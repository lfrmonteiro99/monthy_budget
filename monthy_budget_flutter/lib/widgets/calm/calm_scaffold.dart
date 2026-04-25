import 'package:flutter/material.dart';
import 'package:monthly_management/theme/app_colors.dart';

/// A thin `Scaffold` wrapper that applies the Calm design baseline:
///
/// - Background set to `AppColors.bg(context)` (warm off-white / near-black).
/// - Body wrapped in `SafeArea` with [bodyPadding] horizontal padding (default
///   20px); sections own their own vertical spacing. Pass `EdgeInsets.zero`
///   for screens that embed full-width children (e.g. a `TabBarView` with
///   embedded screens).
/// - AppBar is constructed only when [title] is supplied — transparent,
///   zero elevation, no scroll-under tint. Omitting [title] leaves room for
///   custom headers (e.g. the Dashboard hero-as-header pattern).
/// - [bottom] is forwarded to `AppBar.bottom` (e.g. a `TabBar` or progress
///   indicator). Only meaningful when [title] is non-null.
/// - Default `automaticallyImplyLeading` is preserved so the OS back button
///   appears on push routes without extra wiring.
class CalmScaffold extends StatelessWidget {
  const CalmScaffold({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.bodyPadding = const EdgeInsets.symmetric(horizontal: 20),
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

  /// Optional widget pinned below the AppBar (e.g. `TabBar`,
  /// `LinearProgressIndicator`). Ignored when [title] is null.
  final PreferredSizeWidget? bottom;

  /// Horizontal padding applied around [body]. Defaults to 20px on each
  /// side; pass `EdgeInsets.zero` to opt out (e.g. screens hosting a
  /// `TabBarView` with full-width embedded children).
  final EdgeInsetsGeometry bodyPadding;

  /// Screen content. Wrapped in `SafeArea` + [bodyPadding].
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
              bottom: bottom,
            )
          : null,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Padding(
          padding: bodyPadding,
          child: body,
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
