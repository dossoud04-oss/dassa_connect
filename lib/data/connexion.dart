import 'package:drift/drift.dart' show QueryExecutor;
import 'package:drift_flutter/drift_flutter.dart';

/// Ouvre la base locale : SQLite natif sur Android, SQLite WebAssembly dans le navigateur.
/// Pour le web, copier sqlite3.wasm et le worker de Drift dans web/ (voir README.md).
QueryExecutor ouvrirConnexion() {
  return driftDatabase(
    name: 'dassa_connect',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.dart.js'),
    ),
  );
}
