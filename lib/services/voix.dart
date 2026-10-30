import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Enregistrement du micro et synthèse vocale.
class VoiceService {
  final AudioRecorder _enregistreur = AudioRecorder();
  final FlutterTts _voix = FlutterTts();

  /// Démarre l’enregistrement. Renvoie faux si l’autorisation du micro est refusée.
  Future<bool> demarrer() async {
    if (!await _enregistreur.hasPermission()) return false;
    final dossier = await getTemporaryDirectory();
    final chemin = '${dossier.path}/vocal_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _enregistreur.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: chemin);
    return true;
  }

  /// Arrête l’enregistrement et renvoie le chemin du fichier temporaire.
  Future<String?> arreter() => _enregistreur.stop();

  /// Copie un fichier (audio ou photo) dans le dossier de l’application.
  /// Il survit ainsi au nettoyage du cache, jusqu’à l’envoi à Supabase.
  Future<String> conserver(String cheminTemporaire) async {
    final dossier = await getApplicationDocumentsDirectory();
    final extension = cheminTemporaire.split('.').last;
    final destination = '${dossier.path}/${DateTime.now().millisecondsSinceEpoch}.$extension';
    await File(cheminTemporaire).copy(destination);
    return destination;
  }

  /// Lit un texte à voix haute en français.
  Future<void> parler(String texte) async {
    await _voix.setLanguage('fr-FR');
    await _voix.speak(texte);
  }

  Future<void> liberer() => _enregistreur.dispose();
}
