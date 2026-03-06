import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/actual_expense.dart';
import 'package:orcamento_mensal/models/command_action.dart';
import 'package:orcamento_mensal/services/command_action_registry.dart';
import 'package:orcamento_mensal/theme/app_colors.dart';

void main() {
  late CommandActionRegistry registry;
  late List<ActualExpense> addedExpenses;
  late List<String> deletedExpenseIds;
  late List<ThemeMode> themeModes;
  late List<AppColorPalette> palettes;
  late List<String> navigations;
  late int clearCheckedCount;

  setUp(() {
    addedExpenses = [];
    deletedExpenseIds = [];
    themeModes = [];
    palettes = [];
    navigations = [];
    clearCheckedCount = 0;

    registry = CommandActionRegistry(
      onAddExpense: (expense) async => addedExpenses.add(expense),
      onDeleteExpense: (id) async => deletedExpenseIds.add(id),
      onSetThemeMode: (mode) => themeModes.add(mode),
      onSetColorPalette: (palette) => palettes.add(palette),
      onNavigateTo: (screen) => navigations.add(screen),
      onClearCheckedItems: () => clearCheckedCount++,
    );
  });

  group('validate', () {
    test('accepts known action with correct params', () {
      expect(
        registry.validate('add_expense', {
          'category': 'alimentacao',
          'amount': 25.0,
        }),
        isTrue,
      );
    });

    test('rejects unknown action', () {
      expect(registry.validate('do_magic', {}), isFalse);
    });

    test('rejects add_expense with amount <= 0', () {
      expect(
        registry.validate('add_expense', {
          'category': 'alimentacao',
          'amount': 0,
        }),
        isFalse,
      );
      expect(
        registry.validate('add_expense', {
          'category': 'alimentacao',
          'amount': -5,
        }),
        isFalse,
      );
    });

    test('rejects add_expense with unknown category', () {
      expect(
        registry.validate('add_expense', {
          'category': 'viagens',
          'amount': 10.0,
        }),
        isFalse,
      );
    });

    test('accepts add_expense with amount as int', () {
      expect(
        registry.validate('add_expense', {
          'category': 'saude',
          'amount': 50,
        }),
        isTrue,
      );
    });

    test('accepts add_expense with amount as String', () {
      expect(
        registry.validate('add_expense', {
          'category': 'saude',
          'amount': '12,50',
        }),
        isTrue,
      );
    });

    test('rejects add_expense with unparseable amount', () {
      expect(
        registry.validate('add_expense', {
          'category': 'saude',
          'amount': 'abc',
        }),
        isFalse,
      );
    });

    test('validates set_theme_mode with known modes', () {
      expect(registry.validate('set_theme_mode', {'mode': 'light'}), isTrue);
      expect(registry.validate('set_theme_mode', {'mode': 'dark'}), isTrue);
      expect(registry.validate('set_theme_mode', {'mode': 'system'}), isTrue);
    });

    test('rejects set_theme_mode with unknown mode', () {
      expect(registry.validate('set_theme_mode', {'mode': 'auto'}), isFalse);
    });

    test('validates set_color_palette with known palettes', () {
      expect(
        registry.validate('set_color_palette', {'palette': 'ocean'}),
        isTrue,
      );
      expect(
        registry.validate('set_color_palette', {'palette': 'sunset'}),
        isTrue,
      );
    });

    test('rejects set_color_palette with unknown palette', () {
      expect(
        registry.validate('set_color_palette', {'palette': 'rainbow'}),
        isFalse,
      );
    });

    test('validates navigate_to with known screen', () {
      expect(
        registry.validate('navigate_to', {'screen': 'dashboard'}),
        isTrue,
      );
    });

    test('validates navigate_to with alias', () {
      expect(
        registry.validate('navigate_to', {'screen': 'despesas'}),
        isTrue,
      );
    });

    test('rejects navigate_to with unknown screen', () {
      expect(
        registry.validate('navigate_to', {'screen': 'unknown_page'}),
        isFalse,
      );
    });

    test('clear_checked_items is always valid', () {
      expect(registry.validate('clear_checked_items', {}), isTrue);
    });
  });

  group('execute', () {
    test('add_expense creates correct ActualExpense and calls callback', () async {
      final result = await registry.execute('add_expense', {
        'category': 'alimentacao',
        'amount': 42.5,
        'description': 'Groceries',
      });

      expect(result.succeeded, isTrue);
      expect(addedExpenses, hasLength(1));
      final expense = addedExpenses.first;
      expect(expense.category, 'alimentacao');
      expect(expense.amount, 42.5);
      expect(expense.description, 'Groceries');
      expect(expense.date.day, DateTime.now().day);
    });

    test('add_expense returns undo action that deletes expense', () async {
      final result = await registry.execute('add_expense', {
        'category': 'transportes',
        'amount': 10,
      });

      expect(result.undoAction, isNotNull);
      await result.undoAction!();
      expect(deletedExpenseIds, hasLength(1));
      expect(deletedExpenseIds.first, addedExpenses.first.id);
    });

    test('add_expense handles String amount with comma', () async {
      final result = await registry.execute('add_expense', {
        'category': 'energia',
        'amount': '15,99',
      });

      expect(result.succeeded, isTrue);
      expect(addedExpenses.first.amount, 15.99);
    });

    test('returns failure for invalid params', () async {
      final result = await registry.execute('add_expense', {
        'category': 'alimentacao',
        'amount': -1,
      });

      expect(result.succeeded, isFalse);
      expect(addedExpenses, isEmpty);
    });

    test('returns failure for unknown action', () async {
      final result = await registry.execute('fly_to_moon', {});

      expect(result.succeeded, isFalse);
    });

    test('set_theme_mode calls callback with correct ThemeMode', () async {
      await registry.execute('set_theme_mode', {'mode': 'dark'});
      expect(themeModes, [ThemeMode.dark]);

      await registry.execute('set_theme_mode', {'mode': 'light'});
      expect(themeModes, [ThemeMode.dark, ThemeMode.light]);

      await registry.execute('set_theme_mode', {'mode': 'system'});
      expect(themeModes, [ThemeMode.dark, ThemeMode.light, ThemeMode.system]);
    });

    test('set_color_palette calls callback with correct palette', () async {
      await registry.execute('set_color_palette', {'palette': 'emerald'});
      expect(palettes, [AppColorPalette.emerald]);
    });

    test('navigate_to resolves alias and calls callback', () async {
      await registry.execute('navigate_to', {'screen': 'despesas'});
      expect(navigations, ['expenses']);
    });

    test('navigate_to uses canonical name directly', () async {
      await registry.execute('navigate_to', {'screen': 'settings'});
      expect(navigations, ['settings']);
    });

    test('clear_checked_items calls callback', () async {
      final result = await registry.execute('clear_checked_items', {});
      expect(result.succeeded, isTrue);
      expect(clearCheckedCount, 1);
    });
  });

  group('resolveScreenAlias', () {
    test('maps known aliases to canonical names', () {
      expect(CommandActionRegistry.resolveScreenAlias('orcamento'), 'dashboard');
      expect(CommandActionRegistry.resolveScreenAlias('budget'), 'dashboard');
      expect(CommandActionRegistry.resolveScreenAlias('home'), 'dashboard');
      expect(CommandActionRegistry.resolveScreenAlias('despesas'), 'expenses');
      expect(CommandActionRegistry.resolveScreenAlias('tracker'), 'expenses');
      expect(CommandActionRegistry.resolveScreenAlias('plano'), 'plan');
      expect(CommandActionRegistry.resolveScreenAlias('mais'), 'more');
      expect(CommandActionRegistry.resolveScreenAlias('assistente'), 'coach');
      expect(CommandActionRegistry.resolveScreenAlias('supermercado'), 'grocery');
      expect(CommandActionRegistry.resolveScreenAlias('lista'), 'shopping_list');
      expect(CommandActionRegistry.resolveScreenAlias('compras'), 'shopping_list');
      expect(CommandActionRegistry.resolveScreenAlias('refeicoes'), 'meals');
      expect(CommandActionRegistry.resolveScreenAlias('planner'), 'meals');
      expect(CommandActionRegistry.resolveScreenAlias('definicoes'), 'settings');
      expect(CommandActionRegistry.resolveScreenAlias('tendencias'), 'insights');
      expect(CommandActionRegistry.resolveScreenAlias('trends'), 'insights');
      expect(CommandActionRegistry.resolveScreenAlias('poupanca'), 'savings_goals');
      expect(CommandActionRegistry.resolveScreenAlias('goals'), 'savings_goals');
      expect(CommandActionRegistry.resolveScreenAlias('objetivos'), 'savings_goals');
    });

    test('maps canonical names to themselves', () {
      expect(CommandActionRegistry.resolveScreenAlias('dashboard'), 'dashboard');
      expect(CommandActionRegistry.resolveScreenAlias('expenses'), 'expenses');
      expect(CommandActionRegistry.resolveScreenAlias('settings'), 'settings');
      expect(CommandActionRegistry.resolveScreenAlias('meals'), 'meals');
    });

    test('returns null for unknown screen', () {
      expect(CommandActionRegistry.resolveScreenAlias('unknown_page'), isNull);
      expect(CommandActionRegistry.resolveScreenAlias(''), isNull);
    });
  });
}
