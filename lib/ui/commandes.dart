import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/base.dart';
import '../providers.dart';
import '../utils.dart';
import 'widgets.dart';

const _libellesStatut = {'nouvelle': 'Envoyée', 'ecoutee': 'Écoutée', 'livree': 'Livrée'};

/// Onglet Commandes : les commandes envoyées depuis ce téléphone.
class CommandesPage extends ConsumerWidget {
  const CommandesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commandes = ref.watch(commandesClientProvider).valueOrNull ?? const <CommandeLocale>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: commandes.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Vos commandes apparaîtront ici.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: commandes.length,
              itemBuilder: (context, i) => _CarteCommande(c: commandes[i]),
            ),
    );
  }
}

class _CarteCommande extends StatelessWidget {
  const _CarteCommande({required this.c});

  final CommandeLocale c;

  @override
  Widget build(BuildContext context) {
    final source = c.audioUrl ?? c.audioLocal;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_libellesStatut[c.statut] ?? c.statut} · ${tempsEcoule(c.creeLe)}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            if (source != null) ...[
              const SizedBox(height: 8),
              BulleVocale(source: source, duree: c.audioDuree),
            ],
            if (c.messageTexte != null) ...[
              const SizedBox(height: 8),
              Text(c.messageTexte!, style: const TextStyle(fontSize: 18)),
            ],
          ],
        ),
      ),
    );
  }
}
