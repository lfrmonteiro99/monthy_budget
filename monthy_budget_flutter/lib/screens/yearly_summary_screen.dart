import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/yearly_summary_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// A screen that displays the yearly summary / annual report.
///
/// Receives a pre-computed [YearlySummaryReport] so it stays a pure
/// presentation widget with no service dependencies.
class YearlySummaryScreen extends StatelessWidget {
  final YearlySummaryReport report;

  const YearlySummaryScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return CalmScaffold(
      title: l10n.yearlySummaryTitle,
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          _OverviewCard(report: report),
          if (report.bestMonth != null || report.worstMonth != null) ...[
            const SizedBox(height: 16),
            _BestWorstCard(report: report),
          ],
          if (report.categoryTotals.isNotEmpty) ...[
            const SizedBox(height: 16),
            _CategoryBreakdownCard(report: report),
          ],
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final YearlySummaryReport report;
  const _OverviewCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final netColor =
        report.netSavings >= 0 ? AppColors.ok(context) : AppColors.bad(context);
    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CalmEyebrow(label: '${report.year}'),
          const SizedBox(height: 12),
          CalmHero(
            eyebrow: l10n.yearlySummaryNetSavings,
            amount: formatCurrency(report.netSavings),
            subtitle: l10n.yearlySummarySavingsRate(
              report.savingsRate.toStringAsFixed(1),
            ),
          ),
          const SizedBox(height: 16),
          _KpiRow(
            label: l10n.yearlySummaryIncome,
            value: formatCurrency(report.totalIncome),
            color: AppColors.ok(context),
          ),
          const SizedBox(height: 8),
          _KpiRow(
            label: l10n.yearlySummaryExpenses,
            value: formatCurrency(report.totalExpenses),
            color: AppColors.bad(context),
          ),
          Divider(color: AppColors.line(context), height: 24),
          _KpiRow(
            label: l10n.yearlySummaryNetSavings,
            value: formatCurrency(report.netSavings),
            color: netColor,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _BestWorstCard extends StatelessWidget {
  final YearlySummaryReport report;
  const _BestWorstCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CalmEyebrow(label: l10n.yearlySummaryHighlights),
          const SizedBox(height: 12),
          if (report.bestMonth != null)
            _KpiRow(
              label: l10n.yearlySummaryBestMonth(report.bestMonth!),
              value: formatCurrency(report.bestMonthNet),
              color: AppColors.ok(context),
            ),
          if (report.bestMonth != null && report.worstMonth != null)
            const SizedBox(height: 8),
          if (report.worstMonth != null)
            _KpiRow(
              label: l10n.yearlySummaryWorstMonth(report.worstMonth!),
              value: formatCurrency(report.worstMonthNet),
              color: AppColors.bad(context),
            ),
        ],
      ),
    );
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  final YearlySummaryReport report;
  const _CategoryBreakdownCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final sorted = report.categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CalmEyebrow(label: l10n.yearlySummaryCategoryBreakdown),
          const SizedBox(height: 12),
          for (var i = 0; i < sorted.length; i++) ...[
            _KpiRow(
              label: sorted[i].key,
              value: formatCurrency(sorted[i].value),
            ),
            if (i < sorted.length - 1)
              Divider(color: AppColors.line(context), height: 16),
          ],
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool bold;

  const _KpiRow({
    required this.label,
    required this.value,
    this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: color ?? AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}
