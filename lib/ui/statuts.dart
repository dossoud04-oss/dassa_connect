import 'package:flutter/material.dart';

/// Statuts d’une commande (valeurs stockées en base) et leur libellé en français.
const libellesStatutCommande = <String, String>{
  'nouvelle': 'Nouvelle',
  'ecoutee': 'Vue',
  'en_cours': 'En cours',
  'livree': 'Terminée',
  'refusee': 'Refusée',
};

String libelleStatut(String statut) => libellesStatutCommande[statut] ?? statut;

Color couleurStatutCommande(String statut) {
  switch (statut) {
    case 'nouvelle':
      return const Color(0xFFE87516);
    case 'ecoutee':
      return const Color(0xFF2563EB);
    case 'en_cours':
      return const Color(0xFF7C3AED);
    case 'livree':
      return const Color(0xFF16A34A);
    case 'refusee':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
