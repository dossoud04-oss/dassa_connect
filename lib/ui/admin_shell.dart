import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme.dart';
import 'connexion.dart';
import 'widgets.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});
  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _index = 0;

  Future<void> _seDeconnecter() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Oui', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authProvider).deconnecter();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ConnexionPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _validerPrestataires(),
      _tousPrestataires(),
      _transactions(),
      _parametresAvances(),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Scaffold(
          body: SafeArea(child: pages[_index]),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: vertDassa,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Validation'),
              BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Prestataires'),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Transactions'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Paramètres'),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- VALIDATION ----------
  Widget _validerPrestataires() {
    final isOnline = ref.watch(isOnlineProvider).value ?? true;
    final depot = ref.watch(depotProvider);

    return Column(
      children: [
        const BandeauConnexion(),
        _bandeauErreurs(),
        if (!isOnline)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(12)),
            child: const Text(
              'Hors ligne : vos validations seront synchronisées au retour du réseau',
              style: TextStyle(fontSize: 12, color: Color(0xFF856404)),
            ),
          ),
        Expanded(
          child: StreamBuilder(
            stream: depot.surveillerEnAttente(),
            builder: (context, snapshot) {
              final liste = snapshot.data ?? [];
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('En attente de validation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      _badgeCount('${liste.length}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (liste.isEmpty)
                    _emptyBox(Icons.check_circle_outline, 'Aucun prestataire en attente', 'Les nouvelles demandes apparaîtront ici.')
                  else
                    ...liste.map((p) => _cartePrestataireAdmin(p, pending: true)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Opérations refusées par le serveur (ex. compte admin Supabase non ouvert) :
  /// on le signale au lieu de laisser croire qu’une validation est enregistrée.
  Widget _bandeauErreurs() {
    final depot = ref.read(depotProvider);
    return StreamBuilder<int>(
      stream: depot.nombreEnErreur(),
      builder: (context, snap) {
        final n = snap.data ?? 0;
        if (n == 0) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$n action(s) refusée(s) par le serveur. Vérifiez la connexion administrateur Supabase.',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade800),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await depot.reessayerEnErreur();
                  await ref.read(syncProvider).synchroniser(manuelle: true);
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------- TOUS LES PRESTATAIRES (contrôle total) ----------
  Widget _tousPrestataires() {
    final depot = ref.watch(depotProvider);
    return Column(
      children: [
        const BandeauConnexion(compact: true),
        Expanded(
          child: StreamBuilder(
            stream: depot.surveillerTous(),
            builder: (context, snapshot) {
              final liste = snapshot.data ?? [];
              final approved = liste.where((p) => p.statut == 'approved').length;
              final pending = liste.where((p) => p.statut == 'pending').length;
              final rejected = liste.where((p) => p.statut == 'rejected').length;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Tous les prestataires', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _miniStat('Approuvés', '$approved', const Color(0xFF16A34A))),
                      const SizedBox(width: 8),
                      Expanded(child: _miniStat('Attente', '$pending', orangeDassa)),
                      const SizedBox(width: 8),
                      Expanded(child: _miniStat('Refusés', '$rejected', Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (liste.isEmpty)
                    _emptyBox(Icons.people_outline, 'Aucun prestataire', 'Les inscriptions apparaîtront ici.')
                  else
                    ...liste.map((p) => _cartePrestataireAdmin(p, pending: false)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------- TRANSACTIONS / COMMANDES ----------
  Widget _transactions() {
    final depot = ref.watch(depotProvider);
    return Column(
      children: [
        const BandeauConnexion(compact: true),
        Expanded(
          child: StreamBuilder(
            stream: depot.surveillerToutesCommandes(),
            builder: (context, snapshot) {
              final cmds = snapshot.data ?? [];
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Transactions / Commandes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      _badgeCount('${cmds.length}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (cmds.isEmpty)
                    _emptyBox(Icons.receipt_long, 'Aucune transaction', 'Les commandes clients apparaîtront ici.')
                  else
                    ...cmds.map((c) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.mic, color: orangeDassa, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      c.messageTexte?.isNotEmpty == true ? c.messageTexte! : 'Commande vocale',
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: vertClair,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(c.statut, style: const TextStyle(fontSize: 11, color: vertDassa, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('Client : ${c.clientTelephone}', style: const TextStyle(fontSize: 12, color: grisTexte)),
                              Text('Prestataire ID : ${c.prestataireUid.substring(0, 8)}…', style: const TextStyle(fontSize: 11, color: grisTexte)),
                              Text('${c.creeLe.day}/${c.creeLe.month}/${c.creeLe.year} ${c.creeLe.hour}:${c.creeLe.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 11, color: grisTexte)),
                              if (c.montant > 0)
                                Text('${c.montant} FCFA', style: const TextStyle(fontWeight: FontWeight.w700, color: vertDassa)),
                            ],
                          ),
                        )),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------- PARAMÈTRES ----------
  Widget _parametresAvances() {
    final categories = ref.watch(categoriesProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const BandeauConnexion(compact: true),
        const SizedBox(height: 8),
        const Text('Paramètres Admin', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('Gestion des métiers', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: Colors.grey.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.add_circle, color: Colors.blue),
                title: const Text('Ajouter une catégorie'),
                subtitle: const Text('Créer un nouveau métier'),
                onTap: () => _ajouterCategorie(context, ref),
              ),
              const Divider(height: 1),
              for (var entry in categories.entries)
                ListTile(
                  leading: Icon(getIconFromString(entry.value), color: vertDassa),
                  title: Text(entry.key),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => ref.read(categoriesProvider.notifier).supprimer(entry.key),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Sécurité', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: Colors.grey.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: const Column(
            children: [
              ListTile(
                leading: Icon(Icons.pin, color: vertDassa),
                title: Text('Code PIN (4 chiffres)'),
                subtitle: Text('Premier niveau de sécurité'),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.password, color: orangeDassa),
                title: Text('Code secret admin'),
                subtitle: Text('2e code alphanumérique (clavier)'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _seDeconnecter,
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red),
          ),
        ),
      ],
    );
  }

  // ---------- HELPERS UI ----------
  Widget _cartePrestataireAdmin(dynamic p, {required bool pending}) {
    final depot = ref.read(depotProvider);
    Color statutColor;
    String statutLabel;
    switch (p.statut) {
      case 'approved':
        statutColor = const Color(0xFF16A34A);
        statutLabel = 'Approuvé';
        break;
      case 'rejected':
        statutColor = Colors.red;
        statutLabel = 'Refusé';
        break;
      default:
        statutColor = orangeDassa;
        statutLabel = 'En attente';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: vertClair,
                child: Text(p.nom.isNotEmpty ? p.nom[0].toUpperCase() : '?', style: const TextStyle(color: vertDassa, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.nom, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    Text('${p.categorie} • ${p.quartier}', style: const TextStyle(color: grisTexte, fontSize: 12)),
                    Text(p.telephone, style: const TextStyle(color: grisTexte, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statutColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Text(statutLabel, style: TextStyle(color: statutColor, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (p.statut != 'approved')
                _actionBtn('Valider', const Color(0xFF16A34A), () async {
                  await depot.changerStatutPrestataire(p.uid, 'approved');
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.nom} validé'), backgroundColor: vertDassa));
                }),
              if (p.statut != 'rejected')
                _actionBtn('Refuser', Colors.red, () async {
                  await depot.changerStatutPrestataire(p.uid, 'rejected');
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.nom} refusé')));
                }),
              if (p.statut == 'rejected')
                _actionBtn('Réactiver', vertDassa, () async {
                  await depot.changerStatutPrestataire(p.uid, 'pending');
                }),
              _actionBtn('Supprimer', Colors.red.shade800, () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Supprimer ?'),
                    content: Text('Retirer définitivement ${p.nom} ? Ses commandes seront aussi supprimées.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (ok == true) {
                  await depot.supprimerPrestataire(p.uid);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prestataire supprimé')));
                }
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _badgeCount(String n) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
        child: Text(n, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
      );

  Widget _miniStat(String label, String value, Color color) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      );

  Widget _emptyBox(IconData icon, String title, String sub) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: const Color(0xFFBDBDBD)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center),
          ],
        ),
      );

  Future<void> _ajouterCategorie(BuildContext context, WidgetRef ref) async {
    final nomCtrl = TextEditingController();
    String iconName = 'handyman';
    final icons = {
      'handyman': Icons.carpenter,
      'engineering': Icons.precision_manufacturing,
      'hotel': Icons.hotel,
      'restaurant': Icons.restaurant,
      'plumbing': Icons.plumbing,
      'electric': Icons.electric_bolt,
      'cleaning': Icons.cleaning_services,
      'cut': Icons.content_cut,
      'brush': Icons.brush,
    };

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Nouvelle catégorie'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom du métier')),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: icons.entries.map((e) {
                  final selected = iconName == e.key;
                  return ChoiceChip(
                    label: Icon(e.value, size: 20, color: selected ? Colors.white : vertDassa),
                    selected: selected,
                    selectedColor: vertDassa,
                    onSelected: (_) => setLocal(() => iconName = e.key),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ajouter')),
          ],
        ),
      ),
    );
    if (ok == true && nomCtrl.text.trim().isNotEmpty) {
      await ref.read(categoriesProvider.notifier).ajouter(nomCtrl.text.trim(), iconName);
    }
  }
}
