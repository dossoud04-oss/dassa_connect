# Dassa Connect — corrections (v2, tout en une passe)

## 1. Pourquoi le client ne voyait pas le prestataire validé (v1)

| # | Couche | Cause | Correctif |
|---|--------|-------|-----------|
| 1 | Écran client | Cartes codées en dur, base jamais lue | Liste branchée sur les fiches validées (`catalogueProvider`), recherche sur les vraies données |
| 2 | Synchro (réception) | `order('updated_at')` sur une table sans cette colonne : chaque synchro échouait | Colonne et trigger `updated_at` (migration) |
| 3 | Synchro (envoi) | Colonnes envoyées absentes de la table réelle (`id`, `quartier`, `photos`, `statut`…) | Payloads avec les noms réels (`uid`, `cree_le`…) |
| 4 | Supabase (RLS) | Aucune politique d’inscription pour un prestataire | Politique `auth.uid() = user_id`, `user_id` renseigné par l’app |
| 5 | Validation admin | Session anonyme : `is_admin()` faux, RLS refusait la mise à jour | Écran `AdminComptePage` (compte admin Supabase, mot de passe non stocké) |
| 6 | Validation admin | Mise à jour refusée (0 ligne) comptée comme réussie | `RefusServeur` : l’opération reste en file, en échec |
| 7 | Validations | Pas de `updated_at` modifié : les clients ne recevaient rien | Trigger `touch_updated_at` |
| 8 | Synchro | Suppressions jamais envoyées | Action `delete` gérée |
| 9 | Sécurité | Un prestataire pouvait changer son propre statut | Trigger `proteger_statut` |
| 10 | Photos | Chemins locaux jamais envoyés au Storage | Buckets créés, upload via la file (`add_photo`) |
| 11 | Commande | « Commande envoyée » affiché sans rien enregistrer | `creerCommande` branché et envoyé |
| 12 | Doublons | Nouvelle installation : fiche recréée au lieu de retrouver celle du serveur | Synchro avant la décision de connexion ; index unique sur `telephone` |
| 13 | Espace prestataire | Statut, prix, photo et commandes factices | Données réelles |

## 2. Ce qui a été ajouté ou corrigé dans la v2

| # | Sujet | Correctif |
|---|-------|-----------|
| 14 | Commande du client refusée (défaut de la v1) | Insertion sans `.select()` : la relecture était bloquée par RLS pour un client anonyme |
| 15 | Fiches en attente lisibles par tout le monde (téléphones exposés) | RLS restreinte : public = fiches validées ; chacun = les siennes ; admin = tout |
| 16 | Fiche retirée qui restait visible chez les clients | Réconciliation à chaque synchro : une fiche absente de la liste serveur des validées est retirée localement |
| 17 | Photo envoyée avant sa fiche (même seconde) | Tri de la file : insert, puis update, puis photos, puis suppressions |
| 18 | Refus serveur silencieux | Bandeau sur l’écran admin avec le nombre d’actions refusées et bouton « Réessayer » |
| 19 | Commande vocale absente | Enregistrement via `VoiceService`, envoi du fichier dans le bucket `voice_notes`, lecture par lien |
| 20 | Recherche vocale | Reportée : elle demande un paquet supplémentaire (`speech_to_text`). Le bouton affiche « bientôt disponible ». |
| 21 | Suppression d’un prestataire | La suppression efface aussi ses commandes (cascade existante). L’écran admin le signale avant de confirmer. Préférer « Refuser » pour garder l’historique |

**Correction de la v1 :** la notice affirmait que supprimer un prestataire ayant des commandes échouait. C’était faux : la clé étrangère est en cascade.

## 3. Base Supabase (projet dassa_connect)

- Migration `alignement_schema_dassa_connect_v2` **appliquée** et vérifiée : 15 colonnes sur `prestataires`, 3 triggers `updated_at`, 1 trigger `proteger_statut`, buckets `prestataire_photos` et `voice_notes`, politiques d’insertion et de lecture restreintes.
- Vérification : avec le rôle `anon`, la fiche de test (en attente) n’est pas visible (0 ligne).

## 4. Dépendances

Aucune dépendance supplémentaire n’est nécessaire. Les paquets déjà utilisés (record, flutter_tts, path_provider, url_launcher…) suffisent.

## 5. Ce que vous devez encore faire vous-même (non accessible depuis l’outil)

1. Dashboard > Authentication > Providers : activer **Anonymous sign-ins**. Sans cela, aucun prestataire ne peut s’inscrire.
2. Dashboard > Authentication > Users : définir un mot de passe pour le compte admin (celui de la table `admins`).
3. Vérifier que `web/` contient `sqlite3.wasm` et `drift_worker.js` (base locale sur le web).
4. Garder votre `pubspec.yaml` (l’archive ne le contient pas).

