import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/exceptions/app_exceptions.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/models/custom_category.dart';
import 'package:monthly_management/models/monthly_budget.dart';
import 'package:monthly_management/models/recurring_expense.dart';
import 'package:monthly_management/models/shopping_item.dart';
import 'package:monthly_management/repositories/expense_repository.dart';
import 'package:monthly_management/repositories/settings_repository.dart';
import 'package:monthly_management/repositories/shopping_repository.dart';
import 'package:monthly_management/services/actual_expense_service.dart';
import 'package:monthly_management/services/category_service.dart';
import 'package:monthly_management/services/monthly_budget_service.dart';
import 'package:monthly_management/services/recurring_expense_service.dart';
import 'package:monthly_management/services/settings_service.dart';
import 'package:monthly_management/services/shopping_list_service.dart';
import 'package:monthly_management/models/app_settings.dart';

// ---------------------------------------------------------------------------
// In-memory repository implementations
// ---------------------------------------------------------------------------

class _MemExpenseRepo implements ExpenseRepository {
  final List<ActualExpense> _items;
  bool shouldThrow = false;

  _MemExpenseRepo([List<ActualExpense>? items])
      : _items = List<ActualExpense>.from(items ?? []);

  @override
  Future<List<ActualExpense>> loadMonth(String hid, String mk) async {
    if (shouldThrow) throw StateError('load failed');
    return _items.where((e) => e.monthKey == mk).toList();
  }

  @override
  Future<void> add(ActualExpense expense, String hid) async {
    if (shouldThrow) throw StateError('add failed');
    _items.add(expense);
  }

  @override
  Future<void> addAll(List<ActualExpense> expenses, String hid) async {
    _items.addAll(expenses);
  }

  @override
  Future<void> update(ActualExpense expense) async {
    if (shouldThrow) throw StateError('update failed');
    final idx = _items.indexWhere((e) => e.id == expense.id);
    if (idx >= 0) _items[idx] = expense;
  }

  @override
  Future<void> delete(String id) async {
    if (shouldThrow) throw StateError('delete failed');
    _items.removeWhere((e) => e.id == id);
  }

  @override
  Future<Map<String, List<ActualExpense>>> loadHistory(
    String hid, {
    int months = 12,
  }) async {
    if (shouldThrow) throw StateError('history failed');
    final map = <String, List<ActualExpense>>{};
    for (final e in _items) {
      map.putIfAbsent(e.monthKey, () => []).add(e);
    }
    return map;
  }

  @override
  Future<List<String>> uploadAttachments(
    List<File> files, String hid, String eid,
  ) async {
    if (shouldThrow) throw StateError('upload failed');
    return files.map((f) => 'https://store/${f.path}').toList();
  }
}

class _MemBudgetRepo implements BudgetRepository {
  final List<MonthlyBudget> _items = [];
  bool shouldThrow = false;

  @override
  Future<List<MonthlyBudget>> loadMonth(String hid, String mk) async {
    if (shouldThrow) throw StateError('load failed');
    return _items.where((b) => b.monthKey == mk).toList();
  }

  @override
  Future<void> save(MonthlyBudget budget, String hid) async {
    if (shouldThrow) throw StateError('save failed');
    _items.add(budget);
  }

  @override
  Future<void> saveAll(List<MonthlyBudget> budgets, String hid) async {
    if (shouldThrow) throw StateError('saveAll failed');
    _items.addAll(budgets);
  }
}

class _MemRecurringRepo implements RecurringExpenseRepository {
  final List<RecurringExpense> _items;
  final Set<String> _ran;
  bool shouldThrow = false;

  _MemRecurringRepo({
    List<RecurringExpense>? items,
    Set<String>? alreadyRan,
  })  : _items = List.from(items ?? []),
        _ran = Set.from(alreadyRan ?? {});

  @override
  Future<List<RecurringExpense>> load(String hid) async {
    if (shouldThrow) throw StateError('load failed');
    return List.from(_items);
  }

  @override
  Future<void> save(RecurringExpense expense, String hid) async {
    if (shouldThrow) throw StateError('save failed');
    _items.add(expense);
  }

  @override
  Future<void> delete(String id) async {
    if (shouldThrow) throw StateError('delete failed');
    _items.removeWhere((e) => e.id == id);
  }

  @override
  Future<bool> hasRunForMonth(String hid, String mk) async {
    return _ran.contains('$hid|$mk');
  }

  @override
  Future<void> markRunForMonth(String hid, String mk) async {
    _ran.add('$hid|$mk');
  }
}

