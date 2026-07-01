import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/widgets/star_rating_row.dart';

import '../helpers/test_app.dart';

void main() {
  group('#1129 Calm token migration — meal planner widgets', () {
    testWidgets('StarRatingRow renders filled and empty stars', (tester) async {
      var rated = 0;
      await tester.pumpWidget(
        wrapWithTestApp(
          StarRatingRow(currentRating: 3, onRate: (v) => rated = v),
        ),
      );
      await tester.pump();

      // 5 stars rendered
      expect(find.byType(Icon), findsNWidgets(5));
      // Tap the 5th star
      await tester.tap(find.byType(GestureDetector).last);
      await tester.pump();
      expect(rated, 5);
    });

    testWidgets('StarRatingRow with no rating shows only unfilled stars', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          StarRatingRow(currentRating: null, onRate: (_) {}),
        ),
      );
      await tester.pump();

      final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
      expect(icons.every((i) => i.icon == Icons.star_border_rounded), isTrue);
    });
  });
}
