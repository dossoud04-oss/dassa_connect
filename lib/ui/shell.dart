import 'package:flutter/material.dart';
import '../theme.dart';
import 'prestataires.dart';
import 'espace.dart'; 
import 'connexion.dart'; // On garde l'import pour ConnexionPage

class Racine extends StatefulWidget {
  const Racine({super.key});
  @override
  State<Racine> createState() => _RacineState();
}

class _RacineState extends State<Racine> {
  int _index = 0;
  
  // On utilise tes nouvelles pages ici
  final List<Widget> _pages = [
    const PrestatairesPage(), // L'accueil avec la recherche (Image 3)
    const Center(child: Text('Liste des Prestataires (À venir)')),
    const Center(child: Text('Messages (À venir)')),
    const EspacePage(), // Le profil (Image 4/5)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: vertDassa,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Prestataires'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// --- CE BLOC EST AJOUTÉ POUR QUE LE BOUTON "CLIENT" FONCTIONNE ---
// Si tu as un ancien code dans connexion.dart qui utilisait ConnexionPage(onClient:..., onPro:...),
// cette classe permet de faire le lien sans casser le reste.
class ConnexionPageWrapper extends StatelessWidget {
  final VoidCallback onClient;
  final VoidCallback onPro;
  const ConnexionPageWrapper({super.key, required this.onClient, required this.onPro});

  @override
  Widget build(BuildContext context) {
    // On renvoie simplement la nouvelle page de connexion qui gère tout toute seule
    return const ConnexionPage(); 
  }
}
