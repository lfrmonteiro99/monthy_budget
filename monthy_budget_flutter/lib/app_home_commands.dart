part of 'main.dart';

/// Command chat methods for [_AppHomeState].
extension _AppHomeCommands on _AppHomeState {
  CommandActionRegistry _buildCommandRegistry() {
    return CommandActionRegistry(
      onAddExpense: _addActualExpense,
      onAddShoppingItem: (item) async => _addToShoppingList(item),
      onAddSavingsGoal: _addSavingsGoalFromCommand,
      onAddRecurringExpense: _addRecurringExpenseFromCommand,
      onRemoveShoppingItemByName: _removeShoppingItemByNameFromCommand,
      onToggleShoppingItemCheckedByName:
          _toggleShoppingItemCheckedByNameFromCommand,
      onAddSavingsContributionByGoalName:
          _addSavingsContributionByGoalNameFromCommand,
      onDeleteExpenseByDescription: _deleteExpenseByDescriptionFromCommand,
      onDeleteExpense: _deleteActualExpense,
      onSetThemeMode: (mode) => appThemeModeNotifier.value = mode,
      onSetColorPalette: (palette) {
        AppColors.palette = palette;
        appColorPaletteNotifier.value = palette;
        _localConfigService.saveColorPalette(palette);
      },
      onSetLanguage: (localeCode) {
        _saveSettings(_settings.copyWith(localeOverride: localeCode));
      },
      onNavigateTo: _handleCommandNavigation,
      onClearCheckedItems: _clearCheckedItems,
    );
  }

