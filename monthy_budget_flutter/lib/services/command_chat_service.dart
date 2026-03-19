import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/supabase_public_config.dart';
import '../constants/app_constants.dart';
import '../models/command_action.dart';
import 'command_action_registry.dart';
import 'log_service.dart';

class CommandChatService {
  static const _edgeFunctionName = 'openai-chat';
  static const _model = 'gpt-4o-mini';

  final http.Client _httpClient;

  CommandChatService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// Parse a user command via AI, with retry and regex fallback.
  Future<CommandAction> parseCommand(String userInput) async {
    // Try AI first
    try {
      final result = await _requestAiParse(userInput);
      if (result != null) return result;
    } catch (e) {
      LogService.warning(
        'AI command parse failed',
        error: e,
        category: 'service.command_chat',
      );
    }

    // Retry with stricter prompt
    try {
      final result = await _requestAiParse(userInput, strict: true);
      if (result != null) return result;
    } catch (e) {
      LogService.warning(
        'AI command strict retry failed',
        error: e,
        category: 'service.command_chat',
      );
    }

    // Silent regex fallback
    final regexResult = regexParse(userInput);
    if (regexResult != null) return regexResult;

    // All failed
    return CommandAction.conversational('');
  }

  Future<CommandAction?> _requestAiParse(
    String userInput, {
    bool strict = false,
  }) async {
    final systemPrompt = strict
        ? '${buildSystemPrompt()}\n\nIMPORTANT: Your previous response was '
              'not valid JSON. Return ONLY a JSON object with keys: action, '
              'params, message. No other text.'
        : buildSystemPrompt();

    final anonKey = supabaseAnonKey.trim();
    if (anonKey.isEmpty) return null;

    final response = await _httpClient
        .post(
          Uri.parse('$supabaseUrl/functions/v1/$_edgeFunctionName'),
          headers: {
            'Authorization': 'Bearer $anonKey',
            'apikey': supabaseAnonKey,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': _model,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userInput},
            ],
            'max_tokens': 200,
            'temperature': 0.1,
          }),
        )
        .timeout(AppConstants.commandChatTimeout);

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) return null;

    final content = data['content']?.toString().trim() ?? '';
    if (content.isEmpty) return null;

    // Try to parse as JSON
    try {
      final parsed = jsonDecode(content);
      if (parsed is Map<String, dynamic>) {
        return CommandAction.fromJson(parsed);
      }
    } catch (_) {
      // Not valid JSON — try extracting outermost JSON object
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(content);
      if (jsonMatch != null) {
        try {
          final parsed = jsonDecode(jsonMatch.group(0)!);
          if (parsed is Map<String, dynamic>) {
            return CommandAction.fromJson(parsed);
          }
        } catch (_) {}
      }
    }
    return null;
  }

  /// Regex fallback parser. Returns null if no pattern matches.
  static CommandAction? regexParse(String input) {
    final text = input.toLowerCase().trim();

    // add_expense
    final expenseMatch = RegExp(
      r'(?:adiciona|add|anade|ajoute|mete|poe|coloca)\s+'
      r'(\d+(?:[.,]\d+)?)\s*(?:euros?|eur|€)?\s*'
      r'(?:em|in|en|a|para)?\s*(.+)',
      caseSensitive: false,
    ).firstMatch(text);
    if (expenseMatch != null) {
      final amount = double.tryParse(
        expenseMatch.group(1)!.replaceAll(',', '.'),
      );
      final rawCategory = expenseMatch.group(2)!.trim();
      final category = _resolveCategory(rawCategory);
      if (amount != null && amount > 0 && category != null) {
        return CommandAction.withAction(
          action: 'add_expense',
          params: {'amount': amount, 'category': category},
          message: '',
        );
      }
    }

    // add_shopping_item
    final shoppingMatch = RegExp(
      r'(?:adiciona|add|anade|ajoute|mete|poe|coloca)\s+'
      r'(.+?)\s+'
      r'(?:na|no|to|a|à|ao)\s+'
      r'(?:lista(?:\s+de\s+compras)?|shopping\s+list|liste\s+de\s+courses)',
      caseSensitive: false,
    ).firstMatch(text);
    if (shoppingMatch != null) {
      final name = shoppingMatch.group(1)!.trim();
      if (name.isNotEmpty) {
        return CommandAction.withAction(
          action: 'add_shopping_item',
          params: {'name': name},
          message: '',
        );
      }
    }

    // remove_shopping_item
    final removeShoppingMatch = RegExp(
      r'(?:remove|remover|apaga|delete|tira)\s+'
      r'(.+?)\s+'
      r'(?:da|de|from)\s+'
      r'(?:lista(?:\s+de\s+compras)?|shopping\s+list|liste\s+de\s+courses)',
      caseSensitive: false,
    ).firstMatch(text);
    if (removeShoppingMatch != null) {
      final name = removeShoppingMatch.group(1)!.trim();
      if (name.isNotEmpty) {
        return CommandAction.withAction(
          action: 'remove_shopping_item',
          params: {'name': name},
          message: '',
        );
      }
    }

    // toggle_shopping_item_checked
    final toggleShoppingMatch = RegExp(
      r'(?:marca|mark|check|desmarca|uncheck)\s+'
      r'(.+?)\s+'
      r'(?:na|no|from|on|da|de)\s+'
      r'(?:lista(?:\s+de\s+compras)?|shopping\s+list|liste\s+de\s+courses)',
      caseSensitive: false,
    ).firstMatch(text);
    if (toggleShoppingMatch != null) {
      final name = toggleShoppingMatch.group(1)!.trim();
      final checked = !text.contains('desmarca') && !text.contains('uncheck');
      if (name.isNotEmpty) {
        return CommandAction.withAction(
          action: 'toggle_shopping_item_checked',
          params: {'name': name, 'checked': checked},
          message: '',
        );
      }
    }

    // add_savings_goal
    final savingsGoalMatch = RegExp(
      r'(?:cria|create|add|adiciona|ajoute)\s+'
      r"(?:um\s+)?(?:objetivo\s+de\s+poupanca|savings\s+goal|objectif\s+d'epargne)\s+"
      r'(.+?)\s+'
      r'(?:de|with|com)\s+'
      r'(\d+(?:[.,]\d+)?)',
      caseSensitive: false,
    ).firstMatch(text);
    if (savingsGoalMatch != null) {
      final name = savingsGoalMatch.group(1)!.trim();
      final targetAmount = double.tryParse(
        savingsGoalMatch.group(2)!.replaceAll(',', '.'),
      );
      if (name.isNotEmpty && targetAmount != null && targetAmount > 0) {
        return CommandAction.withAction(
          action: 'add_savings_goal',
          params: {'name': name, 'target_amount': targetAmount},
          message: '',
        );
      }
    }

    // add_savings_contribution
    final savingsContributionMatch = RegExp(
      r'(?:adiciona|add|mete|ajoute)\s+'
      r'(\d+(?:[.,]\d+)?)\s*(?:euros?|eur|€)?\s+'
      r'(?:ao|a|to)\s+'
      r'(?:objetivo|goal|objectif)\s+'
      r'(.+)',
      caseSensitive: false,
    ).firstMatch(text);
    if (savingsContributionMatch != null) {
      final amount = double.tryParse(
        savingsContributionMatch.group(1)!.replaceAll(',', '.'),
      );
      final goalName = savingsContributionMatch.group(2)!.trim();
      if (amount != null && amount > 0 && goalName.isNotEmpty) {
        return CommandAction.withAction(
          action: 'add_savings_contribution',
          params: {'amount': amount, 'goal_name': goalName},
          message: '',
        );
      }
    }

    // delete_expense
    final deleteExpenseMatch = RegExp(
      r'(?:apaga|delete|remove|remover)\s+'
      r'(?:a\s+)?(?:despesa|expense)\s+'
      r'(.+)',
      caseSensitive: false,
    ).firstMatch(text);
    if (deleteExpenseMatch != null) {
      final description = deleteExpenseMatch.group(1)!.trim();
      if (description.isNotEmpty) {
        return CommandAction.withAction(
          action: 'delete_expense',
          params: {'description': description},
          message: '',
        );
      }
    }

    // add_recurring_expense
    final recurringMatch = RegExp(
      r'(?:adiciona|add|ajoute|cria|create)\s+'
      r'(?:uma\s+)?(?:despesa\s+recorrente|recurring\s+expense|depense\s+recurrente)\s+'
      r'(\d+(?:[.,]\d+)?)\s*(?:euros?|eur|€)?\s*'
      r'(?:em|in|en|de)?\s*(\w+)(?:.*?(?:dia|day)\s+(\d{1,2}))?',
      caseSensitive: false,
    ).firstMatch(text);
    if (recurringMatch != null) {
      final amount = double.tryParse(
        recurringMatch.group(1)!.replaceAll(',', '.'),
      );
      final category = _resolveCategory(recurringMatch.group(2)!.trim());
      final day = recurringMatch.group(3) != null
          ? int.tryParse(recurringMatch.group(3)!)
          : null;
      if (amount != null && amount > 0 && category != null) {
        final params = <String, dynamic>{
          'amount': amount,
          'category': category,
        };
        if (day != null) params['day_of_month'] = day;
        return CommandAction.withAction(
          action: 'add_recurring_expense',
          params: params,
          message: '',
        );
      }
    }

    // set_theme_mode
    final themeMatch = RegExp(
      r'(?:tema|theme|modo|thème)\s*(?:para\s+)?(?:o\s+|le\s+|el\s+)?'
      r'(claro|light|escuro|dark|sistema|system|automatico|oscuro|sombre|clair)',
      caseSensitive: false,
    ).firstMatch(text);
    if (themeMatch != null) {
      final raw = themeMatch.group(1)!.toLowerCase();
      final mode = switch (raw) {
        'claro' || 'light' || 'clair' => 'light',
        'escuro' || 'dark' || 'oscuro' || 'sombre' => 'dark',
        _ => 'system',
      };
      return CommandAction.withAction(
        action: 'set_theme_mode',
        params: {'mode': mode},
        message: '',
      );
    }

    // set_color_palette
    final paletteMatch = RegExp(
      r'(?:cor|color|colour|palette|paleta|couleur)\s+'
      r'(ocean|emerald|violet|teal|sunset)',
      caseSensitive: false,
    ).firstMatch(text);
    if (paletteMatch != null) {
      return CommandAction.withAction(
        action: 'set_color_palette',
        params: {'palette': paletteMatch.group(1)!.toLowerCase()},
        message: '',
      );
    }

    // set_language
    final languageMatch = RegExp(
      r'(?:idioma|language|langue|lengua)\s+'
      r'(?:para|to|a|en)?\s*'
      r'(portugues|portuguese|pt|ingles|english|en|espanhol|spanish|es|frances|french|fr|sistema|system)',
      caseSensitive: false,
    ).firstMatch(text);
    if (languageMatch != null) {
      final raw = languageMatch.group(1)!.toLowerCase();
      final locale = switch (raw) {
        'portugues' || 'portuguese' || 'pt' => 'pt',
        'ingles' || 'english' || 'en' => 'en',
        'espanhol' || 'spanish' || 'es' => 'es',
        'frances' || 'french' || 'fr' => 'fr',
        _ => 'system',
      };
      return CommandAction.withAction(
        action: 'set_language',
        params: {'locale': locale},
        message: '',
      );
    }

    // clear_checked_items
    final clearMatch = RegExp(
      r'(?:limpa|clear|limpiar|effacer)\s+(?:a\s+)?'
      r'(?:lista|list|checked|itens)',
      caseSensitive: false,
    ).firstMatch(text);
    if (clearMatch != null) {
      return CommandAction.withAction(
        action: 'clear_checked_items',
        params: {},
        message: '',
      );
    }

    // navigate_to
    final navMatch = RegExp(
      r'(?:vai|abre|open|go|ir|navega|abrir|ouvre|ouvrir|aller)\s+'
      r'(?:para?\s+)?(?:as?\s+|os?\s+|o\s+|les?\s+|la\s+|al\s+)?(.+)',
      caseSensitive: false,
    ).firstMatch(text);
    if (navMatch != null) {
      final rawScreen = navMatch.group(1)!.trim();
      final screen = CommandActionRegistry.resolveScreenAlias(rawScreen);
      if (screen != null) {
        return CommandAction.withAction(
          action: 'navigate_to',
          params: {'screen': screen},
          message: '',
        );
      }
    }

    return null;
  }

  static String? _resolveCategory(String raw) {
    const aliases = <String, String>{
      'alimentacao': 'alimentacao',
      'comida': 'alimentacao',
      'food': 'alimentacao',
      'supermercado': 'alimentacao',
      'habitacao': 'habitacao',
      'renda': 'habitacao',
      'casa': 'habitacao',
      'housing': 'habitacao',
      'rent': 'habitacao',
      'transportes': 'transportes',
      'transporte': 'transportes',
      'transport': 'transportes',
      'gasolina': 'transportes',
      'saude': 'saude',
      'health': 'saude',
      'farmacia': 'saude',
      'medico': 'saude',
      'educacao': 'educacao',
      'education': 'educacao',
      'escola': 'educacao',
      'lazer': 'lazer',
      'leisure': 'lazer',
      'entretenimento': 'lazer',
      'energia': 'energia',
      'energy': 'energia',
      'eletricidade': 'energia',
      'luz': 'energia',
      'agua': 'agua',
      'water': 'agua',
      'telecomunicacoes': 'telecomunicacoes',
      'telecom': 'telecomunicacoes',
      'internet': 'telecomunicacoes',
      'telefone': 'telecomunicacoes',
      'outros': 'outros',
      'other': 'outros',
      'misc': 'outros',
    };
    return aliases[raw.toLowerCase().trim()];
  }

  /// Builds the system prompt that instructs the AI to parse commands.
  static String buildSystemPrompt() {
    return 'You are a command assistant for the "Orcamento Mensal" app.\n'
        'Your job: parse user requests into structured actions.\n'
        '\n'
        'AVAILABLE ACTIONS (return ONLY these):\n'
        '- add_expense: {amount: number, category: string, '
        'description?: string}\n'
        '  Categories: [alimentacao, habitacao, transportes, saude, educacao, '
        'lazer, energia, agua, telecomunicacoes, outros]\n'
        '- add_shopping_item: {name: string, store?: string, price?: number, '
        'unitPrice?: string}\n'
        '- remove_shopping_item: {name: string}\n'
        '- toggle_shopping_item_checked: {name: string, checked: boolean}\n'
        '- add_savings_goal: {name: string, target_amount: number}\n'
        '- add_savings_contribution: {goal_name: string, amount: number}\n'
        '- add_recurring_expense: {amount: number, category: string, '
        'description?: string, day_of_month?: number}\n'
        '- delete_expense: {description: string, category?: string}\n'
        '- set_theme_mode: {mode: "light" | "dark" | "system"}\n'
        '- set_color_palette: {palette: "ocean" | "emerald" | "violet" | '
        '"teal" | "sunset"}\n'
        '- set_language: {locale: "system" | "pt" | "en" | "es" | "fr"}\n'
        '- navigate_to: {screen: "dashboard" | "expenses" | "coach" | '
        '"grocery" | "shopping_list" | "meals" | "settings" | "insights" | '
        '"savings_goals"}\n'
        '- clear_checked_items: {}\n'
        '\n'
        'RULES:\n'
        '- ALWAYS return valid JSON with keys: action, params, message\n'
        '- message: friendly confirmation in the user\'s language\n'
        '- If intent is clear but params are incomplete, ask for the missing '
        'info (action: null)\n'
        '- If the request is financial/analytical, suggest the Coach '
        '(action: null)\n'
        '- If you don\'t understand, ask to rephrase (action: null)\n'
        '- NEVER invent actions outside the list above\n'
        '- NEVER execute if intent OR params are ambiguous\n'
        '- If the request involves multiple actions, choose the SINGLE most '
        'relevant one. Never return multiple actions.\n'
        '- Return EXACTLY ONE action per response. No arrays, no chaining.';
  }
}
