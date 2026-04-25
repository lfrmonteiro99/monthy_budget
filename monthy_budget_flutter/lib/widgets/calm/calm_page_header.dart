import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';
import 'calm_eyebrow.dart';

/// Page-level header for non-dashboard screens (Plano & compras, Ementa,
/// Definições). Replaces the Material `AppBar` for these flows.
///
/// **Layout:**
/// ```
/// [back]   [eyebrow]                          [trailing?]
///          [title (Fraunces)]
/// ```
///
/// - Back button is auto-rendered when [showBack] is true (default) AND
///   `Navigator.canPop(context)` is true.
/// - Title uses Fraunces serif at the size you pass (defaults 24).
/// - [trailing] is placed in the top-right (e.g. a `CalmActionPill`).
///
/// **Padding:** 20 horizontal, 12 top, 16 bottom — matches the mockup
/// breathing room. Sits inside `CalmScaffold(bodyPadding: EdgeInsets.zero)`.
class CalmPageHeader extends StatelessWidget {
  const CalmPageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.showBack = true,
    this.trailing,
    this.titleSize = 24,
  });

  /// Small uppercase label rendered above the title (e.g. `'SEMANA 16'`).
  final String eyebrow;

  /// Main page title in Fraunces serif (e.g. `'Plano & compras'`).
  final String title;

  /// Whether to show the back-chevron button. Defaults to true. The
  /// chevron is only rendered when this is true AND the navigator can pop.
  final bool showBack;

  /// Optional trailing widget placed top-right (e.g. `CalmActionPill`).
  final Widget? trailing;

  /// Fraunces title font size. Defaults to 24.
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final canPop = showBack && Navigator.canPop(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (canPop)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 4),
              child: InkWell(
                onTap: () => Navigator.maybePop(context),
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.chevron_left,
                    size: 28,
                    color: AppColors.ink(context),
                  ),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CalmEyebrow(eyebrow),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fraunces(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                    letterSpacing: -0.01 * titleSize,
                    color: AppColors.ink(context),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}
