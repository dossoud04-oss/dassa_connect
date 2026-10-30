# Dassa Connect — application fusionnée, hors ligne et vocale

Ce dossier fusionne les deux projets précédents en une seule application. Il reprend la base hors ligne et la synchronisation éprouvées dans DassaServices, et les écrans, la voix et la validation de Dassa Connect, aux couleurs des maquettes.

**Il n'a pas été compilé ni exécuté.** Il faut le compiler sur votre machine et corriger les erreurs éventuelles.

## Ce qui vient de chaque projet

| Besoin hors ligne | Source | Ce qui est fait |
| --- | --- | --- |
| Base locale fiable, web compris | DassaServices (Drift) | Une seule base locale, pour le téléphone et le navigateur |
| Synchronisation dans les deux sens | DassaServices | Curseurs par table, reprise après coupure, une tentative par opération |
| Opérations en échec isolées | DassaServices | Au-delà de 5 échecs, l'opération sort de la file active |
| Modification locale jamais écrasée | DassaServices | Le serveur ne remplace pas une ligne encore en attente |
| Synchronisation toutes les 15 minutes | DassaServices | Automatique au retour du réseau, manuelle à tout moment |
| Code PIN local | DassaServices (cahier) | Créé après la première connexion, demandé à l'ouverture |
| Commande vocale façon messagerie | Dassa Connect | Maintenir pour enregistrer, relâcher pour arrêter, écouter, envoyer |
| Validation admin hors ligne | Dassa Connect | Décision écrite localement, envoyée au retour du réseau |
| Tableau de bord prestataire | Dassa Connect | Statistiques, commandes entrantes, photo et prix en file |
| Connexion par code SMS | Dassa Connect | Deux étapes, comme la maquette |
| Logo et palette | Charte fournie | Logo officiel, vert Bénin et orange pour la voix |

## Ce qui suit les maquettes

| Maquette | Écran | Statut |
| --- | --- | --- |
| 1. Connexion par OTP | `ui/connexion.dart` | Fait : deux étapes, clavier géant, numéro +229 |
| 2. Accueil client | `ui/accueil.dart`, `ui/prestataires.dart` | Fait : recherche, micro orange, catégories, prestataires proches, badge « Hors ligne » |
| 3. Validation admin | `ui/espace.dart` | Fait : bandeau mode avion, bandeau de synchronisation, Valider et Refuser |
| 4. Tableau de bord prestataire | `ui/espace.dart` | Fait : trois statistiques, commandes vocales, ajouter photo, modifier prix, ma boutique |
| 5. Logo | `assets/logo.png` | Fait : logo officiel, fond nettoyé |
| 6. Fiche prestataire | `ui/fiche.dart` | Fait : photos, tarifs, Appeler, WhatsApp, commande vocale |

## Choix retenus et écarts

- **Quatre onglets pour tous les rôles** : Accueil, Prestataires, Messages, Profil. La maquette 4 en montre cinq pour le prestataire ; les espaces prestataire et administrateur sont dans l'onglet Profil.
- **Palette verte** : la maquette 6 est orange et propose des notes et des avis. Ni les notes ni les avis ne sont dans cette version : ils n'ont pas de données à afficher. La palette verte suit la charte du prompt. Passer à l'orange est un changement de thème dans `lib/theme.dart`.
- **Délai de réponse retiré** : la maquette affiche « Répond en 10 min » et « Vérifié ». Ces informations ne sont mesurées par aucun écran. Elles ne sont donc pas affichées.
- **Icônes des catégories** : les maquettes montrent des illustrations. J'ai utilisé des icônes Material, plus légères à charger hors ligne.
- **Client sans compte** : le client n'a pas de compte. Il ne voit donc pas l'évolution de ses commandes, qui restent « Envoyée » sur son téléphone.
- **Connexion par SMS** : payante et indispensable aux prestataires et à l'administrateur. Le code à 4 chiffres doit être réglé dans Supabase.

## Installation et compilation (Windows, invite CMD)

```bat
REM Aller dans le dossier du projet décompressé
cd C:\Users\georges\Desktop\dassa_connect_fusion
REM Créer les dossiers android et web absents : ne remplace pas lib\, pubspec.yaml ni assets\
flutter create --platforms=android,web --project-name dassa_connect .
REM Supprimer le test d'exemple de Flutter s'il a été créé
del test\widget_test.dart
REM Télécharger les dépendances
flutter pub get
REM Générer le code de la base locale (database.g.dart) : obligatoire avant toute compilation
dart run build_runner build
REM Analyser le code : viser « No issues found », les lignes info ne bloquent pas
flutter analyze
REM Lancer les tests unitaires
flutter test
REM Définir les valeurs pour cette fenêtre CMD (remplacer par les vôtres)
set SUPABASE_URL=https://votre-projet.supabase.co
set SUPABASE_ANON_KEY=votre-cle-publique
set ADMIN_PHONE=22997000000
REM Installer et lancer sur un téléphone Android branché en USB
flutter run --dart-define=SUPABASE_URL=%SUPABASE_URL% --dart-define=SUPABASE_ANON_KEY=%SUPABASE_ANON_KEY% --dart-define=ADMIN_PHONE=%ADMIN_PHONE%
REM Compiler un APK par architecture (un fichier par type de processeur, plus léger)
flutter build apk --release --split-per-abi --dart-define=SUPABASE_URL=%SUPABASE_URL% --dart-define=SUPABASE_ANON_KEY=%SUPABASE_ANON_KEY% --dart-define=ADMIN_PHONE=%ADMIN_PHONE%
```

