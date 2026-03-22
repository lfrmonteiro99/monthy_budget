import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        surfaceTintColor: AppColors.surface(context),
        title: Text(
          l10n.yearlySummaryTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // -- Overview card
          _OverviewCard(report: report),
          const SizedBox(height: 16),
          // -- Best / worst months
          if (report.bestMonth != null || report.worstMonth != null)
            _BestWorstCard(report: report),
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
    return Card(
      color: AppColors.surface(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${report.year}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 12),
            _Row(
              label: l10n.yearlySummaryIncome,
              value: formatCurrency(report.totalIncome),
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            _Row(
              label: l10n.yearlySummaryExpenses,
              value: formatCurrency(report.totalExpenses),
              color: Colors.red,
            ),
            const Divider(height: 24),
            _Row(
              label: l10n.yearlySummaryNetSavings,
              value: formatCurrency(report.netSavings),
              color: report.netSavings >= 0 ? Colors.green : Colors.red,
              bold: true,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.yearlySummarySavingsRate(
                report.savingsRate.toStringAsFixed(1),
              ),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
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
    return Card(
      color: AppColors.surface(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.yearlySummaryHighlights,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 12),
            if (report.bestMonth != null)
              _Row(
                label: l10n.yearlySummaryBestMonth(report.bestMonth!),
                value: formatCurrency(report.bestMonthNet),
                color: Colors.green,
              ),
            if (report.worstMonth != null) ...[
              const SizedBox(height: 8),
              _Row(
                label: l10n.yearlySummaryWorstMonth(report.worstMonth!),
                value: formatCurrency(report.worstMonthNet),
                color: Colors.red,
              ),
            ],
          ],
        ),
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

    return Card(
      color: AppColors.surface(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.yearlySummaryCategoryBreakdown,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 12),
            for (final entry in sorted) ...[
              _Row(
                label: entry.key,
                value: formatCurrency(entry.value),
              ),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool bold;

  const _Row({
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
