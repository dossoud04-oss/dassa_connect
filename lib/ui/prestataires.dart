import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers.dart';
import '../theme.dart';
import 'fiche.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.recherche.isNotEmpty) {
      _searchController.text = widget.recherche;
    }
  }

  Future<void> _demarrerEcoute() async {
    setState(() => _ecouteEnCours = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _ecouteEnCours = false);
      _searchController.text = "Menuisier Sokponta";
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commande vocale reconnue !')),
      );
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
    final recherche = _searchController.text.toLowerCase();
    
    final categoriesFiltrees = Map.fromEntries(
      toutesLesCategories.entries.where((entry) => entry.key.toLowerCase().contains(recherche))
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EN-TÊTE style Presta
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: vertDassa,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: vertDassa.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('DC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Dassa Connect',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: vertDassa),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_none_rounded, size: 26, color: vertDassa),
                      ),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: purpleLight,
                        child: Icon(Icons.person, color: vertDassa, size: 20),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),

              // BARRE DE RECHERCHE + ICONE VOCALE ORANGE
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Rechercher un prestataire...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _demarrerEcoute,
                    child: Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: _ecouteEnCours ? Colors.red : orangeDassa,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _ecouteEnCours ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // BOUTON PHOTO
              OutlinedButton.icon(
                onPressed: _afficherOptionsImage,
                icon: const Icon(Icons.add_a_photo_rounded, color: vertDassa),
                label: const Text('Décrire avec une photo', style: TextStyle(color: vertDassa)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: BorderSide(color: vertDassa.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),

              if (_imageSelectionnee != null) ...[
                const SizedBox(height: 12),
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb
                          ? Image.network(_imageSelectionnee!.path, height: 140, width: double.infinity, fit: BoxFit.cover)
                          : Image.file(File(_imageSelectionnee!.path), height: 140, width: double.infinity, fit: BoxFit.cover),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      onPressed: () => setState(() => _imageSelectionnee = null),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              // CATÉGORIES (Grille comme Maquette 5)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Catégories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text('Voir tout >', style: TextStyle(color: vertDassa))),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemCount: categoriesFiltrees.length,
                itemBuilder: (context, index) {
                  final entry = categoriesFiltrees.entries.elementAt(index);
                  final nom = entry.key;
                  final icone = getIconFromString(entry.value);
                  return InkWell(
                    onTap: () => setState(() => _searchController.text = nom),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icone, size: 36, color: vertDassa),
                          const SizedBox(height: 8),
                          Text(nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // PRESTATAIRES PRÈS DE VOUS (Cartes conformes Maquette 5)
              const Text('Prestataires près de vous', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _cartePrestataireDemo(
                context: context,
                nom: 'Koffi Mensah',
                metier: 'Menuisier',
                quartier: 'Quartier Sokponta',
                prix: '5000 FCFA',
                imagePath: 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=150',
              ),
              const SizedBox(height: 12),
              _cartePrestataireDemo(
                context: context,
                nom: 'Awa Bagnon',
                metier: 'Soudeuse',
                quartier: 'Quartier Sokponta',
                prix: '8000 FCFA',
                imagePath: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartePrestataireDemo({
    required BuildContext context,
    required String nom,
    required String metier,
    required String quartier,
    required String prix,
    required String imagePath,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FichePage()));
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(imagePath, width: 60, height: 60, fit: BoxFit.cover),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: vertDassa,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('● Hors ligne', style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                Text(' $quartier', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Text('À partir de $prix', style: const TextStyle(fontWeight: FontWeight.bold, color: vertDassa)),
          ],
        ),
      ),
    );
  }
}
