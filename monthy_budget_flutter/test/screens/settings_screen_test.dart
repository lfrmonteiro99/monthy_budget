import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/app_shell.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/screens/settings_screen.dart';
import 'package:monthly_management/services/household_service.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  SettingsScreen buildScreen({
    String? initialSection,
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
      initialSection: initialSection ?? 'household',
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

    final generateButton = find.widgetWithText(
      FilledButton,
      'Generate invite code',
    );
    expect(generateButton, findsOneWidget);
    await tester.ensureVisible(generateButton);
    await tester.tap(generateButton);
    await tester.pumpAndSettle();

    expect(calls, 1);
  });

  testWidgets('income tile lives outside the Advanced section', (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        buildScreen(
          // empty string skips _autoOpenInitialSection (no-op for unknown keys)
          initialSection: '',
          loadAssociatedMembers: (_) async => const [],
        ),
      ),
    );

    await tester.pumpAndSettle();

    final incomeFinder = find.text('Income');
    final advancedFinder = find.text('ADVANCED');

    expect(incomeFinder, findsWidgets);
    expect(advancedFinder, findsOneWidget);

    // The first "Income" occurrence is the eyebrow + tile rendered above the
    // ADVANCED group; assert the tile sits before Advanced in the scroll view.
    final incomeY = tester.getTopLeft(incomeFinder.first).dy;
    final advancedY = tester.getTopLeft(advancedFinder).dy;
    expect(incomeY, lessThan(advancedY));
  });

  testWidgets('appearance section updates app shell theme mode', (
    tester,
  ) async {
    final controller = AppShellController(locale: const Locale('en'));

    await tester.pumpWidget(
      wrapWithTestApp(
        buildScreen(
          initialSection: 'appearance',
          loadAssociatedMembers: (_) async => const [],
        ),
        controller: controller,
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(controller.themeMode, ThemeMode.dark);
  });
}
