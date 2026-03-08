part of 'main.dart';

/// Build method and settings screen builder for [_AppHomeState].
extension _AppHomeBuild on _AppHomeState {
  SettingsScreen _buildSettingsScreen({String? initialSection}) {
    return SettingsScreen(
      settings: _settings,
      onSave: _saveSettings,
      favorites: _favorites,
      onSaveFavorites: _saveFavorites,
      apiKey: _openAiApiKey,
      onSaveApiKey: _saveApiKey,
      isAdmin: widget.isAdmin,
      householdId: widget.householdId,
      products: _products,
      dashboardConfig: _dashboardConfig,
      onSaveDashboardConfig: _saveDashboardConfig,
      onOpenDetailedDashboard: _openDetailedDashboard,
      onOpenNotificationSettings: _openNotificationSettings,
      onOpenSubscription: _openPaywall,
      onOpenCustomerCenter: _openCustomerCenter,
      subscription: _subscription,
      subscriptionLabel: _subscription.isTrialActive
          ? 'Trial (${_subscription.trialDaysRemaining} days left)'
          : _subscription.tier == SubscriptionTier.free
              ? 'Free'
              : 'Pro',
      monthlyBudgets: _monthlyBudgets,
      onSaveMonthlyBudgets: (budgetMap) async {
        final budgets = budgetMap.entries
            .map((e) => MonthlyBudget.create(
                  category: e.key,
                  amount: e.value,
                  monthKey: _currentMonthKey,
                ))
            .toList();
        await _monthlyBudgetService.saveAll(budgets, widget.householdId);
        _loadMonthlyBudgets();
      },
      recurringExpenses: _recurringExpenses,
      onRecurringChanged: (updated) {
        setState(() => _recurringExpenses = updated);
        _refreshNotificationSchedules();
      },
      initialSection: initialSection,
    );
  }

