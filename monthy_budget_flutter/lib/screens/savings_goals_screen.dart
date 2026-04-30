import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/savings_goal.dart';
import '../models/subscription_state.dart';
import '../services/analytics_service.dart';
import '../services/downgrade_service.dart';
import '../services/savings_goal_service.dart';
import '../services/log_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/savings_projections.dart';
import '../widgets/add_savings_goal_sheet.dart';
import '../widgets/limit_reached_dialog.dart';
import '../widgets/info_icon_button.dart';
import '../onboarding/savings_goals_tour.dart';

class SavingsGoalsScreen extends StatefulWidget {
  final String householdId;
  final List<SavingsGoal> goals;
  final ValueChanged<List<SavingsGoal>> onChanged;
  final SubscriptionState? subscription;
  final VoidCallback? onUpgrade;
  final bool showTour;
  final VoidCallback? onTourComplete;

  const SavingsGoalsScreen({
    super.key,
    required this.householdId,
    required this.goals,
    required this.onChanged,
    this.subscription,
    this.onUpgrade,
    this.showTour = false,
    this.onTourComplete,
  });

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  final _service = SavingsGoalService();
  late List<SavingsGoal> _goals;
  bool _showHelp = false;
  bool _tourShown = false;

  @override
  void initState() {
    super.initState();
    _goals = List.from(widget.goals);
    _reloadGoals();
    if (widget.showTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryShowTour());
    }
  }

  void _tryShowTour() {
    if (_tourShown || !mounted) return;
    _tourShown = true;
    buildSavingsGoalsTour(
      context: context,
      onFinish: () => widget.onTourComplete?.call(),
      onSkip: () => widget.onTourComplete?.call(),
    ).show(context: context);
  }

  void _notify() => widget.onChanged(_goals);

  Future<void> _reloadGoals({bool notify = true}) async {
    try {
      final latest = await _service.loadGoals(widget.householdId);
      if (!mounted) return;
      setState(() => _goals = latest);
      if (notify) _notify();
    } catch (_) {
      // Keep local state if remote refresh fails.
    }
  }

  // ── Goal CRUD ──────────────────────────────────────────────────────────

  Future<void> _addOrEditGoal([SavingsGoal? existing]) async {
    final result = await showAddSavingsGoalSheet(
      context: context,
      existing: existing,
    );
    if (result == null) return;

    // If creating a new goal on free tier, check limits
    var goalToSave = result;
    if (existing == null && _isFreeUser) {
      final activeCount = _goals.where((g) => g.isActive).length;
      if (activeCount >= DowngradeService.maxFreeSavingsGoals) {
        if (!mounted) return;
        final action = await showGoalCreateLimitDialog(context);
        if (action == LimitReachedAction.upgrade) {
          widget.onUpgrade?.call();
          return;
        } else if (action == LimitReachedAction.createPaused) {
          goalToSave = result.copyWith(isActive: false);
        } else {
          return; // cancelled
        }
      }
    }

    try {
      await _service.saveGoal(goalToSave, widget.householdId);
      if (existing == null) {
        unawaited(
          AnalyticsService.instance.trackEvent(
            'goal_created',
            properties: {
              'goal_name': goalToSave.name,
              'target_amount': goalToSave.targetAmount,
              'is_active': goalToSave.isActive,
            },
          ),
        );
      }
      await _reloadGoals();
      if (mounted) {
        CalmSnack.success(context, S.of(context).savingsGoalSaved);
      }
    } catch (e) {
      if (mounted) {
        CalmSnack.error(
            context, S.of(context).savingsGoalSaveError(e.toString()));
      }
    }
  }

  Future<void> _deleteGoal(SavingsGoal goal) async {
    final l10n = S.of(context);
    final confirmed = await CalmDialog.confirm(
      context,
      title: l10n.delete,
      body: l10n.savingsGoalDeleteConfirm,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (confirmed != true) return;

    try {
      await _service.deleteGoal(goal.id);
      await _reloadGoals();
    } catch (e) {
      if (mounted) {
        CalmSnack.error(
            context, S.of(context).savingsGoalDeleteError(e.toString()));
      }
    }
  }

  bool get _isFreeUser =>
      widget.subscription != null && !widget.subscription!.hasPremiumAccess;

  Future<void> _toggleActive(SavingsGoal goal) async {
    // If trying to activate a goal and on free tier, check limits
    if (!goal.isActive && _isFreeUser) {
      final activeCount = _goals.where((g) => g.isActive).length;
      if (activeCount >= DowngradeService.maxFreeSavingsGoals) {
        if (!mounted) return;
        final action = await showGoalLimitDialog(context, goal.name);
        if (action == LimitReachedAction.upgrade) {
          widget.onUpgrade?.call();
        }
        // For 'Choose Active Goal' the user stays on this screen to deactivate first
        return;
      }
    }

    final updated = goal.copyWith(isActive: !goal.isActive);
    try {
      await _service.saveGoal(updated, widget.householdId);
      await _reloadGoals();
    } catch (e) {
      if (mounted) {
        CalmSnack.error(
            context, S.of(context).savingsGoalUpdateError(e.toString()));
      }
    }
  }

  // ── Contribution detail ────────────────────────────────────────────────

  Future<void> _openGoalDetail(SavingsGoal goal) async {
    final updatedGoal = await Navigator.of(context).push<SavingsGoal>(
      MaterialPageRoute(
        builder: (_) => _GoalDetailScreen(
          goal: goal,
          householdId: widget.householdId,
          service: _service,
        ),
      ),
    );
    if (updatedGoal != null && mounted) {
      setState(() {
        _goals = _goals
            .map((g) => g.id == updatedGoal.id ? updatedGoal : g)
            .toList();
      });
      _notify();
      await _reloadGoals();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final totalSaved = _goals.fold<double>(0, (s, g) => s + g.currentAmount);
    final totalTarget = _goals.fold<double>(0, (s, g) => s + g.targetAmount);
    final activeCount = _goals.where((g) => g.isActive).length;

    return CalmScaffold(
      title: l10n.savingsGoals,
      actions: [
        IconButton(
          icon: Icon(
            _showHelp ? Icons.help : Icons.help_outline,
            color: AppColors.ink70(context),
          ),
          onPressed: () => setState(() => _showHelp = !_showHelp),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        key: SavingsGoalsTourKeys.addFab,
        onPressed: () => _addOrEditGoal(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero — total saved across all goals (one Fraunces per screen)
          if (_goals.isNotEmpty) ...[
            const SizedBox(height: 16),
            CalmHero(
              // TODO(l10n): move to ARB (Wave H)
              eyebrow: 'POUPANÇA',
              amount: formatCurrency(totalSaved),
              subtitle: totalTarget > 0
                  ? 'de ${formatCurrency(totalTarget)} objetivo'
                  : '$activeCount metas ativas',
            ),
            const SizedBox(height: 12),
            if (totalTarget > 0)
              CalmPill(
                label: '${((totalSaved / totalTarget) * 100).toStringAsFixed(0)}% concluído',
                color: totalSaved >= totalTarget
                    ? AppColors.ok(context)
                    : AppColors.accent(context),
              ),
            const SizedBox(height: 24),
          ] else ...[
            const SizedBox(height: 24),
          ],

          // Collapsible "How it works" explanation
          if (_showHelp)
            _HowItWorksCard(onClose: () => setState(() => _showHelp = false)),

          // Goals list or empty state
          Expanded(
            child: _goals.isEmpty
                ? Center(
                    child: CalmCard(
                      child: CalmEmptyState(
                        icon: Icons.savings_outlined,
                        title: l10n.savingsGoalEmpty,
                        // TODO(l10n): move to ARB (Wave H)
                        body: 'Crie a sua primeira meta de poupança para começar.',
                        action: CalmEmptyStateAction(
                          label: l10n.savingsGoalHowItWorksTitle,
                          onPressed: () => setState(() => _showHelp = true),
                        ),
                      ),
                    ),
                  )
                : Builder(
                    builder: (_) {
                      // Sort: active first, then paused
                      final sorted = List<SavingsGoal>.from(_goals)
                        ..sort((a, b) {
                          if (a.isActive == b.isActive) return 0;
                          return a.isActive ? -1 : 1;
                        });
                      return ListView.separated(
                        padding: const EdgeInsets.only(bottom: 96),
                        itemCount: sorted.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _GoalCard(
                          key: i == 0 ? SavingsGoalsTourKeys.goalCard : null,
                          goal: sorted[i],
                          isFreeUser: _isFreeUser,
                          onTap: () => _openGoalDetail(sorted[i]),
                          onEdit: () => _addOrEditGoal(sorted[i]),
                          onToggle: () => _toggleActive(sorted[i]),
                          onDelete: () => _deleteGoal(sorted[i]),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── How It Works Card ─────────────────────────────────────────────────────

class _HowItWorksCard extends StatelessWidget {
  final VoidCallback onClose;
  const _HowItWorksCard({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final steps = [
      l10n.savingsGoalHowItWorksStep1,
      l10n.savingsGoalHowItWorksStep2,
      l10n.savingsGoalHowItWorksStep3,
      l10n.savingsGoalHowItWorksStep4,
    ];
    final icons = [
      Icons.flag_outlined,
      Icons.calendar_today,
      Icons.add_circle_outline,
      Icons.trending_up,
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CalmCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: AppColors.accent(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.savingsGoalHowItWorksTitle,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink(context),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.ink50(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(steps.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.accentSoft(context),
                      child: Icon(
                        icons[i],
                        size: 14,
                        color: AppColors.accent(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        steps[i],
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.ink70(context),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Goal Card ────────────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final bool isFreeUser;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _GoalCard({
    super.key,
    required this.goal,
    this.isFreeUser = false,
    required this.onTap,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isPaused = !goal.isActive;
    final showProBadge = isPaused && isFreeUser;

    // Progress colour: completed → ok, paused-locked → ink20, else accent
    final progressColor = goal.isCompleted
        ? AppColors.ok(context)
        : (isPaused && isFreeUser)
            ? AppColors.ink20(context)
            : AppColors.accent(context);

    final deadlineInfo = _deadlineLabel(goal, l10n);

    return Semantics(
      label: isPaused ? 'Paused - requires Pro subscription' : null,
      child: CalmCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isPaused && isFreeUser)
                  Icon(
                    Icons.lock_outline,
                    size: 12,
                    color: AppColors.ink50(context),
                  )
                else
                  CircleAvatar(
                    radius: 6,
                    backgroundColor: progressColor,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    goal.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isPaused
                          ? AppColors.ink50(context)
                          : AppColors.ink(context),
                    ),
                  ),
                ),
                if (showProBadge)
                  CalmPill(
                    label: 'PRO',
                    color: AppColors.accent(context),
                  ),
                if (!showProBadge && goal.isCompleted)
                  CalmPill(
                    label: l10n.savingsGoalCompleted,
                    color: AppColors.ok(context),
                  ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  onSelected: (action) {
                    switch (action) {
                      case 'edit':
                        onEdit();
                      case 'toggle':
                        onToggle();
                      case 'delete':
                        onDelete();
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(l10n.savingsGoalEdit),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(
                        goal.isActive
                            ? l10n.savingsGoalInactive
                            : l10n.savingsGoalActive,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        l10n.delete,
                        style: TextStyle(color: AppColors.bad(context)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: AppColors.ink20(context),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),

            // Amount row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${formatCurrency(goal.currentAmount)} / ${formatCurrency(goal.targetAmount)}',
                  style: CalmText.amount(
                    context,
                    size: 13,
                    weight: FontWeight.w500,
                  ).copyWith(
                    color: isPaused
                        ? AppColors.ink50(context)
                        : AppColors.ink70(context),
                  ),
                ),
                Text(
                  l10n.savingsGoalProgress(
                    '${(goal.progress * 100).toStringAsFixed(0)}%',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPaused
                        ? AppColors.ink50(context)
                        : progressColor,
                  ),
                ),
              ],
            ),

            if (!goal.isCompleted) ...[
              const SizedBox(height: 4),
              Text(
                l10n.savingsGoalRemaining(formatCurrency(goal.remaining)),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.ink50(context),
                ),
              ),
            ],

            if (deadlineInfo != null) ...[
              const SizedBox(height: 4),
              Text(
                deadlineInfo,
                style: TextStyle(
                  fontSize: 12,
                  color: _isOverdue(goal)
                      ? AppColors.bad(context)
                      : AppColors.ink50(context),
                ),
              ),
            ],

            if (isPaused && isFreeUser) ...[
              const SizedBox(height: 4),
              Text(
                'Paused — Free plan allows 1 goal',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.ink50(context),
                ),
              ),
            ] else if (isPaused) ...[
              const SizedBox(height: 4),
              Text(
                l10n.savingsGoalInactive,
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.ink50(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Goal Detail (contributions) ──────────────────────────────────────────

class _GoalDetailScreen extends StatefulWidget {
  final SavingsGoal goal;
  final String householdId;
  final SavingsGoalService service;

  const _GoalDetailScreen({
    required this.goal,
    required this.householdId,
    required this.service,
  });

  @override
  State<_GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<_GoalDetailScreen> {
  late SavingsGoal _goal;
  List<SavingsContribution> _contributions = [];
  SavingsProjection? _projection;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _goal = widget.goal;
    _loadContributions();
  }

  Future<void> _loadContributions() async {
    final contributions = await widget.service.loadContributions(_goal.id);
    if (mounted) {
      setState(() {
        _contributions = contributions;
        _projection = calculateProjection(
          goal: _goal,
          contributions: contributions,
        );
        _loading = false;
      });
    }
  }

  Future<void> _addContribution() async {
    final result = await CalmBottomSheet.show<SavingsContribution>(
      context,
      builder: (_) => _AddContributionSheet(goalId: _goal.id),
    );
    if (result == null) return;

    final SavingsGoal updatedGoal;
    try {
      updatedGoal = await widget.service.addContribution(
        result,
        widget.householdId,
      );
    } catch (e, st) {
      LogService.error(
        'Failed to save savings contribution',
        error: e,
        stackTrace: st,
        category: 'ui.savings',
      );
      if (!mounted) return;
      CalmSnack.error(context, S.of(context).savingsContributionSaveError);
      return;
    }
    if (mounted) {
      final updated = [result, ..._contributions];
      setState(() {
        _goal = updatedGoal;
        _contributions = updated;
        _projection = calculateProjection(
          goal: updatedGoal,
          contributions: updated,
        );
      });
      CalmSnack.success(
          context, S.of(context).savingsGoalContributionSaved);
    }
  }

  Future<void> _deleteContribution(SavingsContribution c) async {
    final l10n = S.of(context);
    final confirmed = await CalmDialog.confirm(
      context,
      title: l10n.delete,
      body: l10n.savingsGoalDeleteConfirm,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (confirmed != true) return;

    await widget.service.deleteContribution(c, widget.householdId);
    if (mounted) {
      setState(() {
        _contributions = _contributions.where((x) => x.id != c.id).toList();
        _goal = _goal.copyWith(
          currentAmount: (_goal.currentAmount - c.amount).clamp(
            0,
            double.infinity,
          ),
        );
      });
    }
  }

  Widget _buildProjectionSection(BuildContext context, S l10n) {
    final p = _projection!;
    final progressColor =
        _goal.isCompleted ? AppColors.ok(context) : AppColors.accent(context);

    if (!p.hasData) {
      return Text(
        l10n.savingsProjectionNoData,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.ink50(context),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return CalmCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Average contribution
          Row(
            children: [
              Icon(Icons.trending_up, size: 14, color: progressColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.savingsProjectionAvgContribution(
                    formatCurrency(p.averageMonthlyContribution),
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink(context),
                  ),
                ),
              ),
              InfoIconButton(
                title: l10n.savingsProjectionAvgContribution(''),
                body: l10n.infoSavingsProjection,
              ),
            ],
          ),
          // Projected date
          if (p.projectedDate != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: progressColor),
                const SizedBox(width: 6),
                Text(
                  l10n.savingsProjectionReachedBy(
                    '${p.projectedDate!.month.toString().padLeft(2, '0')}/${p.projectedDate!.year}',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink(context),
                  ),
                ),
              ],
            ),
          ],
          // On-track status
          if (p.onTrack != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  p.onTrack! ? Icons.check_circle_outline : Icons.warning_amber,
                  size: 14,
                  color: p.onTrack!
                      ? AppColors.ok(context)
                      : AppColors.warn(context),
                ),
                const SizedBox(width: 6),
                Text(
                  p.onTrack!
                      ? l10n.savingsProjectionOnTrack
                      : l10n.savingsProjectionBehind,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: p.onTrack!
                        ? AppColors.ok(context)
                        : AppColors.warn(context),
                  ),
                ),
              ],
            ),
          ],
          // Required per month
          if (p.requiredMonthlyContribution != null &&
              p.requiredMonthlyContribution! > 0) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 14,
                  color: AppColors.ink70(context),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.savingsProjectionNeedPerMonth(
                      formatCurrency(p.requiredMonthlyContribution!),
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.ink70(context),
                    ),
                  ),
                ),
                InfoIconButton(
                  title: l10n.savingsProjectionNeedPerMonth(''),
                  body: l10n.infoSavingsRequired,
                ),
              ],
            ),
          ],
          // Timeline bar
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: _goal.progress,
              backgroundColor: AppColors.ink20(context),
              valueColor: AlwaysStoppedAnimation<Color>(
                p.onTrack == null
                    ? progressColor
                    : p.onTrack!
                        ? AppColors.ok(context)
                        : AppColors.warn(context),
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final progressColor =
        _goal.isCompleted ? AppColors.ok(context) : AppColors.accent(context);

    return CalmScaffold(
      title: _goal.name,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addContribution,
        icon: const Icon(Icons.add),
        label: Text(l10n.savingsGoalContribute),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) Navigator.of(context).pop(_goal);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Goal summary header
            const SizedBox(height: 16),
            CalmCard(
              child: Column(
                children: [
                  // Progress ring
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: _goal.progress,
                            strokeWidth: 8,
                            backgroundColor: AppColors.ink20(context),
                            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                          ),
                        ),
                        Text(
                          '${(_goal.progress * 100).toStringAsFixed(0)}%',
                          style: CalmText.display(context, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${formatCurrency(_goal.currentAmount)} / ${formatCurrency(_goal.targetAmount)}',
                    style: CalmText.amount(context, size: 16),
                  ),
                  const SizedBox(height: 4),
                  if (!_goal.isCompleted)
                    Text(
                      l10n.savingsGoalRemaining(
                        formatCurrency(_goal.remaining),
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.ink70(context),
                      ),
                    ),
                  if (_goal.isCompleted)
                    CalmPill(
                      label: l10n.savingsGoalCompleted,
                      color: AppColors.ok(context),
                    ),
                  if (_goal.deadline != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _deadlineLabel(_goal, l10n) ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isOverdue(_goal)
                            ? AppColors.bad(context)
                            : AppColors.ink50(context),
                      ),
                    ),
                  ],
                  // Projection section
                  if (_projection != null && !_goal.isCompleted) ...[
                    const SizedBox(height: 16),
                    _buildProjectionSection(context, l10n),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.line(context), height: 1),

            // Contribution history label
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: CalmEyebrow(l10n.savingsGoalContributionHistory.toUpperCase()),
            ),

            // Contribution list
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent(context),
                      ),
                    )
                  : _contributions.isEmpty
                  ? Center(
                      child: Text(
                        l10n.savingsGoalEmpty,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.ink50(context),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: _contributions.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final c = _contributions[i];
                        return CalmCard(
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  AppColors.accentSoft(context),
                              child: Icon(
                                Icons.arrow_upward,
                                size: 16,
                                color: AppColors.accent(context),
                              ),
                            ),
                            title: Text(
                              formatCurrency(c.amount),
                              style: CalmText.amount(context, size: 14),
                            ),
                            subtitle: Text(
                              [
                                '${c.contributionDate.day.toString().padLeft(2, '0')}/${c.contributionDate.month.toString().padLeft(2, '0')}/${c.contributionDate.year}',
                                if (c.note != null && c.note!.isNotEmpty)
                                  c.note!,
                              ].join(' - '),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.ink70(context),
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: AppColors.ink50(context),
                              ),
                              onPressed: () => _deleteContribution(c),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add Contribution Sheet ───────────────────────────────────────────────

class _AddContributionSheet extends StatefulWidget {
  final String goalId;
  const _AddContributionSheet({required this.goalId});

  @override
  State<_AddContributionSheet> createState() => _AddContributionSheetState();
}

class _AddContributionSheetState extends State<_AddContributionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) return;

    final note = _noteController.text.trim();
    final result = SavingsContribution(
      id: const Uuid().v4(),
      goalId: widget.goalId,
      amount: amount,
      contributionDate: _selectedDate,
      note: note.isEmpty ? null : note,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, scrollController) => Form(
        key: _formKey,
        child: CalmBottomSheetContent(
          title: l10n.savingsGoalContribute,
          primaryAction: FilledButton(
            onPressed: _save,
            child: Text(l10n.save),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Amount
                _sheetLabel(context, l10n.savingsGoalContributionAmount),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    prefixText: currencySymbol(),
                  ),
                  validator: (v) {
                    final val = double.tryParse((v ?? '').replaceAll(',', '.'));
                    if (val == null || val <= 0) {
                      return l10n.savingsGoalContributionAmount;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Date
                _sheetLabel(context, l10n.savingsGoalContributionDate),
                const SizedBox(height: 8),
                CalmCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null && mounted) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: AppColors.ink70(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.ink(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Note
                _sheetLabel(context, l10n.savingsGoalContributionNote),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: l10n.savingsGoalContributionNote,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.ink70(context),
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────

String? _deadlineLabel(SavingsGoal goal, S l10n) {
  if (goal.deadline == null) return null;
  final now = DateTime.now();
  final diff = goal.deadline!.difference(
    DateTime(now.year, now.month, now.day),
  );
  if (diff.isNegative) return l10n.savingsGoalOverdue;
  return l10n.savingsGoalDaysLeft('${diff.inDays}');
}

bool _isOverdue(SavingsGoal goal) {
  if (goal.deadline == null) return false;
  return goal.deadline!.isBefore(DateTime.now());
}
