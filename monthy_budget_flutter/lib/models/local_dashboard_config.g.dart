// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_dashboard_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalDashboardConfig _$LocalDashboardConfigFromJson(
  Map<String, dynamic> json,
) => LocalDashboardConfig(
  showHeroCard: json['showHeroCard'] as bool? ?? true,
  showStressIndex: json['showStressIndex'] as bool? ?? true,
  showMonthReview: json['showMonthReview'] as bool? ?? true,
  showSummaryCards: json['showSummaryCards'] as bool? ?? true,
  showSalaryBreakdown: json['showSalaryBreakdown'] as bool? ?? false,
  showPurchaseHistory: json['showPurchaseHistory'] as bool? ?? false,
  showExpensesBreakdown: json['showExpensesBreakdown'] as bool? ?? false,
  showCharts: json['showCharts'] as bool? ?? false,
  showBudgetVsActual: json['showBudgetVsActual'] as bool? ?? true,
  showSavingsGoals: json['showSavingsGoals'] as bool? ?? false,
  showTaxDeductions: json['showTaxDeductions'] as bool? ?? false,
  showUpcomingBills: json['showUpcomingBills'] as bool? ?? true,
  showBudgetStreaks: json['showBudgetStreaks'] as bool? ?? false,
  showCashFlowForecast: json['showCashFlowForecast'] as bool? ?? true,
  showBurnRate: json['showBurnRate'] as bool? ?? true,
  showTopCategories: json['showTopCategories'] as bool? ?? true,
  showSavingsRate: json['showSavingsRate'] as bool? ?? true,
  showCoachInsight: json['showCoachInsight'] as bool? ?? true,
  showQuickActions: json['showQuickActions'] as bool? ?? true,
  showSpendingAnomalies: json['showSpendingAnomalies'] as bool? ?? true,
  enabledCharts: json['enabledCharts'] == null
      ? const [
          ChartType.expensesPie,
          ChartType.incomeVsExpenses,
          ChartType.deductionsBreakdown,
          ChartType.savingsRate,
        ]
      : LocalDashboardConfig._enabledChartsFromJson(json['enabledCharts']),
  cardOrder:
      (json['cardOrder'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      _defaultDashboardCardOrder,
);

Map<String, dynamic> _$LocalDashboardConfigToJson(
  LocalDashboardConfig instance,
) => <String, dynamic>{
  'showHeroCard': instance.showHeroCard,
  'showStressIndex': instance.showStressIndex,
  'showMonthReview': instance.showMonthReview,
  'showSummaryCards': instance.showSummaryCards,
  'showSalaryBreakdown': instance.showSalaryBreakdown,
  'showPurchaseHistory': instance.showPurchaseHistory,
  'showExpensesBreakdown': instance.showExpensesBreakdown,
  'showCharts': instance.showCharts,
  'showBudgetVsActual': instance.showBudgetVsActual,
  'showSavingsGoals': instance.showSavingsGoals,
  'showTaxDeductions': instance.showTaxDeductions,
  'showUpcomingBills': instance.showUpcomingBills,
  'showBudgetStreaks': instance.showBudgetStreaks,
  'showCashFlowForecast': instance.showCashFlowForecast,
  'showBurnRate': instance.showBurnRate,
  'showTopCategories': instance.showTopCategories,
  'showSavingsRate': instance.showSavingsRate,
  'showCoachInsight': instance.showCoachInsight,
  'showQuickActions': instance.showQuickActions,
  'showSpendingAnomalies': instance.showSpendingAnomalies,
  'enabledCharts': LocalDashboardConfig._enabledChartsToJson(
    instance.enabledCharts,
  ),
  'cardOrder': instance.cardOrder,
};
