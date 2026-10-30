import 'package:flutter_test/flutter_test.dart';

import 'package:dassa_connect/sync/politique.dart';

void main() {
  final maintenant = DateTime.utc(2026, 10, 23, 12, 0);

  test('sans synchronisation précédente, la synchronisation automatique est autorisée', () {
    expect(peutSynchroniserApres(null, maintenant), isTrue);
  });

  test('avant 15 minutes, la synchronisation automatique est refusée', () {
    final derniere = maintenant.subtract(const Duration(minutes: 14));
    expect(peutSynchroniserApres(derniere, maintenant), isFalse);
  });

  test('à partir de 15 minutes, la synchronisation automatique est autorisée', () {
    final derniere = maintenant.subtract(const Duration(minutes: 15));
    expect(peutSynchroniserApres(derniere, maintenant), isTrue);
  });
}
