import 'package:flutter/material.dart';
import '../data/tax/tax_deductions.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class TaxDeductionDetailScreen extends StatelessWidget {
  final YearlyDeductionSummary summary;

  const TaxDeductionDetailScreen({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final deductible = summary.deductible
      ..sort((a, b) => b.finalDeduction.compareTo(a.finalDeduction));
    final nonDeductible = summary.nonDeductible;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.surface(context),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: AppColors.textLabel(context)),
                  ),
                  Expanded(
                    child: Text(
                      l10n.taxDeductionDetailTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.surfaceVariant(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total summary card
                    _buildTotalCard(context, l10n),
                    const SizedBox(height: 20),
                    // Deductible categories
                    Text(
                      l10n.taxDeductionDeductibleTitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted(context),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...deductible.map((c) => _CategoryRow(result: c)),
                    // Non-deductible categories
                    if (nonDeductible.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        l10n.taxDeductionNonDeductibleTitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted(context),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...nonDeductible.map((c) => _NonDeductibleRow(result: c)),
                    ],
                    const SizedBox(height: 20),
                    // Disclaimer
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warningBackground(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.warning(context).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: AppColors.warning(context)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.taxDeductionDisclaimer,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.warning(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(BuildContext context, S l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Text(
            l10n.taxDeductionTotalLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted(context),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatCurrency(summary.totalDeduction),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.success(context),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: summary.maxPossibleDeduction > 0
                  ? (summary.totalDeduction / summary.maxPossibleDeduction)
                      .clamp(0.0, 1.0)
                  : 0,
              backgroundColor: AppColors.border(context),
              color: AppColors.success(context),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.taxDeductionMaxOf(formatCurrency(summary.maxPossibleDeduction)),
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${summary.year}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CategoryDeductionResult result;
  const _CategoryRow({required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _categoryLabel(l10n, result.category),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              Text(
                formatCurrency(result.finalDeduction),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${result.irsCategory} · ${l10n.taxDeductionSpent(formatCurrency(result.spent))}',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted(context),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: result.capUsedPercent,
              backgroundColor: AppColors.border(context),
              color: result.capUsedPercent >= 1.0
                  ? AppColors.success(context)
                  : AppColors.primary(context),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.taxDeductionCapUsed(
              '${(result.capUsedPercent * 100).toStringAsFixed(0)}%',
              formatCurrency(result.annualCap),
            ),
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textMuted(context),
            ),
          ),
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

class _NonDeductibleRow extends StatelessWidget {
  final CategoryDeductionResult result;
  const _NonDeductibleRow({required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(Icons.block, size: 14, color: AppColors.textMuted(context)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _categoryLabel(l10n, result.category),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Text(
            l10n.taxDeductionNotDeductible,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted(context),
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(S l10n, String category) {
    switch (category) {
      case 'telecomunicacoes': return l10n.enumCatTelecomunicacoes;
      case 'energia': return l10n.enumCatEnergia;
      case 'agua': return l10n.enumCatAgua;
      case 'lazer': return l10n.enumCatLazer;
      default: return category;
    }
  }
}
