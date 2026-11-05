import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/base.dart';
import '../data/lecture.dart';
import '../providers.dart';
import '../theme.dart';
import '../utils.dart';
import 'fiche.dart';

/// Vue client : n’affiche QUE les prestataires validés par l’admin, lus dans la base locale
/// (alimentée par la synchro Supabase). Tirer vers le bas pour actualiser.
class PrestatairesPage extends ConsumerStatefulWidget {
  final String? categorie;
  final String recherche;
  const PrestatairesPage({super.key, this.categorie, this.recherche = ''});

  @override
  ConsumerState<PrestatairesPage> createState() => _PrestatairesPageState();
}

class _PrestatairesPageState extends ConsumerState<PrestatairesPage> {
  late final TextEditingController _rechercheCtrl = TextEditingController(text: widget.recherche);

  @override
  void dispose() {
    _rechercheCtrl.dispose();
    super.dispose();
  }

  Future<void> _actualiser() => ref.read(syncProvider).synchroniser(manuelle: true);

  bool _correspond(PrestataireLocal p, String requete) {
    if (requete.isEmpty) return true;
    final texte = '${p.nom} ${p.categorie} ${p.quartier} ${p.description}'.toLowerCase();
    return requete.split(RegExp(r'\s+')).every((mot) => texte.contains(mot));
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final catalogue = ref.watch(catalogueProvider);
    final requete = _rechercheCtrl.text.trim().toLowerCase();
    final categoriesFiltrees =
        categories.entries.where((e) => e.key.toLowerCase().contains(requete)).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _actualiser,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              _entete(),
              const SizedBox(height: 16),
              _barreRecherche(),
              const SizedBox(height: 24),
              const Text('Catégories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  final entree = categoriesFiltrees[index];
                  return InkWell(
                    onTap: () => setState(() => _rechercheCtrl.text = entree.key),
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
                          Icon(getIconFromString(entree.value), size: 36, color: vertDassa),
                          const SizedBox(height: 8),
                          Text(entree.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                requete.isEmpty ? 'Prestataires validés' : 'Résultats',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...catalogue.when<List<Widget>>(
                loading: () => [
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
                error: (e, _) => [_videEtat(Icons.error_outline, 'Impossible de charger les prestataires', '$e')],
                data: (liste) {
                  final visibles = liste.where((p) => _correspond(p, requete)).toList();
                  if (visibles.isEmpty) {
                    return [
                      _videEtat(
                        Icons.person_search,
                        liste.isEmpty ? 'Aucun prestataire validé pour le moment' : 'Aucun résultat',
                        'Tirez vers le bas pour actualiser.',
                      ),
                    ];
                  }
                  return visibles
                      .map((p) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _carte(p)))
                      .toList();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _entete() => Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: vertDassa,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: vertDassa.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3)),
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
      );

  Widget _barreRecherche() => Row(
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
                controller: _rechercheCtrl,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Rechercher un métier ou un quartier...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Recherche vocale : bientôt disponible')),
            ),
            child: Container(
              height: 52,
              width: 52,
              decoration: const BoxDecoration(color: orangeDassa, shape: BoxShape.circle),
              child: const Icon(Icons.mic_none, color: Colors.white, size: 26),
            ),
          ),
        ],
      );

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
              style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(sous, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );

  Widget _carte(PrestataireLocal p) {
    final photos = p.photosList;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FichePage(prestataire: p))),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: vertClair,
          backgroundImage: photos.isNotEmpty ? NetworkImage(photos.first) : null,
          child: photos.isEmpty
              ? Text(initiales(p.nom), style: const TextStyle(color: vertDassa, fontWeight: FontWeight.bold))
              : null,
        ),
        title: Text(p.nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${p.categorie} • ${p.quartier}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                'À partir de ${formatFcfa(p.prixBase)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: vertDassa),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
