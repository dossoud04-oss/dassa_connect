import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'data/base.dart';
import 'data/connexion.dart';
import 'data/depot.dart';
import 'providers.dart';
import 'theme.dart';
import 'ui/shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);
  final db = AppDatabase(ouvrirConnexion());
  runApp(
    ProviderScope(
      overrides: [depotProvider.overrideWithValue(Depot(db))],
      child: const DassaConnectApp(),
    ),
  );
}

class DassaConnectApp extends StatelessWidget {
  const DassaConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dassa Connect',
      debugShowCheckedModeBanner: false,
      theme: themeDassa(),
      home: const Racine(),
    );
  }
}
