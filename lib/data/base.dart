import 'package:drift/drift.dart';

part 'base.g.dart';

/// Copie locale de la table `prestataires`. Les photos et tarifs sont stockés en JSON.
@DataClassName('PrestataireLocal')
class Prestataires extends Table {
  TextColumn get uid => text()();
  TextColumn get nom => text()();
  TextColumn get categorie => text()();
  TextColumn get quartier => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get prixBase => integer().withDefault(const Constant(0))();
  TextColumn get photos => text().withDefault(const Constant('[]'))();
  TextColumn get tarifs => text().withDefault(const Constant('[]'))();
  TextColumn get telephone => text()();
  TextColumn get statut => text().withDefault(const Constant('pending'))();
  IntColumn get vues => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {uid};
}

/// Commandes vocales ou écrites, créées sur ce téléphone ou reçues par le prestataire.
@DataClassName('CommandeLocale')
class Commandes extends Table {
  TextColumn get uid => text()();
  TextColumn get clientTelephone => text()();
  TextColumn get prestataireUid => text()();
  TextColumn get messageTexte => text().nullable()();
  TextColumn get audioLocal => text().nullable()();
  TextColumn get audioUrl => text().nullable()();
  IntColumn get audioDuree => integer().withDefault(const Constant(0))();
  IntColumn get montant => integer().withDefault(const Constant(0))();
  TextColumn get statut => text().withDefault(const Constant('nouvelle'))();
  DateTimeColumn get creeLe => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {uid};
}

/// Recherches vocales faites par le client.
@DataClassName('RechercheLocale')
class Recherches extends Table {
  TextColumn get uid => text()();
  TextColumn get audioLocal => text().nullable()();
  TextColumn get audioUrl => text().nullable()();
  TextColumn get transcription => text().nullable()();
  DateTimeColumn get creeLe => dateTime()();

  @override
  Set<Column> get primaryKey => {uid};
}

/// File d’attente : toute écriture faite hors ligne laisse une trace ici jusqu’à l’acquittement du serveur.
@DataClassName('OperationFile')
class FileAttente extends Table {
  TextColumn get id => text()();
  TextColumn get tableCible => text()();
  TextColumn get ligneId => text()();
  TextColumn get action => text()();
  TextColumn get payload => text()();
  DateTimeColumn get creeLe => dateTime()();
  IntColumn get tentatives => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Valeurs de synchronisation : curseurs, dates, code PIN haché.
@DataClassName('EtatLigne')
class EtatSync extends Table {
  TextColumn get cle => text()();
  TextColumn get valeur => text()();

  @override
  Set<Column> get primaryKey => {cle};
}

@DriftDatabase(tables: [Prestataires, Commandes, Recherches, FileAttente, EtatSync])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}
