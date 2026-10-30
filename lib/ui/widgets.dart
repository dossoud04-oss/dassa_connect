import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../data/base.dart';
import '../services/voix.dart';
import '../theme.dart';
import '../utils.dart';

List<String> photosDe(PrestataireLocal p) => (jsonDecode(p.photos) as List).cast<String>();

List<String> tarifsDe(PrestataireLocal p) => (jsonDecode(p.tarifs) as List).cast<String>();

/// Logo officiel Dassa Connect, tel que fourni dans la charte graphique (assets/logo.png).
class LogoDassa extends StatelessWidget {
  const LogoDassa({super.key, this.taille = 40});

  final double taille;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      height: taille,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Text(
        'Dassa Connect',
        style: TextStyle(color: vertBenin, fontWeight: FontWeight.bold, fontSize: taille * 0.5),
      ),
    );
  }
}

/// Bandeau coloré : mode avion, synchronisation, information.
Widget bandeau(Color couleur, IconData icone, String texte, {Color couleurTexte = Colors.white}) {
  return Container(
    width: double.infinity,
    color: couleur,
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        Icon(icone, color: couleurTexte, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Text(texte, style: TextStyle(color: couleurTexte, fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}

/// Bulle vocale façon messagerie : gros bouton lecture, ondes qui se colorent pendant l’écoute, durée.
/// La lecture d’un fichier distant n’est possible qu’avec internet.
class BulleVocale extends StatefulWidget {
  const BulleVocale({super.key, required this.source, required this.duree, this.couleur = vertBenin});

  /// Chemin local ou adresse publique du fichier audio.
  final String source;

  /// Durée en secondes.
  final int duree;

  final Color couleur;

  @override
  State<BulleVocale> createState() => _BulleVocaleState();
}

class _BulleVocaleState extends State<BulleVocale> {
  final AudioPlayer _lecteur = AudioPlayer();
  bool _pret = false;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      if (widget.source.startsWith('http')) {
        await _lecteur.setUrl(widget.source);
      } else {
        await _lecteur.setFilePath(widget.source);
      }
      if (mounted) setState(() => _pret = true);
    } catch (_) {
      // Fichier absent ou hors connexion : la bulle reste affichée, sans lecture.
    }
  }

  @override
  void dispose() {
    _lecteur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFF1F8F5), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          StreamBuilder<PlayerState>(
            stream: _lecteur.playerStateStream,
            builder: (context, instantane) {
              final joue = instantane.data?.playing ?? false;
              return IconButton.filled(
                iconSize: 36,
                style: IconButton.styleFrom(backgroundColor: widget.couleur, minimumSize: const Size(60, 60)),
                onPressed: !_pret ? null : () => joue ? _lecteur.pause() : _lecteur.play(),
                icon: Icon(joue ? Icons.pause : Icons.play_arrow, color: Colors.white),
              );
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StreamBuilder<Duration>(
              stream: _lecteur.positionStream,
              builder: (context, instantane) {
                final total = widget.duree <= 0 ? 1 : widget.duree;
                final position = instantane.data?.inSeconds ?? 0;
                final progression = (position / total).clamp(0.0, 1.0).toDouble();
                return CustomPaint(
                  size: const Size(double.infinity, 40),
                  painter: _OndesPainter(progression, widget.couleur),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Text(formatDuree(widget.duree), style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          const Icon(Icons.mic, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}

/// Dessine 28 barres verticales ; celles déjà écoutées prennent la couleur de la bulle.
class _OndesPainter extends CustomPainter {
  _OndesPainter(this.progression, this.couleur);

  final double progression;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    const nombre = 28;
    final pas = size.width / nombre;
    for (var i = 0; i < nombre; i++) {
      final hauteur = 8 + (math.sin(i * 1.3) * math.cos(i * 0.6) + 1) * 9;
      final ecoute = i / nombre <= progression;
      final trait = Paint()
        ..color = ecoute ? couleur : Colors.grey.shade400
        ..strokeWidth = pas * 0.5
        ..strokeCap = StrokeCap.round;
      final x = i * pas + pas / 2;
      canvas.drawLine(
        Offset(x, size.height / 2 - hauteur / 2),
        Offset(x, size.height / 2 + hauteur / 2),
        trait,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OndesPainter ancien) => ancien.progression != progression;
}

/// Micro façon messagerie : maintenir pour enregistrer, relâcher pour arrêter. 60 secondes maximum.
class MicroVocal extends StatefulWidget {
  const MicroVocal({super.key, required this.voix, required this.onChange});

  final VoiceService voix;

  /// Appelé avec le chemin temporaire (ou null après suppression) et la durée en secondes.
  final void Function(String? chemin, int duree) onChange;

  @override
  State<MicroVocal> createState() => _MicroVocalState();
}

class _MicroVocalState extends State<MicroVocal> with SingleTickerProviderStateMixin {
  bool _enCours = false;
  int _secondes = 0;
  String? _chemin;
  Timer? _minuteur;

  late final AnimationController _pulsation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _minuteur?.cancel();
    _pulsation.dispose();
    super.dispose();
  }

  Future<void> _commencer() async {
    final autorise = await widget.voix.demarrer();
    if (!mounted) return;
    if (!autorise) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Autorisez le micro dans les réglages du téléphone.')),
      );
      return;
    }
    setState(() {
      _enCours = true;
      _secondes = 0;
      _chemin = null;
    });
    _minuteur = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondes++);
      if (_secondes >= 60) _terminer();
    });
  }

  Future<void> _terminer() async {
    if (!_enCours) return;
    _minuteur?.cancel();
    final chemin = await widget.voix.arreter();
    if (!mounted) return;
    setState(() {
      _enCours = false;
      _chemin = chemin;
    });
    widget.onChange(chemin, _secondes);
  }

  void _supprimer() {
    setState(() {
      _chemin = null;
      _secondes = 0;
    });
    widget.onChange(null, 0);
  }

  @override
  Widget build(BuildContext context) {
    if (_chemin != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BulleVocale(source: _chemin!, duree: _secondes),
          TextButton.icon(
            onPressed: _supprimer,
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
            label: const Text('Supprimer', style: TextStyle(fontSize: 18, color: Colors.red)),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onLongPressStart: (_) => _commencer(),
          onLongPressEnd: (_) => _terminer(),
          child: AnimatedBuilder(
            animation: _pulsation,
            builder: (context, enfant) {
              final echelle = _enCours ? 1 + _pulsation.value * 0.25 : 1.0;
              return Transform.scale(scale: echelle, child: enfant);
            },
            child: Container(
              width: 120,
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _enCours ? Colors.red : orangeVocal,
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(blurRadius: 16, color: Colors.black26)],
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 60),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _enCours ? 'Enregistrement ${formatDuree(_secondes)} : relâchez pour arrêter' : 'Appuyez longtemps et parlez',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}

/// Carte d’un prestataire : photo ronde, nom, quartier, prix, badge hors ligne.
class CartePrestataire extends StatelessWidget {
  const CartePrestataire({super.key, required this.p, required this.onTap});

  final PrestataireLocal p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photos = photosDe(p);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0x1F006A4E),
                backgroundImage: photos.isNotEmpty ? CachedNetworkImageProvider(photos.first) : null,
                child: photos.isEmpty
                    ? Text(
                        initiales(p.nom),
                        style: const TextStyle(fontSize: 20, color: vertBenin, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.nom, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(p.quartier, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(
                      'À partir de ${formatFcfa(p.prixBase)}',
                      style: const TextStyle(fontSize: 16, color: vertBenin, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Chip(
                label: Text('Hors ligne', style: TextStyle(color: Colors.white)),
                backgroundColor: vertBenin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pavé numérique géant, utilisé pour le numéro, le code SMS et le code PIN.
class Clavier extends StatelessWidget {
  const Clavier({super.key, required this.onChiffre, required this.onEffacer});

  final void Function(String chiffre) onChiffre;
  final VoidCallback onEffacer;

  @override
  Widget build(BuildContext context) {
    const touches = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.6,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true,
      children: [
        for (final t in touches)
          t.isEmpty
              ? const SizedBox()
              : OutlinedButton(
                  onPressed: () {
                    if (t == '⌫') {
                      onEffacer();
                    } else {
                      onChiffre(t);
                    }
                  },
                  child: Text(t, style: const TextStyle(fontSize: 28)),
                ),
      ],
    );
  }
}
