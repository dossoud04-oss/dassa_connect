import 'package:flutter/material.dart';
import '../theme.dart';

class CommandePage extends StatefulWidget {
  const CommandePage({super.key});

  @override
  State<CommandePage> createState() => _CommandePageState();
}

class _CommandePageState extends State<CommandePage> {
  bool _enEnregistrement = false;
  final TextEditingController _texteCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _texteCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dassa Connect'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(22),
          child: Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text('Écran 3 • Commande Vocale', style: TextStyle(color: grisTexte, fontSize: 13)),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text('Commande vocale pour tous', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: noirTexte)),
            const SizedBox(height: 6),
            const Text('Parlez simplement, on s\'occupe du reste', style: TextStyle(color: grisTexte, fontSize: 14)),
            const Spacer(flex: 2),
            // Gros micro
            GestureDetector(
              onTap: () => setState(() => _enEnregistrement = !_enEnregistrement),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: orangeDassa.withValues(alpha: 0.12),
                    ),
                  ),
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _enEnregistrement ? Colors.red : orangeDassa,
                      boxShadow: [
                        BoxShadow(
                          color: (_enEnregistrement ? Colors.red : orangeDassa).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      _enEnregistrement ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _enEnregistrement ? 'Écoute en cours...' : 'Appuyez et parlez',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: noirTexte),
            ),
            const Spacer(),
            // Exemple
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: grisTexte, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Exemple : "Je veux porte 2m pour samedi"', style: TextStyle(color: grisTexte, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('— ou —', style: TextStyle(color: grisTexte)),
            const SizedBox(height: 12),
            TextField(
              controller: _texteCtrl,
              decoration: InputDecoration(
                hintText: 'Ou écrivez votre commande...',
                prefixIcon: const Icon(Icons.edit, size: 20),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final phone = await showDialog<String>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Votre numéro'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Pour relier la commande au prestataire, indiquez votre numéro WhatsApp :', style: TextStyle(fontSize: 13)),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              prefixText: '+229 ',
                              hintText: '01 XX XX XX XX',
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, _phoneCtrl.text.trim()),
                          child: const Text('Envoyer'),
                        ),
                      ],
                    ),
                  );
                  if (phone == null || phone.isEmpty) return;
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Commande envoyée depuis +229$phone'), backgroundColor: vertDassa),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeDassa,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Envoyer commande vocale', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Pill(Icons.volume_up, 'Simple'),
                _Pill(Icons.check_circle_outline, 'Rapide'),
                _Pill(Icons.shield_outlined, 'Sécurisé'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Pill(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: grisTexte),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: grisTexte)),
        ],
      ),
    );
  }
}
