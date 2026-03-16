// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get navBudget => 'Budget';

  @override
  String get navGrocery => 'Grocery';

  @override
  String get navList => 'List';

  @override
  String get navCoach => 'Coach';

  @override
  String get navMeals => 'Meals';

  @override
  String get navBudgetTooltip => 'Monthly budget overview';

  @override
  String get navGroceryTooltip => 'Product catalogue';

  @override
  String get navListTooltip => 'Shopping list';

  @override
  String get navCoachTooltip => 'AI financial coach';

  @override
  String get navMealsTooltip => 'Meal planner';

  @override
  String get appTitle => 'Monthly Budget';

  @override
  String get loading => 'Loading...';

  @override
  String get loadingApp => 'Loading application';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get clear => 'Clear';

  @override
  String errorSavingPurchase(String error) {
    return 'Error saving purchase: $error';
  }

  @override
  String filterBy(String label) {
    return 'Filter by $label';
  }

  @override
  String addToList(String name) {
    return 'Add $name to list';
  }

  @override
  String get enumMaritalSolteiro => 'Single';

  @override
  String get enumMaritalCasado => 'Married';

  @override
  String get enumMaritalUniaoFacto => 'Domestic partnership';

  @override
  String get enumMaritalDivorciado => 'Divorced';

  @override
  String get enumMaritalViuvo => 'Widowed';

  @override
  String get enumSubsidyNone => 'No subsidies';

  @override
  String get enumSubsidyFull => 'With subsidies';

  @override
  String get enumSubsidyHalf => '50% subsidies';

  @override
  String get enumSubsidyNoneShort => 'None';

  @override
  String get enumSubsidyFullShort => 'Full';

  @override
  String get enumSubsidyHalfShort => '50%';

  @override
  String get enumMealAllowanceNone => 'None';

  @override
  String get enumMealAllowanceCard => 'Card';

  @override
  String get enumMealAllowanceCash => 'Cash';

  @override
  String get enumCatTelecomunicacoes => 'Telecom';

  @override
  String get enumCatEnergia => 'Energy';

  @override
  String get enumCatAgua => 'Water';

  @override
  String get enumCatAlimentacao => 'Food';

  @override
  String get enumCatEducacao => 'Education';

  @override
  String get enumCatHabitacao => 'Housing';

  @override
  String get enumCatTransportes => 'Transport';

  @override
  String get enumCatSaude => 'Health';

  @override
  String get enumCatLazer => 'Leisure';

  @override
  String get enumCatOutros => 'Other';

  @override
  String get enumChartExpensesPie => 'Expenses by Category';

  @override
  String get enumChartIncomeVsExpenses => 'Income vs Expenses';

  @override
  String get enumChartNetIncome => 'Net Income';

  @override
  String get enumChartDeductions => 'Deductions (Tax + Social)';

  @override
  String get enumChartSavingsRate => 'Savings Rate';

  @override
  String get enumMealBreakfast => 'Breakfast';

  @override
  String get enumMealLunch => 'Lunch';

  @override
  String get enumMealSnack => 'Snack';

  @override
  String get enumMealDinner => 'Dinner';

  @override
  String get enumObjMinimizeCost => 'Minimize cost';

  @override
  String get enumObjBalancedHealth => 'Cost/health balance';

  @override
  String get enumObjHighProtein => 'High protein';

  @override
  String get enumObjLowCarb => 'Low carb';

  @override
  String get enumObjVegetarian => 'Vegetarian';

  @override
  String get enumEquipOven => 'Oven';

  @override
  String get enumEquipAirFryer => 'Air Fryer';

  @override
  String get enumEquipFoodProcessor => 'Food processor';

  @override
  String get enumEquipPressureCooker => 'Pressure cooker';

  @override
  String get enumEquipMicrowave => 'Microwave';

  @override
  String get enumEquipBimby => 'Bimby / Thermomix';

  @override
  String get enumSodiumNoRestriction => 'No restriction';

  @override
  String get enumSodiumReduced => 'Reduced sodium';

  @override
  String get enumSodiumLow => 'Low sodium';

  @override
  String get enumAge0to3 => '0–3 years';

  @override
  String get enumAge4to10 => '4–10 years';

  @override
  String get enumAgeTeen => 'Teenager';

  @override
  String get enumAgeAdult => 'Adult';

  @override
  String get enumAgeSenior => 'Senior (65+)';

  @override
  String get enumActivitySedentary => 'Sedentary';

  @override
  String get enumActivityModerate => 'Moderate';

  @override
  String get enumActivityActive => 'Active';

  @override
  String get enumActivityVeryActive => 'Very active';

  @override
  String get enumMedDiabetes => 'Diabetes';

  @override
  String get enumMedHypertension => 'Hypertension';

  @override
  String get enumMedHighCholesterol => 'High cholesterol';

  @override
  String get enumMedGout => 'Gout';

  @override
  String get enumMedIbs => 'Irritable bowel syndrome';

  @override
  String get stressExcellent => 'Excellent';

  @override
  String get stressGood => 'Good';

  @override
  String get stressWarning => 'Warning';

  @override
  String get stressCritical => 'Critical';

  @override
  String get stressFactorSavings => 'Savings rate';

  @override
  String get stressFactorSafety => 'Safety margin';

  @override
  String get stressFactorFood => 'Food budget';

  @override
  String get stressFactorStability => 'Expense stability';

  @override
  String get stressStable => 'Stable';

  @override
  String get stressHigh => 'High';

  @override
  String stressUsed(String percent) {
    return '$percent% used';
  }

  @override
  String get stressNA => 'N/A';

  @override
  String monthReviewFoodExceeded(String percent) {
    return 'Food exceeded budget by $percent% — consider reviewing portions or shopping frequency.';
  }

  @override
  String monthReviewExpensesExceeded(String amount) {
    return 'Actual expenses exceeded planned by $amount€ — adjust values in settings?';
  }

  @override
  String monthReviewSavedMore(String amount) {
    return 'Saved $amount€ more than expected — consider boosting emergency fund.';
  }

  @override
  String get monthReviewOnTrack =>
      'Expenses within budget. Good financial control.';

  @override
  String get dashboardTitle => 'Monthly Budget';

  @override
  String get dashboardViewFullReport => 'View Full Report';

  @override
  String get dashboardStressIndex => 'Serenity Index';

  @override
  String get dashboardTension => 'Tension';

  @override
  String get dashboardLiquidity => 'Liquidity';

  @override
  String get dashboardFinalPosition => 'Final Position';

  @override
  String get dashboardMonth => 'Month';

  @override
  String get dashboardGross => 'Gross';

  @override
  String get dashboardNet => 'Net';

  @override
  String get dashboardExpenses => 'Expenses';

  @override
  String get dashboardSavingsRate => 'Savings Rate';

  @override
  String get dashboardViewTrends => 'View trends';

  @override
  String get dashboardViewProjection => 'View projection';

  @override
  String get dashboardFinancialSummary => 'FINANCIAL SUMMARY';

  @override
  String get dashboardOpenSettings => 'Open settings';

  @override
  String get dashboardMonthlyLiquidity => 'MONTHLY LIQUIDITY';

  @override
  String get dashboardPositiveBalance => 'Positive balance';

  @override
  String get dashboardNegativeBalance => 'Negative balance';

  @override
  String dashboardHeroLabel(String amount, String status) {
    return 'Monthly liquidity: $amount, $status';
  }

  @override
  String get dashboardConfigureData => 'Set up your data to see the summary.';

  @override
  String get dashboardOpenSettingsButton => 'Open Settings';

  @override
  String get dashboardGrossIncome => 'Gross Income';

  @override
  String get dashboardNetIncome => 'Net Income';

  @override
  String dashboardInclMealAllowance(String amount) {
    return 'Incl. meal allow.: $amount';
  }

  @override
  String get dashboardDeductions => 'Deductions';

  @override
  String dashboardIrsSs(String irs, String ss) {
    return 'Tax: $irs | Social: $ss';
  }

  @override
  String dashboardExpensesAmount(String amount) {
    return 'Expenses: $amount';
  }

  @override
  String get dashboardSalaryDetail => 'SALARY BREAKDOWN';

  @override
  String dashboardSalaryN(int n) {
    return 'Salary $n';
  }

  @override
  String get dashboardFood => 'FOOD';

  @override
  String get dashboardSimulate => 'Simulate';

  @override
  String get dashboardBudgeted => 'Budgeted';

  @override
  String get dashboardSpent => 'Spent';

  @override
  String get dashboardRemaining => 'Remaining';

  @override
  String get dashboardFinalizePurchaseHint =>
      'Finalize a purchase in the List to record spending.';

  @override
  String get dashboardPurchaseHistory => 'PURCHASE HISTORY';

  @override
  String get dashboardViewAll => 'View all';

  @override
  String get dashboardAllPurchases => 'All Purchases';

  @override
  String dashboardPurchaseLabel(String date, String amount) {
    return 'Purchase on $date, $amount';
  }

  @override
  String dashboardProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
    );
    return '$_temp0';
  }

  @override
  String get dashboardMonthlyExpenses => 'MONTHLY EXPENSES';

  @override
  String get dashboardTotal => 'Total';

  @override
  String get dashboardGrossWithSubsidy => 'Gross w/ subsidies';

  @override
  String dashboardIrsRate(String rate) {
    return 'Tax ($rate)';
  }

  @override
  String get dashboardSsRate => 'Social Sec. (11%)';

  @override
  String get dashboardMealAllowance => 'Meal Allowance';

  @override
  String get dashboardExemptIncome => 'Exempt Income';

  @override
  String get dashboardDetails => 'Details';

  @override
  String dashboardVsLastMonth(String delta) {
    return '$delta vs last month';
  }

  @override
  String get dashboardPaceWarning => 'Spending faster than planned';

  @override
  String get dashboardPaceCritical => 'Risk of exceeding food budget';

  @override
  String get dashboardPace => 'Pace';

  @override
  String get dashboardProjection => 'Projection';

  @override
  String dashboardPaceValue(String actual, String expected) {
    return '$actual€/day vs $expected€/day';
  }

  @override
  String get dashboardSummaryLabel => '— SUMMARY';

  @override
  String get dashboardViewMonthSummary => 'View month summary';

  @override
  String get coachTitle => 'Financial Coach';

  @override
  String get coachSubtitle => 'AI · GPT-4o mini';

  @override
  String get coachApiKeyRequired =>
      'Add your OpenAI API key in Settings to use this feature.';

  @override
  String get coachAnalysisTitle => 'Financial analysis in 3 parts';

  @override
  String get coachAnalysisDescription =>
      'General positioning · Critical factors of the Serenity Index · Immediate opportunity. Based on your real budget, expense and purchase history data.';

  @override
  String get coachConfigureApiKey => 'Configure API key in Settings';

  @override
  String get coachApiKeyConfigured => 'API key configured';

  @override
  String get coachAnalyzeButton => 'Analyze my budget';

  @override
  String get coachAnalyzing => 'Analyzing...';

  @override
  String get coachCustomAnalysis => 'Personalized analysis';

  @override
  String get coachNewAnalysis => 'Generate new analysis';

  @override
  String get coachHistory => 'HISTORY';

  @override
  String get coachClearAll => 'Clear all';

  @override
  String get coachClearTitle => 'Clear history';

  @override
  String get coachClearContent =>
      'Are you sure you want to delete all saved analyses?';

  @override
  String get coachDeleteLabel => 'Delete analysis';

  @override
  String get coachDeleteTooltip => 'Delete';

  @override
  String get coachEmptyTitle => 'Your financial coach';

  @override
  String get coachEmptyBody =>
      'Ask anything about your budget, expenses, or savings. I\'ll use your real data to give personalized advice.';

  @override
  String get coachQuickPrompt1 => 'Where can I cut expenses this month?';

  @override
  String get coachQuickPrompt2 => 'How can I improve my savings?';

  @override
  String get coachQuickPrompt3 => 'Help me build a 30-day plan.';

  @override
  String get coachComposerHint => 'Ask your coach...';

  @override
  String get coachYou => 'You';

  @override
  String get coachAssistant => 'Coach';

  @override
  String coachCreditsCount(int count) {
    return '$count credits';
  }

  @override
  String get coachMemory => 'Memory';

  @override
  String get coachCostFree => 'Eco mode — no credits used.';

  @override
  String coachCostCredits(int cost) {
    return 'This message costs $cost credits.';
  }

  @override
  String get coachFree => 'Free';

  @override
  String coachPerMsg(int cost) {
    return '$cost/msg';
  }

  @override
  String get coachEcoFallbackTitle => 'Eco mode active (no credits)';

  @override
  String get coachEcoFallbackBody =>
      'You can keep chatting with reduced memory.';

  @override
  String get coachRestoreMemory => 'Restore memory';

  @override
  String get cmdAssistantTitle => 'Assistant';

  @override
  String get cmdAssistantHint => 'What do you need?';

  @override
  String get cmdAssistantTooltip => 'Need help? Tap here';

  @override
  String get cmdSuggestionAddExpense => 'Add expense';

  @override
  String get cmdSuggestionOpenList => 'Open shopping list';

  @override
  String get cmdSuggestionChangeTheme => 'Change theme';

  @override
  String get cmdSuggestionOpenSettings => 'Go to settings';

  @override
  String get cmdTemplateAddExpense => 'Add [amount] euros in [category]';

  @override
  String get cmdTemplateChangeTheme => 'Change theme to [light/dark]';

  @override
  String get cmdExecutionFailed =>
      'I understood the request, but couldn\'t execute it. Try again.';

  @override
  String get cmdNotUnderstood => 'I didn\'t understand. Can you rephrase?';

  @override
  String get cmdUndo => 'Undo';

  @override
  String get expenseDeleted => 'Expense deleted';

  @override
  String get cmdCapabilitiesCta => 'What can I do?';

  @override
  String get cmdCapabilitiesTitle => 'Available actions';

  @override
  String get cmdCapabilitiesSubtitle =>
      'These are the assistant actions supported right now.';

  @override
  String get cmdCapabilitiesFooter =>
      'We\'re still adding more. If it isn\'t listed here yet, it may not work.';

  @override
  String get cmdCapabilityAddExpense => 'Add an expense';

  @override
  String get cmdCapabilityAddExpenseExample =>
      'Add [amount] euros in [category]';

  @override
  String get cmdCapabilityAddShoppingItem => 'Add a shopping item';

  @override
  String get cmdCapabilityAddShoppingItemExample =>
      'Add [item] to shopping list';

  @override
  String get cmdCapabilityRemoveShoppingItem => 'Remove a shopping item';

  @override
  String get cmdCapabilityRemoveShoppingItemExample =>
      'Remove [item] from shopping list';

  @override
  String get cmdCapabilityToggleShoppingItemChecked =>
      'Check or uncheck a shopping item';

  @override
  String get cmdCapabilityToggleShoppingItemCheckedExample =>
      'Mark [item] on shopping list';

  @override
  String get cmdCapabilityAddSavingsGoal => 'Create a savings goal';

  @override
  String get cmdCapabilityAddSavingsGoalExample =>
      'Create savings goal [name] with [amount]';

  @override
  String get cmdCapabilityAddSavingsContribution => 'Add to a savings goal';

  @override
  String get cmdCapabilityAddSavingsContributionExample =>
      'Add [amount] to goal [name]';

  @override
  String get cmdCapabilityAddRecurringExpense => 'Add a recurring expense';

  @override
  String get cmdCapabilityAddRecurringExpenseExample =>
      'Add recurring expense [amount] in [category] day [day]';

  @override
  String get cmdCapabilityDeleteExpense => 'Delete an expense';

  @override
  String get cmdCapabilityDeleteExpenseExample =>
      'Delete expense [description]';

  @override
  String get cmdCapabilityChangeTheme => 'Change theme';

  @override
  String get cmdCapabilityChangeThemeExample => 'Change theme to [light/dark]';

  @override
  String get cmdCapabilityChangePalette => 'Change color palette';

  @override
  String get cmdCapabilityChangePaletteExample =>
      'Color [ocean/emerald/violet/teal/sunset]';

  @override
  String get cmdCapabilityChangeLanguage => 'Change language';

  @override
  String get cmdCapabilityChangeLanguageExample =>
      'Language [english/portuguese/spanish/french]';

  @override
  String get cmdCapabilityNavigate => 'Open a screen';

  @override
  String get cmdCapabilityNavigateExample => 'Open shopping list';

  @override
  String get cmdCapabilityClearChecked => 'Clear checked items';

  @override
  String get cmdCapabilityClearCheckedExample => 'Clear checked items';

  @override
  String get groceryTitle => 'Grocery';

  @override
  String get grocerySearchHint => 'Search product...';

  @override
  String get groceryLoadingLabel => 'Loading products';

  @override
  String get groceryLoadingMessage => 'Loading products...';

  @override
  String get groceryAll => 'All';

  @override
  String groceryProductCount(int count) {
    return '$count products';
  }

  @override
  String groceryAddedToList(String name) {
    return '$name added to list';
  }

  @override
  String groceryAvgPrice(String unit) {
    return '$unit · average price';
  }

  @override
  String get groceryAvailabilityTitle => 'Data availability';

  @override
  String groceryAvailabilityCountry(String countryCode) {
    return 'Market: $countryCode';
  }

  @override
  String groceryAvailabilitySummary(int fresh, int partial, int failed) {
    return '$fresh fresh · $partial partial · $failed unavailable';
  }

  @override
  String get groceryAvailabilityWarning =>
      'Some stores have stale or partial data. Comparisons may be incomplete.';

  @override
  String get groceryEmptyStateTitle => 'No grocery data available';

  @override
  String get groceryEmptyStateMessage =>
      'Try again later or switch market in settings.';

  @override
  String get shoppingTitle => 'Shopping List';

  @override
  String get shoppingEmpty => 'Empty list';

  @override
  String get shoppingEmptyMessage => 'Add products from the\nGrocery screen.';

  @override
  String shoppingItemsRemaining(int count, String total) {
    return '$count to buy · $total';
  }

  @override
  String get shoppingClear => 'Clear';

  @override
  String get shoppingFinalize => 'Finalize Purchase';

  @override
  String get shoppingEstimatedTotal => 'Estimated total';

  @override
  String get shoppingHowMuchSpent => 'HOW MUCH DID I SPEND? (optional)';

  @override
  String get shoppingConfirm => 'Confirm';

  @override
  String get shoppingHistoryTooltip => 'Purchase history';

  @override
  String get shoppingHistoryTitle => 'Purchase History';

  @override
  String shoppingItemChecked(String name) {
    return '$name, purchased';
  }

  @override
  String shoppingItemSwipe(String name) {
    return '$name, swipe to remove';
  }

  @override
  String shoppingProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
    );
    return '$_temp0';
  }

  @override
  String get shoppingViewItems => 'Items';

  @override
  String get shoppingViewMeals => 'Meals';

  @override
  String get shoppingViewStores => 'Stores';

  @override
  String get shoppingGroupOther => 'Other';

  @override
  String shoppingGroupCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String shoppingCheapestAt(String store, String price) {
    return 'Cheapest at $store ($price)';
  }

  @override
  String get authLogin => 'Sign in';

  @override
  String get authRegister => 'Create account';

  @override
  String get authEmail => 'Email';

  @override
  String get authEmailHint => 'example@email.com';

  @override
  String get authPassword => 'Password';

  @override
  String get authLoginButton => 'Sign in';

  @override
  String get authRegisterButton => 'Register';

  @override
  String get authSwitchToRegister => 'Create new account';

  @override
  String get authSwitchToLogin => 'Already have an account';

  @override
  String get authRegistrationSuccess =>
      'Account created! Check your email to verify your account before signing in.';

  @override
  String get authErrorNetwork =>
      'Could not connect to the server. Check your internet connection and try again.';

  @override
  String get authErrorInvalidCredentials =>
      'Invalid email or password. Please try again.';

  @override
  String get authErrorEmailNotConfirmed =>
      'Please verify your email before signing in.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get authErrorGeneric =>
      'Something went wrong. Please try again later.';

  @override
  String get householdSetupTitle => 'Set Up Household';

  @override
  String get householdCreate => 'Create';

  @override
  String get householdJoinWithCode => 'Join with code';

  @override
  String get householdNameLabel => 'Household name';

  @override
  String get householdNameHint => 'e.g.: Smith Family';

  @override
  String get householdCodeLabel => 'Invite code';

  @override
  String get householdCodeHint => 'XXXXXX';

  @override
  String get householdCreateButton => 'Create Household';

  @override
  String get householdJoinButton => 'Join Household';

  @override
  String get householdNameRequired => 'Please enter the household name.';

  @override
  String get chartExpensesByCategory => 'Expenses by Category';

  @override
  String get chartIncomeVsExpenses => 'Income vs Expenses';

  @override
  String get chartDeductions => 'Deductions (Tax + Social Security)';

  @override
  String get chartGrossVsNet => 'Gross vs Net Income';

  @override
  String get chartSavingsRate => 'Savings Rate';

  @override
  String get chartNetIncome => 'Net Inc.';

  @override
  String get chartExpensesLabel => 'Expenses';

  @override
  String get chartLiquidity => 'Liquidity';

  @override
  String chartSalaryN(int n) {
    return 'Salary $n';
  }

  @override
  String get chartGross => 'Gross';

  @override
  String get chartNet => 'Net';

  @override
  String get chartNetSalary => 'Net Salary';

  @override
  String get chartIRS => 'Income Tax';

  @override
  String get chartSocialSecurity => 'Social Sec.';

  @override
  String get chartSavings => 'savings';

  @override
  String projectionTitle(String month, String year) {
    return 'Projection — $month $year';
  }

  @override
  String projectionSubtitle(String spent, String budget, String days) {
    return 'Spent $spent of $budget in $days days';
  }

  @override
  String get projectionFood => 'FOOD';

  @override
  String get projectionCurrentPace => 'Current pace';

  @override
  String get projectionNoShopping => 'No shopping';

  @override
  String get projectionReduce20 => '-20%';

  @override
  String projectionDailySpend(String amount) {
    return 'Estimated daily spend: $amount/day';
  }

  @override
  String get projectionEndOfMonth => 'End of month projection';

  @override
  String get projectionRemaining => 'Projected remaining';

  @override
  String get projectionStressImpact => 'Index impact';

  @override
  String get projectionExpenses => 'EXPENSES';

  @override
  String get projectionSimulation => 'Simulation — not saved';

  @override
  String get projectionReduceAll => 'Reduce all by ';

  @override
  String get projectionSimLiquidity => 'Simulated liquidity';

  @override
  String get projectionDelta => 'Delta';

  @override
  String get projectionSimSavingsRate => 'Simulated savings rate';

  @override
  String get projectionSimIndex => 'Simulated index';

  @override
  String get trendTitle => 'Trends';

  @override
  String get trendStressIndex => 'SERENITY INDEX';

  @override
  String get trendTotalExpenses => 'TOTAL EXPENSES';

  @override
  String get trendExpensesByCategory => 'EXPENSES BY CATEGORY';

  @override
  String trendCurrent(String amount) {
    return 'Current: $amount';
  }

  @override
  String get trendCatTelecom => 'Telecom';

  @override
  String get trendCatEnergy => 'Energy';

  @override
  String get trendCatWater => 'Water';

  @override
  String get trendCatFood => 'Food';

  @override
  String get trendCatEducation => 'Education';

  @override
  String get trendCatHousing => 'Housing';

  @override
  String get trendCatTransport => 'Transport';

  @override
  String get trendCatHealth => 'Health';

  @override
  String get trendCatLeisure => 'Leisure';

  @override
  String get trendCatOther => 'Other';

  @override
  String monthReviewTitle(String month) {
    return 'Summary — $month';
  }

  @override
  String get monthReviewPlanned => 'Planned';

  @override
  String get monthReviewActual => 'Actual';

  @override
  String get monthReviewDifference => 'Difference';

  @override
  String get monthReviewFood => 'Food';

  @override
  String monthReviewFoodValue(String actual, String budget) {
    return '$actual of $budget';
  }

  @override
  String get monthReviewTopDeviations => 'TOP DEVIATIONS';

  @override
  String get monthReviewSuggestions => 'SUGGESTIONS';

  @override
  String get monthReviewAiAnalysis => 'Detailed AI analysis';

  @override
  String get mealPlannerTitle => 'Meal Planner';

  @override
  String get mealBudgetLabel => 'Food budget';

  @override
  String get mealPeopleLabel => 'Household members';

  @override
  String get mealGeneratePlan => 'Generate Monthly Plan';

  @override
  String get mealGenerating => 'Generating...';

  @override
  String get mealRegenerateTitle => 'Regenerate plan?';

  @override
  String get mealRegenerateContent => 'The current plan will be replaced.';

  @override
  String get mealRegenerate => 'Regenerate';

  @override
  String mealWeekLabel(int n) {
    return 'Week $n';
  }

  @override
  String mealWeekAbbr(int n) {
    return 'Wk.$n';
  }

  @override
  String get mealAddWeekToList => 'Add week to list';

  @override
  String mealIngredientsAdded(int count) {
    return '$count ingredients added to list';
  }

  @override
  String mealDayLabel(int n) {
    return 'Day $n';
  }

  @override
  String get mealIngredients => 'Ingredients';

  @override
  String get mealPreparation => 'Preparation';

  @override
  String get mealSwap => 'Swap';

  @override
  String get mealConsolidatedList => 'View consolidated list';

  @override
  String get mealConsolidatedTitle => 'Consolidated List';

  @override
  String get mealAlternatives => 'Alternatives';

  @override
  String mealTotalCost(String cost) {
    return '$cost€ total';
  }

  @override
  String get mealCatProteins => 'Proteins';

  @override
  String get mealCatVegetables => 'Vegetables';

  @override
  String get mealCatCarbs => 'Carbs';

  @override
  String get mealCatFats => 'Fats';

  @override
  String get mealCatCondiments => 'Condiments';

  @override
  String mealCostPerPerson(String cost) {
    return '$cost€/pp';
  }

  @override
  String get mealNutriProt => 'prot';

  @override
  String get mealNutriCarbs => 'carbs';

  @override
  String get mealNutriFat => 'fat';

  @override
  String get mealNutriFiber => 'fiber';

  @override
  String get wizardStepMeals => 'Meals';

  @override
  String get wizardStepObjective => 'Objective';

  @override
  String get wizardStepRestrictions => 'Restrictions';

  @override
  String get wizardStepKitchen => 'Kitchen';

  @override
  String get wizardStepStrategy => 'Strategy';

  @override
  String get wizardMealsQuestion =>
      'Which meals do you want to include in the daily plan?';

  @override
  String wizardBudgetWeight(String weight) {
    return '$weight of budget';
  }

  @override
  String get wizardObjectiveQuestion =>
      'What is the main objective of your meal plan?';

  @override
  String wizardSelected(String label) {
    return '$label, selected';
  }

  @override
  String get wizardDietaryRestrictions => 'DIETARY RESTRICTIONS';

  @override
  String get wizardGlutenFree => 'Gluten-free';

  @override
  String get wizardLactoseFree => 'Lactose-free';

  @override
  String get wizardNutFree => 'Nut-free';

  @override
  String get wizardShellfishFree => 'Shellfish-free';

  @override
  String get wizardDislikedIngredients => 'INGREDIENTS YOU DISLIKE';

  @override
  String get wizardDislikedHint => 'e.g.: tuna, broccoli';

  @override
  String get wizardMaxPrepTime => 'MAXIMUM PREP TIME PER MEAL';

  @override
  String get wizardMaxComplexity => 'MAXIMUM COMPLEXITY';

  @override
  String get wizardComplexityEasy => 'Easy';

  @override
  String get wizardComplexityMedium => 'Medium';

  @override
  String get wizardComplexityAdvanced => 'Advanced';

  @override
  String get wizardEquipment => 'AVAILABLE EQUIPMENT';

  @override
  String get wizardBatchCooking => 'Batch cooking';

  @override
  String get wizardBatchCookingDesc => 'Cook for multiple days at once';

  @override
  String get wizardMaxBatchDays => 'MAXIMUM DAYS PER RECIPE';

  @override
  String wizardBatchDays(int days) {
    return '$days days';
  }

  @override
  String get wizardPreferredCookingDay => 'PREFERRED COOKING DAY';

  @override
  String get wizardReuseLeftovers => 'Reuse leftovers';

  @override
  String get wizardReuseLeftoversDesc =>
      'Yesterday\'s dinner = today\'s lunch (zero cost)';

  @override
  String get wizardMaxNewIngredients => 'MAXIMUM NEW INGREDIENTS PER WEEK';

  @override
  String get wizardNoLimit => 'No limit';

  @override
  String get wizardMinimizeWaste => 'Minimize waste';

  @override
  String get wizardMinimizeWasteDesc =>
      'Prefer recipes that reuse ingredients already used';

  @override
  String get wizardSettingsInfo =>
      'You can change planner settings anytime in Settings → Meals.';

  @override
  String get wizardContinue => 'Continue';

  @override
  String get wizardGeneratePlan => 'Generate Plan';

  @override
  String wizardStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get wizardWeekdayMon => 'Mon';

  @override
  String get wizardWeekdayTue => 'Tue';

  @override
  String get wizardWeekdayWed => 'Wed';

  @override
  String get wizardWeekdayThu => 'Thu';

  @override
  String get wizardWeekdayFri => 'Fri';

  @override
  String get wizardWeekdaySat => 'Sat';

  @override
  String get wizardWeekdaySun => 'Sun';

  @override
  String wizardPrepMin(int mins) {
    return '${mins}min';
  }

  @override
  String get wizardPrepMin60Plus => '60+';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPersonal => 'Personal Data';

  @override
  String get settingsSalaries => 'Salaries';

  @override
  String get settingsExpenses => 'Budget & Recurring Payments';

  @override
  String get settingsCoachAi => 'AI Coach';

  @override
  String get settingsDashboard => 'Dashboard';

  @override
  String get settingsMeals => 'Meals';

  @override
  String get settingsRegion => 'Region & Language';

  @override
  String get settingsCountry => 'Country';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsMaritalStatus => 'Marital status';

  @override
  String get settingsDependents => 'Dependents';

  @override
  String get settingsDisability => 'Disability';

  @override
  String get settingsGrossSalary => 'Gross salary';

  @override
  String get settingsTitulares => 'Tax holders';

  @override
  String get settingsSubsidyMode => 'Subsidies';

  @override
  String get settingsMealAllowance => 'Meal allowance';

  @override
  String get settingsMealAllowancePerDay => 'Amount/day';

  @override
  String get settingsWorkingDays => 'Working days/month';

  @override
  String get settingsOtherExemptIncome => 'Other exempt income';

  @override
  String get settingsAddSalary => 'Add salary';

  @override
  String get settingsAddExpense => 'Add category';

  @override
  String get settingsExpenseName => 'Category name';

  @override
  String get settingsExpenseAmount => 'Amount';

  @override
  String get settingsExpenseCategory => 'Category';

  @override
  String get settingsApiKey => 'OpenAI API Key';

  @override
  String get settingsInviteCode => 'Invite code';

  @override
  String get settingsCopyCode => 'Copy';

  @override
  String get settingsCodeCopied => 'Code copied!';

  @override
  String get settingsAdminOnly => 'Only the administrator can edit settings.';

  @override
  String get settingsShowSummaryCards => 'Show summary cards';

  @override
  String get settingsEnabledCharts => 'Active charts';

  @override
  String get settingsLogout => 'Sign out';

  @override
  String get settingsLogoutConfirmTitle => 'Sign out';

  @override
  String get settingsLogoutConfirmContent =>
      'Are you sure you want to sign out?';

  @override
  String get settingsLogoutConfirmButton => 'Sign out';

  @override
  String get settingsSalariesSection => 'Income';

  @override
  String get settingsExpensesMonthly => 'Budget & Recurring Payments';

  @override
  String get settingsFavorites => 'Favorite Products';

  @override
  String get settingsCoachOpenAi => 'AI Coach (OpenAI)';

  @override
  String get settingsHousehold => 'Household';

  @override
  String get settingsMaritalStatusLabel => 'MARITAL STATUS';

  @override
  String get settingsDependentsLabel => 'NUMBER OF DEPENDENTS';

  @override
  String settingsSocialSecurityRate(String rate) {
    return 'Social Security: $rate';
  }

  @override
  String get settingsSalaryActive => 'Active';

  @override
  String get settingsGrossMonthlySalary => 'GROSS MONTHLY SALARY';

  @override
  String get settingsSubsidyHoliday =>
      'HOLIDAY & CHRISTMAS SUBSIDIES (TWELFTHS)';

  @override
  String get settingsOtherExemptLabel => 'OTHER TAX-EXEMPT INCOME';

  @override
  String get settingsMealAllowanceLabel => 'MEAL ALLOWANCE';

  @override
  String get settingsAmountPerDay => 'AMOUNT/DAY';

  @override
  String get settingsDaysPerMonth => 'DAYS/MONTH';

  @override
  String get settingsTitularesLabel => 'TAX HOLDERS';

  @override
  String settingsTitularCount(int n, String suffix) {
    return '$n Holder$suffix';
  }

  @override
  String get settingsAddSalaryButton => 'Add salary';

  @override
  String get settingsAddExpenseButton => 'Add Category';

  @override
  String get settingsDeviceLocal =>
      'These settings are stored locally on this device.';

  @override
  String get settingsVisibleSections => 'VISIBLE SECTIONS';

  @override
  String get settingsMinimalist => 'Minimalist';

  @override
  String get settingsFull => 'Full';

  @override
  String get settingsDashMonthlyLiquidity => 'Monthly liquidity';

  @override
  String get settingsDashStressIndex => 'Serenity Index';

  @override
  String get settingsDashSummaryCards => 'Summary cards';

  @override
  String get settingsDashSalaryBreakdown => 'Salary breakdown';

  @override
  String get settingsDashFood => 'Food';

  @override
  String get settingsDashPurchaseHistory => 'Purchase history';

  @override
  String get settingsDashExpensesBreakdown => 'Expenses breakdown';

  @override
  String get settingsDashMonthReview => 'Month review';

  @override
  String get settingsDashCharts => 'Charts';

  @override
  String get dashGroupOverview => 'OVERVIEW';

  @override
  String get dashGroupFinancialDetail => 'FINANCIAL DETAIL';

  @override
  String get dashGroupHistory => 'HISTORY';

  @override
  String get dashGroupCharts => 'CHARTS';

  @override
  String get settingsVisibleCharts => 'VISIBLE CHARTS';

  @override
  String get settingsFavTip =>
      'Favorite products influence the meal plan — recipes with those ingredients get priority.';

  @override
  String get settingsMyFavorites => 'MY FAVORITES';

  @override
  String get settingsProductCatalog => 'PRODUCT CATALOG';

  @override
  String get settingsSearchProduct => 'Search product...';

  @override
  String get settingsLoadingProducts => 'Loading products...';

  @override
  String get settingsAddIngredient => 'Add ingredient';

  @override
  String get settingsIngredientName => 'Ingredient name';

  @override
  String get settingsAddButton => 'Add';

  @override
  String get settingsAddToPantry => 'Add to pantry';

  @override
  String get settingsHouseholdPeople => 'HOUSEHOLD (PEOPLE)';

  @override
  String get settingsAutomatic => '(auto)';

  @override
  String get settingsUseAutoValue => 'Use automatic value';

  @override
  String settingsManualValue(int count) {
    return 'Manual value: $count people';
  }

  @override
  String settingsAutoValue(int count) {
    return 'Calculated automatically: $count (holders + dependents)';
  }

  @override
  String get settingsHouseholdMembers => 'HOUSEHOLD MEMBERS';

  @override
  String get settingsPortions => 'portions';

  @override
  String settingsTotalEquivalent(String total) {
    return 'Total equivalent: $total portions';
  }

  @override
  String get settingsAddMember => 'Add member';

  @override
  String get settingsPreferSeasonal => 'Prefer seasonal recipes';

  @override
  String get settingsPreferSeasonalDesc =>
      'Prioritizes recipes from the current season';

  @override
  String get settingsNutritionalGoals => 'NUTRITIONAL GOALS';

  @override
  String get settingsCalorieHint => 'e.g.: 2000';

  @override
  String get settingsKcalPerDay => 'kcal/day';

  @override
  String get settingsProteinHint => 'e.g.: 60';

  @override
  String get settingsGramsPerDay => 'g/day';

  @override
  String get settingsFiberHint => 'e.g.: 25';

  @override
  String get settingsDailyProtein => 'Daily protein';

  @override
  String get settingsDailyFiber => 'Daily fiber';

  @override
  String get settingsMedicalConditions => 'MEDICAL CONDITIONS';

  @override
  String get settingsActiveMeals => 'ACTIVE MEALS';

  @override
  String get settingsObjective => 'OBJECTIVE';

  @override
  String get settingsVeggieDays => 'VEGETARIAN DAYS PER WEEK';

  @override
  String get settingsDietaryRestrictions => 'DIETARY RESTRICTIONS';

  @override
  String get settingsEggFree => 'Egg-free';

  @override
  String get settingsSodiumPref => 'SODIUM PREFERENCE';

  @override
  String get settingsDislikedIngredients => 'DISLIKED INGREDIENTS';

  @override
  String get settingsExcludedProteins => 'EXCLUDED PROTEINS';

  @override
  String get settingsProteinChicken => 'Chicken';

  @override
  String get settingsProteinGroundMeat => 'Ground Meat';

  @override
  String get settingsProteinPork => 'Pork';

  @override
  String get settingsProteinHake => 'Hake';

  @override
  String get settingsProteinCod => 'Cod';

  @override
  String get settingsProteinSardine => 'Sardine';

  @override
  String get settingsProteinTuna => 'Tuna';

  @override
  String get settingsProteinEgg => 'Eggs';

  @override
  String get settingsMaxPrepTime => 'MAX PREP TIME (MINUTES)';

  @override
  String settingsMaxComplexity(int value) {
    return 'MAX COMPLEXITY ($value/5)';
  }

  @override
  String get settingsWeekendPrepTime => 'WEEKEND PREP TIME (MINUTES)';

  @override
  String settingsWeekendComplexity(int value) {
    return 'WEEKEND COMPLEXITY ($value/5)';
  }

  @override
  String get settingsEatingOutDays => 'EATING OUT DAYS';

  @override
  String get settingsWeeklyDistribution => 'WEEKLY DISTRIBUTION';

  @override
  String settingsFishPerWeek(String count) {
    return 'Fish per week: $count';
  }

  @override
  String get settingsNoMinimum => 'no minimum';

  @override
  String settingsLegumePerWeek(String count) {
    return 'Legumes per week: $count';
  }

  @override
  String settingsRedMeatPerWeek(String count) {
    return 'Red meat max/week: $count';
  }

  @override
  String get settingsNoLimit => 'no limit';

  @override
  String get settingsAvailableEquipment => 'AVAILABLE EQUIPMENT';

  @override
  String get settingsBatchCooking => 'Batch cooking';

  @override
  String get settingsMaxBatchDays => 'MAX DAYS PER RECIPE';

  @override
  String get settingsReuseLeftovers => 'Reuse leftovers';

  @override
  String get settingsMinimizeWaste => 'Minimize waste';

  @override
  String get settingsPrioritizeLowCost => 'Prioritize low cost';

  @override
  String get settingsPrioritizeLowCostDesc => 'Prefer cheaper recipes';

  @override
  String settingsNewIngredientsPerWeek(int count) {
    return 'NEW INGREDIENTS PER WEEK ($count)';
  }

  @override
  String get settingsLunchboxLunches => 'Lunchbox lunches';

  @override
  String get settingsLunchboxLunchesDesc => 'Only portable recipes for lunch';

  @override
  String get settingsPantry => 'PANTRY (ALWAYS IN STOCK)';

  @override
  String get settingsResetWizard => 'Reset Wizard';

  @override
  String get settingsApiKeyInfo =>
      'The key is stored locally on the device and never shared. Uses GPT-4o mini model (~€0.00008 per analysis).';

  @override
  String get settingsInviteCodeLabel => 'INVITE CODE';

  @override
  String get settingsGenerateInvite => 'Generate invite code';

  @override
  String get settingsShareWithMembers => 'Share with household members';

  @override
  String get settingsNewCode => 'New code';

  @override
  String get settingsCodeValidInfo =>
      'The code is valid for 7 days. Share it with anyone you want to add to the household.';

  @override
  String get settingsName => 'Name';

  @override
  String get settingsAgeGroup => 'Age group';

  @override
  String get settingsActivityLevel => 'Activity level';

  @override
  String settingsSalaryN(int n) {
    return 'Salary $n';
  }

  @override
  String get countryPT => 'Portugal';

  @override
  String get countryES => 'Spain';

  @override
  String get countryFR => 'France';

  @override
  String get countryUK => 'United Kingdom';

  @override
  String get langPT => 'Português';

  @override
  String get langEN => 'English';

  @override
  String get langFR => 'Français';

  @override
  String get langES => 'Español';

  @override
  String get langSystem => 'System';

  @override
  String get taxIncomeTax => 'Income tax';

  @override
  String get taxSocialContribution => 'Social contribution';

  @override
  String get taxIRS => 'IRS';

  @override
  String get taxSS => 'Social Security';

  @override
  String get taxIRPF => 'IRPF';

  @override
  String get taxSSSpain => 'Social Security';

  @override
  String get taxIR => 'Income Tax';

  @override
  String get taxCSG => 'CSG + CRDS';

  @override
  String get taxPAYE => 'Income Tax';

  @override
  String get taxNI => 'National Insurance';

  @override
  String get enumSubsidyEsNone => 'No extra payments';

  @override
  String get enumSubsidyEsFull => 'With extra payments';

  @override
  String get enumSubsidyEsHalf => '50% extra payments';

  @override
  String get aiCoachSystemPrompt =>
      'You are a personal financial analyst for Portuguese users. Always respond in European Portuguese. Be direct and analytical — always use concrete numbers from the provided context. Structure the response exactly in the 3 requested parts. Do not introduce external data, benchmarks, or references not provided.';

  @override
  String get aiCoachInvalidApiKey => 'Invalid API key. Check in Settings.';

  @override
  String get aiCoachMidMonthSystem =>
      'You are a Portuguese household budget consultant. Always respond in European Portuguese. Be practical and direct.';

  @override
  String get aiMealPlannerSystem =>
      'You are a Portuguese chef. Always respond in European Portuguese. Respond ONLY with valid JSON, no extra text.';

  @override
  String get monthAbbrJan => 'Jan';

  @override
  String get monthAbbrFeb => 'Feb';

  @override
  String get monthAbbrMar => 'Mar';

  @override
  String get monthAbbrApr => 'Apr';

  @override
  String get monthAbbrMay => 'May';

  @override
  String get monthAbbrJun => 'Jun';

  @override
  String get monthAbbrJul => 'Jul';

  @override
  String get monthAbbrAug => 'Aug';

  @override
  String get monthAbbrSep => 'Sep';

  @override
  String get monthAbbrOct => 'Oct';

  @override
  String get monthAbbrNov => 'Nov';

  @override
  String get monthAbbrDec => 'Dec';

  @override
  String get monthFullJan => 'January';

  @override
  String get monthFullFeb => 'February';

  @override
  String get monthFullMar => 'March';

  @override
  String get monthFullApr => 'April';

  @override
  String get monthFullMay => 'May';

  @override
  String get monthFullJun => 'June';

  @override
  String get monthFullJul => 'July';

  @override
  String get monthFullAug => 'August';

  @override
  String get monthFullSep => 'September';

  @override
  String get monthFullOct => 'October';

  @override
  String get monthFullNov => 'November';

  @override
  String get monthFullDec => 'December';

  @override
  String get setupWizardWelcomeTitle => 'Welcome to your budget';

  @override
  String get setupWizardWelcomeSubtitle =>
      'Let\'s set up the essentials so your dashboard is ready to use.';

  @override
  String get setupWizardBullet1 => 'Calculate your net salary';

  @override
  String get setupWizardBullet2 => 'Organize your expenses';

  @override
  String get setupWizardBullet3 => 'See how much you have left each month';

  @override
  String get setupWizardReassurance =>
      'You can change everything later in settings.';

  @override
  String get setupWizardStart => 'Get started';

  @override
  String get setupWizardSkipAll => 'Skip setup';

  @override
  String setupWizardStepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get setupWizardContinue => 'Continue';

  @override
  String get setupWizardCountryTitle => 'Where do you live?';

  @override
  String get setupWizardCountrySubtitle =>
      'This sets the tax system, currency, and default values.';

  @override
  String get setupWizardLanguage => 'Language';

  @override
  String get setupWizardLangSystem => 'System default';

  @override
  String get setupWizardCountryPT => 'Portugal';

  @override
  String get setupWizardCountryES => 'Spain';

  @override
  String get setupWizardCountryFR => 'France';

  @override
  String get setupWizardCountryUK => 'United Kingdom';

  @override
  String get setupWizardPersonalTitle => 'Personal information';

  @override
  String get setupWizardPersonalSubtitle =>
      'We use this to calculate your taxes more accurately.';

  @override
  String get setupWizardPrivacyNote =>
      'Your data stays in your account and is never shared.';

  @override
  String get setupWizardSingle => 'Single';

  @override
  String get setupWizardMarried => 'Married';

  @override
  String get setupWizardDependents => 'Dependents';

  @override
  String get setupWizardTitulares => 'Tax holders';

  @override
  String get setupWizardSalaryTitle => 'What\'s your salary?';

  @override
  String get setupWizardSalarySubtitle =>
      'Enter your monthly gross amount. We\'ll calculate the net automatically.';

  @override
  String get setupWizardSalaryGross => 'Monthly gross salary';

  @override
  String setupWizardNetEstimate(String amount) {
    return 'Estimated net: $amount';
  }

  @override
  String get setupWizardSalaryMoreLater =>
      'You can add more income sources later.';

  @override
  String get setupWizardSalaryRequired => 'Please enter your salary';

  @override
  String get setupWizardSalaryPositive => 'Salary must be a positive number';

  @override
  String get setupWizardSalarySkip => 'Skip this step';

  @override
  String get setupWizardExpensesTitle => 'Your monthly expenses';

  @override
  String get setupWizardExpensesSubtitle =>
      'Suggested values for your country. Adjust as needed.';

  @override
  String get setupWizardExpensesMoreLater =>
      'You can add more categories later.';

  @override
  String setupWizardNetLabel(String amount) {
    return 'Net: $amount';
  }

  @override
  String setupWizardTotalExpenses(String amount) {
    return 'Expenses: $amount';
  }

  @override
  String setupWizardAvailableLabel(String amount) {
    return 'Available: $amount';
  }

  @override
  String get setupWizardFinish => 'Finish';

  @override
  String get setupWizardCompleteTitle => 'All set!';

  @override
  String get setupWizardCompleteReassurance =>
      'Your budget is configured. You can adjust everything in settings at any time.';

  @override
  String get setupWizardGoToDashboard => 'View my budget';

  @override
  String get setupWizardConfigureSalaryHint =>
      'Set up your salary in settings to see the full calculation.';

  @override
  String get setupWizardExpRent => 'Rent / Mortgage';

  @override
  String get setupWizardExpGroceries => 'Groceries';

  @override
  String get setupWizardExpTransport => 'Transport';

  @override
  String get setupWizardExpUtilities => 'Utilities (electricity, water, gas)';

  @override
  String get setupWizardExpTelecom => 'Telecom';

  @override
  String get setupWizardExpHealth => 'Health';

  @override
  String get setupWizardExpLeisure => 'Leisure';

  @override
  String get expenseTrackerTitle => 'BUDGET VS ACTUAL';

  @override
  String get expenseTrackerBudgeted => 'Budgeted';

  @override
  String get expenseTrackerActual => 'Actual';

  @override
  String get expenseTrackerRemaining => 'Remaining';

  @override
  String get expenseTrackerOver => 'Over budget';

  @override
  String get expenseTrackerViewAll => 'View details';

  @override
  String get expenseTrackerNoExpenses => 'No expenses recorded yet.';

  @override
  String get expenseTrackerScreenTitle => 'Expense Tracker';

  @override
  String expenseTrackerMonthTotal(String amount) {
    return 'Total: $amount';
  }

  @override
  String get expenseTrackerDeleteConfirm => 'Delete this expense?';

  @override
  String get expenseTrackerEmpty =>
      'No expenses this month.\nTap + to add your first expense.';

  @override
  String get addExpenseTitle => 'Add Expense';

  @override
  String get editExpenseTitle => 'Edit Expense';

  @override
  String get addExpenseCategory => 'Category';

  @override
  String get addExpenseAmount => 'Amount';

  @override
  String get addExpenseDate => 'Date';

  @override
  String get addExpenseDescription => 'Description (optional)';

  @override
  String get addExpenseCustomCategory => 'Custom category';

  @override
  String get addExpenseInvalidAmount => 'Enter a valid amount';

  @override
  String get addExpenseTooltip => 'Log expense';

  @override
  String get addExpenseItem => 'Expense';

  @override
  String get addExpenseOthers => 'Others';

  @override
  String get settingsDashBudgetVsActual => 'Budget vs Actual';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get recurringExpenses => 'Recurring Payments';

  @override
  String get recurringExpenseAdd => 'Add Recurring Payment';

  @override
  String get recurringExpenseEdit => 'Edit Recurring Payment';

  @override
  String get recurringExpenseCategory => 'Category';

  @override
  String get recurringExpenseAmount => 'Amount';

  @override
  String get recurringExpenseDescription => 'Description (optional)';

  @override
  String get recurringExpenseDayOfMonth => 'Due day';

  @override
  String get recurringExpenseActive => 'Active';

  @override
  String get recurringExpenseInactive => 'Inactive';

  @override
  String get recurringExpenseEmpty =>
      'No recurring payments.\nAdd one to auto-generate every month.';

  @override
  String get recurringExpenseDeleteConfirm => 'Delete this recurring payment?';

  @override
  String get recurringExpenseAutoCreated => 'Auto-created';

  @override
  String get recurringExpenseManage => 'Manage recurring payments';

  @override
  String get recurringExpenseMarkRecurring => 'Mark as recurring payment';

  @override
  String get recurringExpensePopulated =>
      'Recurring payments generated for this month';

  @override
  String get recurringExpenseDayHint => 'E.g. 1 for the 1st';

  @override
  String get recurringExpenseNoDay => 'No fixed day';

  @override
  String get recurringExpenseSaved => 'Recurring payment saved';

  @override
  String get recurringPaymentToggle => 'Recurring payment';

  @override
  String billsCount(int count) {
    return '$count payments';
  }

  @override
  String get billsNone => 'No recurring payments';

  @override
  String billsPerMonth(int count, String amount) {
    return '$count payments Â· $amount/mo';
  }

  @override
  String billsExceedBudget(String amount) {
    return 'Bills ($amount) exceed budget';
  }

  @override
  String get billsAddBill => 'Add Recurring Payment';

  @override
  String get billsBudgetSettings => 'Budget Settings';

  @override
  String get billsRecurringBills => 'Recurring Payments';

  @override
  String get billsDescription => 'Description';

  @override
  String get billsAmount => 'Amount';

  @override
  String get billsDueDay => 'Due day';

  @override
  String get billsActive => 'Active';

  @override
  String get expenseTrends => 'Expense Trends';

  @override
  String get expenseTrendsViewTrends => 'View Trends';

  @override
  String get expenseTrends3Months => '3M';

  @override
  String get expenseTrends6Months => '6M';

  @override
  String get expenseTrends12Months => '12M';

  @override
  String get expenseTrendsBudgeted => 'Budgeted';

  @override
  String get expenseTrendsActual => 'Actual';

  @override
  String get expenseTrendsByCategory => 'By Category';

  @override
  String get expenseTrendsNoData => 'Not enough data to show trends.';

  @override
  String get expenseTrendsTotal => 'Total';

  @override
  String get expenseTrendsAverage => 'Average';

  @override
  String get expenseTrendsOverview => 'Overview';

  @override
  String get expenseTrendsMonthly => 'Monthly';

  @override
  String get savingsGoals => 'Savings Goals';

  @override
  String get savingsGoalAdd => 'New Goal';

  @override
  String get savingsGoalEdit => 'Edit Goal';

  @override
  String get savingsGoalName => 'Goal name';

  @override
  String get savingsGoalTarget => 'Target amount';

  @override
  String get savingsGoalCurrent => 'Current amount';

  @override
  String get savingsGoalDeadline => 'Deadline';

  @override
  String get savingsGoalNoDeadline => 'No deadline';

  @override
  String get savingsGoalColor => 'Color';

  @override
  String savingsGoalProgress(String percent) {
    return '$percent% reached';
  }

  @override
  String savingsGoalRemaining(String amount) {
    return '$amount remaining';
  }

  @override
  String get savingsGoalCompleted => 'Goal reached!';

  @override
  String get savingsGoalEmpty =>
      'No savings goals.\nCreate one to track progress.';

  @override
  String get savingsGoalDeleteConfirm => 'Delete this goal?';

  @override
  String get savingsGoalContribute => 'Contribute';

  @override
  String get savingsGoalContributionAmount => 'Contribution amount';

  @override
  String get savingsGoalContributionNote => 'Note (optional)';

  @override
  String get savingsGoalContributionDate => 'Date';

  @override
  String get savingsGoalContributionHistory => 'Contribution History';

  @override
  String get savingsGoalSeeAll => 'See all';

  @override
  String savingsGoalSurplusSuggestion(String amount) {
    return 'You had $amount surplus last month â€” allocate to a goal?';
  }

  @override
  String get savingsGoalAllocate => 'Allocate';

  @override
  String get savingsGoalSaved => 'Goal saved';

  @override
  String get savingsGoalContributionSaved => 'Contribution recorded';

  @override
  String get settingsDashSavingsGoals => 'Savings Goals';

  @override
  String get savingsGoalActive => 'Active';

  @override
  String get savingsGoalInactive => 'Inactive';

  @override
  String savingsGoalDaysLeft(String days) {
    return '$days days left';
  }

  @override
  String get savingsGoalOverdue => 'Overdue';

  @override
  String get mealCostReconciliation => 'Meal Costs';

  @override
  String get mealCostEstimated => 'Estimated';

  @override
  String get mealCostActual => 'Actual';

  @override
  String mealCostWeek(String number) {
    return 'Week $number';
  }

  @override
  String get mealCostTotal => 'Monthly Total';

  @override
  String get mealCostSavings => 'Savings';

  @override
  String get mealCostOverrun => 'Overrun';

  @override
  String get mealCostNoData => 'No meal purchase data.';

  @override
  String get mealCostViewCosts => 'Costs';

  @override
  String get mealCostIsMealPurchase => 'Meal purchase';

  @override
  String get mealCostVsBudget => 'vs budget';

  @override
  String get mealCostOnTrack => 'On budget';

  @override
  String get mealCostOver => 'Over budget';

  @override
  String get mealCostUnder => 'Under budget';

  @override
  String get mealVariation => 'Variation';

  @override
  String get mealPairing => 'Pairing';

  @override
  String get mealStorage => 'Storage';

  @override
  String get mealLeftover => 'Leftover';

  @override
  String get mealLeftoverIdea => 'Transform idea';

  @override
  String get mealWeeklySummary => 'Weekly Nutrition';

  @override
  String get mealBatchPrepGuide => 'Batch Cooking';

  @override
  String get mealViewPrepGuide => 'How to Prepare';

  @override
  String get mealPrepGuideTitle => 'How to Prepare';

  @override
  String mealPrepTime(String minutes) {
    return 'Time: $minutes min';
  }

  @override
  String mealBatchTotalTime(String time) {
    return 'Estimated time: $time';
  }

  @override
  String get mealBatchParallelTips => 'Parallel cooking tips';

  @override
  String get mealFeedbackLike => 'Liked';

  @override
  String get mealFeedbackDislike => 'Dislike';

  @override
  String get mealFeedbackSkip => 'Skip';

  @override
  String get mealRateRecipe => 'Rate recipe';

  @override
  String mealRatingLabel(int rating) {
    return '$rating stars';
  }

  @override
  String get mealRatingUnrated => 'Unrated';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get notificationPreferredTime => 'Preferred time';

  @override
  String get notificationPreferredTimeDesc =>
      'Scheduled notifications will use this time (except custom reminders)';

  @override
  String get notificationBillReminders => 'Payment reminders';

  @override
  String get notificationBillReminderDays => 'Days before due';

  @override
  String get notificationBudgetAlerts => 'Budget alerts';

  @override
  String notificationBudgetThreshold(String percent) {
    return 'Alert threshold ($percent%)';
  }

  @override
  String get notificationMealPlanReminder => 'Meal plan reminder';

  @override
  String get notificationMealPlanReminderDesc =>
      'Notifies if no plan for current month';

  @override
  String get notificationCustomReminders => 'Custom Reminders';

  @override
  String get notificationAddCustom => 'Add Reminder';

  @override
  String get notificationCustomTitle => 'Title';

  @override
  String get notificationCustomBody => 'Message';

  @override
  String get notificationCustomTime => 'Time';

  @override
  String get notificationCustomRepeat => 'Repeat';

  @override
  String get notificationCustomRepeatDaily => 'Daily';

  @override
  String get notificationCustomRepeatWeekly => 'Weekly';

  @override
  String get notificationCustomRepeatMonthly => 'Monthly';

  @override
  String get notificationCustomRepeatNone => 'Don\'t repeat';

  @override
  String get notificationCustomSaved => 'Reminder saved';

  @override
  String get notificationCustomDeleteConfirm => 'Delete this reminder?';

  @override
  String get notificationEmpty => 'No custom reminders.';

  @override
  String notificationBillTitle(String name) {
    return 'Payment due: $name';
  }

  @override
  String notificationBillBody(String amount, String days) {
    return '$amount due in $days days';
  }

  @override
  String get notificationBudgetTitle => 'Budget alert';

  @override
  String notificationBudgetBody(String percent) {
    return 'You\'ve spent $percent% of your monthly budget';
  }

  @override
  String get notificationMealPlanTitle => 'Meal plan';

  @override
  String get notificationMealPlanBody =>
      'You haven\'t generated this month\'s meal plan yet';

  @override
  String get notificationPermissionRequired =>
      'Notification permission required';

  @override
  String get notificationSelectDays => 'Select days';

  @override
  String get settingsColorPalette => 'Color palette';

  @override
  String get paletteOcean => 'Ocean';

  @override
  String get paletteEmerald => 'Emerald';

  @override
  String get paletteViolet => 'Violet';

  @override
  String get paletteTeal => 'Teal';

  @override
  String get paletteSunset => 'Sunset';

  @override
  String get exportTooltip => 'Export';

  @override
  String get exportTitle => 'Export month';

  @override
  String get exportPdf => 'PDF Report';

  @override
  String get exportPdfDesc => 'Formatted report with budget vs actual';

  @override
  String get exportCsv => 'CSV Data';

  @override
  String get exportCsvDesc => 'Raw data for spreadsheets';

  @override
  String get exportReportTitle => 'Monthly Expense Report';

  @override
  String get exportBudgetVsActual => 'Budget vs Actual';

  @override
  String get exportExpenseDetail => 'Expense Detail';

  @override
  String get searchExpenses => 'Search';

  @override
  String get searchExpensesHint => 'Search by description...';

  @override
  String get searchDateRange => 'Date range';

  @override
  String get searchNoResults => 'No expenses found';

  @override
  String searchResultCount(int count) {
    return '$count results';
  }

  @override
  String get expenseFixed => 'Fixed';

  @override
  String get expenseVariable => 'Variable';

  @override
  String monthlyBudgetHint(String month) {
    return 'Budget for $month';
  }

  @override
  String unsetBudgetsWarning(int count) {
    return '$count variable budgets not set';
  }

  @override
  String get unsetBudgetsCta => 'Set in settings';

  @override
  String paceProjected(String amount) {
    return 'Projected: $amount';
  }

  @override
  String get onbSkip => 'Skip';

  @override
  String get onbNext => 'Next';

  @override
  String get onbGetStarted => 'Get started';

  @override
  String get onbSlide0Title => 'Your budget, at a glance';

  @override
  String get onbSlide0Body =>
      'The dashboard shows your monthly liquidity, expenses, and Serenity Index.';

  @override
  String get onbSlide1Title => 'Track every expense';

  @override
  String get onbSlide1Body =>
      'Tap + to record a purchase. Assign a category and watch the budget bars update.';

  @override
  String get onbSlide2Title => 'Shop with a list';

  @override
  String get onbSlide2Body =>
      'Browse products, build a list, then finalize to record your spend automatically.';

  @override
  String get onbSlide3Title => 'Your AI financial coach';

  @override
  String get onbSlide3Body =>
      'Get a 3-part analysis based on your actual budget — not generic advice.';

  @override
  String get onbSlide4Title => 'Plan meals in budget';

  @override
  String get onbSlide4Body =>
      'Generate a monthly meal plan tuned to your food budget and household size.';

  @override
  String get onbTourSkip => 'Skip tour';

  @override
  String get onbTourNext => 'Next';

  @override
  String get onbTourDone => 'Got it';

  @override
  String get onbTourDash1Title => 'Monthly liquidity';

  @override
  String get onbTourDash1Body =>
      'Income minus all expenses. Green means positive balance.';

  @override
  String get onbTourDash2Title => 'Serenity Index';

  @override
  String get onbTourDash2Body =>
      'Your financial health score 0–100. Tap to see the factors.';

  @override
  String get onbTourDash3Title => 'Budget vs actual';

  @override
  String get onbTourDash3Body => 'Planned vs real spending per category.';

  @override
  String get onbTourDash4Title => 'Add expense';

  @override
  String get onbTourDash4Body => 'Tap + any time to log a new expense.';

  @override
  String get onbTourDash5Title => 'Navigation';

  @override
  String get onbTourDash5Body =>
      '5 sections: Budget, Grocery, List, Coach, Meals.';

  @override
  String get onbTourGrocery1Title => 'Search & filter';

  @override
  String get onbTourGrocery1Body => 'Search by name or filter by category.';

  @override
  String get onbTourGrocery2Title => 'Add to list';

  @override
  String get onbTourGrocery2Body =>
      'Tap + on any product to add it to your shopping list.';

  @override
  String get onbTourGrocery3Title => 'Categories';

  @override
  String get onbTourGrocery3Body =>
      'Scroll the category chips to narrow down products.';

  @override
  String get onbTourShopping1Title => 'Check off items';

  @override
  String get onbTourShopping1Body => 'Tap any item to mark it as picked up.';

  @override
  String get onbTourShopping2Title => 'Finalize purchase';

  @override
  String get onbTourShopping2Body =>
      'Records the spend and clears checked items.';

  @override
  String get onbTourShopping3Title => 'Purchase history';

  @override
  String get onbTourShopping3Body => 'View all past shopping sessions here.';

  @override
  String get onbTourCoach1Title => 'Analyze my budget';

  @override
  String get onbTourCoach1Body =>
      'Tap to generate a budget analysis using your real data.';

  @override
  String get onbTourCoach2Title => 'Analysis history';

  @override
  String get onbTourCoach2Body => 'Saved analyses appear here, newest first.';

  @override
  String get onbTourMeals1Title => 'Generate plan';

  @override
  String get onbTourMeals1Body =>
      'Creates a full month of meals within your food budget.';

  @override
  String get onbTourMeals2Title => 'Weekly view';

  @override
  String get onbTourMeals2Body =>
      'Browse meals by week. Tap a day for recipe details.';

  @override
  String get onbTourMeals3Title => 'Add to shopping list';

  @override
  String get onbTourMeals3Body =>
      'Send a week\'s ingredients to your list in one tap.';

  @override
  String get onbTourExpenseTracker1Title => 'Month navigation';

  @override
  String get onbTourExpenseTracker1Body =>
      'Switch between months to view or add expenses for any period.';

  @override
  String get onbTourExpenseTracker2Title => 'Budget summary';

  @override
  String get onbTourExpenseTracker2Body =>
      'See your budgeted vs actual spending and remaining balance at a glance.';

  @override
  String get onbTourExpenseTracker3Title => 'Category breakdown';

  @override
  String get onbTourExpenseTracker3Body =>
      'Each category shows a progress bar. Tap to expand and see individual expenses.';

  @override
  String get onbTourExpenseTracker4Title => 'Add expense';

  @override
  String get onbTourExpenseTracker4Body =>
      'Tap + to log a new expense. Pick the category and amount.';

  @override
  String get onbTourSavings1Title => 'Your goals';

  @override
  String get onbTourSavings1Body =>
      'Each card shows progress toward your target. Tap to see details and add contributions.';

  @override
  String get onbTourSavings2Title => 'Create a goal';

  @override
  String get onbTourSavings2Body =>
      'Tap + to set a new savings goal with a target amount and optional deadline.';

  @override
  String get onbTourRecurring1Title => 'Recurring expenses';

  @override
  String get onbTourRecurring1Body =>
      'Fixed monthly bills like rent, subscriptions, and utilities. These are auto-included in your budget.';

  @override
  String get onbTourRecurring2Title => 'Add recurring';

  @override
  String get onbTourRecurring2Body =>
      'Tap + to register a new recurring expense with amount and due day.';

  @override
  String get onbTourAssistant1Title => 'Command assistant';

  @override
  String get onbTourAssistant1Body =>
      'Your shortcut to quick actions. Tap to add expenses, change settings, navigate, and more — just type what you need.';

  @override
  String get taxDeductionTitle => 'IRS Tax Deductions';

  @override
  String get taxDeductionSeeDetail => 'See detail';

  @override
  String get taxDeductionEstimated => 'estimated deduction';

  @override
  String taxDeductionMaxOf(String amount) {
    return 'Max of $amount';
  }

  @override
  String get taxDeductionDetailTitle => 'Tax Deduction Breakdown';

  @override
  String get taxDeductionDeductibleTitle => 'DEDUCTIBLE CATEGORIES';

  @override
  String get taxDeductionNonDeductibleTitle => 'NON-DEDUCTIBLE CATEGORIES';

  @override
  String get taxDeductionTotalLabel => 'ESTIMATED IRS DEDUCTION';

  @override
  String taxDeductionSpent(String amount) {
    return 'Spent: $amount';
  }

  @override
  String taxDeductionCapUsed(String percent, String cap) {
    return '$percent of $cap cap used';
  }

  @override
  String get taxDeductionNotDeductible => 'Not deductible';

  @override
  String get taxDeductionDisclaimer =>
      'These values are estimates based on your tracked expenses. Actual IRS deductions depend on invoices registered in e-Fatura. Consult a tax professional for definitive amounts.';

  @override
  String get settingsDashTaxDeductions => 'Tax deductions (PT)';

  @override
  String get settingsDashUpcomingBills => 'Upcoming payments';

  @override
  String get settingsDashBudgetStreaks => 'Budget streaks';

  @override
  String get settingsDashQuickActions => 'Quick actions';

  @override
  String get upcomingBillsTitle => 'Upcoming Payments';

  @override
  String get upcomingBillsManage => 'Manage';

  @override
  String get billDueToday => 'Today';

  @override
  String get billDueTomorrow => 'Tomorrow';

  @override
  String billDueInDays(int days) {
    return 'In $days days';
  }

  @override
  String savingsProjectionReachedBy(String date) {
    return 'Reached by $date';
  }

  @override
  String savingsProjectionNeedPerMonth(String amount) {
    return 'Need $amount/month to hit deadline';
  }

  @override
  String get savingsProjectionOnTrack => 'On track';

  @override
  String get savingsProjectionBehind => 'Behind schedule';

  @override
  String get savingsProjectionNoData => 'Add contributions to see projection';

  @override
  String savingsProjectionAvgContribution(String amount) {
    return 'Avg. $amount/month';
  }

  @override
  String get taxSimTitle => 'Tax Simulator';

  @override
  String get taxSimPresets => 'QUICK PRESETS';

  @override
  String get taxSimPresetRaise => '+â‚¬200 raise';

  @override
  String get taxSimPresetMeal => 'Card vs cash meal';

  @override
  String get taxSimPresetTitular => 'Joint vs separate';

  @override
  String get taxSimParameters => 'PARAMETERS';

  @override
  String get taxSimGross => 'Gross salary';

  @override
  String get taxSimMarital => 'Marital status';

  @override
  String get taxSimTitulares => 'Titulares';

  @override
  String get taxSimDependentes => 'Dependentes';

  @override
  String get taxSimMealType => 'Meal allowance type';

  @override
  String get taxSimMealAmount => 'Meal allowance/day';

  @override
  String get taxSimComparison => 'CURRENT VS SIMULATED';

  @override
  String get taxSimNetTakeHome => 'Net take-home';

  @override
  String get taxSimIRS => 'IRS retention';

  @override
  String get taxSimSS => 'Social security';

  @override
  String get taxSimDelta => 'Monthly difference:';

  @override
  String get taxSimButton => 'Tax Simulator';

  @override
  String get streakTitle => 'Budget Streaks';

  @override
  String get streakBronze => 'Bronze';

  @override
  String get streakSilver => 'Silver';

  @override
  String get streakGold => 'Gold';

  @override
  String get streakBronzeDesc => 'Positive liquidity';

  @override
  String get streakSilverDesc => 'Under budget';

  @override
  String get streakGoldDesc => 'All categories';

  @override
  String streakMonths(int count) {
    return '$count months';
  }

  @override
  String get expenseDefaultBudget => 'DEFAULT BUDGET';

  @override
  String expenseOverrideActive(String month, String amount) {
    return 'Adjusted for $month: $amount';
  }

  @override
  String expenseAdjustMonth(String month) {
    return 'Adjust for $month';
  }

  @override
  String get expenseAdjustMonthHint => 'Leave empty to use default budget';

  @override
  String get settingsPersonalTip =>
      'Marital status and dependents affect your IRS tax bracket, which determines how much tax is withheld from your salary.';

  @override
  String get settingsSalariesTip =>
      'Your gross salary is used to calculate net income after taxes and social security. Add multiple salaries for households with more than one income.';

  @override
  String get settingsExpensesTip =>
      'Set your monthly budget for each category. You can override any category for a specific month in the category detail view.';

  @override
  String get settingsMealHouseholdTip =>
      'Number of people eating meals at home. This scales recipes and portions in your meal plan.';

  @override
  String get settingsHouseholdTip =>
      'Invite family members to share budget data across devices. All members see the same expenses and budgets.';

  @override
  String get subscriptionTitle => 'Subscription';

  @override
  String get subscriptionFree => 'Free';

  @override
  String get subscriptionPremium => 'Premium';

  @override
  String get subscriptionFamily => 'Family';

  @override
  String get subscriptionTrialActive => 'Trial Active';

  @override
  String subscriptionTrialDaysLeft(int count) {
    return '$count days left';
  }

  @override
  String get subscriptionTrialExpired => 'Trial Expired';

  @override
  String get subscriptionUpgrade => 'Upgrade';

  @override
  String get subscriptionSeePlans => 'See Plans';

  @override
  String get subscriptionCurrentPlan => 'Current Plan';

  @override
  String get subscriptionManage => 'Manage Subscription';

  @override
  String subscriptionFeatureExplored(int count, int total) {
    return '$count/$total features explored';
  }

  @override
  String get subscriptionTrialBannerTitle => 'Premium Trial Active';

  @override
  String subscriptionTrialEndingSoon(int count) {
    return '$count days left in your trial!';
  }

  @override
  String get subscriptionTrialLastDay => 'Last day of your free trial!';

  @override
  String get subscriptionUpgradeNow => 'Upgrade Now';

  @override
  String get subscriptionKeepData => 'Keep Your Data';

  @override
  String get subscriptionCancelAnytime => 'Cancel anytime';

  @override
  String get subscriptionNoHiddenFees => 'No hidden fees';

  @override
  String get subscriptionMostPopular => 'Most Popular';

  @override
  String subscriptionYearlySave(int percent) {
    return 'save $percent%';
  }

  @override
  String get subscriptionMonthly => 'Monthly';

  @override
  String get subscriptionYearly => 'Yearly';

  @override
  String get subscriptionPerMonth => '/month';

  @override
  String get subscriptionPerYear => '/year';

  @override
  String get subscriptionBilledYearly => 'billed yearly';

  @override
  String get subscriptionStartPremium => 'Start Premium';

  @override
  String get subscriptionStartFamily => 'Start Family';

  @override
  String get subscriptionContinueFree => 'Continue Free';

  @override
  String get subscriptionTrialEnded => 'Your trial has ended';

  @override
  String get subscriptionChoosePlan =>
      'Choose a plan to keep all your data and features';

  @override
  String get subscriptionUnlockPower => 'Unlock the full power of your budget';

  @override
  String subscriptionRequiresPaid(String feature) {
    return '$feature requires a paid subscription';
  }

  @override
  String subscriptionTryFeature(String feature) {
    return 'Try $feature';
  }

  @override
  String subscriptionExplore(String feature) {
    return 'Explore $feature';
  }

  @override
  String get subtitleBatchCooking =>
      'Suggests recipes that can be prepped in advance for multiple meals';

  @override
  String get subtitleReuseLeftovers =>
      'Plans meals that use leftover ingredients from previous days';

  @override
  String get subtitleMinimizeWaste =>
      'Prioritizes using all purchased ingredients before they expire';

  @override
  String get subtitleMealTypeInclude => 'Include this meal in your weekly plan';

  @override
  String get subtitleShowHeroCard => 'Your net liquidity summary at the top';

  @override
  String get subtitleShowStressIndex =>
      'Score (0-100) measuring spending pressure vs income';

  @override
  String get subtitleShowMonthReview =>
      'Summary comparing this month to previous months';

  @override
  String get subtitleShowUpcomingBills =>
      'Recurring expenses due in the next 30 days';

  @override
  String get subtitleShowSummaryCards =>
      'Income, deductions, expenses, and savings rate';

  @override
  String get subtitleShowBudgetVsActual =>
      'Side-by-side comparison per expense category';

  @override
  String get subtitleShowExpensesBreakdown =>
      'Pie chart of spending by category';

  @override
  String get subtitleShowSavingsGoals => 'Progress toward your savings targets';

  @override
  String get subtitleShowTaxDeductions =>
      'Estimated eligible tax deductions this year';

  @override
  String get subtitleShowBudgetStreaks =>
      'How many consecutive months you stayed within budget';

  @override
  String get subtitleShowQuickActions =>
      'Shortcuts to add expenses, navigate, and more';

  @override
  String get subtitleShowPurchaseHistory =>
      'Recent shopping list purchases and costs';

  @override
  String get subtitleShowCharts =>
      'Trend charts for budget, expenses, and income';

  @override
  String get subtitleChartExpensesPie =>
      'Spending distribution across categories';

  @override
  String get subtitleChartIncomeVsExpenses =>
      'Monthly income compared to total spending';

  @override
  String get subtitleChartDeductions => 'Tax-deductible expenses breakdown';

  @override
  String get subtitleChartNetIncome => 'Net income trend over time';

  @override
  String get subtitleChartSavingsRate =>
      'Percentage of income saved each month';

  @override
  String get helperCountry =>
      'Determines tax system, currency, and social security rates';

  @override
  String get helperLanguage =>
      'Override system language. \"System\" follows your device setting';

  @override
  String get helperMaritalStatus => 'Affects IRS tax bracket calculation';

  @override
  String get helperMealObjective =>
      'Sets dietary pattern: omnivore, vegetarian, pescatarian, etc.';

  @override
  String get helperSodiumPreference =>
      'Filters recipes by sodium content level';

  @override
  String subtitleDietaryRestriction(String ingredient) {
    return 'Excludes recipes containing $ingredient';
  }

  @override
  String subtitleExcludedProtein(String protein) {
    return 'Remove $protein from all meal suggestions';
  }

  @override
  String subtitleKitchenEquipment(String equipment) {
    return 'Enable recipes that require $equipment';
  }

  @override
  String get helperVeggieDays => 'Number of fully vegetarian days per week';

  @override
  String get helperFishDays => 'Recommended: 2-3 times per week';

  @override
  String get helperLegumeDays => 'Recommended: 2-3 times per week';

  @override
  String get helperRedMeatDays => 'Recommended: max 2 times per week';

  @override
  String get helperMaxPrepTime =>
      'Maximum cooking time for weekday meals (minutes)';

  @override
  String get helperMaxComplexity => 'Recipe difficulty level for weekday meals';

  @override
  String get helperWeekendPrepTime =>
      'Maximum cooking time for weekend meals (minutes)';

  @override
  String get helperWeekendComplexity =>
      'Recipe difficulty level for weekend meals';

  @override
  String get helperMaxBatchDays =>
      'How many days a batch-cooked meal can be reused';

  @override
  String get helperNewIngredients =>
      'Limits how many new ingredients appear each week';

  @override
  String get helperGrossSalary => 'Total salary before taxes and deductions';

  @override
  String get helperExemptIncome =>
      'Additional income not subject to IRS (e.g., subsidies)';

  @override
  String get helperMealAllowance => 'Daily meal subsidy from your employer';

  @override
  String get helperWorkingDays =>
      'Typical: 22. Affects meal allowance calculation';

  @override
  String get helperSalaryLabel => 'A name to identify this income source';

  @override
  String get helperExpenseAmount => 'Monthly budgeted amount for this category';

  @override
  String get helperCalorieTarget => 'Recommended: 2000-2500 kcal for adults';

  @override
  String get helperProteinTarget => 'Recommended: 50-70g for adults';

  @override
  String get helperFiberTarget => 'Recommended: 25-30g for adults';

  @override
  String get infoStressIndex =>
      'Compares actual spending to your budget. Score ranges:\n\n0-30: Comfortable - spending well within budget\n30-60: Moderate - approaching budget limits\n60-100: Critical - spending exceeds budget significantly';

  @override
  String get infoBudgetStreak =>
      'Consecutive months where your total spending stayed within your total budget.';

  @override
  String get infoUpcomingBills =>
      'Shows recurring expenses due in the next 30 days based on your monthly expenses.';

  @override
  String get infoSalaryBreakdown =>
      'Shows how your gross salary is split into IRS tax, social security contributions, net income, and meal allowance.';

  @override
  String get infoBudgetVsActual =>
      'Compares what you budgeted per category vs what you actually spent. Green means under budget, red means over budget.';

  @override
  String get infoSavingsGoals =>
      'Progress toward each savings goal based on contributions you have made.';

  @override
  String get infoTaxDeductions =>
      'Estimated tax-deductible expenses (health, education, housing). These are estimates only - consult a tax professional for precise values.';

  @override
  String get infoPurchaseHistory =>
      'Total spent on shopping list purchases this month.';

  @override
  String get infoExpensesBreakdown =>
      'Visual breakdown of your spending by category for the current month.';

  @override
  String get infoCharts =>
      'Trend data over time. Tap any chart for a detailed view.';

  @override
  String get infoExpenseTrackerSummary =>
      'Budgeted = your planned monthly spending. Actual = what you have spent so far. Remaining = budget minus actual.';

  @override
  String get infoExpenseTrackerProgress =>
      'Green: under 75% of budget. Yellow: 75-100%. Red: over budget.';

  @override
  String get infoExpenseTrackerFilter =>
      'Filter expenses by text, category, or date range.';

  @override
  String get infoSavingsProjection =>
      'Based on your average monthly contributions. \"On track\" means your current pace reaches the goal by deadline. \"Behind\" means you need to increase contributions.';

  @override
  String get infoSavingsRequired =>
      'The amount you need to save each month from now to reach your goal by the deadline.';

  @override
  String get infoCoachModes =>
      'Eco: free, no conversation memory.\nPlus: 1 credit per message, remembers last 5 messages.\nPro: 2 credits per message, full conversation memory.';

  @override
  String get infoCoachCredits =>
      'Credits are used for Plus and Pro modes. You receive starter credits on signup. Eco mode is always free.';

  @override
  String get helperWizardGrossSalary =>
      'Your total monthly salary before taxes';

  @override
  String get helperWizardMealAllowance =>
      'Daily meal subsidy from employer (if any)';

  @override
  String get helperWizardRent => 'Monthly housing payment';

  @override
  String get helperWizardGroceries =>
      'Monthly food and household supplies budget';

  @override
  String get helperWizardTransport =>
      'Monthly transport costs (fuel, public transit, etc.)';

  @override
  String get helperWizardUtilities => 'Monthly electricity, water, gas';

  @override
  String get helperWizardTelecom => 'Monthly internet, phone, TV';

  @override
  String get savingsGoalHowItWorksTitle => 'How does it work?';

  @override
  String get savingsGoalHowItWorksStep1 =>
      'Create a goal with a name and the amount you want to save (e.g. \"Vacation — €2,000\").';

  @override
  String get savingsGoalHowItWorksStep2 =>
      'Optionally set a deadline to have a target date.';

  @override
  String get savingsGoalHowItWorksStep3 =>
      'Whenever you save money, tap the goal and record a contribution with the amount and date.';

  @override
  String get savingsGoalHowItWorksStep4 =>
      'Track your progress: the bar shows how much you\'ve saved and the projection estimates when you\'ll reach your goal.';

  @override
  String get savingsGoalDashboardHint =>
      'Tap a goal to see details and record contributions.';

  @override
  String get rateLimitMessage => 'Please wait a moment before trying again';

  @override
  String get planningExportTitle => 'Export';

  @override
  String get planningImportTitle => 'Import';

  @override
  String get planningExportShoppingList => 'Export shopping list';

  @override
  String get planningImportShoppingList => 'Import shopping list';

  @override
  String get planningExportMealPlan => 'Export meal plan';

  @override
  String get planningImportMealPlan => 'Import meal plan';

  @override
  String get planningExportPantry => 'Export pantry snapshot';

  @override
  String get planningImportPantry => 'Import pantry snapshot';

  @override
  String get planningExportFreeformMeals => 'Export freeform meals';

  @override
  String get planningImportFreeformMeals => 'Import freeform meals';

  @override
  String get planningFormatCsv => 'CSV';

  @override
  String get planningFormatJson => 'JSON';

  @override
  String get planningImportSuccess => 'Imported successfully';

  @override
  String planningImportError(String error) {
    return 'Import failed: $error';
  }

  @override
  String get planningExportSuccess => 'Exported successfully';

  @override
  String get planningDataPortability => 'Data portability';

  @override
  String get planningDataPortabilityDesc =>
      'Import and export planning artifacts';

  @override
  String get mealBudgetInsightTitle => 'Budget Insight';

  @override
  String get mealBudgetStatusSafe => 'On Track';

  @override
  String get mealBudgetStatusWatch => 'Watch';

  @override
  String get mealBudgetStatusOver => 'Over Budget';

  @override
  String get mealBudgetWeeklyCost => 'Weekly estimated cost';

  @override
  String get mealBudgetProjectedMonthly => 'Projected monthly spend';

  @override
  String get mealBudgetMonthlyBudget => 'Monthly food budget';

  @override
  String get mealBudgetRemaining => 'Remaining budget';

  @override
  String get mealBudgetTopExpensive => 'Most expensive meals';

  @override
  String get mealBudgetSuggestedSwaps => 'Suggested cheaper swaps';

  @override
  String get mealBudgetViewDetails => 'View details';

  @override
  String get mealBudgetApplySwap => 'Apply';

  @override
  String mealBudgetSwapSavings(String amount) {
    return 'Save $amount';
  }

  @override
  String get mealBudgetDailyBreakdown => 'Daily cost breakdown';

  @override
  String get mealBudgetShoppingImpact => 'Shopping impact';

  @override
  String get mealBudgetUniqueIngredients => 'Unique ingredients';

  @override
  String get mealBudgetEstShoppingCost => 'Estimated shopping cost';

  @override
  String get productUpdatesTitle => 'Product Updates';

  @override
  String get whatsNewTab => 'What\'s New';

  @override
  String get roadmapTab => 'Roadmap';

  @override
  String get noUpdatesYet => 'No updates yet';

  @override
  String get noRoadmapItems => 'No roadmap items yet';

  @override
  String get roadmapNow => 'Now';

  @override
  String get roadmapNext => 'Next';

  @override
  String get roadmapLater => 'Later';

  @override
  String get productUpdatesSubtitle => 'Changelog and upcoming features';

  @override
  String get whatsNewDialogTitle => 'What\'s New';

  @override
  String get whatsNewDialogDismiss => 'Got it';

  @override
  String get confidenceCenterTitle => 'Confidence Center';

  @override
  String get confidenceSyncHealth => 'Sync Health';

  @override
  String get confidenceDataAlerts => 'Data Quality Alerts';

  @override
  String get confidenceRecommendedActions => 'Recommended Actions';

  @override
  String get confidenceCenterSubtitle => 'Data freshness and system health';

  @override
  String get confidenceCenterTile => 'Confidence Center';

  @override
  String get pantryPickerTitle => 'Pantry Picker';

  @override
  String get pantrySearchHint => 'Search ingredients...';

  @override
  String get pantryTabAlwaysHave => 'Always Have';

  @override
  String get pantryTabThisWeek => 'This Week';

  @override
  String pantrySummaryLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pantry items',
      one: '1 pantry item',
    );
    return '$_temp0';
  }

  @override
  String get pantryEdit => 'Edit';

  @override
  String get pantryUseWhatWeHave => 'Use What We Have';

  @override
  String get pantryMarkAtHome => 'Already at home';

  @override
  String get pantryHaveIt => 'Have it';

  @override
  String pantryCoverageLabel(int pct) {
    return '$pct% covered by pantry';
  }

  @override
  String get pantryStaples => 'STAPLES (ALWAYS HAVE)';

  @override
  String get pantryWeekly => 'THIS WEEK\'S PANTRY';

  @override
  String pantryAddedToWeekly(String name) {
    return '$name added to weekly pantry';
  }

  @override
  String pantryRemovedFromList(String name) {
    return '$name removed from shopping list (already at home)';
  }

  @override
  String pantryMarkedAtHome(String name) {
    return '$name marked as already at home';
  }

  @override
  String get householdActivityTitle => 'Household Activity';

  @override
  String get householdActivityFilterAll => 'All';

  @override
  String get householdActivityFilterShopping => 'Shopping';

  @override
  String get householdActivityFilterMeals => 'Meals';

  @override
  String get householdActivityFilterExpenses => 'Expenses';

  @override
  String get householdActivityFilterPantry => 'Pantry';

  @override
  String get householdActivityFilterSettings => 'Settings';

  @override
  String get householdActivityEmpty => 'No activity yet';

  @override
  String get householdActivityEmptyMessage =>
      'Shared actions from your household will appear here.';

  @override
  String get householdActivityToday => 'TODAY';

  @override
  String get householdActivityYesterday => 'YESTERDAY';

  @override
  String get householdActivityThisWeek => 'THIS WEEK';

  @override
  String get householdActivityOlder => 'OLDER';

  @override
  String get householdActivityJustNow => 'Just now';

  @override
  String householdActivityMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String householdActivityHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String householdActivityDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String householdActivityAddedBy(String name) {
    return 'Added by $name';
  }

  @override
  String householdActivityRemovedBy(String name) {
    return 'Removed by $name';
  }

  @override
  String householdActivitySwappedBy(String name) {
    return 'Swapped by $name';
  }

  @override
  String householdActivityUpdatedBy(String name) {
    return 'Updated by $name';
  }

  @override
  String householdActivityCheckedBy(String name) {
    return 'Checked by $name';
  }

  @override
  String get barcodeScanTitle => 'Scan Barcode';

  @override
  String get barcodeScanHint => 'Point the camera at a barcode to scan it';

  @override
  String get barcodeScanTooltip => 'Scan barcode';

  @override
  String get barcodeProductFound => 'Product Found';

  @override
  String get barcodeProductNotFound => 'Product Not Found';

  @override
  String get barcodeLabel => 'Barcode';

  @override
  String get barcodeAddToList => 'Add to List';

  @override
  String get barcodeManualEntry =>
      'No matching product found. Enter details manually:';

  @override
  String get barcodeProductName => 'Product name';

  @override
  String get barcodePrice => 'Price';

  @override
  String barcodeAddedToList(String name) {
    return '$name added to shopping list';
  }

  @override
  String get barcodeInvoiceDetected =>
      'This is an invoice barcode, not a product';

  @override
  String get barcodeInvoiceAction => 'Open Receipt Scanner';

  @override
  String get quickAddTooltip => 'Quick actions';

  @override
  String get quickAddExpense => 'Add expense';

  @override
  String get quickAddShopping => 'Add shopping item';

  @override
  String get quickOpenMeals => 'Meal planner';

  @override
  String get quickOpenAssistant => 'Assistant';

  @override
  String get freeformBadge => 'Freeform';

  @override
  String get freeformCreateTitle => 'Add freeform meal';

  @override
  String get freeformEditTitle => 'Edit freeform meal';

  @override
  String get freeformTitleLabel => 'Meal title';

  @override
  String get freeformTitleHint => 'e.g. Leftovers, Takeout pizza';

  @override
  String get freeformNoteLabel => 'Note (optional)';

  @override
  String get freeformNoteHint => 'Any details about this meal';

  @override
  String get freeformCostLabel => 'Estimated cost (optional)';

  @override
  String get freeformTagsLabel => 'Tags';

  @override
  String get freeformTagLeftovers => 'Leftovers';

  @override
  String get freeformTagPantryMeal => 'Pantry meal';

  @override
  String get freeformTagTakeout => 'Takeout';

  @override
  String get freeformTagQuickMeal => 'Quick meal';

  @override
  String get freeformShoppingItemsLabel => 'Shopping items';

  @override
  String get freeformAddItem => 'Add item';

  @override
  String get freeformItemName => 'Item name';

  @override
  String get freeformItemQuantity => 'Quantity';

  @override
  String get freeformItemUnit => 'Unit';

  @override
  String get freeformItemPrice => 'Est. price';

  @override
  String get freeformItemStore => 'Store';

  @override
  String freeformShoppingItemCount(int count) {
    return '$count shopping items';
  }

  @override
  String get freeformAddToSlot => 'Add freeform meal';

  @override
  String get freeformReplace => 'Replace with freeform';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get insightsAnalyzeSpending => 'Analyze spending over time';

  @override
  String get insightsTrackProgress => 'Track progress to your targets';

  @override
  String get insightsTaxOutcome => 'Estimate annual tax outcome';

  @override
  String get moreTitle => 'More';

  @override
  String get moreDetailedDashboard => 'Detailed Dashboard';

  @override
  String get moreDetailedDashboardSubtitle =>
      'Open full financial dashboard with all cards';

  @override
  String get moreSavingsSubtitle => 'Track and update your goal progress';

  @override
  String get moreNotificationsSubtitle => 'Budgets, bills and reminders';

  @override
  String get moreSettingsSubtitle => 'Preferences, profile and dashboard';

  @override
  String get morePlanFree => 'Free Plan';

  @override
  String get morePlanTrial => 'Trial Active';

  @override
  String get morePlanPro => 'Pro Plan';

  @override
  String get morePlanFamily => 'Family Plan';

  @override
  String get morePlanManage => 'Manage your plan and billing';

  @override
  String morePlanLimits(int categories, int goals) {
    return '$categories categories • $goals savings goal';
  }

  @override
  String moreItemsPaused(int count) {
    return '$count items paused';
  }

  @override
  String get moreUpgrade => 'Upgrade →';

  @override
  String get planTitle => 'Plan';

  @override
  String get planGrocerySubtitle => 'Browse products and prices';

  @override
  String get planShoppingList => 'Shopping List';

  @override
  String get planShoppingSubtitle => 'Review and finalize purchases';

  @override
  String get planMealSubtitle => 'Generate affordable weekly plans';

  @override
  String coachActiveMemory(String mode, int percent) {
    return 'Active memory: $mode ($percent%)';
  }

  @override
  String get coachCostPerMessageNote =>
      'Cost per message sent. Coach response does not consume credits.';

  @override
  String get coachExpandTip => 'Expand notice';

  @override
  String get coachCollapseTip => 'Minimize notice';

  @override
  String featureTryName(String name) {
    return 'Try $name';
  }

  @override
  String featureExploreName(String name) {
    return 'Explore $name';
  }

  @override
  String featureRequiresPremium(String name) {
    return '$name requires Premium';
  }

  @override
  String get featureTapToUpgrade => 'Tap to upgrade';

  @override
  String get featureNameAiCoach => 'AI Coach';

  @override
  String get featureNameMealPlanner => 'Meal Planner';

  @override
  String get featureNameExpenseTracker => 'Expense Tracker';

  @override
  String get featureNameSavingsGoals => 'Savings Goals';

  @override
  String get featureNameShoppingList => 'Shopping List';

  @override
  String get featureNameGroceryBrowser => 'Grocery Browser';

  @override
  String get featureNameExportReports => 'Export Reports';

  @override
  String get featureNameTaxSimulator => 'Tax Simulator';

  @override
  String get featureNameDashboard => 'Dashboard';

  @override
  String get featureTagAiCoach => 'Your personal financial advisor';

  @override
  String get featureTagMealPlanner => 'Save money on food';

  @override
  String get featureTagExpenseTracker => 'Know where every euro goes';

  @override
  String get featureTagSavingsGoals => 'Make your dreams happen';

  @override
  String get featureTagShoppingList => 'Shop smarter together';

  @override
  String get featureTagGroceryBrowser => 'Compare prices instantly';

  @override
  String get featureTagExportReports => 'Professional budget reports';

  @override
  String get featureTagTaxSimulator => 'Multi-country tax planning';

  @override
  String get featureTagDashboard => 'Your financial overview';

  @override
  String get featureDescAiCoach =>
      'Get personalized insights about your spending habits, savings tips, and budget optimization powered by AI.';

  @override
  String get featureDescMealPlanner =>
      'Plan weekly meals within your budget. AI generates recipes based on your preferences and dietary needs.';

  @override
  String get featureDescExpenseTracker =>
      'Track actual expenses vs. your budget in real-time. See where you\'re overspending and where you can save.';

  @override
  String get featureDescSavingsGoals =>
      'Set savings goals with deadlines, track contributions, and see projections for when you\'ll reach your targets.';

  @override
  String get featureDescShoppingList =>
      'Create shared shopping lists that sync in real-time. Check items off as you shop, finalize and track spending.';

  @override
  String get featureDescGroceryBrowser =>
      'Browse products from multiple stores, compare prices, and add the best deals directly to your shopping list.';

  @override
  String get featureDescExportReports =>
      'Export your budget, expenses, and financial summaries as PDF or CSV for your records or accountant.';

  @override
  String get featureDescTaxSimulator =>
      'Compare tax obligations across countries. Perfect for expats and anyone considering relocation.';

  @override
  String get featureDescDashboard =>
      'See your complete budget breakdown, charts, and financial health at a glance.';

  @override
  String get trialPremiumActive => 'Premium Trial Active';

  @override
  String get trialHalfway => 'Your trial is halfway through';

  @override
  String trialDaysLeftInTrial(int count) {
    return '$count days left in your trial!';
  }

  @override
  String get trialLastDay => 'Last day of your free trial!';

  @override
  String get trialSeePlans => 'See Plans';

  @override
  String get trialUpgradeNow => 'Upgrade Now — Keep Your Data';

  @override
  String get trialSubtitleUrgent =>
      'Your premium access ends soon. Upgrade to keep AI Coach, Meal Planner, and all your data.';

  @override
  String trialSubtitleMidFeature(String name) {
    return 'Have you tried the $name yet? Make the most of your trial!';
  }

  @override
  String get trialSubtitleMidProgress =>
      'You\'re making great progress! Keep exploring premium features.';

  @override
  String get trialSubtitleEarly =>
      'You have full access to all premium features. Explore everything!';

  @override
  String trialFeaturesExplored(int explored, int total) {
    return '$explored/$total features explored';
  }

  @override
  String trialDaysRemaining(int count) {
    return '$count days left';
  }

  @override
  String trialProgressLabel(int percent) {
    return 'Trial progress $percent%';
  }

  @override
  String get featureNameAiCoachFull => 'AI Financial Coach';

  @override
  String get receiptScanTitle => 'Scan Receipt';

  @override
  String get receiptScanQrMode => 'QR Code';

  @override
  String get receiptScanPhotoMode => 'Photo';

  @override
  String get receiptScanHint => 'Point camera at the receipt QR code';

  @override
  String receiptScanSuccess(String amount, String store) {
    return 'Expense of $amount at $store recorded';
  }

  @override
  String get receiptScanFailed => 'Could not read receipt';

  @override
  String get receiptScanPrompt =>
      'Shopping done? Scan the receipt to record expenses automatically.';

  @override
  String get receiptMerchantUnknown => 'Unknown merchant';

  @override
  String receiptMerchantNamePrompt(String nif) {
    return 'Enter store name for NIF $nif';
  }

  @override
  String receiptItemsMatched(int count) {
    return '$count items matched with shopping list';
  }

  @override
  String get quickScanReceipt => 'Scan Receipt';

  @override
  String get receiptReviewTitle => 'Review Receipt';

  @override
  String get receiptReviewMerchant => 'Merchant';

  @override
  String get receiptReviewDate => 'Date';

  @override
  String get receiptReviewTotal => 'Total';

  @override
  String get receiptReviewCategory => 'Category';

  @override
  String receiptReviewItems(int count) {
    return '$count items detected';
  }

  @override
  String get receiptReviewConfirm => 'Add Expense';

  @override
  String get receiptReviewRetake => 'Retake';

  @override
  String get receiptCameraPermissionTitle => 'Camera Access';

  @override
  String get receiptCameraPermissionBody =>
      'Camera access is needed to scan receipts and barcodes.';

  @override
  String get receiptCameraPermissionAllow => 'Allow';

  @override
  String get receiptCameraPermissionDeny => 'Not now';

  @override
  String get receiptCameraBlockedTitle => 'Camera Blocked';

  @override
  String get receiptCameraBlockedBody =>
      'Camera permission was permanently denied. Open app settings to enable it.';

  @override
  String get receiptCameraBlockedSettings => 'Open Settings';

  @override
  String groceryMarketData(String marketCode) {
    return '$marketCode market data';
  }

  @override
  String groceryStoreCoverage(int active, int total) {
    return '$active active of $total stores';
  }

  @override
  String groceryStoreFreshCount(int count) {
    return '$count fresh';
  }

  @override
  String groceryStorePartialCount(int count) {
    return '$count partial';
  }

  @override
  String groceryStoreFailedCount(int count) {
    return '$count failed';
  }

  @override
  String get groceryHideStaleStores => 'Hide stale stores';

  @override
  String groceryComparisonsFreshOnly(int count) {
    return 'Showing $count fresh store in comparisons';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navHomeTip => 'Monthly overview';

  @override
  String get navTrack => 'Track';

  @override
  String get navTrackTip => 'Track monthly expenses';

  @override
  String get navPlan => 'Plan';

  @override
  String get navPlanTip => 'Groceries, list and meal plan';

  @override
  String get navPlanAndShop => 'Shop';

  @override
  String get navPlanAndShopTip => 'Shopping list, grocery and meals';

  @override
  String get navMore => 'More';

  @override
  String get navMoreTip => 'Settings and insights';

  @override
  String get paywallContinueFree => 'Continuing with Free plan';

  @override
  String get paywallUpgradedPro => 'Upgraded to Pro — thank you!';

  @override
  String get paywallNoRestore => 'No previous purchases found';

  @override
  String get paywallRestoredPro => 'Restored Pro subscription!';

  @override
  String get subscriptionPro => 'Pro';

  @override
  String subscriptionTrialLabel(int count) {
    return 'Trial ($count days left)';
  }

  @override
  String get authConnectionError => 'Connection error';

  @override
  String get authRetry => 'Retry';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get actionRetry => 'Retry';

  @override
  String get settingsGroupAccount => 'ACCOUNT';

  @override
  String get settingsGroupBudget => 'BUDGET';

  @override
  String get settingsGroupPreferences => 'PREFERENCES';

  @override
  String get settingsGroupAdvanced => 'ADVANCED';

  @override
  String get settingsManageSubscription => 'Manage Subscription';

  @override
  String get settingsAbout => 'About';

  @override
  String get mealShowDetails => 'Show details';

  @override
  String get mealHideDetails => 'Hide details';

  @override
  String get taxSimTitularesHint => 'Number of income earners in the household';

  @override
  String get taxSimMealTypeHint =>
      'Card: tax-free up to the legal limit. Cash: taxed as income.';

  @override
  String get taxSimIRSFull => 'IRS (Income Tax) retention';

  @override
  String get taxSimSSFull => 'SS (Social Security)';

  @override
  String get stressZoneCritical =>
      '0–39: High financial pressure, urgent action needed';

  @override
  String get stressZoneWarning =>
      '40–59: Some risks present, improvements recommended';

  @override
  String get stressZoneGood =>
      '60–79: Healthy finances, minor optimizations possible';

  @override
  String get stressZoneExcellent =>
      '80–100: Strong financial position, well managed';

  @override
  String get projectionStressHint =>
      'How this spending scenario affects your overall financial health score (0–100)';

  @override
  String get coachWelcomeTitle => 'Your AI Financial Coach';

  @override
  String get coachWelcomeBody =>
      'Ask questions about your budget, expenses, or savings. The coach analyzes your real financial data to provide personalized advice.';

  @override
  String get coachWelcomeCredits =>
      'Credits are used for Plus and Pro modes. Eco mode is always free.';

  @override
  String get coachWelcomeRateLimit =>
      'To ensure quality responses, there is a brief cooldown between messages.';

  @override
  String get planMealsProBadge => 'PRO';

  @override
  String get coachBuyCredits => 'Buy credits';

  @override
  String get coachContinueEco => 'Continue with Eco';

  @override
  String get coachAchieved => 'I did it!';

  @override
  String get coachNotYet => 'Not yet';

  @override
  String coachCreditsAdded(int count) {
    return '+$count credits added';
  }

  @override
  String coachPurchaseError(String error) {
    return 'Purchase error: $error';
  }

  @override
  String coachUseMode(String mode) {
    return 'Use $mode';
  }

  @override
  String coachKeepMode(String mode) {
    return 'Keep $mode';
  }

  @override
  String savingsGoalSaveError(String error) {
    return 'Failed to save goal: $error';
  }

  @override
  String savingsGoalDeleteError(String error) {
    return 'Failed to delete goal: $error';
  }

  @override
  String savingsGoalUpdateError(String error) {
    return 'Failed to update goal: $error';
  }

  @override
  String get settingsSubscription => 'Subscription';

  @override
  String get settingsSubscriptionFree => 'Free';

  @override
  String settingsActiveCategoriesCount(int active, int total) {
    return 'Active Categories ($active of $total)';
  }

  @override
  String get settingsPausedCategories => 'Paused Categories';

  @override
  String get settingsOpenDashboard => 'Open Detailed Dashboard';

  @override
  String get settingsAssistantGroup => 'ASSISTANT';

  @override
  String get settingsAiCoach => 'AI Coach';

  @override
  String get setupWizardSubsidyLabel => 'SUBSIDIES';

  @override
  String get setupWizardPerDay => '/day';

  @override
  String get configurationError => 'Configuration Error';

  @override
  String get confidenceAllHealthy => 'All systems healthy. No actions needed.';

  @override
  String get confidenceNoAlerts => 'No alerts. Everything looks good.';

  @override
  String get onbSwipeHint => 'Swipe to continue';

  @override
  String onbSlideOf(int current, int total) {
    return 'Slide $current of $total';
  }

  @override
  String get expenseTrendsChartLabel =>
      'Expense trends overview chart showing budgeted versus actual spending';

  @override
  String get customCategories => 'Categories';

  @override
  String get customCategoryAdd => 'Add Category';

  @override
  String get customCategoryEdit => 'Edit Category';

  @override
  String get customCategoryDelete => 'Delete Category';

  @override
  String get customCategoryDeleteConfirm => 'Delete this category?';

  @override
  String get customCategoryName => 'Category name';

  @override
  String get customCategoryIcon => 'Icon';

  @override
  String get customCategoryColor => 'Color';

  @override
  String get customCategoryEmpty => 'No custom categories';

  @override
  String get customCategorySaved => 'Category saved';

  @override
  String get customCategoryInUse => 'Category in use, cannot delete';

  @override
  String get customCategoryPredefinedHint =>
      'Built-in categories used across the app';

  @override
  String get customCategoryDefault => 'Default';

  @override
  String get expenseLocationPermissionDenied => 'Location permission denied';

  @override
  String get expenseAttachPhoto => 'Attach Photo';

  @override
  String get expenseAttachCamera => 'Camera';

  @override
  String get expenseAttachGallery => 'Gallery';

  @override
  String get expenseAttachUploadFailed =>
      'Failed to upload attachments. Check your connection.';

  @override
  String get expenseExtras => 'Extras';

  @override
  String get expenseLocationDetect => 'Detect location';

  @override
  String get biometricLockTitle => 'App Lock';

  @override
  String get biometricLockSubtitle =>
      'Require authentication when opening the app';

  @override
  String get biometricPrompt => 'Authenticate to continue';

  @override
  String get biometricReason => 'Verify your identity to unlock the app';

  @override
  String get biometricRetry => 'Try Again';

  @override
  String get notifDailyExpenseReminder => 'Daily expense reminder';

  @override
  String get notifDailyExpenseReminderDesc =>
      'Reminds you to log today\'s expenses';

  @override
  String get notifDailyExpenseTitle => 'Don\'t forget your expenses!';

  @override
  String get notifDailyExpenseBody => 'Take a moment to log today\'s expenses';

  @override
  String get settingsSalaryLabelHint => 'e.g., Main job, Freelance';

  @override
  String get settingsExpenseNameLabel => 'EXPENSE NAME';

  @override
  String get settingsCategoryLabel => 'CATEGORY';

  @override
  String get settingsMonthlyBudgetLabel => 'MONTHLY BUDGET';

  @override
  String get expenseLocationSearch => 'Search';

  @override
  String get expenseLocationSearchHint => 'Search address...';

  @override
  String get dashboardBurnRateTitle => 'Spending Velocity';

  @override
  String get dashboardBurnRateSubtitle => 'Daily average vs available budget';

  @override
  String get dashboardBurnRateOnTrack => 'On track';

  @override
  String get dashboardBurnRateOver => 'Over pace';

  @override
  String get dashboardBurnRateDailyAvg => 'AVG/DAY';

  @override
  String get dashboardBurnRateAllowance => 'ALLOW./DAY';

  @override
  String get dashboardBurnRateDaysLeft => 'DAYS LEFT';

  @override
  String get dashboardTopCategoriesTitle => 'Top Categories';

  @override
  String get dashboardTopCategoriesSubtitle =>
      'Highest spending categories this month';

  @override
  String get dashboardCashFlowTitle => 'Cash Flow Forecast';

  @override
  String get dashboardCashFlowSubtitle =>
      'Projected balance through end of month';

  @override
  String get dashboardCashFlowProjectedSpend => 'PROJECTED SPEND';

  @override
  String get dashboardCashFlowEndOfMonth => 'END OF MONTH';

  @override
  String dashboardCashFlowPendingBills(String amount) {
    return 'Pending bills: $amount';
  }

  @override
  String get dashboardSavingsRateTitle => 'Savings Rate';

  @override
  String get dashboardSavingsRateSubtitle => 'Percentage of income saved';

  @override
  String dashboardSavingsRateSaved(String amount) {
    return 'Saved this month: $amount';
  }

  @override
  String get dashboardCoachInsightTitle => 'Financial Tip';

  @override
  String get dashboardCoachInsightSubtitle =>
      'Personalized suggestion from financial assistant';

  @override
  String get dashboardCoachLowSavings =>
      'Your savings rate is below 10%. Identify one expense you can reduce this month.';

  @override
  String get dashboardCoachHighSpending =>
      'Spending is approaching your income. Review non-essential expenses.';

  @override
  String get dashboardCoachGoodSavings =>
      'Excellent! You\'re saving over 20%. Keep it up!';

  @override
  String get dashboardCoachGeneral => 'Tap for personalized budget analysis.';

  @override
  String get dashGroupInsights => 'Insights';

  @override
  String get dashReorderHint => 'Drag to reorder cards';

  @override
  String get settingsSalarySummaryGross => 'Gross';

  @override
  String get settingsSalarySummaryNet => 'Net';

  @override
  String get settingsDeductionIrs => 'IRS';

  @override
  String get settingsDeductionSs => 'SS';

  @override
  String get settingsDeductionMeal => 'Meal';

  @override
  String settingsMealMonthlyTotal(String amount) {
    return 'Monthly total: $amount';
  }

  @override
  String get mealSubstituteIngredient => 'Substitute ingredient';

  @override
  String mealSubstituteTitle(String name) {
    return 'Replace $name';
  }

  @override
  String mealSubstitutionApplied(String oldName, String newName) {
    return '$oldName replaced with $newName';
  }

  @override
  String get mealSubstitutionAdapting => 'Adapting recipe...';

  @override
  String get mealPlanWithPantry => 'Plan with what I have';

  @override
  String get mealPantrySelectTitle => 'Select pantry ingredients';

  @override
  String get mealPantrySelectHint => 'Pick ingredients you have at home';

  @override
  String mealPantrySelected(int count) {
    return '$count selected';
  }

  @override
  String get mealPantryApply => 'Apply & Generate';

  @override
  String get mealTasteProfileBoost => 'Taste profile applied';

  @override
  String get mealPlanUndoMessage => 'Plan regenerated successfully';

  @override
  String get mealPlanUndoAction => 'Undo';

  @override
  String get mealActiveTime => 'active';

  @override
  String get mealPassiveTime => 'oven/wait';

  @override
  String get mealOptimizeMacros => 'Optimize macros';

  @override
  String mealSwapSuggestion(String current, String suggested) {
    return 'Swap $current for $suggested';
  }

  @override
  String mealSwapReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get mealApplySwap => 'Apply';

  @override
  String get mealSwapSameType => 'Same type';

  @override
  String get mealSwapAllTypes => 'All types';

  @override
  String get pantryManagerTitle => 'Pantry';

  @override
  String get pantryManagerSave => 'Save';

  @override
  String get pantryLowStock => 'Low stock';

  @override
  String get pantryDepleted => 'Depleted';

  @override
  String get pantryRestock => 'Restock';

  @override
  String get pantryQuantity => 'Quantity';

  @override
  String get nutritionDashboardTitle => 'Weekly Nutrition';

  @override
  String get nutritionCalories => 'Calories';

  @override
  String get nutritionProtein => 'Protein';

  @override
  String get nutritionCarbs => 'Carbs';

  @override
  String get nutritionFat => 'Fat';

  @override
  String get nutritionFiber => 'Fiber';

  @override
  String get nutritionTopProteins => 'Top proteins';

  @override
  String get nutritionDailyAvg => 'Daily average';

  @override
  String get mealWasteEstimate => 'Estimated waste';

  @override
  String mealWasteExcess(String qty, String unit) {
    return '$qty $unit excess';
  }

  @override
  String mealWasteSuggestion(String ingredient) {
    return 'Consider doubling this recipe to use $ingredient';
  }

  @override
  String mealWasteCost(String cost) {
    return '~$cost waste';
  }
}
