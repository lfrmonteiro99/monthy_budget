import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/screens/more_screen.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('More screen exposes core utility entry points', (tester) async {
    var detailedDashboard = 0;
    var insights = 0;
    var savings = 0;
    var settings = 0;
    var notifications = 0;
    var subscription = 0;

    await tester.pumpWidget(
      wrapWithTestApp(
        MoreScreen(
          onOpenDetailedDashboard: () => detailedDashboard++,
          onOpenInsights: () => insights++,
          onOpenSavingsGoals: () => savings++,
          onOpenSettings: () => settings++,
          onOpenNotifications: () => notifications++,
          onOpenSubscription: () => subscription++,
        ),
      ),
    );

    await tester.tap(find.widgetWithText(ListTile, 'Detailed Dashboard'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ListTile, 'Insights'));
    await tester.pump();
    await tester.tap(find.text('Savings Goals'));
    await tester.pump();
    await tester.tap(find.text('Notifications'));
    await tester.pump();
    await tester.tap(find.text('Free Plan'));
    await tester.pump();
    await tester.tap(find.text('Settings'));
    await tester.pump();

    expect(detailedDashboard, 1);
    expect(insights, 1);
    expect(savings, 1);
    expect(settings, 1);
    expect(notifications, 1);
    expect(subscription, 1);
  });
}
