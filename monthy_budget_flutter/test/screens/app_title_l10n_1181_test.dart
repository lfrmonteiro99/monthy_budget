import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations_en.dart';
import 'package:monthly_management/l10n/generated/app_localizations_pt.dart';

void main() {
  group('app title l10n (#1181)', () {
    test('EN appTitle is not PT', () {
      final en = SEn();
      expect(en.appTitle, isNot(contains('Orçamento')));
      expect(en.appTitle, isNotEmpty);
    });

    test('PT appTitle is Portuguese', () {
      final pt = SPt();
      expect(pt.appTitle, contains('Orçamento'));
    });
  });
}
