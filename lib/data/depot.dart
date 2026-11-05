import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../utils.dart';
import 'base.dart';
import 'fil.dart';
import 'lecture.dart';

/// Au-delà de ce nombre d'échecs, une opération sort de la file active et reste « en erreur ».
const int seuilEchecs = 5;

const _uuid = Uuid();

/// Toutes les lectures et écritures locales. Chaque écriture ajoute aussi une opération
/// à la file d'envoi, dans la même transaction.
class Depot {
  Depot(this.db);

  final AppDatabase db;

  // ---------- Prestataires ----------

  /// Ce que voit le client : uniquement les fiches validées par l'admin.
  Stream<List<PrestataireLocal>> surveillerCatalogue() => (db.select(db.prestataires)
        ..where((t) => t.statut.equals('approved'))
        ..orderBy([(t) => OrderingTerm.asc(t.nom)]))
      .watch();

  Stream<List<PrestataireLocal>> surveillerEnAttente() =>
      (db.select(db.prestataires)..where((t) => t.statut.equals('pending'))).watch();

  Stream<List<PrestataireLocal>> surveillerTous() => db.select(db.prestataires).watch();

  /// La fiche du prestataire connecté sur ce téléphone (null pour un client).
  Stream<PrestataireLocal?> surveillerMonPrestataire() {
    return Stream.fromFuture(lireEtat('telephone')).asyncExpand((tel) {
      if (tel == null) return Stream<PrestataireLocal?>.value(null);
      return surveillerTous().map<PrestataireLocal?>((liste) {
        for (final p in liste) {
          if (memeNumero(p.telephone, tel)) return p;
        }
        return null;
      });
    });
  }

  /// Retrouve un prestataire par son numéro, quel que soit le format enregistré.
  Future<PrestataireLocal?> prestataireParNumero(String numero) async {
    final tous = await db.select(db.prestataires).get();
    for (final p in tous) {
      if (memeNumero(p.telephone, numero)) return p;
    }
    return null;
  }

  Future<PrestataireLocal?> prestataireParUid(String uid) =>
      (db.select(db.prestataires)..where((t) => t.uid.equals(uid))).getSingleOrNull();

  /// Crée ou met à jour la fiche. [nouvellesPhotos] : photos en data URL (versDataUrl).
  /// [tarifs] null = ne pas modifier les tarifs existants.
  Future<String> creerOuMajPrestataire({
    required String telephone,
    required String nom,
    required String categorie,
    required String quartier,
    String description = '',
    int prixBase = 0,
    List<String> nouvellesPhotos = const [],
    List<Map<String, dynamic>>? tarifs,
  }) async {
    final existant = await prestataireParNumero(telephone);
    final uid = existant?.uid ?? _uuid.v4();
    final maintenant = DateTime.now().toUtc();
    final photos = [...?existant?.photosList, ...nouvellesPhotos];

    await db.transaction(() async {
      await db.into(db.prestataires).insertOnConflictUpdate(PrestatairesCompanion(
            uid: Value(uid),
            nom: Value(nom),
            categorie: Value(categorie),
            quartier: Value(quartier),
            description: Value(description),
            prixBase: Value(prixBase),
            photos: Value(jsonEncode(photos)),
            tarifs: Value(jsonEncode(tarifs ?? existant?.tarifsList ?? const [])),
            telephone: Value(telephone),
            statut: Value(existant?.statut ?? 'pending'),
            vues: Value(existant?.vues ?? 0),
            updatedAt: Value(maintenant),
          ));

      // Le statut n'est JAMAIS envoyé ici : seul l'admin le change.
      final distant = <String, dynamic>{
        'uid': uid,
        'nom': nom,
        'categorie': categorie,
        'quartier': quartier,
        'description': description,
        'prix_base': prixBase,
        'telephone': telephone,
        if (tarifs != null) 'tarifs': tarifs,
      };
      await _ajouter('prestataires', uid, existant == null ? 'insert' : 'update', distant);
      for (final image in nouvellesPhotos) {
        await _ajouter('prestataires', uid, 'add_photo', {'uid': uid, 'photo_data': image});
      }
    });
    return uid;
  }

