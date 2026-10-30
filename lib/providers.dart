import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'data/base.dart';
import 'data/depot.dart';
import 'services/auth.dart';
import 'services/reseau.dart';
import 'services/voix.dart';
import 'sync/synchro.dart';
import 'utils.dart';

/// Initialisée dans main.dart avec overrideWithValue.
final depotProvider = Provider<Depot>((ref) => throw UnimplementedError('Base non initialisée'));

final syncProvider = Provider<SyncService>(
  (ref) => SyncService(ref.watch(depotProvider), Supabase.instance.client),
);

final connectivityProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService(ref.watch(syncProvider))..demarrer();
  ref.onDispose(service.arreter);
  return service;
});

final voixProvider = Provider<VoiceService>((ref) {
  final voix = VoiceService();
  ref.onDispose(voix.liberer);
  return voix;
});

final authProvider = Provider<AuthService>(
  (ref) => AuthService(Supabase.instance.client, ref.watch(depotProvider)),
);

final sessionProvider = StreamProvider<AuthState>(
  (ref) => Supabase.instance.client.auth.onAuthStateChange,
);

bool estEnLigne(List<ConnectivityResult> resultats) => !resultats.contains(ConnectivityResult.none);

final enLigneProvider = StreamProvider<bool>((ref) async* {
  yield estEnLigne(await Connectivity().checkConnectivity());
  yield* Connectivity().onConnectivityChanged.map(estEnLigne);
});

final catalogueProvider = StreamProvider<List<PrestataireLocal>>(
  (ref) => ref.watch(depotProvider).surveillerCatalogue(),
);

final tousPrestatairesProvider = StreamProvider<List<PrestataireLocal>>(
  (ref) => ref.watch(depotProvider).surveillerTous(),
);

final attenteValidationProvider = StreamProvider<List<PrestataireLocal>>(
  (ref) => ref.watch(depotProvider).surveillerEnAttente(),
);

final commandesClientProvider = StreamProvider<List<CommandeLocale>>(
  (ref) => ref.watch(depotProvider).surveillerCommandesClient(),
);

final commandesPrestataireProvider = StreamProvider.family<List<CommandeLocale>, String>(
  (ref, uid) => ref.watch(depotProvider).surveillerCommandesPrestataire(uid),
);

final nombreActivesProvider = StreamProvider<int>((ref) => ref.watch(depotProvider).nombreActives());

final nombreErreursProvider = StreamProvider<int>((ref) => ref.watch(depotProvider).nombreEnErreur());

/// Fiche du prestataire connecté, retrouvée par son numéro de téléphone.
final monPrestataireProvider = Provider<PrestataireLocal?>((ref) {
  ref.watch(sessionProvider);
  final telephone = chiffresSeulement(Supabase.instance.client.auth.currentUser?.phone ?? '');
  if (telephone.isEmpty) return null;
  final liste = ref.watch(tousPrestatairesProvider).valueOrNull ?? const <PrestataireLocal>[];
  for (final p in liste) {
    if (chiffresSeulement(p.telephone) == telephone) return p;
  }
  return null;
});

/// Vrai si le numéro connecté est celui de l’administrateur.
final estAdminProvider = Provider<bool>((ref) {
  ref.watch(sessionProvider);
  final telephone = chiffresSeulement(Supabase.instance.client.auth.currentUser?.phone ?? '');
  return telephone.isNotEmpty && telephone == chiffresSeulement(adminPhone);
});
