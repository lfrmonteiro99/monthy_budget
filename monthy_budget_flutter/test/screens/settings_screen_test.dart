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
    AppSettings settings = const AppSettings(),
    ValueChanged<AppSettings>? onSave,
    Future<List<AssociatedHouseholdMember>> Function(String householdId)?
    loadAssociatedMembers,
    Future<String> Function(String householdId)? generateInviteCode,
  }) {
    return SettingsScreen(
      settings: settings,
      onSave: onSave ?? (_) {},
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

  testWidgets('IRS Jovem note is shown when regime is active', (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        buildScreen(
          initialSection: 'profile',
          settings: const AppSettings(
            personalInfo: PersonalInfo(irsJovemYear: 3),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Modelo 3'), findsOneWidget);
  });

  testWidgets('IRS Jovem note is hidden when regime is not active', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        buildScreen(
          initialSection: 'profile',
          settings: const AppSettings(), // irsJovemYear == 0
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Modelo 3'), findsNothing);
  });

  testWidgets('section detail page has a working Save action', (tester) async {
    AppSettings? saved;
    await tester.pumpWidget(
      wrapWithTestApp(
        buildScreen(
          initialSection: 'profile',
          onSave: (s) => saved = s,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The pushed section page (Pessoal) must expose its own Save action.
    final saveAction = find.byIcon(Icons.check);
    expect(saveAction, findsWidgets);

    await tester.tap(saveAction.last);
    await tester.pumpAndSettle();

    // Tapping Save persists the draft (no need to go back to the main screen).
    expect(saved, isNotNull);
  });
}
