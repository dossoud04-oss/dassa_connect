import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme.dart';
import 'commandes.dart';
import 'liste_conversations.dart';
import 'prestataires.dart';
import 'profil_client.dart';
import 'widgets.dart';

/// Espace client : accueil, commandes, messages et profil.
class ClientShell extends ConsumerStatefulWidget {
  const ClientShell({super.key});

  @override
  ConsumerState<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends ConsumerState<ClientShell> {
  int _index = 0;

  void _alerte(String texte) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texte),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(label: 'Voir', onPressed: () => setState(() => _index = 2)),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final nonLus = ref.watch(messagesNonLusProvider('client')).valueOrNull ?? 0;

    ref.listen<AsyncValue<int>>(messagesNonLusProvider('client'), (prev, next) {
      if (prev == null || !prev.hasValue) return;
      if ((next.valueOrNull ?? 0) > (prev.valueOrNull ?? 0)) {
        _alerte('Nouveau message de votre prestataire');
      }
    });

    final pages = <Widget>[
      const PrestatairesPage(),
      const CommandesPage(),
      const ListeConversations(role: 'client'),
      const ProfilClientPage(),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Scaffold(
          body: Column(
            children: [
              const SafeArea(bottom: false, child: BandeauConnexion(compact: true)),
              Expanded(child: pages[_index]),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: vertDassa,
            unselectedItemColor: Colors.grey,
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Accueil'),
              const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Commandes'),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: nonLus > 0,
                  label: Text('$nonLus'),
                  child: const Icon(Icons.chat_bubble_outline),
                ),
                label: 'Messages',
              ),
              const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }
}
