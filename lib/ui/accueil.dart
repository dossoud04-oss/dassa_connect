import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme.dart';
import 'fiche.dart';
import 'prestataires.dart';
import 'widgets.dart';

/// Accueil client, sans compte, comme la maquette : recherche, catégories, prestataires proches.
/// Tout fonctionne hors ligne grâce au catalogue enregistré sur le téléphone.
class AccueilPage extends ConsumerStatefulWidget {
  const AccueilPage({super.key});

  @override
  ConsumerState<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends ConsumerState<AccueilPage> {
  final _recherche = TextEditingController();

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  void _ouvrirPrestataires({String? categorie, String recherche = ''}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PrestatairesPage(categorie: categorie, recherche: recherche)),
    );
  }

  /// Recherche vocale : la demande est enregistrée sur le téléphone, puis envoyée au retour du réseau.
  Future<void> _rechercheVocale() async {
    String? chemin;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, majFeuille) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Dites ce que vous cherchez', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              MicroVocal(
                voix: ref.read(voixProvider),
                onChange: (fichier, _) => majFeuille(() => chemin = fichier),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: chemin == null
                    ? null
                    : () async {
                        final fichier = await ref.read(voixProvider).conserver(chemin!);
                        await ref.read(depotProvider).creerRecherche(fichier);
                        final nombre = ref.read(catalogueProvider).valueOrNull?.length ?? 0;
                        if (ctx.mounted) Navigator.pop(ctx);
                        await ref.read(voixProvider).parler('Recherche enregistrée. $nombre prestataires trouvés.');
                      },
                child: const Text('Rechercher'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enLigne = ref.watch(enLigneProvider).valueOrNull ?? true;
    final catalogue = ref.watch(catalogueProvider);
    return Scaffold(
      appBar: AppBar(
        title: const LogoDassa(taille: 34),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, size: 28)),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFE5E7EB),
              child: Icon(Icons.person, color: Colors.grey),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _recherche,
            textInputAction: TextInputAction.search,
            onSubmitted: (v) => _ouvrirPrestataires(recherche: v.trim().toLowerCase()),
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Rechercher un prestataire...',
              prefixIcon: const Icon(Icons.search, size: 26),
              filled: true,
              fillColor: const Color(0xFFF2F4F3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(6),
                child: IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: orangeVocal),
                  onPressed: _rechercheVocale,
                  icon: const Icon(Icons.mic, color: Colors.white, size: 26),
                ),
              ),
            ),
          ),
          if (!enLigne) ...[
            const SizedBox(height: 12),
            bandeau(
              const Color(0xFFFFE8D6),
              Icons.wifi_off,
              'Hors connexion : vous voyez le catalogue enregistré sur ce téléphone.',
              couleurTexte: noir,
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text('Catégories', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () => _ouvrirPrestataires(),
                child: const Text('Voir tout', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25,
            children: [
              _CarteCategorie(
                libelle: 'Menuisier',
                icone: Icons.handyman,
                onTap: () => _ouvrirPrestataires(categorie: 'menuisier'),
              ),
              _CarteCategorie(
                libelle: 'Soudeur',
                icone: Icons.construction,
                onTap: () => _ouvrirPrestataires(categorie: 'soudeur'),
              ),
              _CarteCategorie(
                libelle: 'Hôtel',
                icone: Icons.apartment,
                onTap: () => _ouvrirPrestataires(categorie: 'hotel'),
              ),
              _CarteCategorie(
                libelle: 'Restauration',
                icone: Icons.restaurant,
                onTap: () => _ouvrirPrestataires(categorie: 'restauration'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Prestataires près de vous', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          catalogue.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Catalogue indisponible.'),
            data: (liste) {
              if (liste.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Aucun prestataire sur ce téléphone. Connectez-vous une fois à internet pour charger le catalogue.',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }
              return Column(
                children: [
                  for (final p in liste.take(3))
                    CartePrestataire(
                      p: p,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FichePage(uid: p.uid))),
                    ),
                  if (liste.length > 3)
                    TextButton(
                      onPressed: () => _ouvrirPrestataires(),
                      child: Text('Voir les ${liste.length} prestataires', style: const TextStyle(fontSize: 18)),
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

/// Carte de catégorie : icône verte, nom en gros caractères.
class _CarteCategorie extends StatelessWidget {
  const _CarteCategorie({required this.libelle, required this.icone, required this.onTap});

  final String libelle;
  final IconData icone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 42, color: vertBenin),
            const SizedBox(height: 8),
            Text(libelle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
