import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations_fr.dart';
import 'package:monthly_management/services/command_chat_service.dart';

void main() {
  late SFr fr;
  setUpAll(() {
    fr = SFr();
  });

  group('app_fr.arb AI Coach / command bar accents (#1230)', () {
    test('coachEmptyBody has correct French diacritics', () {
      expect(fr.coachEmptyBody, contains('dépenses'));
      expect(fr.coachEmptyBody, contains('épargne'));
      expect(fr.coachEmptyBody, contains('données réelles'));
      expect(fr.coachEmptyBody, contains('personnalisés'));
    });

    test('coachQuickPrompt1 has correct French diacritics', () {
      expect(fr.coachQuickPrompt1, contains('réduire'));
      expect(fr.coachQuickPrompt1, contains('dépenses'));
    });

    test('coachQuickPrompt2 has correct French diacritics', () {
      expect(fr.coachQuickPrompt2, contains('améliorer'));
      expect(fr.coachQuickPrompt2, contains('épargne'));
    });

    test('cmdTemplateAddExpense accents [catégorie] placeholder', () {
      expect(fr.cmdTemplateAddExpense, contains('[catégorie]'));
    });

    test('coachNoApiKeyBody shows Réglages with accent', () {
      expect(fr.coachNoApiKeyBody, contains('Réglages'));
    });

    test('cmdExpenseAdded shows Dépense ajoutée with accents', () {
      expect(fr.cmdExpenseAdded('10', 'courses'), contains('Dépense ajoutée'));
    });

    test('cmdHelpOutput has accented dépense/catégorie/épargne', () {
      final help = fr.cmdHelpOutput;
      expect(help, contains('dépense'));
      expect(help, contains('catégorie'));
      expect(help, contains("d'épargne"));
      // structure preserved: same number of lines and bullet separators
      expect('\n'.allMatches(help).length, 14);
      expect('- '.allMatches(help).length, 14);
    });

    test('regex fallback still recognizes accented "Supprime la dépense" example', () {
      final result = CommandChatService.regexParse('supprime la dépense netflix');
      expect(result, isNotNull);
      expect(result!.action, 'delete_expense');
    });

    test('regex fallback still recognizes unaccented "supprime la depense" (unchanged)', () {
      final result = CommandChatService.regexParse('supprime la depense netflix');
      expect(result, isNotNull);
      expect(result!.action, 'delete_expense');
    });

    test('regex fallback still recognizes accented savings goal example', () {
      final result = CommandChatService.regexParse(
        "crée objectif d'épargne vacances de 1500",
      );
      expect(result, isNotNull);
      expect(result!.action, 'add_savings_goal');
    });

    test('regex fallback still recognizes accented recurring expense example', () {
      final result = CommandChatService.regexParse(
        'ajoute dépense récurrente 35 en telecomunicacoes jour 10',
      );
      expect(result, isNotNull);
      expect(result!.action, 'add_recurring_expense');
    });
  });
}
