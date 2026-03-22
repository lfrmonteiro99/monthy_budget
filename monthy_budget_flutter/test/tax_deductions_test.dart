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

  group('FamilyType', () {
    test('has correct despesas gerais caps', () {
      expect(FamilyType.single.despesasGeraisCap, 250);
      expect(FamilyType.couple.despesasGeraisCap, 500);
      expect(FamilyType.singleParent.despesasGeraisCap, 335);
    });

    test('fromMaritalStatus derives correct family type', () {
      // Couple: casado or uniao_facto
      expect(FamilyType.fromMaritalStatus('casado', 0), FamilyType.couple);
      expect(FamilyType.fromMaritalStatus('casado', 2), FamilyType.couple);
      expect(
          FamilyType.fromMaritalStatus('uniao_facto', 0), FamilyType.couple);
      expect(
          FamilyType.fromMaritalStatus('uniao_facto', 1), FamilyType.couple);

      // Single parent: not married with dependents
      expect(FamilyType.fromMaritalStatus('solteiro', 1),
          FamilyType.singleParent);
      expect(FamilyType.fromMaritalStatus('divorciado', 2),
          FamilyType.singleParent);
      expect(
          FamilyType.fromMaritalStatus('viuvo', 1), FamilyType.singleParent);

      // Single: not married with no dependents
      expect(FamilyType.fromMaritalStatus('solteiro', 0), FamilyType.single);
      expect(
          FamilyType.fromMaritalStatus('divorciado', 0), FamilyType.single);
      expect(FamilyType.fromMaritalStatus('viuvo', 0), FamilyType.single);
    });
  });

  group('PtTaxDeductionSystem', () {
    final system = PtTaxDeductionSystem();

    // ---------------------------------------------------------------
    // 1) Despesas gerais familiares - 35%, cap by family type
    // ---------------------------------------------------------------
    group('despesas gerais familiares', () {
      test('single person: 35% capped at 250', () {
        final summary = system.calculate(
          year: 2026,
          familyType: FamilyType.single,
          spentByCategory: const {
            'transportes': 500,
            'outros': 500,
          },
        );

        final transportes = _byCategory(summary, 'transportes');
        final outros = _byCategory(summary, 'outros');
        final totalGerais =
            transportes.finalDeduction + outros.finalDeduction;
        expect(totalGerais, closeTo(250, 0.01));
      });

      test('couple: 35% capped at 500', () {
        final summary = system.calculate(
          year: 2026,
          familyType: FamilyType.couple,
          spentByCategory: const {
            'transportes': 1000,
            'outros': 500,
          },
        );

        final transportes = _byCategory(summary, 'transportes');
        final outros = _byCategory(summary, 'outros');
        final totalGerais =
            transportes.finalDeduction + outros.finalDeduction;
        // raw = 0.35 * 1500 = 525, capped at 500
        expect(totalGerais, closeTo(500, 0.01));
      });

      test('single parent: 35% capped at 335', () {
        final summary = system.calculate(
          year: 2026,
          familyType: FamilyType.singleParent,
          spentByCategory: const {
            'transportes': 600,
            'outros': 600,
          },
        );

        final transportes = _byCategory(summary, 'transportes');
        final outros = _byCategory(summary, 'outros');
        final totalGerais =
            transportes.finalDeduction + outros.finalDeduction;
        // raw = 0.35 * 1200 = 420, capped at 335
        expect(totalGerais, closeTo(335, 0.01));
      });

      test('under cap returns raw deduction', () {
        final summary = system.calculate(
          year: 2026,
          familyType: FamilyType.single,
          spentByCategory: const {
            'transportes': 200,
            'outros': 100,
          },
        );

        final transportes = _byCategory(summary, 'transportes');
        final outros = _byCategory(summary, 'outros');
        final totalGerais =
            transportes.finalDeduction + outros.finalDeduction;
        // raw = 0.35 * 300 = 105, under 250 cap
        expect(totalGerais, closeTo(105, 0.01));
      });
    });

    // ---------------------------------------------------------------
    // 2) Saude - 15%, cap 1000
    // ---------------------------------------------------------------
    group('saude', () {
      test('15% of health expenses capped at 1000', () {
        final summary = system.calculate(
          year: 2026,
          spentByCategory: const {'saude': 10000},
        );
        final saude = _byCategory(summary, 'saude');
        expect(saude.rawDeduction, 1500);
        expect(saude.finalDeduction, 1000);
        expect(saude.annualCap, 1000);
      });

      test('under cap returns raw deduction', () {
        final summary = system.calculate(
          year: 2026,
          spentByCategory: const {'saude': 2000},
        );
        final saude = _byCategory(summary, 'saude');
        // 0.15 * 2000 = 300
        expect(saude.finalDeduction, closeTo(300, 0.01));
      });
    });

    // ---------------------------------------------------------------
    // 3) Educacao - 30%, cap 800
    // ---------------------------------------------------------------
    group('educacao', () {
      test('30% of education expenses capped at 800', () {
        final summary = system.calculate(
          year: 2026,
          spentByCategory: const {'educacao': 5000},
        );
        final educacao = _byCategory(summary, 'educacao');
        expect(educacao.rawDeduction, 1500);
        expect(educacao.finalDeduction, 800);
        expect(educacao.annualCap, 800);
      });

      test('under cap returns raw deduction', () {
        final summary = system.calculate(
          year: 2026,
          spentByCategory: const {'educacao': 1000},
        );
        final educacao = _byCategory(summary, 'educacao');
        // 0.30 * 1000 = 300
        expect(educacao.finalDeduction, closeTo(300, 0.01));
      });
    });

    // ---------------------------------------------------------------
    // 4) Imoveis / arrendamento - 15%, cap 700
    // ---------------------------------------------------------------
    group('habitacao', () {
      test('15% of rent/housing capped at 700', () {
        final summary = system.calculate(
          year: 2026,
          spentByCategory: const {'habitacao': 12000},
        );
        final habitacao = _byCategory(summary, 'habitacao');
        expect(habitacao.rawDeduction, 1800);
        expect(habitacao.finalDeduction, 700);
        expect(habitacao.annualCap, 700);
      });

      test('under cap returns raw deduction', () {
        final summary = system.calculate(
          year: 2026,
          spentByCategory: const {'habitacao': 2000},
        );
        final habitacao = _byCategory(summary, 'habitacao');
        // 0.15 * 2000 = 300
        expect(habitacao.finalDeduction, closeTo(300, 0.01));
      });
    });

    // ---------------------------------------------------------------
    // 5) IVA setorial - 15% of VAT, cap 250
    // ---------------------------------------------------------------
    group('iva setorial', () {
      test('15% of VAT on restaurant spending capped at 250', () {
        final summary = system.calculate(
          year: 2026,
          spentByCategory: const {'alimentacao': 10000},
        );
        final alimentacao = _byCategory(summary, 'alimentacao');
        // raw = 0.15 * 0.23 * 10000 = 345, capped at 250
        expect(alimentacao.rawDeduction, closeTo(345, 0.01));
        expect(alimentacao.finalDeduction, 250);
        expect(alimentacao.annualCap, 250);
      });

      test('under cap returns raw deduction', () {
        final summary = system.calculate(
          year: 2026,
          spentByCategory: const {'alimentacao': 1000},
        );
        final alimentacao = _byCategory(summary, 'alimentacao');
        // raw = 0.15 * 0.23 * 1000 = 34.50
        expect(alimentacao.finalDeduction, closeTo(34.5, 0.01));
      });
    });

    // ---------------------------------------------------------------
    // Integration: issue example scenario
    // ---------------------------------------------------------------
    group('issue example scenario', () {
      test('couple with mixed expenses matches issue example', () {
        // Issue example:
        // despesas_gerais = 1500 -> min(0.35*1500, 500) = min(525, 500) = 500
        // despesas_saude = 800  -> min(0.15*800, 1000) = min(120, 1000) = 120
        // despesas_educacao = 400 -> min(0.30*400, 800) = min(120, 800) = 120
        // iva_restaurantes = 120 -> min(0.15*120, 250) = min(18, 250) = 18
        // total = 500 + 120 + 120 + 18 = 758
        final summary = system.calculate(
          year: 2026,
          familyType: FamilyType.couple,
          spentByCategory: const {
            'outros': 1500,
            'saude': 800,
            'educacao': 400,
            // For IVA: expense * 0.23 = 120 -> expense = 521.74
            // deduction = 0.15 * 0.23 * 521.74 = 18
            'alimentacao': 521.74,
          },
        );

        final gerais = _byCategory(summary, 'outros');
        // 0.35 * 1500 = 525, but couple cap = 500
        expect(gerais.finalDeduction, closeTo(500, 0.01));

        final saude = _byCategory(summary, 'saude');
        expect(saude.finalDeduction, closeTo(120, 0.01));

        final educacao = _byCategory(summary, 'educacao');
        expect(educacao.finalDeduction, closeTo(120, 0.01));

        final alimentacao = _byCategory(summary, 'alimentacao');
        expect(alimentacao.finalDeduction, closeTo(18, 0.5));

        expect(summary.totalDeduction, closeTo(758, 1.0));
      });
    });

    // ---------------------------------------------------------------
    // Backward compatibility: default familyType is single
    // ---------------------------------------------------------------
    test('default familyType is single (backward compatible)', () {
      final summary = system.calculate(
        year: 2026,
        spentByCategory: const {
          'transportes': 1000,
          'outros': 1000,
        },
      );

      final transportes = _byCategory(summary, 'transportes');
      final outros = _byCategory(summary, 'outros');
      final totalGerais =
          transportes.finalDeduction + outros.finalDeduction;
      // raw = 0.35 * 2000 = 700, single cap = 250
      expect(totalGerais, closeTo(250, 0.01));
    });

    // ---------------------------------------------------------------
    // Non-deductible categories
    // ---------------------------------------------------------------
    test('non-deductible categories have zero deduction', () {
      final summary = system.calculate(
        year: 2026,
        spentByCategory: const {
          'telecomunicacoes': 500,
          'energia': 300,
          'agua': 200,
          'lazer': 400,
        },
      );
      for (final cat in ['telecomunicacoes', 'energia', 'agua', 'lazer']) {
        final result = _byCategory(summary, cat);
        expect(result.isDeductible, isFalse);
        expect(result.finalDeduction, 0);
      }
    });

    // ---------------------------------------------------------------
    // Max possible deduction updated with new caps
    // ---------------------------------------------------------------
    test('maxPossibleDeduction reflects updated caps for single', () {
      final summary = system.calculate(
        year: 2026,
        familyType: FamilyType.single,
        spentByCategory: const {},
      );
      // single: despesas gerais 250 + saude 1000 + educacao 800
      //         + habitacao 700 + iva 250 = 3000
      expect(summary.maxPossibleDeduction, 3000);
    });

    test('maxPossibleDeduction reflects updated caps for couple', () {
      final summary = system.calculate(
        year: 2026,
        familyType: FamilyType.couple,
        spentByCategory: const {},
      );
      // couple: despesas gerais 500 + saude 1000 + educacao 800
      //         + habitacao 700 + iva 250 = 3250
      expect(summary.maxPossibleDeduction, 3250);
    });

    test('maxPossibleDeduction reflects updated caps for singleParent', () {
      final summary = system.calculate(
        year: 2026,
        familyType: FamilyType.singleParent,
        spentByCategory: const {},
      );
      // singleParent: despesas gerais 335 + saude 1000 + educacao 800
      //               + habitacao 700 + iva 250 = 3085
      expect(summary.maxPossibleDeduction, 3085);
    });

    // ---------------------------------------------------------------
    // Full scenario with all categories, caps verified
    // ---------------------------------------------------------------
    test('applies per-category caps, VAT rules and shared cap group', () {
      final summary = system.calculate(
        year: 2026,
        familyType: FamilyType.single,
        spentByCategory: const {
          'saude': 10000, // raw 1500 -> capped 1000
          'educacao': 4000, // raw 1200 -> capped 800
          'habitacao': 5000, // raw 750 -> capped 700
          'transportes': 1000, // raw 350 -> shared group
          'outros': 1000, // raw 350 -> shared group
          'alimentacao': 1000, // raw 34.50 (vat based)
          'telecomunicacoes': 300, // non-deductible
        },
      );

      final saude = _byCategory(summary, 'saude');
      expect(saude.rawDeduction, 1500);
      expect(saude.cappedDeduction, 1000);
      expect(saude.finalDeduction, 1000);

      final educacao = _byCategory(summary, 'educacao');
      expect(educacao.rawDeduction, 1200);
      expect(educacao.cappedDeduction, 800);
      expect(educacao.finalDeduction, 800);

      final habitacao = _byCategory(summary, 'habitacao');
      expect(habitacao.rawDeduction, 750);
      expect(habitacao.cappedDeduction, 700);
      expect(habitacao.finalDeduction, 700);

      final alimentacao = _byCategory(summary, 'alimentacao');
      expect(alimentacao.rawDeduction, closeTo(34.5, 0.001));
      expect(alimentacao.finalDeduction, closeTo(34.5, 0.001));

      // Shared cap group: transportes + outros both have raw 350,
      // capped individually at 250 each = 500 total, but shared cap = 250
      final transportes = _byCategory(summary, 'transportes');
      final outros = _byCategory(summary, 'outros');
      expect(transportes.cappedDeduction, 250);
      expect(outros.cappedDeduction, 250);
      expect(transportes.finalDeduction, closeTo(125, 0.001));
      expect(outros.finalDeduction, closeTo(125, 0.001));

      final telecom = _byCategory(summary, 'telecomunicacoes');
      expect(telecom.isDeductible, isFalse);
      expect(telecom.finalDeduction, 0);

      expect(summary.year, 2026);
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

CategoryDeductionResult _byCategory(
    YearlyDeductionSummary summary, String category) {
  return summary.categories.firstWhere((c) => c.category == category);
}
