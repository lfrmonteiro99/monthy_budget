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
    Map<String, double> monthlyBudgets = const {},
    ValueChanged<Map<String, double>>? onSaveMonthlyBudgets,
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
      monthlyBudgets: monthlyBudgets,
      onSaveMonthlyBudgets: onSaveMonthlyBudgets,
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

  testWidgets(
      'salary numeric edits persist without clobbering and update preview live (issue #1069)',
      (tester) async {
    AppSettings? saved;
    await tester.pumpWidget(
      wrapWithTestApp(
        buildScreen(
          initialSection: 'salaries',
          onSave: (s) => saved = s,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final gross = find.byKey(const ValueKey('gross_0'));
    final exempt = find.byKey(const ValueKey('exempt_0'));
    expect(gross, findsOneWidget);
    expect(exempt, findsOneWidget);

    // Editing a numeric field uses a "quiet" draft update (no full rebuild of
    // the input fields — that resets the Android numeric IME), while the
    // net-salary preview still refreshes via a scoped notifier.
    await tester.ensureVisible(gross);
    await tester.enterText(gross, '1500');
    await tester.pump();
    expect(find.textContaining('1500.00'), findsWidgets,
        reason: 'live preview must reflect the typed gross');

    // A second quiet edit must not clobber the first (each reads the latest
    // draft, not a stale captured copy).
    await tester.ensureVisible(exempt);
    await tester.enterText(exempt, '200');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.check).last);
    await tester.pumpAndSettle();

    expect(saved?.salaries.first.grossAmount, 1500);
    expect(saved?.salaries.first.otherExemptIncome, 200);
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

  // ── Issue #1320: editing the recurring-expense "monthly budget" field was
  // silently inert whenever a current-month override existed, with no
  // warning. See docs in the issue for the reproduction. ──
  group('expense category budget vs current-month override (issue #1320)', () {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    String currentMonthLabel() {
      final now = DateTime.now();
      return '${monthNames[now.month - 1]} ${now.year}';
    }

    const expense = ExpenseItem(
      id: 'compras',
      label: 'Compras / Alimentação',
      category: 'alimentacao',
      amount: 520,
    );

    Future<void> expandExpenseCard(WidgetTester tester) async {
      await tester.pumpAndSettle();
      // AnimatedCrossFade builds both children up front (collapsed row +
      // the pre-built expanded fields, which repeat the label in the
      // "Expense Name" input's initialValue), so more than one Text widget
      // can match; the collapsed row is built first.
      final collapsedRow = find.text('Compras / Alimentação').first;
      await tester.tap(collapsedRow);
      await tester.pumpAndSettle();
    }

    testWidgets(
        'field above the amount input reads "default budget", not "monthly budget"',
        (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          buildScreen(
            initialSection: 'expenses',
            settings: const AppSettings(expenses: [expense]),
            monthlyBudgets: const {'alimentacao': 520},
          ),
        ),
      );
      await expandExpenseCard(tester);

      expect(find.text('DEFAULT BUDGET'), findsOneWidget,
          reason: 'the template field is not the current-month value; '
              'calling it "monthly budget" is what misled the user in #1320');
      expect(find.text('MONTHLY BUDGET'), findsNothing);
    });

    testWidgets(
        'override banner with its Adjust action sits right after the amount field, no scroll needed',
        (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          buildScreen(
            initialSection: 'expenses',
            settings: const AppSettings(expenses: [expense]),
            monthlyBudgets: const {'alimentacao': 520},
          ),
        ),
      );
      await expandExpenseCard(tester);

      final month = currentMonthLabel();
      final bannerFinder = find.text('Adjusted for $month: 520.00');
      final adjustActionFinder = find.text('Adjust for $month');
      expect(bannerFinder, findsOneWidget,
          reason: 'issue #1320: this text existed but only at the bottom of '
              'the already-expanded card, requiring an extra scroll');
      expect(adjustActionFinder, findsOneWidget,
          reason: 'the banner must offer a one-tap way to apply the edited '
              'value to the current month, not just inform silently');

      final amountFieldY =
          tester.getTopLeft(find.byKey(const ValueKey('expense_amount_compras'))).dy;
      final bannerY = tester.getTopLeft(bannerFinder).dy;
      final recurringToggleY =
          tester.getTopLeft(find.text('Recurring payment')).dy;

      expect(bannerY, greaterThan(amountFieldY),
          reason: 'banner must render after the amount field');
      expect(bannerY, lessThan(recurringToggleY),
          reason: 'banner must render immediately after the field, before '
              'the rest of the card (recurring toggle etc.), so it is '
              'visible without scrolling inside the expanded category');
    });

    testWidgets(
        'tapping Adjust for {month} then Save applies the edited value to the current-month override',
        (tester) async {
      Map<String, double>? savedBudgets;
      await tester.pumpWidget(
        wrapWithTestApp(
          buildScreen(
            initialSection: 'expenses',
            settings: const AppSettings(expenses: [expense]),
            monthlyBudgets: const {'alimentacao': 520},
            onSaveMonthlyBudgets: (m) => savedBudgets = m,
          ),
        ),
      );
      await expandExpenseCard(tester);

      final amountField = find.byKey(const ValueKey('expense_amount_compras'));
      await tester.ensureVisible(amountField);
      await tester.enterText(amountField, '600');
      await tester.pump();

      final month = currentMonthLabel();
      final adjustAction = find.text('Adjust for $month');
      await tester.ensureVisible(adjustAction);
      await tester.tap(adjustAction);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.check).last);
      await tester.pumpAndSettle();

      expect(savedBudgets, isNotNull);
      expect(savedBudgets!['alimentacao'], 600,
          reason: 'this is the exact defect from #1320: editing the field '
              'and saving must actually reach the value the rest of the app '
              '(Dashboard, Despesas) reads for the current month');
    });

    testWidgets(
        'editing only the default-budget field (without tapping Adjust) leaves the current-month override unchanged',
        (tester) async {
      Map<String, double>? savedBudgets;
      AppSettings? savedSettings;
      await tester.pumpWidget(
        wrapWithTestApp(
          buildScreen(
            initialSection: 'expenses',
            settings: const AppSettings(expenses: [expense]),
            monthlyBudgets: const {'alimentacao': 520},
            onSave: (s) => savedSettings = s,
            onSaveMonthlyBudgets: (m) => savedBudgets = m,
          ),
        ),
      );
      await expandExpenseCard(tester);

      final amountField = find.byKey(const ValueKey('expense_amount_compras'));
      await tester.ensureVisible(amountField);
      await tester.enterText(amountField, '600');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.check).last);
      await tester.pumpAndSettle();

      // Intentional, per the issue's acceptance criteria: the base template
      // value does update, but it must NOT silently override the
      // current-month value without the explicit "Adjust for {month}" tap.
      expect(savedSettings?.expenses.first.amount, 600);
      expect(savedBudgets!['alimentacao'], 520);
    });

    testWidgets(
        'removing the override via the close icon then Save clears it for the current month',
        (tester) async {
      Map<String, double>? savedBudgets;
      await tester.pumpWidget(
        wrapWithTestApp(
          buildScreen(
            initialSection: 'expenses',
            settings: const AppSettings(expenses: [expense]),
            monthlyBudgets: const {'alimentacao': 520},
            onSaveMonthlyBudgets: (m) => savedBudgets = m,
          ),
        ),
      );
      await expandExpenseCard(tester);

      final closeIcon = find.byIcon(Icons.close);
      await tester.ensureVisible(closeIcon);
      await tester.tap(closeIcon);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.check).last);
      await tester.pumpAndSettle();

      expect(savedBudgets, isNotNull);
      expect(savedBudgets!.containsKey('alimentacao'), isFalse);
    });

    testWidgets(
        'category without a current-month override still updates immediately on Save (no regression)',
        (tester) async {
      AppSettings? savedSettings;
      Map<String, double>? savedBudgets;
      await tester.pumpWidget(
        wrapWithTestApp(
          buildScreen(
            initialSection: 'expenses',
            settings: const AppSettings(expenses: [expense]),
            monthlyBudgets: const {}, // no override for 'alimentacao'
            onSave: (s) => savedSettings = s,
            onSaveMonthlyBudgets: (m) => savedBudgets = m,
          ),
        ),
      );
      await expandExpenseCard(tester);

      expect(find.textContaining('Adjusted for'), findsNothing,
          reason: 'no override exists, so no override banner should render');

      final amountField = find.byKey(const ValueKey('expense_amount_compras'));
      await tester.ensureVisible(amountField);
      await tester.enterText(amountField, '600');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.check).last);
      await tester.pumpAndSettle();

      expect(savedSettings?.expenses.first.amount, 600);
      expect(savedBudgets, isEmpty);
    });
  });
}
