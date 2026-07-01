// TDD for issue #1166 — expense_search_view l10n
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations_en.dart';

void main() {
  late SEn en;

  setUpAll(() {
    en = SEn();
  });

  tearDownAll(() {});

  test('searchEmptyTitle exists and is not hardcoded PT', () {
    expect(en.searchEmptyTitle, isNotNull);
    expect(en.searchEmptyTitle, isNot('Nada encontrado'));
  });
}
