import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/formatters.dart';

/// "Taxa de poupança" insight card.
///
/// Mirrors `calm-income.jsx` §6: green eyebrow with trend-up icon,
/// 22px Fraunces headline, body copy + two CTAs.
class SavingsRateInsightCard extends StatelessWidget {
  const SavingsRateInsightCard({
    super.key,
    required this.savedThisMonth,
    required this.savingsRate,
    required this.onAllocate,
    required this.onViewProjection,
  });

  final double savedThisMonth;
  /// Fraction (0.30 → 30%).
  final double savingsRate;
  final VoidCallback onAllocate;
  final VoidCallback onViewProjection;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final ok = AppColors.ok(context);
    final ink = AppColors.ink(context);
    final ink70 = AppColors.ink70(context);
    final pct = (savingsRate * 100).round();
    final yearly = savedThisMonth * 12;

    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, size: 14, color: ok),
              const SizedBox(width: 6),
              Text(
                l10n.incomeInsightEyebrow.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ok,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.incomeInsightHeadline(pct),
            style: GoogleFonts.fraunces(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              height: 1.25,
              letterSpacing: -0.3,
              color: ink,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.incomeInsightBody(formatCurrency(yearly)),
            style: TextStyle(fontSize: 13, height: 1.5, color: ink70),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onAllocate,
                  style: FilledButton.styleFrom(
                    backgroundColor: ink,
                    foregroundColor: AppColors.inkInverse(context),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(l10n.incomeInsightAllocateCta),
                ),
              ),
              const SizedBox(width: 8),
              CalmActionPill(
                label: l10n.incomeInsightProjectionCta,
                onTap: onViewProjection,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
