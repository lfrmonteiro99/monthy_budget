import 'package:flutter/material.dart';

/// A thin `Card` wrapper that applies 20px padding around [child] and
/// optionally wraps everything in an `InkWell` for tappable cards.
///
/// **Important:** this widget intentionally sets NO `color`, `shape`, or
/// `elevation` — those are owned by `CardTheme` (radius 20, `line` border,
/// zero shadow). Overriding them here would defeat the theme system and
/// cause drift from screens that use bare `Card` widgets.
///
/// Usage:
/// ```dart
/// // Static card
/// CalmCard(child: MyContent())
///
/// // Tappable card
/// CalmCard(
///   onTap: () => Navigator.push(context, ...),
///   child: MyContent(),
/// )
/// ```
///
/// Reference: Monthly Budget Calm handoff §4.3.
class CalmCard extends StatelessWidget {
  const CalmCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  /// Content rendered inside the card.
  final Widget child;

  /// Internal padding. Defaults to `EdgeInsets.all(20)` per the Calm spec.
  final EdgeInsets padding;

  /// Optional tap handler. When supplied, the card is wrapped in an
  /// `InkWell` whose `borderRadius` matches the theme's card radius (20px)
  /// so the ripple effect respects the rounded corners.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);

    if (onTap == null) {
      return Card(child: content);
    }

    // Use ClipRRect + InkWell so the splash is clipped to the card shape.
    // We cannot read CardTheme's exact shape here without resolving it, so
    // we hard-code radius 20 — which mirrors the CardTheme definition in
    // app_theme.dart and the Calm spec (§4.1).
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: content,
      ),
    );
  }
}
