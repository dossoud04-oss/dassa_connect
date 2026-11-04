import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'data/base.dart';
import 'data/connexion.dart';
import 'data/depot.dart';
import 'providers.dart';
import 'theme.dart';
import 'ui/connexion.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );

    // Connexion anonyme pour autoriser les écritures côté Supabase (RLS)
    if (Supabase.instance.client.auth.currentUser == null) {
      await Supabase.instance.client.auth.signInAnonymously();
      debugPrint('✅ Connecté à Supabase en mode anonyme');
    }
  } catch (e, st) {
    // Mode 100 % local si pas de réseau / clé invalide / hors ligne au démarrage
    debugPrint('⚠️ Supabase non initialisé (Mode local) : $e');
    debugPrint('$st');
  }

  final db = AppDatabase(ouvrirConnexion());

  runApp(
    ProviderScope(
      overrides: [depotProvider.overrideWithValue(Depot(db))],
      child: const DassaConnectApp(),
    ),
  );
}

// 1. On transforme la classe en ConsumerWidget
class DassaConnectApp extends ConsumerWidget {
  const DassaConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. C'EST LA LIGNE MAGIQUE ! 
    // En écoutant le connectivityProvider ici, il démarre au lancement de l'app 
    // et tourne en arrière-plan tant que l'application est ouverte.
    ref.watch(connectivityProvider);

    return MaterialApp(
      title: 'Dassa Connect',
      debugShowCheckedModeBanner: false,
      theme: themeDassa(),
      home: const ConnexionPage(),
    );
  }
}
