import 'package:flutter/material.dart';

import '../models/actual_expense.dart';
import '../models/command_action.dart';
import '../theme/app_colors.dart';

class CommandActionRegistry {
  final Future<void> Function(ActualExpense expense) onAddExpense;
  final Future<void> Function(String id) onDeleteExpense;
  final void Function(ThemeMode mode) onSetThemeMode;
  final void Function(AppColorPalette palette) onSetColorPalette;
  final void Function(String screen) onNavigateTo;
  final void Function() onClearCheckedItems;

  CommandActionRegistry({
    required this.onAddExpense,
    required this.onDeleteExpense,
    required this.onSetThemeMode,
    required this.onSetColorPalette,
    required this.onNavigateTo,
    required this.onClearCheckedItems,
  });

  // ── Screen alias map ───────────────────────────────────────────────

  static const _screenAliases = <String, String>{
    'dashboard': 'dashboard',
    'orcamento': 'dashboard',
    'budget': 'dashboard',
    'home': 'dashboard',
    'expenses': 'expenses',
    'despesas': 'expenses',
    'tracker': 'expenses',
    'plan': 'plan',
    'plano': 'plan',
    'more': 'more',
    'mais': 'more',
    'coach': 'coach',
    'assistente': 'coach',
    'grocery': 'grocery',
    'supermercado': 'grocery',
    'shopping_list': 'shopping_list',
    'lista': 'shopping_list',
    'list': 'shopping_list',
    'compras': 'shopping_list',
    'meals': 'meals',
    'refeicoes': 'meals',
    'planner': 'meals',
    'settings': 'settings',
    'definicoes': 'settings',
    'insights': 'insights',
    'tendencias': 'insights',
    'trends': 'insights',
    'savings_goals': 'savings_goals',
    'poupanca': 'savings_goals',
    'goals': 'savings_goals',
    'objetivos': 'savings_goals',
  };

  static const _validCategories = <String>{
    'telecomunicacoes',
    'energia',
    'agua',
    'alimentacao',
    'educacao',
    'habitacao',
    'transportes',
    'saude',
    'lazer',
    'outros',
  };

  static const _validThemeModes = <String, ThemeMode>{
    'light': ThemeMode.light,
    'dark': ThemeMode.dark,
    'system': ThemeMode.system,
  };

  static const _validPalettes = <String, AppColorPalette>{
    'ocean': AppColorPalette.ocean,
    'emerald': AppColorPalette.emerald,
    'violet': AppColorPalette.violet,
    'teal': AppColorPalette.teal,
    'sunset': AppColorPalette.sunset,
  };

  // ── Public API ─────────────────────────────────────────────────────

  static String? resolveScreenAlias(String input) {
    final key = input.toLowerCase().trim();
    return _screenAliases[key];
  }

  bool validate(String action, Map<String, dynamic> params) {
    switch (action) {
      case 'add_expense':
        return _validateAddExpense(params);
      case 'set_theme_mode':
        return _validateSetThemeMode(params);
      case 'set_color_palette':
        return _validateSetColorPalette(params);
      case 'navigate_to':
        return _validateNavigateTo(params);
      case 'clear_checked_items':
        return true;
      default:
        return false;
    }
  }

  Future<CommandResult> execute(
    String action,
    Map<String, dynamic> params,
  ) async {
    if (!validate(action, params)) {
      return CommandResult.failure(
        message: 'Invalid action or parameters: $action',
      );
    }

    switch (action) {
      case 'add_expense':
        return _executeAddExpense(params);
      case 'set_theme_mode':
        return _executeSetThemeMode(params);
      case 'set_color_palette':
        return _executeSetColorPalette(params);
      case 'navigate_to':
        return _executeNavigateTo(params);
      case 'clear_checked_items':
        return _executeClearCheckedItems();
      default:
        return CommandResult.failure(message: 'Unknown action: $action');
    }
  }

  // ── Validation helpers ─────────────────────────────────────────────

  bool _validateAddExpense(Map<String, dynamic> params) {
    final category = params['category'] as String?;
    if (category == null || !_validCategories.contains(category)) return false;

    final parsed = _parseDouble(params['amount']);
    if (parsed == null || parsed <= 0) return false;

    return true;
  }

  bool _validateSetThemeMode(Map<String, dynamic> params) {
    final mode = params['mode'] as String?;
    return mode != null && _validThemeModes.containsKey(mode);
  }

  bool _validateSetColorPalette(Map<String, dynamic> params) {
    final palette = params['palette'] as String?;
    return palette != null && _validPalettes.containsKey(palette);
  }

  bool _validateNavigateTo(Map<String, dynamic> params) {
    final screen = params['screen'] as String?;
    return screen != null && resolveScreenAlias(screen) != null;
  }

  // ── Execution helpers ──────────────────────────────────────────────

  Future<CommandResult> _executeAddExpense(Map<String, dynamic> params) async {
    final category = params['category'] as String;
    final amount = _parseDouble(params['amount'])!;
    final description = params['description'] as String?;

    final expense = ActualExpense.create(
      category: category,
      amount: amount,
      date: DateTime.now(),
      description: description,
    );

    await onAddExpense(expense);

    return CommandResult.success(
      message: 'Expense added: $amount in $category',
      undoAction: () => onDeleteExpense(expense.id),
    );
  }

  Future<CommandResult> _executeSetThemeMode(
    Map<String, dynamic> params,
  ) async {
    final mode = _validThemeModes[params['mode'] as String]!;
    onSetThemeMode(mode);
    return CommandResult.success(message: 'Theme set to ${params['mode']}');
  }

  Future<CommandResult> _executeSetColorPalette(
    Map<String, dynamic> params,
  ) async {
    final palette = _validPalettes[params['palette'] as String]!;
    onSetColorPalette(palette);
    return CommandResult.success(
      message: 'Color palette set to ${params['palette']}',
    );
  }

  Future<CommandResult> _executeNavigateTo(
    Map<String, dynamic> params,
  ) async {
    final canonical = resolveScreenAlias(params['screen'] as String)!;
    onNavigateTo(canonical);
    return CommandResult.success(message: 'Navigated to $canonical');
  }

  Future<CommandResult> _executeClearCheckedItems() async {
    onClearCheckedItems();
    return CommandResult.success(message: 'Checked items cleared');
  }

  // ── Parsing ────────────────────────────────────────────────────────

  static double? _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final normalized = value.replaceAll(',', '.');
      return double.tryParse(normalized);
    }
    return null;
  }
}
