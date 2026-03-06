import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;

import '../l10n/generated/app_localizations.dart';
import '../models/actual_expense.dart';
import '../models/command_action.dart';
import '../models/recurring_expense.dart';
import '../models/savings_goal.dart';
import '../models/shopping_item.dart';
import '../theme/app_colors.dart';
import 'package:uuid/uuid.dart';

S _l10n() {
  final code = intl.Intl.getCurrentLocale().split('_').first;
  return lookupS(Locale(code));
}

class CommandActionRegistry {
  final Future<void> Function(ActualExpense expense) onAddExpense;
  final Future<void> Function(ShoppingItem item) onAddShoppingItem;
  final Future<void> Function(SavingsGoal goal) onAddSavingsGoal;
  final Future<void> Function(RecurringExpense expense) onAddRecurringExpense;
  final Future<bool> Function(String itemName) onRemoveShoppingItemByName;
  final Future<bool> Function(String itemName, bool checked)
      onToggleShoppingItemCheckedByName;
  final Future<bool> Function(String goalName, double amount)
      onAddSavingsContributionByGoalName;
  final Future<bool> Function(String description, {String? category})
      onDeleteExpenseByDescription;
  final Future<void> Function(String id) onDeleteExpense;
  final void Function(ThemeMode mode) onSetThemeMode;
  final void Function(AppColorPalette palette) onSetColorPalette;
  final void Function(String? localeCode) onSetLanguage;
  final void Function(String screen) onNavigateTo;
  final void Function() onClearCheckedItems;

