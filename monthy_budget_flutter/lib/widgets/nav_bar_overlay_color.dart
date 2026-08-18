import 'package:flutter/material.dart';

/// State-layer overlay color for the bottom [NavigationBar]'s destinations.
///
/// Without an explicit `overlayColor`, Flutter's Material 3 default paints a
/// semi-transparent `onSurface` state layer over the selection indicator
/// whenever a destination is hovered/focused/pressed. That layer is
/// transient for tapped destinations (it fades once the gesture ends), but
/// it is *persistent* for a destination that receives keyboard/semantics
/// focus on first frame — on Flutter Web the initial tab (e.g. "Início")
/// gets that focus at load, so its indicator pill rendered visibly darker
/// than the other tabs' pill, which is reached only via a transient tap.
///
/// The indicator pill already communicates selection, so the state layer is
/// suppressed for the selected destination — but only for it, to keep the
/// hover/focus/press feedback for keyboard/mouse users on the *unselected*
/// destinations intact. See issue #1221.
Color? navBarOverlayColor(Set<WidgetState> states) {
  if (states.contains(WidgetState.selected)) {
    return Colors.transparent;
  }
  return null;
}
