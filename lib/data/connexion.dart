import 'package:drift/drift.dart' show QueryExecutor;
import 'package:drift_flutter/drift_flutter.dart';

/// Ouvre la base locale : SQLite natif sur Android, SQLite WebAssembly dans le navigateur.
/// Pour le web, sqlite3.wasm et drift_worker.js doivent être dans le dossier web/ (ils y sont).
QueryExecutor ouvrirConnexion() {
  return driftDatabase(
    name: 'dassa_connect',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
