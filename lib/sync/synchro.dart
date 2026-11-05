import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:supabase_flutter/supabase_flutter.dart'
    show FileOptions, PostgrestException, StorageException, SupabaseClient;

import '../data/base.dart';
import '../data/depot.dart';
import 'politique.dart';

enum StatutSync { ok, horsLigne, intervalle, dejaEnCours, erreur }

class BilanSync {
  const BilanSync(this.statut, {this.envoyees = 0, this.echecs = 0, this.recues = 0});

  final StatutSync statut;
  final int envoyees;
  final int echecs;
  final int recues;
}

/// Le serveur a refusé l’opération sans erreur SQL : règle RLS (0 ligne modifiée),
/// fiche introuvable, session absente… Sans ce contrôle, une validation admin refusée
/// serait marquée « envoyée » puis perdue.
class RefusServeur implements Exception {
  const RefusServeur(this.message);

  final String message;

  @override
  String toString() => message;
}

const _cleTentative = 'derniere_tentative';
const _cleDerniereSync = 'derniere_sync';
const _actionsConnues = {'insert', 'update', 'delete', 'add_photo'};

/// Synchronisation entre la base locale et Supabase, dans les deux sens.
/// Les noms de colonnes correspondent au schéma réel de la table (cf. supabase/migration_dassa_connect.sql).
class SyncService {
  SyncService(this._depot, this._client);

  final Depot _depot;

  /// Null quand Supabase n’est pas configuré : l’application reste alors en mode local.
  final SupabaseClient? _client;
  SupabaseClient get _c => _client!;
  bool _enCours = false;

