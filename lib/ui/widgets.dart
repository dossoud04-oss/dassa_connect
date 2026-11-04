import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme.dart';
import '../utils.dart';

class LogoDassa extends StatelessWidget {
  final double taille;
  const LogoDassa({super.key, this.taille = 40});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: taille,
          height: taille,
          decoration: BoxDecoration(
            color: vertDassa,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: vertDassa.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'DC',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: taille * 0.38,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'DASSA CONNECT',
          style: TextStyle(
            fontSize: taille * 0.42,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: vertDassa,
          ),
        ),
      ],
    );
  }
}

class Clavier extends StatelessWidget {
  final Function(String) onChiffre;
  final VoidCallback onEffacer;
  const Clavier({super.key, required this.onChiffre, required this.onEffacer});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', 'del']
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var key in row)
                if (key.isEmpty)
                  const SizedBox(width: 80, height: 70)
                else
                  InkWell(
                    onTap: () => key == 'del' ? onEffacer() : onChiffre(key),
                    borderRadius: BorderRadius.circular(35),
                    child: Container(
                      width: 80,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE9D5FF), width: 1.5),
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: key == 'del'
                          ? const Icon(Icons.backspace_outlined, size: 24, color: grisTexte)
                          : Text(
                              key,
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: noirTexte),
                            ),
                    ),
                  ),
            ],
          ),
      ],
    );
  }
}

class MicroVocal extends StatelessWidget {
  final dynamic voix;
  final VoidCallback? onChange;
  final bool enCours;
  final VoidCallback? onPressed;

  const MicroVocal({
    super.key,
    this.voix,
    this.onChange,
    this.enCours = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: enCours ? Colors.red : orangeDassa,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (enCours ? Colors.red : orangeDassa).withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          enCours ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

class BulleVocale extends StatelessWidget {
  final dynamic source;
  final dynamic duree;

  const BulleVocale({super.key, this.source, this.duree});

  @override
  Widget build(BuildContext context) {
    final secondes = (duree is int) ? duree as int : 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: purpleLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: vertDassa.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_circle_fill, color: vertDassa, size: 28),
          const SizedBox(width: 8),
          Text(
            formatDuree(secondes),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: vertDassa,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.graphic_eq, color: vertDassa.withValues(alpha: 0.6), size: 18),
        ],
      ),
    );
  }
}

class CartePrestataire extends StatelessWidget {
  final String? nom;
  final String? quartier;
  final int? prix;
  final VoidCallback? onTap;
  final dynamic p;
  final String? uid;
  final String? categorie;

  const CartePrestataire({
    super.key,
    this.nom,
    this.quartier,
    this.prix,
    this.onTap,
    this.p,
    this.uid,
    this.categorie,
  });

  @override
  Widget build(BuildContext context) {
    final titre = nom ?? (p != null ? (p.nom as String?) : null) ?? 'Prestataire';
    final lieu = quartier ?? (p != null ? (p.quartier as String?) : null) ?? '';
    final montant = prix ?? (p != null ? (p.prixBase as int?) : null) ?? 0;
    final cat = categorie ?? (p != null ? (p.categorie as String?) : null) ?? '';

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: purpleLight,
                child: Text(
                  initiales(titre),
                  style: const TextStyle(
                    color: vertDassa,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: noirTexte,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (cat.isNotEmpty || lieu.isNotEmpty)
                      Text(
                        [if (cat.isNotEmpty) cat, if (lieu.isNotEmpty) lieu].join(' · '),
                        style: const TextStyle(color: grisTexte, fontSize: 13),
                      ),
                    if (montant > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        formatFcfa(montant),
                        style: const TextStyle(
                          color: vertDassa,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: purpleLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Contacter',
                  style: TextStyle(
                    color: vertDassa,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Bandeau visible sur tous les écrans : Mode Avion / En ligne
class BandeauConnexion extends ConsumerWidget {
  final bool compact;
  const BandeauConnexion({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineAsync = ref.watch(isOnlineProvider);
    // Pendant le chargement, on affiche "En ligne" (évite le faux Mode Avion)
    final isOnline = onlineAsync.when(
      data: (v) => v,
      loading: () => true,
      error: (_, __) => true,
    );

    return Container(
      width: double.infinity,
      margin: compact ? EdgeInsets.zero : const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: compact ? 8 : 12),
      decoration: BoxDecoration(
        color: isOnline ? const Color(0xFF16A34A) : orangeDassa,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(isOnline ? Icons.wifi : Icons.airplanemode_active, color: Colors.white, size: compact ? 18 : 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isOnline ? 'En ligne' : 'Mode Avion',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: compact ? 13 : 15),
                ),
                if (!compact)
                  Text(
                    isOnline
                        ? 'Connexion active • Sync en arrière-plan'
                        : 'Hors ligne • Validation locale active',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
