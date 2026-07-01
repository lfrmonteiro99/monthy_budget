import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations_en.dart';

void main() {
  late SEn en;
  setUpAll(() { en = SEn(); });

  group('paywall_screen l10n keys (#1180)', () {
    test('error messages are in EN', () {
      expect(en.paywallErrorPurchaseFailed, contains('failed'));
      expect(en.paywallErrorRestoreFailed, contains('failed'));
    });

    test('period labels are in EN not PT', () {
      expect(en.paywallPeriodBilledYearly, isNot(contains('anual')));
      expect(en.paywallPeriodForever, isNot(contains('sempre')));
    });

    test('trust signal is in EN', () {
      expect(en.paywallTrustSignal, contains('Cancel'));
    });

    test('current plan label is in EN', () {
      expect(en.paywallCurrentPlan, isNot(contains('Atual')));
    });

    test('pro tier feature strings are in EN', () {
      expect(en.paywallProFeatUnlimitedCategories, contains('Unlimited'));
      expect(en.paywallProFeatAiCoach, contains('AI'));
      expect(en.paywallProFeatMealPlanner, contains('Meal'));
      expect(en.paywallProFeatSync, contains('sync'));
      expect(en.paywallProFeatExport, contains('CSV'));
      expect(en.paywallProFeatBillReminders, contains('reminders'));
      expect(en.paywallProFeatExpenseTrends, contains('Expense'));
      expect(en.paywallProFeatUnlimitedSavings, contains('savings'));
      expect(en.paywallProFeatHousehold, contains('Household'));
      expect(en.paywallProFeatTaxSimulator, contains('tax'));
      expect(en.paywallProFeatDashboard, contains('Dashboard'));
      expect(en.paywallProFeatThemes, contains('themes'));
      expect(en.paywallProFeatNoAds, contains('ads'));
    });

    test('free tier feature strings are in EN', () {
      expect(en.paywallFreeFeatBudget, contains('Budget'));
      expect(en.paywallFreeFeatTracking, contains('expense'));
      expect(en.paywallFreeFeatSavings, contains('goal'));
      expect(en.paywallFreeFeatShopping, contains('Shopping'));
      expect(en.paywallFreeFeatAds, contains('ads'));
    });

    test('yearly note template formats correctly', () {
      final result = en.paywallYearlyNoteTemplate('€29.99');
      expect(result, contains('€29.99'));
      expect(result, contains('37%'));
    });

    test('blocked feature message formats correctly', () {
      final result = en.paywallBlockedFeatureMessage('AI Financial Coach');
      expect(result, contains('AI Financial Coach'));
      expect(result, contains('subscription'));
    });

    test('feature display names are in EN', () {
      expect(en.paywallFeatNameAiCoach, contains('AI'));
      expect(en.paywallFeatNameMealPlanner, isNot(contains('Planificador')));
      expect(en.paywallFeatNameTaxSimulator, contains('Tax'));
    });
  });
}
