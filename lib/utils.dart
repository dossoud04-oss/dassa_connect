import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Durée en secondes → « 0:18 ».
String formatDuree(int secondes) {
  final minutes = secondes ~/ 60;
  final reste = secondes % 60;
  return '$minutes:${reste.toString().padLeft(2, '0')}';
}

/// Montant → « 25 000 FCFA ».
String formatFcfa(int montant) {
  final texte = montant.toString();
  final sortie = StringBuffer();
  for (var i = 0; i < texte.length; i++) {
    if (i > 0 && (texte.length - i) % 3 == 0) sortie.write(' ');
    sortie.write(texte[i]);
  }
  return '$sortie FCFA';
}

/// Nom → initiales, par exemple « KM » pour Koffi Mensah.
String initiales(String nom) {
  final mots = nom.trim().split(RegExp(r'\s+')).where((m) => m.isNotEmpty).toList();
  if (mots.isEmpty) return '?';
  if (mots.length == 1) return mots.first[0].toUpperCase();
  return (mots.first[0] + mots.last[0]).toUpperCase();
}

/// Ne garde que les chiffres : « +229 97 00 00 00 » → « 22997000000 ».
String chiffresSeulement(String texte) => texte.replaceAll(RegExp(r'[^0-9]'), '');

/// Texte relatif pour les commandes : « il y a 5 min ».
String tempsEcoule(DateTime date) {
  final ecart = DateTime.now().difference(date);
  if (ecart.inMinutes < 1) return 'à l’instant';
  if (ecart.inMinutes < 60) return 'il y a ${ecart.inMinutes} min';
  if (ecart.inHours < 24) return 'il y a ${ecart.inHours} h';
  return 'il y a ${ecart.inDays} j';
}

/// Empreinte du code PIN, salée. Le code n’est jamais stocké en clair.
String hashPin(String pin, String sel) => sha256.convert(utf8.encode('$sel:$pin')).toString();
