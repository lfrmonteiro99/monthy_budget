import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/utils/shopping_grouping.dart';
import 'package:monthly_management/widgets/shopping_group_toggle.dart';

import '../helpers/test_app.dart';

void main() {
  group('ShoppingGroupToggle', () {
    testWidgets('renders three mode labels', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: ShoppingGroupToggle(
              availableModes: ShoppingGroupMode.values,
              selected: ShoppingGroupMode.items,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Items'), findsOneWidget);
      expect(find.text('Meals'), findsOneWidget);
      expect(find.text('Stores'), findsOneWidget);
    });

    testWidgets('tapping a mode calls onChanged', (tester) async {
      ShoppingGroupMode? tapped;

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: ShoppingGroupToggle(
              availableModes: ShoppingGroupMode.values,
              selected: ShoppingGroupMode.items,
              onChanged: (mode) => tapped = mode,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Meals'));
      await tester.pump();

      expect(tapped, ShoppingGroupMode.meals);
    });

    testWidgets('tapping Stores calls onChanged with stores', (tester) async {
      ShoppingGroupMode? tapped;

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: ShoppingGroupToggle(
              availableModes: ShoppingGroupMode.values,
              selected: ShoppingGroupMode.items,
              onChanged: (mode) => tapped = mode,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Stores'));
      await tester.pump();

      expect(tapped, ShoppingGroupMode.stores);
    });
  });
}
