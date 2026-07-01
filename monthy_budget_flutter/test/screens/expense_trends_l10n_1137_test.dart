import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';

void main() {
  group('#1137 expense_trends_screen — l10n keys', () {
    late S l10n;

    setUpAll(() async {
      l10n = await S.delegate.load(const Locale('en'));
    });

    test('expenseTrendsEyebrow is non-empty and not hardcoded PT', () {
      expect(l10n.expenseTrendsEyebrow, isNotEmpty);
      expect(l10n.expenseTrendsEyebrow, isNot('TENDÊNCIAS'));
    });

    test('expenseTrendsEmptyBody is non-empty and not hardcoded PT', () {
      expect(l10n.expenseTrendsEmptyBody, isNotEmpty);
      expect(l10n.expenseTrendsEmptyBody,
          isNot('Adiciona despesas para ver as tendências.'));
    });

    test('expenseTrendsMonthlyHistoryEyebrow is non-empty and not hardcoded PT',
        () {
      expect(l10n.expenseTrendsMonthlyHistoryEyebrow, isNotEmpty);
      expect(l10n.expenseTrendsMonthlyHistoryEyebrow, isNot('HISTÓRICO MENSAL'));
    });
  });
}
