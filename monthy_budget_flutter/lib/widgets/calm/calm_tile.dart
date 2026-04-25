import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';

/// Vertical quick-action tile: outlined icon + label + count subtitle.
///
/// Used in mockup #2 ("Plano & compras") for the 3-tile horizontal Row.
///
/// **Layout (top → bottom, cross-axis start):**
/// ```
/// [icon 24px ink]
/// 12px
/// [label 15/w600/ink]
/// 2px
/// [count 13/ink70]
/// ```
///
/// Wrap in `Expanded` to make 3 tiles share row width:
/// ```dart
/// Row(children: [
///   Expanded(child: CalmTile(...)),
///   const SizedBox(width: 12),
///   Expanded(child: CalmTile(...)),
///   const SizedBox(width: 12),
///   Expanded(child: CalmTile(...)),
/// ])
/// ```
class CalmTile extends StatelessWidget {
  const CalmTile({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    this.onTap,
  });

  /// Icon rendered at 24px in ink colour.
  final IconData icon;

  /// Primary label (e.g. `'Lista'`).
  final String label;

  /// Secondary count/subtitle (e.g. `'14 itens'`).
  final String count;

  /// Optional tap handler. When provided, wraps content in an `InkWell`.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: AppColors.ink(context)),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.ink(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: TextStyle(fontSize: 13, color: AppColors.ink70(context)),
          ),
        ],
      ),
    );

    if (onTap == null) return Card(child: content);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: content,
      ),
    );
  }
}
