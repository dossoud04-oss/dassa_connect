import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'base.dart';

/// Au-delà de ce nombre d’échecs, une opération sort de la file active et reste « en erreur ».
const int seuilEchecs = 5;

const _uuid = Uuid();

/// Toutes les lectures et écritures locales.
/// Chaque écriture ajoute aussi une opération à la file, dans la même transaction.
class Depot {
  Depot(this.db);

  final AppDatabase db;

  // ---------- Catalogue et prestataires ----------

  Stream<List<PrestataireLocal>> surveillerCatalogue() => (db.select(db.prestataires)
        ..where((t) => t.statut.equals('approved'))
        ..orderBy([(t) => OrderingTerm.asc(t.nom)]))
      .watch();

  Stream<List<PrestataireLocal>> surveillerEnAttente() =>
      (db.select(db.prestataires)..where((t) => t.statut.equals('pending'))).watch();

  Stream<List<PrestataireLocal>> surveillerTous() => db.select(db.prestataires).watch();

  Future<PrestataireLocal?> prestataireParTelephone(String telephone) =>
      (db.select(db.prestataires)..where((t) => t.telephone.equals(telephone))).getSingleOrNull();

  Future<void> sauverPrestataires(List<PrestatairesCompanion> lignes) async {
    await db.batch((b) => b.insertAllOnConflictUpdate(db.prestataires, lignes));
  }

  Future<void> changerStatutPrestataire(String uid, String statut) =>
      _modifierFiche(uid, PrestatairesCompanion(statut: Value(statut)), {'statut': statut});

  Future<void> changerPrix(String uid, int prix) =>
      _modifierFiche(uid, PrestatairesCompanion(prixBase: Value(prix)), {'prix_base': prix});

  Future<void> ajouterPhoto(String uid, String cheminLocal) async {
    await db.transaction(() async {
      await _ajouter('prestataires', uid, 'add_photo', {'id': uid, 'photo_local': cheminLocal});
    });
  }

  Future<void> _modifierFiche(String uid, PrestatairesCompanion changements, Map<String, dynamic> donnees) async {
    await db.transaction(() async {
      await (db.update(db.prestataires)..where((t) => t.uid.equals(uid))).write(changements);
      await _ajouter('prestataires', uid, 'update', {'id': uid, ...donnees});
    });
  }

  Future<void> sauverPrestataireDistant(PrestatairesCompanion ligne) async {
    await db.into(db.prestataires).insertOnConflictUpdate(ligne);
  }

  // ---------- Commandes ----------

  Stream<List<CommandeLocale>> surveillerCommandesClient() =>
      (db.select(db.commandes)..orderBy([(t) => OrderingTerm.desc(t.creeLe)])).watch();

  Stream<List<CommandeLocale>> surveillerCommandesPrestataire(String prestataireUid) => (db.select(db.commandes)
        ..where((t) => t.prestataireUid.equals(prestataireUid))
        ..orderBy([(t) => OrderingTerm.desc(t.creeLe)]))
      .watch();

  Future<String> creerCommande({
    required String clientTelephone,
    required String prestataireUid,
    String? message,
    String? audioLocal,
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
            audioLocal: Value(audioLocal),
            audioDuree: Value(duree),
            creeLe: maintenant,
            updatedAt: maintenant,
          ));
      await _ajouter('commandes', uid, 'insert', {
        'id': uid,
        'client_telephone': clientTelephone,
        'prestataire_id': prestataireUid,
        'message_texte': message,
        'audio_duration': duree,
        'statut': 'nouvelle',
        if (audioLocal != null) 'audio_local': audioLocal,
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
      await _ajouter('commandes', uid, 'update', {'id': uid, 'statut': statut});
    });
  }

  Future<void> sauverCommandeDistante(CommandesCompanion ligne) async {
    await db.into(db.commandes).insertOnConflictUpdate(ligne);
  }

  // ---------- Recherches vocales ----------

  Future<void> creerRecherche(String audioLocal) async {
    final uid = _uuid.v4();
    await db.transaction(() async {
      await db.into(db.recherches).insert(RecherchesCompanion.insert(
            uid: uid,
            audioLocal: Value(audioLocal),
            creeLe: DateTime.now().toUtc(),
          ));
      await _ajouter('voice_searches', uid, 'insert', {
        'id': uid,
        'client_telephone': '',
        'audio_local': audioLocal,
      });
    });
  }

  // ---------- File d’attente ----------

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

  /// Opérations encore à envoyer, les plus anciennes d’abord.
  Future<List<OperationFile>> lireActives({int limite = 500}) => (db.select(db.fileAttente)
        ..where((t) => t.tentatives.isSmallerThanValue(seuilEchecs))
        ..orderBy([(t) => OrderingTerm.asc(t.creeLe)])
        ..limit(limite))
      .get();

  /// Vrai si une modification de cette ligne attend encore d’être envoyée.
  Future<bool> ligneEnAttente(String table, String ligneId) async {
    final operations = await (db.select(db.fileAttente)
          ..where((t) => t.tableCible.equals(table) & t.ligneId.equals(ligneId)))
        .get();
    return operations.isNotEmpty;
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
