import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/base.dart';
import '../data/lecture.dart';
import '../theme.dart';
import '../utils.dart';
import 'commande.dart';

/// Fiche d’un prestataire validé : toutes les informations viennent de la base locale.
class FichePage extends StatelessWidget {
  final PrestataireLocal prestataire;
  const FichePage({super.key, required this.prestataire});

  String get _chiffres => prestataire.telephone.replaceAll(RegExp(r'[^0-9]'), '');

  void _snack(BuildContext context, String texte) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texte)));

  Future<void> _appeler(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: '+$_chiffres');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) _snack(context, 'Impossible d’ouvrir l’appel vers +$_chiffres');
    } catch (_) {
      if (context.mounted) _snack(context, 'Appel non supporté ici. Numéro : +$_chiffres');
    }
  }

  Future<void> _whatsapp(BuildContext context) async {
    final msg = Uri.encodeComponent('Bonjour ${prestataire.nom}, je vous contacte via Dassa Connect.');
    final uri = Uri.parse('https://wa.me/$_chiffres?text=$msg');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) _snack(context, 'Impossible d’ouvrir WhatsApp');
    } catch (_) {
      if (context.mounted) _snack(context, 'WhatsApp : https://wa.me/$_chiffres');
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
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(color: vertClair, borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.image_outlined, size: 56, color: vertDassa),
      );
    }
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(photos[i], width: 220, height: 160, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _tarifs(List<Map<String, dynamic>> tarifs) {
    if (tarifs.isEmpty) {
      return Text(
        'Prix de base : ${formatFcfa(prestataire.prixBase)}',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          for (var i = 0; i < tarifs.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _LigneTarif(
              libelle: '${tarifs[i]['libelle'] ?? tarifs[i]['nom'] ?? 'Prestation'}',
              prix: tarifs[i]['prix'] != null ? '${tarifs[i]['prix']} FCFA' : '',
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = prestataire;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Fiche prestataire')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _galerie(p.photosList),
            const SizedBox(height: 16),
            Text(p.nom, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: noirTexte)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _badge(Icons.handyman, p.categorie, Colors.grey.shade100, noirTexte),
                _badge(Icons.location_on, p.quartier, Colors.grey.shade100, noirTexte),
                _badge(Icons.verified, 'Validé par Dassa Connect', vertClair, vertDassa),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Tarifs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _tarifs(p.tarifsList),
            const SizedBox(height: 24),
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              p.description.trim().isEmpty ? 'Ce prestataire n’a pas encore décrit ses services.' : p.description,
              style: const TextStyle(color: grisTexte, height: 1.45, fontSize: 14),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _appeler(context),
                    icon: const Icon(Icons.phone, size: 20),
                    label: const Text('Appeler'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _whatsapp(context),
                    icon: const Icon(Icons.chat, size: 20),
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CommandePage(prestataireUid: p.uid, prestataireNom: p.nom),
                  ),
                ),
                icon: const Icon(Icons.edit_note, size: 20),
                label: const Text('Passer une commande'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeDassa,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LigneTarif extends StatelessWidget {
  final String libelle;
  final String prix;
  const _LigneTarif({required this.libelle, required this.prix});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(child: Text(libelle, style: const TextStyle(fontSize: 14))),
            Text(prix, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
