import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';

void main() {
  group('#1135 shopping_list_screen — l10n keys', () {
    late S l10n;

    setUpAll(() async {
      l10n = await S.delegate.load(const Locale('en'));
    });

    test('shoppingFinalizing is non-empty and not hardcoded PT', () {
      expect(l10n.shoppingFinalizing, isNotEmpty);
      expect(l10n.shoppingFinalizing, isNot('A FINALIZAR'));
    });

    test('shoppingListEyebrow is non-empty and not hardcoded PT', () {
      expect(l10n.shoppingListEyebrow, isNotEmpty);
      expect(l10n.shoppingListEyebrow, isNot('LISTA'));
    });

    test('shoppingHeroItemCount returns a string containing the count', () {
      final result = l10n.shoppingHeroItemCount(3);
      expect(result, isNotEmpty);
      expect(result, contains('3'));
    });

    test('shoppingSummaryEyebrow is non-empty and not hardcoded PT', () {
      expect(l10n.shoppingSummaryEyebrow, isNotEmpty);
      expect(l10n.shoppingSummaryEyebrow, isNot('RESUMO'));
    });

    test('shoppingCheckedCountLabel returns a string containing the count', () {
      final result = l10n.shoppingCheckedCountLabel(2);
      expect(result, isNotEmpty);
      expect(result, contains('2'));
    });

    test('shoppingToBuyEyebrow is non-empty and not hardcoded PT', () {
      expect(l10n.shoppingToBuyEyebrow, isNotEmpty);
      expect(l10n.shoppingToBuyEyebrow, isNot('POR COMPRAR'));
    });

    test('shoppingInBasketEyebrow is non-empty and not hardcoded PT', () {
      expect(l10n.shoppingInBasketEyebrow, isNotEmpty);
      expect(l10n.shoppingInBasketEyebrow, isNot('NO CESTO'));
    });

    test('shoppingHistoryEyebrow is non-empty and not hardcoded PT', () {
      expect(l10n.shoppingHistoryEyebrow, isNotEmpty);
      expect(l10n.shoppingHistoryEyebrow, isNot('HISTÓRICO'));
    });
  });
}
