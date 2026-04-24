import 'package:flutter/material.dart';

/// A compact status badge following the Calm pill spec (handoff §4.5):
///
/// - Shape: fully rounded (radius 100).
/// - Background: `color.withValues(alpha: 0.12)` — subtle tint.
/// - Text: 11px Inter w600, colour = [color].
/// - Padding: 3px vertical, 10px horizontal.
///
/// Usage:
/// ```dart
/// CalmPill(label: 'ok',   color: AppColors.ok(context))
/// CalmPill(label: '82%',  color: AppColors.warn(context))
/// CalmPill(label: '+€40', color: AppColors.bad(context))
/// ```
class CalmPill extends StatelessWidget {
  const CalmPill({
    super.key,
    required this.label,
    required this.color,
  });

  /// Text displayed inside the pill.
  final String label;

  /// Semantic colour used for both the text and the tinted background.
  /// Pass `AppColors.ok/warn/bad(context)` — never a raw `Color(0x...)`.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
