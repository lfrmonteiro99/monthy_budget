import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';
import 'calm_eyebrow.dart';

/// Meal-list row: rounded-square thumbnail + 3-line text column.
///
/// Used in:
///   - Plano & compras "Próximas refeições" preview (mockup #2)
///   - Ementa drilldown / weekly meal lists (mockup #3 detail view)
///
/// **Layout:**
/// ```
/// [44 thumbnail]  16  [eyebrow / title / meta]    [trailing?]
/// ```
///
/// **Background:** none — parent owns surface (use inside a `CalmCard`).
/// Dividers between rows are the parent's responsibility:
/// `Divider(color: AppColors.line(context), height: 1, indent: 60)`.
///
/// The 60-indent matches: 44 thumb + 16 gap.
class CalmMealRow extends StatelessWidget {
  const CalmMealRow({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.meta,
    this.thumbnail,
    this.onTap,
  });

  /// Small uppercase label above the title (e.g. `'Hoje · jantar'`).
  /// Note: not all-uppercase per mockup — eyebrow style is rendered as-is.
  final String eyebrow;

  /// Meal name (e.g. `'Massa com pesto e frango'`).
  final String title;

  /// Metadata line (e.g. `'20min · €4,20/pessoa'`).
  final String meta;

  /// Optional thumbnail widget. When null, a 44×44 rounded `bgSunk` placeholder
  /// is rendered. Pass an `Image.network` or icon as needed.
  final Widget? thumbnail;

  /// Optional tap handler.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.bgSunk(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.restaurant_outlined,
          size: 22, color: AppColors.ink50(context)),
    );

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: thumbnail != null
                ? SizedBox(width: 44, height: 44, child: thumbnail)
                : placeholder,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CalmEyebrow(eyebrow),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.ink70(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}
