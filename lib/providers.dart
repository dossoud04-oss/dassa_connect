import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/base.dart';
import 'data/depot.dart';
import 'services/auth.dart';
import 'services/reseau.dart';
import 'services/voix.dart';
import 'sync/synchro.dart';

final depotProvider = Provider<Depot>((ref) => throw UnimplementedError('Base non initialisée'));

final syncProvider = Provider<SyncService>((ref) {
  // Si Supabase n'a pas pu démarrer (hors ligne au lancement), on reste en mode local.
  SupabaseClient? client;
  try {
    client = Supabase.instance.client;
  } catch (_) {
    client = null;
  }
  return SyncService(ref.watch(depotProvider), client);
});

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

final isOnlineProvider = StreamProvider<bool>((ref) async* {
  bool estConnecte(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    // Sur web / desktop, wifi/ethernet/mobile/vpn/other = en ligne
    return results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet ||
        r == ConnectivityResult.vpn ||
        r == ConnectivityResult.other);
  }

  // 1) État initial immédiat (évite le faux "Mode Avion" au démarrage)
  try {
    final initial = await Connectivity().checkConnectivity();
    yield estConnecte(initial);
  } catch (_) {
    yield true; // en cas d'erreur de plugin, on suppose en ligne
  }

  // 2) Puis écoute des changements
  await for (final results in Connectivity().onConnectivityChanged) {
    yield estConnecte(results);
  }
});

IconData getIconFromString(String iconName) {
  switch (iconName) {
    case 'handyman': return Icons.carpenter;
    case 'engineering': return Icons.precision_manufacturing;
    case 'hotel': return Icons.hotel;
    case 'restaurant': return Icons.restaurant;
    case 'plumbing': return Icons.plumbing;
    case 'electric': return Icons.electric_bolt;
    case 'cleaning': return Icons.cleaning_services;
    case 'car': return Icons.car_repair;
    case 'medical': return Icons.medical_services;
    case 'computer': return Icons.computer;
    case 'cut': return Icons.content_cut;
    case 'brush': return Icons.brush;
    case 'agriculture': return Icons.agriculture;
    case 'school': return Icons.school;
    default: return Icons.category;
  }
}

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

// Correction de la syntaxe du StateNotifierProvider
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, Map<String, String>>(
  (ref) => CategoriesNotifier(ref.watch(depotProvider)),
);

final catalogueProvider = StreamProvider<List<PrestataireLocal>>(
  (ref) => ref.watch(depotProvider).surveillerCatalogue(),
);
final enLigneProvider = StreamProvider<bool>((ref) => Stream.value(true));
final commandesClientProvider = StreamProvider<List<CommandeLocale>>(
  (ref) => ref.watch(depotProvider).surveillerCommandesClient(),
);
final tousPrestatairesProvider = StreamProvider<List<PrestataireLocal>>(
  (ref) => ref.watch(depotProvider).surveillerTous(),
);
