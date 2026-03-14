import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/data/tax/tax_deductions.dart';
import 'package:monthly_management/data/tax/tax_system.dart';

void main() {
  group('getTaxDeductionSystem', () {
    test('returns PT system for Portugal and null for others', () {
      expect(getTaxDeductionSystem(Country.pt), isA<PtTaxDeductionSystem>());
      expect(getTaxDeductionSystem(Country.es), isNull);
      expect(getTaxDeductionSystem(Country.fr), isNull);
      expect(getTaxDeductionSystem(Country.uk), isNull);
    });
  });

  group('PtTaxDeductionSystem', () {
    final system = PtTaxDeductionSystem();

    test('applies per-category caps, VAT rules and shared cap group', () {
      final summary = system.calculate(
        year: 2026,
        spentByCategory: const {
          'saude': 10000, // raw 1500 -> capped 1000
          'educacao': 4000, // raw 1200 -> capped 800
          'habitacao': 5000, // raw 750 -> capped 502
          'transportes': 1000, // raw 350 -> capped 250
          'outros': 1000, // raw 350 -> capped 250
          'alimentacao': 1000, // raw 34.50 (vat based)
          'telecomunicacoes': 300, // non-deductible
        },
      );

      CategoryDeductionResult byCategory(String category) =>
          summary.categories.firstWhere((c) => c.category == category);

      final saude = byCategory('saude');
      expect(saude.rawDeduction, 1500);
      expect(saude.cappedDeduction, 1000);
      expect(saude.finalDeduction, 1000);

      final alimentacao = byCategory('alimentacao');
      expect(alimentacao.rawDeduction, closeTo(34.5, 0.001));
      expect(alimentacao.finalDeduction, closeTo(34.5, 0.001));

      final transportes = byCategory('transportes');
      final outros = byCategory('outros');
      expect(transportes.cappedDeduction, 250);
      expect(outros.cappedDeduction, 250);
      expect(transportes.finalDeduction, closeTo(125, 0.001));
      expect(outros.finalDeduction, closeTo(125, 0.001));

      final telecom = byCategory('telecomunicacoes');
      expect(telecom.isDeductible, isFalse);
      expect(telecom.finalDeduction, 0);
      expect(telecom.capUsedPercent, 0);

      expect(summary.year, 2026);
      expect(summary.maxPossibleDeduction, 2802);
      expect(summary.totalDeduction, closeTo(2586.5, 0.001));
    });

    test('exposes deductible/non-deductible and top categories', () {
      final summary = system.calculate(
        year: 2026,
        spentByCategory: const {
          'saude': 900,
          'educacao': 1000,
          'habitacao': 1000,
          'transportes': 200,
          'outros': 0,
          'alimentacao': 500,
          'telecomunicacoes': 1000,
          'energia': 1000,
          'agua': 1000,
          'lazer': 1000,
        },
      );

      expect(summary.deductible, isNotEmpty);
      expect(summary.nonDeductible.length, 4);

      final top = summary.topCategories;
      expect(top.length, 3);
      expect(top.first.finalDeduction >= top[1].finalDeduction, isTrue);
      expect(top[1].finalDeduction >= top[2].finalDeduction, isTrue);
      expect(top.first.category, 'educacao');
    });
  });
}
