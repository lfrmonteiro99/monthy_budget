import 'dart:convert';

import '../../data/tax/tax_system.dart';
import '../../models/app_settings.dart';
import '../../models/custom_category.dart';
import '../../models/household_activity_event.dart';
import '../../models/meal_settings.dart';
import '../../models/monthly_budget.dart';
import '../../models/product.dart';
import '../../models/recurring_expense.dart';
import '../../models/savings_goal.dart';
import '../local/qa_local_store.dart';
import 'qa_collections.dart';

/// Writes the fixed QA dataset into [QaLocalStore].
///
/// Every date is derived from a single injected `now`, and every id is a
/// literal, so two pipeline runs against the same clock produce byte-identical
/// rows — the testers compare layout and totals against these numbers.
///
/// Covers, by design: three months of budgets + expenses (so trend and yearly
/// views have history), one deliberately over-budget category (alert states),
/// savings goals in on-track / behind / completed states, a partially checked
/// shopping list, and personal-info fields the tax simulator needs.
class QaSeed {
  QaSeed({
    required QaLocalStore store,
    required String householdId,
    required String userId,
    required String userEmail,
    required DateTime now,
  }) : _store = store,
       _householdId = householdId,
       _userId = userId,
       _userEmail = userEmail,
       _now = now;

  final QaLocalStore _store;
  final String _householdId;
  final String _userId;
  final String _userEmail;
  final DateTime _now;

  /// Pseudo-household the globally-scoped collections (products, merchants)
  /// live under.
  static const globalScope = 'qa-global';

  static const householdName = 'Casa QA';
  static const inviteCode = 'QATEST';
  static const seedVersion = 3;

  /// Number of `actual_expenses` rows the seed writes. Asserted by tests so a
  /// change to the dataset is a deliberate act, not a silent drift.
  static int get expectedExpenseCount => _expenseSpecs.length;
  static int get expectedSavingsGoalCount => 3;
  static int get expectedRecurringCount => 4;
  static int get expectedShoppingItemCount => 6;

  DateTime get _currentMonth => DateTime(_now.year, _now.month);
  DateTime get _priorMonth => DateTime(_now.year, _now.month - 1);
  DateTime get _twoMonthsAgo => DateTime(_now.year, _now.month - 2);

  List<DateTime> get _months => [_twoMonthsAgo, _priorMonth, _currentMonth];

  static String _monthKey(DateTime month) =>
      '${month.year}-${month.month.toString().padLeft(2, '0')}';

  /// Clamps [day] into [month] so a 31st never rolls into the next month.
  DateTime _dayIn(DateTime month, int day) {
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    return DateTime(month.year, month.month, day.clamp(1, lastDay));
  }

  /// Runs the seed unless the marker row already records this [seedVersion].
  /// Returns true when rows were written.
  Future<bool> runIfNeeded() async {
    final marker = await _store.get(
      QaCollections.seedMarker,
      _householdId,
      'marker',
    );
    if (marker != null && marker['version'] == seedVersion) return false;

    await _seedHouseholdAndProfile();
    await _seedSettings();
    await _seedCategoriesAndFavorites();
    await _seedBudgets();
    await _seedExpenses();
    await _seedRecurringExpenses();
    await _seedExpenseSnapshots();
    await _seedSavings();
    await _seedShoppingList();
    await _seedPurchaseHistory();
    await _seedCoachInsights();
    await _seedActivityEvents();
    await _seedProductsAndMerchants();

    await _store.put(QaCollections.seedMarker, _householdId, 'marker', {
      'version': seedVersion,
      'seeded_at': _now.toIso8601String(),
    });
    return true;
  }

  // ---------------------------------------------------------------------------
  // Identity
  // ---------------------------------------------------------------------------

