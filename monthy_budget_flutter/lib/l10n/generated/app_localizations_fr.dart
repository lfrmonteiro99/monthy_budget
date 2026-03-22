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
    return 'Ajouter $name Ã  la liste';
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
  String get enumMealSnack => 'GoÃ»ter';

  @override
  String get enumMealDinner => 'Dîner';

  @override
  String get enumObjMinimizeCost => 'Minimiser les coÃ»ts';

  @override
  String get enumObjBalancedHealth => 'Ã‰quilibre coÃ»t/santé';

  @override
  String get enumObjHighProtein => 'Riche en protéines';

  @override
  String get enumObjLowCarb => 'Faible en glucides';

  @override
  String get enumObjVegetarian => 'Végétarien';

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
  String get enumSodiumReduced => 'Sodium réduit';

  @override
  String get enumSodiumLow => 'Faible en sodium';

  @override
  String get enumAge0to3 => '0ââ‚¬â€œ3 ans';

  @override
  String get enumAge4to10 => '4ââ‚¬â€œ10 ans';

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
  String get stressHigh => 'Ã‰levée';

  @override
  String stressUsed(String percent) {
    return '$percent% utilisé';
  }

  @override
  String get stressNA => 'N/D';

  @override
  String monthReviewFoodExceeded(String percent) {
    return 'L\'alimentation a dépassé le budget de $percent% ââ‚¬â€ envisagez de revoir les portions ou la fréquence des courses.';
  }

  @override
  String monthReviewExpensesExceeded(String amount) {
    return 'Les dépenses réelles ont dépassé le prévu de $amountââ€šÂ¬ ââ‚¬â€ ajuster les valeurs dans les paramètres ?';
  }

  @override
  String monthReviewSavedMore(String amount) {
    return 'Ã‰conomisé $amountââ€šÂ¬ de plus que prévu ââ‚¬â€ vous pouvez renforcer le fonds d\'urgence.';
  }

  @override
  String get monthReviewOnTrack =>
      'Dépenses dans les prévisions. Bon contrÃ´le budgétaire.';

  @override
  String get dashboardTitle => 'Budget Mensuel';

  @override
  String get dashboardViewFullReport => 'Voir le Rapport Complet';

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
  String get dashboardSavingsRate => 'Taux Ã‰pargne';

  @override
  String get dashboardViewTrends => 'Voir évolution';

  @override
  String get dashboardViewProjection => 'Voir projection';

  @override
  String get dashboardFinancialSummary => 'RÃ‰SUMÃ‰ FINANCIER';

  @override
  String get dashboardOpenSettings => 'Ouvrir les paramètres';

  @override
  String get dashboardMonthlyLiquidity => 'LIQUIDITÃ‰ MENSUELLE';

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
    return '$actualâ‚¬/jour vs $expectedâ‚¬/jour';
  }

  @override
  String get dashboardSummaryLabel => 'ââ‚¬â€ RÃ‰SUMÃ‰';

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
      'ÃŠtes-vous sÃ»r de vouloir supprimer toutes les analyses enregistrées ?';

  @override
  String get coachDeleteLabel => 'Supprimer l\'analyse';

  @override
  String get coachDeleteTooltip => 'Supprimer';

  @override
  String get coachEmptyTitle => 'Votre coach financier';

  @override
  String get coachEmptyBody =>
      'Posez toute question sur votre budget, depenses ou epargne. J\'utiliserai vos donnees reelles pour des conseils personnalises.';

  @override
  String get coachQuickPrompt1 =>
      'Ou puis-je reduire mes depenses ce mois-ci ?';

  @override
  String get coachQuickPrompt2 => 'Comment ameliorer mon epargne ?';

  @override
  String get coachQuickPrompt3 => 'Aidez-moi a creer un plan sur 30 jours.';

  @override
  String get coachComposerHint => 'Demandez a votre coach...';

  @override
  String get coachYou => 'Vous';

  @override
  String get coachAssistant => 'Coach';

  @override
  String coachCreditsCount(int count) {
    return '$count credits';
  }

  @override
  String get coachMemory => 'Memoire';

  @override
  String get coachCostFree => 'Mode Eco â€” sans cout de credits.';

  @override
  String coachCostCredits(int cost) {
    return 'Ce message coute $cost credits.';
  }

  @override
  String get coachFree => 'Gratuit';

  @override
  String coachPerMsg(int cost) {
    return '$cost/msg';
  }

  @override
  String get coachEcoFallbackTitle => 'Mode Eco actif (sans credits)';

  @override
  String get coachEcoFallbackBody =>
      'Vous pouvez continuer a discuter avec une memoire reduite.';

  @override
  String get coachRestoreMemory => 'Restaurer la memoire';

  @override
  String get cmdAssistantTitle => 'Assistant';

  @override
  String get cmdAssistantHint => 'De quoi avez-vous besoin ?';

  @override
  String get cmdAssistantTooltip => 'Besoin d\'aide ? Appuyez ici';

  @override
  String get cmdSuggestionAddExpense => 'Ajouter une depense';

  @override
  String get cmdSuggestionOpenList => 'Ouvrir la liste de courses';

  @override
  String get cmdSuggestionChangeTheme => 'Changer le theme';

  @override
  String get cmdSuggestionOpenSettings => 'Aller aux parametres';

  @override
  String get cmdTemplateAddExpense => 'Ajoute [montant] euros en [categorie]';

  @override
  String get cmdTemplateChangeTheme => 'Change le theme en [clair/sombre]';

  @override
  String get cmdExecutionFailed =>
      'J\'ai compris la demande, mais je n\'ai pas pu l\'executer. Reessayez.';

  @override
  String get cmdNotUnderstood =>
      'Je n\'ai pas compris. Pouvez-vous reformuler ?';

  @override
  String get cmdUndo => 'Annuler';

  @override
  String get expenseDeleted => 'Dépense supprimée';

  @override
  String get cmdCapabilitiesCta => 'Que puis-je faire ?';

  @override
  String get cmdCapabilitiesTitle => 'Actions disponibles';

  @override
  String get cmdCapabilitiesSubtitle =>
      'Voici les actions que l\'assistant prend en charge pour le moment.';

  @override
  String get cmdCapabilitiesFooter =>
      'Nous en ajoutons encore. Si ce n\'est pas liste ici, cela peut ne pas encore fonctionner.';

  @override
  String get cmdCapabilityAddExpense => 'Ajouter une depense';

  @override
  String get cmdCapabilityAddExpenseExample =>
      'Ajoute [montant] euros en [categorie]';

  @override
  String get cmdCapabilityAddShoppingItem => 'Ajouter a la liste';

  @override
  String get cmdCapabilityAddShoppingItemExample =>
      'Ajoute [article] a la liste de courses';

  @override
  String get cmdCapabilityRemoveShoppingItem => 'Retirer de la liste';

  @override
  String get cmdCapabilityRemoveShoppingItemExample =>
      'Retire [article] de la liste de courses';

  @override
  String get cmdCapabilityToggleShoppingItemChecked =>
      'Cocher ou decocher un article';

  @override
  String get cmdCapabilityToggleShoppingItemCheckedExample =>
      'Coche [article] dans la liste de courses';

  @override
  String get cmdCapabilityAddSavingsGoal => 'Creer un objectif d\'epargne';

  @override
  String get cmdCapabilityAddSavingsGoalExample =>
      'Cree objectif d\'epargne [nom] de [montant]';

  @override
  String get cmdCapabilityAddSavingsContribution =>
      'Ajouter a l\'objectif d\'epargne';

  @override
  String get cmdCapabilityAddSavingsContributionExample =>
      'Ajoute [montant] a l\'objectif [nom]';

  @override
  String get cmdCapabilityAddRecurringExpense =>
      'Ajouter une depense recurrente';

  @override
  String get cmdCapabilityAddRecurringExpenseExample =>
      'Ajoute depense recurrente [montant] en [categorie] jour [jour]';

  @override
  String get cmdCapabilityDeleteExpense => 'Supprimer une depense';

  @override
  String get cmdCapabilityDeleteExpenseExample =>
      'Supprime la depense [description]';

  @override
  String get cmdCapabilityChangeTheme => 'Changer le theme';

  @override
  String get cmdCapabilityChangeThemeExample =>
      'Change le theme en [clair/sombre]';

  @override
  String get cmdCapabilityChangePalette => 'Changer la palette';

  @override
  String get cmdCapabilityChangePaletteExample =>
      'Couleur [ocean/emerald/violet/teal/sunset]';

  @override
  String get cmdCapabilityChangeLanguage => 'Changer la langue';

  @override
  String get cmdCapabilityChangeLanguageExample =>
      'Langue [anglais/portugais/espagnol/francais]';

  @override
  String get cmdCapabilityNavigate => 'Ouvrir un ecran';

  @override
  String get cmdCapabilityNavigateExample => 'Ouvre la liste de courses';

  @override
  String get cmdCapabilityClearChecked => 'Vider les coches';

  @override
  String get cmdCapabilityClearCheckedExample => 'Effacer les elements coches';

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
    return '$name ajouté Ã  la liste';
  }

  @override
  String groceryAvgPrice(String unit) {
    return '$unit · prix moyen';
  }

  @override
  String get groceryAvailabilityTitle => 'Disponibilité des données';

  @override
  String groceryAvailabilityCountry(String countryCode) {
    return 'Marché : $countryCode';
  }

  @override
  String groceryAvailabilitySummary(int fresh, int partial, int failed) {
    return '$fresh fraîches · $partial partielles · $failed indisponibles';
  }

  @override
  String get groceryAvailabilityWarning =>
      'Certaines enseignes ont des données partielles ou périmées. Les comparaisons peuvent être incomplètes.';

  @override
  String get groceryEmptyStateTitle => 'Aucune donnée de courses disponible';

  @override
  String get groceryEmptyStateMessage =>
      'Réessayez plus tard ou changez de marché dans les réglages.';

  @override
  String get shoppingTitle => 'Liste de Courses';

  @override
  String get shoppingEmpty => 'Liste vide';

  @override
  String get shoppingEmptyMessage =>
      'Ajoutez des produits depuis\nl\'écran Courses.';

  @override
  String shoppingItemsRemaining(int count, String total) {
    return '$count Ã  acheter · $total';
  }

  @override
  String get shoppingClear => 'Effacer';

  @override
  String get shoppingFinalize => 'Finaliser l\'Achat';

  @override
  String get shoppingEstimatedTotal => 'Total estimé';

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
  String get shoppingPendingSync => 'Synchronisation en attente';

  @override
  String get shoppingViewItems => 'Articles';

  @override
  String get shoppingViewMeals => 'Repas';

  @override
  String get shoppingViewStores => 'Magasins';

  @override
  String get offlineBannerMessage =>
      'Hors ligne : les modifications seront synchronisées lorsque vous serez reconnecté.';

  @override
  String get shoppingGroupOther => 'Autres';

  @override
  String shoppingGroupCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
    );
    return '$_temp0';
  }

  @override
  String shoppingCheapestAt(String store, String price) {
    return 'Moins cher chez $store ($price)';
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
  String get authSwitchToLogin => 'J\'ai déjÃ  un compte';

  @override
  String get authRegistrationSuccess =>
      'Compte créé ! Vérifiez votre email pour confirmer votre compte avant de vous connecter.';

  @override
  String get authErrorNetwork =>
      'Impossible de se connecter au serveur. Vérifiez votre connexion internet et réessayez.';

  @override
  String get authErrorInvalidCredentials =>
      'Email ou mot de passe incorrect. Veuillez réessayer.';

  @override
  String get authErrorEmailNotConfirmed =>
      'Veuillez vérifier votre email avant de vous connecter.';

  @override
  String get authErrorTooManyRequests =>
      'Trop de tentatives. Veuillez patienter et réessayer.';

  @override
  String get authErrorGeneric =>
      'Une erreur est survenue. Veuillez réessayer plus tard.';

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
  String get chartSavingsRate => 'Taux d\'Ã‰pargne';

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
    return 'Projection ââ‚¬â€ $month $year';
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
  String get projectionExpenses => 'DÃ‰PENSES';

  @override
  String get projectionSimulation => 'Simulation ââ‚¬â€ non enregistré';

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
  String get trendCatTelecom => 'Télécom';

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
  String get trendCatHealth => 'Santé';

  @override
  String get trendCatLeisure => 'Loisirs';

  @override
  String get trendCatOther => 'Autres';

  @override
  String monthReviewTitle(String month) {
    return 'Résumé ââ‚¬â€ $month';
  }

  @override
  String get monthReview => 'Bilan du mois';

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
  String get monthReviewTopDeviations => 'Ã‰CARTS PRINCIPAUX';

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
  String get mealAddWeekToList => 'Ajouter la semaine Ã  la liste';

  @override
  String mealIngredientsAdded(int count) {
    return '$count ingrédients ajoutés Ã  la liste';
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
  String get mealSwap => 'Ã‰changer';

  @override
  String get mealConsolidatedList => 'Voir la liste consolidée';

  @override
  String get mealConsolidatedTitle => 'Liste Consolidée';

  @override
  String get mealAlternatives => 'Alternatives';

  @override
  String mealTotalCost(String cost) {
    return '$costââ€šÂ¬ total';
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
    return '$costâ‚¬/pers';
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
  String get wizardNutFree => 'Sans fruits Ã  coque';

  @override
  String get wizardShellfishFree => 'Sans crustacés';

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
  String get wizardComplexityAdvanced => 'Avancé';

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
  String get wizardReuseLeftovers => 'Réutiliser les restes';

  @override
  String get wizardReuseLeftoversDesc =>
      'Le dîner d\'hier = le déjeuner d\'aujourd\'hui (coÃ»t 0)';

  @override
  String get wizardMaxNewIngredients => 'NOUVEAUX INGRÃ‰DIENTS PAR SEMAINE MAX';

  @override
  String get wizardNoLimit => 'Sans limite';

  @override
  String get wizardMinimizeWaste => 'Minimiser le gaspillage';

  @override
  String get wizardMinimizeWasteDesc =>
      'Préférer les recettes réutilisant des ingrédients déjÃ  utilisés';

  @override
  String get wizardSettingsInfo =>
      'Vous pouvez modifier les paramètres du planificateur Ã  tout moment dans Paramètres ââ€ â€™ Repas.';

  @override
  String get wizardContinue => 'Continuer';

  @override
  String get wizardGeneratePlan => 'Générer le Plan';

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
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsPersonal => 'Données Personnelles';

  @override
  String get settingsSalaries => 'Salaires';

  @override
  String get settingsExpenses => 'Budget et Paiements Récurrents';

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
  String get settingsAddExpense => 'Ajouter une catégorie';

  @override
  String get settingsExpenseName => 'Nom de catégorie';

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
      'ÃŠtes-vous sÃ»r de vouloir vous déconnecter ?';

  @override
  String get settingsLogoutConfirmButton => 'Se déconnecter';

  @override
  String get settingsSalariesSection => 'Revenus';

  @override
  String get settingsExpensesMonthly => 'Budget et Paiements Récurrents';

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
  String get settingsAddExpenseButton => 'Ajouter une Catégorie';

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
  String get dashGroupFinancialDetail => 'DÃ‰TAIL FINANCIER';

  @override
  String get dashGroupHistory => 'HISTORIQUE';

  @override
  String get dashGroupCharts => 'GRAPHIQUES';

  @override
  String get settingsVisibleCharts => 'GRAPHIQUES VISIBLES';

  @override
  String get settingsFavTip =>
      'Les produits favoris influencent le plan repas â€” les recettes avec ces ingrédients sont prioritaires.';

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
    return 'Calculé automatiquement : $count (titulaires + personnes Ã  charge)';
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
    return 'Légumineuses par semaine : $count';
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
  String get settingsReuseLeftovers => 'Réutiliser les restes';

  @override
  String get settingsMinimizeWaste => 'Minimiser le gaspillage';

  @override
  String get settingsPrioritizeLowCost => 'Prioriser le bas coÃ»t';

  @override
  String get settingsPrioritizeLowCostDesc =>
      'Préférer les recettes moins chères';

  @override
  String settingsNewIngredientsPerWeek(int count) {
    return 'NOUVEAUX INGRÃ‰DIENTS PAR SEMAINE ($count)';
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
  String get settingsMealAdvanced => 'Avancé';

  @override
  String get settingsMealAdvancedSubtitle =>
      'Réinitialiser l\'assistant de configuration';

  @override
  String get settingsApiKeyInfo =>
      'La clé est stockée localement sur l\'appareil et n\'est jamais partagée. Utilise le modèle GPT-4o mini (~â‚¬0,00008 par analyse).';

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
  String get taxIncomeTax => 'ImpÃ´t sur le revenu';

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
      'Tu es un analyste financier personnel pour des utilisateurs portugais. Réponds toujours en portugais européen. Sois direct et analytique ââ‚¬â€ utilise toujours les chiffres concrets du contexte fourni. Structure la réponse exactement dans les 3 parties demandées. N\'introduis pas de données, benchmarks ou références externes non fournis.';

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
  String get monthAbbrAug => 'AoÃ»';

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
  String get monthFullAug => 'AoÃ»t';

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
    return 'Ã‰tape $step sur $total';
  }

  @override
  String get setupWizardContinue => 'Continuer';

  @override
  String get setupWizardCountryTitle => 'OÃ¹ habitez-vous ?';

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
      'Nous utilisons ceci pour calculer vos impÃ´ts plus précisément.';

  @override
  String get setupWizardPrivacyNote =>
      'Vos données restent dans votre compte et ne sont jamais partagées.';

  @override
  String get setupWizardSingle => 'Célibataire';

  @override
  String get setupWizardMarried => 'Marié(e)';

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
    return 'Net estimé : $amount';
  }

  @override
  String get setupWizardSalaryMoreLater =>
      'Vous pouvez ajouter d\'autres sources de revenus plus tard.';

  @override
  String get setupWizardSalaryRequired => 'Veuillez entrer votre salaire';

  @override
  String get setupWizardSalaryPositive =>
      'Le salaire doit être un nombre positif';

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
      'Votre budget est configuré. Vous pouvez tout ajuster dans les paramètres Ã  tout moment.';

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
  String get expenseTrackerTitle => 'BUDGET VS RÃ‰EL';

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
  String get addExpenseTooltip => 'Saisir une dépense';

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
  String get recurringExpenses => 'Paiements Récurrents';

  @override
  String get recurringExpenseAdd => 'Ajouter un Paiement Récurrent';

  @override
  String get recurringExpenseEdit => 'Modifier le Paiement Récurrent';

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
      'Aucun paiement récurrent.\nAjoutez-en un pour le générer automatiquement chaque mois.';

  @override
  String get recurringExpenseDeleteConfirm =>
      'Supprimer ce paiement récurrent ?';

  @override
  String get recurringExpenseAutoCreated => 'Créée automatiquement';

  @override
  String get recurringExpenseManage => 'Gérer les paiements récurrents';

  @override
  String get recurringExpenseMarkRecurring =>
      'Marquer comme paiement récurrent';

  @override
  String get recurringExpensePopulated =>
      'Paiements récurrents générés pour ce mois';

  @override
  String get recurringExpenseDayHint => 'Ex : 1 pour le 1er';

  @override
  String get recurringExpenseNoDay => 'Pas de jour fixe';

  @override
  String get recurringExpenseSaved => 'Paiement récurrent enregistré';

  @override
  String get recurringPaymentToggle => 'Paiement récurrent';

  @override
  String billsCount(int count) {
    return '$count paiements';
  }

  @override
  String get billsNone => 'Aucun paiement récurrent';

  @override
  String billsPerMonth(int count, String amount) {
    return '$count paiements · $amount/mois';
  }

  @override
  String billsExceedBudget(String amount) {
    return 'Factures ($amount) dépassent le budget';
  }

  @override
  String get billsAddBill => 'Ajouter un Paiement Récurrent';

  @override
  String get billsBudgetSettings => 'Paramètres du Budget';

  @override
  String get billsRecurringBills => 'Paiements Récurrents';

  @override
  String get billsDescription => 'Description';

  @override
  String get billsAmount => 'Montant';

  @override
  String get billsDueDay => 'Jour d\'échéance';

  @override
  String get billsActive => 'Active';

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
    return 'Vous aviez $amount d\'excédent le mois dernier ââ‚¬â€ allouer Ã  un objectif ?';
  }

  @override
  String get savingsGoalAllocate => 'Allouer';

  @override
  String get savingsGoalSaved => 'Objectif enregistré';

  @override
  String get savingsGoalContributionSaved => 'Contribution enregistrée';

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
  String get mealCostReconciliation => 'CoÃ»ts des Repas';

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
  String get mealCostSavings => 'Ã‰conomie';

  @override
  String get mealCostOverrun => 'Dépassement';

  @override
  String get mealCostNoData => 'Aucune donnée d\'achats repas.';

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
  String get mealLeftoverIdea => 'Idée de transformation';

  @override
  String get mealWeeklySummary => 'Nutrition Hebdomadaire';

  @override
  String get mealBatchPrepGuide => 'Cuisine en Lot';

  @override
  String get mealViewPrepGuide => 'Préparation';

  @override
  String get mealPrepGuideTitle => 'Comment Préparer';

  @override
  String mealPrepTime(String minutes) {
    return 'Temps: $minutes min';
  }

  @override
  String mealBatchTotalTime(String time) {
    return 'Temps estimé: $time';
  }

  @override
  String get mealBatchParallelTips => 'Astuces de cuisson parallèle';

  @override
  String get mealFeedbackLike => 'J\'aime';

  @override
  String get mealFeedbackDislike => 'Je n\'aime pas';

  @override
  String get mealFeedbackSkip => 'Passer';

  @override
  String get mealRateRecipe => 'Noter la recette';

  @override
  String mealRatingLabel(int rating) {
    return '$rating etoiles';
  }

  @override
  String get mealRatingUnrated => 'Non note';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSettings => 'Paramètres de Notifications';

  @override
  String get notificationPreferredTime => 'Heure préférée';

  @override
  String get notificationPreferredTimeDesc =>
      'Les notifications programmées utiliseront cette heure (sauf rappels personnalisés)';

  @override
  String get notificationBillReminders => 'Rappels de paiements';

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
    return 'Paiement Ã  venir : $name';
  }

  @override
  String notificationBillBody(String amount, String days) {
    return '$amount dÃ» dans $days jours';
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
  String get exportMonthlySummary => 'Résumé Mensuel';

  @override
  String get exportMonthlySummaryDesc =>
      'Revenus, budget vs réel et taux d\'épargne';

  @override
  String get exportSectionIncome => 'Revenus';

  @override
  String get exportSectionSummary => 'Résumé Mensuel';

  @override
  String get exportLabelTotalIncome => 'Revenu Net Total';

  @override
  String get exportLabelGrossIncome => 'Revenu Brut';

  @override
  String get exportLabelDeductions => 'Déductions';

  @override
  String get exportLabelTotalExpenses => 'Total des Dépenses';

  @override
  String get exportLabelNetLiquidity => 'Liquidité Mensuelle';

  @override
  String get exportLabelSavingsRate => 'Taux d\'Épargne';

  @override
  String get exportLabelTotal => 'Total';

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
  String get expenseTypeLabel => 'TYPE';

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
  String get onbSlide0Title => 'Votre budget, en un coup d\'Ã…â€œil';

  @override
  String get onbSlide0Body =>
      'Le tableau de bord affiche votre liquidité mensuelle, dépenses et Indice de Sérénité.';

  @override
  String get onbSlide1Title => 'Suivez chaque dépense';

  @override
  String get onbSlide1Body =>
      'Appuyez sur + pour enregistrer un achat. Assignez une catégorie et regardez les barres se mettre Ã  jour.';

  @override
  String get onbSlide2Title => 'Achetez avec une liste';

  @override
  String get onbSlide2Body =>
      'Parcourez les produits, créez une liste, puis finalisez pour enregistrer vos dépenses automatiquement.';

  @override
  String get onbSlide3Title => 'Votre coach financier IA';

  @override
  String get onbSlide3Body =>
      'Obtenez une analyse en 3 parties basée sur votre budget réel â€” pas des conseils génériques.';

  @override
  String get onbSlide4Title => 'Planifiez vos repas dans le budget';

  @override
  String get onbSlide4Body =>
      'Générez un plan mensuel adapté Ã  votre budget alimentaire et la taille du foyer.';

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
      'Score de santé financière 0â€“100. Appuyez pour voir les facteurs.';

  @override
  String get onbTourDash3Title => 'Budget vs réel';

  @override
  String get onbTourDash3Body => 'Dépenses prévues vs réelles par catégorie.';

  @override
  String get onbTourDash4Title => 'Ajouter une dépense';

  @override
  String get onbTourDash4Body =>
      'Appuyez sur + Ã  tout moment pour enregistrer une dépense.';

  @override
  String get onbTourDash5Title => 'Navigation';

  @override
  String get onbTourDash5Body =>
      '5 sections : Budget, Ã‰picerie, Liste, Coach, Repas.';

  @override
  String get onbTourGrocery1Title => 'Rechercher et filtrer';

  @override
  String get onbTourGrocery1Body =>
      'Recherchez par nom ou filtrez par catégorie.';

  @override
  String get onbTourGrocery2Title => 'Ajouter Ã  la liste';

  @override
  String get onbTourGrocery2Body =>
      'Appuyez sur + sur un produit pour l\'ajouter Ã  votre liste de courses.';

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
  String get onbTourMeals3Title => 'Ajouter Ã  la liste de courses';

  @override
  String get onbTourMeals3Body =>
      'Envoyez les ingrédients de la semaine Ã  votre liste en un seul appui.';

  @override
  String get onbTourExpenseTracker1Title => 'Navigation mensuelle';

  @override
  String get onbTourExpenseTracker1Body =>
      'Changez de mois pour voir ou ajouter des dépenses pour n\'importe quelle période.';

  @override
  String get onbTourExpenseTracker2Title => 'Résumé du budget';

  @override
  String get onbTourExpenseTracker2Body =>
      'Voyez votre budget vs dépenses réelles et le solde restant en un coup d\'Å“il.';

  @override
  String get onbTourExpenseTracker3Title => 'Par catégorie';

  @override
  String get onbTourExpenseTracker3Body =>
      'Chaque catégorie affiche une barre de progression. Touchez pour développer et voir les dépenses individuelles.';

  @override
  String get onbTourExpenseTracker4Title => 'Ajouter une dépense';

  @override
  String get onbTourExpenseTracker4Body =>
      'Touchez + pour enregistrer une nouvelle dépense. Choisissez la catégorie et le montant.';

  @override
  String get onbTourSavings1Title => 'Vos objectifs';

  @override
  String get onbTourSavings1Body =>
      'Chaque carte montre la progression vers votre objectif. Touchez pour voir les détails et ajouter des contributions.';

  @override
  String get onbTourSavings2Title => 'Créer un objectif';

  @override
  String get onbTourSavings2Body =>
      'Touchez + pour définir un nouvel objectif d\'épargne avec un montant cible et une date limite optionnelle.';

  @override
  String get onbTourRecurring1Title => 'Dépenses récurrentes';

  @override
  String get onbTourRecurring1Body =>
      'Factures fixes mensuelles comme le loyer, abonnements et services. Incluses automatiquement dans votre budget.';

  @override
  String get onbTourRecurring2Title => 'Ajouter récurrente';

  @override
  String get onbTourRecurring2Body =>
      'Touchez + pour enregistrer une nouvelle dépense récurrente avec montant et jour d\'échéance.';

  @override
  String get onbTourAssistant1Title => 'Assistant de commandes';

  @override
  String get onbTourAssistant1Body =>
      'Votre raccourci pour les actions rapides. Touchez pour ajouter des dépenses, changer les paramètres, naviguer et plus â€” tapez simplement ce dont vous avez besoin.';

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
  String get taxDeductionDetailTitle => 'Déductions Fiscales ââ‚¬â€ Détail';

  @override
  String get taxDeductionDeductibleTitle => 'CATÃ‰GORIES DÃ‰DUCTIBLES';

  @override
  String get taxDeductionNonDeductibleTitle => 'CATÃ‰GORIES NON DÃ‰DUCTIBLES';

  @override
  String get taxDeductionTotalLabel => 'DÃ‰DUCTION ESTIMÃ‰E';

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
  String get settingsDashUpcomingBills => 'Prochains paiements';

  @override
  String get settingsDashBudgetStreaks => 'Séries de budget';

  @override
  String get settingsDashQuickActions => 'Actions rapides';

  @override
  String get upcomingBillsTitle => 'Prochains Paiements';

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
  String get taxSimPresets => 'SCÃ‰NARIOS RAPIDES';

  @override
  String get taxSimPresetRaise => '+ââ€šÂ¬200 augmentation';

  @override
  String get taxSimPresetMeal => 'Carte vs espèces';

  @override
  String get taxSimPresetTitular => 'Conjoint vs séparé';

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
  String get taxSimMealType => 'Type d\'indemnité repas';

  @override
  String get taxSimMealAmount => 'Indemnité repas/jour';

  @override
  String get taxSimComparison => 'ACTUEL VS SIMULÃ‰';

  @override
  String get taxSimNetTakeHome => 'Net Ã  percevoir';

  @override
  String get taxSimIRS => 'Retenue d\'impÃ´t';

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

  @override
  String get expenseDefaultBudget => 'BUDGET DE BASE';

  @override
  String expenseOverrideActive(String month, String amount) {
    return 'Ajusté pour $month: $amount';
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
      'Le statut matrimonial et les personnes Ã  charge affectent votre tranche d\'imposition, ce qui détermine le montant d\'impÃ´t retenu sur votre salaire.';

  @override
  String get settingsSalariesTip =>
      'Le salaire brut est utilisé pour calculer le revenu net après impÃ´ts et sécurité sociale. Ajoutez plusieurs salaires si le ménage a plus d\'un revenu.';

  @override
  String get settingsExpensesTip =>
      'Définissez le budget mensuel pour chaque catégorie. Vous pouvez le modifier pour des mois spécifiques dans la vue détaillée.';

  @override
  String get settingsMealHouseholdTip =>
      'Nombre de personnes qui mangent Ã  la maison. Cela adapte les recettes et les portions dans votre plan de repas.';

  @override
  String get settingsHouseholdTip =>
      'Invitez des membres de la famille Ã  partager les données budgétaires entre appareils. Tous les membres voient les mêmes dépenses et budgets.';

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
  String get subscriptionTrialExpired => 'Essai expiré';

  @override
  String get subscriptionUpgrade => 'Mettre Ã  jour';

  @override
  String get subscriptionSeePlans => 'Voir les Plans';

  @override
  String get subscriptionCurrentPlan => 'Plan Actuel';

  @override
  String get subscriptionManage => 'Gérer l\'Abonnement';

  @override
  String subscriptionFeatureExplored(int count, int total) {
    return '$count/$total fonctionnalités explorées';
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
  String get subscriptionKeepData => 'Conserver Vos Données';

  @override
  String get subscriptionCancelAnytime => 'Annulez Ã  tout moment';

  @override
  String get subscriptionNoHiddenFees => 'Sans frais cachés';

  @override
  String get subscriptionMostPopular => 'Le Plus Populaire';

  @override
  String subscriptionYearlySave(int percent) {
    return 'économisez $percent%';
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
  String get subscriptionBilledYearly => 'facturé annuellement';

  @override
  String get subscriptionStartPremium => 'Commencer Premium';

  @override
  String get subscriptionStartFamily => 'Commencer Famille';

  @override
  String get subscriptionContinueFree => 'Continuer Gratuit';

  @override
  String get subscriptionTrialEnded => 'Votre période d\'essai est terminée';

  @override
  String get subscriptionChoosePlan =>
      'Choisissez un plan pour conserver toutes vos données et fonctionnalités';

  @override
  String get subscriptionUnlockPower =>
      'Débloquez toute la puissance de votre budget';

  @override
  String subscriptionRequiresPaid(String feature) {
    return '$feature nécessite un abonnement payant';
  }

  @override
  String subscriptionTryFeature(String feature) {
    return 'Essayez $feature';
  }

  @override
  String subscriptionExplore(String feature) {
    return 'Explorer $feature';
  }

  @override
  String get subtitleBatchCooking =>
      'Suggère des recettes préparables Ã  l\'avance pour plusieurs repas';

  @override
  String get subtitleReuseLeftovers =>
      'Planifie des repas qui réutilisent les ingrédients des jours précédents';

  @override
  String get subtitleMinimizeWaste =>
      'Priorise l\'utilisation de tous les ingrédients achetés avant leur expiration';

  @override
  String get subtitleMealTypeInclude =>
      'Inclure ce repas dans votre plan hebdomadaire';

  @override
  String get subtitleShowHeroCard => 'Votre résumé de liquidité nette en haut';

  @override
  String get subtitleShowStressIndex =>
      'Score (0-100) mesurant la pression des dépenses vs les revenus';

  @override
  String get subtitleShowMonthReview =>
      'Résumé comparatif de ce mois avec les précédents';

  @override
  String get subtitleShowUpcomingBills =>
      'Dépenses récurrentes dans les 30 prochains jours';

  @override
  String get subtitleShowSummaryCards =>
      'Revenus, déductions, dépenses et taux d\'épargne';

  @override
  String get subtitleShowBudgetVsActual =>
      'Comparaison cÃ´te Ã  cÃ´te par catégorie de dépense';

  @override
  String get subtitleShowExpensesBreakdown =>
      'Graphique circulaire des dépenses par catégorie';

  @override
  String get subtitleShowSavingsGoals =>
      'Progression vers vos objectifs d\'épargne';

  @override
  String get subtitleShowTaxDeductions =>
      'Déductions fiscales éligibles estimées cette année';

  @override
  String get subtitleShowBudgetStreaks =>
      'Combien de mois consécutifs vous êtes resté dans le budget';

  @override
  String get subtitleShowQuickActions =>
      'Raccourcis pour ajouter des dépenses, naviguer et plus';

  @override
  String get subtitleShowPurchaseHistory =>
      'Achats récents de la liste de courses et coÃ»ts';

  @override
  String get subtitleShowCharts =>
      'Graphiques de tendance du budget, des dépenses et des revenus';

  @override
  String get subtitleChartExpensesPie =>
      'Répartition des dépenses par catégorie';

  @override
  String get subtitleChartIncomeVsExpenses =>
      'Revenus mensuels comparés aux dépenses totales';

  @override
  String get subtitleChartDeductions =>
      'Ventilation des dépenses déductibles d\'impÃ´ts';

  @override
  String get subtitleChartNetIncome => 'Tendance du revenu net au fil du temps';

  @override
  String get subtitleChartSavingsRate =>
      'Pourcentage de revenus épargnés chaque mois';

  @override
  String get helperCountry =>
      'Détermine le système fiscal, la devise et les taux de sécurité sociale';

  @override
  String get helperLanguage =>
      'Remplacer la langue du système. \"Système\" suit le réglage de votre appareil';

  @override
  String get helperMaritalStatus =>
      'Affecte le calcul de la tranche d\'imposition';

  @override
  String get helperMealObjective =>
      'Définit le régime alimentaire : omnivore, végétarien, pescatarien, etc.';

  @override
  String get helperSodiumPreference =>
      'Filtre les recettes par niveau de teneur en sodium';

  @override
  String subtitleDietaryRestriction(String ingredient) {
    return 'Exclut les recettes contenant $ingredient';
  }

  @override
  String subtitleExcludedProtein(String protein) {
    return 'Supprimer $protein de toutes les suggestions de repas';
  }

  @override
  String subtitleKitchenEquipment(String equipment) {
    return 'Active les recettes nécessitant $equipment';
  }

  @override
  String get helperVeggieDays =>
      'Nombre de jours entièrement végétariens par semaine';

  @override
  String get helperFishDays => 'Recommandé : 2-3 fois par semaine';

  @override
  String get helperLegumeDays => 'Recommandé : 2-3 fois par semaine';

  @override
  String get helperRedMeatDays => 'Recommandé : maximum 2 fois par semaine';

  @override
  String get helperMaxPrepTime =>
      'Temps de cuisson maximum pour les repas en semaine (minutes)';

  @override
  String get helperMaxComplexity =>
      'Niveau de difficulté des recettes pour les jours de semaine';

  @override
  String get helperWeekendPrepTime =>
      'Temps de cuisson maximum pour les repas du week-end (minutes)';

  @override
  String get helperWeekendComplexity =>
      'Niveau de difficulté des recettes pour le week-end';

  @override
  String get helperMaxBatchDays =>
      'Combien de jours un repas cuisiné en lot peut être réutilisé';

  @override
  String get helperNewIngredients =>
      'Limite le nombre de nouveaux ingrédients par semaine';

  @override
  String get helperGrossSalary => 'Salaire total avant impÃ´ts et déductions';

  @override
  String get helperExemptIncome =>
      'Revenus supplémentaires non soumis Ã  l\'impÃ´t (ex. : subventions)';

  @override
  String get helperMealAllowance =>
      'Indemnité repas journalière de votre employeur';

  @override
  String get helperWorkingDays =>
      'Typique : 22. Affecte le calcul de l\'indemnité repas';

  @override
  String get helperSalaryLabel =>
      'Un nom pour identifier cette source de revenus';

  @override
  String get helperExpenseAmount =>
      'Montant mensuel budgété pour cette catégorie';

  @override
  String get helperCalorieTarget =>
      'Recommandé : 2000-2500 kcal pour les adultes';

  @override
  String get helperProteinTarget => 'Recommandé : 50-70g pour les adultes';

  @override
  String get helperFiberTarget => 'Recommandé : 25-30g pour les adultes';

  @override
  String get infoStressIndex =>
      'Compare les dépenses réelles Ã  votre budget. Plages de scores :\n\n0-30 : Confortable - dépenses bien dans le budget\n30-60 : Modéré - approche des limites du budget\n60-100 : Critique - les dépenses dépassent significativement le budget';

  @override
  String get infoBudgetStreak =>
      'Mois consécutifs oÃ¹ vos dépenses totales sont restées dans le budget total.';

  @override
  String get infoUpcomingBills =>
      'Affiche les dépenses récurrentes dans les 30 prochains jours basées sur vos dépenses mensuelles.';

  @override
  String get infoSalaryBreakdown =>
      'Montre comment votre salaire brut est réparti en impÃ´t sur le revenu, cotisations de sécurité sociale, revenu net et indemnité repas.';

  @override
  String get infoBudgetVsActual =>
      'Compare ce que vous avez budgété par catégorie avec ce que vous avez réellement dépensé. Vert signifie sous le budget, rouge signifie au-dessus.';

  @override
  String get infoSavingsGoals =>
      'Progression vers chaque objectif d\'épargne basée sur les contributions effectuées.';

  @override
  String get infoTaxDeductions =>
      'Dépenses déductibles estimées (santé, éducation, logement). Ce sont uniquement des estimations - consultez un professionnel fiscal pour des valeurs précises.';

  @override
  String get infoPurchaseHistory =>
      'Total dépensé en achats de la liste de courses ce mois-ci.';

  @override
  String get infoExpensesBreakdown =>
      'Ventilation visuelle de vos dépenses par catégorie pour le mois en cours.';

  @override
  String get infoCharts =>
      'Données de tendance au fil du temps. Appuyez sur un graphique pour une vue détaillée.';

  @override
  String get infoExpenseTrackerSummary =>
      'Budgété = vos dépenses mensuelles prévues. Réel = ce que vous avez dépensé jusqu\'ici. Restant = budget moins réel.';

  @override
  String get infoExpenseTrackerProgress =>
      'Vert : en dessous de 75% du budget. Jaune : 75-100%. Rouge : au-dessus du budget.';

  @override
  String get infoExpenseTrackerFilter =>
      'Filtrez les dépenses par texte, catégorie ou plage de dates.';

  @override
  String get infoSavingsProjection =>
      'Basé sur vos contributions mensuelles moyennes. \"En bonne voie\" signifie que votre rythme actuel atteint l\'objectif Ã  temps. \"En retard\" signifie que vous devez augmenter vos contributions.';

  @override
  String get infoSavingsRequired =>
      'Le montant que vous devez épargner chaque mois Ã  partir de maintenant pour atteindre votre objectif dans les délais.';

  @override
  String get infoCoachModes =>
      'Eco : gratuit, sans mémoire de conversation.\nPlus : 1 crédit par message, retient les 5 derniers messages.\nPro : 2 crédits par message, mémoire de conversation complète.';

  @override
  String get infoCoachCredits =>
      'Les crédits sont utilisés pour les modes Plus et Pro. Vous recevez des crédits de démarrage Ã  l\'inscription. Le mode Eco est toujours gratuit.';

  @override
  String get helperWizardGrossSalary =>
      'Votre salaire mensuel total avant impÃ´ts';

  @override
  String get helperWizardMealAllowance =>
      'Indemnité repas journalière de l\'employeur (le cas échéant)';

  @override
  String get helperWizardRent => 'Paiement mensuel de logement';

  @override
  String get helperWizardGroceries =>
      'Budget mensuel alimentation et produits ménagers';

  @override
  String get helperWizardTransport =>
      'CoÃ»ts mensuels de transport (carburant, transports en commun, etc.)';

  @override
  String get helperWizardUtilities => 'Ã‰lectricité, eau et gaz mensuels';

  @override
  String get helperWizardTelecom => 'Internet, téléphone et TV mensuels';

  @override
  String get savingsGoalHowItWorksTitle => 'Comment ça marche ?';

  @override
  String get savingsGoalHowItWorksStep1 =>
      'Créez un objectif avec un nom et le montant Ã  atteindre (ex : \"Vacances â€” 2 000 â‚¬\").';

  @override
  String get savingsGoalHowItWorksStep2 =>
      'Définissez éventuellement une date limite comme référence.';

  @override
  String get savingsGoalHowItWorksStep3 =>
      'Chaque fois que vous économisez, touchez l\'objectif et enregistrez une contribution avec le montant et la date.';

  @override
  String get savingsGoalHowItWorksStep4 =>
      'Suivez votre progression : la barre montre combien vous avez épargné et la projection estime quand vous atteindrez votre objectif.';

  @override
  String get savingsGoalDashboardHint =>
      'Touchez un objectif pour voir les détails et enregistrer des contributions.';

  @override
  String get rateLimitMessage =>
      'Veuillez patienter un moment avant de réessayer';

  @override
  String get planningExportTitle => 'Exporter';

  @override
  String get planningImportTitle => 'Importer';

  @override
  String get planningExportShoppingList => 'Exporter la liste de courses';

  @override
  String get planningImportShoppingList => 'Importer la liste de courses';

  @override
  String get planningExportMealPlan => 'Exporter le plan de repas';

  @override
  String get planningImportMealPlan => 'Importer le plan de repas';

  @override
  String get planningExportPantry => 'Exporter le garde-manger';

  @override
  String get planningImportPantry => 'Importer le garde-manger';

  @override
  String get planningExportFreeformMeals => 'Exporter les repas libres';

  @override
  String get planningImportFreeformMeals => 'Importer les repas libres';

  @override
  String get planningFormatCsv => 'CSV';

  @override
  String get planningFormatJson => 'JSON';

  @override
  String get planningImportSuccess => 'Importé avec succès';

  @override
  String planningImportError(String error) {
    return 'Ã‰chec de l\'importation : $error';
  }

  @override
  String get planningExportSuccess => 'Exporté avec succès';

  @override
  String get planningDataPortability => 'Portabilité des données';

  @override
  String get planningDataPortabilityDesc =>
      'Importer et exporter des artefacts de planification';

  @override
  String get mealBudgetInsightTitle => 'Aperçu du Budget';

  @override
  String get mealBudgetStatusSafe => 'En bonne voie';

  @override
  String get mealBudgetStatusWatch => 'Attention';

  @override
  String get mealBudgetStatusOver => 'Hors budget';

  @override
  String get mealBudgetWeeklyCost => 'CoÃ»t hebdomadaire estimé';

  @override
  String get mealBudgetProjectedMonthly => 'Projection mensuelle';

  @override
  String get mealBudgetMonthlyBudget => 'Budget alimentaire mensuel';

  @override
  String get mealBudgetRemaining => 'Budget restant';

  @override
  String get mealBudgetTopExpensive => 'Repas les plus chers';

  @override
  String get mealBudgetSuggestedSwaps => 'Ã‰changes moins chers suggérés';

  @override
  String get mealBudgetViewDetails => 'Voir les détails';

  @override
  String get mealBudgetApplySwap => 'Appliquer';

  @override
  String mealBudgetSwapSavings(String amount) {
    return 'Ã‰conomisez $amount';
  }

  @override
  String get mealBudgetDailyBreakdown => 'Répartition quotidienne des coÃ»ts';

  @override
  String get mealBudgetShoppingImpact => 'Impact sur les courses';

  @override
  String get mealBudgetUniqueIngredients => 'Ingrédients uniques';

  @override
  String get mealBudgetEstShoppingCost => 'CoÃ»t estimé des courses';

  @override
  String get productUpdatesTitle => 'Mises a jour';

  @override
  String get whatsNewTab => 'Nouveautes';

  @override
  String get roadmapTab => 'Feuille de Route';

  @override
  String get noUpdatesYet => 'Pas encore de nouveautes';

  @override
  String get noRoadmapItems =>
      'Pas encore d\'elements dans la feuille de route';

  @override
  String get roadmapNow => 'Maintenant';

  @override
  String get roadmapNext => 'Ensuite';

  @override
  String get roadmapLater => 'Plus tard';

  @override
  String get productUpdatesSubtitle => 'Changelog et fonctionnalites a venir';

  @override
  String get whatsNewDialogTitle => 'Nouveautes';

  @override
  String get whatsNewDialogDismiss => 'Compris';

  @override
  String get confidenceCenterTitle => 'Centre de Confiance';

  @override
  String get confidenceSyncHealth => 'Ã‰tat de Synchronisation';

  @override
  String get confidenceDataAlerts => 'Alertes de Qualité des Données';

  @override
  String get confidenceRecommendedActions => 'Actions Recommandées';

  @override
  String get confidenceCenterSubtitle =>
      'Fraîcheur des données et santé du système';

  @override
  String get confidenceCenterTile => 'Centre de Confiance';

  @override
  String get pantryPickerTitle => 'Sélecteur de Garde-Manger';

  @override
  String get pantrySearchHint => 'Rechercher des ingrédients...';

  @override
  String get pantryTabAlwaysHave => 'Toujours en Stock';

  @override
  String get pantryTabThisWeek => 'Cette Semaine';

  @override
  String pantrySummaryLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles en garde-manger',
      one: '1 article en garde-manger',
    );
    return '$_temp0';
  }

  @override
  String get pantryEdit => 'Modifier';

  @override
  String get pantryUseWhatWeHave => 'Utiliser Ce Qu\'on A';

  @override
  String get pantryMarkAtHome => 'DéjÃ  Ã  la maison';

  @override
  String get pantryHaveIt => 'J\'en ai';

  @override
  String pantryCoverageLabel(int pct) {
    return '$pct% couvert par le garde-manger';
  }

  @override
  String get pantryStaples => 'ESSENTIELS (TOUJOURS EN STOCK)';

  @override
  String get pantryWeekly => 'GARDE-MANGER DE LA SEMAINE';

  @override
  String pantryAddedToWeekly(String name) {
    return '$name ajouté au garde-manger hebdomadaire';
  }

  @override
  String pantryRemovedFromList(String name) {
    return '$name retiré de la liste (déjÃ  Ã  la maison)';
  }

  @override
  String pantryMarkedAtHome(String name) {
    return '$name marqué comme déjÃ  Ã  la maison';
  }

  @override
  String get householdActivityTitle => 'Activité du Foyer';

  @override
  String get householdActivityFilterAll => 'Tout';

  @override
  String get householdActivityFilterShopping => 'Courses';

  @override
  String get householdActivityFilterMeals => 'Repas';

  @override
  String get householdActivityFilterExpenses => 'Dépenses';

  @override
  String get householdActivityFilterPantry => 'Garde-manger';

  @override
  String get householdActivityFilterSettings => 'Paramètres';

  @override
  String get householdActivityEmpty => 'Aucune activité';

  @override
  String get householdActivityEmptyMessage =>
      'Les actions partagées de votre foyer apparaîtront ici.';

  @override
  String get householdActivityToday => 'AUJOURD\'HUI';

  @override
  String get householdActivityYesterday => 'HIER';

  @override
  String get householdActivityThisWeek => 'CETTE SEMAINE';

  @override
  String get householdActivityOlder => 'PLUS ANCIEN';

  @override
  String get householdActivityJustNow => 'Ã€ l\'instant';

  @override
  String householdActivityMinutesAgo(int count) {
    return 'il y a $count min';
  }

  @override
  String householdActivityHoursAgo(int count) {
    return 'il y a ${count}h';
  }

  @override
  String householdActivityDaysAgo(int count) {
    return 'il y a ${count}j';
  }

  @override
  String householdActivityAddedBy(String name) {
    return 'Ajouté par $name';
  }

  @override
  String householdActivityRemovedBy(String name) {
    return 'Supprimé par $name';
  }

  @override
  String householdActivitySwappedBy(String name) {
    return 'Ã‰changé par $name';
  }

  @override
  String householdActivityUpdatedBy(String name) {
    return 'Mis Ã  jour par $name';
  }

  @override
  String householdActivityCheckedBy(String name) {
    return 'Coché par $name';
  }

  @override
  String get barcodeScanTitle => 'Scanner Code-barres';

  @override
  String get barcodeScanHint => 'Pointez la camera vers un code-barres';

  @override
  String get barcodeScanTooltip => 'Scanner code-barres';

  @override
  String get barcodeProductFound => 'Produit Trouve';

  @override
  String get barcodeProductNotFound => 'Produit Non Trouve';

  @override
  String get barcodeLabel => 'Code-barres';

  @override
  String get barcodeAddToList => 'Ajouter a la Liste';

  @override
  String get barcodeManualEntry =>
      'Aucun produit trouve. Saisissez les details manuellement :';

  @override
  String get barcodeProductName => 'Nom du produit';

  @override
  String get barcodePrice => 'Prix';

  @override
  String barcodeAddedToList(String name) {
    return '$name ajoute a la liste de courses';
  }

  @override
  String get barcodeInvoiceDetected =>
      'Ceci est un code de facture, pas de produit';

  @override
  String get barcodeInvoiceAction => 'Ouvrir le Scanner de Reçus';

  @override
  String get quickAddTooltip => 'Actions rapides';

  @override
  String get quickAddExpense => 'Ajouter une dépense';

  @override
  String get quickAddShopping => 'Ajouter un article';

  @override
  String get quickOpenMeals => 'Planificateur de repas';

  @override
  String get quickOpenAssistant => 'Assistant';

  @override
  String get freeformBadge => 'Libre';

  @override
  String get freeformCreateTitle => 'Ajouter repas libre';

  @override
  String get freeformEditTitle => 'Modifier repas libre';

  @override
  String get freeformTitleLabel => 'Titre du repas';

  @override
  String get freeformTitleHint => 'ex. Restes, Pizza Ã  emporter';

  @override
  String get freeformNoteLabel => 'Note (optionnel)';

  @override
  String get freeformNoteHint => 'Détails sur ce repas';

  @override
  String get freeformCostLabel => 'CoÃ»t estimé (optionnel)';

  @override
  String get freeformTagsLabel => 'Ã‰tiquettes';

  @override
  String get freeformTagLeftovers => 'Restes';

  @override
  String get freeformTagPantryMeal => 'Garde-manger';

  @override
  String get freeformTagTakeout => 'Ã€ emporter';

  @override
  String get freeformTagQuickMeal => 'Repas rapide';

  @override
  String get freeformShoppingItemsLabel => 'Articles de courses';

  @override
  String get freeformAddItem => 'Ajouter article';

  @override
  String get freeformItemName => 'Nom de l\'article';

  @override
  String get freeformItemQuantity => 'Quantité';

  @override
  String get freeformItemUnit => 'Unité';

  @override
  String get freeformItemPrice => 'Prix est.';

  @override
  String get freeformItemStore => 'Magasin';

  @override
  String freeformShoppingItemCount(int count) {
    return '$count articles de courses';
  }

  @override
  String get freeformAddToSlot => 'Ajouter repas libre';

  @override
  String get freeformReplace => 'Remplacer par repas libre';

  @override
  String get insightsTitle => 'Analyses';

  @override
  String get insightsAnalyzeSpending => 'Analyser les depenses dans le temps';

  @override
  String get insightsTrackProgress => 'Suivre la progression de vos objectifs';

  @override
  String get insightsTaxOutcome => 'Estimer le resultat fiscal annuel';

  @override
  String get moreTitle => 'Plus';

  @override
  String get moreDetailedDashboard => 'Tableau de Bord Detaille';

  @override
  String get moreDetailedDashboardSubtitle =>
      'Ouvrir le tableau de bord financier complet';

  @override
  String get moreSavingsSubtitle =>
      'Suivre et mettre a jour la progression des objectifs';

  @override
  String get moreNotificationsSubtitle => 'Budgets, factures et rappels';

  @override
  String get moreSettingsSubtitle => 'Preferences, profil et tableau de bord';

  @override
  String get morePlanFree => 'Plan Gratuit';

  @override
  String get morePlanTrial => 'Essai Actif';

  @override
  String get morePlanPro => 'Plan Pro';

  @override
  String get morePlanFamily => 'Plan Famille';

  @override
  String get morePlanManage => 'Gerer votre plan et facturation';

  @override
  String morePlanLimits(int categories, int goals) {
    return '$categories categories • $goals objectif d\'epargne';
  }

  @override
  String moreItemsPaused(int count) {
    return '$count elements en pause';
  }

  @override
  String get moreUpgrade => 'Ameliorer →';

  @override
  String get planTitle => 'Planifier';

  @override
  String get planGrocerySubtitle => 'Parcourir produits et prix';

  @override
  String get planShoppingList => 'Liste de Courses';

  @override
  String get planShoppingSubtitle => 'Verifier et finaliser les achats';

  @override
  String get planMealSubtitle => 'Generer des plans hebdomadaires abordables';

  @override
  String coachActiveMemory(String mode, int percent) {
    return 'Memoire active : $mode ($percent%)';
  }

  @override
  String get coachCostPerMessageNote =>
      'Cout par message envoye. La reponse du coach ne consomme pas de credits.';

  @override
  String get coachExpandTip => 'Developper l\'avis';

  @override
  String get coachCollapseTip => 'Reduire l\'avis';

  @override
  String featureTryName(String name) {
    return 'Essayer $name';
  }

  @override
  String featureExploreName(String name) {
    return 'Explorer $name';
  }

  @override
  String featureRequiresPremium(String name) {
    return '$name necessite Premium';
  }

  @override
  String get featureTapToUpgrade => 'Appuyez pour ameliorer';

  @override
  String get featureNameAiCoach => 'Coach IA';

  @override
  String get featureNameMealPlanner => 'Planificateur de Repas';

  @override
  String get featureNameExpenseTracker => 'Suivi des Depenses';

  @override
  String get featureNameSavingsGoals => 'Objectifs d\'Epargne';

  @override
  String get featureNameShoppingList => 'Liste de Courses';

  @override
  String get featureNameGroceryBrowser => 'Explorateur de Produits';

  @override
  String get featureNameExportReports => 'Exporter les Rapports';

  @override
  String get featureNameTaxSimulator => 'Simulateur Fiscal';

  @override
  String get featureNameDashboard => 'Tableau de Bord';

  @override
  String get featureTagAiCoach => 'Votre conseiller financier personnel';

  @override
  String get featureTagMealPlanner => 'Economisez sur l\'alimentation';

  @override
  String get featureTagExpenseTracker => 'Sachez ou va chaque euro';

  @override
  String get featureTagSavingsGoals => 'Realisez vos reves';

  @override
  String get featureTagShoppingList => 'Achetez plus intelligemment';

  @override
  String get featureTagGroceryBrowser => 'Comparez les prix instantanement';

  @override
  String get featureTagExportReports => 'Rapports budgetaires professionnels';

  @override
  String get featureTagTaxSimulator => 'Planification fiscale multi-pays';

  @override
  String get featureTagDashboard => 'Votre apercu financier';

  @override
  String get featureDescAiCoach =>
      'Obtenez des informations personnalisees sur vos habitudes de depenses, des conseils d\'epargne et l\'optimisation du budget par IA.';

  @override
  String get featureDescMealPlanner =>
      'Planifiez des repas hebdomadaires dans votre budget. L\'IA genere des recettes selon vos preferences et besoins alimentaires.';

  @override
  String get featureDescExpenseTracker =>
      'Suivez les depenses reelles vs. budget en temps reel. Voyez ou vous depensez trop et ou vous pouvez economiser.';

  @override
  String get featureDescSavingsGoals =>
      'Definissez des objectifs d\'epargne avec des echeances, suivez les contributions et voyez les projections.';

  @override
  String get featureDescShoppingList =>
      'Creez des listes de courses partagees en temps reel. Cochez les articles en magasin, finalisez et suivez les depenses.';

  @override
  String get featureDescGroceryBrowser =>
      'Parcourez les produits de plusieurs magasins, comparez les prix et ajoutez les meilleures offres a votre liste.';

  @override
  String get featureDescExportReports =>
      'Exportez votre budget, depenses et resumes financiers en PDF ou CSV pour vos dossiers ou comptable.';

  @override
  String get featureDescTaxSimulator =>
      'Comparez les obligations fiscales entre pays. Parfait pour les expatries et ceux qui envisagent de demenager.';

  @override
  String get featureDescDashboard =>
      'Voyez le resume complet du budget, les graphiques et la sante financiere en un coup d\'oeil.';

  @override
  String get trialPremiumActive => 'Essai Premium Actif';

  @override
  String get trialHalfway => 'Votre essai est a mi-parcours';

  @override
  String trialDaysLeftInTrial(int count) {
    return '$count jours restants dans votre essai !';
  }

  @override
  String get trialLastDay => 'Dernier jour de votre essai gratuit !';

  @override
  String get trialSeePlans => 'Voir les Plans';

  @override
  String get trialUpgradeNow => 'Ameliorer Maintenant — Conservez Vos Donnees';

  @override
  String get trialSubtitleUrgent =>
      'Votre acces premium se termine bientot. Ameliorez pour garder le Coach IA, le Planificateur de Repas et toutes vos donnees.';

  @override
  String trialSubtitleMidFeature(String name) {
    return 'Avez-vous essaye le $name ? Profitez au maximum de votre essai !';
  }

  @override
  String get trialSubtitleMidProgress =>
      'Vous progressez bien ! Continuez a explorer les fonctionnalites premium.';

  @override
  String get trialSubtitleEarly =>
      'Vous avez un acces complet a toutes les fonctionnalites premium. Explorez tout !';

  @override
  String trialFeaturesExplored(int explored, int total) {
    return '$explored/$total fonctionnalites explorees';
  }

  @override
  String trialDaysRemaining(int count) {
    return '$count jours restants';
  }

  @override
  String trialProgressLabel(int percent) {
    return 'Progression de l\'essai $percent%';
  }

  @override
  String get featureNameAiCoachFull => 'Coach Financier IA';

  @override
  String get receiptScanTitle => 'Scanner Reçu';

  @override
  String get receiptScanQrMode => 'QR Code';

  @override
  String get receiptScanPhotoMode => 'Photo';

  @override
  String get receiptScanHint => 'Pointez la caméra vers le QR code du reçu';

  @override
  String get receiptScanPhotoHint =>
      'Positionnez le reçu et appuyez sur le bouton pour capturer';

  @override
  String get receiptScanProcessing => 'Lecture du reçuâ€¦';

  @override
  String receiptScanSuccess(String amount, String store) {
    return 'Dépense de $amount chez $store enregistrée';
  }

  @override
  String get receiptScanFailed => 'Impossible de lire le reçu';

  @override
  String get receiptScanPrompt =>
      'Courses terminées? Scannez le reçu pour enregistrer les dépenses automatiquement.';

  @override
  String get receiptMerchantUnknown => 'Commerçant inconnu';

  @override
  String receiptMerchantNamePrompt(String nif) {
    return 'Entrez le nom du magasin pour NIF $nif';
  }

  @override
  String receiptItemsMatched(int count) {
    return '$count articles associés Ã  la liste de courses';
  }

  @override
  String get quickScanReceipt => 'Scanner Reçu';

  @override
  String get receiptReviewTitle => 'Vérifier le Reçu';

  @override
  String get receiptReviewMerchant => 'Commerce';

  @override
  String get receiptReviewDate => 'Date';

  @override
  String get receiptReviewTotal => 'Total';

  @override
  String get receiptReviewCategory => 'Catégorie';

  @override
  String receiptReviewItems(int count) {
    return '$count articles détectés';
  }

  @override
  String get receiptReviewConfirm => 'Ajouter Dépense';

  @override
  String get receiptReviewRetake => 'Reprendre';

  @override
  String get receiptCameraPermissionTitle => 'Accès Caméra';

  @override
  String get receiptCameraPermissionBody =>
      'L\'accès Ã  la caméra est nécessaire pour scanner les reçus et les codes-barres.';

  @override
  String get receiptCameraPermissionAllow => 'Autoriser';

  @override
  String get receiptCameraPermissionDeny => 'Pas maintenant';

  @override
  String get receiptCameraBlockedTitle => 'Caméra Bloquée';

  @override
  String get receiptCameraBlockedBody =>
      'L\'autorisation de la caméra a été définitivement refusée. Ouvrez les paramètres pour l\'activer.';

  @override
  String get receiptCameraBlockedSettings => 'Ouvrir Paramètres';

  @override
  String groceryMarketData(String marketCode) {
    return 'Données du marché $marketCode';
  }

  @override
  String groceryStoreCoverage(int active, int total) {
    return '$active magasins actifs sur $total';
  }

  @override
  String groceryStoreFreshCount(int count) {
    return '$count frais';
  }

  @override
  String groceryStorePartialCount(int count) {
    return '$count partiel';
  }

  @override
  String groceryStoreFailedCount(int count) {
    return '$count en échec';
  }

  @override
  String get groceryHideStaleStores => 'Masquer les magasins obsolètes';

  @override
  String groceryComparisonsFreshOnly(int count) {
    return 'Affichage de $count magasin frais dans les comparaisons';
  }

  @override
  String get navHome => 'Accueil';

  @override
  String get navHomeTip => 'Résumé mensuel';

  @override
  String get navTrack => 'Dépenses';

  @override
  String get navTrackTip => 'Suivre les dépenses mensuelles';

  @override
  String get navPlan => 'Planifier';

  @override
  String get navPlanTip => 'Courses, liste et plan de repas';

  @override
  String get navPlanAndShop => 'Courses';

  @override
  String get navPlanAndShopTip => 'Liste de courses, épicerie et repas';

  @override
  String get navMore => 'Plus';

  @override
  String get navMoreTip => 'Paramètres et analyses';

  @override
  String get paywallContinueFree => 'Continuer gratuitement';

  @override
  String get paywallUpgradedPro => 'Mis Ã  jour vers Pro â€” merci !';

  @override
  String get paywallNoRestore => 'Aucun achat précédent trouvé';

  @override
  String get paywallRestoredPro => 'Abonnement Pro restauré !';

  @override
  String get subscriptionPro => 'Pro';

  @override
  String subscriptionTrialLabel(int count) {
    return 'Essai ($count jours restants)';
  }

  @override
  String get authConnectionError => 'Erreur de connexion';

  @override
  String get authRetry => 'Réessayer';

  @override
  String get authSignOut => 'Se déconnecter';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get settingsGroupAccount => 'COMPTE';

  @override
  String get settingsGroupBudget => 'BUDGET';

  @override
  String get settingsGroupPreferences => 'PRÃ‰FÃ‰RENCES';

  @override
  String get settingsGroupAdvanced => 'AVANCÃ‰';

  @override
  String get settingsManageSubscription => 'Gérer l\'abonnement';

  @override
  String get settingsAbout => 'Ã€ propos';

  @override
  String get mealShowDetails => 'Afficher les détails';

  @override
  String get mealHideDetails => 'Masquer les détails';

  @override
  String get taxSimTitularesHint =>
      'Nombre de titulaires de revenus dans le ménage';

  @override
  String get taxSimMealTypeHint =>
      'Carte: exonéré d\'impÃ´t jusqu\'Ã  la limite légale. Espèces: imposé comme revenu.';

  @override
  String get taxSimIRSFull => 'IRS (ImpÃ´t sur le Revenu) retenue';

  @override
  String get taxSimSSFull => 'SS (Sécurité Sociale)';

  @override
  String get stressZoneCritical =>
      '0â€“39: Pression financière élevée, action urgente nécessaire';

  @override
  String get stressZoneWarning =>
      '40â€“59: Quelques risques présents, améliorations recommandées';

  @override
  String get stressZoneGood =>
      '60â€“79: Finances saines, petites optimisations possibles';

  @override
  String get stressZoneExcellent =>
      '80â€“100: Position financière solide, bien gérée';

  @override
  String get projectionStressHint =>
      'Comment ce scénario de dépenses affecte votre score global de santé financière (0â€“100)';

  @override
  String get coachWelcomeTitle => 'Votre Coach Financier IA';

  @override
  String get coachWelcomeBody =>
      'Posez des questions sur votre budget, dépenses ou épargne. Le coach analyse vos données financières réelles pour des conseils personnalisés.';

  @override
  String get coachWelcomeCredits =>
      'Les crédits sont utilisés pour les modes Plus et Pro. Le mode Eco est toujours gratuit.';

  @override
  String get coachWelcomeRateLimit =>
      'Pour garantir des réponses de qualité, il y a un bref délai entre les messages.';

  @override
  String get planMealsProBadge => 'PRO';

  @override
  String get coachBuyCredits => 'Acheter des crédits';

  @override
  String get coachContinueEco => 'Continuer avec Eco';

  @override
  String get coachAchieved => 'J\'ai réussi !';

  @override
  String get coachNotYet => 'Pas encore';

  @override
  String coachCreditsAdded(int count) {
    return '+$count crédits ajoutés';
  }

  @override
  String coachPurchaseError(String error) {
    return 'Erreur d\'achat : $error';
  }

  @override
  String coachUseMode(String mode) {
    return 'Utiliser $mode';
  }

  @override
  String coachKeepMode(String mode) {
    return 'Garder $mode';
  }

  @override
  String savingsGoalSaveError(String error) {
    return 'Erreur lors de la sauvegarde : $error';
  }

  @override
  String savingsGoalDeleteError(String error) {
    return 'Erreur lors de la suppression : $error';
  }

  @override
  String savingsGoalUpdateError(String error) {
    return 'Erreur lors de la mise Ã  jour : $error';
  }

  @override
  String get settingsSubscription => 'Abonnement';

  @override
  String get settingsSubscriptionFree => 'Gratuit';

  @override
  String settingsActiveCategoriesCount(int active, int total) {
    return 'Catégories Actives ($active sur $total)';
  }

  @override
  String get settingsPausedCategories => 'Catégories en Pause';

  @override
  String get settingsOpenDashboard => 'Ouvrir le Tableau de Bord Détaillé';

  @override
  String get settingsAssistantGroup => 'ASSISTANT';

  @override
  String get settingsAiCoach => 'Coach IA';

  @override
  String get setupWizardSubsidyLabel => 'SUBVENTIONS';

  @override
  String get setupWizardPerDay => '/jour';

  @override
  String get configurationError => 'Erreur de Configuration';

  @override
  String get confidenceAllHealthy =>
      'Tous les systèmes fonctionnent. Aucune action requise.';

  @override
  String get confidenceNoAlerts => 'Aucune alerte. Tout est en ordre.';

  @override
  String get onbSwipeHint => 'Glissez pour continuer';

  @override
  String onbSlideOf(int current, int total) {
    return 'Diapositive $current sur $total';
  }

  @override
  String get expenseTrendsChartLabel =>
      'Graphique des tendances de dépenses montrant le budget par rapport aux dépenses réelles';

  @override
  String get customCategories => 'Catégories';

  @override
  String get customCategoryAdd => 'Ajouter Catégorie';

  @override
  String get customCategoryEdit => 'Modifier Catégorie';

  @override
  String get customCategoryDelete => 'Supprimer Catégorie';

  @override
  String get customCategoryDeleteConfirm => 'Supprimer cette catégorie ?';

  @override
  String get customCategoryName => 'Nom de catégorie';

  @override
  String get customCategoryIcon => 'IcÃ´ne';

  @override
  String get customCategoryColor => 'Couleur';

  @override
  String get customCategoryEmpty => 'Aucune catégorie personnalisée';

  @override
  String get customCategorySaved => 'Catégorie enregistrée';

  @override
  String get customCategoryInUse => 'Catégorie en cours d\'utilisation';

  @override
  String get customCategoryPredefinedHint =>
      'Catégories prédéfinies utilisées dans l\'application';

  @override
  String get customCategoryDefault => 'Prédéfinie';

  @override
  String get expenseLocationPermissionDenied =>
      'Autorisation de localisation refusée';

  @override
  String get expenseAttachPhoto => 'Joindre une photo';

  @override
  String get expenseAttachCamera => 'Appareil photo';

  @override
  String get expenseAttachGallery => 'Galerie';

  @override
  String get expenseAttachUploadFailed =>
      'Ã‰chec du téléchargement des pièces jointes. Vérifiez votre connexion.';

  @override
  String get expenseExtras => 'Extras';

  @override
  String get expenseLocationDetect => 'Détecter la position';

  @override
  String get biometricLockTitle => 'Verrouillage de l\'app';

  @override
  String get biometricLockSubtitle =>
      'Exiger l\'authentification Ã  l\'ouverture de l\'application';

  @override
  String get biometricPrompt => 'Authentifiez-vous pour continuer';

  @override
  String get biometricReason =>
      'Vérifiez votre identité pour déverrouiller l\'application';

  @override
  String get biometricRetry => 'Réessayer';

  @override
  String get notifDailyExpenseReminder => 'Rappel quotidien des dépenses';

  @override
  String get notifDailyExpenseReminderDesc =>
      'Vous rappelle d\'enregistrer les dépenses du jour';

  @override
  String get notifDailyExpenseTitle => 'N\'oubliez pas vos dépenses !';

  @override
  String get notifDailyExpenseBody =>
      'Prenez un moment pour enregistrer les dépenses d\'aujourd\'hui';

  @override
  String get settingsSalaryLabelHint => 'ex : Emploi principal, Freelance';

  @override
  String get settingsExpenseNameLabel => 'NOM DE LA DÃ‰PENSE';

  @override
  String get settingsCategoryLabel => 'CATÃ‰GORIE';

  @override
  String get settingsMonthlyBudgetLabel => 'BUDGET MENSUEL';

  @override
  String get expenseLocationSearch => 'Rechercher';

  @override
  String get expenseLocationSearchHint => 'Rechercher une adresse...';

  @override
  String get dashboardBurnRateTitle => 'Vitesse de Dépense';

  @override
  String get dashboardBurnRateSubtitle =>
      'Moyenne quotidienne vs budget disponible';

  @override
  String get dashboardBurnRateOnTrack => 'En bonne voie';

  @override
  String get dashboardBurnRateOver => 'Au-dessus du rythme';

  @override
  String get dashboardBurnRateDailyAvg => 'MOY./JOUR';

  @override
  String get dashboardBurnRateAllowance => 'DISP./JOUR';

  @override
  String get dashboardBurnRateDaysLeft => 'JOURS RESTANTS';

  @override
  String get dashboardTopCategoriesTitle => 'Top Catégories';

  @override
  String get dashboardTopCategoriesSubtitle =>
      'Catégories les plus dépensières ce mois';

  @override
  String get dashboardCashFlowTitle => 'Prévision de Trésorerie';

  @override
  String get dashboardCashFlowSubtitle =>
      'Solde projeté jusqu\'Ã  la fin du mois';

  @override
  String get dashboardCashFlowProjectedSpend => 'DÃ‰PENSES PROJETÃ‰ES';

  @override
  String get dashboardCashFlowEndOfMonth => 'FIN DU MOIS';

  @override
  String dashboardCashFlowPendingBills(String amount) {
    return 'Factures en attente : $amount';
  }

  @override
  String get dashboardSavingsRateTitle => 'Taux d\'Ã‰pargne';

  @override
  String get dashboardSavingsRateSubtitle => 'Pourcentage du revenu épargné';

  @override
  String dashboardSavingsRateSaved(String amount) {
    return 'Ã‰pargné ce mois : $amount';
  }

  @override
  String get dashboardCoachInsightTitle => 'Conseil Financier';

  @override
  String get dashboardCoachInsightSubtitle =>
      'Suggestion personnalisée de l\'assistant financier';

  @override
  String get dashboardCoachLowSavings =>
      'Votre taux d\'épargne est inférieur Ã  10%. Identifiez une dépense Ã  réduire ce mois.';

  @override
  String get dashboardCoachHighSpending =>
      'Les dépenses approchent vos revenus. Révisez les dépenses non essentielles.';

  @override
  String get dashboardCoachGoodSavings =>
      'Excellent ! Vous épargnez plus de 20%. Continuez ainsi !';

  @override
  String get dashboardCoachGeneral =>
      'Appuyez pour des analyses personnalisées de votre budget.';

  @override
  String get dashGroupInsights => 'Analyses';

  @override
  String get dashReorderHint => 'Glissez pour réorganiser les cartes';

  @override
  String get settingsSalarySummaryGross => 'Brut';

  @override
  String get settingsSalarySummaryNet => 'Net';

  @override
  String get settingsDeductionIrs => 'IR';

  @override
  String get settingsDeductionSs => 'SS';

  @override
  String get settingsDeductionMeal => 'Repas';

  @override
  String settingsMealMonthlyTotal(String amount) {
    return 'Total mensuel : $amount';
  }

  @override
  String get mealSubstituteIngredient => 'Remplacer l\'ingrédient';

  @override
  String mealSubstituteTitle(String name) {
    return 'Remplacer $name';
  }

  @override
  String mealSubstitutionApplied(String oldName, String newName) {
    return '$oldName remplacé par $newName';
  }

  @override
  String get mealSubstitutionAdapting => 'Adaptation de la recette...';

  @override
  String get mealPlanWithPantry => 'Planifier avec ce que j\'ai';

  @override
  String get mealPantrySelectTitle =>
      'Sélectionner les ingrédients du garde-manger';

  @override
  String get mealPantrySelectHint =>
      'Choisissez les ingrédients que vous avez chez vous';

  @override
  String mealPantrySelected(int count) {
    return '$count sélectionnés';
  }

  @override
  String get mealPantryApply => 'Appliquer et générer';

  @override
  String get mealTasteProfileBoost => 'Profil de goÃ»t appliqué';

  @override
  String get mealPlanUndoMessage => 'Plan régénéré avec succès';

  @override
  String get mealPlanUndoAction => 'Annuler';

  @override
  String get mealActiveTime => 'actif';

  @override
  String get mealPassiveTime => 'four/attente';

  @override
  String get mealOptimizeMacros => 'Optimiser macros';

  @override
  String mealSwapSuggestion(String current, String suggested) {
    return 'Remplacer $current par $suggested';
  }

  @override
  String mealSwapReason(String reason) {
    return 'Raison : $reason';
  }

  @override
  String get mealApplySwap => 'Appliquer';

  @override
  String get mealSwapSameType => 'Même type';

  @override
  String get mealSwapAllTypes => 'Tous les types';

  @override
  String get pantryManagerTitle => 'Garde-manger';

  @override
  String get pantryManagerSave => 'Enregistrer';

  @override
  String get pantryLowStock => 'Stock faible';

  @override
  String get pantryDepleted => 'Ã‰puisé';

  @override
  String get pantryRestock => 'Réapprovisionner';

  @override
  String get pantryQuantity => 'Quantité';

  @override
  String get nutritionDashboardTitle => 'Nutrition Hebdomadaire';

  @override
  String get nutritionCalories => 'Calories';

  @override
  String get nutritionProtein => 'Protéines';

  @override
  String get nutritionCarbs => 'Glucides';

  @override
  String get nutritionFat => 'Lipides';

  @override
  String get nutritionFiber => 'Fibres';

  @override
  String get nutritionTopProteins => 'Top protéines';

  @override
  String get nutritionDailyAvg => 'Moyenne quotidienne';

  @override
  String get mealWasteEstimate => 'Gaspillage estimé';

  @override
  String mealWasteExcess(String qty, String unit) {
    return '$qty $unit en excès';
  }

  @override
  String mealWasteSuggestion(String ingredient) {
    return 'Envisagez de doubler cette recette pour utiliser $ingredient';
  }

  @override
  String mealWasteCost(String cost) {
    return '~$cost gaspillage';
  }

  @override
  String groceryStorePartialFallback(String storeName) {
    return '$storeName a des donnees partielles — les prix peuvent etre obsoletes';
  }

  @override
  String groceryStoreFailedFallback(String storeName) {
    return '$storeName est indisponible — exclue des comparaisons';
  }

  @override
  String get groceryStoreFreshLabel => 'A jour';

  @override
  String get groceryStoreStaleLabel => 'Obsolete';

  @override
  String get groceryStorePartialLabel => 'Partiel';

  @override
  String get groceryStoreFailedLabel => 'Indisponible';

  @override
  String groceryStoreUpdatedHoursAgo(int hours) {
    return 'Mis a jour il y a ${hours}h';
  }

  @override
  String groceryStoreUpdatedDaysAgo(int days) {
    return 'Mis a jour il y a ${days}d';
  }

  @override
  String get upgradeToPro => 'Passer a Pro';

  @override
  String get createAsPaused => 'Créer en pause';

  @override
  String get categoryLimitReached => 'Limite de catégories atteinte';

  @override
  String get savingsGoalLimitReached =>
      'Limite d\'objectifs d\'épargne atteinte';

  @override
  String get limitSwapActive => 'Échanger l\'active';

  @override
  String get limitChooseActiveGoal => 'Choisir l\'objectif actif';

  @override
  String get errorBoundarySomethingWentWrong => 'Une erreur est survenue';

  @override
  String get errorBoundaryDescription =>
      'Cette section a rencontré une erreur.\nLe reste de l\'application n\'est pas affecté.';

  @override
  String get retry => 'Réessayer';

  @override
  String get filter => 'Filtre';

  @override
  String get paywallFree => 'Gratuit';

  @override
  String get paywallStartPro => 'Démarrer Pro';

  @override
  String get paywallBestValue => 'Meilleur rapport qualité-prix';

  @override
  String get complexityEasy => 'Facile';

  @override
  String get complexityPro => 'Pro';
}
