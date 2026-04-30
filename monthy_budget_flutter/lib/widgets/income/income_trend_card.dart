import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/formatters.dart';

/// 6-month income trend card.
///
/// Mirrors `calm-income.jsx` §3:
/// - eyebrow + Fraunces 28px average
/// - delta pill (`+4,2%`) — green when positive, ink50 outline when ≤ 0
/// - mini bar chart (6 cols), current month highlighted in accent
class IncomeTrendCard extends StatelessWidget {
  const IncomeTrendCard({
    super.key,
    required this.values,
    required this.average,
    required this.delta,
  });

  /// Six values, oldest → newest. Length is enforced upstream by
  /// `IncomeService`.
  final List<double> values;
  final double average;
  /// Fraction (0.042 → +4,2%).
  final double delta;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final now = DateTime.now();
    final months = List.generate(
      6,
      (i) {
        final m = DateTime(now.year, now.month - (5 - i), 1);
        return localizedMonthAbbr(l10n, m.month);
      },
    );

    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(average: average, delta: delta),
          const SizedBox(height: 16),
          SizedBox(
            height: 78,
            child: _Bars(values: values, months: months),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.average, required this.delta});

  final double average;
  final double delta;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isPositive = delta > 0;
    final isFlat = delta.abs() < 0.0005;
    final pillColor = isPositive
        ? AppColors.ok(context)
        : (isFlat ? AppColors.ink50(context) : AppColors.warn(context));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CalmEyebrow(l10n.incomeTrendEyebrow.toUpperCase()),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  text: formatCurrency(average),
                  style: GoogleFonts.fraunces(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                    color: AppColors.ink(context),
                  ),
                  children: [
                    TextSpan(
                      text: ' ${l10n.incomeTrendAverageSuffix}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.ink50(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: pillColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            _formatDelta(delta),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: pillColor,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDelta(double d) {
    final pct = (d * 100);
    final rounded = (pct * 10).roundToDouble() / 10;
    final sign = rounded > 0 ? '+' : '';
    return '$sign${rounded.toStringAsFixed(1).replaceAll('.', ',')}%';
  }
}

class _Bars extends StatelessWidget {
  const _Bars({required this.values, required this.months});

  final List<double> values;
  final List<String> months;

  @override
  Widget build(BuildContext context) {
    final max = values.fold<double>(0, (a, b) => b > a ? b : a);
    final accent = AppColors.accent(context);
    final ink = AppColors.ink(context);
    final last = values.length - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(values.length, (i) {
        final v = values[i];
        final ratio = max > 0 ? v / max : 0.0;
        final current = i == last;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == last ? 0 : 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 64,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: ratio == 0 ? 0.02 : ratio.clamp(0.05, 1.0),
                      widthFactor: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: current ? accent : ink.withValues(alpha: 0.85),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  months[i],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                    color: current ? accent : AppColors.ink50(context),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
