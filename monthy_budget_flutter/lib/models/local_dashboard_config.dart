import 'dart:convert';
import 'app_settings.dart';

class LocalDashboardConfig {
  final bool showHeroCard;
  final bool showStressIndex;
  final bool showSummaryCards;
  final bool showSalaryBreakdown;
  final bool showFoodSpending;
  final bool showPurchaseHistory;
  final bool showExpensesBreakdown;
  final bool showCharts;
  final List<ChartType> enabledCharts;

  const LocalDashboardConfig({
    this.showHeroCard = true,
    this.showStressIndex = true,
    this.showSummaryCards = true,
    this.showSalaryBreakdown = true,
    this.showFoodSpending = true,
    this.showPurchaseHistory = true,
    this.showExpensesBreakdown = true,
    this.showCharts = true,
    this.enabledCharts = const [
      ChartType.expensesPie,
      ChartType.incomeVsExpenses,
      ChartType.deductionsBreakdown,
      ChartType.savingsRate,
    ],
  });

  LocalDashboardConfig copyWith({
    bool? showHeroCard,
    bool? showStressIndex,
    bool? showSummaryCards,
    bool? showSalaryBreakdown,
    bool? showFoodSpending,
    bool? showPurchaseHistory,
    bool? showExpensesBreakdown,
    bool? showCharts,
    List<ChartType>? enabledCharts,
  }) {
    return LocalDashboardConfig(
      showHeroCard: showHeroCard ?? this.showHeroCard,
      showStressIndex: showStressIndex ?? this.showStressIndex,
      showSummaryCards: showSummaryCards ?? this.showSummaryCards,
      showSalaryBreakdown: showSalaryBreakdown ?? this.showSalaryBreakdown,
      showFoodSpending: showFoodSpending ?? this.showFoodSpending,
      showPurchaseHistory: showPurchaseHistory ?? this.showPurchaseHistory,
      showExpensesBreakdown: showExpensesBreakdown ?? this.showExpensesBreakdown,
      showCharts: showCharts ?? this.showCharts,
      enabledCharts: enabledCharts ?? this.enabledCharts,
    );
  }

  Map<String, dynamic> toJson() => {
        'showHeroCard': showHeroCard,
        'showStressIndex': showStressIndex,
        'showSummaryCards': showSummaryCards,
        'showSalaryBreakdown': showSalaryBreakdown,
        'showFoodSpending': showFoodSpending,
        'showPurchaseHistory': showPurchaseHistory,
        'showExpensesBreakdown': showExpensesBreakdown,
        'showCharts': showCharts,
        'enabledCharts': enabledCharts.map((c) => c.jsonValue).toList(),
      };

  factory LocalDashboardConfig.fromJson(Map<String, dynamic> json) {
    return LocalDashboardConfig(
      showHeroCard: json['showHeroCard'] ?? true,
      showStressIndex: json['showStressIndex'] ?? true,
      showSummaryCards: json['showSummaryCards'] ?? true,
      showSalaryBreakdown: json['showSalaryBreakdown'] ?? true,
      showFoodSpending: json['showFoodSpending'] ?? true,
      showPurchaseHistory: json['showPurchaseHistory'] ?? true,
      showExpensesBreakdown: json['showExpensesBreakdown'] ?? true,
      showCharts: json['showCharts'] ?? true,
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
