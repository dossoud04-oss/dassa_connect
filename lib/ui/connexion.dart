import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme.dart';
import 'widgets.dart';
import 'client_shell.dart';      
import 'prestataire_shell.dart'; 
import 'admin_shell.dart';       

class ConnexionPage extends ConsumerWidget {
  const ConnexionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LogoDassa(taille: 60),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, foregroundColor: vertDassa,
                    side: const BorderSide(color: vertDassa, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.person),
                  label: const Text('Je suis un Client', style: TextStyle(fontSize: 18)),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ClientShell())),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vertDassa, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.work),
                  label: const Text('Je suis Prestataire', style: TextStyle(fontSize: 18)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SaisieNumeroProPage())),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SaisieNumeroProPage extends ConsumerStatefulWidget {
  const SaisieNumeroProPage({super.key});
  @override
  ConsumerState<SaisieNumeroProPage> createState() => _SaisieNumeroProPageState();
}

class _SaisieNumeroProPageState extends ConsumerState<SaisieNumeroProPage> {
  String _numero = '';
  bool _occupe = false;

  Future<void> _validerNumero() async {
    if (_numero.length != 10) return;
    setState(() => _occupe = true);
    try {
      final auth = ref.read(authProvider);
      await auth.connecterLocalement(_numero);
      
      if (!mounted) return;

      if (!await auth.pinDefini(_numero)) {
        if (!mounted) return;
        await Navigator.push(context, MaterialPageRoute(builder: (_) => PinPage(creation: true, numero: _numero)));
      } else {
        bool deverrouille = false;
        if (!mounted) return;
        await Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (_) => PinPage(
              creation: false,
              numero: _numero,
              onDeverrouille: () { deverrouille = true; Navigator.pop(context); },
            ),
          ),
        );
        if (!deverrouille) { setState(() => _occupe = false); return; }
      }

      if (mounted) {
        bool isAdmin = await auth.estAdmin();
        if (!mounted) return;
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(
            // ICI : Pas de const devant les pages
            builder: (_) => isAdmin ? AdminShell() : PrestataireShell(),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion Prestataire')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Entrez votre numéro professionnel', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🇧🇯 +229', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Text(_numero.isEmpty ? '01 XX XX XX XX' : _numero, style: const TextStyle(fontSize: 28, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Clavier(
                    onChiffre: (c) => setState(() { if (_numero.length < 10) _numero += c; }),
                    onEffacer: () => setState(() { if (_numero.isNotEmpty) _numero = _numero.substring(0, _numero.length - 1); }),
                  ),
                ),
                SizedBox(width: double.infinity, child: FilledButton(onPressed: _occupe ? null : _validerNumero, child: const Text('Continuer'))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PinPage extends ConsumerStatefulWidget {
  final bool creation;
  final String numero; 
  final VoidCallback? onDeverrouille;
  
  const PinPage({super.key, required this.creation, required this.numero, this.onDeverrouille});
  
  @override
  ConsumerState<PinPage> createState() => _PinPageState();
}

class _PinPageState extends ConsumerState<PinPage> {
  String _saisie = '';
  String? _premier;

  void _chiffre(String c) {
    if (_saisie.length >= 4) return;
    setState(() => _saisie += c);
    if (_saisie.length == 4) _valider();
  }

  Future<void> _valider() async {
    final auth = ref.read(authProvider);
    if (!widget.creation) {
      if (await auth.verifierPin(widget.numero, _saisie)) {
        widget.onDeverrouille?.call();
      } else {
        setState(() { _saisie = ''; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code PIN incorrect.')));
      }
      return;
    }
    if (_premier == null) {
      setState(() { _premier = _saisie; _saisie = ''; });
    } else {
      if (_premier == _saisie) { 
        await auth.definirPin(widget.numero, _saisie); 
        if (mounted) Navigator.pop(context); 
      } else {
        setState(() { _premier = null; _saisie = ''; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Les codes ne correspondent pas.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.creation ? 'Créer un code PIN' : 'Déverrouiller'),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 16), child: LogoDassa(taille: 30))
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.creation ? 'Créez un code PIN à 4 chiffres' : 'Entrez votre code PIN',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 4; i++)
                    Container(
                      margin: const EdgeInsets.all(8), 
                      width: 24, height: 24, 
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, 
                        color: i < _saisie.length ? vertDassa : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Clavier(
                  onChiffre: _chiffre, 
                  onEffacer: () => setState(() { if (_saisie.isNotEmpty) _saisie = _saisie.substring(0, _saisie.length - 1); }),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
