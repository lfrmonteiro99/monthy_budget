import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';

/// Static helper that opens a Calm-styled `AlertDialog`.
///
/// **Usage:**
/// ```dart
/// final confirmed = await CalmDialog.confirm(
///   context,
///   title: 'Apagar despesa?',
///   body: 'Esta ação não pode ser revertida.',
///   confirmLabel: 'Apagar',
///   destructive: true,
/// );
/// if (confirmed == true) _delete();
/// ```
///
/// Or, for a free-form dialog:
/// ```dart
/// CalmDialog.show(
///   context,
///   title: 'Detalhes',
///   child: MyContent(),
///   actions: [TextButton(onPressed: ..., child: Text('Fechar'))],
/// );
/// ```
///
/// Reference: Monthly Budget Calm handoff — modal patterns.
class CalmDialog {
  CalmDialog._();

  /// Opens a generic Calm dialog and returns its `Future<T?>` result.
  ///
  /// - Surface: `AppColors.card(context)`.
  /// - Radius: 20px (matches Calm card radius).
  /// - No elevation / shadow.
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    Widget? child,
    String? body,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    assert(child != null || body != null,
        'Provide either `child` or `body` text.');
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card(ctx),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        title: title != null
            ? Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink(ctx),
                ),
              )
            : null,
        content: child ??
            Text(
              body!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.ink70(ctx),
                height: 1.4,
              ),
            ),
        actions: actions,
      ),
    );
  }

  /// Opens a confirm/cancel dialog. Resolves to `true` if confirmed,
  /// `false` if cancelled, `null` if dismissed via barrier tap.
  ///
  /// Pass [destructive] = true to render the confirm button in `bad`
  /// (used for delete / wipe / unrecoverable actions).
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    String? body,
    String confirmLabel = 'OK',
    String cancelLabel = 'Cancelar',
    bool destructive = false,
  }) {
    return show<bool>(
      context,
      title: title,
      body: body,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: AppColors.bad(context),
                  foregroundColor: AppColors.bg(context),
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
