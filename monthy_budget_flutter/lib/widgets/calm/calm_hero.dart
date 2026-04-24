import 'package:flutter/material.dart';
import 'package:monthly_management/theme/app_colors.dart';
import 'package:monthly_management/theme/app_theme.dart';
import 'calm_eyebrow.dart';

/// The primary screen hero block: eyebrow label + large Fraunces amount +
/// optional subtitle line.
///
/// Layout (top-to-bottom, cross-axis start by default):
/// ```
/// ESTE MÊS          ← CalmEyebrow
/// €1 247,30         ← CalmText.display (Fraunces, [size] default 44)
/// restam 12 dias    ← 14px ink70 (optional)
/// ```
///
/// **IMPORTANT — max one Fraunces display per screen.**
/// If a screen needs a second big number, use `CalmText.amount` (Inter tabular)
/// instead. Stacking two Fraunces heroes breaks the visual hierarchy and is
/// explicitly against the Calm design system.
///
/// Reference: Monthly Budget Calm handoff §4.2.
class CalmHero extends StatelessWidget {
  const CalmHero({
    super.key,
    required this.eyebrow,
    required this.amount,
    this.subtitle,
    this.size = 44,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  /// Short uppercase label above the amount (e.g. `"ESTE MÊS"`).
  final String eyebrow;

  /// The hero number or currency string (e.g. `"€1 247,30"`).
  final String amount;

  /// Optional secondary line below the amount (e.g. `"restam 12 dias"`).
  /// Rendered at 14px, `ink70`.
  final String? subtitle;

  /// Font size for the Fraunces display amount. Defaults to 44.
  final double size;

  /// Column cross-axis alignment. Defaults to [CrossAxisAlignment.start].
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        CalmEyebrow(eyebrow),
        const SizedBox(height: 8),
        Text(amount, style: CalmText.display(context, size: size)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(fontSize: 14, color: AppColors.ink70(context)),
          ),
        ],
      ],
    );
  }
}
