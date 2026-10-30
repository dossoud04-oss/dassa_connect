import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'fiche.dart'; 
import 'widgets.dart';

/// Libellés des catégories, dans l’ordre d’affichage.
const Map<String, String> kCategories = {
  'menuisier': 'Menuisier',
  'soudeur': 'Soudeur',
  'hotel': 'Hôtel',
  'restauration': 'Restauration',
  'autre': 'Autre',
};

/// Liste complète des prestataires, avec recherche et filtres par catégorie. Fonctionne hors ligne.
class PrestatairesPage extends ConsumerStatefulWidget {
  const PrestatairesPage({super.key, this.categorie, this.recherche = ''});

  final String? categorie;
  final String recherche;

  @override
  ConsumerState<PrestatairesPage> createState() => _PrestatairesPageState();
}

class _PrestatairesPageState extends ConsumerState<PrestatairesPage> {
  late final TextEditingController _champ = TextEditingController(text: widget.recherche);
  late String _requete = widget.recherche.trim().toLowerCase();
  late String? _categorie = widget.categorie;

  @override
  void dispose() {
    _champ.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogue = ref.watch(catalogueProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Prestataires')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _champ,
            onChanged: (v) => setState(() => _requete = v.trim().toLowerCase()),
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Rechercher un prestataire...',
              prefixIcon: const Icon(Icons.search, size: 26),
              filled: true,
              fillColor: const Color(0xFFF2F4F3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Tous'),
                selected: _categorie == null,
                onSelected: (_) => setState(() => _categorie = null),
              ),
              for (final e in kCategories.entries)
                ChoiceChip(
                  label: Text(e.value),
                  selected: _categorie == e.key,
                  onSelected: (_) => setState(() => _categorie = e.key),
                ),
            ],
          ),
          const SizedBox(height: 12),
          catalogue.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Catalogue indisponible.'),
            data: (liste) {
              final filtrees = liste.where((p) {
                final bonneCategorie = _categorie == null || p.categorie == _categorie;
                final bonneRecherche = _requete.isEmpty ||
                    p.nom.toLowerCase().contains(_requete) ||
                    p.quartier.toLowerCase().contains(_requete) ||
                    p.categorie.contains(_requete);
                return bonneCategorie && bonneRecherche;
              }).toList();
              if (filtrees.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aucun prestataire trouvé sur ce téléphone.', style: TextStyle(fontSize: 18)),
                );
              }
              return Column(
                children: [
                  for (final p in filtrees)
                    CartePrestataire(
                      p: p,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FichePage(uid: p.uid))),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
