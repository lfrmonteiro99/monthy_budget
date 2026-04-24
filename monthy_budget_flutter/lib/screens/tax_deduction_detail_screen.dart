import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../data/tax/tax_deductions.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
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

    return CalmScaffold(
      title: l10n.taxDeductionDetailTitle,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildHero(context, l10n),
            const SizedBox(height: 24),
            _buildCapProgress(context, l10n),
            const SizedBox(height: 24),
            CalmEyebrow(l10n.taxDeductionDeductibleTitle),
            const SizedBox(height: 12),
            if (deductible.isNotEmpty)
              CalmCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < deductible.length; i++) ...[
                      _DeductibleTile(result: deductible[i]),
                      if (i != deductible.length - 1)
                        Divider(
                          height: 1,
                          color: AppColors.line(context),
                        ),
                    ],
                  ],
                ),
              ),
            if (nonDeductible.isNotEmpty) ...[
              const SizedBox(height: 24),
              CalmEyebrow(l10n.taxDeductionNonDeductibleTitle),
              const SizedBox(height: 12),
              CalmCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < nonDeductible.length; i++) ...[
                      _NonDeductibleTile(result: nonDeductible[i]),
                      if (i != nonDeductible.length - 1)
                        Divider(
                          height: 1,
                          color: AppColors.line(context),
                        ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            _buildDisclaimer(context, l10n),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, S l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CalmHero(
          eyebrow: l10n.taxDeductionTotalLabel.toUpperCase(),
          amount: formatCurrency(summary.totalDeduction),
          subtitle: l10n.taxDeductionMaxOf(
            formatCurrency(summary.maxPossibleDeduction),
          ),
        ),
        const SizedBox(height: 12),
        CalmPill(
          label: '${summary.year}',
          color: AppColors.accent(context),
        ),
      ],
    );
  }

  Widget _buildCapProgress(BuildContext context, S l10n) {
    final pct = summary.maxPossibleDeduction > 0
        ? (summary.totalDeduction / summary.maxPossibleDeduction)
            .clamp(0.0, 1.0)
        : 0.0;
    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CalmEyebrow(l10n.taxDeductionTotalLabel),
              ),
              CalmPill(
                label: '${(pct * 100).toStringAsFixed(0)}%',
                color: pct >= 1.0
                    ? AppColors.ok(context)
                    : AppColors.accent(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.line(context),
              color: pct >= 1.0
                  ? AppColors.ok(context)
                  : AppColors.accent(context),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context, S l10n) {
    return CalmCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: AppColors.warn(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.taxDeductionDisclaimer,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.ink70(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _categoryLabelDeductible(S l10n, String category) {
  switch (category) {
    case 'saude':
      return l10n.enumCatSaude;
    case 'educacao':
      return l10n.enumCatEducacao;
    case 'habitacao':
      return l10n.enumCatHabitacao;
    case 'transportes':
      return l10n.enumCatTransportes;
    case 'outros':
      return l10n.enumCatOutros;
    case 'alimentacao':
      return l10n.enumCatAlimentacao;
    default:
      return category;
  }
}

String _categoryLabelNonDeductible(S l10n, String category) {
  switch (category) {
    case 'telecomunicacoes':
      return l10n.enumCatTelecomunicacoes;
    case 'energia':
      return l10n.enumCatEnergia;
    case 'agua':
      return l10n.enumCatAgua;
    case 'lazer':
      return l10n.enumCatLazer;
    default:
      return category;
  }
}

class _DeductibleTile extends StatelessWidget {
  final CategoryDeductionResult result;

  const _DeductibleTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final pct = result.capUsedPercent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _categoryLabelDeductible(l10n, result.category),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink(context),
                  ),
                ),
              ),
              Text(
                formatCurrency(result.finalDeduction),
                style: CalmText.amount(context, weight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${result.irsCategory} · ${l10n.taxDeductionSpent(formatCurrency(result.spent))}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.ink50(context),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.line(context),
              color: pct >= 1.0
                  ? AppColors.ok(context)
                  : AppColors.accent(context),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.taxDeductionCapUsed(
              '${(pct * 100).toStringAsFixed(0)}%',
              formatCurrency(result.annualCap),
            ),
            style: TextStyle(
              fontSize: 11,
              color: AppColors.ink50(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _NonDeductibleTile extends StatelessWidget {
  final CategoryDeductionResult result;

  const _NonDeductibleTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(Icons.block, size: 16, color: AppColors.ink50(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _categoryLabelNonDeductible(l10n, result.category),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.ink70(context),
              ),
            ),
          ),
          CalmPill(
            label: l10n.taxDeductionNotDeductible,
            color: AppColors.ink50(context),
          ),
        ],
      ),
    );
  }
}
