import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:monthly_management/services/command_chat_service.dart';

void main() {
  group('CommandChatService regex fallback', () {
    test('parses add_expense from Portuguese', () {
      final result =
          CommandChatService.regexParse('adiciona 50 euros em alimentacao');
      expect(result, isNotNull);
      expect(result!.action, 'add_expense');
      expect(result.params?['amount'], 50.0);
      expect(result.params?['category'], 'alimentacao');
    });

    test('parses add_expense with decimal and description', () {
      final result = CommandChatService.regexParse('adiciona 12.50 em saude');
      expect(result, isNotNull);
      expect(result!.action, 'add_expense');
      expect(result.params?['amount'], 12.5);
      expect(result.params?['category'], 'saude');
    });

    test('parses add_expense from English', () {
      final result =
          CommandChatService.regexParse('add 30 euros in transportes');
      expect(result, isNotNull);
      expect(result!.action, 'add_expense');
      expect(result.params?['amount'], 30.0);
    });

    test('parses set_theme_mode dark', () {
      final result = CommandChatService.regexParse('tema escuro');
      expect(result, isNotNull);
      expect(result!.action, 'set_theme_mode');
      expect(result.params?['mode'], 'dark');
    });

    test('parses set_theme_mode light', () {
      final result = CommandChatService.regexParse('theme light');
      expect(result, isNotNull);
      expect(result!.action, 'set_theme_mode');
      expect(result.params?['mode'], 'light');
    });

    test('parses set_theme_mode system', () {
      final result = CommandChatService.regexParse('modo sistema');
      expect(result, isNotNull);
      expect(result!.action, 'set_theme_mode');
      expect(result.params?['mode'], 'system');
    });

    test('parses set_color_palette', () {
      final result = CommandChatService.regexParse('cor emerald');
      expect(result, isNotNull);
      expect(result!.action, 'set_color_palette');
      expect(result.params?['palette'], 'emerald');
    });

    test('parses add_shopping_item from Portuguese', () {
      final result = CommandChatService.regexParse(
        'adiciona leite na lista de compras',
      );
      expect(result, isNotNull);
      expect(result!.action, 'add_shopping_item');
      expect(result.params?['name'], 'leite');
    });

    test('parses add_shopping_item from English', () {
      final result = CommandChatService.regexParse(
        'add bread to shopping list',
      );
      expect(result, isNotNull);
      expect(result!.action, 'add_shopping_item');
      expect(result.params?['name'], 'bread');
    });

    test('parses remove_shopping_item', () {
      final result = CommandChatService.regexParse(
        'remove leite from shopping list',
      );
      expect(result, isNotNull);
      expect(result!.action, 'remove_shopping_item');
      expect(result.params?['name'], 'leite');
    });

    test('parses toggle_shopping_item_checked as checked', () {
      final result = CommandChatService.regexParse(
        'marca leite na lista de compras',
      );
      expect(result, isNotNull);
      expect(result!.action, 'toggle_shopping_item_checked');
      expect(result.params?['name'], 'leite');
      expect(result.params?['checked'], isTrue);
    });

    test('parses toggle_shopping_item_checked as unchecked', () {
      final result = CommandChatService.regexParse(
        'uncheck milk from shopping list',
      );
      expect(result, isNotNull);
      expect(result!.action, 'toggle_shopping_item_checked');
      expect(result.params?['name'], 'milk');
      expect(result.params?['checked'], isFalse);
    });

    test('parses set_language', () {
      final result = CommandChatService.regexParse('idioma ingles');
      expect(result, isNotNull);
      expect(result!.action, 'set_language');
      expect(result.params?['locale'], 'en');
    });

    test('parses add_savings_goal', () {
      final result = CommandChatService.regexParse(
        'cria objetivo de poupanca ferias de 1200',
      );
      expect(result, isNotNull);
      expect(result!.action, 'add_savings_goal');
      expect(result.params?['name'], 'ferias');
      expect(result.params?['target_amount'], 1200.0);
    });

    test('parses add_recurring_expense', () {
      final result = CommandChatService.regexParse(
        'adiciona despesa recorrente 29.9 em telecomunicacoes dia 5',
      );
      expect(result, isNotNull);
      expect(result!.action, 'add_recurring_expense');
      expect(result.params?['amount'], 29.9);
      expect(result.params?['category'], 'telecomunicacoes');
      expect(result.params?['day_of_month'], 5);
    });

    test('parses add_savings_contribution', () {
      final result = CommandChatService.regexParse('add 50 to goal ferias');
      expect(result, isNotNull);
      expect(result!.action, 'add_savings_contribution');
      expect(result.params?['goal_name'], 'ferias');
      expect(result.params?['amount'], 50.0);
    });

    test('parses delete_expense', () {
      final result = CommandChatService.regexParse('apaga a despesa netflix');
      expect(result, isNotNull);
      expect(result!.action, 'delete_expense');
      expect(result.params?['description'], 'netflix');
    });

    test('parses navigate_to from Portuguese', () {
      final result = CommandChatService.regexParse('abre as definicoes');
      expect(result, isNotNull);
      expect(result!.action, 'navigate_to');
      expect(result.params?['screen'], isNotNull);
    });

    test('parses navigate_to from English', () {
      final result = CommandChatService.regexParse('open insights');
      expect(result, isNotNull);
      expect(result!.action, 'navigate_to');
      expect(result.params?['screen'], 'insights');
    });

    test('parses clear_checked_items', () {
      final result = CommandChatService.regexParse('limpa a lista');
      expect(result, isNotNull);
      expect(result!.action, 'clear_checked_items');
    });

    test('returns null for unrecognized input', () {
      final result = CommandChatService.regexParse('how is the weather');
      expect(result, isNull);
    });

    test('parses palette from Portuguese', () {
      final result = CommandChatService.regexParse('paleta sunset');
      expect(result, isNotNull);
      expect(result!.action, 'set_color_palette');
      expect(result.params?['palette'], 'sunset');
    });
  });

  group('French command regex (#750)', () {
    test('parses add_expense from French', () {
      final result =
          CommandChatService.regexParse('ajoute 45 euros en alimentacao');
      expect(result, isNotNull);
      expect(result!.action, 'add_expense');
      expect(result.params?['amount'], 45.0);
      expect(result.params?['category'], 'alimentacao');
    });

    test('parses add_shopping_item from French', () {
      final result = CommandChatService.regexParse(
        'ajoute pain a la liste de courses',
      );
      expect(result, isNotNull);
      expect(result!.action, 'add_shopping_item');
      expect(result.params?['name'], 'pain');
    });

    test('parses remove_shopping_item from French', () {
      final result = CommandChatService.regexParse(
        'retire beurre de la liste de courses',
      );
      expect(result, isNotNull);
      expect(result!.action, 'remove_shopping_item');
      expect(result.params?['name'], 'beurre');
    });

    test('parses toggle_shopping_item checked from French', () {
      final result = CommandChatService.regexParse(
        'coche lait dans la liste de courses',
      );
      expect(result, isNotNull);
      expect(result!.action, 'toggle_shopping_item_checked');
      expect(result.params?['name'], 'lait');
      expect(result.params?['checked'], isTrue);
    });

    test('parses toggle_shopping_item unchecked from French', () {
      final result = CommandChatService.regexParse(
        'decoche lait dans la liste de courses',
      );
      expect(result, isNotNull);
      expect(result!.action, 'toggle_shopping_item_checked');
      expect(result.params?['name'], 'lait');
      expect(result.params?['checked'], isFalse);
    });

    test('parses delete_expense from French', () {
      final result =
          CommandChatService.regexParse('supprime la depense netflix');
      expect(result, isNotNull);
      expect(result!.action, 'delete_expense');
      expect(result.params?['description'], 'netflix');
    });

    test('parses add_savings_goal from French', () {
      final result = CommandChatService.regexParse(
        "cree objectif d'epargne vacances de 1500",
      );
      expect(result, isNotNull);
      expect(result!.action, 'add_savings_goal');
      expect(result.params?['name'], 'vacances');
      expect(result.params?['target_amount'], 1500.0);
    });

    test('parses add_recurring_expense from French', () {
      final result = CommandChatService.regexParse(
        'ajoute depense recurrente 35 en telecomunicacoes jour 10',
      );
      expect(result, isNotNull);
      expect(result!.action, 'add_recurring_expense');
      expect(result.params?['amount'], 35.0);
      expect(result.params?['category'], 'telecomunicacoes');
      expect(result.params?['day_of_month'], 10);
    });

    test('parses navigate_to from French', () {
      final result = CommandChatService.regexParse('ouvre les parametres');
      expect(result, isNotNull);
      expect(result!.action, 'navigate_to');
    });

    test('parses set_theme_mode from French', () {
      final result = CommandChatService.regexParse('theme sombre');
      expect(result, isNotNull);
      expect(result!.action, 'set_theme_mode');
      expect(result.params?['mode'], 'dark');
    });

    test('parses set_language from French', () {
      final result = CommandChatService.regexParse('langue francais');
      expect(result, isNotNull);
      expect(result!.action, 'set_language');
      expect(result.params?['locale'], 'fr');
    });

    test('parses clear_checked_items from French', () {
      final result = CommandChatService.regexParse('effacer les coches');
      expect(result, isNotNull);
      expect(result!.action, 'clear_checked_items');
    });
  });

  group('Spanish command regex (#750)', () {
    test('parses add_expense from Spanish', () {
      final result =
          CommandChatService.regexParse('anade 25 euros en alimentacao');
      expect(result, isNotNull);
      expect(result!.action, 'add_expense');
      expect(result.params?['amount'], 25.0);
      expect(result.params?['category'], 'alimentacao');
    });

    test('parses add_shopping_item from Spanish', () {
      final result = CommandChatService.regexParse(
        'anade leche a la lista de compras',
      );
      expect(result, isNotNull);
      expect(result!.action, 'add_shopping_item');
      expect(result.params?['name'], 'leche');
    });

    test('parses remove_shopping_item from Spanish', () {
      final result = CommandChatService.regexParse(
        'quita mantequilla de la lista de compras',
      );
      expect(result, isNotNull);
      expect(result!.action, 'remove_shopping_item');
      expect(result.params?['name'], 'mantequilla');
    });

    test('parses toggle_shopping_item checked from Spanish', () {
      final result = CommandChatService.regexParse(
        'marca huevos en la lista de compras',
      );
      expect(result, isNotNull);
      expect(result!.action, 'toggle_shopping_item_checked');
      expect(result.params?['name'], 'huevos');
      expect(result.params?['checked'], isTrue);
    });

    test('parses toggle_shopping_item unchecked from Spanish', () {
      final result = CommandChatService.regexParse(
        'desmarca huevos en la lista de compras',
      );
      expect(result, isNotNull);
      expect(result!.action, 'toggle_shopping_item_checked');
      expect(result.params?['name'], 'huevos');
      expect(result.params?['checked'], isFalse);
    });

    test('parses delete_expense from Spanish', () {
      final result =
          CommandChatService.regexParse('elimina el gasto netflix');
      expect(result, isNotNull);
      expect(result!.action, 'delete_expense');
      expect(result.params?['description'], 'netflix');
    });

    test('parses add_savings_goal from Spanish', () {
      final result = CommandChatService.regexParse(
        'crea objetivo de ahorro vacaciones de 2000',
      );
      expect(result, isNotNull);
      expect(result!.action, 'add_savings_goal');
      expect(result.params?['name'], 'vacaciones');
      expect(result.params?['target_amount'], 2000.0);
    });

    test('parses add_recurring_expense from Spanish', () {
      final result = CommandChatService.regexParse(
        'anade gasto recurrente 50 en energia dia 15',
      );
      expect(result, isNotNull);
      expect(result!.action, 'add_recurring_expense');
      expect(result.params?['amount'], 50.0);
      expect(result.params?['category'], 'energia');
      expect(result.params?['day_of_month'], 15);
    });

    test('parses navigate_to from Spanish', () {
      final result = CommandChatService.regexParse('abre los ajustes');
      expect(result, isNotNull);
      expect(result!.action, 'navigate_to');
    });

    test('parses set_theme_mode from Spanish', () {
      final result = CommandChatService.regexParse('tema oscuro');
      expect(result, isNotNull);
      expect(result!.action, 'set_theme_mode');
      expect(result.params?['mode'], 'dark');
    });

    test('parses set_language from Spanish', () {
      final result = CommandChatService.regexParse('lengua espanol');
      expect(result, isNotNull);
      expect(result!.action, 'set_language');
      expect(result.params?['locale'], 'es');
    });

    test('parses clear_checked_items from Spanish', () {
      final result = CommandChatService.regexParse('limpiar los marcados');
      expect(result, isNotNull);
      expect(result!.action, 'clear_checked_items');
    });
  });

  group('Help command regex (#755)', () {
    test('parses help in English', () {
      final result = CommandChatService.regexParse('help');
      expect(result, isNotNull);
      expect(result!.action, 'show_help');
    });

    test('parses ajuda in Portuguese', () {
      final result = CommandChatService.regexParse('ajuda');
      expect(result, isNotNull);
      expect(result!.action, 'show_help');
    });

    test('parses aide in French', () {
      final result = CommandChatService.regexParse('aide');
      expect(result, isNotNull);
      expect(result!.action, 'show_help');
    });

    test('parses ayuda in Spanish', () {
      final result = CommandChatService.regexParse('ayuda');
      expect(result, isNotNull);
      expect(result!.action, 'show_help');
    });

    test('parses help with leading/trailing spaces', () {
      final result = CommandChatService.regexParse('  help  ');
      expect(result, isNotNull);
      expect(result!.action, 'show_help');
    });

    test('system prompt includes show_help action', () {
      final prompt = CommandChatService.buildSystemPrompt();
      expect(prompt, contains('show_help'));
    });
  });

  group('CommandChatService system prompt', () {
    test('buildSystemPrompt returns non-empty string with all actions', () {
      final prompt = CommandChatService.buildSystemPrompt();
      expect(prompt, contains('add_expense'));
      expect(prompt, contains('set_theme_mode'));
      expect(prompt, contains('add_shopping_item'));
      expect(prompt, contains('remove_shopping_item'));
      expect(prompt, contains('toggle_shopping_item_checked'));
      expect(prompt, contains('add_savings_goal'));
      expect(prompt, contains('add_savings_contribution'));
      expect(prompt, contains('add_recurring_expense'));
      expect(prompt, contains('delete_expense'));
      expect(prompt, contains('set_language'));
      expect(prompt, contains('navigate_to'));
      expect(prompt, contains('clear_checked_items'));
      expect(prompt, contains('EXACTLY ONE action'));
    });
  });

  group('extractJsonObject (#753)', () {
    test('extracts simple JSON object', () {
      const input = '{"action":"add_expense","params":{"amount":10}}';
      expect(CommandChatService.extractJsonObject(input), input);
    });

    test('extracts JSON from surrounding text', () {
      const input = 'Here is the result: {"action":"nav","params":{}} done';
      expect(
        CommandChatService.extractJsonObject(input),
        '{"action":"nav","params":{}}',
      );
    });

    test('handles nested braces correctly', () {
      const input = '{"action":"add","params":{"nested":{"deep":1}},"message":"ok"}';
      expect(CommandChatService.extractJsonObject(input), input);
    });

    test('ignores braces inside strings', () {
      const input = '{"msg":"a { b } c","val":1}';
      expect(CommandChatService.extractJsonObject(input), input);
    });

    test('returns null for no braces', () {
      expect(CommandChatService.extractJsonObject('no json here'), isNull);
    });

    test('returns null for unbalanced braces', () {
      expect(CommandChatService.extractJsonObject('{unclosed'), isNull);
    });

    test('stops at first balanced object (does not greedily match)', () {
      const input = '{"a":1} some text {"b":2}';
      expect(CommandChatService.extractJsonObject(input), '{"a":1}');
    });

    test('handles escaped quotes in strings', () {
      const input = r'{"msg":"say \"hello\"","v":1}';
      expect(CommandChatService.extractJsonObject(input), input);
    });
  });

  group('parseCommand fallback (#758)', () {
    test('returns meaningful error when all parsing fails', () async {
      final service = CommandChatService(httpClient: _NoopClient());
      final result = await service.parseCommand('xyzzy gibberish');
      expect(result.action, isNull);
      expect(result.message, isNotEmpty);
      expect(result.message, isNot(equals('')));
    });
  });
}

class _NoopClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(Stream.value([]), 500);
  }
}
