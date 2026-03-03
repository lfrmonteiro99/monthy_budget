import 'package:flutter/material.dart';
import '../data/tax/tax_deductions.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// Compact dashboard card showing total estimated IRS deduction
/// and top 3 deductible categories.
class TaxDeductionCard extends StatelessWidget {
  final YearlyDeductionSummary summary;
  final VoidCallback onSeeDetail;

  const TaxDeductionCard({
    super.key,
    required this.summary,
    required this.onSeeDetail,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final top = summary.topCategories;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, size: 18, color: AppColors.primary(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.taxDeductionTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onSeeDetail,
                child: Text(
                  l10n.taxDeductionSeeDetail,
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
          // Total deduction estimate
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formatCurrency(summary.totalDeduction),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success(context),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.taxDeductionEstimated,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Progress toward max
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: summary.maxPossibleDeduction > 0
                  ? (summary.totalDeduction / summary.maxPossibleDeduction)
                      .clamp(0.0, 1.0)
                  : 0,
              backgroundColor: AppColors.border(context),
              color: AppColors.success(context),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.taxDeductionMaxOf(formatCurrency(summary.maxPossibleDeduction)),
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textMuted(context),
            ),
          ),
          if (top.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...top.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _categoryLabel(l10n, c.category),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                      Text(
                        formatCurrency(c.finalDeduction),
                        style: TextStyle(
                          fontSize: 12,
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

  String _categoryLabel(S l10n, String category) {
    switch (category) {
      case 'saude': return l10n.enumCatSaude;
      case 'educacao': return l10n.enumCatEducacao;
      case 'habitacao': return l10n.enumCatHabitacao;
      case 'transportes': return l10n.enumCatTransportes;
      case 'outros': return l10n.enumCatOutros;
      case 'alimentacao': return l10n.enumCatAlimentacao;
      default: return category;
    }
  }
}
