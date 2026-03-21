import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/data/tax/tax_deductions.dart';
import 'package:monthly_management/widgets/irs_deduction_banner.dart';

import '../helpers/test_app.dart';

void main() {
  final summary = YearlyDeductionSummary(
    year: 2026,
    categories: const [
      CategoryDeductionResult(
        category: 'saude',
        irsCategory: 'Saúde',
        spent: 500,
        rawDeduction: 75,
        cappedDeduction: 75,
        finalDeduction: 75,
        annualCap: 1000,
        isDeductible: true,
      ),
      CategoryDeductionResult(
        category: 'educacao',
        irsCategory: 'Educação',
        spent: 300,
        rawDeduction: 90,
        cappedDeduction: 90,
        finalDeduction: 90,
        annualCap: 800,
        isDeductible: true,
      ),
    ],
    totalDeduction: 165,
    maxPossibleDeduction: 2802,
  );

  group('IrsDeductionBanner', () {
    testWidgets('renders total deduction and progress indicator',
        (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: IrsDeductionBanner(
              summary: summary,
              onSeeDetail: () {},
            ),
          ),
        ),
      );

      // Shows the IRS deduction icon
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
      // Shows the total deduction amount
      expect(find.textContaining('165'), findsWidgets);
      // Shows the progress bar
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('triggers onSeeDetail callback when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: IrsDeductionBanner(
              summary: summary,
              onSeeDetail: () => tapped = true,
            ),
          ),
        ),
      );

      // Tap the see-detail area
      await tester.tap(find.byType(IrsDeductionBanner));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('returns SizedBox.shrink when summary is null', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          const Scaffold(
            body: IrsDeductionBanner(
              summary: null,
              onSeeDetail: null,
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.receipt_long), findsNothing);
    });

    testWidgets('shows max deduction info', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: IrsDeductionBanner(
              summary: summary,
              onSeeDetail: () {},
            ),
          ),
        ),
      );

      // Should show the max possible deduction reference
      expect(find.textContaining('2'), findsWidgets);
    });
  });
}
