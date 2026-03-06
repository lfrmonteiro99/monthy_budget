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
  String get settingsExpenses => 'Budget & Bills';

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
  String get settingsExpensesMonthly => 'Budget & Bills';

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
  String get recurringExpenses => 'Monthly Bills';

  @override
  String get recurringExpenseAdd => 'Add Bill';

  @override
  String get recurringExpenseEdit => 'Edit Bill';

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
      'No monthly bills.\nAdd one to auto-generate every month.';

  @override
  String get recurringExpenseDeleteConfirm => 'Delete this bill?';

  @override
  String get recurringExpenseAutoCreated => 'Auto-created';

  @override
  String get recurringExpenseManage => 'Manage bills';

  @override
  String get recurringExpenseMarkRecurring => 'Mark as monthly bill';

  @override
  String get recurringExpensePopulated =>
      'Monthly bills generated for this month';

  @override
  String get recurringExpenseDayHint => 'E.g. 1 for the 1st';

  @override
  String get recurringExpenseNoDay => 'No fixed day';

  @override
  String get recurringExpenseSaved => 'Bill saved';

  @override
  String billsCount(int count) {
    return '$count bills';
  }

  @override
  String get billsNone => 'No bills';

  @override
  String billsPerMonth(int count, String amount) {
    return '$count bills Â· $amount/mo';
  }

  @override
  String billsExceedBudget(String amount) {
    return 'Bills ($amount) exceed budget';
  }

  @override
  String get billsAddBill => 'Add Bill';

  @override
  String get billsBudgetSettings => 'Budget Settings';

  @override
  String get billsRecurringBills => 'Recurring Bills';

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
  String get mealBatchPrepGuide => 'Prep Guide';

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
  String get notifications => 'Notifications';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get notificationBillReminders => 'Bill reminders';

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
    return 'Bill due: $name';
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
  String get settingsDashUpcomingBills => 'Upcoming bills';

  @override
  String get settingsDashBudgetStreaks => 'Budget streaks';

  @override
  String get upcomingBillsTitle => 'Upcoming Bills';

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
}
