import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/config/ad_config.dart';
import 'package:orcamento_mensal/models/monthly_budget.dart';
import 'package:orcamento_mensal/onboarding/tour_step_content.dart';

import 'helpers/test_app.dart';

void main() {
  group('MonthlyBudget', () {
    test('create builds id and stores fields', () {
      final budget = MonthlyBudget.create(
        category: 'alimentacao',
        amount: 320.5,
        monthKey: '2026-03',
      );

      expect(budget.id.startsWith('mb_'), isTrue);
      expect(budget.category, 'alimentacao');
      expect(budget.amount, 320.5);
      expect(budget.monthKey, '2026-03');
    });

    test('fromSupabase/toSupabase/copyWith work as expected', () {
      final budget = MonthlyBudget.fromSupabase({
        'id': 'mb_1',
        'category': 'saude',
        'amount': 90,
        'month_key': '2026-04',
      });

      expect(budget.amount, 90.0);

      final updated = budget.copyWith(amount: 120, category: 'educacao');
      expect(updated.amount, 120);
      expect(updated.category, 'educacao');
      expect(updated.id, 'mb_1');
      expect(updated.monthKey, '2026-04');

      final map = updated.toSupabase('house_1');
      expect(map['household_id'], 'house_1');
      expect(map['amount'], 120.0);
      expect(map['category'], 'educacao');
      expect(map['month_key'], '2026-04');
    });
  });

  test('AdConfig returns test banner id in test/debug mode', () {
    expect(AdConfig.appId, isNotEmpty);
    expect(AdConfig.bannerAdUnitId, 'ca-app-pub-3940256099942544/6300978111');
  });

  testWidgets('TourStepContent renders title and body', (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        const TourStepContent(
          title: 'Track spending',
          body: 'Use this area to keep monthly costs under control.',
        ),
      ),
    );

    expect(find.text('Track spending'), findsOneWidget);
    expect(
      find.text('Use this area to keep monthly costs under control.'),
      findsOneWidget,
    );
  });
}
