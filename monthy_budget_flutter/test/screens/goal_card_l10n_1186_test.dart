import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations_en.dart';

void main() {
  late SEn en;
  setUpAll(() { en = SEn(); });

  group('goal_card l10n keys (#1186)', () {
    test('paused semantic label is EN not PT', () {
      expect(en.goalCardPausedSemanticLabel, contains('Paused'));
      expect(en.goalCardPausedSemanticLabel, isNot(contains('pausa')));
    });
  });
}
