import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/base.dart';
import '../providers.dart';
import '../theme.dart';
import '../utils.dart';
import 'commande.dart';
import 'widgets.dart';

/// Fiche d’un prestataire : photos (mises en cache), tarifs, et trois actions fixes en bas.
class FichePage extends ConsumerWidget {
  const FichePage({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liste = ref.watch(tousPrestatairesProvider).valueOrNull ?? const <PrestataireLocal>[];
    PrestataireLocal? trouve;
    for (final x in liste) {
      if (x.uid == uid) trouve = x;
    }
    if (trouve == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Fiche introuvable sur ce téléphone.', style: TextStyle(fontSize: 18))),
      );
    }
    final fiche = trouve;
    final photos = photosDe(fiche);
    final tarifs = tarifsDe(fiche);

    return Scaffold(
      appBar: AppBar(title: Text(fiche.nom)),
      body: ListView(
        children: [
          SizedBox(
            height: 200,
            child: photos.isEmpty
                ? Container(
                    color: const Color(0x1F006A4E),
                    alignment: Alignment.center,
                    child: const Icon(Icons.image, size: 80, color: vertBenin),
                  )
                : PageView(
                    children: [
                      for (final url in photos)
                        CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 60),
                        ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fiche.nom, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text(fiche.categorie, style: const TextStyle(fontSize: 16))),
                    const Chip(
                      avatar: Icon(Icons.wifi_off, size: 18, color: Colors.white),
                      label: Text('Disponible hors ligne', style: TextStyle(color: Colors.white)),
                      backgroundColor: vertBenin,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(fiche.quartier, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                const Text('Tarifs', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                for (final ligne in tarifs) _ligneTarif(ligne),
                const SizedBox(height: 20),
                const Text('Description', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(fiche.description, style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1565C0)),
                  onPressed: () => launchUrl(Uri(scheme: 'tel', path: fiche.telephone)),
                  icon: const Icon(Icons.call),
                  label: const Text('Appeler'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF128C4A)),
                  onPressed: () => launchUrl(
                    Uri.parse('https://wa.me/${chiffresSeulement(fiche.telephone)}'),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.chat),
                  label: const Text('WhatsApp'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: orangeVocal),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CommandePage(prestataireUid: fiche.uid)),
                  ),
                  icon: const Icon(Icons.mic),
                  label: const Text('Commander vocalement'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Une ligne de tarif au format « libellé|prix ».
  Widget _ligneTarif(String ligne) {
    final morceaux = ligne.split('|');
    final prix = morceaux.length > 1 ? (int.tryParse(morceaux[1]) ?? 0) : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(morceaux.first, style: const TextStyle(fontSize: 18))),
          Text(
            formatFcfa(prix),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: vertBenin),
          ),
        ],
      ),
    );
  }
}
