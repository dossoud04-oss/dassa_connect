import 'dart:convert';
import 'dart:typed_data';

/// Photo stockée en texte (data URL) tant qu'elle n'est pas envoyée au serveur.
String versDataUrl(Uint8List octets) => 'data:image/jpeg;base64,${base64Encode(octets)}';

bool estDataUrl(String source) => source.startsWith('data:');

/// Octets d'une data URL (ou d'une chaîne base64 nue).
Uint8List decoderDataUrl(String source) {
  final virgule = source.indexOf(',');
  return base64Decode(virgule < 0 ? source : source.substring(virgule + 1));
}
