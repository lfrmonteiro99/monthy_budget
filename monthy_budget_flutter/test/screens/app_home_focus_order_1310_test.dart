import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/widgets/calm/calm_scaffold.dart';
import 'package:monthly_management/widgets/quick_add_launcher.dart';

import '../helpers/test_app.dart';

/// Mirrors the outer `Scaffold` chrome [AppHome] builds for every tab —
/// content / `floatingActionButton` / `bottomNavigationBar`, see
/// `lib/app_home.dart` ~2364-2504 — wrapping each region with the real
/// [ChromeFocusOrder] production widget that fixes #1310's Tab-order loop.
///
/// A full `AppHome` pump is not viable in this repo — `_AppHomeState.initState`
/// touches `AppDatabase.instance`/Supabase defaults, which throw in a bare
/// widget test (see `dashboard_fab_overlap_1202_test.dart`'s doc-comment). This
/// harness instead exercises the same chrome structure with the real
/// [ChromeFocusOrder], [FabClearance] and [QuickAddLauncher] widgets, so a
/// regression in [ChromeFocusOrder]'s own ordering logic (shared by
/// `app_home.dart`) is caught here even though a regression in whether
/// `app_home.dart` still calls it would not be.
Future<void> _pumpMirroredChrome(WidgetTester tester) async {
  await tester.pumpWidget(
    wrapWithTestApp(
      Scaffold(
        body: Column(
          children: [
            Expanded(
              child: ChromeFocusOrder(
                order: 0,
                child: FabClearance(
                  reserve: true,
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(
                        20,
                        (i) => SizedBox(
                          height: 48,
                          child: TextButton(
                            onPressed: () {},
                            child: Text('Item $i'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: ChromeFocusOrder(
          order: 1,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: QuickAddLauncher(onAction: (_) {}),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: ChromeFocusOrder(
          order: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 1, color: Colors.black12),
              NavigationBar(
                height: 72,
                selectedIndex: 0,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.receipt_long_outlined),
                    label: 'Track',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Finds the nearest ancestor `Semantics` widget carrying a non-null
/// [SemanticsProperties.sortKey] above [finder] and returns it as an
/// [OrdinalSortKey] — the structural mechanism #1310's fix relies on.
/// Without it, Flutter's web semantics tree orders siblings by paint
/// geometry, which is exactly what destabilizes under Tab-triggered scroll
/// (see #1310's root-cause analysis).
OrdinalSortKey _sortKeyAbove(Finder finder) {
  final element = finder.evaluate().single;
  Semantics? found;
  element.visitAncestorElements((ancestor) {
    final widget = ancestor.widget;
    if (widget is Semantics && widget.properties.sortKey != null) {
      found = widget;
      return false;
    }
    return true;
  });
  expect(
    found,
    isNotNull,
    reason:
        'expected an ancestor Semantics(sortKey:) wrapping this region '
        '(#1310) — without it, Tab order is geometry-based and unstable '
        'across scroll',
  );
  return found!.properties.sortKey! as OrdinalSortKey;
}

void main() {
  testWidgets('content, FAB and bottom nav each carry an explicit, increasing '
      'OrdinalSortKey so Tab order stays fixed (#1310)', (tester) async {
    await _pumpMirroredChrome(tester);

    final contentOrder = _sortKeyAbove(find.byType(SingleChildScrollView));
    final fabOrder = _sortKeyAbove(find.byType(QuickAddLauncher));
    final navOrder = _sortKeyAbove(find.byType(NavigationBar));

    expect(
      contentOrder.order,
      lessThan(fabOrder.order),
      reason:
          'content must sort before the FAB, or Tab can land on the '
          "FAB before reaching the end of the screen's content",
    );
    expect(
      fabOrder.order,
      lessThan(navOrder.order),
      reason:
          'the FAB must sort before the bottom nav bar, matching the '
          'reported focus order (FAB, then Início/.../Mais)',
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'scrolling the content region does not change the fixed sort order of '
    'content/FAB/nav (#1310 — without an explicit sortKey, geometry-based '
    'ordering shifts on every Tab-triggered scroll-into-view)',
    (tester) async {
      await _pumpMirroredChrome(tester);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -3000),
      );
      await tester.pumpAndSettle();

      final contentOrder = _sortKeyAbove(find.byType(SingleChildScrollView));
      final fabOrder = _sortKeyAbove(find.byType(QuickAddLauncher));
      final navOrder = _sortKeyAbove(find.byType(NavigationBar));

      expect(contentOrder.order, lessThan(fabOrder.order));
      expect(fabOrder.order, lessThan(navOrder.order));
      expect(tester.takeException(), isNull);
    },
  );
}
