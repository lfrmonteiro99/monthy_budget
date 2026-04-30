import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/budget_summary.dart';
import 'package:monthly_management/services/income_service.dart';

BudgetSummary _summary({
  double net = 2380,
  double totalExpenses = 1300,
}) =>
    BudgetSummary(
      totalNetWithMeal: net,
      totalNet: net,
      totalGross: net,
      totalExpenses: totalExpenses,
      netLiquidity: net - totalExpenses,
      savingsRate: net > 0 ? (net - totalExpenses) / net : 0,
    );

IncomeSource _src(
  String id, {
  required double amount,
  IncomePeriod period = IncomePeriod.monthly,
  bool received = false,
  bool recurring = false,
}) =>
    IncomeSource(
      id: id,
      label: id,
      amount: amount,
      period: period,
      received: received,
      recurring: recurring,
    );

void main() {
  group('IncomeService.calculate', () {
    const service = IncomeService();

    test('treats salary baseline as already received', () {
      final b = service.calculate(
        summary: _summary(net: 2000, totalExpenses: 1000),
        sources: const [],
      );
      expect(b.receivedThisMonth, 2000);
      expect(b.expected, 0);
      expect(b.planned, 2000);
    });

    test('sums received extras into receivedThisMonth and excludes yearly '
        'from expected', () {
      final b = service.calculate(
        summary: _summary(net: 2000, totalExpenses: 1000),
        sources: [
          _src('rent', amount: 480, received: true, recurring: true),
          _src('interest', amount: 18, period: IncomePeriod.monthly),
          _src('irs', amount: 600, period: IncomePeriod.yearly),
        ],
      );
      expect(b.receivedThisMonth, 2480); // 2000 salary + 480 received rent
      expect(b.expected, 18);             // monthly expected interest only
      expect(b.planned, 2498);            // yearly excluded
    });

    test('savings rate is saved/planned, computed in service', () {
      final b = service.calculate(
        summary: _summary(net: 2000, totalExpenses: 1200),
        sources: const [],
        savedThisMonth: 400,
      );
      // saved = 400 (explicit), planned = 2000 → 20%
      expect(b.savingsRate, closeTo(0.2, 0.0001));
    });

    test('allocation always sums to planned (rounding aside)', () {
      final b = service.calculate(
        summary: _summary(net: 2500, totalExpenses: 1500),
        sources: const [],
        fixedExpenses: 1000,
      );
      final a = b.allocation;
      expect(a.fixed, 1000);
      expect(a.variable, 500);
      expect(a.fixed + a.variable + a.saved + a.remaining,
          closeTo(b.planned, 0.01));
    });

    test('clamps fixed to total expenses', () {
      final b = service.calculate(
        summary: _summary(net: 2000, totalExpenses: 800),
        sources: const [],
        fixedExpenses: 9999,
      );
      expect(b.allocation.fixed, 800);
      expect(b.allocation.variable, 0);
    });

    test('trend has 6 entries with current as last and pad uses salary', () {
      final b = service.calculate(
        summary: _summary(net: 2000, totalExpenses: 1000),
        sources: const [],
        previousMonthsIncome: const [1800, 1900, 2000, 2100, 1950],
      );
      expect(b.trend6m.length, 6);
      expect(b.trend6m.last, 2000);
      expect(b.trend6m.first, 1800);
    });

    test('trendDelta is fraction vs previous month', () {
      final b = service.calculate(
        summary: _summary(net: 2100, totalExpenses: 1000),
        sources: const [],
        previousMonthsIncome: const [1800, 1900, 2000, 2000, 2000],
      );
      // current 2100 vs prev 2000 → +5%
      expect(b.trendDelta, closeTo(0.05, 0.0001));
    });

    test('isEmpty when planned is zero', () {
      final b = service.calculate(
        summary: _summary(net: 0, totalExpenses: 0),
        sources: const [],
      );
      expect(b.isEmpty, true);
    });
  });

  group('IncomeService.orderedSources', () {
    const service = IncomeService();

    test('received first, then expected, then yearly', () {
      final ordered = service.orderedSources([
        _src('a', amount: 100, period: IncomePeriod.yearly),
        _src('b', amount: 200, received: true),
        _src('c', amount: 300),
      ]);
      expect(ordered.map((s) => s.id).toList(), ['b', 'c', 'a']);
    });

    test('within received, larger amounts first', () {
      final ordered = service.orderedSources([
        _src('small', amount: 50, received: true),
        _src('big', amount: 500, received: true),
      ]);
      expect(ordered.map((s) => s.id).toList(), ['big', 'small']);
    });
  });

  group('IncomeSource serialization', () {
    test('round-trips through JSON', () {
      final source = IncomeSource(
        id: 'rent-1',
        label: 'Renda T1',
        amount: 480,
        period: IncomePeriod.monthly,
        dayOfMonth: 8,
        category: 'home',
        recurring: true,
        received: true,
        date: '2026-04-08',
      );
      final back = IncomeSource.fromJson(source.toJson());
      expect(back.id, source.id);
      expect(back.label, source.label);
      expect(back.amount, source.amount);
      expect(back.period, source.period);
      expect(back.dayOfMonth, source.dayOfMonth);
      expect(back.category, source.category);
      expect(back.recurring, source.recurring);
      expect(back.received, source.received);
      expect(back.date, source.date);
    });

    test('persists on AppSettings JSON', () {
      final settings = AppSettings(
        incomeSources: const [
          IncomeSource(
            id: 'r1',
            label: 'Renda',
            amount: 480,
            period: IncomePeriod.monthly,
            recurring: true,
          ),
        ],
      );
      final back = AppSettings.fromJsonString(settings.toJsonString());
      expect(back.incomeSources.length, 1);
      expect(back.incomeSources.first.id, 'r1');
      expect(back.incomeSources.first.amount, 480);
    });
  });
}
