import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_theme.dart';
import 'package:monthly_management/widgets/calm/calm.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget wrap(Widget child) =>
      MaterialApp(theme: lightTheme(), home: Scaffold(body: child));

  // ── CalmEmptyState ──────────────────────────────────────────────────────

  testWidgets('CalmEmptyState renders icon, title, body', (tester) async {
    await tester.pumpWidget(wrap(const CalmEmptyState(
      icon: Icons.inbox_outlined,
      title: 'Nothing here',
      body: 'Add an expense to get started.',
    )));
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('Add an expense to get started.'), findsOneWidget);
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('CalmEmptyState optional action button taps', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(CalmEmptyState(
      icon: Icons.inbox_outlined,
      title: 'Empty',
      body: 'Body text.',
      action: CalmEmptyStateAction(
        label: 'Add item',
        onPressed: () => tapped = true,
      ),
    )));
    expect(find.text('Add item'), findsOneWidget);
    await tester.tap(find.text('Add item'));
    expect(tapped, isTrue);
  });

  // ── CalmListTile ────────────────────────────────────────────────────────

  testWidgets('CalmListTile renders leading circle, title, trailing',
      (tester) async {
    await tester.pumpWidget(wrap(const CalmListTile(
      leadingIcon: Icons.restaurant_outlined,
      leadingColor: Colors.green,
      title: 'Lunch',
      subtitle: 'Food & Drink',
      trailing: '€12,50',
    )));
    expect(find.byIcon(Icons.restaurant_outlined), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Food & Drink'), findsOneWidget);
    expect(find.text('€12,50'), findsOneWidget);
  });

  testWidgets('CalmListTile wraps in InkWell when onTap supplied',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(CalmListTile(
      leadingIcon: Icons.shopping_cart_outlined,
      leadingColor: Colors.blue,
      title: 'Groceries',
      onTap: () => tapped = true,
    )));
    await tester.tap(find.byType(InkWell));
    expect(tapped, isTrue);
  });

  // ── CalmBottomSheet ─────────────────────────────────────────────────────

  testWidgets('CalmBottomSheet.show opens sheet with drag handle',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme(),
      home: Builder(builder: (ctx) {
        return Scaffold(
          body: ElevatedButton(
            onPressed: () => CalmBottomSheet.show(
              ctx,
              builder: (_) => const CalmBottomSheetContent(
                title: 'Test Sheet',
                child: Text('sheet content'),
              ),
            ),
            child: const Text('Open'),
          ),
        );
      }),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    // Sheet opened: title and content are visible.
    expect(find.text('Test Sheet'), findsOneWidget);
    expect(find.text('sheet content'), findsOneWidget);
    // Drag handle: a Container with width=40 decoration is present.
    final handles = tester
        .widgetList<Container>(find.byType(Container))
        .where((c) => c.decoration is BoxDecoration)
        .toList();
    expect(handles, isNotEmpty);
  });
}
