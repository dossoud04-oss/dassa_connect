import 'package:flutter_test/flutter_test.dart';

import 'package:dassa_connect/utils.dart';

void main() {
  test('formatDuree affiche minutes et secondes', () {
    expect(formatDuree(18), '0:18');
    expect(formatDuree(65), '1:05');
  });

  test('formatFcfa sépare les milliers', () {
    expect(formatFcfa(25000), '25 000 FCFA');
    expect(formatFcfa(450), '450 FCFA');
  });

  test('initiales et numéro de téléphone', () {
    expect(initiales('Koffi Mensah'), 'KM');
    expect(chiffresSeulement('+229 97 00 00 00'), '22997000000');
  });

  test('le hash du PIN dépend du sel et du code', () {
    expect(hashPin('1234', 'sel'), hashPin('1234', 'sel'));
    expect(hashPin('1234', 'sel'), isNot(hashPin('1235', 'sel')));
    expect(hashPin('1234', 'sel'), isNot(hashPin('1234', 'autre')));
  });
}
