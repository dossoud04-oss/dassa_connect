import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme.dart';
import '../utils.dart';
import 'widgets.dart';

/// Commande adressée à un prestataire : texte, message vocal, ou les deux.
/// Enregistrée dans la base locale, puis envoyée à Supabase par la file de synchronisation.
class CommandePage extends ConsumerStatefulWidget {
  final String prestataireUid;
  final String prestataireNom;
  const CommandePage({super.key, required this.prestataireUid, required this.prestataireNom});

  @override
  ConsumerState<CommandePage> createState() => _CommandePageState();
}

class _CommandePageState extends ConsumerState<CommandePage> {
  final _texteCtrl = TextEditingController();
  bool _occupe = false;
  bool _enregistrement = false;
  DateTime? _debut;
  String? _cheminAudio;
  int _duree = 0;

  @override
  void dispose() {
    _texteCtrl.dispose();
    super.dispose();
  }

  void _snack(String texte, {Color? couleur}) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(texte), backgroundColor: couleur),
      );

  /// Premier appui : démarre l’enregistrement. Second appui : l’arrête et garde le message.
  Future<void> _basculerMicro() async {
    final voix = ref.read(voixProvider);
    if (!_enregistrement) {
      try {
        final autorise = await voix.demarrer();
        if (!mounted) return;
        if (!autorise) {
          _snack('Autorisez l’accès au micro pour enregistrer un message.');
          return;
        }
        setState(() {
          _enregistrement = true;
          _debut = DateTime.now();
          _cheminAudio = null;
          _duree = 0;
        });
      } catch (e) {
        _snack('Micro indisponible : $e');
      }
      return;
    }
    final chemin = await voix.arreter();
    if (!mounted) return;
    setState(() {
      _enregistrement = false;
      _cheminAudio = chemin;
      _duree = _debut == null ? 0 : DateTime.now().difference(_debut!).inSeconds;
    });
    if (chemin == null) _snack('L’enregistrement n’a pas abouti. Réessayez.');
  }

  /// Numéro au format +229XXXXXXXX, avec la même logique que l’écran de connexion.
  String? _normaliser(String saisie) {
    final chiffres = chiffresSeulement(saisie);
    if (chiffres.length < 8) return null;
    return chiffres.startsWith('229') ? '+$chiffres' : '+229$chiffres';
  }

  Future<String?> _demanderNumero(String dejaEnregistre) async {
    final ctrl = TextEditingController(text: dejaEnregistre);
    final saisie = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Votre numéro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pour que le prestataire puisse vous répondre :', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(prefixText: '+229 ', hintText: '01 XX XX XX XX'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Envoyer')),
        ],
      ),
    );
    if (saisie == null) return null;
    final numero = _normaliser(saisie);
    if (numero == null) _snack('Numéro invalide (8 chiffres minimum).');
    return numero;
  }

  Future<void> _envoyer() async {
    final texte = _texteCtrl.text.trim();
    if (texte.isEmpty && _cheminAudio == null) {
      _snack('Écrivez ou enregistrez votre commande avant de l’envoyer.');
      return;
    }
    if (_enregistrement) {
      _snack('Arrêtez l’enregistrement avant d’envoyer.');
      return;
    }
    final depot = ref.read(depotProvider);
    final memorise = await depot.lireEtat('client_telephone');
    if (!mounted) return;
    final numero = await _demanderNumero(
      chiffresSeulement(memorise ?? '').replaceFirst(RegExp(r'^229'), ''),
    );
    if (numero == null || !mounted) return;

    setState(() => _occupe = true);
    try {
      String? audioLocal;
      if (_cheminAudio != null) {
        // Copie du message dans le dossier de l’app : il survit jusqu’à l’envoi au serveur.
        audioLocal = await ref.read(voixProvider).conserver(_cheminAudio!);
      }
      await depot.creerCommande(
        clientTelephone: numero,
        prestataireUid: widget.prestataireUid,
        message: texte.isEmpty ? null : texte,
        audioLocal: audioLocal,
        duree: _duree,
      );
      if (!mounted) return;
      _snack('Commande envoyée à ${widget.prestataireNom}', couleur: vertDassa);
      Navigator.pop(context);
    } catch (e) {
      _snack('Erreur : $e');
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  Widget _zoneVocale() {
    if (_cheminAudio != null && !_enregistrement) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BulleVocale(source: _cheminAudio, duree: _duree),
          IconButton(
            tooltip: 'Supprimer le message vocal',
            onPressed: () => setState(() {
              _cheminAudio = null;
              _duree = 0;
            }),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      );
    }
    return GestureDetector(
      onTap: _basculerMicro,
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _enregistrement ? Colors.red : orangeDassa,
          boxShadow: [
            BoxShadow(
              color: (_enregistrement ? Colors.red : orangeDassa).withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(_enregistrement ? Icons.stop : Icons.mic, color: Colors.white, size: 48),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final legende = _enregistrement
        ? 'Enregistrement… appuyez pour arrêter'
        : (_cheminAudio != null ? 'Message vocal prêt' : 'Appuyez pour dicter votre commande');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Commander')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Text(
              'Commande pour ${widget.prestataireNom}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: noirTexte),
            ),
            const SizedBox(height: 24),
            _zoneVocale(),
            const SizedBox(height: 10),
            Text(legende, style: const TextStyle(color: grisTexte, fontSize: 13)),
            const SizedBox(height: 24),
            TextField(
              controller: _texteCtrl,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Ou écrivez votre commande : Ex. porte 2 m pour samedi',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _occupe ? null : _envoyer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: vertDassa,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _occupe
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Envoyer ma commande', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