  Widget buildHome(BuildContext context) {
    if (!_loaded) {
      return const BrandedLoading();
    }

    if (!_settings.setupWizardCompleted) {
      return SetupWizardScreen(
        initial: _settings,
        onComplete: (settings) {
          final completed = settings.copyWith(setupWizardCompleted: true);
          _saveSettings(completed);
        },
      );
    }

    if (!_onboardingState.welcomeSeen) {
      return WelcomeSlideshowScreen(
        onComplete: () {
          final updated = _onboardingState.copyWith(welcomeSeen: true);
          setState(() => _onboardingState = updated);
          _localConfigService.saveOnboardingState(updated);
        },
      );
    }

    final taxSystem = getTaxSystem(_settings.country);
    final summary = calculateBudgetSummary(
      _settings.salaries,
      _settings.personalInfo,
      _settings.expenses,
      taxSystem,
      monthlyBudgets: _monthlyBudgets,
    );

    final focusedDashboardConfig = _dashboardConfig.copyWith(
      showSummaryCards: false,
      showSalaryBreakdown: false,
      showPurchaseHistory: false,
      showExpensesBreakdown: false,
      showCharts: false,
      showBudgetVsActual: false,
      showSavingsGoals: false,
      showTaxDeductions: false,
    );

    final screens = [
      DashboardScreen(
        settings: _settings,
        summary: summary,
        purchaseHistory: _purchaseHistory,
        onSaveSettings: _saveSettings,
        dashboardConfig: focusedDashboardConfig,
        expenseHistory: _expenseHistory,
        onSnapshotExpenses: _snapshotExpenses,
        actualExpenses: _actualExpenses,
        onAddExpense: _openAddExpenseSheet,
        monthlyBudgets: _monthlyBudgets,
        onOpenExpenseTracker: () => setState(() => _currentIndex = 1),
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
        showTour: !_onboardingState.isTourDone('dashboard'),
        onTourComplete: () => _markTourDone('dashboard'),
        fabKey: _fabKey,
        navBarKey: _navBarKey,
        focusedMode: true,
        onOpenInsights: _openInsights,
      ),
      ExpenseTrackerScreen(
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
      PlanHubScreen(
        onOpenGrocery: _openGrocery,
        onOpenShoppingList: _openShoppingList,
        onOpenMealPlanner: _openMealPlanner,
        onOpenCoach: _openCoach,
      ),
      MoreScreen(
        onOpenDetailedDashboard: _openDetailedDashboard,
        onOpenInsights: _openInsights,
        onOpenSavingsGoals: _openSavingsGoals,
        onOpenSettings: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => _buildSettingsScreen()),
          );
        },
        onOpenNotifications: _openNotificationSettings,
        onOpenSubscription: _openPaywall,
        subscription: _subscription,
        pausedItemCount:
            DowngradeService.pausedCategories(_settings.expenses) +
                DowngradeService.pausedSavingsGoals(_savingsGoals),
      ),
    ];

    return Stack(
      children: [
        Scaffold(
      body: _currentIndex == 0
          ? Column(
              children: [
                // Trial banner on dashboard
                if (_subscription.isTrialActive)
                  TrialBanner(
                    subscription: _subscription,
                    onUpgrade: _openPaywall,
                  ),
                // Feature discovery nudge
                if (_subscription.isTrialActive &&
                    _subscription.nextFeatureToDiscover != null)
                  FeatureDiscoveryCard(
                    subscription: _subscription,
                    onExploreFeature: _navigateToFeature,
                    onDismiss: () {
                      // Skip this feature in discovery
                      final next = _subscription.nextFeatureToDiscover;
                      if (next != null) _trackFeature(next);
                    },
                  ),
                Expanded(child: screens[0]),
                AdBannerWidget(
                  showAd: AdService.shouldShowAds(_subscription),
                ),
              ],
            )
          : screens[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              key: _fabKey,
              onPressed: _openAddExpenseSheet,
              backgroundColor: AppColors.primary(context),
              tooltip: S.of(context).addExpenseTooltip,
              child: Icon(Icons.add, color: AppColors.onPrimary(context)),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        key: _navBarKey,
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          const tabFeatures = ['dashboard', 'expense_tracker', 'planning', 'more'];
          if (i < tabFeatures.length) _trackFeature(tabFeatures[i]);

          setState(() => _currentIndex = i);
        },
        backgroundColor: AppColors.surface(context),
        indicatorColor: AppColors.navIndicator(context),
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.primary(context)),
            label: 'Home',
            tooltip: 'Monthly overview',
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon:
                Icon(Icons.receipt_long, color: AppColors.primary(context)),
            label: 'Track',
            tooltip: 'Track monthly expenses',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _shoppingList.any((i) => !i.checked),
              label: Text(
                '${_shoppingList.where((i) => !i.checked).length}',
                style: const TextStyle(fontSize: 10),
              ),
              child: const Icon(Icons.event_note_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: _shoppingList.any((i) => !i.checked),
              label: Text(
                '${_shoppingList.where((i) => !i.checked).length}',
                style: const TextStyle(fontSize: 10),
              ),
              child: Icon(Icons.event_note, color: AppColors.primary(context)),
            ),
            label: 'Plan',
            tooltip: 'Groceries, list and meal plan',
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            selectedIcon:
                Icon(Icons.more_horiz, color: AppColors.primary(context)),
            label: 'More',
            tooltip: 'Settings and insights',
          ),
        ],
      ),
        ),
        // Command assistant scrim
        if (_commandPanelOpen)
          GestureDetector(
            onTap: () => setState(() => _commandPanelOpen = false),
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),
        // Command assistant panel
        if (_commandPanelOpen)
          CommandChatPanel(
            onMinimize: () => setState(() => _commandPanelOpen = false),
            onSendCommand: (input) async {
              final cached = _commandPatternCache.match(input);
              if (cached != null) {
                return CommandAction.withAction(
                  action: cached.action,
                  params: cached.params,
                  message: '',
                );
              }
              return _commandChatService.parseCommand(input);
            },
            onExecuteAction: (action) async {
              final registry = _buildCommandRegistry();
              return registry.execute(
                action.action!,
                action.params ?? {},
              );
            },
            onCachePattern: (input, action, params) {
              _commandPatternCache.store(
                input: input,
                action: action,
                params: params,
              );
            },
          ),
        // Command assistant FAB
        CommandChatFab(
          onTap: () => setState(() => _commandPanelOpen = !_commandPanelOpen),
          isDashboard: _currentIndex == 0,
          isExpanded: _commandPanelOpen,
          showTour: !_onboardingState.isTourDone('command_assistant'),
          onTourComplete: () => _markTourDone('command_assistant'),
        ),
      ],
    );
  }
}
