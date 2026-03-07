// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class SFr extends S {
  SFr([String locale = 'fr']) : super(locale);

  @override
  String get navBudget => 'Budget';

  @override
  String get navGrocery => 'Courses';

  @override
  String get navList => 'Liste';

  @override
  String get navCoach => 'Coach';

  @override
  String get navMeals => 'Repas';

  @override
  String get navBudgetTooltip => 'AperÃ§u du budget mensuel';

  @override
  String get navGroceryTooltip => 'Catalogue de produits';

  @override
  String get navListTooltip => 'Liste de courses';

  @override
  String get navCoachTooltip => 'Coach financier IA';

  @override
  String get navMealsTooltip => 'Planificateur de repas';

  @override
  String get appTitle => 'Budget Mensuel';

  @override
  String get loading => 'Chargement...';

  @override
  String get loadingApp => 'Chargement de l\'application';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get close => 'Fermer';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get clear => 'Effacer';

  @override
  String errorSavingPurchase(String error) {
    return 'Erreur lors de l\'enregistrement : $error';
  }

  @override
  String filterBy(String label) {
    return 'Filtrer par $label';
  }

  @override
  String addToList(String name) {
    return 'Ajouter $name Ã  la liste';
  }

  @override
  String get enumMaritalSolteiro => 'CÃ©libataire';

  @override
  String get enumMaritalCasado => 'MariÃ©(e)';

  @override
  String get enumMaritalUniaoFacto => 'Union libre';

  @override
  String get enumMaritalDivorciado => 'DivorcÃ©(e)';

  @override
  String get enumMaritalViuvo => 'Veuf/Veuve';

  @override
  String get enumSubsidyNone => 'Sans primes';

  @override
  String get enumSubsidyFull => 'Avec primes';

  @override
  String get enumSubsidyHalf => '50% primes';

  @override
  String get enumSubsidyNoneShort => 'Sans';

  @override
  String get enumSubsidyFullShort => 'Avec';

  @override
  String get enumSubsidyHalfShort => '50%';

  @override
  String get enumMealAllowanceNone => 'Sans';

  @override
  String get enumMealAllowanceCard => 'Carte';

  @override
  String get enumMealAllowanceCash => 'EspÃ¨ces';

  @override
  String get enumCatTelecomunicacoes => 'TÃ©lÃ©com';

  @override
  String get enumCatEnergia => 'Ã‰nergie';

  @override
  String get enumCatAgua => 'Eau';

  @override
  String get enumCatAlimentacao => 'Alimentation';

  @override
  String get enumCatEducacao => 'Ã‰ducation';

  @override
  String get enumCatHabitacao => 'Logement';

  @override
  String get enumCatTransportes => 'Transport';

  @override
  String get enumCatSaude => 'SantÃ©';

  @override
  String get enumCatLazer => 'Loisirs';

  @override
  String get enumCatOutros => 'Autres';

  @override
  String get enumChartExpensesPie => 'DÃ©penses par catÃ©gorie';

  @override
  String get enumChartIncomeVsExpenses => 'Revenus vs DÃ©penses';

  @override
  String get enumChartNetIncome => 'Revenu Net';

  @override
  String get enumChartDeductions => 'PrÃ©lÃ¨vements (IR + Cotis.)';

  @override
  String get enumChartSavingsRate => 'Taux d\'Ã©pargne';

  @override
  String get enumMealBreakfast => 'Petit-dÃ©jeuner';

  @override
  String get enumMealLunch => 'DÃ©jeuner';

  @override
  String get enumMealSnack => 'GoÃ»ter';

  @override
  String get enumMealDinner => 'DÃ®ner';

  @override
  String get enumObjMinimizeCost => 'Minimiser les coÃ»ts';

  @override
  String get enumObjBalancedHealth => 'Ã‰quilibre coÃ»t/santÃ©';

  @override
  String get enumObjHighProtein => 'Riche en protÃ©ines';

  @override
  String get enumObjLowCarb => 'Faible en glucides';

  @override
  String get enumObjVegetarian => 'VÃ©gÃ©tarien';

  @override
  String get enumEquipOven => 'Four';

  @override
  String get enumEquipAirFryer => 'Friteuse Ã  air';

  @override
  String get enumEquipFoodProcessor => 'Robot culinaire';

  @override
  String get enumEquipPressureCooker => 'Autocuiseur';

  @override
  String get enumEquipMicrowave => 'Micro-ondes';

  @override
  String get enumEquipBimby => 'Bimby / Thermomix';

  @override
  String get enumSodiumNoRestriction => 'Sans restriction';

  @override
  String get enumSodiumReduced => 'Sodium rÃ©duit';

  @override
  String get enumSodiumLow => 'Faible en sodium';

  @override
  String get enumAge0to3 => '0â€“3 ans';

  @override
  String get enumAge4to10 => '4â€“10 ans';

  @override
  String get enumAgeTeen => 'Adolescent';

  @override
  String get enumAgeAdult => 'Adulte';

  @override
  String get enumAgeSenior => 'Senior (65+)';

  @override
  String get enumActivitySedentary => 'SÃ©dentaire';

  @override
  String get enumActivityModerate => 'ModÃ©rÃ©';

  @override
  String get enumActivityActive => 'Actif';

  @override
  String get enumActivityVeryActive => 'TrÃ¨s actif';

  @override
  String get enumMedDiabetes => 'DiabÃ¨te';

  @override
  String get enumMedHypertension => 'Hypertension';

  @override
  String get enumMedHighCholesterol => 'CholestÃ©rol Ã©levÃ©';

  @override
  String get enumMedGout => 'Goutte';

  @override
  String get enumMedIbs => 'Syndrome du cÃ´lon irritable';

  @override
  String get stressExcellent => 'Excellent';

  @override
  String get stressGood => 'Bon';

  @override
  String get stressWarning => 'Attention';

  @override
  String get stressCritical => 'Critique';

  @override
  String get stressFactorSavings => 'Taux d\'Ã©pargne';

  @override
  String get stressFactorSafety => 'Marge de sÃ©curitÃ©';

  @override
  String get stressFactorFood => 'Budget alimentation';

  @override
  String get stressFactorStability => 'StabilitÃ© des dÃ©penses';

  @override
  String get stressStable => 'Stable';

  @override
  String get stressHigh => 'Ã‰levÃ©e';

  @override
  String stressUsed(String percent) {
    return '$percent% utilisÃ©';
  }

  @override
  String get stressNA => 'N/D';

  @override
  String monthReviewFoodExceeded(String percent) {
    return 'L\'alimentation a dÃ©passÃ© le budget de $percent% â€” envisagez de revoir les portions ou la frÃ©quence des courses.';
  }

  @override
  String monthReviewExpensesExceeded(String amount) {
    return 'Les dÃ©penses rÃ©elles ont dÃ©passÃ© le prÃ©vu de $amountâ‚¬ â€” ajuster les valeurs dans les paramÃ¨tres ?';
  }

  @override
  String monthReviewSavedMore(String amount) {
    return 'Ã‰conomisÃ© $amountâ‚¬ de plus que prÃ©vu â€” vous pouvez renforcer le fonds d\'urgence.';
  }

  @override
  String get monthReviewOnTrack =>
      'DÃ©penses dans les prÃ©visions. Bon contrÃ´le budgÃ©taire.';

  @override
  String get dashboardTitle => 'Budget Mensuel';

  @override
  String get dashboardStressIndex => 'Indice de SÃ©rÃ©nitÃ©';

  @override
  String get dashboardTension => 'Tension';

  @override
  String get dashboardLiquidity => 'LiquiditÃ©';

  @override
  String get dashboardFinalPosition => 'Position Finale';

  @override
  String get dashboardMonth => 'Mois';

  @override
  String get dashboardGross => 'Brut';

  @override
  String get dashboardNet => 'Net';

  @override
  String get dashboardExpenses => 'DÃ©penses';

  @override
  String get dashboardSavingsRate => 'Taux Ã‰pargne';

  @override
  String get dashboardViewTrends => 'Voir Ã©volution';

  @override
  String get dashboardViewProjection => 'Voir projection';

  @override
  String get dashboardFinancialSummary => 'RÃ‰SUMÃ‰ FINANCIER';

  @override
  String get dashboardOpenSettings => 'Ouvrir les paramÃ¨tres';

  @override
  String get dashboardMonthlyLiquidity => 'LIQUIDITÃ‰ MENSUELLE';

  @override
  String get dashboardPositiveBalance => 'Solde positif';

  @override
  String get dashboardNegativeBalance => 'Solde nÃ©gatif';

  @override
  String dashboardHeroLabel(String amount, String status) {
    return 'LiquiditÃ© mensuelle : $amount, $status';
  }

  @override
  String get dashboardConfigureData =>
      'Configurez vos donnÃ©es pour voir le rÃ©sumÃ©.';

  @override
  String get dashboardOpenSettingsButton => 'Ouvrir les ParamÃ¨tres';

  @override
  String get dashboardGrossIncome => 'Revenu Brut';

  @override
  String get dashboardNetIncome => 'Revenu Net';

  @override
  String dashboardInclMealAllowance(String amount) {
    return 'Incl. indemn. repas : $amount';
  }

  @override
  String get dashboardDeductions => 'PrÃ©lÃ¨vements';

  @override
  String dashboardIrsSs(String irs, String ss) {
    return 'IR : $irs | Cotis. : $ss';
  }

  @override
  String dashboardExpensesAmount(String amount) {
    return 'DÃ©penses : $amount';
  }

  @override
  String get dashboardSalaryDetail => 'DÃ‰TAIL DES SALAIRES';

  @override
  String dashboardSalaryN(int n) {
    return 'Salaire $n';
  }

  @override
  String get dashboardFood => 'ALIMENTATION';

  @override
  String get dashboardSimulate => 'Simuler';

  @override
  String get dashboardBudgeted => 'BudgÃ©tÃ©';

  @override
  String get dashboardSpent => 'DÃ©pensÃ©';

  @override
  String get dashboardRemaining => 'Restant';

  @override
  String get dashboardFinalizePurchaseHint =>
      'Finalisez un achat dans la Liste pour enregistrer les dÃ©penses.';

  @override
  String get dashboardPurchaseHistory => 'HISTORIQUE DES ACHATS';

  @override
  String get dashboardViewAll => 'Tout voir';

  @override
  String get dashboardAllPurchases => 'Tous les Achats';

  @override
  String dashboardPurchaseLabel(String date, String amount) {
    return 'Achat du $date, $amount';
  }

  @override
  String dashboardProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produits',
      one: '1 produit',
    );
    return '$_temp0';
  }

  @override
  String get dashboardMonthlyExpenses => 'DÃ‰PENSES MENSUELLES';

  @override
  String get dashboardTotal => 'Total';

  @override
  String get dashboardGrossWithSubsidy => 'Brut av/ primes';

  @override
  String dashboardIrsRate(String rate) {
    return 'IR ($rate)';
  }

  @override
  String get dashboardSsRate => 'Cotis. Soc. (11%)';

  @override
  String get dashboardMealAllowance => 'Indemn. Repas';

  @override
  String get dashboardExemptIncome => 'Rev. ExonÃ©rÃ©';

  @override
  String get dashboardDetails => 'DÃ©tails';

  @override
  String dashboardVsLastMonth(String delta) {
    return '$delta vs mois dernier';
  }

  @override
  String get dashboardPaceWarning => 'DÃ©penses plus rapides que prÃ©vu';

  @override
  String get dashboardPaceCritical =>
      'Risque de dÃ©passement du budget alimentaire';

  @override
  String get dashboardPace => 'Rythme';

  @override
  String get dashboardProjection => 'Projection';

  @override
  String dashboardPaceValue(String actual, String expected) {
    return '$actual€/jour vs $expected€/jour';
  }

  @override
  String get dashboardSummaryLabel => 'â€” RÃ‰SUMÃ‰';

  @override
  String get dashboardViewMonthSummary => 'Voir le rÃ©sumÃ© du mois';

  @override
  String get coachTitle => 'Coach Financier';

  @override
  String get coachSubtitle => 'IA Â· GPT-4o mini';

  @override
  String get coachApiKeyRequired =>
      'Ajoutez votre clÃ© API OpenAI dans les ParamÃ¨tres pour utiliser cette fonctionnalitÃ©.';

  @override
  String get coachAnalysisTitle => 'Analyse financiÃ¨re en 3 parties';

  @override
  String get coachAnalysisDescription =>
      'Positionnement gÃ©nÃ©ral Â· Facteurs critiques de l\'Indice de SÃ©rÃ©nitÃ© Â· OpportunitÃ© immÃ©diate. BasÃ© sur vos donnÃ©es rÃ©elles de budget, dÃ©penses et historique d\'achats.';

  @override
  String get coachConfigureApiKey =>
      'Configurer la clÃ© API dans les ParamÃ¨tres';

  @override
  String get coachApiKeyConfigured => 'ClÃ© API configurÃ©e';

  @override
  String get coachAnalyzeButton => 'Analyser mon budget';

  @override
  String get coachAnalyzing => 'Analyse en cours...';

  @override
  String get coachCustomAnalysis => 'Analyse personnalisÃ©e';

  @override
  String get coachNewAnalysis => 'GÃ©nÃ©rer nouvelle analyse';

  @override
  String get coachHistory => 'HISTORIQUE';

  @override
  String get coachClearAll => 'Tout effacer';

  @override
  String get coachClearTitle => 'Effacer l\'historique';

  @override
  String get coachClearContent =>
      'ÃŠtes-vous sÃ»r de vouloir supprimer toutes les analyses enregistrÃ©es ?';

  @override
  String get coachDeleteLabel => 'Supprimer l\'analyse';

  @override
  String get coachDeleteTooltip => 'Supprimer';

  @override
  String get groceryTitle => 'Courses';

  @override
  String get grocerySearchHint => 'Rechercher un produit...';

  @override
  String get groceryLoadingLabel => 'Chargement des produits';

  @override
  String get groceryLoadingMessage => 'Chargement des produits...';

  @override
  String get groceryAll => 'Tous';

  @override
  String groceryProductCount(int count) {
    return '$count produits';
  }

  @override
  String groceryAddedToList(String name) {
    return '$name ajoutÃ© Ã  la liste';
  }

  @override
  String groceryAvgPrice(String unit) {
    return '$unit Â· prix moyen';
  }

  @override
  String get shoppingTitle => 'Liste de Courses';

  @override
  String get shoppingEmpty => 'Liste vide';

  @override
  String get shoppingEmptyMessage =>
      'Ajoutez des produits depuis\nl\'Ã©cran Courses.';

  @override
  String shoppingItemsRemaining(int count, String total) {
    return '$count Ã  acheter Â· $total';
  }

  @override
  String get shoppingClear => 'Effacer';

  @override
  String get shoppingFinalize => 'Finaliser l\'Achat';

  @override
  String get shoppingEstimatedTotal => 'Total estimÃ©';

  @override
  String get shoppingHowMuchSpent => 'COMBIEN AI-JE DÃ‰PENSÃ‰ ? (optionnel)';

  @override
  String get shoppingConfirm => 'Confirmer';

  @override
  String get shoppingHistoryTooltip => 'Historique d\'achats';

  @override
  String get shoppingHistoryTitle => 'Historique d\'Achats';

  @override
  String shoppingItemChecked(String name) {
    return '$name, achetÃ©';
  }

  @override
  String shoppingItemSwipe(String name) {
    return '$name, glisser pour supprimer';
  }

  @override
  String shoppingProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produits',
      one: '1 produit',
    );
    return '$_temp0';
  }

  @override
  String get authLogin => 'Se connecter';

  @override
  String get authRegister => 'CrÃ©er un compte';

  @override
  String get authEmail => 'Email';

  @override
  String get authEmailHint => 'exemple@email.com';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authLoginButton => 'Se connecter';

  @override
  String get authRegisterButton => 'S\'inscrire';

  @override
  String get authSwitchToRegister => 'CrÃ©er un nouveau compte';

  @override
  String get authSwitchToLogin => 'J\'ai dÃ©jÃ  un compte';

  @override
  String get authRegistrationSuccess =>
      'Compte crÃ©Ã© ! VÃ©rifiez votre email pour confirmer votre compte avant de vous connecter.';

  @override
  String get householdSetupTitle => 'Configurer le Foyer';

  @override
  String get householdCreate => 'CrÃ©er';

  @override
  String get householdJoinWithCode => 'Rejoindre avec un code';

  @override
  String get householdNameLabel => 'Nom du foyer';

  @override
  String get householdNameHint => 'ex : Famille Dupont';

  @override
  String get householdCodeLabel => 'Code d\'invitation';

  @override
  String get householdCodeHint => 'XXXXXX';

  @override
  String get householdCreateButton => 'CrÃ©er le Foyer';

  @override
  String get householdJoinButton => 'Rejoindre le Foyer';

  @override
  String get householdNameRequired => 'Veuillez indiquer le nom du foyer.';

  @override
  String get chartExpensesByCategory => 'DÃ©penses par CatÃ©gorie';

  @override
  String get chartIncomeVsExpenses => 'Revenus vs DÃ©penses';

  @override
  String get chartDeductions => 'PrÃ©lÃ¨vements (IR + Cotisations)';

  @override
  String get chartGrossVsNet => 'Revenu Brut vs Net';

  @override
  String get chartSavingsRate => 'Taux d\'Ã‰pargne';

  @override
  String get chartNetIncome => 'Rev. Net';

  @override
  String get chartExpensesLabel => 'DÃ©penses';

  @override
  String get chartLiquidity => 'LiquiditÃ©';

  @override
  String chartSalaryN(int n) {
    return 'Sal. $n';
  }

  @override
  String get chartGross => 'Brut';

  @override
  String get chartNet => 'Net';

  @override
  String get chartNetSalary => 'Sal. Net';

  @override
  String get chartIRS => 'IR';

  @override
  String get chartSocialSecurity => 'Cotis. Soc.';

  @override
  String get chartSavings => 'Ã©pargne';

  @override
  String projectionTitle(String month, String year) {
    return 'Projection â€” $month $year';
  }

  @override
  String projectionSubtitle(String spent, String budget, String days) {
    return 'DÃ©pensÃ© $spent sur $budget en $days jours';
  }

  @override
  String get projectionFood => 'ALIMENTATION';

  @override
  String get projectionCurrentPace => 'Rythme actuel';

  @override
  String get projectionNoShopping => 'Sans courses';

  @override
  String get projectionReduce20 => '-20%';

  @override
  String projectionDailySpend(String amount) {
    return 'DÃ©pense journaliÃ¨re estimÃ©e : $amount/jour';
  }

  @override
  String get projectionEndOfMonth => 'Projection fin de mois';

  @override
  String get projectionRemaining => 'Restant projetÃ©';

  @override
  String get projectionStressImpact => 'Impact sur l\'indice';

  @override
  String get projectionExpenses => 'DÃ‰PENSES';

  @override
  String get projectionSimulation => 'Simulation â€” non enregistrÃ©';

  @override
  String get projectionReduceAll => 'RÃ©duire toutes de ';

  @override
  String get projectionSimLiquidity => 'LiquiditÃ© simulÃ©e';

  @override
  String get projectionDelta => 'Delta';

  @override
  String get projectionSimSavingsRate => 'Taux Ã©pargne simulÃ©';

  @override
  String get projectionSimIndex => 'Indice simulÃ©';

  @override
  String get trendTitle => 'Ã‰volution';

  @override
  String get trendStressIndex => 'INDICE DE SÃ‰RÃ‰NITÃ‰';

  @override
  String get trendTotalExpenses => 'DÃ‰PENSES TOTALES';

  @override
  String get trendExpensesByCategory => 'DÃ‰PENSES PAR CATÃ‰GORIE';

  @override
  String trendCurrent(String amount) {
    return 'Actuel : $amount';
  }

  @override
  String get trendCatTelecom => 'TÃ©lÃ©com';

  @override
  String get trendCatEnergy => 'Ã‰nergie';

  @override
  String get trendCatWater => 'Eau';

  @override
  String get trendCatFood => 'Alimentation';

  @override
  String get trendCatEducation => 'Ã‰ducation';

  @override
  String get trendCatHousing => 'Logement';

  @override
  String get trendCatTransport => 'Transport';

  @override
  String get trendCatHealth => 'SantÃ©';

  @override
  String get trendCatLeisure => 'Loisirs';

  @override
  String get trendCatOther => 'Autres';

  @override
  String monthReviewTitle(String month) {
    return 'RÃ©sumÃ© â€” $month';
  }

  @override
  String get monthReviewPlanned => 'PrÃ©vu';

  @override
  String get monthReviewActual => 'RÃ©el';

  @override
  String get monthReviewDifference => 'DiffÃ©rence';

  @override
  String get monthReviewFood => 'Alimentation';

  @override
  String monthReviewFoodValue(String actual, String budget) {
    return '$actual sur $budget';
  }

  @override
  String get monthReviewTopDeviations => 'Ã‰CARTS PRINCIPAUX';

  @override
  String get monthReviewSuggestions => 'SUGGESTIONS';

  @override
  String get monthReviewAiAnalysis => 'Analyse IA dÃ©taillÃ©e';

  @override
  String get mealPlannerTitle => 'Planificateur de Repas';

  @override
  String get mealBudgetLabel => 'Budget alimentation';

  @override
  String get mealPeopleLabel => 'Personnes au foyer';

  @override
  String get mealGeneratePlan => 'GÃ©nÃ©rer le Plan Mensuel';

  @override
  String get mealGenerating => 'GÃ©nÃ©ration...';

  @override
  String get mealRegenerateTitle => 'RÃ©gÃ©nÃ©rer le plan ?';

  @override
  String get mealRegenerateContent => 'Le plan actuel sera remplacÃ©.';

  @override
  String get mealRegenerate => 'RÃ©gÃ©nÃ©rer';

  @override
  String mealWeekLabel(int n) {
    return 'Semaine $n';
  }

  @override
  String mealWeekAbbr(int n) {
    return 'Sem.$n';
  }

  @override
  String get mealAddWeekToList => 'Ajouter la semaine Ã  la liste';

  @override
  String mealIngredientsAdded(int count) {
    return '$count ingrÃ©dients ajoutÃ©s Ã  la liste';
  }

  @override
  String mealDayLabel(int n) {
    return 'Jour $n';
  }

  @override
  String get mealIngredients => 'IngrÃ©dients';

  @override
  String get mealPreparation => 'PrÃ©paration';

  @override
  String get mealSwap => 'Ã‰changer';

  @override
  String get mealConsolidatedList => 'Voir la liste consolidÃ©e';

  @override
  String get mealConsolidatedTitle => 'Liste ConsolidÃ©e';

  @override
  String get mealAlternatives => 'Alternatives';

  @override
  String mealTotalCost(String cost) {
    return '$costâ‚¬ total';
  }

  @override
  String get mealCatProteins => 'ProtÃ©ines';

  @override
  String get mealCatVegetables => 'LÃ©gumes';

  @override
  String get mealCatCarbs => 'Glucides';

  @override
  String get mealCatFats => 'MatiÃ¨res grasses';

  @override
  String get mealCatCondiments => 'Condiments';

  @override
  String mealCostPerPerson(String cost) {
    return '$cost€/pers';
  }

  @override
  String get mealNutriProt => 'prot';

  @override
  String get mealNutriCarbs => 'gluc';

  @override
  String get mealNutriFat => 'gras';

  @override
  String get mealNutriFiber => 'fibre';

  @override
  String get wizardStepMeals => 'Repas';

  @override
  String get wizardStepObjective => 'Objectif';

  @override
  String get wizardStepRestrictions => 'Restrictions';

  @override
  String get wizardStepKitchen => 'Cuisine';

  @override
  String get wizardStepStrategy => 'StratÃ©gie';

  @override
  String get wizardMealsQuestion =>
      'Quels repas voulez-vous inclure dans le plan quotidien ?';

  @override
  String wizardBudgetWeight(String weight) {
    return '$weight du budget';
  }

  @override
  String get wizardObjectiveQuestion =>
      'Quel est l\'objectif principal de votre plan alimentaire ?';

  @override
  String wizardSelected(String label) {
    return '$label, sÃ©lectionnÃ©';
  }

  @override
  String get wizardDietaryRestrictions => 'RESTRICTIONS ALIMENTAIRES';

  @override
  String get wizardGlutenFree => 'Sans gluten';

  @override
  String get wizardLactoseFree => 'Sans lactose';

  @override
  String get wizardNutFree => 'Sans fruits Ã  coque';

  @override
  String get wizardShellfishFree => 'Sans crustacÃ©s';

  @override
  String get wizardDislikedIngredients => 'INGRÃ‰DIENTS QUE VOUS N\'AIMEZ PAS';

  @override
  String get wizardDislikedHint => 'ex : thon, brocoli';

  @override
  String get wizardMaxPrepTime => 'TEMPS DE PRÃ‰PARATION MAXIMUM';

  @override
  String get wizardMaxComplexity => 'COMPLEXITÃ‰ MAXIMUM';

  @override
  String get wizardComplexityEasy => 'Facile';

  @override
  String get wizardComplexityMedium => 'Moyen';

  @override
  String get wizardComplexityAdvanced => 'AvancÃ©';

  @override
  String get wizardEquipment => 'Ã‰QUIPEMENT DISPONIBLE';

  @override
  String get wizardBatchCooking => 'Batch cooking';

  @override
  String get wizardBatchCookingDesc =>
      'Cuisiner pour plusieurs jours Ã  la fois';

  @override
  String get wizardMaxBatchDays => 'JOURS MAXIMUM PAR RECETTE';

  @override
  String wizardBatchDays(int days) {
    return '$days jours';
  }

  @override
  String get wizardPreferredCookingDay => 'JOUR DE CUISINE PRÃ‰FÃ‰RÃ‰';

  @override
  String get wizardReuseLeftovers => 'RÃ©utiliser les restes';

  @override
  String get wizardReuseLeftoversDesc =>
      'Le dÃ®ner d\'hier = le dÃ©jeuner d\'aujourd\'hui (coÃ»t 0)';

  @override
  String get wizardMaxNewIngredients => 'NOUVEAUX INGRÃ‰DIENTS PAR SEMAINE MAX';

  @override
  String get wizardNoLimit => 'Sans limite';

  @override
  String get wizardMinimizeWaste => 'Minimiser le gaspillage';

  @override
  String get wizardMinimizeWasteDesc =>
      'PrÃ©fÃ©rer les recettes rÃ©utilisant des ingrÃ©dients dÃ©jÃ  utilisÃ©s';

  @override
  String get wizardSettingsInfo =>
      'Vous pouvez modifier les paramÃ¨tres du planificateur Ã  tout moment dans ParamÃ¨tres â†’ Repas.';

  @override
  String get wizardContinue => 'Continuer';

  @override
  String get wizardGeneratePlan => 'GÃ©nÃ©rer le Plan';

  @override
  String wizardStepOf(int current, int total) {
    return 'Ã‰tape $current sur $total';
  }

  @override
  String get wizardWeekdayMon => 'Lun';

  @override
  String get wizardWeekdayTue => 'Mar';

  @override
  String get wizardWeekdayWed => 'Mer';

  @override
  String get wizardWeekdayThu => 'Jeu';

  @override
  String get wizardWeekdayFri => 'Ven';

  @override
  String get wizardWeekdaySat => 'Sam';

  @override
  String get wizardWeekdaySun => 'Dim';

  @override
  String wizardPrepMin(int mins) {
    return '${mins}min';
  }

  @override
  String get wizardPrepMin60Plus => '60+';

  @override
  String get settingsTitle => 'ParamÃ¨tres';

  @override
  String get settingsPersonal => 'DonnÃ©es Personnelles';

  @override
  String get settingsSalaries => 'Salaires';

  @override
  String get settingsExpenses => 'Budget et Factures';

  @override
  String get settingsCoachAi => 'Coach IA';

  @override
  String get settingsDashboard => 'Tableau de bord';

  @override
  String get settingsMeals => 'Repas';

  @override
  String get settingsRegion => 'RÃ©gion et Langue';

  @override
  String get settingsCountry => 'Pays';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsMaritalStatus => 'Ã‰tat civil';

  @override
  String get settingsDependents => 'Personnes Ã  charge';

  @override
  String get settingsDisability => 'Handicap';

  @override
  String get settingsGrossSalary => 'Salaire brut';

  @override
  String get settingsTitulares => 'Titulaires d\'impÃ´t';

  @override
  String get settingsSubsidyMode => 'Primes';

  @override
  String get settingsMealAllowance => 'IndemnitÃ© repas';

  @override
  String get settingsMealAllowancePerDay => 'Montant/jour';

  @override
  String get settingsWorkingDays => 'Jours ouvrÃ©s/mois';

  @override
  String get settingsOtherExemptIncome => 'Autres revenus exonÃ©rÃ©s';

  @override
  String get settingsAddSalary => 'Ajouter un salaire';

  @override
  String get settingsAddExpense => 'Ajouter une catÃ©gorie';

  @override
  String get settingsExpenseName => 'Nom de catÃ©gorie';

  @override
  String get settingsExpenseAmount => 'Montant';

  @override
  String get settingsExpenseCategory => 'CatÃ©gorie';

  @override
  String get settingsApiKey => 'ClÃ© API OpenAI';

  @override
  String get settingsInviteCode => 'Code d\'invitation';

  @override
  String get settingsCopyCode => 'Copier';

  @override
  String get settingsCodeCopied => 'Code copiÃ© !';

  @override
  String get settingsAdminOnly =>
      'Seul l\'administrateur peut modifier les paramÃ¨tres.';

  @override
  String get settingsShowSummaryCards => 'Afficher les cartes rÃ©sumÃ©';

  @override
  String get settingsEnabledCharts => 'Graphiques actifs';

  @override
  String get settingsLogout => 'Se dÃ©connecter';

  @override
  String get settingsLogoutConfirmTitle => 'Se dÃ©connecter';

  @override
  String get settingsLogoutConfirmContent =>
      'ÃŠtes-vous sÃ»r de vouloir vous dÃ©connecter ?';

  @override
  String get settingsLogoutConfirmButton => 'Se dÃ©connecter';

  @override
  String get settingsSalariesSection => 'Revenus';

  @override
  String get settingsExpensesMonthly => 'Budget et Factures';

  @override
  String get settingsFavorites => 'Produits Favoris';

  @override
  String get settingsCoachOpenAi => 'Coach IA (OpenAI)';

  @override
  String get settingsHousehold => 'Foyer';

  @override
  String get settingsMaritalStatusLabel => 'Ã‰TAT CIVIL';

  @override
  String get settingsDependentsLabel => 'NOMBRE DE PERSONNES Ã€ CHARGE';

  @override
  String settingsSocialSecurityRate(String rate) {
    return 'Cotisations sociales : $rate';
  }

  @override
  String get settingsSalaryActive => 'Actif';

  @override
  String get settingsGrossMonthlySalary => 'SALAIRE BRUT MENSUEL';

  @override
  String get settingsSubsidyHoliday =>
      'PRIMES DE VACANCES ET NOÃ‹L (DOUZIÃˆMES)';

  @override
  String get settingsOtherExemptLabel => 'AUTRES REVENUS EXONÃ‰RÃ‰S D\'IMPÃ”T';

  @override
  String get settingsMealAllowanceLabel => 'INDEMNITÃ‰ REPAS';

  @override
  String get settingsAmountPerDay => 'MONTANT/JOUR';

  @override
  String get settingsDaysPerMonth => 'JOURS/MOIS';

  @override
  String get settingsTitularesLabel => 'TITULAIRES D\'IMPÃ”T';

  @override
  String settingsTitularCount(int n, String suffix) {
    return '$n Titulaire$suffix';
  }

  @override
  String get settingsAddSalaryButton => 'Ajouter un salaire';

  @override
  String get settingsAddExpenseButton => 'Ajouter une CatÃ©gorie';

  @override
  String get settingsDeviceLocal =>
      'Ces paramÃ¨tres sont stockÃ©s localement sur cet appareil.';

  @override
  String get settingsVisibleSections => 'SECTIONS VISIBLES';

  @override
  String get settingsMinimalist => 'Minimaliste';

  @override
  String get settingsFull => 'Complet';

  @override
  String get settingsDashMonthlyLiquidity => 'LiquiditÃ© mensuelle';

  @override
  String get settingsDashStressIndex => 'Indice de SÃ©rÃ©nitÃ©';

  @override
  String get settingsDashSummaryCards => 'Cartes rÃ©sumÃ©';

  @override
  String get settingsDashSalaryBreakdown => 'DÃ©tail par salaire';

  @override
  String get settingsDashFood => 'Alimentation';

  @override
  String get settingsDashPurchaseHistory => 'Historique d\'achats';

  @override
  String get settingsDashExpensesBreakdown => 'DÃ©tail des dÃ©penses';

  @override
  String get settingsDashMonthReview => 'Bilan du mois';

  @override
  String get settingsDashCharts => 'Graphiques';

  @override
  String get dashGroupOverview => 'VUE D\'ENSEMBLE';

  @override
  String get dashGroupFinancialDetail => 'DÃ‰TAIL FINANCIER';

  @override
  String get dashGroupHistory => 'HISTORIQUE';

  @override
  String get dashGroupCharts => 'GRAPHIQUES';

  @override
  String get settingsVisibleCharts => 'GRAPHIQUES VISIBLES';

  @override
  String get settingsFavTip =>
      'Les produits favoris influencent le plan repas — les recettes avec ces ingrÃ©dients sont prioritaires.';

  @override
  String get settingsMyFavorites => 'MES FAVORIS';

  @override
  String get settingsProductCatalog => 'CATALOGUE DE PRODUITS';

  @override
  String get settingsSearchProduct => 'Rechercher un produit...';

  @override
  String get settingsLoadingProducts => 'Chargement des produits...';

  @override
  String get settingsAddIngredient => 'Ajouter un ingrÃ©dient';

  @override
  String get settingsIngredientName => 'Nom de l\'ingrÃ©dient';

  @override
  String get settingsAddButton => 'Ajouter';

  @override
  String get settingsAddToPantry => 'Ajouter au garde-manger';

  @override
  String get settingsHouseholdPeople => 'FOYER (PERSONNES)';

  @override
  String get settingsAutomatic => '(auto)';

  @override
  String get settingsUseAutoValue => 'Utiliser la valeur automatique';

  @override
  String settingsManualValue(int count) {
    return 'Valeur manuelle : $count personnes';
  }

  @override
  String settingsAutoValue(int count) {
    return 'CalculÃ© automatiquement : $count (titulaires + personnes Ã  charge)';
  }

  @override
  String get settingsHouseholdMembers => 'MEMBRES DU FOYER';

  @override
  String get settingsPortions => 'portions';

  @override
  String settingsTotalEquivalent(String total) {
    return 'Ã‰quivalent total : $total portions';
  }

  @override
  String get settingsAddMember => 'Ajouter un membre';

  @override
  String get settingsPreferSeasonal => 'PrÃ©fÃ©rer les recettes de saison';

  @override
  String get settingsPreferSeasonalDesc =>
      'Priorise les recettes de la saison actuelle';

  @override
  String get settingsNutritionalGoals => 'OBJECTIFS NUTRITIONNELS';

  @override
  String get settingsCalorieHint => 'ex : 2000';

  @override
  String get settingsKcalPerDay => 'kcal/jour';

  @override
  String get settingsProteinHint => 'ex : 60';

  @override
  String get settingsGramsPerDay => 'g/jour';

  @override
  String get settingsFiberHint => 'ex : 25';

  @override
  String get settingsDailyProtein => 'ProtÃ©ines quotidiennes';

  @override
  String get settingsDailyFiber => 'Fibres quotidiennes';

  @override
  String get settingsMedicalConditions => 'CONDITIONS MÃ‰DICALES';

  @override
  String get settingsActiveMeals => 'REPAS ACTIFS';

  @override
  String get settingsObjective => 'OBJECTIF';

  @override
  String get settingsVeggieDays => 'JOURS VÃ‰GÃ‰TARIENS PAR SEMAINE';

  @override
  String get settingsDietaryRestrictions => 'RESTRICTIONS ALIMENTAIRES';

  @override
  String get settingsEggFree => 'Sans oeufs';

  @override
  String get settingsSodiumPref => 'PRÃ‰FÃ‰RENCE EN SODIUM';

  @override
  String get settingsDislikedIngredients => 'INGRÃ‰DIENTS NON SOUHAITÃ‰S';

  @override
  String get settingsExcludedProteins => 'PROTÃ‰INES EXCLUES';

  @override
  String get settingsProteinChicken => 'Poulet';

  @override
  String get settingsProteinGroundMeat => 'Viande hachÃ©e';

  @override
  String get settingsProteinPork => 'Porc';

  @override
  String get settingsProteinHake => 'Merlu';

  @override
  String get settingsProteinCod => 'Morue';

  @override
  String get settingsProteinSardine => 'Sardine';

  @override
  String get settingsProteinTuna => 'Thon';

  @override
  String get settingsProteinEgg => 'Oeufs';

  @override
  String get settingsMaxPrepTime => 'TEMPS MAX (MINUTES)';

  @override
  String settingsMaxComplexity(int value) {
    return 'COMPLEXITÃ‰ MAXIMUM ($value/5)';
  }

  @override
  String get settingsWeekendPrepTime => 'TEMPS WEEK-END (MINUTES)';

  @override
  String settingsWeekendComplexity(int value) {
    return 'COMPLEXITÃ‰ WEEK-END ($value/5)';
  }

  @override
  String get settingsEatingOutDays => 'JOURS AU RESTAURANT';

  @override
  String get settingsWeeklyDistribution => 'DISTRIBUTION HEBDOMADAIRE';

  @override
  String settingsFishPerWeek(String count) {
    return 'Poisson par semaine : $count';
  }

  @override
  String get settingsNoMinimum => 'sans minimum';

  @override
  String settingsLegumePerWeek(String count) {
    return 'LÃ©gumineuses par semaine : $count';
  }

  @override
  String settingsRedMeatPerWeek(String count) {
    return 'Viande rouge max/semaine : $count';
  }

  @override
  String get settingsNoLimit => 'sans limite';

  @override
  String get settingsAvailableEquipment => 'Ã‰QUIPEMENT DISPONIBLE';

  @override
  String get settingsBatchCooking => 'Batch cooking';

  @override
  String get settingsMaxBatchDays => 'JOURS MAX PAR RECETTE';

  @override
  String get settingsReuseLeftovers => 'RÃ©utiliser les restes';

  @override
  String get settingsMinimizeWaste => 'Minimiser le gaspillage';

  @override
  String get settingsPrioritizeLowCost => 'Prioriser le bas coÃ»t';

  @override
  String get settingsPrioritizeLowCostDesc =>
      'PrÃ©fÃ©rer les recettes moins chÃ¨res';

  @override
  String settingsNewIngredientsPerWeek(int count) {
    return 'NOUVEAUX INGRÃ‰DIENTS PAR SEMAINE ($count)';
  }

  @override
  String get settingsLunchboxLunches => 'DÃ©jeuners en boÃ®te';

  @override
  String get settingsLunchboxLunchesDesc =>
      'Uniquement des recettes transportables pour le dÃ©jeuner';

  @override
  String get settingsPantry => 'GARDE-MANGER (TOUJOURS EN STOCK)';

  @override
  String get settingsResetWizard => 'RÃ©initialiser l\'Assistant';

  @override
  String get settingsApiKeyInfo =>
      'La clÃ© est stockÃ©e localement sur l\'appareil et n\'est jamais partagÃ©e. Utilise le modÃ¨le GPT-4o mini (~€0,00008 par analyse).';

  @override
  String get settingsInviteCodeLabel => 'CODE D\'INVITATION';

  @override
  String get settingsGenerateInvite => 'GÃ©nÃ©rer un code d\'invitation';

  @override
  String get settingsShareWithMembers => 'Partager avec les membres du foyer';

  @override
  String get settingsNewCode => 'Nouveau code';

  @override
  String get settingsCodeValidInfo =>
      'Le code est valide pendant 7 jours. Partagez-le avec les personnes que vous souhaitez ajouter au foyer.';

  @override
  String get settingsName => 'Nom';

  @override
  String get settingsAgeGroup => 'Tranche d\'Ã¢ge';

  @override
  String get settingsActivityLevel => 'Niveau d\'activitÃ©';

  @override
  String settingsSalaryN(int n) {
    return 'Salaire $n';
  }

  @override
  String get countryPT => 'Portugal';

  @override
  String get countryES => 'Espagne';

  @override
  String get countryFR => 'France';

  @override
  String get countryUK => 'Royaume-Uni';

  @override
  String get langPT => 'PortuguÃªs';

  @override
  String get langEN => 'English';

  @override
  String get langFR => 'FranÃ§ais';

  @override
  String get langES => 'EspaÃ±ol';

  @override
  String get langSystem => 'SystÃ¨me';

  @override
  String get taxIncomeTax => 'ImpÃ´t sur le revenu';

  @override
  String get taxSocialContribution => 'Cotisation sociale';

  @override
  String get taxIRS => 'IRS';

  @override
  String get taxSS => 'SÃ©curitÃ© Sociale';

  @override
  String get taxIRPF => 'IRPF';

  @override
  String get taxSSSpain => 'Seguridad Social';

  @override
  String get taxIR => 'ImpÃ´t sur le Revenu';

  @override
  String get taxCSG => 'CSG + CRDS';

  @override
  String get taxPAYE => 'Income Tax';

  @override
  String get taxNI => 'National Insurance';

  @override
  String get enumSubsidyEsNone => 'Sans payes extras';

  @override
  String get enumSubsidyEsFull => 'Avec payes extras';

  @override
  String get enumSubsidyEsHalf => '50% payes extras';

  @override
  String get aiCoachSystemPrompt =>
      'Tu es un analyste financier personnel pour des utilisateurs portugais. RÃ©ponds toujours en portugais europÃ©en. Sois direct et analytique â€” utilise toujours les chiffres concrets du contexte fourni. Structure la rÃ©ponse exactement dans les 3 parties demandÃ©es. N\'introduis pas de donnÃ©es, benchmarks ou rÃ©fÃ©rences externes non fournis.';

  @override
  String get aiCoachInvalidApiKey =>
      'ClÃ© API invalide. VÃ©rifiez dans les ParamÃ¨tres.';

  @override
  String get aiCoachMidMonthSystem =>
      'Tu es un consultant en budget domestique portugais. RÃ©ponds toujours en portugais europÃ©en. Sois pratique et direct.';

  @override
  String get aiMealPlannerSystem =>
      'Tu es un chef portugais. RÃ©ponds toujours en portugais europÃ©en. RÃ©ponds UNIQUEMENT avec du JSON valide, sans texte supplÃ©mentaire.';

  @override
  String get monthAbbrJan => 'Jan';

  @override
  String get monthAbbrFeb => 'FÃ©v';

  @override
  String get monthAbbrMar => 'Mar';

  @override
  String get monthAbbrApr => 'Avr';

  @override
  String get monthAbbrMay => 'Mai';

  @override
  String get monthAbbrJun => 'Jui';

  @override
  String get monthAbbrJul => 'Jul';

  @override
  String get monthAbbrAug => 'AoÃ»';

  @override
  String get monthAbbrSep => 'Sep';

  @override
  String get monthAbbrOct => 'Oct';

  @override
  String get monthAbbrNov => 'Nov';

  @override
  String get monthAbbrDec => 'DÃ©c';

  @override
  String get monthFullJan => 'Janvier';

  @override
  String get monthFullFeb => 'FÃ©vrier';

  @override
  String get monthFullMar => 'Mars';

  @override
  String get monthFullApr => 'Avril';

  @override
  String get monthFullMay => 'Mai';

  @override
  String get monthFullJun => 'Juin';

  @override
  String get monthFullJul => 'Juillet';

  @override
  String get monthFullAug => 'AoÃ»t';

  @override
  String get monthFullSep => 'Septembre';

  @override
  String get monthFullOct => 'Octobre';

  @override
  String get monthFullNov => 'Novembre';

  @override
  String get monthFullDec => 'DÃ©cembre';

  @override
  String get setupWizardWelcomeTitle => 'Bienvenue dans votre budget';

  @override
  String get setupWizardWelcomeSubtitle =>
      'Configurons l\'essentiel pour que votre tableau de bord soit prÃªt.';

  @override
  String get setupWizardBullet1 => 'Calculer votre salaire net';

  @override
  String get setupWizardBullet2 => 'Organiser vos dÃ©penses';

  @override
  String get setupWizardBullet3 => 'Voir combien il vous reste chaque mois';

  @override
  String get setupWizardReassurance =>
      'Vous pouvez tout modifier plus tard dans les paramÃ¨tres.';

  @override
  String get setupWizardStart => 'Commencer';

  @override
  String get setupWizardSkipAll => 'Passer la configuration';

  @override
  String setupWizardStepOf(int step, int total) {
    return 'Ã‰tape $step sur $total';
  }

  @override
  String get setupWizardContinue => 'Continuer';

  @override
  String get setupWizardCountryTitle => 'OÃ¹ habitez-vous ?';

  @override
  String get setupWizardCountrySubtitle =>
      'Cela dÃ©finit le systÃ¨me fiscal, la devise et les valeurs par dÃ©faut.';

  @override
  String get setupWizardLanguage => 'Langue';

  @override
  String get setupWizardLangSystem => 'Par dÃ©faut du systÃ¨me';

  @override
  String get setupWizardCountryPT => 'Portugal';

  @override
  String get setupWizardCountryES => 'Espagne';

  @override
  String get setupWizardCountryFR => 'France';

  @override
  String get setupWizardCountryUK => 'Royaume-Uni';

  @override
  String get setupWizardPersonalTitle => 'Informations personnelles';

  @override
  String get setupWizardPersonalSubtitle =>
      'Nous utilisons ceci pour calculer vos impÃ´ts plus prÃ©cisÃ©ment.';

  @override
  String get setupWizardPrivacyNote =>
      'Vos donnÃ©es restent dans votre compte et ne sont jamais partagÃ©es.';

  @override
  String get setupWizardSingle => 'CÃ©libataire';

  @override
  String get setupWizardMarried => 'MariÃ©(e)';

  @override
  String get setupWizardDependents => 'Personnes Ã  charge';

  @override
  String get setupWizardTitulares => 'Titulaires fiscaux';

  @override
  String get setupWizardSalaryTitle => 'Quel est votre salaire ?';

  @override
  String get setupWizardSalarySubtitle =>
      'Entrez le montant brut mensuel. Nous calculerons le net automatiquement.';

  @override
  String get setupWizardSalaryGross => 'Salaire brut mensuel';

  @override
  String setupWizardNetEstimate(String amount) {
    return 'Net estimÃ© : $amount';
  }

  @override
  String get setupWizardSalaryMoreLater =>
      'Vous pouvez ajouter d\'autres sources de revenus plus tard.';

  @override
  String get setupWizardSalarySkip => 'Passer cette Ã©tape';

  @override
  String get setupWizardExpensesTitle => 'Vos dÃ©penses mensuelles';

  @override
  String get setupWizardExpensesSubtitle =>
      'Valeurs suggÃ©rÃ©es pour votre pays. Ajustez selon vos besoins.';

  @override
  String get setupWizardExpensesMoreLater =>
      'Vous pouvez ajouter d\'autres catÃ©gories plus tard.';

  @override
  String setupWizardNetLabel(String amount) {
    return 'Net : $amount';
  }

  @override
  String setupWizardTotalExpenses(String amount) {
    return 'DÃ©penses : $amount';
  }

  @override
  String setupWizardAvailableLabel(String amount) {
    return 'Disponible : $amount';
  }

  @override
  String get setupWizardFinish => 'Terminer';

  @override
  String get setupWizardCompleteTitle => 'Tout est prÃªt !';

  @override
  String get setupWizardCompleteReassurance =>
      'Votre budget est configurÃ©. Vous pouvez tout ajuster dans les paramÃ¨tres Ã  tout moment.';

  @override
  String get setupWizardGoToDashboard => 'Voir mon budget';

  @override
  String get setupWizardConfigureSalaryHint =>
      'Configurez votre salaire dans les paramÃ¨tres pour voir le calcul complet.';

  @override
  String get setupWizardExpRent => 'Loyer / CrÃ©dit immobilier';

  @override
  String get setupWizardExpGroceries => 'Alimentation';

  @override
  String get setupWizardExpTransport => 'Transport';

  @override
  String get setupWizardExpUtilities => 'Services (Ã©lectricitÃ©, eau, gaz)';

  @override
  String get setupWizardExpTelecom => 'TÃ©lÃ©communications';

  @override
  String get setupWizardExpHealth => 'SantÃ©';

  @override
  String get setupWizardExpLeisure => 'Loisirs';

  @override
  String get expenseTrackerTitle => 'BUDGET VS RÃ‰EL';

  @override
  String get expenseTrackerBudgeted => 'BudgÃ©tÃ©';

  @override
  String get expenseTrackerActual => 'RÃ©el';

  @override
  String get expenseTrackerRemaining => 'Restant';

  @override
  String get expenseTrackerOver => 'DÃ©passement';

  @override
  String get expenseTrackerViewAll => 'Voir dÃ©tails';

  @override
  String get expenseTrackerNoExpenses => 'Aucune dÃ©pense enregistrÃ©e.';

  @override
  String get expenseTrackerScreenTitle => 'Suivi des DÃ©penses';

  @override
  String expenseTrackerMonthTotal(String amount) {
    return 'Total : $amount';
  }

  @override
  String get expenseTrackerDeleteConfirm => 'Supprimer cette dÃ©pense ?';

  @override
  String get expenseTrackerEmpty =>
      'Aucune dÃ©pense ce mois.\nAppuyez sur + pour ajouter.';

  @override
  String get addExpenseTitle => 'Ajouter une DÃ©pense';

  @override
  String get editExpenseTitle => 'Modifier la DÃ©pense';

  @override
  String get addExpenseCategory => 'CatÃ©gorie';

  @override
  String get addExpenseAmount => 'Montant';

  @override
  String get addExpenseDate => 'Date';

  @override
  String get addExpenseDescription => 'Description (facultatif)';

  @override
  String get addExpenseCustomCategory => 'CatÃ©gorie personnalisÃ©e';

  @override
  String get addExpenseInvalidAmount => 'Entrez un montant valide';

  @override
  String get addExpenseTooltip => 'Saisir une dÃ©pense';

  @override
  String get addExpenseItem => 'DÃ©pense';

  @override
  String get addExpenseOthers => 'Autres';

  @override
  String get settingsDashBudgetVsActual => 'Budget vs RÃ©el';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsTheme => 'ThÃ¨me';

  @override
  String get themeSystem => 'SystÃ¨me';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get recurringExpenses => 'Factures Mensuelles';

  @override
  String get recurringExpenseAdd => 'Ajouter une Facture';

  @override
  String get recurringExpenseEdit => 'Modifier la Facture';

  @override
  String get recurringExpenseCategory => 'CatÃ©gorie';

  @override
  String get recurringExpenseAmount => 'Montant';

  @override
  String get recurringExpenseDescription => 'Description (facultatif)';

  @override
  String get recurringExpenseDayOfMonth => 'Jour d\'Ã©chÃ©ance';

  @override
  String get recurringExpenseActive => 'Active';

  @override
  String get recurringExpenseInactive => 'Inactive';

  @override
  String get recurringExpenseEmpty =>
      'Aucune facture mensuelle.\nAjoutez-en une pour la gÃ©nÃ©rer automatiquement chaque mois.';

  @override
  String get recurringExpenseDeleteConfirm => 'Supprimer cette facture ?';

  @override
  String get recurringExpenseAutoCreated => 'CrÃ©Ã©e automatiquement';

  @override
  String get recurringExpenseManage => 'GÃ©rer les factures';

  @override
  String get recurringExpenseMarkRecurring => 'Marquer comme facture mensuelle';

  @override
  String get recurringExpensePopulated =>
      'Factures mensuelles gÃ©nÃ©rÃ©es pour ce mois';

  @override
  String get recurringExpenseDayHint => 'Ex : 1 pour le 1er';

  @override
  String get recurringExpenseNoDay => 'Pas de jour fixe';

  @override
  String get recurringExpenseSaved => 'Facture enregistrÃ©e';

  @override
  String billsCount(int count) {
    return '$count factures';
  }

  @override
  String get billsNone => 'Aucune facture';

  @override
  String billsPerMonth(int count, String amount) {
    return '$count factures Â· $amount/mois';
  }

  @override
  String billsExceedBudget(String amount) {
    return 'Factures ($amount) dÃ©passent le budget';
  }

  @override
  String get billsAddBill => 'Ajouter une Facture';

  @override
  String get billsBudgetSettings => 'ParamÃ¨tres du Budget';

  @override
  String get billsRecurringBills => 'Factures RÃ©currentes';

  @override
  String get billsDescription => 'Description';

  @override
  String get billsAmount => 'Montant';

  @override
  String get billsDueDay => 'Jour d\'Ã©chÃ©ance';

  @override
  String get billsActive => 'Active';

  @override
  String get expenseTrends => 'Tendances des DÃ©penses';

  @override
  String get expenseTrendsViewTrends => 'Voir les Tendances';

  @override
  String get expenseTrends3Months => '3M';

  @override
  String get expenseTrends6Months => '6M';

  @override
  String get expenseTrends12Months => '12M';

  @override
  String get expenseTrendsBudgeted => 'BudgÃ©tÃ©';

  @override
  String get expenseTrendsActual => 'RÃ©el';

  @override
  String get expenseTrendsByCategory => 'Par CatÃ©gorie';

  @override
  String get expenseTrendsNoData =>
      'DonnÃ©es insuffisantes pour afficher les tendances.';

  @override
  String get expenseTrendsTotal => 'Total';

  @override
  String get expenseTrendsAverage => 'Moyenne';

  @override
  String get expenseTrendsOverview => 'Vue d\'ensemble';

  @override
  String get expenseTrendsMonthly => 'Mensuel';

  @override
  String get savingsGoals => 'Objectifs d\'Ã‰pargne';

  @override
  String get savingsGoalAdd => 'Nouvel Objectif';

  @override
  String get savingsGoalEdit => 'Modifier l\'Objectif';

  @override
  String get savingsGoalName => 'Nom de l\'objectif';

  @override
  String get savingsGoalTarget => 'Montant cible';

  @override
  String get savingsGoalCurrent => 'Montant actuel';

  @override
  String get savingsGoalDeadline => 'Date limite';

  @override
  String get savingsGoalNoDeadline => 'Pas de date limite';

  @override
  String get savingsGoalColor => 'Couleur';

  @override
  String savingsGoalProgress(String percent) {
    return '$percent% atteint';
  }

  @override
  String savingsGoalRemaining(String amount) {
    return '$amount restant';
  }

  @override
  String get savingsGoalCompleted => 'Objectif atteint !';

  @override
  String get savingsGoalEmpty =>
      'Aucun objectif d\'Ã©pargne.\nCrÃ©ez-en un pour suivre vos progrÃ¨s.';

  @override
  String get savingsGoalDeleteConfirm => 'Supprimer cet objectif ?';

  @override
  String get savingsGoalContribute => 'Contribuer';

  @override
  String get savingsGoalContributionAmount => 'Montant de la contribution';

  @override
  String get savingsGoalContributionNote => 'Note (facultatif)';

  @override
  String get savingsGoalContributionDate => 'Date';

  @override
  String get savingsGoalContributionHistory => 'Historique des Contributions';

  @override
  String get savingsGoalSeeAll => 'Voir tout';

  @override
  String savingsGoalSurplusSuggestion(String amount) {
    return 'Vous aviez $amount d\'excÃ©dent le mois dernier â€” allouer Ã  un objectif ?';
  }

  @override
  String get savingsGoalAllocate => 'Allouer';

  @override
  String get savingsGoalSaved => 'Objectif enregistrÃ©';

  @override
  String get savingsGoalContributionSaved => 'Contribution enregistrÃ©e';

  @override
  String get settingsDashSavingsGoals => 'Objectifs d\'Ã‰pargne';

  @override
  String get savingsGoalActive => 'Actif';

  @override
  String get savingsGoalInactive => 'Inactif';

  @override
  String savingsGoalDaysLeft(String days) {
    return '$days jours restants';
  }

  @override
  String get savingsGoalOverdue => 'En retard';

  @override
  String get savingsGoalHowItWorksTitle => 'Comment ça marche ?';

  @override
  String get savingsGoalHowItWorksStep1 => 'Créez un objectif avec un nom et le montant à atteindre (ex : \"Vacances — 2 000 €\").';

  @override
  String get savingsGoalHowItWorksStep2 => 'Définissez éventuellement une date limite comme référence.';

  @override
  String get savingsGoalHowItWorksStep3 => 'Chaque fois que vous économisez, touchez l\'objectif et enregistrez une contribution avec le montant et la date.';

  @override
  String get savingsGoalHowItWorksStep4 => 'Suivez votre progression : la barre montre combien vous avez épargné et la projection estime quand vous atteindrez votre objectif.';

  @override
  String get savingsGoalDashboardHint => 'Touchez un objectif pour voir les détails et enregistrer des contributions.';

  @override
  String get mealCostReconciliation => 'CoÃ»ts des Repas';

  @override
  String get mealCostEstimated => 'EstimÃ©';

  @override
  String get mealCostActual => 'RÃ©el';

  @override
  String mealCostWeek(String number) {
    return 'Semaine $number';
  }

  @override
  String get mealCostTotal => 'Total du Mois';

  @override
  String get mealCostSavings => 'Ã‰conomie';

  @override
  String get mealCostOverrun => 'DÃ©passement';

  @override
  String get mealCostNoData => 'Aucune donnÃ©e d\'achats repas.';

  @override
  String get mealCostViewCosts => 'CoÃ»ts';

  @override
  String get mealCostIsMealPurchase => 'Achat repas';

  @override
  String get mealCostVsBudget => 'vs budget';

  @override
  String get mealCostOnTrack => 'Dans le budget';

  @override
  String get mealCostOver => 'Au-dessus du budget';

  @override
  String get mealCostUnder => 'En dessous du budget';

  @override
  String get mealVariation => 'Variante';

  @override
  String get mealPairing => 'Accompagnement';

  @override
  String get mealStorage => 'Conservation';

  @override
  String get mealLeftover => 'Restes';

  @override
  String get mealLeftoverIdea => 'IdÃ©e de transformation';

  @override
  String get mealWeeklySummary => 'Nutrition Hebdomadaire';

  @override
  String get mealBatchPrepGuide => 'Guide de PrÃ©paration';

  @override
  String mealBatchTotalTime(String time) {
    return 'Temps estimÃ©: $time';
  }

  @override
  String get mealBatchParallelTips => 'Astuces de cuisson parallÃ¨le';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSettings => 'ParamÃ¨tres de Notifications';

  @override
  String get notificationBillReminders => 'Rappels de factures';

  @override
  String get notificationBillReminderDays => 'Jours avant l\'Ã©chÃ©ance';

  @override
  String get notificationBudgetAlerts => 'Alertes budget';

  @override
  String notificationBudgetThreshold(String percent) {
    return 'Seuil d\'alerte ($percent%)';
  }

  @override
  String get notificationMealPlanReminder => 'Rappel plan repas';

  @override
  String get notificationMealPlanReminderDesc =>
      'Notifie si aucun plan pour le mois en cours';

  @override
  String get notificationCustomReminders => 'Rappels PersonnalisÃ©s';

  @override
  String get notificationAddCustom => 'Ajouter un Rappel';

  @override
  String get notificationCustomTitle => 'Titre';

  @override
  String get notificationCustomBody => 'Message';

  @override
  String get notificationCustomTime => 'Heure';

  @override
  String get notificationCustomRepeat => 'RÃ©pÃ©ter';

  @override
  String get notificationCustomRepeatDaily => 'Quotidien';

  @override
  String get notificationCustomRepeatWeekly => 'Hebdomadaire';

  @override
  String get notificationCustomRepeatMonthly => 'Mensuel';

  @override
  String get notificationCustomRepeatNone => 'Ne pas rÃ©pÃ©ter';

  @override
  String get notificationCustomSaved => 'Rappel enregistrÃ©';

  @override
  String get notificationCustomDeleteConfirm => 'Supprimer ce rappel ?';

  @override
  String get notificationEmpty => 'Aucun rappel personnalisÃ©.';

  @override
  String notificationBillTitle(String name) {
    return 'Facture Ã  payer : $name';
  }

  @override
  String notificationBillBody(String amount, String days) {
    return '$amount dÃ» dans $days jours';
  }

  @override
  String get notificationBudgetTitle => 'Alerte budget';

  @override
  String notificationBudgetBody(String percent) {
    return 'Vous avez dÃ©pensÃ© $percent% du budget mensuel';
  }

  @override
  String get notificationMealPlanTitle => 'Plan de repas';

  @override
  String get notificationMealPlanBody =>
      'Vous n\'avez pas encore gÃ©nÃ©rÃ© le plan repas ce mois-ci';

  @override
  String get notificationPermissionRequired =>
      'Autorisation de notifications requise';

  @override
  String get notificationSelectDays => 'SÃ©lectionner les jours';

  @override
  String get settingsColorPalette => 'Palette de couleurs';

  @override
  String get paletteOcean => 'OcÃ©an';

  @override
  String get paletteEmerald => 'Ã‰meraude';

  @override
  String get paletteViolet => 'Violet';

  @override
  String get paletteTeal => 'Sarcelle';

  @override
  String get paletteSunset => 'Coucher de soleil';

  @override
  String get exportTooltip => 'Exporter';

  @override
  String get exportTitle => 'Exporter le mois';

  @override
  String get exportPdf => 'Rapport PDF';

  @override
  String get exportPdfDesc => 'Rapport avec budget vs rÃ©el';

  @override
  String get exportCsv => 'DonnÃ©es CSV';

  @override
  String get exportCsvDesc => 'DonnÃ©es brutes pour tableur';

  @override
  String get exportReportTitle => 'Rapport Mensuel des DÃ©penses';

  @override
  String get exportBudgetVsActual => 'Budget vs RÃ©el';

  @override
  String get exportExpenseDetail => 'DÃ©tail des DÃ©penses';

  @override
  String get searchExpenses => 'Rechercher';

  @override
  String get searchExpensesHint => 'Rechercher par description...';

  @override
  String get searchDateRange => 'PÃ©riode';

  @override
  String get searchNoResults => 'Aucune dÃ©pense trouvÃ©e';

  @override
  String searchResultCount(int count) {
    return '$count rÃ©sultats';
  }

  @override
  String get expenseFixed => 'Fixe';

  @override
  String get expenseVariable => 'Variable';

  @override
  String monthlyBudgetHint(String month) {
    return 'Budget pour $month';
  }

  @override
  String unsetBudgetsWarning(int count) {
    return '$count budgets variables non dÃ©finis';
  }

  @override
  String get unsetBudgetsCta => 'DÃ©finir dans les paramÃ¨tres';

  @override
  String paceProjected(String amount) {
    return 'Projection : $amount';
  }

  @override
  String get onbSkip => 'Passer';

  @override
  String get onbNext => 'Suivant';

  @override
  String get onbGetStarted => 'Commencer';

  @override
  String get onbSlide0Title => 'Votre budget, en un coup d\'Å“il';

  @override
  String get onbSlide0Body =>
      'Le tableau de bord affiche votre liquiditÃ© mensuelle, dÃ©penses et Indice de SÃ©rÃ©nitÃ©.';

  @override
  String get onbSlide1Title => 'Suivez chaque dÃ©pense';

  @override
  String get onbSlide1Body =>
      'Appuyez sur + pour enregistrer un achat. Assignez une catÃ©gorie et regardez les barres se mettre Ã  jour.';

  @override
  String get onbSlide2Title => 'Achetez avec une liste';

  @override
  String get onbSlide2Body =>
      'Parcourez les produits, crÃ©ez une liste, puis finalisez pour enregistrer vos dÃ©penses automatiquement.';

  @override
  String get onbSlide3Title => 'Votre coach financier IA';

  @override
  String get onbSlide3Body =>
      'Obtenez une analyse en 3 parties basÃ©e sur votre budget rÃ©el — pas des conseils gÃ©nÃ©riques.';

  @override
  String get onbSlide4Title => 'Planifiez vos repas dans le budget';

  @override
  String get onbSlide4Body =>
      'GÃ©nÃ©rez un plan mensuel adaptÃ© Ã  votre budget alimentaire et la taille du foyer.';

  @override
  String get onbTourSkip => 'Passer la visite';

  @override
  String get onbTourNext => 'Suivant';

  @override
  String get onbTourDone => 'Compris';

  @override
  String get onbTourDash1Title => 'LiquiditÃ© mensuelle';

  @override
  String get onbTourDash1Body =>
      'Revenus moins toutes les dÃ©penses. Vert signifie solde positif.';

  @override
  String get onbTourDash2Title => 'Indice de SÃ©rÃ©nitÃ©';

  @override
  String get onbTourDash2Body =>
      'Score de santÃ© financiÃ¨re 0–100. Appuyez pour voir les facteurs.';

  @override
  String get onbTourDash3Title => 'Budget vs rÃ©el';

  @override
  String get onbTourDash3Body =>
      'DÃ©penses prÃ©vues vs rÃ©elles par catÃ©gorie.';

  @override
  String get onbTourDash4Title => 'Ajouter une dÃ©pense';

  @override
  String get onbTourDash4Body =>
      'Appuyez sur + Ã  tout moment pour enregistrer une dÃ©pense.';

  @override
  String get onbTourDash5Title => 'Navigation';

  @override
  String get onbTourDash5Body =>
      '5 sections : Budget, Ã‰picerie, Liste, Coach, Repas.';

  @override
  String get onbTourGrocery1Title => 'Rechercher et filtrer';

  @override
  String get onbTourGrocery1Body =>
      'Recherchez par nom ou filtrez par catÃ©gorie.';

  @override
  String get onbTourGrocery2Title => 'Ajouter Ã  la liste';

  @override
  String get onbTourGrocery2Body =>
      'Appuyez sur + sur un produit pour l\'ajouter Ã  votre liste de courses.';

  @override
  String get onbTourGrocery3Title => 'CatÃ©gories';

  @override
  String get onbTourGrocery3Body =>
      'Faites dÃ©filer les filtres de catÃ©gorie pour affiner les produits.';

  @override
  String get onbTourShopping1Title => 'Cocher les articles';

  @override
  String get onbTourShopping1Body =>
      'Appuyez sur un article pour le marquer comme pris.';

  @override
  String get onbTourShopping2Title => 'Finaliser l\'achat';

  @override
  String get onbTourShopping2Body =>
      'Enregistre la dÃ©pense et efface les articles cochÃ©s.';

  @override
  String get onbTourShopping3Title => 'Historique d\'achats';

  @override
  String get onbTourShopping3Body =>
      'Consultez toutes vos sessions d\'achats passÃ©es ici.';

  @override
  String get onbTourCoach1Title => 'Analyser mon budget';

  @override
  String get onbTourCoach1Body =>
      'Appuyez pour gÃ©nÃ©rer une analyse basÃ©e sur vos donnÃ©es rÃ©elles.';

  @override
  String get onbTourCoach2Title => 'Historique d\'analyses';

  @override
  String get onbTourCoach2Body =>
      'Les analyses sauvegardÃ©es apparaissent ici, les plus rÃ©centes en premier.';

  @override
  String get onbTourMeals1Title => 'GÃ©nÃ©rer un plan';

  @override
  String get onbTourMeals1Body =>
      'CrÃ©e un mois complet de repas dans votre budget alimentaire.';

  @override
  String get onbTourMeals2Title => 'Vue hebdomadaire';

  @override
  String get onbTourMeals2Body =>
      'Parcourez les repas par semaine. Appuyez sur un jour pour voir la recette.';

  @override
  String get onbTourMeals3Title => 'Ajouter Ã  la liste de courses';

  @override
  String get onbTourMeals3Body =>
      'Envoyez les ingrÃ©dients de la semaine Ã  votre liste en un seul appui.';

  @override
  String get taxDeductionTitle => 'DÃ©ductions Fiscales';

  @override
  String get taxDeductionSeeDetail => 'Voir dÃ©tail';

  @override
  String get taxDeductionEstimated => 'dÃ©duction estimÃ©e';

  @override
  String taxDeductionMaxOf(String amount) {
    return 'Max. de $amount';
  }

  @override
  String get taxDeductionDetailTitle => 'DÃ©ductions Fiscales â€” DÃ©tail';

  @override
  String get taxDeductionDeductibleTitle => 'CATÃ‰GORIES DÃ‰DUCTIBLES';

  @override
  String get taxDeductionNonDeductibleTitle => 'CATÃ‰GORIES NON DÃ‰DUCTIBLES';

  @override
  String get taxDeductionTotalLabel => 'DÃ‰DUCTION ESTIMÃ‰E';

  @override
  String taxDeductionSpent(String amount) {
    return 'DÃ©pensÃ© : $amount';
  }

  @override
  String taxDeductionCapUsed(String percent, String cap) {
    return '$percent de $cap utilisÃ©';
  }

  @override
  String get taxDeductionNotDeductible => 'Non dÃ©ductible';

  @override
  String get taxDeductionDisclaimer =>
      'Ces valeurs sont des estimations basÃ©es sur vos dÃ©penses enregistrÃ©es. Les dÃ©ductions rÃ©elles dÃ©pendent des factures dÃ©clarÃ©es. Consultez un professionnel fiscal pour les montants dÃ©finitifs.';

  @override
  String get settingsDashTaxDeductions => 'DÃ©ductions fiscales (PT)';

  @override
  String get settingsDashUpcomingBills => 'Factures Ã  venir';

  @override
  String get settingsDashBudgetStreaks => 'SÃ©ries de budget';

  @override
  String get upcomingBillsTitle => 'Factures Ã  Venir';

  @override
  String get upcomingBillsManage => 'GÃ©rer';

  @override
  String get billDueToday => 'Aujourd\'hui';

  @override
  String get billDueTomorrow => 'Demain';

  @override
  String billDueInDays(int days) {
    return 'Dans $days jours';
  }

  @override
  String savingsProjectionReachedBy(String date) {
    return 'Atteint d\'ici $date';
  }

  @override
  String savingsProjectionNeedPerMonth(String amount) {
    return 'Besoin de $amount/mois pour respecter l\'Ã©chÃ©ance';
  }

  @override
  String get savingsProjectionOnTrack => 'En bonne voie';

  @override
  String get savingsProjectionBehind => 'En retard';

  @override
  String get savingsProjectionNoData =>
      'Ajoutez des contributions pour voir la projection';

  @override
  String savingsProjectionAvgContribution(String amount) {
    return 'Moy. $amount/mois';
  }

  @override
  String get taxSimTitle => 'Simulateur Fiscal';

  @override
  String get taxSimPresets => 'SCÃ‰NARIOS RAPIDES';

  @override
  String get taxSimPresetRaise => '+â‚¬200 augmentation';

  @override
  String get taxSimPresetMeal => 'Carte vs espÃ¨ces';

  @override
  String get taxSimPresetTitular => 'Conjoint vs sÃ©parÃ©';

  @override
  String get taxSimParameters => 'PARAMÃˆTRES';

  @override
  String get taxSimGross => 'Salaire brut';

  @override
  String get taxSimMarital => 'Ã‰tat civil';

  @override
  String get taxSimTitulares => 'Titulaires';

  @override
  String get taxSimDependentes => 'Personnes Ã  charge';

  @override
  String get taxSimMealType => 'Type d\'indemnitÃ© repas';

  @override
  String get taxSimMealAmount => 'IndemnitÃ© repas/jour';

  @override
  String get taxSimComparison => 'ACTUEL VS SIMULÃ‰';

  @override
  String get taxSimNetTakeHome => 'Net Ã  percevoir';

  @override
  String get taxSimIRS => 'Retenue d\'impÃ´t';

  @override
  String get taxSimSS => 'SÃ©curitÃ© sociale';

  @override
  String get taxSimDelta => 'DiffÃ©rence mensuelle :';

  @override
  String get taxSimButton => 'Simulateur Fiscal';

  @override
  String get streakTitle => 'SÃ©ries de Budget';

  @override
  String get streakBronze => 'Bronze';

  @override
  String get streakSilver => 'Argent';

  @override
  String get streakGold => 'Or';

  @override
  String get streakBronzeDesc => 'LiquiditÃ© positive';

  @override
  String get streakSilverDesc => 'Dans le budget';

  @override
  String get streakGoldDesc => 'Toutes catÃ©gories';

  @override
  String streakMonths(int count) {
    return '$count mois';
  }

  @override
  String get expenseDefaultBudget => 'BUDGET DE BASE';

  @override
  String expenseOverrideActive(String month, String amount) {
    return 'AjustÃ© pour $month: $amount';
  }

  @override
  String expenseAdjustMonth(String month) {
    return 'Ajuster pour $month';
  }

  @override
  String get expenseAdjustMonthHint =>
      'Laissez vide pour utiliser le budget de base';

  @override
  String get settingsPersonalTip =>
      'Le statut matrimonial et les personnes Ã  charge affectent votre tranche d\'imposition, ce qui dÃ©termine le montant d\'impÃ´t retenu sur votre salaire.';

  @override
  String get settingsSalariesTip =>
      'Le salaire brut est utilisÃ© pour calculer le revenu net aprÃ¨s impÃ´ts et sÃ©curitÃ© sociale. Ajoutez plusieurs salaires si le mÃ©nage a plus d\'un revenu.';

  @override
  String get settingsExpensesTip =>
      'DÃ©finissez le budget mensuel pour chaque catÃ©gorie. Vous pouvez le modifier pour des mois spÃ©cifiques dans la vue dÃ©taillÃ©e.';

  @override
  String get settingsMealHouseholdTip =>
      'Nombre de personnes qui mangent Ã  la maison. Cela adapte les recettes et les portions dans votre plan de repas.';

  @override
  String get settingsHouseholdTip =>
      'Invitez des membres de la famille Ã  partager les donnÃ©es budgÃ©taires entre appareils. Tous les membres voient les mÃªmes dÃ©penses et budgets.';

  @override
  String get subscriptionTitle => 'Abonnement';

  @override
  String get subscriptionFree => 'Gratuit';

  @override
  String get subscriptionPremium => 'Premium';

  @override
  String get subscriptionFamily => 'Famille';

  @override
  String get subscriptionTrialActive => 'Essai actif';

  @override
  String subscriptionTrialDaysLeft(int count) {
    return '$count jours restants';
  }

  @override
  String get subscriptionTrialExpired => 'Essai expirÃ©';

  @override
  String get subscriptionUpgrade => 'Mettre Ã  jour';

  @override
  String get subscriptionSeePlans => 'Voir les Plans';

  @override
  String get subscriptionCurrentPlan => 'Plan Actuel';

  @override
  String get subscriptionManage => 'GÃ©rer l\'Abonnement';

  @override
  String subscriptionFeatureExplored(int count, int total) {
    return '$count/$total fonctionnalitÃ©s explorÃ©es';
  }

  @override
  String get subscriptionTrialBannerTitle => 'Essai Premium Actif';

  @override
  String subscriptionTrialEndingSoon(int count) {
    return '$count jours restants dans votre essai !';
  }

  @override
  String get subscriptionTrialLastDay =>
      'Dernier jour de votre essai gratuit !';

  @override
  String get subscriptionUpgradeNow => 'Mettre Ã  jour Maintenant';

  @override
  String get subscriptionKeepData => 'Conserver Vos DonnÃ©es';

  @override
  String get subscriptionCancelAnytime => 'Annulez Ã  tout moment';

  @override
  String get subscriptionNoHiddenFees => 'Sans frais cachÃ©s';

  @override
  String get subscriptionMostPopular => 'Le Plus Populaire';

  @override
  String subscriptionYearlySave(int percent) {
    return 'Ã©conomisez $percent%';
  }

  @override
  String get subscriptionMonthly => 'Mensuel';

  @override
  String get subscriptionYearly => 'Annuel';

  @override
  String get subscriptionPerMonth => '/mois';

  @override
  String get subscriptionPerYear => '/an';

  @override
  String get subscriptionBilledYearly => 'facturÃ© annuellement';

  @override
  String get subscriptionStartPremium => 'Commencer Premium';

  @override
  String get subscriptionStartFamily => 'Commencer Famille';

  @override
  String get subscriptionContinueFree => 'Continuer Gratuit';

  @override
  String get subscriptionTrialEnded => 'Votre pÃ©riode d\'essai est terminÃ©e';

  @override
  String get subscriptionChoosePlan =>
      'Choisissez un plan pour conserver toutes vos donnÃ©es et fonctionnalitÃ©s';

  @override
  String get subscriptionUnlockPower =>
      'DÃ©bloquez toute la puissance de votre budget';

  @override
  String subscriptionRequiresPaid(String feature) {
    return '$feature nÃ©cessite un abonnement payant';
  }

  @override
  String subscriptionTryFeature(String feature) {
    return 'Essayez $feature';
  }

  @override
  String subscriptionExplore(String feature) {
    return 'Explorer $feature';
  }
}
