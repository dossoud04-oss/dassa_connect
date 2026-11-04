/// Intervalle minimal entre deux synchronisations automatiques.
const Duration intervalleMinimal = Duration(minutes: 15);

/// Vrai si une synchronisation automatique peut être lancée maintenant.
bool peutSynchroniserApres(DateTime? derniereTentative, DateTime maintenant) {
  if (derniereTentative == null) return true;
  return maintenant.difference(derniereTentative) >= intervalleMinimal;
}
