import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/meal_planner.dart';
import 'package:orcamento_mensal/models/meal_settings.dart';
import 'package:orcamento_mensal/models/shopping_item.dart';
import 'package:orcamento_mensal/widgets/freeform_meal_card.dart';
import 'package:orcamento_mensal/widgets/freeform_meal_sheet.dart';

import '../helpers/test_app.dart';

void main() {
  group('FreeformMealCard', () {
    testWidgets('displays freeform meal title and badge', (tester) async {
      final meal = MealDay(
        dayIndex: 3,
        mealKind: MealKind.freeform,
        costEstimate: 8.50,
        mealType: MealType.dinner,
        freeformTitle: 'Leftover pasta',
        freeformNote: 'From yesterday dinner',
        freeformTags: ['leftovers'],
      );

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: FreeformMealCard(
              mealDay: meal,
              onEdit: () {},
              onAddToShoppingList: (_) {},
              onFeedback: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Leftover pasta'), findsOneWidget);
      expect(find.text('Freeform'), findsOneWidget);
      expect(find.text('From yesterday dinner'), findsOneWidget);
      expect(find.text('8.50\u20AC'), findsOneWidget);
      expect(find.text('Leftovers'), findsOneWidget);
    });

    testWidgets('displays shopping item count', (tester) async {
      final meal = MealDay(
        dayIndex: 1,
        mealKind: MealKind.freeform,
        costEstimate: 5.0,
        mealType: MealType.lunch,
        freeformTitle: 'Quick lunch',
        freeformShoppingItems: [
          FreeformMealItem(name: 'Bread'),
          FreeformMealItem(name: 'Cheese'),
        ],
      );

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: FreeformMealCard(
              mealDay: meal,
              onEdit: () {},
              onAddToShoppingList: (_) {},
              onFeedback: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('2 shopping items'), findsOneWidget);
    });

    testWidgets('tapping card invokes onEdit', (tester) async {
      bool tapped = false;
      final meal = MealDay(
        dayIndex: 1,
        mealKind: MealKind.freeform,
        costEstimate: 0,
        freeformTitle: 'Test',
      );

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: FreeformMealCard(
              mealDay: meal,
              onEdit: () => tapped = true,
              onAddToShoppingList: (_) {},
              onFeedback: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test'));
      expect(tapped, true);
    });

    testWidgets('shows multiple tags as chips', (tester) async {
      final meal = MealDay(
        dayIndex: 1,
        mealKind: MealKind.freeform,
        costEstimate: 0,
        freeformTitle: 'Tagged meal',
        freeformTags: ['leftovers', 'quick_meal'],
      );

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: FreeformMealCard(
              mealDay: meal,
              onEdit: () {},
              onAddToShoppingList: (_) {},
              onFeedback: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Leftovers'), findsOneWidget);
      expect(find.text('Quick meal'), findsOneWidget);
    });
  });

  group('FreeformMealSheet', () {
    testWidgets('renders create form with empty fields', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const FreeformMealSheet(
                      dayIndex: 1,
                      mealType: MealType.dinner,
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Add freeform meal'), findsWidgets);
      expect(find.text('Meal title'), findsOneWidget);
    });

    testWidgets('renders edit form with existing data', (tester) async {
      final existing = MealDay(
        dayIndex: 5,
        mealKind: MealKind.freeform,
        costEstimate: 7.50,
        mealType: MealType.lunch,
        freeformTitle: 'Leftover stew',
        freeformNote: 'Reheat only',
        freeformEstimatedCost: 7.50,
        freeformTags: ['leftovers'],
      );

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => FreeformMealSheet(
                      dayIndex: 5,
                      mealType: MealType.lunch,
                      existing: existing,
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Edit freeform meal'), findsOneWidget);
      // The existing title should be pre-filled in the text field
      expect(find.text('Leftover stew'), findsOneWidget);
      // Delete button should be present in edit mode
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });
  });
}
