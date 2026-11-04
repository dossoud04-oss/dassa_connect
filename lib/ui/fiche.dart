import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import 'commande.dart';

class FichePage extends StatelessWidget {
  /// Numéro du prestataire (format international de préférence, ex: +2290160821000)
  final String telephone;
  final String nom;
  final String metier;
  final String quartier;

  const FichePage({
    super.key,
    this.telephone = '+2290160000000',
    this.nom = 'Atelier Pierre Dassa',
    this.metier = 'Menuisier',
    this.quartier = 'Sokponta',
  });

  /// Chiffres seuls, sans + ni espaces
  String get _digits => telephone.replaceAll(RegExp(r'[^0-9]'), '');

  Future<void> _appeler(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: '+$_digits');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir l\'appel vers +$_digits')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appel non supporté ici. Numéro : +$_digits')),
        );
      }
    }
  }

  Future<void> _whatsapp(BuildContext context) async {
    final msg = Uri.encodeComponent('Bonjour $nom, je vous contacte via Dassa Connect.');
    // wa.me fonctionne sur mobile et sur le web
    final uri = Uri.parse('https://wa.me/$_digits?text=$msg');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('WhatsApp : https://wa.me/$_digits')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Prestataire Detail'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _photo('https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=400'),
                  const SizedBox(width: 10),
                  _photo('https://images.unsplash.com/photo-1538688525198-9b88f6f53126?w=400'),
                  const SizedBox(width: 10),
                  _photo('https://images.unsplash.com/photo-1504148455328-c376907d081c?w=400'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(nom, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: noirTexte)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _badge(Icons.handyman, metier, Colors.grey.shade100, noirTexte),
                _badge(Icons.location_on, quartier, Colors.grey.shade100, noirTexte),
                _badge(Icons.check_circle, 'Disponible hors-ligne', vertClair, vertDassa),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Tarifs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Column(
                children: [
                  _LigneTarif('Étagère bois massif', '25 000 FCFA'),
                  Divider(height: 1),
                  _LigneTarif('Porte sur mesure', '45 000 FCFA'),
                  Divider(height: 1),
                  _LigneTarif('Réparation meuble', '8 000 FCFA'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text(
              'Artisan menuisier avec plus de 10 ans d\'expérience. Spécialisé dans les meubles en bois massif, portes sur mesure et réparations. Travail soigné, matériaux locaux et de qualité. Devis gratuit et rapide sur demande.',
              style: TextStyle(color: grisTexte, height: 1.45, fontSize: 14),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _whatsapp(context),
                    icon: const Icon(Icons.chat, size: 20),
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommandePage())),
                icon: const Icon(Icons.mic, size: 22),
                label: const Text('Commander vocalement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeDassa,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _photo(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: 200,
        height: 160,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 200,
          height: 160,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}

class _LigneTarif extends StatelessWidget {
  final String nom;
  final String prix;
  const _LigneTarif(this.nom, this.prix);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nom, style: const TextStyle(fontSize: 14, color: noirTexte)),
          Text(prix, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: noirTexte)),
        ],
      ),
    );
  }
}
