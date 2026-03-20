import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// Bottom nav label for budget tab
  ///
  /// In pt, this message translates to:
  /// **'OrÃ§amento'**
  String get navBudget;

  /// Bottom nav label for grocery tab
  ///
  /// In pt, this message translates to:
  /// **'Supermercado'**
  String get navGrocery;

  /// Bottom nav label for shopping list tab
  ///
  /// In pt, this message translates to:
  /// **'Lista'**
  String get navList;

  /// Bottom nav label for AI coach tab
  ///
  /// In pt, this message translates to:
  /// **'Coach'**
  String get navCoach;

  /// Bottom nav label for meal planner tab
  ///
  /// In pt, this message translates to:
  /// **'RefeiÃ§Ãµes'**
  String get navMeals;

  /// Tooltip for budget nav item
  ///
  /// In pt, this message translates to:
  /// **'Resumo do orÃ§amento mensal'**
  String get navBudgetTooltip;

  /// Tooltip for grocery nav item
  ///
  /// In pt, this message translates to:
  /// **'CatÃ¡logo de produtos'**
  String get navGroceryTooltip;

  /// Tooltip for shopping list nav item
  ///
  /// In pt, this message translates to:
  /// **'Lista de compras'**
  String get navListTooltip;

  /// Tooltip for coach nav item
  ///
  /// In pt, this message translates to:
  /// **'Coach financeiro com IA'**
  String get navCoachTooltip;

  /// Tooltip for meals nav item
  ///
  /// In pt, this message translates to:
  /// **'Planeador de refeiÃ§Ãµes'**
  String get navMealsTooltip;

  /// App title shown in app bar
  ///
  /// In pt, this message translates to:
  /// **'OrÃ§amento Mensal'**
  String get appTitle;

  /// Generic loading text
  ///
  /// In pt, this message translates to:
  /// **'A carregar...'**
  String get loading;

  /// Loading text shown on app startup
  ///
  /// In pt, this message translates to:
  /// **'A carregar a aplicaÃ§Ã£o'**
  String get loadingApp;

  /// Cancel button label
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Confirm button label
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// Close button label
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// Save button label
  ///
  /// In pt, this message translates to:
  /// **'Guardar'**
  String get save;

  /// Delete button label
  ///
  /// In pt, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// Clear button label
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get clear;

  /// Error message when saving a purchase fails
  ///
  /// In pt, this message translates to:
  /// **'Erro ao guardar compra: {error}'**
  String errorSavingPurchase(String error);

  /// Filter chip label
  ///
  /// In pt, this message translates to:
  /// **'Filtrar por {label}'**
  String filterBy(String label);

  /// Accessibility label for adding item to shopping list
  ///
  /// In pt, this message translates to:
  /// **'Adicionar {name} Ã  lista'**
  String addToList(String name);

  /// Marital status: single
  ///
  /// In pt, this message translates to:
  /// **'Solteiro(a)'**
  String get enumMaritalSolteiro;

  /// Marital status: married
  ///
  /// In pt, this message translates to:
  /// **'Casado(a)'**
  String get enumMaritalCasado;

  /// Marital status: domestic partnership
  ///
  /// In pt, this message translates to:
  /// **'Uniao de Facto'**
  String get enumMaritalUniaoFacto;

  /// Marital status: divorced
  ///
  /// In pt, this message translates to:
  /// **'Divorciado(a)'**
  String get enumMaritalDivorciado;

  /// Marital status: widowed
  ///
  /// In pt, this message translates to:
  /// **'Viuvo(a)'**
  String get enumMaritalViuvo;

  /// Subsidy mode: no twelfths
  ///
  /// In pt, this message translates to:
  /// **'Sem duodÃ©cimos'**
  String get enumSubsidyNone;

  /// Subsidy mode: full twelfths
  ///
  /// In pt, this message translates to:
  /// **'Com duodÃ©cimos'**
  String get enumSubsidyFull;

  /// Subsidy mode: half twelfths
  ///
  /// In pt, this message translates to:
  /// **'50% duodÃ©cimos'**
  String get enumSubsidyHalf;

  /// Subsidy mode short label: none
  ///
  /// In pt, this message translates to:
  /// **'Sem'**
  String get enumSubsidyNoneShort;

  /// Subsidy mode short label: full
  ///
  /// In pt, this message translates to:
  /// **'Com'**
  String get enumSubsidyFullShort;

  /// Subsidy mode short label: half
  ///
  /// In pt, this message translates to:
  /// **'50%'**
  String get enumSubsidyHalfShort;

  /// Meal allowance type: none
  ///
  /// In pt, this message translates to:
  /// **'Sem'**
  String get enumMealAllowanceNone;

  /// Meal allowance type: card
  ///
  /// In pt, this message translates to:
  /// **'Cartao'**
  String get enumMealAllowanceCard;

  /// Meal allowance type: cash
  ///
  /// In pt, this message translates to:
  /// **'Com base'**
  String get enumMealAllowanceCash;

  /// Expense category: telecommunications
  ///
  /// In pt, this message translates to:
  /// **'TelecomunicaÃ§Ãµes'**
  String get enumCatTelecomunicacoes;

  /// Expense category: energy
  ///
  /// In pt, this message translates to:
  /// **'Energia'**
  String get enumCatEnergia;

  /// Expense category: water
  ///
  /// In pt, this message translates to:
  /// **'Ãgua'**
  String get enumCatAgua;

  /// Expense category: food
  ///
  /// In pt, this message translates to:
  /// **'AlimentaÃ§Ã£o'**
  String get enumCatAlimentacao;

  /// Expense category: education
  ///
  /// In pt, this message translates to:
  /// **'EducaÃ§Ã£o'**
  String get enumCatEducacao;

  /// Expense category: housing
  ///
  /// In pt, this message translates to:
  /// **'HabitaÃ§Ã£o'**
  String get enumCatHabitacao;

  /// Expense category: transport
  ///
  /// In pt, this message translates to:
  /// **'Transportes'**
  String get enumCatTransportes;

  /// Expense category: health
  ///
  /// In pt, this message translates to:
  /// **'SaÃºde'**
  String get enumCatSaude;

  /// Expense category: leisure
  ///
  /// In pt, this message translates to:
  /// **'Lazer'**
  String get enumCatLazer;

  /// Expense category: other
  ///
  /// In pt, this message translates to:
  /// **'Outros'**
  String get enumCatOutros;

  /// Chart type: expenses pie
  ///
  /// In pt, this message translates to:
  /// **'Despesas por Categoria'**
  String get enumChartExpensesPie;

  /// Chart type: income vs expenses
  ///
  /// In pt, this message translates to:
  /// **'Rendimento vs Despesas'**
  String get enumChartIncomeVsExpenses;

  /// Chart type: net income
  ///
  /// In pt, this message translates to:
  /// **'Rendimento LÃ­quido'**
  String get enumChartNetIncome;

  /// Chart type: deductions
  ///
  /// In pt, this message translates to:
  /// **'Descontos (IRS + SS)'**
  String get enumChartDeductions;

  /// Chart type: savings rate
  ///
  /// In pt, this message translates to:
  /// **'Taxa de PoupanÃ§a'**
  String get enumChartSavingsRate;

  /// Meal type: breakfast
  ///
  /// In pt, this message translates to:
  /// **'Pequeno-almoÃ§o'**
  String get enumMealBreakfast;

  /// Meal type: lunch
  ///
  /// In pt, this message translates to:
  /// **'AlmoÃ§o'**
  String get enumMealLunch;

  /// Meal type: snack
  ///
  /// In pt, this message translates to:
  /// **'Lanche'**
  String get enumMealSnack;

  /// Meal type: dinner
  ///
  /// In pt, this message translates to:
  /// **'Jantar'**
  String get enumMealDinner;

  /// Meal objective: minimize cost
  ///
  /// In pt, this message translates to:
  /// **'Minimizar custo'**
  String get enumObjMinimizeCost;

  /// Meal objective: balanced health
  ///
  /// In pt, this message translates to:
  /// **'EquilÃ­brio custo/saÃºde'**
  String get enumObjBalancedHealth;

  /// Meal objective: high protein
  ///
  /// In pt, this message translates to:
  /// **'Alta proteÃ­na'**
  String get enumObjHighProtein;

  /// Meal objective: low carb
  ///
  /// In pt, this message translates to:
  /// **'Baixo carboidrato'**
  String get enumObjLowCarb;

  /// Meal objective: vegetarian
  ///
  /// In pt, this message translates to:
  /// **'Vegetariano'**
  String get enumObjVegetarian;

  /// Kitchen equipment: oven
  ///
  /// In pt, this message translates to:
  /// **'Forno'**
  String get enumEquipOven;

  /// Kitchen equipment: air fryer
  ///
  /// In pt, this message translates to:
  /// **'Air Fryer'**
  String get enumEquipAirFryer;

  /// Kitchen equipment: food processor
  ///
  /// In pt, this message translates to:
  /// **'Robot de cozinha'**
  String get enumEquipFoodProcessor;

  /// Kitchen equipment: pressure cooker
  ///
  /// In pt, this message translates to:
  /// **'Panela de pressÃ£o'**
  String get enumEquipPressureCooker;

  /// Kitchen equipment: microwave
  ///
  /// In pt, this message translates to:
  /// **'Micro-ondas'**
  String get enumEquipMicrowave;

  /// Kitchen equipment: Bimby/Thermomix
  ///
  /// In pt, this message translates to:
  /// **'Bimby / Thermomix'**
  String get enumEquipBimby;

  /// Sodium preference: no restriction
  ///
  /// In pt, this message translates to:
  /// **'Sem restriÃ§Ã£o'**
  String get enumSodiumNoRestriction;

  /// Sodium preference: reduced
  ///
  /// In pt, this message translates to:
  /// **'SÃ³dio reduzido'**
  String get enumSodiumReduced;

  /// Sodium preference: low
  ///
  /// In pt, this message translates to:
  /// **'Baixo sÃ³dio'**
  String get enumSodiumLow;

  /// Age group: 0 to 3 years
  ///
  /// In pt, this message translates to:
  /// **'0â€“3 anos'**
  String get enumAge0to3;

  /// Age group: 4 to 10 years
  ///
  /// In pt, this message translates to:
  /// **'4â€“10 anos'**
  String get enumAge4to10;

  /// Age group: teenager
  ///
  /// In pt, this message translates to:
  /// **'Adolescente'**
  String get enumAgeTeen;

  /// Age group: adult
  ///
  /// In pt, this message translates to:
  /// **'Adulto'**
  String get enumAgeAdult;

  /// Age group: senior
  ///
  /// In pt, this message translates to:
  /// **'SÃ©nior (65+)'**
  String get enumAgeSenior;

  /// Activity level: sedentary
  ///
  /// In pt, this message translates to:
  /// **'SedentÃ¡rio'**
  String get enumActivitySedentary;

  /// Activity level: moderate
  ///
  /// In pt, this message translates to:
  /// **'Moderado'**
  String get enumActivityModerate;

  /// Activity level: active
  ///
  /// In pt, this message translates to:
  /// **'Ativo'**
  String get enumActivityActive;

  /// Activity level: very active
  ///
  /// In pt, this message translates to:
  /// **'Muito ativo'**
  String get enumActivityVeryActive;

  /// Medical condition: diabetes
  ///
  /// In pt, this message translates to:
  /// **'Diabetes'**
  String get enumMedDiabetes;

  /// Medical condition: hypertension
  ///
  /// In pt, this message translates to:
  /// **'HipertensÃ£o'**
  String get enumMedHypertension;

  /// Medical condition: high cholesterol
  ///
  /// In pt, this message translates to:
  /// **'Colesterol alto'**
  String get enumMedHighCholesterol;

  /// Medical condition: gout
  ///
  /// In pt, this message translates to:
  /// **'Gota'**
  String get enumMedGout;

  /// Medical condition: IBS
  ///
  /// In pt, this message translates to:
  /// **'SÃ­ndrome do intestino irritÃ¡vel'**
  String get enumMedIbs;

  /// Stress index level: excellent
  ///
  /// In pt, this message translates to:
  /// **'Excelente'**
  String get stressExcellent;

  /// Stress index level: good
  ///
  /// In pt, this message translates to:
  /// **'Bom'**
  String get stressGood;

  /// Stress index level: warning
  ///
  /// In pt, this message translates to:
  /// **'AtenÃ§Ã£o'**
  String get stressWarning;

  /// Stress index level: critical
  ///
  /// In pt, this message translates to:
  /// **'CrÃ­tico'**
  String get stressCritical;

  /// Stress factor: savings rate
  ///
  /// In pt, this message translates to:
  /// **'Taxa de poupanÃ§a'**
  String get stressFactorSavings;

  /// Stress factor: safety margin
  ///
  /// In pt, this message translates to:
  /// **'Margem de seguranÃ§a'**
  String get stressFactorSafety;

  /// Stress factor: food budget
  ///
  /// In pt, this message translates to:
  /// **'OrÃ§amento alimentaÃ§Ã£o'**
  String get stressFactorFood;

  /// Stress factor: expense stability
  ///
  /// In pt, this message translates to:
  /// **'Estabilidade despesas'**
  String get stressFactorStability;

  /// Stability label: stable
  ///
  /// In pt, this message translates to:
  /// **'EstÃ¡vel'**
  String get stressStable;

  /// Stability label: high
  ///
  /// In pt, this message translates to:
  /// **'Elevada'**
  String get stressHigh;

  /// Percentage used label
  ///
  /// In pt, this message translates to:
  /// **'{percent}% usado'**
  String stressUsed(String percent);

  /// Not available label
  ///
  /// In pt, this message translates to:
  /// **'N/D'**
  String get stressNA;

  /// Month review insight: food budget exceeded
  ///
  /// In pt, this message translates to:
  /// **'AlimentaÃ§Ã£o excedeu o orÃ§amento em {percent}% â€” considere rever porÃ§Ãµes ou frequÃªncia de compras.'**
  String monthReviewFoodExceeded(String percent);

  /// Month review insight: expenses exceeded plan
  ///
  /// In pt, this message translates to:
  /// **'Despesas reais superaram o planeado em {amount}â‚¬ â€” ajustar valores nas definiÃ§Ãµes?'**
  String monthReviewExpensesExceeded(String amount);

  /// Month review insight: saved more than expected
  ///
  /// In pt, this message translates to:
  /// **'Poupou {amount}â‚¬ mais do que previsto â€” pode reforÃ§ar fundo de emergÃªncia.'**
  String monthReviewSavedMore(String amount);

  /// Month review insight: on track
  ///
  /// In pt, this message translates to:
  /// **'Despesas dentro do previsto. Bom controlo orÃ§amental.'**
  String get monthReviewOnTrack;

  /// Dashboard screen title
  ///
  /// In pt, this message translates to:
  /// **'OrÃ§amento Mensal'**
  String get dashboardTitle;

  /// No description provided for @dashboardViewFullReport.
  ///
  /// In pt, this message translates to:
  /// **'Ver RelatÃ³rio Completo'**
  String get dashboardViewFullReport;

  /// Stress index card title
  ///
  /// In pt, this message translates to:
  /// **'Ãndice de Tranquilidade'**
  String get dashboardStressIndex;

  /// Dashboard tension label
  ///
  /// In pt, this message translates to:
  /// **'TensÃ£o'**
  String get dashboardTension;

  /// Dashboard liquidity label
  ///
  /// In pt, this message translates to:
  /// **'Liquidez'**
  String get dashboardLiquidity;

  /// Dashboard final position label
  ///
  /// In pt, this message translates to:
  /// **'PosiÃ§Ã£o Final'**
  String get dashboardFinalPosition;

  /// Dashboard month label
  ///
  /// In pt, this message translates to:
  /// **'MÃªs'**
  String get dashboardMonth;

  /// Dashboard gross income label
  ///
  /// In pt, this message translates to:
  /// **'Bruto'**
  String get dashboardGross;

  /// Dashboard net income label
  ///
  /// In pt, this message translates to:
  /// **'LÃ­quido'**
  String get dashboardNet;

  /// Dashboard expenses label
  ///
  /// In pt, this message translates to:
  /// **'Despesas'**
  String get dashboardExpenses;

  /// Dashboard savings rate label
  ///
  /// In pt, this message translates to:
  /// **'Taxa PoupanÃ§a'**
  String get dashboardSavingsRate;

  /// Dashboard view trends button
  ///
  /// In pt, this message translates to:
  /// **'Ver evoluÃ§Ã£o'**
  String get dashboardViewTrends;

  /// Dashboard view projection button
  ///
  /// In pt, this message translates to:
  /// **'Ver projeÃ§Ã£o'**
  String get dashboardViewProjection;

  /// Dashboard subtitle label
  ///
  /// In pt, this message translates to:
  /// **'RESUMO FINANCEIRO'**
  String get dashboardFinancialSummary;

  /// Accessibility label for settings button
  ///
  /// In pt, this message translates to:
  /// **'Abrir definiÃ§Ãµes'**
  String get dashboardOpenSettings;

  /// Hero card monthly liquidity label
  ///
  /// In pt, this message translates to:
  /// **'LIQUIDEZ MENSAL'**
  String get dashboardMonthlyLiquidity;

  /// Positive balance badge text
  ///
  /// In pt, this message translates to:
  /// **'Saldo positivo'**
  String get dashboardPositiveBalance;

  /// Negative balance badge text
  ///
  /// In pt, this message translates to:
  /// **'Saldo negativo'**
  String get dashboardNegativeBalance;

  /// Accessibility label for hero card
  ///
  /// In pt, this message translates to:
  /// **'Liquidez mensal: {amount}, {status}'**
  String dashboardHeroLabel(String amount, String status);

  /// Empty state message
  ///
  /// In pt, this message translates to:
  /// **'Configure os seus dados para ver o resumo.'**
  String get dashboardConfigureData;

  /// Empty state settings button label
  ///
  /// In pt, this message translates to:
  /// **'Abrir DefiniÃ§Ãµes'**
  String get dashboardOpenSettingsButton;

  /// Summary card gross income label
  ///
  /// In pt, this message translates to:
  /// **'Rendimento Bruto'**
  String get dashboardGrossIncome;

  /// Summary card net income label
  ///
  /// In pt, this message translates to:
  /// **'Rendimento LÃ­quido'**
  String get dashboardNetIncome;

  /// Summary card meal allowance sublabel
  ///
  /// In pt, this message translates to:
  /// **'Incl. sub. alim.: {amount}'**
  String dashboardInclMealAllowance(String amount);

  /// Summary card deductions label
  ///
  /// In pt, this message translates to:
  /// **'Descontos'**
  String get dashboardDeductions;

  /// Summary card IRS and SS sublabel
  ///
  /// In pt, this message translates to:
  /// **'IRS: {irs} | SS: {ss}'**
  String dashboardIrsSs(String irs, String ss);

  /// Summary card expenses sublabel
  ///
  /// In pt, this message translates to:
  /// **'Despesas: {amount}'**
  String dashboardExpensesAmount(String amount);

  /// Salary breakdown section header
  ///
  /// In pt, this message translates to:
  /// **'DETALHE VENCIMENTOS'**
  String get dashboardSalaryDetail;

  /// Default salary label with index
  ///
  /// In pt, this message translates to:
  /// **'Vencimento {n}'**
  String dashboardSalaryN(int n);

  /// Food spending card header
  ///
  /// In pt, this message translates to:
  /// **'ALIMENTAÃ‡ÃƒO'**
  String get dashboardFood;

  /// Simulate button label
  ///
  /// In pt, this message translates to:
  /// **'Simular'**
  String get dashboardSimulate;

  /// Food card budgeted label
  ///
  /// In pt, this message translates to:
  /// **'OrÃ§ado'**
  String get dashboardBudgeted;

  /// Food card spent label
  ///
  /// In pt, this message translates to:
  /// **'Gasto'**
  String get dashboardSpent;

  /// Food card remaining label
  ///
  /// In pt, this message translates to:
  /// **'Restante'**
  String get dashboardRemaining;

  /// Food card hint when no purchases yet
  ///
  /// In pt, this message translates to:
  /// **'Finaliza uma compra na Lista para registar gastos.'**
  String get dashboardFinalizePurchaseHint;

  /// Purchase history card header
  ///
  /// In pt, this message translates to:
  /// **'HISTÃ“RICO DE COMPRAS'**
  String get dashboardPurchaseHistory;

  /// View all button label
  ///
  /// In pt, this message translates to:
  /// **'Ver tudo'**
  String get dashboardViewAll;

  /// All purchases sheet title
  ///
  /// In pt, this message translates to:
  /// **'Todas as Compras'**
  String get dashboardAllPurchases;

  /// Accessibility label for a purchase record
  ///
  /// In pt, this message translates to:
  /// **'Compra de {date}, {amount}'**
  String dashboardPurchaseLabel(String date, String amount);

  /// Product count in purchase history
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 produto} other{{count} produtos}}'**
  String dashboardProductCount(int count);

  /// Monthly expenses breakdown header
  ///
  /// In pt, this message translates to:
  /// **'DESPESAS MENSAIS'**
  String get dashboardMonthlyExpenses;

  /// Total row label
  ///
  /// In pt, this message translates to:
  /// **'Total'**
  String get dashboardTotal;

  /// Gross with subsidies label
  ///
  /// In pt, this message translates to:
  /// **'Bruto c/ duodÃ©c.'**
  String get dashboardGrossWithSubsidy;

  /// IRS with rate label
  ///
  /// In pt, this message translates to:
  /// **'IRS ({rate})'**
  String dashboardIrsRate(String rate);

  /// Social security rate label
  ///
  /// In pt, this message translates to:
  /// **'SS (11%)'**
  String get dashboardSsRate;

  /// Meal allowance label in salary breakdown
  ///
  /// In pt, this message translates to:
  /// **'Sub. AlimentaÃ§Ã£o'**
  String get dashboardMealAllowance;

  /// Exempt income label
  ///
  /// In pt, this message translates to:
  /// **'Rend. Isento'**
  String get dashboardExemptIncome;

  /// Details expand button label
  ///
  /// In pt, this message translates to:
  /// **'Detalhes'**
  String get dashboardDetails;

  /// Stress index delta vs last month
  ///
  /// In pt, this message translates to:
  /// **'{delta} vs mÃªs passado'**
  String dashboardVsLastMonth(String delta);

  /// Budget pace warning title
  ///
  /// In pt, this message translates to:
  /// **'A gastar mais rÃ¡pido que o previsto'**
  String get dashboardPaceWarning;

  /// Budget pace critical title
  ///
  /// In pt, this message translates to:
  /// **'Risco de ultrapassar orÃ§amento alimentar'**
  String get dashboardPaceCritical;

  /// Pace label in budget pace alert
  ///
  /// In pt, this message translates to:
  /// **'Ritmo'**
  String get dashboardPace;

  /// Projection label in budget pace alert
  ///
  /// In pt, this message translates to:
  /// **'ProjeÃ§Ã£o'**
  String get dashboardProjection;

  /// Budget pace comparison value
  ///
  /// In pt, this message translates to:
  /// **'{actual}â‚¬/dia vs {expected}â‚¬/dia'**
  String dashboardPaceValue(String actual, String expected);

  /// Month review card summary suffix
  ///
  /// In pt, this message translates to:
  /// **'â€” RESUMO'**
  String get dashboardSummaryLabel;

  /// Accessibility label for month review card
  ///
  /// In pt, this message translates to:
  /// **'Ver resumo do mÃªs'**
  String get dashboardViewMonthSummary;

  /// Coach screen title
  ///
  /// In pt, this message translates to:
  /// **'Coach Financeiro'**
  String get coachTitle;

  /// Coach screen subtitle
  ///
  /// In pt, this message translates to:
  /// **'IA Â· GPT-4o mini'**
  String get coachSubtitle;

  /// Coach API key required message
  ///
  /// In pt, this message translates to:
  /// **'Adiciona a tua OpenAI API key nas DefiniÃ§Ãµes para usar esta funcionalidade.'**
  String get coachApiKeyRequired;

  /// Coach analysis card title
  ///
  /// In pt, this message translates to:
  /// **'AnÃ¡lise financeira em 3 partes'**
  String get coachAnalysisTitle;

  /// Coach analysis card description
  ///
  /// In pt, this message translates to:
  /// **'Posicionamento geral Â· Factores crÃ­ticos do Ãndice de Tranquilidade Â· Oportunidade imediata. Baseado nos teus dados reais de orÃ§amento, despesas e histÃ³rico de compras.'**
  String get coachAnalysisDescription;

  /// Coach configure API key button
  ///
  /// In pt, this message translates to:
  /// **'Configurar API key nas DefiniÃ§Ãµes'**
  String get coachConfigureApiKey;

  /// Coach API key configured label
  ///
  /// In pt, this message translates to:
  /// **'API key configurada'**
  String get coachApiKeyConfigured;

  /// Coach analyze button label
  ///
  /// In pt, this message translates to:
  /// **'Analisar o meu orÃ§amento'**
  String get coachAnalyzeButton;

  /// Coach analyzing state text
  ///
  /// In pt, this message translates to:
  /// **'A analisar...'**
  String get coachAnalyzing;

  /// Coach custom analysis label
  ///
  /// In pt, this message translates to:
  /// **'AnÃ¡lise personalizada'**
  String get coachCustomAnalysis;

  /// Coach new analysis button
  ///
  /// In pt, this message translates to:
  /// **'Gerar nova anÃ¡lise'**
  String get coachNewAnalysis;

  /// Coach history section header
  ///
  /// In pt, this message translates to:
  /// **'HISTÃ“RICO'**
  String get coachHistory;

  /// Coach clear all button
  ///
  /// In pt, this message translates to:
  /// **'Limpar tudo'**
  String get coachClearAll;

  /// Coach clear history dialog title
  ///
  /// In pt, this message translates to:
  /// **'Limpar histÃ³rico'**
  String get coachClearTitle;

  /// Coach clear history dialog content
  ///
  /// In pt, this message translates to:
  /// **'Tens a certeza que queres apagar todas as anÃ¡lises guardadas?'**
  String get coachClearContent;

  /// Coach delete analysis label
  ///
  /// In pt, this message translates to:
  /// **'Eliminar anÃ¡lise'**
  String get coachDeleteLabel;

  /// Coach delete tooltip
  ///
  /// In pt, this message translates to:
  /// **'Eliminar'**
  String get coachDeleteTooltip;

  /// Empty state title in coach chat
  ///
  /// In pt, this message translates to:
  /// **'O teu coach financeiro'**
  String get coachEmptyTitle;

  /// Empty state body in coach chat
  ///
  /// In pt, this message translates to:
  /// **'Pergunta o que quiseres sobre o teu orcamento, despesas ou poupancas. Vou usar os teus dados reais para dar conselhos personalizados.'**
  String get coachEmptyBody;

  /// Quick prompt suggestion 1
  ///
  /// In pt, this message translates to:
  /// **'Onde posso cortar despesas este mes?'**
  String get coachQuickPrompt1;

  /// Quick prompt suggestion 2
  ///
  /// In pt, this message translates to:
  /// **'Como melhoro a minha poupanca?'**
  String get coachQuickPrompt2;

  /// Quick prompt suggestion 3
  ///
  /// In pt, this message translates to:
  /// **'Ajuda-me a definir um plano para 30 dias.'**
  String get coachQuickPrompt3;

  /// Composer text field hint
  ///
  /// In pt, this message translates to:
  /// **'Pergunta ao coach...'**
  String get coachComposerHint;

  /// Label for user messages
  ///
  /// In pt, this message translates to:
  /// **'Tu'**
  String get coachYou;

  /// Label for assistant messages
  ///
  /// In pt, this message translates to:
  /// **'Coach'**
  String get coachAssistant;

  /// Credits pill label
  ///
  /// In pt, this message translates to:
  /// **'{count} creditos'**
  String coachCreditsCount(int count);

  /// Memory section header
  ///
  /// In pt, this message translates to:
  /// **'Memoria'**
  String get coachMemory;

  /// Cost info when mode is free
  ///
  /// In pt, this message translates to:
  /// **'Modo Eco â€” sem custos de creditos.'**
  String get coachCostFree;

  /// Cost info per message
  ///
  /// In pt, this message translates to:
  /// **'Esta mensagem custa {cost} creditos.'**
  String coachCostCredits(int cost);

  /// Free label on mode chip
  ///
  /// In pt, this message translates to:
  /// **'Gratis'**
  String get coachFree;

  /// Cost per message on mode chip
  ///
  /// In pt, this message translates to:
  /// **'{cost}/msg'**
  String coachPerMsg(int cost);

  /// Eco fallback banner title
  ///
  /// In pt, this message translates to:
  /// **'Modo Eco ativo (sem creditos)'**
  String get coachEcoFallbackTitle;

  /// Eco fallback banner body
  ///
  /// In pt, this message translates to:
  /// **'Podes continuar a conversar, mas com memoria reduzida.'**
  String get coachEcoFallbackBody;

  /// Button to restore memory/credits
  ///
  /// In pt, this message translates to:
  /// **'Restaurar memoria'**
  String get coachRestoreMemory;

  /// No description provided for @cmdAssistantTitle.
  ///
  /// In pt, this message translates to:
  /// **'Assistente'**
  String get cmdAssistantTitle;

  /// No description provided for @cmdAssistantHint.
  ///
  /// In pt, this message translates to:
  /// **'O que precisas?'**
  String get cmdAssistantHint;

  /// No description provided for @cmdAssistantTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Precisa de ajuda? Toca aqui'**
  String get cmdAssistantTooltip;

  /// No description provided for @cmdSuggestionAddExpense.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar despesa'**
  String get cmdSuggestionAddExpense;

  /// No description provided for @cmdSuggestionOpenList.
  ///
  /// In pt, this message translates to:
  /// **'Abrir lista de compras'**
  String get cmdSuggestionOpenList;

  /// No description provided for @cmdSuggestionChangeTheme.
  ///
  /// In pt, this message translates to:
  /// **'Mudar tema'**
  String get cmdSuggestionChangeTheme;

  /// No description provided for @cmdSuggestionOpenSettings.
  ///
  /// In pt, this message translates to:
  /// **'Ir para definicoes'**
  String get cmdSuggestionOpenSettings;

  /// No description provided for @cmdTemplateAddExpense.
  ///
  /// In pt, this message translates to:
  /// **'Adiciona [valor] euros em [categoria]'**
  String get cmdTemplateAddExpense;

  /// No description provided for @cmdTemplateChangeTheme.
  ///
  /// In pt, this message translates to:
  /// **'Muda o tema para [claro/escuro]'**
  String get cmdTemplateChangeTheme;

  /// No description provided for @cmdExecutionFailed.
  ///
  /// In pt, this message translates to:
  /// **'Percebi o pedido, mas nao consegui executar. Tenta novamente.'**
  String get cmdExecutionFailed;

  /// No description provided for @cmdNotUnderstood.
  ///
  /// In pt, this message translates to:
  /// **'Nao percebi. Podes reformular?'**
  String get cmdNotUnderstood;

  /// No description provided for @cmdUndo.
  ///
  /// In pt, this message translates to:
  /// **'Desfazer'**
  String get cmdUndo;

  /// No description provided for @expenseDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Despesa eliminada'**
  String get expenseDeleted;

  /// No description provided for @cmdCapabilitiesCta.
  ///
  /// In pt, this message translates to:
  /// **'O que posso fazer?'**
  String get cmdCapabilitiesCta;

  /// No description provided for @cmdCapabilitiesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Acoes disponiveis'**
  String get cmdCapabilitiesTitle;

  /// No description provided for @cmdCapabilitiesSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Estas sao as acoes que o assistente suporta neste momento.'**
  String get cmdCapabilitiesSubtitle;

  /// No description provided for @cmdCapabilitiesFooter.
  ///
  /// In pt, this message translates to:
  /// **'Estamos a adicionar mais. Se ainda nao estiver aqui, pode nao funcionar.'**
  String get cmdCapabilitiesFooter;

  /// No description provided for @cmdCapabilityAddExpense.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar uma despesa'**
  String get cmdCapabilityAddExpense;

  /// No description provided for @cmdCapabilityAddExpenseExample.
  ///
  /// In pt, this message translates to:
  /// **'Adiciona [valor] euros em [categoria]'**
  String get cmdCapabilityAddExpenseExample;

  /// No description provided for @cmdCapabilityAddShoppingItem.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar item a lista'**
  String get cmdCapabilityAddShoppingItem;

  /// No description provided for @cmdCapabilityAddShoppingItemExample.
  ///
  /// In pt, this message translates to:
  /// **'Adiciona [item] a lista de compras'**
  String get cmdCapabilityAddShoppingItemExample;

  /// No description provided for @cmdCapabilityRemoveShoppingItem.
  ///
  /// In pt, this message translates to:
  /// **'Remover item da lista'**
  String get cmdCapabilityRemoveShoppingItem;

  /// No description provided for @cmdCapabilityRemoveShoppingItemExample.
  ///
  /// In pt, this message translates to:
  /// **'Remove [item] da lista de compras'**
  String get cmdCapabilityRemoveShoppingItemExample;

  /// No description provided for @cmdCapabilityToggleShoppingItemChecked.
  ///
  /// In pt, this message translates to:
  /// **'Marcar ou desmarcar item da lista'**
  String get cmdCapabilityToggleShoppingItemChecked;

  /// No description provided for @cmdCapabilityToggleShoppingItemCheckedExample.
  ///
  /// In pt, this message translates to:
  /// **'Marca [item] na lista de compras'**
  String get cmdCapabilityToggleShoppingItemCheckedExample;

  /// No description provided for @cmdCapabilityAddSavingsGoal.
  ///
  /// In pt, this message translates to:
  /// **'Criar objetivo de poupanca'**
  String get cmdCapabilityAddSavingsGoal;

  /// No description provided for @cmdCapabilityAddSavingsGoalExample.
  ///
  /// In pt, this message translates to:
  /// **'Cria objetivo de poupanca [nome] de [valor]'**
  String get cmdCapabilityAddSavingsGoalExample;

  /// No description provided for @cmdCapabilityAddSavingsContribution.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar ao objetivo de poupanca'**
  String get cmdCapabilityAddSavingsContribution;

  /// No description provided for @cmdCapabilityAddSavingsContributionExample.
  ///
  /// In pt, this message translates to:
  /// **'Adiciona [valor] ao objetivo [nome]'**
  String get cmdCapabilityAddSavingsContributionExample;

  /// No description provided for @cmdCapabilityAddRecurringExpense.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar despesa recorrente'**
  String get cmdCapabilityAddRecurringExpense;

  /// No description provided for @cmdCapabilityAddRecurringExpenseExample.
  ///
  /// In pt, this message translates to:
  /// **'Adiciona despesa recorrente [valor] em [categoria] dia [dia]'**
  String get cmdCapabilityAddRecurringExpenseExample;

  /// No description provided for @cmdCapabilityDeleteExpense.
  ///
  /// In pt, this message translates to:
  /// **'Apagar uma despesa'**
  String get cmdCapabilityDeleteExpense;

  /// No description provided for @cmdCapabilityDeleteExpenseExample.
  ///
  /// In pt, this message translates to:
  /// **'Apaga a despesa [descricao]'**
  String get cmdCapabilityDeleteExpenseExample;

  /// No description provided for @cmdCapabilityChangeTheme.
  ///
  /// In pt, this message translates to:
  /// **'Mudar tema'**
  String get cmdCapabilityChangeTheme;

  /// No description provided for @cmdCapabilityChangeThemeExample.
  ///
  /// In pt, this message translates to:
  /// **'Muda o tema para [claro/escuro]'**
  String get cmdCapabilityChangeThemeExample;

  /// No description provided for @cmdCapabilityChangePalette.
  ///
  /// In pt, this message translates to:
  /// **'Mudar paleta de cor'**
  String get cmdCapabilityChangePalette;

  /// No description provided for @cmdCapabilityChangePaletteExample.
  ///
  /// In pt, this message translates to:
  /// **'Cor [ocean/emerald/violet/teal/sunset]'**
  String get cmdCapabilityChangePaletteExample;

  /// No description provided for @cmdCapabilityChangeLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Mudar idioma'**
  String get cmdCapabilityChangeLanguage;

  /// No description provided for @cmdCapabilityChangeLanguageExample.
  ///
  /// In pt, this message translates to:
  /// **'Idioma [ingles/portugues/espanhol/frances]'**
  String get cmdCapabilityChangeLanguageExample;

  /// No description provided for @cmdCapabilityNavigate.
  ///
  /// In pt, this message translates to:
  /// **'Abrir ecra'**
  String get cmdCapabilityNavigate;

  /// No description provided for @cmdCapabilityNavigateExample.
  ///
  /// In pt, this message translates to:
  /// **'Abre a lista de compras'**
  String get cmdCapabilityNavigateExample;

  /// No description provided for @cmdCapabilityClearChecked.
  ///
  /// In pt, this message translates to:
  /// **'Limpar itens marcados'**
  String get cmdCapabilityClearChecked;

  /// No description provided for @cmdCapabilityClearCheckedExample.
  ///
  /// In pt, this message translates to:
  /// **'Limpa os itens marcados'**
  String get cmdCapabilityClearCheckedExample;

  /// Grocery screen title
  ///
  /// In pt, this message translates to:
  /// **'Supermercado'**
  String get groceryTitle;

  /// Grocery search field hint
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar produto...'**
  String get grocerySearchHint;

  /// Grocery loading semantic label
  ///
  /// In pt, this message translates to:
  /// **'A carregar produtos'**
  String get groceryLoadingLabel;

  /// Grocery loading message
  ///
  /// In pt, this message translates to:
  /// **'A carregar produtos...'**
  String get groceryLoadingMessage;

  /// Grocery filter: all products
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get groceryAll;

  /// Number of products shown
  ///
  /// In pt, this message translates to:
  /// **'{count} produtos'**
  String groceryProductCount(int count);

  /// Snackbar message when product added to list
  ///
  /// In pt, this message translates to:
  /// **'{name} adicionado Ã  lista'**
  String groceryAddedToList(String name);

  /// Product card average price label
  ///
  /// In pt, this message translates to:
  /// **'{unit} Â· preÃ§o mÃ©dio'**
  String groceryAvgPrice(String unit);

  /// Grocery data availability card title
  ///
  /// In pt, this message translates to:
  /// **'Disponibilidade dos dados'**
  String get groceryAvailabilityTitle;

  /// Selected grocery market label
  ///
  /// In pt, this message translates to:
  /// **'Mercado: {countryCode}'**
  String groceryAvailabilityCountry(String countryCode);

  /// Grocery store status count summary
  ///
  /// In pt, this message translates to:
  /// **'{fresh} frescas Â· {partial} parciais Â· {failed} indisponÃ­veis'**
  String groceryAvailabilitySummary(int fresh, int partial, int failed);

  /// Warning shown when grocery market data is degraded
  ///
  /// In pt, this message translates to:
  /// **'Algumas lojas tÃªm dados parciais ou desatualizados. As comparaÃ§Ãµes podem estar incompletas.'**
  String get groceryAvailabilityWarning;

  /// Grocery empty state title
  ///
  /// In pt, this message translates to:
  /// **'Sem dados de supermercado disponÃ­veis'**
  String get groceryEmptyStateTitle;

  /// Grocery empty state message
  ///
  /// In pt, this message translates to:
  /// **'Tenta novamente mais tarde ou muda de mercado nas definiÃ§Ãµes.'**
  String get groceryEmptyStateMessage;

  /// Shopping list screen title
  ///
  /// In pt, this message translates to:
  /// **'Lista de Compras'**
  String get shoppingTitle;

  /// Shopping list empty state title
  ///
  /// In pt, this message translates to:
  /// **'Lista vazia'**
  String get shoppingEmpty;

  /// Shopping list empty state message
  ///
  /// In pt, this message translates to:
  /// **'Adiciona produtos a partir do\necrÃ£ Supermercado.'**
  String get shoppingEmptyMessage;

  /// Shopping list items remaining summary
  ///
  /// In pt, this message translates to:
  /// **'{count} por comprar Â· {total}'**
  String shoppingItemsRemaining(int count, String total);

  /// Shopping list clear button
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get shoppingClear;

  /// Shopping list finalize button
  ///
  /// In pt, this message translates to:
  /// **'Finalizar Compra'**
  String get shoppingFinalize;

  /// Shopping list estimated total label
  ///
  /// In pt, this message translates to:
  /// **'Total estimado'**
  String get shoppingEstimatedTotal;

  /// Shopping list finalize dialog question
  ///
  /// In pt, this message translates to:
  /// **'QUANTO GASTEI NO TOTAL? (opcional)'**
  String get shoppingHowMuchSpent;

  /// Shopping list finalize confirm button
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get shoppingConfirm;

  /// Shopping list history tooltip
  ///
  /// In pt, this message translates to:
  /// **'HistÃ³rico de compras'**
  String get shoppingHistoryTooltip;

  /// Shopping history screen title
  ///
  /// In pt, this message translates to:
  /// **'HistÃ³rico de Compras'**
  String get shoppingHistoryTitle;

  /// Accessibility label for checked shopping item
  ///
  /// In pt, this message translates to:
  /// **'{name}, comprado'**
  String shoppingItemChecked(String name);

  /// Accessibility label for swipe to remove
  ///
  /// In pt, this message translates to:
  /// **'{name}, deslizar para remover'**
  String shoppingItemSwipe(String name);

  /// Pluralized product count
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 produto} other{{count} produtos}}'**
  String shoppingProductCount(int count);

  /// Etiqueta exibida nos itens da lista de compras que estão aguardando sincronização.
  ///
  /// In pt, this message translates to:
  /// **'Sincronização pendente'**
  String get shoppingPendingSync;

  /// No description provided for @shoppingViewItems.
  ///
  /// In pt, this message translates to:
  /// **'Itens'**
  String get shoppingViewItems;

  /// No description provided for @shoppingViewMeals.
  ///
  /// In pt, this message translates to:
  /// **'Refeicoes'**
  String get shoppingViewMeals;

  /// No description provided for @shoppingViewStores.
  ///
  /// In pt, this message translates to:
  /// **'Lojas'**
  String get shoppingViewStores;

  /// Texto exibido na bandeira de aviso de ausência de conexão.
  ///
  /// In pt, this message translates to:
  /// **'Modo offline: as alterações serão sincronizadas assim que recuperar a ligação.'**
  String get offlineBannerMessage;

  /// No description provided for @shoppingGroupOther.
  ///
  /// In pt, this message translates to:
  /// **'Outros'**
  String get shoppingGroupOther;

  /// Pluralized item count in group header
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} itens}}'**
  String shoppingGroupCount(int count);

  /// Cheapest known store hint
  ///
  /// In pt, this message translates to:
  /// **'Mais barato em {store} ({price})'**
  String shoppingCheapestAt(String store, String price);

  /// Auth login screen title
  ///
  /// In pt, this message translates to:
  /// **'Entrar na conta'**
  String get authLogin;

  /// Auth register screen title
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get authRegister;

  /// Auth email field label
  ///
  /// In pt, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// Auth email field hint
  ///
  /// In pt, this message translates to:
  /// **'exemplo@email.com'**
  String get authEmailHint;

  /// Auth password field label
  ///
  /// In pt, this message translates to:
  /// **'Palavra-passe'**
  String get authPassword;

  /// Auth login button label
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get authLoginButton;

  /// Auth register button label
  ///
  /// In pt, this message translates to:
  /// **'Registar'**
  String get authRegisterButton;

  /// Auth switch to register link
  ///
  /// In pt, this message translates to:
  /// **'Criar conta nova'**
  String get authSwitchToRegister;

  /// Auth switch to login link
  ///
  /// In pt, this message translates to:
  /// **'JÃ¡ tenho conta'**
  String get authSwitchToLogin;

  /// Registration success message
  ///
  /// In pt, this message translates to:
  /// **'Conta criada! Verifique o seu email para confirmar a conta antes de iniciar sessÃ£o.'**
  String get authRegistrationSuccess;

  /// No description provided for @authErrorNetwork.
  ///
  /// In pt, this message translates to:
  /// **'NÃ£o foi possÃ­vel ligar ao servidor. Verifique a sua ligaÃ§Ã£o Ã  internet e tente novamente.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In pt, this message translates to:
  /// **'Email ou palavra-passe invÃ¡lidos. Tente novamente.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorEmailNotConfirmed.
  ///
  /// In pt, this message translates to:
  /// **'Verifique o seu email antes de iniciar sessÃ£o.'**
  String get authErrorEmailNotConfirmed;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In pt, this message translates to:
  /// **'Demasiadas tentativas. Aguarde um momento e tente novamente.'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Ocorreu um erro. Tente novamente mais tarde.'**
  String get authErrorGeneric;

  /// Household setup screen title
  ///
  /// In pt, this message translates to:
  /// **'Configurar Agregado'**
  String get householdSetupTitle;

  /// Household create tab label
  ///
  /// In pt, this message translates to:
  /// **'Criar'**
  String get householdCreate;

  /// Household join tab label
  ///
  /// In pt, this message translates to:
  /// **'Entrar com cÃ³digo'**
  String get householdJoinWithCode;

  /// Household name field label
  ///
  /// In pt, this message translates to:
  /// **'Nome do agregado'**
  String get householdNameLabel;

  /// Household name field hint
  ///
  /// In pt, this message translates to:
  /// **'ex: FamÃ­lia Silva'**
  String get householdNameHint;

  /// Household invite code field label
  ///
  /// In pt, this message translates to:
  /// **'CÃ³digo de convite'**
  String get householdCodeLabel;

  /// Household invite code field hint
  ///
  /// In pt, this message translates to:
  /// **'XXXXXX'**
  String get householdCodeHint;

  /// Household create button label
  ///
  /// In pt, this message translates to:
  /// **'Criar Agregado'**
  String get householdCreateButton;

  /// Household join button label
  ///
  /// In pt, this message translates to:
  /// **'Entrar no Agregado'**
  String get householdJoinButton;

  /// Household name validation error
  ///
  /// In pt, this message translates to:
  /// **'Indica o nome do agregado.'**
  String get householdNameRequired;

  /// Chart title: expenses by category
  ///
  /// In pt, this message translates to:
  /// **'Despesas por Categoria'**
  String get chartExpensesByCategory;

  /// Chart title: income vs expenses
  ///
  /// In pt, this message translates to:
  /// **'Rendimento vs Despesas'**
  String get chartIncomeVsExpenses;

  /// Chart title: deductions
  ///
  /// In pt, this message translates to:
  /// **'Descontos (IRS + SeguranÃ§a Social)'**
  String get chartDeductions;

  /// Chart title: gross vs net
  ///
  /// In pt, this message translates to:
  /// **'Rendimento Bruto vs LÃ­quido'**
  String get chartGrossVsNet;

  /// Chart title: savings rate
  ///
  /// In pt, this message translates to:
  /// **'Taxa de PoupanÃ§a'**
  String get chartSavingsRate;

  /// Chart label: net income abbreviated
  ///
  /// In pt, this message translates to:
  /// **'Rend. Liq.'**
  String get chartNetIncome;

  /// Chart label: expenses
  ///
  /// In pt, this message translates to:
  /// **'Despesas'**
  String get chartExpensesLabel;

  /// Chart label: liquidity
  ///
  /// In pt, this message translates to:
  /// **'Liquidez'**
  String get chartLiquidity;

  /// Chart label: salary number N
  ///
  /// In pt, this message translates to:
  /// **'Venc. {n}'**
  String chartSalaryN(int n);

  /// Chart label: gross
  ///
  /// In pt, this message translates to:
  /// **'Bruto'**
  String get chartGross;

  /// Chart label: net
  ///
  /// In pt, this message translates to:
  /// **'LÃ­quido'**
  String get chartNet;

  /// Chart label: net salary
  ///
  /// In pt, this message translates to:
  /// **'Sal. LÃ­quido'**
  String get chartNetSalary;

  /// Chart label: IRS tax
  ///
  /// In pt, this message translates to:
  /// **'IRS'**
  String get chartIRS;

  /// Chart label: social security
  ///
  /// In pt, this message translates to:
  /// **'Seg. Social'**
  String get chartSocialSecurity;

  /// Chart label: savings
  ///
  /// In pt, this message translates to:
  /// **'poupanÃ§a'**
  String get chartSavings;

  /// Projection sheet title
  ///
  /// In pt, this message translates to:
  /// **'ProjeÃ§Ã£o â€” {month} {year}'**
  String projectionTitle(String month, String year);

  /// Projection sheet subtitle
  ///
  /// In pt, this message translates to:
  /// **'Gastou {spent} de {budget} em {days} dias'**
  String projectionSubtitle(String spent, String budget, String days);

  /// Projection section: food
  ///
  /// In pt, this message translates to:
  /// **'ALIMENTAÃ‡ÃƒO'**
  String get projectionFood;

  /// Projection scenario: current pace
  ///
  /// In pt, this message translates to:
  /// **'Ritmo atual'**
  String get projectionCurrentPace;

  /// Projection scenario: no shopping
  ///
  /// In pt, this message translates to:
  /// **'Sem compras'**
  String get projectionNoShopping;

  /// Projection scenario: reduce 20%
  ///
  /// In pt, this message translates to:
  /// **'-20%'**
  String get projectionReduce20;

  /// Projection daily spend estimate
  ///
  /// In pt, this message translates to:
  /// **'Gasto diÃ¡rio estimado: {amount}/dia'**
  String projectionDailySpend(String amount);

  /// Projection end of month label
  ///
  /// In pt, this message translates to:
  /// **'ProjeÃ§Ã£o fim de mÃªs'**
  String get projectionEndOfMonth;

  /// Projection remaining label
  ///
  /// In pt, this message translates to:
  /// **'Restante projetado'**
  String get projectionRemaining;

  /// Projection stress impact label
  ///
  /// In pt, this message translates to:
  /// **'Impacto no Ãndice'**
  String get projectionStressImpact;

  /// Projection section: expenses
  ///
  /// In pt, this message translates to:
  /// **'DESPESAS'**
  String get projectionExpenses;

  /// Projection simulation disclaimer
  ///
  /// In pt, this message translates to:
  /// **'SimulaÃ§Ã£o â€” nÃ£o guardado'**
  String get projectionSimulation;

  /// Projection reduce all expenses label
  ///
  /// In pt, this message translates to:
  /// **'Reduzir todas em '**
  String get projectionReduceAll;

  /// Projection simulated liquidity label
  ///
  /// In pt, this message translates to:
  /// **'Liquidez simulada'**
  String get projectionSimLiquidity;

  /// Projection delta label
  ///
  /// In pt, this message translates to:
  /// **'Delta'**
  String get projectionDelta;

  /// Projection simulated savings rate label
  ///
  /// In pt, this message translates to:
  /// **'Taxa poupanÃ§a simulada'**
  String get projectionSimSavingsRate;

  /// Projection simulated stress index label
  ///
  /// In pt, this message translates to:
  /// **'Ãndice simulado'**
  String get projectionSimIndex;

  /// Trend sheet title
  ///
  /// In pt, this message translates to:
  /// **'EvoluÃ§Ã£o'**
  String get trendTitle;

  /// Trend section: stress index
  ///
  /// In pt, this message translates to:
  /// **'ÃNDICE DE TRANQUILIDADE'**
  String get trendStressIndex;

  /// Trend section: total expenses
  ///
  /// In pt, this message translates to:
  /// **'DESPESAS TOTAIS'**
  String get trendTotalExpenses;

  /// Trend section: expenses by category
  ///
  /// In pt, this message translates to:
  /// **'DESPESAS POR CATEGORIA'**
  String get trendExpensesByCategory;

  /// Trend current value label
  ///
  /// In pt, this message translates to:
  /// **'Atual: {amount}'**
  String trendCurrent(String amount);

  /// Trend category: telecom
  ///
  /// In pt, this message translates to:
  /// **'Telecom'**
  String get trendCatTelecom;

  /// Trend category: energy
  ///
  /// In pt, this message translates to:
  /// **'Energia'**
  String get trendCatEnergy;

  /// Trend category: water
  ///
  /// In pt, this message translates to:
  /// **'Ãgua'**
  String get trendCatWater;

  /// Trend category: food
  ///
  /// In pt, this message translates to:
  /// **'AlimentaÃ§Ã£o'**
  String get trendCatFood;

  /// Trend category: education
  ///
  /// In pt, this message translates to:
  /// **'EducaÃ§Ã£o'**
  String get trendCatEducation;

  /// Trend category: housing
  ///
  /// In pt, this message translates to:
  /// **'HabitaÃ§Ã£o'**
  String get trendCatHousing;

  /// Trend category: transport
  ///
  /// In pt, this message translates to:
  /// **'Transportes'**
  String get trendCatTransport;

  /// Trend category: health
  ///
  /// In pt, this message translates to:
  /// **'SaÃºde'**
  String get trendCatHealth;

  /// Trend category: leisure
  ///
  /// In pt, this message translates to:
  /// **'Lazer'**
  String get trendCatLeisure;

  /// Trend category: other
  ///
  /// In pt, this message translates to:
  /// **'Outros'**
  String get trendCatOther;

  /// Month review sheet title
  ///
  /// In pt, this message translates to:
  /// **'Resumo â€” {month}'**
  String monthReviewTitle(String month);

  /// Month review column: planned
  ///
  /// In pt, this message translates to:
  /// **'Planeado'**
  String get monthReviewPlanned;

  /// Month review column: actual
  ///
  /// In pt, this message translates to:
  /// **'Real'**
  String get monthReviewActual;

  /// Month review column: difference
  ///
  /// In pt, this message translates to:
  /// **'DiferenÃ§a'**
  String get monthReviewDifference;

  /// Month review row: food
  ///
  /// In pt, this message translates to:
  /// **'AlimentaÃ§Ã£o'**
  String get monthReviewFood;

  /// Month review food value display
  ///
  /// In pt, this message translates to:
  /// **'{actual} de {budget}'**
  String monthReviewFoodValue(String actual, String budget);

  /// Month review section: top deviations
  ///
  /// In pt, this message translates to:
  /// **'MAIORES DESVIOS'**
  String get monthReviewTopDeviations;

  /// Month review section: suggestions
  ///
  /// In pt, this message translates to:
  /// **'SUGESTÃ•ES'**
  String get monthReviewSuggestions;

  /// Month review AI analysis button
  ///
  /// In pt, this message translates to:
  /// **'AnÃ¡lise AI detalhada'**
  String get monthReviewAiAnalysis;

  /// Meal planner screen title
  ///
  /// In pt, this message translates to:
  /// **'Planeador de RefeiÃ§Ãµes'**
  String get mealPlannerTitle;

  /// Meal planner budget label
  ///
  /// In pt, this message translates to:
  /// **'OrÃ§amento alimentaÃ§Ã£o'**
  String get mealBudgetLabel;

  /// Meal planner people count label
  ///
  /// In pt, this message translates to:
  /// **'Pessoas no agregado'**
  String get mealPeopleLabel;

  /// Meal planner generate button
  ///
  /// In pt, this message translates to:
  /// **'Gerar Plano Mensal'**
  String get mealGeneratePlan;

  /// Meal planner generating state
  ///
  /// In pt, this message translates to:
  /// **'A gerar...'**
  String get mealGenerating;

  /// Meal planner regenerate dialog title
  ///
  /// In pt, this message translates to:
  /// **'Regenerar plano?'**
  String get mealRegenerateTitle;

  /// Meal planner regenerate dialog content
  ///
  /// In pt, this message translates to:
  /// **'O plano atual serÃ¡ substituÃ­do.'**
  String get mealRegenerateContent;

  /// Meal planner regenerate button
  ///
  /// In pt, this message translates to:
  /// **'Regenerar'**
  String get mealRegenerate;

  /// Meal planner week label
  ///
  /// In pt, this message translates to:
  /// **'Semana {n}'**
  String mealWeekLabel(int n);

  /// Meal planner week abbreviation
  ///
  /// In pt, this message translates to:
  /// **'Sem.{n}'**
  String mealWeekAbbr(int n);

  /// Meal planner add week to shopping list button
  ///
  /// In pt, this message translates to:
  /// **'Adicionar semana Ã  lista'**
  String get mealAddWeekToList;

  /// Meal planner ingredients added snackbar
  ///
  /// In pt, this message translates to:
  /// **'{count} ingredientes adicionados Ã  lista'**
  String mealIngredientsAdded(int count);

  /// Meal planner day label
  ///
  /// In pt, this message translates to:
  /// **'Dia {n}'**
  String mealDayLabel(int n);

  /// Meal detail: ingredients section
  ///
  /// In pt, this message translates to:
  /// **'Ingredientes'**
  String get mealIngredients;

  /// Meal detail: preparation section
  ///
  /// In pt, this message translates to:
  /// **'PreparaÃ§Ã£o'**
  String get mealPreparation;

  /// Meal detail: swap button
  ///
  /// In pt, this message translates to:
  /// **'Trocar'**
  String get mealSwap;

  /// Meal planner consolidated list button
  ///
  /// In pt, this message translates to:
  /// **'Ver lista consolidada'**
  String get mealConsolidatedList;

  /// Meal planner consolidated list title
  ///
  /// In pt, this message translates to:
  /// **'Lista Consolidada'**
  String get mealConsolidatedTitle;

  /// Meal detail: alternatives section
  ///
  /// In pt, this message translates to:
  /// **'Alternativas'**
  String get mealAlternatives;

  /// Meal planner total cost display
  ///
  /// In pt, this message translates to:
  /// **'{cost}â‚¬ total'**
  String mealTotalCost(String cost);

  /// Meal ingredient category: proteins
  ///
  /// In pt, this message translates to:
  /// **'ProteÃ­nas'**
  String get mealCatProteins;

  /// Meal ingredient category: vegetables
  ///
  /// In pt, this message translates to:
  /// **'Vegetais'**
  String get mealCatVegetables;

  /// Meal ingredient category: carbs
  ///
  /// In pt, this message translates to:
  /// **'Hidratos'**
  String get mealCatCarbs;

  /// Meal ingredient category: fats
  ///
  /// In pt, this message translates to:
  /// **'Gorduras'**
  String get mealCatFats;

  /// Meal ingredient category: condiments
  ///
  /// In pt, this message translates to:
  /// **'Condimentos'**
  String get mealCatCondiments;

  /// Cost per person display in meal card
  ///
  /// In pt, this message translates to:
  /// **'{cost}â‚¬/pess'**
  String mealCostPerPerson(String cost);

  /// Nutrition badge abbreviation: protein
  ///
  /// In pt, this message translates to:
  /// **'prot'**
  String get mealNutriProt;

  /// Nutrition badge abbreviation: carbohydrates
  ///
  /// In pt, this message translates to:
  /// **'carbs'**
  String get mealNutriCarbs;

  /// Nutrition badge abbreviation: fat
  ///
  /// In pt, this message translates to:
  /// **'gord'**
  String get mealNutriFat;

  /// Nutrition badge abbreviation: fiber
  ///
  /// In pt, this message translates to:
  /// **'fibra'**
  String get mealNutriFiber;

  /// Wizard step label: meals
  ///
  /// In pt, this message translates to:
  /// **'RefeiÃ§Ãµes'**
  String get wizardStepMeals;

  /// Wizard step label: objective
  ///
  /// In pt, this message translates to:
  /// **'Objetivo'**
  String get wizardStepObjective;

  /// Wizard step label: restrictions
  ///
  /// In pt, this message translates to:
  /// **'RestriÃ§Ãµes'**
  String get wizardStepRestrictions;

  /// Wizard step label: kitchen
  ///
  /// In pt, this message translates to:
  /// **'Cozinha'**
  String get wizardStepKitchen;

  /// Wizard step label: strategy
  ///
  /// In pt, this message translates to:
  /// **'EstratÃ©gia'**
  String get wizardStepStrategy;

  /// Wizard meals step question
  ///
  /// In pt, this message translates to:
  /// **'Quais refeiÃ§Ãµes queres incluir no plano diÃ¡rio?'**
  String get wizardMealsQuestion;

  /// Wizard budget weight display
  ///
  /// In pt, this message translates to:
  /// **'{weight} do orÃ§amento'**
  String wizardBudgetWeight(String weight);

  /// Wizard objective step question
  ///
  /// In pt, this message translates to:
  /// **'Qual Ã© o objetivo principal do teu plano alimentar?'**
  String get wizardObjectiveQuestion;

  /// Wizard accessibility label for selected item
  ///
  /// In pt, this message translates to:
  /// **'{label}, selecionado'**
  String wizardSelected(String label);

  /// Wizard restrictions section header
  ///
  /// In pt, this message translates to:
  /// **'RESTRIÃ‡Ã•ES DIETÃ‰TICAS'**
  String get wizardDietaryRestrictions;

  /// Wizard dietary restriction: gluten free
  ///
  /// In pt, this message translates to:
  /// **'Sem glÃºten'**
  String get wizardGlutenFree;

  /// Wizard dietary restriction: lactose free
  ///
  /// In pt, this message translates to:
  /// **'Sem lactose'**
  String get wizardLactoseFree;

  /// Wizard dietary restriction: nut free
  ///
  /// In pt, this message translates to:
  /// **'Sem frutos secos'**
  String get wizardNutFree;

  /// Wizard dietary restriction: shellfish free
  ///
  /// In pt, this message translates to:
  /// **'Sem marisco'**
  String get wizardShellfishFree;

  /// Wizard disliked ingredients section header
  ///
  /// In pt, this message translates to:
  /// **'INGREDIENTES QUE NÃƒO GOSTAS'**
  String get wizardDislikedIngredients;

  /// Wizard disliked ingredients hint
  ///
  /// In pt, this message translates to:
  /// **'ex: atum, brÃ³colos'**
  String get wizardDislikedHint;

  /// Wizard max prep time section header
  ///
  /// In pt, this message translates to:
  /// **'TEMPO MÃXIMO POR REFEIÃ‡ÃƒO'**
  String get wizardMaxPrepTime;

  /// Wizard max complexity section header
  ///
  /// In pt, this message translates to:
  /// **'COMPLEXIDADE MÃXIMA'**
  String get wizardMaxComplexity;

  /// Wizard complexity level: easy
  ///
  /// In pt, this message translates to:
  /// **'FÃ¡cil'**
  String get wizardComplexityEasy;

  /// Wizard complexity level: medium
  ///
  /// In pt, this message translates to:
  /// **'MÃ©dio'**
  String get wizardComplexityMedium;

  /// Wizard complexity level: advanced
  ///
  /// In pt, this message translates to:
  /// **'AvanÃ§ado'**
  String get wizardComplexityAdvanced;

  /// Wizard equipment section header
  ///
  /// In pt, this message translates to:
  /// **'EQUIPAMENTO DISPONÃVEL'**
  String get wizardEquipment;

  /// Wizard strategy: batch cooking toggle
  ///
  /// In pt, this message translates to:
  /// **'Batch cooking'**
  String get wizardBatchCooking;

  /// Wizard strategy: batch cooking description
  ///
  /// In pt, this message translates to:
  /// **'Cozinhar para vÃ¡rios dias de uma vez'**
  String get wizardBatchCookingDesc;

  /// Wizard max batch days section header
  ///
  /// In pt, this message translates to:
  /// **'MÃXIMO DE DIAS POR RECEITA'**
  String get wizardMaxBatchDays;

  /// Wizard batch days display
  ///
  /// In pt, this message translates to:
  /// **'{days} dias'**
  String wizardBatchDays(int days);

  /// Wizard preferred cooking day section header
  ///
  /// In pt, this message translates to:
  /// **'DIA PREFERIDO PARA COZINHAR'**
  String get wizardPreferredCookingDay;

  /// Wizard strategy: reuse leftovers toggle
  ///
  /// In pt, this message translates to:
  /// **'Reaproveitar sobras'**
  String get wizardReuseLeftovers;

  /// Wizard strategy: reuse leftovers description
  ///
  /// In pt, this message translates to:
  /// **'Jantar de ontem = almoÃ§o de hoje (custo 0)'**
  String get wizardReuseLeftoversDesc;

  /// Wizard max new ingredients section header
  ///
  /// In pt, this message translates to:
  /// **'MÃXIMO DE INGREDIENTES NOVOS POR SEMANA'**
  String get wizardMaxNewIngredients;

  /// Wizard no limit label
  ///
  /// In pt, this message translates to:
  /// **'Sem limite'**
  String get wizardNoLimit;

  /// Wizard strategy: minimize waste toggle
  ///
  /// In pt, this message translates to:
  /// **'Minimizar desperdÃ­cio'**
  String get wizardMinimizeWaste;

  /// Wizard strategy: minimize waste description
  ///
  /// In pt, this message translates to:
  /// **'Prefere receitas que reutilizam ingredientes jÃ¡ usados'**
  String get wizardMinimizeWasteDesc;

  /// Wizard settings info text
  ///
  /// In pt, this message translates to:
  /// **'Podes alterar as definiÃ§Ãµes do planeador em qualquer altura em DefiniÃ§Ãµes â†’ RefeiÃ§Ãµes.'**
  String get wizardSettingsInfo;

  /// Wizard continue button
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get wizardContinue;

  /// Wizard generate plan button
  ///
  /// In pt, this message translates to:
  /// **'Gerar Plano'**
  String get wizardGeneratePlan;

  /// Wizard step progress indicator
  ///
  /// In pt, this message translates to:
  /// **'Passo {current} de {total}'**
  String wizardStepOf(int current, int total);

  /// Weekday abbreviation: Monday
  ///
  /// In pt, this message translates to:
  /// **'Seg'**
  String get wizardWeekdayMon;

  /// Weekday abbreviation: Tuesday
  ///
  /// In pt, this message translates to:
  /// **'Ter'**
  String get wizardWeekdayTue;

  /// Weekday abbreviation: Wednesday
  ///
  /// In pt, this message translates to:
  /// **'Qua'**
  String get wizardWeekdayWed;

  /// Weekday abbreviation: Thursday
  ///
  /// In pt, this message translates to:
  /// **'Qui'**
  String get wizardWeekdayThu;

  /// Weekday abbreviation: Friday
  ///
  /// In pt, this message translates to:
  /// **'Sex'**
  String get wizardWeekdayFri;

  /// Weekday abbreviation: Saturday
  ///
  /// In pt, this message translates to:
  /// **'SÃ¡b'**
  String get wizardWeekdaySat;

  /// Weekday abbreviation: Sunday
  ///
  /// In pt, this message translates to:
  /// **'Dom'**
  String get wizardWeekdaySun;

  /// Wizard prep time in minutes
  ///
  /// In pt, this message translates to:
  /// **'{mins}min'**
  String wizardPrepMin(int mins);

  /// Wizard prep time: 60+ minutes
  ///
  /// In pt, this message translates to:
  /// **'60+'**
  String get wizardPrepMin60Plus;

  /// Settings screen title
  ///
  /// In pt, this message translates to:
  /// **'DefiniÃ§Ãµes'**
  String get settingsTitle;

  /// Settings section: personal data
  ///
  /// In pt, this message translates to:
  /// **'Dados Pessoais'**
  String get settingsPersonal;

  /// Settings section: salaries
  ///
  /// In pt, this message translates to:
  /// **'SalÃ¡rios'**
  String get settingsSalaries;

  /// Settings section: expenses
  ///
  /// In pt, this message translates to:
  /// **'OrÃ§amento e Pagamentos Recorrentes'**
  String get settingsExpenses;

  /// Settings section: AI coach
  ///
  /// In pt, this message translates to:
  /// **'Coach IA'**
  String get settingsCoachAi;

  /// Settings section: dashboard
  ///
  /// In pt, this message translates to:
  /// **'Dashboard'**
  String get settingsDashboard;

  /// Settings section: meals
  ///
  /// In pt, this message translates to:
  /// **'RefeiÃ§Ãµes'**
  String get settingsMeals;

  /// Settings section: region and language
  ///
  /// In pt, this message translates to:
  /// **'RegiÃ£o e Idioma'**
  String get settingsRegion;

  /// Settings field: country
  ///
  /// In pt, this message translates to:
  /// **'PaÃ­s'**
  String get settingsCountry;

  /// Settings field: language
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// Settings field: marital status
  ///
  /// In pt, this message translates to:
  /// **'Estado civil'**
  String get settingsMaritalStatus;

  /// Settings field: dependents
  ///
  /// In pt, this message translates to:
  /// **'Dependentes'**
  String get settingsDependents;

  /// Settings field: disability
  ///
  /// In pt, this message translates to:
  /// **'Deficiente'**
  String get settingsDisability;

  /// Settings field: gross salary
  ///
  /// In pt, this message translates to:
  /// **'SalÃ¡rio bruto'**
  String get settingsGrossSalary;

  /// Settings field: titulares (tax holders)
  ///
  /// In pt, this message translates to:
  /// **'Titulares'**
  String get settingsTitulares;

  /// Settings field: subsidy mode
  ///
  /// In pt, this message translates to:
  /// **'DuodÃ©cimos'**
  String get settingsSubsidyMode;

  /// Settings field: meal allowance
  ///
  /// In pt, this message translates to:
  /// **'SubsÃ­dio de alimentaÃ§Ã£o'**
  String get settingsMealAllowance;

  /// Settings field: meal allowance per day
  ///
  /// In pt, this message translates to:
  /// **'Valor/dia'**
  String get settingsMealAllowancePerDay;

  /// Settings field: working days per month
  ///
  /// In pt, this message translates to:
  /// **'Dias Ãºteis/mÃªs'**
  String get settingsWorkingDays;

  /// Settings field: other exempt income
  ///
  /// In pt, this message translates to:
  /// **'Outros rendimentos isentos'**
  String get settingsOtherExemptIncome;

  /// Settings add salary button
  ///
  /// In pt, this message translates to:
  /// **'Adicionar salÃ¡rio'**
  String get settingsAddSalary;

  /// Settings add expense button
  ///
  /// In pt, this message translates to:
  /// **'Adicionar categoria'**
  String get settingsAddExpense;

  /// Settings field: expense name
  ///
  /// In pt, this message translates to:
  /// **'Nome da categoria'**
  String get settingsExpenseName;

  /// Settings field: expense amount
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get settingsExpenseAmount;

  /// Settings field: expense category
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get settingsExpenseCategory;

  /// Settings field: OpenAI API key
  ///
  /// In pt, this message translates to:
  /// **'API Key OpenAI'**
  String get settingsApiKey;

  /// Settings field: invite code
  ///
  /// In pt, this message translates to:
  /// **'CÃ³digo de convite'**
  String get settingsInviteCode;

  /// Settings copy code button
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get settingsCopyCode;

  /// Settings code copied snackbar
  ///
  /// In pt, this message translates to:
  /// **'CÃ³digo copiado!'**
  String get settingsCodeCopied;

  /// Settings admin only warning
  ///
  /// In pt, this message translates to:
  /// **'Apenas o administrador pode editar as definiÃ§Ãµes.'**
  String get settingsAdminOnly;

  /// Settings toggle: show summary cards
  ///
  /// In pt, this message translates to:
  /// **'Mostrar cartÃµes resumo'**
  String get settingsShowSummaryCards;

  /// Settings section: enabled charts
  ///
  /// In pt, this message translates to:
  /// **'GrÃ¡ficos ativos'**
  String get settingsEnabledCharts;

  /// Settings logout button
  ///
  /// In pt, this message translates to:
  /// **'Terminar sessÃ£o'**
  String get settingsLogout;

  /// Settings logout dialog title
  ///
  /// In pt, this message translates to:
  /// **'Terminar sessÃ£o'**
  String get settingsLogoutConfirmTitle;

  /// Settings logout dialog content
  ///
  /// In pt, this message translates to:
  /// **'Tens a certeza que queres sair?'**
  String get settingsLogoutConfirmContent;

  /// Settings logout dialog confirm button
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get settingsLogoutConfirmButton;

  /// Settings section header: salaries/income
  ///
  /// In pt, this message translates to:
  /// **'Vencimentos'**
  String get settingsSalariesSection;

  /// Settings section header: monthly expenses
  ///
  /// In pt, this message translates to:
  /// **'OrÃ§amento e Pagamentos Recorrentes'**
  String get settingsExpensesMonthly;

  /// Settings section header: favorite products
  ///
  /// In pt, this message translates to:
  /// **'Produtos Favoritos'**
  String get settingsFavorites;

  /// Settings section header: AI coach
  ///
  /// In pt, this message translates to:
  /// **'Coach IA (OpenAI)'**
  String get settingsCoachOpenAi;

  /// Settings section header: household
  ///
  /// In pt, this message translates to:
  /// **'Agregado'**
  String get settingsHousehold;

  /// Settings label: marital status
  ///
  /// In pt, this message translates to:
  /// **'ESTADO CIVIL'**
  String get settingsMaritalStatusLabel;

  /// Settings label: number of dependents
  ///
  /// In pt, this message translates to:
  /// **'NÃšMERO DE DEPENDENTES'**
  String get settingsDependentsLabel;

  /// Settings social security rate display
  ///
  /// In pt, this message translates to:
  /// **'SeguranÃ§a Social: {rate}'**
  String settingsSocialSecurityRate(String rate);

  /// Settings salary active toggle label
  ///
  /// In pt, this message translates to:
  /// **'Ativo'**
  String get settingsSalaryActive;

  /// Settings label: gross monthly salary
  ///
  /// In pt, this message translates to:
  /// **'SALÃRIO BRUTO MENSAL'**
  String get settingsGrossMonthlySalary;

  /// Settings label: holiday subsidies
  ///
  /// In pt, this message translates to:
  /// **'SUBSÃDIOS DE FÃ‰RIAS E NATAL (DUODÃ‰CIMOS)'**
  String get settingsSubsidyHoliday;

  /// Settings label: other exempt income
  ///
  /// In pt, this message translates to:
  /// **'OUTROS RENDIMENTOS ISENTOS DE IRS'**
  String get settingsOtherExemptLabel;

  /// Settings label: meal allowance
  ///
  /// In pt, this message translates to:
  /// **'SUBSÃDIO DE ALIMENTAÃ‡ÃƒO'**
  String get settingsMealAllowanceLabel;

  /// Settings label: amount per day
  ///
  /// In pt, this message translates to:
  /// **'VALOR/DIA'**
  String get settingsAmountPerDay;

  /// Settings label: days per month
  ///
  /// In pt, this message translates to:
  /// **'DIAS/MÃŠS'**
  String get settingsDaysPerMonth;

  /// Settings label: number of tax holders
  ///
  /// In pt, this message translates to:
  /// **'N. TITULARES'**
  String get settingsTitularesLabel;

  /// Settings titular count button
  ///
  /// In pt, this message translates to:
  /// **'{n} Titular{suffix}'**
  String settingsTitularCount(int n, String suffix);

  /// Settings add salary button
  ///
  /// In pt, this message translates to:
  /// **'Adicionar vencimento'**
  String get settingsAddSalaryButton;

  /// Settings add expense button
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Categoria'**
  String get settingsAddExpenseButton;

  /// Settings device local storage info
  ///
  /// In pt, this message translates to:
  /// **'Estas definiÃ§Ãµes sÃ£o guardadas neste dispositivo.'**
  String get settingsDeviceLocal;

  /// Settings label: visible sections
  ///
  /// In pt, this message translates to:
  /// **'SECÃ‡Ã•ES VISÃVEIS'**
  String get settingsVisibleSections;

  /// Settings dashboard preset: minimalist
  ///
  /// In pt, this message translates to:
  /// **'Minimalista'**
  String get settingsMinimalist;

  /// Settings dashboard preset: full
  ///
  /// In pt, this message translates to:
  /// **'Completo'**
  String get settingsFull;

  /// Settings dashboard toggle: monthly liquidity
  ///
  /// In pt, this message translates to:
  /// **'Liquidez mensal'**
  String get settingsDashMonthlyLiquidity;

  /// Settings dashboard toggle: stress index
  ///
  /// In pt, this message translates to:
  /// **'Ãndice de Tranquilidade'**
  String get settingsDashStressIndex;

  /// Settings dashboard toggle: summary cards
  ///
  /// In pt, this message translates to:
  /// **'CartÃµes de resumo'**
  String get settingsDashSummaryCards;

  /// Settings dashboard toggle: salary breakdown
  ///
  /// In pt, this message translates to:
  /// **'Detalhe por vencimento'**
  String get settingsDashSalaryBreakdown;

  /// Settings dashboard toggle: food spending
  ///
  /// In pt, this message translates to:
  /// **'AlimentaÃ§Ã£o'**
  String get settingsDashFood;

  /// Settings dashboard toggle: purchase history
  ///
  /// In pt, this message translates to:
  /// **'HistÃ³rico de compras'**
  String get settingsDashPurchaseHistory;

  /// Settings dashboard toggle: expenses breakdown
  ///
  /// In pt, this message translates to:
  /// **'Breakdown despesas'**
  String get settingsDashExpensesBreakdown;

  /// Settings dashboard toggle: month review
  ///
  /// In pt, this message translates to:
  /// **'RevisÃ£o do mÃªs'**
  String get settingsDashMonthReview;

  /// Settings dashboard toggle: charts
  ///
  /// In pt, this message translates to:
  /// **'GrÃ¡ficos'**
  String get settingsDashCharts;

  /// Dashboard settings group label: overview
  ///
  /// In pt, this message translates to:
  /// **'VISÃƒO GERAL'**
  String get dashGroupOverview;

  /// Dashboard settings group label: financial detail
  ///
  /// In pt, this message translates to:
  /// **'DETALHE FINANCEIRO'**
  String get dashGroupFinancialDetail;

  /// Dashboard settings group label: history
  ///
  /// In pt, this message translates to:
  /// **'HISTÃ“RICO'**
  String get dashGroupHistory;

  /// Dashboard settings group label: charts
  ///
  /// In pt, this message translates to:
  /// **'GRÃFICOS'**
  String get dashGroupCharts;

  /// Settings label: visible charts
  ///
  /// In pt, this message translates to:
  /// **'GRÃFICOS VISÃVEIS'**
  String get settingsVisibleCharts;

  /// Settings favorites tip text
  ///
  /// In pt, this message translates to:
  /// **'Os produtos favoritos influenciam o plano de refeiÃ§Ãµes â€” receitas com esses ingredientes ficam em prioridade.'**
  String get settingsFavTip;

  /// Settings label: my favorites
  ///
  /// In pt, this message translates to:
  /// **'OS MEUS FAVORITOS'**
  String get settingsMyFavorites;

  /// Settings label: product catalog
  ///
  /// In pt, this message translates to:
  /// **'CATÃLOGO DE PRODUTOS'**
  String get settingsProductCatalog;

  /// Settings search product hint
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar produto...'**
  String get settingsSearchProduct;

  /// Settings loading products message
  ///
  /// In pt, this message translates to:
  /// **'A carregar produtos...'**
  String get settingsLoadingProducts;

  /// Settings dialog title: add ingredient
  ///
  /// In pt, this message translates to:
  /// **'Adicionar ingrediente'**
  String get settingsAddIngredient;

  /// Settings dialog hint: ingredient name
  ///
  /// In pt, this message translates to:
  /// **'Nome do ingrediente'**
  String get settingsIngredientName;

  /// Settings add button label
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get settingsAddButton;

  /// Settings dialog title: add to pantry
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Ã  despensa'**
  String get settingsAddToPantry;

  /// Settings label: household people
  ///
  /// In pt, this message translates to:
  /// **'AGREGADO (PESSOAS)'**
  String get settingsHouseholdPeople;

  /// Settings automatic value suffix
  ///
  /// In pt, this message translates to:
  /// **'(auto)'**
  String get settingsAutomatic;

  /// Settings tooltip: use automatic value
  ///
  /// In pt, this message translates to:
  /// **'Usar valor automÃ¡tico'**
  String get settingsUseAutoValue;

  /// Settings manual household value
  ///
  /// In pt, this message translates to:
  /// **'Valor manual: {count} pessoas'**
  String settingsManualValue(int count);

  /// Settings auto household value
  ///
  /// In pt, this message translates to:
  /// **'Calculado automaticamente: {count} (titulares + dependentes)'**
  String settingsAutoValue(int count);

  /// Settings label: household members
  ///
  /// In pt, this message translates to:
  /// **'MEMBROS DO AGREGADO'**
  String get settingsHouseholdMembers;

  /// Settings portions unit label
  ///
  /// In pt, this message translates to:
  /// **'porÃ§Ãµes'**
  String get settingsPortions;

  /// Settings total portion equivalent
  ///
  /// In pt, this message translates to:
  /// **'Equivalente total: {total} porÃ§Ãµes'**
  String settingsTotalEquivalent(String total);

  /// Settings add member button/dialog title
  ///
  /// In pt, this message translates to:
  /// **'Adicionar membro'**
  String get settingsAddMember;

  /// Settings toggle: prefer seasonal recipes
  ///
  /// In pt, this message translates to:
  /// **'Preferir receitas sazonais'**
  String get settingsPreferSeasonal;

  /// Settings toggle description: seasonal
  ///
  /// In pt, this message translates to:
  /// **'Prioriza receitas da Ã©poca atual'**
  String get settingsPreferSeasonalDesc;

  /// Settings label: nutritional goals
  ///
  /// In pt, this message translates to:
  /// **'OBJETIVOS NUTRICIONAIS'**
  String get settingsNutritionalGoals;

  /// Settings calorie target hint
  ///
  /// In pt, this message translates to:
  /// **'ex: 2000'**
  String get settingsCalorieHint;

  /// Settings kcal per day suffix
  ///
  /// In pt, this message translates to:
  /// **'kcal/dia'**
  String get settingsKcalPerDay;

  /// Settings protein target hint
  ///
  /// In pt, this message translates to:
  /// **'ex: 60'**
  String get settingsProteinHint;

  /// Settings grams per day suffix
  ///
  /// In pt, this message translates to:
  /// **'g/dia'**
  String get settingsGramsPerDay;

  /// Settings fiber target hint
  ///
  /// In pt, this message translates to:
  /// **'ex: 25'**
  String get settingsFiberHint;

  /// Settings field: daily protein
  ///
  /// In pt, this message translates to:
  /// **'ProteÃ­na diÃ¡ria'**
  String get settingsDailyProtein;

  /// Settings field: daily fiber
  ///
  /// In pt, this message translates to:
  /// **'Fibra diÃ¡ria'**
  String get settingsDailyFiber;

  /// Settings label: medical conditions
  ///
  /// In pt, this message translates to:
  /// **'CONDIÃ‡Ã•ES MÃ‰DICAS'**
  String get settingsMedicalConditions;

  /// Settings label: active meals
  ///
  /// In pt, this message translates to:
  /// **'REFEIÃ‡Ã•ES ATIVAS'**
  String get settingsActiveMeals;

  /// Settings label: objective
  ///
  /// In pt, this message translates to:
  /// **'OBJETIVO'**
  String get settingsObjective;

  /// Settings label: veggie days per week
  ///
  /// In pt, this message translates to:
  /// **'DIAS VEGETARIANOS POR SEMANA'**
  String get settingsVeggieDays;

  /// Settings label: dietary restrictions
  ///
  /// In pt, this message translates to:
  /// **'RESTRIÃ‡Ã•ES DIETÃ‰TICAS'**
  String get settingsDietaryRestrictions;

  /// Settings dietary restriction: egg free
  ///
  /// In pt, this message translates to:
  /// **'Sem ovos'**
  String get settingsEggFree;

  /// Settings label: sodium preference
  ///
  /// In pt, this message translates to:
  /// **'PREFERÃŠNCIA DE SÃ“DIO'**
  String get settingsSodiumPref;

  /// Settings label: disliked ingredients
  ///
  /// In pt, this message translates to:
  /// **'INGREDIENTES INDESEJADOS'**
  String get settingsDislikedIngredients;

  /// Settings label: excluded proteins
  ///
  /// In pt, this message translates to:
  /// **'PROTEÃNAS EXCLUÃDAS'**
  String get settingsExcludedProteins;

  /// Settings protein: chicken
  ///
  /// In pt, this message translates to:
  /// **'Frango'**
  String get settingsProteinChicken;

  /// Settings protein: ground meat
  ///
  /// In pt, this message translates to:
  /// **'Carne Picada'**
  String get settingsProteinGroundMeat;

  /// Settings protein: pork
  ///
  /// In pt, this message translates to:
  /// **'Porco'**
  String get settingsProteinPork;

  /// Settings protein: hake
  ///
  /// In pt, this message translates to:
  /// **'Pescada'**
  String get settingsProteinHake;

  /// Settings protein: cod
  ///
  /// In pt, this message translates to:
  /// **'Bacalhau'**
  String get settingsProteinCod;

  /// Settings protein: sardine
  ///
  /// In pt, this message translates to:
  /// **'Sardinha'**
  String get settingsProteinSardine;

  /// Settings protein: tuna
  ///
  /// In pt, this message translates to:
  /// **'Atum'**
  String get settingsProteinTuna;

  /// Settings protein: eggs
  ///
  /// In pt, this message translates to:
  /// **'Ovos'**
  String get settingsProteinEgg;

  /// Settings label: max prep time
  ///
  /// In pt, this message translates to:
  /// **'TEMPO MÃXIMO (MINUTOS)'**
  String get settingsMaxPrepTime;

  /// Settings label: max complexity
  ///
  /// In pt, this message translates to:
  /// **'COMPLEXIDADE MÃXIMA ({value}/5)'**
  String settingsMaxComplexity(int value);

  /// Settings label: weekend prep time
  ///
  /// In pt, this message translates to:
  /// **'TEMPO FIM-DE-SEMANA (MINUTOS)'**
  String get settingsWeekendPrepTime;

  /// Settings label: weekend complexity
  ///
  /// In pt, this message translates to:
  /// **'COMPLEXIDADE FIM-DE-SEMANA ({value}/5)'**
  String settingsWeekendComplexity(int value);

  /// Settings label: eating out days
  ///
  /// In pt, this message translates to:
  /// **'DIAS DE COMER FORA'**
  String get settingsEatingOutDays;

  /// Settings label: weekly distribution
  ///
  /// In pt, this message translates to:
  /// **'DISTRIBUIÃ‡ÃƒO SEMANAL'**
  String get settingsWeeklyDistribution;

  /// Settings fish days per week display
  ///
  /// In pt, this message translates to:
  /// **'Peixe por semana: {count}'**
  String settingsFishPerWeek(String count);

  /// Settings no minimum label
  ///
  /// In pt, this message translates to:
  /// **'sem mÃ­nimo'**
  String get settingsNoMinimum;

  /// Settings legume days per week display
  ///
  /// In pt, this message translates to:
  /// **'Leguminosas por semana: {count}'**
  String settingsLegumePerWeek(String count);

  /// Settings red meat max per week display
  ///
  /// In pt, this message translates to:
  /// **'Carne vermelha mÃ¡x/semana: {count}'**
  String settingsRedMeatPerWeek(String count);

  /// Settings no limit label
  ///
  /// In pt, this message translates to:
  /// **'sem limite'**
  String get settingsNoLimit;

  /// Settings label: available equipment
  ///
  /// In pt, this message translates to:
  /// **'EQUIPAMENTO DISPONÃVEL'**
  String get settingsAvailableEquipment;

  /// Settings toggle: batch cooking
  ///
  /// In pt, this message translates to:
  /// **'Batch cooking'**
  String get settingsBatchCooking;

  /// Settings label: max batch days
  ///
  /// In pt, this message translates to:
  /// **'MÃXIMO DE DIAS POR RECEITA'**
  String get settingsMaxBatchDays;

  /// Settings toggle: reuse leftovers
  ///
  /// In pt, this message translates to:
  /// **'Reaproveitar sobras'**
  String get settingsReuseLeftovers;

  /// Settings toggle: minimize waste
  ///
  /// In pt, this message translates to:
  /// **'Minimizar desperdÃ­cio'**
  String get settingsMinimizeWaste;

  /// Settings toggle: prioritize low cost
  ///
  /// In pt, this message translates to:
  /// **'Priorizar custo baixo'**
  String get settingsPrioritizeLowCost;

  /// Settings toggle desc: prioritize low cost
  ///
  /// In pt, this message translates to:
  /// **'Preferir receitas mais econÃ³micas'**
  String get settingsPrioritizeLowCostDesc;

  /// Settings label: new ingredients per week
  ///
  /// In pt, this message translates to:
  /// **'INGREDIENTES NOVOS POR SEMANA ({count})'**
  String settingsNewIngredientsPerWeek(int count);

  /// Settings toggle: lunchbox lunches
  ///
  /// In pt, this message translates to:
  /// **'AlmoÃ§os de marmita'**
  String get settingsLunchboxLunches;

  /// Settings toggle desc: lunchbox lunches
  ///
  /// In pt, this message translates to:
  /// **'Apenas receitas transportÃ¡veis ao almoÃ§o'**
  String get settingsLunchboxLunchesDesc;

  /// Settings label: pantry
  ///
  /// In pt, this message translates to:
  /// **'DESPENSA (SEMPRE EM STOCK)'**
  String get settingsPantry;

  /// Settings reset wizard button
  ///
  /// In pt, this message translates to:
  /// **'Repor Wizard'**
  String get settingsResetWizard;

  /// Settings API key info text
  ///
  /// In pt, this message translates to:
  /// **'A key Ã© guardada localmente no dispositivo e nunca Ã© partilhada. Usa o modelo GPT-4o mini (~â‚¬0,00008 por anÃ¡lise).'**
  String get settingsApiKeyInfo;

  /// Settings label: invite code
  ///
  /// In pt, this message translates to:
  /// **'CÃ“DIGO DE CONVITE'**
  String get settingsInviteCodeLabel;

  /// Settings generate invite code
  ///
  /// In pt, this message translates to:
  /// **'Gerar cÃ³digo de convite'**
  String get settingsGenerateInvite;

  /// Settings share invite code info
  ///
  /// In pt, this message translates to:
  /// **'Partilha com membros do agregado'**
  String get settingsShareWithMembers;

  /// Settings new code tooltip
  ///
  /// In pt, this message translates to:
  /// **'Novo cÃ³digo'**
  String get settingsNewCode;

  /// Settings invite code validity info
  ///
  /// In pt, this message translates to:
  /// **'O cÃ³digo Ã© vÃ¡lido por 7 dias. Partilha-o com quem queres adicionar ao agregado.'**
  String get settingsCodeValidInfo;

  /// Settings field: name
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get settingsName;

  /// Settings field: age group
  ///
  /// In pt, this message translates to:
  /// **'Faixa etÃ¡ria'**
  String get settingsAgeGroup;

  /// Settings field: activity level
  ///
  /// In pt, this message translates to:
  /// **'NÃ­vel de atividade'**
  String get settingsActivityLevel;

  /// Settings salary number placeholder
  ///
  /// In pt, this message translates to:
  /// **'Vencimento {n}'**
  String settingsSalaryN(int n);

  /// Country name: Portugal
  ///
  /// In pt, this message translates to:
  /// **'Portugal'**
  String get countryPT;

  /// Country name: Spain
  ///
  /// In pt, this message translates to:
  /// **'Espanha'**
  String get countryES;

  /// Country name: France
  ///
  /// In pt, this message translates to:
  /// **'FranÃ§a'**
  String get countryFR;

  /// Country name: United Kingdom
  ///
  /// In pt, this message translates to:
  /// **'Reino Unido'**
  String get countryUK;

  /// Language name: Portuguese
  ///
  /// In pt, this message translates to:
  /// **'PortuguÃªs'**
  String get langPT;

  /// Language name: English
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get langEN;

  /// Language name: French
  ///
  /// In pt, this message translates to:
  /// **'FranÃ§ais'**
  String get langFR;

  /// Language name: Spanish
  ///
  /// In pt, this message translates to:
  /// **'EspaÃ±ol'**
  String get langES;

  /// Language option: system default
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get langSystem;

  /// Tax label: income tax (generic)
  ///
  /// In pt, this message translates to:
  /// **'Imposto sobre rendimento'**
  String get taxIncomeTax;

  /// Tax label: social contribution (generic)
  ///
  /// In pt, this message translates to:
  /// **'ContribuiÃ§Ã£o social'**
  String get taxSocialContribution;

  /// Tax label: IRS (Portugal)
  ///
  /// In pt, this message translates to:
  /// **'IRS'**
  String get taxIRS;

  /// Tax label: Social Security (Portugal)
  ///
  /// In pt, this message translates to:
  /// **'SeguranÃ§a Social'**
  String get taxSS;

  /// Tax label: IRPF (Spain)
  ///
  /// In pt, this message translates to:
  /// **'IRPF'**
  String get taxIRPF;

  /// Tax label: Social Security (Spain)
  ///
  /// In pt, this message translates to:
  /// **'Seguridad Social'**
  String get taxSSSpain;

  /// Tax label: Income Tax (France)
  ///
  /// In pt, this message translates to:
  /// **'ImpÃ´t sur le Revenu'**
  String get taxIR;

  /// Tax label: CSG + CRDS (France)
  ///
  /// In pt, this message translates to:
  /// **'CSG + CRDS'**
  String get taxCSG;

  /// Tax label: PAYE Income Tax (UK)
  ///
  /// In pt, this message translates to:
  /// **'Income Tax'**
  String get taxPAYE;

  /// Tax label: National Insurance (UK)
  ///
  /// In pt, this message translates to:
  /// **'National Insurance'**
  String get taxNI;

  /// ES subsidy mode: no extra pay
  ///
  /// In pt, this message translates to:
  /// **'Sin pagas extras'**
  String get enumSubsidyEsNone;

  /// ES subsidy mode: with extra pay
  ///
  /// In pt, this message translates to:
  /// **'Con pagas extras'**
  String get enumSubsidyEsFull;

  /// ES subsidy mode: half extra pay
  ///
  /// In pt, this message translates to:
  /// **'50% pagas extras'**
  String get enumSubsidyEsHalf;

  /// AI coach system prompt for financial analysis
  ///
  /// In pt, this message translates to:
  /// **'Ã‰s um analista financeiro pessoal para utilizadores portugueses. Responde sempre em portuguÃªs europeu. SÃª directo e analÃ­tico â€” usa sempre nÃºmeros concretos do contexto fornecido. Estrutura a resposta exactamente nas 3 partes pedidas. NÃ£o introduzas dados, benchmarks ou referÃªncias externas que nÃ£o foram fornecidos.'**
  String get aiCoachSystemPrompt;

  /// AI coach invalid API key error
  ///
  /// In pt, this message translates to:
  /// **'API key invÃ¡lida. Verifica nas DefiniÃ§Ãµes.'**
  String get aiCoachInvalidApiKey;

  /// AI coach mid-month system prompt
  ///
  /// In pt, this message translates to:
  /// **'Ã‰s um consultor de orÃ§amento domÃ©stico portuguÃªs. Responde sempre em portuguÃªs europeu. SÃª prÃ¡tico e directo.'**
  String get aiCoachMidMonthSystem;

  /// AI meal planner system prompt
  ///
  /// In pt, this message translates to:
  /// **'Ã‰s um chef portuguÃªs. Responde sempre em portuguÃªs europeu. Responde APENAS com JSON vÃ¡lido, sem texto extra.'**
  String get aiMealPlannerSystem;

  /// Month abbreviation: January
  ///
  /// In pt, this message translates to:
  /// **'Jan'**
  String get monthAbbrJan;

  /// Month abbreviation: February
  ///
  /// In pt, this message translates to:
  /// **'Fev'**
  String get monthAbbrFeb;

  /// Month abbreviation: March
  ///
  /// In pt, this message translates to:
  /// **'Mar'**
  String get monthAbbrMar;

  /// Month abbreviation: April
  ///
  /// In pt, this message translates to:
  /// **'Abr'**
  String get monthAbbrApr;

  /// Month abbreviation: May
  ///
  /// In pt, this message translates to:
  /// **'Mai'**
  String get monthAbbrMay;

  /// Month abbreviation: June
  ///
  /// In pt, this message translates to:
  /// **'Jun'**
  String get monthAbbrJun;

  /// Month abbreviation: July
  ///
  /// In pt, this message translates to:
  /// **'Jul'**
  String get monthAbbrJul;

  /// Month abbreviation: August
  ///
  /// In pt, this message translates to:
  /// **'Ago'**
  String get monthAbbrAug;

  /// Month abbreviation: September
  ///
  /// In pt, this message translates to:
  /// **'Set'**
  String get monthAbbrSep;

  /// Month abbreviation: October
  ///
  /// In pt, this message translates to:
  /// **'Out'**
  String get monthAbbrOct;

  /// Month abbreviation: November
  ///
  /// In pt, this message translates to:
  /// **'Nov'**
  String get monthAbbrNov;

  /// Month abbreviation: December
  ///
  /// In pt, this message translates to:
  /// **'Dez'**
  String get monthAbbrDec;

  /// Full month name: January
  ///
  /// In pt, this message translates to:
  /// **'Janeiro'**
  String get monthFullJan;

  /// Full month name: February
  ///
  /// In pt, this message translates to:
  /// **'Fevereiro'**
  String get monthFullFeb;

  /// Full month name: March
  ///
  /// In pt, this message translates to:
  /// **'MarÃ§o'**
  String get monthFullMar;

  /// Full month name: April
  ///
  /// In pt, this message translates to:
  /// **'Abril'**
  String get monthFullApr;

  /// Full month name: May
  ///
  /// In pt, this message translates to:
  /// **'Maio'**
  String get monthFullMay;

  /// Full month name: June
  ///
  /// In pt, this message translates to:
  /// **'Junho'**
  String get monthFullJun;

  /// Full month name: July
  ///
  /// In pt, this message translates to:
  /// **'Julho'**
  String get monthFullJul;

  /// Full month name: August
  ///
  /// In pt, this message translates to:
  /// **'Agosto'**
  String get monthFullAug;

  /// Full month name: September
  ///
  /// In pt, this message translates to:
  /// **'Setembro'**
  String get monthFullSep;

  /// Full month name: October
  ///
  /// In pt, this message translates to:
  /// **'Outubro'**
  String get monthFullOct;

  /// Full month name: November
  ///
  /// In pt, this message translates to:
  /// **'Novembro'**
  String get monthFullNov;

  /// Full month name: December
  ///
  /// In pt, this message translates to:
  /// **'Dezembro'**
  String get monthFullDec;

  /// Setup wizard welcome screen title
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo ao seu orÃ§amento'**
  String get setupWizardWelcomeTitle;

  /// Setup wizard welcome screen subtitle
  ///
  /// In pt, this message translates to:
  /// **'Vamos configurar o essencial para que o seu painel fique pronto a usar.'**
  String get setupWizardWelcomeSubtitle;

  /// Setup wizard welcome bullet 1
  ///
  /// In pt, this message translates to:
  /// **'Calcular o seu salÃ¡rio lÃ­quido'**
  String get setupWizardBullet1;

  /// Setup wizard welcome bullet 2
  ///
  /// In pt, this message translates to:
  /// **'Organizar as suas despesas'**
  String get setupWizardBullet2;

  /// Setup wizard welcome bullet 3
  ///
  /// In pt, this message translates to:
  /// **'Ver quanto sobra cada mÃªs'**
  String get setupWizardBullet3;

  /// Reassurance text shown on welcome screen
  ///
  /// In pt, this message translates to:
  /// **'Pode alterar tudo mais tarde nas definiÃ§Ãµes.'**
  String get setupWizardReassurance;

  /// Start button on welcome screen
  ///
  /// In pt, this message translates to:
  /// **'ComeÃ§ar'**
  String get setupWizardStart;

  /// Skip all button on welcome screen
  ///
  /// In pt, this message translates to:
  /// **'Saltar configuraÃ§Ã£o'**
  String get setupWizardSkipAll;

  /// Step progress indicator
  ///
  /// In pt, this message translates to:
  /// **'Passo {step} de {total}'**
  String setupWizardStepOf(int step, int total);

  /// Continue button label
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get setupWizardContinue;

  /// Country step title
  ///
  /// In pt, this message translates to:
  /// **'Onde vive?'**
  String get setupWizardCountryTitle;

  /// Country step subtitle
  ///
  /// In pt, this message translates to:
  /// **'Isto define o sistema fiscal, moeda e valores por defeito.'**
  String get setupWizardCountrySubtitle;

  /// Language dropdown label
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get setupWizardLanguage;

  /// System default language option
  ///
  /// In pt, this message translates to:
  /// **'PredefiniÃ§Ã£o do sistema'**
  String get setupWizardLangSystem;

  /// Portugal country name
  ///
  /// In pt, this message translates to:
  /// **'Portugal'**
  String get setupWizardCountryPT;

  /// Spain country name
  ///
  /// In pt, this message translates to:
  /// **'Espanha'**
  String get setupWizardCountryES;

  /// France country name
  ///
  /// In pt, this message translates to:
  /// **'FranÃ§a'**
  String get setupWizardCountryFR;

  /// UK country name
  ///
  /// In pt, this message translates to:
  /// **'Reino Unido'**
  String get setupWizardCountryUK;

  /// Personal info step title
  ///
  /// In pt, this message translates to:
  /// **'InformaÃ§Ã£o pessoal'**
  String get setupWizardPersonalTitle;

  /// Personal info step subtitle
  ///
  /// In pt, this message translates to:
  /// **'Usamos isto para calcular os seus impostos com mais precisÃ£o.'**
  String get setupWizardPersonalSubtitle;

  /// Privacy note on personal info step
  ///
  /// In pt, this message translates to:
  /// **'Os seus dados ficam na sua conta e nunca sÃ£o partilhados.'**
  String get setupWizardPrivacyNote;

  /// Single marital status card
  ///
  /// In pt, this message translates to:
  /// **'Solteiro(a)'**
  String get setupWizardSingle;

  /// Married marital status card
  ///
  /// In pt, this message translates to:
  /// **'Casado(a)'**
  String get setupWizardMarried;

  /// Dependents label
  ///
  /// In pt, this message translates to:
  /// **'Dependentes'**
  String get setupWizardDependents;

  /// Tax holders label (PT only)
  ///
  /// In pt, this message translates to:
  /// **'Titulares'**
  String get setupWizardTitulares;

  /// Salary step title
  ///
  /// In pt, this message translates to:
  /// **'Qual Ã© o seu salÃ¡rio?'**
  String get setupWizardSalaryTitle;

  /// Salary step subtitle
  ///
  /// In pt, this message translates to:
  /// **'Introduza o valor bruto mensal. Calculamos o lÃ­quido automaticamente.'**
  String get setupWizardSalarySubtitle;

  /// Gross salary field label
  ///
  /// In pt, this message translates to:
  /// **'SalÃ¡rio bruto mensal'**
  String get setupWizardSalaryGross;

  /// Inline net salary estimate
  ///
  /// In pt, this message translates to:
  /// **'LÃ­quido estimado: {amount}'**
  String setupWizardNetEstimate(String amount);

  /// Info text on salary step
  ///
  /// In pt, this message translates to:
  /// **'Pode adicionar mais fontes de rendimento mais tarde.'**
  String get setupWizardSalaryMoreLater;

  /// No description provided for @setupWizardSalaryRequired.
  ///
  /// In pt, this message translates to:
  /// **'Por favor insira o seu salÃ¡rio'**
  String get setupWizardSalaryRequired;

  /// No description provided for @setupWizardSalaryPositive.
  ///
  /// In pt, this message translates to:
  /// **'O salÃ¡rio deve ser um nÃºmero positivo'**
  String get setupWizardSalaryPositive;

  /// Skip button on salary step
  ///
  /// In pt, this message translates to:
  /// **'Saltar este passo'**
  String get setupWizardSalarySkip;

  /// Expenses step title
  ///
  /// In pt, this message translates to:
  /// **'As suas despesas mensais'**
  String get setupWizardExpensesTitle;

  /// Expenses step subtitle
  ///
  /// In pt, this message translates to:
  /// **'Valores sugeridos para o seu paÃ­s. Ajuste conforme necessÃ¡rio.'**
  String get setupWizardExpensesSubtitle;

  /// Info text on expenses step
  ///
  /// In pt, this message translates to:
  /// **'Pode adicionar mais categorias mais tarde.'**
  String get setupWizardExpensesMoreLater;

  /// Net salary label on expenses step
  ///
  /// In pt, this message translates to:
  /// **'LÃ­quido: {amount}'**
  String setupWizardNetLabel(String amount);

  /// Total expenses label
  ///
  /// In pt, this message translates to:
  /// **'Despesas: {amount}'**
  String setupWizardTotalExpenses(String amount);

  /// Available amount label on completion screen
  ///
  /// In pt, this message translates to:
  /// **'DisponÃ­vel: {amount}'**
  String setupWizardAvailableLabel(String amount);

  /// Finish button on expenses step
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get setupWizardFinish;

  /// Completion screen title
  ///
  /// In pt, this message translates to:
  /// **'Tudo pronto!'**
  String get setupWizardCompleteTitle;

  /// Reassurance text on completion screen
  ///
  /// In pt, this message translates to:
  /// **'O seu orÃ§amento estÃ¡ configurado. Pode ajustar tudo nas definiÃ§Ãµes a qualquer momento.'**
  String get setupWizardCompleteReassurance;

  /// Button to go to dashboard from completion screen
  ///
  /// In pt, this message translates to:
  /// **'Ver o meu orÃ§amento'**
  String get setupWizardGoToDashboard;

  /// Hint when salary not configured
  ///
  /// In pt, this message translates to:
  /// **'Configure o seu salÃ¡rio nas definiÃ§Ãµes para ver o cÃ¡lculo completo.'**
  String get setupWizardConfigureSalaryHint;

  /// Rent expense category
  ///
  /// In pt, this message translates to:
  /// **'Renda / PrestaÃ§Ã£o'**
  String get setupWizardExpRent;

  /// Groceries expense category
  ///
  /// In pt, this message translates to:
  /// **'AlimentaÃ§Ã£o'**
  String get setupWizardExpGroceries;

  /// Transport expense category
  ///
  /// In pt, this message translates to:
  /// **'Transportes'**
  String get setupWizardExpTransport;

  /// Utilities expense category
  ///
  /// In pt, this message translates to:
  /// **'Utilidades (luz, Ã¡gua, gÃ¡s)'**
  String get setupWizardExpUtilities;

  /// Telecom expense category
  ///
  /// In pt, this message translates to:
  /// **'TelecomunicaÃ§Ãµes'**
  String get setupWizardExpTelecom;

  /// Health expense category
  ///
  /// In pt, this message translates to:
  /// **'SaÃºde'**
  String get setupWizardExpHealth;

  /// Leisure expense category
  ///
  /// In pt, this message translates to:
  /// **'Lazer'**
  String get setupWizardExpLeisure;

  /// Budget vs actual card title
  ///
  /// In pt, this message translates to:
  /// **'ORÃ‡AMENTO VS REAL'**
  String get expenseTrackerTitle;

  /// Budgeted label
  ///
  /// In pt, this message translates to:
  /// **'OrÃ§amentado'**
  String get expenseTrackerBudgeted;

  /// Actual label
  ///
  /// In pt, this message translates to:
  /// **'Real'**
  String get expenseTrackerActual;

  /// Remaining label
  ///
  /// In pt, this message translates to:
  /// **'Restante'**
  String get expenseTrackerRemaining;

  /// Over budget label
  ///
  /// In pt, this message translates to:
  /// **'Acima do orÃ§amento'**
  String get expenseTrackerOver;

  /// View all link
  ///
  /// In pt, this message translates to:
  /// **'Ver detalhes'**
  String get expenseTrackerViewAll;

  /// No expenses empty state
  ///
  /// In pt, this message translates to:
  /// **'Ainda sem despesas registadas.'**
  String get expenseTrackerNoExpenses;

  /// Expense tracker screen title
  ///
  /// In pt, this message translates to:
  /// **'Controlo de Despesas'**
  String get expenseTrackerScreenTitle;

  /// Month total label
  ///
  /// In pt, this message translates to:
  /// **'Total: {amount}'**
  String expenseTrackerMonthTotal(String amount);

  /// Delete expense confirmation
  ///
  /// In pt, this message translates to:
  /// **'Eliminar esta despesa?'**
  String get expenseTrackerDeleteConfirm;

  /// Empty state for tracker screen
  ///
  /// In pt, this message translates to:
  /// **'Sem despesas este mÃªs.\nToca + para adicionar a primeira.'**
  String get expenseTrackerEmpty;

  /// Add expense sheet title
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Despesa'**
  String get addExpenseTitle;

  /// Edit expense sheet title
  ///
  /// In pt, this message translates to:
  /// **'Editar Despesa'**
  String get editExpenseTitle;

  /// Category field label
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get addExpenseCategory;

  /// Amount field label
  ///
  /// In pt, this message translates to:
  /// **'Montante'**
  String get addExpenseAmount;

  /// Date field label
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get addExpenseDate;

  /// Description field label
  ///
  /// In pt, this message translates to:
  /// **'DescriÃ§Ã£o (opcional)'**
  String get addExpenseDescription;

  /// Custom category hint
  ///
  /// In pt, this message translates to:
  /// **'Categoria personalizada'**
  String get addExpenseCustomCategory;

  /// Invalid amount error
  ///
  /// In pt, this message translates to:
  /// **'Introduza um valor vÃ¡lido'**
  String get addExpenseInvalidAmount;

  /// FAB tooltip
  ///
  /// In pt, this message translates to:
  /// **'Registar despesa'**
  String get addExpenseTooltip;

  /// Expense item section label
  ///
  /// In pt, this message translates to:
  /// **'Despesa'**
  String get addExpenseItem;

  /// Others chip label
  ///
  /// In pt, this message translates to:
  /// **'Outros'**
  String get addExpenseOthers;

  /// Settings dashboard toggle: budget vs actual
  ///
  /// In pt, this message translates to:
  /// **'OrÃ§amento vs Real'**
  String get settingsDashBudgetVsActual;

  /// Settings section: appearance
  ///
  /// In pt, this message translates to:
  /// **'AparÃªncia'**
  String get settingsAppearance;

  /// Theme setting label
  ///
  /// In pt, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// System theme option
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// Light theme option
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// Dark theme option
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get themeDark;

  /// Recurring expenses title
  ///
  /// In pt, this message translates to:
  /// **'Pagamentos Recorrentes'**
  String get recurringExpenses;

  /// Add recurring expense
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Pagamento Recorrente'**
  String get recurringExpenseAdd;

  /// Edit recurring expense
  ///
  /// In pt, this message translates to:
  /// **'Editar Pagamento Recorrente'**
  String get recurringExpenseEdit;

  /// Category field
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get recurringExpenseCategory;

  /// Amount field
  ///
  /// In pt, this message translates to:
  /// **'Montante'**
  String get recurringExpenseAmount;

  /// Description field
  ///
  /// In pt, this message translates to:
  /// **'DescriÃ§Ã£o (opcional)'**
  String get recurringExpenseDescription;

  /// Day of month field
  ///
  /// In pt, this message translates to:
  /// **'Dia de vencimento'**
  String get recurringExpenseDayOfMonth;

  /// Active toggle label
  ///
  /// In pt, this message translates to:
  /// **'Ativa'**
  String get recurringExpenseActive;

  /// Inactive label
  ///
  /// In pt, this message translates to:
  /// **'Inativa'**
  String get recurringExpenseInactive;

  /// Empty state message
  ///
  /// In pt, this message translates to:
  /// **'Sem pagamentos recorrentes.\nAdicione para gerar automaticamente todos os meses.'**
  String get recurringExpenseEmpty;

  /// Delete confirmation
  ///
  /// In pt, this message translates to:
  /// **'Eliminar este pagamento recorrente?'**
  String get recurringExpenseDeleteConfirm;

  /// Badge for auto-created expenses
  ///
  /// In pt, this message translates to:
  /// **'Criada automaticamente'**
  String get recurringExpenseAutoCreated;

  /// Manage recurring button
  ///
  /// In pt, this message translates to:
  /// **'Gerir pagamentos recorrentes'**
  String get recurringExpenseManage;

  /// Toggle to mark expense as recurring
  ///
  /// In pt, this message translates to:
  /// **'Marcar como pagamento recorrente'**
  String get recurringExpenseMarkRecurring;

  /// Snackbar when recurring populated
  ///
  /// In pt, this message translates to:
  /// **'Pagamentos recorrentes gerados para este mÃªs'**
  String get recurringExpensePopulated;

  /// Hint for day of month field
  ///
  /// In pt, this message translates to:
  /// **'Ex: 1 para dia 1'**
  String get recurringExpenseDayHint;

  /// Label when no day set
  ///
  /// In pt, this message translates to:
  /// **'Sem dia fixo'**
  String get recurringExpenseNoDay;

  /// Snackbar on save
  ///
  /// In pt, this message translates to:
  /// **'Pagamento recorrente guardado'**
  String get recurringExpenseSaved;

  /// Toggle label for recurring payment per budget item
  ///
  /// In pt, this message translates to:
  /// **'Pagamento recorrente'**
  String get recurringPaymentToggle;

  /// No description provided for @billsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} pagamentos'**
  String billsCount(int count);

  /// No description provided for @billsNone.
  ///
  /// In pt, this message translates to:
  /// **'Sem pagamentos recorrentes'**
  String get billsNone;

  /// No description provided for @billsPerMonth.
  ///
  /// In pt, this message translates to:
  /// **'{count} pagamentos Â· {amount}/mÃªs'**
  String billsPerMonth(int count, String amount);

  /// No description provided for @billsExceedBudget.
  ///
  /// In pt, this message translates to:
  /// **'Contas ({amount}) excedem orÃ§amento'**
  String billsExceedBudget(String amount);

  /// No description provided for @billsAddBill.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Pagamento Recorrente'**
  String get billsAddBill;

  /// No description provided for @billsBudgetSettings.
  ///
  /// In pt, this message translates to:
  /// **'ConfiguraÃ§Ã£o do OrÃ§amento'**
  String get billsBudgetSettings;

  /// No description provided for @billsRecurringBills.
  ///
  /// In pt, this message translates to:
  /// **'Pagamentos Recorrentes'**
  String get billsRecurringBills;

  /// No description provided for @billsDescription.
  ///
  /// In pt, this message translates to:
  /// **'DescriÃ§Ã£o'**
  String get billsDescription;

  /// No description provided for @billsAmount.
  ///
  /// In pt, this message translates to:
  /// **'Montante'**
  String get billsAmount;

  /// No description provided for @billsDueDay.
  ///
  /// In pt, this message translates to:
  /// **'Dia de vencimento'**
  String get billsDueDay;

  /// No description provided for @billsActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativa'**
  String get billsActive;

  /// Expense trends screen title
  ///
  /// In pt, this message translates to:
  /// **'TendÃªncias de Despesas'**
  String get expenseTrends;

  /// Button to open trends
  ///
  /// In pt, this message translates to:
  /// **'Ver TendÃªncias'**
  String get expenseTrendsViewTrends;

  /// 3 months chip
  ///
  /// In pt, this message translates to:
  /// **'3M'**
  String get expenseTrends3Months;

  /// 6 months chip
  ///
  /// In pt, this message translates to:
  /// **'6M'**
  String get expenseTrends6Months;

  /// 12 months chip
  ///
  /// In pt, this message translates to:
  /// **'12M'**
  String get expenseTrends12Months;

  /// Budgeted line label
  ///
  /// In pt, this message translates to:
  /// **'OrÃ§amentado'**
  String get expenseTrendsBudgeted;

  /// Actual line label
  ///
  /// In pt, this message translates to:
  /// **'Real'**
  String get expenseTrendsActual;

  /// Category breakdown header
  ///
  /// In pt, this message translates to:
  /// **'Por Categoria'**
  String get expenseTrendsByCategory;

  /// No data message
  ///
  /// In pt, this message translates to:
  /// **'Sem dados suficientes para mostrar tendÃªncias.'**
  String get expenseTrendsNoData;

  /// Total label
  ///
  /// In pt, this message translates to:
  /// **'Total'**
  String get expenseTrendsTotal;

  /// Average label
  ///
  /// In pt, this message translates to:
  /// **'MÃ©dia'**
  String get expenseTrendsAverage;

  /// Overview tab label
  ///
  /// In pt, this message translates to:
  /// **'VisÃ£o Geral'**
  String get expenseTrendsOverview;

  /// Monthly label
  ///
  /// In pt, this message translates to:
  /// **'Mensal'**
  String get expenseTrendsMonthly;

  /// Savings goals title
  ///
  /// In pt, this message translates to:
  /// **'Objetivos de PoupanÃ§a'**
  String get savingsGoals;

  /// Add savings goal
  ///
  /// In pt, this message translates to:
  /// **'Novo Objetivo'**
  String get savingsGoalAdd;

  /// Edit savings goal
  ///
  /// In pt, this message translates to:
  /// **'Editar Objetivo'**
  String get savingsGoalEdit;

  /// Goal name field
  ///
  /// In pt, this message translates to:
  /// **'Nome do objetivo'**
  String get savingsGoalName;

  /// Target amount field
  ///
  /// In pt, this message translates to:
  /// **'Valor alvo'**
  String get savingsGoalTarget;

  /// Current amount label
  ///
  /// In pt, this message translates to:
  /// **'Valor atual'**
  String get savingsGoalCurrent;

  /// Deadline field
  ///
  /// In pt, this message translates to:
  /// **'Data limite'**
  String get savingsGoalDeadline;

  /// No deadline label
  ///
  /// In pt, this message translates to:
  /// **'Sem data limite'**
  String get savingsGoalNoDeadline;

  /// Color picker label
  ///
  /// In pt, this message translates to:
  /// **'Cor'**
  String get savingsGoalColor;

  /// Progress percentage
  ///
  /// In pt, this message translates to:
  /// **'{percent}% alcanÃ§ado'**
  String savingsGoalProgress(String percent);

  /// Remaining amount
  ///
  /// In pt, this message translates to:
  /// **'Faltam {amount}'**
  String savingsGoalRemaining(String amount);

  /// Goal completed message
  ///
  /// In pt, this message translates to:
  /// **'Objetivo alcanÃ§ado!'**
  String get savingsGoalCompleted;

  /// Empty state
  ///
  /// In pt, this message translates to:
  /// **'Sem objetivos de poupanÃ§a.\nCrie um para acompanhar o progresso.'**
  String get savingsGoalEmpty;

  /// Delete confirmation
  ///
  /// In pt, this message translates to:
  /// **'Eliminar este objetivo?'**
  String get savingsGoalDeleteConfirm;

  /// Add contribution button
  ///
  /// In pt, this message translates to:
  /// **'Contribuir'**
  String get savingsGoalContribute;

  /// Contribution amount field
  ///
  /// In pt, this message translates to:
  /// **'Valor da contribuiÃ§Ã£o'**
  String get savingsGoalContributionAmount;

  /// Contribution note field
  ///
  /// In pt, this message translates to:
  /// **'Nota (opcional)'**
  String get savingsGoalContributionNote;

  /// Contribution date field
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get savingsGoalContributionDate;

  /// Contribution history header
  ///
  /// In pt, this message translates to:
  /// **'HistÃ³rico de ContribuiÃ§Ãµes'**
  String get savingsGoalContributionHistory;

  /// See all goals button
  ///
  /// In pt, this message translates to:
  /// **'Ver todos'**
  String get savingsGoalSeeAll;

  /// Surplus suggestion card
  ///
  /// In pt, this message translates to:
  /// **'Tiveste {amount} de excedente no mÃªs passado â€” queres alocar a um objetivo?'**
  String savingsGoalSurplusSuggestion(String amount);

  /// Allocate button
  ///
  /// In pt, this message translates to:
  /// **'Alocar'**
  String get savingsGoalAllocate;

  /// Snackbar on save
  ///
  /// In pt, this message translates to:
  /// **'Objetivo guardado'**
  String get savingsGoalSaved;

  /// Snackbar on contribution
  ///
  /// In pt, this message translates to:
  /// **'ContribuiÃ§Ã£o registada'**
  String get savingsGoalContributionSaved;

  /// Dashboard toggle for savings goals
  ///
  /// In pt, this message translates to:
  /// **'Objetivos de PoupanÃ§a'**
  String get settingsDashSavingsGoals;

  /// Active label
  ///
  /// In pt, this message translates to:
  /// **'Ativo'**
  String get savingsGoalActive;

  /// Inactive label
  ///
  /// In pt, this message translates to:
  /// **'Inativo'**
  String get savingsGoalInactive;

  /// Days until deadline
  ///
  /// In pt, this message translates to:
  /// **'{days} dias restantes'**
  String savingsGoalDaysLeft(String days);

  /// Overdue label
  ///
  /// In pt, this message translates to:
  /// **'Prazo ultrapassado'**
  String get savingsGoalOverdue;

  /// Meal cost reconciliation title
  ///
  /// In pt, this message translates to:
  /// **'Custos de RefeiÃ§Ãµes'**
  String get mealCostReconciliation;

  /// Estimated cost label
  ///
  /// In pt, this message translates to:
  /// **'Estimado'**
  String get mealCostEstimated;

  /// Actual cost label
  ///
  /// In pt, this message translates to:
  /// **'Real'**
  String get mealCostActual;

  /// Week label
  ///
  /// In pt, this message translates to:
  /// **'Semana {number}'**
  String mealCostWeek(String number);

  /// Monthly total label
  ///
  /// In pt, this message translates to:
  /// **'Total do MÃªs'**
  String get mealCostTotal;

  /// Savings indicator
  ///
  /// In pt, this message translates to:
  /// **'PoupanÃ§a'**
  String get mealCostSavings;

  /// Overrun indicator
  ///
  /// In pt, this message translates to:
  /// **'Excesso'**
  String get mealCostOverrun;

  /// No meal purchase data
  ///
  /// In pt, this message translates to:
  /// **'Sem dados de compras para refeiÃ§Ãµes.'**
  String get mealCostNoData;

  /// Button to open reconciliation
  ///
  /// In pt, this message translates to:
  /// **'Custos'**
  String get mealCostViewCosts;

  /// Checkbox label in finalize
  ///
  /// In pt, this message translates to:
  /// **'Compra para refeiÃ§Ãµes'**
  String get mealCostIsMealPurchase;

  /// Vs budget label
  ///
  /// In pt, this message translates to:
  /// **'vs orÃ§amento'**
  String get mealCostVsBudget;

  /// On track message
  ///
  /// In pt, this message translates to:
  /// **'Dentro do orÃ§amento'**
  String get mealCostOnTrack;

  /// Over budget message
  ///
  /// In pt, this message translates to:
  /// **'Acima do orÃ§amento'**
  String get mealCostOver;

  /// Under budget message
  ///
  /// In pt, this message translates to:
  /// **'Abaixo do orÃ§amento'**
  String get mealCostUnder;

  /// Variation label for AI recipe content
  ///
  /// In pt, this message translates to:
  /// **'VariaÃ§Ã£o'**
  String get mealVariation;

  /// Pairing suggestion label
  ///
  /// In pt, this message translates to:
  /// **'Acompanhamento'**
  String get mealPairing;

  /// Storage info label
  ///
  /// In pt, this message translates to:
  /// **'ConservaÃ§Ã£o'**
  String get mealStorage;

  /// Leftover badge label
  ///
  /// In pt, this message translates to:
  /// **'Sobras'**
  String get mealLeftover;

  /// Leftover transformation idea label
  ///
  /// In pt, this message translates to:
  /// **'Ideia de reaproveitamento'**
  String get mealLeftoverIdea;

  /// Weekly nutrition summary header
  ///
  /// In pt, this message translates to:
  /// **'NutriÃ§Ã£o Semanal'**
  String get mealWeeklySummary;

  /// Batch cooking prep guide button
  ///
  /// In pt, this message translates to:
  /// **'Cozinha em Lote'**
  String get mealBatchPrepGuide;

  /// Per-meal preparation guide button
  ///
  /// In pt, this message translates to:
  /// **'PreparaÃ§Ã£o'**
  String get mealViewPrepGuide;

  /// Title for the per-meal preparation guide sheet
  ///
  /// In pt, this message translates to:
  /// **'Como Preparar'**
  String get mealPrepGuideTitle;

  /// Prep time label in guide
  ///
  /// In pt, this message translates to:
  /// **'Tempo: {minutes} min'**
  String mealPrepTime(String minutes);

  /// Batch cooking total time estimate
  ///
  /// In pt, this message translates to:
  /// **'Tempo estimado: {time}'**
  String mealBatchTotalTime(String time);

  /// Parallel cooking tips header
  ///
  /// In pt, this message translates to:
  /// **'Dicas de cozinha paralela'**
  String get mealBatchParallelTips;

  /// Label for liked meal feedback button
  ///
  /// In pt, this message translates to:
  /// **'Gostei'**
  String get mealFeedbackLike;

  /// Label for disliked meal feedback button
  ///
  /// In pt, this message translates to:
  /// **'NÃ£o gostei'**
  String get mealFeedbackDislike;

  /// Label for skipped meal feedback button
  ///
  /// In pt, this message translates to:
  /// **'Saltar'**
  String get mealFeedbackSkip;

  /// Rate recipe accessibility label
  ///
  /// In pt, this message translates to:
  /// **'Avaliar receita'**
  String get mealRateRecipe;

  /// Rating label
  ///
  /// In pt, this message translates to:
  /// **'{rating} estrelas'**
  String mealRatingLabel(int rating);

  /// Unrated label
  ///
  /// In pt, this message translates to:
  /// **'Sem avaliacao'**
  String get mealRatingUnrated;

  /// Notifications title
  ///
  /// In pt, this message translates to:
  /// **'NotificaÃ§Ãµes'**
  String get notifications;

  /// Notification settings title
  ///
  /// In pt, this message translates to:
  /// **'DefiniÃ§Ãµes de NotificaÃ§Ãµes'**
  String get notificationSettings;

  /// Preferred notification time label
  ///
  /// In pt, this message translates to:
  /// **'Hora preferida'**
  String get notificationPreferredTime;

  /// Preferred notification time description
  ///
  /// In pt, this message translates to:
  /// **'NotificaÃ§Ãµes agendadas usarÃ£o esta hora (exceto lembretes personalizados)'**
  String get notificationPreferredTimeDesc;

  /// Bill reminders toggle
  ///
  /// In pt, this message translates to:
  /// **'Lembretes de pagamentos'**
  String get notificationBillReminders;

  /// Days before bill due
  ///
  /// In pt, this message translates to:
  /// **'Dias antes do vencimento'**
  String get notificationBillReminderDays;

  /// Budget alerts toggle
  ///
  /// In pt, this message translates to:
  /// **'Alertas de orÃ§amento'**
  String get notificationBudgetAlerts;

  /// Budget alert threshold
  ///
  /// In pt, this message translates to:
  /// **'Limite de alerta ({percent}%)'**
  String notificationBudgetThreshold(String percent);

  /// Meal plan reminder toggle
  ///
  /// In pt, this message translates to:
  /// **'Lembrete de plano de refeiÃ§Ãµes'**
  String get notificationMealPlanReminder;

  /// Meal plan reminder description
  ///
  /// In pt, this message translates to:
  /// **'Notifica se nÃ£o hÃ¡ plano para o mÃªs atual'**
  String get notificationMealPlanReminderDesc;

  /// Custom reminders section
  ///
  /// In pt, this message translates to:
  /// **'Lembretes Personalizados'**
  String get notificationCustomReminders;

  /// Add custom reminder
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Lembrete'**
  String get notificationAddCustom;

  /// Custom reminder title field
  ///
  /// In pt, this message translates to:
  /// **'TÃ­tulo'**
  String get notificationCustomTitle;

  /// Custom reminder body field
  ///
  /// In pt, this message translates to:
  /// **'Mensagem'**
  String get notificationCustomBody;

  /// Custom reminder time field
  ///
  /// In pt, this message translates to:
  /// **'Hora'**
  String get notificationCustomTime;

  /// Custom reminder repeat field
  ///
  /// In pt, this message translates to:
  /// **'Repetir'**
  String get notificationCustomRepeat;

  /// Daily repeat option
  ///
  /// In pt, this message translates to:
  /// **'DiÃ¡rio'**
  String get notificationCustomRepeatDaily;

  /// Weekly repeat option
  ///
  /// In pt, this message translates to:
  /// **'Semanal'**
  String get notificationCustomRepeatWeekly;

  /// Monthly repeat option
  ///
  /// In pt, this message translates to:
  /// **'Mensal'**
  String get notificationCustomRepeatMonthly;

  /// No repeat option
  ///
  /// In pt, this message translates to:
  /// **'NÃ£o repetir'**
  String get notificationCustomRepeatNone;

  /// Custom reminder saved
  ///
  /// In pt, this message translates to:
  /// **'Lembrete guardado'**
  String get notificationCustomSaved;

  /// Delete custom reminder confirmation
  ///
  /// In pt, this message translates to:
  /// **'Eliminar este lembrete?'**
  String get notificationCustomDeleteConfirm;

  /// Empty custom reminders
  ///
  /// In pt, this message translates to:
  /// **'Sem lembretes personalizados.'**
  String get notificationEmpty;

  /// Bill notification title
  ///
  /// In pt, this message translates to:
  /// **'Pagamento a vencer: {name}'**
  String notificationBillTitle(String name);

  /// Bill notification body
  ///
  /// In pt, this message translates to:
  /// **'{amount} vence em {days} dias'**
  String notificationBillBody(String amount, String days);

  /// Budget alert title
  ///
  /// In pt, this message translates to:
  /// **'Alerta de orÃ§amento'**
  String get notificationBudgetTitle;

  /// Budget alert body
  ///
  /// In pt, this message translates to:
  /// **'JÃ¡ gastaste {percent}% do orÃ§amento mensal'**
  String notificationBudgetBody(String percent);

  /// Meal plan notification title
  ///
  /// In pt, this message translates to:
  /// **'Plano de refeiÃ§Ãµes'**
  String get notificationMealPlanTitle;

  /// Meal plan notification body
  ///
  /// In pt, this message translates to:
  /// **'Ainda nÃ£o geraste o plano de refeiÃ§Ãµes deste mÃªs'**
  String get notificationMealPlanBody;

  /// Permission required message
  ///
  /// In pt, this message translates to:
  /// **'PermissÃ£o de notificaÃ§Ãµes necessÃ¡ria'**
  String get notificationPermissionRequired;

  /// Select days label
  ///
  /// In pt, this message translates to:
  /// **'Selecionar dias'**
  String get notificationSelectDays;

  /// Color palette setting label
  ///
  /// In pt, this message translates to:
  /// **'Paleta de cores'**
  String get settingsColorPalette;

  /// Ocean palette name
  ///
  /// In pt, this message translates to:
  /// **'Oceano'**
  String get paletteOcean;

  /// Emerald palette name
  ///
  /// In pt, this message translates to:
  /// **'Esmeralda'**
  String get paletteEmerald;

  /// Violet palette name
  ///
  /// In pt, this message translates to:
  /// **'Violeta'**
  String get paletteViolet;

  /// Teal palette name
  ///
  /// In pt, this message translates to:
  /// **'Azul-petrÃ³leo'**
  String get paletteTeal;

  /// Sunset palette name
  ///
  /// In pt, this message translates to:
  /// **'PÃ´r do sol'**
  String get paletteSunset;

  /// Export button tooltip
  ///
  /// In pt, this message translates to:
  /// **'Exportar'**
  String get exportTooltip;

  /// Export sheet title
  ///
  /// In pt, this message translates to:
  /// **'Exportar mÃªs'**
  String get exportTitle;

  /// PDF export option
  ///
  /// In pt, this message translates to:
  /// **'RelatÃ³rio PDF'**
  String get exportPdf;

  /// PDF export description
  ///
  /// In pt, this message translates to:
  /// **'RelatÃ³rio formatado com orÃ§amento vs real'**
  String get exportPdfDesc;

  /// CSV export option
  ///
  /// In pt, this message translates to:
  /// **'Dados CSV'**
  String get exportCsv;

  /// CSV export description
  ///
  /// In pt, this message translates to:
  /// **'Dados brutos para folha de cÃ¡lculo'**
  String get exportCsvDesc;

  /// PDF report title
  ///
  /// In pt, this message translates to:
  /// **'RelatÃ³rio Mensal de Despesas'**
  String get exportReportTitle;

  /// Budget vs actual section header
  ///
  /// In pt, this message translates to:
  /// **'OrÃ§amento vs Real'**
  String get exportBudgetVsActual;

  /// Expense detail section header
  ///
  /// In pt, this message translates to:
  /// **'Detalhe de Despesas'**
  String get exportExpenseDetail;

  /// Search button label
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar'**
  String get searchExpenses;

  /// Search field hint
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar por descriÃ§Ã£o...'**
  String get searchExpensesHint;

  /// Date range label
  ///
  /// In pt, this message translates to:
  /// **'PerÃ­odo'**
  String get searchDateRange;

  /// No search results message
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma despesa encontrada'**
  String get searchNoResults;

  /// Search result count
  ///
  /// In pt, this message translates to:
  /// **'{count} resultados'**
  String searchResultCount(int count);

  /// Fixed expense type label
  ///
  /// In pt, this message translates to:
  /// **'Fixo'**
  String get expenseFixed;

  /// Variable expense type label
  ///
  /// In pt, this message translates to:
  /// **'VariÃ¡vel'**
  String get expenseVariable;

  /// Monthly budget hint with month name
  ///
  /// In pt, this message translates to:
  /// **'OrÃ§amento para {month}'**
  String monthlyBudgetHint(String month);

  /// Warning for unset variable budgets
  ///
  /// In pt, this message translates to:
  /// **'{count} orÃ§amentos variÃ¡veis por definir'**
  String unsetBudgetsWarning(int count);

  /// CTA to set budgets in settings
  ///
  /// In pt, this message translates to:
  /// **'Definir nas definiÃ§Ãµes'**
  String get unsetBudgetsCta;

  /// Projected spending amount
  ///
  /// In pt, this message translates to:
  /// **'ProjeÃ§Ã£o: {amount}'**
  String paceProjected(String amount);

  /// No description provided for @onbSkip.
  ///
  /// In pt, this message translates to:
  /// **'Saltar'**
  String get onbSkip;

  /// No description provided for @onbNext.
  ///
  /// In pt, this message translates to:
  /// **'Seguinte'**
  String get onbNext;

  /// No description provided for @onbGetStarted.
  ///
  /// In pt, this message translates to:
  /// **'ComeÃ§ar'**
  String get onbGetStarted;

  /// No description provided for @onbSlide0Title.
  ///
  /// In pt, this message translates to:
  /// **'O seu orÃ§amento, num relance'**
  String get onbSlide0Title;

  /// No description provided for @onbSlide0Body.
  ///
  /// In pt, this message translates to:
  /// **'O painel mostra a sua liquidez mensal, despesas e Ãndice de Serenidade.'**
  String get onbSlide0Body;

  /// No description provided for @onbSlide1Title.
  ///
  /// In pt, this message translates to:
  /// **'Registe cada despesa'**
  String get onbSlide1Title;

  /// No description provided for @onbSlide1Body.
  ///
  /// In pt, this message translates to:
  /// **'Toque + para registar uma compra. Atribua uma categoria e veja as barras atualizarem.'**
  String get onbSlide1Body;

  /// No description provided for @onbSlide2Title.
  ///
  /// In pt, this message translates to:
  /// **'Compre com lista'**
  String get onbSlide2Title;

  /// No description provided for @onbSlide2Body.
  ///
  /// In pt, this message translates to:
  /// **'Navegue produtos, monte a lista e finalize para registar o gasto automaticamente.'**
  String get onbSlide2Body;

  /// No description provided for @onbSlide3Title.
  ///
  /// In pt, this message translates to:
  /// **'O seu coach financeiro IA'**
  String get onbSlide3Title;

  /// No description provided for @onbSlide3Body.
  ///
  /// In pt, this message translates to:
  /// **'Obtenha uma anÃ¡lise em 3 partes baseada no seu orÃ§amento real â€” nÃ£o conselhos genÃ©ricos.'**
  String get onbSlide3Body;

  /// No description provided for @onbSlide4Title.
  ///
  /// In pt, this message translates to:
  /// **'Planeie refeiÃ§Ãµes no orÃ§amento'**
  String get onbSlide4Title;

  /// No description provided for @onbSlide4Body.
  ///
  /// In pt, this message translates to:
  /// **'Gere um plano mensal ajustado ao seu orÃ§amento alimentar e agregado familiar.'**
  String get onbSlide4Body;

  /// No description provided for @onbTourSkip.
  ///
  /// In pt, this message translates to:
  /// **'Saltar tour'**
  String get onbTourSkip;

  /// No description provided for @onbTourNext.
  ///
  /// In pt, this message translates to:
  /// **'Seguinte'**
  String get onbTourNext;

  /// No description provided for @onbTourDone.
  ///
  /// In pt, this message translates to:
  /// **'Entendido'**
  String get onbTourDone;

  /// No description provided for @onbTourDash1Title.
  ///
  /// In pt, this message translates to:
  /// **'Liquidez mensal'**
  String get onbTourDash1Title;

  /// No description provided for @onbTourDash1Body.
  ///
  /// In pt, this message translates to:
  /// **'Rendimento menos todas as despesas. Verde significa saldo positivo.'**
  String get onbTourDash1Body;

  /// No description provided for @onbTourDash2Title.
  ///
  /// In pt, this message translates to:
  /// **'Ãndice de Serenidade'**
  String get onbTourDash2Title;

  /// No description provided for @onbTourDash2Body.
  ///
  /// In pt, this message translates to:
  /// **'PontuaÃ§Ã£o de saÃºde financeira 0â€“100. Toque para ver os fatores.'**
  String get onbTourDash2Body;

  /// No description provided for @onbTourDash3Title.
  ///
  /// In pt, this message translates to:
  /// **'OrÃ§amento vs real'**
  String get onbTourDash3Title;

  /// No description provided for @onbTourDash3Body.
  ///
  /// In pt, this message translates to:
  /// **'Gastos planeados vs reais por categoria.'**
  String get onbTourDash3Body;

  /// No description provided for @onbTourDash4Title.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar despesa'**
  String get onbTourDash4Title;

  /// No description provided for @onbTourDash4Body.
  ///
  /// In pt, this message translates to:
  /// **'Toque + a qualquer momento para registar uma despesa.'**
  String get onbTourDash4Body;

  /// No description provided for @onbTourDash5Title.
  ///
  /// In pt, this message translates to:
  /// **'NavegaÃ§Ã£o'**
  String get onbTourDash5Title;

  /// No description provided for @onbTourDash5Body.
  ///
  /// In pt, this message translates to:
  /// **'5 secÃ§Ãµes: OrÃ§amento, Supermercado, Lista, Coach, RefeiÃ§Ãµes.'**
  String get onbTourDash5Body;

  /// No description provided for @onbTourGrocery1Title.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar e filtrar'**
  String get onbTourGrocery1Title;

  /// No description provided for @onbTourGrocery1Body.
  ///
  /// In pt, this message translates to:
  /// **'Pesquise por nome ou filtre por categoria.'**
  String get onbTourGrocery1Body;

  /// No description provided for @onbTourGrocery2Title.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Ã  lista'**
  String get onbTourGrocery2Title;

  /// No description provided for @onbTourGrocery2Body.
  ///
  /// In pt, this message translates to:
  /// **'Toque + num produto para o adicionar Ã  lista de compras.'**
  String get onbTourGrocery2Body;

  /// No description provided for @onbTourGrocery3Title.
  ///
  /// In pt, this message translates to:
  /// **'Categorias'**
  String get onbTourGrocery3Title;

  /// No description provided for @onbTourGrocery3Body.
  ///
  /// In pt, this message translates to:
  /// **'Deslize os filtros de categoria para refinar produtos.'**
  String get onbTourGrocery3Body;

  /// No description provided for @onbTourShopping1Title.
  ///
  /// In pt, this message translates to:
  /// **'Riscar itens'**
  String get onbTourShopping1Title;

  /// No description provided for @onbTourShopping1Body.
  ///
  /// In pt, this message translates to:
  /// **'Toque num item para o marcar como apanhado.'**
  String get onbTourShopping1Body;

  /// No description provided for @onbTourShopping2Title.
  ///
  /// In pt, this message translates to:
  /// **'Finalizar compra'**
  String get onbTourShopping2Title;

  /// No description provided for @onbTourShopping2Body.
  ///
  /// In pt, this message translates to:
  /// **'Regista o gasto e limpa os itens marcados.'**
  String get onbTourShopping2Body;

  /// No description provided for @onbTourShopping3Title.
  ///
  /// In pt, this message translates to:
  /// **'HistÃ³rico de compras'**
  String get onbTourShopping3Title;

  /// No description provided for @onbTourShopping3Body.
  ///
  /// In pt, this message translates to:
  /// **'Veja todas as sessÃµes de compras anteriores aqui.'**
  String get onbTourShopping3Body;

  /// No description provided for @onbTourCoach1Title.
  ///
  /// In pt, this message translates to:
  /// **'Analisar o meu orÃ§amento'**
  String get onbTourCoach1Title;

  /// No description provided for @onbTourCoach1Body.
  ///
  /// In pt, this message translates to:
  /// **'Toque para gerar uma anÃ¡lise baseada nos seus dados reais.'**
  String get onbTourCoach1Body;

  /// No description provided for @onbTourCoach2Title.
  ///
  /// In pt, this message translates to:
  /// **'HistÃ³rico de anÃ¡lises'**
  String get onbTourCoach2Title;

  /// No description provided for @onbTourCoach2Body.
  ///
  /// In pt, this message translates to:
  /// **'As anÃ¡lises guardadas aparecem aqui, mais recentes primeiro.'**
  String get onbTourCoach2Body;

  /// No description provided for @onbTourMeals1Title.
  ///
  /// In pt, this message translates to:
  /// **'Gerar plano'**
  String get onbTourMeals1Title;

  /// No description provided for @onbTourMeals1Body.
  ///
  /// In pt, this message translates to:
  /// **'Cria um mÃªs completo de refeiÃ§Ãµes dentro do orÃ§amento alimentar.'**
  String get onbTourMeals1Body;

  /// No description provided for @onbTourMeals2Title.
  ///
  /// In pt, this message translates to:
  /// **'Vista semanal'**
  String get onbTourMeals2Title;

  /// No description provided for @onbTourMeals2Body.
  ///
  /// In pt, this message translates to:
  /// **'Navegue refeiÃ§Ãµes por semana. Toque num dia para ver a receita.'**
  String get onbTourMeals2Body;

  /// No description provided for @onbTourMeals3Title.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Ã  lista de compras'**
  String get onbTourMeals3Title;

  /// No description provided for @onbTourMeals3Body.
  ///
  /// In pt, this message translates to:
  /// **'Envie os ingredientes da semana para a lista com um toque.'**
  String get onbTourMeals3Body;

  /// No description provided for @onbTourExpenseTracker1Title.
  ///
  /// In pt, this message translates to:
  /// **'NavegaÃ§Ã£o mensal'**
  String get onbTourExpenseTracker1Title;

  /// No description provided for @onbTourExpenseTracker1Body.
  ///
  /// In pt, this message translates to:
  /// **'Alterne entre meses para ver ou adicionar despesas de qualquer perÃ­odo.'**
  String get onbTourExpenseTracker1Body;

  /// No description provided for @onbTourExpenseTracker2Title.
  ///
  /// In pt, this message translates to:
  /// **'Resumo do orÃ§amento'**
  String get onbTourExpenseTracker2Title;

  /// No description provided for @onbTourExpenseTracker2Body.
  ///
  /// In pt, this message translates to:
  /// **'Veja o orÃ§ado vs real e o saldo restante de relance.'**
  String get onbTourExpenseTracker2Body;

  /// No description provided for @onbTourExpenseTracker3Title.
  ///
  /// In pt, this message translates to:
  /// **'Por categoria'**
  String get onbTourExpenseTracker3Title;

  /// No description provided for @onbTourExpenseTracker3Body.
  ///
  /// In pt, this message translates to:
  /// **'Cada categoria mostra uma barra de progresso. Toque para expandir e ver despesas individuais.'**
  String get onbTourExpenseTracker3Body;

  /// No description provided for @onbTourExpenseTracker4Title.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar despesa'**
  String get onbTourExpenseTracker4Title;

  /// No description provided for @onbTourExpenseTracker4Body.
  ///
  /// In pt, this message translates to:
  /// **'Toque + para registar uma nova despesa. Escolha a categoria e o valor.'**
  String get onbTourExpenseTracker4Body;

  /// No description provided for @onbTourSavings1Title.
  ///
  /// In pt, this message translates to:
  /// **'Os seus objetivos'**
  String get onbTourSavings1Title;

  /// No description provided for @onbTourSavings1Body.
  ///
  /// In pt, this message translates to:
  /// **'Cada cartÃ£o mostra o progresso em direÃ§Ã£o ao objetivo. Toque para ver detalhes e adicionar contribuiÃ§Ãµes.'**
  String get onbTourSavings1Body;

  /// No description provided for @onbTourSavings2Title.
  ///
  /// In pt, this message translates to:
  /// **'Criar objetivo'**
  String get onbTourSavings2Title;

  /// No description provided for @onbTourSavings2Body.
  ///
  /// In pt, this message translates to:
  /// **'Toque + para definir um novo objetivo de poupanÃ§a com valor alvo e prazo opcional.'**
  String get onbTourSavings2Body;

  /// No description provided for @onbTourRecurring1Title.
  ///
  /// In pt, this message translates to:
  /// **'Despesas recorrentes'**
  String get onbTourRecurring1Title;

  /// No description provided for @onbTourRecurring1Body.
  ///
  /// In pt, this message translates to:
  /// **'Contas fixas mensais como renda, subscriÃ§Ãµes e serviÃ§os. SÃ£o incluÃ­das automaticamente no orÃ§amento.'**
  String get onbTourRecurring1Body;

  /// No description provided for @onbTourRecurring2Title.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar recorrente'**
  String get onbTourRecurring2Title;

  /// No description provided for @onbTourRecurring2Body.
  ///
  /// In pt, this message translates to:
  /// **'Toque + para registar uma nova despesa recorrente com valor e dia de vencimento.'**
  String get onbTourRecurring2Body;

  /// No description provided for @onbTourAssistant1Title.
  ///
  /// In pt, this message translates to:
  /// **'Assistente de comandos'**
  String get onbTourAssistant1Title;

  /// No description provided for @onbTourAssistant1Body.
  ///
  /// In pt, this message translates to:
  /// **'O seu atalho para aÃ§Ãµes rÃ¡pidas. Toque para adicionar despesas, mudar definiÃ§Ãµes, navegar e mais â€” basta escrever o que precisa.'**
  String get onbTourAssistant1Body;

  /// No description provided for @taxDeductionTitle.
  ///
  /// In pt, this message translates to:
  /// **'DeduÃ§Ãµes IRS'**
  String get taxDeductionTitle;

  /// No description provided for @taxDeductionSeeDetail.
  ///
  /// In pt, this message translates to:
  /// **'Ver detalhe'**
  String get taxDeductionSeeDetail;

  /// No description provided for @taxDeductionEstimated.
  ///
  /// In pt, this message translates to:
  /// **'deduÃ§Ã£o estimada'**
  String get taxDeductionEstimated;

  /// No description provided for @taxDeductionMaxOf.
  ///
  /// In pt, this message translates to:
  /// **'MÃ¡x. de {amount}'**
  String taxDeductionMaxOf(String amount);

  /// No description provided for @taxDeductionDetailTitle.
  ///
  /// In pt, this message translates to:
  /// **'DeduÃ§Ãµes IRS â€” Detalhe'**
  String get taxDeductionDetailTitle;

  /// No description provided for @taxDeductionDeductibleTitle.
  ///
  /// In pt, this message translates to:
  /// **'CATEGORIAS DEDUTÃVEIS'**
  String get taxDeductionDeductibleTitle;

  /// No description provided for @taxDeductionNonDeductibleTitle.
  ///
  /// In pt, this message translates to:
  /// **'CATEGORIAS NÃƒO DEDUTÃVEIS'**
  String get taxDeductionNonDeductibleTitle;

  /// No description provided for @taxDeductionTotalLabel.
  ///
  /// In pt, this message translates to:
  /// **'DEDUÃ‡ÃƒO IRS ESTIMADA'**
  String get taxDeductionTotalLabel;

  /// No description provided for @taxDeductionSpent.
  ///
  /// In pt, this message translates to:
  /// **'Gasto: {amount}'**
  String taxDeductionSpent(String amount);

  /// No description provided for @taxDeductionCapUsed.
  ///
  /// In pt, this message translates to:
  /// **'{percent} de {cap} utilizado'**
  String taxDeductionCapUsed(String percent, String cap);

  /// No description provided for @taxDeductionNotDeductible.
  ///
  /// In pt, this message translates to:
  /// **'NÃ£o dedutÃ­vel'**
  String get taxDeductionNotDeductible;

  /// No description provided for @taxDeductionDisclaimer.
  ///
  /// In pt, this message translates to:
  /// **'Estes valores sÃ£o estimativas baseadas nas despesas registadas. As deduÃ§Ãµes reais dependem das faturas registadas no e-Fatura. Consulte um profissional fiscal para valores definitivos.'**
  String get taxDeductionDisclaimer;

  /// No description provided for @settingsDashTaxDeductions.
  ///
  /// In pt, this message translates to:
  /// **'DeduÃ§Ãµes fiscais (PT)'**
  String get settingsDashTaxDeductions;

  /// No description provided for @settingsDashUpcomingBills.
  ///
  /// In pt, this message translates to:
  /// **'PrÃ³ximos pagamentos'**
  String get settingsDashUpcomingBills;

  /// No description provided for @settingsDashBudgetStreaks.
  ///
  /// In pt, this message translates to:
  /// **'SÃ©ries de orÃ§amento'**
  String get settingsDashBudgetStreaks;

  /// No description provided for @settingsDashQuickActions.
  ///
  /// In pt, this message translates to:
  /// **'AÃ§Ãµes rÃ¡pidas'**
  String get settingsDashQuickActions;

  /// No description provided for @upcomingBillsTitle.
  ///
  /// In pt, this message translates to:
  /// **'PrÃ³ximos Pagamentos'**
  String get upcomingBillsTitle;

  /// No description provided for @upcomingBillsManage.
  ///
  /// In pt, this message translates to:
  /// **'Gerir'**
  String get upcomingBillsManage;

  /// No description provided for @billDueToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get billDueToday;

  /// No description provided for @billDueTomorrow.
  ///
  /// In pt, this message translates to:
  /// **'AmanhÃ£'**
  String get billDueTomorrow;

  /// No description provided for @billDueInDays.
  ///
  /// In pt, this message translates to:
  /// **'Em {days} dias'**
  String billDueInDays(int days);

  /// No description provided for @savingsProjectionReachedBy.
  ///
  /// In pt, this message translates to:
  /// **'Atingido atÃ© {date}'**
  String savingsProjectionReachedBy(String date);

  /// No description provided for @savingsProjectionNeedPerMonth.
  ///
  /// In pt, this message translates to:
  /// **'Precisa {amount}/mÃªs para cumprir prazo'**
  String savingsProjectionNeedPerMonth(String amount);

  /// No description provided for @savingsProjectionOnTrack.
  ///
  /// In pt, this message translates to:
  /// **'No caminho certo'**
  String get savingsProjectionOnTrack;

  /// No description provided for @savingsProjectionBehind.
  ///
  /// In pt, this message translates to:
  /// **'Atrasado'**
  String get savingsProjectionBehind;

  /// No description provided for @savingsProjectionNoData.
  ///
  /// In pt, this message translates to:
  /// **'Adicione contribuiÃ§Ãµes para ver projeÃ§Ã£o'**
  String get savingsProjectionNoData;

  /// No description provided for @savingsProjectionAvgContribution.
  ///
  /// In pt, this message translates to:
  /// **'MÃ©dia {amount}/mÃªs'**
  String savingsProjectionAvgContribution(String amount);

  /// No description provided for @taxSimTitle.
  ///
  /// In pt, this message translates to:
  /// **'Simulador Fiscal'**
  String get taxSimTitle;

  /// No description provided for @taxSimPresets.
  ///
  /// In pt, this message translates to:
  /// **'CENÃRIOS RÃPIDOS'**
  String get taxSimPresets;

  /// No description provided for @taxSimPresetRaise.
  ///
  /// In pt, this message translates to:
  /// **'+â‚¬200 aumento'**
  String get taxSimPresetRaise;

  /// No description provided for @taxSimPresetMeal.
  ///
  /// In pt, this message translates to:
  /// **'CartÃ£o vs dinheiro'**
  String get taxSimPresetMeal;

  /// No description provided for @taxSimPresetTitular.
  ///
  /// In pt, this message translates to:
  /// **'Ãšnico vs conjunto'**
  String get taxSimPresetTitular;

  /// No description provided for @taxSimParameters.
  ///
  /// In pt, this message translates to:
  /// **'PARÃ‚METROS'**
  String get taxSimParameters;

  /// No description provided for @taxSimGross.
  ///
  /// In pt, this message translates to:
  /// **'SalÃ¡rio bruto'**
  String get taxSimGross;

  /// No description provided for @taxSimMarital.
  ///
  /// In pt, this message translates to:
  /// **'Estado civil'**
  String get taxSimMarital;

  /// No description provided for @taxSimTitulares.
  ///
  /// In pt, this message translates to:
  /// **'Titulares'**
  String get taxSimTitulares;

  /// No description provided for @taxSimDependentes.
  ///
  /// In pt, this message translates to:
  /// **'Dependentes'**
  String get taxSimDependentes;

  /// No description provided for @taxSimMealType.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de subsÃ­dio de alimentaÃ§Ã£o'**
  String get taxSimMealType;

  /// No description provided for @taxSimMealAmount.
  ///
  /// In pt, this message translates to:
  /// **'SubsÃ­dio alim./dia'**
  String get taxSimMealAmount;

  /// No description provided for @taxSimComparison.
  ///
  /// In pt, this message translates to:
  /// **'ATUAL VS SIMULADO'**
  String get taxSimComparison;

  /// No description provided for @taxSimNetTakeHome.
  ///
  /// In pt, this message translates to:
  /// **'LÃ­quido a receber'**
  String get taxSimNetTakeHome;

  /// No description provided for @taxSimIRS.
  ///
  /// In pt, this message translates to:
  /// **'RetenÃ§Ã£o IRS'**
  String get taxSimIRS;

  /// No description provided for @taxSimSS.
  ///
  /// In pt, this message translates to:
  /// **'SeguranÃ§a social'**
  String get taxSimSS;

  /// No description provided for @taxSimDelta.
  ///
  /// In pt, this message translates to:
  /// **'DiferenÃ§a mensal:'**
  String get taxSimDelta;

  /// No description provided for @taxSimButton.
  ///
  /// In pt, this message translates to:
  /// **'Simulador Fiscal'**
  String get taxSimButton;

  /// No description provided for @streakTitle.
  ///
  /// In pt, this message translates to:
  /// **'SÃ©ries de OrÃ§amento'**
  String get streakTitle;

  /// No description provided for @streakBronze.
  ///
  /// In pt, this message translates to:
  /// **'Bronze'**
  String get streakBronze;

  /// No description provided for @streakSilver.
  ///
  /// In pt, this message translates to:
  /// **'Prata'**
  String get streakSilver;

  /// No description provided for @streakGold.
  ///
  /// In pt, this message translates to:
  /// **'Ouro'**
  String get streakGold;

  /// No description provided for @streakBronzeDesc.
  ///
  /// In pt, this message translates to:
  /// **'Liquidez positiva'**
  String get streakBronzeDesc;

  /// No description provided for @streakSilverDesc.
  ///
  /// In pt, this message translates to:
  /// **'Dentro do orÃ§amento'**
  String get streakSilverDesc;

  /// No description provided for @streakGoldDesc.
  ///
  /// In pt, this message translates to:
  /// **'Todas as categorias'**
  String get streakGoldDesc;

  /// No description provided for @streakMonths.
  ///
  /// In pt, this message translates to:
  /// **'{count} meses'**
  String streakMonths(int count);

  /// No description provided for @expenseDefaultBudget.
  ///
  /// In pt, this message translates to:
  /// **'ORÃ‡AMENTO BASE'**
  String get expenseDefaultBudget;

  /// No description provided for @expenseOverrideActive.
  ///
  /// In pt, this message translates to:
  /// **'Ajustado para {month}: {amount}'**
  String expenseOverrideActive(String month, String amount);

  /// No description provided for @expenseAdjustMonth.
  ///
  /// In pt, this message translates to:
  /// **'Ajustar para {month}'**
  String expenseAdjustMonth(String month);

  /// No description provided for @expenseAdjustMonthHint.
  ///
  /// In pt, this message translates to:
  /// **'Deixe vazio para usar o orÃ§amento base'**
  String get expenseAdjustMonthHint;

  /// No description provided for @settingsPersonalTip.
  ///
  /// In pt, this message translates to:
  /// **'O estado civil e dependentes afetam o escalÃ£o de IRS, que determina o imposto retido no salÃ¡rio.'**
  String get settingsPersonalTip;

  /// No description provided for @settingsSalariesTip.
  ///
  /// In pt, this message translates to:
  /// **'O salÃ¡rio bruto Ã© usado para calcular o rendimento lÃ­quido apÃ³s impostos e seguranÃ§a social. Adicione vÃ¡rios salÃ¡rios se o agregado tiver mais que um rendimento.'**
  String get settingsSalariesTip;

  /// No description provided for @settingsExpensesTip.
  ///
  /// In pt, this message translates to:
  /// **'Defina o orÃ§amento mensal para cada categoria. Pode ajustar para meses especÃ­ficos na vista de detalhe da categoria.'**
  String get settingsExpensesTip;

  /// No description provided for @settingsMealHouseholdTip.
  ///
  /// In pt, this message translates to:
  /// **'NÃºmero de pessoas que fazem refeiÃ§Ãµes em casa. Isto ajusta receitas e porÃ§Ãµes no plano alimentar.'**
  String get settingsMealHouseholdTip;

  /// No description provided for @settingsHouseholdTip.
  ///
  /// In pt, this message translates to:
  /// **'Convide membros da famÃ­lia para partilhar dados do orÃ§amento entre dispositivos. Todos veem as mesmas despesas e orÃ§amentos.'**
  String get settingsHouseholdTip;

  /// Subscription section title
  ///
  /// In pt, this message translates to:
  /// **'SubscriÃ§Ã£o'**
  String get subscriptionTitle;

  /// Free tier label
  ///
  /// In pt, this message translates to:
  /// **'Gratuito'**
  String get subscriptionFree;

  /// Premium tier label
  ///
  /// In pt, this message translates to:
  /// **'Premium'**
  String get subscriptionPremium;

  /// Family tier label
  ///
  /// In pt, this message translates to:
  /// **'FamÃ­lia'**
  String get subscriptionFamily;

  /// Trial active label
  ///
  /// In pt, this message translates to:
  /// **'PerÃ­odo de teste ativo'**
  String get subscriptionTrialActive;

  /// No description provided for @subscriptionTrialDaysLeft.
  ///
  /// In pt, this message translates to:
  /// **'{count} dias restantes'**
  String subscriptionTrialDaysLeft(int count);

  /// Trial expired label
  ///
  /// In pt, this message translates to:
  /// **'PerÃ­odo de teste expirado'**
  String get subscriptionTrialExpired;

  /// Upgrade button label
  ///
  /// In pt, this message translates to:
  /// **'Atualizar'**
  String get subscriptionUpgrade;

  /// See plans button label
  ///
  /// In pt, this message translates to:
  /// **'Ver Planos'**
  String get subscriptionSeePlans;

  /// Current plan label
  ///
  /// In pt, this message translates to:
  /// **'Plano Atual'**
  String get subscriptionCurrentPlan;

  /// Manage subscription label
  ///
  /// In pt, this message translates to:
  /// **'Gerir SubscriÃ§Ã£o'**
  String get subscriptionManage;

  /// No description provided for @subscriptionFeatureExplored.
  ///
  /// In pt, this message translates to:
  /// **'{count}/{total} funcionalidades exploradas'**
  String subscriptionFeatureExplored(int count, int total);

  /// Trial banner title
  ///
  /// In pt, this message translates to:
  /// **'Teste Premium Ativo'**
  String get subscriptionTrialBannerTitle;

  /// No description provided for @subscriptionTrialEndingSoon.
  ///
  /// In pt, this message translates to:
  /// **'{count} dias restantes no seu teste!'**
  String subscriptionTrialEndingSoon(int count);

  /// Last day of trial message
  ///
  /// In pt, this message translates to:
  /// **'Ãšltimo dia do seu teste gratuito!'**
  String get subscriptionTrialLastDay;

  /// Upgrade now button
  ///
  /// In pt, this message translates to:
  /// **'Atualizar Agora'**
  String get subscriptionUpgradeNow;

  /// Keep data message
  ///
  /// In pt, this message translates to:
  /// **'Manter os Seus Dados'**
  String get subscriptionKeepData;

  /// Cancel anytime text
  ///
  /// In pt, this message translates to:
  /// **'Cancele a qualquer momento'**
  String get subscriptionCancelAnytime;

  /// No hidden fees text
  ///
  /// In pt, this message translates to:
  /// **'Sem taxas ocultas'**
  String get subscriptionNoHiddenFees;

  /// Most popular badge
  ///
  /// In pt, this message translates to:
  /// **'Mais Popular'**
  String get subscriptionMostPopular;

  /// No description provided for @subscriptionYearlySave.
  ///
  /// In pt, this message translates to:
  /// **'poupe {percent}%'**
  String subscriptionYearlySave(int percent);

  /// Monthly billing label
  ///
  /// In pt, this message translates to:
  /// **'Mensal'**
  String get subscriptionMonthly;

  /// Yearly billing label
  ///
  /// In pt, this message translates to:
  /// **'Anual'**
  String get subscriptionYearly;

  /// Per month label
  ///
  /// In pt, this message translates to:
  /// **'/mÃªs'**
  String get subscriptionPerMonth;

  /// Per year label
  ///
  /// In pt, this message translates to:
  /// **'/ano'**
  String get subscriptionPerYear;

  /// Billed yearly label
  ///
  /// In pt, this message translates to:
  /// **'faturado anualmente'**
  String get subscriptionBilledYearly;

  /// Start premium button
  ///
  /// In pt, this message translates to:
  /// **'ComeÃ§ar Premium'**
  String get subscriptionStartPremium;

  /// Start family button
  ///
  /// In pt, this message translates to:
  /// **'ComeÃ§ar FamÃ­lia'**
  String get subscriptionStartFamily;

  /// Continue free button
  ///
  /// In pt, this message translates to:
  /// **'Continuar Gratuito'**
  String get subscriptionContinueFree;

  /// Trial ended title
  ///
  /// In pt, this message translates to:
  /// **'O seu perÃ­odo de teste terminou'**
  String get subscriptionTrialEnded;

  /// Choose plan subtitle
  ///
  /// In pt, this message translates to:
  /// **'Escolha um plano para manter todos os seus dados e funcionalidades'**
  String get subscriptionChoosePlan;

  /// Unlock subtitle
  ///
  /// In pt, this message translates to:
  /// **'Desbloqueie todo o poder do seu orÃ§amento'**
  String get subscriptionUnlockPower;

  /// No description provided for @subscriptionRequiresPaid.
  ///
  /// In pt, this message translates to:
  /// **'{feature} requer uma subscriÃ§Ã£o paga'**
  String subscriptionRequiresPaid(String feature);

  /// No description provided for @subscriptionTryFeature.
  ///
  /// In pt, this message translates to:
  /// **'Experimente {feature}'**
  String subscriptionTryFeature(String feature);

  /// No description provided for @subscriptionExplore.
  ///
  /// In pt, this message translates to:
  /// **'Explorar {feature}'**
  String subscriptionExplore(String feature);

  /// No description provided for @subtitleBatchCooking.
  ///
  /// In pt, this message translates to:
  /// **'Sugere receitas que podem ser preparadas com antecedÃªncia para vÃ¡rias refeiÃ§Ãµes'**
  String get subtitleBatchCooking;

  /// No description provided for @subtitleReuseLeftovers.
  ///
  /// In pt, this message translates to:
  /// **'Planeia refeiÃ§Ãµes que reutilizam ingredientes de dias anteriores'**
  String get subtitleReuseLeftovers;

  /// No description provided for @subtitleMinimizeWaste.
  ///
  /// In pt, this message translates to:
  /// **'Prioriza o uso de todos os ingredientes comprados antes de expirarem'**
  String get subtitleMinimizeWaste;

  /// No description provided for @subtitleMealTypeInclude.
  ///
  /// In pt, this message translates to:
  /// **'Incluir esta refeiÃ§Ã£o no plano semanal'**
  String get subtitleMealTypeInclude;

  /// No description provided for @subtitleShowHeroCard.
  ///
  /// In pt, this message translates to:
  /// **'Resumo da liquidez lÃ­quida no topo'**
  String get subtitleShowHeroCard;

  /// No description provided for @subtitleShowStressIndex.
  ///
  /// In pt, this message translates to:
  /// **'PontuaÃ§Ã£o (0-100) que mede a pressÃ£o de despesas vs rendimento'**
  String get subtitleShowStressIndex;

  /// No description provided for @subtitleShowMonthReview.
  ///
  /// In pt, this message translates to:
  /// **'Resumo comparativo deste mÃªs com os anteriores'**
  String get subtitleShowMonthReview;

  /// No description provided for @subtitleShowUpcomingBills.
  ///
  /// In pt, this message translates to:
  /// **'Despesas recorrentes nos prÃ³ximos 30 dias'**
  String get subtitleShowUpcomingBills;

  /// No description provided for @subtitleShowSummaryCards.
  ///
  /// In pt, this message translates to:
  /// **'Rendimento, deduÃ§Ãµes, despesas e taxa de poupanÃ§a'**
  String get subtitleShowSummaryCards;

  /// No description provided for @subtitleShowBudgetVsActual.
  ///
  /// In pt, this message translates to:
  /// **'ComparaÃ§Ã£o lado a lado por categoria de despesa'**
  String get subtitleShowBudgetVsActual;

  /// No description provided for @subtitleShowExpensesBreakdown.
  ///
  /// In pt, this message translates to:
  /// **'GrÃ¡fico circular de despesas por categoria'**
  String get subtitleShowExpensesBreakdown;

  /// No description provided for @subtitleShowSavingsGoals.
  ///
  /// In pt, this message translates to:
  /// **'Progresso em relaÃ§Ã£o aos seus objetivos de poupanÃ§a'**
  String get subtitleShowSavingsGoals;

  /// No description provided for @subtitleShowTaxDeductions.
  ///
  /// In pt, this message translates to:
  /// **'DeduÃ§Ãµes fiscais elegÃ­veis estimadas este ano'**
  String get subtitleShowTaxDeductions;

  /// No description provided for @subtitleShowBudgetStreaks.
  ///
  /// In pt, this message translates to:
  /// **'Quantos meses consecutivos ficou dentro do orÃ§amento'**
  String get subtitleShowBudgetStreaks;

  /// No description provided for @subtitleShowQuickActions.
  ///
  /// In pt, this message translates to:
  /// **'Atalhos para adicionar despesas, navegar e mais'**
  String get subtitleShowQuickActions;

  /// No description provided for @subtitleShowPurchaseHistory.
  ///
  /// In pt, this message translates to:
  /// **'Compras recentes da lista de compras e custos'**
  String get subtitleShowPurchaseHistory;

  /// No description provided for @subtitleShowCharts.
  ///
  /// In pt, this message translates to:
  /// **'GrÃ¡ficos de tendÃªncia de orÃ§amento, despesas e rendimento'**
  String get subtitleShowCharts;

  /// No description provided for @subtitleChartExpensesPie.
  ///
  /// In pt, this message translates to:
  /// **'DistribuiÃ§Ã£o de despesas por categoria'**
  String get subtitleChartExpensesPie;

  /// No description provided for @subtitleChartIncomeVsExpenses.
  ///
  /// In pt, this message translates to:
  /// **'Rendimento mensal comparado com despesas totais'**
  String get subtitleChartIncomeVsExpenses;

  /// No description provided for @subtitleChartDeductions.
  ///
  /// In pt, this message translates to:
  /// **'DiscriminaÃ§Ã£o de despesas dedutÃ­veis nos impostos'**
  String get subtitleChartDeductions;

  /// No description provided for @subtitleChartNetIncome.
  ///
  /// In pt, this message translates to:
  /// **'TendÃªncia do rendimento lÃ­quido ao longo do tempo'**
  String get subtitleChartNetIncome;

  /// No description provided for @subtitleChartSavingsRate.
  ///
  /// In pt, this message translates to:
  /// **'Percentagem de rendimento poupado por mÃªs'**
  String get subtitleChartSavingsRate;

  /// No description provided for @helperCountry.
  ///
  /// In pt, this message translates to:
  /// **'Determina o sistema fiscal, moeda e taxas de seguranÃ§a social'**
  String get helperCountry;

  /// No description provided for @helperLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Substituir o idioma do sistema. \"Sistema\" segue a definiÃ§Ã£o do dispositivo'**
  String get helperLanguage;

  /// No description provided for @helperMaritalStatus.
  ///
  /// In pt, this message translates to:
  /// **'Afeta o cÃ¡lculo do escalÃ£o de IRS'**
  String get helperMaritalStatus;

  /// No description provided for @helperMealObjective.
  ///
  /// In pt, this message translates to:
  /// **'Define o padrÃ£o alimentar: omnÃ­voro, vegetariano, pescatariano, etc.'**
  String get helperMealObjective;

  /// No description provided for @helperSodiumPreference.
  ///
  /// In pt, this message translates to:
  /// **'Filtra receitas pelo nÃ­vel de teor de sÃ³dio'**
  String get helperSodiumPreference;

  /// No description provided for @subtitleDietaryRestriction.
  ///
  /// In pt, this message translates to:
  /// **'Exclui receitas que contÃªm {ingredient}'**
  String subtitleDietaryRestriction(String ingredient);

  /// No description provided for @subtitleExcludedProtein.
  ///
  /// In pt, this message translates to:
  /// **'Remove {protein} de todas as sugestÃµes de refeiÃ§Ãµes'**
  String subtitleExcludedProtein(String protein);

  /// No description provided for @subtitleKitchenEquipment.
  ///
  /// In pt, this message translates to:
  /// **'Ativa receitas que requerem {equipment}'**
  String subtitleKitchenEquipment(String equipment);

  /// No description provided for @helperVeggieDays.
  ///
  /// In pt, this message translates to:
  /// **'NÃºmero de dias totalmente vegetarianos por semana'**
  String get helperVeggieDays;

  /// No description provided for @helperFishDays.
  ///
  /// In pt, this message translates to:
  /// **'Recomendado: 2-3 vezes por semana'**
  String get helperFishDays;

  /// No description provided for @helperLegumeDays.
  ///
  /// In pt, this message translates to:
  /// **'Recomendado: 2-3 vezes por semana'**
  String get helperLegumeDays;

  /// No description provided for @helperRedMeatDays.
  ///
  /// In pt, this message translates to:
  /// **'Recomendado: mÃ¡ximo 2 vezes por semana'**
  String get helperRedMeatDays;

  /// No description provided for @helperMaxPrepTime.
  ///
  /// In pt, this message translates to:
  /// **'Tempo mÃ¡ximo de confeÃ§Ã£o para refeiÃ§Ãµes de semana (minutos)'**
  String get helperMaxPrepTime;

  /// No description provided for @helperMaxComplexity.
  ///
  /// In pt, this message translates to:
  /// **'NÃ­vel de dificuldade das receitas para dias de semana'**
  String get helperMaxComplexity;

  /// No description provided for @helperWeekendPrepTime.
  ///
  /// In pt, this message translates to:
  /// **'Tempo mÃ¡ximo de confeÃ§Ã£o para refeiÃ§Ãµes de fim de semana (minutos)'**
  String get helperWeekendPrepTime;

  /// No description provided for @helperWeekendComplexity.
  ///
  /// In pt, this message translates to:
  /// **'NÃ­vel de dificuldade das receitas para fins de semana'**
  String get helperWeekendComplexity;

  /// No description provided for @helperMaxBatchDays.
  ///
  /// In pt, this message translates to:
  /// **'Quantos dias uma refeiÃ§Ã£o preparada em lote pode ser reutilizada'**
  String get helperMaxBatchDays;

  /// No description provided for @helperNewIngredients.
  ///
  /// In pt, this message translates to:
  /// **'Limita quantos ingredientes novos aparecem por semana'**
  String get helperNewIngredients;

  /// No description provided for @helperGrossSalary.
  ///
  /// In pt, this message translates to:
  /// **'SalÃ¡rio total antes de impostos e deduÃ§Ãµes'**
  String get helperGrossSalary;

  /// No description provided for @helperExemptIncome.
  ///
  /// In pt, this message translates to:
  /// **'Rendimento adicional nÃ£o sujeito a IRS (ex.: subsÃ­dios)'**
  String get helperExemptIncome;

  /// No description provided for @helperMealAllowance.
  ///
  /// In pt, this message translates to:
  /// **'SubsÃ­dio de refeiÃ§Ã£o diÃ¡rio do empregador'**
  String get helperMealAllowance;

  /// No description provided for @helperWorkingDays.
  ///
  /// In pt, this message translates to:
  /// **'TÃ­pico: 22. Afeta o cÃ¡lculo do subsÃ­dio de refeiÃ§Ã£o'**
  String get helperWorkingDays;

  /// No description provided for @helperSalaryLabel.
  ///
  /// In pt, this message translates to:
  /// **'Um nome para identificar esta fonte de rendimento'**
  String get helperSalaryLabel;

  /// No description provided for @helperExpenseAmount.
  ///
  /// In pt, this message translates to:
  /// **'Montante mensal orÃ§amentado para esta categoria'**
  String get helperExpenseAmount;

  /// No description provided for @helperCalorieTarget.
  ///
  /// In pt, this message translates to:
  /// **'Recomendado: 2000-2500 kcal para adultos'**
  String get helperCalorieTarget;

  /// No description provided for @helperProteinTarget.
  ///
  /// In pt, this message translates to:
  /// **'Recomendado: 50-70g para adultos'**
  String get helperProteinTarget;

  /// No description provided for @helperFiberTarget.
  ///
  /// In pt, this message translates to:
  /// **'Recomendado: 25-30g para adultos'**
  String get helperFiberTarget;

  /// No description provided for @infoStressIndex.
  ///
  /// In pt, this message translates to:
  /// **'Compara os gastos reais com o seu orÃ§amento. Intervalos de pontuaÃ§Ã£o:\n\n0-30: ConfortÃ¡vel - gastos bem dentro do orÃ§amento\n30-60: Moderado - a aproximar-se dos limites do orÃ§amento\n60-100: CrÃ­tico - gastos excedem significativamente o orÃ§amento'**
  String get infoStressIndex;

  /// No description provided for @infoBudgetStreak.
  ///
  /// In pt, this message translates to:
  /// **'Meses consecutivos em que a despesa total ficou dentro do orÃ§amento total.'**
  String get infoBudgetStreak;

  /// No description provided for @infoUpcomingBills.
  ///
  /// In pt, this message translates to:
  /// **'Mostra despesas recorrentes nos prÃ³ximos 30 dias com base nas suas despesas mensais.'**
  String get infoUpcomingBills;

  /// No description provided for @infoSalaryBreakdown.
  ///
  /// In pt, this message translates to:
  /// **'Mostra como o salÃ¡rio bruto Ã© dividido em imposto IRS, contribuiÃ§Ãµes para a seguranÃ§a social, rendimento lÃ­quido e subsÃ­dio de refeiÃ§Ã£o.'**
  String get infoSalaryBreakdown;

  /// No description provided for @infoBudgetVsActual.
  ///
  /// In pt, this message translates to:
  /// **'Compara o que orÃ§amentou por categoria com o que realmente gastou. Verde significa abaixo do orÃ§amento, vermelho significa acima do orÃ§amento.'**
  String get infoBudgetVsActual;

  /// No description provided for @infoSavingsGoals.
  ///
  /// In pt, this message translates to:
  /// **'Progresso em relaÃ§Ã£o a cada objetivo de poupanÃ§a com base nas contribuiÃ§Ãµes efetuadas.'**
  String get infoSavingsGoals;

  /// No description provided for @infoTaxDeductions.
  ///
  /// In pt, this message translates to:
  /// **'Despesas dedutÃ­veis estimadas (saÃºde, educaÃ§Ã£o, habitaÃ§Ã£o). Estas sÃ£o apenas estimativas - consulte um profissional fiscal para valores precisos.'**
  String get infoTaxDeductions;

  /// No description provided for @infoPurchaseHistory.
  ///
  /// In pt, this message translates to:
  /// **'Total gasto em compras da lista de compras este mÃªs.'**
  String get infoPurchaseHistory;

  /// No description provided for @infoExpensesBreakdown.
  ///
  /// In pt, this message translates to:
  /// **'DiscriminaÃ§Ã£o visual das suas despesas por categoria no mÃªs atual.'**
  String get infoExpensesBreakdown;

  /// No description provided for @infoCharts.
  ///
  /// In pt, this message translates to:
  /// **'Dados de tendÃªncia ao longo do tempo. Toque em qualquer grÃ¡fico para uma vista detalhada.'**
  String get infoCharts;

  /// No description provided for @infoExpenseTrackerSummary.
  ///
  /// In pt, this message translates to:
  /// **'OrÃ§amentado = despesa mensal planeada. Real = o que gastou atÃ© agora. Restante = orÃ§amento menos real.'**
  String get infoExpenseTrackerSummary;

  /// No description provided for @infoExpenseTrackerProgress.
  ///
  /// In pt, this message translates to:
  /// **'Verde: abaixo de 75% do orÃ§amento. Amarelo: 75-100%. Vermelho: acima do orÃ§amento.'**
  String get infoExpenseTrackerProgress;

  /// No description provided for @infoExpenseTrackerFilter.
  ///
  /// In pt, this message translates to:
  /// **'Filtre despesas por texto, categoria ou intervalo de datas.'**
  String get infoExpenseTrackerFilter;

  /// No description provided for @infoSavingsProjection.
  ///
  /// In pt, this message translates to:
  /// **'Baseado nas suas contribuiÃ§Ãµes mensais mÃ©dias. \"No caminho certo\" significa que o ritmo atual atinge o objetivo no prazo. \"Atrasado\" significa que precisa de aumentar as contribuiÃ§Ãµes.'**
  String get infoSavingsProjection;

  /// No description provided for @infoSavingsRequired.
  ///
  /// In pt, this message translates to:
  /// **'O montante que precisa de poupar por mÃªs a partir de agora para atingir o objetivo no prazo.'**
  String get infoSavingsRequired;

  /// No description provided for @infoCoachModes.
  ///
  /// In pt, this message translates to:
  /// **'Eco: gratuito, sem memÃ³ria de conversa.\nPlus: 1 crÃ©dito por mensagem, lembra as Ãºltimas 5 mensagens.\nPro: 2 crÃ©ditos por mensagem, memÃ³ria de conversa completa.'**
  String get infoCoachModes;

  /// No description provided for @infoCoachCredits.
  ///
  /// In pt, this message translates to:
  /// **'Os crÃ©ditos sÃ£o usados nos modos Plus e Pro. Recebe crÃ©ditos iniciais ao registar-se. O modo Eco Ã© sempre gratuito.'**
  String get infoCoachCredits;

  /// No description provided for @helperWizardGrossSalary.
  ///
  /// In pt, this message translates to:
  /// **'O seu salÃ¡rio mensal total antes de impostos'**
  String get helperWizardGrossSalary;

  /// No description provided for @helperWizardMealAllowance.
  ///
  /// In pt, this message translates to:
  /// **'SubsÃ­dio de refeiÃ§Ã£o diÃ¡rio do empregador (se aplicÃ¡vel)'**
  String get helperWizardMealAllowance;

  /// No description provided for @helperWizardRent.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento mensal de habitaÃ§Ã£o'**
  String get helperWizardRent;

  /// No description provided for @helperWizardGroceries.
  ///
  /// In pt, this message translates to:
  /// **'OrÃ§amento mensal de alimentaÃ§Ã£o e produtos domÃ©sticos'**
  String get helperWizardGroceries;

  /// No description provided for @helperWizardTransport.
  ///
  /// In pt, this message translates to:
  /// **'Custos mensais de transporte (combustÃ­vel, transportes pÃºblicos, etc.)'**
  String get helperWizardTransport;

  /// No description provided for @helperWizardUtilities.
  ///
  /// In pt, this message translates to:
  /// **'Eletricidade, Ã¡gua e gÃ¡s mensais'**
  String get helperWizardUtilities;

  /// No description provided for @helperWizardTelecom.
  ///
  /// In pt, this message translates to:
  /// **'Internet, telefone e TV mensais'**
  String get helperWizardTelecom;

  /// How it works section title
  ///
  /// In pt, this message translates to:
  /// **'Como funciona?'**
  String get savingsGoalHowItWorksTitle;

  /// How it works step 1
  ///
  /// In pt, this message translates to:
  /// **'Crie um objetivo com um nome e o valor que pretende atingir (ex: \"FÃ©rias â€” 2 000 â‚¬\").'**
  String get savingsGoalHowItWorksStep1;

  /// How it works step 2
  ///
  /// In pt, this message translates to:
  /// **'Opcionalmente defina uma data limite para ter um prazo de referÃªncia.'**
  String get savingsGoalHowItWorksStep2;

  /// How it works step 3
  ///
  /// In pt, this message translates to:
  /// **'Sempre que poupar dinheiro, toque no objetivo e registe uma contribuiÃ§Ã£o com o valor e a data.'**
  String get savingsGoalHowItWorksStep3;

  /// How it works step 4
  ///
  /// In pt, this message translates to:
  /// **'Acompanhe o progresso: a barra mostra quanto jÃ¡ poupou e a projeÃ§Ã£o estima quando atingirÃ¡ o objetivo.'**
  String get savingsGoalHowItWorksStep4;

  /// Dashboard hint text
  ///
  /// In pt, this message translates to:
  /// **'Toque num objetivo para ver detalhes e registar contribuiÃ§Ãµes.'**
  String get savingsGoalDashboardHint;

  /// No description provided for @rateLimitMessage.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, aguarde um momento antes de tentar novamente'**
  String get rateLimitMessage;

  /// No description provided for @planningExportTitle.
  ///
  /// In pt, this message translates to:
  /// **'Exportar'**
  String get planningExportTitle;

  /// No description provided for @planningImportTitle.
  ///
  /// In pt, this message translates to:
  /// **'Importar'**
  String get planningImportTitle;

  /// No description provided for @planningExportShoppingList.
  ///
  /// In pt, this message translates to:
  /// **'Exportar lista de compras'**
  String get planningExportShoppingList;

  /// No description provided for @planningImportShoppingList.
  ///
  /// In pt, this message translates to:
  /// **'Importar lista de compras'**
  String get planningImportShoppingList;

  /// No description provided for @planningExportMealPlan.
  ///
  /// In pt, this message translates to:
  /// **'Exportar plano de refeiÃ§Ãµes'**
  String get planningExportMealPlan;

  /// No description provided for @planningImportMealPlan.
  ///
  /// In pt, this message translates to:
  /// **'Importar plano de refeiÃ§Ãµes'**
  String get planningImportMealPlan;

  /// No description provided for @planningExportPantry.
  ///
  /// In pt, this message translates to:
  /// **'Exportar despensa'**
  String get planningExportPantry;

  /// No description provided for @planningImportPantry.
  ///
  /// In pt, this message translates to:
  /// **'Importar despensa'**
  String get planningImportPantry;

  /// No description provided for @planningExportFreeformMeals.
  ///
  /// In pt, this message translates to:
  /// **'Exportar refeiÃ§Ãµes livres'**
  String get planningExportFreeformMeals;

  /// No description provided for @planningImportFreeformMeals.
  ///
  /// In pt, this message translates to:
  /// **'Importar refeiÃ§Ãµes livres'**
  String get planningImportFreeformMeals;

  /// No description provided for @planningFormatCsv.
  ///
  /// In pt, this message translates to:
  /// **'CSV'**
  String get planningFormatCsv;

  /// No description provided for @planningFormatJson.
  ///
  /// In pt, this message translates to:
  /// **'JSON'**
  String get planningFormatJson;

  /// No description provided for @planningImportSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Importado com sucesso'**
  String get planningImportSuccess;

  /// No description provided for @planningImportError.
  ///
  /// In pt, this message translates to:
  /// **'ImportaÃ§Ã£o falhou: {error}'**
  String planningImportError(String error);

  /// No description provided for @planningExportSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Exportado com sucesso'**
  String get planningExportSuccess;

  /// No description provided for @planningDataPortability.
  ///
  /// In pt, this message translates to:
  /// **'Portabilidade de dados'**
  String get planningDataPortability;

  /// No description provided for @planningDataPortabilityDesc.
  ///
  /// In pt, this message translates to:
  /// **'Importar e exportar artefactos de planeamento'**
  String get planningDataPortabilityDesc;

  /// No description provided for @mealBudgetInsightTitle.
  ///
  /// In pt, this message translates to:
  /// **'VisÃ£o do OrÃ§amento'**
  String get mealBudgetInsightTitle;

  /// No description provided for @mealBudgetStatusSafe.
  ///
  /// In pt, this message translates to:
  /// **'No caminho'**
  String get mealBudgetStatusSafe;

  /// No description provided for @mealBudgetStatusWatch.
  ///
  /// In pt, this message translates to:
  /// **'AtenÃ§Ã£o'**
  String get mealBudgetStatusWatch;

  /// No description provided for @mealBudgetStatusOver.
  ///
  /// In pt, this message translates to:
  /// **'Acima do orÃ§amento'**
  String get mealBudgetStatusOver;

  /// No description provided for @mealBudgetWeeklyCost.
  ///
  /// In pt, this message translates to:
  /// **'Custo semanal estimado'**
  String get mealBudgetWeeklyCost;

  /// No description provided for @mealBudgetProjectedMonthly.
  ///
  /// In pt, this message translates to:
  /// **'ProjeÃ§Ã£o mensal'**
  String get mealBudgetProjectedMonthly;

  /// No description provided for @mealBudgetMonthlyBudget.
  ///
  /// In pt, this message translates to:
  /// **'OrÃ§amento mensal de alimentaÃ§Ã£o'**
  String get mealBudgetMonthlyBudget;

  /// No description provided for @mealBudgetRemaining.
  ///
  /// In pt, this message translates to:
  /// **'OrÃ§amento restante'**
  String get mealBudgetRemaining;

  /// No description provided for @mealBudgetTopExpensive.
  ///
  /// In pt, this message translates to:
  /// **'RefeiÃ§Ãµes mais caras'**
  String get mealBudgetTopExpensive;

  /// No description provided for @mealBudgetSuggestedSwaps.
  ///
  /// In pt, this message translates to:
  /// **'Trocas mais baratas sugeridas'**
  String get mealBudgetSuggestedSwaps;

  /// No description provided for @mealBudgetViewDetails.
  ///
  /// In pt, this message translates to:
  /// **'Ver detalhes'**
  String get mealBudgetViewDetails;

  /// No description provided for @mealBudgetApplySwap.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar'**
  String get mealBudgetApplySwap;

  /// No description provided for @mealBudgetSwapSavings.
  ///
  /// In pt, this message translates to:
  /// **'Poupa {amount}'**
  String mealBudgetSwapSavings(String amount);

  /// No description provided for @mealBudgetDailyBreakdown.
  ///
  /// In pt, this message translates to:
  /// **'Custo diÃ¡rio detalhado'**
  String get mealBudgetDailyBreakdown;

  /// No description provided for @mealBudgetShoppingImpact.
  ///
  /// In pt, this message translates to:
  /// **'Impacto nas compras'**
  String get mealBudgetShoppingImpact;

  /// No description provided for @mealBudgetUniqueIngredients.
  ///
  /// In pt, this message translates to:
  /// **'Ingredientes Ãºnicos'**
  String get mealBudgetUniqueIngredients;

  /// No description provided for @mealBudgetEstShoppingCost.
  ///
  /// In pt, this message translates to:
  /// **'Custo estimado de compras'**
  String get mealBudgetEstShoppingCost;

  /// No description provided for @productUpdatesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novidades do Produto'**
  String get productUpdatesTitle;

  /// No description provided for @whatsNewTab.
  ///
  /// In pt, this message translates to:
  /// **'Novidades'**
  String get whatsNewTab;

  /// No description provided for @roadmapTab.
  ///
  /// In pt, this message translates to:
  /// **'Roteiro'**
  String get roadmapTab;

  /// No description provided for @noUpdatesYet.
  ///
  /// In pt, this message translates to:
  /// **'Sem novidades ainda'**
  String get noUpdatesYet;

  /// No description provided for @noRoadmapItems.
  ///
  /// In pt, this message translates to:
  /// **'Sem itens no roteiro ainda'**
  String get noRoadmapItems;

  /// No description provided for @roadmapNow.
  ///
  /// In pt, this message translates to:
  /// **'Agora'**
  String get roadmapNow;

  /// No description provided for @roadmapNext.
  ///
  /// In pt, this message translates to:
  /// **'Em breve'**
  String get roadmapNext;

  /// No description provided for @roadmapLater.
  ///
  /// In pt, this message translates to:
  /// **'Mais tarde'**
  String get roadmapLater;

  /// No description provided for @productUpdatesSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Changelog e funcionalidades futuras'**
  String get productUpdatesSubtitle;

  /// No description provided for @whatsNewDialogTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novidades'**
  String get whatsNewDialogTitle;

  /// No description provided for @whatsNewDialogDismiss.
  ///
  /// In pt, this message translates to:
  /// **'Entendi'**
  String get whatsNewDialogDismiss;

  /// No description provided for @confidenceCenterTitle.
  ///
  /// In pt, this message translates to:
  /// **'Centro de ConfianÃ§a'**
  String get confidenceCenterTitle;

  /// No description provided for @confidenceSyncHealth.
  ///
  /// In pt, this message translates to:
  /// **'Estado de SincronizaÃ§Ã£o'**
  String get confidenceSyncHealth;

  /// No description provided for @confidenceDataAlerts.
  ///
  /// In pt, this message translates to:
  /// **'Alertas de Qualidade dos Dados'**
  String get confidenceDataAlerts;

  /// No description provided for @confidenceRecommendedActions.
  ///
  /// In pt, this message translates to:
  /// **'AÃ§Ãµes Recomendadas'**
  String get confidenceRecommendedActions;

  /// No description provided for @confidenceCenterSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Frescura dos dados e saÃºde do sistema'**
  String get confidenceCenterSubtitle;

  /// No description provided for @confidenceCenterTile.
  ///
  /// In pt, this message translates to:
  /// **'Centro de ConfianÃ§a'**
  String get confidenceCenterTile;

  /// No description provided for @pantryPickerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar Despensa'**
  String get pantryPickerTitle;

  /// No description provided for @pantrySearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar ingredientes...'**
  String get pantrySearchHint;

  /// No description provided for @pantryTabAlwaysHave.
  ///
  /// In pt, this message translates to:
  /// **'Sempre Tenho'**
  String get pantryTabAlwaysHave;

  /// No description provided for @pantryTabThisWeek.
  ///
  /// In pt, this message translates to:
  /// **'Esta Semana'**
  String get pantryTabThisWeek;

  /// No description provided for @pantrySummaryLabel.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 item na despensa} other{{count} itens na despensa}}'**
  String pantrySummaryLabel(int count);

  /// No description provided for @pantryEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get pantryEdit;

  /// No description provided for @pantryUseWhatWeHave.
  ///
  /// In pt, this message translates to:
  /// **'Usar o Que Temos'**
  String get pantryUseWhatWeHave;

  /// No description provided for @pantryMarkAtHome.
  ///
  /// In pt, this message translates to:
  /// **'JÃ¡ tenho em casa'**
  String get pantryMarkAtHome;

  /// No description provided for @pantryHaveIt.
  ///
  /// In pt, this message translates to:
  /// **'Tenho'**
  String get pantryHaveIt;

  /// No description provided for @pantryCoverageLabel.
  ///
  /// In pt, this message translates to:
  /// **'{pct}% coberto pela despensa'**
  String pantryCoverageLabel(int pct);

  /// No description provided for @pantryStaples.
  ///
  /// In pt, this message translates to:
  /// **'ESSENCIAIS (SEMPRE EM STOCK)'**
  String get pantryStaples;

  /// No description provided for @pantryWeekly.
  ///
  /// In pt, this message translates to:
  /// **'DESPENSA DESTA SEMANA'**
  String get pantryWeekly;

  /// No description provided for @pantryAddedToWeekly.
  ///
  /// In pt, this message translates to:
  /// **'{name} adicionado Ã  despensa semanal'**
  String pantryAddedToWeekly(String name);

  /// No description provided for @pantryRemovedFromList.
  ///
  /// In pt, this message translates to:
  /// **'{name} removido da lista (jÃ¡ em casa)'**
  String pantryRemovedFromList(String name);

  /// No description provided for @pantryMarkedAtHome.
  ///
  /// In pt, this message translates to:
  /// **'{name} marcado como jÃ¡ em casa'**
  String pantryMarkedAtHome(String name);

  /// No description provided for @householdActivityTitle.
  ///
  /// In pt, this message translates to:
  /// **'Atividade do Agregado'**
  String get householdActivityTitle;

  /// No description provided for @householdActivityFilterAll.
  ///
  /// In pt, this message translates to:
  /// **'Tudo'**
  String get householdActivityFilterAll;

  /// No description provided for @householdActivityFilterShopping.
  ///
  /// In pt, this message translates to:
  /// **'Compras'**
  String get householdActivityFilterShopping;

  /// No description provided for @householdActivityFilterMeals.
  ///
  /// In pt, this message translates to:
  /// **'RefeiÃ§Ãµes'**
  String get householdActivityFilterMeals;

  /// No description provided for @householdActivityFilterExpenses.
  ///
  /// In pt, this message translates to:
  /// **'Despesas'**
  String get householdActivityFilterExpenses;

  /// No description provided for @householdActivityFilterPantry.
  ///
  /// In pt, this message translates to:
  /// **'Despensa'**
  String get householdActivityFilterPantry;

  /// No description provided for @householdActivityFilterSettings.
  ///
  /// In pt, this message translates to:
  /// **'DefiniÃ§Ãµes'**
  String get householdActivityFilterSettings;

  /// No description provided for @householdActivityEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Sem atividade'**
  String get householdActivityEmpty;

  /// No description provided for @householdActivityEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'As aÃ§Ãµes partilhadas do seu agregado aparecerÃ£o aqui.'**
  String get householdActivityEmptyMessage;

  /// No description provided for @householdActivityToday.
  ///
  /// In pt, this message translates to:
  /// **'HOJE'**
  String get householdActivityToday;

  /// No description provided for @householdActivityYesterday.
  ///
  /// In pt, this message translates to:
  /// **'ONTEM'**
  String get householdActivityYesterday;

  /// No description provided for @householdActivityThisWeek.
  ///
  /// In pt, this message translates to:
  /// **'ESTA SEMANA'**
  String get householdActivityThisWeek;

  /// No description provided for @householdActivityOlder.
  ///
  /// In pt, this message translates to:
  /// **'ANTERIORES'**
  String get householdActivityOlder;

  /// No description provided for @householdActivityJustNow.
  ///
  /// In pt, this message translates to:
  /// **'Agora mesmo'**
  String get householdActivityJustNow;

  /// No description provided for @householdActivityMinutesAgo.
  ///
  /// In pt, this message translates to:
  /// **'{count} min atrÃ¡s'**
  String householdActivityMinutesAgo(int count);

  /// No description provided for @householdActivityHoursAgo.
  ///
  /// In pt, this message translates to:
  /// **'{count}h atrÃ¡s'**
  String householdActivityHoursAgo(int count);

  /// No description provided for @householdActivityDaysAgo.
  ///
  /// In pt, this message translates to:
  /// **'{count}d atrÃ¡s'**
  String householdActivityDaysAgo(int count);

  /// No description provided for @householdActivityAddedBy.
  ///
  /// In pt, this message translates to:
  /// **'Adicionado por {name}'**
  String householdActivityAddedBy(String name);

  /// No description provided for @householdActivityRemovedBy.
  ///
  /// In pt, this message translates to:
  /// **'Removido por {name}'**
  String householdActivityRemovedBy(String name);

  /// No description provided for @householdActivitySwappedBy.
  ///
  /// In pt, this message translates to:
  /// **'Trocado por {name}'**
  String householdActivitySwappedBy(String name);

  /// No description provided for @householdActivityUpdatedBy.
  ///
  /// In pt, this message translates to:
  /// **'Atualizado por {name}'**
  String householdActivityUpdatedBy(String name);

  /// No description provided for @householdActivityCheckedBy.
  ///
  /// In pt, this message translates to:
  /// **'Marcado por {name}'**
  String householdActivityCheckedBy(String name);

  /// No description provided for @barcodeScanTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ler Codigo de Barras'**
  String get barcodeScanTitle;

  /// No description provided for @barcodeScanHint.
  ///
  /// In pt, this message translates to:
  /// **'Aponte a camera para um codigo de barras'**
  String get barcodeScanHint;

  /// No description provided for @barcodeScanTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Ler codigo de barras'**
  String get barcodeScanTooltip;

  /// No description provided for @barcodeProductFound.
  ///
  /// In pt, this message translates to:
  /// **'Produto Encontrado'**
  String get barcodeProductFound;

  /// No description provided for @barcodeProductNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Produto Nao Encontrado'**
  String get barcodeProductNotFound;

  /// No description provided for @barcodeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Codigo de barras'**
  String get barcodeLabel;

  /// No description provided for @barcodeAddToList.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar a Lista'**
  String get barcodeAddToList;

  /// No description provided for @barcodeManualEntry.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum produto encontrado. Insira os dados manualmente:'**
  String get barcodeManualEntry;

  /// No description provided for @barcodeProductName.
  ///
  /// In pt, this message translates to:
  /// **'Nome do produto'**
  String get barcodeProductName;

  /// No description provided for @barcodePrice.
  ///
  /// In pt, this message translates to:
  /// **'Preco'**
  String get barcodePrice;

  /// No description provided for @barcodeAddedToList.
  ///
  /// In pt, this message translates to:
  /// **'{name} adicionado a lista de compras'**
  String barcodeAddedToList(String name);

  /// No description provided for @barcodeInvoiceDetected.
  ///
  /// In pt, this message translates to:
  /// **'Este Ã© um cÃ³digo de fatura, nÃ£o de produto'**
  String get barcodeInvoiceDetected;

  /// No description provided for @barcodeInvoiceAction.
  ///
  /// In pt, this message translates to:
  /// **'Abrir Scanner de Recibos'**
  String get barcodeInvoiceAction;

  /// No description provided for @quickAddTooltip.
  ///
  /// In pt, this message translates to:
  /// **'AÃ§Ãµes rÃ¡pidas'**
  String get quickAddTooltip;

  /// No description provided for @quickAddExpense.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar despesa'**
  String get quickAddExpense;

  /// No description provided for @quickAddShopping.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar item de compras'**
  String get quickAddShopping;

  /// No description provided for @quickOpenMeals.
  ///
  /// In pt, this message translates to:
  /// **'Planeador de refeiÃ§Ãµes'**
  String get quickOpenMeals;

  /// No description provided for @quickOpenAssistant.
  ///
  /// In pt, this message translates to:
  /// **'Assistente'**
  String get quickOpenAssistant;

  /// No description provided for @freeformBadge.
  ///
  /// In pt, this message translates to:
  /// **'Livre'**
  String get freeformBadge;

  /// No description provided for @freeformCreateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar refeiÃ§Ã£o livre'**
  String get freeformCreateTitle;

  /// No description provided for @freeformEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar refeiÃ§Ã£o livre'**
  String get freeformEditTitle;

  /// No description provided for @freeformTitleLabel.
  ///
  /// In pt, this message translates to:
  /// **'TÃ­tulo da refeiÃ§Ã£o'**
  String get freeformTitleLabel;

  /// No description provided for @freeformTitleHint.
  ///
  /// In pt, this message translates to:
  /// **'ex. Sobras, Pizza de takeaway'**
  String get freeformTitleHint;

  /// No description provided for @freeformNoteLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nota (opcional)'**
  String get freeformNoteLabel;

  /// No description provided for @freeformNoteHint.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes sobre esta refeiÃ§Ã£o'**
  String get freeformNoteHint;

  /// No description provided for @freeformCostLabel.
  ///
  /// In pt, this message translates to:
  /// **'Custo estimado (opcional)'**
  String get freeformCostLabel;

  /// No description provided for @freeformTagsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Etiquetas'**
  String get freeformTagsLabel;

  /// No description provided for @freeformTagLeftovers.
  ///
  /// In pt, this message translates to:
  /// **'Sobras'**
  String get freeformTagLeftovers;

  /// No description provided for @freeformTagPantryMeal.
  ///
  /// In pt, this message translates to:
  /// **'Despensa'**
  String get freeformTagPantryMeal;

  /// No description provided for @freeformTagTakeout.
  ///
  /// In pt, this message translates to:
  /// **'Takeaway'**
  String get freeformTagTakeout;

  /// No description provided for @freeformTagQuickMeal.
  ///
  /// In pt, this message translates to:
  /// **'RefeiÃ§Ã£o rÃ¡pida'**
  String get freeformTagQuickMeal;

  /// No description provided for @freeformShoppingItemsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Itens de compras'**
  String get freeformShoppingItemsLabel;

  /// No description provided for @freeformAddItem.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar item'**
  String get freeformAddItem;

  /// No description provided for @freeformItemName.
  ///
  /// In pt, this message translates to:
  /// **'Nome do item'**
  String get freeformItemName;

  /// No description provided for @freeformItemQuantity.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade'**
  String get freeformItemQuantity;

  /// No description provided for @freeformItemUnit.
  ///
  /// In pt, this message translates to:
  /// **'Unidade'**
  String get freeformItemUnit;

  /// No description provided for @freeformItemPrice.
  ///
  /// In pt, this message translates to:
  /// **'PreÃ§o est.'**
  String get freeformItemPrice;

  /// No description provided for @freeformItemStore.
  ///
  /// In pt, this message translates to:
  /// **'Loja'**
  String get freeformItemStore;

  /// No description provided for @freeformShoppingItemCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} itens de compras'**
  String freeformShoppingItemCount(int count);

  /// No description provided for @freeformAddToSlot.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar refeiÃ§Ã£o livre'**
  String get freeformAddToSlot;

  /// No description provided for @freeformReplace.
  ///
  /// In pt, this message translates to:
  /// **'Substituir por refeiÃ§Ã£o livre'**
  String get freeformReplace;

  /// Title for the Insights screen
  ///
  /// In pt, this message translates to:
  /// **'AnÃ¡lise'**
  String get insightsTitle;

  /// Subtitle for expense trends tile
  ///
  /// In pt, this message translates to:
  /// **'Analisar gastos ao longo do tempo'**
  String get insightsAnalyzeSpending;

  /// Subtitle for savings goals tile
  ///
  /// In pt, this message translates to:
  /// **'Acompanhar progresso das metas'**
  String get insightsTrackProgress;

  /// Subtitle for tax simulator tile
  ///
  /// In pt, this message translates to:
  /// **'Estimar resultado fiscal anual'**
  String get insightsTaxOutcome;

  /// Title for the More screen
  ///
  /// In pt, this message translates to:
  /// **'Mais'**
  String get moreTitle;

  /// Detailed dashboard tile title
  ///
  /// In pt, this message translates to:
  /// **'Painel Detalhado'**
  String get moreDetailedDashboard;

  /// Detailed dashboard tile subtitle
  ///
  /// In pt, this message translates to:
  /// **'Abrir painel financeiro completo com todos os cartÃµes'**
  String get moreDetailedDashboardSubtitle;

  /// Savings goals tile subtitle
  ///
  /// In pt, this message translates to:
  /// **'Acompanhar e atualizar o progresso das metas'**
  String get moreSavingsSubtitle;

  /// Notifications tile subtitle
  ///
  /// In pt, this message translates to:
  /// **'OrÃ§amentos, contas e lembretes'**
  String get moreNotificationsSubtitle;

  /// Settings tile subtitle
  ///
  /// In pt, this message translates to:
  /// **'PreferÃªncias, perfil e painel'**
  String get moreSettingsSubtitle;

  /// Free plan label
  ///
  /// In pt, this message translates to:
  /// **'Plano GrÃ¡tis'**
  String get morePlanFree;

  /// Trial active label
  ///
  /// In pt, this message translates to:
  /// **'PerÃ­odo de Teste Ativo'**
  String get morePlanTrial;

  /// Pro plan label
  ///
  /// In pt, this message translates to:
  /// **'Plano Pro'**
  String get morePlanPro;

  /// Family plan label
  ///
  /// In pt, this message translates to:
  /// **'Plano FamÃ­lia'**
  String get morePlanFamily;

  /// Manage plan subtitle
  ///
  /// In pt, this message translates to:
  /// **'Gerir o teu plano e faturaÃ§Ã£o'**
  String get morePlanManage;

  /// Free plan limits summary
  ///
  /// In pt, this message translates to:
  /// **'{categories} categorias • {goals} meta de poupanÃ§a'**
  String morePlanLimits(int categories, int goals);

  /// Count of paused items on subscription tile
  ///
  /// In pt, this message translates to:
  /// **'{count} itens pausados'**
  String moreItemsPaused(int count);

  /// Upgrade CTA text
  ///
  /// In pt, this message translates to:
  /// **'Upgrade →'**
  String get moreUpgrade;

  /// Title for the Plan hub screen
  ///
  /// In pt, this message translates to:
  /// **'Planear'**
  String get planTitle;

  /// Grocery tile subtitle
  ///
  /// In pt, this message translates to:
  /// **'Explorar produtos e preÃ§os'**
  String get planGrocerySubtitle;

  /// Shopping list tile title
  ///
  /// In pt, this message translates to:
  /// **'Lista de Compras'**
  String get planShoppingList;

  /// Shopping list tile subtitle
  ///
  /// In pt, this message translates to:
  /// **'Rever e finalizar compras'**
  String get planShoppingSubtitle;

  /// Meal planner tile subtitle
  ///
  /// In pt, this message translates to:
  /// **'Gerar planos semanais acessÃ­veis'**
  String get planMealSubtitle;

  /// Active memory status line in coach mode card
  ///
  /// In pt, this message translates to:
  /// **'MemÃ³ria ativa: {mode} ({percent}%)'**
  String coachActiveMemory(String mode, int percent);

  /// Note about credit cost per message
  ///
  /// In pt, this message translates to:
  /// **'Custo por mensagem enviada. A resposta do coach nÃ£o consome crÃ©ditos.'**
  String get coachCostPerMessageNote;

  /// Tooltip for expanding fallback card
  ///
  /// In pt, this message translates to:
  /// **'Expandir aviso'**
  String get coachExpandTip;

  /// Tooltip for collapsing fallback card
  ///
  /// In pt, this message translates to:
  /// **'Minimizar aviso'**
  String get coachCollapseTip;

  /// Feature discovery card title
  ///
  /// In pt, this message translates to:
  /// **'Experimentar {name}'**
  String featureTryName(String name);

  /// Feature discovery card CTA button
  ///
  /// In pt, this message translates to:
  /// **'Explorar {name}'**
  String featureExploreName(String name);

  /// Lock overlay message
  ///
  /// In pt, this message translates to:
  /// **'{name} requer Premium'**
  String featureRequiresPremium(String name);

  /// Lock overlay CTA
  ///
  /// In pt, this message translates to:
  /// **'Toca para fazer upgrade'**
  String get featureTapToUpgrade;

  /// AI Coach feature name
  ///
  /// In pt, this message translates to:
  /// **'Coach IA'**
  String get featureNameAiCoach;

  /// Meal Planner feature name
  ///
  /// In pt, this message translates to:
  /// **'Planeador de RefeiÃ§Ãµes'**
  String get featureNameMealPlanner;

  /// Expense Tracker feature name
  ///
  /// In pt, this message translates to:
  /// **'Rastreador de Despesas'**
  String get featureNameExpenseTracker;

  /// Savings Goals feature name
  ///
  /// In pt, this message translates to:
  /// **'Metas de PoupanÃ§a'**
  String get featureNameSavingsGoals;

  /// Shopping List feature name
  ///
  /// In pt, this message translates to:
  /// **'Lista de Compras'**
  String get featureNameShoppingList;

  /// Grocery Browser feature name
  ///
  /// In pt, this message translates to:
  /// **'Explorador de Produtos'**
  String get featureNameGroceryBrowser;

  /// Export Reports feature name
  ///
  /// In pt, this message translates to:
  /// **'Exportar RelatÃ³rios'**
  String get featureNameExportReports;

  /// Tax Simulator feature name
  ///
  /// In pt, this message translates to:
  /// **'Simulador Fiscal'**
  String get featureNameTaxSimulator;

  /// Dashboard feature name
  ///
  /// In pt, this message translates to:
  /// **'Painel'**
  String get featureNameDashboard;

  /// AI Coach tagline
  ///
  /// In pt, this message translates to:
  /// **'O teu consultor financeiro pessoal'**
  String get featureTagAiCoach;

  /// Meal Planner tagline
  ///
  /// In pt, this message translates to:
  /// **'Poupa dinheiro na alimentaÃ§Ã£o'**
  String get featureTagMealPlanner;

  /// Expense Tracker tagline
  ///
  /// In pt, this message translates to:
  /// **'Sabe para onde vai cada euro'**
  String get featureTagExpenseTracker;

  /// Savings Goals tagline
  ///
  /// In pt, this message translates to:
  /// **'Concretiza os teus sonhos'**
  String get featureTagSavingsGoals;

  /// Shopping List tagline
  ///
  /// In pt, this message translates to:
  /// **'Compra de forma mais inteligente'**
  String get featureTagShoppingList;

  /// Grocery Browser tagline
  ///
  /// In pt, this message translates to:
  /// **'Compara preÃ§os instantaneamente'**
  String get featureTagGroceryBrowser;

  /// Export Reports tagline
  ///
  /// In pt, this message translates to:
  /// **'RelatÃ³rios profissionais de orÃ§amento'**
  String get featureTagExportReports;

  /// Tax Simulator tagline
  ///
  /// In pt, this message translates to:
  /// **'Planeamento fiscal multi-paÃ­s'**
  String get featureTagTaxSimulator;

  /// Dashboard tagline
  ///
  /// In pt, this message translates to:
  /// **'A tua visÃ£o financeira geral'**
  String get featureTagDashboard;

  /// AI Coach description
  ///
  /// In pt, this message translates to:
  /// **'ObtÃ©m insights personalizados sobre os teus hÃ¡bitos de gastos, dicas de poupanÃ§a e otimizaÃ§Ã£o do orÃ§amento com IA.'**
  String get featureDescAiCoach;

  /// Meal Planner description
  ///
  /// In pt, this message translates to:
  /// **'Planeia refeiÃ§Ãµes semanais dentro do teu orÃ§amento. A IA gera receitas com base nas tuas preferÃªncias e necessidades alimentares.'**
  String get featureDescMealPlanner;

  /// Expense Tracker description
  ///
  /// In pt, this message translates to:
  /// **'Acompanha despesas reais vs. orÃ§amento em tempo real. VÃª onde gastas demais e onde podes poupar.'**
  String get featureDescExpenseTracker;

  /// Savings Goals description
  ///
  /// In pt, this message translates to:
  /// **'Define metas de poupanÃ§a com prazos, acompanha contribuiÃ§Ãµes e vÃª projeÃ§Ãµes de quando atingirÃ¡s os teus objetivos.'**
  String get featureDescSavingsGoals;

  /// Shopping List description
  ///
  /// In pt, this message translates to:
  /// **'Cria listas de compras partilhadas em tempo real. Marca itens enquanto compras, finaliza e acompanha gastos.'**
  String get featureDescShoppingList;

  /// Grocery Browser description
  ///
  /// In pt, this message translates to:
  /// **'Explora produtos de vÃ¡rias lojas, compara preÃ§os e adiciona as melhores ofertas diretamente Ã  tua lista de compras.'**
  String get featureDescGroceryBrowser;

  /// Export Reports description
  ///
  /// In pt, this message translates to:
  /// **'Exporta o teu orÃ§amento, despesas e resumos financeiros em PDF ou CSV para os teus registos ou contabilista.'**
  String get featureDescExportReports;

  /// Tax Simulator description
  ///
  /// In pt, this message translates to:
  /// **'Compara obrigaÃ§Ãµes fiscais entre paÃ­ses. Perfeito para expatriados e quem considera mudanÃ§a de paÃ­s.'**
  String get featureDescTaxSimulator;

  /// Dashboard description
  ///
  /// In pt, this message translates to:
  /// **'VÃª o resumo completo do orÃ§amento, grÃ¡ficos e saÃºde financeira de relance.'**
  String get featureDescDashboard;

  /// Early phase trial headline
  ///
  /// In pt, this message translates to:
  /// **'PerÃ­odo de Teste Premium Ativo'**
  String get trialPremiumActive;

  /// Mid phase trial headline
  ///
  /// In pt, this message translates to:
  /// **'O teu perÃ­odo de teste estÃ¡ a meio'**
  String get trialHalfway;

  /// Urgent phase headline with days count
  ///
  /// In pt, this message translates to:
  /// **'{count} dias restantes no teu perÃ­odo de teste!'**
  String trialDaysLeftInTrial(int count);

  /// Last day urgent headline
  ///
  /// In pt, this message translates to:
  /// **'Ãšltimo dia do teu perÃ­odo de teste grÃ¡tis!'**
  String get trialLastDay;

  /// CTA button text early/mid phase
  ///
  /// In pt, this message translates to:
  /// **'Ver Planos'**
  String get trialSeePlans;

  /// CTA button text urgent phase
  ///
  /// In pt, this message translates to:
  /// **'Upgrade Agora — MantÃ©m os Teus Dados'**
  String get trialUpgradeNow;

  /// Urgent phase subtitle
  ///
  /// In pt, this message translates to:
  /// **'O teu acesso premium termina em breve. Faz upgrade para manter o Coach IA, Planeador de RefeiÃ§Ãµes e todos os teus dados.'**
  String get trialSubtitleUrgent;

  /// Mid phase subtitle suggesting next feature
  ///
  /// In pt, this message translates to:
  /// **'JÃ¡ experimentaste o {name}? Aproveita ao mÃ¡ximo o teu perÃ­odo de teste!'**
  String trialSubtitleMidFeature(String name);

  /// Mid phase subtitle when all features explored
  ///
  /// In pt, this message translates to:
  /// **'EstÃ¡s a fazer Ã³timo progresso! Continua a explorar funcionalidades premium.'**
  String get trialSubtitleMidProgress;

  /// Early phase subtitle
  ///
  /// In pt, this message translates to:
  /// **'Tens acesso total a todas as funcionalidades premium. Explora tudo!'**
  String get trialSubtitleEarly;

  /// Features explored progress label
  ///
  /// In pt, this message translates to:
  /// **'{explored}/{total} funcionalidades exploradas'**
  String trialFeaturesExplored(int explored, int total);

  /// Days remaining label
  ///
  /// In pt, this message translates to:
  /// **'{count} dias restantes'**
  String trialDaysRemaining(int count);

  /// Accessibility label for trial progress bar
  ///
  /// In pt, this message translates to:
  /// **'Progresso do teste {percent}%'**
  String trialProgressLabel(int percent);

  /// Full AI Financial Coach name for trial banner
  ///
  /// In pt, this message translates to:
  /// **'Coach Financeiro IA'**
  String get featureNameAiCoachFull;

  /// No description provided for @receiptScanTitle.
  ///
  /// In pt, this message translates to:
  /// **'Scan Recibo'**
  String get receiptScanTitle;

  /// No description provided for @receiptScanQrMode.
  ///
  /// In pt, this message translates to:
  /// **'QR Code'**
  String get receiptScanQrMode;

  /// No description provided for @receiptScanPhotoMode.
  ///
  /// In pt, this message translates to:
  /// **'Foto'**
  String get receiptScanPhotoMode;

  /// No description provided for @receiptScanHint.
  ///
  /// In pt, this message translates to:
  /// **'Aponte a cÃ¢mara para o QR code do recibo'**
  String get receiptScanHint;

  /// No description provided for @receiptScanPhotoHint.
  ///
  /// In pt, this message translates to:
  /// **'Posicione o recibo e toque no botÃ£o para capturar'**
  String get receiptScanPhotoHint;

  /// No description provided for @receiptScanProcessing.
  ///
  /// In pt, this message translates to:
  /// **'A ler reciboâ€¦'**
  String get receiptScanProcessing;

  /// No description provided for @receiptScanSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Despesa de {amount} no {store} registada'**
  String receiptScanSuccess(String amount, String store);

  /// No description provided for @receiptScanFailed.
  ///
  /// In pt, this message translates to:
  /// **'NÃ£o foi possÃ­vel ler o recibo'**
  String get receiptScanFailed;

  /// No description provided for @receiptScanPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Compras feitas? Scan o recibo para registar despesa automaticamente.'**
  String get receiptScanPrompt;

  /// No description provided for @receiptMerchantUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Loja desconhecida'**
  String get receiptMerchantUnknown;

  /// No description provided for @receiptMerchantNamePrompt.
  ///
  /// In pt, this message translates to:
  /// **'Insira o nome da loja para NIF {nif}'**
  String receiptMerchantNamePrompt(String nif);

  /// No description provided for @receiptItemsMatched.
  ///
  /// In pt, this message translates to:
  /// **'{count} itens associados Ã  lista de compras'**
  String receiptItemsMatched(int count);

  /// No description provided for @quickScanReceipt.
  ///
  /// In pt, this message translates to:
  /// **'Scan Recibo'**
  String get quickScanReceipt;

  /// No description provided for @receiptReviewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Rever Recibo'**
  String get receiptReviewTitle;

  /// No description provided for @receiptReviewMerchant.
  ///
  /// In pt, this message translates to:
  /// **'Loja'**
  String get receiptReviewMerchant;

  /// No description provided for @receiptReviewDate.
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get receiptReviewDate;

  /// No description provided for @receiptReviewTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total'**
  String get receiptReviewTotal;

  /// No description provided for @receiptReviewCategory.
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get receiptReviewCategory;

  /// No description provided for @receiptReviewItems.
  ///
  /// In pt, this message translates to:
  /// **'{count} itens detetados'**
  String receiptReviewItems(int count);

  /// No description provided for @receiptReviewConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Despesa'**
  String get receiptReviewConfirm;

  /// No description provided for @receiptReviewRetake.
  ///
  /// In pt, this message translates to:
  /// **'Repetir'**
  String get receiptReviewRetake;

  /// No description provided for @receiptCameraPermissionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Acesso Ã  CÃ¢mara'**
  String get receiptCameraPermissionTitle;

  /// No description provided for @receiptCameraPermissionBody.
  ///
  /// In pt, this message translates to:
  /// **'Ã‰ necessÃ¡rio acesso Ã  cÃ¢mara para digitalizar recibos e cÃ³digos de barras.'**
  String get receiptCameraPermissionBody;

  /// No description provided for @receiptCameraPermissionAllow.
  ///
  /// In pt, this message translates to:
  /// **'Permitir'**
  String get receiptCameraPermissionAllow;

  /// No description provided for @receiptCameraPermissionDeny.
  ///
  /// In pt, this message translates to:
  /// **'Agora nÃ£o'**
  String get receiptCameraPermissionDeny;

  /// No description provided for @receiptCameraBlockedTitle.
  ///
  /// In pt, this message translates to:
  /// **'CÃ¢mara Bloqueada'**
  String get receiptCameraBlockedTitle;

  /// No description provided for @receiptCameraBlockedBody.
  ///
  /// In pt, this message translates to:
  /// **'A permissÃ£o da cÃ¢mara foi negada permanentemente. Abra as definiÃ§Ãµes para a ativar.'**
  String get receiptCameraBlockedBody;

  /// No description provided for @receiptCameraBlockedSettings.
  ///
  /// In pt, this message translates to:
  /// **'Abrir DefiniÃ§Ãµes'**
  String get receiptCameraBlockedSettings;

  /// No description provided for @groceryMarketData.
  ///
  /// In pt, this message translates to:
  /// **'Dados do mercado {marketCode}'**
  String groceryMarketData(String marketCode);

  /// No description provided for @groceryStoreCoverage.
  ///
  /// In pt, this message translates to:
  /// **'{active} lojas ativas em {total}'**
  String groceryStoreCoverage(int active, int total);

  /// No description provided for @groceryStoreFreshCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} fresca'**
  String groceryStoreFreshCount(int count);

  /// No description provided for @groceryStorePartialCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} parcial'**
  String groceryStorePartialCount(int count);

  /// No description provided for @groceryStoreFailedCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} falhada'**
  String groceryStoreFailedCount(int count);

  /// No description provided for @groceryHideStaleStores.
  ///
  /// In pt, this message translates to:
  /// **'Esconder lojas desatualizadas'**
  String get groceryHideStaleStores;

  /// No description provided for @groceryComparisonsFreshOnly.
  ///
  /// In pt, this message translates to:
  /// **'A mostrar {count} loja fresca nas comparações'**
  String groceryComparisonsFreshOnly(int count);

  /// No description provided for @navHome.
  ///
  /// In pt, this message translates to:
  /// **'InÃ­cio'**
  String get navHome;

  /// No description provided for @navHomeTip.
  ///
  /// In pt, this message translates to:
  /// **'Resumo mensal'**
  String get navHomeTip;

  /// No description provided for @navTrack.
  ///
  /// In pt, this message translates to:
  /// **'Despesas'**
  String get navTrack;

  /// No description provided for @navTrackTip.
  ///
  /// In pt, this message translates to:
  /// **'Registar despesas mensais'**
  String get navTrackTip;

  /// No description provided for @navPlan.
  ///
  /// In pt, this message translates to:
  /// **'Planear'**
  String get navPlan;

  /// No description provided for @navPlanTip.
  ///
  /// In pt, this message translates to:
  /// **'Mercearia, lista e plano de refeiÃ§Ãµes'**
  String get navPlanTip;

  /// No description provided for @navPlanAndShop.
  ///
  /// In pt, this message translates to:
  /// **'Compras'**
  String get navPlanAndShop;

  /// No description provided for @navPlanAndShopTip.
  ///
  /// In pt, this message translates to:
  /// **'Lista de compras, mercearia e refeiÃ§Ãµes'**
  String get navPlanAndShopTip;

  /// No description provided for @navMore.
  ///
  /// In pt, this message translates to:
  /// **'Mais'**
  String get navMore;

  /// No description provided for @navMoreTip.
  ///
  /// In pt, this message translates to:
  /// **'DefiniÃ§Ãµes e anÃ¡lises'**
  String get navMoreTip;

  /// No description provided for @paywallContinueFree.
  ///
  /// In pt, this message translates to:
  /// **'A continuar com o plano gratuito'**
  String get paywallContinueFree;

  /// No description provided for @paywallUpgradedPro.
  ///
  /// In pt, this message translates to:
  /// **'Atualizado para Pro â€” obrigado!'**
  String get paywallUpgradedPro;

  /// No description provided for @paywallNoRestore.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma compra anterior encontrada'**
  String get paywallNoRestore;

  /// No description provided for @paywallRestoredPro.
  ///
  /// In pt, this message translates to:
  /// **'SubscriÃ§Ã£o Pro restaurada!'**
  String get paywallRestoredPro;

  /// No description provided for @subscriptionPro.
  ///
  /// In pt, this message translates to:
  /// **'Pro'**
  String get subscriptionPro;

  /// No description provided for @subscriptionTrialLabel.
  ///
  /// In pt, this message translates to:
  /// **'Teste ({count} dias restantes)'**
  String subscriptionTrialLabel(int count);

  /// No description provided for @authConnectionError.
  ///
  /// In pt, this message translates to:
  /// **'Erro de ligaÃ§Ã£o'**
  String get authConnectionError;

  /// No description provided for @authRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get authRetry;

  /// No description provided for @authSignOut.
  ///
  /// In pt, this message translates to:
  /// **'Terminar sessÃ£o'**
  String get authSignOut;

  /// No description provided for @actionRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get actionRetry;

  /// No description provided for @settingsGroupAccount.
  ///
  /// In pt, this message translates to:
  /// **'CONTA'**
  String get settingsGroupAccount;

  /// No description provided for @settingsGroupBudget.
  ///
  /// In pt, this message translates to:
  /// **'ORÃ‡AMENTO'**
  String get settingsGroupBudget;

  /// No description provided for @settingsGroupPreferences.
  ///
  /// In pt, this message translates to:
  /// **'PREFERÃŠNCIAS'**
  String get settingsGroupPreferences;

  /// No description provided for @settingsGroupAdvanced.
  ///
  /// In pt, this message translates to:
  /// **'AVANÃ‡ADO'**
  String get settingsGroupAdvanced;

  /// No description provided for @settingsManageSubscription.
  ///
  /// In pt, this message translates to:
  /// **'Gerir SubscriÃ§Ã£o'**
  String get settingsManageSubscription;

  /// No description provided for @settingsAbout.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get settingsAbout;

  /// No description provided for @mealShowDetails.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar detalhes'**
  String get mealShowDetails;

  /// No description provided for @mealHideDetails.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar detalhes'**
  String get mealHideDetails;

  /// No description provided for @taxSimTitularesHint.
  ///
  /// In pt, this message translates to:
  /// **'NÃºmero de titulares de rendimento no agregado familiar'**
  String get taxSimTitularesHint;

  /// No description provided for @taxSimMealTypeHint.
  ///
  /// In pt, this message translates to:
  /// **'CartÃ£o: isento de imposto atÃ© ao limite legal. Dinheiro: tributado como rendimento.'**
  String get taxSimMealTypeHint;

  /// No description provided for @taxSimIRSFull.
  ///
  /// In pt, this message translates to:
  /// **'IRS (Imposto sobre o Rendimento) retenÃ§Ã£o'**
  String get taxSimIRSFull;

  /// No description provided for @taxSimSSFull.
  ///
  /// In pt, this message translates to:
  /// **'SS (SeguranÃ§a Social)'**
  String get taxSimSSFull;

  /// No description provided for @stressZoneCritical.
  ///
  /// In pt, this message translates to:
  /// **'0â€“39: PressÃ£o financeira elevada, aÃ§Ã£o urgente necessÃ¡ria'**
  String get stressZoneCritical;

  /// No description provided for @stressZoneWarning.
  ///
  /// In pt, this message translates to:
  /// **'40â€“59: Alguns riscos presentes, melhorias recomendadas'**
  String get stressZoneWarning;

  /// No description provided for @stressZoneGood.
  ///
  /// In pt, this message translates to:
  /// **'60â€“79: FinanÃ§as saudÃ¡veis, pequenas otimizaÃ§Ãµes possÃ­veis'**
  String get stressZoneGood;

  /// No description provided for @stressZoneExcellent.
  ///
  /// In pt, this message translates to:
  /// **'80â€“100: PosiÃ§Ã£o financeira forte, bem gerida'**
  String get stressZoneExcellent;

  /// No description provided for @projectionStressHint.
  ///
  /// In pt, this message translates to:
  /// **'Como este cenÃ¡rio de gastos afeta a sua pontuaÃ§Ã£o geral de saÃºde financeira (0â€“100)'**
  String get projectionStressHint;

  /// No description provided for @coachWelcomeTitle.
  ///
  /// In pt, this message translates to:
  /// **'O Seu Coach Financeiro IA'**
  String get coachWelcomeTitle;

  /// No description provided for @coachWelcomeBody.
  ///
  /// In pt, this message translates to:
  /// **'FaÃ§a perguntas sobre o seu orÃ§amento, despesas ou poupanÃ§as. O coach analisa os seus dados financeiros reais para dar conselhos personalizados.'**
  String get coachWelcomeBody;

  /// No description provided for @coachWelcomeCredits.
  ///
  /// In pt, this message translates to:
  /// **'Os crÃ©ditos sÃ£o usados nos modos Plus e Pro. O modo Eco Ã© sempre gratuito.'**
  String get coachWelcomeCredits;

  /// No description provided for @coachWelcomeRateLimit.
  ///
  /// In pt, this message translates to:
  /// **'Para garantir respostas de qualidade, existe um breve intervalo entre mensagens.'**
  String get coachWelcomeRateLimit;

  /// No description provided for @planMealsProBadge.
  ///
  /// In pt, this message translates to:
  /// **'PRO'**
  String get planMealsProBadge;

  /// No description provided for @coachBuyCredits.
  ///
  /// In pt, this message translates to:
  /// **'Comprar crÃ©ditos'**
  String get coachBuyCredits;

  /// No description provided for @coachContinueEco.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com Eco'**
  String get coachContinueEco;

  /// No description provided for @coachAchieved.
  ///
  /// In pt, this message translates to:
  /// **'Consegui!'**
  String get coachAchieved;

  /// No description provided for @coachNotYet.
  ///
  /// In pt, this message translates to:
  /// **'Ainda nÃ£o'**
  String get coachNotYet;

  /// No description provided for @coachCreditsAdded.
  ///
  /// In pt, this message translates to:
  /// **'+{count} crÃ©ditos adicionados'**
  String coachCreditsAdded(int count);

  /// No description provided for @coachPurchaseError.
  ///
  /// In pt, this message translates to:
  /// **'Erro na compra: {error}'**
  String coachPurchaseError(String error);

  /// No description provided for @coachUseMode.
  ///
  /// In pt, this message translates to:
  /// **'Usar {mode}'**
  String coachUseMode(String mode);

  /// No description provided for @coachKeepMode.
  ///
  /// In pt, this message translates to:
  /// **'Manter {mode}'**
  String coachKeepMode(String mode);

  /// No description provided for @savingsGoalSaveError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao guardar objetivo: {error}'**
  String savingsGoalSaveError(String error);

  /// No description provided for @savingsGoalDeleteError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao eliminar objetivo: {error}'**
  String savingsGoalDeleteError(String error);

  /// No description provided for @savingsGoalUpdateError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao atualizar objetivo: {error}'**
  String savingsGoalUpdateError(String error);

  /// No description provided for @settingsSubscription.
  ///
  /// In pt, this message translates to:
  /// **'SubscriÃ§Ã£o'**
  String get settingsSubscription;

  /// No description provided for @settingsSubscriptionFree.
  ///
  /// In pt, this message translates to:
  /// **'Gratuito'**
  String get settingsSubscriptionFree;

  /// No description provided for @settingsActiveCategoriesCount.
  ///
  /// In pt, this message translates to:
  /// **'Categorias Ativas ({active} de {total})'**
  String settingsActiveCategoriesCount(int active, int total);

  /// No description provided for @settingsPausedCategories.
  ///
  /// In pt, this message translates to:
  /// **'Categorias Pausadas'**
  String get settingsPausedCategories;

  /// No description provided for @settingsOpenDashboard.
  ///
  /// In pt, this message translates to:
  /// **'Abrir Dashboard Detalhado'**
  String get settingsOpenDashboard;

  /// No description provided for @settingsAssistantGroup.
  ///
  /// In pt, this message translates to:
  /// **'ASSISTENTE'**
  String get settingsAssistantGroup;

  /// No description provided for @settingsAiCoach.
  ///
  /// In pt, this message translates to:
  /// **'Coach IA'**
  String get settingsAiCoach;

  /// No description provided for @setupWizardSubsidyLabel.
  ///
  /// In pt, this message translates to:
  /// **'DUODÃ‰CIMOS'**
  String get setupWizardSubsidyLabel;

  /// No description provided for @setupWizardPerDay.
  ///
  /// In pt, this message translates to:
  /// **'/dia'**
  String get setupWizardPerDay;

  /// No description provided for @configurationError.
  ///
  /// In pt, this message translates to:
  /// **'Erro de ConfiguraÃ§Ã£o'**
  String get configurationError;

  /// No description provided for @confidenceAllHealthy.
  ///
  /// In pt, this message translates to:
  /// **'Todos os sistemas saudÃ¡veis. Nenhuma aÃ§Ã£o necessÃ¡ria.'**
  String get confidenceAllHealthy;

  /// No description provided for @confidenceNoAlerts.
  ///
  /// In pt, this message translates to:
  /// **'Sem alertas. Tudo em ordem.'**
  String get confidenceNoAlerts;

  /// No description provided for @onbSwipeHint.
  ///
  /// In pt, this message translates to:
  /// **'Deslize para continuar'**
  String get onbSwipeHint;

  /// No description provided for @onbSlideOf.
  ///
  /// In pt, this message translates to:
  /// **'Slide {current} de {total}'**
  String onbSlideOf(int current, int total);

  /// No description provided for @expenseTrendsChartLabel.
  ///
  /// In pt, this message translates to:
  /// **'GrÃ¡fico de tendÃªncias de despesas mostrando orÃ§amento versus gastos reais'**
  String get expenseTrendsChartLabel;

  /// Custom categories section title
  ///
  /// In pt, this message translates to:
  /// **'Categorias'**
  String get customCategories;

  /// Add custom category button
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Categoria'**
  String get customCategoryAdd;

  /// Edit custom category title
  ///
  /// In pt, this message translates to:
  /// **'Editar Categoria'**
  String get customCategoryEdit;

  /// Delete custom category title
  ///
  /// In pt, this message translates to:
  /// **'Eliminar Categoria'**
  String get customCategoryDelete;

  /// Delete custom category confirmation
  ///
  /// In pt, this message translates to:
  /// **'Eliminar esta categoria?'**
  String get customCategoryDeleteConfirm;

  /// Category name field label
  ///
  /// In pt, this message translates to:
  /// **'Nome da categoria'**
  String get customCategoryName;

  /// Category icon field label
  ///
  /// In pt, this message translates to:
  /// **'Ãcone'**
  String get customCategoryIcon;

  /// Category color field label
  ///
  /// In pt, this message translates to:
  /// **'Cor'**
  String get customCategoryColor;

  /// Empty state for custom categories
  ///
  /// In pt, this message translates to:
  /// **'Sem categorias personalizadas'**
  String get customCategoryEmpty;

  /// Category saved snackbar message
  ///
  /// In pt, this message translates to:
  /// **'Categoria guardada'**
  String get customCategorySaved;

  /// Category in use error message
  ///
  /// In pt, this message translates to:
  /// **'Categoria em uso, nÃ£o pode ser eliminada'**
  String get customCategoryInUse;

  /// Hint for predefined categories section
  ///
  /// In pt, this message translates to:
  /// **'Categorias predefinidas usadas em toda a aplicaÃ§Ã£o'**
  String get customCategoryPredefinedHint;

  /// Badge for predefined categories
  ///
  /// In pt, this message translates to:
  /// **'Predefinida'**
  String get customCategoryDefault;

  /// Location permission denied message
  ///
  /// In pt, this message translates to:
  /// **'PermissÃ£o de localizaÃ§Ã£o negada'**
  String get expenseLocationPermissionDenied;

  /// Attach photo label
  ///
  /// In pt, this message translates to:
  /// **'Anexar Foto'**
  String get expenseAttachPhoto;

  /// Camera option label
  ///
  /// In pt, this message translates to:
  /// **'CÃ¢mara'**
  String get expenseAttachCamera;

  /// Gallery option label
  ///
  /// In pt, this message translates to:
  /// **'Galeria'**
  String get expenseAttachGallery;

  /// Attachment upload failure message
  ///
  /// In pt, this message translates to:
  /// **'Falha ao carregar anexos. Verifique a sua ligaÃ§Ã£o.'**
  String get expenseAttachUploadFailed;

  /// Extras toggle label
  ///
  /// In pt, this message translates to:
  /// **'Extras'**
  String get expenseExtras;

  /// Detect location button label
  ///
  /// In pt, this message translates to:
  /// **'Detetar localizaÃ§Ã£o'**
  String get expenseLocationDetect;

  /// Biometric lock setting title
  ///
  /// In pt, this message translates to:
  /// **'Bloqueio da App'**
  String get biometricLockTitle;

  /// Biometric lock setting subtitle
  ///
  /// In pt, this message translates to:
  /// **'Exigir autenticaÃ§Ã£o ao abrir a aplicaÃ§Ã£o'**
  String get biometricLockSubtitle;

  /// Biometric lock screen prompt
  ///
  /// In pt, this message translates to:
  /// **'Autentique-se para continuar'**
  String get biometricPrompt;

  /// Biometric authentication reason
  ///
  /// In pt, this message translates to:
  /// **'Verifique a sua identidade para desbloquear a aplicaÃ§Ã£o'**
  String get biometricReason;

  /// Biometric retry button
  ///
  /// In pt, this message translates to:
  /// **'Tentar Novamente'**
  String get biometricRetry;

  /// Daily expense reminder toggle label
  ///
  /// In pt, this message translates to:
  /// **'Lembrete diÃ¡rio de despesas'**
  String get notifDailyExpenseReminder;

  /// Daily expense reminder description
  ///
  /// In pt, this message translates to:
  /// **'Lembra-o de registar as despesas do dia'**
  String get notifDailyExpenseReminderDesc;

  /// Daily expense notification title
  ///
  /// In pt, this message translates to:
  /// **'NÃ£o se esqueÃ§a das despesas!'**
  String get notifDailyExpenseTitle;

  /// Daily expense notification body
  ///
  /// In pt, this message translates to:
  /// **'Reserve um momento para registar as despesas de hoje'**
  String get notifDailyExpenseBody;

  /// Placeholder for salary label input
  ///
  /// In pt, this message translates to:
  /// **'ex: Emprego principal, Freelance'**
  String get settingsSalaryLabelHint;

  /// Label above expense name input
  ///
  /// In pt, this message translates to:
  /// **'NOME DA DESPESA'**
  String get settingsExpenseNameLabel;

  /// Label above category dropdown
  ///
  /// In pt, this message translates to:
  /// **'CATEGORIA'**
  String get settingsCategoryLabel;

  /// Label above monthly budget input
  ///
  /// In pt, this message translates to:
  /// **'ORÃ‡AMENTO MENSAL'**
  String get settingsMonthlyBudgetLabel;

  /// Search address button label
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar'**
  String get expenseLocationSearch;

  /// Address search field hint
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar endereÃ§o...'**
  String get expenseLocationSearchHint;

  /// Burn rate card title
  ///
  /// In pt, this message translates to:
  /// **'Velocidade de Gasto'**
  String get dashboardBurnRateTitle;

  /// Burn rate card subtitle for settings
  ///
  /// In pt, this message translates to:
  /// **'MÃ©dia diÃ¡ria vs orÃ§amento disponÃ­vel'**
  String get dashboardBurnRateSubtitle;

  /// On track pace label
  ///
  /// In pt, this message translates to:
  /// **'No caminho'**
  String get dashboardBurnRateOnTrack;

  /// Over pace label
  ///
  /// In pt, this message translates to:
  /// **'Acima do ritmo'**
  String get dashboardBurnRateOver;

  /// Daily average label
  ///
  /// In pt, this message translates to:
  /// **'MÃ‰DIA/DIA'**
  String get dashboardBurnRateDailyAvg;

  /// Daily allowance label
  ///
  /// In pt, this message translates to:
  /// **'DISP./DIA'**
  String get dashboardBurnRateAllowance;

  /// Days remaining label
  ///
  /// In pt, this message translates to:
  /// **'DIAS RESTANTES'**
  String get dashboardBurnRateDaysLeft;

  /// Top categories card title
  ///
  /// In pt, this message translates to:
  /// **'Top Categorias'**
  String get dashboardTopCategoriesTitle;

  /// Top categories subtitle for settings
  ///
  /// In pt, this message translates to:
  /// **'Categorias com mais despesas este mÃªs'**
  String get dashboardTopCategoriesSubtitle;

  /// Cash flow forecast card title
  ///
  /// In pt, this message translates to:
  /// **'PrevisÃ£o de Fluxo'**
  String get dashboardCashFlowTitle;

  /// Cash flow subtitle for settings
  ///
  /// In pt, this message translates to:
  /// **'ProjeÃ§Ã£o de saldo atÃ© ao fim do mÃªs'**
  String get dashboardCashFlowSubtitle;

  /// Projected spend label
  ///
  /// In pt, this message translates to:
  /// **'GASTO PROJETADO'**
  String get dashboardCashFlowProjectedSpend;

  /// End of month label
  ///
  /// In pt, this message translates to:
  /// **'FIM DO MÃŠS'**
  String get dashboardCashFlowEndOfMonth;

  /// Pending bills message
  ///
  /// In pt, this message translates to:
  /// **'Contas pendentes: {amount}'**
  String dashboardCashFlowPendingBills(String amount);

  /// Savings rate card title
  ///
  /// In pt, this message translates to:
  /// **'Taxa de PoupanÃ§a'**
  String get dashboardSavingsRateTitle;

  /// Savings rate subtitle for settings
  ///
  /// In pt, this message translates to:
  /// **'Percentagem do rendimento poupada'**
  String get dashboardSavingsRateSubtitle;

  /// Saved amount message
  ///
  /// In pt, this message translates to:
  /// **'Poupado este mÃªs: {amount}'**
  String dashboardSavingsRateSaved(String amount);

  /// Coach insight card title
  ///
  /// In pt, this message translates to:
  /// **'Dica Financeira'**
  String get dashboardCoachInsightTitle;

  /// Coach insight subtitle for settings
  ///
  /// In pt, this message translates to:
  /// **'SugestÃ£o personalizada do assistente financeiro'**
  String get dashboardCoachInsightSubtitle;

  /// Low savings coach tip
  ///
  /// In pt, this message translates to:
  /// **'A sua taxa de poupanÃ§a estÃ¡ abaixo de 10%. Identifique uma despesa que pode reduzir este mÃªs.'**
  String get dashboardCoachLowSavings;

  /// High spending coach tip
  ///
  /// In pt, this message translates to:
  /// **'Os gastos estÃ£o a aproximar-se do rendimento. Reveja as despesas nÃ£o essenciais.'**
  String get dashboardCoachHighSpending;

  /// Good savings coach tip
  ///
  /// In pt, this message translates to:
  /// **'Excelente! EstÃ¡ a poupar mais de 20%. Continue assim!'**
  String get dashboardCoachGoodSavings;

  /// General coach tip
  ///
  /// In pt, this message translates to:
  /// **'Toque para obter anÃ¡lises personalizadas do seu orÃ§amento.'**
  String get dashboardCoachGeneral;

  /// Insights group label in dashboard settings
  ///
  /// In pt, this message translates to:
  /// **'AnÃ¡lise'**
  String get dashGroupInsights;

  /// Hint text for drag-to-reorder in dashboard card settings
  ///
  /// In pt, this message translates to:
  /// **'Arraste para reordenar os cartÃµes'**
  String get dashReorderHint;

  /// Label for gross amount in salary summary row
  ///
  /// In pt, this message translates to:
  /// **'Bruto'**
  String get settingsSalarySummaryGross;

  /// Label for net amount in salary summary row
  ///
  /// In pt, this message translates to:
  /// **'LÃ­quido'**
  String get settingsSalarySummaryNet;

  /// IRS deduction label in salary breakdown
  ///
  /// In pt, this message translates to:
  /// **'IRS'**
  String get settingsDeductionIrs;

  /// Social security deduction label in salary breakdown
  ///
  /// In pt, this message translates to:
  /// **'SS'**
  String get settingsDeductionSs;

  /// Meal allowance label in salary breakdown
  ///
  /// In pt, this message translates to:
  /// **'Sub. Alim.'**
  String get settingsDeductionMeal;

  /// Monthly meal allowance total
  ///
  /// In pt, this message translates to:
  /// **'Total mensal: {amount}'**
  String settingsMealMonthlyTotal(String amount);

  /// No description provided for @mealSubstituteIngredient.
  ///
  /// In pt, this message translates to:
  /// **'Substituir ingrediente'**
  String get mealSubstituteIngredient;

  /// No description provided for @mealSubstituteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Substituir {name}'**
  String mealSubstituteTitle(String name);

  /// No description provided for @mealSubstitutionApplied.
  ///
  /// In pt, this message translates to:
  /// **'{oldName} substituÃ­do por {newName}'**
  String mealSubstitutionApplied(String oldName, String newName);

  /// No description provided for @mealSubstitutionAdapting.
  ///
  /// In pt, this message translates to:
  /// **'A adaptar receita...'**
  String get mealSubstitutionAdapting;

  /// No description provided for @mealPlanWithPantry.
  ///
  /// In pt, this message translates to:
  /// **'Planear com o que tenho'**
  String get mealPlanWithPantry;

  /// No description provided for @mealPantrySelectTitle.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar ingredientes da despensa'**
  String get mealPantrySelectTitle;

  /// No description provided for @mealPantrySelectHint.
  ///
  /// In pt, this message translates to:
  /// **'Escolha ingredientes que tem em casa'**
  String get mealPantrySelectHint;

  /// No description provided for @mealPantrySelected.
  ///
  /// In pt, this message translates to:
  /// **'{count} selecionados'**
  String mealPantrySelected(int count);

  /// No description provided for @mealPantryApply.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar e gerar'**
  String get mealPantryApply;

  /// No description provided for @mealTasteProfileBoost.
  ///
  /// In pt, this message translates to:
  /// **'Perfil de gosto aplicado'**
  String get mealTasteProfileBoost;

  /// Message shown after plan regeneration
  ///
  /// In pt, this message translates to:
  /// **'Plano regenerado com sucesso'**
  String get mealPlanUndoMessage;

  /// Undo button label on regeneration snackbar
  ///
  /// In pt, this message translates to:
  /// **'Desfazer'**
  String get mealPlanUndoAction;

  /// Label for active/hands-on prep time
  ///
  /// In pt, this message translates to:
  /// **'ativo'**
  String get mealActiveTime;

  /// Label for passive prep time (oven, marinating, etc.)
  ///
  /// In pt, this message translates to:
  /// **'forno/espera'**
  String get mealPassiveTime;

  /// Button label to trigger AI macro optimization
  ///
  /// In pt, this message translates to:
  /// **'Otimizar macros'**
  String get mealOptimizeMacros;

  /// No description provided for @mealSwapSuggestion.
  ///
  /// In pt, this message translates to:
  /// **'Trocar {current} por {suggested}'**
  String mealSwapSuggestion(String current, String suggested);

  /// No description provided for @mealSwapReason.
  ///
  /// In pt, this message translates to:
  /// **'Motivo: {reason}'**
  String mealSwapReason(String reason);

  /// Button label to apply a macro swap suggestion
  ///
  /// In pt, this message translates to:
  /// **'Aplicar'**
  String get mealApplySwap;

  /// Filter chip label for same meal type
  ///
  /// In pt, this message translates to:
  /// **'Mesmo tipo'**
  String get mealSwapSameType;

  /// Filter chip label for all meal types
  ///
  /// In pt, this message translates to:
  /// **'Todos os tipos'**
  String get mealSwapAllTypes;

  /// No description provided for @pantryManagerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Despensa'**
  String get pantryManagerTitle;

  /// No description provided for @pantryManagerSave.
  ///
  /// In pt, this message translates to:
  /// **'Guardar'**
  String get pantryManagerSave;

  /// No description provided for @pantryLowStock.
  ///
  /// In pt, this message translates to:
  /// **'Stock baixo'**
  String get pantryLowStock;

  /// No description provided for @pantryDepleted.
  ///
  /// In pt, this message translates to:
  /// **'Esgotado'**
  String get pantryDepleted;

  /// No description provided for @pantryRestock.
  ///
  /// In pt, this message translates to:
  /// **'Repor'**
  String get pantryRestock;

  /// No description provided for @pantryQuantity.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade'**
  String get pantryQuantity;

  /// Title for the weekly nutrition dashboard card
  ///
  /// In pt, this message translates to:
  /// **'NutriÃ§Ã£o Semanal'**
  String get nutritionDashboardTitle;

  /// Calories label
  ///
  /// In pt, this message translates to:
  /// **'Calorias'**
  String get nutritionCalories;

  /// Protein label
  ///
  /// In pt, this message translates to:
  /// **'ProteÃ­na'**
  String get nutritionProtein;

  /// Carbs label
  ///
  /// In pt, this message translates to:
  /// **'Hidratos'**
  String get nutritionCarbs;

  /// Fat label
  ///
  /// In pt, this message translates to:
  /// **'Gordura'**
  String get nutritionFat;

  /// Fiber label
  ///
  /// In pt, this message translates to:
  /// **'Fibra'**
  String get nutritionFiber;

  /// Top protein sources label
  ///
  /// In pt, this message translates to:
  /// **'Top proteÃ­nas'**
  String get nutritionTopProteins;

  /// Daily average label
  ///
  /// In pt, this message translates to:
  /// **'MÃ©dia diÃ¡ria'**
  String get nutritionDailyAvg;

  /// Waste forecast section title
  ///
  /// In pt, this message translates to:
  /// **'DesperdÃ­cio estimado'**
  String get mealWasteEstimate;

  /// Excess quantity for an ingredient
  ///
  /// In pt, this message translates to:
  /// **'{qty} {unit} em excesso'**
  String mealWasteExcess(String qty, String unit);

  /// Suggestion to reuse excess ingredient
  ///
  /// In pt, this message translates to:
  /// **'Considere duplicar esta receita para usar {ingredient}'**
  String mealWasteSuggestion(String ingredient);

  /// Estimated waste cost chip label
  ///
  /// In pt, this message translates to:
  /// **'~{cost} em desperdÃ­cio'**
  String mealWasteCost(String cost);
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'es':
      return SEs();
    case 'fr':
      return SFr();
    case 'pt':
      return SPt();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
