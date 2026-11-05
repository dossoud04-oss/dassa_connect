import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:url_launcher/url_launcher.dart';

import '../data/base.dart';
import '../data/fil.dart';
import '../providers.dart';
import '../services/messagerie.dart';
import '../theme.dart';
import '../utils.dart';
import 'audio_message.dart';
import 'photo.dart';
import 'statuts.dart';

const _fondConversation = Color(0xFFECE5DD);
const _bulleMoi = Color(0xFFDCF8C6);
const _coche = Color(0xFF53BDEB);

enum _Etat { envoye, attente, echec }

/// Élément de la conversation : un message reçu, envoyé, en cours d'envoi, ou la première commande.
class _Bulle {
  const _Bulle({
    required this.uid,
    required this.auteur,
    required this.creeLe,
    this.texte,
    this.audioUrl,
    this.audioDuree = 0,
    this.audioEnCours = false,
    this.etat = _Etat.envoye,
  });

  final String uid;
  final String auteur;
  final DateTime creeLe;
  final String? texte;
  final String? audioUrl;
  final int audioDuree;
  final bool audioEnCours;
  final _Etat etat;
}

/// Conversation WhatsApp-like : toutes les commandes d'un même couple, texte et vocal dans les deux sens.
class ConversationPage extends ConsumerStatefulWidget {
  const ConversationPage({
    super.key,
    required this.role,
    required this.cle,
    required this.titre,
    this.photo,
    this.prestataireUid,
  });

  /// 'client' ou 'prestataire' : détermine de quel côté s'affichent les messages.
  final String role;
  final String cle;
  final String titre;
  final String? photo;

  /// Renseigné pour une nouvelle discussion : le premier message crée la commande.
  final String? prestataireUid;

