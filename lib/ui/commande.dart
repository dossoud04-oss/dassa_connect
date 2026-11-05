import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import '../providers.dart';
import '../theme.dart';
import '../utils.dart';
import 'conversation.dart';

/// Première commande d'une conversation : texte, message vocal, ou les deux.
/// Si la conversation existe déjà, le message y est ajouté au lieu de créer une nouvelle commande.
class CommandePage extends ConsumerStatefulWidget {
  const CommandePage({super.key, required this.prestataireUid, required this.prestataireNom, this.photo});

  final String prestataireUid;
  final String prestataireNom;
  final String? photo;

  @override
  ConsumerState<CommandePage> createState() => _CommandePageState();
}

class _CommandePageState extends ConsumerState<CommandePage> {
  final _texteCtrl = TextEditingController();
  bool _occupe = false;
  bool _enregistrement = false;
  DateTime? _debut;
  Uint8List? _octets;
  int _duree = 0;

  @override
  void dispose() {
    _texteCtrl.dispose();
    super.dispose();
  }

  void _snack(String texte) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texte)));
  }

  Future<void> _basculerMicro() async {
    final voix = ref.read(voixProvider);
    if (!_enregistrement) {
      try {
        final autorise = await voix.demarrer();
        if (!mounted) return;
        if (!autorise) {
          _snack('Autorisez le micro pour enregistrer un message.');
          return;
        }
        setState(() {
          _enregistrement = true;
          _debut = DateTime.now();
          _octets = null;
          _duree = 0;
        });
      } catch (e) {
        _snack('Micro indisponible : $e');
      }
      return;
    }
    final chemin = await voix.arreter();
    if (!mounted) return;
    final debut = _debut;
    setState(() {
      _enregistrement = false;
      _duree = debut == null ? 0 : DateTime.now().difference(debut).inSeconds;
    });
    if (chemin == null) {
      _snack('L’enregistrement n’a pas abouti. Réessayez.');
      return;
    }
    try {
      final octets = await XFile(chemin).readAsBytes();
      if (mounted) setState(() => _octets = octets);
    } catch (e) {
      _snack('Lecture du message impossible : $e');
    }
  }

  /// Numéro au format +229XXXXXXXX.
  String? _normaliser(String saisie) {
    final chiffres = chiffresSeulement(saisie);
    if (chiffres.length < 8) return null;
    return chiffres.startsWith('229') ? '+$chiffres' : '+229$chiffres';
  }

  Future<String?> _demanderNumero() async {
    final ctrl = TextEditingController();
    final saisie = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Votre numéro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Le prestataire vous répondra sur ce numéro. Il est demandé une seule fois.',
              style: TextStyle(fontSize: 13),
            ),
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
          ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Valider')),
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
    if (texte.isEmpty && _octets == null) {
      _snack('Écrivez ou enregistrez votre commande.');
      return;
    }
    if (_enregistrement) {
      _snack('Arrêtez l’enregistrement avant d’envoyer.');
      return;
    }
    final depot = ref.read(depotProvider);
    final telephone = await depot.lireEtat('client_telephone') ?? await _demanderNumero();
    if (telephone == null || !mounted) return;
    await depot.ecrireEtat('client_telephone', telephone);

    setState(() => _occupe = true);
    try {
      final existantes = await depot.commandesDuFil('client', 'p:${widget.prestataireUid}');
      final message = texte.isEmpty ? null : texte;
      if (existantes.isEmpty) {
        await depot.creerCommande(
          clientTelephone: telephone,
          prestataireUid: widget.prestataireUid,
          message: message,
          audioBytes: _octets,
          duree: _duree,
        );
      } else {
        await depot.envoyerMessage(
          commandeUid: existantes.first.uid,
          auteur: 'client',
          texte: message,
          audioBytes: _octets,
          duree: _duree,
        );
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ConversationPage(
            role: 'client',
            cle: 'p:${widget.prestataireUid}',
            titre: widget.prestataireNom,
            photo: widget.photo,
          ),
        ),
      );
    } catch (e) {
      _snack('Erreur : $e');
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  Widget _zoneVocale() {
    if (_octets != null && !_enregistrement) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFDCF8C6), borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mic, color: vertDassa),
                const SizedBox(width: 8),
                Text('Message vocal · ${formatDuree(_duree)}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Supprimer le message vocal',
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => setState(() {
              _octets = null;
              _duree = 0;
            }),
          ),
        ],
      );
    }
    return GestureDetector(
      onTap: _basculerMicro,
      child: Container(
        width: 104,
        height: 104,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _enregistrement ? Colors.red : vertDassa,
          boxShadow: [
            BoxShadow(
              color: (_enregistrement ? Colors.red : vertDassa).withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(_enregistrement ? Icons.stop : Icons.mic, color: Colors.white, size: 46),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final legende = _enregistrement
        ? 'Enregistrement… appuyez pour arrêter'
        : (_octets != null ? 'Message vocal prêt' : 'Appuyez pour dicter votre commande');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.prestataireNom),
        backgroundColor: Colors.white,
        foregroundColor: noirTexte,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            const Text(
              'Décrivez votre besoin',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: noirTexte),
            ),
            const SizedBox(height: 4),
            const Text(
              'Votre message part dans la conversation avec ce prestataire.',
              textAlign: TextAlign.center,
              style: TextStyle(color: grisTexte, fontSize: 13),
            ),
            const SizedBox(height: 24),
            _zoneVocale(),
            const SizedBox(height: 10),
            Text(legende, style: const TextStyle(color: grisTexte, fontSize: 13)),
            const SizedBox(height: 22),
            TextField(
              controller: _texteCtrl,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Ou écrivez votre demande…',
                filled: true,
                fillColor: grisFond,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _occupe ? null : _envoyer,
                icon: _occupe
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send),
                label: const Text('Envoyer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: vertDassa,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
