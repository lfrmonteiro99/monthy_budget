import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

void main() {
  late S l10n;

  setUpAll(() async {
    l10n = await S.delegate.load(const Locale('pt'));
  });

  group('command bar / coach PT-PT diacritics #1313', () {
    test('cmdSuggestionOpenSettings has correct diacritics', () {
      expect(l10n.cmdSuggestionOpenSettings, 'Ir para definições');
    });

    test('cmdTemplateOpenSettings has correct diacritics', () {
      expect(l10n.cmdTemplateOpenSettings, 'Abre as definições');
    });

    test('cmdExecutionFailed has correct diacritics', () {
      expect(
        l10n.cmdExecutionFailed,
        'Percebi o pedido, mas não consegui executar. Tenta novamente.',
      );
    });

    test('cmdNotUnderstood has correct diacritics', () {
      expect(l10n.cmdNotUnderstood, 'Não percebi. Podes reformular?');
    });

    test('cmdCapabilitiesTitle has correct diacritics', () {
      expect(l10n.cmdCapabilitiesTitle, 'Ações disponíveis');
    });

    test('cmdCapabilitiesSubtitle has correct diacritics', () {
      expect(
        l10n.cmdCapabilitiesSubtitle,
        'Estas são as ações que o assistente suporta neste momento.',
      );
    });

    test('cmdCapabilitiesFooter has correct diacritics', () {
      expect(
        l10n.cmdCapabilitiesFooter,
        'Estamos a adicionar mais. Se ainda não estiver aqui, pode não funcionar.',
      );
    });

    test('cmdCapabilityAddSavingsGoal has correct diacritics', () {
      expect(l10n.cmdCapabilityAddSavingsGoal, 'Criar objetivo de poupança');
    });

    test('cmdCapabilityAddSavingsGoalExample preserves placeholders', () {
      expect(
        l10n.cmdCapabilityAddSavingsGoalExample,
        'Cria objetivo de poupança [nome] de [valor]',
      );
    });

    test('cmdCapabilityDeleteExpenseExample preserves placeholders', () {
      expect(
        l10n.cmdCapabilityDeleteExpenseExample,
        'Apaga a despesa [descrição]',
      );
    });

    test('cmdCapabilityChangeLanguageExample has correct diacritics', () {
      expect(
        l10n.cmdCapabilityChangeLanguageExample,
        'Idioma [inglês/português/espanhol/francês]',
      );
    });

    test('cmdCapabilityNavigate has correct diacritics', () {
      expect(l10n.cmdCapabilityNavigate, 'Abrir ecrã');
    });

    test('coachMemory has correct diacritics', () {
      expect(l10n.coachMemory, 'Memória');
    });

    test('coachFree has correct diacritics', () {
      expect(l10n.coachFree, 'Grátis');
    });

    test('coachEcoFallbackBody has correct diacritics', () {
      expect(
        l10n.coachEcoFallbackBody,
        'Podes continuar a conversar, mas com memória reduzida.',
      );
    });

    test('coachRestoreMemory has correct diacritics', () {
      expect(l10n.coachRestoreMemory, 'Restaurar memória');
    });

    test('coachQuickPrompt1 has correct diacritics', () {
      expect(
        l10n.coachQuickPrompt1,
        'Onde posso cortar despesas este mês?',
      );
    });

    test('coachQuickPrompt2 has correct diacritics', () {
      expect(l10n.coachQuickPrompt2, 'Como melhoro a minha poupança?');
    });

    test('coachCompareMemory20 has correct diacritics', () {
      expect(l10n.coachCompareMemory20, 'Memória: 20 msgs');
    });

    test('coachCompareMemory6 has correct diacritics', () {
      expect(l10n.coachCompareMemory6, 'Memória: 6 msgs');
    });

    test('coachSuggestedDaysAgo has correct diacritics', () {
      expect(l10n.coachSuggestedDaysAgo(3), 'Sugerido há 3 dias');
    });

    test('coachCapWarning has correct diacritics', () {
      expect(
        l10n.coachCapWarning,
        'Máximo atingido (150). Usa os teus créditos antes da próxima renovação!',
      );
    });

    test('cmdContributionAdded preserves placeholders', () {
      expect(
        l10n.cmdContributionAdded('10€', 'Férias'),
        'Contribuição adicionada: 10€ a Férias',
      );
    });

    test('coachFreeTrialBanner has correct diacritics', () {
      expect(
        l10n.coachFreeTrialBanner(2, 5),
        'Período gratuito: 2/5 perguntas usadas este mês',
      );
    });

    test('barcodeProductNotFound has correct diacritics', () {
      expect(l10n.barcodeProductNotFound, 'Produto Não Encontrado');
    });
  });
}
