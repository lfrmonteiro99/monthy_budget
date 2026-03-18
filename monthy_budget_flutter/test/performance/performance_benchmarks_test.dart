import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/data/tax/tax_system.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/budget_summary.dart';
import 'package:monthly_management/models/expense_snapshot.dart';
import 'package:monthly_management/models/local_dashboard_config.dart';
import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/models/meal_settings.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/models/recurring_expense.dart';
import 'package:monthly_management/models/shopping_item.dart';
import 'package:monthly_management/screens/dashboard_screen.dart';
import 'package:monthly_management/screens/shopping_list_screen.dart';
import 'package:monthly_management/services/meal_planner_service.dart';

import '../helpers/test_app.dart';

const _dashboardRenderBudgetMs = 500.0;
// Stopwatch-based widget tests include harness overhead, so keep the hard
// failure budget slightly above a 60 fps frame while warnings still catch
// smaller regressions from the recorded baseline.
const _shoppingScrollBudgetMs = 19.0;
const _mealPlannerBudgetMs = 2000.0;

final _recordedMetrics = <String, Map<String, dynamic>>{};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  tearDownAll(() {
    final benchmarkResultsPath =
        Platform.environment['PERF_RESULTS_PATH'] ??
        'build/performance/performance_results.json';
    if (_recordedMetrics.isEmpty) {
      return;
    }

    final file = File(benchmarkResultsPath);
    final payload = <String, dynamic>{
      'generated_at': DateTime.now().toUtc().toIso8601String(),
      'metrics': _recordedMetrics,
    };
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(payload));
  });

  testWidgets('dashboard initial render stays within budget', (tester) async {
    _configureLargeViewport(tester);

    await _pumpDashboardBenchmark(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    final samplesMs = <double>[];
    for (var i = 0; i < 6; i++) {
      final stopwatch = Stopwatch()..start();
      await _pumpDashboardBenchmark(tester);
      stopwatch.stop();

      expect(find.byType(DashboardScreen), findsOneWidget);
      samplesMs.add(_durationToMs(stopwatch.elapsed));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }

    final medianMs = _median(samplesMs.skip(1).toList());
    expect(medianMs, lessThan(_dashboardRenderBudgetMs));

    _recordMetric(
      name: 'dashboard_initial_render_ms',
      label: 'Dashboard initial render',
      aggregator: 'median',
      valueMs: medianMs,
      budgetMs: _dashboardRenderBudgetMs,
      samplesMs: samplesMs.skip(1).toList(),
      metadata: const {'screen': 'dashboard', 'fixture': 'full_dashboard'},
    );
  });

  testWidgets('shopping list scroll stays within frame budget', (tester) async {
    _configureLargeViewport(tester);

    await tester.pumpWidget(wrapWithTestApp(_buildShoppingBenchmarkScreen()));
    await tester.pump();

    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    final maxOffset = scrollable.position.maxScrollExtent;
    for (var i = 0; i < 10; i++) {
      final warmupOffset = math.min(
        maxOffset,
        scrollable.position.pixels + 32.0,
      );
      scrollable.position.jumpTo(warmupOffset);
      await tester.pump();
    }

    final frameSamplesMs = <double>[];

    for (var i = 0; i < 40; i++) {
      final targetOffset = math.min(
        maxOffset,
        scrollable.position.pixels + 32.0,
      );
      final stopwatch = Stopwatch()..start();
      scrollable.position.jumpTo(targetOffset);
      await tester.pump();
      stopwatch.stop();
      frameSamplesMs.add(_durationToMs(stopwatch.elapsed));
    }

    final p85Ms = _percentile(frameSamplesMs, 0.85);
    expect(p85Ms, lessThan(_shoppingScrollBudgetMs));

    _recordMetric(
      name: 'shopping_list_scroll_p85_frame_ms',
      label: 'Shopping list scroll p85 frame time',
      aggregator: 'p85',
      valueMs: p85Ms,
      budgetMs: _shoppingScrollBudgetMs,
      samplesMs: frameSamplesMs,
      metadata: const {'items': 600, 'group_mode': 'items'},
    );
  });

  test('meal planner generation stays within budget', () {
    final service = MealPlannerService()
      ..loadCatalogFromJson(
        File('assets/meal_planner/ingredients.json').readAsStringSync(),
        File('assets/meal_planner/recipes.json').readAsStringSync(),
      );

    final samplesMs = <double>[];
    for (var i = 0; i < 7; i++) {
      final stopwatch = Stopwatch()..start();
      service.generate(
        _buildMealPlannerSettings(),
        DateTime(2026, 3),
        previousFeedback: const {
          'frango_assado': MealFeedback.liked,
          'massa_atum': MealFeedback.disliked,
        },
        groceryPrices: const {
          'frango': 5.2,
          'tomate': 1.9,
          'batata': 1.2,
          'arroz': 1.1,
          'brocolos': 2.4,
        },
      );
      stopwatch.stop();
      samplesMs.add(_durationToMs(stopwatch.elapsed));
    }

    final medianMs = _median(samplesMs.skip(1).toList());
    expect(medianMs, lessThan(_mealPlannerBudgetMs));

    _recordMetric(
      name: 'meal_planner_generation_ms',
      label: 'Meal planner generation',
      aggregator: 'median',
      valueMs: medianMs,
      budgetMs: _mealPlannerBudgetMs,
      samplesMs: samplesMs.skip(1).toList(),
      metadata: const {'month': '2026-03', 'enabled_meals': 4},
    );
  });
}

