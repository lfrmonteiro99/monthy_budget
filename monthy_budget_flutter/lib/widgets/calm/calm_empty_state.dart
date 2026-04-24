import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';

/// Describes the optional call-to-action rendered below a [CalmEmptyState].
///
/// Use a plain class (not a Dart record) for clean analysis across all
/// analyzer versions.
class CalmEmptyStateAction {
  const CalmEmptyStateAction({
    required this.label,
    required this.onPressed,
  });

  /// Button label text.
  final String label;

  /// Callback invoked when the button is tapped.
  final VoidCallback onPressed;
}

/// Centred empty-state block: outlined icon, title, body copy, and an
/// optional text-button CTA.
///
/// Layout (top → bottom, cross-axis centred):
/// ```
/// [icon 32px ink50]
/// 16px
/// [title 17px w600 ink]
/// 8px
/// [body 14px ink70, max 2 lines, centred]
/// 20px + [TextButton accent] (if action supplied)
/// ```
///
/// **Rules:**
/// - Always pass an outlined `Icons.*` variant (e.g. `Icons.inbox_outlined`).
///   Custom SVG illustrations require design approval.
/// - Keep [body] under ~60 characters so it wraps naturally at 2 lines on
///   a 320px viewport.
///
/// Reference: Monthly Budget Calm handoff §4.7.
class CalmEmptyState extends StatelessWidget {
  const CalmEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  /// Outlined Material icon displayed at 32px in `ink50`.
  final IconData icon;

  /// Short headline — 17px, w600, `ink`.
  final String title;

  /// Context sentence — 14px, `ink70`, max 2 lines, centred.
  final String body;

  /// Optional call-to-action. When supplied, a `TextButton` with accent
  /// foreground is rendered 20px below [body].
  final CalmEmptyStateAction? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 32, color: AppColors.ink50(context)),
        const SizedBox(height: 16),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.ink(context),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: TextStyle(fontSize: 14, color: AppColors.ink70(context)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        if (action != null) ...[
          const SizedBox(height: 20),
          TextButton(
            onPressed: action!.onPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent(context),
            ),
            child: Text(action!.label),
          ),
        ],
      ],
    );
  }
}
