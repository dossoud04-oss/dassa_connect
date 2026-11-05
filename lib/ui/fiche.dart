import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/base.dart';
import '../data/lecture.dart';
import '../providers.dart';
import '../theme.dart';
import '../utils.dart';
import 'conversation.dart';
import 'photo.dart';

/// Fiche d'un prestataire validé : toutes les informations viennent de la base locale.
class FichePage extends ConsumerWidget {
  const FichePage({super.key, required this.prestataire});

  final PrestataireLocal prestataire;

  String get _chiffres => prestataire.telephone.replaceAll(RegExp(r'[^0-9]'), '');

  void _snack(BuildContext context, String texte) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texte)));

  Future<void> _appeler(BuildContext context) async {
    try {
      final ok = await launchUrl(Uri(scheme: 'tel', path: '+$_chiffres'));
      if (!ok && context.mounted) _snack(context, 'Impossible d’ouvrir l’appel.');
    } catch (_) {
      if (context.mounted) _snack(context, 'Appel impossible sur cet appareil.');
    }
  }

  Future<void> _whatsapp(BuildContext context) async {
    final msg = Uri.encodeComponent('Bonjour ${prestataire.nom}, je vous contacte via Dassa Connect.');
    try {
      final ok = await launchUrl(
        Uri.parse('https://wa.me/$_chiffres?text=$msg'),
        mode: LaunchMode.externalApplication,
      );
      if (!ok && context.mounted) _snack(context, 'Impossible d’ouvrir WhatsApp.');
    } catch (_) {
      if (context.mounted) _snack(context, 'WhatsApp indisponible sur cet appareil.');
    }
  }

  Widget _badge(IconData icone, String texte, Color fond, Color couleur) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: fond, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 14, color: couleur),
            const SizedBox(width: 4),
            Text(texte, style: TextStyle(fontSize: 12, color: couleur, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _galerie(List<String> photos) {
    if (photos.isEmpty) {
      return Container(
        height: 190,
        width: double.infinity,
        decoration: BoxDecoration(color: vertClair, borderRadius: BorderRadius.circular(16)),
        child: Center(child: Avatar(initiales: initiales(prestataire.nom), rayon: 44)),
      );
    }
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image(
            image: imageDe(photos[i])!,
            width: 280,
            height: 190,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 280,
              color: vertClair,
              child: const Icon(Icons.broken_image_outlined, color: vertDassa),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tarifs(List<Map<String, dynamic>> tarifs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: grisFond,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          for (var i = 0; i < tarifs.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                children: [
                  Expanded(child: Text('${tarifs[i]['libelle'] ?? tarifs[i]['nom'] ?? 'Prestation'}')),
                  Text(
                    tarifs[i]['prix'] != null ? '${tarifs[i]['prix']} FCFA' : '',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = prestataire;
    final photos = p.photosList;
    final tarifs = p.tarifsList;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(p.nom),
        backgroundColor: Colors.white,
        foregroundColor: noirTexte,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _galerie(photos),
            const SizedBox(height: 16),
            Text(p.nom, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: noirTexte)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _badge(Icons.handyman, p.categorie, grisFond, noirTexte),
                _badge(Icons.location_on, p.quartier, grisFond, noirTexte),
                _badge(Icons.verified, 'Validé par Dassa Connect', vertClair, vertDassa),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'À partir de ${formatFcfa(p.prixBase)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: vertDassa),
            ),
            if (tarifs.isNotEmpty) ...[
              const SizedBox(height: 14),
              _tarifs(tarifs),
            ],
            const SizedBox(height: 18),
            const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              p.description.trim().isEmpty ? 'Ce prestataire n’a pas encore décrit ses services.' : p.description,
              style: const TextStyle(color: grisTexte, height: 1.45),
            ),
            const SizedBox(height: 22),
            FutureBuilder<List<CommandeLocale>>(
              future: ref.read(depotProvider).commandesDuFil('client', 'p:${p.uid}'),
              builder: (context, snap) {
                final dejaEnDiscussion = (snap.data ?? const <CommandeLocale>[]).isNotEmpty;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ConversationPage(
                          role: 'client',
                          cle: 'p:${p.uid}',
                          titre: p.nom,
                          photo: photos.isEmpty ? null : photos.first,
                          prestataireUid: p.uid,
                        ),
                      ),
                    ),
                    icon: Icon(dejaEnDiscussion ? Icons.chat : Icons.edit_note),
                    label: Text(
                      dejaEnDiscussion ? 'Ouvrir la discussion' : 'Écrire au prestataire',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vertDassa,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _appeler(context),
                    icon: const Icon(Icons.phone),
                    label: const Text('Appeler'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _whatsapp(context),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('WhatsApp'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
