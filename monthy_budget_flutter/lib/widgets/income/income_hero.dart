import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/formatters.dart';

/// Hero block for the Income screen.
///
/// Mirrors `calm-income.jsx` §2:
/// - eyebrow `"RECEBIDO ESTE MÊS"` (handled by parent → kept simple here)
/// - 64px Fraunces amount with €/cents de-emphasised
/// - status row: "X entradas confirmadas · +€Y prev."
/// - 2px hairline progress: received vs planned
class IncomeHero extends StatelessWidget {
  const IncomeHero({
    super.key,
    required this.received,
    required this.expected,
    required this.confirmedCount,
  });

  final double received;
  final double expected;
  final int confirmedCount;

  double get _planned => received + expected;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final symbol = currencySymbol();
    final whole = received.floor();
    final cents = ((received - whole) * 100).round().toString().padLeft(2, '0');
    final progress = _planned > 0 ? (received / _planned).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.incomeHeroLabel,
            style: TextStyle(fontSize: 12, color: AppColors.ink50(context)),
          ),
          const SizedBox(height: 6),
          _Amount(symbol: symbol, whole: whole, cents: cents),
          const SizedBox(height: 10),
          _StatusRow(
            confirmedCount: confirmedCount,
            expected: expected,
          ),
          const SizedBox(height: 18),
          _Hairline(progress: progress, planned: _planned),
        ],
      ),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({
    required this.symbol,
    required this.whole,
    required this.cents,
  });

  final String symbol;
  final int whole;
  final String cents;

  @override
  Widget build(BuildContext context) {
    final ink = AppColors.ink(context);
    final base = GoogleFonts.fraunces(
      fontSize: 64,
      fontWeight: FontWeight.w400,
      height: 1.02,
      letterSpacing: -1.0,
      color: ink,
    );
    return RichText(
      text: TextSpan(
        style: base,
        children: [
          TextSpan(
            text: symbol,
            style: GoogleFonts.fraunces(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              color: ink.withValues(alpha: 0.5),
              letterSpacing: 0,
            ),
          ),
          const TextSpan(text: ' '),
          TextSpan(text: '$whole'),
          TextSpan(
            text: ',$cents',
            style: GoogleFonts.fraunces(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: ink.withValues(alpha: 0.45),
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.confirmedCount,
    required this.expected,
  });

  final int confirmedCount;
  final double expected;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.ok(context),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          l10n.incomeConfirmedEntries(confirmedCount),
          style: TextStyle(fontSize: 13, color: AppColors.ink70(context)),
        ),
        if (expected > 0) ...[
          const SizedBox(width: 8),
          Text('·', style: TextStyle(color: AppColors.ink50(context))),
          const SizedBox(width: 8),
          Text(
            l10n.incomeExpectedShort(formatCurrency(expected)),
            style: TextStyle(fontSize: 13, color: AppColors.ink70(context)),
          ),
        ],
      ],
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline({required this.progress, required this.planned});

  final double progress;
  final double planned;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 2,
            child: Stack(
              children: [
                Container(color: AppColors.ink20(context)),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(color: AppColors.ink(context)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.incomeHairlineReceived,
              style: TextStyle(fontSize: 11, color: AppColors.ink50(context)),
            ),
            Text(
              l10n.incomeHairlinePlanned(formatCurrency(planned)),
              style: TextStyle(fontSize: 11, color: AppColors.ink50(context)),
            ),
          ],
        ),
      ],
    );
  }
}
