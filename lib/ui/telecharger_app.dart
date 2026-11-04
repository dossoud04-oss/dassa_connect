import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

/// Lien de l'APK Android.
/// - Nom de fichier simple (ex. 'dassa_connect.apk') : le fichier est placé dans le dossier web/ du projet.
/// - Ou URL complète (GitHub Releases, Supabase Storage...) : 'https://.../dassa_connect.apk'
const String lienApkAndroid = 'dassa_connect.apk';

/// Visible uniquement dans la version web : propose d'installer l'appli mobile.
class BoutonTelechargerApp extends StatelessWidget {
  const BoutonTelechargerApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();

    // iPhone : pas d'APK possible, on propose l'ajout à l'écran d'accueil.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          'Sur iPhone : touchez Partager puis « Sur l’écran d’accueil » pour installer l’application.',
          textAlign: TextAlign.center,
          style: TextStyle(color: grisTexte, fontSize: 13),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.download, color: vertDassa),
          label: const Text('Télécharger l’application Android'),
          onPressed: () => launchUrl(
            Uri.base.resolve(lienApkAndroid),
            webOnlyWindowName: '_self',
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Fonctionne aussi sans internet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: grisTexte, fontSize: 12),
        ),
      ],
    );
  }
}
