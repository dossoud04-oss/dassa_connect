import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../sync/synchro.dart';

/// Synchronisation en arrière-plan tant que l'application est ouverte :
/// - au démarrage ;
/// - dès que le réseau revient ;
/// - toutes les 30 secondes, pour envoyer vite ce qui attend dans la file (commande, prix, photo) ;
/// - toutes les 15 minutes, pour recevoir les nouveautés.
class ConnectivityService {
  ConnectivityService(this._sync);

  final SyncService _sync;
  StreamSubscription<List<ConnectivityResult>>? _abonnement;
  Timer? _envoiRapide;
  Timer? _reception;

  void demarrer() {
    _sync.synchroniser(manuelle: true);

    _abonnement = Connectivity().onConnectivityChanged.listen((resultats) {
      if (!resultats.contains(ConnectivityResult.none)) {
        _sync.synchroniser(manuelle: true);
      }
    });

    _envoiRapide = Timer.periodic(const Duration(seconds: 30), (_) => _sync.envoyerSiEnAttente());
    _reception = Timer.periodic(const Duration(minutes: 15), (_) => _sync.synchroniser());
  }

  void arreter() {
    _abonnement?.cancel();
    _envoiRapide?.cancel();
    _reception?.cancel();
  }
}
