import 'package:flutter/material.dart';

/// Wraps a bottom-nav [destination] so that, when it is the currently
/// selected one, its indicator's hover/focus/press state layer is always
/// transparent — regardless of how long the mouse cursor rests on it or
/// whether it holds keyboard focus. For every other (unselected) destination
/// this is a complete no-op: the original [destination] widget is returned
/// unwrapped, so its hover/focus/press feedback is entirely unaffected.
///
/// ## Why a per-destination [NavigationBarTheme] wrapper, not
/// `NavigationBar.overlayColor`
///
/// A first attempt (#1221 round 1) set `NavigationBar.overlayColor` to a
/// `WidgetStateProperty` that returned `Colors.transparent` whenever
/// `WidgetState.selected` was present in the resolved state set. It shipped,
/// and QA found the selected pill *still* darkened — because that state set
/// never actually contains `selected`. Flutter's `_IndicatorInkWell` (the
/// SDK's navigation_bar.dart) is a bare `InkResponse`, and `InkResponse`'s
/// own internal `statesController` (ink_well.dart) only ever tracks
/// `{disabled, hovered, focused, pressed}` — a generic `InkResponse` has no
/// notion of "which nav destination is currently selected", so
/// `overlayColor.resolve(...)` is *always* called without `selected`, making
/// any `states.contains(WidgetState.selected)` branch unreachable from the
/// real widget tree. Confirmed by reading the SDK source, not guessed.
///
/// The concrete symptom QA measured: `page.mouse.click()` (used by the
/// verification script) moves the cursor to the destination and — like a
/// real desktop-web user who clicks a tab and doesn't move the mouse away —
/// never dispatches a follow-up move elsewhere. `handleHoverChange`
/// (ink_well.dart) updates the hover highlight unconditionally on real
/// `MouseRegion` enter/exit; unlike keyboard-focus visibility (gated by
/// `FocusHighlightMode`), hover is never suppressed. So the just-selected
/// destination keeps `WidgetState.hovered` active indefinitely, and with no
/// way to special-case it, the default ~8% onSurface hover tint stays
/// painted over the indicator pill.
///
/// Since `overlayColor` is structurally destination-agnostic when set on
/// `NavigationBar` itself, `NavigationBar.overlayColor` must NOT be set at
/// all (see the bottom nav in `app_home.dart`) — leaving each
/// `_IndicatorInkWell` to resolve its `overlayColor` from the closest
/// ancestor `NavigationBarTheme` instead
/// (`info.overlayColor ?? navigationBarTheme.overlayColor` in the SDK).
/// *That* lookup — `NavigationBarTheme.of(context)` — walks up to the
/// closest ancestor `NavigationBarTheme` **InheritedWidget**, and each
/// destination has its own ancestor chain, so wrapping just the selected
/// destination in a local override genuinely reaches only it. The ambient
/// theme's other fields (iconTheme, labelTextStyle, indicatorShape, height,
/// ...) are preserved via `copyWith` — only `overlayColor` differs — so the
/// app's Calm design tokens for icon/label colors are untouched.
///
/// An earlier version of this fix tried `AbsorbPointer` to block pointer
/// hit-testing on the selected destination instead. That was reverted: by
/// default `AbsorbPointer` sets `SemanticsConfiguration.isBlockingUserActions
/// = true` while absorbing, which strips the semantics tap action — and
/// `NavigationBar` asserts every `SemanticsRole.tab` node must have one
/// ("A tab must have a tap action"), so it crashed the widget tree in debug
/// mode. This theme-based approach never touches hit-testing or semantics.
Widget navBarSuppressOverlayWhenSelected({
  required BuildContext context,
  required int index,
  required int selectedIndex,
  required Widget destination,
}) {
  if (index != selectedIndex) return destination;
  final ambient = NavigationBarTheme.of(context);
  return NavigationBarTheme(
    data: ambient.copyWith(overlayColor: WidgetStateProperty.all(Colors.transparent)),
    child: destination,
  );
}
