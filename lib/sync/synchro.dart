import 'dart:convert';
import 'dart:typed_data';

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

const _cleTentative = 'derniere_tentative';
const _cleDerniereSync = 'derniere_sync';
const _actionsConnues = {'insert', 'update', 'add_photo'};

/// Synchronisation entre la base locale et Supabase, dans les deux sens.
/// Reprend le fonctionnement éprouvé du projet DassaServices : curseurs par table,
/// isolement des opérations en échec, protection des modifications locales en attente.
class SyncService {
  SyncService(this._depot, this._client);

  final Depot _depot;
  /// Null quand Supabase n'est pas configuré : l'application reste alors en mode local.
  final SupabaseClient? _client;
  SupabaseClient get _c => _client!;
  bool _enCours = false;

  /// Teste une vraie requête : un Wi-Fi sans accès Internet renvoie faux.
  Future<bool> estJoignable() async {
    if (_client == null) return false;
    try {
      await _c.from('prestataires').select('id').limit(1).timeout(const Duration(seconds: 5));
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

  /// Envoi rapide : s'il reste des opérations en attente, on synchronise sans attendre l'intervalle.
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
      } catch (_) {
        // Erreur de transport, probablement hors ligne : on arrête sans compter cet échec.
        break;
      }
    }
    return (envoyees: envoyees, echecs: echecs);
  }

  Future<void> _envoyer(OperationFile operation) async {
    final donnees = jsonDecode(operation.payload) as Map<String, dynamic>;
    final id = donnees['id'] as String;
    if (operation.action == 'insert') {
      if (donnees.containsKey('audio_local')) {
        final chemin = donnees.remove('audio_local') as String;
        donnees['audio_url'] = await _televerser('voice_notes', chemin, id);
      }
      await _c.from(operation.tableCible).insert(donnees);
    } else if (operation.action == 'update') {
      await _c.from(operation.tableCible).update(donnees).eq('id', id);
    } else {
      final url = await _televerser('prestataire_photos', donnees['photo_local'] as String, id);
      final actuelle = await _c.from('prestataires').select('photos_url').eq('id', id).single();
      final photos = [...((actuelle['photos_url'] as List?) ?? const []), url];
      await _c.from('prestataires').update({'photos_url': photos}).eq('id', id);
    }
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

    // XFile lit aussi bien un fichier Android qu'une adresse blob: du navigateur.
    final List<int> octets;
    try {
      octets = await XFile(cheminLocal).readAsBytes();
    } catch (_) {
      throw StorageException('Fichier local introuvable');
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
    final monId = await _monIdentifiant();
    final commandes = monId == null ? 0 : await _tirerCommandes(monId);
    return prestataires + commandes;
  }

  Future<int> _tirerPrestataires() async {
    final curseur = await _depot.lireEtat('curseur:prestataires');
    final base = _c.from('prestataires').select();
    final filtre = curseur == null ? base : base.gt('updated_at', curseur);
    final lignes = await filtre.order('updated_at', ascending: true);
    if (lignes.isEmpty) return 0;
    for (final m in lignes) {
      if (await _depot.ligneEnAttente('prestataires', m['id'] as String)) continue;
      await _depot.sauverPrestataireDistant(_versPrestataire(m));
    }
    await _depot.ecrireEtat('curseur:prestataires', lignes.last['updated_at'] as String);
    return lignes.length;
  }

  /// Le prestataire connecté reçoit les commandes qui lui sont adressées.
  Future<int> _tirerCommandes(String prestataireId) async {
    final curseur = await _depot.lireEtat('curseur:commandes');
    final base = _c.from('commandes').select().eq('prestataire_id', prestataireId);
    final filtre = curseur == null ? base : base.gt('updated_at', curseur);
    final lignes = await filtre.order('updated_at', ascending: true);
    if (lignes.isEmpty) return 0;
    for (final m in lignes) {
      if (await _depot.ligneEnAttente('commandes', m['id'] as String)) continue;
      await _depot.sauverCommandeDistante(_versCommande(m));
    }
    await _depot.ecrireEtat('curseur:commandes', lignes.last['updated_at'] as String);
    return lignes.length;
  }

  /// Identifiant du prestataire connecté, retrouvé grâce au numéro enregistré sur le téléphone.
  Future<String?> _monIdentifiant() async {
    final telephone = await _depot.lireEtat('telephone');
    if (telephone == null) return null;
    return (await _depot.prestataireParNumero(telephone))?.uid;
  }

  PrestatairesCompanion _versPrestataire(Map<String, dynamic> m) => PrestatairesCompanion(
        uid: Value(m['id'] as String),
        nom: Value(m['nom'] as String),
        categorie: Value(m['categorie'] as String),
        quartier: Value(m['quartier'] as String),
        description: Value((m['description'] as String?) ?? ''),
        prixBase: Value(((m['prix_base'] as num?) ?? 0).toInt()),
        photos: Value(jsonEncode((m['photos_url'] as List?) ?? const [])),
        tarifs: Value(jsonEncode((m['tarifs'] as List?) ?? const [])),
        telephone: Value(m['telephone'] as String),
        statut: Value(m['statut'] as String),
        vues: Value(((m['vues'] as num?) ?? 0).toInt()),
        updatedAt: Value(DateTime.parse(m['updated_at'] as String)),
      );

  CommandesCompanion _versCommande(Map<String, dynamic> m) => CommandesCompanion(
        uid: Value(m['id'] as String),
        clientTelephone: Value(m['client_telephone'] as String),
        prestataireUid: Value(m['prestataire_id'] as String),
        messageTexte: Value(m['message_texte'] as String?),
        audioUrl: Value(m['audio_url'] as String?),
        audioDuree: Value(((m['audio_duration'] as num?) ?? 0).toInt()),
        montant: Value(((m['montant'] as num?) ?? 0).toInt()),
        statut: Value(m['statut'] as String),
        creeLe: Value(DateTime.parse(m['created_at'] as String)),
        updatedAt: Value(DateTime.parse(m['updated_at'] as String)),
      );
}
