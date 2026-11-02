import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/depot.dart';
import 'services/auth.dart';
import 'services/reseau.dart';
import 'services/voix.dart';
import 'sync/synchro.dart';

final depotProvider = Provider<Depot>((ref) => throw UnimplementedError('Base non initialisée'));

final syncProvider = Provider<SyncService>(
  (ref) => SyncService(ref.watch(depotProvider), Supabase.instance.client),
);

final connectivityProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService(ref.watch(syncProvider))..demarrer();
  ref.onDispose(service.arreter);
  return service;
});

final authProvider = Provider<AuthService>((ref) => AuthService(ref.watch(depotProvider)));

final voixProvider = Provider<VoiceService>((ref) {
  final voix = VoiceService();
  ref.onDispose(voix.liberer);
  return voix;
});

// --- NOUVEAU : DÉTECTEUR DE CONNEXION RÉELLE ---
final isOnlineProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    // Si la liste contient 'none', on est hors ligne.
    return !results.contains(ConnectivityResult.none);
  });
});

// --- FONCTION POUR TRADUIRE LE NOM DE L'ICÔNE ---
IconData getIconFromString(String iconName) {
  switch (iconName) {
    case 'handyman': return Icons.handyman;
    case 'engineering': return Icons.engineering;
    case 'hotel': return Icons.hotel;
    case 'restaurant': return Icons.restaurant;
    case 'plumbing': return Icons.plumbing;
    case 'electric': return Icons.electric_bolt;
    case 'cleaning': return Icons.cleaning_services;
    case 'car': return Icons.car_repair;
    case 'medical': return Icons.medical_services;
    case 'computer': return Icons.computer;
    case 'cut': return Icons.cut;
    case 'brush': return Icons.brush;
    case 'agriculture': return Icons.agriculture;
    case 'school': return Icons.school;
    default: return Icons.category;
  }
}

// --- GESTION DES CATÉGORIES ---
class CategoriesNotifier extends StateNotifier<Map<String, String>> {
  final Depot _depot;
  CategoriesNotifier(this._depot) : super({}) { _charger(); }

  Future<void> _charger() async {
    final jsonStr = await _depot.lireEtat('categories_map');
    if (jsonStr != null) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      state = map.map((key, value) => MapEntry(key, value as String));
    } else {
      state = {
        'Menuisier': 'handyman',
        'Soudeur': 'engineering',
        'Hôtel': 'hotel',
        'Restauration': 'restaurant',
        'Plomberie': 'plumbing',
        'Électricité': 'electric',
      };
      await _sauvegarder();
    }
  }

  Future<void> ajouter(String nom, String iconName) async {
    if (nom.isNotEmpty && !state.containsKey(nom)) {
      state = {...state, nom: iconName};
      await _sauvegarder();
    }
  }

  Future<void> supprimer(String nom) async {
    final newState = Map<String, String>.from(state)..remove(nom);
    state = newState;
    await _sauvegarder();
  }

  Future<void> _sauvegarder() async {
    await _depot.ecrireEtat('categories_map', jsonEncode(state));
  }
}

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, Map<String, String>>((ref) {
  return CategoriesNotifier(ref.watch(depotProvider));
});

// Providers fantômes
final catalogueProvider = StreamProvider<List<dynamic>>((ref) => Stream.value([]));
final enLigneProvider = StreamProvider<bool>((ref) => Stream.value(true));
final commandesClientProvider = StreamProvider<List<dynamic>>((ref) => Stream.value([]));
final tousPrestatairesProvider = StreamProvider<List<dynamic>>((ref) => Stream.value([]));
