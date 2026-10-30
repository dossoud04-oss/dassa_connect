import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers.dart';
import 'accueil.dart';
import 'commandes.dart';
import 'connexion.dart';
import 'prestataires.dart';
import 'profil.dart';

/// Point d’entrée de l’interface : démarre le réseau et la synchronisation, puis affiche la navigation.
class Racine extends ConsumerStatefulWidget {
  const Racine({super.key});

  @override
  ConsumerState<Racine> createState() => _RacineState();
}

class _RacineState extends ConsumerState<Racine> {
  @override
  void initState() {
    super.initState();
    ref.read(connectivityProvider);
    ref.read(syncProvider).synchroniser();
  }

  @override
  Widget build(BuildContext context) => const PorteEntree();
}

/// Si une session existe et qu’un PIN est défini, l’application demande le PIN avant d’ouvrir.
class PorteEntree extends ConsumerStatefulWidget {
  const PorteEntree({super.key});

  @override
  ConsumerState<PorteEntree> createState() => _PorteEntreeState();
}

class _PorteEntreeState extends ConsumerState<PorteEntree> {
  bool? _verrouille;

  @override
  void initState() {
    super.initState();
    _verifier();
  }

  Future<void> _verifier() async {
    final session = Supabase.instance.client.auth.currentSession;
    final pin = await ref.read(authProvider).pinDefini();
    if (mounted) setState(() => _verrouille = session != null && pin);
  }

  @override
  Widget build(BuildContext context) {
    final etat = _verrouille;
    if (etat == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (etat) {
      return PinPage(creation: false, onDeverrouille: () => setState(() => _verrouille = false));
    }
    return const Shell();
  }
}

/// Navigation en quatre onglets, comme la maquette : Accueil, Prestataires, Messages, Profil.
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _onglet = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _onglet,
        children: const [AccueilPage(), PrestatairesPage(), CommandesPage(), ProfilPage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _onglet,
        onDestinationSelected: (i) => setState(() => _onglet = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Prestataires'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
