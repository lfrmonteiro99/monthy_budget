import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/notification_preferences.dart';
import 'package:orcamento_mensal/screens/notification_settings_screen.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('shows title and empty custom reminders message', (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        NotificationSettingsScreen(
          preferences: const NotificationPreferences(),
          onSave: (_) {},
        ),
      ),
    );

    expect(find.text('Notification Settings'), findsOneWidget);
    expect(find.text('No custom reminders.'), findsOneWidget);
  });

  testWidgets('toggle bill reminders triggers onSave', (tester) async {
    NotificationPreferences? saved;

    await tester.pumpWidget(
      wrapWithTestApp(
        NotificationSettingsScreen(
          preferences: const NotificationPreferences(billReminders: true),
          onSave: (p) => saved = p,
        ),
      ),
    );

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.billReminders, isFalse);
  });
}
