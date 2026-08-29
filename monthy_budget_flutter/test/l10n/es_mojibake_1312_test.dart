import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('#1312 app_es.arb mojibake — ¡/¿ not double-encoded', () {
    late S l;

    setUpAll(() async {
      l = await S.delegate.load(const Locale('es'));
    });

    test('dashboardCoachGoodSavings has correct ¡ characters, not Â¡', () {
      expect(l.dashboardCoachGoodSavings, contains('¡Excelente'));
      expect(l.dashboardCoachGoodSavings, isNot(contains('Â¡')));
      expect(l.dashboardCoachGoodSavings, isNot(contains('Â¿')));
    });

    test('authRegistrationSuccess has correct ¡/¿, not mojibake', () {
      expect(l.authRegistrationSuccess, isNot(contains('Â¡')));
      expect(l.authRegistrationSuccess, isNot(contains('Â¿')));
    });

    test('setupWizardCountryTitle has correct ¡/¿, not mojibake', () {
      expect(l.setupWizardCountryTitle, isNot(contains('Â¡')));
      expect(l.setupWizardCountryTitle, isNot(contains('Â¿')));
    });

    test('expenseTrackerDeleteConfirm has correct ¡/¿, not mojibake', () {
      expect(l.expenseTrackerDeleteConfirm, isNot(contains('Â¡')));
      expect(l.expenseTrackerDeleteConfirm, isNot(contains('Â¿')));
    });
  });
}
