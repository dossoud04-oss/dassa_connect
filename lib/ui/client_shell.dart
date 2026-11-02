import 'package:flutter/material.dart';
import '../theme.dart';
import 'prestataires.dart';

class ClientShell extends StatefulWidget {
  const ClientShell({super.key});
  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _index = 0;

  final List<Widget> _pages = [
    const PrestatairesPage(),
    const Center(child: Text('Tous les prestataires')),
    const Center(child: Text('Messages')),
    const Center(child: Text('Mon Profil Client')),
  ];

  @override
  Widget build(BuildContext context) {
    // ON BRIDE LA LARGEUR ICI POUR AVOIR UN EFFET MOBILE SUR PC
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Scaffold(
          body: _pages[_index],
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
