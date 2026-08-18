import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/widgets/nav_bar_overlay_color.dart';

// Regression test for #1221 (2nd round): QA found that the round-1 fix
// (`overlayColor: WidgetStateProperty.resolveWith(navBarOverlayColor)` set
// directly on `NavigationBar`) did NOT actually suppress the state layer for
// a destination selected via a real mouse click.
//
// Root cause (confirmed by reading the Flutter SDK source, not guessed):
// `_IndicatorInkWell` (navigation_bar.dart) is a bare `InkResponse`. Its own
// internal `statesController` (ink_well.dart) only ever tracks
// {disabled, hovered, focused, pressed} — it NEVER adds `WidgetState.selected`,
// because a generic `InkResponse` has no notion of "which nav destination is
// currently selected". So a `WidgetStateProperty` set directly on
// `NavigationBar.overlayColor` is *always* resolved without `selected` in
// the set — any `states.contains(WidgetState.selected)` branch in it is
// structurally unreachable from the real widget tree.
//
// QA's verification script (v-check-1221.mjs) drives the app with
// `page.mouse.click(x, y)` — a real Playwright *mouse* click, which moves the
// virtual cursor to the destination and, critically, leaves it resting there
// (Playwright never dispatches a follow-up mousemove to a neutral spot). In
// Flutter, `handleHoverChange` (ink_well.dart) updates the hover highlight
// unconditionally on real MouseRegion enter/exit — unlike keyboard focus,
// hover visibility is never gated by `FocusHighlightMode`. So once a
// destination is tap-selected with a mouse, it keeps `WidgetState.hovered`
// active indefinitely (as would happen for any real desktop-web user who
// clicks a tab and doesn't move the mouse away), resolving to the default
// ~8% onSurface hover tint painted over the indicator pill.
//
// This test reproduces that exact interaction with a mouse `TestGesture`
// (move → down → up, cursor left in place — matching `page.mouse.click`)
// against the real widget tree built with the actual fix:
// `navBarSuppressOverlayWhenSelected` (per-destination `NavigationBarTheme`
// override — see its doc for why this approach, and not `overlayColor` or
// `AbsorbPointer`, is the one that works).
void main() {
  const indicatorColor = Color(0xFFEAEEFF); // stand-in for AppColors.accentSoft

  Future<Color> samplePixel(
    WidgetTester tester,
    GlobalKey boundaryKey,
    Offset globalPoint,
  ) async {
    final boundary =
        boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final local = boundary.globalToLocal(globalPoint);
    // toImage()/toByteData() need a real event-loop tick to raster and
    // encode; inside the fake-async zone testWidgets normally runs in, that
    // Future never completes. runAsync briefly escapes to the real zone for
    // just this capture.
    final result = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final x = local.dx.round().clamp(0, image.width - 1);
      final y = local.dy.round().clamp(0, image.height - 1);
      final bytes = byteData!.buffer.asUint8List();
      final offset = (y * image.width + x) * 4;
      return Color.fromARGB(
        bytes[offset + 3],
        bytes[offset],
        bytes[offset + 1],
        bytes[offset + 2],
      );
    });
    return result!;
  }

  // Point sampled just above each destination's icon: inside the indicator
  // pill (default M3 height 32, icon size 24) but off the icon glyph itself,
  // so icon-shape holes (e.g. an outlined icon) don't produce a false read.
  Offset pillSamplePoint(WidgetTester tester, IconData icon) {
    final center = tester.getCenter(find.byIcon(icon));
    return center + const Offset(0, -13);
  }

  testWidgets(
    'indicator pill stays pure indicatorColor after a real mouse click '
    'selects the destination and the cursor is left resting on it '
    '(reproduces page.mouse.click, which never moves the cursor away)',
    (tester) async {
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: RepaintBoundary(
            key: boundaryKey,
            child: _NavHost(initialIndex: 0, indicatorColor: indicatorColor),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final neverTouchedColor = await samplePixel(
        tester,
        boundaryKey,
        pillSamplePoint(tester, Icons.dashboard),
      );

      final target = tester.getCenter(find.byIcon(Icons.receipt_long_outlined));
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);
      // Start away from the target so the move below is a real hover-enter,
      // then click — mirroring Playwright's page.mouse.click: move, down,
      // up, and (crucially) never move away afterward.
      await gesture.addPointer(location: Offset.zero);
      await tester.pump();
      await gesture.moveTo(target);
      await tester.pump();
      await gesture.down(target);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      // Cursor is still sitting on `target` here — no moveTo away was issued.

      final clickedAndStillHoveredColor = await samplePixel(
        tester,
        boundaryKey,
        pillSamplePoint(tester, Icons.receipt_long),
      );

      expect(
        clickedAndStillHoveredColor,
        equals(neverTouchedColor),
        reason:
            'The selected-destination pill must render pure indicatorColor '
            'even while the mouse cursor is still resting on it after the '
            'click that selected it. Got never-touched=$neverTouchedColor '
            'vs clicked-and-still-hovered=$clickedAndStillHoveredColor.',
      );
    },
  );

  testWidgets(
    'unselected destination still shows the default hover tint '
    '(hover/focus/press feedback must survive on non-selected tabs)',
    (tester) async {
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: RepaintBoundary(
            key: boundaryKey,
            child: _NavHost(initialIndex: 0, indicatorColor: indicatorColor),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final samplePoint = pillSamplePoint(tester, Icons.receipt_long_outlined);

      // Baseline: destination 1 ("Despesas", NOT selected — index 0 is),
      // mouse elsewhere, no hover.
      final baselineColor = await samplePixel(tester, boundaryKey, samplePoint);

      // Hover destination 1 without clicking.
      final target = tester.getCenter(find.byIcon(Icons.receipt_long_outlined));
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);
      await gesture.addPointer(location: Offset.zero);
      await tester.pump();
      await gesture.moveTo(target);
      await tester.pumpAndSettle();

      final hoveredUnselectedColor = await samplePixel(tester, boundaryKey, samplePoint);

      // The default M3 hover tint must still visibly darken the same spot —
      // proving hover/focus/press feedback was NOT removed from unselected
      // destinations by this fix.
      expect(
        hoveredUnselectedColor,
        isNot(equals(baselineColor)),
        reason:
            'Hovering an unselected destination must still show visible '
            'feedback (default M3 hover tint). Got baseline=$baselineColor '
            'vs hovered=$hoveredUnselectedColor — identical means the '
            'state-layer was suppressed for a destination that should '
            'keep it.',
      );
    },
  );
}

class _NavHost extends StatefulWidget {
  const _NavHost({required this.initialIndex, required this.indicatorColor});

  final int initialIndex;
  final Color indicatorColor;

  @override
  State<_NavHost> createState() => _NavHostState();
}

class _NavHostState extends State<_NavHost> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: widget.indicatorColor,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          navBarSuppressOverlayWhenSelected(
            context: context,
            index: 0,
            selectedIndex: _index,
            destination: const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Início',
            ),
          ),
          navBarSuppressOverlayWhenSelected(
            context: context,
            index: 1,
            selectedIndex: _index,
            destination: const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Despesas',
            ),
          ),
        ],
      ),
    );
  }
}