Future<void> _pumpDashboardBenchmark(WidgetTester tester) {
  return tester.pumpWidget(
    wrapWithTestApp(
      DashboardScreen(
        settings: _buildDashboardSettings(),
        summary: _buildDashboardSummary(),
        purchaseHistory: _buildPurchaseHistory(),
        dashboardConfig: LocalDashboardConfig.full().copyWith(
          showSavingsGoals: false,
        ),
        expenseHistory: _buildExpenseHistory(),
        actualExpenses: _buildActualExpenses(),
        monthlyBudgets: _buildMonthlyBudgets(),
        recurringExpenses: _buildRecurringExpenses(),
        actualExpenseHistory: _buildActualExpenseHistory(),
        customCategories: const [],
        onOpenSettings: () {},
        onSaveSettings: (_) {},
        onSnapshotExpenses: () {},
        onAddExpense: () {},
        onOpenExpenseTracker: () {},
        onOpenInsights: () {},
        onOpenCoach: () {},
      ),
    ),
  );
}

AppSettings _buildDashboardSettings() {
  return AppSettings(
    country: Country.pt,
    personalInfo: const PersonalInfo(
      maritalStatus: MaritalStatus.casado,
      dependentes: 2,
    ),
    salaries: const [
      SalaryInfo(
        label: 'Primary salary',
        grossAmount: 3200,
        mealAllowanceType: MealAllowanceType.card,
        mealAllowancePerDay: 9.6,
        workingDaysPerMonth: 22,
        subsidyMode: SubsidyMode.full,
      ),
      SalaryInfo(
        label: 'Secondary salary',
        grossAmount: 1850,
        mealAllowanceType: MealAllowanceType.card,
        mealAllowancePerDay: 7.5,
        workingDaysPerMonth: 22,
        subsidyMode: SubsidyMode.none,
        otherExemptIncome: 120,
      ),
    ],
    expenses: const [
      ExpenseItem(
        id: 'rent',
        label: 'Rent',
        amount: 980,
        category: 'habitacao',
      ),
      ExpenseItem(
        id: 'food',
        label: 'Food',
        amount: 520,
        category: 'alimentacao',
      ),
      ExpenseItem(
        id: 'transport',
        label: 'Transport',
        amount: 210,
        category: 'transportes',
      ),
      ExpenseItem(
        id: 'electricity',
        label: 'Electricity',
        amount: 95,
        category: 'energia',
      ),
      ExpenseItem(id: 'water', label: 'Water', amount: 34, category: 'agua'),
      ExpenseItem(
        id: 'school',
        label: 'School',
        amount: 165,
        category: 'educacao',
      ),
      ExpenseItem(
        id: 'health',
        label: 'Health',
        amount: 110,
        category: 'saude',
      ),
      ExpenseItem(
        id: 'phone',
        label: 'Phone',
        amount: 42,
        category: 'telecomunicacoes',
      ),
      ExpenseItem(
        id: 'leisure',
        label: 'Leisure',
        amount: 160,
        category: 'lazer',
      ),
      ExpenseItem(id: 'other', label: 'Other', amount: 90, category: 'outros'),
    ],
    stressHistory: const {'2025-12': 67, '2026-01': 62, '2026-02': 58},
  );
}

