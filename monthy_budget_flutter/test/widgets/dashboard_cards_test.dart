import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/data/tax/tax_deductions.dart';
import 'package:monthly_management/models/recurring_expense.dart';
import 'package:monthly_management/utils/budget_streaks.dart';
import 'package:monthly_management/widgets/budget_streak_card.dart';
import 'package:monthly_management/widgets/tax_deduction_card.dart';
import 'package:monthly_management/widgets/upcoming_bills_card.dart';

import '../helpers/test_app.dart';

void main() {
  group('BudgetStreakCard', () {
    testWidgets('renders counts and inactive placeholder', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          const Scaffold(
            body: BudgetStreakCard(
              streaks: AllStreaks(
                bronze: StreakResult(tier: StreakTier.bronze, count: 0),
                silver: StreakResult(tier: StreakTier.silver, count: 2),
                gold: StreakResult(tier: StreakTier.gold, count: 1),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      expect(find.text('-'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });
  });

  group('TaxDeductionCard', () {
    testWidgets('renders top categories and triggers detail callback',
        (tester) async {
      var detailTapped = false;

      final summary = YearlyDeductionSummary(
        year: 2026,
        categories: const [
          CategoryDeductionResult(
            category: 'saude',
            irsCategory: 'Saude',
            spent: 0,
            rawDeduction: 0,
            cappedDeduction: 0,
            finalDeduction: 120,
            annualCap: 1000,
            isDeductible: true,
          ),
          CategoryDeductionResult(
            category: 'alimentacao',
            irsCategory: 'Alimentacao',
            spent: 0,
            rawDeduction: 0,
            cappedDeduction: 0,
            finalDeduction: 60,
            annualCap: 250,
            isDeductible: true,
          ),
          CategoryDeductionResult(
            category: 'custom_unknown',
            irsCategory: 'Other',
            spent: 0,
            rawDeduction: 0,
            cappedDeduction: 0,
            finalDeduction: 30,
            annualCap: 999,
            isDeductible: true,
          ),
        ],
        totalDeduction: 210,
        maxPossibleDeduction: 2802,
      );

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: TaxDeductionCard(
              summary: summary,
              onSeeDetail: () => detailTapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('custom_unknown'), findsOneWidget);
      expect(find.textContaining('210'), findsWidgets);

      await tester.tap(find.text('See detail'));
      await tester.pumpAndSettle();
      expect(detailTapped, isTrue);
    });
  });

  group('UpcomingBillsCard', () {
    testWidgets('returns empty widget when there are no upcoming bills',
        (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          const Scaffold(
            body: UpcomingBillsCard(recurringExpenses: []),
          ),
        ),
      );

      expect(find.byIcon(Icons.event_note), findsNothing);
    });

    testWidgets('shows eligible bills and triggers manage callback',
        (tester) async {
      var manageTapped = false;
      final now = DateTime.now();
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final today = now.day;

      // Keep due days deterministic and valid regardless of month boundaries.
      final dueToday = today;
      final dueInTwoDays = (today + 2) <= daysInMonth ? today + 2 : daysInMonth;
      final farOrPastDay = (today + 15) <= daysInMonth ? today + 15 : 1;

      final bills = [
        RecurringExpense(
          id: 'b1',
          category: 'saude',
          amount: 45.0,
          description: 'Gym',
          dayOfMonth: dueToday,
          isActive: true,
        ),
        RecurringExpense(
          id: 'b2',
          category: 'educacao',
          amount: 30.0,
          dayOfMonth: dueInTwoDays,
          isActive: true,
        ),
        RecurringExpense(
          id: 'b3',
          category: 'outros',
          amount: 10.0,
          description: 'Inactive',
          dayOfMonth: dueToday,
          isActive: false,
        ),
        RecurringExpense(
          id: 'b4',
          category: 'outros',
          amount: 999.0,
          description: 'Far bill',
          dayOfMonth: farOrPastDay,
          isActive: true,
        ),
      ];

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: UpcomingBillsCard(
              recurringExpenses: bills,
              reminderDaysBefore: 3,
              onOpenRecurring: () => manageTapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.event_note), findsOneWidget);
      expect(find.text('Gym'), findsOneWidget);
      expect(find.text('Inactive'), findsNothing);

      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();
      expect(manageTapped, isTrue);
    });
  });
}
