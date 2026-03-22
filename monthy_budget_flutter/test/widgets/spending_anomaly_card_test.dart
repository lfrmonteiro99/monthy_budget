import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/services/spending_anomaly_service.dart';
import 'package:monthly_management/widgets/spending_anomaly_card.dart';

import '../helpers/test_app.dart';

void main() {
  group('SpendingAnomalyCard', () {
    testWidgets('renders nothing when anomalies list is empty', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          const Scaffold(
            body: SpendingAnomalyCard(anomalies: []),
          ),
        ),
      );

      expect(find.byType(SpendingAnomalyCard), findsOneWidget);
      // Should render SizedBox.shrink -- no visible content
      expect(find.byIcon(Icons.trending_up), findsNothing);
    });

    testWidgets('shows anomaly rows with deviation percentage', (tester) async {
      const anomalies = [
        SpendingAnomaly(
          category: 'alimentacao',
          currentAmount: 200,
          averageAmount: 100,
          deviationPercent: 100.0,
        ),
        SpendingAnomaly(
          category: 'transportes',
          currentAmount: 80,
          averageAmount: 50,
          deviationPercent: 60.0,
        ),
      ];

      await tester.pumpWidget(
        wrapWithTestApp(
          const Scaffold(
            body: SingleChildScrollView(
              child: SpendingAnomalyCard(anomalies: anomalies),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.text('+100%'), findsOneWidget);
      expect(find.text('+60%'), findsOneWidget);
    });

    testWidgets('limits displayed anomalies to 5', (tester) async {
      final anomalies = List.generate(
        7,
        (i) => SpendingAnomaly(
          category: 'cat_$i',
          currentAmount: 200.0 + i * 10,
          averageAmount: 100.0,
          deviationPercent: 100.0 + i * 10,
        ),
      );

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: SpendingAnomalyCard(anomalies: anomalies),
            ),
          ),
        ),
      );

      // Only 5 deviation badges should render
      expect(find.textContaining('+'), findsNWidgets(5));
    });
  });
}
