import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/app_settings.dart';
import 'package:orcamento_mensal/screens/settings_screen.dart';
import 'package:orcamento_mensal/services/household_service.dart';

import '../helpers/test_app.dart';

void main() {
  SettingsScreen buildScreen({
    Future<List<AssociatedHouseholdMember>> Function(String householdId)?
        loadAssociatedMembers,
    Future<String> Function(String householdId)? generateInviteCode,
  }) {
    return SettingsScreen(
      settings: const AppSettings(),
      onSave: (_) {},
      favorites: const [],
      onSaveFavorites: (_) {},
      apiKey: '',
      onSaveApiKey: (_) {},
      isAdmin: true,
      householdId: 'hh_1',
      initialSection: 'household',
      loadAssociatedMembers: loadAssociatedMembers,
      generateInviteCode: generateInviteCode,
    );
  }

  testWidgets('shows associated household members when available', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        buildScreen(
          loadAssociatedMembers: (_) async => const [
            AssociatedHouseholdMember(
              id: 'u1',
              email: 'ana@example.com',
              role: 'admin',
            ),
            AssociatedHouseholdMember(
              id: 'u2',
              email: 'rui@example.com',
              role: 'member',
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ana@example.com'), findsOneWidget);
    expect(find.text('rui@example.com'), findsOneWidget);
  });

  testWidgets('generates and displays new invite code', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      wrapWithTestApp(
        buildScreen(
          loadAssociatedMembers: (_) async => const [],
          generateInviteCode: (_) async {
            calls += 1;
            return 'ABC123';
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    final refreshButton = find.byIcon(Icons.refresh);
    await tester.ensureVisible(refreshButton);
    await tester.tap(refreshButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(calls, 1);
    expect(find.text('ABC123'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'New code'), findsOneWidget);
  });
}