class _MemShoppingRepo implements ShoppingRepository {
  final List<ShoppingItem> _items = [];
  bool shouldThrow = false;

  @override
  Stream<List<ShoppingItem>> stream(String hid) {
    return Stream.value(List.from(_items));
  }

  @override
  Future<List<ShoppingItem>> load(String hid) async => List.from(_items);

  @override
  Future<ShoppingItem> add(ShoppingItem item, String hid) async {
    if (shouldThrow) throw StateError('add failed');
    _items.add(item);
    return item;
  }

  @override
  Future<void> updateItem(
    String id, {
    required double price,
    double? quantity,
    String? unit,
  }) async {
    if (shouldThrow) throw StateError('update failed');
  }

  @override
  Future<void> toggle(String id, bool checked) async {
    if (shouldThrow) throw StateError('toggle failed');
  }

  @override
  Future<void> remove(String id) async {
    if (shouldThrow) throw StateError('remove failed');
    _items.removeWhere((i) => i.id == id);
  }

  @override
  Future<void> clearChecked(String hid) async {
    if (shouldThrow) throw StateError('clear failed');
    _items.removeWhere((i) => i.checked);
  }
}

class _MemSettingsRepo implements SettingsRepository {
  final List<CustomCategory> _categories = [];
  bool shouldThrow = false;

  @override
  Future<AppSettings> loadSettings(String hid) async => const AppSettings();

  @override
  Future<void> saveSettings(AppSettings settings, String hid) async {}

  @override
  Future<List<CustomCategory>> loadCategories(String hid) async {
    if (shouldThrow) throw StateError('load failed');
    return List.from(_categories);
  }

