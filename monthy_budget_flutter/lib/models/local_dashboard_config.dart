import 'dart:convert';
import 'app_settings.dart';

class LocalDashboardConfig {
  final bool showHeroCard;
  final bool showStressIndex;
  final bool showMonthReview;
  final bool showSummaryCards;
  final bool showSalaryBreakdown;
  final bool showPurchaseHistory;
  final bool showExpensesBreakdown;
  final bool showCharts;
  final bool showBudgetVsActual;
  final bool showSavingsGoals;
  final bool showTaxDeductions;
  final bool showUpcomingBills;
  final bool showBudgetStreaks;
  final List<ChartType> enabledCharts;

  const LocalDashboardConfig({
    this.showHeroCard = true,
    this.showStressIndex = true,
    this.showMonthReview = true,
    this.showSummaryCards = false,
    this.showSalaryBreakdown = false,
    this.showPurchaseHistory = false,
    this.showExpensesBreakdown = false,
    this.showCharts = false,
    this.showBudgetVsActual = false,
    this.showSavingsGoals = false,
    this.showTaxDeductions = false,
    this.showUpcomingBills = true,
    this.showBudgetStreaks = false,
    this.enabledCharts = const [
      ChartType.expensesPie,
      ChartType.incomeVsExpenses,
      ChartType.deductionsBreakdown,
      ChartType.savingsRate,
    ],
  });

  factory LocalDashboardConfig.minimalist() => const LocalDashboardConfig(
    showHeroCard: true,
    showStressIndex: false,
    showMonthReview: true,
    showSummaryCards: false,
    showSalaryBreakdown: false,
    showPurchaseHistory: false,
    showExpensesBreakdown: false,
    showCharts: false,
    showBudgetVsActual: false,
    showSavingsGoals: false,
    showTaxDeductions: false,
    showUpcomingBills: false,
    showBudgetStreaks: false,
    enabledCharts: [],
  );

  factory LocalDashboardConfig.full() => const LocalDashboardConfig(
    showHeroCard: true,
    showStressIndex: true,
    showMonthReview: true,
    showSummaryCards: true,
    showSalaryBreakdown: true,
    showPurchaseHistory: true,
    showExpensesBreakdown: true,
    showCharts: true,
    showBudgetVsActual: true,
    showSavingsGoals: true,
    showTaxDeductions: true,
    showUpcomingBills: true,
    showBudgetStreaks: true,
    enabledCharts: [
      ChartType.expensesPie,
      ChartType.incomeVsExpenses,
      ChartType.deductionsBreakdown,
      ChartType.savingsRate,
    ],
  );

  LocalDashboardConfig copyWith({
    bool? showHeroCard,
    bool? showStressIndex,
    bool? showMonthReview,
    bool? showSummaryCards,
    bool? showSalaryBreakdown,
    bool? showPurchaseHistory,
    bool? showExpensesBreakdown,
    bool? showCharts,
    bool? showBudgetVsActual,
    bool? showSavingsGoals,
    bool? showTaxDeductions,
    bool? showUpcomingBills,
    bool? showBudgetStreaks,
    List<ChartType>? enabledCharts,
  }) {
    return LocalDashboardConfig(
      showHeroCard: showHeroCard ?? this.showHeroCard,
      showStressIndex: showStressIndex ?? this.showStressIndex,
      showMonthReview: showMonthReview ?? this.showMonthReview,
      showSummaryCards: showSummaryCards ?? this.showSummaryCards,
      showSalaryBreakdown: showSalaryBreakdown ?? this.showSalaryBreakdown,
      showPurchaseHistory: showPurchaseHistory ?? this.showPurchaseHistory,
      showExpensesBreakdown: showExpensesBreakdown ?? this.showExpensesBreakdown,
      showCharts: showCharts ?? this.showCharts,
      showBudgetVsActual: showBudgetVsActual ?? this.showBudgetVsActual,
      showSavingsGoals: showSavingsGoals ?? this.showSavingsGoals,
      showTaxDeductions: showTaxDeductions ?? this.showTaxDeductions,
      showUpcomingBills: showUpcomingBills ?? this.showUpcomingBills,
      showBudgetStreaks: showBudgetStreaks ?? this.showBudgetStreaks,
      enabledCharts: enabledCharts ?? this.enabledCharts,
    );
  }

  Map<String, dynamic> toJson() => {
        'showHeroCard': showHeroCard,
        'showStressIndex': showStressIndex,
        'showMonthReview': showMonthReview,
        'showSummaryCards': showSummaryCards,
        'showSalaryBreakdown': showSalaryBreakdown,
        'showPurchaseHistory': showPurchaseHistory,
        'showExpensesBreakdown': showExpensesBreakdown,
        'showCharts': showCharts,
        'showBudgetVsActual': showBudgetVsActual,
        'showSavingsGoals': showSavingsGoals,
        'showTaxDeductions': showTaxDeductions,
        'showUpcomingBills': showUpcomingBills,
        'showBudgetStreaks': showBudgetStreaks,
        'enabledCharts': enabledCharts.map((c) => c.jsonValue).toList(),
      };

  factory LocalDashboardConfig.fromJson(Map<String, dynamic> json) {
    return LocalDashboardConfig(
      showHeroCard: json['showHeroCard'] ?? true,
      showStressIndex: json['showStressIndex'] ?? true,
      showMonthReview: json['showMonthReview'] ?? true,
      showSummaryCards: json['showSummaryCards'] ?? false,
      showSalaryBreakdown: json['showSalaryBreakdown'] ?? false,
      showPurchaseHistory: json['showPurchaseHistory'] ?? false,
      showExpensesBreakdown: json['showExpensesBreakdown'] ?? false,
      showCharts: json['showCharts'] ?? false,
      showBudgetVsActual: json['showBudgetVsActual'] ?? false,
      showSavingsGoals: json['showSavingsGoals'] ?? false,
      showTaxDeductions: json['showTaxDeductions'] ?? false,
      showUpcomingBills: json['showUpcomingBills'] ?? true,
      showBudgetStreaks: json['showBudgetStreaks'] ?? false,
      enabledCharts: (json['enabledCharts'] as List<dynamic>?)
              ?.map((e) => ChartType.fromJson(e as String))
              .toList() ??
          const [
            ChartType.expensesPie,
            ChartType.incomeVsExpenses,
            ChartType.deductionsBreakdown,
            ChartType.savingsRate,
          ],
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory LocalDashboardConfig.fromJsonString(String s) {
    try {
      return LocalDashboardConfig.fromJson(jsonDecode(s) as Map<String, dynamic>);
    } catch (_) {
      return const LocalDashboardConfig();
    }
  }
}
