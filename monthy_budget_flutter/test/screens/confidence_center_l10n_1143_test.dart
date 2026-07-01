import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';

void main() {
  group('#1143 confidence_center_screen — l10n keys', () {
    late S l10n;

    setUpAll(() async {
      l10n = await S.delegate.load(const Locale('en'));
    });

    test('alertSeverityCritical non-empty, not hardcoded PT', () {
      expect(l10n.alertSeverityCritical, isNotEmpty);
      expect(l10n.alertSeverityCritical, isNot('crítico'));
    });

    test('alertSeverityWarning non-empty, not hardcoded PT', () {
      expect(l10n.alertSeverityWarning, isNotEmpty);
      expect(l10n.alertSeverityWarning, isNot('aviso'));
    });

    test('alertSeverityInfo non-empty', () {
      expect(l10n.alertSeverityInfo, isNotEmpty);
    });

    test('criticalAlertBannerMessage singular contains count', () {
      final result = l10n.criticalAlertBannerMessage(1);
      expect(result, isNotEmpty);
      expect(result, contains('1'));
    });

    test('criticalAlertBannerMessage plural contains count', () {
      final result = l10n.criticalAlertBannerMessage(3);
      expect(result, isNotEmpty);
      expect(result, contains('3'));
    });

    test('criticalAlertBannerMessage singular and plural differ', () {
      expect(
        l10n.criticalAlertBannerMessage(1),
        isNot(l10n.criticalAlertBannerMessage(3)),
      );
    });
  });
}
