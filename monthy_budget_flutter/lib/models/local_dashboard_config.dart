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
  final bool showCashFlowForecast;
  final bool showBurnRate;
  final bool showTopCategories;
  final bool showSavingsRate;
  final bool showCoachInsight;
  final List<ChartType> enabledCharts;
  final List<String> cardOrder;

  static const defaultCardOrder = [
    'heroCard', 'stressIndex', 'budgetStreaks', 'monthReview',
    'upcomingBills', 'burnRate', 'topCategories', 'cashFlowForecast',
    'savingsRate', 'coachInsight', 'summaryCards', 'salaryBreakdown',
    'budgetVsActual', 'savingsGoals', 'taxDeductions', 'purchaseHistory',
    'expensesBreakdown', 'charts',
  ];

  const LocalDashboardConfig({
    this.showHeroCard = true,
    this.showStressIndex = true,
    this.showMonthReview = true,
    this.showSummaryCards = true,
    this.showSalaryBreakdown = false,
    this.showPurchaseHistory = false,
    this.showExpensesBreakdown = false,
    this.showCharts = false,
    this.showBudgetVsActual = true,
    this.showSavingsGoals = false,
    this.showTaxDeductions = false,
    this.showUpcomingBills = true,
    this.showBudgetStreaks = false,
    this.showCashFlowForecast = true,
    this.showBurnRate = true,
    this.showTopCategories = true,
    this.showSavingsRate = true,
    this.showCoachInsight = true,
    this.enabledCharts = const [
      ChartType.expensesPie,
      ChartType.incomeVsExpenses,
      ChartType.deductionsBreakdown,
      ChartType.savingsRate,
    ],
    this.cardOrder = defaultCardOrder,
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
    showCashFlowForecast: false,
    showBurnRate: false,
    showTopCategories: false,
    showSavingsRate: false,
    showCoachInsight: false,
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
    showCashFlowForecast: true,
    showBurnRate: true,
    showTopCategories: true,
    showSavingsRate: true,
    showCoachInsight: true,
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
    bool? showCashFlowForecast,
    bool? showBurnRate,
    bool? showTopCategories,
    bool? showSavingsRate,
    bool? showCoachInsight,
    List<ChartType>? enabledCharts,
    List<String>? cardOrder,
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
      showCashFlowForecast: showCashFlowForecast ?? this.showCashFlowForecast,
      showBurnRate: showBurnRate ?? this.showBurnRate,
      showTopCategories: showTopCategories ?? this.showTopCategories,
      showSavingsRate: showSavingsRate ?? this.showSavingsRate,
      showCoachInsight: showCoachInsight ?? this.showCoachInsight,
      enabledCharts: enabledCharts ?? this.enabledCharts,
      cardOrder: cardOrder ?? this.cardOrder,
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
        'showCashFlowForecast': showCashFlowForecast,
        'showBurnRate': showBurnRate,
        'showTopCategories': showTopCategories,
        'showSavingsRate': showSavingsRate,
        'showCoachInsight': showCoachInsight,
        'enabledCharts': enabledCharts.map((c) => c.jsonValue).toList(),
        'cardOrder': cardOrder,
      };

  factory LocalDashboardConfig.fromJson(Map<String, dynamic> json) {
    return LocalDashboardConfig(
      showHeroCard: json['showHeroCard'] ?? true,
      showStressIndex: json['showStressIndex'] ?? true,
      showMonthReview: json['showMonthReview'] ?? true,
      showSummaryCards: json['showSummaryCards'] ?? true,
      showSalaryBreakdown: json['showSalaryBreakdown'] ?? false,
      showPurchaseHistory: json['showPurchaseHistory'] ?? false,
      showExpensesBreakdown: json['showExpensesBreakdown'] ?? false,
      showCharts: json['showCharts'] ?? false,
      showBudgetVsActual: json['showBudgetVsActual'] ?? true,
      showSavingsGoals: json['showSavingsGoals'] ?? false,
      showTaxDeductions: json['showTaxDeductions'] ?? false,
      showUpcomingBills: json['showUpcomingBills'] ?? true,
      showBudgetStreaks: json['showBudgetStreaks'] ?? false,
      showCashFlowForecast: json['showCashFlowForecast'] ?? true,
      showBurnRate: json['showBurnRate'] ?? true,
      showTopCategories: json['showTopCategories'] ?? true,
      showSavingsRate: json['showSavingsRate'] ?? true,
      showCoachInsight: json['showCoachInsight'] ?? true,
      enabledCharts: (json['enabledCharts'] as List<dynamic>?)
              ?.map((e) => ChartType.fromJson(e as String))
              .toList() ??
          const [
            ChartType.expensesPie,
            ChartType.incomeVsExpenses,
            ChartType.deductionsBreakdown,
            ChartType.savingsRate,
          ],
      cardOrder: (json['cardOrder'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          defaultCardOrder,
    );
  }

  bool isCardVisible(String cardId) {
    switch (cardId) {
      case 'heroCard': return showHeroCard;
      case 'stressIndex': return showStressIndex;
      case 'monthReview': return showMonthReview;
      case 'summaryCards': return showSummaryCards;
      case 'salaryBreakdown': return showSalaryBreakdown;
      case 'purchaseHistory': return showPurchaseHistory;
      case 'expensesBreakdown': return showExpensesBreakdown;
      case 'charts': return showCharts;
      case 'budgetVsActual': return showBudgetVsActual;
      case 'savingsGoals': return showSavingsGoals;
      case 'taxDeductions': return showTaxDeductions;
      case 'upcomingBills': return showUpcomingBills;
      case 'budgetStreaks': return showBudgetStreaks;
      case 'cashFlowForecast': return showCashFlowForecast;
      case 'burnRate': return showBurnRate;
      case 'topCategories': return showTopCategories;
      case 'savingsRate': return showSavingsRate;
      case 'coachInsight': return showCoachInsight;
      default: return false;
    }
  }

  LocalDashboardConfig setCardVisible(String cardId, bool value) {
    switch (cardId) {
      case 'heroCard': return copyWith(showHeroCard: value);
      case 'stressIndex': return copyWith(showStressIndex: value);
      case 'monthReview': return copyWith(showMonthReview: value);
      case 'summaryCards': return copyWith(showSummaryCards: value);
      case 'salaryBreakdown': return copyWith(showSalaryBreakdown: value);
      case 'purchaseHistory': return copyWith(showPurchaseHistory: value);
      case 'expensesBreakdown': return copyWith(showExpensesBreakdown: value);
      case 'charts': return copyWith(showCharts: value);
      case 'budgetVsActual': return copyWith(showBudgetVsActual: value);
      case 'savingsGoals': return copyWith(showSavingsGoals: value);
      case 'taxDeductions': return copyWith(showTaxDeductions: value);
      case 'upcomingBills': return copyWith(showUpcomingBills: value);
      case 'budgetStreaks': return copyWith(showBudgetStreaks: value);
      case 'cashFlowForecast': return copyWith(showCashFlowForecast: value);
      case 'burnRate': return copyWith(showBurnRate: value);
      case 'topCategories': return copyWith(showTopCategories: value);
      case 'savingsRate': return copyWith(showSavingsRate: value);
      case 'coachInsight': return copyWith(showCoachInsight: value);
      default: return this;
    }
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
