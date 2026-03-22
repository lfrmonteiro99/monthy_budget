import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/app_settings.dart';

void main() {
  group('MaritalStatus', () {
    test('label returns non-empty string for each value', () {
      for (final status in MaritalStatus.values) {
        expect(status.label, isNotEmpty);
      }
    });

    test('jsonValue returns lowercase snake_case', () {
      expect(MaritalStatus.solteiro.jsonValue, 'solteiro');
      expect(MaritalStatus.casado.jsonValue, 'casado');
      expect(MaritalStatus.uniaoFacto.jsonValue, 'uniao_facto');
      expect(MaritalStatus.divorciado.jsonValue, 'divorciado');
      expect(MaritalStatus.viuvo.jsonValue, 'viuvo');
    });

    test('fromJson roundtrip for all values', () {
      for (final status in MaritalStatus.values) {
        expect(MaritalStatus.fromJson(status.jsonValue), status);
      }
    });

    test('fromJson defaults to solteiro for unknown value', () {
      expect(MaritalStatus.fromJson('unknown'), MaritalStatus.solteiro);
      expect(MaritalStatus.fromJson(''), MaritalStatus.solteiro);
    });
  });

  group('SubsidyMode', () {
    test('monthlyFactor values', () {
      expect(SubsidyMode.none.monthlyFactor, 1.0);
      expect(SubsidyMode.full.monthlyFactor, closeTo(14 / 12, 0.001));
      expect(SubsidyMode.half.monthlyFactor, closeTo(13 / 12, 0.001));
    });

    test('label returns non-empty for each value', () {
      for (final mode in SubsidyMode.values) {
        expect(mode.label, isNotEmpty);
      }
    });

    test('shortLabel returns non-empty for each value', () {
      for (final mode in SubsidyMode.values) {
        expect(mode.shortLabel, isNotEmpty);
      }
    });
  });

  group('MealAllowanceType', () {
    test('label returns non-empty for each value', () {
      for (final type in MealAllowanceType.values) {
        expect(type.label, isNotEmpty);
      }
    });
  });

  group('ExpenseCategory', () {
    test('label returns non-empty for each value', () {
      for (final cat in ExpenseCategory.values) {
        expect(cat.label, isNotEmpty);
      }
    });

    test('fromJson returns correct category by name', () {
      for (final cat in ExpenseCategory.values) {
        expect(ExpenseCategory.fromJson(cat.name), cat);
      }
    });

    test('fromJson defaults to outros for unknown name', () {
      expect(ExpenseCategory.fromJson('nonexistent'), ExpenseCategory.outros);
    });
  });

  group('ChartType', () {
    test('label returns non-empty for each value', () {
      for (final chart in ChartType.values) {
        expect(chart.label, isNotEmpty);
      }
    });

    test('jsonValue roundtrip via fromJson', () {
      for (final chart in ChartType.values) {
        expect(ChartType.fromJson(chart.jsonValue), chart);
      }
    });

    test('fromJson defaults to expensesPie for unknown', () {
      expect(ChartType.fromJson('unknown'), ChartType.expensesPie);
    });
  });

  group('PersonalInfo', () {
    test('defaults', () {
      const info = PersonalInfo();
      expect(info.maritalStatus, MaritalStatus.solteiro);
      expect(info.dependentes, 0);
      expect(info.deficiente, false);
    });

    test('copyWith updates fields', () {
      const info = PersonalInfo(
        maritalStatus: MaritalStatus.solteiro,
        dependentes: 0,
        deficiente: false,
      );
      final copy = info.copyWith(
        maritalStatus: MaritalStatus.casado,
        dependentes: 2,
        deficiente: true,
      );
      expect(copy.maritalStatus, MaritalStatus.casado);
      expect(copy.dependentes, 2);
      expect(copy.deficiente, true);
    });

    test('toJson / fromJson roundtrip', () {
      const original = PersonalInfo(
        maritalStatus: MaritalStatus.uniaoFacto,
        dependentes: 3,
        deficiente: true,
      );
      final json = original.toJson();
      final restored = PersonalInfo.fromJson(json);
      expect(restored.maritalStatus, original.maritalStatus);
      expect(restored.dependentes, original.dependentes);
      expect(restored.deficiente, original.deficiente);
    });

    test('fromJson handles missing keys', () {
      final info = PersonalInfo.fromJson({});
      expect(info.maritalStatus, MaritalStatus.solteiro);
      expect(info.dependentes, 0);
      expect(info.deficiente, false);
    });
  });

  group('SalaryInfo', () {
    test('defaults', () {
      const salary = SalaryInfo();
      expect(salary.label, '');
      expect(salary.grossAmount, 0);
      expect(salary.enabled, true);
      expect(salary.titulares, 1);
      expect(salary.mealAllowanceType, MealAllowanceType.none);
      expect(salary.mealAllowancePerDay, 0);
      expect(salary.workingDaysPerMonth, 22);
      expect(salary.subsidyMode, SubsidyMode.none);
      expect(salary.otherExemptIncome, 0);
    });

    test('copyWith updates fields', () {
      const salary = SalaryInfo(grossAmount: 1500);
      final copy = salary.copyWith(
        grossAmount: 2000,
        mealAllowanceType: MealAllowanceType.card,
        subsidyMode: SubsidyMode.full,
      );
      expect(copy.grossAmount, 2000);
      expect(copy.mealAllowanceType, MealAllowanceType.card);
      expect(copy.subsidyMode, SubsidyMode.full);
      expect(copy.label, salary.label);
    });

    test('toJson / fromJson roundtrip', () {
      const original = SalaryInfo(
        label: 'Salary 1',
        grossAmount: 2500,
        enabled: true,
        titulares: 2,
        mealAllowanceType: MealAllowanceType.card,
        mealAllowancePerDay: 8.5,
        workingDaysPerMonth: 20,
        subsidyMode: SubsidyMode.half,
        otherExemptIncome: 100,
      );
      final json = original.toJson();
      final restored = SalaryInfo.fromJson(json);
      expect(restored.label, original.label);
      expect(restored.grossAmount, original.grossAmount);
      expect(restored.enabled, original.enabled);
      expect(restored.titulares, original.titulares);
      expect(restored.mealAllowanceType, original.mealAllowanceType);
      expect(restored.mealAllowancePerDay, original.mealAllowancePerDay);
      expect(restored.workingDaysPerMonth, original.workingDaysPerMonth);
      expect(restored.subsidyMode, original.subsidyMode);
      expect(restored.otherExemptIncome, original.otherExemptIncome);
    });

    test('fromJson handles missing keys with defaults', () {
      final salary = SalaryInfo.fromJson({});
      expect(salary.label, '');
      expect(salary.grossAmount, 0);
      expect(salary.mealAllowanceType, MealAllowanceType.none);
      expect(salary.subsidyMode, SubsidyMode.none);
    });
  });

  group('ExpenseItem', () {
    test('defaults', () {
      const item = ExpenseItem(id: 'e1');
      expect(item.label, '');
      expect(item.amount, 0);
      expect(item.category, 'outros');
      expect(item.enabled, true);
      expect(item.isFixed, true);
      expect(item.rolloverEnabled, false);
    });

    test('copyWith updates fields', () {
      const item = ExpenseItem(id: 'e1', label: 'Rent', amount: 500);
      final copy = item.copyWith(
        label: 'Mortgage',
        amount: 800,
        rolloverEnabled: true,
      );
      expect(copy.label, 'Mortgage');
      expect(copy.amount, 800);
      expect(copy.rolloverEnabled, true);
      expect(copy.id, 'e1');
    });

    test('toJson / fromJson roundtrip', () {
      const original = ExpenseItem(
        id: 'e_rt',
        label: 'Insurance',
        amount: 150,
        category: 'saude',
        enabled: true,
        isFixed: false,
        rolloverEnabled: true,
      );
      final json = original.toJson();
      final restored = ExpenseItem.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.label, original.label);
      expect(restored.amount, original.amount);
      expect(restored.category, original.category);
      expect(restored.enabled, original.enabled);
      expect(restored.isFixed, original.isFixed);
      expect(restored.rolloverEnabled, original.rolloverEnabled);
    });
  });

  group('DashboardConfig', () {
    test('defaults', () {
      const config = DashboardConfig();
      expect(config.showSummaryCards, true);
      expect(config.enabledCharts, hasLength(4));
    });

    test('copyWith updates fields', () {
      const config = DashboardConfig();
      final copy = config.copyWith(
        showSummaryCards: false,
        enabledCharts: [ChartType.expensesPie],
      );
      expect(copy.showSummaryCards, false);
      expect(copy.enabledCharts, [ChartType.expensesPie]);
    });

    test('toJson / fromJson roundtrip', () {
      const original = DashboardConfig(
        showSummaryCards: false,
        enabledCharts: [ChartType.savingsRate, ChartType.netIncomeBar],
      );
      final json = original.toJson();
      final restored = DashboardConfig.fromJson(json);
      expect(restored.showSummaryCards, original.showSummaryCards);
      expect(restored.enabledCharts, original.enabledCharts);
    });

    test('fromJson handles missing keys', () {
      final config = DashboardConfig.fromJson({});
      expect(config.showSummaryCards, true);
      expect(config.enabledCharts, hasLength(4));
    });
  });

  group('AppSettings', () {
    test('copyWith updates country', () {
      const settings = AppSettings();
      final copy = settings.copyWith(
        setupWizardCompleted: true,
      );
      expect(copy.setupWizardCompleted, true);
      expect(copy.personalInfo.maritalStatus, MaritalStatus.solteiro);
    });

    test('copyWith can set localeOverride to null', () {
      final settings = const AppSettings().copyWith(localeOverride: 'en');
      expect(settings.localeOverride, 'en');
      final cleared = settings.copyWith(localeOverride: null);
      expect(cleared.localeOverride, isNull);
    });

    test('toJsonString / fromJsonString roundtrip', () {
      const original = AppSettings(
        personalInfo: PersonalInfo(
          maritalStatus: MaritalStatus.casado,
          dependentes: 2,
        ),
        setupWizardCompleted: true,
      );
      final json = original.toJsonString();
      final restored = AppSettings.fromJsonString(json);
      expect(restored.personalInfo.maritalStatus, MaritalStatus.casado);
      expect(restored.personalInfo.dependentes, 2);
      expect(restored.setupWizardCompleted, true);
    });

    test('fromJsonString with legacy data (no setupWizardCompleted key) '
         'infers from salary', () {
      // Simulate legacy JSON: has salary > 0, no setupWizardCompleted key
      final json = '{'
        '"personalInfo": {"maritalStatus": "solteiro", "dependentes": 0, "deficiente": false},'
        '"salaries": [{"label": "Salary", "grossAmount": 1500, "enabled": true, '
        '"titulares": 1, "mealAllowanceType": "none", "mealAllowancePerDay": 0, '
        '"workingDaysPerMonth": 22, "subsidyMode": "none", "otherExemptIncome": 0}],'
        '"expenses": []'
        '}';
      final settings = AppSettings.fromJsonString(json);
      // Should infer setupWizardCompleted = true because salary > 0
      expect(settings.setupWizardCompleted, true);
    });

    test('fromJsonString with legacy data (no salary) defaults to false', () {
      final json = '{'
        '"personalInfo": {"maritalStatus": "solteiro", "dependentes": 0, "deficiente": false},'
        '"salaries": [{"label": "Salary", "grossAmount": 0, "enabled": true, '
        '"titulares": 1, "mealAllowanceType": "none", "mealAllowancePerDay": 0, '
        '"workingDaysPerMonth": 22, "subsidyMode": "none", "otherExemptIncome": 0}],'
        '"expenses": []'
        '}';
      final settings = AppSettings.fromJsonString(json);
      expect(settings.setupWizardCompleted, false);
    });
  });
}
