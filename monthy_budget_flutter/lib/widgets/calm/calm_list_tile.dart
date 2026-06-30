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
/// **Structured variants** (the widget keeps control of the Calm styling — no
/// arbitrary-widget pass-through, which would bypass the design system):
/// - **No-icon row**: pass `leadingIcon: null` (and `leadingColor: null`) to
///   omit the avatar; the text column renders flush-left, still in Calm tokens.
///   For non-transaction rows that have no category icon (e.g. waste/leftover
///   or freeform list items).
/// - **Selectable value**: pass [selectableSubtitle] instead of [subtitle] to
///   render a copyable secondary line (e.g. an invite code) in Calm typography.
///
/// Reference: Monthly Budget Calm handoff §4.4.
class CalmListTile extends StatelessWidget {
  const CalmListTile({
    super.key,
    this.leadingIcon,
    this.leadingColor,
    required this.title,
    this.subtitle,
    this.selectableSubtitle,
    this.trailing,
    this.trailingWidget,
    this.onTap,
  })  : assert(
          (leadingIcon == null) == (leadingColor == null),
          'leadingIcon and leadingColor must be provided together or both omitted',
        ),
        assert(
          subtitle == null || selectableSubtitle == null,
          'Provide either subtitle or selectableSubtitle, not both',
        ),
        assert(
          trailing == null || trailingWidget == null,
          'Provide either trailing or trailingWidget, not both',
        );

  /// Icon displayed inside the 32px circular avatar (16px, [leadingColor]).
  /// When null, the avatar is omitted and the text renders flush-left.
  final IconData? leadingIcon;

  /// Category colour. Applied at full opacity on the icon; at 0.15 alpha for
  /// the avatar background circle. Must be null iff [leadingIcon] is null.
  final Color? leadingColor;

  /// Primary row label — 15px, medium weight, `ink`.
  final String title;

  /// Optional secondary line — 13px, `ink50`.
  final String? subtitle;

  /// Optional copyable secondary line (e.g. an invite code), rendered as a
  /// [SelectableText] in Calm tabular style. Mutually exclusive with [subtitle].
  final String? selectableSubtitle;

  /// Optional trailing amount string, rendered via `CalmText.amount`.
  /// Pass `null` to omit the trailing section.
  final String? trailing;

  /// Optional trailing affordance widget — for actions only (icon button,
  /// quantity stepper, chevron, generate button). NOT a general content slot:
  /// the row's Calm identity (avatar + title/subtitle typography) stays owned
  /// by this widget. Mutually exclusive with [trailing].
  final Widget? trailingWidget;

  /// Optional tap handler. When supplied, the tile is wrapped in an
  /// [InkWell] with a ripple clipped to the tile bounds.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Leading circular avatar (omitted for no-icon rows)
          if (leadingIcon != null) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: leadingColor!.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(leadingIcon, size: 16, color: leadingColor),
            ),
            const SizedBox(width: 12),
          ],
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
                if (selectableSubtitle != null)
                  SelectableText(
                    selectableSubtitle!,
                    style: CalmText.amount(context, size: 16),
                  ),
              ],
            ),
          ),
          // Optional trailing amount / affordance
          if (trailing != null) ...[
            const SizedBox(width: 12),
            Text(trailing!, style: CalmText.amount(context)),
          ] else if (trailingWidget != null) ...[
            const SizedBox(width: 8),
            trailingWidget!,
          ],
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
