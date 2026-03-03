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
  String get authRegistrationSuccess =>
      'Compte créé ! Vérifiez votre email pour confirmer votre compte avant de vous connecter.';

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
  String get settingsDashMonthReview => 'Bilan du mois';

  @override
  String get settingsDashCharts => 'Graphiques';

  @override
  String get dashGroupOverview => 'VUE D\'ENSEMBLE';

  @override
  String get dashGroupFinancialDetail => 'DÉTAIL FINANCIER';

  @override
  String get dashGroupHistory => 'HISTORIQUE';

  @override
  String get dashGroupCharts => 'GRAPHIQUES';

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
  String get addExpenseItem => 'Dépense';

  @override
  String get addExpenseOthers => 'Autres';

  @override
  String get settingsDashBudgetVsActual => 'Budget vs Réel';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get recurringExpenses => 'Dépenses Récurrentes';

  @override
  String get recurringExpenseAdd => 'Ajouter une Dépense Récurrente';

  @override
  String get recurringExpenseEdit => 'Modifier la Dépense Récurrente';

  @override
  String get recurringExpenseCategory => 'Catégorie';

  @override
  String get recurringExpenseAmount => 'Montant';

  @override
  String get recurringExpenseDescription => 'Description (facultatif)';

  @override
  String get recurringExpenseDayOfMonth => 'Jour d\'échéance';

  @override
  String get recurringExpenseActive => 'Active';

  @override
  String get recurringExpenseInactive => 'Inactive';

  @override
  String get recurringExpenseEmpty =>
      'Aucune dépense récurrente.\nAjoutez-en pour générer automatiquement chaque mois.';

  @override
  String get recurringExpenseDeleteConfirm =>
      'Supprimer cette dépense récurrente ?';

  @override
  String get recurringExpenseAutoCreated => 'Créée automatiquement';

  @override
  String get recurringExpenseManage => 'Gérer récurrentes';

  @override
  String get recurringExpenseMarkRecurring => 'Marquer comme récurrente';

  @override
  String get recurringExpensePopulated =>
      'Dépenses récurrentes générées pour ce mois';

  @override
  String get recurringExpenseDayHint => 'Ex : 1 pour le 1er';

  @override
  String get recurringExpenseNoDay => 'Pas de jour fixe';

  @override
  String get recurringExpenseSaved => 'Dépense récurrente enregistrée';

  @override
  String get expenseTrends => 'Tendances des Dépenses';

  @override
  String get expenseTrendsViewTrends => 'Voir les Tendances';

  @override
  String get expenseTrends3Months => '3M';

  @override
  String get expenseTrends6Months => '6M';

  @override
  String get expenseTrends12Months => '12M';

  @override
  String get expenseTrendsBudgeted => 'Budgété';

  @override
  String get expenseTrendsActual => 'Réel';

  @override
  String get expenseTrendsByCategory => 'Par Catégorie';

  @override
  String get expenseTrendsNoData =>
      'Données insuffisantes pour afficher les tendances.';

  @override
  String get expenseTrendsTotal => 'Total';

  @override
  String get expenseTrendsAverage => 'Moyenne';

  @override
  String get expenseTrendsOverview => 'Vue d\'ensemble';

  @override
  String get expenseTrendsMonthly => 'Mensuel';

  @override
  String get savingsGoals => 'Objectifs d\'Épargne';

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
      'Aucun objectif d\'épargne.\nCréez-en un pour suivre vos progrès.';

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
    return 'Vous aviez $amount d\'excédent le mois dernier — allouer à un objectif ?';
  }

  @override
  String get savingsGoalAllocate => 'Allouer';

  @override
  String get savingsGoalSaved => 'Objectif enregistré';

  @override
  String get savingsGoalContributionSaved => 'Contribution enregistrée';

  @override
  String get settingsDashSavingsGoals => 'Objectifs d\'Épargne';

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
  String get mealCostReconciliation => 'Coûts des Repas';

  @override
  String get mealCostEstimated => 'Estimé';

  @override
  String get mealCostActual => 'Réel';

  @override
  String mealCostWeek(String number) {
    return 'Semaine $number';
  }

  @override
  String get mealCostTotal => 'Total du Mois';

  @override
  String get mealCostSavings => 'Économie';

  @override
  String get mealCostOverrun => 'Dépassement';

  @override
  String get mealCostNoData => 'Aucune donnée d\'achats repas.';

  @override
  String get mealCostViewCosts => 'Coûts';

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
  String get notifications => 'Notifications';

  @override
  String get notificationSettings => 'Paramètres de Notifications';

  @override
  String get notificationBillReminders => 'Rappels de factures';

  @override
  String get notificationBillReminderDays => 'Jours avant l\'échéance';

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
  String get notificationCustomReminders => 'Rappels Personnalisés';

  @override
  String get notificationAddCustom => 'Ajouter un Rappel';

  @override
  String get notificationCustomTitle => 'Titre';

  @override
  String get notificationCustomBody => 'Message';

  @override
  String get notificationCustomTime => 'Heure';

  @override
  String get notificationCustomRepeat => 'Répéter';

  @override
  String get notificationCustomRepeatDaily => 'Quotidien';

  @override
  String get notificationCustomRepeatWeekly => 'Hebdomadaire';

  @override
  String get notificationCustomRepeatMonthly => 'Mensuel';

  @override
  String get notificationCustomRepeatNone => 'Ne pas répéter';

  @override
  String get notificationCustomSaved => 'Rappel enregistré';

  @override
  String get notificationCustomDeleteConfirm => 'Supprimer ce rappel ?';

  @override
  String get notificationEmpty => 'Aucun rappel personnalisé.';

  @override
  String notificationBillTitle(String name) {
    return 'Facture à payer : $name';
  }

  @override
  String notificationBillBody(String amount, String days) {
    return '$amount dû dans $days jours';
  }

  @override
  String get notificationBudgetTitle => 'Alerte budget';

  @override
  String notificationBudgetBody(String percent) {
    return 'Vous avez dépensé $percent% du budget mensuel';
  }

  @override
  String get notificationMealPlanTitle => 'Plan de repas';

  @override
  String get notificationMealPlanBody =>
      'Vous n\'avez pas encore généré le plan repas ce mois-ci';

  @override
  String get notificationPermissionRequired =>
      'Autorisation de notifications requise';

  @override
  String get notificationSelectDays => 'Sélectionner les jours';

  @override
  String get settingsColorPalette => 'Palette de couleurs';

  @override
  String get paletteOcean => 'Océan';

  @override
  String get paletteEmerald => 'Émeraude';

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
  String get exportPdfDesc => 'Rapport avec budget vs réel';

  @override
  String get exportCsv => 'Données CSV';

  @override
  String get exportCsvDesc => 'Données brutes pour tableur';

  @override
  String get exportReportTitle => 'Rapport Mensuel des Dépenses';

  @override
  String get exportBudgetVsActual => 'Budget vs Réel';

  @override
  String get exportExpenseDetail => 'Détail des Dépenses';

  @override
  String get searchExpenses => 'Rechercher';

  @override
  String get searchExpensesHint => 'Rechercher par description...';

  @override
  String get searchDateRange => 'Période';

  @override
  String get searchNoResults => 'Aucune dépense trouvée';

  @override
  String searchResultCount(int count) {
    return '$count résultats';
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
    return '$count budgets variables non définis';
  }

  @override
  String get unsetBudgetsCta => 'Définir dans les paramètres';

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
  String get onbSlide0Title => 'Votre budget, en un coup d\'œil';

  @override
  String get onbSlide0Body =>
      'Le tableau de bord affiche votre liquidité mensuelle, dépenses et Indice de Sérénité.';

  @override
  String get onbSlide1Title => 'Suivez chaque dépense';

  @override
  String get onbSlide1Body =>
      'Appuyez sur + pour enregistrer un achat. Assignez une catégorie et regardez les barres se mettre à jour.';

  @override
  String get onbSlide2Title => 'Achetez avec une liste';

  @override
  String get onbSlide2Body =>
      'Parcourez les produits, créez une liste, puis finalisez pour enregistrer vos dépenses automatiquement.';

  @override
  String get onbSlide3Title => 'Votre coach financier IA';

  @override
  String get onbSlide3Body =>
      'Obtenez une analyse en 3 parties basée sur votre budget réel — pas des conseils génériques.';

  @override
  String get onbSlide4Title => 'Planifiez vos repas dans le budget';

  @override
  String get onbSlide4Body =>
      'Générez un plan mensuel adapté à votre budget alimentaire et la taille du foyer.';

  @override
  String get onbTourSkip => 'Passer la visite';

  @override
  String get onbTourNext => 'Suivant';

  @override
  String get onbTourDone => 'Compris';

  @override
  String get onbTourDash1Title => 'Liquidité mensuelle';

  @override
  String get onbTourDash1Body =>
      'Revenus moins toutes les dépenses. Vert signifie solde positif.';

  @override
  String get onbTourDash2Title => 'Indice de Sérénité';

  @override
  String get onbTourDash2Body =>
      'Score de santé financière 0–100. Appuyez pour voir les facteurs.';

  @override
  String get onbTourDash3Title => 'Budget vs réel';

  @override
  String get onbTourDash3Body => 'Dépenses prévues vs réelles par catégorie.';

  @override
  String get onbTourDash4Title => 'Ajouter une dépense';

  @override
  String get onbTourDash4Body =>
      'Appuyez sur + à tout moment pour enregistrer une dépense.';

  @override
  String get onbTourDash5Title => 'Navigation';

  @override
  String get onbTourDash5Body =>
      '5 sections : Budget, Épicerie, Liste, Coach, Repas.';

  @override
  String get onbTourGrocery1Title => 'Rechercher et filtrer';

  @override
  String get onbTourGrocery1Body =>
      'Recherchez par nom ou filtrez par catégorie.';

  @override
  String get onbTourGrocery2Title => 'Ajouter à la liste';

  @override
  String get onbTourGrocery2Body =>
      'Appuyez sur + sur un produit pour l\'ajouter à votre liste de courses.';

  @override
  String get onbTourGrocery3Title => 'Catégories';

  @override
  String get onbTourGrocery3Body =>
      'Faites défiler les filtres de catégorie pour affiner les produits.';

  @override
  String get onbTourShopping1Title => 'Cocher les articles';

  @override
  String get onbTourShopping1Body =>
      'Appuyez sur un article pour le marquer comme pris.';

  @override
  String get onbTourShopping2Title => 'Finaliser l\'achat';

  @override
  String get onbTourShopping2Body =>
      'Enregistre la dépense et efface les articles cochés.';

  @override
  String get onbTourShopping3Title => 'Historique d\'achats';

  @override
  String get onbTourShopping3Body =>
      'Consultez toutes vos sessions d\'achats passées ici.';

  @override
  String get onbTourCoach1Title => 'Analyser mon budget';

  @override
  String get onbTourCoach1Body =>
      'Appuyez pour générer une analyse basée sur vos données réelles.';

  @override
  String get onbTourCoach2Title => 'Historique d\'analyses';

  @override
  String get onbTourCoach2Body =>
      'Les analyses sauvegardées apparaissent ici, les plus récentes en premier.';

  @override
  String get onbTourMeals1Title => 'Générer un plan';

  @override
  String get onbTourMeals1Body =>
      'Crée un mois complet de repas dans votre budget alimentaire.';

  @override
  String get onbTourMeals2Title => 'Vue hebdomadaire';

  @override
  String get onbTourMeals2Body =>
      'Parcourez les repas par semaine. Appuyez sur un jour pour voir la recette.';

  @override
  String get onbTourMeals3Title => 'Ajouter à la liste de courses';

  @override
  String get onbTourMeals3Body =>
      'Envoyez les ingrédients de la semaine à votre liste en un seul appui.';

  @override
  String get taxDeductionTitle => 'Déductions Fiscales';

  @override
  String get taxDeductionSeeDetail => 'Voir détail';

  @override
  String get taxDeductionEstimated => 'déduction estimée';

  @override
  String taxDeductionMaxOf(String amount) {
    return 'Max. de $amount';
  }

  @override
  String get taxDeductionDetailTitle => 'Déductions Fiscales — Détail';

  @override
  String get taxDeductionDeductibleTitle => 'CATÉGORIES DÉDUCTIBLES';

  @override
  String get taxDeductionNonDeductibleTitle => 'CATÉGORIES NON DÉDUCTIBLES';

  @override
  String get taxDeductionTotalLabel => 'DÉDUCTION ESTIMÉE';

  @override
  String taxDeductionSpent(String amount) {
    return 'Dépensé : $amount';
  }

  @override
  String taxDeductionCapUsed(String percent, String cap) {
    return '$percent de $cap utilisé';
  }

  @override
  String get taxDeductionNotDeductible => 'Non déductible';

  @override
  String get taxDeductionDisclaimer =>
      'Ces valeurs sont des estimations basées sur vos dépenses enregistrées. Les déductions réelles dépendent des factures déclarées. Consultez un professionnel fiscal pour les montants définitifs.';

  @override
  String get settingsDashTaxDeductions => 'Déductions fiscales (PT)';

  @override
  String get settingsDashUpcomingBills => 'Factures à venir';

  @override
  String get settingsDashBudgetStreaks => 'Séries de budget';

  @override
  String get upcomingBillsTitle => 'Factures à Venir';

  @override
  String get upcomingBillsManage => 'Gérer';

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
    return 'Besoin de $amount/mois pour respecter l\'échéance';
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
  String get taxSimPresets => 'SCÉNARIOS RAPIDES';

  @override
  String get taxSimPresetRaise => '+€200 augmentation';

  @override
  String get taxSimPresetMeal => 'Carte vs espèces';

  @override
  String get taxSimPresetTitular => 'Conjoint vs séparé';

  @override
  String get taxSimParameters => 'PARAMÈTRES';

  @override
  String get taxSimGross => 'Salaire brut';

  @override
  String get taxSimMarital => 'État civil';

  @override
  String get taxSimTitulares => 'Titulaires';

  @override
  String get taxSimDependentes => 'Personnes à charge';

  @override
  String get taxSimMealType => 'Type d\'indemnité repas';

  @override
  String get taxSimMealAmount => 'Indemnité repas/jour';

  @override
  String get taxSimComparison => 'ACTUEL VS SIMULÉ';

  @override
  String get taxSimNetTakeHome => 'Net à percevoir';

  @override
  String get taxSimIRS => 'Retenue d\'impôt';

  @override
  String get taxSimSS => 'Sécurité sociale';

  @override
  String get taxSimDelta => 'Différence mensuelle :';

  @override
  String get taxSimButton => 'Simulateur Fiscal';

  @override
  String get streakTitle => 'Séries de Budget';

  @override
  String get streakBronze => 'Bronze';

  @override
  String get streakSilver => 'Argent';

  @override
  String get streakGold => 'Or';

  @override
  String get streakBronzeDesc => 'Liquidité positive';

  @override
  String get streakSilverDesc => 'Dans le budget';

  @override
  String get streakGoldDesc => 'Toutes catégories';

  @override
  String streakMonths(int count) {
    return '$count mois';
  }
}
