import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/screens/auth/household_setup_screen.dart';
import 'package:monthly_management/services/household_service.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets(
    'creating a household persists setupWizardCompleted as false',
    (tester) async {
      final createdNames = <String>[];
      final savedSettings = <AppSettings>[];
      final savedHouseholdIds = <String>[];
      HouseholdProfile? completedProfile;

      await tester.pumpWidget(
        wrapWithTestApp(
          HouseholdSetupScreen(
            createHousehold: (name) async {
              createdNames.add(name);
              return const HouseholdProfile(
                householdId: 'house-1',
                householdName: 'Smith Family',
                role: 'admin',
              );
            },
            saveSettings: (settings, householdId) async {
              savedSettings.add(settings);
              savedHouseholdIds.add(householdId);
            },
            onSetupComplete: (profile) => completedProfile = profile,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Smith Family');
      await tester.tap(find.text('Create Household'));
      await tester.pumpAndSettle();

      expect(createdNames, ['Smith Family']);
      expect(savedHouseholdIds, ['house-1']);
      expect(savedSettings.single.setupWizardCompleted, isFalse);
      expect(completedProfile?.householdId, 'house-1');
    },
  );

  testWidgets('joining a household does not overwrite setup wizard state', (
    tester,
  ) async {
    final joinedCodes = <String>[];
    final savedSettings = <AppSettings>[];

    await tester.pumpWidget(
      wrapWithTestApp(
        HouseholdSetupScreen(
          joinHousehold: (inviteCode) async {
            joinedCodes.add(inviteCode);
            return const HouseholdProfile(
              householdId: 'house-2',
              householdName: 'Joined Family',
              role: 'member',
            );
          },
          saveSettings: (settings, householdId) async {
            savedSettings.add(settings);
          },
          onSetupComplete: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Join with code'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'abc123');
    await tester.tap(find.text('Join Household'));
    await tester.pumpAndSettle();

    expect(joinedCodes, ['abc123']);
    expect(savedSettings, isEmpty);
  });
}
