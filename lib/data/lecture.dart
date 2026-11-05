import 'dart:convert';

import 'base.dart';

/// Lecture des colonnes JSON stockées en texte dans la base locale.
/// Un JSON invalide ne fait jamais planter un écran : on renvoie une liste vide.
extension FichePrestataire on PrestataireLocal {
  List<String> get photosList =>
      _lireListe(photos).map((e) => e.toString()).where((e) => e.isNotEmpty).toList();

  List<Map<String, dynamic>> get tarifsList => _lireListe(tarifs)
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

List<dynamic> _lireListe(String json) {
  try {
    final valeur = jsonDecode(json);
    return valeur is List ? valeur : const [];
  } catch (_) {
    return const [];
  }
}
