import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/savings_goal.dart';
import '../services/savings_goal_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../utils/savings_projections.dart';
import '../widgets/add_savings_goal_sheet.dart';
import '../widgets/info_icon_button.dart';

class SavingsGoalsScreen extends StatefulWidget {
  final String householdId;
  final List<SavingsGoal> goals;
  final ValueChanged<List<SavingsGoal>> onChanged;

  const SavingsGoalsScreen({
    super.key,
    required this.householdId,
    required this.goals,
    required this.onChanged,
  });

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  final _service = SavingsGoalService();
  late List<SavingsGoal> _goals;

  @override
  void initState() {
    super.initState();
    _goals = List.from(widget.goals);
    _reloadGoals();
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

    try {
      await _service.saveGoal(result, widget.householdId);
      await _reloadGoals();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).savingsGoalSaved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save goal: $e')),
        );
      }
    }
  }

  Future<void> _deleteGoal(SavingsGoal goal) async {
    final l10n = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.savingsGoalDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete,
                style: TextStyle(color: AppColors.error(context))),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _service.deleteGoal(goal.id);
      await _reloadGoals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete goal: $e')),
        );
      }
    }
  }

  Future<void> _toggleActive(SavingsGoal goal) async {
    final updated = goal.copyWith(isActive: !goal.isActive);
    try {
      await _service.saveGoal(updated, widget.householdId);
      await _reloadGoals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update goal: $e')),
        );
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
    if (updatedGoal != null) {
      setState(() {
        _goals =
            _goals.map((g) => g.id == updatedGoal.id ? updatedGoal : g).toList();
      });
      _notify();
      await _reloadGoals();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(l10n.savingsGoals),
        backgroundColor: AppColors.surface(context),
        foregroundColor: AppColors.textPrimary(context),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditGoal(),
        backgroundColor: AppColors.primary(context),
        child: Icon(Icons.add, color: AppColors.onPrimary(context)),
      ),
      body: _goals.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.savingsGoalEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _goals.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _GoalCard(
                goal: _goals[i],
                onTap: () => _openGoalDetail(_goals[i]),
                onEdit: () => _addOrEditGoal(_goals[i]),
                onToggle: () => _toggleActive(_goals[i]),
                onDelete: () => _deleteGoal(_goals[i]),
              ),
            ),
    );
  }
}

