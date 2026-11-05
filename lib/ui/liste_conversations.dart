import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/base.dart';
import '../data/fil.dart';
import '../data/lecture.dart';
import '../providers.dart';
import '../services/messagerie.dart';
import '../theme.dart';
import '../utils.dart';
import 'conversation.dart';
import 'photo.dart';

/// Liste des conversations : une ligne par interlocuteur, comme dans WhatsApp.
class ListeConversations extends ConsumerStatefulWidget {
  const ListeConversations({super.key, required this.role});

  /// 'client' ou 'prestataire'.
  final String role;

  @override
  ConsumerState<ListeConversations> createState() => _ListeConversationsState();
}

class _ListeConversationsState extends ConsumerState<ListeConversations> {
  late final Stream<List<CommandeLocale>> _flux;
  Timer? _minuterie;
  Map<String, MessageDistant> _derniers = {};
  Map<String, DateTime?> _lus = {};
  bool _horsLigne = false;

  @override
  void initState() {
    super.initState();
    _flux = ref.read(depotProvider).surveillerToutesCommandes();
    _charger();
    _minuterie = Timer.periodic(const Duration(seconds: 8), (_) => _charger());
  }

  @override
  void dispose() {
    _minuterie?.cancel();
    super.dispose();
  }

  /// Dernier message de chaque conversation et heure de lecture, relus du serveur et de l'appareil.
  Future<void> _charger() async {
    final depot = ref.read(depotProvider);
    final messagerie = ref.read(messagerieProvider);
    final role = widget.role;
    try {
      final commandes = await depot.lireToutesCommandes();
      final cleParCommande = {for (final c in commandes) c.uid: cleFil(role, c)};
      final recents = await messagerie.derniers();
      final derniers = <String, MessageDistant>{};
      for (final m in recents) {
        final cle = cleParCommande[m.commandeUid];
        if (cle != null) derniers.putIfAbsent(cle, () => m);
      }
      final lus = <String, DateTime?>{};
      for (final cle in cleParCommande.values.toSet()) {
        lus[cle] = DateTime.tryParse(await depot.lireEtat(cleLu(role, cle)) ?? '');
      }
      if (!mounted) return;
      setState(() {
        _derniers = derniers;
        _lus = lus;
        _horsLigne = false;
      });
    } catch (_) {
      if (mounted) setState(() => _horsLigne = true);
    }
  }

  /// Toutes les commandes d'un même couple forment une seule conversation.
  Map<String, List<CommandeLocale>> _grouper(List<CommandeLocale> commandes) {
    final groupes = <String, List<CommandeLocale>>{};
    for (final c in commandes) {
      groupes.putIfAbsent(cleFil(widget.role, c), () => []).add(c);
    }
    return groupes;
  }

  DateTime _activite(String cle, List<CommandeLocale> groupe) =>
      _derniers[cle]?.creeLe ?? groupe.first.creeLe.toLocal();

  bool _nonLu(String cle) {
    final dernier = _derniers[cle];
    if (dernier == null || dernier.auteur == widget.role) return false;
    final lu = _lus[cle];
    return lu == null || dernier.creeLe.isAfter(lu);
  }

  String _apercu(String cle, CommandeLocale plusRecente) {
    final dernier = _derniers[cle];
    if (dernier != null) {
      if (dernier.texte?.isNotEmpty == true) return dernier.texte!;
      if (dernier.audioUrl != null) return 'Message vocal';
    }
    if (plusRecente.messageTexte?.isNotEmpty == true) return plusRecente.messageTexte!;
    return plusRecente.audioUrl != null || plusRecente.audioLocal != null ? 'Message vocal' : 'Commande';
  }

  PrestataireLocal? _prestataireDe(String uid, List<PrestataireLocal> liste) {
    for (final p in liste) {
      if (p.uid == uid) return p;
    }
    return null;
  }

  Widget _ligne(String cle, List<CommandeLocale> groupe, List<PrestataireLocal> prestataires) {
    final plusRecente = groupe.first;
    final estClient = widget.role == 'client';
    final prestataire = estClient ? _prestataireDe(plusRecente.prestataireUid, prestataires) : null;
    final titre = estClient
        ? (prestataire?.nom ?? 'Prestataire')
        : 'Client ${plusRecente.clientTelephone}';
    final photos = prestataire?.photosList ?? const <String>[];
    final photo = photos.isEmpty ? null : photos.first;
    final nonLu = _nonLu(cle);
    final activite = _activite(cle, groupe);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ConversationPage(role: widget.role, cle: cle, titre: titre, photo: photo),
          ),
        );
        if (mounted) _charger();
      },
      leading: Avatar(initiales: estClient ? initiales(titre) : 'C', photo: photo, rayon: 24),
      title: Text(
        titre,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: nonLu ? FontWeight.w800 : FontWeight.w600),
      ),
      subtitle: Text(
        _apercu(cle, plusRecente),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: nonLu ? noirTexte : grisTexte,
          fontWeight: nonLu ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(tempsEcoule(activite), style: TextStyle(fontSize: 11, color: nonLu ? vertDassa : Colors.grey)),
          const SizedBox(height: 6),
          if (nonLu)
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(color: vertDassa, shape: BoxShape.circle),
            )
          else
            const SizedBox(width: 10, height: 10),
        ],
      ),
    );
  }

  Widget _vide() => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline, size: 56, color: Colors.grey),
              SizedBox(height: 12),
              Text('Aucune conversation', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text(
                'Vos échanges avec les prestataires apparaîtront ici.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final prestataires = ref.watch(tousPrestatairesProvider).valueOrNull ?? const <PrestataireLocal>[];
    return StreamBuilder<List<CommandeLocale>>(
      stream: _flux,
      builder: (context, snap) {
        final groupes = _grouper(snap.data ?? const <CommandeLocale>[]);
        if (groupes.isEmpty) return _vide();
        final cles = groupes.keys.toList()
          ..sort((a, b) => _activite(b, groupes[b]!).compareTo(_activite(a, groupes[a]!)));
        return Column(
          children: [
            if (_horsLigne)
              Container(
                width: double.infinity,
                color: Colors.orange.shade100,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: const Text('Hors ligne : les messages seront mis à jour au retour du réseau.',
                    style: TextStyle(fontSize: 12)),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: cles.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                itemBuilder: (context, i) => _ligne(cles[i], groupes[cles[i]]!, prestataires),
              ),
            ),
          ],
        );
      },
    );
  }
}
