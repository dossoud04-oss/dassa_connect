import 'package:flutter/material.dart';
import '../theme.dart';

class EspacePage extends StatelessWidget {
  const EspacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Espace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prestataire Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: vertDassa),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _carteStat('Vues', '152', Icons.visibility)),
                const SizedBox(width: 12),
                Expanded(child: _carteStat('Commandes', '12', Icons.receipt_long)),
                const SizedBox(width: 12),
                Expanded(child: _carteStat('Revenu', '8 450', Icons.monetization_on)),
              ],
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Icon(Icons.mic, color: vertDassa),
                SizedBox(width: 8),
                Text('Commandes vocales entrantes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            _carteCommande('Commande #1021', 'Légumes & Riz • Il y a 5 min', '0:18'),
            _carteCommande('Commande #1020', 'Poulet Yassa • Il y a 12 min', '0:24'),
            _carteCommande('Commande #1019', 'Thieboudienne • Il y a 27 min', '0:30'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt, color: vertDassa),
                    label: const Text('Ajouter photo', style: TextStyle(color: vertDassa)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifier prix'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vertDassa,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.store, color: vertDassa),
                          SizedBox(width: 8),
                          Text('Ma boutique', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: vertDassa,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Approuvé', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text('Statut : Approuvé • Vérifié', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ouverte • Répond en 10 min • Dernière mise à jour aujourd\'hui',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _carteStat(String titre, String valeur, IconData icone) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // CORRECTION ICI : withValues à la place de withOpacity
        color: vertDassa.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icone, color: vertDassa),
          const SizedBox(height: 8),
          Text(titre, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(valeur, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: vertDassa)),
        ],
      ),
    );
  }

  Widget _carteCommande(String titre, String description, String duree) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          // CORRECTION ICI : withValues à la place de withOpacity
          decoration: BoxDecoration(color: vertDassa.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.play_arrow, color: vertDassa),
        ),
        title: Text(titre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: Text('Audio • $duree', style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ),
    );
  }
}
