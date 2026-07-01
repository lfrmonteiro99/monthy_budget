import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';

void main() {
  group('#1141 welcome_slideshow_screen — l10n keys', () {
    late S l10n;

    setUpAll(() async {
      l10n = await S.delegate.load(const Locale('en'));
    });

    test('welcomeSlideWelcomeEyebrow non-empty, not hardcoded PT', () {
      expect(l10n.welcomeSlideWelcomeEyebrow, isNotEmpty);
      expect(l10n.welcomeSlideWelcomeEyebrow, isNot('BEM-VINDO'));
    });

    test('welcomeSlideWelcomeTitle non-empty, not hardcoded PT', () {
      expect(l10n.welcomeSlideWelcomeTitle, isNotEmpty);
      expect(l10n.welcomeSlideWelcomeTitle, isNot('O teu orçamento, numa vista só'));
    });

    test('welcomeSlideWelcomeBody non-empty, not hardcoded PT', () {
      expect(l10n.welcomeSlideWelcomeBody, isNotEmpty);
      expect(l10n.welcomeSlideWelcomeBody, isNot(contains('Índice de Serenidade')));
    });

    test('welcomeSlideFeaturesEyebrow non-empty, not hardcoded PT', () {
      expect(l10n.welcomeSlideFeaturesEyebrow, isNotEmpty);
      expect(l10n.welcomeSlideFeaturesEyebrow, isNot('FUNCIONALIDADES'));
    });

    test('welcomeSlideFeaturesTitle non-empty, not hardcoded PT', () {
      expect(l10n.welcomeSlideFeaturesTitle, isNotEmpty);
      expect(l10n.welcomeSlideFeaturesTitle, isNot('Controla cada despesa'));
    });

    test('welcomeSlideFeaturesBody non-empty, not hardcoded PT', () {
      expect(l10n.welcomeSlideFeaturesBody, isNotEmpty);
      expect(l10n.welcomeSlideFeaturesBody, isNot(contains('actualizarem')));
    });

    test('welcomeSlidePrivacyEyebrow non-empty, not hardcoded PT', () {
      expect(l10n.welcomeSlidePrivacyEyebrow, isNotEmpty);
      expect(l10n.welcomeSlidePrivacyEyebrow, isNot('PRIVACIDADE'));
    });

    test('welcomeSlidePrivacyTitle non-empty, not hardcoded PT', () {
      expect(l10n.welcomeSlidePrivacyTitle, isNotEmpty);
      expect(l10n.welcomeSlidePrivacyTitle, isNot('Os teus dados ficam aqui'));
    });

    test('welcomeSlidePrivacyBody non-empty, not hardcoded PT', () {
      expect(l10n.welcomeSlidePrivacyBody, isNotEmpty);
      expect(l10n.welcomeSlidePrivacyBody, isNot(contains('partilha de dados')));
    });

    test('welcomeSlideStart non-empty, not hardcoded PT', () {
      expect(l10n.welcomeSlideStart, isNotEmpty);
      expect(l10n.welcomeSlideStart, isNot('Começar'));
    });

    test('welcomeSlideContinue non-empty, not hardcoded PT', () {
      expect(l10n.welcomeSlideContinue, isNotEmpty);
      expect(l10n.welcomeSlideContinue, isNot('Continuar'));
    });

    test('welcomeSlideSkip non-empty, not hardcoded PT', () {
      expect(l10n.welcomeSlideSkip, isNotEmpty);
      expect(l10n.welcomeSlideSkip, isNot('Saltar'));
    });
  });
}