Le fichier `app-arm64-v8a-release.apk` convient à la plupart des téléphones récents. Vérifiez l'architecture de votre modèle avant de publier.

### Permissions Android à ajouter

Dans `android\app\src\main\AndroidManifest.xml`, ajoutez ces deux lignes juste après la balise `<manifest ...>`, avant `<application>` :

```xml
<!-- Accès au réseau, y compris en version publiée (absent par défaut du manifeste principal) -->
<uses-permission android:name="android.permission.INTERNET" />
<!-- Enregistrement des commandes vocales -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

Sans la première, l'application publiée ne peut pas se synchroniser. Sans la seconde, le micro ne fonctionne pas.

## Configuration Supabase

1. **Base** : dans l'éditeur SQL, coller `supabase/schema.sql` et exécuter. Remplacer `22997000000` par votre numéro d'administrateur, en chiffres seulement. Ce numéro doit être identique à `ADMIN_PHONE`.
2. **Connexion par SMS** : dans les réglages d'authentification, activer le fournisseur téléphone et choisir un fournisseur SMS. Ce service est payant, et sa couverture au Bénin est à vérifier avant le lancement.
3. **Longueur du code** : régler le code OTP à 4 chiffres dans les mêmes réglages. Vérifier l'emplacement exact de ce réglage.
4. **Adresse du site** : renseigner l'adresse du site dans les URL d'authentification.

## Publication

1. Copier `build\app\outputs\flutter-apk\app-arm64-v8a-release.apk` sous le nom `dassa-connect.apk`.
2. Dans Supabase, ouvrir Storage, le bucket `apks`, puis téléverser le fichier.
3. Dans `site_telechargement\index.html`, remplacer `VOTRE-PROJET` par l'identifiant du projet, puis envoyer le fichier sur Hostinger avec FileZilla.

## Mode avion

| Fonction | Hors ligne |
| --- | --- |
| Catalogue, fiches, tarifs, recherche par nom ou catégorie | Oui, après une première synchronisation |
| Enregistrer, écouter et envoyer une commande vocale ou écrite | Oui, envoyée au retour du réseau |
| Recherche vocale | Oui, envoyée au retour du réseau |
| Valider ou refuser un prestataire (admin) | Oui, envoyé au retour du réseau |
| Modifier le prix, ajouter une photo, passer une commande « écoutée » ou « livrée » | Oui, envoyé au retour du réseau |
| Ouvrir l'application avec le code PIN | Oui, après une première connexion |
| Se connecter par code SMS | Non : il faut internet |
| Afficher les photos déjà vues | Oui, mises en cache après le premier affichage |
| Afficher les photos jamais vues | Non |
| Écouter une bulle distante | Non, seulement les enregistrements faits sur ce téléphone |

Scénario de démonstration pour la soutenance :

1. Lancer l'application avec internet, puis ouvrir l'onglet Prestataires : le catalogue doit s'afficher.
2. Activer le mode avion.
3. Ouvrir une fiche, appuyer sur « Commander vocalement », enregistrer, puis envoyer. Le message « sera envoyée dès WiFi » s'affiche.
4. Dans Profil, le compteur « En attente d'envoi » indique 1.
5. Désactiver le mode avion et appuyer sur « Synchroniser maintenant ». Le compteur doit revenir à 0 et la commande apparaître dans la table `commandes` de Supabase.

## Limites connues

- **Non compilé** : les versions des paquets et la génération du code peuvent demander des corrections au premier lancement.
- **Synchronisation** : la file s'arrête au premier échec réseau. Une opération refusée par le serveur est comptée en échec, mais ne bloque pas les autres.
- **Réseau** : le message « sera envoyée dès WiFi » reprend le prompt. La synchronisation part pourtant sur n'importe quelle connexion, Wi-Fi ou données mobiles.
- **Commandes sans compte** : n'importe quel client peut envoyer de nombreuses commandes. Une limite de débit côté Supabase est à prévoir.
- **Administration** : le contrôle est fait deux fois, dans l'application (`ADMIN_PHONE`) et sur le serveur (table `admins` et RLS). Les deux doivent contenir le même numéro.
- **Chiffre d'affaires** : il additionne le montant des commandes livrées, mais l'application ne permet pas encore de saisir ce montant.
- **Initiales des commandes** : elles reprennent les deux derniers chiffres du numéro du client, faute de nom.
- **Synthèse vocale** : elle utilise la voix française du téléphone, qui doit être installée.
- **Mode sombre et tailles d'écran** : non testés. Les maquettes ont été reprises en portrait sur téléphone.
# dassa_connect
