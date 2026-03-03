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
  final List<ChartType> enabledCharts;

  const LocalDashboardConfig({
    this.showHeroCard = true,
    this.showStressIndex = true,
    this.showMonthReview = true,
    this.showSummaryCards = true,
    this.showSalaryBreakdown = true,
    this.showPurchaseHistory = true,
    this.showExpensesBreakdown = true,
    this.showCharts = true,
    this.showBudgetVsActual = true,
    this.showSavingsGoals = true,
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
    enabledCharts: [],
  );

  factory LocalDashboardConfig.full() => const LocalDashboardConfig();

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
        'enabledCharts': enabledCharts.map((c) => c.jsonValue).toList(),
      };

  factory LocalDashboardConfig.fromJson(Map<String, dynamic> json) {
    return LocalDashboardConfig(
      showHeroCard: json['showHeroCard'] ?? true,
      showStressIndex: json['showStressIndex'] ?? true,
      showMonthReview: json['showMonthReview'] ?? true,
      showSummaryCards: json['showSummaryCards'] ?? true,
      showSalaryBreakdown: json['showSalaryBreakdown'] ?? true,
      showPurchaseHistory: json['showPurchaseHistory'] ?? true,
      showExpensesBreakdown: json['showExpensesBreakdown'] ?? true,
      showCharts: json['showCharts'] ?? true,
      showBudgetVsActual: json['showBudgetVsActual'] ?? true,
      showSavingsGoals: json['showSavingsGoals'] ?? true,
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