## 6. Scénario de test

1. Prestataire : s’inscrire, remplir la fiche, envoyer. Il voit « En attente de validation ».
2. Admin : PIN, code secret, puis compte Supabase. La fiche apparaît dans « Validation ».
3. Admin : « Valider ». Sur un autre téléphone, le client tire vers le bas : la fiche apparaît, avec ses vraies données.
4. Client : commande texte, puis commande vocale. Le prestataire la voit dans « Commandes » après synchro, avec le message vocal lisible.
5. Admin : « Refuser ». Le client actualise : la fiche disparaît du catalogue.

## 7. Limites restantes

- Le code n’a pas été compilé : aucun SDK Dart/Flutter n’est disponible dans cet environnement et pub.dev n’est pas accessible. Lancer `flutter analyze` après avoir ajouté la dépendance.
- Les deux points de la section 5 ne peuvent pas être faits depuis l’outil.

## 8. Version 5 : espaces client et prestataire en direct

### Constats (captures d’écran)

- Commandes : le message vocal n’apparaissait pas, impossible de l’écouter, de répondre ou de changer le statut.
- Tableau de bord : compteurs figés à 0, aucune alerte à l’arrivée d’une commande.
- Messagerie et profil : écrans vides.

### Causes

- Côté serveur : la connexion anonyme est désactivée dans Supabase (aucun utilisateur anonyme enregistré). Sans session, aucune fiche prestataire ni aucune commande n’a pu être envoyée. Aucun correctif de code ne remplace cette activation.
- Côté application : la file d’envoi s’arrêtait sur une erreur inattendue, ce qui bloquait toutes les opérations suivantes ; les messages vocaux étaient conservés sous une adresse temporaire, perdue au rechargement de la page ; aucune réponse n’était possible ; les écrans n’étaient pas réactifs.

### Corrections

- Messagerie : table `commande_messages` (texte et vocal, dans les deux sens). Seuls les deux participants de la commande peuvent lire ou écrire (règles RLS).
- Commandes : le téléphone du client est lié à sa session (`client_user_id`). Il reçoit les mises à jour de statut de ses commandes.
- Vocaux : les octets du message sont conservés et envoyés, le format est détecté à partir du contenu du fichier.
- File d’envoi : une erreur isolée ne bloque plus les autres opérations. Les opérations en échec sont relancées à chaque démarrage.
- Écrans : tableau de bord, commandes et conversations mis à jour en direct. Pastilles « non lu », alertes à l’arrivée d’une commande ou d’un message, statut modifiable et appel du client depuis la conversation.
- Synchronisation automatique toutes les 20 secondes tant que l’application est ouverte.

### Actions à faire

1. Supabase : Authentication > Sign In / Providers > activer **Anonymous Sign-Ins**.
2. Ouvrir l’application. Si la fiche n’apparaît pas encore sur le serveur, la valider à nouveau dans l’espace administrateur.
3. Ajouter le seul nouveau paquet : `flutter pub add just_audio`.
4. Tester le client et le prestataire dans deux navigateurs (ou une fenêtre privée) distincts : une seule session par navigateur.

### Limites

- Les alertes sont affichées dans l’application. Les notifications système (application fermée) demandent un service externe (Firebase Cloud Messaging), qui n’est pas inclus ici.
- Les mises à jour arrivent toutes les 6 à 20 secondes, pas instantanément.

## 9. Audit client et admin (v5.2)

### Ce qui a été corrigé

- Administrateur : lecture de toutes les commandes (politique RLS dédiée, synchronisation pour les comptes non anonymes).
- Onglet Transactions : nom du prestataire, client, statut lisible, date, type de contenu, compteurs.
- Profil client : statuts traduits.

### Ce qui n'a PAS été vérifié

Aucun test sur l'application en fonctionnement : le code n'a pas été compilé ni lancé dans cet environnement. Les points suivants sont à tester avant mise en production.

### Plan de test (environ 20 minutes, dans trois navigateurs séparés)

Client :
1. Accueil : seuls les prestataires validés apparaissent.
2. Fiche : vraies informations, bouton « Passer une commande ».
3. Commande texte : statut « Nouvelle » dans l'onglet Commandes.
4. Commande vocale : le vocal apparaît puis devient lisible après synchronisation.
5. Réponse du prestataire : pastille « non lu » et alerte.
6. Statut « Terminée » visible côté client.

