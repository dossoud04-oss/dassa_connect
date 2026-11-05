import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme.dart';
import 'admin_shell.dart';

/// Côté serveur, les règles RLS exigent un compte administrateur Supabase (ligne dans la table `admins`).
/// Une session anonyme ne peut donc pas valider une fiche. Ce compte sert à ouvrir cette session ;
/// le mot de passe n’est jamais stocké par l’application.
class AdminComptePage extends StatefulWidget {
  const AdminComptePage({super.key});

  @override
  State<AdminComptePage> createState() => _AdminComptePageState();
}

class _AdminComptePageState extends State<AdminComptePage> {
  final _email = TextEditingController();
  final _motDePasse = TextEditingController();
  bool _occupe = false;

  SupabaseClient? _client() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Session administrateur déjà ouverte et conservée : on entre directement.
    final utilisateur = _client()?.auth.currentUser;
    if (utilisateur != null && !utilisateur.isAnonymous) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _entrer());
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  void _message(String texte) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texte)));
  }

  void _entrer() {
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminShell()));
  }

  Future<void> _connecter() async {
    final client = _client();
    if (client == null) {
      _message('Supabase indisponible : vérifiez la connexion internet.');
      return;
    }
    setState(() => _occupe = true);
    try {
      await client.auth.signInWithPassword(email: _email.text.trim(), password: _motDePasse.text);
      _entrer();
    } on AuthException catch (e) {
      _message('Connexion refusée : ${e.message}');
    } catch (e) {
      _message('Connexion impossible : $e');
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compte administrateur')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.admin_panel_settings, size: 56, color: vertDassa),
              const SizedBox(height: 12),
              const Text(
                'Connectez-vous avec le compte administrateur Supabase pour valider les prestataires sur le serveur.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.mail_outline)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _motDePasse,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mot de passe', prefixIcon: Icon(Icons.lock_outline)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _occupe ? null : _connecter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: vertDassa,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _occupe
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Se connecter'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _entrer,
                child: const Text('Continuer sans session serveur (validations non envoyées)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
