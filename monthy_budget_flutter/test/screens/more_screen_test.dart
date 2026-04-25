import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/screens/more_screen.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('More screen exposes core utility entry points', (tester) async {
    var insights = 0;
    var savings = 0;
    var settings = 0;
    var notifications = 0;
    var subscription = 0;
    var productUpdates = 0;

    await tester.pumpWidget(
      wrapWithTestApp(
        MoreScreen(
          onOpenInsights: () => insights++,
          onOpenSavingsGoals: () => savings++,
          onOpenSettings: () => settings++,
          onOpenNotifications: () => notifications++,
          onOpenSubscription: () => subscription++,
          onOpenProductUpdates: () => productUpdates++,
        ),
      ),
    );

    Future<void> tapText(String text) async {
      final finder = find.text(text);
      await tester.ensureVisible(finder);
      await tester.pump();
      await tester.tap(finder);
      await tester.pump();
    }

    await tapText('Insights');
    await tapText('Savings Goals');
    await tapText('Notifications');
    await tapText('Free Plan');
    await tapText('Product Updates');
    await tapText('Settings');

    expect(insights, 1);
    expect(savings, 1);
    expect(settings, 1);
    expect(notifications, 1);
    expect(subscription, 1);
    expect(productUpdates, 1);
  });
}