  void _handleCommandNavigation(String screen) {
    switch (screen) {
      case 'dashboard':
        setState(() => _currentIndex = 0);
      case 'expenses':
        setState(() => _currentIndex = 1);
      case 'plan':
        setState(() => _currentIndex = 2);
      case 'more':
        setState(() => _currentIndex = 3);
      case 'coach':
        _openCoach();
      case 'grocery':
        _openGrocery();
      case 'shopping_list':
        _openShoppingList();
      case 'meals':
        _openMealPlanner();
      case 'settings':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => _buildSettingsScreen()),
        );
      case 'insights':
        _openInsights();
      case 'savings_goals':
        _openSavingsGoals();
    }
    setState(() => _commandPanelOpen = false);
  }

  Future<void> _addSavingsGoalFromCommand(SavingsGoal goal) async {
    setState(() {
      _savingsGoals = [..._savingsGoals, goal]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    });
    try {
      await _savingsGoalService.saveGoal(goal, widget.householdId);
    } catch (e) {
      debugPrint('Failed to add savings goal: $e');
      _loadSavingsGoals();
    }
  }

  Future<void> _addRecurringExpenseFromCommand(
    RecurringExpense expense,
  ) async {
    setState(() {
      _recurringExpenses = [..._recurringExpenses, expense]
        ..sort((a, b) {
          final dayA = a.dayOfMonth ?? 99;
          final dayB = b.dayOfMonth ?? 99;
          return dayA.compareTo(dayB);
        });
    });
    _refreshNotificationSchedules();
    try {
      await _recurringExpenseService.save(expense, widget.householdId);
    } catch (e) {
      debugPrint('Failed to add recurring expense: $e');
      _loadRecurringExpenses();
    }
  }

  Future<bool> _removeShoppingItemByNameFromCommand(String itemName) async {
    final query = itemName.trim().toLowerCase();
    final match = _shoppingList
        .where((item) => item.productName.trim().toLowerCase() == query)
        .cast<ShoppingItem?>()
        .firstWhere((item) => item != null, orElse: () => null);
    final fallback = match ??
        _shoppingList
            .where((item) => item.productName.trim().toLowerCase().contains(query))
            .cast<ShoppingItem?>()
            .firstWhere((item) => item != null, orElse: () => null);
    final item = fallback;
    if (item == null || item.id.isEmpty) return false;
    final previousItems = List<ShoppingItem>.from(_shoppingList);
    setState(() {
      _shoppingList = _shoppingList.where((i) => i.id != item.id).toList();
    });
    try {
      await _shoppingListService.remove(item.id);
      return true;
    } catch (e) {
      debugPrint('Failed to remove shopping item: $e');
      setState(() => _shoppingList = previousItems);
      return false;
    }
  }

  Future<bool> _toggleShoppingItemCheckedByNameFromCommand(
    String itemName,
    bool checked,
  ) async {
    final query = itemName.trim().toLowerCase();
    final exact = _shoppingList
        .where((item) => item.productName.trim().toLowerCase() == query)
        .cast<ShoppingItem?>()
        .firstWhere((item) => item != null, orElse: () => null);
    final item = exact ??
        _shoppingList
            .where((i) => i.productName.trim().toLowerCase().contains(query))
            .cast<ShoppingItem?>()
            .firstWhere((i) => i != null, orElse: () => null);
    if (item == null || item.id.isEmpty) return false;
    final previousItems = List<ShoppingItem>.from(_shoppingList);
    setState(() {
      _shoppingList = _shoppingList.map((i) {
        if (i.id != item.id) return i;
        return ShoppingItem(
          id: i.id,
          productName: i.productName,
          store: i.store,
          price: i.price,
          unitPrice: i.unitPrice,
          checked: checked,
        );
      }).toList();
    });
    try {
      await _shoppingListService.toggle(item.id, checked);
      return true;
    } catch (e) {
      debugPrint('Failed to toggle shopping item: $e');
      setState(() => _shoppingList = previousItems);
      return false;
    }
  }

  Future<bool> _addSavingsContributionByGoalNameFromCommand(
    String goalName,
    double amount,
  ) async {
    final query = goalName.trim().toLowerCase();
    final exact = _savingsGoals
        .where((goal) => goal.name.trim().toLowerCase() == query)
        .cast<SavingsGoal?>()
        .firstWhere((goal) => goal != null, orElse: () => null);
    final goal = exact ??
        _savingsGoals
            .where((g) => g.name.trim().toLowerCase().contains(query))
            .cast<SavingsGoal?>()
            .firstWhere((g) => g != null, orElse: () => null);
    if (goal == null) return false;

    final contribution = SavingsContribution(
      id: 'contrib_${DateTime.now().millisecondsSinceEpoch}',
      goalId: goal.id,
      amount: amount,
      contributionDate: DateTime.now(),
    );

    try {
      final updatedGoal = await _savingsGoalService.addContribution(
        contribution,
        widget.householdId,
      );
      setState(() {
        _savingsGoals = _savingsGoals
            .map((g) => g.id == updatedGoal.id ? updatedGoal : g)
            .toList();
      });
      return true;
    } catch (e) {
      debugPrint('Failed to add savings contribution: $e');
      _loadSavingsGoals();
      return false;
    }
  }

  Future<bool> _deleteExpenseByDescriptionFromCommand(
    String description, {
    String? category,
  }) async {
    final query = description.trim().toLowerCase();
    final exact = _actualExpenses
        .where((expense) {
          final desc = (expense.description ?? '').trim().toLowerCase();
          if (desc != query) return false;
          return category == null || expense.category == category;
        })
        .cast<ActualExpense?>()
        .firstWhere((expense) => expense != null, orElse: () => null);
    final expense = exact ??
        _actualExpenses
            .where((e) {
              final desc = (e.description ?? '').trim().toLowerCase();
              if (!desc.contains(query)) return false;
              return category == null || e.category == category;
            })
            .cast<ActualExpense?>()
            .firstWhere((e) => e != null, orElse: () => null);
    if (expense == null) return false;
    final previousExpenses = List<ActualExpense>.from(_actualExpenses);
    setState(() {
      _actualExpenses = _actualExpenses.where((e) => e.id != expense.id).toList();
    });
    _refreshNotificationSchedules();
    try {
      await _actualExpenseService.delete(expense.id);
      return true;
    } catch (e) {
      debugPrint('Failed to delete expense by description: $e');
      setState(() => _actualExpenses = previousExpenses);
      _refreshNotificationSchedules();
      return false;
    }
  }
}
