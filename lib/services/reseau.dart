import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../sync/synchro.dart';

/// Dès que le réseau revient, une synchronisation automatique est tentée.
/// Elle respecte l’intervalle minimal de 15 minutes.
class ConnectivityService {
  ConnectivityService(this._sync);

  final SyncService _sync;
  StreamSubscription<List<ConnectivityResult>>? _abonnement;

  void demarrer() {
    _abonnement = Connectivity().onConnectivityChanged.listen((resultats) {
      if (!resultats.contains(ConnectivityResult.none)) {
        _sync.synchroniser();
      }
    });
  }

  void arreter() => _abonnement?.cancel();
}
