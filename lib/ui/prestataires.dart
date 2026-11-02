import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers.dart';
import '../theme.dart';

class PrestatairesPage extends ConsumerStatefulWidget {
  final String? categorie;
  final String recherche;
  const PrestatairesPage({super.key, this.categorie, this.recherche = ''});

  @override
  ConsumerState<PrestatairesPage> createState() => _PrestatairesPageState();
}

class _PrestatairesPageState extends ConsumerState<PrestatairesPage> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageSelectionnee;
  bool _ecouteEnCours = false;

  Future<void> _demarrerEcoute() async {
    setState(() => _ecouteEnCours = true);
    await Future.delayed(const Duration(seconds: 2)); 
    if (mounted) {
      setState(() => _ecouteEnCours = false);
      _searchController.text = "Réparation de porte en bois"; 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Commande vocale reconnue !')));
    }
  }

  Future<void> _choisirImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 70);
      if (image != null) setState(() => _imageSelectionnee = image);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  void _afficherOptionsImage() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: vertDassa),
              title: const Text('Prendre une photo'),
              onTap: () { Navigator.pop(context); _choisirImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: vertDassa),
              title: const Text('Choisir dans la galerie'),
              onTap: () { Navigator.pop(context); _choisirImage(ImageSource.gallery); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final toutesLesCategories = ref.watch(categoriesProvider);
    
    // CORRECTION ICI : On utilise bien .entries.where() pour filtrer une Map
    final recherche = _searchController.text.toLowerCase();
    final categoriesFiltrees = Map.fromEntries(
      toutesLesCategories.entries.where((entry) => entry.key.toLowerCase().contains(recherche))
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Dassa Connect', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(30)),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() {}), 
                      decoration: const InputDecoration(hintText: 'Rechercher...', border: InputBorder.none, icon: Icon(Icons.search, color: Colors.grey)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _demarrerEcoute,
                  child: Container(
                    padding: const EdgeInsets.all(12), 
                    decoration: BoxDecoration(color: _ecouteEnCours ? Colors.red : orangeDassa, shape: BoxShape.circle), 
                    child: Icon(_ecouteEnCours ? Icons.mic : Icons.mic_none, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _afficherOptionsImage,
              icon: const Icon(Icons.add_a_photo, color: vertDassa),
              label: const Text('Décrire avec une photo', style: TextStyle(color: vertDassa)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: vertDassa.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            if (_imageSelectionnee != null) ...[
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb 
                      ? Image.network(_imageSelectionnee!.path, height: 150, width: double.infinity, fit: BoxFit.cover)
                      : Image.file(File(_imageSelectionnee!.path), height: 150, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => setState(() => _imageSelectionnee = null)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            const Text('Catégories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 2.0,
              ),
              itemCount: categoriesFiltrees.length,
              itemBuilder: (context, index) {
                final entry = categoriesFiltrees.entries.elementAt(index);
                final nomCategorie = entry.key;
                final iconeCategorie = getIconFromString(entry.value);
                
                return InkWell(
                  onTap: () {
                    setState(() => _searchController.text = nomCategorie);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: _categorieCard(iconeCategorie, nomCategorie),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Prestataires près de vous', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
              child: const Column(children: [Icon(Icons.storefront, size: 48, color: Colors.grey), SizedBox(height: 12), Text('Aucun prestataire enregistré', style: TextStyle(color: Colors.grey))]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categorieCard(IconData icon, String nom) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [Icon(icon, size: 32, color: vertDassa), const SizedBox(height: 8), Text(nom, style: const TextStyle(fontWeight: FontWeight.bold))]
      ),
    );
  }
}
