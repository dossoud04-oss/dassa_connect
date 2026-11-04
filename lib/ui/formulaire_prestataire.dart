import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers.dart';
import '../theme.dart';
import 'prestataire_shell.dart';

/// Formulaire obligatoire à la première connexion prestataire.
/// Champs requis : nom, métier, quartier. Photos et description recommandés.
class FormulairePrestatairePage extends ConsumerStatefulWidget {
  final String telephone;
  final bool edition; // true = modification depuis Boutique
  const FormulairePrestatairePage({super.key, required this.telephone, this.edition = false});

  @override
  ConsumerState<FormulairePrestatairePage> createState() => _FormulairePrestatairePageState();
}

class _FormulairePrestatairePageState extends ConsumerState<FormulairePrestatairePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _quartierCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _prixCtrl = TextEditingController(text: '5000');
  String? _metier;
  final List<XFile> _photos = [];
  bool _occupe = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _precharger();
  }

  Future<void> _precharger() async {
    final depot = ref.read(depotProvider);
    final existant = await depot.prestataireParNumero(widget.telephone);
    if (existant != null && mounted) {
      setState(() {
        _nomCtrl.text = existant.nom;
        _quartierCtrl.text = existant.quartier;
        _descCtrl.text = existant.description;
        _prixCtrl.text = existant.prixBase.toString();
        _metier = existant.categorie.isNotEmpty ? existant.categorie : null;
      });
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _quartierCtrl.dispose();
    _descCtrl.dispose();
    _prixCtrl.dispose();
    super.dispose();
  }

  Future<void> _ajouterPhoto() async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: vertDassa),
            title: const Text('Appareil photo'),
            onTap: () async {
              Navigator.pop(ctx);
              final img = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
              if (img != null) setState(() => _photos.add(img));
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: vertDassa),
            title: const Text('Galerie'),
            onTap: () async {
              Navigator.pop(ctx);
              final imgs = await _picker.pickMultiImage(imageQuality: 70);
              if (imgs.isNotEmpty) setState(() => _photos.addAll(imgs));
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;
    if (_metier == null || _metier!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choisissez votre métier')));
      return;
    }
    setState(() => _occupe = true);
    try {
      final depot = ref.read(depotProvider);
      final photosPaths = _photos.map((p) => p.path).toList();
      await depot.creerOuMajPrestataire(
        telephone: widget.telephone,
        nom: _nomCtrl.text.trim(),
        categorie: _metier!,
        quartier: _quartierCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        prixBase: int.tryParse(_prixCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        photos: photosPaths,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.edition
              ? 'Profil mis à jour'
              : 'Fiche envoyée ! En attente de validation admin.'),
          backgroundColor: vertDassa,
        ),
      );
      if (widget.edition) {
        Navigator.pop(context);
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PrestataireShell()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final metiers = categories.keys.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.edition ? 'Modifier ma fiche' : 'Compléter mon profil'),
        automaticallyImplyLeading: widget.edition,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (!widget.edition) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: orangeDassa.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: orangeDassa.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: orangeDassa),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ces informations sont obligatoires. Un admin validera votre fiche avant qu\'elle soit visible par les clients.',
                          style: TextStyle(fontSize: 13, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              const Text('Nom complet / Atelier *', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nomCtrl,
                decoration: const InputDecoration(hintText: 'Ex: Atelier Pierre Dassa'),
                validator: (v) => (v == null || v.trim().length < 2) ? 'Nom requis' : null,
              ),
              const SizedBox(height: 16),
              const Text('Métier *', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _metier != null && metiers.contains(_metier) ? _metier : null,
                decoration: const InputDecoration(hintText: 'Choisir un métier'),
                items: metiers.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setState(() => _metier = v),
                validator: (v) => v == null ? 'Métier requis' : null,
              ),
              const SizedBox(height: 16),
              const Text('Quartier *', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _quartierCtrl,
                decoration: const InputDecoration(hintText: 'Ex: Sokponta'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Quartier requis' : null,
              ),
              const SizedBox(height: 16),
              const Text('Prix de base (FCFA)', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _prixCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '5000', suffixText: 'FCFA'),
              ),
              const SizedBox(height: 16),
              const Text('Description de vos services', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Décrivez votre expérience, spécialités, délais...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Photos de vos réalisations', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._photos.map((p) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: kIsWeb
                                    ? Image.network(p.path, width: 100, height: 100, fit: BoxFit.cover)
                                    : Image.file(File(p.path), width: 100, height: 100, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () => setState(() => _photos.remove(p)),
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black54,
                                    child: Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    GestureDetector(
                      onTap: _ajouterPhoto,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: vertClair,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: vertDassa, style: BorderStyle.solid),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: vertDassa),
                            SizedBox(height: 4),
                            Text('Ajouter', style: TextStyle(fontSize: 12, color: vertDassa)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _occupe ? null : _soumettre,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vertDassa,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _occupe
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(widget.edition ? 'Enregistrer les modifications' : 'Envoyer pour validation',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('* Champs obligatoires', style: TextStyle(color: grisTexte, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
