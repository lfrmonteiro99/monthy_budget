import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/actual_expense.dart';
import '../models/command_action.dart';
import '../models/recurring_expense.dart';
import '../models/savings_goal.dart';
import '../models/shopping_item.dart';
import '../theme/app_colors.dart';

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

  // -- Screen alias map ---------------------------------------------------

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
    'ajustes': 'settings',
    'parametres': 'settings',
    'reglages': 'settings',
    'configuracion': 'settings',
    'insights': 'insights',
    'tendencias': 'insights',
    'trends': 'insights',
    'tendances': 'insights',
    'savings_goals': 'savings_goals',
    'poupanca': 'savings_goals',
    'goals': 'savings_goals',
    'objetivos': 'savings_goals',
    'ahorro': 'savings_goals',
    'epargne': 'savings_goals',
    'repas': 'meals',
    'comidas': 'meals',
    'courses': 'shopping_list',
    'gastos': 'expenses',
    'depenses': 'expenses',
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
    'calm': AppColorPalette.calm,
  };

  static const _validLanguages = <String>{
    'system',
    'pt',
    'en',
    'es',
    'fr',
  };

  // -- Public API ---------------------------------------------------------

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
      case 'show_help':
        return true;
      default:
        return false;
    }
  }

  Future<CommandResult> execute(
    String action,
    Map<String, dynamic> params, {
    S? l10n,
  }) async {
    if (!validate(action, params)) {
      return CommandResult.failure(
        message: l10n?.cmdInvalidAction(action) ??
            'Invalid action or parameters: $action',
      );
    }

    switch (action) {
      case 'add_expense':
        return _executeAddExpense(params, l10n);
      case 'add_shopping_item':
        return _executeAddShoppingItem(params, l10n);
      case 'add_savings_goal':
        return _executeAddSavingsGoal(params, l10n);
      case 'add_recurring_expense':
        return _executeAddRecurringExpense(params, l10n);
      case 'remove_shopping_item':
        return _executeRemoveShoppingItem(params, l10n);
      case 'add_savings_contribution':
        return _executeAddSavingsContribution(params, l10n);
      case 'toggle_shopping_item_checked':
        return _executeToggleShoppingItemChecked(params, l10n);
      case 'delete_expense':
        return _executeDeleteExpense(params, l10n);
      case 'set_theme_mode':
        return _executeSetThemeMode(params, l10n);
      case 'set_color_palette':
        return _executeSetColorPalette(params, l10n);
      case 'set_language':
        return _executeSetLanguage(params, l10n);
      case 'navigate_to':
        return _executeNavigateTo(params, l10n);
      case 'clear_checked_items':
        return _executeClearCheckedItems(l10n);
      case 'show_help':
        return _executeShowHelp(l10n);
      default:
        return CommandResult.failure(
          message: l10n?.cmdUnknownAction(action) ??
              'Unknown action: $action',
        );
    }
  }

  // -- Validation helpers -------------------------------------------------

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
    return name != null && name.trim().isNotEmpty && checked is bool;
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

  // -- Execution helpers --------------------------------------------------

  Future<CommandResult> _executeAddExpense(Map<String, dynamic> params, S? l10n) async {
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
      message: l10n?.cmdExpenseAdded('$amount', category) ??
          'Expense added: $amount in $category',
      undoAction: () => onDeleteExpense(expense.id),
    );
  }

  Future<CommandResult> _executeAddShoppingItem(Map<String, dynamic> params, S? l10n) async {
    final name = (params['name'] as String).trim();
    final item = ShoppingItem(
      productName: name,
      store: params['store'] as String? ?? '',
      price: _parseDouble(params['price']) ?? 0,
      unitPrice: params['unitPrice'] as String?,
    );
    await onAddShoppingItem(item);
    return CommandResult.success(
      message: l10n?.cmdShoppingItemAdded(name) ?? 'Shopping item added: $name',
    );
  }

  Future<CommandResult> _executeAddSavingsGoal(Map<String, dynamic> params, S? l10n) async {
    final name = (params['name'] as String).trim();
    final goal = SavingsGoal(
      id: const Uuid().v4(),
      name: name,
      targetAmount: _parseDouble(params['target_amount'])!,
    );
    await onAddSavingsGoal(goal);
    return CommandResult.success(
      message: l10n?.cmdSavingsGoalAdded(name) ?? 'Savings goal added: $name',
    );
  }

  Future<CommandResult> _executeAddRecurringExpense(Map<String, dynamic> params, S? l10n) async {
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
      message: l10n?.cmdRecurringExpenseAdded('${expense.amount}', expense.category) ??
          'Recurring expense added: ${expense.amount} in ${expense.category}',
    );
  }

  Future<CommandResult> _executeRemoveShoppingItem(Map<String, dynamic> params, S? l10n) async {
    final name = (params['name'] as String).trim();
    final removed = await onRemoveShoppingItemByName(name);
    if (!removed) {
      return CommandResult.failure(
        message: l10n?.cmdShoppingItemNotFound(name) ?? 'Could not find shopping item: $name',
      );
    }
    return CommandResult.success(
      message: l10n?.cmdShoppingItemRemoved(name) ?? 'Shopping item removed: $name',
    );
  }

  Future<CommandResult> _executeAddSavingsContribution(Map<String, dynamic> params, S? l10n) async {
    final goalName = (params['goal_name'] as String).trim();
    final amount = _parseDouble(params['amount'])!;
    final applied = await onAddSavingsContributionByGoalName(goalName, amount);
    if (!applied) {
      return CommandResult.failure(
        message: l10n?.cmdSavingsGoalNotFound(goalName) ?? 'Could not find savings goal: $goalName',
      );
    }
    return CommandResult.success(
      message: l10n?.cmdContributionAdded('$amount', goalName) ??
          'Contribution added: $amount to $goalName',
    );
  }

  Future<CommandResult> _executeToggleShoppingItemChecked(Map<String, dynamic> params, S? l10n) async {
    final name = (params['name'] as String).trim();
    final checked = params['checked'] as bool;
    final updated = await onToggleShoppingItemCheckedByName(name, checked);
    if (!updated) {
      return CommandResult.failure(
        message: l10n?.cmdShoppingItemNotFound(name) ?? 'Could not find shopping item: $name',
      );
    }
    return CommandResult.success(
      message: checked
          ? (l10n?.cmdShoppingItemChecked(name) ?? 'Shopping item checked: $name')
          : (l10n?.cmdShoppingItemUnchecked(name) ?? 'Shopping item unchecked: $name'),
    );
  }

  Future<CommandResult> _executeDeleteExpense(Map<String, dynamic> params, S? l10n) async {
    final description = (params['description'] as String).trim();
    final category = params['category'] as String?;
    final deleted = await onDeleteExpenseByDescription(description, category: category);
    if (!deleted) {
      return CommandResult.failure(
        message: l10n?.cmdExpenseNotFound(description) ?? 'Could not find expense: $description',
      );
    }
    return CommandResult.success(
      message: l10n?.cmdExpenseDeleted(description) ?? 'Expense deleted: $description',
    );
  }

  Future<CommandResult> _executeSetThemeMode(Map<String, dynamic> params, S? l10n) async {
    final modeStr = params['mode'] as String;
    final mode = _validThemeModes[modeStr]!;
    onSetThemeMode(mode);
    return CommandResult.success(
      message: l10n?.cmdThemeSet(modeStr) ?? 'Theme set to $modeStr',
    );
  }

  Future<CommandResult> _executeSetColorPalette(Map<String, dynamic> params, S? l10n) async {
    final paletteStr = params['palette'] as String;
    final palette = _validPalettes[paletteStr]!;
    onSetColorPalette(palette);
    return CommandResult.success(
      message: l10n?.cmdPaletteSet(paletteStr) ?? 'Color palette set to $paletteStr',
    );
  }

  Future<CommandResult> _executeSetLanguage(Map<String, dynamic> params, S? l10n) async {
    final locale = params['locale'] as String;
    onSetLanguage(locale == 'system' ? null : locale);
    return CommandResult.success(
      message: l10n?.cmdLanguageSet(locale) ?? 'Language set to $locale',
    );
  }

  Future<CommandResult> _executeNavigateTo(Map<String, dynamic> params, S? l10n) async {
    final canonical = resolveScreenAlias(params['screen'] as String)!;
    onNavigateTo(canonical);
    return CommandResult.success(
      message: l10n?.cmdNavigatedTo(canonical) ?? 'Navigated to $canonical',
    );
  }

  Future<CommandResult> _executeClearCheckedItems(S? l10n) async {
    onClearCheckedItems();
    return CommandResult.success(
      message: l10n?.cmdCheckedItemsCleared ?? 'Checked items cleared',
    );
  }

  Future<CommandResult> _executeShowHelp(S? l10n) async {
    final message = l10n?.cmdHelpOutput ?? _defaultHelpOutput;
    return CommandResult.success(message: message);
  }

  static const _defaultHelpOutput =
      'Available commands:\n'
      '- Add expense: add [amount] in [category]\n'
      '- Add to shopping list: add [item] to shopping list\n'
      '- Remove from shopping list: remove [item] from shopping list\n'
      '- Check/uncheck item: check [item] on shopping list\n'
      '- Create savings goal: create savings goal [name] with [amount]\n'
      '- Add to goal: add [amount] to goal [name]\n'
      '- Recurring expense: add recurring expense [amount] in [category]\n'
      '- Delete expense: delete expense [description]\n'
      '- Theme: theme [light/dark/system]\n'
      '- Palette: color [calm]\n'
      '- Language: language [english/portuguese/spanish/french]\n'
      '- Navigate: open [screen]\n'
      '- Clear checked: clear checked\n'
      '- Help: help';

  // -- Parsing ------------------------------------------------------------

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
