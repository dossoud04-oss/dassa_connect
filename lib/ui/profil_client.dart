import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme.dart';
import 'connexion.dart';

/// Profil client sans obligation de compte : historique local, préférences, infos app.
class ProfilClientPage extends ConsumerWidget {
  const ProfilClientPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final depot = ref.watch(depotProvider);

    return Scaffold(
      backgroundColor: grisFond,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: vertClair,
                    child: Icon(Icons.person, size: 44, color: vertDassa),
                  ),
                  const SizedBox(height: 12),
                  const Text('Espace Client', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: vertDassa)),
                  const SizedBox(height: 4),
                  const Text('Pas besoin de compte pour explorer', style: TextStyle(color: grisTexte, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _section('Mes commandes', [
              StreamBuilder(
                stream: depot.surveillerCommandesClient(),
                builder: (context, snap) {
                  final cmds = snap.data ?? [];
                  if (cmds.isEmpty) {
                    return const ListTile(
                      leading: Icon(Icons.inbox_outlined, color: grisTexte),
                      title: Text('Aucune commande pour le moment'),
                      subtitle: Text('Vos commandes vocales apparaîtront ici'),
                    );
                  }
                  return Column(
                    children: cmds.take(10).map((c) {
                      return ListTile(
                        leading: const Icon(Icons.mic, color: orangeDassa),
                        title: Text(c.messageTexte?.isNotEmpty == true ? c.messageTexte! : 'Commande vocale'),
                        subtitle: Text('${c.clientTelephone} • ${c.statut}'),
                        trailing: Text(
                          '${c.creeLe.day}/${c.creeLe.month}',
                          style: const TextStyle(fontSize: 12, color: grisTexte),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ]),

            _section('Préférences', [
              ListTile(
                leading: const Icon(Icons.phone_android, color: vertDassa),
                title: const Text('Mon numéro (optionnel)'),
                subtitle: const Text('Utilisé uniquement lors d\'une commande'),
                onTap: () async {
                  final ctrl = TextEditingController();
                  final n = await showDialog<String>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Enregistrer mon numéro'),
                      content: TextField(
                        controller: ctrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(prefixText: '+229 ', hintText: '01 XX XX XX XX'),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                          child: const Text('Sauver'),
                        ),
                      ],
                    ),
                  );
                  if (n != null && n.isNotEmpty) {
                    await depot.ecrireEtat('client_telephone', '+229$n');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Numéro enregistré localement')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined, color: vertDassa),
                title: const Text('Notifications'),
                subtitle: const Text('Alertes commandes et messages'),
                trailing: Switch(value: true, onChanged: (_) {}, activeColor: vertDassa),
              ),
            ]),

            _section('À propos', [
              const ListTile(
                leading: Icon(Icons.info_outline, color: vertDassa),
                title: Text('Dassa Connect'),
                subtitle: Text('Trouver un prestataire près de toi • Mode hors-ligne'),
              ),
              ListTile(
                leading: const Icon(Icons.handyman, color: vertDassa),
                title: const Text('Devenir prestataire'),
                subtitle: const Text('Proposer vos services'),
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const ConnexionPage()),
                    (_) => false,
                  );
                },
              ),
            ]),

            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const ConnexionPage()),
                  (_) => false,
                );
              },
              icon: const Icon(Icons.home_outlined),
              label: const Text('Retour à l\'accueil connexion'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String titre, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(titre, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: vertDassa)),
          ),
          ...children,
        ],
      ),
    );
  }
}