  @override
  ConsumerState<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends ConsumerState<ConversationPage> {
  final _texteCtrl = TextEditingController();
  final _defilement = ScrollController();
  late final Stream<List<CommandeLocale>> _commandes;
  late final Stream<List<Map<String, dynamic>>> _attente;
  Timer? _minuterie;
  Timer? _chrono;
  List<MessageDistant> _messages = const [];
  String? _telephoneAutre;
  bool _chargement = true;
  bool _horsLigne = false;
  bool _enregistrement = false;
  DateTime? _debut;
  int _secondes = 0;
  int _nombreAffiche = -1;

  @override
  void initState() {
    super.initState();
    final depot = ref.read(depotProvider);
    final role = widget.role;
    final cle = widget.cle;
    _commandes = depot
        .surveillerToutesCommandes()
        .map((liste) => liste.where((c) => cleFil(role, c) == cle).toList());
    _attente = depot.surveillerOperationsMessages();
    _rafraichir();
    _minuterie = Timer.periodic(const Duration(seconds: 6), (_) => _rafraichir());
  }

  @override
  void dispose() {
    _minuterie?.cancel();
    _chrono?.cancel();
    _texteCtrl.dispose();
    _defilement.dispose();
    super.dispose();
  }

  void _snack(String texte) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texte)));
  }

  /// Relit les messages du serveur et marque la conversation comme lue.
  Future<void> _rafraichir() async {
    final depot = ref.read(depotProvider);
    final messagerie = ref.read(messagerieProvider);
    try {
      final commandes = await depot.commandesDuFil(widget.role, widget.cle);
      final messages = await messagerie.messagesDe([for (final c in commandes) c.uid]);
      String? tel;
      if (commandes.isNotEmpty) {
        tel = widget.role == 'client'
            ? (await depot.prestataireParUid(commandes.first.prestataireUid))?.telephone
            : commandes.first.clientTelephone;
      }
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _telephoneAutre = tel;
        _chargement = false;
        _horsLigne = false;
      });
      await depot.marquerLu(widget.role, widget.cle);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _chargement = false;
        _horsLigne = true;
      });
    }
  }

  /// Les messages vont sur la commande la plus récente de la conversation.
  Future<String?> _cibleEnvoi() async {
    final liste = await ref.read(depotProvider).commandesDuFil(widget.role, widget.cle);
    return liste.isEmpty ? null : liste.first.uid;
  }

  /// Demande le numéro une seule fois : il sert à retrouver la discussion côté prestataire.
  Future<String?> _demanderNumero() async {
    final ctrl = TextEditingController();
    final saisie = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Votre numéro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Le prestataire vous répondra sur ce numéro. Demandé une seule fois.',
                style: TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(prefixText: '+229 ', hintText: '01 XX XX XX XX'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Valider')),
        ],
      ),
    );
    if (saisie == null) return null;
    final chiffres = saisie.replaceAll(RegExp(r'[^0-9]'), '');
    if (chiffres.length < 8) {
      _snack('Numéro invalide (8 chiffres minimum).');
      return null;
    }
    return chiffres.startsWith('229') ? '+$chiffres' : '+229$chiffres';
  }

  /// Envoie dans la discussion. Si elle est vide, le premier message crée la commande.
  Future<void> _envoyerMessage({String? texte, Uint8List? octets, int duree = 0}) async {
    final depot = ref.read(depotProvider);
    final cible = await _cibleEnvoi();
    if (cible != null) {
      await depot.envoyerMessage(
          commandeUid: cible, auteur: widget.role, texte: texte, audioBytes: octets, duree: duree);
      return;
    }
    final prestataire = widget.prestataireUid;
    if (prestataire == null) {
      _snack('Aucune commande dans cette conversation.');
      return;
    }
    final telephone = await depot.lireEtat('client_telephone') ?? await _demanderNumero();
    if (telephone == null) return;
    await depot.ecrireEtat('client_telephone', telephone);
    await depot.creerCommande(
      clientTelephone: telephone,
      prestataireUid: prestataire,
      message: texte,
      audioBytes: octets,
      duree: duree,
    );
  }

  Future<void> _envoyerTexte(String texte) async {
    try {
      await _envoyerMessage(texte: texte);
      _texteCtrl.clear();
      if (mounted) setState(() {});
    } catch (e) {
      _snack('Message non enregistré : $e');
    }
  }

  Future<void> _demarrerVocal() async {
    final voix = ref.read(voixProvider);
    try {
      final autorise = await voix.demarrer();
      if (!mounted) return;
      if (!autorise) {
        _snack('Autorisez le micro pour envoyer un message vocal.');
        return;
      }
      _debut = DateTime.now();
      setState(() {
        _enregistrement = true;
        _secondes = 0;
      });
      _chrono = Timer.periodic(const Duration(seconds: 1), (_) {
        final debut = _debut;
        if (debut != null && mounted) {
          setState(() => _secondes = DateTime.now().difference(debut).inSeconds);
        }
      });
    } catch (e) {
      _snack('Micro indisponible : $e');
    }
  }

  Future<void> _terminerVocal({required bool envoyer}) async {
    _chrono?.cancel();
    final duree = _secondes;
    if (mounted) setState(() => _enregistrement = false);
    final voix = ref.read(voixProvider);
    try {
      final chemin = await voix.arreter();
      if (!envoyer || chemin == null) return;
      final octets = await XFile(chemin).readAsBytes();
      await _envoyerMessage(octets: octets, duree: duree);
    } catch (e) {
      _snack('Vocal non envoyé : $e');
    }
  }

  Future<void> _changerStatut(String statut) async {
    final cible = await _cibleEnvoi();
    if (cible == null) return;
    await ref.read(depotProvider).changerStatutCommande(cible, statut);
    _snack('Statut : ${libelleStatut(statut)}');
  }

  Future<void> _appeler(String telephone) async {
    final numero = chiffresSeulement(telephone);
    try {
      final ok = await launchUrl(Uri(scheme: 'tel', path: '+$numero'));
      if (!ok) _snack('Impossible d’ouvrir l’appel.');
    } catch (_) {
      _snack('Appel impossible sur cet appareil.');
    }
  }

  /// Assemble le fil : première commande, messages reçus, messages en cours d'envoi,
  /// avec un séparateur à chaque changement de jour.
  List<Object> _construireFil(List<CommandeLocale> commandes, List<Map<String, dynamic>> attente) {
    final uids = {for (final c in commandes) c.uid};
    final bulles = <_Bulle>[];
    for (final c in commandes) {
      bulles.add(_Bulle(
        uid: c.uid,
        auteur: 'client',
        creeLe: c.creeLe.toLocal(),
        texte: c.messageTexte,
        audioUrl: c.audioUrl,
        audioDuree: c.audioDuree,
        audioEnCours: c.audioUrl == null && c.audioLocal != null,
      ));
    }
    final recus = <String>{};
    for (final m in _messages) {
      recus.add(m.uid);
      bulles.add(_Bulle(
        uid: m.uid,
        auteur: m.auteur,
        creeLe: m.creeLe,
        texte: m.texte,
        audioUrl: m.audioUrl,
        audioDuree: m.audioDuree,
      ));
    }
    for (final p in attente) {
      final uid = p['uid'] as String;
      if (recus.contains(uid) || !uids.contains(p['commande_uid'])) continue;
      bulles.add(_Bulle(
        uid: uid,
        auteur: p['auteur'] as String,
        creeLe: DateTime.parse(p['cree_le'] as String).toLocal(),
        texte: p['texte'] as String?,
        audioDuree: ((p['audio_duree'] as num?) ?? 0).toInt(),
        etat: p['erreur'] == true ? _Etat.echec : _Etat.attente,
      ));
    }
    bulles.sort((a, b) => a.creeLe.compareTo(b.creeLe));
    final items = <Object>[];
    DateTime? jour;
    for (final b in bulles) {
      final j = DateTime(b.creeLe.year, b.creeLe.month, b.creeLe.day);
      if (jour == null || j != jour) {
        items.add(j);
        jour = j;
      }
      items.add(b);
    }
    return items;
  }

  void _planifierDefilement(int nombre) {
    if (nombre == _nombreAffiche) return;
    _nombreAffiche = nombre;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_defilement.hasClients) _defilement.jumpTo(_defilement.position.maxScrollExtent);
    });
  }

  String _heure(DateTime d) =>
      '${d.hour.toString().padLeft(2, "0")}:${d.minute.toString().padLeft(2, "0")}';

  Widget _separateurJour(DateTime j) {
    final maintenant = DateTime.now();
    final aujourdhui = DateTime(maintenant.year, maintenant.month, maintenant.day);
    final hier = aujourdhui.subtract(const Duration(days: 1));
    final libelle = j == aujourdhui
        ? 'Aujourd’hui'
        : (j == hier ? 'Hier' : '${j.day.toString().padLeft(2, "0")}/${j.month.toString().padLeft(2, "0")}/${j.year}');
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(8)),
        child: Text(libelle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ),
    );
  }

  Widget _bulle(_Bulle b) {
    final moi = b.auteur == widget.role;
    final largeur = MediaQuery.sizeOf(context).width;
    final fond = b.etat == _Etat.echec ? Colors.red.shade100 : (moi ? _bulleMoi : Colors.white);
    final contenu = <Widget>[];
    if (b.texte != null && b.texte!.isNotEmpty) {
      contenu.add(Text(b.texte!, style: const TextStyle(fontSize: 15, height: 1.3)));
    }
    if (b.audioUrl != null) {
      contenu.add(AudioMessage(url: b.audioUrl!, duree: b.audioDuree, moi: moi));
    } else if (b.audioEnCours) {
      contenu.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mic, size: 18, color: Colors.grey),
          const SizedBox(width: 6),
          Text('Vocal en cours d’envoi…',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontStyle: FontStyle.italic)),
        ],
      ));
    }
    final Widget coche;
    if (!moi) {
      coche = const SizedBox.shrink();
    } else if (b.etat == _Etat.echec) {
      coche = const Icon(Icons.error_outline, size: 14, color: Colors.red);
    } else if (b.etat == _Etat.attente) {
      coche = const Icon(Icons.access_time, size: 13, color: Colors.grey);
    } else {
      coche = const Icon(Icons.done_all, size: 15, color: _coche);
    }
    return Align(
      alignment: moi ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: largeur * 0.8),
        margin: EdgeInsets.fromLTRB(moi ? 48 : 0, 2, moi ? 0 : 48, 2),
        padding: const EdgeInsets.fromLTRB(9, 6, 7, 4),
        decoration: BoxDecoration(
          color: fond,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 2, offset: const Offset(0, 1))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...contenu,
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_heure(b.creeLe), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  if (moi) ...[const SizedBox(width: 3), coche],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fil(List<CommandeLocale> commandes, List<Map<String, dynamic>> attente) {
    final items = _construireFil(commandes, attente);
    _planifierDefilement(items.length);
    if (items.isEmpty) {
      return Center(
        child: _chargement
            ? const CircularProgressIndicator()
            : const Text('Décrivez votre besoin. Votre premier message crée la commande.', style: TextStyle(color: Colors.black54)),
      );
    }
    return ListView.builder(
      controller: _defilement,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        if (item is DateTime) return _separateurJour(item);
        return _bulle(item as _Bulle);
      },
    );
  }

  Widget _barre() {
    if (_enregistrement) return _barreVocale();
    final vide = _texteCtrl.text.trim().isEmpty;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: _texteCtrl,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Message',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: vide ? _demarrerVocal : () => _envoyerTexte(_texteCtrl.text.trim()),
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(color: vertDassa, shape: BoxShape.circle),
                child: Icon(vide ? Icons.mic : Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barreVocale() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Annuler',
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _terminerVocal(envoyer: false),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                child: Row(
                  children: [
                    const Icon(Icons.fiber_manual_record, color: Colors.red, size: 14),
                    const SizedBox(width: 8),
                    Text(formatDuree(_secondes), style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 10),
                    const Expanded(child: Text('Enregistrement…', style: TextStyle(color: Colors.grey))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _terminerVocal(envoyer: true),
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(color: vertDassa, shape: BoxShape.circle),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estClient = widget.role == 'client';
    return StreamBuilder<List<CommandeLocale>>(
      stream: _commandes,
      builder: (context, snapCommandes) {
        final commandes = snapCommandes.data ?? const <CommandeLocale>[];
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _attente,
          builder: (context, snapAttente) {
            final attente = snapAttente.data ?? const <Map<String, dynamic>>[];
            final statut = commandes.isEmpty ? null : commandes.first.statut;
            return Scaffold(
              backgroundColor: _fondConversation,
              appBar: AppBar(
                backgroundColor: vertDassa,
                foregroundColor: Colors.white,
                titleSpacing: 0,
                title: Row(
                  children: [
                    Avatar(initiales: estClient ? initiales(widget.titre) : 'C', photo: widget.photo, rayon: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.titre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            statut == null ? 'Nouvelle conversation' : libelleStatut(statut),
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    tooltip: estClient ? 'Appeler le prestataire' : 'Appeler le client',
                    icon: const Icon(Icons.call),
                    onPressed: _telephoneAutre == null ? null : () => _appeler(_telephoneAutre!),
                  ),
                  if (!estClient)
                    PopupMenuButton<String>(
                      tooltip: 'Statut de la commande',
                      icon: const Icon(Icons.more_vert),
                      onSelected: _changerStatut,
                      itemBuilder: (_) => [
                        for (final e in libellesStatutCommande.entries)
                          PopupMenuItem<String>(value: e.key, child: Text('Marquer : ${e.value}')),
                      ],
                    ),
                ],
              ),
              body: Column(
                children: [
                  if (_horsLigne)
                    Container(
                      width: double.infinity,
                      color: Colors.orange.shade100,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: const Text('Hors ligne : les messages arriveront au retour du réseau.',
                          style: TextStyle(fontSize: 12)),
                    ),
                  Expanded(child: _fil(commandes, attente)),
                  _barre(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
