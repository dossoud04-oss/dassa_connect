import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:supabase_flutter/supabase_flutter.dart'
    show FileOptions, PostgrestException, StorageException, SupabaseClient;

import '../data/base.dart';
import '../data/depot.dart';
import '../data/images.dart';
import 'politique.dart';

enum StatutSync { ok, horsLigne, intervalle, dejaEnCours, erreur }

class BilanSync {
  const BilanSync(this.statut, {this.envoyees = 0, this.echecs = 0, this.recues = 0});

  final StatutSync statut;
  final int envoyees;
  final int echecs;
  final int recues;
}

/// Le serveur a refusé l’opération sans erreur SQL (RLS : 0 ligne modifiée, fiche introuvable, session absente…).
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

  /// [manuelle] : demandée par l’utilisateur ou par le rafraîchissement automatique.
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

  /// Une opération en échec ne bloque plus les suivantes. Seule une coupure réseau arrête la boucle.
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
        // Hors ligne : on arrête. Sinon, seule cette opération compte en échec.
        if (!await estJoignable()) break;
        echecs++;
        await _depot.noterEchec(operation);
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
      if (table == 'commandes') donnees['client_user_id'] ??= _identifiantSession();

      final audioLocal = donnees.remove('audio_local') as String?;
      final audioB64 = donnees.remove('audio_b64') as String?;
      if (audioB64 != null) {
        donnees['audio_url'] = await _televerserOctets('voice_notes', base64Decode(audioB64), cle);
      } else if (audioLocal != null) {
        donnees['audio_url'] = await _televerser('voice_notes', audioLocal, cle);
      }
      // Pas de .select() : relire la ligne serait bloqué par RLS pour un client. Un refus lève une erreur.
      await _c.from(table).insert(donnees);
    } else if (operation.action == 'update') {
      donnees.remove('uid');
      final lignes = await _c.from(table).update(donnees).eq('uid', cle).select();
      if (lignes.isEmpty) {
        throw const RefusServeur('Mise à jour refusée : fiche introuvable ou droits insuffisants');
      }
    } else if (operation.action == 'delete') {
      await _c.from(table).delete().eq('uid', cle);
    } else {
      // add_photo : l'image n'est envoyée qu'une fois (son adresse est gardée dans la file),
      // puis ajoutée à photos_url. Une relance ne renvoie donc pas deux fois la même image.
      var url = donnees['photo_url'] as String?;
      if (url == null) {
        url = await _televerserOctets('prestataire_photos', decoderDataUrl(donnees['photo_data'] as String), cle);
        donnees['photo_url'] = url;
        await _depot.majPayload(operation.id, donnees);
      }
      final actuelle = await _c.from('prestataires').select('photos_url').eq('uid', cle).single();
      final courantes = (actuelle['photos_url'] as List?) ?? const [];
      final photos = courantes.contains(url) ? courantes : [...courantes, url];
      final lignes = await _c.from('prestataires').update({'photos_url': photos}).eq('uid', cle).select();
      if (lignes.isEmpty) throw const RefusServeur('Ajout de photo refusé par le serveur');
    }
  }

  /// Identifiant de la session courante : exigé par les règles RLS d’écriture.
  String _identifiantSession() {
    final id = _c.auth.currentUser?.id;
    if (id == null) throw const RefusServeur('Pas de session Supabase (connexion anonyme requise)');
    return id;
  }

  /// Format détecté d’après le contenu du fichier (et non d’après son nom).
  ({String extension, String mime}) _formatFichier(Uint8List octets, String bucket) {
    bool commence(List<int> signature, [int decalage = 0]) {
      if (octets.length < decalage + signature.length) return false;
      for (var i = 0; i < signature.length; i++) {
        if (octets[decalage + i] != signature[i]) return false;
      }
      return true;
    }

    if (commence([0x1A, 0x45, 0xDF, 0xA3])) return (extension: 'webm', mime: 'audio/webm');
    if (commence([0x4F, 0x67, 0x67, 0x53])) return (extension: 'ogg', mime: 'audio/ogg');
    if (commence([0x66, 0x74, 0x79, 0x70], 4)) return (extension: 'm4a', mime: 'audio/mp4');
    if (commence([0x52, 0x49, 0x46, 0x46])) return (extension: 'wav', mime: 'audio/wav');
    if (commence([0xFF, 0xD8, 0xFF])) return (extension: 'jpg', mime: 'image/jpeg');
    if (commence([0x89, 0x50, 0x4E, 0x47])) return (extension: 'png', mime: 'image/png');
    return bucket == 'voice_notes'
        ? (extension: 'm4a', mime: 'audio/mp4')
        : (extension: 'jpg', mime: 'image/jpeg');
  }

  Future<String> _televerserOctets(String bucket, Uint8List octets, String id) async {
    final format = _formatFichier(octets, bucket);
    final nom = '${id}_${DateTime.now().millisecondsSinceEpoch}.${format.extension}';
    await _c.storage.from(bucket).uploadBinary(
          nom,
          octets,
          fileOptions: FileOptions(contentType: format.mime),
        );
    return _c.storage.from(bucket).getPublicUrl(nom);
  }

  /// Envoie un fichier local (chemin ou adresse blob:) vers le Storage.
  Future<String> _televerser(String bucket, String cheminLocal, String id) async {
    final List<int> octets;
    try {
      octets = await XFile(cheminLocal).readAsBytes();
    } catch (_) {
      throw const StorageException('Fichier local introuvable');
    }
    return _televerserOctets(bucket, Uint8List.fromList(octets), id);
  }

  // ---------- Réception ----------

  Future<int> _tirer() async {
    final prestataires = await _tirerPrestataires();
    await _reconcilierApprouves();
    final commandes = await _tirerCommandes();
    return prestataires + commandes;
  }

  /// Le curseur porte sur updated_at, mis à jour par un trigger côté Supabase.
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

  /// Un client reçoit ses commandes ; un prestataire reçoit celles qui lui sont adressées.
  /// Les règles RLS limitent de toute façon ce qui est renvoyé.
  Future<int> _tirerCommandes() async {
    final utilisateur = _c.auth.currentUser;
    if (utilisateur == null) return 0;
    final prestataireUid = await _monIdentifiant();
    final curseur = await _depot.lireEtat('curseur:commandes');
    // Compte administrateur (session non anonyme) : les règles RLS lui ouvrent toutes les commandes.
    final base = !utilisateur.isAnonymous
        ? _c.from('commandes').select()
        : prestataireUid == null
            ? _c.from('commandes').select().eq('client_user_id', utilisateur.id)
            : _c
                .from('commandes')
                .select()
                .or('client_user_id.eq.${utilisateur.id},prestataire_uid.eq.$prestataireUid');
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

  /// Un client ne reçoit plus les fiches retirées du catalogue : on compare avec la liste validée du serveur.
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

  /// La version serveur fait foi : le message vocal local n’est plus nécessaire une fois reçu.
  CommandesCompanion _versCommande(Map<String, dynamic> m) => CommandesCompanion(
        uid: Value(m['uid'] as String),
        clientTelephone: Value((m['client_telephone'] as String?) ?? ''),
        prestataireUid: Value(m['prestataire_uid'] as String),
        messageTexte: Value(m['message'] as String?),
        audioLocal: const Value(null),
        audioUrl: Value(m['audio_url'] as String?),
        audioDuree: Value(((m['audio_duree'] as num?) ?? 0).toInt()),
        montant: Value(((m['montant'] as num?) ?? 0).toInt()),
        statut: Value((m['statut'] as String?) ?? 'nouvelle'),
        creeLe: Value(DateTime.parse(m['cree_le'] as String)),
        updatedAt: Value(DateTime.parse(m['updated_at'] as String)),
      );
}
