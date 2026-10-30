import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme.dart';
import '../utils.dart';
import 'widgets.dart';

/// Commande vocale ou écrite. Elle est enregistrée sur le téléphone, puis envoyée au retour du réseau.
class CommandePage extends ConsumerStatefulWidget {
  const CommandePage({super.key, required this.prestataireUid});

  final String prestataireUid;

  @override
  ConsumerState<CommandePage> createState() => _CommandePageState();
}

class _CommandePageState extends ConsumerState<CommandePage> {
  final _telephone = TextEditingController();
  final _texte = TextEditingController();
  String? _chemin;
  int _duree = 0;
  bool _envoi = false;

  @override
  void dispose() {
    _telephone.dispose();
    _texte.dispose();
    super.dispose();
  }

  void _message(String texte) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texte, style: const TextStyle(fontSize: 16))));
  }

  Future<void> _envoyer() async {
    final telephone = chiffresSeulement(_telephone.text);
    final texte = _texte.text.trim();
    if (telephone.length < 8) {
      _message('Indiquez votre numéro de téléphone.');
      return;
    }
    if (_chemin == null && texte.isEmpty) {
      _message('Parlez ou écrivez votre commande.');
      return;
    }
    setState(() => _envoi = true);
    final fichier = _chemin == null ? null : await ref.read(voixProvider).conserver(_chemin!);
    await ref.read(depotProvider).creerCommande(
          clientTelephone: telephone,
          prestataireUid: widget.prestataireUid,
          message: texte.isEmpty ? null : texte,
          audioLocal: fichier,
          duree: _duree,
        );
    if (!mounted) return;
    _message('Commande enregistrée localement, sera envoyée dès WiFi');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commande vocale')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Appuyez et parlez', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
              'Exemple : « Je veux une porte de 2 m pour samedi »',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            MicroVocal(
              voix: ref.read(voixProvider),
              onChange: (chemin, duree) => setState(() {
                _chemin = chemin;
                _duree = duree;
              }),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Text('Ou écrire', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              controller: _texte,
              maxLines: 3,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(hintText: 'Votre commande', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _telephone,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(labelText: 'Votre numéro de téléphone', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _envoi ? null : _envoyer,
              icon: const Icon(Icons.send, size: 26),
              label: const Text('Envoyer commande vocale'),
              style: FilledButton.styleFrom(backgroundColor: vertBenin),
            ),
          ],
        ),
      ),
    );
  }
}
