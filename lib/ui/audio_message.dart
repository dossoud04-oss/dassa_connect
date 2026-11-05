import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../theme.dart';
import '../utils.dart';

/// Message vocal façon WhatsApp : bouton lecture/pause, barre de progression et durée.
class AudioMessage extends StatefulWidget {
  const AudioMessage({super.key, required this.url, required this.duree, required this.moi});

  final String url;
  final int duree;

  /// true si le message vient de l'utilisateur courant.
  final bool moi;

  @override
  State<AudioMessage> createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage> {
  final AudioPlayer _lecteur = AudioPlayer();
  bool _pret = false;
  bool _erreur = false;
  int _dureeMs = 0;

  @override
  void initState() {
    super.initState();
    _preparer();
  }

  Future<void> _preparer() async {
    try {
      final duree = await _lecteur.setUrl(widget.url);
      if (!mounted) return;
      setState(() {
        _pret = true;
        _dureeMs = duree?.inMilliseconds ?? widget.duree * 1000;
      });
    } catch (_) {
      if (mounted) setState(() => _erreur = true);
    }
  }

  @override
  void dispose() {
    _lecteur.dispose();
    super.dispose();
  }

  Future<void> _basculer(PlayerState etat) async {
    if (!_pret) return;
    if (etat.playing) {
      await _lecteur.pause();
      return;
    }
    if (etat.processingState == ProcessingState.completed) {
      await _lecteur.seek(Duration.zero);
    }
    // Pas d'attente : play() ne se termine qu'à la fin du message.
    _lecteur.play();
  }

  @override
  Widget build(BuildContext context) {
    final couleurTexte = Colors.grey.shade700;
    return StreamBuilder<PlayerState>(
      stream: _lecteur.playerStateStream,
      builder: (context, snapEtat) {
        final etat = snapEtat.data ?? _lecteur.playerState;
        final joue = etat.playing && etat.processingState != ProcessingState.completed;
        return StreamBuilder<Duration>(
          stream: _lecteur.positionStream,
          builder: (context, snapPos) {
            final position = snapPos.data ?? Duration.zero;
            final total = _dureeMs > 0 ? _dureeMs : 1;
            final brut = position.inMilliseconds / total;
            final double progression = brut < 0 ? 0.0 : (brut > 1 ? 1.0 : brut);
            return SizedBox(
              width: 210,
              child: Row(
                children: [
                  InkWell(
                    onTap: (_erreur || !_pret) ? null : () => _basculer(etat),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(color: vertDassa, shape: BoxShape.circle),
                      child: Icon(
                        _erreur ? Icons.error_outline : (joue ? Icons.pause : Icons.play_arrow),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: _erreur ? 0.0 : progression,
                          minHeight: 3,
                          backgroundColor: Colors.grey.shade300,
                          color: vertDassa,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _erreur
                              ? 'Audio indisponible'
                              : formatDuree(joue ? position.inSeconds : widget.duree),
                          style: TextStyle(fontSize: 11, color: couleurTexte),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
