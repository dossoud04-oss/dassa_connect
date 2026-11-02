import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme.dart';
import 'connexion.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});
  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _index = 0;

  Future<void> _seDeconnecter() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Oui', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider).deconnecter();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const ConnexionPage()), (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _validerPrestataires(),
      const Center(child: Text('Aucun historique disponible')),
      _parametresAvances(),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Scaffold(
          body: SafeArea(child: pages[_index]),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            selectedItemColor: Colors.blue,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Validation'),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Paramètres'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _validerPrestataires() {
    // ON ÉCOUTE L'ÉTAT DU RÉSEAU ICI
    final isOnlineAsync = ref.watch(isOnlineProvider);
    final isOnline = isOnlineAsync.value ?? false;

    return Column(
      children: [
        // LE BANDEAU DEVIENT DYNAMIQUE
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isOnline ? Colors.green : orangeDassa, // Vert si en ligne, Orange si hors ligne
            borderRadius: BorderRadius.circular(16)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(isOnline ? Icons.wifi : Icons.airplanemode_active, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    isOnline ? 'En ligne' : 'Mode Avion',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                  )
                ]
              ),
              const SizedBox(height: 4),
              Text(
                isOnline ? 'Connexion internet active • Synchronisation en cours' : 'Vous êtes hors ligne • Validation locale active',
                style: const TextStyle(color: Colors.white70)
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Prestataires en attente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('0 en attente', style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
                child: const Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('Aucun prestataire en attente', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    Text('Les nouvelles demandes apparaîtront ici.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _parametresAvances() {
    final categories = ref.watch(categoriesProvider);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text('Paramètres Admin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        const Text('Gestion des Métiers', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: Colors.grey.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.add_circle, color: Colors.blue),
                title: const Text('Ajouter une catégorie'),
                subtitle: const Text('Créer un nouveau métier et choisir son icône'),
                onTap: () => _ajouterCategorie(context, ref),
              ),
              const Divider(height: 1),
              for (var entry in categories.entries)
                ListTile(
                  leading: Icon(getIconFromString(entry.value), color: vertDassa),
                  title: Text(entry.key),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      ref.read(categoriesProvider.notifier).supprimer(entry.key);
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _seDeconnecter,
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red),
          ),
        ),
      ],
    );
  }

  void _ajouterCategorie(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();
    String iconeSelectionnee = 'category';

    final List<MapEntry<String, IconData>> iconesDisponibles = [
      const MapEntry('category', Icons.category),
      const MapEntry('handyman', Icons.handyman),
      const MapEntry('engineering', Icons.engineering),
      const MapEntry('hotel', Icons.hotel),
      const MapEntry('restaurant', Icons.restaurant),
      const MapEntry('plumbing', Icons.plumbing),
      const MapEntry('electric', Icons.electric_bolt),
      const MapEntry('cleaning', Icons.cleaning_services),
      const MapEntry('car', Icons.car_repair),
      const MapEntry('medical', Icons.medical_services),
      const MapEntry('computer', Icons.computer),
      const MapEntry('cut', Icons.cut),
      const MapEntry('brush', Icons.brush),
      const MapEntry('agriculture', Icons.agriculture),
      const MapEntry('school', Icons.school),
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( 
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nouvelle Catégorie'),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: 'Ex: Maçon, Couturier...'),
                    ),
                    const SizedBox(height: 20),
                    const Text('Choisir une icône :', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 150,
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 8, crossAxisSpacing: 8),
                        itemCount: iconesDisponibles.length,
                        itemBuilder: (context, index) {
                          final icone = iconesDisponibles[index];
                          final estSelectionnee = icone.key == iconeSelectionnee;
                          return InkWell(
                            onTap: () => setState(() => iconeSelectionnee = icone.key),
                            child: Container(
                              decoration: BoxDecoration(color: estSelectionnee ? vertDassa : Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                              child: Icon(icone.value, color: estSelectionnee ? Colors.white : Colors.black, size: 24),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      ref.read(categoriesProvider.notifier).ajouter(controller.text.trim(), iconeSelectionnee);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
