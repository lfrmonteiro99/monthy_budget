import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/widgets/nav_bar_overlay_color.dart';

// Regression test for #1221: the bottom NavigationBar's selected-tab pill
// darkened whenever the real mouse cursor was left resting on it after a
// click (or, before round 1's partial fix, whenever a destination held
// keyboard focus since first frame). Round 1 tried to suppress this via
// `NavigationBar.overlayColor`, conditioned on `WidgetState.selected` — QA
// found it never actually fired, because `InkResponse` (which owns that
// resolution) never carries a `selected` state. This round fixes it by
// wrapping only the selected destination in a local `NavigationBarTheme`
// override — see navBarSuppressOverlayWhenSelected's doc for the full
// mechanism and why the alternatives (bare overlayColor, AbsorbPointer)
// don't work.
void main() {
  group('navBarSuppressOverlayWhenSelected', () {
    Widget destination(Key key) => SizedBox(key: key, width: 10, height: 10);

    testWidgets('returns the destination unwrapped when NOT selected', (
      tester,
    ) async {
      final childKey = UniqueKey();
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return navBarSuppressOverlayWhenSelected(
                context: context,
                index: 0,
                selectedIndex: 1,
                destination: destination(childKey),
              );
            },
          ),
        ),
      );

      // Not selected: no NavigationBarTheme wrapper inserted above the
      // destination beyond whatever ambient theme already existed.
      final ambient = NavigationBarTheme.of(capturedContext);
      final resolvedAtChild = NavigationBarTheme.of(
        tester.element(find.byKey(childKey)),
      );
      expect(resolvedAtChild.overlayColor, equals(ambient.overlayColor));
      expect(find.byKey(childKey), findsOneWidget);
    });

    testWidgets(
      'wraps the destination in a NavigationBarTheme forcing a transparent '
      'overlayColor when it IS selected',
      (tester) async {
        final childKey = UniqueKey();
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return navBarSuppressOverlayWhenSelected(
                  context: context,
                  index: 2,
                  selectedIndex: 2,
                  destination: destination(childKey),
                );
              },
            ),
          ),
        );

        final resolvedAtChild = NavigationBarTheme.of(
          tester.element(find.byKey(childKey)),
        );
        expect(
          resolvedAtChild.overlayColor?.resolve({WidgetState.hovered}),
          Colors.transparent,
        );
        expect(
          resolvedAtChild.overlayColor?.resolve({WidgetState.focused}),
          Colors.transparent,
        );
        expect(
          resolvedAtChild.overlayColor?.resolve({WidgetState.pressed}),
          Colors.transparent,
        );
      },
    );

    testWidgets(
      'preserves the ambient theme\'s other fields (e.g. indicatorColor) '
      'when selected — only overlayColor is overridden',
      (tester) async {
        final childKey = UniqueKey();
        const ambientIndicatorColor = Color(0xFF123456);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              navigationBarTheme: const NavigationBarThemeData(
                indicatorColor: ambientIndicatorColor,
              ),
            ),
            home: Builder(
              builder: (context) {
                return navBarSuppressOverlayWhenSelected(
                  context: context,
                  index: 0,
                  selectedIndex: 0,
                  destination: destination(childKey),
                );
              },
            ),
          ),
        );

        final resolvedAtChild = NavigationBarTheme.of(
          tester.element(find.byKey(childKey)),
        );
        expect(resolvedAtChild.indicatorColor, ambientIndicatorColor);
      },
    );
  });
}
