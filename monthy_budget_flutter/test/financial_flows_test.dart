import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/data/tax/es_tax_system.dart';
import 'package:monthly_management/data/tax/fr_tax_system.dart';
import 'package:monthly_management/data/tax/pt_tax_system.dart';
import 'package:monthly_management/data/tax/tax_deductions.dart';
import 'package:monthly_management/data/tax/tax_factory.dart';
import 'package:monthly_management/data/tax/tax_system.dart';
import 'package:monthly_management/data/tax/uk_tax_system.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/budget_category_view.dart';
import 'package:monthly_management/models/budget_summary.dart';
import 'package:monthly_management/models/meal_budget_insight.dart';
import 'package:monthly_management/models/monthly_budget.dart';
import 'package:monthly_management/models/recurring_expense.dart';
import 'package:monthly_management/models/savings_goal.dart';
import 'package:monthly_management/utils/budget_rollover.dart';
import 'package:monthly_management/utils/calculations.dart';
import 'package:monthly_management/utils/savings_projections.dart';
import 'package:monthly_management/utils/stress_index.dart';

import 'helpers/test_helpers.dart';

void main() {
  // ─── 1. Net Salary Calculation ───────────────────────────────

  group('calculateNetSalary', () {
    test('PT salary with full subsidy yields higher effective gross', () {
      final salary = makeSalary(
        grossAmount: 1500,
        subsidyMode: SubsidyMode.full,
      );
      final result = calculateNetSalary(
        salary,
        makePersonalInfo(),
        PtTaxSystem(),
      );

      // Full subsidy factor = 14/12 = 1.1667
      expect(result.effectiveGrossAmount, closeTo(1500 * 14 / 12, 0.01));
      expect(result.subsidyMonthlyBonus, greaterThan(0));
      expect(result.netAmount, greaterThan(0));
      expect(result.netAmount, lessThan(result.effectiveGrossAmount));
    });

    test('PT salary with meal allowance card adds net meal to total', () {
      final salary = makeSalary(
        grossAmount: 1200,
        mealAllowanceType: MealAllowanceType.card,
        mealAllowancePerDay: 9.60,
        workingDaysPerMonth: 22,
      );
      final result = calculateNetSalary(
        salary,
        makePersonalInfo(),
        PtTaxSystem(),
      );

      expect(result.mealAllowance.totalMonthly, closeTo(9.60 * 22, 0.01));
      expect(result.mealAllowance.netMealAllowance, greaterThan(0));
      expect(result.totalNetWithMeal,
          greaterThan(result.netAmount));
    });

    test('UK salary ignores subsidy mode (no subsidies)', () {
      final salary = makeSalary(
        grossAmount: 3000,
        subsidyMode: SubsidyMode.full,
      );
      final result = calculateNetSalary(
        salary,
        makePersonalInfo(),
        UkTaxSystem(),
      );

      // UK has no subsidies, factor should be 1.0
      expect(result.effectiveGrossAmount, closeTo(3000, 0.01));
      expect(result.subsidyMonthlyBonus, closeTo(0, 0.01));
      // UK has no meal allowance
      expect(result.mealAllowance.totalMonthly, 0);
    });

    test('zero gross salary returns zero net with optional meal only', () {
      final salary = makeSalary(
        grossAmount: 0,
        mealAllowanceType: MealAllowanceType.card,
        mealAllowancePerDay: 9.60,
        workingDaysPerMonth: 22,
      );
      final result = calculateNetSalary(
        salary,
        makePersonalInfo(),
        PtTaxSystem(),
      );

      expect(result.netAmount, 0);
      expect(result.irsRetention, 0);
      expect(result.mealAllowance.totalMonthly, closeTo(9.60 * 22, 0.01));
      expect(result.totalNetWithMeal, greaterThan(0));
    });

    test('other exempt income is added to totalNetWithMeal', () {
      final salary = makeSalary(
        grossAmount: 1500,
        otherExemptIncome: 200,
      );
      final result = calculateNetSalary(
        salary,
        makePersonalInfo(),
        PtTaxSystem(),
      );

      // totalNetWithMeal = netAmount + mealAllowance.net + otherExemptIncome
      expect(result.totalNetWithMeal,
          closeTo(result.netAmount + result.mealAllowance.netMealAllowance + 200, 0.01));
    });
  });

  // ─── 2. Multi-Salary Budget Summary ─────────────────────────

  group('calculateBudgetSummary multi-salary', () {
    test('sums two enabled salaries and computes correct totals', () {
      final salaries = [
        makeSalary(grossAmount: 1500, label: 'Salary 1'),
        makeSalary(grossAmount: 1200, label: 'Salary 2'),
      ];
      final expenses = [
        makeExpense(category: 'habitacao', amount: 600),
        makeExpense(id: 'food', category: 'alimentacao', amount: 300),
      ];
      final summary = calculateBudgetSummary(
        salaries,
        makePersonalInfo(),
        expenses,
        PtTaxSystem(),
      );

      expect(summary.totalGross, closeTo(1500 + 1200, 0.01));
      expect(summary.totalNet, greaterThan(0));
      expect(summary.totalExpenses, 900);
      expect(summary.totalNetWithMeal, greaterThanOrEqualTo(summary.totalNet));
      // With 900 expenses on ~2700 gross, should have positive liquidity
      expect(summary.netLiquidity, greaterThan(0));
      expect(summary.savingsRate, greaterThan(0));
    });

    test('disabled salary is excluded from totals', () {
      final salaries = [
        makeSalary(grossAmount: 2000, enabled: true),
        makeSalary(grossAmount: 5000, enabled: false),
      ];
      final summary = calculateBudgetSummary(
        salaries,
        makePersonalInfo(),
        const [],
        PtTaxSystem(),
      );

      // Only the 2000 salary should count
      expect(summary.totalGross, closeTo(2000, 0.01));
    });

    test('savings rate is negative when expenses exceed income', () {
      final salaries = [makeSalary(grossAmount: 800)];
      final expenses = [makeExpense(amount: 2000, category: 'outros')];
      final summary = calculateBudgetSummary(
        salaries,
        makePersonalInfo(),
        expenses,
        PtTaxSystem(),
      );

      expect(summary.netLiquidity, lessThan(0));
      expect(summary.savingsRate, lessThan(0));
    });
  });

  // ─── 3. Tax Bracket Progressive Computation ─────────────────

  group('TaxBracket.applyBrackets', () {
    test('income within first bracket uses only that rate', () {
      final tax = TaxBracket.applyBrackets(500, const [
        TaxBracket(upTo: 1000, rate: 0.10),
        TaxBracket(upTo: 2000, rate: 0.20),
      ]);
      expect(tax, closeTo(50, 0.01));
    });

    test('income spanning multiple brackets accumulates progressively', () {
      final tax = TaxBracket.applyBrackets(3000, const [
        TaxBracket(upTo: 1000, rate: 0.10),
        TaxBracket(upTo: 2000, rate: 0.20),
        TaxBracket(upTo: double.infinity, rate: 0.30),
      ]);
      // 1000*0.10 + 1000*0.20 + 1000*0.30 = 100 + 200 + 300 = 600
      expect(tax, closeTo(600, 0.01));
    });

    test('zero income yields zero tax', () {
      final tax = TaxBracket.applyBrackets(0, const [
        TaxBracket(upTo: 1000, rate: 0.10),
      ]);
      expect(tax, 0);
    });
  });

  // ─── 4. Country-Specific Tax Calculations ───────────────────

  group('Country-specific tax net salary invariants', () {
    test('ES tax on 2000 gross has correct SS rate 6.35%', () {
      final es = EsTaxSystem();
      final result = es.calculateTax(
        grossSalary: 2000,
        maritalStatus: 'solteiro',
        titulares: 1,
        dependentes: 0,
      );

      expect(result.socialContribution, closeTo(2000 * 0.0635, 0.01));
      expect(result.socialContributionRate, 0.0635);
      expect(result.netSalary, lessThan(2000));
      expect(result.netSalary, greaterThan(0));
    });

    test('FR tax on 2500 gross has correct social rate 9.7%', () {
      final fr = FrTaxSystem();
      final result = fr.calculateTax(
        grossSalary: 2500,
        maritalStatus: 'solteiro',
        titulares: 1,
        dependentes: 0,
      );

      expect(result.socialContribution, closeTo(2500 * 0.097, 0.01));
      expect(result.netSalary, lessThan(2500));
    });

    test('UK low salary below personal allowance has zero income tax', () {
      final uk = UkTaxSystem();
      // 800/month * 12 = 9600/year, below 12570 personal allowance
      final result = uk.calculateTax(
        grossSalary: 800,
        maritalStatus: 'solteiro',
        titulares: 1,
        dependentes: 0,
      );

      expect(result.incomeTax, 0);
      expect(result.socialContribution, 0); // Below NI threshold too
    });
  });

  // ─── 5. Budget Pace Checking ────────────────────────────────

  group('checkBudgetPace', () {
    test('mid-month underspend returns ok severity', () {
      final result = checkBudgetPace(
        budget: 600,
        spent: 200,
        now: DateTime(2026, 3, 15),
      );

      // 200/15 = 13.33/day, expected = 600/31 = 19.35/day
      expect(result.isOverPace, isFalse);
      expect(result.severity, 'ok');
      expect(result.daysElapsed, 15);
      expect(result.daysRemaining, 16);
    });

    test('mid-month overspend returns danger severity', () {
      final result = checkBudgetPace(
        budget: 300,
        spent: 250,
        now: DateTime(2026, 3, 10),
      );

      // 250/10 = 25/day, expected = 300/31 = 9.68/day
      // paceRatio = 25/9.68 = 2.58 -> danger
      expect(result.isOverPace, isTrue);
      expect(result.severity, 'danger');
      expect(result.projectedTotal, greaterThan(300));
    });

    test('slightly over pace returns warning severity', () {
      // paceRatio needs to be between 1.0 and 1.2
      // budget/31 = expected. We need dailyPace/expected ~ 1.1
      // budget=310, day 10. expected=10/day. spent should give ~11/day => 110
      final result = checkBudgetPace(
        budget: 310,
        spent: 110,
        now: DateTime(2026, 3, 10),
      );

      // dailyPace = 11, expected = 10, ratio = 1.1
      expect(result.isOverPace, isTrue);
      expect(result.severity, 'warning');
    });

    test('zero budget returns ok with zero expected pace', () {
      final result = checkBudgetPace(
        budget: 0,
        spent: 100,
        now: DateTime(2026, 3, 15),
      );

      // expectedPace = 0, paceRatio = 0 (guarded), severity = ok
      expect(result.severity, 'ok');
      expect(result.dailyPace, greaterThan(0));
    });
  });

  // ─── 6. Savings Goal Computed Properties ────────────────────

  group('SavingsGoal computed properties', () {
    test('progress clamps at 1.0 when overfunded', () {
      final goal = SavingsGoal(
        id: 'g1',
        name: 'Fund',
        targetAmount: 1000,
        currentAmount: 1500,
      );

      expect(goal.progress, 1.0);
      expect(goal.isCompleted, isTrue);
      expect(goal.remaining, 0);
    });

    test('progress is 0 when target is 0', () {
      final goal = SavingsGoal(
        id: 'g2',
        name: 'Empty',
        targetAmount: 0,
        currentAmount: 0,
      );

      expect(goal.progress, 0);
      expect(goal.isCompleted, isTrue);
    });

    test('remaining clamps to target when current is 0', () {
      final goal = SavingsGoal(
        id: 'g3',
        name: 'New Goal',
        targetAmount: 5000,
        currentAmount: 0,
      );

      expect(goal.remaining, 5000);
      expect(goal.progress, 0);
      expect(goal.isCompleted, isFalse);
    });

    test('half-funded goal returns 50% progress', () {
      final goal = SavingsGoal(
        id: 'g4',
        name: 'Trip',
        targetAmount: 2000,
        currentAmount: 1000,
      );

      expect(goal.progress, closeTo(0.5, 0.001));
      expect(goal.remaining, 1000);
    });
  });

  // ─── 7. Savings Projection Edge Cases ───────────────────────

  group('SavingsProjection edge cases', () {
    test('goal already at target returns immediate completion', () {
      final projection = calculateProjection(
        goal: SavingsGoal(
          id: 'g1', name: 'Done', targetAmount: 500, currentAmount: 500,
        ),
        contributions: const [],
        now: DateTime(2026, 6, 1),
      );

      expect(projection.remaining, 0);
      expect(projection.hasData, isTrue);
      expect(projection.projectedDate, DateTime(2026, 6, 1));
    });

    test('no contributions and no deadline returns no projection data', () {
      final projection = calculateProjection(
        goal: SavingsGoal(
          id: 'g2', name: 'Vague', targetAmount: 10000, currentAmount: 0,
        ),
        contributions: const [],
        now: DateTime(2026, 3, 1),
      );

      expect(projection.hasData, isFalse);
      expect(projection.averageMonthlyContribution, 0);
      expect(projection.requiredMonthlyContribution, isNull);
    });

    test('on-track projection with adequate contributions', () {
      final projection = calculateProjection(
        goal: SavingsGoal(
          id: 'g3', name: 'Car', targetAmount: 6000, currentAmount: 3000,
          deadline: DateTime(2027, 3, 1),
        ),
        contributions: [
          makeContribution(id: 'c1', amount: 500,
              contributionDate: DateTime(2026, 1, 15)),
          makeContribution(id: 'c2', amount: 500,
              contributionDate: DateTime(2026, 2, 15)),
          makeContribution(id: 'c3', amount: 500,
              contributionDate: DateTime(2026, 3, 1)),
        ],
        now: DateTime(2026, 3, 15),
      );

      expect(projection.hasData, isTrue);
      expect(projection.onTrack, isTrue);
      expect(projection.remaining, 3000);
    });
  });

  // ─── 8. CategoryBudgetSummary Pace Logic ────────────────────

  group('CategoryBudgetSummary pace severity', () {
    test('over-pace category gets danger severity', () {
      final summaries = CategoryBudgetSummary.buildSummaries(
        const [
          ExpenseItem(id: 'rent', category: 'habitacao', amount: 500),
        ],
        [
          ActualExpense(
            id: '1', category: 'habitacao', amount: 400,
            date: DateTime(2026, 3, 10), monthKey: '2026-03',
          ),
        ],
        now: DateTime(2026, 3, 10),
      );

      final rent = summaries.firstWhere((s) => s.category == 'habitacao');
      // 400/10 = 40/day, expected 500/31 = 16.13/day -> paceRatio ~2.5 -> danger
      expect(rent.isOverPace, isTrue);
      expect(rent.paceSeverity, 'danger');
      expect(rent.projectedTotal, greaterThan(500));
    });

    test('disabled expense item is excluded from budget build', () {
      final summaries = CategoryBudgetSummary.buildSummaries(
        const [
          ExpenseItem(
            id: 'old', category: 'lazer', amount: 200, enabled: false,
          ),
        ],
        const [],
        now: DateTime(2026, 3, 15),
      );

      expect(summaries.where((s) => s.category == 'lazer'), isEmpty);
    });

    test('sorting places custom categories (budget=0) after budgeted ones', () {
      final summaries = CategoryBudgetSummary.buildSummaries(
        const [
          ExpenseItem(id: 'rent', category: 'habitacao', amount: 500),
        ],
        [
          ActualExpense(
            id: '1', category: 'habitacao', amount: 100,
            date: DateTime(2026, 3, 5), monthKey: '2026-03',
          ),
          ActualExpense(
            id: '2', category: 'lazer', amount: 50,
            date: DateTime(2026, 3, 5), monthKey: '2026-03',
          ),
        ],
        now: DateTime(2026, 3, 10),
      );

      // habitacao (budgeted) should come before lazer (custom/unbudgeted)
      final habitacaoIdx = summaries.indexWhere((s) => s.category == 'habitacao');
      final lazerIdx = summaries.indexWhere((s) => s.category == 'lazer');
      expect(habitacaoIdx, lessThan(lazerIdx));
    });
  });

  // ─── 9. BudgetCategoryView Computed Properties ──────────────

  group('BudgetCategoryView', () {
    test('totalRecurringAmount sums only active bills', () {
      final view = BudgetCategoryView(
        budgetItem: makeExpense(amount: 300, category: 'telecomunicacoes'),
        recurringBills: [
          makeRecurringExpense(id: 're1', amount: 50, isActive: true),
          makeRecurringExpense(id: 're2', amount: 30, isActive: false),
          makeRecurringExpense(id: 're3', amount: 20, isActive: true),
        ],
      );

      expect(view.totalRecurringAmount, 70);
      expect(view.activeBillCount, 2);
      expect(view.remainingVariableBudget, 230);
      expect(view.billsExceedBudget, isFalse);
    });

    test('billsExceedBudget is true when recurring exceeds budget', () {
      final view = BudgetCategoryView(
        budgetItem: makeExpense(amount: 50, category: 'telecomunicacoes'),
        recurringBills: [
          makeRecurringExpense(id: 're1', amount: 60, isActive: true),
        ],
      );

      expect(view.billsExceedBudget, isTrue);
      expect(view.remainingVariableBudget, -10);
    });

    test('empty recurring bills yields full budget available', () {
      final view = BudgetCategoryView(
        budgetItem: makeExpense(amount: 200),
      );

      expect(view.totalRecurringAmount, 0);
      expect(view.remainingVariableBudget, 200);
      expect(view.hasRecurringBills, isFalse);
    });
  });

  // ─── 10. Subsidy Mode Factors ───────────────────────────────

  group('SubsidyMode factors', () {
    test('none factor is 1.0', () {
      expect(SubsidyMode.none.monthlyFactor, 1.0);
    });

    test('full factor is 14/12', () {
      expect(SubsidyMode.full.monthlyFactor, closeTo(14 / 12, 0.0001));
    });

    test('half factor is 13/12', () {
      expect(SubsidyMode.half.monthlyFactor, closeTo(13 / 12, 0.0001));
    });
  });

  // ─── 11. Meal Allowance Calculations ────────────────────────

  group('Meal allowance edge cases', () {
    test('cash meal allowance uses lower exempt limit than card', () {
      final cardResult = calculateMealAllowance(
        MealAllowanceType.card, 10, 22, 0.15, 0.11,
      );
      final cashResult = calculateMealAllowance(
        MealAllowanceType.cash, 10, 22, 0.15, 0.11,
      );

      // Card exempt limit is 10.20, cash is 6.00
      // At 10/day, card has no taxable portion, cash has 4.00 taxable
      expect(cardResult.taxablePortion, 0);
      expect(cashResult.taxablePortion, greaterThan(0));
      expect(cardResult.netMealAllowance, greaterThan(cashResult.netMealAllowance));
    });

    test('meal allowance with very high per-day amount taxes the excess', () {
      final result = calculateMealAllowance(
        MealAllowanceType.card, 15, 22, 0.20, 0.11,
      );

      // 15 - 10.20 = 4.80 taxable per day
      expect(result.taxablePortion, closeTo(4.80 * 22, 0.01));
      expect(result.irsTaxOnMeal, greaterThan(0));
      expect(result.ssTaxOnMeal, greaterThan(0));
    });
  });

  // ─── 12. Tax Deduction Shared Cap Proportional Split ────────

  group('Tax deduction shared cap proportional allocation', () {
    test('unequal spending in shared group splits cap proportionally', () {
      final system = PtTaxDeductionSystem();
      final summary = system.calculate(
        year: 2026,
        familyType: FamilyType.single,
        spentByCategory: const {
          'transportes': 300,  // raw = 0.35 * 300 = 105
          'outros': 900,       // raw = 0.35 * 900 = 315, capped at 250
        },
      );

      final transportes = summary.categories
          .firstWhere((c) => c.category == 'transportes');
      final outros = summary.categories
          .firstWhere((c) => c.category == 'outros');

      // Total capped = 105 + 250 = 355, exceeds shared cap 250
      // Ratio = 250 / 355 = 0.7042
      // transportes final = 105 * ratio, outros final = 250 * ratio
      final total = transportes.finalDeduction + outros.finalDeduction;
      expect(total, closeTo(250, 0.01));
      // outros should get more since it had higher capped amount
      expect(outros.finalDeduction, greaterThan(transportes.finalDeduction));
    });
  });

  // ─── 13. CategoryBudgetSummary.remaining/progress/isOver ────

  group('CategoryBudgetSummary field computations', () {
    test('remaining is budgeted minus actual', () {
      const summary = CategoryBudgetSummary(
        category: 'alimentacao', budgeted: 400, actual: 150,
      );
      expect(summary.remaining, 250);
      expect(summary.isOver, isFalse);
    });

    test('progress clamps between 0 and 1.5', () {
      const under = CategoryBudgetSummary(
        category: 'a', budgeted: 100, actual: 50,
      );
      expect(under.progress, closeTo(0.5, 0.001));

      const over = CategoryBudgetSummary(
        category: 'b', budgeted: 100, actual: 200,
      );
      expect(over.progress, closeTo(1.5, 0.001));
      expect(over.isOver, isTrue);
    });

    test('zero budget yields zero progress and isCustom true', () {
      const custom = CategoryBudgetSummary(
        category: 'c', budgeted: 0, actual: 100,
      );
      expect(custom.progress, 0);
      expect(custom.isCustom, isTrue);
    });
  });

  // ─── 14. Budget Rollover Integration ────────────────────────

  group('Budget rollover with monthly overrides integration', () {
    test('rollover plus monthly override adjusts effective budget', () {
      // Step 1: Compute rollover from previous month
      final expenses = [
        const ExpenseItem(
          id: 'food', category: 'alimentacao', amount: 300,
          rolloverEnabled: true,
        ),
      ];
      final prevActuals = [
        ActualExpense(
          id: 'a1', category: 'alimentacao', amount: 250,
          date: DateTime(2026, 2, 15), monthKey: '2026-02',
        ),
      ];

      final rollovers = BudgetRollover.computeRollovers(
        expenseItems: expenses,
        previousMonthActuals: prevActuals,
        previousMonthBudgetOverrides: const {},
      );

      expect(rollovers['alimentacao'], 50);

      // Step 2: Apply rollover + monthly override to current month summary
      final summaries = CategoryBudgetSummary.buildSummaries(
        expenses,
        [
          ActualExpense(
            id: 'a2', category: 'alimentacao', amount: 100,
            date: DateTime(2026, 3, 10), monthKey: '2026-03',
          ),
        ],
        monthlyBudgets: const {'alimentacao': 280},
        rolloverAmounts: rollovers,
        now: DateTime(2026, 3, 10),
      );

      final food = summaries.firstWhere((s) => s.category == 'alimentacao');
      // Override 280 + rollover 50 = 330 effective budget
      expect(food.budgeted, 330);
      expect(food.actual, 100);
    });
  });

  // ─── 15. MealPlanBudgetInsight Model ────────────────────────

  group('MealPlanBudgetInsight.budgetUsagePercent', () {
    test('returns correct ratio when budget is positive', () {
      const insight = MealPlanBudgetInsight(
        weeklyEstimatedCost: 50,
        projectedMonthlySpend: 200,
        monthlyBudget: 400,
        remainingBudget: 200,
        status: MealBudgetStatus.safe,
        topExpensiveMeals: [],
        suggestedSwaps: [],
        shoppingImpact: ShoppingImpactSummary(
          uniqueIngredients: 10,
          estimatedShoppingCost: 80,
        ),
      );

      expect(insight.budgetUsagePercent, closeTo(0.5, 0.001));
    });

    test('returns 0 when monthly budget is 0', () {
      const insight = MealPlanBudgetInsight(
        weeklyEstimatedCost: 50,
        projectedMonthlySpend: 200,
        monthlyBudget: 0,
        remainingBudget: -200,
        status: MealBudgetStatus.over,
        topExpensiveMeals: [],
        suggestedSwaps: [],
        shoppingImpact: ShoppingImpactSummary(
          uniqueIngredients: 0,
          estimatedShoppingCost: 0,
        ),
      );

      expect(insight.budgetUsagePercent, 0);
    });
  });

  // ─── 16. Meal Cost Swap Savings ─────────────────────────────

  group('MealCostSwap.savings', () {
    test('savings is original cost minus alternative cost', () {
      const swap = MealCostSwap(
        original: MealCostEntry(
          recipeId: 'r1', recipeName: 'Steak',
          cost: 15.0, dayIndex: 1, mealType: 'dinner',
        ),
        alternativeRecipeId: 'r2',
        alternativeRecipeName: 'Pasta',
        alternativeCost: 5.0,
      );

      expect(swap.savings, 10.0);
    });
  });

  // ─── 17. DayCostBreakdown.totalCost ─────────────────────────

  group('DayCostBreakdown.totalCost', () {
    test('sums all meal costs for the day', () {
      const breakdown = DayCostBreakdown(
        dayIndex: 1,
        mealCosts: {'breakfast': 3.0, 'lunch': 8.0, 'dinner': 12.0},
      );

      expect(breakdown.totalCost, 23.0);
    });
  });

  // ─── 18. TaxResult.totalDeductions ──────────────────────────

  group('TaxResult.totalDeductions', () {
    test('equals income tax plus social contribution', () {
      const result = TaxResult(
        incomeTax: 200,
        incomeTaxRate: 0.15,
        socialContribution: 165,
        socialContributionRate: 0.11,
        netSalary: 1135,
      );

      expect(result.totalDeductions, 365);
    });
  });

  // ─── 19. CategoryDeductionResult.capUsedPercent ─────────────

  group('CategoryDeductionResult.capUsedPercent', () {
    test('returns 1.0 when fully capped', () {
      const result = CategoryDeductionResult(
        category: 'saude', irsCategory: 'Saude',
        spent: 10000, rawDeduction: 1500,
        cappedDeduction: 1000, finalDeduction: 1000,
        annualCap: 1000, isDeductible: true,
      );

      expect(result.capUsedPercent, 1.0);
    });

    test('returns correct fraction when partially used', () {
      const result = CategoryDeductionResult(
        category: 'saude', irsCategory: 'Saude',
        spent: 2000, rawDeduction: 300,
        cappedDeduction: 300, finalDeduction: 300,
        annualCap: 1000, isDeductible: true,
      );

      expect(result.capUsedPercent, closeTo(0.3, 0.001));
    });

    test('returns 0 when cap is 0', () {
      const result = CategoryDeductionResult(
        category: 'energia', irsCategory: '',
        spent: 300, rawDeduction: 0,
        cappedDeduction: 0, finalDeduction: 0,
        annualCap: 0, isDeductible: false,
      );

      expect(result.capUsedPercent, 0);
    });
  });

  // ─── 20. SavingsContribution Negative Amount Guarding ───────

  group('SavingsContribution.fromSupabase guards negative amounts', () {
    test('negative amount in supabase data is clamped to 0', () {
      final contribution = SavingsContribution.fromSupabase({
        'id': 'c1',
        'goal_id': 'g1',
        'amount': -50,
        'contribution_date': '2026-03-01',
      });

      expect(contribution.amount, 0);
    });
  });

  // ─── 21. MonthlyBudget Amount Guarding ──────────────────────

  group('MonthlyBudget model guards', () {
    test('negative amount from JSON is clamped to 0', () {
      final budget = MonthlyBudget.fromJson({
        'id': 'mb1',
        'category': 'alimentacao',
        'amount': -100,
        'month_key': '2026-03',
      });

      expect(budget.amount, 0);
    });
  });

  // ─── 22. ActualExpense.create monthKey derivation ───────────

  group('ActualExpense.create derives monthKey from date', () {
    test('January date produces correct monthKey', () {
      final expense = ActualExpense.create(
        category: 'outros',
        amount: 50,
        date: DateTime(2026, 1, 15),
      );

      expect(expense.monthKey, '2026-01');
    });

    test('December date produces correct monthKey', () {
      final expense = ActualExpense.create(
        category: 'outros',
        amount: 50,
        date: DateTime(2026, 12, 25),
      );

      expect(expense.monthKey, '2026-12');
    });
  });

  // ─── 23. Stress Index Budget Pace Integration ───────────────

  group('Stress index financial factors', () {
    test('high savings rate and liquidity yield excellent score', () {
      final result = calculateStressIndex(
        summary: makeBudgetSummary(
          totalNetWithMeal: 3000,
          totalExpenses: 1500,
          netLiquidity: 1500,
          savingsRate: 0.50,
        ),
        purchaseHistory: makePurchaseHistory(),
        settings: makeSettings(
          expenses: [makeExpense(category: 'alimentacao', amount: 300)],
        ),
      );

      expect(result.score, greaterThanOrEqualTo(80));
      expect(result.level, StressLevel.excellent);
    });

    test('zero income yields critical stress', () {
      final result = calculateStressIndex(
        summary: makeBudgetSummary(
          totalNetWithMeal: 0,
          totalExpenses: 500,
          netLiquidity: -500,
          savingsRate: 0,
        ),
        purchaseHistory: makePurchaseHistory(),
        settings: makeSettings(salaries: []),
      );

      expect(result.score, lessThanOrEqualTo(40));
      expect(result.level, isIn([StressLevel.critical, StressLevel.warning]));
    });
  });
}