  Future<void> supprimerPrestataire(String uid) async {
    await db.transaction(() async {
      await (db.delete(db.prestataires)..where((t) => t.uid.equals(uid))).go();
      await _ajouter('prestataires', uid, 'delete', {'uid': uid});
    });
  }

  Future<void> changerStatutPrestataire(String uid, String statut) =>
      _modifierFiche(uid, PrestatairesCompanion(statut: Value(statut)), {'statut': statut});

  Future<void> changerPrix(String uid, int prix) =>
      _modifierFiche(uid, PrestatairesCompanion(prixBase: Value(prix)), {'prix_base': prix});

  /// Photo ajoutée : visible tout de suite (data URL), envoyée au serveur ensuite.
  Future<void> ajouterPhoto(String uid, String dataUrl) async {
    await db.transaction(() async {
      final ligne =
          await (db.select(db.prestataires)..where((t) => t.uid.equals(uid))).getSingleOrNull();
      if (ligne != null) {
        await (db.update(db.prestataires)..where((t) => t.uid.equals(uid))).write(
              PrestatairesCompanion(
                photos: Value(jsonEncode([...ligne.photosList, dataUrl])),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            );
      }
      await _ajouter('prestataires', uid, 'add_photo', {'uid': uid, 'photo_data': dataUrl});
    });
  }

  Future<void> _modifierFiche(
      String uid, PrestatairesCompanion changements, Map<String, dynamic> donnees) async {
    await db.transaction(() async {
      await (db.update(db.prestataires)..where((t) => t.uid.equals(uid))).write(changements);
      await _ajouter('prestataires', uid, 'update', {'uid': uid, ...donnees});
    });
  }

  Future<void> sauverPrestataireDistant(PrestatairesCompanion ligne) async {
    await db.into(db.prestataires).insertOnConflictUpdate(ligne);
  }

  // ---------- Commandes ----------

  Stream<List<CommandeLocale>> surveillerToutesCommandes() => _commandesTriees(null);

  Stream<List<CommandeLocale>> surveillerCommandesClient() => surveillerToutesCommandes();

  Stream<List<CommandeLocale>> surveillerCommandesPrestataire(String prestataireUid) =>
      _commandesTriees(prestataireUid);

  /// Les commandes du prestataire connecté sur ce téléphone (liste vide pour un client).
  Stream<List<CommandeLocale>> surveillerCommandesMoi() {
    return surveillerMonPrestataire().asyncExpand((moi) {
      if (moi == null) return Stream<List<CommandeLocale>>.value(const []);
      return surveillerCommandesPrestataire(moi.uid);
    });
  }

  Stream<CommandeLocale?> surveillerCommande(String uid) =>
      (db.select(db.commandes)..where((t) => t.uid.equals(uid))).watchSingleOrNull();

  Stream<List<CommandeLocale>> _commandesTriees(String? prestataireUid) {
    final requete = db.select(db.commandes)..orderBy([(t) => OrderingTerm.desc(t.creeLe)]);
    if (prestataireUid != null) {
      requete.where((t) => t.prestataireUid.equals(prestataireUid));
    }
    return requete.watch();
  }

  /// Toutes les commandes de cet appareil, la plus récente d'abord.
  Future<List<CommandeLocale>> lireToutesCommandes() =>
      (db.select(db.commandes)..orderBy([(t) => OrderingTerm.desc(t.creeLe)])).get();

  /// Les commandes d'une conversation, la plus récente d'abord.
  Future<List<CommandeLocale>> commandesDuFil(String role, String cle) async {
    final toutes = await lireToutesCommandes();
    return toutes.where((c) => cleFil(role, c) == cle).toList();
  }

  /// Crée la première commande d'une conversation. Un message vocal est gardé en mémoire
  /// (octets) : il est envoyé même si la page est rechargée entre-temps.
  Future<String> creerCommande({
    required String clientTelephone,
    required String prestataireUid,
    String? message,
    Uint8List? audioBytes,
    int duree = 0,
  }) async {
    final uid = _uuid.v4();
    final maintenant = DateTime.now().toUtc();
    await db.transaction(() async {
      await db.into(db.commandes).insert(CommandesCompanion.insert(
            uid: uid,
            clientTelephone: clientTelephone,
            prestataireUid: prestataireUid,
            messageTexte: Value(message),
            audioLocal: Value(audioBytes == null ? null : 'audio_en_attente'),
            audioDuree: Value(duree),
            creeLe: maintenant,
            updatedAt: maintenant,
          ));
      await _ajouter('commandes', uid, 'insert', {
        'uid': uid,
        'client_telephone': clientTelephone,
        'prestataire_uid': prestataireUid,
        'message': message,
        'audio_duree': duree,
        'statut': 'nouvelle',
        if (audioBytes != null) 'audio_b64': base64Encode(audioBytes),
      });
    });
    return uid;
  }

  Future<void> changerStatutCommande(String uid, String statut) async {
    await db.transaction(() async {
      await (db.update(db.commandes)..where((t) => t.uid.equals(uid))).write(CommandesCompanion(
            statut: Value(statut),
            updatedAt: Value(DateTime.now().toUtc()),
          ));
      await _ajouter('commandes', uid, 'update', {'uid': uid, 'statut': statut});
    });
  }

  Future<void> sauverCommandeDistante(CommandesCompanion ligne) async {
    await db.into(db.commandes).insertOnConflictUpdate(ligne);
  }

  // ---------- Messages ----------

  /// Messages pas encore arrivés au serveur (« en cours d'envoi » ou « échec »).
  Stream<List<Map<String, dynamic>>> surveillerOperationsMessages() {
    final flux =
        (db.select(db.fileAttente)..where((t) => t.tableCible.equals('commande_messages'))).watch();
    return flux.map((lignes) => lignes.map(_versMessageEnAttente).toList());
  }

  Stream<List<Map<String, dynamic>>> operationsMessages(String commandeUid) =>
      surveillerOperationsMessages()
          .map((liste) => liste.where((p) => p['commande_uid'] == commandeUid).toList());

  Map<String, dynamic> _versMessageEnAttente(OperationFile l) {
    final p = jsonDecode(l.payload) as Map<String, dynamic>;
    p.remove('audio_b64');
    p['cree_le'] = l.creeLe.toUtc().toIso8601String();
    p['erreur'] = l.tentatives >= seuilEchecs;
    return p;
  }

  /// Envoie un message (texte, vocal, ou les deux) dans une commande.
  Future<String> envoyerMessage({
    required String commandeUid,
    required String auteur,
    String? texte,
    Uint8List? audioBytes,
    int duree = 0,
  }) async {
    final uid = _uuid.v4();
    await _ajouter('commande_messages', uid, 'insert', {
      'uid': uid,
      'commande_uid': commandeUid,
      'auteur': auteur,
      'texte': texte,
      'audio_duree': duree,
      if (audioBytes != null) 'audio_b64': base64Encode(audioBytes),
    });
    return uid;
  }

  /// Mémorise l'heure de lecture d'une conversation (pastilles « non lu »).
  Future<void> marquerLu(String role, String cle) =>
      ecrireEtat(cleLu(role, cle), DateTime.now().toUtc().toIso8601String());

  // ---------- Recherches ----------

  Future<void> creerRecherche(String audioLocal) async {
    final uid = _uuid.v4();
    await db.transaction(() async {
      await db.into(db.recherches).insert(RecherchesCompanion.insert(
            uid: uid,
            audioLocal: Value(audioLocal),
            creeLe: DateTime.now().toUtc(),
          ));
      await _ajouter('recherches', uid, 'insert', {
        'uid': uid,
        'client_telephone': '',
        'audio_local': audioLocal,
      });
    });
  }

  // ---------- File d'attente ----------

  Future<void> _ajouter(String table, String ligneId, String action, Map<String, dynamic> donnees) =>
      db.into(db.fileAttente).insert(FileAttenteCompanion.insert(
            id: _uuid.v4(),
            tableCible: table,
            ligneId: ligneId,
            action: action,
            payload: jsonEncode(donnees),
            creeLe: DateTime.now().toUtc(),
          ));

  Stream<List<OperationFile>> surveillerActives() => (db.select(db.fileAttente)
        ..where((t) => t.tentatives.isSmallerThanValue(seuilEchecs)))
      .watch();

  Stream<int> nombreActives() => surveillerActives().map((liste) => liste.length);

  Stream<int> nombreEnErreur() => (db.select(db.fileAttente)
        ..where((t) => t.tentatives.isBiggerOrEqualValue(seuilEchecs)))
      .watch()
      .map((liste) => liste.length);

  /// Opérations encore à envoyer. À seconde égale, on envoie insert avant update,
  /// puis les photos, puis les suppressions.
  Future<List<OperationFile>> lireActives({int limite = 500}) async {
    final operations = await (db.select(db.fileAttente)
          ..where((t) => t.tentatives.isSmallerThanValue(seuilEchecs))
          ..orderBy([(t) => OrderingTerm.asc(t.creeLe)])
          ..limit(limite))
        .get();
    final triees = [...operations]..sort((a, b) {
        final parDate = a.creeLe.compareTo(b.creeLe);
        return parDate != 0 ? parDate : _rangAction(a.action).compareTo(_rangAction(b.action));
      });
    return triees;
  }

  int _rangAction(String action) => switch (action) {
        'insert' => 0,
        'update' => 1,
        'add_photo' => 2,
        'delete' => 3,
        _ => 4,
      };

  /// Vrai si une modification de cette ligne attend encore d'être envoyée.
  Future<bool> ligneEnAttente(String table, String ligneId) async {
    final operations = await (db.select(db.fileAttente)
          ..where((t) => t.tableCible.equals(table) & t.ligneId.equals(ligneId)))
        .get();
    return operations.isNotEmpty;
  }

  /// Uids des fiches que cet appareil considère validées.
  Future<List<String>> uidsApprouves() async {
    final lignes = await (db.select(db.prestataires)..where((t) => t.statut.equals('approved'))).get();
    return lignes.map((p) => p.uid).toList();
  }

  /// Retire une fiche du catalogue local SANS passer par la file (rien n'est renvoyé au serveur).
  Future<void> marquerNonValidee(String uid) async {
    await (db.update(db.prestataires)..where((t) => t.uid.equals(uid))).write(
          const PrestatairesCompanion(statut: Value('pending')),
        );
  }

  /// Remet en file les opérations refusées, pour un nouvel essai.
  Future<void> reessayerEnErreur() async {
    await (db.update(db.fileAttente)..where((t) => t.tentatives.isBiggerOrEqualValue(seuilEchecs))).write(
          const FileAttenteCompanion(tentatives: Value(0)),
        );
  }

  /// Met à jour le contenu d'une opération (ex. adresse de photo déjà envoyée).
  Future<void> majPayload(String id, Map<String, dynamic> donnees) async {
    await (db.update(db.fileAttente)..where((t) => t.id.equals(id))).write(
          FileAttenteCompanion(payload: Value(jsonEncode(donnees))),
        );
  }

  Future<void> acquitter(String id) async {
    await (db.delete(db.fileAttente)..where((t) => t.id.equals(id))).go();
  }

  Future<void> noterEchec(OperationFile operation) async {
    await (db.update(db.fileAttente)..where((t) => t.id.equals(operation.id))).write(
          FileAttenteCompanion(tentatives: Value(operation.tentatives + 1)),
        );
  }

  // ---------- Valeurs persistantes ----------

  Stream<String?> surveillerEtat(String cle) => (db.select(db.etatSync)
        ..where((t) => t.cle.equals(cle)))
      .watchSingleOrNull()
      .map((ligne) => ligne?.valeur);

  Future<String?> lireEtat(String cle) async {
    final ligne = await (db.select(db.etatSync)..where((t) => t.cle.equals(cle))).getSingleOrNull();
    return ligne?.valeur;
  }

  Future<void> ecrireEtat(String cle, String valeur) async {
    await db.into(db.etatSync).insertOnConflictUpdate(EtatSyncCompanion.insert(cle: cle, valeur: valeur));
  }

  Future<void> supprimerEtat(String cle) async {
    await (db.delete(db.etatSync)..where((t) => t.cle.equals(cle))).go();
  }

  Future<DateTime?> lireDate(String cle) async {
    final valeur = await lireEtat(cle);
    return valeur == null ? null : DateTime.parse(valeur);
  }

  Future<void> ecrireDate(String cle, DateTime date) => ecrireEtat(cle, date.toUtc().toIso8601String());
}
