import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations_en.dart';

void main() {
  late SEn en;
  setUpAll(() { en = SEn(); });
  tearDownAll(() {});

  group('plan_and_shop_screen l10n keys (#1170)', () {
    test('planShopDayToday is not hardcoded PT', () {
      expect(en.planShopDayToday, isNotNull);
      expect(en.planShopDayToday, isNot('Hoje'));
    });

    test('planShopDayTomorrow is not hardcoded PT', () {
      expect(en.planShopDayTomorrow, isNotNull);
      expect(en.planShopDayTomorrow, isNot('Amanhã'));
    });

    test('planShopDayMon is not hardcoded PT', () {
      expect(en.planShopDayMon, isNotNull);
      expect(en.planShopDayMon, isNot('Seg'));
    });

    test('planShopDayTue is not hardcoded PT', () {
      expect(en.planShopDayTue, isNotNull);
      expect(en.planShopDayTue, isNot('Ter'));
    });

    test('planShopDayWed is not hardcoded PT', () {
      expect(en.planShopDayWed, isNotNull);
      expect(en.planShopDayWed, isNot('Qua'));
    });

    test('planShopDayThu is not hardcoded PT', () {
      expect(en.planShopDayThu, isNotNull);
      expect(en.planShopDayThu, isNot('Qui'));
    });

    test('planShopDayFri is not hardcoded PT', () {
      expect(en.planShopDayFri, isNotNull);
      expect(en.planShopDayFri, isNot('Sex'));
    });

    test('planShopDaySat is not hardcoded PT', () {
      expect(en.planShopDaySat, isNotNull);
      expect(en.planShopDaySat, isNot('Sáb'));
    });

    test('planShopDaySun is not hardcoded PT', () {
      expect(en.planShopDaySun, isNotNull);
      expect(en.planShopDaySun, isNot('Dom'));
    });

    test('planShopWeekEyebrow formats weekNum', () {
      expect(en.planShopWeekEyebrow(27), isNotNull);
      expect(en.planShopWeekEyebrow(27), contains('27'));
    });

    test('planShopTitle is not hardcoded PT', () {
      expect(en.planShopTitle, isNotNull);
      expect(en.planShopTitle, isNot('Plano & compras'));
    });

    test('planShopBudgetEyebrow is not hardcoded PT', () {
      expect(en.planShopBudgetEyebrow, isNotNull);
      expect(en.planShopBudgetEyebrow, isNot('ORÇAMENTO SEMANAL'));
    });

    test('planShopNoMenuTitle is not hardcoded PT', () {
      expect(en.planShopNoMenuTitle, isNotNull);
      expect(en.planShopNoMenuTitle, isNot('Sem ementa esta semana'));
    });

    test('planShopNoMenuBody is not hardcoded PT', () {
      expect(en.planShopNoMenuBody, isNotNull);
      expect(en.planShopNoMenuBody, isNot(contains('Ementa')));
    });

    test('planShopSpentLabel is not hardcoded PT', () {
      expect(en.planShopSpentLabel, isNotNull);
      expect(en.planShopSpentLabel, isNot('Planeado'));
    });

    test('planShopRemainingLabel is not hardcoded PT', () {
      expect(en.planShopRemainingLabel, isNotNull);
      expect(en.planShopRemainingLabel, isNot('Restante'));
    });

    test('planShopTileList is not hardcoded PT', () {
      expect(en.planShopTileList, isNotNull);
      expect(en.planShopTileList, isNot('Lista'));
    });

    test('planShopTileMenu is not hardcoded PT', () {
      expect(en.planShopTileMenu, isNotNull);
      expect(en.planShopTileMenu, isNot('Ementa'));
    });

    test('planShopMealCount singular does not contain PT', () {
      expect(en.planShopMealCount(1), isNotNull);
      expect(en.planShopMealCount(1), isNot(contains('refeição')));
    });

    test('planShopMealCount plural contains count', () {
      expect(en.planShopMealCount(3), contains('3'));
    });

    test('planShopNoPlanLabel is not hardcoded PT', () {
      expect(en.planShopNoPlanLabel, isNotNull);
      expect(en.planShopNoPlanLabel, isNot('sem plano'));
    });

    test('planShopTilePantry is not hardcoded PT', () {
      expect(en.planShopTilePantry, isNotNull);
      expect(en.planShopTilePantry, isNot('Despensa'));
    });

    test('planShopItemCount singular does not contain PT plural', () {
      expect(en.planShopItemCount(1), isNotNull);
      expect(en.planShopItemCount(1), isNot(contains('itens')));
    });

    test('planShopItemCount plural contains count', () {
      expect(en.planShopItemCount(5), contains('5'));
    });

    test('planShopUpcomingEyebrow is not hardcoded PT', () {
      expect(en.planShopUpcomingEyebrow, isNotNull);
      expect(en.planShopUpcomingEyebrow, isNot('PRÓXIMAS REFEIÇÕES'));
    });

    test('planShopNoMealsTitle is not hardcoded PT', () {
      expect(en.planShopNoMealsTitle, isNotNull);
      expect(en.planShopNoMealsTitle, isNot('Sem refeições planeadas'));
    });

    test('planShopNoMealsBodyNoMenu is not hardcoded PT', () {
      expect(en.planShopNoMealsBodyNoMenu, isNotNull);
      expect(en.planShopNoMealsBodyNoMenu, isNot(contains('ementa')));
    });

    test('planShopNoMealsBodyWithMenu is not hardcoded PT', () {
      expect(en.planShopNoMealsBodyWithMenu, isNotNull);
      expect(en.planShopNoMealsBodyWithMenu, isNot(contains('Nenhuma')));
    });
  });
}
