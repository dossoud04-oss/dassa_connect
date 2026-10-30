import 'package:flutter/material.dart';

const Color vertBenin = Color(0xFF006A4E);
const Color orangeVocal = Color(0xFFFF6B00);
const Color jauneAccent = Color(0xFFFFD700);
const Color noir = Color(0xFF111111);

/// Thème lisible : texte large, boutons de 60 px de haut.
ThemeData themeDassa() {
  final base = ThemeData(colorSchemeSeed: vertBenin, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: Colors.white,
    textTheme: base.textTheme.apply(bodyColor: noir).copyWith(
          bodyLarge: const TextStyle(fontSize: 18),
          bodyMedium: const TextStyle(fontSize: 16),
        ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(60), textStyle: const TextStyle(fontSize: 18)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(60), textStyle: const TextStyle(fontSize: 18)),
    ),
  );
}
