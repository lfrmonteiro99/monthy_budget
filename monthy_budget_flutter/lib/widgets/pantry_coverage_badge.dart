import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Small badge showing pantry coverage percentage for a recipe.
class PantryCoverageBadge extends StatelessWidget {
  final double coverageRatio;

  const PantryCoverageBadge({
    super.key,
    required this.coverageRatio,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (coverageRatio * 100).round();
    if (pct == 0) return const SizedBox.shrink();

    final Color bgColor;
    final Color fgColor;
    if (coverageRatio >= 0.75) {
      bgColor = AppColors.successBackground(context);
      fgColor = AppColors.success(context);
    } else if (coverageRatio >= 0.4) {
      bgColor = AppColors.warningBackground(context);
      fgColor = AppColors.warning(context);
    } else {
      bgColor = AppColors.surfaceVariant(context);
      fgColor = AppColors.textMuted(context);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.kitchen_outlined, size: 12, color: fgColor),
          const SizedBox(width: 3),
          Text(
            '$pct%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }
}
