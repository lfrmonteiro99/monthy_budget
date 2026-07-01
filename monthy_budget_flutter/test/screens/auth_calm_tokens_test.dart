import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/screens/auth/biometric_lock_screen.dart';

import '../helpers/test_app.dart';

void main() {
  group('#1131 Auth screens — Calm token migration', () {
    testWidgets('BiometricLockScreen renders without error', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          BiometricLockScreen(onUnlocked: () {}),
        ),
      );
      await tester.pump();
      expect(find.byType(BiometricLockScreen), findsOneWidget);
    });
  });
}
