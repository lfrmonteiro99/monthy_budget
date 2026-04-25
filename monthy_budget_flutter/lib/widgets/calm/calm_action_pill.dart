import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';

/// Outlined pill-shaped action button with optional leading icon.
///
/// Used for "Gerar" on mockup #3 (Ementa). Distinct from [CalmPill] which
/// is a status badge with tinted background + no border.
///
/// **Style:**
/// - Border: 1px ink.
/// - Padding: 6 vertical, 12 horizontal.
/// - Radius: 100 (fully rounded).
/// - Icon: 16px ink, 6px right gap.
/// - Label: 13/w600/ink.
class CalmActionPill extends StatelessWidget {
  const CalmActionPill({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
  });

  /// Button label text (e.g. `'Gerar'`).
  final String label;

  /// Optional leading icon rendered at 16px.
  final IconData? icon;

  /// Tap callback — required (this is an action button, not a badge).
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.ink(context), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.ink(context)),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
