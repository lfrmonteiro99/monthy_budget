import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/whats_new_entry.dart';
import 'package:orcamento_mensal/widgets/whats_new_card.dart';

import '../helpers/test_app.dart';

void main() {
  group('WhatsNewCard', () {
    testWidgets('renders version, title, and body', (tester) async {
      const entry = WhatsNewEntry(
        id: 'test-1',
        version: '2026.3.5',
        title: 'Test Feature',
        body: 'This is a test feature description.',
      );

      await tester.pumpWidget(
        wrapWithTestApp(
          const Scaffold(
            body: SingleChildScrollView(
              child: WhatsNewCard(entry: entry),
            ),
          ),
        ),
      );

      expect(find.text('v2026.3.5'), findsOneWidget);
      expect(find.text('Test Feature'), findsOneWidget);
      expect(find.text('This is a test feature description.'), findsOneWidget);
    });

    testWidgets('shows Try it link when featureKey and callback provided',
        (tester) async {
      const entry = WhatsNewEntry(
        id: 'test-2',
        version: '2026.3.5',
        title: 'Feature With Link',
        body: 'Has a deep link.',
        featureKey: 'savings',
      );

      var tapped = false;

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: WhatsNewCard(
                entry: entry,
                onFeatureTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Try it'), findsOneWidget);
      await tester.tap(find.text('Try it'));
      expect(tapped, true);
    });

    testWidgets('hides Try it link when no featureKey', (tester) async {
      const entry = WhatsNewEntry(
        id: 'test-3',
        version: '2026.3.4',
        title: 'No Link Feature',
        body: 'No deep link here.',
      );

      await tester.pumpWidget(
        wrapWithTestApp(
          const Scaffold(
            body: SingleChildScrollView(
              child: WhatsNewCard(entry: entry),
            ),
          ),
        ),
      );

      expect(find.text('Try it'), findsNothing);
    });
  });
}
