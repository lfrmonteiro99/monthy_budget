import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';

/// Circular avatar with monochrome initials.
///
/// Used on:
///   - Dashboard top header (size 36, mockup #1)
///   - Settings user card (size 64, mockup #4)
///
/// **Surface colour:** always [`AppColors.inkSurface`] — near-black on
/// light, ink on dark. Deliberately NOT [`AppColors.ink`] in dark mode
/// (see token notes in spec §0).
///
/// **Initials:** caller passes a 1–2-character string; widget renders as-is
/// (no upper-casing). For raw names, pre-process at the call site:
/// ```dart
/// final initials = name
///     .split(RegExp(r'\s+'))
///     .where((s) => s.isNotEmpty)
///     .map((s) => s[0])
///     .take(2)
///     .join()
///     .toUpperCase();
/// ```
class CalmAvatarBadge extends StatelessWidget {
  const CalmAvatarBadge({
    super.key,
    required this.initials,
    this.size = 36,
    this.onTap,
  });

  /// 1–2 character pre-formatted initials (e.g. `'RS'`).
  final String initials;

  /// Diameter in logical pixels. Defaults to 36.
  final double size;

  /// Optional tap handler. Adds an `InkWell` ripple clipped to the circle.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Font size scales linearly: 36 → 13, 64 → 24.
    final fontSize = (size * 13 / 36).clamp(11, 28).toDouble();

    final inner = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.inkSurface(context),
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.inkInverse(context),
          letterSpacing: 0.5,
        ),
      ),
    );

    if (onTap == null) return inner;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: inner,
    );
  }
}
