import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/screens/plan_hub_screen.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('Plan hub routes to each planning feature', (tester) async {
    var grocery = 0;
    var shopping = 0;
    var meals = 0;
    var coach = 0;

    await tester.pumpWidget(
      wrapWithTestApp(
        PlanHubScreen(
          onOpenGrocery: () => grocery++,
          onOpenShoppingList: () => shopping++,
          onOpenMealPlanner: () => meals++,
          onOpenCoach: () => coach++,
        ),
      ),
    );

    await tester.tap(find.text('Grocery'));
    await tester.pump();
    await tester.tap(find.text('Shopping List'));
    await tester.pump();
    await tester.tap(find.text('Meal Planner'));
    await tester.pump();
    await tester.tap(find.text('Financial Coach'));
    await tester.pump();

    expect(grocery, 1);
    expect(shopping, 1);
    expect(meals, 1);
    expect(coach, 1);
  });
}
