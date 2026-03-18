import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/app_shell.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/screens/setup_wizard_screen.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('shows welcome step and advances to country step', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        SetupWizardScreen(initial: const AppSettings(), onComplete: (_) {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to your budget'), findsOneWidget);
    expect(find.text('Where do you live?'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to your budget'), findsNothing);
  });

  testWidgets('skip all triggers onComplete callback', (tester) async {
    var called = false;
    await tester.pumpWidget(
      wrapWithTestApp(
        SetupWizardScreen(
          initial: const AppSettings(),
          onComplete: (_) => called = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip setup'));
    await tester.pumpAndSettle();
    expect(called, isTrue);
  });

  testWidgets('country selection updates the scoped locale', (tester) async {
    final controller = AppShellController(locale: const Locale('en'));

    await tester.pumpWidget(
      wrapWithTestApp(
        SetupWizardScreen(initial: const AppSettings(), onComplete: (_) {}),
        controller: controller,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Spain'));
    await tester.pumpAndSettle();

    expect(controller.locale, const Locale('es'));
  });
}
