/// Intervalle minimal entre deux synchronisations automatiques (exigence ENF-10).
/// La synchronisation demandée à la main par l’utilisateur ne respecte pas cet intervalle.
const Duration intervalleSyncAutomatique = Duration(minutes: 15);

/// Vrai si une synchronisation automatique peut partir maintenant.
bool peutSynchroniserApres(DateTime? derniereTentative, DateTime maintenant) {
  if (derniereTentative == null) return true;
  return maintenant.difference(derniereTentative) >= intervalleSyncAutomatique;
}
