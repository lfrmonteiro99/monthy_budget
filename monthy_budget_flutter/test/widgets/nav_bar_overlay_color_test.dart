import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/widgets/nav_bar_overlay_color.dart';

// Regression test for #1221: the bottom NavigationBar's selected-tab pill
// showed a neutral-gray overlay on "Início" (focused since first frame) but
// the correct accentSoft lilac on the other three tabs (only ever reached
// via a transient tap that doesn't leave a lingering overlay). Root cause:
// no `overlayColor` was set on the NavigationBar, so Flutter's Material 3
// default state-layer (~10% onSurface) painted over the indicator whenever
// a destination was focused/hovered/pressed. The fix suppresses that layer
// specifically for the selected destination, since the indicator pill
// already communicates selection and needs no extra tint.
void main() {
  group('navBarOverlayColor', () {
    test('suppresses the state layer for the selected destination', () {
      final resolved = navBarOverlayColor({WidgetState.selected});
      expect(resolved, Colors.transparent);
    });

    test(
      'suppresses the state layer even when selected AND focused '
      '(the exact combination that broke the initial "Início" tab)',
      () {
        final resolved = navBarOverlayColor({
          WidgetState.selected,
          WidgetState.focused,
        });
        expect(resolved, Colors.transparent);
      },
    );

    test('keeps the default overlay for an unselected, unfocused destination', () {
      final resolved = navBarOverlayColor({});
      expect(resolved, isNull);
    });

    test(
      'keeps the default focus overlay for a NOT-selected destination '
      '(accessibility: keyboard focus must stay visible)',
      () {
        final resolved = navBarOverlayColor({WidgetState.focused});
        expect(resolved, isNull);
      },
    );

    test('keeps the default hover overlay for a NOT-selected destination', () {
      final resolved = navBarOverlayColor({WidgetState.hovered});
      expect(resolved, isNull);
    });

    test('keeps the default press overlay for a NOT-selected destination', () {
      final resolved = navBarOverlayColor({WidgetState.pressed});
      expect(resolved, isNull);
    });
  });
}
