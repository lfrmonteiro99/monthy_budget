import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';

/// Static helper that opens a Calm-styled modal bottom sheet.
///
/// **Usage:**
/// ```dart
/// CalmBottomSheet.show(
///   context,
///   builder: (_) => CalmBottomSheetContent(
///     title: 'Editar despesa',
///     child: MyForm(),
///     primaryAction: FilledButton(
///       onPressed: _save,
///       child: const Text('Guardar'),
///     ),
///   ),
/// );
/// ```
///
/// **Escape hatch:** if you need a sheet without the default drag handle /
/// title chrome (e.g. a full-screen picker), pass your own widget directly
/// in [builder] instead of wrapping it in [CalmBottomSheetContent]:
/// ```dart
/// CalmBottomSheet.show(context, builder: (_) => MyCustomSheet());
/// ```
///
/// This class is NOT a widget — do not extend or instantiate it.
///
/// Reference: Monthly Budget Calm handoff §4.8.
class CalmBottomSheet {
  CalmBottomSheet._();

  /// Opens a modal bottom sheet with Calm chrome:
  /// - Background: `AppColors.card(context)`.
  /// - Top corner radius: 24px.
  /// - No elevation / shadow.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool isDismissible = true,
    bool isScrollControlled = true,
    String? title,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      backgroundColor: AppColors.card(context),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: builder,
    );
  }
}

/// Default Calm bottom sheet content layout.
///
/// Renders, from top to bottom:
/// 1. Drag handle (40×4, `ink20`, centred, 12px from top).
/// 2. Optional [title] at 17px w600.
/// 3. 24px gap.
/// 4. Caller-supplied [child].
/// 5. If [primaryAction] is provided, a safe-area padded full-width CTA
///    at the bottom.
///
/// Pass this into [CalmBottomSheet.show]'s `builder` for 90% of sheets:
/// ```dart
/// CalmBottomSheet.show(
///   context,
///   builder: (_) => CalmBottomSheetContent(
///     title: 'Detalhes',
///     child: MyContent(),
///   ),
/// );
/// ```
class CalmBottomSheetContent extends StatelessWidget {
  const CalmBottomSheetContent({
    super.key,
    this.title,
    required this.child,
    this.primaryAction,
  });

  /// Optional sheet title — 17px, w600, `ink`.
  final String? title;

  /// Main content area.
  final Widget child;

  /// Optional full-width CTA rendered at the bottom, safe-area padded.
  /// Typically a `FilledButton` or `OutlinedButton`.
  final Widget? primaryAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.ink20(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: 16),
            Text(
              title!,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.ink(context),
              ),
            ),
          ],
          const SizedBox(height: 24),
          child,
          if (primaryAction != null) ...[
            const SizedBox(height: 16),
            SafeArea(
              top: false,
              child: SizedBox(width: double.infinity, child: primaryAction),
            ),
          ],
        ],
      ),
    );
  }
}
