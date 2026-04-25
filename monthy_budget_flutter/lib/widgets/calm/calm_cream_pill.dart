import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';

/// Warm-cream marketing pill with optional leading icon.
///
/// Visually distinct from [CalmPill] (semantic status, tinted bg) — used
/// for plan/subscription badges, premium markers, etc. Mockup #4.
///
/// **Style:**
/// - Background: `AppColors.pillCream(context)`.
/// - Text: `AppColors.pillCreamInk(context)`, 12/w600.
/// - Icon: 14px, same colour as text.
/// - Padding: 4 vertical, 10 horizontal.
/// - Radius: 100.
class CalmCreamPill extends StatelessWidget {
  const CalmCreamPill({
    super.key,
    required this.label,
    this.icon,
  });

  /// Badge text (e.g. `'✦ Plano Plus'`).
  final String label;

  /// Optional leading icon rendered at 14px in pillCreamInk colour.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = AppColors.pillCreamInk(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.pillCream(context),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
