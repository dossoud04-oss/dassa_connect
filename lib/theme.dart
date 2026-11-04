import 'package:flutter/material.dart';

// Palette pro Dassa Connect (vert + orange) alignée sur les maquettes
const Color vertDassa = Color(0xFF1B7A4E);      // Vert principal
const Color vertBenin = Color(0xFF008751);
const Color orangeDassa = Color(0xFFE87516);    // Orange vocal / offline
const Color orangeVocal = Color(0xFFE87516);
const Color jauneAccent = Color(0xFFFFC857);
const Color noir = Color(0xFF1A1A1A);
const Color noirTexte = Color(0xFF1A1A1A);
const Color grisTexte = Color(0xFF6B7280);
const Color grisFond = Color(0xFFF5F7F6);
const Color bleuDassa = Color(0xFF1B7A4E);
const Color surfaceDassa = Color(0xFFFFFFFF);
const Color purpleLight = Color(0xFFE8F5E9);    // Vert très clair (compat)
const Color purpleDark = Color(0xFF145C3A);
const Color vertClair = Color(0xFFE8F5E9);
const Color vertHeader = Color(0xFF2E9B6A);

ThemeData themeDassa() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: vertDassa,
      primary: vertDassa,
      secondary: orangeDassa,
      surface: surfaceDassa,
      error: const Color(0xFFEF4444),
    ),
    useMaterial3: true,
  );

  return base.copyWith(
    scaffoldBackgroundColor: grisFond,
    primaryColor: vertDassa,
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceDassa,
      foregroundColor: vertDassa,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: vertDassa,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: vertDassa),
    ),
    textTheme: base.textTheme.apply(bodyColor: noir, displayColor: vertDassa).copyWith(
          headlineLarge: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: vertDassa, height: 1.15),
          headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: vertDassa),
          titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: vertDassa),
          titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: vertDassa),
          bodyLarge: const TextStyle(fontSize: 16, color: noir, height: 1.35),
          bodyMedium: const TextStyle(fontSize: 14, color: noir, height: 1.35),
        ),
    cardTheme: CardThemeData(
      color: surfaceDassa,
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: vertDassa, width: 1.6),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceDassa,
      selectedItemColor: vertDassa,
      unselectedItemColor: Color(0xFF9CA3AF),
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      type: BottomNavigationBarType.fixed,
      elevation: 12,
      showUnselectedLabels: true,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: orangeDassa,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: vertDassa,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: vertDassa,
        minimumSize: const Size.fromHeight(50),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: vertDassa,
      contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: DividerThemeData(color: Colors.grey.shade200, thickness: 1, space: 1),
  );
}
