import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';
import 'calm_eyebrow.dart';

/// Two-line dashboard header:
///   [eyebrow]
///   [title text]  [chevron]    ...trailing actions
///
/// Replaces the Material `AppBar` for screens whose top chrome is a
/// custom 2-line title block (Calm dashboard, "casa" landing pages).
///
/// **Geometry:**
/// - Outer padding: `EdgeInsets.fromLTRB(20, 8, 20, 8)`.
/// - Title row vertical 2px gap.
/// - Trailing actions are a `Wrap`/`Row` you supply; this widget does not
///   prescribe icon styling — pass `IconButton` or `CalmAvatarBadge`.
///
/// **Tap-to-pick:** if [onTitleTap] is provided, the title + chevron are
/// wrapped in an `InkWell`. The chevron is rendered automatically when
/// `onTitleTap` is non-null. Pass null for static titles.
///
/// Reference: Calm redesign mockup #1.
class CalmHeader extends StatelessWidget {
  const CalmHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.onTitleTap,
    this.actions = const [],
  });

  /// Small uppercase label rendered above the title (e.g. `'CASA SILVA'`).
  final String eyebrow;

  /// Main title text (e.g. `'Abril 2026'`).
  final String title;

  /// Optional tap handler for the title block. When non-null a chevron-down
  /// icon is rendered after the title and the row becomes tappable.
  final VoidCallback? onTitleTap;

  /// Trailing widgets (icons, avatars). Rendered right-aligned with 8px gap
  /// between siblings.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final titleRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppColors.ink(context),
            ),
          ),
        ),
        if (onTitleTap != null) ...[
          const SizedBox(width: 4),
          Icon(Icons.expand_more, size: 20, color: AppColors.ink70(context)),
        ],
      ],
    );

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CalmEyebrow(eyebrow),
        const SizedBox(height: 2),
        if (onTitleTap != null)
          InkWell(
            onTap: onTitleTap,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: titleRow,
            ),
          )
        else
          titleRow,
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: titleBlock),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            actions[i],
          ],
        ],
      ),
    );
  }
}
