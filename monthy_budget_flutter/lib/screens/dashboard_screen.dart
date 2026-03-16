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
import '../utils/category_helpers.dart';
import '../utils/formatters.dart';
import '../utils/stress_index.dart';
import '../utils/budget_streaks.dart';
import '../data/tax/tax_system.dart';
import '../data/tax/tax_deductions.dart';
import '../widgets/charts/budget_charts.dart';
import '../widgets/trend_sheet.dart';
import '../widgets/tax_deduction_card.dart';
import '../widgets/upcoming_bills_card.dart';
import '../widgets/budget_streak_card.dart';
import '../models/local_dashboard_config.dart';
import '../models/expense_snapshot.dart';
import '../utils/month_review.dart';
import '../widgets/month_review_sheet.dart';
import '../models/savings_goal.dart';
import '../widgets/savings_goal_card.dart';
import '../widgets/info_icon_button.dart';
import '../utils/savings_projections.dart';
import '../onboarding/dashboard_tour.dart';
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
  final List<CustomCategory> customCategories;

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
    this.customCategories = const [],
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _tourShown = false;
  TutorialCoachMark? _activeTour;

  // Convenience accessors so helper methods don't need widget. prefix everywhere
  AppSettings get settings => widget.settings;
  BudgetSummary get summary => widget.summary;
  PurchaseHistory get purchaseHistory => widget.purchaseHistory;
  LocalDashboardConfig get dashboardConfig => widget.dashboardConfig;
  Map<String, List<ExpenseSnapshot>> get expenseHistory => widget.expenseHistory;
  List<ActualExpense> get actualExpenses => widget.actualExpenses;
  List<SavingsGoal> get savingsGoals => widget.savingsGoals;
  Map<String, SavingsProjection> get savingsProjections => widget.savingsProjections;
  Map<String, double> get monthlyBudgets => widget.monthlyBudgets;
  List<RecurringExpense> get recurringExpenses => widget.recurringExpenses;
  Map<String, List<ActualExpense>> get actualExpenseHistory => widget.actualExpenseHistory;
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
          Future.delayed(const Duration(milliseconds: 500), () {
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

    // Stress Index — calculate and persist if changed
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

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                color: AppColors.surface(context),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.dashboardTitle,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary(context),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.dashboardFinancialSummary,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary(context),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.onOpenCoach != null)
                                Semantics(
                                  button: true,
                                  label: l10n.coachTitle,
                                  child: Material(
                                    color: AppColors.background(context),
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      onTap: widget.onOpenCoach,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppColors.border(context)),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(Icons.psychology, size: 20, color: AppColors.primary(context)),
                                      ),
                                    ),
                                  ),
                                ),
                              if (widget.onOpenCoach != null) const SizedBox(width: 8),
                              Semantics(
                                button: true,
                                label: l10n.dashboardOpenSettings,
                                child: Material(
                                  color: AppColors.background(context),
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: onOpenSettings,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.border(context)),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.settings, size: 20, color: AppColors.textSecondary(context)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (hasData && dashboardConfig.showHeroCard) _buildHeroCard(context, isPositive, l10n)
                    else if (!hasData) _buildEmptyState(context, l10n),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              if (hasData) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      for (final cardId in dashboardConfig.cardOrder)
                        if (cardId != 'heroCard')
                          ..._buildCardById(cardId, context, stressResult, monthReview, l10n),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

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
            onShowTrend: stressResult.score > 0 ? () {
              showTrendSheet(
                context: context,
                stressHistory: settings.stressHistory,
                expenseHistory: expenseHistory,
                currentTotalExpenses: summary.totalExpenses,
              );
            } : null,
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
      case 'monthReview':
        if (monthReview == null) return const [];
        return [
          _MonthReviewCard(
            review: monthReview,
            onTap: () => showMonthReviewSheet(context: context, review: monthReview),
          ),
          const SizedBox(height: 16),
        ];
      case 'upcomingBills':
        if (!recurringExpenses.any((r) => r.isActive && r.dayOfMonth != null)) return const [];
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
        return [_buildTopCategoriesCard(context, l10n), const SizedBox(height: 16)];
      case 'cashFlowForecast':
        return [_buildCashFlowForecastCard(context, l10n), const SizedBox(height: 16)];
      case 'savingsRate':
        return [_buildSavingsRateCard(context, l10n), const SizedBox(height: 16)];
      case 'coachInsight':
        if (widget.onOpenCoach == null) return const [];
        return [_buildCoachInsightCard(context, l10n), const SizedBox(height: 16)];
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
        return [_buildPurchaseHistoryCard(context), const SizedBox(height: 16)];
      case 'expensesBreakdown':
        if (summary.totalExpenses <= 0) return const [];
        return [_buildExpensesBreakdown(context, l10n), const SizedBox(height: 16)];
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

  Widget _buildNextActionsCard(BuildContext context, S l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsDashQuickActions,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
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
        foregroundColor: AppColors.textPrimary(context),
        side: BorderSide(color: AppColors.border(context)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, bool isPositive, S l10n) {
    return Semantics(
      key: DashboardTourKeys.heroCard,
      label: l10n.dashboardHeroLabel(formatCurrency(summary.netLiquidity), isPositive ? l10n.dashboardPositiveBalance : l10n.dashboardNegativeBalance),
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceVariant(context)),
      ),
      child: Column(
        children: [
          Text(
            l10n.dashboardMonthlyLiquidity,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary(context),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatCurrency(summary.netLiquidity),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: isPositive ? AppColors.success(context) : AppColors.error(context),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isPositive ? AppColors.successBackground(context) : AppColors.errorBackground(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  size: 13,
                  color: isPositive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                ),
                const SizedBox(width: 4),
                Text(
                  isPositive ? l10n.dashboardPositiveBalance : l10n.dashboardNegativeBalance,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildEmptyState(BuildContext context, S l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.infoBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.infoBorder(context)),
      ),
      child: Column(
        children: [
          Icon(Icons.monetization_on_outlined, size: 40, color: Colors.blue.shade200),
          const SizedBox(height: 12),
          Text(
            l10n.dashboardConfigureData,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textLabel(context)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onOpenSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(context),
              foregroundColor: AppColors.onPrimary(context),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
            child: Text(l10n.dashboardOpenSettingsButton, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // ── Burn Rate Card ──
  Widget _buildBurnRateCard(BuildContext context, S l10n) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysPassed = now.day;
    final daysRemaining = daysInMonth - daysPassed;
    final totalBudget = summary.totalNetWithMeal;
    final spent = summary.totalExpenses;
    final remaining = totalBudget - spent;
    final dailyAvgSpend = daysPassed > 0 ? spent / daysPassed : 0.0;
    final dailyBudgetAllowance = daysRemaining > 0 ? remaining / daysRemaining : 0.0;
    final isOverBudget = remaining < 0;
    final paceLabel = dailyAvgSpend <= (totalBudget / daysInMonth)
        ? l10n.dashboardBurnRateOnTrack
        : l10n.dashboardBurnRateOver;
    final paceColor = dailyAvgSpend <= (totalBudget / daysInMonth)
        ? const Color(0xFF34D399)
        : AppColors.error(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceVariant(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.speed, size: 18, color: paceColor),
            const SizedBox(width: 8),
            Text(l10n.dashboardBurnRateTitle, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textLabel(context))),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: paceColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
              child: Text(paceLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: paceColor)),
            ),
          ]),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: totalBudget > 0 ? (spent / totalBudget).clamp(0.0, 1.0) : 0.0,
              backgroundColor: AppColors.surfaceVariant(context),
              color: isOverBudget ? AppColors.error(context) : AppColors.primary(context),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _miniStat(l10n.dashboardBurnRateDailyAvg, formatCurrency(dailyAvgSpend), context)),
            Expanded(child: _miniStat(l10n.dashboardBurnRateAllowance, formatCurrency(dailyBudgetAllowance > 0 ? dailyBudgetAllowance : 0), context)),
            Expanded(child: _miniStat(l10n.dashboardBurnRateDaysLeft, '$daysRemaining', context)),
          ]),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 9, color: AppColors.textMuted(context))),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
      ],
    );
  }

  // ── Top Categories Card ──
  Widget _buildTopCategoriesCard(BuildContext context, S l10n) {
    final categoryTotals = <String, double>{};
    for (final e in actualExpenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }
    final sorted = categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();
    final total = summary.totalExpenses;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceVariant(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.pie_chart_outline, size: 18, color: AppColors.primary(context)),
            const SizedBox(width: 8),
            Text(l10n.dashboardTopCategoriesTitle, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textLabel(context))),
          ]),
          const SizedBox(height: 12),
          ...top.map((entry) {
            final pct = total > 0 ? entry.value / total : 0.0;
            final budgetAmount = monthlyBudgets[entry.key] ?? 0;
            final overBudget = budgetAmount > 0 && entry.value > budgetAmount;
            final barColor = overBudget
                ? AppColors.error(context)
                : pct > 0.3
                    ? Colors.amber.shade600
                    : AppColors.primary(context);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(categoryIconByName(entry.key, customCategories: widget.customCategories), size: 14, color: AppColors.textSecondary(context)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(_budgetCategoryLabel(entry.key, l10n), style: TextStyle(fontSize: 11, color: AppColors.textSecondary(context)))),
                    Text(formatCurrency(entry.value), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context))),
                    const SizedBox(width: 6),
                    Text('${(pct * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 10, color: AppColors.textMuted(context))),
                  ]),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: pct.clamp(0.0, 1.0),
                      backgroundColor: AppColors.surfaceVariant(context),
                      color: barColor,
                      minHeight: 3,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Cash Flow Forecast Card ──
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
        .where((r) => r.isActive && r.dayOfMonth != null && r.dayOfMonth! > daysPassed)
        .fold(0.0, (sum, r) => sum + r.amount);
    final dailyDiscretionary = daysPassed > 0
        ? (currentSpent - (recurringTotal - recurringRemaining)).clamp(0.0, double.infinity) / daysPassed
        : 0.0;
    final projectedSpend = currentSpent + recurringRemaining + (dailyDiscretionary * daysRemaining);
    final projectedBalance = monthlyIncome - projectedSpend;
    final isPositive = projectedBalance >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceVariant(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.trending_up, size: 18, color: isPositive ? const Color(0xFF34D399) : AppColors.error(context)),
            const SizedBox(width: 8),
            Text(l10n.dashboardCashFlowTitle, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textLabel(context))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _miniStat(l10n.dashboardCashFlowProjectedSpend, formatCurrency(projectedSpend), context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.dashboardCashFlowEndOfMonth, style: TextStyle(fontSize: 9, color: AppColors.textMuted(context))),
                  const SizedBox(height: 2),
                  Text(
                    formatCurrency(projectedBalance),
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: isPositive ? const Color(0xFF34D399) : AppColors.error(context),
                    ),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 8),
          if (recurringRemaining > 0)
            Text(
              l10n.dashboardCashFlowPendingBills(formatCurrency(recurringRemaining)),
              style: TextStyle(fontSize: 10, color: AppColors.textMuted(context)),
            ),
        ],
      ),
    );
  }

  // ── Savings Rate Card ──
  Widget _buildSavingsRateCard(BuildContext context, S l10n) {
    final currentRate = summary.savingsRate;
    final saved = summary.netLiquidity > 0 ? summary.netLiquidity : 0.0;
    final rateColor = currentRate >= 20
        ? const Color(0xFF34D399)
        : currentRate >= 10
            ? Colors.amber.shade600
            : AppColors.error(context);

    // Build 6-month trend from actualExpenseHistory
    final now = DateTime.now();
    final monthRates = <String, double>{};
    for (int i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      final key = '${m.year}-${m.month.toString().padLeft(2, '0')}';
      final expenses = actualExpenseHistory[key];
      if (expenses != null && expenses.isNotEmpty) {
        final totalSpent = expenses.fold(0.0, (s, e) => s + e.amount);
        final income = summary.totalNetWithMeal;
        monthRates[key] = income > 0 ? ((income - totalSpent) / income * 100).clamp(-100, 100) : 0;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceVariant(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.savings_outlined, size: 18, color: rateColor),
            const SizedBox(width: 8),
            Text(l10n.dashboardSavingsRateTitle, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textLabel(context))),
            const Spacer(),
            Text(
              '${currentRate.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: rateColor),
            ),
          ]),
          const SizedBox(height: 8),
          Text(
            l10n.dashboardSavingsRateSaved(formatCurrency(saved)),
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary(context)),
          ),
          if (monthRates.length > 1) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: monthRates.entries.map((e) {
                  final barHeight = (e.value.clamp(0, 100) / 100 * 36).clamp(2.0, 36.0);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: e.value >= 20
                                  ? const Color(0xFF34D399).withValues(alpha: 0.6)
                                  : e.value >= 0
                                      ? Colors.amber.withValues(alpha: 0.6)
                                      : AppColors.error(context).withValues(alpha: 0.6),
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

  // ── AI Coach Insight Card ──
  Widget _buildCoachInsightCard(BuildContext context, S l10n) {
    // Generate a contextual insight based on current data
    String insight;
    IconData insightIcon;
    if (summary.savingsRate < 10 && summary.totalExpenses > 0) {
      insight = l10n.dashboardCoachLowSavings;
      insightIcon = Icons.warning_amber;
    } else if (summary.totalExpenses > summary.totalNetWithMeal * 0.9) {
      insight = l10n.dashboardCoachHighSpending;
      insightIcon = Icons.trending_down;
    } else if (summary.savingsRate >= 20) {
      insight = l10n.dashboardCoachGoodSavings;
      insightIcon = Icons.emoji_events;
    } else {
      insight = l10n.dashboardCoachGeneral;
      insightIcon = Icons.lightbulb_outline;
    }

    return GestureDetector(
      onTap: widget.onOpenCoach,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary(context).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(insightIcon, size: 20, color: AppColors.primary(context)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.dashboardCoachInsightTitle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary(context))),
                  const SizedBox(height: 4),
                  Text(insight, style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context))),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(S l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.account_balance_wallet,
                label: l10n.dashboardGrossIncome,
                value: formatCurrency(summary.totalGross),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.arrow_circle_up,
                label: l10n.dashboardNetIncome,
                value: formatCurrency(summary.totalNetWithMeal),
                sublabel: summary.totalMealAllowance > 0
                    ? l10n.dashboardInclMealAllowance(formatCurrency(summary.totalMealAllowance))
                    : null,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.arrow_circle_down,
                label: l10n.dashboardDeductions,
                value: formatCurrency(summary.totalDeductions),
                sublabel: l10n.dashboardIrsSs(formatCurrency(summary.totalIRS), formatCurrency(summary.totalSS)),
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.savings,
                label: l10n.dashboardSavingsRate,
                value: formatPercentage(summary.savingsRate > 0 ? summary.savingsRate : 0),
                sublabel: l10n.dashboardExpensesAmount(formatCurrency(summary.totalExpenses)),
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalaryBreakdown(BuildContext context, S l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceVariant(context)),
        boxShadow: [
          BoxShadow(color: AppColors.shimmer(context), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.dashboardSalaryDetail,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary(context), letterSpacing: 0.5),
                ),
              ),
              InfoIconButton(title: l10n.dashboardSalaryDetail, body: l10n.infoSalaryBreakdown),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(summary.salaries.length, (i) {
            final calc = summary.salaries[i];
            final hasGross = calc.effectiveGrossAmount > 0;
            final hasAnyIncome = hasGross || calc.otherExemptIncome > 0;
            if (!hasAnyIncome) return const SizedBox.shrink();
            final label = i < settings.salaries.length && settings.salaries[i].label.isNotEmpty
                ? settings.salaries[i].label
                : l10n.dashboardSalaryN(i + 1);
            return Padding(
              padding: EdgeInsets.only(top: i > 0 ? 12 : 0),
              child: hasGross
                  ? _SalaryRow(label: label, calc: calc)
                  : _ExemptIncomeRow(label: label, amount: calc.otherExemptIncome),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildViewTrendsButton(BuildContext context, S l10n) {
    return Material(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onViewTrends,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            children: [
              Icon(Icons.trending_up, size: 20, color: AppColors.primary(context)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.expenseTrends,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaxSimulatorButton(BuildContext context, S l10n) {
    return Material(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TaxSimulatorScreen(settings: settings),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            children: [
              Icon(Icons.calculate_outlined, size: 20, color: AppColors.primary(context)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.taxSimButton,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaxDeductionCard(BuildContext context) {
    final now = DateTime.now();
    // Aggregate spending by category for the current tax year (Jan-Dec)
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
    // Also include current month actuals
    for (final expense in actualExpenses) {
      if (expense.date.year == now.year) {
        spentByCategory[expense.category] =
            (spentByCategory[expense.category] ?? 0) + expense.amount;
      }
    }
    // Include food purchases
    final foodSpent = purchaseHistory.records
        .where((r) => r.date.year == now.year)
        .fold(0.0, (s, r) => s + r.amount);
    if (foodSpent > 0) {
      spentByCategory['alimentacao'] =
          (spentByCategory['alimentacao'] ?? 0) + foodSpent;
    }

    final deductionSystem = getTaxDeductionSystem(settings.country);
    if (deductionSystem == null) return const SizedBox.shrink();

    final deductionSummary = deductionSystem.calculate(
      spentByCategory: spentByCategory,
      year: now.year,
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

    // Count expenses with zero default and no monthly override
    final unsetCount = settings.expenses
        .where((e) => e.enabled && e.amount == 0 && !monthlyBudgets.containsKey(e.category))
        .map((e) => e.category)
        .toSet()
        .length;

    return Container(
      key: DashboardTourKeys.budgetVsActual,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows,
                  size: 16, color: AppColors.textSecondary(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.expenseTrackerTitle,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary(context),
                      letterSpacing: 0.8),
                ),
              ),
              InfoIconButton(title: l10n.expenseTrackerTitle, body: l10n.infoBudgetVsActual),
              TextButton(
                onPressed: onOpenExpenseTracker,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary(context),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warningBackground(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning(context).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: AppColors.warning(context)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.unsetBudgetsWarning(unsetCount),
                        style: TextStyle(fontSize: 11, color: AppColors.warning(context)),
                      ),
                    ),
                    Text(
                      l10n.unsetBudgetsCta,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning(context)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (actualExpenses.isEmpty && foodSpent == 0) ...[
            const SizedBox(height: 12),
            Text(
              l10n.expenseTrackerNoExpenses,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
            ),
          ] else ...[
            const SizedBox(height: 12),
            ...summaries.where((s) => s.actual > 0 || s.budgeted > 0).take(6).map((s) {
              final progressColor = s.isOver
                  ? AppColors.error(context)
                  : s.progress > 0.8
                      ? AppColors.warning(context)
                      : AppColors.success(context);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_budgetCategoryIcon(s.category, customCategories: widget.customCategories),
                            size: 14, color: AppColors.textSecondary(context)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _budgetCategoryLabel(s.category, l10n),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary(context)),
                          ),
                        ),
                        if (s.isOverPace && !s.isOver)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.trending_up,
                              size: 12,
                              color: s.paceSeverity == 'warning'
                                  ? AppColors.warning(context)
                                  : AppColors.error(context),
                            ),
                          ),
                        Text(
                          s.isOver
                              ? '-${formatCurrency(s.remaining.abs())}'
                              : formatCurrency(s.remaining),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: s.isOver
                                ? AppColors.error(context)
                                : AppColors.success(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: s.progress.clamp(0.0, 1.0),
                      backgroundColor: AppColors.border(context),
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
                              fontSize: 10, color: AppColors.textMuted(context)),
                        ),
                        if (s.isOverPace && s.budgeted > 0)
                          Text(
                            l10n.paceProjected(formatCurrency(s.projectedTotal)),
                            style: TextStyle(
                              fontSize: 10,
                              color: s.paceSeverity == 'warning'
                                  ? AppColors.warning(context)
                                  : AppColors.error(context),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            Divider(height: 16, color: AppColors.border(context)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.expenseTrackerBudgeted}: ${formatCurrency(totalBudgeted)}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context)),
                ),
                Text(
                  '${l10n.expenseTrackerActual}: ${formatCurrency(totalActual)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: totalActual > totalBudgeted
                        ? AppColors.error(context)
                        : AppColors.textPrimary(context),
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

  Widget _buildPurchaseHistoryCard(BuildContext context) {
    final recent = purchaseHistory.records.take(5).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 16, color: AppColors.textSecondary(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  S.of(context).dashboardPurchaseHistory,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary(context),
                      letterSpacing: 0.8),
                ),
              ),
              TextButton(
                onPressed: () => _showAllHistory(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary(context),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(48, 40),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                child: Text(S.of(context).dashboardViewAll),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recent.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.background(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${r.date.day}/${r.date.month}',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary(context)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).dashboardProductCount(r.itemCount),
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary(context)),
                          ),
                          if (r.items.isNotEmpty)
                            Text(
                              r.items.take(3).join(', ') +
                                  (r.items.length > 3 ? '...' : ''),
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.textMuted(context)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Text(
                      formatCurrency(r.amount),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showAllHistory(BuildContext context) {
    final expandedMap = <int, bool>{};
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (sheetContext, scrollController) => StatefulBuilder(
          builder: (ctx, setLocalState) => Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.borderMuted(sheetContext),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    S.of(context).dashboardAllPurchases,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary(sheetContext)),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  itemCount: purchaseHistory.records.length,
                  itemBuilder: (itemContext, i) {
                    final r = purchaseHistory.records[i];
                    final isExpanded = expandedMap[i] ?? false;
                    return Semantics(
                      button: true,
                      label: S.of(context).dashboardPurchaseLabel('${r.date.day}/${r.date.month}/${r.date.year}', formatCurrency(r.amount)),
                      child: Material(
                      color: AppColors.background(itemContext),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                      onTap: () =>
                          setLocalState(() => expandedMap[i] = !isExpanded),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border(itemContext)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${r.date.day}/${r.date.month}/${r.date.year}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textLabel(itemContext)),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      formatCurrency(r.amount),
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary(itemContext)),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      isExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      size: 18,
                                      color: AppColors.textMuted(itemContext),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (!isExpanded)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  S.of(context).dashboardProductCount(r.itemCount),
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.textMuted(itemContext)),
                                ),
                              ),
                            if (isExpanded && r.items.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              ...r.items.map((name) => Padding(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: Row(
                                      children: [
                                        Icon(Icons.circle,
                                            size: 4, color: AppColors.textMuted(itemContext)),
                                        const SizedBox(width: 8),
                                        Text(name,
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: AppColors.textLabel(itemContext))),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpensesBreakdown(BuildContext context, S l10n) {
    final activeExpenses = settings.expenses.where((e) => e.enabled && e.amount > 0).toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceVariant(context)),
        boxShadow: [
          BoxShadow(color: AppColors.shimmer(context), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.dashboardMonthlyExpenses,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary(context), letterSpacing: 0.5),
                ),
              ),
              InfoIconButton(title: l10n.dashboardMonthlyExpenses, body: l10n.infoExpensesBreakdown),
            ],
          ),
          const SizedBox(height: 16),
          ...activeExpenses.map((expense) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.background(context)))),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _categoryColor(expense.category),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Text(expense.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textLabel(context))),
                            const SizedBox(width: 8),
                            Text(categoryLabel(expense.category), style: TextStyle(fontSize: 11, color: AppColors.textMuted(context))),
                          ],
                        ),
                      ),
                      Text(formatCurrency(expense.amount), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context))),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.border(context)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.dashboardTotal, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textLabel(context))),
                Text(formatCurrency(summary.totalExpenses), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.error(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _categoryColor(String category) =>
      AppColors.categoryColorByName(category);
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? sublabel;
  final MaterialColor color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(
          left: BorderSide(color: color.shade400, width: 3),
          top: BorderSide(color: AppColors.surfaceVariant(context)),
          right: BorderSide(color: AppColors.surfaceVariant(context)),
          bottom: BorderSide(color: AppColors.surfaceVariant(context)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color.shade500),
          ),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted(context))),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context), letterSpacing: -0.3)),
          if (sublabel != null) ...[
            const SizedBox(height: 4),
            Text(sublabel!, style: TextStyle(fontSize: 9, color: AppColors.textMuted(context))),
          ],
        ],
      ),
      ),
    );
  }
}

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
        return f.valueLabel.isEmpty ? l10n.stressNA : l10n.stressUsed(f.valueLabel);
      case StressFactorType.stability:
        return f.valueLabel == 'stable' ? l10n.stressStable : l10n.stressHigh;
      default:
        return f.valueLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final l10n = S.of(context);
    final color = _scoreColor(context, result.score);

    // Gradient background matching mockup stress-card
    final bgGradient = result.score >= 60
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0FDF4), Color(0xFFECFDF5)],
          )
        : result.score >= 40
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
              );
    final borderColor = result.score >= 60
        ? const Color(0xFFBBF7D0)
        : result.score >= 40
            ? const Color(0xFFFDE68A)
            : const Color(0xFFFECACA);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text(
            '${result.score}',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            l10n.dashboardStressIndex,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.8),
            ),
          ),
          if (result.delta != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.dashboardVsLastMonth('${result.delta! >= 0 ? "↑" : "↓"} ${result.delta!.abs().toStringAsFixed(1)}'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                ),
                label: Text(_expanded ? l10n.close : l10n.dashboardDetails),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary(context),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  minimumSize: const Size(48, 40),
                ),
              ),
              if (widget.onShowTrend != null) ...[
                Container(
                  width: 1, height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: AppColors.border(context),
                ),
                TextButton.icon(
                  onPressed: widget.onShowTrend,
                  icon: const Icon(Icons.show_chart, size: 14),
                  label: Text(l10n.trendTitle),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary(context),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    minimumSize: const Size(48, 40),
                  ),
                ),
              ],
            ],
          ),
          if (_expanded) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: borderColor),
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
                            ? AppColors.success(context)
                            : AppColors.warning(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          f.type.localizedLabel(l10n),
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textLabel(context),
                          ),
                        ),
                      ),
                      Text(
                        _localizedValueLabel(f, l10n),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Color _scoreColor(BuildContext context, int score) {
    if (score >= 80) return AppColors.success(context);
    if (score >= 60) return AppColors.primary(context);
    if (score >= 40) return AppColors.warning(context);
    return AppColors.error(context);
  }
}

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
        color: AppColors.background(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textLabel(context))),
              Text(
                formatCurrency(calc.totalNetWithMeal),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success(context)),
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
                      hasSubsidy ? l10n.dashboardGrossWithSubsidy : l10n.dashboardGross,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMuted(context)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatCurrency(calc.effectiveGrossAmount),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textLabel(context)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dashboardIrsRate(formatPercentage(calc.irsRate)), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMuted(context))),
                    const SizedBox(height: 2),
                    Text('-${formatCurrency(calc.irsRetention)}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.error(context))),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dashboardSsRate, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMuted(context))),
                    const SizedBox(height: 2),
                    Text('-${formatCurrency(calc.socialSecurity)}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning(context))),
                  ],
                ),
              ),
            ],
          ),
          if (hasMeal) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.border(context)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.dashboardMealAllowance, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted(context))),
                  Text(
                    '+${formatCurrency(calc.mealAllowance.netMealAllowance)}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success(context)),
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
                Text(l10n.dashboardExemptIncome, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted(context))),
                Text(
                  '+${formatCurrency(calc.otherExemptIncome)}',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success(context)),
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
        color: AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted(context))),
              const SizedBox(height: 2),
              Text(l10n.dashboardExemptIncome, style: TextStyle(fontSize: 10, color: AppColors.textMuted(context))),
            ],
          ),
          Text(
            '+${formatCurrency(amount)}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success(context)),
          ),
        ],
      ),
    );
  }
}

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
      child: Material(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment_outlined, size: 16, color: AppColors.textMuted(context)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${review.monthLabel.toUpperCase()} ${l10n.dashboardSummaryLabel}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                InfoIconButton(title: 'Month Review', body: l10n.infoCharts),
                Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary(context)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.monthReviewPlanned, style: TextStyle(fontSize: 10, color: AppColors.textSecondary(context))),
                      Text(formatCurrency(review.totalPlanned),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textLabel(context))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.monthReviewActual, style: TextStyle(fontSize: 10, color: AppColors.textSecondary(context))),
                      Text(formatCurrency(review.totalActual),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(l10n.monthReviewDifference, style: TextStyle(fontSize: 10, color: AppColors.textSecondary(context))),
                      Text(
                        '${isOver ? '+' : ''}${formatCurrency(review.totalDifference)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isOver ? AppColors.error(context) : AppColors.success(context),
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
    ),
    ),
    );
  }
}