  /// Teste une vraie requête : un Wi-Fi sans accès Internet renvoie faux.
  Future<bool> estJoignable() async {
    if (_client == null) return false;
    try {
      await _c.from('prestataires').select('uid').limit(1).timeout(const Duration(seconds: 5));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// [manuelle] : demandée par l’utilisateur, l’intervalle minimal ne s’applique alors pas.
  Future<BilanSync> synchroniser({bool manuelle = false}) async {
    if (_enCours) return const BilanSync(StatutSync.dejaEnCours);
    final maintenant = DateTime.now().toUtc();
    if (!manuelle && !peutSynchroniserApres(await _depot.lireDate(_cleTentative), maintenant)) {
      return const BilanSync(StatutSync.intervalle);
    }
    _enCours = true;
    try {
      if (!await estJoignable()) return const BilanSync(StatutSync.horsLigne);
      await _depot.ecrireDate(_cleTentative, maintenant);
      final envoi = await _pousser();
      final recues = await _tirer();
      await _depot.ecrireDate(_cleDerniereSync, DateTime.now().toUtc());
      return BilanSync(StatutSync.ok, envoyees: envoi.envoyees, echecs: envoi.echecs, recues: recues);
    } catch (_) {
      return const BilanSync(StatutSync.erreur);
    } finally {
      _enCours = false;
    }
  }

  /// Envoi rapide : s’il reste des opérations en attente, on synchronise sans attendre l’intervalle.
  Future<void> envoyerSiEnAttente() async {
    if (_enCours || _client == null) return;
    if ((await _depot.lireActives(limite: 1)).isEmpty) return;
    await synchroniser(manuelle: true);
  }

  // ---------- Envoi de la file ----------

  /// Chaque opération est tentée une fois par synchronisation. Un refus du serveur ne bloque pas les autres.
  Future<({int envoyees, int echecs})> _pousser() async {
    var envoyees = 0;
    var echecs = 0;
    for (final operation in await _depot.lireActives()) {
      if (!_actionsConnues.contains(operation.action)) {
        echecs++;
        await _depot.noterEchec(operation);
        continue;
      }
      try {
        await _envoyer(operation);
        await _depot.acquitter(operation.id);
        envoyees++;
      } on PostgrestException {
        echecs++;
        await _depot.noterEchec(operation);
      } on StorageException {
        echecs++;
        await _depot.noterEchec(operation);
      } on RefusServeur {
        echecs++;
        await _depot.noterEchec(operation);
      } catch (_) {
        // Erreur de transport (probablement hors ligne) : on arrête sans compter cet échec.
        break;
      }
    }
    return (envoyees: envoyees, echecs: echecs);
  }

  Future<void> _envoyer(OperationFile operation) async {
    final donnees = jsonDecode(operation.payload) as Map<String, dynamic>;
    final table = operation.tableCible;
    final cle = donnees['uid'] as String;

    if (operation.action == 'insert') {
      if (table == 'prestataires') donnees['user_id'] = _identifiantSession();
      final audio = donnees.remove('audio_local') as String?;
      if (audio != null) donnees['audio_url'] = await _televerser('voice_notes', audio, cle);
      // Pas de .select() : relire la ligne serait bloqué par RLS pour un client anonyme (commande).
      // Un refus RLS à l’insertion lève déjà une erreur, il n’est donc jamais silencieux.
      await _c.from(table).insert(donnees);
    } else if (operation.action == 'update') {
      donnees.remove('uid');
      final lignes = await _c.from(table).update(donnees).eq('uid', cle).select();
      if (lignes.isEmpty) {
        throw const RefusServeur(
            'Mise à jour refusée : fiche introuvable ou droits insuffisants (session admin requise ?)');
      }
    } else if (operation.action == 'delete') {
      await _c.from(table).delete().eq('uid', cle);
    } else {
      // add_photo : envoi du fichier puis ajout de son URL publique à photos_url.
      final url = await _televerser('prestataire_photos', donnees['photo_local'] as String, cle);
      final actuelle = await _c.from('prestataires').select('photos_url').eq('uid', cle).single();
      final photos = [...((actuelle['photos_url'] as List?) ?? const []), url];
      final lignes = await _c.from('prestataires').update({'photos_url': photos}).eq('uid', cle).select();
      if (lignes.isEmpty) throw const RefusServeur('Ajout de photo refusé par le serveur');
    }
  }

  /// Identifiant de la session courante : exigé par la règle RLS d’insertion des prestataires.
  String _identifiantSession() {
    final id = _c.auth.currentUser?.id;
    if (id == null) throw const RefusServeur('Pas de session Supabase (connexion anonyme requise)');
    return id;
  }

  Future<String> _televerser(String bucket, String cheminLocal, String id) async {
    final brut = cheminLocal.split('?').first.split('.').last.toLowerCase();
    final extension =
        RegExp(r'^[a-z0-9]{2,5}$').hasMatch(brut) ? brut : (bucket == 'voice_notes' ? 'webm' : 'jpg');
    const types = {
      'm4a': 'audio/mp4',
      'webm': 'audio/webm',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
    };

    // XFile lit aussi bien un fichier Android qu’une adresse blob: du navigateur.
    final List<int> octets;
    try {
      octets = await XFile(cheminLocal).readAsBytes();
    } catch (_) {
      throw const StorageException('Fichier local introuvable');
    }

    final nom = '${id}_${DateTime.now().millisecondsSinceEpoch}.$extension';
    await _c.storage.from(bucket).uploadBinary(
          nom,
          Uint8List.fromList(octets),
          fileOptions: FileOptions(contentType: types[extension]),
        );
    return _c.storage.from(bucket).getPublicUrl(nom);
  }

  // ---------- Réception ----------

  Future<int> _tirer() async {
    final prestataires = await _tirerPrestataires();
    await _reconcilierApprouves();
    final monId = await _monIdentifiant();
    final commandes = monId == null ? 0 : await _tirerCommandes(monId);
    return prestataires + commandes;
  }

  /// Le curseur porte sur updated_at, mis à jour par un trigger côté Supabase :
  /// une validation admin remonte donc bien jusqu’aux téléphones des clients.
  Future<int> _tirerPrestataires() async {
    final curseur = await _depot.lireEtat('curseur:prestataires');
    final base = _c.from('prestataires').select();
    final filtre = curseur == null ? base : base.gt('updated_at', curseur);
    final lignes = await filtre.order('updated_at', ascending: true);
    if (lignes.isEmpty) return 0;
    for (final m in lignes) {
      if (await _depot.ligneEnAttente('prestataires', m['uid'] as String)) continue;
      await _depot.sauverPrestataireDistant(_versPrestataire(m));
    }
    await _depot.ecrireEtat('curseur:prestataires', lignes.last['updated_at'] as String);
    return lignes.length;
  }

  /// Le prestataire connecté reçoit les commandes qui lui sont adressées.
  Future<int> _tirerCommandes(String prestataireUid) async {
    final curseur = await _depot.lireEtat('curseur:commandes');
    final base = _c.from('commandes').select().eq('prestataire_uid', prestataireUid);
    final filtre = curseur == null ? base : base.gt('updated_at', curseur);
    final lignes = await filtre.order('updated_at', ascending: true);
    if (lignes.isEmpty) return 0;
    for (final m in lignes) {
      if (await _depot.ligneEnAttente('commandes', m['uid'] as String)) continue;
      await _depot.sauverCommandeDistante(_versCommande(m));
    }
    await _depot.ecrireEtat('curseur:commandes', lignes.last['updated_at'] as String);
    return lignes.length;
  }

  /// Un client ne reçoit plus les fiches retirées du catalogue (elles ne lui sont plus lisibles),
  /// donc aucune mise à jour ne lui parvient. On compare la liste des fiches validées sur le serveur
  /// avec celle de l’appareil, et on retire les fiches qui ne le sont plus.
  Future<void> _reconcilierApprouves() async {
    final lignes = await _c.from('prestataires').select('uid').eq('statut', 'approved');
    final validees = {for (final m in lignes) m['uid'] as String};
    for (final uid in await _depot.uidsApprouves()) {
      if (validees.contains(uid)) continue;
      if (await _depot.ligneEnAttente('prestataires', uid)) continue;
      await _depot.marquerNonValidee(uid);
    }
  }

  /// Identifiant du prestataire connecté, retrouvé grâce au numéro enregistré sur le téléphone.
  Future<String?> _monIdentifiant() async {
    final telephone = await _depot.lireEtat('telephone');
    if (telephone == null) return null;
    return (await _depot.prestataireParNumero(telephone))?.uid;
  }

  PrestatairesCompanion _versPrestataire(Map<String, dynamic> m) => PrestatairesCompanion(
        uid: Value(m['uid'] as String),
        nom: Value((m['nom'] as String?) ?? ''),
        categorie: Value((m['categorie'] as String?) ?? ''),
        quartier: Value((m['quartier'] as String?) ?? ''),
        description: Value((m['description'] as String?) ?? ''),
        prixBase: Value(((m['prix_base'] as num?) ?? 0).toInt()),
        photos: Value(jsonEncode((m['photos_url'] as List?) ?? const [])),
        tarifs: Value(jsonEncode((m['tarifs'] as List?) ?? const [])),
        telephone: Value((m['telephone'] as String?) ?? ''),
        statut: Value((m['statut'] as String?) ?? 'pending'),
        vues: Value(((m['vues'] as num?) ?? 0).toInt()),
        updatedAt: Value(DateTime.parse(m['updated_at'] as String)),
      );

  CommandesCompanion _versCommande(Map<String, dynamic> m) => CommandesCompanion(
        uid: Value(m['uid'] as String),
        clientTelephone: Value((m['client_telephone'] as String?) ?? ''),
        prestataireUid: Value(m['prestataire_uid'] as String),
        messageTexte: Value(m['message'] as String?),
        audioUrl: Value(m['audio_url'] as String?),
        audioDuree: Value(((m['audio_duree'] as num?) ?? 0).toInt()),
        montant: Value(((m['montant'] as num?) ?? 0).toInt()),
        statut: Value((m['statut'] as String?) ?? 'nouvelle'),
        creeLe: Value(DateTime.parse(m['cree_le'] as String)),
        updatedAt: Value(DateTime.parse(m['updated_at'] as String)),
      );
}
