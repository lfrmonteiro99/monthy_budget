part of 'main.dart';

/// Navigation helper methods for [_AppHomeState].
extension _AppHomeNavigation on _AppHomeState {
  void _openRecurringExpenses() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _buildSettingsScreen(initialSection: 'expenses'),
      ),
    );
  }

  void _openExpenseTrends() {
    if (!_gateFeature(PremiumFeature.expenseTrends)) return;
    _trackFeature('expense_tracker');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseTrendsScreen(
          actualExpenseHistory: _actualExpenseHistory,
          expenseHistory: _expenseHistory,
        ),
      ),
    );
  }

  void _openSavingsGoals() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SavingsGoalsScreen(
          householdId: widget.householdId,
          goals: _savingsGoals,
          onChanged: (updated) {
            setState(() => _savingsGoals = updated);
            _loadSavingsGoals();
          },
          subscription: _subscription,
          onUpgrade: _openPaywall,
          showTour: !_onboardingState.isTourDone('savings_goals'),
          onTourComplete: () => _markTourDone('savings_goals'),
        ),
      ),
    );
  }

  void _openNotificationSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationSettingsScreen(
          preferences: _notificationPrefs,
          onSave: (prefs) {
            setState(() => _notificationPrefs = prefs);
            _refreshNotificationSchedules();
          },
        ),
      ),
    );
  }

  void _openInsights() {
    final taxSystem = getTaxSystem(_settings.country);
    final summary = calculateBudgetSummary(
      _settings.salaries,
      _settings.personalInfo,
      _settings.expenses,
      taxSystem,
      monthlyBudgets: _monthlyBudgets,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InsightsScreen(
          settings: _settings,
          summary: summary,
          onOpenExpenseTrends: _openExpenseTrends,
          onOpenSavingsGoals: _openSavingsGoals,
          onOpenTaxSimulator: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TaxSimulatorScreen(settings: _settings),
            ),
          ),
        ),
      ),
    );
  }

  void _openDetailedDashboard() {
    final taxSystem = getTaxSystem(_settings.country);
    final summary = calculateBudgetSummary(
      _settings.salaries,
      _settings.personalInfo,
      _settings.expenses,
      taxSystem,
      monthlyBudgets: _monthlyBudgets,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DashboardScreen(
          settings: _settings,
          summary: summary,
          purchaseHistory: _purchaseHistory,
          onSaveSettings: _saveSettings,
          dashboardConfig: LocalDashboardConfig.full(),
          expenseHistory: _expenseHistory,
          onSnapshotExpenses: _snapshotExpenses,
          actualExpenses: _actualExpenses,
          onAddExpense: _openAddExpenseSheet,
          monthlyBudgets: _monthlyBudgets,
          onOpenExpenseTracker: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ExpenseTrackerScreen(
                settings: _settings,
                expenses: _actualExpenses,
                householdId: widget.householdId,
                onAdd: _addActualExpense,
                onUpdate: _updateActualExpense,
                onDelete: _deleteActualExpense,
                onLoadMonth: (monthKey) =>
                    _actualExpenseService.loadMonth(widget.householdId, monthKey),
                onLoadHistory: () =>
                    _actualExpenseService.loadHistory(widget.householdId),
                onOpenRecurring: _openRecurringExpenses,
                showTour: !_onboardingState.isTourDone('expense_tracker'),
                onTourComplete: () => _markTourDone('expense_tracker'),
              ),
            ),
          ),
          onViewTrends: _openExpenseTrends,
          savingsGoals: _savingsGoals,
          savingsProjections: _savingsProjections,
          onOpenSavingsGoals: _openSavingsGoals,
          recurringExpenses: _recurringExpenses,
          actualExpenseHistory: _actualExpenseHistory,
          billReminderDaysBefore: _notificationPrefs.billReminderDaysBefore,
          onOpenRecurringExpenses: _openRecurringExpenses,
          onOpenSettings: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => _buildSettingsScreen()),
            );
          },
        ),
      ),
    );
  }

  void _openGrocery() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GroceryScreen(
          products: _products,
          onAddToShoppingList: _addToShoppingList,
          showTour: !_onboardingState.isTourDone('grocery'),
          onTourComplete: () => _markTourDone('grocery'),
        ),
      ),
    );
  }

  void _openShoppingList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShoppingListScreen(
          items: _shoppingList,
          onToggleChecked: _toggleShoppingItem,
          onRemove: _removeShoppingItem,
          onClearChecked: _clearCheckedItems,
          onFinalize: _finalizeShopping,
          purchaseHistory: _purchaseHistory,
          showTour: !_onboardingState.isTourDone('shopping'),
          onTourComplete: () => _markTourDone('shopping'),
        ),
      ),
    );
  }

  void _openCoach() {
    if (!_gateFeature(PremiumFeature.aiCoach)) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoachScreen(
          settings: _settings,
          purchaseHistory: _purchaseHistory,
          apiKey: _openAiApiKey,
          householdId: widget.householdId,
          subscription: _subscription,
          onSubscriptionChanged: (next) {
            if (!mounted) return;
            setState(() => _subscription = next);
          },
          onRestoreMemory: _openPaywall,
          onOpenSettings: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => _buildSettingsScreen()),
            );
          },
          showTour: !_onboardingState.isTourDone('coach'),
          onTourComplete: () => _markTourDone('coach'),
        ),
      ),
    );
  }

  void _openMealPlanner() {
    if (!_gateFeature(PremiumFeature.mealPlanner)) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MealPlannerScreen(
          settings: _settings,
          apiKey: _openAiApiKey,
          favorites: _favorites,
          onAddToShoppingList: _addToShoppingList,
          householdId: widget.householdId,
          onSaveSettings: _saveSettings,
          purchaseHistory: _purchaseHistory,
          onOpenMealSettings: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _buildSettingsScreen(initialSection: 'meals'),
            ),
          ),
          showTour: !_onboardingState.isTourDone('meals'),
          onTourComplete: () => _markTourDone('meals'),
        ),
      ),
    );
  }
}
