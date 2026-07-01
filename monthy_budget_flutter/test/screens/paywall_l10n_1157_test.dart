import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';

void main() {
  late S l10n;

  setUpAll(() async {
    l10n = await S.delegate.load(const Locale('en'));
  });

  group('paywall_screen l10n #1157', () {
    test('paywallFeatureBudgetTitle is not hardcoded PT', () {
      expect(l10n.paywallFeatureBudgetTitle.toLowerCase(), isNot(contains('orçamento')));
    });

    test('paywallFeatureBudgetSubtitle is not hardcoded PT', () {
      expect(l10n.paywallFeatureBudgetSubtitle.toLowerCase(), isNot(contains('categorias')));
    });

    test('paywallFeatureCoachTitle is not hardcoded PT', () {
      expect(l10n.paywallFeatureCoachTitle.toLowerCase(), isNot(contains('coach financeiro')));
    });

    test('paywallFeatureMealTitle is not hardcoded PT', () {
      expect(l10n.paywallFeatureMealTitle.toLowerCase(), isNot(contains('planeador')));
    });

    test('paywallFeatureSyncTitle is not hardcoded PT', () {
      expect(l10n.paywallFeatureSyncTitle, isNotEmpty);
    });

    test('paywallFeatureExportTitle is not hardcoded PT', () {
      expect(l10n.paywallFeatureExportTitle, isNotEmpty);
    });

    test('paywallCloseLabel exists', () {
      expect(l10n.paywallCloseLabel, isNotEmpty);
    });

    test('paywallProductName exists', () {
      expect(l10n.paywallProductName, isNotEmpty);
    });

    test('paywallHeroSubtitle is not hardcoded PT', () {
      expect(l10n.paywallHeroSubtitle.toLowerCase(), isNot(contains('paz financeira')));
    });

    test('paywallYearlyPlanLabel exists', () {
      expect(l10n.paywallYearlyPlanLabel, isNotEmpty);
    });

    test('paywallMonthlyPlanLabel exists', () {
      expect(l10n.paywallMonthlyPlanLabel, isNotEmpty);
    });

    test('paywallPerMonth exists', () {
      expect(l10n.paywallPerMonth, isNotEmpty);
    });

    test('paywallTrialText is not hardcoded PT', () {
      expect(l10n.paywallTrialText.toLowerCase(), isNot(contains('grátis')));
    });

    test('paywallCtaButton is not hardcoded PT', () {
      expect(l10n.paywallCtaButton.toLowerCase(), isNot(contains('começar')));
    });

    test('paywallComparePlansEyebrow exists', () {
      expect(l10n.paywallComparePlansEyebrow, isNotEmpty);
    });

    test('paywallRestorePurchase is not hardcoded PT', () {
      expect(l10n.paywallRestorePurchase.toLowerCase(), isNot(contains('restaurar')));
    });

    test('paywallTermsOfService exists', () {
      expect(l10n.paywallTermsOfService, isNotEmpty);
    });

    test('paywallPrivacyPolicy exists', () {
      expect(l10n.paywallPrivacyPolicy, isNotEmpty);
    });

    test('paywallBillingMonthly exists', () {
      expect(l10n.paywallBillingMonthly, isNotEmpty);
    });

    test('paywallBillingYearly exists', () {
      expect(l10n.paywallBillingYearly, isNotEmpty);
    });
  });
}
