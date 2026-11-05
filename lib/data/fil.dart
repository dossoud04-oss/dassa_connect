import '../utils.dart';
import 'base.dart';

/// Une conversation regroupe toutes les commandes d'un même couple.
/// Côté client : une conversation par prestataire.
/// Côté prestataire : une conversation par numéro de client.
String cleFil(String role, CommandeLocale c) =>
    role == 'prestataire' ? 'c:${chiffresSeulement(c.clientTelephone)}' : 'p:${c.prestataireUid}';

/// Clé de l'heure de lecture d'une conversation, propre à chaque rôle.
String cleLu(String role, String cle) => 'lu:$role:$cle';
