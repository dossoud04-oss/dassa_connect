import 'package:flutter/material.dart';
import '../theme.dart';
import 'prestataires.dart';
import 'profil_client.dart';
import 'widgets.dart';

class ClientShell extends StatefulWidget {
  const ClientShell({super.key});
  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _index = 0;

  final List<Widget> _pages = [
    const PrestatairesPage(),
    const PrestatairesPage(), // liste = même source pour l'instant
    const Center(child: Text('Messages — bientôt disponible')),
    const ProfilClientPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Scaffold(
          body: Column(
            children: [
              const SafeArea(bottom: false, child: BandeauConnexion(compact: true)),
              Expanded(child: _pages[_index]),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: vertDassa,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
              BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Prestataires'),
              BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }
}
