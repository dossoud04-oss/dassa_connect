import 'package:uuid/uuid.dart';
import '../config.dart';
import '../data/depot.dart';
import '../utils.dart';

class AuthService {
  AuthService(this._depot);
  final Depot _depot;
  static const int maxTentatives = 5;
  static const int tempsBlocageMinutes = 1;

  Future<void> connecterLocalement(String numero) async {
    final chiffres = numero.replaceAll(RegExp(r'[^0-9]'), '');
    final numeroComplet = chiffres.startsWith('229') ? '+$chiffres' : '+229$chiffres';
    await _depot.ecrireEtat('telephone', numeroComplet);
    final estAdmin = memeNumero(numeroComplet, adminPhone);
    await _depot.ecrireEtat('est_admin', estAdmin ? 'true' : 'false');
  }

  Future<bool> estAdmin() async => (await _depot.lireEtat('est_admin')) == 'true';

  Future<bool> pinDefini(String numero) async => (await _depot.lireEtat('pin_hash_$numero')) != null;

  Future<void> definirPin(String numero, String pin) async {
    final sel = const Uuid().v4();
    await _depot.ecrireEtat('pin_sel_$numero', sel);
    await _depot.ecrireEtat('pin_hash_$numero', hashPin(pin, sel));
    await _depot.supprimerEtat('pin_tentatives_$numero');
    await _depot.supprimerEtat('pin_bloque_jusqua_$numero');
  }

  Future<bool> verifierPin(String numero, String pin) async {
    final bloqueJusquaStr = await _depot.lireEtat('pin_bloque_jusqua_$numero');
    if (bloqueJusquaStr != null) {
      final bloqueJusqua = DateTime.tryParse(bloqueJusquaStr);
      if (bloqueJusqua != null && DateTime.now().isBefore(bloqueJusqua)) return false;
      await _depot.supprimerEtat('pin_bloque_jusqua_$numero');
      await _depot.supprimerEtat('pin_tentatives_$numero');
    }

    final sel = await _depot.lireEtat('pin_sel_$numero');
    final attendu = await _depot.lireEtat('pin_hash_$numero');
    if (sel == null || attendu == null) return false;

    if (hashPin(pin, sel) == attendu) {
      await _depot.supprimerEtat('pin_tentatives_$numero');
      return true;
    } else {
      final tentativesStr = await _depot.lireEtat('pin_tentatives_$numero') ?? '0';
      int tentatives = (int.tryParse(tentativesStr) ?? 0) + 1;
      if (tentatives >= maxTentatives) {
        final finBlocage = DateTime.now().add(const Duration(minutes: tempsBlocageMinutes));
        await _depot.ecrireEtat('pin_bloque_jusqua_$numero', finBlocage.toIso8601String());
        await _depot.supprimerEtat('pin_tentatives_$numero');
      } else {
        await _depot.ecrireEtat('pin_tentatives_$numero', tentatives.toString());
      }
      return false;
    }
  }

  Future<void> deconnecter() async {
    await _depot.supprimerEtat('telephone');
    await _depot.supprimerEtat('est_admin');
  }

  // ---------- 2e code admin (alphanumérique, saisie clavier) ----------

  Future<bool> codeAdminDefini(String numero) async =>
      (await _depot.lireEtat('admin_code_hash_$numero')) != null;

  Future<void> definirCodeAdmin(String numero, String code) async {
    final sel = const Uuid().v4();
    await _depot.ecrireEtat('admin_code_sel_$numero', sel);
    await _depot.ecrireEtat('admin_code_hash_$numero', hashPin(code, sel));
  }

  Future<bool> verifierCodeAdmin(String numero, String code) async {
    final sel = await _depot.lireEtat('admin_code_sel_$numero');
    final attendu = await _depot.lireEtat('admin_code_hash_$numero');
    if (sel == null || attendu == null) return false;
    return hashPin(code, sel) == attendu;
  }
}
