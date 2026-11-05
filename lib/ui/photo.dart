import 'package:flutter/material.dart';

import '../data/images.dart';
import '../theme.dart';

/// Image d'un prestataire ou d'un client : adresse du serveur, ou photo locale (data URL).
ImageProvider? imageDe(String? source) {
  if (source == null || source.isEmpty) return null;
  if (estDataUrl(source)) return MemoryImage(decoderDataUrl(source));
  return NetworkImage(source);
}

/// Avatar rond : la photo si elle existe, sinon les initiales.
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.initiales, this.photo, this.rayon = 24});

  final String initiales;
  final String? photo;
  final double rayon;

  @override
  Widget build(BuildContext context) {
    final image = imageDe(photo);
    return CircleAvatar(
      radius: rayon,
      backgroundColor: vertClair,
      backgroundImage: image,
      onBackgroundImageError: image == null ? null : (_, __) {},
      child: image == null
          ? Text(
              initiales,
              style: TextStyle(color: vertDassa, fontWeight: FontWeight.w700, fontSize: rayon * 0.7),
            )
          : null,
    );
  }
}
