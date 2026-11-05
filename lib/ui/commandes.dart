import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/base.dart';
import '../data/fil.dart';
import '../data/lecture.dart';
import '../providers.dart';
import '../theme.dart';
import '../utils.dart';
import 'conversation.dart';
import 'photo.dart';
import 'statuts.dart';

/// Mes commandes : une carte par commande, avec son statut mis à jour en direct.
class CommandesPage extends ConsumerWidget {
  const CommandesPage({super.key});

  PrestataireLocal? _prestataire(List<PrestataireLocal> liste, String uid) {
    for (final p in liste) {
      if (p.uid == uid) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commandes = ref.watch(commandesClientProvider).valueOrNull ?? const <CommandeLocale>[];
    final prestataires = ref.watch(tousPrestatairesProvider).valueOrNull ?? const <PrestataireLocal>[];
    if (commandes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long, size: 56, color: Colors.grey),
              SizedBox(height: 12),
              Text('Aucune commande pour le moment', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text(
                'Vos commandes et leur suivi apparaîtront ici.',
                textAlign: TextAlign.center,
                style: TextStyle(color: grisTexte),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: commandes.length,
      itemBuilder: (context, i) {
        final c = commandes[i];
        final p = _prestataire(prestataires, c.prestataireUid);
        final nom = p?.nom ?? 'Prestataire';
        final photo = (p?.photosList ?? const <String>[]).isEmpty ? null : p!.photosList.first;
        final couleur = couleurStatutCommande(c.statut);
        final vocal = c.audioUrl != null || c.audioLocal != null;
        final apercu = c.messageTexte?.isNotEmpty == true
            ? c.messageTexte!
            : (vocal ? 'Message vocal' : 'Commande');
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ConversationPage(
                  role: 'client',
                  cle: cleFil('client', c),
                  titre: nom,
                  photo: photo,
                ),
              ),
            ),
            leading: Avatar(initiales: initiales(nom), photo: photo, rayon: 24),
            title: Text(nom, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(apercu, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: couleur.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          libelleStatut(c.statut),
                          style: TextStyle(color: couleur, fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(tempsEcoule(c.creeLe), style: const TextStyle(fontSize: 12, color: grisTexte)),
                    ],
                  ),
                ],
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}
