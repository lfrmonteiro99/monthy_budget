import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations_en.dart';

void main() {
  late SEn en;
  setUpAll(() { en = SEn(); });
  tearDownAll(() {});

  group('meal_menu_screen day/meal label l10n keys (#1177)', () {
    test('mealMenuDayMon is EN not PT', () {
      expect(en.mealMenuDayMon, isNotNull);
      expect(en.mealMenuDayMon, isNot('Seg'));
    });

    test('mealMenuDayTue is EN not PT', () {
      expect(en.mealMenuDayTue, isNot('Ter'));
    });

    test('mealMenuDayWed is EN not PT', () {
      expect(en.mealMenuDayWed, isNot('Qua'));
    });

    test('mealMenuDayThu is EN not PT', () {
      expect(en.mealMenuDayThu, isNot('Qui'));
    });

    test('mealMenuDayFri is EN not PT', () {
      expect(en.mealMenuDayFri, isNot('Sex'));
    });

    test('mealMenuDaySat is EN not PT', () {
      expect(en.mealMenuDaySat, isNot(contains('Sáb')));
    });

    test('mealMenuDaySun is EN not PT', () {
      expect(en.mealMenuDaySun, isNot('Dom'));
    });

    test('mealMenuRowBreakfast is EN not PT', () {
      expect(en.mealMenuRowBreakfast, isNotNull);
      expect(en.mealMenuRowBreakfast, isNot(contains('Peq')));
    });

    test('mealMenuRowLunch is EN not PT', () {
      expect(en.mealMenuRowLunch, isNotNull);
      expect(en.mealMenuRowLunch, isNot(contains('Almoço')));
    });

    test('mealMenuRowDinner is EN not PT', () {
      expect(en.mealMenuRowDinner, isNotNull);
      expect(en.mealMenuRowDinner, isNot(contains('Jantar')));
    });
  });
}
