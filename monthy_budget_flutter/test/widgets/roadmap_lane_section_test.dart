import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/roadmap_entry.dart';
import 'package:monthly_management/widgets/roadmap_lane_section.dart';

import '../helpers/test_app.dart';

void main() {
  group('RoadmapLaneSection', () {
    testWidgets('renders lane title and entries', (tester) async {
      const entries = [
        RoadmapEntry(
          id: 'r1',
          lane: RoadmapLane.now,
          title: 'Receipt Scanning',
          body: 'Snap a photo of your receipt.',
          isHighlighted: true,
        ),
        RoadmapEntry(
          id: 'r2',
          lane: RoadmapLane.now,
          title: 'Budget Templates',
          body: 'Pre-built budget templates.',
        ),
      ];

      await tester.pumpWidget(
        wrapWithTestApp(
          const Scaffold(
            body: SingleChildScrollView(
              child: RoadmapLaneSection(
                title: 'Now',
                icon: Icons.bolt_outlined,
                entries: entries,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Now'), findsOneWidget);
      expect(find.text('Receipt Scanning'), findsOneWidget);
      expect(find.text('Budget Templates'), findsOneWidget);
      expect(find.text('Snap a photo of your receipt.'), findsOneWidget);
    });

    testWidgets('shows star icon for highlighted entries', (tester) async {
      const entries = [
        RoadmapEntry(
          id: 'r1',
          lane: RoadmapLane.now,
          title: 'Highlighted',
          body: 'This is highlighted.',
          isHighlighted: true,
        ),
        RoadmapEntry(
          id: 'r2',
          lane: RoadmapLane.now,
          title: 'Not Highlighted',
          body: 'This is not highlighted.',
        ),
      ];

      await tester.pumpWidget(
        wrapWithTestApp(
          const Scaffold(
            body: SingleChildScrollView(
              child: RoadmapLaneSection(
                title: 'Now',
                icon: Icons.bolt_outlined,
                entries: entries,
              ),
            ),
          ),
        ),
      );

      // One star icon for the highlighted entry
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('renders nothing when entries list is empty', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          const Scaffold(
            body: RoadmapLaneSection(
              title: 'Empty',
              icon: Icons.bolt_outlined,
              entries: [],
            ),
          ),
        ),
      );

      expect(find.text('Empty'), findsNothing);
    });
  });
}
