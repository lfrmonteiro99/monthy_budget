import 'package:flutter/material.dart';
import 'package:monthly_management/theme/app_colors.dart';
import 'package:monthly_management/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/app_settings.dart';
import '../../utils/formatters.dart';
import 'income_icons.dart';

/// Single row in the "Fontes" list on the Income screen.
///
/// Mirrors `calm-income.jsx` §4: rounded-square icon (ok-tinted when
/// received, sunk when expected), label + recurring pill, sub-label
/// (received/expected · date · period), trailing amount with `+€` prefix.
class IncomeSourceRow extends StatelessWidget {
  const IncomeSourceRow({
    super.key,
    required this.source,
    this.onTap,
    this.dividerBelow = true,
  });

  final IncomeSource source;
  final VoidCallback? onTap;
  final bool dividerBelow;

  @override
  Widget build(BuildContext context) {
    final iconBg = source.received
        ? AppColors.ok(context).withValues(alpha: 0.13)
        : AppColors.bgSunk(context);
    final iconFg =
        source.received ? AppColors.ok(context) : AppColors.ink50(context);
    final amountColor =
        source.received ? AppColors.ink(context) : AppColors.ink50(context);

    final row = Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              incomeCategoryIcon(source.category),
              size: 17,
              color: iconFg,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _Body(source: source)),
          const SizedBox(width: 8),
          Text(
            '+${formatCurrency(source.amount)}',
            style: CalmText.amount(
              context,
              size: 15,
              weight: FontWeight.w500,
            ).copyWith(color: amountColor),
          ),
        ],
      ),
    );

    final tappable = onTap != null
        ? InkWell(onTap: onTap, child: row)
        : row;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tappable,
        if (dividerBelow)
          Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 0,
            color: AppColors.line(context),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

}

class _Body extends StatelessWidget {
  const _Body({required this.source});

  final IncomeSource source;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                source.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink(context),
                ),
              ),
            ),
            if (source.recurring) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.line(context)),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  l10n.incomeSourceRecurringPill,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink50(context),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          _subLabel(l10n),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight:
                source.received ? FontWeight.w400 : FontWeight.w600,
            color: source.received
                ? AppColors.ink50(context)
                : AppColors.warn(context),
          ),
        ),
      ],
    );
  }

  String _subLabel(S l10n) {
    final period = _localizedPeriod(l10n, source.period);
    final dateStr = source.date ?? period;
    final base = source.received
        ? l10n.incomeSourceReceivedOn(dateStr)
        : l10n.incomeSourceExpectedOn(dateStr);
    if (source.period == IncomePeriod.oneOff) return base;
    if (source.date == null) return base;
    return '$base · $period';
  }

  String _localizedPeriod(S l10n, IncomePeriod p) {
    switch (p) {
      case IncomePeriod.monthly:
        return l10n.incomePeriodMonthly;
      case IncomePeriod.oneOff:
        return l10n.incomePeriodOneOff;
      case IncomePeriod.yearly:
        return l10n.incomePeriodYearly;
    }
  }
}
