// lib/ui/connexion.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme.dart';
import 'widgets.dart';

/// Page de connexion locale : numéro de téléphone, puis code PIN.
class ConnexionPage extends ConsumerStatefulWidget {
  const ConnexionPage({super.key});

  @override
  ConsumerState<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends ConsumerState<ConnexionPage> {
  String _numero = '';
  bool _occupe = false;

  void _message(String texte) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texte, style: const TextStyle(fontSize: 16))),
    );
  }

  Future<void> _validerNumero() async {
    if (_numero.length != 8) {
      _message('Entrez les 8 chiffres de votre numéro.');
      return;
    }
    setState(() => _occupe = true);
    
    try {
      final auth = ref.read(authProvider);
      
      // 1. On enregistre le numéro localement
      await auth.connecterLocalement(_numero);
      if (!mounted) return;
      
      // 2. Si c'est la première fois, on demande de créer un PIN
      if (!await auth.pinDefini()) {
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PinPage(creation: true)),
        );
      }
      
      // 3. On ferme la page de connexion pour aller à l'accueil
      if (mounted) Navigator.pop(context);
      
    } catch (_) {
      _message('Erreur lors de la connexion.');
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const LogoDassa(taille: 36)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Entrez votre numéro',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                DropdownButton<String>(
                  value: '+229',
                  onChanged: null,
                  items: const [
                    DropdownMenuItem(
                      value: '+229',
                      child: Text('🇧🇯 +229', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _numero.isEmpty ? '97 XXXXXXXX' : _numero,
                    style: const TextStyle(fontSize: 24, letterSpacing: 2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Clavier(
                onChiffre: (c) => setState(() {
                  if (_numero.length < 8) _numero += c;
                }),
                onEffacer: () => setState(() {
                  if (_numero.isNotEmpty) {
                    _numero = _numero.substring(0, _numero.length - 1);
                  }
                }),
              ),
            ),
            FilledButton(
              onPressed: _occupe ? null : _validerNumero,
              child: const Text('Continuer'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Code PIN à 4 chiffres. En création, il faut le saisir deux fois.
class PinPage extends ConsumerStatefulWidget {
  const PinPage({super.key, required this.creation, this.onDeverrouille});

  final bool creation;
  final VoidCallback? onDeverrouille;

  @override
  ConsumerState<PinPage> createState() => _PinPageState();
}

class _PinPageState extends ConsumerState<PinPage> {
  String _saisie = '';
  String? _premier;
  String _info = '';

  void _chiffre(String c) {
    if (_saisie.length >= 4) return;
    setState(() {
      _saisie += c;
      _info = '';
    });
    if (_saisie.length == 4) _valider();
  }

  void _effacer() {
    if (_saisie.isEmpty) return;
    setState(() => _saisie = _saisie.substring(0, _saisie.length - 1));
  }

  Future<void> _valider() async {
    final auth = ref.read(authProvider);
    
    if (!widget.creation) {
      if (await auth.verifierPin(_saisie)) {
        widget.onDeverrouille?.call();
      } else {
        setState(() {
          _saisie = '';
          _info = 'Code PIN incorrect.';
        });
      }
      return;
    }
    
    // Mode création
    if (_premier == null) {
      setState(() {
        _premier = _saisie;
        _saisie = '';
        _info = 'Confirmez votre code PIN.';
      });
      return;
    }
    
    if (_premier == _saisie) {
      await auth.definirPin(_saisie);
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        _premier = null;
        _saisie = '';
        _info = 'Les codes ne correspondent pas. Recommencez.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final titre = widget.creation
        ? (_premier == null
            ? 'Créez un code PIN de 4 chiffres'
            : 'Confirmez votre code PIN')
        : 'Entrez votre code PIN';
        
    return Scaffold(
      appBar: AppBar(title: const Text('Code PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              titre,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 4; i++)
                  Container(
                    margin: const EdgeInsets.all(8),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _saisie.length ? vertBenin : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _info,
              style: const TextStyle(fontSize: 18, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Expanded(child: Clavier(onChiffre: _chiffre, onEffacer: _effacer)),
          ],
        ),
      ),
    );
  }
}
