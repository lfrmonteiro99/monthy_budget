import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';

/// Static helper that surfaces Calm-styled `SnackBar`s.
///
/// Three semantic variants:
/// - [CalmSnack.show]    — neutral (ink surface).
/// - [CalmSnack.success] — `ok` accent line.
/// - [CalmSnack.error]   — `bad` accent line.
///
/// All variants use:
/// - `SnackBarBehavior.floating`.
/// - 14px radius (matches `app_theme.dart` snackBarTheme).
/// - 3-second default duration.
/// - Inter 14px w500 text in `bg` colour for contrast against the ink fill.
///
/// Usage:
/// ```dart
/// CalmSnack.success(context, 'Despesa guardada');
/// CalmSnack.error(context, 'Falha ao sincronizar');
/// CalmSnack.show(context, 'Sessão prolongada por 5 min');
/// ```
class CalmSnack {
  CalmSnack._();

  /// Neutral snackbar — uses theme defaults (ink surface, bg text).
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _push(context, message, accent: null, duration: duration, action: action);
  }

  /// Success snackbar — adds a 3px-wide leading rule in `ok`.
  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _push(context, message,
        accent: AppColors.ok(context), duration: duration, action: action);
  }

  /// Error snackbar — adds a 3px-wide leading rule in `bad`.
  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    _push(context, message,
        accent: AppColors.bad(context), duration: duration, action: action);
  }

  static void _push(
    BuildContext context,
    String message, {
    required Color? accent,
    required Duration duration,
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        action: action,
        content: Row(
          children: [
            if (accent != null) ...[
              Container(
                width: 3,
                height: 24,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.bg(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
