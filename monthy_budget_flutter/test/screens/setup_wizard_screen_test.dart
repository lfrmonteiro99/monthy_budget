import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/screens/setup_wizard_screen.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('shows welcome step and advances to country step', (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        SetupWizardScreen(
          initial: const AppSettings(),
          onComplete: (_) {},
        ),
      ),
    );

    expect(find.text('Welcome to your budget'), findsOneWidget);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Where do you live?'), findsOneWidget);
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

    await tester.tap(find.text('Skip setup'));
    await tester.pumpAndSettle();
    expect(called, isTrue);
  });
}
