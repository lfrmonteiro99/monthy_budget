import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/spending_anomaly_service.dart';
import '../theme/app_colors.dart';
import '../utils/category_helpers.dart';
import '../utils/formatters.dart';
import 'calm/calm.dart';
import 'info_icon_button.dart';

/// Dashboard card that highlights categories with spending anomalies.
class SpendingAnomalyCard extends StatelessWidget {
  final List<SpendingAnomaly> anomalies;

  const SpendingAnomalyCard({
    super.key,
    required this.anomalies,
  });

  @override
  Widget build(BuildContext context) {
    if (anomalies.isEmpty) return const SizedBox.shrink();

    final l10n = S.of(context);

    return CalmCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up,
                  size: 18, color: AppColors.error(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.spendingAnomalyTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              InfoIconButton(
                title: l10n.spendingAnomalyTitle,
                body: l10n.spendingAnomalyInfo,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...anomalies.take(5).map((a) => _AnomalyRow(anomaly: a)),
        ],
      ),
    );
  }
}

class _AnomalyRow extends StatelessWidget {
  final SpendingAnomaly anomaly;

  const _AnomalyRow({required this.anomaly});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final label = localizedCategoryLabel(anomaly.category, l10n);
    final deviationText = '+${anomaly.deviationPercent.round()}%';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Semantics(
        label: '$label: $deviationText above average',
        child: Row(
          children: [
            Icon(
              categoryIconByName(anomaly.category),
              size: 16,
              color: AppColors.textSecondary(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  Text(
                    l10n.spendingAnomalyAvg(
                      formatCurrency(anomaly.averageAmount),
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted(context),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(anomaly.currentAmount),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error(context),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    deviationText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
