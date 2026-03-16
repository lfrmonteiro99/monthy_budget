import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/utils/unit_converter.dart';

void main() {
  group('UnitConverter', () {
    group('normalize', () {
      test('kg stays as kg', () {
        final (qty, unit) = UnitConverter.normalize(1.5, 'kg');
        expect(qty, 1.5);
        expect(unit, 'kg');
      });

      test('g converts to kg', () {
        final (qty, unit) = UnitConverter.normalize(500, 'g');
        expect(qty, 0.5);
        expect(unit, 'kg');
      });

      test('L stays as L', () {
        final (qty, unit) = UnitConverter.normalize(2, 'L');
        expect(qty, 2);
        expect(unit, 'L');
      });

      test('mL converts to L', () {
        final (qty, unit) = UnitConverter.normalize(250, 'mL');
        expect(qty, 0.25);
        expect(unit, 'L');
      });

      test('lowercase l is alias for L', () {
        final (qty, unit) = UnitConverter.normalize(3, 'l');
        expect(qty, 3);
        expect(unit, 'L');
      });

      test('lowercase ml is alias for mL', () {
        final (qty, unit) = UnitConverter.normalize(100, 'ml');
        expect(qty, 0.1);
        expect(unit, 'L');
      });

      test('unknown unit passes through', () {
        final (qty, unit) = UnitConverter.normalize(3, 'unidade');
        expect(qty, 3);
        expect(unit, 'unidade');
      });
    });

    group('compatible', () {
      test('kg and g are compatible', () {
        expect(UnitConverter.compatible('kg', 'g'), true);
      });

      test('g and kg are compatible (reverse)', () {
        expect(UnitConverter.compatible('g', 'kg'), true);
      });

      test('L and mL are compatible', () {
        expect(UnitConverter.compatible('L', 'mL'), true);
      });

      test('l and mL are compatible (lowercase alias)', () {
        expect(UnitConverter.compatible('l', 'mL'), true);
      });

      test('kg and L are incompatible', () {
        expect(UnitConverter.compatible('kg', 'L'), false);
      });

      test('kg and mL are incompatible', () {
        expect(UnitConverter.compatible('kg', 'mL'), false);
      });

      test('g and mL are incompatible', () {
        expect(UnitConverter.compatible('g', 'mL'), false);
      });

      test('unknown units are compatible only if equal', () {
        expect(UnitConverter.compatible('unidade', 'unidade'), true);
        expect(UnitConverter.compatible('unidade', 'un'), false);
      });
    });

    group('convert', () {
      test('500g to kg', () {
        expect(UnitConverter.convert(500, 'g', 'kg'), 0.5);
      });

      test('1.5kg to g', () {
        expect(UnitConverter.convert(1.5, 'kg', 'g'), 1500);
      });

      test('250mL to L', () {
        expect(UnitConverter.convert(250, 'mL', 'L'), 0.25);
      });

      test('2L to mL', () {
        expect(UnitConverter.convert(2, 'L', 'mL'), 2000);
      });

      test('incompatible returns null', () {
        expect(UnitConverter.convert(1, 'kg', 'L'), null);
      });

      test('unknown target returns null', () {
        expect(UnitConverter.convert(1, 'kg', 'unidade'), null);
      });

      test('same unit returns same value', () {
        expect(UnitConverter.convert(3, 'kg', 'kg'), 3);
      });
    });

    group('displayFriendly', () {
      test('1500g displays as 1.5 kg', () {
        final (qty, unit) = UnitConverter.displayFriendly(1500, 'g');
        expect(qty, 1.5);
        expect(unit, 'kg');
      });

      test('500g stays as 500 g (under 1 kg)', () {
        final (qty, unit) = UnitConverter.displayFriendly(500, 'g');
        expect(qty, 500);
        expect(unit, 'g');
      });

      test('1000g displays as 1 kg (exactly 1)', () {
        final (qty, unit) = UnitConverter.displayFriendly(1000, 'g');
        expect(qty, 1);
        expect(unit, 'kg');
      });

      test('2000mL displays as 2 L', () {
        final (qty, unit) = UnitConverter.displayFriendly(2000, 'mL');
        expect(qty, 2);
        expect(unit, 'L');
      });

      test('250mL stays as 250 mL', () {
        final (qty, unit) = UnitConverter.displayFriendly(250, 'mL');
        expect(qty, 250);
        expect(unit, 'mL');
      });

      test('2kg stays as 2 kg', () {
        final (qty, unit) = UnitConverter.displayFriendly(2, 'kg');
        expect(qty, 2);
        expect(unit, 'kg');
      });

      test('0.3kg displays as 300 g', () {
        final (qty, unit) = UnitConverter.displayFriendly(0.3, 'kg');
        expect(qty, closeTo(300, 0.001));
        expect(unit, 'g');
      });

      test('0.5L displays as 500 mL', () {
        final (qty, unit) = UnitConverter.displayFriendly(0.5, 'L');
        expect(qty, 500);
        expect(unit, 'mL');
      });

      test('unknown unit passes through', () {
        final (qty, unit) = UnitConverter.displayFriendly(5, 'unidade');
        expect(qty, 5);
        expect(unit, 'unidade');
      });
    });

    group('integration: shopping list merge scenario', () {
      test('0.5 kg + 500 g merges to 1 kg', () {
        // Simulates merging: existing has 0.5 kg, new item has 500 g
        const existingQty = 0.5;
        const existingUnit = 'kg';
        const newQty = 500.0;
        const newUnit = 'g';

        expect(UnitConverter.compatible(existingUnit, newUnit), true);

        final converted = UnitConverter.convert(newQty, newUnit, existingUnit)!;
        expect(converted, 0.5);

        final merged = existingQty + converted;
        expect(merged, 1.0);

        final (displayQty, displayUnit) = UnitConverter.displayFriendly(merged, existingUnit);
        expect(displayQty, 1.0);
        expect(displayUnit, 'kg');
      });

      test('200 mL + 1.5 L merges to 1.7 L', () {
        const existingQty = 200.0;
        const existingUnit = 'mL';
        const newQty = 1.5;
        const newUnit = 'L';

        expect(UnitConverter.compatible(existingUnit, newUnit), true);

        final converted = UnitConverter.convert(newQty, newUnit, existingUnit)!;
        expect(converted, 1500);

        final merged = existingQty + converted;
        expect(merged, 1700);

        final (displayQty, displayUnit) = UnitConverter.displayFriendly(merged, existingUnit);
        expect(displayQty, 1.7);
        expect(displayUnit, 'L');
      });

      test('kg + L are not merged (incompatible)', () {
        expect(UnitConverter.compatible('kg', 'L'), false);
        expect(UnitConverter.convert(1, 'kg', 'L'), null);
      });
    });
  });
}
