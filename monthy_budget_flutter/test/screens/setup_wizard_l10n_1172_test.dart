import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations_en.dart';

void main() {
  late SEn en;
  setUpAll(() { en = SEn(); });
  tearDownAll(() {});

  group('setup_wizard_screen expense l10n keys (#1172)', () {
    test('setupWizardExpRent is EN not PT', () {
      expect(en.setupWizardExpRent, isNotNull);
      expect(en.setupWizardExpRent, isNot('Renda'));
    });

    test('setupWizardExpGroceries is EN not PT', () {
      expect(en.setupWizardExpGroceries, isNotNull);
      expect(en.setupWizardExpGroceries, isNot('Alimentação'));
    });

    test('setupWizardExpTransport is EN not PT', () {
      expect(en.setupWizardExpTransport, isNotNull);
      expect(en.setupWizardExpTransport, isNot('Transportes'));
    });

    test('setupWizardExpUtilities is EN not PT', () {
      expect(en.setupWizardExpUtilities, isNotNull);
      expect(en.setupWizardExpUtilities, isNot('Utilidades'));
    });

    test('setupWizardExpTelecom is EN not PT', () {
      expect(en.setupWizardExpTelecom, isNotNull);
      expect(en.setupWizardExpTelecom, isNot('Telecomunicações'));
    });

    test('setupWizardExpHealth is EN not PT', () {
      expect(en.setupWizardExpHealth, isNotNull);
      expect(en.setupWizardExpHealth, isNot('Saúde'));
    });

    test('setupWizardExpLeisure is EN not PT', () {
      expect(en.setupWizardExpLeisure, isNotNull);
      expect(en.setupWizardExpLeisure, isNot('Lazer'));
    });
  });
}
