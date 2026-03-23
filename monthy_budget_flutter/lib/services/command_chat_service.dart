import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/supabase_public_config.dart';
import '../constants/app_constants.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/command_action.dart';
import 'command_action_registry.dart';
import 'log_service.dart';

class CommandChatService {
  static const _edgeFunctionName = 'openai-chat';
  static const _model = 'gpt-4o-mini';
  static const _maxUserMessageLength = 2000;

  final http.Client _httpClient;

  CommandChatService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// Sanitize user input before interpolating into prompts.
  ///
  /// Truncates to [_maxUserMessageLength] and strips sequences that could
  /// be mistaken for prompt boundaries (e.g. system-role injections).
  static String sanitizeUserInput(String input) {
    var sanitized = input.trim();
    if (sanitized.length > _maxUserMessageLength) {
      sanitized = sanitized.substring(0, _maxUserMessageLength);
    }
    // Strip common prompt-injection patterns
    sanitized = sanitized.replaceAll(RegExp(r'```system\b', caseSensitive: false), '');
    sanitized = sanitized.replaceAll(RegExp(r'\[SYSTEM\]', caseSensitive: false), '');
    sanitized = sanitized.replaceAll(RegExp(r'\[INST\]', caseSensitive: false), '');
    sanitized = sanitized.replaceAll(RegExp(r'<\|im_start\|>', caseSensitive: false), '');
    sanitized = sanitized.replaceAll(RegExp(r'<\|im_end\|>', caseSensitive: false), '');
    return sanitized;
  }

