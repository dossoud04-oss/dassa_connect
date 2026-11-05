import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../data/lecture.dart';
import '../data/base.dart';
import '../data/fil.dart';
import '../data/images.dart';
import '../providers.dart';
import '../theme.dart';
import '../utils.dart';
import 'connexion.dart';
import 'conversation.dart';
import 'formulaire_prestataire.dart';
import 'liste_conversations.dart';
import 'photo.dart';
import 'statuts.dart';
import 'widgets.dart';

/// Espace prestataire : tableau de bord en direct, commandes, messagerie, boutique et profil.
class PrestataireShell extends ConsumerStatefulWidget {
  const PrestataireShell({super.key});

  @override
  ConsumerState<PrestataireShell> createState() => _PrestataireShellState();
}

class _PrestataireShellState extends ConsumerState<PrestataireShell> {
  int _index = 0;
  String _filtre = 'toutes';
  final ImagePicker _picker = ImagePicker();

  void _aller(int onglet) => setState(() => _index = onglet);

  void _alerte(String texte, int onglet) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texte),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(label: 'Voir', onPressed: () => _aller(onglet)),
        ),
      );
    });
  }

  /// Fiche du prestataire connecté, retrouvée grâce au numéro enregistré sur ce téléphone.
  Future<PrestataireLocal?> _monPrestataire() async {
    final depot = ref.read(depotProvider);
    final tel = await depot.lireEtat('telephone');
    if (tel == null) return null;
    return depot.prestataireParNumero(tel);
  }

  void _ajouterPhoto() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: vertDassa),
              title: const Text('Prendre une photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final image = await _picker.pickImage(
                    source: ImageSource.camera, maxWidth: 800, maxHeight: 800, imageQuality: 75);
                if (image != null) await _enregistrerPhoto(image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: vertDassa),
              title: const Text('Choisir dans la galerie'),
              onTap: () async {
                Navigator.pop(ctx);
                final image = await _picker.pickImage(
                    source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 75);
                if (image != null) await _enregistrerPhoto(image);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// La photo est visible tout de suite sur cet appareil, puis envoyée au serveur.
  Future<void> _enregistrerPhoto(XFile image) async {
    final depot = ref.read(depotProvider);
    final moi = await _monPrestataire();
    if (moi == null) return;
    final dataUrl = versDataUrl(await image.readAsBytes());
    await depot.ajouterPhoto(moi.uid, dataUrl);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo ajoutée. Elle sera visible par les clients après synchronisation.')),
    );
  }

  void _modifierPrix(int prixActuel) {
    final controller = TextEditingController(text: prixActuel.toString());
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le prix de base'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Entrez le prix (FCFA)', suffixText: 'FCFA'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final navigateur = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final depot = ref.read(depotProvider);
              final prix = int.tryParse(controller.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              final moi = await _monPrestataire();
              if (moi != null) await depot.changerPrix(moi.uid, prix);
              navigateur.pop();
              messenger.showSnackBar(const SnackBar(content: Text('Prix mis à jour')));
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _ouvrirFiche() async {
    final tel = await ref.read(depotProvider).lireEtat('telephone') ?? '';
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => FormulairePrestatairePage(telephone: tel, edition: true)),
    );
  }

  Future<void> _seDeconnecter() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authProvider).deconnecter();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const ConnexionPage()),
          (route) => false,
        );
      }
    }
  }

  ({String libelle, Color couleur}) _presentationStatut(String? statut) {
    switch (statut) {
      case 'approved':
        return (libelle: 'Approuvé • visible par les clients', couleur: const Color(0xFF16A34A));
      case 'rejected':
        return (libelle: 'Refusé par l’administrateur', couleur: Colors.red);
      default:
        return (libelle: 'En attente de validation', couleur: Colors.orange);
    }
  }

  Widget _bandeauStatut(String? statut) {
    final p = _presentationStatut(statut);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(color: p.couleur.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(Icons.verified, color: p.couleur, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(p.libelle, style: TextStyle(color: p.couleur, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _pastilleStatut(String statut) {
    final couleur = couleurStatutCommande(statut);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: couleur.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
      child: Text(libelleStatut(statut), style: TextStyle(color: couleur, fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }

  Widget _carteStat(String titre, String valeur, IconData icone, Color couleur) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: couleur.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Icon(icone, color: couleur, size: 20),
          const SizedBox(height: 6),
          Text(valeur, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: couleur)),
          const SizedBox(height: 2),
          Text(titre, style: const TextStyle(fontSize: 11, color: grisTexte)),
        ],
      ),
    );
  }

  Widget _videListe(IconData icone, String titre, String sous) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Icon(icone, size: 42, color: Colors.grey),
            const SizedBox(height: 10),
            Text(titre, style: const TextStyle(color: grisTexte, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(sous, textAlign: TextAlign.center, style: const TextStyle(color: grisTexte, fontSize: 12)),
          ],
        ),
      );

  Widget _ligneInfo(String libelle, String valeur) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Text(libelle, style: const TextStyle(color: grisTexte)),
            const Spacer(),
            Flexible(
              child: Text(
                valeur,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );

  /// Photo du prestataire, avec un petit bouton pour la changer.
  Widget _avatar(double rayon, PrestataireLocal? moi) {
    final photos = moi?.photosList ?? const <String>[];
    return GestureDetector(
      onTap: _ajouterPhoto,
      child: Stack(
        children: [
          Avatar(
            initiales: initiales(moi?.nom ?? 'P'),
            photo: photos.isEmpty ? null : photos.first,
            rayon: rayon,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: vertDassa, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _ouvrirConversation(CommandeLocale c) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ConversationPage(
          role: 'prestataire',
          cle: cleFil('prestataire', c),
          titre: 'Client ${c.clientTelephone}',
        ),
      ),
    );
  }

  Widget _carteCommande(CommandeLocale c) {
    final couleur = couleurStatutCommande(c.statut);
    final vocal = c.audioUrl != null || c.audioLocal != null;
    final apercu = c.messageTexte?.isNotEmpty == true
        ? c.messageTexte!
        : (vocal ? 'Message vocal' : 'Commande');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () => _ouvrirConversation(c),
        leading: CircleAvatar(
          backgroundColor: couleur.withValues(alpha: 0.12),
          child: Icon(vocal ? Icons.mic : Icons.receipt_long, color: couleur),
        ),
        title: Text('Client ${c.clientTelephone}', style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(apercu, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _pastilleStatut(c.statut),
            const SizedBox(height: 4),
            Text(tempsEcoule(c.creeLe), style: const TextStyle(fontSize: 11, color: grisTexte)),
          ],
        ),
      ),
    );
  }

  // ---------- Pages ----------

  Widget _pageAccueil(PrestataireLocal? moi) {
    final commandes = ref.watch(commandesMoiProvider).valueOrNull ?? const <CommandeLocale>[];
    final nonLus = ref.watch(messagesNonLusProvider('prestataire')).valueOrNull ?? 0;
    final nouvelles = commandes.where((c) => c.statut == 'nouvelle').length;
    final enCours = commandes.where((c) => c.statut == 'ecoutee' || c.statut == 'en_cours').length;
    final terminees = commandes.where((c) => c.statut == 'livree').length;
    final recentes = <CommandeLocale>[];
    final vues = <String>{};
    for (final c in commandes) {
      if (vues.add(cleFil('prestataire', c))) recentes.add(c);
    }
    final presentation = _presentationStatut(moi?.statut);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [vertDassa, vertHeader]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _avatar(34, moi),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            moi?.nom ?? 'Mon espace',
                            style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            moi == null ? '' : '${moi.categorie} • ${moi.quartier}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 9, color: presentation.couleur),
                      const SizedBox(width: 6),
                      Text(presentation.libelle,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: presentation.couleur)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _carteStat('Nouvelles', '$nouvelles', Icons.fiber_new,
                    nouvelles > 0 ? orangeDassa : vertDassa),
              ),
              const SizedBox(width: 10),
              Expanded(child: _carteStat('En cours', '$enCours', Icons.timelapse, vertDassa)),
              const SizedBox(width: 10),
              Expanded(child: _carteStat('Terminées', '$terminees', Icons.task_alt, vertDassa)),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _aller(3),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.chat_bubble_outline, color: nonLus > 0 ? orangeDassa : vertDassa),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      nonLus > 0 ? '$nonLus conversation(s) avec un nouveau message' : 'Aucun nouveau message',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: grisTexte),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              const Expanded(
                child: Text('Conversations récentes',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              ),
              TextButton(onPressed: () => _aller(1), child: const Text('Tout voir')),
            ],
          ),
          if (recentes.isEmpty)
            _videListe(Icons.inbox_outlined, 'Aucune commande pour le moment',
                'Les demandes de vos clients apparaîtront ici.')
          else
            ...recentes.take(4).map(_carteCommande),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _ajouterPhoto,
                  icon: const Icon(Icons.add_a_photo_outlined, color: vertDassa),
                  label: const Text('Photo', style: TextStyle(color: vertDassa)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _modifierPrix(moi?.prixBase ?? 0),
                  icon: const Icon(Icons.sell_outlined),
                  label: const Text('Prix'),
                  style: ElevatedButton.styleFrom(backgroundColor: vertDassa, foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pageCommandes() {
    final toutes = ref.watch(commandesMoiProvider).valueOrNull ?? const <CommandeLocale>[];
    final filtrees = toutes.where((c) {
      if (_filtre == 'toutes') return true;
      if (_filtre == 'en_cours') return c.statut == 'en_cours' || c.statut == 'ecoutee';
      return c.statut == _filtre;
    }).toList();
    const filtres = <String, String>{
      'toutes': 'Toutes',
      'nouvelle': 'Nouvelles',
      'en_cours': 'En cours',
      'livree': 'Terminées',
      'refusee': 'Refusées',
    };
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            children: [
              for (final e in filtres.entries)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(e.value),
                    selected: _filtre == e.key,
                    selectedColor: vertDassa.withValues(alpha: 0.2),
                    onSelected: (_) => setState(() => _filtre = e.key),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: filtrees.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: _videListe(Icons.receipt_long, 'Aucune commande ici',
                      'Les commandes correspondant à ce filtre apparaîtront ici.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: filtrees.length,
                  itemBuilder: (context, i) => _carteCommande(filtrees[i]),
                ),
        ),
      ],
    );
  }

  Widget _pageMessages() => const ListeConversations(role: 'prestataire');

  Widget _pageBoutique(PrestataireLocal? moi) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ma boutique',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: vertDassa)),
          const SizedBox(height: 16),
          Center(child: _avatar(56, moi)),
          const SizedBox(height: 16),
          _bandeauStatut(moi?.statut),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                _ligneInfo('Prix de base', formatFcfa(moi?.prixBase ?? 0)),
                const Divider(height: 1),
                _ligneInfo('Métier', moi?.categorie ?? '—'),
                const Divider(height: 1),
                _ligneInfo('Quartier', moi?.quartier ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _ajouterPhoto,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Ajouter une photo'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _modifierPrix(moi?.prixBase ?? 0),
            icon: const Icon(Icons.sell_outlined),
            label: const Text('Modifier le prix de base'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _ouvrirFiche,
            icon: const Icon(Icons.badge_outlined),
            label: const Text('Modifier ma fiche'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: vertDassa,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageProfil(PrestataireLocal? moi) {
    final p = _presentationStatut(moi?.statut);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _avatar(44, moi),
          const SizedBox(height: 12),
          Text(moi?.nom ?? 'Mon profil',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: noirTexte)),
          const SizedBox(height: 4),
          Text(moi == null ? 'Prestataire' : '${moi.categorie} • ${moi.quartier}',
              style: const TextStyle(color: grisTexte)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _ligneInfo('Téléphone', moi?.telephone ?? '—'),
                const Divider(height: 1),
                _ligneInfo('Métier', moi?.categorie ?? '—'),
                const Divider(height: 1),
                _ligneInfo('Quartier', moi?.quartier ?? '—'),
                const Divider(height: 1),
                _ligneInfo('Prix de base', formatFcfa(moi?.prixBase ?? 0)),
                const Divider(height: 1),
                _ligneInfo('Statut', p.libelle),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _ouvrirFiche,
              icon: const Icon(Icons.edit),
              label: const Text('Modifier ma fiche'),
              style: ElevatedButton.styleFrom(
                backgroundColor: vertDassa,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _seDeconnecter,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Se déconnecter', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moi = ref.watch(monPrestataireProvider).valueOrNull;
    final nouvelles = ref.watch(nouvellesCommandesProvider).valueOrNull ?? 0;
    final nonLus = ref.watch(messagesNonLusProvider('prestataire')).valueOrNull ?? 0;

    // Notifications : alerte seulement lors d'une augmentation réelle, pas au premier chargement.
    ref.listen<AsyncValue<int>>(nouvellesCommandesProvider, (prev, next) {
      if (prev == null || !prev.hasValue) return;
      if ((next.valueOrNull ?? 0) > (prev.valueOrNull ?? 0)) _alerte('Nouvelle commande reçue', 1);
    });
    ref.listen<AsyncValue<int>>(messagesNonLusProvider('prestataire'), (prev, next) {
      if (prev == null || !prev.hasValue) return;
      if ((next.valueOrNull ?? 0) > (prev.valueOrNull ?? 0)) _alerte('Nouveau message d’un client', 3);
    });

    final pages = <Widget>[
      _pageAccueil(moi),
      _pageCommandes(),
      _pageBoutique(moi),
      _pageMessages(),
      _pageProfil(moi),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Scaffold(
          appBar: AppBar(
            title: Text(moi?.nom ?? 'Dassa Connect'),
            backgroundColor: vertDassa,
            foregroundColor: Colors.white,
            actions: [
              IconButton(icon: const Icon(Icons.logout), tooltip: 'Se déconnecter', onPressed: _seDeconnecter),
            ],
          ),
          body: Column(
            children: [
              const BandeauConnexion(compact: true),
              Expanded(child: pages[_index]),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _index,
            onTap: _aller,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: vertDassa,
            unselectedItemColor: Colors.grey,
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Accueil'),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: nouvelles > 0,
                  label: Text('$nouvelles'),
                  child: const Icon(Icons.receipt_long_outlined),
                ),
                label: 'Commandes',
              ),
              const BottomNavigationBarItem(icon: Icon(Icons.store_outlined), label: 'Boutique'),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: nonLus > 0,
                  label: Text('$nonLus'),
                  child: const Icon(Icons.chat_bubble_outline),
                ),
                label: 'Messages',
              ),
              const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }
}
