# Corrections apportées (compilation)

## Erreurs bloquantes corrigées
- `lib/ui/widgets.dart` : le fichier avait perdu son début (plus de `LogoDassa`, `bandeau`, `BulleVocale`, `MicroVocal`, `CartePrestataire`, `Clavier`…). Version complète restaurée.
- `lib/ui/espace.dart`, `prestataires.dart`, `fiche.dart` : versions simplifiées (sans `EspaceSections`, sans paramètres `uid`, `categorie`, `recherche`) remplacées par les versions complètes attendues par `accueil.dart`, `profil.dart`, `shell.dart`.
- `lib/providers.dart` : les « providers fictifs » (`List<dynamic>`) provoquaient des erreurs de type ; remplacés par de vrais providers branchés sur la base locale. `sessionProvider`, `monPrestataireProvider` et `estAdminProvider` ajoutés (session locale par numéro de téléphone).
- `lib/services/auth.dart` : `deconnecter()` renvoie maintenant un `bool` (comme l'attend `profil.dart`) et refuse de déconnecter tant que des données ne sont pas synchronisées.
- `lib/ui/shell.dart` : `Racine`, `PorteEntree` et `Shell` réécrits et cohérents (choix Client / Pro → PIN → application).
- `lib/ui/connexion.dart` : écran de choix, saisie du numéro et PIN reliés entre eux (plus de navigation qui se perd).
- `lib/theme.dart` : constantes manquantes (`jauneAccent`, etc.) rétablies, tout en gardant vos couleurs.
- `pubspec.yaml` : la section `flutter:` (Material Icons + `assets/logo.png`) avait disparu.
- `lib/data/connexion.dart` : le worker Drift pointait vers `drift_worker.dart.js` alors que le fichier du projet s'appelle `drift_worker.js`.
- `lib/main.dart` : `publishableKey` remplacé par `anonKey` (paramètre de `Supabase.initialize`) ; l'application ne plante plus si la clé Supabase est absente.
- `android/app/src/main/AndroidManifest.xml` : permissions `INTERNET` et `RECORD_AUDIO` ajoutées (sans elles, la synchro et le micro ne marchent pas dans l'APK), plus les `<queries>` pour l'appel et WhatsApp.

## Améliorations
- Mode local si pas de clé Supabase (la synchronisation est simplement désactivée).
- Numéros à 8 ou 10 chiffres (nouveau format béninois) ; comparaison des numéros par leurs 8 derniers chiffres.
- Message « Trop d'essais » avec compte à rebours après 5 PIN faux.
- Le PIN et le numéro ne sont enregistrés qu'une fois la connexion réussie.
- Animation du micro active seulement pendant l'enregistrement.
- Workflow GitHub : clés passées par secrets (facultatif).
- Nouveau test pour `memeNumero`.

## À vérifier chez vous
Je n'ai pas pu lancer Flutter dans mon environnement : relisez les messages de `flutter analyze` si quelque chose apparaît.
