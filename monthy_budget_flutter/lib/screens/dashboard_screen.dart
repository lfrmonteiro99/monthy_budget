import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/actual_expense.dart';
import '../models/budget_summary.dart';
import '../models/purchase_record.dart';
import '../models/recurring_expense.dart';
import '../models/custom_category.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/category_helpers.dart';
import '../utils/formatters.dart';
import '../utils/stress_index.dart';
import '../utils/budget_streaks.dart';
import '../constants/app_constants.dart';
import '../data/tax/tax_system.dart';
import '../data/tax/tax_deductions.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../widgets/charts/budget_charts.dart';
import '../widgets/trend_sheet.dart';
import '../widgets/tax_deduction_card.dart';
import '../widgets/upcoming_bills_card.dart';
import '../widgets/budget_streak_card.dart';
import '../widgets/spending_anomaly_card.dart';
import '../services/spending_anomaly_service.dart';
import '../models/local_dashboard_config.dart';
import '../models/expense_snapshot.dart';
import '../utils/month_review.dart';
import '../widgets/month_review_sheet.dart';
import '../models/savings_goal.dart';
import '../widgets/savings_goal_card.dart';
import '../widgets/info_icon_button.dart';
import '../utils/savings_projections.dart';
import '../onboarding/dashboard_tour.dart';
import '../models/notification_preferences.dart';
import '../services/local_config_service.dart';
import 'notification_settings_screen.dart';
import 'tax_deduction_detail_screen.dart';
import 'tax_simulator_screen.dart';

class DashboardScreen extends StatefulWidget {
  final AppSettings settings;
  final BudgetSummary summary;
  final PurchaseHistory purchaseHistory;
  final VoidCallback onOpenSettings;
  final ValueChanged<AppSettings> onSaveSettings;
  final LocalDashboardConfig dashboardConfig;
  final Map<String, List<ExpenseSnapshot>> expenseHistory;
  final VoidCallback onSnapshotExpenses;
  final List<ActualExpense> actualExpenses;
  final VoidCallback onAddExpense;
  final VoidCallback onOpenExpenseTracker;
  final VoidCallback? onViewTrends;
  final List<SavingsGoal> savingsGoals;
  final Map<String, SavingsProjection> savingsProjections;
  final VoidCallback? onOpenSavingsGoals;
  final Map<String, double> monthlyBudgets;
  final List<RecurringExpense> recurringExpenses;
  final Map<String, List<ActualExpense>> actualExpenseHistory;
  final int billReminderDaysBefore;
  final VoidCallback? onOpenRecurringExpenses;
  final bool showTour;
  final VoidCallback? onTourComplete;
  final GlobalKey? fabKey;
  final GlobalKey? navBarKey;
  final VoidCallback? onOpenInsights;
  final VoidCallback? onOpenCoach;
  final VoidCallback? onOpenIncome;
  final VoidCallback? onOpenTaxSimulator;
  final List<CustomCategory> customCategories;

  /// Household display name shown in the CalmHeader eyebrow (e.g. 'CASA SILVA').
  /// Falls back to empty string when not provided.
  final String householdName;

  /// Called when the bell icon is tapped. Typically opens notification
  /// settings. No-op tooltip is shown if null.
  final VoidCallback? onOpenNotificationSettings;

