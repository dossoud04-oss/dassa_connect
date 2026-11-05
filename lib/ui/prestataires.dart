import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/base.dart';
import '../data/lecture.dart';
import '../providers.dart';
import '../theme.dart';
import '../utils.dart';
import 'fiche.dart';
import 'photo.dart';

/// Accueil client : catégories, recherche et prestataires validés. Tirer vers le bas pour actualiser.
class PrestatairesPage extends ConsumerStatefulWidget {
  final String? categorie;
  final String recherche;
  const PrestatairesPage({super.key, this.categorie, this.recherche = ''});

  @override
  ConsumerState<PrestatairesPage> createState() => _PrestatairesPageState();
}

class _PrestatairesPageState extends ConsumerState<PrestatairesPage> {
  late final TextEditingController _rechercheCtrl = TextEditingController(text: widget.recherche);
  late String? _categorie = widget.categorie;

  @override
  void dispose() {
    _rechercheCtrl.dispose();
    super.dispose();
  }

  Future<void> _actualiser() => ref.read(syncProvider).synchroniser(manuelle: true);

  bool _correspond(PrestataireLocal p, String requete) {
    if (_categorie != null && p.categorie != _categorie) return false;
    if (requete.isEmpty) return true;
    final texte = '${p.nom} ${p.categorie} ${p.quartier} ${p.description}'.toLowerCase();
    return requete.split(RegExp(r'\s+')).every((mot) => texte.contains(mot));
  }

  Widget _entete() => Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(color: vertDassa, shape: BoxShape.circle),
            child: const Center(
              child: Text('DC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dassa Connect', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: vertDassa)),
                Text('Trouvez un prestataire près de vous', style: TextStyle(fontSize: 12, color: grisTexte)),
              ],
            ),
          ),
        ],
      );

  Widget _barreRecherche() => Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: TextField(
          controller: _rechercheCtrl,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Rechercher un métier ou un quartier',
            prefixIcon: Icon(Icons.search, color: grisTexte),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );

  Widget _chip(String libelle, IconData icone, bool actif, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: actif ? vertDassa : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: actif ? vertDassa : Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 16, color: actif ? Colors.white : vertDassa),
              const SizedBox(width: 6),
              Text(
                libelle,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: actif ? Colors.white : noirTexte),
              ),
            ],
          ),
        ),
      );

  Widget _chipsCategories(Map<String, String> categories) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _chip('Tous', Icons.apps, _categorie == null, () => setState(() => _categorie = null)),
          ),
          for (final e in categories.entries)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _chip(
                e.key,
                getIconFromString(e.value),
                _categorie == e.key,
                () => setState(() => _categorie = _categorie == e.key ? null : e.key),
              ),
            ),
        ],
      ),
    );
  }

  Widget _carte(PrestataireLocal p) {
    final photos = p.photosList;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => FichePage(prestataire: p)),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Avatar(initiales: initiales(p.nom), photo: photos.isEmpty ? null : photos.first, rayon: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${p.categorie} • ${p.quartier}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: grisTexte),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'À partir de ${formatFcfa(p.prixBase)}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: vertDassa, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: grisTexte),
            ],
          ),
        ),
      ),
    );
  }

  Widget _videEtat(IconData icone, String titre, String sous) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icone, size: 48, color: const Color(0xFFBDBDBD)),
            const SizedBox(height: 12),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: const TextStyle(color: grisTexte, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(sous, textAlign: TextAlign.center, style: const TextStyle(color: grisTexte, fontSize: 13)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final catalogue = ref.watch(catalogueProvider);
    final requete = _rechercheCtrl.text.trim().toLowerCase();
    return Scaffold(
      backgroundColor: grisFond,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _actualiser,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _entete(),
              const SizedBox(height: 14),
              _barreRecherche(),
              const SizedBox(height: 16),
              _chipsCategories(categories),
              const SizedBox(height: 18),
              Text(
                _categorie ?? 'Prestataires validés',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: noirTexte),
              ),
              const SizedBox(height: 10),
              ...catalogue.when<List<Widget>>(
                loading: () => [
                  const Padding(
                    padding: EdgeInsets.all(28),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
                error: (e, _) => [_videEtat(Icons.error_outline, 'Impossible de charger les prestataires', '$e')],
                data: (liste) {
                  final visibles = liste.where((p) => _correspond(p, requete)).toList();
                  if (visibles.isEmpty) {
                    return [
                      _videEtat(
                        Icons.storefront_outlined,
                        liste.isEmpty ? 'Aucun prestataire validé pour le moment' : 'Aucun résultat',
                        'Tirez vers le bas pour actualiser.',
                      ),
                    ];
                  }
                  return visibles
                      .map((p) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _carte(p)))
                      .toList();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
