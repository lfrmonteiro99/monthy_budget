import 'package:flutter/material.dart';
import 'package:monthly_management/theme/app_colors.dart';

/// A thin `Scaffold` wrapper that applies the Calm design baseline:
///
/// - Background set to `AppColors.bg(context)` (warm off-white / near-black).
/// - Body wrapped in `SafeArea` with 20px horizontal padding; sections own
///   their own vertical spacing.
/// - AppBar is constructed only when [title] is supplied — transparent,
///   zero elevation, no scroll-under tint. Omitting [title] leaves room for
///   custom headers (e.g. the Dashboard hero-as-header pattern).
/// - Default `automaticallyImplyLeading` is preserved so the OS back button
///   appears on push routes without extra wiring.
class CalmScaffold extends StatelessWidget {
  const CalmScaffold({
    super.key,
    this.title,
    this.actions,
    this.leading,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  /// Optional AppBar title. When null, no AppBar is built.
  final String? title;

  /// AppBar trailing actions. Ignored when [title] is null.
  final List<Widget>? actions;

  /// AppBar leading widget. Ignored when [title] is null.
  final Widget? leading;

  /// Screen content. Wrapped in `SafeArea` + 20px horizontal padding.
  final Widget body;

  /// Forwarded directly to `Scaffold.floatingActionButton`.
  final Widget? floatingActionButton;

  /// Forwarded directly to `Scaffold.bottomNavigationBar`.
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: title != null
          ? AppBar(
              leading: leading,
              title: Text(title!),
              actions: actions,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
            )
          : null,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: body,
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