  const DashboardScreen({
    super.key,
    required this.settings,
    required this.summary,
    required this.purchaseHistory,
    required this.onOpenSettings,
    required this.onSaveSettings,
    required this.dashboardConfig,
    required this.expenseHistory,
    required this.onSnapshotExpenses,
    required this.actualExpenses,
    required this.onAddExpense,
    required this.onOpenExpenseTracker,
    this.onViewTrends,
    this.savingsGoals = const [],
    this.savingsProjections = const {},
    this.onOpenSavingsGoals,
    this.monthlyBudgets = const {},
    this.recurringExpenses = const [],
    this.actualExpenseHistory = const {},
    this.billReminderDaysBefore = 3,
    this.onOpenRecurringExpenses,
    this.showTour = false,
    this.onTourComplete,
    this.fabKey,
    this.navBarKey,
    this.onOpenInsights,
    this.onOpenCoach,
    this.onOpenIncome,
    this.onOpenTaxSimulator,
    this.customCategories = const [],
    this.householdName = '',
    this.onOpenNotificationSettings,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _tourShown = false;
  TutorialCoachMark? _activeTour;

  // Convenience accessors so helper methods don't need widget. prefix everywhere.
  AppSettings get settings => widget.settings;
  BudgetSummary get summary => widget.summary;
  PurchaseHistory get purchaseHistory => widget.purchaseHistory;
  LocalDashboardConfig get dashboardConfig => widget.dashboardConfig;
  Map<String, List<ExpenseSnapshot>> get expenseHistory => widget.expenseHistory;
  List<ActualExpense> get actualExpenses => widget.actualExpenses;
  List<SavingsGoal> get savingsGoals => widget.savingsGoals;
  Map<String, SavingsProjection> get savingsProjections =>
      widget.savingsProjections;
  Map<String, double> get monthlyBudgets => widget.monthlyBudgets;
  List<RecurringExpense> get recurringExpenses => widget.recurringExpenses;
  Map<String, List<ActualExpense>> get actualExpenseHistory =>
      widget.actualExpenseHistory;
  VoidCallback get onOpenSettings => widget.onOpenSettings;
  ValueChanged<AppSettings> get onSaveSettings => widget.onSaveSettings;
  VoidCallback get onSnapshotExpenses => widget.onSnapshotExpenses;
  VoidCallback get onAddExpense => widget.onAddExpense;
  VoidCallback get onOpenExpenseTracker => widget.onOpenExpenseTracker;
  VoidCallback? get onViewTrends => widget.onViewTrends;
  VoidCallback? get onOpenSavingsGoals => widget.onOpenSavingsGoals;

  @override
  void initState() {
    super.initState();
    if (widget.showTour && widget.fabKey != null && widget.navBarKey != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_tourShown && mounted) {
          _tourShown = true;
          Future.delayed(AppConstants.tourStartDelay, () {
            if (!mounted) return;
            _activeTour = buildDashboardTour(
              context: context,
              fabKey: widget.fabKey!,
              navBarKey: widget.navBarKey!,
              onFinish: () {
                _activeTour = null;
                widget.onTourComplete?.call();
              },
              onSkip: () {
                _activeTour = null;
                widget.onTourComplete?.call();
              },
            );
            _activeTour!.show(context: context);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _activeTour?.finish();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasData = summary.totalGross > 0;
    final isPositive = summary.netLiquidity >= 0;

    // Stress Index — calculate and persist if changed.
    final stressResult = calculateStressIndex(
      summary: summary,
      purchaseHistory: purchaseHistory,
      settings: settings,
    );
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final l10n = S.of(context);
    final monthReview = buildMonthReview(
      expenseHistory: expenseHistory,
      currentExpenses: settings.expenses,
      purchaseHistory: purchaseHistory,
      now: now,
      monthLabelBuilder: (m, y) => '${localizedMonthFull(l10n, m)} $y',
    );
    if (hasData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (settings.stressHistory[monthKey] != stressResult.score) {
          final updated = Map<String, int>.from(settings.stressHistory)
            ..[monthKey] = stressResult.score;
          onSaveSettings(settings.copyWith(stressHistory: updated));
        }
        onSnapshotExpenses();
      });
    }

    return CalmScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCalmHeader(context, l10n),
            const SizedBox(height: 24),
            if (hasData && dashboardConfig.showHeroCard)
              _buildHero(context, isPositive, l10n)
            else if (!hasData)
              _buildEmptyState(context, l10n),
            const SizedBox(height: 24),
            if (hasData) ...[
              for (final cardId in dashboardConfig.cardOrder)
                if (cardId != 'heroCard')
                  ..._buildCardById(cardId, context, stressResult, monthReview, l10n),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Header (CalmHeader) ───────────────────────────

  Widget _buildCalmHeader(BuildContext context, S l10n) {
    final now = DateTime.now();
    final monthLabel =
        '${localizedMonthFull(l10n, now.month)} ${now.year}';

    final eyebrow = widget.householdName.isNotEmpty
        ? widget.householdName.toUpperCase()
        : l10n.appTitle.toUpperCase();

    return CalmHeader(
      eyebrow: eyebrow,
      title: monthLabel,
      actions: [
        Tooltip(
          message: l10n.notificationSettings,
          child: IconButton(
            icon: Badge(
              isLabelVisible: false,
              child: Icon(
                Icons.notifications_outlined,
                size: 24,
                color: AppColors.ink70(context),
              ),
            ),
            onPressed: widget.onOpenNotificationSettings ??
                () => _openNotificationSettings(context),
          ),
        ),
        Tooltip(
          message: l10n.dashboardOpenSettings,
          child: IconButton(
            icon: Icon(
              Icons.settings_outlined,
              size: 24,
              color: AppColors.ink70(context),
            ),
            onPressed: onOpenSettings,
          ),
        ),
      ],
    );
  }

  Future<void> _openNotificationSettings(BuildContext context) async {
    final config = LocalConfigService();
    final prefs = await config.loadNotificationPreferences();
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationSettingsScreen(
          preferences: prefs,
          onSave: (updated) => config.saveNotificationPreferences(updated),
        ),
      ),
    );
  }

  // ───────────────────────────────── Hero ──────────────────────────────────

  Widget _buildHero(BuildContext context, bool isPositive, S l10n) {
    return Semantics(
      key: DashboardTourKeys.heroCard,
      label: l10n.dashboardHeroLabel(
        formatCurrency(summary.netLiquidity),
        isPositive
            ? l10n.dashboardPositiveBalance
            : l10n.dashboardNegativeBalance,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalmHero(
            eyebrow: l10n.dashboardMonthlyLiquidity.toUpperCase(),
            amount: formatCurrency(summary.netLiquidity),
            subtitle: l10n.dashboardFinancialSummary,
          ),
          const SizedBox(height: 12),
          CalmPill(
            label: isPositive
                ? l10n.dashboardPositiveBalance
                : l10n.dashboardNegativeBalance,
            color: isPositive ? AppColors.ok(context) : AppColors.bad(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, S l10n) {
    return CalmCard(
      child: CalmEmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: l10n.dashboardConfigureData,
        // TODO(l10n): move to ARB (Wave H)
        body: 'Configure os seus rendimentos e despesas para começar.',
        action: CalmEmptyStateAction(
          label: l10n.dashboardOpenSettingsButton,
          onPressed: onOpenSettings,
        ),
      ),
    );
  }

  // ───────────────────────── Card dispatcher ───────────────────────────────

  List<Widget> _buildCardById(
    String cardId,
    BuildContext context,
    StressIndexResult stressResult,
    MonthReviewResult? monthReview,
    S l10n,
  ) {
    if (!dashboardConfig.isCardVisible(cardId)) return const [];
    switch (cardId) {
      case 'stressIndex':
        return [
          _StressIndexCard(
            key: DashboardTourKeys.stressIndex,
            result: stressResult,
            onShowTrend: stressResult.score > 0
                ? () {
                    showTrendSheet(
                      context: context,
                      stressHistory: settings.stressHistory,
                      expenseHistory: expenseHistory,
                      currentTotalExpenses: summary.totalExpenses,
                    );
                  }
                : null,
          ),
          const SizedBox(height: 16),
        ];
      case 'budgetStreaks':
        return [
          BudgetStreakCard(
            streaks: calculateStreaks(
              actualExpenseHistory: actualExpenseHistory,
              expenses: settings.expenses,
              totalNetIncome: summary.totalNetWithMeal,
              purchaseHistory: purchaseHistory,
              monthlyBudgets: monthlyBudgets,
            ),
          ),
          const SizedBox(height: 16),
        ];
      case 'spendingAnomalies':
        final now = DateTime.now();
        final anomalyMonthKey =
            '${now.year}-${now.month.toString().padLeft(2, '0')}';
        final anomalies = SpendingAnomalyService.detectAnomalies(
          actualExpenseHistory: actualExpenseHistory,
          currentMonthKey: anomalyMonthKey,
        );
        if (anomalies.isEmpty) return const [];
        return [
          SpendingAnomalyCard(anomalies: anomalies),
          const SizedBox(height: 16),
        ];
      case 'monthReview':
        if (monthReview == null) return const [];
        return [
          _MonthReviewCard(
            review: monthReview,
            onTap: () =>
                showMonthReviewSheet(context: context, review: monthReview),
          ),
          const SizedBox(height: 16),
        ];
      case 'upcomingBills':
        if (!recurringExpenses
            .any((r) => r.isActive && r.dayOfMonth != null)) {
          return const [];
        }
        return [
          UpcomingBillsCard(
            recurringExpenses: recurringExpenses,
            reminderDaysBefore: widget.billReminderDaysBefore,
            onOpenRecurring: widget.onOpenRecurringExpenses,
          ),
          const SizedBox(height: 16),
        ];
      case 'burnRate':
        return [_buildBurnRateCard(context, l10n), const SizedBox(height: 16)];
      case 'topCategories':
        if (summary.totalExpenses <= 0) return const [];
        return [
          _buildTopCategoriesCard(context, l10n),
          const SizedBox(height: 16)
        ];
      case 'cashFlowForecast':
        return [
          _buildCashFlowForecastCard(context, l10n),
          const SizedBox(height: 16)
        ];
      case 'savingsRate':
        return [
          _buildSavingsRateCard(context, l10n),
          const SizedBox(height: 16)
        ];
      case 'coachInsight':
        if (widget.onOpenCoach == null) return const [];
        return [
          _buildCoachInsightCard(context, l10n),
          const SizedBox(height: 16)
        ];
      case 'summaryCards':
        return [_buildSummaryCards(l10n), const SizedBox(height: 16)];
      case 'salaryBreakdown':
        return [
          _buildSalaryBreakdown(context, l10n),
          if (settings.country == Country.pt) ...[
            const SizedBox(height: 8),
            _buildTaxSimulatorButton(context, l10n),
          ],
          const SizedBox(height: 16),
        ];
      case 'budgetVsActual':
        return [
          _buildBudgetVsActualCard(context),
          if (onViewTrends != null) ...[
            const SizedBox(height: 16),
            _buildViewTrendsButton(context, l10n),
          ],
          const SizedBox(height: 16),
        ];
      case 'savingsGoals':
        if (onOpenSavingsGoals == null) return const [];
        return [
          SavingsGoalCard(
            goals: savingsGoals,
            onSeeAll: onOpenSavingsGoals!,
            projections: savingsProjections,
          ),
          const SizedBox(height: 16),
        ];
      case 'taxDeductions':
        if (settings.country != Country.pt) return const [];
        return [_buildTaxDeductionCard(context), const SizedBox(height: 16)];
      case 'purchaseHistory':
        if (purchaseHistory.records.isEmpty) return const [];
        return [
          _buildPurchaseHistoryCard(context),
          const SizedBox(height: 16)
        ];
      case 'expensesBreakdown':
        if (summary.totalExpenses <= 0) return const [];
        return [
          _buildExpensesBreakdown(context, l10n),
          const SizedBox(height: 16)
        ];
      case 'charts':
        return [
          BudgetCharts(
            summary: summary,
            expenses: settings.expenses,
            enabledCharts: dashboardConfig.enabledCharts,
          ),
          const SizedBox(height: 16),
        ];
      case 'quickActions':
        return [_buildNextActionsCard(context, l10n), const SizedBox(height: 16)];
      default:
        return const [];
    }
  }

  // ───────────────────────── Quick actions ────────────────────────────────

  Widget _buildNextActionsCard(BuildContext context, S l10n) {
    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalmEyebrow(l10n.settingsDashQuickActions.toUpperCase()),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _actionButton(
                context,
                icon: Icons.add_circle_outline,
                label: l10n.addExpenseTooltip,
                onTap: onAddExpense,
              ),
              _actionButton(
                context,
                icon: Icons.receipt_long_outlined,
                label: l10n.expenseTrackerScreenTitle,
                onTap: onOpenExpenseTracker,
              ),
              if (widget.onOpenInsights != null)
                _actionButton(
                  context,
                  icon: Icons.insights_outlined,
                  label: l10n.trendTitle,
                  onTap: widget.onOpenInsights!,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink(context),
        side: BorderSide(color: AppColors.line(context)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ───────────────────────── Burn Rate ─────────────────────────────────────

  Widget _buildBurnRateCard(BuildContext context, S l10n) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysPassed = now.day;
    final daysRemaining = daysInMonth - daysPassed;
    final totalBudget = summary.totalNetWithMeal;
    final spent = summary.totalExpenses;
    final remaining = totalBudget - spent;
    final dailyAvgSpend = daysPassed > 0 ? spent / daysPassed : 0.0;
    final dailyBudgetAllowance =
        daysRemaining > 0 ? remaining / daysRemaining : 0.0;
    final isOverBudget = remaining < 0;
    final onTrack = dailyAvgSpend <= (totalBudget / daysInMonth);
    final paceLabel = onTrack
        ? l10n.dashboardBurnRateOnTrack
        : l10n.dashboardBurnRateOver;
    final paceColor = onTrack ? AppColors.ok(context) : AppColors.bad(context);

    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, size: 18, color: paceColor),
              const SizedBox(width: 8),
              Expanded(
                child: CalmEyebrow(l10n.dashboardBurnRateTitle.toUpperCase()),
              ),
              CalmPill(label: paceLabel, color: paceColor),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: totalBudget > 0
                  ? (spent / totalBudget).clamp(0.0, 1.0)
                  : 0.0,
              backgroundColor: AppColors.bgSunk(context),
              color: isOverBudget ? AppColors.bad(context) : AppColors.ink(context),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _miniStat(l10n.dashboardBurnRateDailyAvg,
                      formatCurrency(dailyAvgSpend), context)),
              Expanded(
                  child: _miniStat(
                      l10n.dashboardBurnRateAllowance,
                      formatCurrency(
                          dailyBudgetAllowance > 0 ? dailyBudgetAllowance : 0),
                      context)),
              Expanded(
                  child: _miniStat(l10n.dashboardBurnRateDaysLeft,
                      '$daysRemaining', context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: AppColors.ink50(context)),
        ),
        const SizedBox(height: 2),
        Text(value, style: CalmText.amount(context, size: 13)),
      ],
    );
  }

  // ───────────────────────── Top Categories ────────────────────────────────

  Widget _buildTopCategoriesCard(BuildContext context, S l10n) {
    final categoryTotals = <String, double>{};
    for (final e in actualExpenses) {
      categoryTotals[e.category] =
          (categoryTotals[e.category] ?? 0) + e.amount;
    }
    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();
    final total = summary.totalExpenses;

    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_outline,
                  size: 18, color: AppColors.accent(context)),
              const SizedBox(width: 8),
              CalmEyebrow(l10n.dashboardTopCategoriesTitle.toUpperCase()),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < top.length; i++) ...[
            if (i > 0) Divider(color: AppColors.line(context), height: 1),
            _topCategoryRow(context, top[i].key, top[i].value, total, l10n),
          ],
        ],
      ),
    );
  }

  Widget _topCategoryRow(
    BuildContext context,
    String categoryName,
    double value,
    double total,
    S l10n,
  ) {
    final pct = total > 0 ? value / total : 0.0;
    final budgetAmount = monthlyBudgets[categoryName] ?? 0;
    final overBudget = budgetAmount > 0 && value > budgetAmount;
    final trailing = overBudget
        ? '+${formatCurrency(value - budgetAmount)}'
        : '${(pct * 100).toStringAsFixed(0)}%';
    return CalmListTile(
      leadingIcon: categoryIconByName(
        categoryName,
        customCategories: widget.customCategories,
      ),
      leadingColor: AppColors.categoryColorByName(categoryName),
      title: _budgetCategoryLabel(categoryName, l10n),
      subtitle: budgetAmount > 0
          ? '${formatCurrency(value)} de ${formatCurrency(budgetAmount)}'
          : formatCurrency(value),
      trailing: trailing,
      onTap: widget.onOpenExpenseTracker,
    );
  }

  // ───────────────────────── Cash Flow Forecast ────────────────────────────

  Widget _buildCashFlowForecastCard(BuildContext context, S l10n) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysPassed = now.day;
    final daysRemaining = daysInMonth - daysPassed;
    final monthlyIncome = summary.totalNetWithMeal;
    final currentSpent = summary.totalExpenses;
    final recurringTotal = recurringExpenses
        .where((r) => r.isActive)
        .fold(0.0, (sum, r) => sum + r.amount);
    final recurringRemaining = recurringExpenses
        .where((r) =>
            r.isActive && r.dayOfMonth != null && r.dayOfMonth! > daysPassed)
        .fold(0.0, (sum, r) => sum + r.amount);
    final dailyDiscretionary = daysPassed > 0
        ? (currentSpent - (recurringTotal - recurringRemaining))
                .clamp(0.0, double.infinity) /
            daysPassed
        : 0.0;
    final projectedSpend =
        currentSpent + recurringRemaining + (dailyDiscretionary * daysRemaining);
    final projectedBalance = monthlyIncome - projectedSpend;
    final isPositive = projectedBalance >= 0;
    final color = isPositive ? AppColors.ok(context) : AppColors.bad(context);

    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, size: 18, color: color),
              const SizedBox(width: 8),
              CalmEyebrow(l10n.dashboardCashFlowTitle.toUpperCase()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  l10n.dashboardCashFlowProjectedSpend,
                  formatCurrency(projectedSpend),
                  context,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dashboardCashFlowEndOfMonth,
                      style: TextStyle(
                          fontSize: 10, color: AppColors.ink50(context)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatCurrency(projectedBalance),
                      style: CalmText.amount(context, size: 15)
                          .copyWith(color: color),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (recurringRemaining > 0) ...[
            const SizedBox(height: 8),
            Text(
              l10n.dashboardCashFlowPendingBills(
                  formatCurrency(recurringRemaining)),
              style: TextStyle(fontSize: 11, color: AppColors.ink50(context)),
            ),
          ],
        ],
      ),
    );
  }

  // ───────────────────────── Savings Rate ──────────────────────────────────

  Widget _buildSavingsRateCard(BuildContext context, S l10n) {
    final currentRate = summary.savingsRate;
    final saved = summary.netLiquidity > 0 ? summary.netLiquidity : 0.0;
    final rateColor = currentRate >= 20
        ? AppColors.ok(context)
        : currentRate >= 10
            ? AppColors.warn(context)
            : AppColors.bad(context);

    // Build 6-month trend from actualExpenseHistory.
    final now = DateTime.now();
    final monthRates = <String, double>{};
    for (int i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      final key = '${m.year}-${m.month.toString().padLeft(2, '0')}';
      final expenses = actualExpenseHistory[key];
      if (expenses != null && expenses.isNotEmpty) {
        final totalSpent = expenses.fold(0.0, (s, e) => s + e.amount);
        final income = summary.totalNetWithMeal;
        monthRates[key] = income > 0
            ? ((income - totalSpent) / income * 100).clamp(-100, 100)
            : 0;
      }
    }

    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.savings_outlined, size: 18, color: rateColor),
              const SizedBox(width: 8),
              Expanded(
                child: CalmEyebrow(
                    l10n.dashboardSavingsRateTitle.toUpperCase()),
              ),
              Text(
                '${currentRate.toStringAsFixed(1)}%',
                style: CalmText.amount(context, size: 18)
                    .copyWith(color: rateColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.dashboardSavingsRateSaved(formatCurrency(saved)),
            style: TextStyle(fontSize: 12, color: AppColors.ink70(context)),
          ),
          if (monthRates.length > 1) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: monthRates.entries.map((e) {
                  final barHeight =
                      (e.value.clamp(0, 100) / 100 * 36).clamp(2.0, 36.0);
                  final barColor = e.value >= 20
                      ? AppColors.ok(context)
                      : e.value >= 0
                          ? AppColors.warn(context)
                          : AppColors.bad(context);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: barColor.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ───────────────────────── Coach Insight ─────────────────────────────────

  Widget _buildCoachInsightCard(BuildContext context, S l10n) {
    String insight;
    IconData insightIcon;
    if (summary.savingsRate < 10 && summary.totalExpenses > 0) {
      insight = l10n.dashboardCoachLowSavings;
      insightIcon = Icons.warning_amber_outlined;
    } else if (summary.totalExpenses > summary.totalNetWithMeal * 0.9) {
      insight = l10n.dashboardCoachHighSpending;
      insightIcon = Icons.trending_down;
    } else if (summary.savingsRate >= 20) {
      insight = l10n.dashboardCoachGoodSavings;
      insightIcon = Icons.emoji_events_outlined;
    } else {
      insight = l10n.dashboardCoachGeneral;
      insightIcon = Icons.lightbulb_outline;
    }

    return CalmCard(
      onTap: widget.onOpenCoach,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentSoft(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(insightIcon,
                size: 20, color: AppColors.accent(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CalmEyebrow(l10n.dashboardCoachInsightTitle.toUpperCase()),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style:
                      TextStyle(fontSize: 13, color: AppColors.ink70(context)),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              size: 20, color: AppColors.ink50(context)),
        ],
      ),
    );
  }

  // ───────────────────────── Summary Cards ─────────────────────────────────

  Widget _buildSummaryCards(S l10n) {
    final openIncome = widget.onOpenIncome;
    final openTaxSimulator = widget.onOpenTaxSimulator ?? widget.onOpenIncome;
    final openSavings = widget.onOpenSavingsGoals;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.account_balance_wallet_outlined,
                label: l10n.dashboardGrossIncome,
                value: formatCurrency(summary.totalGross),
                accent: AppColors.accent,
                onTap: openIncome,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.arrow_circle_up_outlined,
                label: l10n.dashboardNetIncome,
                value: formatCurrency(summary.totalNetWithMeal),
                sublabel: summary.totalMealAllowance > 0
                    ? l10n.dashboardInclMealAllowance(
                        formatCurrency(summary.totalMealAllowance))
                    : null,
                accent: AppColors.ok,
                onTap: openIncome,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.arrow_circle_down_outlined,
                label: l10n.dashboardDeductions,
                value: formatCurrency(summary.totalDeductions),
                sublabel: l10n.dashboardIrsSs(
                    formatCurrency(summary.totalIRS),
                    formatCurrency(summary.totalSS)),
                accent: AppColors.warn,
                onTap: openTaxSimulator,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.savings_outlined,
                label: l10n.dashboardSavingsRate,
                value: formatPercentage(
                    summary.savingsRate > 0 ? summary.savingsRate : 0),
                sublabel: l10n.dashboardExpensesAmount(
                    formatCurrency(summary.totalExpenses)),
                accent: AppColors.accent,
                onTap: openSavings,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ───────────────────────── Salary Breakdown ─────────────────────────────

  Widget _buildSalaryBreakdown(BuildContext context, S l10n) {
    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CalmEyebrow(l10n.dashboardSalaryDetail.toUpperCase()),
              ),
              InfoIconButton(
                  title: l10n.dashboardSalaryDetail,
                  body: l10n.infoSalaryBreakdown),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(summary.salaries.length, (i) {
            final calc = summary.salaries[i];
            final hasGross = calc.effectiveGrossAmount > 0;
            final hasAnyIncome = hasGross || calc.otherExemptIncome > 0;
            if (!hasAnyIncome) return const SizedBox.shrink();
            final label = i < settings.salaries.length &&
                    settings.salaries[i].label.isNotEmpty
                ? settings.salaries[i].label
                : l10n.dashboardSalaryN(i + 1);
            return Padding(
              padding: EdgeInsets.only(top: i > 0 ? 12 : 0),
              child: hasGross
                  ? _SalaryRow(label: label, calc: calc)
                  : _ExemptIncomeRow(
                      label: label, amount: calc.otherExemptIncome),
            );
          }),
        ],
      ),
    );
  }

  // ───────────────────────── Nav CTAs ──────────────────────────────────────

  Widget _buildViewTrendsButton(BuildContext context, S l10n) {
    return CalmCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      onTap: onViewTrends,
      child: Row(
        children: [
          Icon(Icons.trending_up,
              size: 20, color: AppColors.accent(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.expenseTrends,
              style: CalmText.amount(context, size: 14,
                  weight: FontWeight.w600),
            ),
          ),
          Icon(Icons.chevron_right,
              size: 20, color: AppColors.ink50(context)),
        ],
      ),
    );
  }

  Widget _buildTaxSimulatorButton(BuildContext context, S l10n) {
    return CalmCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TaxSimulatorScreen(settings: settings),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.calculate_outlined,
              size: 20, color: AppColors.accent(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.taxSimButton,
              style: CalmText.amount(context, size: 14,
                  weight: FontWeight.w600),
            ),
          ),
          Icon(Icons.chevron_right,
              size: 20, color: AppColors.ink50(context)),
        ],
      ),
    );
  }

  // ───────────────────────── Tax Deduction ─────────────────────────────────

  Widget _buildTaxDeductionCard(BuildContext context) {
    final now = DateTime.now();
    final spentByCategory = <String, double>{};
    for (final entry in actualExpenseHistory.entries) {
      final parts = entry.key.split('-');
      if (parts.length < 2) continue;
      final year = int.tryParse(parts[0]);
      if (year != now.year) continue;
      for (final expense in entry.value) {
        spentByCategory[expense.category] =
            (spentByCategory[expense.category] ?? 0) + expense.amount;
      }
    }
    for (final expense in actualExpenses) {
      if (expense.date.year == now.year) {
        spentByCategory[expense.category] =
            (spentByCategory[expense.category] ?? 0) + expense.amount;
      }
    }
    final foodSpent = purchaseHistory.records
        .where((r) => r.date.year == now.year)
        .fold(0.0, (s, r) => s + r.amount);
    if (foodSpent > 0) {
      spentByCategory['alimentacao'] =
          (spentByCategory['alimentacao'] ?? 0) + foodSpent;
    }

    final deductionSystem = getTaxDeductionSystem(settings.country);
    if (deductionSystem == null) return const SizedBox.shrink();

    final familyType = FamilyType.fromMaritalStatus(
      settings.personalInfo.maritalStatus.jsonValue,
      settings.personalInfo.dependentes,
    );

    final deductionSummary = deductionSystem.calculate(
      spentByCategory: spentByCategory,
      year: now.year,
      familyType: familyType,
    );

    return TaxDeductionCard(
      summary: deductionSummary,
      onSeeDetail: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TaxDeductionDetailScreen(summary: deductionSummary),
        ),
      ),
    );
  }

  // ───────────────────────── Budget vs Actual ──────────────────────────────

  Widget _buildBudgetVsActualCard(BuildContext context) {
    final l10n = S.of(context);
    final now = DateTime.now();
    final foodSpent = purchaseHistory.spentInMonth(now.year, now.month);
    final summaries = CategoryBudgetSummary.buildSummaries(
      settings.expenses,
      actualExpenses,
      monthlyBudgets: monthlyBudgets,
      foodPurchaseSpent: foodSpent,
      now: now,
    );
    final totalBudgeted = summaries.fold(0.0, (s, e) => s + e.budgeted);
    final totalActual = summaries.fold(0.0, (s, e) => s + e.actual);

    final unsetCount = settings.expenses
        .where((e) =>
            e.enabled && e.amount == 0 && !monthlyBudgets.containsKey(e.category))
        .map((e) => e.category)
        .toSet()
        .length;

    final visible =
        summaries.where((s) => s.actual > 0 || s.budgeted > 0).take(6).toList();

    return CalmCard(
      key: DashboardTourKeys.budgetVsActual,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.compare_arrows,
                    size: 16, color: AppColors.ink70(context)),
                const SizedBox(width: 8),
                Expanded(
                  child: CalmEyebrow(l10n.expenseTrackerTitle.toUpperCase()),
                ),
                InfoIconButton(
                    title: l10n.expenseTrackerTitle,
                    body: l10n.infoBudgetVsActual),
                TextButton(
                  onPressed: onOpenExpenseTracker,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent(context),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(48, 40),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  child: Text(l10n.expenseTrackerViewAll),
                ),
              ],
            ),
            if (unsetCount > 0) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onOpenSettings,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warn(context).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.warn(context).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 14, color: AppColors.warn(context)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.unsetBudgetsWarning(unsetCount),
                          style: TextStyle(
                              fontSize: 11, color: AppColors.warn(context)),
                        ),
                      ),
                      Text(
                        l10n.unsetBudgetsCta,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warn(context)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (visible.isEmpty) ...[
              const SizedBox(height: 12),
              Text(
                l10n.expenseTrackerNoExpenses,
                style:
                    TextStyle(fontSize: 13, color: AppColors.ink50(context)),
              ),
            ] else ...[
              const SizedBox(height: 12),
              ...visible.map((s) {
                final progressColor = s.isOver
                    ? AppColors.bad(context)
                    : s.progress > 0.8
                        ? AppColors.warn(context)
                        : AppColors.ok(context);
                return InkWell(
                  onTap: widget.onOpenExpenseTracker,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _budgetCategoryIcon(s.category,
                                customCategories: widget.customCategories),
                            size: 14,
                            color: AppColors.ink70(context),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _budgetCategoryLabel(s.category, l10n),
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.ink(context)),
                            ),
                          ),
                          if (s.isOverPace && !s.isOver)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.trending_up,
                                size: 12,
                                color: s.paceSeverity == 'warning'
                                    ? AppColors.warn(context)
                                    : AppColors.bad(context),
                              ),
                            ),
                          Text(
                            s.isOver
                                ? '-${formatCurrency(s.remaining.abs())}'
                                : formatCurrency(s.remaining),
                            style: CalmText.amount(context, size: 12).copyWith(
                              color: s.isOver
                                  ? AppColors.bad(context)
                                  : AppColors.ok(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: s.progress.clamp(0.0, 1.0),
                        backgroundColor: AppColors.line(context),
                        color: progressColor,
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${formatCurrency(s.actual)} / ${formatCurrency(s.budgeted)}',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.ink50(context)),
                          ),
                          if (s.isOverPace && s.budgeted > 0)
                            Text(
                              l10n.paceProjected(
                                  formatCurrency(s.projectedTotal)),
                              style: TextStyle(
                                fontSize: 10,
                                color: s.paceSeverity == 'warning'
                                    ? AppColors.warn(context)
                                    : AppColors.bad(context),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  ),
                );
              }),
              Divider(height: 16, color: AppColors.line(context)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n.expenseTrackerBudgeted}: ${formatCurrency(totalBudgeted)}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink70(context)),
                  ),
                  Text(
                    '${l10n.expenseTrackerActual}: ${formatCurrency(totalActual)}',
                    style: CalmText.amount(context, size: 12).copyWith(
                      color: totalActual > totalBudgeted
                          ? AppColors.bad(context)
                          : AppColors.ink(context),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
  }

  static IconData _budgetCategoryIcon(
    String catName, {
    List<CustomCategory>? customCategories,
  }) {
    return categoryIconByName(catName, customCategories: customCategories);
  }

  static String _budgetCategoryLabel(String catName, S l10n) {
    try {
      final cat = ExpenseCategory.values.firstWhere((c) => c.name == catName);
      return cat.localizedLabel(l10n);
    } catch (_) {
      return catName;
    }
  }

  // ───────────────────────── Purchase History ──────────────────────────────

  Widget _buildPurchaseHistoryCard(BuildContext context) {
    final l10n = S.of(context);
    final recent = purchaseHistory.records.take(5).toList();
    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 16, color: AppColors.ink70(context)),
              const SizedBox(width: 8),
              Expanded(
                child: CalmEyebrow(
                    l10n.dashboardPurchaseHistory.toUpperCase()),
              ),
              TextButton(
                onPressed: () => _showAllHistory(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent(context),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(48, 40),
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
                child: Text(l10n.dashboardViewAll),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < recent.length; i++) ...[
            if (i > 0) Divider(color: AppColors.line(context), height: 1),
            _purchaseHistoryRow(context, recent[i], l10n),
          ],
        ],
      ),
    );
  }

  Widget _purchaseHistoryRow(BuildContext context, PurchaseRecord r, S l10n) {
    final summary = r.items.isNotEmpty
        ? (r.items.take(3).join(', ') + (r.items.length > 3 ? '...' : ''))
        : l10n.dashboardProductCount(r.itemCount);
    return InkWell(
      onTap: () => _showAllHistory(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.bgSunk(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${r.date.day}/${r.date.month}',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink70(context)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dashboardProductCount(r.itemCount),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink(context)),
                ),
                Text(
                  summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12, color: AppColors.ink50(context)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatCurrency(r.amount),
            style: CalmText.amount(context, size: 14),
          ),
        ],
      ),
      ),
    );
  }

  void _showAllHistory(BuildContext context) {
    final expandedMap = <int, bool>{};
    CalmBottomSheet.show<void>(
      context,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (innerContext, scrollController) => StatefulBuilder(
          builder: (ctx, setLocalState) => CalmBottomSheetContent(
            title: S.of(context).dashboardAllPurchases,
            // Cap at half the screen height — leaves room for the sheet
            // title + handle + bottom inset without overflowing in narrow
            // viewports (widget tests use 800x600 by default).
            child: SizedBox(
              height: MediaQuery.of(innerContext).size.height * 0.45,
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
                itemCount: purchaseHistory.records.length,
                itemBuilder: (itemContext, i) {
                  final r = purchaseHistory.records[i];
                  final isExpanded = expandedMap[i] ?? false;
                  return Semantics(
                    button: true,
                    label: S.of(context).dashboardPurchaseLabel(
                          '${r.date.day}/${r.date.month}/${r.date.year}',
                          formatCurrency(r.amount),
                        ),
                    child: Material(
                      color: AppColors.card(itemContext),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => setLocalState(
                            () => expandedMap[i] = !isExpanded),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.line(itemContext)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${r.date.day}/${r.date.month}/${r.date.year}',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.ink70(itemContext)),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        formatCurrency(r.amount),
                                        style: CalmText.amount(itemContext,
                                            size: 15),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        isExpanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        size: 18,
                                        color: AppColors.ink50(itemContext),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (!isExpanded)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    S.of(context)
                                        .dashboardProductCount(r.itemCount),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.ink50(itemContext)),
                                  ),
                                ),
                              if (isExpanded && r.items.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                ...r.items.map((name) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 3),
                                      child: Row(
                                        children: [
                                          Icon(Icons.circle,
                                              size: 4,
                                              color: AppColors.ink50(
                                                  itemContext)),
                                          const SizedBox(width: 8),
                                          Text(name,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: AppColors.ink70(
                                                      itemContext))),
                                        ],
                                      ),
                                    )),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── Expenses Breakdown ────────────────────────────

  Widget _buildExpensesBreakdown(BuildContext context, S l10n) {
    final activeExpenses =
        settings.expenses.where((e) => e.enabled && e.amount > 0).toList();
    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CalmEyebrow(
                    l10n.dashboardMonthlyExpenses.toUpperCase()),
              ),
              InfoIconButton(
                  title: l10n.dashboardMonthlyExpenses,
                  body: l10n.infoExpensesBreakdown),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < activeExpenses.length; i++) ...[
            if (i > 0) Divider(color: AppColors.line(context), height: 1),
            InkWell(
              onTap: widget.onOpenRecurringExpenses,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _categoryColor(activeExpenses[i].category),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              activeExpenses[i].label,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.ink(context)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              categoryLabel(activeExpenses[i].category),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.ink50(context)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatCurrency(activeExpenses[i].amount),
                      style: CalmText.amount(context, size: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.line(context)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.dashboardTotal,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink70(context)),
              ),
              Text(
                formatCurrency(summary.totalExpenses),
                style: CalmText.amount(context, size: 14, weight: FontWeight.w700)
                    .copyWith(color: AppColors.bad(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _categoryColor(String category) =>
      AppColors.categoryColorByName(category);
}

// ───────────────────────── Summary Card ────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? sublabel;
  final Color Function(BuildContext) accent;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    this.sublabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = accent(context);
    return CalmCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.ink50(context)),
          ),
          const SizedBox(height: 2),
          Text(value, style: CalmText.amount(context, size: 16, weight: FontWeight.w700)),
          if (sublabel != null) ...[
            const SizedBox(height: 4),
            Text(
              sublabel!,
              style: TextStyle(
                  fontSize: 10, color: AppColors.ink50(context)),
            ),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────── Stress Index ────────────────────────────────────

class _StressIndexCard extends StatefulWidget {
  final StressIndexResult result;
  final VoidCallback? onShowTrend;
  const _StressIndexCard({super.key, required this.result, this.onShowTrend});

  @override
  State<_StressIndexCard> createState() => _StressIndexCardState();
}

class _StressIndexCardState extends State<_StressIndexCard> {
  bool _expanded = false;

  String _localizedValueLabel(StressFactorResult f, S l10n) {
    switch (f.type) {
      case StressFactorType.food:
        return f.valueLabel.isEmpty
            ? l10n.stressNA
            : l10n.stressUsed(f.valueLabel);
      case StressFactorType.stability:
        return f.valueLabel == 'stable' ? l10n.stressStable : l10n.stressHigh;
      default:
        return f.valueLabel;
    }
  }

  Color _scoreColor(BuildContext context, int score) {
    if (score >= 60) return AppColors.ok(context);
    if (score >= 40) return AppColors.warn(context);
    return AppColors.bad(context);
  }

  String _statusLabel(BuildContext context, int score, S l10n) {
    if (score >= 60) return l10n.dashboardBurnRateOnTrack;
    // TODO(l10n): move to ARB (Wave H)
    if (score >= 40) return 'atenção';
    return l10n.dashboardBurnRateOver;
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final l10n = S.of(context);
    final color = _scoreColor(context, result.score);

    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CalmEyebrow(l10n.dashboardStressIndex.toUpperCase()),
                    const SizedBox(height: 6),
                    Text(
                      '${result.score}',
                      style: CalmText.amount(context,
                              size: 32, weight: FontWeight.w700)
                          .copyWith(color: color),
                    ),
                    if (result.delta != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          l10n.dashboardVsLastMonth(
                              '${result.delta! >= 0 ? "↑" : "↓"} ${result.delta!.abs().toStringAsFixed(1)}'),
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.ink50(context)),
                        ),
                      ),
                  ],
                ),
              ),
              CalmPill(
                label: _statusLabel(context, result.score, l10n),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                ),
                label: Text(_expanded ? l10n.close : l10n.dashboardDetails),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.ink70(context),
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                  minimumSize: const Size(48, 40),
                ),
              ),
              if (widget.onShowTrend != null) ...[
                Container(
                  width: 1,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: AppColors.line(context),
                ),
                TextButton.icon(
                  onPressed: widget.onShowTrend,
                  icon: const Icon(Icons.show_chart, size: 14),
                  label: Text(l10n.trendTitle),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent(context),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500),
                    minimumSize: const Size(48, 40),
                  ),
                ),
              ],
            ],
          ),
          if (_expanded) ...[
            Divider(height: 1, color: AppColors.line(context)),
            const SizedBox(height: 10),
            ...result.factors.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        f.ok
                            ? Icons.check_circle_outline
                            : Icons.warning_amber_outlined,
                        size: 16,
                        color: f.ok
                            ? AppColors.ok(context)
                            : AppColors.warn(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          f.type.localizedLabel(l10n),
                          style: TextStyle(
                              fontSize: 13, color: AppColors.ink70(context)),
                        ),
                      ),
                      Text(
                        _localizedValueLabel(f, l10n),
                        style: CalmText.amount(context, size: 13),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────── Salary Row ──────────────────────────────────────

class _SalaryRow extends StatelessWidget {
  final String label;
  final SalaryCalculation calc;
  const _SalaryRow({required this.label, required this.calc});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final hasMeal = calc.mealAllowance.totalMonthly > 0;
    final hasSubsidy = calc.subsidyMonthlyBonus > 0;
    final hasExempt = calc.otherExemptIncome > 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSunk(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink70(context)),
              ),
              Text(
                formatCurrency(calc.totalNetWithMeal),
                style: CalmText.amount(context, size: 14, weight: FontWeight.w700)
                    .copyWith(color: AppColors.ok(context)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasSubsidy
                          ? l10n.dashboardGrossWithSubsidy
                          : l10n.dashboardGross,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink50(context)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatCurrency(calc.effectiveGrossAmount),
                      style: CalmText.amount(context, size: 11),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dashboardIrsRate(formatPercentage(calc.irsRate)),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink50(context)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '-${formatCurrency(calc.irsRetention)}',
                      style: CalmText.amount(context, size: 11)
                          .copyWith(color: AppColors.bad(context)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dashboardSsRate,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink50(context)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '-${formatCurrency(calc.socialSecurity)}',
                      style: CalmText.amount(context, size: 11)
                          .copyWith(color: AppColors.warn(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasMeal) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: AppColors.line(context)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.dashboardMealAllowance,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink50(context)),
                  ),
                  Text(
                    '+${formatCurrency(calc.mealAllowance.netMealAllowance)}',
                    style: CalmText.amount(context, size: 11)
                        .copyWith(color: AppColors.ok(context)),
                  ),
                ],
              ),
            ),
          ],
          if (hasExempt) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.dashboardExemptIncome,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink50(context)),
                ),
                Text(
                  '+${formatCurrency(calc.otherExemptIncome)}',
                  style: CalmText.amount(context, size: 11)
                      .copyWith(color: AppColors.ok(context)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ExemptIncomeRow extends StatelessWidget {
  final String label;
  final double amount;
  const _ExemptIncomeRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgSunk(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink70(context)),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.dashboardExemptIncome,
                style: TextStyle(
                    fontSize: 10, color: AppColors.ink50(context)),
              ),
            ],
          ),
          Text(
            '+${formatCurrency(amount)}',
            style: CalmText.amount(context, size: 13)
                .copyWith(color: AppColors.ok(context)),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Month Review Card ───────────────────────────────

class _MonthReviewCard extends StatelessWidget {
  final MonthReviewResult review;
  final VoidCallback onTap;

  const _MonthReviewCard({required this.review, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isOver = review.totalDifference > 0;
    return Semantics(
      button: true,
      label: l10n.dashboardViewMonthSummary,
      child: CalmCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment_outlined,
                    size: 16, color: AppColors.ink70(context)),
                const SizedBox(width: 8),
                Expanded(
                  child: CalmEyebrow(
                    '${review.monthLabel.toUpperCase()} ${l10n.dashboardSummaryLabel.toUpperCase()}',
                  ),
                ),
                InfoIconButton(
                    title: l10n.monthReview, body: l10n.infoCharts),
                Icon(Icons.chevron_right,
                    size: 18, color: AppColors.ink70(context)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.monthReviewPlanned,
                        style: TextStyle(
                            fontSize: 10, color: AppColors.ink70(context)),
                      ),
                      Text(
                        formatCurrency(review.totalPlanned),
                        style: CalmText.amount(context, size: 14).copyWith(
                            color: AppColors.ink70(context)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.monthReviewActual,
                        style: TextStyle(
                            fontSize: 10, color: AppColors.ink70(context)),
                      ),
                      Text(
                        formatCurrency(review.totalActual),
                        style: CalmText.amount(context, size: 14),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.monthReviewDifference,
                        style: TextStyle(
                            fontSize: 10, color: AppColors.ink70(context)),
                      ),
                      Text(
                        '${isOver ? '+' : ''}${formatCurrency(review.totalDifference)}',
                        style: CalmText.amount(context,
                                size: 14, weight: FontWeight.w700)
                            .copyWith(
                          color: isOver
                              ? AppColors.bad(context)
                              : AppColors.ok(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
