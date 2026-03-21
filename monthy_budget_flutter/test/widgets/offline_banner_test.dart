import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/widgets/offline_banner.dart';

import '../helpers/test_app.dart';

void main() {
  group('OfflineBanner', () {
    testWidgets('default message renders', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          const Scaffold(
            body: OfflineBanner(),
          ),
        ),
      );

      expect(
        find.text('Offline mode: changes will sync when you regain connectivity.'),
        findsOneWidget,
      );
    });

    testWidgets('custom message renders', (tester) async {
      const customMessage = 'You are offline. Data is cached locally.';

      await tester.pumpWidget(
        wrapWithTestApp(
          const Scaffold(
            body: OfflineBanner(message: customMessage),
          ),
        ),
      );

      expect(find.text(customMessage), findsOneWidget);
    });

    testWidgets('pending count badge shows when pendingCount is greater than 0', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          const Scaffold(
            body: OfflineBanner(pendingCount: 5),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('pending count badge is hidden when pendingCount is 0', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          const Scaffold(
            body: OfflineBanner(pendingCount: 0),
          ),
        ),
      );

      expect(find.text('0'), findsNothing);
    });

    testWidgets('cloud off icon is present', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          const Scaffold(
            body: OfflineBanner(),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    });
  });
}
