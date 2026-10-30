import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dassa_connect/data/base.dart';
import 'package:dassa_connect/data/depot.dart';

void main() {
  late AppDatabase db;
  late Depot depot;

  setUp(() {
    // Base en mémoire : chaque test repart d’une base vide.
    db = AppDatabase(NativeDatabase.memory());
    depot = Depot(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('une commande hors ligne est enregistrée et mise en file', () async {
    final uid = await depot.creerCommande(clientTelephone: '22997000000', prestataireUid: 'p1', message: 'Porte 2 m');

    final commandes = await db.select(db.commandes).get();
    expect(commandes.length, 1);
    expect(commandes.first.uid, uid);

    final file = await depot.lireActives();
    expect(file.length, 1);
    expect(file.first.tableCible, 'commandes');
    expect(file.first.action, 'insert');
  });

  test('un changement de statut est aussi mis en file', () async {
    final uid = await depot.creerCommande(clientTelephone: '22997000000', prestataireUid: 'p1');

    await depot.changerStatutCommande(uid, 'livree');

    final commandes = await db.select(db.commandes).get();
    expect(commandes.first.statut, 'livree');
    expect((await depot.lireActives()).length, 2);
  });

  test('après cinq échecs, une opération sort de la file active', () async {
    await depot.creerRecherche('/tmp/vocal.m4a');
    for (var i = 0; i < seuilEchecs; i++) {
      final operation = (await depot.lireActives()).first;
      await depot.noterEchec(operation);
    }
    expect(await depot.lireActives(), isEmpty);
  });
}
