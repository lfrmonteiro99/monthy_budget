import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';
import 'package:monthly_management/theme/app_theme.dart';

/// Single label-on-left, value-on-right row for KPI grouped lists.
///
/// **Layout:** 16px vertical padding; row baseline-aligned. Used in:
/// - Ementa "Resumo · semana" card (mockup #3)
/// - Anywhere else that previously used hand-rolled `Row(spaceBetween)` for
///   label/value pairs.
///
/// **Background:** none — wrap in `CalmCard`.
/// Dividers are the parent's responsibility:
/// `Divider(color: AppColors.line(context), height: 1)`.
class CalmKpiRow extends StatelessWidget {
  const CalmKpiRow(this.label, this.value, {super.key, this.valueStyle});

  /// Descriptive label on the left side of the row (e.g. `'Calorias médias'`).
  final String label;

  /// Value text on the right side (e.g. `'1 840 kcal'`).
  final String value;

  /// Override for the value style. Defaults to `CalmText.amount(c)` so
  /// numbers tabular-align between rows.
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.ink70(context),
              ),
            ),
          ),
          Text(value, style: valueStyle ?? CalmText.amount(context)),
        ],
      ),
    );
  }
}
