import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';

void main() {
  group('#1145 setup_wizard_screen — l10n keys', () {
    late S l10n;

    setUpAll(() async {
      l10n = await S.delegate.load(const Locale('en'));
    });

    test('setupWizardBack non-empty, not hardcoded PT', () {
      expect(l10n.setupWizardBack, isNotEmpty);
      expect(l10n.setupWizardBack, isNot('Anterior'));
    });

    test('setupWizardStepEyebrow contains step number', () {
      expect(l10n.setupWizardStepEyebrow(1), contains('1'));
      expect(l10n.setupWizardStepEyebrow(2), contains('2'));
      expect(l10n.setupWizardStepEyebrow(3), contains('3'));
    });

    test('setupWizardStepEyebrow not hardcoded PT prefix', () {
      expect(l10n.setupWizardStepEyebrow(1), isNot(startsWith('PASSO')));
    });

    test('setupWizardIncomeEyebrow non-empty, not hardcoded PT', () {
      expect(l10n.setupWizardIncomeEyebrow, isNotEmpty);
      expect(l10n.setupWizardIncomeEyebrow, isNot('RENDIMENTO'));
    });

    test('setupWizardExpensesEyebrow non-empty, not hardcoded PT', () {
      expect(l10n.setupWizardExpensesEyebrow, isNotEmpty);
      expect(l10n.setupWizardExpensesEyebrow, isNot('DESPESAS MENSAIS'));
    });
  });
}