  @override
  Future<void> saveCategory(CustomCategory category, String hid) async {
    if (shouldThrow) throw StateError('save failed');
    _categories.add(category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    if (shouldThrow) throw StateError('delete failed');
    _categories.removeWhere((c) => c.id == id);
  }

  @override
  Future<List<String>> loadFavorites(String hid) async => [];

  @override
  Future<void> saveFavorites(List<String> favorites, String hid) async {}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ActualExpenseService - extended', () {
    late _MemExpenseRepo repo;
    late ActualExpenseService service;

    setUp(() {
      repo = _MemExpenseRepo([
        ActualExpense(
          id: 'e1', category: 'food', amount: 25,
          date: DateTime(2026, 3, 5), monthKey: '2026-03',
        ),
        ActualExpense(
          id: 'e2', category: 'food', amount: 30,
          date: DateTime(2026, 2, 10), monthKey: '2026-02',
        ),
      ]);
      service = ActualExpenseService(repository: repo);
    });

    test('update delegates to repository', () async {
      final updated = ActualExpense(
        id: 'e1', category: 'food', amount: 50,
        date: DateTime(2026, 3, 5), monthKey: '2026-03',
      );
      await service.update(updated);
      final loaded = await service.loadMonth('hh', '2026-03');
      expect(loaded.first.amount, 50);
    });

    test('update wraps error in DataException', () async {
      repo.shouldThrow = true;
      final exp = ActualExpense(
        id: 'e1', category: 'food', amount: 10,
        date: DateTime(2026, 3, 5), monthKey: '2026-03',
      );
      await expectLater(
        service.update(exp),
        throwsA(isA<DataException>()),
      );
    });

    test('delete removes expense', () async {
      await service.delete('e1');
      final loaded = await service.loadMonth('hh', '2026-03');
      expect(loaded, isEmpty);
    });

    test('delete wraps error in DataException', () async {
      repo.shouldThrow = true;
      await expectLater(
        service.delete('e1'),
        throwsA(isA<DataException>()),
      );
    });

    test('loadHistory returns grouped expenses', () async {
      final history = await service.loadHistory('hh', months: 12);
      expect(history.keys, containsAll(['2026-03', '2026-02']));
      expect(history['2026-03'], hasLength(1));
      expect(history['2026-02'], hasLength(1));
    });

    test('loadHistory wraps error in DataException', () async {
      repo.shouldThrow = true;
      await expectLater(
        service.loadHistory('hh'),
        throwsA(isA<DataException>()),
      );
    });

    test('loadMonth wraps error in DataException', () async {
      repo.shouldThrow = true;
      await expectLater(
        service.loadMonth('hh', '2026-03'),
        throwsA(isA<DataException>()),
      );
    });
  });

  group('MonthlyBudgetService - extended', () {
    late _MemBudgetRepo repo;
    late MonthlyBudgetService service;

    setUp(() {
      repo = _MemBudgetRepo();
      service = MonthlyBudgetService(repository: repo);
    });

    test('loadMonth returns budgets for month', () async {
      await repo.save(
        MonthlyBudget(
          id: 'b1', category: 'food', amount: 300, monthKey: '2026-03',
        ),
        'hh_1',
      );
      final result = await service.loadMonth('hh_1', '2026-03');
      expect(result, hasLength(1));
      expect(result.first.amount, 300);
    });

    test('loadMonth wraps error in DataException', () async {
      repo.shouldThrow = true;
      await expectLater(
        service.loadMonth('hh_1', '2026-03'),
        throwsA(isA<DataException>()),
      );
    });

    test('save wraps error in DataException', () async {
      repo.shouldThrow = true;
      await expectLater(
        service.save(
          MonthlyBudget(id: 'b1', category: 'x', amount: 1, monthKey: '2026-01'),
          'hh_1',
        ),
        throwsA(isA<DataException>()),
      );
    });

    test('saveAll with data saves through repository', () async {
      final budgets = [
        MonthlyBudget(id: 'b1', category: 'food', amount: 300, monthKey: '2026-03'),
        MonthlyBudget(id: 'b2', category: 'rent', amount: 800, monthKey: '2026-03'),
      ];
      await service.saveAll(budgets, 'hh_1');
      final loaded = await service.loadMonth('hh_1', '2026-03');
      expect(loaded, hasLength(2));
    });

    test('saveAll wraps error in DataException', () async {
      repo.shouldThrow = true;
      await expectLater(
        service.saveAll(
          [MonthlyBudget(id: 'b1', category: 'x', amount: 1, monthKey: '2026-01')],
          'hh_1',
        ),
        throwsA(isA<DataException>()),
      );
    });
  });

  group('RecurringExpenseService - extended', () {
    late _MemRecurringRepo recurringRepo;
    late _MemExpenseRepo expenseRepo;
    late RecurringExpenseService service;

    setUp(() {
      recurringRepo = _MemRecurringRepo();
      expenseRepo = _MemExpenseRepo();
      service = RecurringExpenseService(
        recurringRepository: recurringRepo,
        expenseRepository: expenseRepo,
      );
    });

    test('load delegates to repository', () async {
      recurringRepo._items.add(
        RecurringExpense(id: 're_1', category: 'rent', amount: 900),
      );
      final result = await service.load('hh_1');
      expect(result, hasLength(1));
      expect(result.first.category, 'rent');
    });

    test('load wraps error in DataException', () async {
      recurringRepo.shouldThrow = true;
      await expectLater(
        service.load('hh_1'),
        throwsA(isA<DataException>()),
      );
    });

    test('save delegates to repository', () async {
      final expense = RecurringExpense(id: 're_2', category: 'water', amount: 30);
      await service.save(expense, 'hh_1');
      final loaded = await recurringRepo.load('hh_1');
      expect(loaded.any((e) => e.id == 're_2'), true);
    });

    test('save wraps error in DataException', () async {
      recurringRepo.shouldThrow = true;
      await expectLater(
        service.save(
          RecurringExpense(id: 're_1', category: 'x', amount: 10),
          'hh_1',
        ),
        throwsA(isA<DataException>()),
      );
    });

    test('delete delegates to repository', () async {
      recurringRepo._items.add(
        RecurringExpense(id: 're_del', category: 'x', amount: 10),
      );
      await service.delete('re_del');
      final loaded = await recurringRepo.load('hh_1');
      expect(loaded.any((e) => e.id == 're_del'), false);
    });

    test('delete wraps error in DataException', () async {
      recurringRepo.shouldThrow = true;
      await expectLater(
        service.delete('re_1'),
        throwsA(isA<DataException>()),
      );
    });

    test('populateMonthIfNeeded skips inactive expenses', () async {
      recurringRepo._items.addAll([
        RecurringExpense(
          id: 're_active', category: 'rent', amount: 900,
          isActive: true, dayOfMonth: 1,
        ),
        RecurringExpense(
          id: 're_inactive', category: 'gym', amount: 30,
          isActive: false, dayOfMonth: 1,
        ),
      ]);
      final created = await service.populateMonthIfNeeded('hh_1', '2026-03');
      expect(created, hasLength(1));
      expect(created.first.category, 'rent');
    });

    test('populateMonthIfNeeded returns empty when no active', () async {
      recurringRepo._items.add(
        RecurringExpense(
          id: 're_off', category: 'gym', amount: 30,
          isActive: false, dayOfMonth: 1,
        ),
      );
      final created = await service.populateMonthIfNeeded('hh_1', '2026-03');
      expect(created, isEmpty);
    });
  });

  group('ShoppingListService', () {
    late _MemShoppingRepo repo;
    late ShoppingListService service;

    setUp(() {
      repo = _MemShoppingRepo();
      service = ShoppingListService(repository: repo);
    });

    test('stream returns items from repository', () async {
      repo._items.add(
        ShoppingItem(id: 'si_1', productName: 'Milk', store: '', price: 1.29),
      );
      final items = await service.stream('hh_1').first;
      expect(items, hasLength(1));
      expect(items.first.productName, 'Milk');
    });

    test('add returns the added item', () async {
      final item = ShoppingItem(
        productName: 'Bread', store: 'Lidl', price: 0.80,
      );
      final result = await service.add(item, 'hh_1');
      expect(result.productName, 'Bread');
    });

    test('add wraps error in DataException', () async {
      repo.shouldThrow = true;
      await expectLater(
        service.add(
          ShoppingItem(productName: 'x', store: '', price: 0),
          'hh_1',
        ),
        throwsA(isA<DataException>()),
      );
    });

    test('updateItem delegates to repository', () async {
      await service.updateItem('si_1', price: 2.0, quantity: 1.5, unit: 'kg');
      // No exception = success
    });

    test('updateItem wraps error in DataException', () async {
      repo.shouldThrow = true;
      await expectLater(
        service.updateItem('si_1', price: 2.0),
        throwsA(isA<DataException>()),
      );
    });

    test('toggle delegates to repository', () async {
      await service.toggle('si_1', true);
      // No exception = success
    });

    test('toggle wraps error in DataException', () async {
      repo.shouldThrow = true;
      await expectLater(
        service.toggle('si_1', true),
        throwsA(isA<DataException>()),
      );
    });

    test('remove delegates to repository', () async {
      repo._items.add(
        ShoppingItem(id: 'si_rm', productName: 'X', store: '', price: 1),
      );
      await service.remove('si_rm');
      expect(repo._items.any((i) => i.id == 'si_rm'), false);
    });

    test('remove wraps error in DataException', () async {
      repo.shouldThrow = true;
      await expectLater(
        service.remove('si_1'),
        throwsA(isA<DataException>()),
      );
    });

    test('clearChecked delegates to repository', () async {
      repo._items.addAll([
        ShoppingItem(
          id: 'si_1', productName: 'A', store: '', price: 1, checked: true,
        ),
        ShoppingItem(
          id: 'si_2', productName: 'B', store: '', price: 2, checked: false,
        ),
      ]);
      await service.clearChecked('hh_1');
      expect(repo._items, hasLength(1));
      expect(repo._items.first.id, 'si_2');
    });

    test('clearChecked wraps error in DataException', () async {
      repo.shouldThrow = true;
      await expectLater(
        service.clearChecked('hh_1'),
        throwsA(isA<DataException>()),
      );
    });
  });

  group('CategoryService', () {
    late _MemSettingsRepo repo;
    late CategoryService service;

    setUp(() {
      repo = _MemSettingsRepo();
      service = CategoryService(repository: repo);
    });

    test('load returns categories from repository', () async {
      repo._categories.add(
        const CustomCategory(id: 'cat_1', name: 'Food'),
      );
      final result = await service.load('hh_1');
      expect(result, hasLength(1));
      expect(result.first.name, 'Food');
    });

    test('save adds category to repository', () async {
      const cat = CustomCategory(id: 'cat_new', name: 'Drinks');
      await service.save(cat, 'hh_1');
      final loaded = await repo.loadCategories('hh_1');
      expect(loaded.any((c) => c.id == 'cat_new'), true);
    });

    test('delete removes category from repository', () async {
      repo._categories.add(
        const CustomCategory(id: 'cat_del', name: 'Old'),
      );
      await service.delete('cat_del');
      final loaded = await repo.loadCategories('hh_1');
      expect(loaded.any((c) => c.id == 'cat_del'), false);
    });
  });

  group('SettingsService', () {
    late _MemSettingsRepo repo;
    late SettingsService service;

    setUp(() {
      repo = _MemSettingsRepo();
      service = SettingsService(repository: repo);
    });

    test('load returns settings from repository', () async {
      final settings = await service.load('hh_1');
      expect(settings, isA<AppSettings>());
    });

    test('save delegates to repository', () async {
      const settings = AppSettings(
        personalInfo: PersonalInfo(dependentes: 2),
      );
      await service.save(settings, 'hh_1');
      // No exception = success
    });
  });
}
