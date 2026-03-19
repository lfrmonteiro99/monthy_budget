import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';
import 'package:monthly_management/widgets/receipt_scan_sheet.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  group('ReceiptScanSheet', () {
    testWidgets('builds without errors', (tester) async {
      await tester.pumpWidget(_wrap(const ReceiptScanSheet()));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(find.text('Scan Receipt'), findsOneWidget);
    });

    testWidgets('shows QR and Photo mode buttons', (tester) async {
      await tester.pumpWidget(_wrap(const ReceiptScanSheet()));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(find.text('QR Code'), findsOneWidget);
      expect(find.text('Photo'), findsOneWidget);
    });

    testWidgets('shows close button', (tester) async {
      await tester.pumpWidget(_wrap(const ReceiptScanSheet()));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows hint text', (tester) async {
      await tester.pumpWidget(_wrap(const ReceiptScanSheet()));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(
        find.text('Point camera at the receipt QR code'),
        findsOneWidget,
      );
    });

    testWidgets('switching to photo mode shows photo hint', (tester) async {
      await tester.pumpWidget(_wrap(const ReceiptScanSheet()));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      // Tap the Photo segment
      await tester.tap(find.text('Photo'));
      // Use pump instead of pumpAndSettle because the camera loading
      // indicator animates continuously and would cause a timeout.
      await tester.pump(const Duration(milliseconds: 100));

      // Photo mode shows in-app camera hint
      expect(
        find.text('Position the receipt and tap the button to capture'),
        findsOneWidget,
      );
    });

    testWidgets('static show method exists', (tester) async {
      // Verify the static method signature exists (compile-time check).
      // We cannot fully test modal opening without a navigator, but we
      // confirm the API surface.
      expect(ReceiptScanSheet.show, isA<Function>());
    });
  });
}
