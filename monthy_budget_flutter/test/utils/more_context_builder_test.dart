import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/budget_summary.dart';
import 'package:monthly_management/screens/more_screen.dart';
import 'package:monthly_management/utils/more_context_builder.dart';
import 'package:monthly_management/widgets/calm/calm_observation_card.dart';

void main() {
  late S l10n;

  setUpAll(() async {
    l10n = await S.delegate.load(const Locale('en'));
  });

  BudgetSummary summaryWith({
    double totalNetWithMeal = 2000,
    double totalExpenses = 1500,
    double netLiquidity = 500,
    double savingsRate = 0.25,
  }) {
    return BudgetSummary(
      totalNetWithMeal: totalNetWithMeal,
      totalExpenses: totalExpenses,
      netLiquidity: netLiquidity,
      savingsRate: savingsRate,
    );
  }

  group('coach quote', () {
    test('liveQuote (LLM) wins over the projection rule', () {
      final ctx = MoreContextBuilder.build(
        summary: summaryWith(netLiquidity: 500),
        topCategory: null,
        l10n: l10n,
        liveQuote: 'You can save €1200 by cutting eating out.',
      );
      expect(ctx.coachQuote, 'You can save €1200 by cutting eating out.');
    });

    test('whitespace-only liveQuote falls through to projection', () {
      final ctx = MoreContextBuilder.build(
        summary: summaryWith(netLiquidity: 880),
        topCategory: null,
        l10n: l10n,
        liveQuote: '   \n  ',
      );
      expect(ctx.coachQuote, contains('880'));
    });

    test('overlong liveQuote is truncated with an ellipsis', () {
      final long = 'a' * 400;
      final ctx = MoreContextBuilder.build(
        summary: summaryWith(),
        topCategory: null,
        l10n: l10n,
        liveQuote: long,
      );
      expect(ctx.coachQuote.length, lessThanOrEqualTo(MoreContextBuilder.liveQuoteMaxChars));
      expect(ctx.coachQuote.endsWith('…'), isTrue);
    });

    test('uses projection copy when there is positive liquidity', () {
      final ctx = MoreContextBuilder.build(
        summary: summaryWith(netLiquidity: 880),
        topCategory: null,
        l10n: l10n,
      );
      expect(ctx.coachQuote, contains('880'));
      expect(ctx.coachQuote, isNot(equals(l10n.moreCoachFallbackQuote)));
    });

    test('falls back to static when net liquidity is non-positive', () {
      final ctx = MoreContextBuilder.build(
        summary: summaryWith(netLiquidity: 0),
        topCategory: null,
        l10n: l10n,
      );
      expect(ctx.coachQuote, l10n.moreCoachFallbackQuote);
    });

    test('falls back to static when there is no income', () {
      final ctx = MoreContextBuilder.build(
        summary: summaryWith(
          totalNetWithMeal: 0,
          totalExpenses: 0,
          netLiquidity: 0,
          savingsRate: 0,
        ),
        topCategory: null,
        l10n: l10n,
      );
      expect(ctx.coachQuote, l10n.moreCoachFallbackQuote);
    });
  });

  group('observations', () {
    test('emits over-budget observation for category > 110%', () {
      final ctx = MoreContextBuilder.build(
        summary: summaryWith(savingsRate: 0.05),
        topCategory: const TopCategoryUsage(
          category: 'Leisure',
          percent: 143,
        ),
        l10n: l10n,
      );
      expect(ctx.observations, hasLength(1));
      expect(ctx.observations.first.kind, CalmObservationKind.warning);
      expect(ctx.observations.first.title, contains('Leisure'));
      expect(ctx.observations.first.title, contains('43'));
    });

    test('emits good-savings observation when rate ≥ 20%', () {
      final ctx = MoreContextBuilder.build(
        summary: summaryWith(savingsRate: 0.27),
        topCategory: null,
        l10n: l10n,
      );
      expect(ctx.observations, hasLength(1));
      expect(ctx.observations.first.kind, CalmObservationKind.success);
      expect(ctx.observations.first.title, contains('27'));
    });

    test('emits low-savings observation when rate < 10% and no over-budget', () {
      final ctx = MoreContextBuilder.build(
        summary: summaryWith(savingsRate: 0.05, netLiquidity: 80),
        topCategory: const TopCategoryUsage(
          category: 'Food',
          percent: 80,
        ),
        l10n: l10n,
      );
      expect(ctx.observations, hasLength(1));
      expect(ctx.observations.first.kind, CalmObservationKind.warning);
      expect(ctx.observations.first.id, 'savings-low');
    });

    test('does NOT double-warn when an over-budget category is already shown', () {
      final ctx = MoreContextBuilder.build(
        summary: summaryWith(savingsRate: 0.05),
        topCategory: const TopCategoryUsage(
          category: 'Leisure',
          percent: 143,
        ),
        l10n: l10n,
      );
      expect(
        ctx.observations.where((o) => o.id == 'savings-low'),
        isEmpty,
        reason: 'low-savings warning is suppressed when a category warning already exists',
      );
    });

    test('combines over-budget + good-savings when both apply', () {
      final ctx = MoreContextBuilder.build(
        summary: summaryWith(savingsRate: 0.22),
        topCategory: const TopCategoryUsage(
          category: 'Leisure',
          percent: 130,
        ),
        l10n: l10n,
      );
      expect(ctx.observations, hasLength(2));
      expect(ctx.observations[0].kind, CalmObservationKind.warning);
      expect(ctx.observations[1].kind, CalmObservationKind.success);
    });

    test('emits no observations on a quiet month with no expenses', () {
      final ctx = MoreContextBuilder.build(
        summary: summaryWith(
          totalExpenses: 0,
          netLiquidity: 2000,
          savingsRate: 1.0,
        ),
        topCategory: null,
        l10n: l10n,
      );
      // Savings rate is high (>= 20%), so good-savings still fires.
      // What we're guarding against is no `savings-low` warning when
      // expenses are zero.
      expect(
        ctx.observations.where((o) => o.id == 'savings-low'),
        isEmpty,
      );
    });

    test('observations list is unmodifiable', () {
      final ctx = MoreContextBuilder.build(
        summary: summaryWith(),
        topCategory: null,
        l10n: l10n,
      );
      expect(
        () => ctx.observations.add(
          const MoreObservation(
            id: 'x',
            kind: CalmObservationKind.info,
            title: 't',
            body: 'b',
          ),
        ),
        throwsUnsupportedError,
      );
    });

    test('over-budget observation rounds the post-fix 115.83% to 16% (#1220)', () {
      // 139 € spent on a 120 € monthly-adjusted budget = 115.83% → "16% above".
      // Guards the acceptance criterion: the More tab must read "16% above",
      // not the pre-fix "140%" computed from the unadjusted 58 €.
      final ctx = MoreContextBuilder.build(
        summary: summaryWith(savingsRate: 0.05),
        topCategory: const TopCategoryUsage(
          category: 'Leisure',
          percent: 115.83,
        ),
        l10n: l10n,
      );
      expect(ctx.observations.first.kind, CalmObservationKind.warning);
      expect(ctx.observations.first.title, contains('Leisure'));
      expect(ctx.observations.first.title, contains('16'));
      expect(ctx.observations.first.title, isNot(contains('140')));
    });
  });

  group('budgetByCategory', () {
    test('applies the monthly override over the settings default (#1220)', () {
      final budgets = MoreContextBuilder.budgetByCategory(
        const [
          ExpenseItem(id: 'leisure', category: 'lazer', amount: 58),
          ExpenseItem(id: 'energy', category: 'energia', amount: 94.4),
        ],
        monthlyBudgets: const {'lazer': 120},
      );
      // Lazer is overridden to the monthly-adjusted 120 €; Energia keeps its
      // settings default because it has no monthly record.
      expect(budgets['lazer'], 120);
      expect(budgets['energia'], 94.4);
    });

    test('ignores overrides for categories absent from settings expenses (#1220)', () {
      // Mirrors buildSummaries: an override may only replace a category that
      // exists in the budget list — it must not introduce a new one.
      final budgets = MoreContextBuilder.budgetByCategory(
        const [ExpenseItem(id: 'leisure', category: 'lazer', amount: 58)],
        monthlyBudgets: const {'transportes': 180},
      );
      expect(budgets.containsKey('transportes'), isFalse);
    });

    test('empty expenses yield an empty budget map (#1220)', () {
      final budgets = MoreContextBuilder.budgetByCategory(
        const [],
        monthlyBudgets: const {'lazer': 120},
      );
      expect(budgets, isEmpty);
    });

    test('a zero override is honoured, not treated as missing (#1220)', () {
      // buildSummaries uses `monthlyBudgets[key] ?? default` — a present 0
      // must replace the default, only an absent key keeps it.
      final budgets = MoreContextBuilder.budgetByCategory(
        const [ExpenseItem(id: 'leisure', category: 'lazer', amount: 58)],
        monthlyBudgets: const {'lazer': 0},
      );
      expect(budgets['lazer'], 0);
    });

    test('disabled expenses are excluded, then the override applies (#1220)', () {
      final budgets = MoreContextBuilder.budgetByCategory(
        const [
          ExpenseItem(id: 'a', category: 'lazer', amount: 30),
          ExpenseItem(id: 'b', category: 'lazer', amount: 70, enabled: false),
        ],
        monthlyBudgets: const {'lazer': 120},
      );
      // Only the enabled 30 € is summed as the default; the override then
      // replaces it with 120 €.
      expect(budgets['lazer'], 120);
    });
  });
}
