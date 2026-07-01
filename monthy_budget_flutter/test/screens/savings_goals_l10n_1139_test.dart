import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';

void main() {
  group('#1139 savings_goals_screen — l10n keys', () {
    late S l10n;

    setUpAll(() async {
      l10n = await S.delegate.load(const Locale('en'));
    });

    test('savingsGoalsEyebrow is non-empty and not hardcoded PT', () {
      expect(l10n.savingsGoalsEyebrow, isNotEmpty);
      expect(l10n.savingsGoalsEyebrow, isNot('POUPANÇA'));
    });

    test('savingsGoalsSubtitleTarget contains the total placeholder value', () {
      final result = l10n.savingsGoalsSubtitleTarget('€1,000.00');
      expect(result, isNotEmpty);
      expect(result, contains('€1,000.00'));
      expect(result, isNot(contains('objetivo')));
    });

    test('savingsGoalsSubtitleActive contains the count value', () {
      final result = l10n.savingsGoalsSubtitleActive(3);
      expect(result, isNotEmpty);
      expect(result, contains('3'));
      expect(result, isNot(contains('metas')));
    });

    test('savingsGoalsPercentComplete contains the percent value', () {
      final result = l10n.savingsGoalsPercentComplete('42');
      expect(result, isNotEmpty);
      expect(result, contains('42'));
      expect(result, isNot(contains('concluído')));
    });

    test('savingsGoalsEmptyBody is non-empty and not hardcoded PT', () {
      expect(l10n.savingsGoalsEmptyBody, isNotEmpty);
      expect(l10n.savingsGoalsEmptyBody,
          isNot('Crie a sua primeira meta de poupança para começar.'));
    });
  });
}
