import 'package:flutter/material.dart';
import '../data/tax/tax_deductions.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// Compact banner showing the IRS deduction estimate.
/// Designed for primary-access screens like the Expense Tracker.
/// Tapping navigates to the full deduction detail screen.
class IrsDeductionBanner extends StatelessWidget {
  final YearlyDeductionSummary? summary;
  final VoidCallback? onSeeDetail;

  const IrsDeductionBanner({
    super.key,
    required this.summary,
    required this.onSeeDetail,
  });

  @override
  Widget build(BuildContext context) {
    if (summary == null) return const SizedBox.shrink();

    final l10n = S.of(context);
    final s = summary!;
    final progress = s.maxPossibleDeduction > 0
        ? (s.totalDeduction / s.maxPossibleDeduction).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: onSeeDetail,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          border: Border(
            bottom: BorderSide(color: AppColors.border(context)),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.receipt_long, size: 18, color: AppColors.primary(context)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        formatCurrency(s.totalDeduction),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success(context),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l10n.taxDeductionEstimated,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted(context),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.border(context),
                      color: AppColors.success(context),
                      minHeight: 3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.taxDeductionMaxOf(formatCurrency(s.maxPossibleDeduction)),
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.textMuted(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted(context)),
          ],
        ),
      ),
    );
  }
}