// ── Goal Card ────────────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.goal,
    required this.onTap,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final goalColor = goal.color != null
        ? _hexToColor(goal.color!)
        : AppColors.primary(context);
    final deadlineInfo = _deadlineLabel(goal, l10n);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(context)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: goalColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    goal.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: goal.isActive
                          ? AppColors.textPrimary(context)
                          : AppColors.textMuted(context),
                    ),
                  ),
                ),
                if (goal.isCompleted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successBackground(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.savingsGoalCompleted,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success(context),
                      ),
                    ),
                  ),
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
                      child: Text(goal.isActive
                          ? l10n.savingsGoalInactive
                          : l10n.savingsGoalActive),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(l10n.delete,
                          style: TextStyle(color: AppColors.error(context))),
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
                backgroundColor: AppColors.border(context),
                color: goal.isCompleted
                    ? AppColors.success(context)
                    : goalColor,
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
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                Text(
                  l10n.savingsGoalProgress(
                      '${(goal.progress * 100).toStringAsFixed(0)}%'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: goalColor,
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
                  color: AppColors.textMuted(context),
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
                      ? AppColors.error(context)
                      : AppColors.textMuted(context),
                ),
              ),
            ],

            if (!goal.isActive) ...[
              const SizedBox(height: 4),
              Text(
                l10n.savingsGoalInactive,
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textMuted(context),
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
    final contributions =
        await widget.service.loadContributions(_goal.id);
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
    final result = await showModalBottomSheet<SavingsContribution>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddContributionSheet(goalId: _goal.id),
    );
    if (result == null) return;

    final updatedGoal =
        await widget.service.addContribution(result, widget.householdId);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).savingsGoalContributionSaved)),
      );
    }
  }

  Future<void> _deleteContribution(SavingsContribution c) async {
    final l10n = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.savingsGoalDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete,
                style: TextStyle(color: AppColors.error(context))),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await widget.service.deleteContribution(c, widget.householdId);
    if (mounted) {
      setState(() {
        _contributions = _contributions.where((x) => x.id != c.id).toList();
        _goal = _goal.copyWith(
          currentAmount: (_goal.currentAmount - c.amount).clamp(0, double.infinity),
        );
      });
    }
  }

  Widget _buildProjectionSection(BuildContext context, S l10n) {
    final p = _projection!;
    final goalColor = _goal.color != null
        ? _hexToColor(_goal.color!)
        : AppColors.primary(context);

    if (!p.hasData) {
      return Text(
        l10n.savingsProjectionNoData,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textMuted(context),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Average contribution
          Row(
            children: [
              Icon(Icons.trending_up, size: 14, color: goalColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.savingsProjectionAvgContribution(
                      formatCurrency(p.averageMonthlyContribution)),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary(context),
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
                Icon(Icons.calendar_today, size: 14, color: goalColor),
                const SizedBox(width: 6),
                Text(
                  l10n.savingsProjectionReachedBy(
                      '${p.projectedDate!.month.toString().padLeft(2, '0')}/${p.projectedDate!.year}'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary(context),
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
                      ? AppColors.success(context)
                      : AppColors.warning(context),
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
                        ? AppColors.success(context)
                        : AppColors.warning(context),
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
                Icon(Icons.flag_outlined, size: 14,
                    color: AppColors.textSecondary(context)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.savingsProjectionNeedPerMonth(
                        formatCurrency(p.requiredMonthlyContribution!)),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
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
              backgroundColor: AppColors.border(context),
              color: p.onTrack == null
                  ? goalColor
                  : p.onTrack!
                      ? AppColors.success(context)
                      : AppColors.warning(context),
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
    final goalColor = _goal.color != null
        ? _hexToColor(_goal.color!)
        : AppColors.primary(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(_goal.name),
        backgroundColor: AppColors.surface(context),
        foregroundColor: AppColors.textPrimary(context),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addContribution,
        backgroundColor: AppColors.primary(context),
        foregroundColor: AppColors.onPrimary(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.savingsGoalContribute),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) Navigator.of(context).pop(_goal);
        },
        child: Column(
          children: [
            // Goal summary header
            Container(
              color: AppColors.surface(context),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Big progress ring
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
                            backgroundColor: AppColors.border(context),
                            color: _goal.isCompleted
                                ? AppColors.success(context)
                                : goalColor,
                          ),
                        ),
                        Text(
                          '${(_goal.progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${formatCurrency(_goal.currentAmount)} / ${formatCurrency(_goal.targetAmount)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (!_goal.isCompleted)
                    Text(
                      l10n.savingsGoalRemaining(
                          formatCurrency(_goal.remaining)),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  if (_goal.isCompleted)
                    Text(
                      l10n.savingsGoalCompleted,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success(context),
                      ),
                    ),
                  if (_goal.deadline != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _deadlineLabel(_goal, l10n) ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isOverdue(_goal)
                            ? AppColors.error(context)
                            : AppColors.textMuted(context),
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
            const Divider(height: 1),

            // Contribution history label
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.savingsGoalContributionHistory,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(context),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // Contribution list
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary(context)))
                  : _contributions.isEmpty
                      ? Center(
                          child: Text(
                            l10n.savingsGoalEmpty,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted(context),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _contributions.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 6),
                          itemBuilder: (_, i) {
                            final c = _contributions[i];
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface(context),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.border(context)),
                              ),
                              child: ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                      goalColor.withValues(alpha: 0.15),
                                  child: Icon(Icons.arrow_upward,
                                      size: 16, color: goalColor),
                                ),
                                title: Text(
                                  formatCurrency(c.amount),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                                subtitle: Text(
                                  [
                                    '${c.contributionDate.day.toString().padLeft(2, '0')}/${c.contributionDate.month.toString().padLeft(2, '0')}/${c.contributionDate.year}',
                                    if (c.note != null &&
                                        c.note!.isNotEmpty)
                                      c.note!,
                                  ].join(' - '),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        AppColors.textSecondary(context),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      size: 18,
                                      color: AppColors.textMuted(context)),
                                  onPressed: () =>
                                      _deleteContribution(c),
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
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.'));
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
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.dragHandle(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.savingsGoalContribute,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 20),

              // Amount
              _sheetLabel(context, l10n.savingsGoalContributionAmount),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: currencySymbol(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
                validator: (v) {
                  final val =
                      double.tryParse((v ?? '').replaceAll(',', '.'));
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
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColors.borderMuted(context)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 18,
                          color: AppColors.textSecondary(context)),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // Save
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    foregroundColor: AppColors.onPrimary(context),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.save,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
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
        color: AppColors.textSecondary(context),
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────

Color _hexToColor(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

String? _deadlineLabel(SavingsGoal goal, S l10n) {
  if (goal.deadline == null) return null;
  final now = DateTime.now();
  final diff = goal.deadline!.difference(DateTime(now.year, now.month, now.day));
  if (diff.isNegative) return l10n.savingsGoalOverdue;
  return l10n.savingsGoalDaysLeft('${diff.inDays}');
}

bool _isOverdue(SavingsGoal goal) {
  if (goal.deadline == null) return false;
  return goal.deadline!.isBefore(DateTime.now());
}
