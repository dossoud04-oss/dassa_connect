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
  } catch (e) {
    // Hors ligne au démarrage ou clé invalide : l’application fonctionne en mode local.
    debugPrint('⚠️ Supabase non initialisé (mode local) : $e');
  }

  await _assurerSessionAnonyme();

  final db = AppDatabase(ouvrirConnexion());
  final depot = Depot(db);
  // Au démarrage, on retente les opérations restées en échec (ex. après l’activation de la connexion anonyme).
  await depot.reessayerEnErreur();

  runApp(
    ProviderScope(
      overrides: [depotProvider.overrideWithValue(depot)],
      child: const DassaConnectApp(),
    ),
  );
}

/// Les règles RLS exigent une session pour écrire. Si l’authentification anonyme est désactivée
/// dans Supabase, ce message l’indique clairement au lieu d’échouer en silence.
Future<void> _assurerSessionAnonyme() async {
  try {
    final auth = Supabase.instance.client.auth;
    if (auth.currentSession == null) {
      await auth.signInAnonymously();
      debugPrint('✅ Session anonyme ouverte');
    }
  } catch (e) {
    debugPrint('⚠️ Connexion anonyme impossible : activez « Anonymous sign-ins » dans Supabase. Détail : $e');
  }
}

class DassaConnectApp extends ConsumerWidget {
  const DassaConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Démarre la synchronisation (au lancement, au retour du réseau, puis périodiquement).
    ref.watch(connectivityProvider);
    ref.watch(rafraichissementProvider);

    return MaterialApp(
      title: 'Dassa Connect',
      debugShowCheckedModeBanner: false,
      theme: themeDassa(),
      home: const ConnexionPage(),
    );
  }
}
