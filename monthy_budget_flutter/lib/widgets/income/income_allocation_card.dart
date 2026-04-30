import 'package:flutter/material.dart';
import 'package:monthly_management/theme/app_colors.dart';
import 'package:monthly_management/theme/app_theme.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/income_service.dart';
import '../../utils/formatters.dart';

/// "Para onde foi" card — stacked bar (12px) plus per-bucket legend.
///
/// Mirrors `calm-income.jsx` §5.
class IncomeAllocationCard extends StatelessWidget {
  const IncomeAllocationCard({
    super.key,
    required this.allocation,
    required this.planned,
  });

  final IncomeAllocation allocation;
  final double planned;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final ink = AppColors.ink(context);
    final ink50 = AppColors.ink50(context);
    final ok = AppColors.ok(context);
    final sunk = AppColors.bgSunk(context);

    final rows = <_LegendItem>[
      _LegendItem(
        color: ink,
        label: l10n.incomeAllocFixedLabel,
        sub: l10n.incomeAllocFixedSub,
        value: allocation.fixed,
      ),
      _LegendItem(
        color: ink50,
        label: l10n.incomeAllocVariableLabel,
        sub: l10n.incomeAllocVariableSub,
        value: allocation.variable,
      ),
      _LegendItem(
        color: ok,
        label: l10n.incomeAllocSavedLabel,
        sub: l10n.incomeAllocSavedSub,
        value: allocation.saved,
      ),
      _LegendItem(
        color: sunk,
        label: l10n.incomeAllocRemainingLabel,
        sub: l10n.incomeAllocRemainingSub,
        value: allocation.remaining,
        bordered: true,
      ),
    ];

    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 12,
              child: planned <= 0
                  ? Container(color: sunk)
                  : Row(
                      children: [
                        _bar(allocation.fixed, ink),
                        _bar(allocation.variable, ink50),
                        _bar(allocation.saved, ok),
                        _bar(allocation.remaining, sunk),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 14),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LegendRow(item: row, planned: planned),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double value, Color color) {
    if (value <= 0) return const SizedBox.shrink();
    return Expanded(
      flex: (value * 1000).round().clamp(1, 1 << 20),
      child: Container(color: color),
    );
  }
}

class _LegendItem {
  final Color color;
  final String label;
  final String sub;
  final double value;
  final bool bordered;

  _LegendItem({
    required this.color,
    required this.label,
    required this.sub,
    required this.value,
    this.bordered = false,
  });
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.item, required this.planned});

  final _LegendItem item;
  final double planned;

  @override
  Widget build(BuildContext context) {
    final pct = planned > 0 ? (item.value / planned * 100).round() : 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(3),
            border: item.bordered
                ? Border.all(color: AppColors.ink20(context), width: 1)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink(context),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                item.sub,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.ink50(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            style: CalmText.amount(
              context,
              size: 13,
              weight: FontWeight.w500,
            ),
            children: [
              TextSpan(text: formatCurrency(item.value)),
              TextSpan(
                text: '  $pct%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.ink50(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