  /// Parse a user command via AI, with retry and regex fallback.
  Future<CommandAction> parseCommand(String userInput, {S? l10n}) async {
    final safeInput = sanitizeUserInput(userInput);
    // Try AI first
    try {
      final result = await _requestAiParse(safeInput);
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
      final result = await _requestAiParse(safeInput, strict: true);
      if (result != null) return result;
    } catch (e) {
      LogService.warning(
        'AI command strict retry failed',
        error: e,
        category: 'service.command_chat',
      );
    }

    // Silent regex fallback
    final regexResult = regexParse(safeInput);
    if (regexResult != null) return regexResult;

    // All failed -- return localized error message
    final errorMessage = l10n?.cmdParseError ??
        'Sorry, I could not understand your request. Please try rephrasing.';
    return CommandAction.conversational(errorMessage);
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
      // Not valid JSON -- try extracting outermost JSON object with
      // brace-depth counting (safe alternative to greedy regex).
      final jsonStr = extractJsonObject(content);
      if (jsonStr != null) {
        try {
          final parsed = jsonDecode(jsonStr);
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

    // show_help (#755) -- exact-match keywords, checked early
    if (RegExp(r'^(?:help|ajuda|aide|ayuda)$').hasMatch(text)) {
      return CommandAction.withAction(
        action: 'show_help',
        params: {},
        message: '',
      );
    }

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

    // add_shopping_item (PT/EN/FR/ES)
    final shoppingMatch = RegExp(
      r'(?:adiciona|add|anade|ajoute|mete|poe|coloca)\s+'
      r'(.+?)\s+'
      r'(?:na|no|to|a|à|ao|al)\s+'
      r'(?:la\s+)?(?:lista(?:\s+de\s+(?:compras|courses))?|shopping\s+list|liste\s+de\s+courses)',
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

    // remove_shopping_item (PT/EN/FR/ES)
    final removeShoppingMatch = RegExp(
      r'(?:remove|remover|apaga|delete|tira|retire|retirer|quita|quitar|elimina|eliminar|supprime|supprimer)\s+'
      r'(.+?)\s+'
      r'(?:da|de|from)\s+'
      r'(?:la\s+)?(?:lista(?:\s+de\s+(?:compras|courses))?|shopping\s+list|liste\s+de\s+courses)',
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

    // toggle_shopping_item_checked (PT/EN/FR/ES)
    final toggleShoppingMatch = RegExp(
      r'(?:marca|mark|check|desmarca|uncheck|coche|decoche|marcar|desmarcar)\s+'
      r'(.+?)\s+'
      r'(?:na|no|from|on|da|de|dans|en)\s+'
      r'(?:la\s+)?(?:lista(?:\s+de\s+(?:compras|courses))?|shopping\s+list|liste\s+de\s+courses)',
      caseSensitive: false,
    ).firstMatch(text);
    if (toggleShoppingMatch != null) {
      final name = toggleShoppingMatch.group(1)!.trim();
      final checked = !text.contains('desmarca') &&
          !text.contains('uncheck') &&
          !text.contains('decoche');
      if (name.isNotEmpty) {
        return CommandAction.withAction(
          action: 'toggle_shopping_item_checked',
          params: {'name': name, 'checked': checked},
          message: '',
        );
      }
    }

    // add_savings_goal (PT/EN/FR/ES)
    final savingsGoalMatch = RegExp(
      r'(?:cria|cree|crea|create|add|adiciona|ajoute|anade)\s+'
      r"(?:um\s+)?(?:objetivo\s+de\s+(?:poupanca|ahorro)|savings\s+goal|objectif\s+d'epargne)\s+"
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

    // add_savings_contribution (PT/EN/FR/ES)
    final savingsContributionMatch = RegExp(
      r'(?:adiciona|add|mete|ajoute|anade)\s+'
      r'(\d+(?:[.,]\d+)?)\s*(?:euros?|eur|€)?\s+'
      r'(?:ao|a|to|al)\s+'
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

    // delete_expense (PT/EN/FR/ES)
    final deleteExpenseMatch = RegExp(
      r'(?:apaga|delete|remove|remover|supprime|supprimer|elimina|eliminar|borra|borrar)\s+'
      r'(?:a\s+|la\s+|el\s+)?(?:despesa|expense|depense|gasto)\s+'
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

    // add_recurring_expense (PT/EN/FR/ES)
    final recurringMatch = RegExp(
      r'(?:adiciona|add|ajoute|anade|cria|cree|crea|create)\s+'
      r'(?:uma?\s+)?(?:despesa\s+recorrente|recurring\s+expense|depense\s+recurrente|gasto\s+recurrente)\s+'
      r'(\d+(?:[.,]\d+)?)\s*(?:euros?|eur|€)?\s*'
      r'(?:em|in|en|de)?\s*(\w+)(?:.*?(?:dia|day|jour)\s+(\d{1,2}))?',
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

    // set_language (PT/EN/FR/ES)
    final languageMatch = RegExp(
      r'(?:idioma|language|langue|lengua)\s+'
      r'(?:para|to|a|en)?\s*'
      r'(portugues|portuguese|pt|ingles|english|en|espanhol|espanol|spanish|es|frances|francais|french|fr|sistema|system|systeme)',
      caseSensitive: false,
    ).firstMatch(text);
    if (languageMatch != null) {
      final raw = languageMatch.group(1)!.toLowerCase();
      final locale = switch (raw) {
        'portugues' || 'portuguese' || 'pt' => 'pt',
        'ingles' || 'english' || 'en' => 'en',
        'espanhol' || 'espanol' || 'spanish' || 'es' => 'es',
        'frances' || 'francais' || 'french' || 'fr' => 'fr',
        _ => 'system',
      };
      return CommandAction.withAction(
        action: 'set_language',
        params: {'locale': locale},
        message: '',
      );
    }

    // clear_checked_items (PT/EN/FR/ES)
    final clearMatch = RegExp(
      r'(?:limpa|clear|limpiar|effacer)\s+(?:a\s+|os\s+|los\s+|les\s+)?'
      r'(?:lista|list|checked|itens|marcados|coches|elementos)',
      caseSensitive: false,
    ).firstMatch(text);
    if (clearMatch != null) {
      return CommandAction.withAction(
        action: 'clear_checked_items',
        params: {},
        message: '',
      );
    }

    // navigate_to (PT/EN/FR/ES)
    final navMatch = RegExp(
      r'(?:vai|abre|open|go|ir|navega|abrir|ouvre|ouvrir|aller)\s+'
      r'(?:para?\s+)?(?:as?\s+|os?\s+|o\s+|les?\s+|la\s+|al\s+|los\s+|aux?\s+)?(.+)',
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

  /// Extracts the first balanced JSON object from [text] using brace-depth
  /// counting. Returns null when no balanced object is found.
  static String? extractJsonObject(String text) {
    bool inString = false;
    bool escaped = false;
    int? start;
    int depth = 0;

    for (int i = 0; i < text.length; i++) {
      final c = text[i];

      if (escaped) {
        escaped = false;
        continue;
      }
      if (c == r'\' && inString) {
        escaped = true;
        continue;
      }
      if (c == '"') {
        inString = !inString;
        continue;
      }
      if (inString) continue;

      if (c == '{') {
        if (depth == 0) start = i;
        depth++;
      } else if (c == '}') {
        depth--;
        if (depth == 0 && start != null) {
          return text.substring(start, i + 1);
        }
      }
    }
    return null;
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
        '- show_help: {} (user says help/ajuda/aide/ayuda)\n'
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
