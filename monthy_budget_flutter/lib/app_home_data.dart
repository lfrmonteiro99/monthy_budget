part of 'main.dart';

/// Data loading and persistence methods for [_AppHomeState].
extension _AppHomeData on _AppHomeState {
  /// Lightweight refresh of household-synced data — called on app resume.
  Future<void> _refreshData() async {
    if (!mounted) return;
    final results = await Future.wait([
      _settingsService.load(widget.householdId),
      _favoritesService.load(widget.householdId),
      _purchaseHistoryService.load(widget.householdId),
    ]);
    if (mounted) {
      setState(() {
        _settings = results[0] as AppSettings;
        _favorites = results[1] as List<String>;
        _purchaseHistory = results[2] as PurchaseHistory;
      });
    }
    _expenseSnapshotService.loadHistory(widget.householdId).then((history) {
      if (mounted) setState(() => _expenseHistory = history);
    });
    _loadActualExpenses();
  }

  Future<void> _loadAll() async {
    // Detect user change and clear stale per-user local data
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final changed = await _localConfigService.checkUserChanged(userId);
      if (changed) await _subscriptionService.clear();
    }

    final results = await Future.wait([
      _settingsService.load(widget.householdId),
      _favoritesService.load(widget.householdId),
      _purchaseHistoryService.load(widget.householdId),
      _aiCoachService.loadApiKey(),
      _productsService.load(),
      _localConfigService.load(),
      _localConfigService.loadOnboardingState(),
      _subscriptionService.load(),
    ]);
    setState(() {
      _settings = results[0] as AppSettings;
      _favorites = results[1] as List<String>;
      _purchaseHistory = results[2] as PurchaseHistory;
      _openAiApiKey = results[3] as String;
      _products = results[4] as List<Product>;
      _dashboardConfig = results[5] as LocalDashboardConfig;
      _onboardingState = results[6] as OnboardingState;
      _subscription = results[7] as SubscriptionState;
      _loaded = true;
    });
    _syncLocaleAndFormatter(_settings);
    _expenseSnapshotService.loadHistory(widget.householdId).then((history) {
      if (mounted) setState(() => _expenseHistory = history);
    });
    _loadActualExpenses();
    _loadRecurringExpenses();
    _loadActualExpenseHistory();
    _loadMonthlyBudgets();
    _loadNotificationPrefs();
    await _loadSavingsGoals();
    _syncRevenueCat();
    _checkDowngrade();
  }

  String get _currentMonthKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<void> _loadActualExpenses() async {
    final expenses = await _actualExpenseService.loadMonth(
        widget.householdId, _currentMonthKey);
    if (mounted) {
      setState(() => _actualExpenses = expenses);
      _refreshNotificationSchedules();
    }
  }

  Future<void> _loadRecurringExpenses() async {
    final recurring =
        await _recurringExpenseService.load(widget.householdId);
    if (mounted) {
      setState(() => _recurringExpenses = recurring);
      _refreshNotificationSchedules();
    }
    // Auto-populate recurring expenses for the current month
    final created = await _recurringExpenseService.populateMonthIfNeeded(
        widget.householdId, _currentMonthKey);
    if (created.isNotEmpty) {
      _loadActualExpenses();
    }
  }

  Future<void> _loadActualExpenseHistory() async {
    final history =
        await _actualExpenseService.loadHistory(widget.householdId);
    if (mounted) setState(() => _actualExpenseHistory = history);
  }

  Future<void> _loadMonthlyBudgets() async {
    final budgets = await _monthlyBudgetService.loadMonth(
        widget.householdId, _currentMonthKey);
    if (mounted) {
      setState(() => _monthlyBudgets = {
        for (final b in budgets) b.category: b.amount,
      });
    }
  }

  Future<void> _loadNotificationPrefs() async {
    final prefs =
        await _localConfigService.loadNotificationPreferences();
    if (mounted) {
      setState(() => _notificationPrefs = prefs);
      _refreshNotificationSchedules();
    }
  }

  Future<void> _loadSavingsGoals() async {
    final goals = await _savingsGoalService.loadGoals(widget.householdId);
    if (mounted) setState(() => _savingsGoals = goals);
    // Load contributions and compute projections for dashboard card
    final allContribs = await _savingsGoalService.loadAllContributions(
        widget.householdId, recentMonths: 6);
    final projections = <String, SavingsProjection>{};
    for (final goal in goals) {
      projections[goal.id] = calculateProjection(
        goal: goal,
        contributions: allContribs[goal.id] ?? [],
      );
    }
    if (mounted) setState(() => _savingsProjections = projections);
  }

  void _syncLocaleAndFormatter(AppSettings settings) {
    setFormatterCountry(settings.country);
    if (settings.localeOverride != null) {
      appLocaleNotifier.value = Locale(settings.localeOverride!);
    } else {
      appLocaleNotifier.value = null; // system default
    }
  }

  void _saveSettings(AppSettings settings) {
    if (!widget.isAdmin) return;
    setState(() => _settings = settings);
    _syncLocaleAndFormatter(settings);
    _settingsService.save(settings, widget.householdId);
    _refreshNotificationSchedules();
  }

  void _saveDashboardConfig(LocalDashboardConfig config) {
    setState(() => _dashboardConfig = config);
    _localConfigService.save(config);
  }

  void _snapshotExpenses() {
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    _expenseSnapshotService
        .snapshotIfNeeded(widget.householdId, monthKey, _settings.expenses)
        .then((_) => _expenseSnapshotService.loadHistory(widget.householdId))
        .then((history) {
      if (mounted) setState(() => _expenseHistory = history);
    });
  }

  void _saveFavorites(List<String> favorites) {
    setState(() => _favorites = favorites);
    _favoritesService.save(favorites, widget.householdId);
  }

  void _saveApiKey(String key) {
    setState(() => _openAiApiKey = key);
    _aiCoachService.saveApiKey(key);
  }

  void _markTourDone(String key) {
    final updated = _onboardingState.copyWith(
      toursCompleted: {..._onboardingState.toursCompleted, key: true},
    );
    setState(() => _onboardingState = updated);
    _localConfigService.saveOnboardingState(updated);
  }

  double _currentBudgetUsagePercent() {
    final totalBudget = _settings.expenses
        .where((e) => e.enabled)
        .fold<double>(0, (sum, e) => sum + e.amount);
    if (totalBudget <= 0) return 0;

    final spent = _actualExpenses.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );
    return (spent / totalBudget) * 100;
  }

  ({String category, double percent})? _topCategoryUsage() {
    final budgetByCategory = <String, double>{};
    for (final item in _settings.expenses.where((e) => e.enabled && e.amount > 0)) {
      budgetByCategory.update(item.category.name, (v) => v + item.amount,
          ifAbsent: () => item.amount);
    }
    if (budgetByCategory.isEmpty) return null;

    final spentByCategory = <String, double>{};
    for (final expense in _actualExpenses) {
      spentByCategory.update(expense.category, (v) => v + expense.amount,
          ifAbsent: () => expense.amount);
    }

    String? topCategory;
    double topPercent = 0.0;
    for (final entry in budgetByCategory.entries) {
      final spent = spentByCategory[entry.key] ?? 0.0;
      final percent = entry.value > 0 ? (spent / entry.value) * 100 : 0.0;
      if (topCategory == null || percent > topPercent) {
        topCategory = entry.key;
        topPercent = percent;
      }
    }
    if (topCategory == null) return null;
    return (category: topCategory, percent: topPercent);
  }

  void _refreshNotificationSchedules() {
    final topCategory = _topCategoryUsage();
    unawaited(NotificationService().refreshAllSchedules(
      prefs: _notificationPrefs,
      recurringExpenses: _recurringExpenses,
      budgetUsagePercent: _currentBudgetUsagePercent(),
      hasMealPlan: true, // TODO: wire with generated meal plan state.
      topCategoryName: topCategory?.category,
      topCategoryUsagePercent: topCategory?.percent,
    ));
  }

  Future<void> _addActualExpense(ActualExpense expense) async {
    setState(() => _actualExpenses = [expense, ..._actualExpenses]);
    _refreshNotificationSchedules();
    try {
      await _actualExpenseService.add(expense, widget.householdId);
    } catch (e) {
      debugPrint('Failed to add expense: $e');
      // Reload from Supabase to get the real state
      _loadActualExpenses();
    }
  }

  Future<void> _updateActualExpense(ActualExpense expense) async {
    setState(() {
      _actualExpenses =
          _actualExpenses.map((e) => e.id == expense.id ? expense : e).toList();
    });
    _refreshNotificationSchedules();
    await _actualExpenseService.update(expense);
  }

  Future<void> _deleteActualExpense(String id) async {
    setState(() {
      _actualExpenses = _actualExpenses.where((e) => e.id != id).toList();
    });
    _refreshNotificationSchedules();
    await _actualExpenseService.delete(id);
  }

  void _openAddExpenseSheet() async {
    final result = await showAddExpenseSheet(
      context: context,
      budgetExpenses: _settings.expenses,
      currentExpenses: _actualExpenses,
    );
    if (result != null) {
      _addActualExpense(result);
    }
  }
}