  Future<void> _seedHouseholdAndProfile() async {
    await _store.put(QaCollections.households, _householdId, _householdId, {
      'id': _householdId,
      'name': householdName,
      'created_at': _twoMonthsAgo.toIso8601String(),
    });

    // Shape matches the Supabase `profiles` select with the joined household
    // name, which HouseholdService.getProfile() unwraps.
    await _store.put(QaCollections.profiles, _householdId, _userId, {
      'id': _userId,
      'email': _userEmail,
      'household_id': _householdId,
      'role': 'admin',
      'created_at': _twoMonthsAgo.toIso8601String(),
      'households': {'name': householdName},
    });
    await _store.put(QaCollections.profiles, _householdId, 'qa-user-0002', {
      'id': 'qa-user-0002',
      'email': 'qa.partner@example.com',
      'household_id': _householdId,
      'role': 'member',
      'created_at': _priorMonth.toIso8601String(),
      'households': {'name': householdName},
    });

    await _store.put(
      QaCollections.householdInvites,
      _householdId,
      inviteCode,
      {
        'household_id': _householdId,
        'code': inviteCode,
        'created_by': _userId,
        'created_at': _twoMonthsAgo.toIso8601String(),
        'expires_at': _now.add(const Duration(days: 30)).toIso8601String(),
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Settings — salaries, fixed expenses, personal info (tax simulator inputs)
  // ---------------------------------------------------------------------------

  Future<void> _seedSettings() async {
    const settings = AppSettings(
      personalInfo: PersonalInfo(
        maritalStatus: MaritalStatus.casado,
        dependentes: 2,
      ),
      salaries: [
        SalaryInfo(
          label: 'Vencimento 1',
          grossAmount: 2400,
          enabled: true,
          titulares: 2,
          mealAllowanceType: MealAllowanceType.card,
          mealAllowancePerDay: 8.5,
          subsidyMode: SubsidyMode.full,
        ),
        SalaryInfo(
          label: 'Vencimento 2',
          grossAmount: 1450,
          enabled: true,
          titulares: 2,
          mealAllowanceType: MealAllowanceType.cash,
          mealAllowancePerDay: 6,
        ),
      ],
      expenses: [
        ExpenseItem(
          id: 'qa-exp-telecom',
          label: 'Fibra + Móveis',
          amount: 62.9,
          category: 'telecomunicacoes',
        ),
        ExpenseItem(
          id: 'qa-exp-energia',
          label: 'Eletricidade',
          amount: 94.4,
          category: 'energia',
        ),
        ExpenseItem(
          id: 'qa-exp-agua',
          label: 'Água',
          amount: 31.2,
          category: 'agua',
        ),
        ExpenseItem(
          id: 'qa-exp-alimentacao',
          label: 'Supermercado',
          amount: 520,
          category: 'alimentacao',
          isFixed: false,
          rolloverEnabled: true,
        ),
        ExpenseItem(
          id: 'qa-exp-habitacao',
          label: 'Crédito habitação',
          amount: 685,
          category: 'habitacao',
        ),
        ExpenseItem(
          id: 'qa-exp-transportes',
          label: 'Combustível + Passes',
          amount: 180,
          category: 'transportes',
          isFixed: false,
        ),
        ExpenseItem(
          id: 'qa-exp-educacao',
          label: 'Creche',
          amount: 240,
          category: 'educacao',
        ),
        ExpenseItem(
          id: 'qa-exp-lazer',
          label: 'Streaming + Ginásio',
          amount: 58,
          category: 'lazer',
          isFixed: false,
        ),
      ],
      incomeSources: [
        IncomeSource(
          id: 'qa-income-rent',
          label: 'Arrendamento T1',
          amount: 450,
          period: IncomePeriod.monthly,
          received: true,
        ),
        IncomeSource(
          id: 'qa-income-freelance',
          label: 'Freelance design',
          amount: 320,
          period: IncomePeriod.oneOff,
        ),
        IncomeSource(
          id: 'qa-income-irs',
          label: 'Reembolso IRS',
          amount: 780,
          period: IncomePeriod.yearly,
        ),
      ],
      mealSettings: MealSettings(householdSize: 4, wizardCompleted: true),
      country: Country.pt,
      setupWizardCompleted: true,
    );

    await _store.put(QaCollections.householdSettings, _householdId, 'settings', {
      'household_id': _householdId,
      'settings_json': settings.toJsonString(),
      'updated_at': _now.toIso8601String(),
    });
  }

  Future<void> _seedCategoriesAndFavorites() async {
    const categories = [
      CustomCategory(
        id: 'qa-cat-animais',
        name: 'Animais',
        iconName: 'pets',
        colorHex: '#8E7CC3',
        sortOrder: 1,
      ),
      CustomCategory(
        id: 'qa-cat-viagens',
        name: 'Viagens',
        iconName: 'flight',
        colorHex: '#4FA3D1',
        sortOrder: 2,
      ),
    ];
    await _store.putAll(QaCollections.customCategories, _householdId, {
      for (final category in categories)
        category.id: category.toSupabase(_householdId),
    });

    await _store.put(
      QaCollections.householdFavorites,
      _householdId,
      'favorites',
      {
        'household_id': _householdId,
        'favorites_json': jsonEncode(const [
          'Leite meio-gordo',
          'Pão de forma',
          'Ovos M',
          'Café moído',
        ]),
        'updated_at': _now.toIso8601String(),
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Budgets — same envelope every month so month-over-month deltas come purely
  // from spending.
  // ---------------------------------------------------------------------------

  static const _budgetEnvelope = <String, double>{
    'telecomunicacoes': 65,
    'energia': 100,
    'agua': 35,
    'alimentacao': 520,
    'educacao': 240,
    'habitacao': 685,
    'transportes': 180,
    'saude': 90,
    'lazer': 120,
    'outros': 80,
  };

  Future<void> _seedBudgets() async {
    for (final month in _months) {
      final monthKey = _monthKey(month);
      final budgets = _budgetEnvelope.entries
          .map(
            (entry) => MonthlyBudget(
              id: 'qa-mb-$monthKey-${entry.key}',
              category: entry.key,
              amount: entry.value,
              monthKey: monthKey,
            ),
          )
          .toList();
      await _store.putAll(QaCollections.monthlyBudgets, _householdId, {
        for (final budget in budgets)
          '${budget.monthKey}|${budget.category}':
              budget.toSupabase(_householdId),
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Actual expenses
  // ---------------------------------------------------------------------------

  /// `(monthOffset, day, category, amount, description)`.
  ///
  /// `monthOffset` 0 = two months ago, 1 = prior month, 2 = current month.
  /// The current month deliberately overspends `alimentacao`
  /// (585.60 vs a 520 budget) and `lazer` (139 vs 120) so the over-budget and
  /// anomaly states render without any interaction.
  static const _expenseSpecs = <(int, int, String, double, String)>[
    // ── two months ago ──
    (0, 3, 'habitacao', 685.0, 'Prestação casa'),
    (0, 5, 'telecomunicacoes', 62.9, 'Fibra + móveis'),
    (0, 8, 'alimentacao', 148.35, 'Compras Continente'),
    (0, 12, 'energia', 91.2, 'Eletricidade'),
    (0, 15, 'transportes', 68.4, 'Combustível'),
    (0, 19, 'alimentacao', 132.7, 'Compras Lidl'),
    (0, 22, 'educacao', 240.0, 'Creche'),
    (0, 26, 'lazer', 41.5, 'Cinema + jantar'),
    (0, 28, 'agua', 29.8, 'Água'),
    // ── prior month ──
    (1, 3, 'habitacao', 685.0, 'Prestação casa'),
    (1, 5, 'telecomunicacoes', 62.9, 'Fibra + móveis'),
    (1, 7, 'alimentacao', 161.2, 'Compras Continente'),
    (1, 11, 'energia', 97.85, 'Eletricidade'),
    (1, 14, 'saude', 55.0, 'Consulta dentista'),
    (1, 17, 'transportes', 74.9, 'Combustível'),
    (1, 20, 'alimentacao', 143.05, 'Compras Pingo Doce'),
    (1, 22, 'educacao', 240.0, 'Creche'),
    (1, 24, 'lazer', 62.0, 'Concerto'),
    (1, 27, 'agua', 32.4, 'Água'),
    (1, 29, 'outros', 38.9, 'Prendas'),
    // ── current month (over budget on alimentacao + lazer) ──
    (2, 2, 'habitacao', 685.0, 'Prestação casa'),
    (2, 4, 'telecomunicacoes', 62.9, 'Fibra + móveis'),
    (2, 6, 'alimentacao', 189.4, 'Compras Continente'),
    (2, 9, 'energia', 104.6, 'Eletricidade'),
    (2, 11, 'transportes', 81.25, 'Combustível'),
    (2, 13, 'alimentacao', 214.8, 'Compras + peixaria'),
    (2, 15, 'saude', 42.5, 'Farmácia'),
    (2, 17, 'lazer', 139.0, 'Fim de semana fora'),
    (2, 19, 'alimentacao', 181.4, 'Compras Auchan'),
    (2, 21, 'educacao', 240.0, 'Creche'),
    (2, 23, 'agua', 33.1, 'Água'),
    (2, 24, 'outros', 26.5, 'Correios'),
  ];

  Future<void> _seedExpenses() async {
    final documents = <String, Map<String, dynamic>>{};
    for (var i = 0; i < _expenseSpecs.length; i++) {
      final (monthOffset, day, category, amount, description) =
          _expenseSpecs[i];
      final month = _months[monthOffset];
      final date = _dayIn(month, day);
      final id = 'qa-ae-${i.toString().padLeft(3, '0')}';
      documents[id] = {
        'id': id,
        'household_id': _householdId,
        'category': category,
        'amount': amount,
        'expense_date':
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'description': description,
        'month_key': _monthKey(month),
      };
    }
    await _store.putAll(
      QaCollections.actualExpenses,
      _householdId,
      documents,
    );
  }

  Future<void> _seedRecurringExpenses() async {
    final recurring = [
      RecurringExpense(
        id: 'qa-rec-habitacao',
        category: 'habitacao',
        amount: 685,
        description: 'Crédito habitação',
        dayOfMonth: 2,
      ),
      RecurringExpense(
        id: 'qa-rec-telecom',
        category: 'telecomunicacoes',
        amount: 62.9,
        description: 'Fibra + móveis',
        dayOfMonth: 4,
      ),
      RecurringExpense(
        id: 'qa-rec-educacao',
        category: 'educacao',
        amount: 240,
        description: 'Creche',
        dayOfMonth: 21,
      ),
      RecurringExpense(
        id: 'qa-rec-lazer',
        category: 'lazer',
        amount: 17.99,
        description: 'Streaming (inativo)',
        dayOfMonth: 8,
        isActive: false,
      ),
    ];
    await _store.putAll(QaCollections.recurringExpenses, _householdId, {
      for (final expense in recurring)
        expense.id: expense.toSupabase(_householdId),
    });

    // Mark the prior months as already generated so a QA boot does not inject
    // duplicate expenses on top of the curated dataset.
    for (final month in _months) {
      final monthKey = _monthKey(month);
      await _store.put(
        QaCollections.recurringExpenseRuns,
        _householdId,
        monthKey,
        {'household_id': _householdId, 'month_key': monthKey},
      );
    }
  }

  /// Snapshots of the planned fixed expenses per month, which the yearly and
  /// month-review screens diff against.
  Future<void> _seedExpenseSnapshots() async {
    const planned = <(String, String, String, double)>[
      ('qa-exp-telecom', 'Fibra + Móveis', 'telecomunicacoes', 62.9),
      ('qa-exp-energia', 'Eletricidade', 'energia', 94.4),
      ('qa-exp-agua', 'Água', 'agua', 31.2),
      ('qa-exp-alimentacao', 'Supermercado', 'alimentacao', 520.0),
      ('qa-exp-habitacao', 'Crédito habitação', 'habitacao', 685.0),
      ('qa-exp-transportes', 'Combustível + Passes', 'transportes', 180.0),
      ('qa-exp-educacao', 'Creche', 'educacao', 240.0),
      ('qa-exp-lazer', 'Streaming + Ginásio', 'lazer', 58.0),
    ];

    for (final month in _months) {
      final monthKey = _monthKey(month);
      await _store.putAll(QaCollections.expenseSnapshots, _householdId, {
        for (final (id, label, category, amount) in planned)
          '$monthKey|$id': {
            'household_id': _householdId,
            'month': monthKey,
            'expense_id': id,
            'label': label,
            'category': category,
            'amount': amount,
            'enabled': true,
          },
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Savings — on track / behind / completed
  // ---------------------------------------------------------------------------

  Future<void> _seedSavings() async {
    final goals = [
      SavingsGoal(
        id: 'qa-goal-fundo',
        name: 'Fundo de emergência',
        targetAmount: 6000,
        currentAmount: 3900,
        deadline: DateTime(_now.year + 1, 6, 30),
        color: '#3E7C59',
      ),
      SavingsGoal(
        id: 'qa-goal-ferias',
        name: 'Férias 2027',
        targetAmount: 2500,
        currentAmount: 380,
        deadline: DateTime(_now.year, 12, 31),
        color: '#C97B3C',
      ),
      SavingsGoal(
        id: 'qa-goal-portatil',
        name: 'Portátil novo',
        targetAmount: 1200,
        currentAmount: 1200,
        deadline: _dayIn(_priorMonth, 28),
        color: '#5B6BAF',
        isActive: false,
      ),
    ];
    await _store.putAll(QaCollections.savingsGoals, _householdId, {
      for (final goal in goals) goal.id: goal.toSupabase(_householdId),
    });

    final contributions = [
      SavingsContribution(
        id: 'qa-contrib-001',
        goalId: 'qa-goal-fundo',
        amount: 1500,
        contributionDate: _dayIn(_twoMonthsAgo, 6),
        note: 'Transferência inicial',
      ),
      SavingsContribution(
        id: 'qa-contrib-002',
        goalId: 'qa-goal-fundo',
        amount: 1200,
        contributionDate: _dayIn(_priorMonth, 6),
      ),
      SavingsContribution(
        id: 'qa-contrib-003',
        goalId: 'qa-goal-fundo',
        amount: 1200,
        contributionDate: _dayIn(_currentMonth, 6),
      ),
      SavingsContribution(
        id: 'qa-contrib-004',
        goalId: 'qa-goal-ferias',
        amount: 200,
        contributionDate: _dayIn(_priorMonth, 10),
      ),
      SavingsContribution(
        id: 'qa-contrib-005',
        goalId: 'qa-goal-ferias',
        amount: 180,
        contributionDate: _dayIn(_currentMonth, 10),
      ),
      SavingsContribution(
        id: 'qa-contrib-006',
        goalId: 'qa-goal-portatil',
        amount: 1200,
        contributionDate: _dayIn(_twoMonthsAgo, 14),
        note: 'Objetivo concluído',
      ),
    ];
    await _store.putAll(QaCollections.savingsContributions, _householdId, {
      for (final contribution in contributions)
        contribution.id: contribution.toSupabase(_householdId),
    });
  }

  // ---------------------------------------------------------------------------
  // Shopping + purchases
  // ---------------------------------------------------------------------------

  Future<void> _seedShoppingList() async {
    const items = <(String, String, String, double, bool, double, String)>[
      ('qa-shop-001', 'Leite meio-gordo', 'Continente', 0.79, true, 6, 'L'),
      ('qa-shop-002', 'Pão de forma', 'Continente', 1.29, true, 1, 'un'),
      ('qa-shop-003', 'Peito de frango', 'Pingo Doce', 6.49, false, 1.2, 'kg'),
      ('qa-shop-004', 'Arroz agulha', 'Lidl', 1.15, false, 2, 'kg'),
      ('qa-shop-005', 'Tomate cherry', 'Mercado', 2.39, false, 0.5, 'kg'),
      ('qa-shop-006', 'Detergente louça', 'Auchan', 2.05, false, 1, 'un'),
    ];

    final documents = <String, Map<String, dynamic>>{};
    for (var i = 0; i < items.length; i++) {
      final (id, name, store, price, checked, quantity, unit) = items[i];
      // created_at drives list order, so space entries out deterministically.
      final createdAt = _now.subtract(Duration(minutes: (items.length - i) * 7));
      documents[id] = {
        'id': id,
        'household_id': _householdId,
        'product_name': name,
        'store': store,
        'price': price,
        'checked': checked,
        'quantity': quantity,
        'unit': unit,
        'created_at': createdAt.toIso8601String(),
        'updated_at': createdAt.toIso8601String(),
      };
    }
    await _store.putAll(QaCollections.shoppingItems, _householdId, documents);
  }

  Future<void> _seedPurchaseHistory() async {
    final records = <(String, DateTime, double, int, List<String>, bool)>[
      (
        'qa-purchase-001',
        _dayIn(_twoMonthsAgo, 8),
        148.35,
        22,
        const ['Leite', 'Pão', 'Fruta', 'Massa'],
        false,
      ),
      (
        'qa-purchase-002',
        _dayIn(_priorMonth, 7),
        161.2,
        25,
        const ['Leite', 'Carne', 'Legumes', 'Iogurtes'],
        true,
      ),
      (
        'qa-purchase-003',
        _dayIn(_currentMonth, 6),
        189.4,
        28,
        const ['Leite', 'Peixe', 'Arroz', 'Detergente'],
        true,
      ),
    ];

    await _store.putAll(QaCollections.purchaseRecords, _householdId, {
      for (final (id, date, amount, count, items, isMeal) in records)
        id: {
          'id': id,
          'household_id': _householdId,
          'amount': amount,
          'item_count': count,
          'purchased_at': date.toIso8601String(),
          'items_json': jsonEncode(items),
          'is_meal_purchase': isMeal,
        },
    });
  }

  Future<void> _seedCoachInsights() async {
    final insights = <(String, DateTime, String, int)>[
      (
        'qa-insight-001',
        _dayIn(_priorMonth, 26),
        'A alimentação ficou 8% acima do envelope no mês passado. '
            'Reduzir uma ida ao supermercado por semana liberta cerca de 60 € por mês.',
        42,
      ),
      (
        'qa-insight-002',
        _dayIn(_currentMonth, 16),
        'O fundo de emergência já cobre 2,4 meses de despesas fixas. '
            'Manter 300 € por mês atinge a meta antes do prazo.',
        28,
      ),
    ];

    await _store.putAll(QaCollections.coachInsights, _householdId, {
      for (final (id, timestamp, content, stress) in insights)
        id: {
          'id': id,
          'household_id': _householdId,
          'created_at': timestamp.toIso8601String(),
          'content': content,
          'stress_score': stress,
        },
    });
  }

  Future<void> _seedActivityEvents() async {
    final events = <(
      String,
      int,
      ActivityDomain,
      ActivityAction,
      String,
      String,
      String,
    )>[
      (
        'qa-evt-001',
        180,
        ActivityDomain.shopping,
        ActivityAction.added,
        'qa-shop-003',
        'Peito de frango',
        'Rita',
      ),
      (
        'qa-evt-002',
        140,
        ActivityDomain.shopping,
        ActivityAction.checked,
        'qa-shop-001',
        'Leite meio-gordo',
        'Rita',
      ),
      (
        'qa-evt-003',
        95,
        ActivityDomain.expenses,
        ActivityAction.added,
        'qa-ae-031',
        'Correios',
        'Tester QA',
      ),
      (
        'qa-evt-004',
        50,
        ActivityDomain.meals,
        ActivityAction.swapped,
        'qa-meal-plan',
        'Jantar de quarta',
        'Tester QA',
      ),
      (
        'qa-evt-005',
        20,
        ActivityDomain.settings,
        ActivityAction.updated,
        'qa-exp-lazer',
        'Streaming + Ginásio',
        'Tester QA',
      ),
    ];

    await _store.putAll(QaCollections.activityEvents, _householdId, {
      for (final (id, minutesAgo, domain, action, subjectId, label, actor)
          in events)
        id: {
          'id': id,
          'household_id': _householdId,
          'actor_user_id': actor == 'Tester QA' ? _userId : 'qa-user-0002',
          'actor_display_name': actor,
          'domain': domain.name,
          'action': action.name,
          'subject_id': subjectId,
          'subject_label': label,
          'metadata': const <String, dynamic>{},
          'created_at': _now
              .subtract(Duration(minutes: minutesAgo))
              .toIso8601String(),
        },
    });
  }

  Future<void> _seedProductsAndMerchants() async {
    const products = [
      Product(
        id: 'qa-prod-leite',
        name: 'Leite meio-gordo',
        category: 'lacteos',
        avgPrice: 0.79,
        unit: 'L',
      ),
      Product(
        id: 'qa-prod-pao',
        name: 'Pão de forma',
        category: 'padaria',
        avgPrice: 1.29,
        unit: 'un',
      ),
      Product(
        id: 'qa-prod-frango',
        name: 'Peito de frango',
        category: 'carne',
        avgPrice: 6.49,
        unit: 'kg',
      ),
      Product(
        id: 'qa-prod-arroz',
        name: 'Arroz agulha',
        category: 'mercearia',
        avgPrice: 1.15,
        unit: 'kg',
      ),
      Product(
        id: 'qa-prod-ovos',
        name: 'Ovos M',
        category: 'frescos',
        avgPrice: 2.19,
        unit: 'dz',
      ),
      Product(
        id: 'qa-prod-cafe',
        name: 'Café moído',
        category: 'mercearia',
        avgPrice: 3.45,
        unit: 'un',
      ),
    ];
    await _store.putAll(QaCollections.products, globalScope, {
      for (final product in products) product.id: product.toJson(),
    });

    await _store.putAll(QaCollections.merchants, globalScope, {
      '500829993': {
        'nif': '500829993',
        'name': 'Continente',
        'chain': 'MC',
        'category': 'supermercado',
        'confirmed_count': 12,
        'created_by': _userId,
      },
      '502011475': {
        'nif': '502011475',
        'name': 'Pingo Doce',
        'chain': 'Jerónimo Martins',
        'category': 'supermercado',
        'confirmed_count': 7,
        'created_by': _userId,
      },
    });
  }
}
