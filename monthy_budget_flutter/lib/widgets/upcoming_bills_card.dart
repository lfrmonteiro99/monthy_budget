import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/recurring_expense.dart';
import '../models/app_settings.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'info_icon_button.dart';

/// Dashboard card showing bills due in the next N days.
class UpcomingBillsCard extends StatelessWidget {
  final List<RecurringExpense> recurringExpenses;
  final int reminderDaysBefore;
  final VoidCallback? onOpenRecurring;

  const UpcomingBillsCard({
    super.key,
    required this.recurringExpenses,
    this.reminderDaysBefore = 3,
    this.onOpenRecurring,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final upcoming = _getUpcomingBills();
    if (upcoming.isEmpty) return const SizedBox.shrink();

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
              Icon(Icons.event_note, size: 18, color: AppColors.warning(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.upcomingBillsTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              InfoIconButton(title: l10n.upcomingBillsTitle, body: l10n.infoUpcomingBills),
              if (onOpenRecurring != null)
                GestureDetector(
                  onTap: onOpenRecurring,
                  child: Text(
                    l10n.upcomingBillsManage,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary(context),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...upcoming.map((bill) => _BillRow(
                expense: bill.expense,
                daysUntilDue: bill.daysUntilDue,
              )),
        ],
      ),
    );
  }

  List<_UpcomingBill> _getUpcomingBills() {
    final now = DateTime.now();
    final today = now.day;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final bills = <_UpcomingBill>[];

    for (final expense in recurringExpenses) {
      if (!expense.isActive || expense.dayOfMonth == null) continue;
      final dueDay = expense.dayOfMonth!.clamp(1, daysInMonth);
      int daysUntilDue = dueDay - today;
      if (daysUntilDue < 0) {
        // Due date passed this month — calculate days until next month's due date
        final nextMonthDays = DateTime(now.year, now.month + 2, 0).day;
        final nextDueDay = expense.dayOfMonth!.clamp(1, nextMonthDays);
        daysUntilDue = (daysInMonth - today) + nextDueDay;
      }
      if (daysUntilDue <= reminderDaysBefore) {
        bills.add(_UpcomingBill(expense: expense, daysUntilDue: daysUntilDue));
      }
    }

    bills.sort((a, b) => a.daysUntilDue.compareTo(b.daysUntilDue));
    return bills;
  }
}

class _UpcomingBill {
  final RecurringExpense expense;
  final int daysUntilDue;
  const _UpcomingBill({required this.expense, required this.daysUntilDue});
}

class _BillRow extends StatelessWidget {
  final RecurringExpense expense;
  final int daysUntilDue;

  const _BillRow({required this.expense, required this.daysUntilDue});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isToday = daysUntilDue == 0;
    final isTomorrow = daysUntilDue == 1;

    final dueText = isToday
        ? l10n.billDueToday
        : isTomorrow
            ? l10n.billDueTomorrow
            : l10n.billDueInDays(daysUntilDue);

    final label = expense.description?.isNotEmpty == true
        ? expense.description!
        : _categoryLabel(l10n, expense.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isToday
                  ? AppColors.error(context)
                  : isTomorrow
                      ? AppColors.warning(context)
                      : AppColors.textMuted(context),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary(context),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatCurrency(expense.amount),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isToday
                  ? AppColors.errorBackground(context)
                  : isTomorrow
                      ? AppColors.warningBackground(context)
                      : AppColors.background(context),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              dueText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isToday
                    ? AppColors.error(context)
                    : isTomorrow
                        ? AppColors.warning(context)
                        : AppColors.textMuted(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(S l10n, String category) {
    final cat = ExpenseCategory.values.cast<ExpenseCategory?>().firstWhere(
          (c) => c!.name == category,
          orElse: () => null,
        );
    return cat?.localizedLabel(l10n) ?? category;
  }
}
