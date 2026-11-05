import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../data/images.dart';
import '../providers.dart';
import '../theme.dart';
import 'connexion.dart';
import 'photo.dart';

/// Profil client : numéro pour suivre les commandes, photo facultative, à propos.
class ProfilClientPage extends ConsumerWidget {
  const ProfilClientPage({super.key});

  Future<void> _changerPhoto(BuildContext context, WidgetRef ref) async {
    final depot = ref.read(depotProvider);
    final picker = ImagePicker();
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: vertDassa),
              title: const Text('Prendre une photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final img = await picker.pickImage(
                    source: ImageSource.camera, maxWidth: 400, maxHeight: 400, imageQuality: 70);
                if (img != null) await depot.ecrireEtat('photo_client', versDataUrl(await img.readAsBytes()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: vertDassa),
              title: const Text('Choisir dans la galerie'),
              onTap: () async {
                Navigator.pop(ctx);
                final img = await picker.pickImage(
                    source: ImageSource.gallery, maxWidth: 400, maxHeight: 400, imageQuality: 70);
                if (img != null) await depot.ecrireEtat('photo_client', versDataUrl(await img.readAsBytes()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Supprimer la photo'),
              onTap: () async {
                Navigator.pop(ctx);
                await depot.supprimerEtat('photo_client');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _modifierNumero(BuildContext context, WidgetRef ref, String? actuel) async {
    final depot = ref.read(depotProvider);
    final ctrl = TextEditingController(text: actuel == null ? '' : actuel.replaceFirst('+229', ''));
    final saisie = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mon numéro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Les prestataires vous répondent sur ce numéro. Facultatif.',
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
          ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Enregistrer')),
        ],
      ),
    );
    if (saisie == null) return;
    final chiffres = saisie.replaceAll(RegExp(r'[^0-9]'), '');
    if (chiffres.isEmpty) {
      await depot.supprimerEtat('client_telephone');
    } else if (chiffres.length < 8) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Numéro invalide (8 chiffres minimum).')));
      }
    } else {
      await depot.ecrireEtat('client_telephone', chiffres.startsWith('229') ? '+$chiffres' : '+229$chiffres');
    }
  }

  Widget _section(String titre, List<Widget> lignes) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(titre,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: vertDassa)),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                for (var i = 0; i < lignes.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 56),
                  lignes[i],
                ],
              ],
            ),
          ),
        ],
      );

  Widget _tuile(IconData icone, String titre, String sous, VoidCallback? onTap) => ListTile(
        leading: Icon(icone, color: vertDassa),
        title: Text(titre, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(sous, style: const TextStyle(fontSize: 12, color: grisTexte)),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right, color: grisTexte),
        onTap: onTap,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final depot = ref.watch(depotProvider);
    return Scaffold(
      backgroundColor: grisFond,
      body: SafeArea(
        child: StreamBuilder<String?>(
          stream: depot.surveillerEtat('photo_client'),
          builder: (context, snapPhoto) => StreamBuilder<String?>(
            stream: depot.surveillerEtat('client_telephone'),
            builder: (context, snapTel) {
              final photo = snapPhoto.data;
              final tel = snapTel.data;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => _changerPhoto(context, ref),
                          child: Stack(
                            children: [
                              Avatar(initiales: 'C', photo: photo, rayon: 46),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(color: vertDassa, shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('Mon profil',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: noirTexte)),
                        const SizedBox(height: 2),
                        Text(tel ?? 'Aucun numéro enregistré', style: const TextStyle(color: grisTexte)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _section('Mon compte', [
                    _tuile(
                      Icons.phone_iphone,
                      'Mon numéro',
                      tel == null ? 'Ajouter pour suivre mes commandes' : 'Utilisé pour vos commandes',
                      () => _modifierNumero(context, ref, tel),
                    ),
                    _tuile(
                      Icons.photo_camera_outlined,
                      'Photo de profil',
                      photo == null ? 'Facultatif' : 'Modifier ou supprimer',
                      () => _changerPhoto(context, ref),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _section('À propos', [
                    _tuile(Icons.info_outline, 'Dassa Connect', 'Trouver un prestataire près de vous', null),
                  ]),
                  const SizedBox(height: 22),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(builder: (_) => const ConnexionPage()),
                      (route) => false,
                    ),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Retour à l’accueil'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