  CommandActionRegistry({
    required this.onAddExpense,
    required this.onAddShoppingItem,
    required this.onAddSavingsGoal,
    required this.onAddRecurringExpense,
    required this.onRemoveShoppingItemByName,
    required this.onToggleShoppingItemCheckedByName,
    required this.onAddSavingsContributionByGoalName,
    required this.onDeleteExpenseByDescription,
    required this.onDeleteExpense,
    required this.onSetThemeMode,
    required this.onSetColorPalette,
    required this.onSetLanguage,
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

  static const _validLanguages = <String>{
    'system',
    'pt',
    'en',
    'es',
    'fr',
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
      case 'add_shopping_item':
        return _validateAddShoppingItem(params);
      case 'add_savings_goal':
        return _validateAddSavingsGoal(params);
      case 'add_recurring_expense':
        return _validateAddRecurringExpense(params);
      case 'remove_shopping_item':
        return _validateRemoveShoppingItem(params);
      case 'add_savings_contribution':
        return _validateAddSavingsContribution(params);
      case 'toggle_shopping_item_checked':
        return _validateToggleShoppingItemChecked(params);
      case 'delete_expense':
        return _validateDeleteExpense(params);
      case 'set_theme_mode':
        return _validateSetThemeMode(params);
      case 'set_color_palette':
        return _validateSetColorPalette(params);
      case 'set_language':
        return _validateSetLanguage(params);
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
        message: _l10n().cmdInvalidAction(action),
      );
    }

    switch (action) {
      case 'add_expense':
        return _executeAddExpense(params);
      case 'add_shopping_item':
        return _executeAddShoppingItem(params);
      case 'add_savings_goal':
        return _executeAddSavingsGoal(params);
      case 'add_recurring_expense':
        return _executeAddRecurringExpense(params);
      case 'remove_shopping_item':
        return _executeRemoveShoppingItem(params);
      case 'add_savings_contribution':
        return _executeAddSavingsContribution(params);
      case 'toggle_shopping_item_checked':
        return _executeToggleShoppingItemChecked(params);
      case 'delete_expense':
        return _executeDeleteExpense(params);
      case 'set_theme_mode':
        return _executeSetThemeMode(params);
      case 'set_color_palette':
        return _executeSetColorPalette(params);
      case 'set_language':
        return _executeSetLanguage(params);
      case 'navigate_to':
        return _executeNavigateTo(params);
      case 'clear_checked_items':
        return _executeClearCheckedItems();
      default:
        return CommandResult.failure(message: _l10n().cmdUnknownAction(action));
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

  bool _validateAddShoppingItem(Map<String, dynamic> params) {
    final name = params['name'] as String?;
    return name != null && name.trim().isNotEmpty;
  }

  bool _validateAddSavingsGoal(Map<String, dynamic> params) {
    final name = params['name'] as String?;
    final targetAmount = _parseDouble(params['target_amount']);
    return name != null &&
        name.trim().isNotEmpty &&
        targetAmount != null &&
        targetAmount > 0;
  }

  bool _validateAddRecurringExpense(Map<String, dynamic> params) {
    final category = params['category'] as String?;
    final amount = _parseDouble(params['amount']);
    final day = params['day_of_month'];
    final parsedDay = day is int
        ? day
        : day is String
            ? int.tryParse(day)
            : null;
    if (category == null || !_validCategories.contains(category)) return false;
    if (amount == null || amount <= 0) return false;
    if (parsedDay != null && (parsedDay < 1 || parsedDay > 31)) return false;
    return true;
  }

  bool _validateRemoveShoppingItem(Map<String, dynamic> params) {
    final name = params['name'] as String?;
    return name != null && name.trim().isNotEmpty;
  }

  bool _validateAddSavingsContribution(Map<String, dynamic> params) {
    final goalName = params['goal_name'] as String?;
    final amount = _parseDouble(params['amount']);
    return goalName != null &&
        goalName.trim().isNotEmpty &&
        amount != null &&
        amount > 0;
  }

  bool _validateToggleShoppingItemChecked(Map<String, dynamic> params) {
    final name = params['name'] as String?;
    final checked = params['checked'];
    return name != null &&
        name.trim().isNotEmpty &&
        checked is bool;
  }

  bool _validateDeleteExpense(Map<String, dynamic> params) {
    final description = params['description'] as String?;
    final category = params['category'] as String?;
    if (description == null || description.trim().isEmpty) return false;
    if (category != null && !_validCategories.contains(category)) return false;
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

  bool _validateSetLanguage(Map<String, dynamic> params) {
    final locale = params['locale'] as String?;
    return locale != null && _validLanguages.contains(locale);
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
      message: _l10n().cmdExpenseAdded(
        '$amount',
        _localizedCategory(category),
      ),
      undoAction: () => onDeleteExpense(expense.id),
    );
  }

  Future<CommandResult> _executeAddShoppingItem(
    Map<String, dynamic> params,
  ) async {
    final name = (params['name'] as String).trim();
    final item = ShoppingItem(
      productName: name,
      store: params['store'] as String? ?? '',
      price: _parseDouble(params['price']) ?? 0,
      unitPrice: params['unitPrice'] as String?,
    );
    await onAddShoppingItem(item);
    return CommandResult.success(message: _l10n().cmdShoppingAdded(name));
  }

  Future<CommandResult> _executeAddSavingsGoal(
    Map<String, dynamic> params,
  ) async {
    final name = (params['name'] as String).trim();
    final goal = SavingsGoal(
      id: const Uuid().v4(),
      name: name,
      targetAmount: _parseDouble(params['target_amount'])!,
    );
    await onAddSavingsGoal(goal);
    return CommandResult.success(message: _l10n().cmdSavingsGoalAdded(name));
  }

  Future<CommandResult> _executeAddRecurringExpense(
    Map<String, dynamic> params,
  ) async {
    final day = params['day_of_month'];
    final parsedDay = day is int
        ? day
        : day is String
            ? int.tryParse(day)
            : null;
    final expense = RecurringExpense(
      id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
      category: params['category'] as String,
      amount: _parseDouble(params['amount'])!,
      description: params['description'] as String?,
      dayOfMonth: parsedDay,
      isActive: true,
    );
    await onAddRecurringExpense(expense);
    return CommandResult.success(
      message: _l10n().cmdRecurringExpenseAdded(
        '${expense.amount}',
        _localizedCategory(expense.category),
      ),
    );
  }

  Future<CommandResult> _executeRemoveShoppingItem(
    Map<String, dynamic> params,
  ) async {
    final name = (params['name'] as String).trim();
    final removed = await onRemoveShoppingItemByName(name);
    if (!removed) {
      return CommandResult.failure(
        message: _l10n().cmdShoppingNotFound(name),
      );
    }
    return CommandResult.success(message: _l10n().cmdShoppingRemoved(name));
  }

  Future<CommandResult> _executeAddSavingsContribution(
    Map<String, dynamic> params,
  ) async {
    final goalName = (params['goal_name'] as String).trim();
    final amount = _parseDouble(params['amount'])!;
    final applied = await onAddSavingsContributionByGoalName(goalName, amount);
    if (!applied) {
      return CommandResult.failure(
        message: _l10n().cmdSavingsGoalNotFound(goalName),
      );
    }
    return CommandResult.success(
      message: _l10n().cmdContributionAdded('$amount', goalName),
    );
  }

  Future<CommandResult> _executeToggleShoppingItemChecked(
    Map<String, dynamic> params,
  ) async {
    final name = (params['name'] as String).trim();
    final checked = params['checked'] as bool;
    final updated = await onToggleShoppingItemCheckedByName(name, checked);
    if (!updated) {
      return CommandResult.failure(
        message: _l10n().cmdShoppingNotFound(name),
      );
    }
    return CommandResult.success(
      message: checked
          ? _l10n().cmdShoppingChecked(name)
          : _l10n().cmdShoppingUnchecked(name),
    );
  }

  Future<CommandResult> _executeDeleteExpense(
    Map<String, dynamic> params,
  ) async {
    final description = (params['description'] as String).trim();
    final category = params['category'] as String?;
    final deleted = await onDeleteExpenseByDescription(
      description,
      category: category,
    );
    if (!deleted) {
      return CommandResult.failure(
        message: _l10n().cmdExpenseNotFound(description),
      );
    }
    return CommandResult.success(message: _l10n().cmdExpenseDeleted(description));
  }

  Future<CommandResult> _executeSetThemeMode(
    Map<String, dynamic> params,
  ) async {
    final mode = _validThemeModes[params['mode'] as String]!;
    onSetThemeMode(mode);
    return CommandResult.success(
      message: _l10n().cmdThemeSet(params['mode'] as String),
    );
  }

  Future<CommandResult> _executeSetColorPalette(
    Map<String, dynamic> params,
  ) async {
    final palette = _validPalettes[params['palette'] as String]!;
    onSetColorPalette(palette);
    return CommandResult.success(
      message: _l10n().cmdPaletteSet(params['palette'] as String),
    );
  }

  Future<CommandResult> _executeSetLanguage(
    Map<String, dynamic> params,
  ) async {
    final locale = params['locale'] as String;
    onSetLanguage(locale == 'system' ? null : locale);
    return CommandResult.success(message: _l10n().cmdLanguageSet(locale));
  }

  Future<CommandResult> _executeNavigateTo(
    Map<String, dynamic> params,
  ) async {
    final canonical = resolveScreenAlias(params['screen'] as String)!;
    onNavigateTo(canonical);
    return CommandResult.success(message: _l10n().cmdNavigatedTo(canonical));
  }

  Future<CommandResult> _executeClearCheckedItems() async {
    onClearCheckedItems();
    return CommandResult.success(message: _l10n().cmdCheckedItemsCleared);
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

  String _localizedCategory(String category) {
    switch (category) {
      case 'telecomunicacoes':
        return _l10n().enumCatTelecomunicacoes;
      case 'energia':
        return _l10n().enumCatEnergia;
      case 'agua':
        return _l10n().enumCatAgua;
      case 'alimentacao':
        return _l10n().enumCatAlimentacao;
      case 'educacao':
        return _l10n().enumCatEducacao;
      case 'habitacao':
        return _l10n().enumCatHabitacao;
      case 'transportes':
        return _l10n().enumCatTransportes;
      case 'saude':
        return _l10n().enumCatSaude;
      case 'lazer':
        return _l10n().enumCatLazer;
      default:
        return _l10n().enumCatOutros;
    }
  }
}
