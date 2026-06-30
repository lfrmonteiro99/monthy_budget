import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class Stars extends StatelessWidget {
  final int complexity;
  const Stars(this.complexity, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < complexity ? Icons.star : Icons.star_border,
          size: 13,
          color: AppColors.warning(context),
        ),
      ),
    );
  }
}

class NutriBadge extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const NutriBadge(this.value, this.label, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Justified: micro nutrition badge — no Calm equivalent for inline tinted label
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        // Justified: micro nutrition badge colour tint
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$value $label',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

