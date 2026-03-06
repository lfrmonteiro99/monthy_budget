import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/services/command_chat_service.dart';

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

    test('parses navigate_to from Portuguese', () {
      final result = CommandChatService.regexParse('abre as definicoes');
      expect(result, isNotNull);
      expect(result!.action, 'navigate_to');
      expect(result.params?['screen'], isNotNull);
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

  group('CommandChatService system prompt', () {
    test('buildSystemPrompt returns non-empty string with all actions', () {
      final prompt = CommandChatService.buildSystemPrompt();
      expect(prompt, contains('add_expense'));
      expect(prompt, contains('set_theme_mode'));
      expect(prompt, contains('navigate_to'));
      expect(prompt, contains('clear_checked_items'));
      expect(prompt, contains('EXACTLY ONE action'));
    });
  });
}
