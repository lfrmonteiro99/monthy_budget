import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/notification_preferences.dart';
import 'package:monthly_management/screens/notification_settings_screen.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('shows title and empty custom reminders message', (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        NotificationSettingsScreen(
          preferences: NotificationPreferences(),
          onSave: (_) {},
        ),
      ),
    );

    expect(find.text('Notification Settings'), findsOneWidget);
    expect(find.text('No custom reminders.'), findsOneWidget);
  });

  testWidgets('shows daily expense reminder toggle ON by default', (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        NotificationSettingsScreen(
          preferences: NotificationPreferences(),
          onSave: (_) {},
        ),
      ),
    );

    expect(find.text('Daily expense reminder'), findsOneWidget);
    expect(find.text('Reminds you to log today\'s expenses'), findsOneWidget);
  });

  testWidgets('toggle daily expense reminder triggers onSave', (tester) async {
    NotificationPreferences? saved;

    await tester.pumpWidget(
      wrapWithTestApp(
        NotificationSettingsScreen(
          preferences: NotificationPreferences(dailyExpenseReminder: true),
          onSave: (p) => saved = p,
        ),
      ),
    );

    // The daily expense reminder is the first SwitchListTile, which maps to the first Switch
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.dailyExpenseReminder, isFalse);
  });

  testWidgets('toggle bill reminders triggers onSave', (tester) async {
    NotificationPreferences? saved;

    await tester.pumpWidget(
      wrapWithTestApp(
        NotificationSettingsScreen(
          preferences: NotificationPreferences(billReminders: true),
          onSave: (p) => saved = p,
        ),
      ),
    );

    // Bill reminders is the second SwitchListTile (after daily expense reminder)
    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.billReminders, isFalse);
  });
}