Prestataire :
1. Accueil : compteurs réels, bandeau de statut.
2. Commandes : filtres, ouverture de la conversation, changement de statut, appel du client.
3. Messages : réponse texte et vocal, écoute des vocaux reçus.
4. Boutique : modification du prix et de la photo.
5. Profil : informations réelles.

Administrateur :
1. Connexion : code PIN, code secret, puis compte Supabase.
2. Validation : « Valider » rend la fiche visible côté client.
3. Prestataires : compteurs corrects.
4. Transactions : toutes les commandes, avec les noms des prestataires.
5. Sans session serveur : un bandeau signale les actions refusées.

### Limites connues

- La section « Sécurité » des paramètres admin est informative : le code PIN n'est pas modifiable depuis l'application.
- Les fichiers `espace.dart` et `shell.dart` ne sont plus utilisés (ancienne maquette avec des valeurs fixes) : ils peuvent être supprimés.

## 10. Version 6 : une seule conversation par interlocuteur, photos et écrans refaits

### Ce qui a été corrigé

- Conversation : toutes les commandes d'un même couple forment une seule discussion. Un nouveau message ou vocal s'ajoute à la conversation existante, il ne crée plus une nouvelle commande. La liste affiche une ligne par interlocuteur.
- Numéro du client : demandé une seule fois, puis mémorisé. Il est modifiable dans le profil.
- Discussion façon WhatsApp : bulles vertes et blanches, séparateurs de jour, coches d'envoi, messages vocaux avec barre de progression, enregistrement avec compteur, appel du prestataire ou du client, statut de la commande.
- Photos : compressées (800 px), converties en texte, affichées tout de suite, puis envoyées au serveur une seule fois. Une relance ne renvoie plus la même image.
- Accueil client : catégories en puces, recherche, cartes avec photo du prestataire.
- Espace prestataire : carte d'accueil, compteurs réels, conversations récentes, photo affichée sur l'accueil, la boutique et le profil.
- Profil client : suppression du bouton « Notifications » (non fonctionnel) et de « Devenir prestataire ». Numéro et photo facultative fonctionnels.

### Problèmes du serveur constatés (à corriger avant de tester)

- La connexion anonyme est toujours désactivée : aucun utilisateur anonyme n'existe. Sans elle, les appareils clients et prestataires n'ont pas de session, et la messagerie ne peut pas fonctionner entre deux appareils.
- La fiche « Gg digital » appartient au compte administrateur (`user_id` = administrateur). Cela vient du fait que le test a été fait dans un seul navigateur, où la session admin a remplacé celle du prestataire.
- Les deux photos déjà présentes dans le stockage ne sont pas rattachées à la fiche (`photos_url` vide). Il faut en ajouter une nouvelle depuis la boutique.

### Actions à faire, dans l'ordre

1. Supabase : Authentication > Sign In / Providers > activer **Anonymous Sign-Ins**.
2. Tester le prestataire dans un navigateur dédié (ou une fenêtre privée), sans session administrateur. Ouvrir l'application une fois, puis exécuter ce SQL dans SQL Editor pour rattacher la fiche à cette session :

```sql
update prestataires
set user_id = (select id from auth.users where is_anonymous order by created_at desc limit 1)
where nom = 'Gg digital';
```

3. Tester le client dans un autre navigateur ou une fenêtre privée. Une session par navigateur : l'administrateur doit aussi être dans son propre navigateur.

### Plan de test

Client : accueil (catégories, recherche, photos), fiche, « Passer une commande » (une seule fois), message texte et vocal ensuite dans la même conversation, réponse du prestataire, alerte et pastille « non lu », statut à jour.

Prestataire : accueil (compteurs, conversations récentes), commandes (une carte par commande), messages (une ligne par client), réponse texte et vocal, appel du client, changement de statut, ajout de photo (visible sur l'accueil, la boutique et le profil).

Administrateur : validation, prestataires, transactions.

### Limites

- Le code n'a pas été compilé ni lancé dans cet environnement. Lancer `flutter analyze`.
- Les alertes sont dans l'application uniquement (pas de notifications système quand l'application est fermée).
- Les mises à jour arrivent toutes les 6 à 20 secondes.

## 11. Version 7 : commande façon WhatsApp et corrections d'analyse

- Erreur corrigée : `photosList` utilisé dans l'espace prestataire sans import de l'extension qui le définit.
- Suggestions corrigées : `const` ajoutés, `const` inutiles retirés, import inutile supprimé.
- Plus de formulaire de commande séparé. « Écrire au prestataire » ouvre directement une discussion : le premier message (texte ou vocal) crée la commande, les suivants s'ajoutent à la même discussion.
- Le numéro du client est demandé une seule fois, au premier envoi, puis mémorisé.