BudgetSummary _buildDashboardSummary() {
  return const BudgetSummary(
    salaries: [
      SalaryCalculation(
        grossAmount: 3200,
        effectiveGrossAmount: 3733.33,
        subsidyMonthlyBonus: 533.33,
        otherExemptIncome: 0,
        irsRetention: 654,
        irsRate: 0.175,
        socialSecurity: 352,
        socialSecurityRate: 0.11,
        netAmount: 2727.33,
        mealAllowance: MealAllowanceCalculation(
          totalMonthly: 211.2,
          exemptPortion: 211.2,
          taxablePortion: 0,
          netMealAllowance: 211.2,
        ),
        totalNetWithMeal: 2938.53,
      ),
      SalaryCalculation(
        grossAmount: 1850,
        effectiveGrossAmount: 1850,
        subsidyMonthlyBonus: 0,
        otherExemptIncome: 120,
        irsRetention: 240,
        irsRate: 0.13,
        socialSecurity: 203.5,
        socialSecurityRate: 0.11,
        netAmount: 1526.5,
        mealAllowance: MealAllowanceCalculation(
          totalMonthly: 165,
          exemptPortion: 165,
          taxablePortion: 0,
          netMealAllowance: 165,
        ),
        totalNetWithMeal: 1811.5,
      ),
    ],
    totalGross: 5583.33,
    totalNet: 4253.83,
    totalNetWithMeal: 4750.03,
    totalMealAllowance: 376.2,
    totalIRS: 894,
    totalSS: 555.5,
    totalDeductions: 1449.5,
    totalExpenses: 2406,
    netLiquidity: 2344.03,
    savingsRate: 0.49,
  );
}

PurchaseHistory _buildPurchaseHistory() {
  return PurchaseHistory(
    records: List.generate(18, (index) {
      final month = 3 - (index % 6);
      final year = month <= 0 ? 2025 : 2026;
      final normalizedMonth = month <= 0 ? month + 12 : month;
      return PurchaseRecord(
        id: 'purchase_$index',
        date: DateTime(year, normalizedMonth, (index % 24) + 1),
        amount: 48 + (index * 5.75),
        itemCount: 6 + (index % 5),
        items: List.generate(4, (itemIndex) => 'Item ${index}_$itemIndex'),
        isMealPurchase: index.isEven,
      );
    }),
  );
}

Map<String, List<ExpenseSnapshot>> _buildExpenseHistory() {
  return const {
    '2026-02': [
      ExpenseSnapshot(
        expenseId: 'rent',
        label: 'Rent',
        category: 'habitacao',
        amount: 980,
        enabled: true,
      ),
      ExpenseSnapshot(
        expenseId: 'food',
        label: 'Food',
        category: 'alimentacao',
        amount: 500,
        enabled: true,
      ),
      ExpenseSnapshot(
        expenseId: 'transport',
        label: 'Transport',
        category: 'transportes',
        amount: 210,
        enabled: true,
      ),
    ],
  };
}

List<ActualExpense> _buildActualExpenses() {
  final categories = <String>[
    'habitacao',
    'alimentacao',
    'transportes',
    'energia',
    'agua',
    'educacao',
    'saude',
    'telecomunicacoes',
    'lazer',
    'outros',
  ];
  return List.generate(48, (index) {
    final category = categories[index % categories.length];
    return ActualExpense(
      id: 'actual_$index',
      category: category,
      amount: 18 + (index % 7) * 11.5,
      date: DateTime(2026, 3, (index % 27) + 1),
      description: 'Expense $index',
      monthKey: '2026-03',
    );
  });
}

Map<String, double> _buildMonthlyBudgets() {
  return const {
    'habitacao': 980,
    'alimentacao': 520,
    'transportes': 210,
    'energia': 95,
    'agua': 34,
    'educacao': 165,
    'saude': 110,
    'telecomunicacoes': 42,
    'lazer': 160,
    'outros': 90,
  };
}

