import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme.dart';
import 'widgets.dart';
import 'client_shell.dart';
import 'prestataire_shell.dart';
import 'admin_compte.dart';
import 'telecharger_app.dart';
import 'formulaire_prestataire.dart';

class ConnexionPage extends ConsumerWidget {
  const ConnexionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: grisFond,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LogoDassa(taille: 56),
                const SizedBox(height: 12),
                const Text(
                  'Le bon prestataire, près de toi',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: grisTexte, fontSize: 15),
                ),
                const SizedBox(height: 40),
                // Bouton Client (style Presta)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: vertDassa,
                    side: const BorderSide(color: vertDassa, width: 1.8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.person_search_rounded),
                  label: const Text('Je suis un Client', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ClientShell())),
                ),
                const SizedBox(height: 14),
                // Bouton Prestataire
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vertDassa,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.handyman_rounded),
                  label: const Text('Je suis Prestataire', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SaisieNumeroProPage())),
                ),
                const SizedBox(height: 28),
                const BoutonTelechargerApp(),
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
      // Pull serveur avant de décider : l’admin voit les nouvelles demandes, et un prestataire
      // retrouve sa fiche sur un nouveau téléphone (sinon un doublon serait créé).
      await ref.read(syncProvider).synchroniser(manuelle: true);

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
        if (isAdmin) {
          // 2e facteur : code secret admin (alphanumérique)
          final auth2 = ref.read(authProvider);
          if (!await auth2.codeAdminDefini(_numero)) {
            if (!mounted) return;
            final cree = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => CodeAdminPage(creation: true, numero: _numero)),
            );
            if (cree != true) { setState(() => _occupe = false); return; }
          } else {
            if (!mounted) return;
            final ok = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => CodeAdminPage(creation: false, numero: _numero)),
            );
            if (ok != true) { setState(() => _occupe = false); return; }
          }
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminComptePage()),
          );
        } else {
          // Prestataire : vérifier si la fiche est remplie
          final depot = ref.read(depotProvider);
          final fiche = await depot.prestataireParNumero('+229$_numero');
          // aussi essayer le format stocké
          final fiche2 = fiche ?? await depot.prestataireParNumero(_numero);
          if (!mounted) return;
          if (fiche2 == null || fiche2.nom.isEmpty || fiche2.categorie.isEmpty) {
            // Première connexion → formulaire obligatoire
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => FormulairePrestatairePage(telephone: '+229$_numero'),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PrestataireShell()),
            );
          }
        }
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
                const Text('Entrez votre numéro professionnel', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🇧🇯 +229', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Text(_numero.isEmpty ? '01 XX XX XX XX' : _numero, style: const TextStyle(fontSize: 26, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Clavier(
                    onChiffre: (c) => setState(() { if (_numero.length < 10) _numero += c; }),
                    onEffacer: () => setState(() { if (_numero.isNotEmpty) _numero = _numero.substring(0, _numero.length - 1); }),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _occupe ? null : _validerNumero,
                    child: const Text('Continuer'),
                  ),
                ),
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
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code PIN incorrect.')));
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
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Les codes ne correspondent pas.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.creation ? 'Créer un code PIN' : 'Déverrouiller'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 16), child: LogoDassa(taille: 30))
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
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
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
                        color: i < _saisie.length ? vertDassa : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Clavier(
                  onChiffre: _chiffre,
                  onEffacer: () => setState(() { if (_saisie.isNotEmpty) _saisie = _saisie.substring(0, _saisie.length - 1); }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// 2e code admin : saisie clavier (lettres + chiffres), min 6 caractères
class CodeAdminPage extends ConsumerStatefulWidget {
  final bool creation;
  final String numero;
  const CodeAdminPage({super.key, required this.creation, required this.numero});

  @override
  ConsumerState<CodeAdminPage> createState() => _CodeAdminPageState();
}

class _CodeAdminPageState extends ConsumerState<CodeAdminPage> {
  final _ctrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _occupe = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    final code = _ctrl.text.trim();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minimum 6 caractères')));
      return;
    }
    setState(() => _occupe = true);
    final auth = ref.read(authProvider);
    try {
      if (widget.creation) {
        if (code != _confirmCtrl.text.trim()) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Les codes ne correspondent pas')));
          return;
        }
        await auth.definirCodeAdmin(widget.numero, code);
        if (mounted) Navigator.pop(context, true);
      } else {
        final ok = await auth.verifierCodeAdmin(widget.numero, code);
        if (ok) {
          if (mounted) Navigator.pop(context, true);
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code secret incorrect')));
        }
      }
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.creation ? 'Créer le code secret admin' : 'Code secret admin')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.security, size: 56, color: vertDassa),
            const SizedBox(height: 16),
            Text(
              widget.creation
                  ? 'Choisissez un code secret (lettres et chiffres, min. 6 caractères). Il s\'ajoute au PIN pour sécuriser l\'espace admin.'
                  : 'Entrez votre code secret administrateur',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _ctrl,
              obscureText: _obscure,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: 'Code secret',
                prefixIcon: const Icon(Icons.password),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            if (widget.creation) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _confirmCtrl,
                obscureText: _obscure,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le code',
                  prefixIcon: Icon(Icons.password),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _occupe ? null : _valider,
              style: ElevatedButton.styleFrom(
                backgroundColor: vertDassa,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(widget.creation ? 'Enregistrer' : 'Valider'),
            ),
          ],
        ),
      ),
    );
  }
}
