import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations_en.dart';

void main() {
  late SEn en;
  setUpAll(() { en = SEn(); });
  tearDownAll(() {});

  group('tax_simulator_screen l10n keys (#1176)', () {
    test('taxSimSimulationEyebrow is EN not PT', () {
      expect(en.taxSimSimulationEyebrow, isNotNull);
      expect(en.taxSimSimulationEyebrow, isNot(contains('SIMULAÇÃO')));
    });
  });
}