List<RecurringExpense> _buildRecurringExpenses() {
  return List.generate(10, (index) {
    return RecurringExpense(
      id: 'recurring_$index',
      category: index.isEven ? 'habitacao' : 'servicos',
      amount: 32 + (index * 17),
      description: 'Recurring $index',
      dayOfMonth: (index * 3) + 1,
      isActive: true,
    );
  });
}

Map<String, List<ActualExpense>> _buildActualExpenseHistory() {
  final currentMonth = _buildActualExpenses();
  return {
    '2026-02': currentMonth
        .take(18)
        .map(
          (expense) => expense.copyWith(
            id: '${expense.id}_prev',
            date: DateTime(2026, 2, expense.date.day),
          ),
        )
        .toList(),
    '2026-03': currentMonth,
  };
}

ShoppingListScreen _buildShoppingBenchmarkScreen() {
  return ShoppingListScreen(
    items: List.generate(600, (index) {
      return ShoppingItem(
        id: 'item_$index',
        productName: 'Benchmark item $index',
        store: index.isEven ? 'Continente' : 'Pingo Doce',
        price: 1.2 + (index % 9) * 0.45,
        sourceMealLabels: [
          'Meal ${(index % 12) + 1}',
          if (index % 5 == 0) 'Backup meal ${(index % 7) + 1}',
        ],
      );
    }),
    purchaseHistory: _buildPurchaseHistory(),
    onToggleChecked: (_) {},
    onRemove: (_) {},
    onClearChecked: () {},
    onFinalize: (_, checkedItems, {isMealPurchase = false}) {},
  );
}

AppSettings _buildMealPlannerSettings() {
  return AppSettings(
    country: Country.pt,
    personalInfo: const PersonalInfo(dependentes: 2),
    salaries: const [
      SalaryInfo(label: 'Planner salary', grossAmount: 2600, titulares: 2),
    ],
    expenses: const [
      ExpenseItem(
        id: 'food',
        label: 'Food',
        amount: 620,
        category: 'alimentacao',
      ),
      ExpenseItem(
        id: 'rent',
        label: 'Rent',
        amount: 1000,
        category: 'habitacao',
      ),
    ],
    mealSettings: const MealSettings(
      enabledMeals: {
        MealType.breakfast,
        MealType.lunch,
        MealType.snack,
        MealType.dinner,
      },
      fishDaysPerWeek: 2,
      legumeDaysPerWeek: 2,
      batchCookingEnabled: true,
      maxBatchDays: 3,
      reuseLeftovers: true,
      lunchboxLunches: true,
      preferSeasonal: true,
      maxPrepMinutes: 35,
      maxPrepMinutesWeekend: 60,
      dailyCalorieTarget: 2400,
      dailyProteinTargetG: 140,
      objective: MealObjective.balancedHealth,
    ),
  );
}

void _configureLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1440, 3200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

double _durationToMs(Duration duration) => duration.inMicroseconds / 1000;

double _median(List<double> values) {
  final sorted = values.toList()..sort();
  final middle = sorted.length ~/ 2;
  if (sorted.length.isOdd) {
    return sorted[middle];
  }
  return (sorted[middle - 1] + sorted[middle]) / 2;
}

double _percentile(List<double> values, double percentile) {
  final sorted = values.toList()..sort();
  final rawIndex = (sorted.length - 1) * percentile;
  final lower = rawIndex.floor();
  final upper = rawIndex.ceil();
  if (lower == upper) {
    return sorted[lower];
  }
  final fraction = rawIndex - lower;
  return sorted[lower] + (sorted[upper] - sorted[lower]) * fraction;
}

void _recordMetric({
  required String name,
  required String label,
  required String aggregator,
  required double valueMs,
  required double budgetMs,
  required List<double> samplesMs,
  Map<String, Object?> metadata = const {},
}) {
  _recordedMetrics[name] = {
    'label': label,
    'unit': 'ms',
    'aggregator': aggregator,
    'value': valueMs,
    'budget_ms': budgetMs,
    'samples': samplesMs,
    'metadata': metadata,
  };
}
