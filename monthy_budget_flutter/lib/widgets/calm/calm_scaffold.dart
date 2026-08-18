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
  /// Bottom clearance a scrollable body must reserve when a persistent
  /// `floatingActionButton` floats over it (own or injected by a parent
  /// `Scaffold`, e.g. the dashboard tab's FAB in `app_home.dart`).
  ///
  /// Covers the FAB's ~56dp footprint plus its default margin so early,
  /// pre-scroll content never renders underneath it. Screens with a FAB
  /// must wrap their scrollable viewport (not just append trailing list
  /// padding) in `Padding(bottom: fabBottomClearance)` — trailing padding
  /// only protects the last item, not content visible before any scroll.
  ///
  /// **Where to apply it matters (#1202).** The `Padding` must wrap the
  /// scrollable at the SAME `Scaffold` the FAB is attached to — the FAB's
  /// position is computed against that Scaffold's body, so the reservation
  /// has to be measured from the same bottom edge:
  /// - FAB owned by the screen's own `CalmScaffold` (e.g. expense tracker):
  ///   wrap that screen's own scrollable directly — the screen's bottom
  ///   edge IS the FAB's reference edge.
  /// - FAB injected by a parent `Scaffold` (e.g. the dashboard tab's FAB in
  ///   `app_home.dart`, floating over a container `Column` that wraps the
  ///   screen together with sibling banners/ad): wrap `content` at THAT
  ///   parent `Scaffold`, not the inner screen's own scrollable. A
  ///   clearance added inside the screen anchors to the screen's own bottom
  ///   edge, which only equals the FAB's reference edge when every sibling
  ///   renders at zero height — and leaves a bottom sibling (e.g.
  ///   `AdBannerWidget`) inside the FAB's band. Wrapping at the parent
  ///   reserves the full footprint around the whole content, invariant to
  ///   viewport height and to whatever the container renders inside.
  static const double fabBottomClearance = 88.0;

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

/// Reserves the footprint of a persistent `floatingActionButton` that floats
/// over a scrollable body, measured from the same `Scaffold` edge the FAB's
/// own position is computed from (#1202).
///
/// This is the widget form of
/// `Padding(bottom: CalmScaffold.fabBottomClearance)` — the reservation is a
/// named, shared production unit instead of each caller inlining the padding.
/// Use it as the direct child of the slot the FAB floats over, gated on
/// whether that FAB is actually present in THIS same `Scaffold` (`reserve`):
///
/// ```dart
/// Expanded(
///   child: FabClearance(
///     reserve: _currentTab == AppTab.dashboard,
///     child: content,
///   ),
/// )
/// ```
///
/// When `reserve` is false the child is returned unchanged (no reservation),
/// so non-FAB tabs keep their full height. See [CalmScaffold.fabBottomClearance]
/// for where the reservation must be anchored (same `Scaffold` as the FAB,
/// not a screen nested deeper down).
class FabClearance extends StatelessWidget {
  const FabClearance({
    super.key,
    required this.reserve,
    required this.child,
  });

  /// Whether a FAB floats over this same `Scaffold`. When false, [child] is
  /// returned without any bottom reservation.
  final bool reserve;

  /// The content the FAB floats over (e.g. a screen or a container `Column`
  /// that wraps one together with sibling banners/ad).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return reserve
        ? Padding(
            padding: const EdgeInsets.only(
              bottom: CalmScaffold.fabBottomClearance,
            ),
            child: child,
          )
        : child;
  }
}
