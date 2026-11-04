import 'package:flutter/material.dart';
import '../theme.dart';

class EspacePage extends StatelessWidget {
  const EspacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vertHeader,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Dassa Connect',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, bottom: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Prestataire Dashboard', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ),
            ),
            // Corps blanc arrondi
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats
                      Row(
                        children: [
                          Expanded(child: _statCard(Icons.visibility_outlined, 'Vues', '152')),
                          const SizedBox(width: 10),
                          Expanded(child: _statCard(Icons.assignment_outlined, 'Commandes', '12')),
                          const SizedBox(width: 10),
                          Expanded(child: _statCard(Icons.account_balance_wallet_outlined, 'Revenue', '8 450 FCFA')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Commandes vocales
                      const Row(
                        children: [
                          Icon(Icons.mic, color: vertDassa, size: 22),
                          SizedBox(width: 8),
                          Text('Commandes vocales entrantes', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: vertDassa)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _commandeCard('AM', 'Commande #1021', 'Légumes & Riz • Il y a 5 min', '0:18'),
                      _commandeCard('KD', 'Commande #1020', 'Poulet Yassa • Il y a 12 min', '0:24'),
                      _commandeCard('SL', 'Commande #1019', 'Thieboudienne • Il y a 27 min', '0:30'),
                      const SizedBox(height: 16),
                      // Boutons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.camera_alt_outlined, size: 18),
                              label: const Text('Ajouter photo'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: vertDassa,
                                side: const BorderSide(color: vertDassa),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Modifier prix'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: vertDassa,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Ma boutique
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: vertClair,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.storefront, color: vertDassa),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text('Ma boutique', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: vertDassa)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, color: vertDassa, size: 16),
                                      SizedBox(width: 4),
                                      Text('Approuvé', style: TextStyle(color: vertDassa, fontWeight: FontWeight.w700, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text('Statut : Approuvé • Vérifié', style: TextStyle(color: vertDassa, fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 4),
                            const Text('Ouverte • Répond en 10 min • Dernière mise à jour aujourd\'hui', style: TextStyle(color: grisTexte, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: vertClair,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: vertDassa, size: 26),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: grisTexte)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: vertDassa)),
        ],
      ),
    );
  }

  Widget _commandeCard(String initials, String title, String subtitle, String duree) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: vertClair,
            child: Text(initials, style: const TextStyle(color: vertDassa, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: grisTexte, fontSize: 12)),
              ],
            ),
          ),
          Column(
            children: [
              const Icon(Icons.play_circle_fill, color: vertDassa, size: 32),
              Text('Audio • $duree', style: const TextStyle(fontSize: 10, color: grisTexte)),
            ],
          ),
        ],
      ),
    );
  }
}
