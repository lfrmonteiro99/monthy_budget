import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';

void main() {
  late S l10n;

  setUpAll(() async {
    l10n = await S.delegate.load(const Locale('en'));
  });

  group('grocery_screen l10n #1153', () {
    test('groceryItemCountEyebrow contains count and is not hardcoded PT', () {
      final value = l10n.groceryItemCountEyebrow(7);
      expect(value, contains('7'));
      expect(value.toUpperCase(), isNot(contains('ITENS')));
    });

    test('groceryPantryTitle exists and is not hardcoded PT', () {
      final value = l10n.groceryPantryTitle;
      expect(value, isNotEmpty);
      expect(value.toLowerCase(), isNot(equals('despensa')));
    });

    test('groceryStorePartialCount contains count', () {
      final value = l10n.groceryStorePartialCount(3);
      expect(value, contains('3'));
    });

    test('groceryStoreFailedCount contains count', () {
      final value = l10n.groceryStoreFailedCount(2);
      expect(value, contains('2'));
    });
  });
}
