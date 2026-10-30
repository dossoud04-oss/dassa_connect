// lib/services/auth.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../config.dart'; // <-- Import ajouté pour adminPhone
import '../data/depot.dart';
import '../utils.dart';

class AuthService {
  AuthService(this._client, this._depot);

  final SupabaseClient _client;
  final Depot _depot;

  static const int maxTentatives = 5;
  static const int tempsBlocageMinutes = 1;

  /// Enregistre le numéro et définit si c'est un admin.
  Future<void> connecterLocalement(String numero) async {
    final numeroComplet = '+229$numero';
    await _depot.ecrireEtat('telephone', numeroComplet);
    
    // Vérification de l'admin
    final estAdmin = (numeroComplet == adminPhone);
    await _depot.ecrireEtat('est_admin', estAdmin ? 'true' : 'false');
  }

  /// Récupère le numéro de téléphone stocké localement.
  Future<String?> lireTelephone() async {
    return await _depot.lireEtat('telephone');
  }

  /// Vérifie si l'utilisateur actuel est administrateur.
  Future<bool> estAdmin() async {
    return (await _depot.lireEtat('est_admin')) == 'true';
  }

  /// Vérifie si un code PIN a déjà été créé.
  Future<bool> pinDefini() async => (await _depot.lireEtat('pin_hash')) != null;

  /// Crée le code PIN localement.
  Future<void> definirPin(String pin) async {
    final sel = const Uuid().v4();
    await _depot.ecrireEtat('pin_sel', sel);
    await _depot.ecrireEtat('pin_hash', hashPin(pin, sel));
    
    await _depot.supprimerEtat('pin_tentatives');
    await _depot.supprimerEtat('pin_bloque_jusqua');
  }

  /// Vérifie le PIN avec blocage après 5 échecs.
  Future<bool> verifierPin(String pin) async {
    final bloqueJusquaStr = await _depot.lireEtat('pin_bloque_jusqua');
    if (bloqueJusquaStr != null) {
      final bloqueJusqua = DateTime.tryParse(bloqueJusquaStr);
      if (bloqueJusqua != null && DateTime.now().isBefore(bloqueJusqua)) {
        return false; 
      } else {
        await _depot.supprimerEtat('pin_bloque_jusqua');
        await _depot.supprimerEtat('pin_tentatives');
      }
    }

    final sel = await _depot.lireEtat('pin_sel');
    final attendu = await _depot.lireEtat('pin_hash');
    if (sel == null || attendu == null) return false;

    final calcule = hashPin(pin, sel);

    if (calcule == attendu) {
      await _depot.supprimerEtat('pin_tentatives');
      return true;
    } else {
      final tentativesStr = await _depot.lireEtat('pin_tentatives') ?? '0';
      int tentatives = (int.tryParse(tentativesStr) ?? 0) + 1;

      if (tentatives >= maxTentatives) {
        final finBlocage = DateTime.now().add(const Duration(minutes: tempsBlocageMinutes));
        await _depot.ecrireEtat('pin_bloque_jusqua', finBlocage.toIso8601String());
        await _depot.supprimerEtat('pin_tentatives');
      } else {
        await _depot.ecrireEtat('pin_tentatives', tentatives.toString());
      }
      return false;
    }
  }

  /// Déconnexion locale : supprime les infos de l'utilisateur.
  Future<bool> deconnecter() async {
    if ((await _depot.lireActives()).isNotEmpty) return false;
    
    await _depot.supprimerEtat('telephone');
    await _depot.supprimerEtat('est_admin');
    await _depot.supprimerEtat('pin_hash');
    await _depot.supprimerEtat('pin_sel');
    await _depot.supprimerEtat('pin_tentatives');
    await _depot.supprimerEtat('pin_bloque_jusqua');
    
    return true;
  }
}
