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
  String get navBudgetTooltip => 'Aperçu du budget mensuel';

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
    return 'Ajouter $name à la liste';
  }

  @override
  String get enumMaritalSolteiro => 'Célibataire';

  @override
  String get enumMaritalCasado => 'Marié(e)';

  @override
  String get enumMaritalUniaoFacto => 'Union libre';

  @override
  String get enumMaritalDivorciado => 'Divorcé(e)';

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
  String get enumMealAllowanceCash => 'Espèces';

  @override
  String get enumCatTelecomunicacoes => 'Télécom';

  @override
  String get enumCatEnergia => 'Énergie';

  @override
  String get enumCatAgua => 'Eau';

  @override
  String get enumCatAlimentacao => 'Alimentation';

  @override
  String get enumCatEducacao => 'Éducation';

  @override
  String get enumCatHabitacao => 'Logement';

  @override
  String get enumCatTransportes => 'Transport';

  @override
  String get enumCatSaude => 'Santé';

  @override
  String get enumCatLazer => 'Loisirs';

  @override
  String get enumCatOutros => 'Autres';

  @override
  String get enumChartExpensesPie => 'Dépenses par catégorie';

  @override
  String get enumChartIncomeVsExpenses => 'Revenus vs Dépenses';

  @override
  String get enumChartNetIncome => 'Revenu Net';

  @override
  String get enumChartDeductions => 'Prélèvements (IR + Cotis.)';

  @override
  String get enumChartSavingsRate => 'Taux d\'épargne';

  @override
  String get enumMealBreakfast => 'Petit-déjeuner';

  @override
  String get enumMealLunch => 'Déjeuner';

  @override
  String get enumMealSnack => 'Goûter';

  @override
  String get enumMealDinner => 'Dîner';

  @override
  String get enumObjMinimizeCost => 'Minimiser les coûts';

  @override
  String get enumObjBalancedHealth => 'Équilibre coût/santé';

  @override
  String get enumObjHighProtein => 'Riche en protéines';

  @override
  String get enumObjLowCarb => 'Faible en glucides';

  @override
  String get enumObjVegetarian => 'Végétarien';

  @override
  String get enumEquipOven => 'Four';

  @override
  String get enumEquipAirFryer => 'Friteuse à air';

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
  String get enumSodiumReduced => 'Sodium réduit';

  @override
  String get enumSodiumLow => 'Faible en sodium';

  @override
  String get enumAge0to3 => '0–3 ans';

  @override
  String get enumAge4to10 => '4–10 ans';

  @override
  String get enumAgeTeen => 'Adolescent';

  @override
  String get enumAgeAdult => 'Adulte';

  @override
  String get enumAgeSenior => 'Senior (65+)';

  @override
  String get enumActivitySedentary => 'Sédentaire';

  @override
  String get enumActivityModerate => 'Modéré';

  @override
  String get enumActivityActive => 'Actif';

  @override
  String get enumActivityVeryActive => 'Très actif';

  @override
  String get enumMedDiabetes => 'Diabète';

  @override
  String get enumMedHypertension => 'Hypertension';

  @override
  String get enumMedHighCholesterol => 'Cholestérol élevé';

  @override
  String get enumMedGout => 'Goutte';

  @override
  String get enumMedIbs => 'Syndrome du côlon irritable';

  @override
  String get stressExcellent => 'Excellent';

  @override
  String get stressGood => 'Bon';

  @override
  String get stressWarning => 'Attention';

  @override
  String get stressCritical => 'Critique';

  @override
  String get stressFactorSavings => 'Taux d\'épargne';

  @override
  String get stressFactorSafety => 'Marge de sécurité';

  @override
  String get stressFactorFood => 'Budget alimentation';

  @override
  String get stressFactorStability => 'Stabilité des dépenses';

  @override
  String get stressStable => 'Stable';

  @override
  String get stressHigh => 'Élevée';

  @override
  String stressUsed(String percent) {
    return '$percent% utilisé';
  }

  @override
  String get stressNA => 'N/D';

  @override
  String monthReviewFoodExceeded(String percent) {
    return 'L\'alimentation a dépassé le budget de $percent% — envisagez de revoir les portions ou la fréquence des courses.';
  }

  @override
  String monthReviewExpensesExceeded(String amount) {
    return 'Les dépenses réelles ont dépassé le prévu de $amount€ — ajuster les valeurs dans les paramètres ?';
  }

  @override
  String monthReviewSavedMore(String amount) {
    return 'Économisé $amount€ de plus que prévu — vous pouvez renforcer le fonds d\'urgence.';
  }

  @override
  String get monthReviewOnTrack =>
      'Dépenses dans les prévisions. Bon contrôle budgétaire.';

  @override
  String get dashboardTitle => 'Budget Mensuel';

  @override
  String get dashboardStressIndex => 'Indice de Sérénité';

  @override
  String get dashboardTension => 'Tension';

  @override
  String get dashboardLiquidity => 'Liquidité';

  @override
  String get dashboardFinalPosition => 'Position Finale';

  @override
  String get dashboardMonth => 'Mois';

  @override
  String get dashboardGross => 'Brut';

  @override
  String get dashboardNet => 'Net';

  @override
  String get dashboardExpenses => 'Dépenses';

  @override
  String get dashboardSavingsRate => 'Taux Épargne';

  @override
  String get dashboardViewTrends => 'Voir évolution';

  @override
  String get dashboardViewProjection => 'Voir projection';

  @override
  String get dashboardFinancialSummary => 'RÉSUMÉ FINANCIER';

  @override
  String get dashboardOpenSettings => 'Ouvrir les paramètres';

  @override
  String get dashboardMonthlyLiquidity => 'LIQUIDITÉ MENSUELLE';

  @override
  String get dashboardPositiveBalance => 'Solde positif';

  @override
  String get dashboardNegativeBalance => 'Solde négatif';

  @override
  String dashboardHeroLabel(String amount, String status) {
    return 'Liquidité mensuelle : $amount, $status';
  }

  @override
  String get dashboardConfigureData =>
      'Configurez vos données pour voir le résumé.';

  @override
  String get dashboardOpenSettingsButton => 'Ouvrir les Paramètres';

  @override
  String get dashboardGrossIncome => 'Revenu Brut';

  @override
  String get dashboardNetIncome => 'Revenu Net';

  @override
  String dashboardInclMealAllowance(String amount) {
    return 'Incl. indemn. repas : $amount';
  }

  @override
  String get dashboardDeductions => 'Prélèvements';

  @override
  String dashboardIrsSs(String irs, String ss) {
    return 'IR : $irs | Cotis. : $ss';
  }

  @override
  String dashboardExpensesAmount(String amount) {
    return 'Dépenses : $amount';
  }

  @override
  String get dashboardSalaryDetail => 'DÉTAIL DES SALAIRES';

  @override
  String dashboardSalaryN(int n) {
    return 'Salaire $n';
  }

  @override
  String get dashboardFood => 'ALIMENTATION';

  @override
  String get dashboardSimulate => 'Simuler';

  @override
  String get dashboardBudgeted => 'Budgété';

  @override
  String get dashboardSpent => 'Dépensé';

  @override
  String get dashboardRemaining => 'Restant';

  @override
  String get dashboardFinalizePurchaseHint =>
      'Finalisez un achat dans la Liste pour enregistrer les dépenses.';

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
  String get dashboardMonthlyExpenses => 'DÉPENSES MENSUELLES';

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
  String get dashboardExemptIncome => 'Rev. Exonéré';

  @override
  String get dashboardDetails => 'Détails';

  @override
  String dashboardVsLastMonth(String delta) {
    return '$delta vs mois dernier';
  }

  @override
  String get dashboardPaceWarning => 'Dépenses plus rapides que prévu';

  @override
  String get dashboardPaceCritical =>
      'Risque de dépassement du budget alimentaire';

  @override
  String get dashboardPace => 'Rythme';

  @override
  String get dashboardProjection => 'Projection';

  @override
  String dashboardPaceValue(String actual, String expected) {
    return '$actual€/jour vs $expected€/jour';
  }

  @override
  String get dashboardSummaryLabel => '— RÉSUMÉ';

  @override
  String get dashboardViewMonthSummary => 'Voir le résumé du mois';

  @override
  String get coachTitle => 'Coach Financier';

  @override
  String get coachSubtitle => 'IA · GPT-4o mini';

  @override
  String get coachApiKeyRequired =>
      'Ajoutez votre clé API OpenAI dans les Paramètres pour utiliser cette fonctionnalité.';

  @override
  String get coachAnalysisTitle => 'Analyse financière en 3 parties';

  @override
  String get coachAnalysisDescription =>
      'Positionnement général · Facteurs critiques de l\'Indice de Sérénité · Opportunité immédiate. Basé sur vos données réelles de budget, dépenses et historique d\'achats.';

  @override
  String get coachConfigureApiKey =>
      'Configurer la clé API dans les Paramètres';

  @override
  String get coachApiKeyConfigured => 'Clé API configurée';

  @override
  String get coachAnalyzeButton => 'Analyser mon budget';

  @override
  String get coachAnalyzing => 'Analyse en cours...';

  @override
  String get coachCustomAnalysis => 'Analyse personnalisée';

  @override
  String get coachNewAnalysis => 'Générer nouvelle analyse';

  @override
  String get coachHistory => 'HISTORIQUE';

  @override
  String get coachClearAll => 'Tout effacer';

  @override
  String get coachClearTitle => 'Effacer l\'historique';

  @override
  String get coachClearContent =>
      'Êtes-vous sûr de vouloir supprimer toutes les analyses enregistrées ?';

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
    return '$name ajouté à la liste';
  }

  @override
  String groceryAvgPrice(String unit) {
    return '$unit · prix moyen';
  }

  @override
  String get shoppingTitle => 'Liste de Courses';

  @override
  String get shoppingEmpty => 'Liste vide';

  @override
  String get shoppingEmptyMessage =>
      'Ajoutez des produits depuis\nl\'écran Courses.';

  @override
  String shoppingItemsRemaining(int count, String total) {
    return '$count à acheter · $total';
  }

  @override
  String get shoppingClear => 'Effacer';

  @override
  String get shoppingFinalize => 'Finaliser l\'Achat';

  @override
  String get shoppingEstimatedTotal => 'Total estimé';

  @override
  String get shoppingHowMuchSpent => 'COMBIEN AI-JE DÉPENSÉ ? (optionnel)';

  @override
  String get shoppingConfirm => 'Confirmer';

  @override
  String get shoppingHistoryTooltip => 'Historique d\'achats';

  @override
  String get shoppingHistoryTitle => 'Historique d\'Achats';

  @override
  String shoppingItemChecked(String name) {
    return '$name, acheté';
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
  String get authRegister => 'Créer un compte';

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
  String get authSwitchToRegister => 'Créer un nouveau compte';

  @override
  String get authSwitchToLogin => 'J\'ai déjà un compte';

  @override
  String get householdSetupTitle => 'Configurer le Foyer';

  @override
  String get householdCreate => 'Créer';

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
  String get householdCreateButton => 'Créer le Foyer';

  @override
  String get householdJoinButton => 'Rejoindre le Foyer';

  @override
  String get householdNameRequired => 'Veuillez indiquer le nom du foyer.';

  @override
  String get chartExpensesByCategory => 'Dépenses par Catégorie';

  @override
  String get chartIncomeVsExpenses => 'Revenus vs Dépenses';

  @override
  String get chartDeductions => 'Prélèvements (IR + Cotisations)';

  @override
  String get chartGrossVsNet => 'Revenu Brut vs Net';

  @override
  String get chartSavingsRate => 'Taux d\'Épargne';

  @override
  String get chartNetIncome => 'Rev. Net';

  @override
  String get chartExpensesLabel => 'Dépenses';

  @override
  String get chartLiquidity => 'Liquidité';

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
  String get chartSavings => 'épargne';

  @override
  String projectionTitle(String month, String year) {
    return 'Projection — $month $year';
  }

  @override
  String projectionSubtitle(String spent, String budget, String days) {
    return 'Dépensé $spent sur $budget en $days jours';
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
    return 'Dépense journalière estimée : $amount/jour';
  }

  @override
  String get projectionEndOfMonth => 'Projection fin de mois';

  @override
  String get projectionRemaining => 'Restant projeté';

  @override
  String get projectionStressImpact => 'Impact sur l\'indice';

  @override
  String get projectionExpenses => 'DÉPENSES';

  @override
  String get projectionSimulation => 'Simulation — non enregistré';

  @override
  String get projectionReduceAll => 'Réduire toutes de ';

  @override
  String get projectionSimLiquidity => 'Liquidité simulée';

  @override
  String get projectionDelta => 'Delta';

  @override
  String get projectionSimSavingsRate => 'Taux épargne simulé';

  @override
  String get projectionSimIndex => 'Indice simulé';

  @override
  String get trendTitle => 'Évolution';

  @override
  String get trendStressIndex => 'INDICE DE SÉRÉNITÉ';

  @override
  String get trendTotalExpenses => 'DÉPENSES TOTALES';

  @override
  String get trendExpensesByCategory => 'DÉPENSES PAR CATÉGORIE';

  @override
  String trendCurrent(String amount) {
    return 'Actuel : $amount';
  }

  @override
  String get trendCatTelecom => 'Télécom';

  @override
  String get trendCatEnergy => 'Énergie';

  @override
  String get trendCatWater => 'Eau';

  @override
  String get trendCatFood => 'Alimentation';

  @override
  String get trendCatEducation => 'Éducation';

  @override
  String get trendCatHousing => 'Logement';

  @override
  String get trendCatTransport => 'Transport';

  @override
  String get trendCatHealth => 'Santé';

  @override
  String get trendCatLeisure => 'Loisirs';

  @override
  String get trendCatOther => 'Autres';

  @override
  String monthReviewTitle(String month) {
    return 'Résumé — $month';
  }

  @override
  String get monthReviewPlanned => 'Prévu';

  @override
  String get monthReviewActual => 'Réel';

  @override
  String get monthReviewDifference => 'Différence';

  @override
  String get monthReviewFood => 'Alimentation';

  @override
  String monthReviewFoodValue(String actual, String budget) {
    return '$actual sur $budget';
  }

  @override
  String get monthReviewTopDeviations => 'ÉCARTS PRINCIPAUX';

  @override
  String get monthReviewSuggestions => 'SUGGESTIONS';

  @override
  String get monthReviewAiAnalysis => 'Analyse IA détaillée';

  @override
  String get mealPlannerTitle => 'Planificateur de Repas';

  @override
  String get mealBudgetLabel => 'Budget alimentation';

  @override
  String get mealPeopleLabel => 'Personnes au foyer';

  @override
  String get mealGeneratePlan => 'Générer le Plan Mensuel';

  @override
  String get mealGenerating => 'Génération...';

  @override
  String get mealRegenerateTitle => 'Régénérer le plan ?';

  @override
  String get mealRegenerateContent => 'Le plan actuel sera remplacé.';

  @override
  String get mealRegenerate => 'Régénérer';

  @override
  String mealWeekLabel(int n) {
    return 'Semaine $n';
  }

  @override
  String mealWeekAbbr(int n) {
    return 'Sem.$n';
  }

  @override
  String get mealAddWeekToList => 'Ajouter la semaine à la liste';

  @override
  String mealIngredientsAdded(int count) {
    return '$count ingrédients ajoutés à la liste';
  }

  @override
  String mealDayLabel(int n) {
    return 'Jour $n';
  }

  @override
  String get mealIngredients => 'Ingrédients';

  @override
  String get mealPreparation => 'Préparation';

  @override
  String get mealSwap => 'Échanger';

  @override
  String get mealConsolidatedList => 'Voir la liste consolidée';

  @override
  String get mealConsolidatedTitle => 'Liste Consolidée';

  @override
  String get mealAlternatives => 'Alternatives';

  @override
  String mealTotalCost(String cost) {
    return '$cost€ total';
  }

  @override
  String get mealCatProteins => 'Protéines';

  @override
  String get mealCatVegetables => 'Légumes';

  @override
  String get mealCatCarbs => 'Glucides';

  @override
  String get mealCatFats => 'Matières grasses';

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
  String get wizardStepStrategy => 'Stratégie';

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
    return '$label, sélectionné';
  }

  @override
  String get wizardDietaryRestrictions => 'RESTRICTIONS ALIMENTAIRES';

  @override
  String get wizardGlutenFree => 'Sans gluten';

  @override
  String get wizardLactoseFree => 'Sans lactose';

  @override
  String get wizardNutFree => 'Sans fruits à coque';

  @override
  String get wizardShellfishFree => 'Sans crustacés';

  @override
  String get wizardDislikedIngredients => 'INGRÉDIENTS QUE VOUS N\'AIMEZ PAS';

  @override
  String get wizardDislikedHint => 'ex : thon, brocoli';

  @override
  String get wizardMaxPrepTime => 'TEMPS DE PRÉPARATION MAXIMUM';

  @override
  String get wizardMaxComplexity => 'COMPLEXITÉ MAXIMUM';

  @override
  String get wizardComplexityEasy => 'Facile';

  @override
  String get wizardComplexityMedium => 'Moyen';

  @override
  String get wizardComplexityAdvanced => 'Avancé';

  @override
  String get wizardEquipment => 'ÉQUIPEMENT DISPONIBLE';

  @override
  String get wizardBatchCooking => 'Batch cooking';

  @override
  String get wizardBatchCookingDesc =>
      'Cuisiner pour plusieurs jours à la fois';

  @override
  String get wizardMaxBatchDays => 'JOURS MAXIMUM PAR RECETTE';

  @override
  String wizardBatchDays(int days) {
    return '$days jours';
  }

  @override
  String get wizardPreferredCookingDay => 'JOUR DE CUISINE PRÉFÉRÉ';

  @override
  String get wizardReuseLeftovers => 'Réutiliser les restes';

  @override
  String get wizardReuseLeftoversDesc =>
      'Le dîner d\'hier = le déjeuner d\'aujourd\'hui (coût 0)';

  @override
  String get wizardMaxNewIngredients => 'NOUVEAUX INGRÉDIENTS PAR SEMAINE MAX';

  @override
  String get wizardNoLimit => 'Sans limite';

  @override
  String get wizardMinimizeWaste => 'Minimiser le gaspillage';

  @override
  String get wizardMinimizeWasteDesc =>
      'Préférer les recettes réutilisant des ingrédients déjà utilisés';

  @override
  String get wizardSettingsInfo =>
      'Vous pouvez modifier les paramètres du planificateur à tout moment dans Paramètres → Repas.';

  @override
  String get wizardContinue => 'Continuer';

  @override
  String get wizardGeneratePlan => 'Générer le Plan';

  @override
  String wizardStepOf(int current, int total) {
    return 'Étape $current sur $total';
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
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsPersonal => 'Données Personnelles';

  @override
  String get settingsSalaries => 'Salaires';

  @override
  String get settingsExpenses => 'Dépenses';

  @override
  String get settingsCoachAi => 'Coach IA';

  @override
  String get settingsDashboard => 'Tableau de bord';

  @override
  String get settingsMeals => 'Repas';

  @override
  String get settingsRegion => 'Région et Langue';

  @override
  String get settingsCountry => 'Pays';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsMaritalStatus => 'État civil';

  @override
  String get settingsDependents => 'Personnes à charge';

  @override
  String get settingsDisability => 'Handicap';

  @override
  String get settingsGrossSalary => 'Salaire brut';

  @override
  String get settingsTitulares => 'Titulaires d\'impôt';

  @override
  String get settingsSubsidyMode => 'Primes';

  @override
  String get settingsMealAllowance => 'Indemnité repas';

  @override
  String get settingsMealAllowancePerDay => 'Montant/jour';

  @override
  String get settingsWorkingDays => 'Jours ouvrés/mois';

  @override
  String get settingsOtherExemptIncome => 'Autres revenus exonérés';

  @override
  String get settingsAddSalary => 'Ajouter un salaire';

  @override
  String get settingsAddExpense => 'Ajouter une dépense';

  @override
  String get settingsExpenseName => 'Nom de la dépense';

  @override
  String get settingsExpenseAmount => 'Montant';

  @override
  String get settingsExpenseCategory => 'Catégorie';

  @override
  String get settingsApiKey => 'Clé API OpenAI';

  @override
  String get settingsInviteCode => 'Code d\'invitation';

  @override
  String get settingsCopyCode => 'Copier';

  @override
  String get settingsCodeCopied => 'Code copié !';

  @override
  String get settingsAdminOnly =>
      'Seul l\'administrateur peut modifier les paramètres.';

  @override
  String get settingsShowSummaryCards => 'Afficher les cartes résumé';

  @override
  String get settingsEnabledCharts => 'Graphiques actifs';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get settingsLogoutConfirmTitle => 'Se déconnecter';

  @override
  String get settingsLogoutConfirmContent =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get settingsLogoutConfirmButton => 'Se déconnecter';

  @override
  String get settingsSalariesSection => 'Revenus';

  @override
  String get settingsExpensesMonthly => 'Dépenses Mensuelles';

  @override
  String get settingsFavorites => 'Produits Favoris';

  @override
  String get settingsCoachOpenAi => 'Coach IA (OpenAI)';

  @override
  String get settingsHousehold => 'Foyer';

  @override
  String get settingsMaritalStatusLabel => 'ÉTAT CIVIL';

  @override
  String get settingsDependentsLabel => 'NOMBRE DE PERSONNES À CHARGE';

  @override
  String settingsSocialSecurityRate(String rate) {
    return 'Cotisations sociales : $rate';
  }

  @override
  String get settingsSalaryActive => 'Actif';

  @override
  String get settingsGrossMonthlySalary => 'SALAIRE BRUT MENSUEL';

  @override
  String get settingsSubsidyHoliday => 'PRIMES DE VACANCES ET NOËL (DOUZIÈMES)';

  @override
  String get settingsOtherExemptLabel => 'AUTRES REVENUS EXONÉRÉS D\'IMPÔT';

  @override
  String get settingsMealAllowanceLabel => 'INDEMNITÉ REPAS';

  @override
  String get settingsAmountPerDay => 'MONTANT/JOUR';

  @override
  String get settingsDaysPerMonth => 'JOURS/MOIS';

  @override
  String get settingsTitularesLabel => 'TITULAIRES D\'IMPÔT';

  @override
  String settingsTitularCount(int n, String suffix) {
    return '$n Titulaire$suffix';
  }

  @override
  String get settingsAddSalaryButton => 'Ajouter un salaire';

  @override
  String get settingsAddExpenseButton => 'Ajouter une Dépense';

  @override
  String get settingsDeviceLocal =>
      'Ces paramètres sont stockés localement sur cet appareil.';

  @override
  String get settingsVisibleSections => 'SECTIONS VISIBLES';

  @override
  String get settingsMinimalist => 'Minimaliste';

  @override
  String get settingsFull => 'Complet';

  @override
  String get settingsDashMonthlyLiquidity => 'Liquidité mensuelle';

  @override
  String get settingsDashStressIndex => 'Indice de Sérénité';

  @override
  String get settingsDashSummaryCards => 'Cartes résumé';

  @override
  String get settingsDashSalaryBreakdown => 'Détail par salaire';

  @override
  String get settingsDashFood => 'Alimentation';

  @override
  String get settingsDashPurchaseHistory => 'Historique d\'achats';

  @override
  String get settingsDashExpensesBreakdown => 'Détail des dépenses';

  @override
  String get settingsDashCharts => 'Graphiques';

  @override
  String get settingsVisibleCharts => 'GRAPHIQUES VISIBLES';

  @override
  String get settingsFavTip =>
      'Les produits favoris influencent le plan repas — les recettes avec ces ingrédients sont prioritaires.';

  @override
  String get settingsMyFavorites => 'MES FAVORIS';

  @override
  String get settingsProductCatalog => 'CATALOGUE DE PRODUITS';

  @override
  String get settingsSearchProduct => 'Rechercher un produit...';

  @override
  String get settingsLoadingProducts => 'Chargement des produits...';

  @override
  String get settingsAddIngredient => 'Ajouter un ingrédient';

  @override
  String get settingsIngredientName => 'Nom de l\'ingrédient';

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
    return 'Calculé automatiquement : $count (titulaires + personnes à charge)';
  }

  @override
  String get settingsHouseholdMembers => 'MEMBRES DU FOYER';

  @override
  String get settingsPortions => 'portions';

  @override
  String settingsTotalEquivalent(String total) {
    return 'Équivalent total : $total portions';
  }

  @override
  String get settingsAddMember => 'Ajouter un membre';

  @override
  String get settingsPreferSeasonal => 'Préférer les recettes de saison';

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
  String get settingsDailyProtein => 'Protéines quotidiennes';

  @override
  String get settingsDailyFiber => 'Fibres quotidiennes';

  @override
  String get settingsMedicalConditions => 'CONDITIONS MÉDICALES';

  @override
  String get settingsActiveMeals => 'REPAS ACTIFS';

  @override
  String get settingsObjective => 'OBJECTIF';

  @override
  String get settingsVeggieDays => 'JOURS VÉGÉTARIENS PAR SEMAINE';

  @override
  String get settingsDietaryRestrictions => 'RESTRICTIONS ALIMENTAIRES';

  @override
  String get settingsEggFree => 'Sans oeufs';

  @override
  String get settingsSodiumPref => 'PRÉFÉRENCE EN SODIUM';

  @override
  String get settingsDislikedIngredients => 'INGRÉDIENTS NON SOUHAITÉS';

  @override
  String get settingsExcludedProteins => 'PROTÉINES EXCLUES';

  @override
  String get settingsProteinChicken => 'Poulet';

  @override
  String get settingsProteinGroundMeat => 'Viande hachée';

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
    return 'COMPLEXITÉ MAXIMUM ($value/5)';
  }

  @override
  String get settingsWeekendPrepTime => 'TEMPS WEEK-END (MINUTES)';

  @override
  String settingsWeekendComplexity(int value) {
    return 'COMPLEXITÉ WEEK-END ($value/5)';
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
    return 'Légumineuses par semaine : $count';
  }

  @override
  String settingsRedMeatPerWeek(String count) {
    return 'Viande rouge max/semaine : $count';
  }

  @override
  String get settingsNoLimit => 'sans limite';

  @override
  String get settingsAvailableEquipment => 'ÉQUIPEMENT DISPONIBLE';

  @override
  String get settingsBatchCooking => 'Batch cooking';

  @override
  String get settingsMaxBatchDays => 'JOURS MAX PAR RECETTE';

  @override
  String get settingsReuseLeftovers => 'Réutiliser les restes';

  @override
  String get settingsMinimizeWaste => 'Minimiser le gaspillage';

  @override
  String get settingsPrioritizeLowCost => 'Prioriser le bas coût';

  @override
  String get settingsPrioritizeLowCostDesc =>
      'Préférer les recettes moins chères';

  @override
  String settingsNewIngredientsPerWeek(int count) {
    return 'NOUVEAUX INGRÉDIENTS PAR SEMAINE ($count)';
  }

  @override
  String get settingsLunchboxLunches => 'Déjeuners en boîte';

  @override
  String get settingsLunchboxLunchesDesc =>
      'Uniquement des recettes transportables pour le déjeuner';

  @override
  String get settingsPantry => 'GARDE-MANGER (TOUJOURS EN STOCK)';

  @override
  String get settingsResetWizard => 'Réinitialiser l\'Assistant';

  @override
  String get settingsApiKeyInfo =>
      'La clé est stockée localement sur l\'appareil et n\'est jamais partagée. Utilise le modèle GPT-4o mini (~€0,00008 par analyse).';

  @override
  String get settingsInviteCodeLabel => 'CODE D\'INVITATION';

  @override
  String get settingsGenerateInvite => 'Générer un code d\'invitation';

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
  String get settingsAgeGroup => 'Tranche d\'âge';

  @override
  String get settingsActivityLevel => 'Niveau d\'activité';

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
  String get langPT => 'Português';

  @override
  String get langEN => 'English';

  @override
  String get langFR => 'Français';

  @override
  String get langES => 'Español';

  @override
  String get langSystem => 'Système';

  @override
  String get taxIncomeTax => 'Impôt sur le revenu';

  @override
  String get taxSocialContribution => 'Cotisation sociale';

  @override
  String get taxIRS => 'IRS';

  @override
  String get taxSS => 'Sécurité Sociale';

  @override
  String get taxIRPF => 'IRPF';

  @override
  String get taxSSSpain => 'Seguridad Social';

  @override
  String get taxIR => 'Impôt sur le Revenu';

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
      'Tu es un analyste financier personnel pour des utilisateurs portugais. Réponds toujours en portugais européen. Sois direct et analytique — utilise toujours les chiffres concrets du contexte fourni. Structure la réponse exactement dans les 3 parties demandées. N\'introduis pas de données, benchmarks ou références externes non fournis.';

  @override
  String get aiCoachInvalidApiKey =>
      'Clé API invalide. Vérifiez dans les Paramètres.';

  @override
  String get aiCoachMidMonthSystem =>
      'Tu es un consultant en budget domestique portugais. Réponds toujours en portugais européen. Sois pratique et direct.';

  @override
  String get aiMealPlannerSystem =>
      'Tu es un chef portugais. Réponds toujours en portugais européen. Réponds UNIQUEMENT avec du JSON valide, sans texte supplémentaire.';

  @override
  String get monthAbbrJan => 'Jan';

  @override
  String get monthAbbrFeb => 'Fév';

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
  String get monthAbbrAug => 'Aoû';

  @override
  String get monthAbbrSep => 'Sep';

  @override
  String get monthAbbrOct => 'Oct';

  @override
  String get monthAbbrNov => 'Nov';

  @override
  String get monthAbbrDec => 'Déc';

  @override
  String get monthFullJan => 'Janvier';

  @override
  String get monthFullFeb => 'Février';

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
  String get monthFullAug => 'Août';

  @override
  String get monthFullSep => 'Septembre';

  @override
  String get monthFullOct => 'Octobre';

  @override
  String get monthFullNov => 'Novembre';

  @override
  String get monthFullDec => 'Décembre';

  @override
  String get setupWizardWelcomeTitle => 'Bienvenue dans votre budget';

  @override
  String get setupWizardWelcomeSubtitle =>
      'Configurons l\'essentiel pour que votre tableau de bord soit prêt.';

  @override
  String get setupWizardBullet1 => 'Calculer votre salaire net';

  @override
  String get setupWizardBullet2 => 'Organiser vos dépenses';

  @override
  String get setupWizardBullet3 => 'Voir combien il vous reste chaque mois';

  @override
  String get setupWizardReassurance =>
      'Vous pouvez tout modifier plus tard dans les paramètres.';

  @override
  String get setupWizardStart => 'Commencer';

  @override
  String get setupWizardSkipAll => 'Passer la configuration';

  @override
  String setupWizardStepOf(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String get setupWizardContinue => 'Continuer';

  @override
  String get setupWizardCountryTitle => 'Où habitez-vous ?';

  @override
  String get setupWizardCountrySubtitle =>
      'Cela définit le système fiscal, la devise et les valeurs par défaut.';

  @override
  String get setupWizardLanguage => 'Langue';

  @override
  String get setupWizardLangSystem => 'Par défaut du système';

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
      'Nous utilisons ceci pour calculer vos impôts plus précisément.';

  @override
  String get setupWizardPrivacyNote =>
      'Vos données restent dans votre compte et ne sont jamais partagées.';

  @override
  String get setupWizardSingle => 'Célibataire';

  @override
  String get setupWizardMarried => 'Marié(e)';

  @override
  String get setupWizardDependents => 'Personnes à charge';

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
    return 'Net estimé : $amount';
  }

  @override
  String get setupWizardSalaryMoreLater =>
      'Vous pouvez ajouter d\'autres sources de revenus plus tard.';

  @override
  String get setupWizardSalarySkip => 'Passer cette étape';

  @override
  String get setupWizardExpensesTitle => 'Vos dépenses mensuelles';

  @override
  String get setupWizardExpensesSubtitle =>
      'Valeurs suggérées pour votre pays. Ajustez selon vos besoins.';

  @override
  String get setupWizardExpensesMoreLater =>
      'Vous pouvez ajouter d\'autres catégories plus tard.';

  @override
  String setupWizardNetLabel(String amount) {
    return 'Net : $amount';
  }

  @override
  String setupWizardTotalExpenses(String amount) {
    return 'Dépenses : $amount';
  }

  @override
  String setupWizardAvailableLabel(String amount) {
    return 'Disponible : $amount';
  }

  @override
  String get setupWizardFinish => 'Terminer';

  @override
  String get setupWizardCompleteTitle => 'Tout est prêt !';

  @override
  String get setupWizardCompleteReassurance =>
      'Votre budget est configuré. Vous pouvez tout ajuster dans les paramètres à tout moment.';

  @override
  String get setupWizardGoToDashboard => 'Voir mon budget';

  @override
  String get setupWizardConfigureSalaryHint =>
      'Configurez votre salaire dans les paramètres pour voir le calcul complet.';

  @override
  String get setupWizardExpRent => 'Loyer / Crédit immobilier';

  @override
  String get setupWizardExpGroceries => 'Alimentation';

  @override
  String get setupWizardExpTransport => 'Transport';

  @override
  String get setupWizardExpUtilities => 'Services (électricité, eau, gaz)';

  @override
  String get setupWizardExpTelecom => 'Télécommunications';

  @override
  String get setupWizardExpHealth => 'Santé';

  @override
  String get setupWizardExpLeisure => 'Loisirs';

  @override
  String get expenseTrackerTitle => 'BUDGET VS RÉEL';

  @override
  String get expenseTrackerBudgeted => 'Budgété';

  @override
  String get expenseTrackerActual => 'Réel';

  @override
  String get expenseTrackerRemaining => 'Restant';

  @override
  String get expenseTrackerOver => 'Dépassement';

  @override
  String get expenseTrackerViewAll => 'Voir détails';

  @override
  String get expenseTrackerNoExpenses => 'Aucune dépense enregistrée.';

  @override
  String get expenseTrackerScreenTitle => 'Suivi des Dépenses';

  @override
  String expenseTrackerMonthTotal(String amount) {
    return 'Total : $amount';
  }

  @override
  String get expenseTrackerDeleteConfirm => 'Supprimer cette dépense ?';

  @override
  String get expenseTrackerEmpty =>
      'Aucune dépense ce mois.\nAppuyez sur + pour ajouter.';

  @override
  String get addExpenseTitle => 'Ajouter une Dépense';

  @override
  String get editExpenseTitle => 'Modifier la Dépense';

  @override
  String get addExpenseCategory => 'Catégorie';

  @override
  String get addExpenseAmount => 'Montant';

  @override
  String get addExpenseDate => 'Date';

  @override
  String get addExpenseDescription => 'Description (facultatif)';

  @override
  String get addExpenseCustomCategory => 'Catégorie personnalisée';

  @override
  String get addExpenseInvalidAmount => 'Entrez un montant valide';

  @override
  String get addExpenseTooltip => 'Ajouter une dépense';

  @override
  String get settingsDashBudgetVsActual => 'Budget vs Réel';
}
