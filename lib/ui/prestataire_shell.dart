import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers.dart';
import '../theme.dart';
import 'connexion.dart';
import 'formulaire_prestataire.dart';
import 'widgets.dart';

class PrestataireShell extends ConsumerStatefulWidget {
  const PrestataireShell({super.key});
  @override
  ConsumerState<PrestataireShell> createState() => _PrestataireShellState();
}

class _PrestataireShellState extends ConsumerState<PrestataireShell> {
  int _index = 0;
  XFile? _photoBoutique;
  String _prixBoutique = "0";
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _changerPhoto() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: vertDassa),
              title: const Text('Prendre une photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                if (image != null) setState(() => _photoBoutique = image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: vertDassa),
              title: const Text('Choisir dans la galerie'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) setState(() => _photoBoutique = image);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _modifierPrix() {
    final controller = TextEditingController(text: _prixBoutique);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le prix de base'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Entrez le prix (FCFA)', suffixText: 'FCFA'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              setState(() => _prixBoutique = controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prix mis à jour !')));
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _ouvrirFiche() async {
    final tel = await ref.read(depotProvider).lireEtat('telephone') ?? '';
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormulairePrestatairePage(telephone: tel, edition: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _pageAccueil(),
      _pageCommandes(),
      _pageBoutique(),
      _pageMessages(),
      _pageProfil(),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Dassa Connect'),
            backgroundColor: vertDassa,
            foregroundColor: Colors.white,
            actions: [IconButton(icon: const Icon(Icons.settings), onPressed: _seDeconnecter)],
          ),
          body: Column(
            children: [
              const BandeauConnexion(compact: true),
              Expanded(child: pages[_index]),
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
              BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Commandes'),
              BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Boutique'),
              BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pageAccueil() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: GestureDetector(
              onTap: _changerPhoto,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _photoBoutique != null
                        ? (kIsWeb ? NetworkImage(_photoBoutique!.path) : FileImage(File(_photoBoutique!.path)) as ImageProvider)
                        : null,
                    child: _photoBoutique == null ? const Icon(Icons.store, size: 40, color: Colors.grey) : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: vertDassa, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Prestataire Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: vertDassa)),
          const SizedBox(height: 8),
          FutureBuilder(
            future: ref.read(depotProvider).lireEtat('telephone').then((tel) async {
              if (tel == null) return null;
              return ref.read(depotProvider).prestataireParNumero(tel);
            }),
            builder: (context, snap) {
              final p = snap.data;
              final statut = p?.statut ?? 'pending';
              final label = statut == 'approved' ? 'Approuvé • Visible' : (statut == 'rejected' ? 'Refusé' : 'En attente de validation');
              final color = statut == 'approved' ? const Color(0xFF16A34A) : (statut == 'rejected' ? Colors.red : orangeDassa);
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  Icon(Icons.verified, color: color, size: 18),
                  const SizedBox(width: 8),
                  Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
                ]),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _carteStat('Vues', '0', Icons.visibility)),
              const SizedBox(width: 10),
              Expanded(child: _carteStat('Commandes', '0', Icons.receipt_long)),
              const SizedBox(width: 10),
              Expanded(child: _carteStat('Revenu', _prixBoutique, Icons.monetization_on)),
            ],
          ),
          const SizedBox(height: 24),
          const Row(children: [Icon(Icons.mic, color: vertDassa), SizedBox(width: 8), Text('Commandes vocales entrantes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 16),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
            child: const Column(
              children: [
                Icon(Icons.inbox, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text('Aucune commande pour le moment', style: TextStyle(color: Colors.grey, fontSize: 16)),
                Text('Vos futures commandes vocales apparaîtront ici.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: _changerPhoto, icon: const Icon(Icons.camera_alt, color: vertDassa), label: const Text('Ajouter photo', style: TextStyle(color: vertDassa)))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton.icon(onPressed: _modifierPrix, icon: const Icon(Icons.edit), label: const Text('Modifier prix'), style: ElevatedButton.styleFrom(backgroundColor: vertDassa, foregroundColor: Colors.white))),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(children: [Icon(Icons.store, color: vertDassa), SizedBox(width: 8), Text('Ma boutique', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)), child: const Text('En attente', style: TextStyle(color: Colors.white, fontSize: 12))),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(children: [Icon(Icons.info_outline, color: Colors.orange, size: 16), SizedBox(width: 4), Text('Statut : En attente de validation', style: TextStyle(color: Colors.orange))]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageCommandes() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Aucune commande', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('Vos commandes clients apparaîtront ici.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _pageBoutique() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gestion de la Boutique', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: vertDassa)),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: _changerPhoto,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: _photoBoutique != null
                    ? (kIsWeb ? NetworkImage(_photoBoutique!.path) : FileImage(File(_photoBoutique!.path)) as ImageProvider)
                    : null,
                child: _photoBoutique == null ? const Icon(Icons.store, size: 50, color: Colors.grey) : null,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _changerPhoto,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Changer la photo de profil'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _modifierPrix,
            icon: const Icon(Icons.edit),
            label: const Text('Modifier le prix de base'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _ouvrirFiche,
            icon: const Icon(Icons.badge_outlined),
            label: const Text('Modifier ma fiche (nom, métier, quartier, photos)'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: vertDassa,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageMessages() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Aucun message', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('Discutez avec vos clients ici.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _pageProfil() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 16),
            const Text('Mon Profil Prestataire', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
        ),
      ),
    );
  }

  Widget _carteStat(String titre, String valeur, IconData icone) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: vertDassa.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icone, color: vertDassa),
          const SizedBox(height: 8),
          Text(titre, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(valeur, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: vertDassa)),
        ],
      ),
    );
  }
}
