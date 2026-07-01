import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/meal_settings.dart';
import 'package:monthly_management/widgets/calm/calm_month_grid.dart';

import '../helpers/test_app.dart';

void main() {
  group('CalmMonthGrid', () {
    testWidgets('renders every day of the month and fires onDayTap', (tester) async {
      int? tapped;
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: CalmMonthGrid(
              year: 2026,
              month: 7, // July 2026 has 31 days
              mealsByDay: const {14: {MealType.breakfast, MealType.lunch, MealType.dinner}},
              weekdayLabels: const ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'],
              onDayTap: (d) => tapped = d,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // All 31 day numbers present.
      expect(find.text('31'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // Tapping day 14 reports 14.
      await tester.tap(find.text('14'));
      await tester.pump();
      expect(tapped, 14);
    });
  });
}
