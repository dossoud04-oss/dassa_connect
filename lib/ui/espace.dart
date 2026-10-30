import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../data/base.dart';
import '../providers.dart';
import '../theme.dart';
import '../utils.dart';
import 'widgets.dart';

/// Sections réservées aux prestataires et à l’administrateur, affichées dans l’onglet Profil.
class EspaceSections extends ConsumerWidget {
  const EspaceSections({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sessionProvider);
    final prestataire = ref.watch(monPrestataireProvider);
    final admin = ref.watch(estAdminProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (prestataire != null) _Tableau(p: prestataire),
        if (admin) const _Validation(),
      ],
    );
  }
}

/// Tableau de bord du prestataire : statistiques, commandes vocales, boutique.
class _Tableau extends ConsumerWidget {
  const _Tableau({required this.p});

  final PrestataireLocal p;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commandes = ref.watch(commandesPrestataireProvider(p.uid)).valueOrNull ?? const <CommandeLocale>[];
    final revenu = commandes.where((c) => c.statut == 'livree').fold<int>(0, (somme, c) => somme + c.montant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Text('Tableau de bord prestataire', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            _statistique(Icons.visibility, 'Vues', '${p.vues}'),
            const SizedBox(width: 10),
            _statistique(Icons.assignment, 'Commandes', '${commandes.length}'),
            const SizedBox(width: 10),
            _statistique(Icons.payments, 'Revenue', formatFcfa(revenu)),
          ],
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Icon(Icons.mic, color: orangeVocal),
            SizedBox(width: 8),
            Text('Commandes vocales entrantes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        if (commandes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Aucune commande pour l’instant.', style: TextStyle(fontSize: 18)),
          ),
        for (final c in commandes) _Commande(c: c),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _photo(context, ref),
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Ajouter photo'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _prix(context, ref),
                icon: const Icon(Icons.edit),
                label: const Text('Modifier prix'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Boutique(p: p),
      ],
    );
  }

  Widget _statistique(IconData icone, String libelle, String valeur) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(color: const Color(0xFFE8F5EF), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            CircleAvatar(radius: 22, backgroundColor: vertBenin, child: Icon(icone, color: Colors.white)),
            const SizedBox(height: 8),
            Text(valeur, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: vertBenin)),
            Text(libelle, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  /// La photo est copiée sur le téléphone puis mise en file : elle partira à la prochaine connexion.
  Future<void> _photo(BuildContext context, WidgetRef ref) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 60);
    if (image == null) return;
    final chemin = await ref.read(voixProvider).conserver(image.path);
    await ref.read(depotProvider).ajouterPhoto(p.uid, chemin);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo enregistrée. Elle sera envoyée dès la connexion.')),
    );
  }

  Future<void> _prix(BuildContext context, WidgetRef ref) async {
    final controleur = TextEditingController(text: '${p.prixBase}');
    final valeur = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouveau prix de base (FCFA)'),
        content: TextField(controller: controleur, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 22)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(controleur.text.trim())),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    controleur.dispose();
    if (valeur == null) return;
    await ref.read(depotProvider).changerPrix(p.uid, valeur);
  }
}

/// Boutique : l’état d’approbation de la fiche. Aucun délai de réponse n’est affiché : il n’est pas mesuré.
class _Boutique extends StatelessWidget {
  const _Boutique({required this.p});

  final PrestataireLocal p;

  @override
  Widget build(BuildContext context) {
    final approuve = p.statut == 'approved';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFE8F5EF), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront, color: vertBenin, size: 30),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Ma boutique', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: vertBenin)),
              ),
              Chip(
                label: Text(approuve ? 'Approuvé' : 'En attente'),
                backgroundColor: approuve ? Colors.green.shade100 : Colors.orange.shade100,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            approuve ? 'Votre fiche est visible par les clients.' : 'Votre fiche attend la validation de l’administrateur.',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

/// Une commande reçue : numéro, message, bulle audio, puis actions.
class _Commande extends ConsumerWidget {
  const _Commande({required this.c});

  final CommandeLocale c;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source = c.audioUrl ?? c.audioLocal;
    final depot = ref.read(depotProvider);
    final initialesClient =
        c.clientTelephone.length >= 2 ? c.clientTelephone.substring(c.clientTelephone.length - 2) : '?';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: vertBenin,
                  child: Text(initialesClient, style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Commande #${c.uid.substring(0, 4).toUpperCase()}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${c.messageTexte ?? 'Commande vocale'} • ${tempsEcoule(c.creeLe)}',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (source != null) ...[
              const SizedBox(height: 8),
              BulleVocale(source: source, duree: c.audioDuree),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (c.statut == 'nouvelle')
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => depot.changerStatutCommande(c.uid, 'ecoutee'),
                      child: const Text('Écoutée'),
                    ),
                  ),
                if (c.statut != 'livree') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => depot.changerStatutCommande(c.uid, 'livree'),
                      child: const Text('Livrée'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Validation des prestataires : bandeaux mode avion et synchronisation, puis fiches à valider.
class _Validation extends ConsumerWidget {
  const _Validation();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enLigne = ref.watch(enLigneProvider).valueOrNull ?? true;
    final actions = ref.watch(nombreActivesProvider).valueOrNull ?? 0;
    final attente = ref.watch(attenteValidationProvider).valueOrNull ?? const <PrestataireLocal>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Text('Administration', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (!enLigne)
          bandeau(orangeVocal, Icons.airplanemode_active, 'Mode Avion - Vous êtes hors ligne - Validation locale active'),
        const SizedBox(height: 6),
        bandeau(
          jauneAccent,
          Icons.sync,
          '$actions actions en attente - Seront synchronisées automatiquement dès le retour en ligne',
          couleurTexte: noir,
        ),
        const SizedBox(height: 8),
        Text('Prestataires en attente : ${attente.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        for (final p in attente)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.nom, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(
                    '${p.categorie} · ID PV-${p.uid.substring(0, 4).toUpperCase()}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: vertBenin),
                          onPressed: () => ref.read(depotProvider).changerStatutPrestataire(p.uid, 'approved'),
                          child: const Text('Valider'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => ref.read(depotProvider).changerStatutPrestataire(p.uid, 'rejected'),
                          child: const Text('Refuser'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
