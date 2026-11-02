import 'package:flutter/material.dart';

const Color vertDassa = Color(0xFF00704A);
const Color vertBenin = Color(0xFF008751);
const Color orangeDassa = Color(0xFFF27C22);
const Color orangeVocal = Color(0xFFF27C22);
const Color jauneAccent = Color(0xFFFFD700);
const Color noir = Color(0xFF111111);
const Color grisFond = Color(0xFFF5F5F5);

/// Thème lisible : texte large, boutons de 60 px de haut.
ThemeData themeDassa() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: vertDassa, primary: vertDassa, secondary: orangeDassa),
    useMaterial3: true,
  );
  return base.copyWith(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
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
