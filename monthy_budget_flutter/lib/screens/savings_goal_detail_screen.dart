import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/savings_goal.dart';
import '../services/savings_goal_service.dart';
import '../services/log_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/savings_projections.dart';
import '../utils/savings_goal_format.dart';
import '../widgets/info_icon_button.dart';
import '../widgets/savings/add_contribution_sheet.dart';

/// Detail screen for a single savings goal: progress ring, contribution
/// projection and the contribution history list. Pops with the (possibly
/// updated) [SavingsGoal] so the caller can refresh its list.
class SavingsGoalDetailScreen extends StatefulWidget {
  final SavingsGoal goal;
  final String householdId;
  final SavingsGoalService service;

  const SavingsGoalDetailScreen({
    super.key,
    required this.goal,
    required this.householdId,
    required this.service,
  });

  @override
  State<SavingsGoalDetailScreen> createState() =>
      _SavingsGoalDetailScreenState();
}

class _SavingsGoalDetailScreenState extends State<SavingsGoalDetailScreen> {
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
      builder: (_) => AddContributionSheet(goalId: _goal.id),
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
                      savingsDeadlineLabel(_goal, l10n) ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: savingsGoalIsOverdue(_goal)
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
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: CalmListTile(
                              leadingIcon: Icons.arrow_upward,
                              leadingColor: AppColors.accent(context),
                              title: formatCurrency(c.amount),
                              subtitle: [
                                '${c.contributionDate.day.toString().padLeft(2, '0')}/${c.contributionDate.month.toString().padLeft(2, '0')}/${c.contributionDate.year}',
                                if (c.note != null && c.note!.isNotEmpty)
                                  c.note!,
                              ].join(' - '),
                              trailingWidget: IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: AppColors.ink50(context),
                                ),
                                onPressed: () => _deleteContribution(c),
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
    );
  }
}
