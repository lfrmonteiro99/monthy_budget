import 'dart:async';

import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/savings_goal.dart';
import '../models/subscription_state.dart';
import '../services/analytics_service.dart';
import '../services/downgrade_service.dart';
import '../services/savings_goal_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/add_savings_goal_sheet.dart';
import '../widgets/limit_reached_dialog.dart';
import '../widgets/savings/goal_card.dart';
import '../widgets/savings/how_it_works_card.dart';
import '../onboarding/savings_goals_tour.dart';
import 'savings_goal_detail_screen.dart';

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
        builder: (_) => SavingsGoalDetailScreen(
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
                label: '${((totalSaved / totalTarget) * 100).clamp(0.0, 100.0).toStringAsFixed(0)}% concluído',
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
            HowItWorksCard(onClose: () => setState(() => _showHelp = false)),

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
                        itemBuilder: (_, i) => GoalCard(
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
