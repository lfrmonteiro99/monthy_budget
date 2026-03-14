import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/widgets/ad_banner_widget.dart';

void main() {
  group('AdBannerWidget', () {
    testWidgets('renders nothing when showAd is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdBannerWidget(showAd: false),
          ),
        ),
      );

      expect(find.byKey(const Key('ad_banner_container')), findsNothing);
    });

    testWidgets('renders widget when showAd is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdBannerWidget(showAd: true),
          ),
        ),
      );

      expect(find.byType(AdBannerWidget), findsOneWidget);
    });
  });
}
