import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/depot.dart';
import '../data/fil.dart';

/// Un message d'une commande, tel qu'il est stocké sur le serveur.
class MessageDistant {
  const MessageDistant({
    required this.uid,
    required this.commandeUid,
    required this.auteur,
    required this.texte,
    required this.audioUrl,
    required this.audioDuree,
    required this.creeLe,
  });

  final String uid;
  final String commandeUid;
  final String auteur;
  final String? texte;
  final String? audioUrl;
  final int audioDuree;
  final DateTime creeLe;

  factory MessageDistant.depuis(Map<String, dynamic> m) => MessageDistant(
        uid: m['uid'] as String,
        commandeUid: m['commande_uid'] as String,
        auteur: m['auteur'] as String,
        texte: m['texte'] as String?,
        audioUrl: m['audio_url'] as String?,
        audioDuree: ((m['audio_duree'] as num?) ?? 0).toInt(),
        creeLe: DateTime.parse(m['cree_le'] as String).toLocal(),
      );
}

/// Lecture des messages sur le serveur. Les règles RLS ne renvoient que les messages
/// des commandes dont cet appareil est participant.
class Messagerie {
  Messagerie(this._client, this._depot);

  final SupabaseClient? _client;
  final Depot _depot;

  /// Messages de plusieurs commandes d'une même conversation, du plus ancien au plus récent.
  Future<List<MessageDistant>> messagesDe(List<String> uids) async {
    final c = _client;
    if (c == null || uids.isEmpty) return const [];
    final resultat = <MessageDistant>[];
    for (final uid in uids) {
      final lignes = await c
          .from('commande_messages')
          .select()
          .eq('commande_uid', uid)
          .order('cree_le', ascending: true)
          .limit(500);
      resultat.addAll(lignes.map((m) => MessageDistant.depuis(m)));
    }
    resultat.sort((a, b) => a.creeLe.compareTo(b.creeLe));
    return resultat;
  }

  /// Derniers messages, toutes commandes confondues, du plus récent au plus ancien.
  Future<List<MessageDistant>> derniers({int limite = 300}) async {
    final c = _client;
    if (c == null) return const [];
    final lignes =
        await c.from('commande_messages').select().order('cree_le', ascending: false).limit(limite);
    return lignes.map((m) => MessageDistant.depuis(m)).toList();
  }

  /// Nombre de conversations dont le dernier message vient de l'autre partie et n'a pas été lu.
  Future<int> compterNonLus(String role) async {
    final commandes = await _depot.lireToutesCommandes();
    final cleParCommande = {for (final c in commandes) c.uid: cleFil(role, c)};
    final recents = await derniers();
    final dernierParCle = <String, MessageDistant>{};
    for (final m in recents) {
      final cle = cleParCommande[m.commandeUid];
      if (cle != null) dernierParCle.putIfAbsent(cle, () => m);
    }
    var total = 0;
    for (final entree in dernierParCle.entries) {
      if (entree.value.auteur == role) continue;
      final lu = DateTime.tryParse(await _depot.lireEtat(cleLu(role, entree.key)) ?? '');
      if (lu == null || entree.value.creeLe.isAfter(lu)) total++;
    }
    return total;
  }
}
