import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/screens/setup_wizard_screen.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('shows welcome step and advances to country step',
      (tester) async {
    // Welcome and country selection are now combined into a single step.
    // Verify both sections are visible on the first page, then advance.
    await tester.pumpWidget(
      wrapWithTestApp(
        SetupWizardScreen(
          initial: const AppSettings(),
          onComplete: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Both welcome title and country title appear on the same combined step.
    expect(find.text('Welcome to your budget'), findsOneWidget);
    expect(find.text('Where do you live?'), findsOneWidget);

    // Tap "Continue" to advance to the salary/expenses step.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // After advancing, welcome text should no longer be visible.
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
}
