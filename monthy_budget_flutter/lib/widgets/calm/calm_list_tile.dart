import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';
import 'package:monthly_management/theme/app_theme.dart';

/// A bare transaction/expense row for use inside a grouped container.
///
/// Layout (horizontal, vertically centred):
/// ```
/// [32px circle avatar]  12px  [title + subtitle (expanded)]  [trailing amount]
/// ```
///
/// **Important design rules:**
/// - This widget sets NO background — the grouped container owns the surface
///   colour (`AppColors.card` or `AppColors.bgSunk`).
/// - Dividers between rows are the **parent's** responsibility:
///   `Divider(color: AppColors.line(context), height: 1)`.
/// - The [leadingColor] comes from `AppColors.categoryColor(...)` at the
///   call site; this widget applies a 0.15-alpha tint automatically for the
///   avatar background.
///
/// Reference: Monthly Budget Calm handoff §4.4.
class CalmListTile extends StatelessWidget {
  const CalmListTile({
    super.key,
    required this.leadingIcon,
    required this.leadingColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  /// Icon displayed inside the 32px circular avatar (16px, [leadingColor]).
  final IconData leadingIcon;

  /// Category colour. Applied at full opacity on the icon; at 0.15 alpha for
  /// the avatar background circle.
  final Color leadingColor;

  /// Primary row label — 15px, medium weight, `ink`.
  final String title;

  /// Optional secondary line — 13px, `ink50`.
  final String? subtitle;

  /// Optional trailing amount string, rendered via `CalmText.amount`.
  /// Pass `null` to omit the trailing section.
  final String? trailing;

  /// Optional tap handler. When supplied, the tile is wrapped in an
  /// [InkWell] with a ripple clipped to the tile bounds.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Leading circular avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: leadingColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(leadingIcon, size: 16, color: leadingColor),
          ),
          const SizedBox(width: 12),
          // Title + optional subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink(context),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.ink50(context),
                    ),
                  ),
              ],
            ),
          ),
          // Optional trailing amount
          if (trailing != null)
            Text(trailing!, style: CalmText.amount(context)),
        ],
      ),
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      child: content,
    );
  }
}
