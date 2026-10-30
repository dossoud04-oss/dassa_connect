import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers.dart';
import '../sync/synchro.dart';
import '../utils.dart';
import 'connexion.dart';
import 'espace.dart';

/// Onglet Profil : état de la file, synchronisation manuelle, espace prestataire ou administrateur, connexion.
class ProfilPage extends ConsumerStatefulWidget {
  const ProfilPage({super.key});

  @override
  ConsumerState<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends ConsumerState<ProfilPage> {
  String _info = '';
  bool _occupe = false;

  Future<void> _synchroniser() async {
    setState(() => _occupe = true);
    final bilan = await ref.read(syncProvider).synchroniser(manuelle: true);
    if (!mounted) return;
    setState(() {
      _occupe = false;
      _info = _decrire(bilan);
    });
  }

  String _decrire(BilanSync b) {
    return switch (b.statut) {
      StatutSync.ok => 'Synchronisé : ${b.envoyees} envoyée(s), ${b.recues} reçue(s), ${b.echecs} en échec.',
      StatutSync.horsLigne => 'Pas d’accès à Supabase. Les données restent sur ce téléphone.',
      StatutSync.intervalle => 'Une synchronisation automatique a eu lieu il y a moins de 15 minutes.',
      StatutSync.dejaEnCours => 'Une synchronisation est déjà en cours.',
      StatutSync.erreur => 'Erreur pendant la synchronisation. Les opérations restent en file.',
    };
  }

  Future<void> _deconnecter() async {
    final ok = await ref.read(authProvider).deconnecter();
    if (!mounted) return;
    setState(() {
      _info = ok
          ? 'Vous êtes déconnecté.'
          : 'Synchronisez avant de vous déconnecter : des opérations attendent encore d’être envoyées.';
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(sessionProvider);
    final connecte = Supabase.instance.client.auth.currentUser != null;
    final actives = ref.watch(nombreActivesProvider).valueOrNull ?? 0;
    final erreurs = ref.watch(nombreErreursProvider).valueOrNull ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(leading: const Icon(Icons.cloud_upload), title: Text('En attente d’envoi : $actives')),
          ListTile(leading: const Icon(Icons.error_outline), title: Text('En erreur (après 5 essais) : $erreurs')),
          FutureBuilder<DateTime?>(
            future: ref.read(depotProvider).lireDate('derniere_sync'),
            builder: (context, instantane) => ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(
                instantane.data == null
                    ? 'Jamais synchronisé'
                    : 'Dernière synchronisation : ${tempsEcoule(instantane.data!)}',
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_info.isNotEmpty) Text(_info, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _occupe ? null : _synchroniser,
            icon: const Icon(Icons.sync),
            label: const Text('Synchroniser maintenant'),
          ),
          const EspaceSections(),
          const SizedBox(height: 24),
          if (connecte)
            OutlinedButton(onPressed: _deconnecter, child: const Text('Se déconnecter'))
          else
            OutlinedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnexionPage())),
              child: const Text('Connexion prestataire ou administrateur'),
            ),
        ],
      ),
    );
  }
}
