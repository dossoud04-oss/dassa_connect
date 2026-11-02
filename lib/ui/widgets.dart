import 'package:flutter/material.dart';
import '../theme.dart';

class LogoDassa extends StatelessWidget {
  final double taille;
  const LogoDassa({super.key, this.taille = 40});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: taille, height: taille,
          decoration: const BoxDecoration(color: vertDassa, shape: BoxShape.circle),
          child: Center(child: Text('DC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: taille * 0.4))),
        ),
        const SizedBox(width: 10),
        Text('DASSA CONNECT', style: TextStyle(fontSize: taille * 0.45, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
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
        for (var row in [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9'], ['', '0', 'del']])
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
                      width: 80, height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 1.5),
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: key == 'del' 
                        ? const Icon(Icons.backspace_outlined, size: 24, color: Colors.grey) 
                        : Text(key, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),
                    ),
                  ),
            ],
          ),
      ],
    );
  }
}

// Classes vides ou simplifiées pour que les anciens fichiers ne plantent pas
class MicroVocal extends StatelessWidget {
  final dynamic voix;
  final VoidCallback? onChange;
  const MicroVocal({super.key, this.voix, this.onChange});
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class BulleVocale extends StatelessWidget {
  final dynamic source;
  final dynamic duree;
  const BulleVocale({super.key, this.source, this.duree});
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class CartePrestataire extends StatelessWidget {
  final String? nom; final String? quartier; final int? prix; final VoidCallback? onTap;
  final dynamic p; final String? uid;
  const CartePrestataire({super.key, this.nom, this.quartier, this.prix, this.onTap, this.p, this.uid});
  @override
  Widget build(BuildContext context) { return const SizedBox(); }
}
