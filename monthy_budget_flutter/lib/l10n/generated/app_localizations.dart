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
  /// **'Orçamento'**
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
  /// **'Refeições'**
  String get navMeals;

  /// Tooltip for budget nav item
  ///
  /// In pt, this message translates to:
  /// **'Resumo do orçamento mensal'**
  String get navBudgetTooltip;

  /// Tooltip for grocery nav item
  ///
  /// In pt, this message translates to:
  /// **'Catálogo de produtos'**
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
  /// **'Planeador de refeições'**
  String get navMealsTooltip;

  /// App title shown in app bar
  ///
  /// In pt, this message translates to:
  /// **'Orçamento Mensal'**
  String get appTitle;

  /// Generic loading text
  ///
  /// In pt, this message translates to:
  /// **'A carregar...'**
  String get loading;

  /// Loading text shown on app startup
  ///
  /// In pt, this message translates to:
  /// **'A carregar a aplicação'**
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
  /// **'Adicionar {name} à lista'**
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
  /// **'Sem duodécimos'**
  String get enumSubsidyNone;

  /// Subsidy mode: full twelfths
  ///
  /// In pt, this message translates to:
  /// **'Com duodécimos'**
  String get enumSubsidyFull;

  /// Subsidy mode: half twelfths
  ///
  /// In pt, this message translates to:
  /// **'50% duodécimos'**
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
  /// **'Telecomunicações'**
  String get enumCatTelecomunicacoes;

  /// Expense category: energy
  ///
  /// In pt, this message translates to:
  /// **'Energia'**
  String get enumCatEnergia;

  /// Expense category: water
  ///
  /// In pt, this message translates to:
  /// **'Água'**
  String get enumCatAgua;

  /// Expense category: food
  ///
  /// In pt, this message translates to:
  /// **'Alimentação'**
  String get enumCatAlimentacao;

  /// Expense category: education
  ///
  /// In pt, this message translates to:
  /// **'Educação'**
  String get enumCatEducacao;

  /// Expense category: housing
  ///
  /// In pt, this message translates to:
  /// **'Habitação'**
  String get enumCatHabitacao;

  /// Expense category: transport
  ///
  /// In pt, this message translates to:
  /// **'Transportes'**
  String get enumCatTransportes;

  /// Expense category: health
  ///
  /// In pt, this message translates to:
  /// **'Saúde'**
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
  /// **'Rendimento Líquido'**
  String get enumChartNetIncome;

  /// Chart type: deductions
  ///
  /// In pt, this message translates to:
  /// **'Descontos (IRS + SS)'**
  String get enumChartDeductions;

  /// Chart type: savings rate
  ///
  /// In pt, this message translates to:
  /// **'Taxa de Poupança'**
  String get enumChartSavingsRate;

  /// Meal type: breakfast
  ///
  /// In pt, this message translates to:
  /// **'Pequeno-almoço'**
  String get enumMealBreakfast;

  /// Meal type: lunch
  ///
  /// In pt, this message translates to:
  /// **'Almoço'**
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
  /// **'Equilíbrio custo/saúde'**
  String get enumObjBalancedHealth;

  /// Meal objective: high protein
  ///
  /// In pt, this message translates to:
  /// **'Alta proteína'**
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
  /// **'Panela de pressão'**
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
  /// **'Sem restrição'**
  String get enumSodiumNoRestriction;

  /// Sodium preference: reduced
  ///
  /// In pt, this message translates to:
  /// **'Sódio reduzido'**
  String get enumSodiumReduced;

  /// Sodium preference: low
  ///
  /// In pt, this message translates to:
  /// **'Baixo sódio'**
  String get enumSodiumLow;

  /// Age group: 0 to 3 years
  ///
  /// In pt, this message translates to:
  /// **'0–3 anos'**
  String get enumAge0to3;

  /// Age group: 4 to 10 years
  ///
  /// In pt, this message translates to:
  /// **'4–10 anos'**
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
  /// **'Sénior (65+)'**
  String get enumAgeSenior;

  /// Activity level: sedentary
  ///
  /// In pt, this message translates to:
  /// **'Sedentário'**
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
  /// **'Hipertensão'**
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
  /// **'Síndrome do intestino irritável'**
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
  /// **'Atenção'**
  String get stressWarning;

  /// Stress index level: critical
  ///
  /// In pt, this message translates to:
  /// **'Crítico'**
  String get stressCritical;

  /// Stress factor: savings rate
  ///
  /// In pt, this message translates to:
  /// **'Taxa de poupança'**
  String get stressFactorSavings;

  /// Stress factor: safety margin
  ///
  /// In pt, this message translates to:
  /// **'Margem de segurança'**
  String get stressFactorSafety;

  /// Stress factor: food budget
  ///
  /// In pt, this message translates to:
  /// **'Orçamento alimentação'**
  String get stressFactorFood;

  /// Stress factor: expense stability
  ///
  /// In pt, this message translates to:
  /// **'Estabilidade despesas'**
  String get stressFactorStability;

  /// Stability label: stable
  ///
  /// In pt, this message translates to:
  /// **'Estável'**
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
  /// **'Alimentação excedeu o orçamento em {percent}% — considere rever porções ou frequência de compras.'**
  String monthReviewFoodExceeded(String percent);

  /// Month review insight: expenses exceeded plan
  ///
  /// In pt, this message translates to:
  /// **'Despesas reais superaram o planeado em {amount}€ — ajustar valores nas definições?'**
  String monthReviewExpensesExceeded(String amount);

  /// Month review insight: saved more than expected
  ///
  /// In pt, this message translates to:
  /// **'Poupou {amount}€ mais do que previsto — pode reforçar fundo de emergência.'**
  String monthReviewSavedMore(String amount);

  /// Month review insight: on track
  ///
  /// In pt, this message translates to:
  /// **'Despesas dentro do previsto. Bom controlo orçamental.'**
  String get monthReviewOnTrack;

  /// Dashboard screen title
  ///
  /// In pt, this message translates to:
  /// **'Orçamento Mensal'**
  String get dashboardTitle;

  /// Stress index card title
  ///
  /// In pt, this message translates to:
  /// **'Índice de Tranquilidade'**
  String get dashboardStressIndex;

  /// Dashboard tension label
  ///
  /// In pt, this message translates to:
  /// **'Tensão'**
  String get dashboardTension;

  /// Dashboard liquidity label
  ///
  /// In pt, this message translates to:
  /// **'Liquidez'**
  String get dashboardLiquidity;

  /// Dashboard final position label
  ///
  /// In pt, this message translates to:
  /// **'Posição Final'**
  String get dashboardFinalPosition;

  /// Dashboard month label
  ///
  /// In pt, this message translates to:
  /// **'Mês'**
  String get dashboardMonth;

  /// Dashboard gross income label
  ///
  /// In pt, this message translates to:
  /// **'Bruto'**
  String get dashboardGross;

  /// Dashboard net income label
  ///
  /// In pt, this message translates to:
  /// **'Líquido'**
  String get dashboardNet;

  /// Dashboard expenses label
  ///
  /// In pt, this message translates to:
  /// **'Despesas'**
  String get dashboardExpenses;

  /// Dashboard savings rate label
  ///
  /// In pt, this message translates to:
  /// **'Taxa Poupança'**
  String get dashboardSavingsRate;

  /// Dashboard view trends button
  ///
  /// In pt, this message translates to:
  /// **'Ver evolução'**
  String get dashboardViewTrends;

  /// Dashboard view projection button
  ///
  /// In pt, this message translates to:
  /// **'Ver projeção'**
  String get dashboardViewProjection;

  /// Dashboard subtitle label
  ///
  /// In pt, this message translates to:
  /// **'RESUMO FINANCEIRO'**
  String get dashboardFinancialSummary;

  /// Accessibility label for settings button
  ///
  /// In pt, this message translates to:
  /// **'Abrir definições'**
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
  /// **'Abrir Definições'**
  String get dashboardOpenSettingsButton;

  /// Summary card gross income label
  ///
  /// In pt, this message translates to:
  /// **'Rendimento Bruto'**
  String get dashboardGrossIncome;

  /// Summary card net income label
  ///
  /// In pt, this message translates to:
  /// **'Rendimento Líquido'**
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
  /// **'ALIMENTAÇÃO'**
  String get dashboardFood;

  /// Simulate button label
  ///
  /// In pt, this message translates to:
  /// **'Simular'**
  String get dashboardSimulate;

  /// Food card budgeted label
  ///
  /// In pt, this message translates to:
  /// **'Orçado'**
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
  /// **'HISTÓRICO DE COMPRAS'**
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
  /// **'Bruto c/ duodéc.'**
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
  /// **'Sub. Alimentação'**
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
  /// **'{delta} vs mês passado'**
  String dashboardVsLastMonth(String delta);

  /// Budget pace warning title
  ///
  /// In pt, this message translates to:
  /// **'A gastar mais rápido que o previsto'**
  String get dashboardPaceWarning;

  /// Budget pace critical title
  ///
  /// In pt, this message translates to:
  /// **'Risco de ultrapassar orçamento alimentar'**
  String get dashboardPaceCritical;

  /// Pace label in budget pace alert
  ///
  /// In pt, this message translates to:
  /// **'Ritmo'**
  String get dashboardPace;

  /// Projection label in budget pace alert
  ///
  /// In pt, this message translates to:
  /// **'Projeção'**
  String get dashboardProjection;

  /// Budget pace comparison value
  ///
  /// In pt, this message translates to:
  /// **'{actual}€/dia vs {expected}€/dia'**
  String dashboardPaceValue(String actual, String expected);

  /// Month review card summary suffix
  ///
  /// In pt, this message translates to:
  /// **'— RESUMO'**
  String get dashboardSummaryLabel;

  /// Accessibility label for month review card
  ///
  /// In pt, this message translates to:
  /// **'Ver resumo do mês'**
  String get dashboardViewMonthSummary;

  /// Coach screen title
  ///
  /// In pt, this message translates to:
  /// **'Coach Financeiro'**
  String get coachTitle;

  /// Coach screen subtitle
  ///
  /// In pt, this message translates to:
  /// **'IA · GPT-4o mini'**
  String get coachSubtitle;

  /// Coach API key required message
  ///
  /// In pt, this message translates to:
  /// **'Adiciona a tua OpenAI API key nas Definições para usar esta funcionalidade.'**
  String get coachApiKeyRequired;

  /// Coach analysis card title
  ///
  /// In pt, this message translates to:
  /// **'Análise financeira em 3 partes'**
  String get coachAnalysisTitle;

  /// Coach analysis card description
  ///
  /// In pt, this message translates to:
  /// **'Posicionamento geral · Factores críticos do Índice de Tranquilidade · Oportunidade imediata. Baseado nos teus dados reais de orçamento, despesas e histórico de compras.'**
  String get coachAnalysisDescription;

  /// Coach configure API key button
  ///
  /// In pt, this message translates to:
  /// **'Configurar API key nas Definições'**
  String get coachConfigureApiKey;

  /// Coach API key configured label
  ///
  /// In pt, this message translates to:
  /// **'API key configurada'**
  String get coachApiKeyConfigured;

  /// Coach analyze button label
  ///
  /// In pt, this message translates to:
  /// **'Analisar o meu orçamento'**
  String get coachAnalyzeButton;

  /// Coach analyzing state text
  ///
  /// In pt, this message translates to:
  /// **'A analisar...'**
  String get coachAnalyzing;

  /// Coach custom analysis label
  ///
  /// In pt, this message translates to:
  /// **'Análise personalizada'**
  String get coachCustomAnalysis;

  /// Coach new analysis button
  ///
  /// In pt, this message translates to:
  /// **'Gerar nova análise'**
  String get coachNewAnalysis;

  /// Coach history section header
  ///
  /// In pt, this message translates to:
  /// **'HISTÓRICO'**
  String get coachHistory;

  /// Coach clear all button
  ///
  /// In pt, this message translates to:
  /// **'Limpar tudo'**
  String get coachClearAll;

  /// Coach clear history dialog title
  ///
  /// In pt, this message translates to:
  /// **'Limpar histórico'**
  String get coachClearTitle;

  /// Coach clear history dialog content
  ///
  /// In pt, this message translates to:
  /// **'Tens a certeza que queres apagar todas as análises guardadas?'**
  String get coachClearContent;

  /// Coach delete analysis label
  ///
  /// In pt, this message translates to:
  /// **'Eliminar análise'**
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
  /// **'Modo Eco — sem custos de creditos.'**
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
  /// **'{name} adicionado à lista'**
  String groceryAddedToList(String name);

  /// Product card average price label
  ///
  /// In pt, this message translates to:
  /// **'{unit} · preço médio'**
  String groceryAvgPrice(String unit);

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
  /// **'Adiciona produtos a partir do\necrã Supermercado.'**
  String get shoppingEmptyMessage;

  /// Shopping list items remaining summary
  ///
  /// In pt, this message translates to:
  /// **'{count} por comprar · {total}'**
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
  /// **'Histórico de compras'**
  String get shoppingHistoryTooltip;

  /// Shopping history screen title
  ///
  /// In pt, this message translates to:
  /// **'Histórico de Compras'**
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
  /// **'Já tenho conta'**
  String get authSwitchToLogin;

  /// Registration success message
  ///
  /// In pt, this message translates to:
  /// **'Conta criada! Verifique o seu email para confirmar a conta antes de iniciar sessão.'**
  String get authRegistrationSuccess;

  /// No description provided for @authErrorNetwork.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível ligar ao servidor. Verifique a sua ligação à internet e tente novamente.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In pt, this message translates to:
  /// **'Email ou palavra-passe inválidos. Tente novamente.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorEmailNotConfirmed.
  ///
  /// In pt, this message translates to:
  /// **'Verifique o seu email antes de iniciar sessão.'**
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
  /// **'Entrar com código'**
  String get householdJoinWithCode;

  /// Household name field label
  ///
  /// In pt, this message translates to:
  /// **'Nome do agregado'**
  String get householdNameLabel;

  /// Household name field hint
  ///
  /// In pt, this message translates to:
  /// **'ex: Família Silva'**
  String get householdNameHint;

  /// Household invite code field label
  ///
  /// In pt, this message translates to:
  /// **'Código de convite'**
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
  /// **'Descontos (IRS + Segurança Social)'**
  String get chartDeductions;

  /// Chart title: gross vs net
  ///
  /// In pt, this message translates to:
  /// **'Rendimento Bruto vs Líquido'**
  String get chartGrossVsNet;

  /// Chart title: savings rate
  ///
  /// In pt, this message translates to:
  /// **'Taxa de Poupança'**
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
  /// **'Líquido'**
  String get chartNet;

  /// Chart label: net salary
  ///
  /// In pt, this message translates to:
  /// **'Sal. Líquido'**
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
  /// **'poupança'**
  String get chartSavings;

  /// Projection sheet title
  ///
  /// In pt, this message translates to:
  /// **'Projeção — {month} {year}'**
  String projectionTitle(String month, String year);

  /// Projection sheet subtitle
  ///
  /// In pt, this message translates to:
  /// **'Gastou {spent} de {budget} em {days} dias'**
  String projectionSubtitle(String spent, String budget, String days);

  /// Projection section: food
  ///
  /// In pt, this message translates to:
  /// **'ALIMENTAÇÃO'**
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
  /// **'Gasto diário estimado: {amount}/dia'**
  String projectionDailySpend(String amount);

  /// Projection end of month label
  ///
  /// In pt, this message translates to:
  /// **'Projeção fim de mês'**
  String get projectionEndOfMonth;

  /// Projection remaining label
  ///
  /// In pt, this message translates to:
  /// **'Restante projetado'**
  String get projectionRemaining;

  /// Projection stress impact label
  ///
  /// In pt, this message translates to:
  /// **'Impacto no Índice'**
  String get projectionStressImpact;

  /// Projection section: expenses
  ///
  /// In pt, this message translates to:
  /// **'DESPESAS'**
  String get projectionExpenses;

  /// Projection simulation disclaimer
  ///
  /// In pt, this message translates to:
  /// **'Simulação — não guardado'**
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
  /// **'Taxa poupança simulada'**
  String get projectionSimSavingsRate;

  /// Projection simulated stress index label
  ///
  /// In pt, this message translates to:
  /// **'Índice simulado'**
  String get projectionSimIndex;

  /// Trend sheet title
  ///
  /// In pt, this message translates to:
  /// **'Evolução'**
  String get trendTitle;

  /// Trend section: stress index
  ///
  /// In pt, this message translates to:
  /// **'ÍNDICE DE TRANQUILIDADE'**
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
  /// **'Água'**
  String get trendCatWater;

  /// Trend category: food
  ///
  /// In pt, this message translates to:
  /// **'Alimentação'**
  String get trendCatFood;

  /// Trend category: education
  ///
  /// In pt, this message translates to:
  /// **'Educação'**
  String get trendCatEducation;

  /// Trend category: housing
  ///
  /// In pt, this message translates to:
  /// **'Habitação'**
  String get trendCatHousing;

  /// Trend category: transport
  ///
  /// In pt, this message translates to:
  /// **'Transportes'**
  String get trendCatTransport;

  /// Trend category: health
  ///
  /// In pt, this message translates to:
  /// **'Saúde'**
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
  /// **'Resumo — {month}'**
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
  /// **'Diferença'**
  String get monthReviewDifference;

  /// Month review row: food
  ///
  /// In pt, this message translates to:
  /// **'Alimentação'**
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
  /// **'SUGESTÕES'**
  String get monthReviewSuggestions;

  /// Month review AI analysis button
  ///
  /// In pt, this message translates to:
  /// **'Análise AI detalhada'**
  String get monthReviewAiAnalysis;

  /// Meal planner screen title
  ///
  /// In pt, this message translates to:
  /// **'Planeador de Refeições'**
  String get mealPlannerTitle;

  /// Meal planner budget label
  ///
  /// In pt, this message translates to:
  /// **'Orçamento alimentação'**
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
  /// **'O plano atual será substituído.'**
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
  /// **'Adicionar semana à lista'**
  String get mealAddWeekToList;

  /// Meal planner ingredients added snackbar
  ///
  /// In pt, this message translates to:
  /// **'{count} ingredientes adicionados à lista'**
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
  /// **'Preparação'**
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
  /// **'{cost}€ total'**
  String mealTotalCost(String cost);

  /// Meal ingredient category: proteins
  ///
  /// In pt, this message translates to:
  /// **'Proteínas'**
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
  /// **'{cost}€/pess'**
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
  /// **'Refeições'**
  String get wizardStepMeals;

  /// Wizard step label: objective
  ///
  /// In pt, this message translates to:
  /// **'Objetivo'**
  String get wizardStepObjective;

  /// Wizard step label: restrictions
  ///
  /// In pt, this message translates to:
  /// **'Restrições'**
  String get wizardStepRestrictions;

  /// Wizard step label: kitchen
  ///
  /// In pt, this message translates to:
  /// **'Cozinha'**
  String get wizardStepKitchen;

  /// Wizard step label: strategy
  ///
  /// In pt, this message translates to:
  /// **'Estratégia'**
  String get wizardStepStrategy;

  /// Wizard meals step question
  ///
  /// In pt, this message translates to:
  /// **'Quais refeições queres incluir no plano diário?'**
  String get wizardMealsQuestion;

  /// Wizard budget weight display
  ///
  /// In pt, this message translates to:
  /// **'{weight} do orçamento'**
  String wizardBudgetWeight(String weight);

  /// Wizard objective step question
  ///
  /// In pt, this message translates to:
  /// **'Qual é o objetivo principal do teu plano alimentar?'**
  String get wizardObjectiveQuestion;

  /// Wizard accessibility label for selected item
  ///
  /// In pt, this message translates to:
  /// **'{label}, selecionado'**
  String wizardSelected(String label);

  /// Wizard restrictions section header
  ///
  /// In pt, this message translates to:
  /// **'RESTRIÇÕES DIETÉTICAS'**
  String get wizardDietaryRestrictions;

  /// Wizard dietary restriction: gluten free
  ///
  /// In pt, this message translates to:
  /// **'Sem glúten'**
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
  /// **'INGREDIENTES QUE NÃO GOSTAS'**
  String get wizardDislikedIngredients;

  /// Wizard disliked ingredients hint
  ///
  /// In pt, this message translates to:
  /// **'ex: atum, brócolos'**
  String get wizardDislikedHint;

  /// Wizard max prep time section header
  ///
  /// In pt, this message translates to:
  /// **'TEMPO MÁXIMO POR REFEIÇÃO'**
  String get wizardMaxPrepTime;

  /// Wizard max complexity section header
  ///
  /// In pt, this message translates to:
  /// **'COMPLEXIDADE MÁXIMA'**
  String get wizardMaxComplexity;

  /// Wizard complexity level: easy
  ///
  /// In pt, this message translates to:
  /// **'Fácil'**
  String get wizardComplexityEasy;

  /// Wizard complexity level: medium
  ///
  /// In pt, this message translates to:
  /// **'Médio'**
  String get wizardComplexityMedium;

  /// Wizard complexity level: advanced
  ///
  /// In pt, this message translates to:
  /// **'Avançado'**
  String get wizardComplexityAdvanced;

  /// Wizard equipment section header
  ///
  /// In pt, this message translates to:
  /// **'EQUIPAMENTO DISPONÍVEL'**
  String get wizardEquipment;

  /// Wizard strategy: batch cooking toggle
  ///
  /// In pt, this message translates to:
  /// **'Batch cooking'**
  String get wizardBatchCooking;

  /// Wizard strategy: batch cooking description
  ///
  /// In pt, this message translates to:
  /// **'Cozinhar para vários dias de uma vez'**
  String get wizardBatchCookingDesc;

  /// Wizard max batch days section header
  ///
  /// In pt, this message translates to:
  /// **'MÁXIMO DE DIAS POR RECEITA'**
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
  /// **'Jantar de ontem = almoço de hoje (custo 0)'**
  String get wizardReuseLeftoversDesc;

  /// Wizard max new ingredients section header
  ///
  /// In pt, this message translates to:
  /// **'MÁXIMO DE INGREDIENTES NOVOS POR SEMANA'**
  String get wizardMaxNewIngredients;

  /// Wizard no limit label
  ///
  /// In pt, this message translates to:
  /// **'Sem limite'**
  String get wizardNoLimit;

  /// Wizard strategy: minimize waste toggle
  ///
  /// In pt, this message translates to:
  /// **'Minimizar desperdício'**
  String get wizardMinimizeWaste;

  /// Wizard strategy: minimize waste description
  ///
  /// In pt, this message translates to:
  /// **'Prefere receitas que reutilizam ingredientes já usados'**
  String get wizardMinimizeWasteDesc;

  /// Wizard settings info text
  ///
  /// In pt, this message translates to:
  /// **'Podes alterar as definições do planeador em qualquer altura em Definições → Refeições.'**
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
  /// **'Sáb'**
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
  /// **'Definições'**
  String get settingsTitle;

  /// Settings section: personal data
  ///
  /// In pt, this message translates to:
  /// **'Dados Pessoais'**
  String get settingsPersonal;

  /// Settings section: salaries
  ///
  /// In pt, this message translates to:
  /// **'Salários'**
  String get settingsSalaries;

  /// Settings section: expenses
  ///
  /// In pt, this message translates to:
  /// **'Orçamento e Contas'**
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
  /// **'Refeições'**
  String get settingsMeals;

  /// Settings section: region and language
  ///
  /// In pt, this message translates to:
  /// **'Região e Idioma'**
  String get settingsRegion;

  /// Settings field: country
  ///
  /// In pt, this message translates to:
  /// **'País'**
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
  /// **'Salário bruto'**
  String get settingsGrossSalary;

  /// Settings field: titulares (tax holders)
  ///
  /// In pt, this message translates to:
  /// **'Titulares'**
  String get settingsTitulares;

  /// Settings field: subsidy mode
  ///
  /// In pt, this message translates to:
  /// **'Duodécimos'**
  String get settingsSubsidyMode;

  /// Settings field: meal allowance
  ///
  /// In pt, this message translates to:
  /// **'Subsídio de alimentação'**
  String get settingsMealAllowance;

  /// Settings field: meal allowance per day
  ///
  /// In pt, this message translates to:
  /// **'Valor/dia'**
  String get settingsMealAllowancePerDay;

  /// Settings field: working days per month
  ///
  /// In pt, this message translates to:
  /// **'Dias úteis/mês'**
  String get settingsWorkingDays;

  /// Settings field: other exempt income
  ///
  /// In pt, this message translates to:
  /// **'Outros rendimentos isentos'**
  String get settingsOtherExemptIncome;

  /// Settings add salary button
  ///
  /// In pt, this message translates to:
  /// **'Adicionar salário'**
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
  /// **'Código de convite'**
  String get settingsInviteCode;

  /// Settings copy code button
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get settingsCopyCode;

  /// Settings code copied snackbar
  ///
  /// In pt, this message translates to:
  /// **'Código copiado!'**
  String get settingsCodeCopied;

  /// Settings admin only warning
  ///
  /// In pt, this message translates to:
  /// **'Apenas o administrador pode editar as definições.'**
  String get settingsAdminOnly;

  /// Settings toggle: show summary cards
  ///
  /// In pt, this message translates to:
  /// **'Mostrar cartões resumo'**
  String get settingsShowSummaryCards;

  /// Settings section: enabled charts
  ///
  /// In pt, this message translates to:
  /// **'Gráficos ativos'**
  String get settingsEnabledCharts;

  /// Settings logout button
  ///
  /// In pt, this message translates to:
  /// **'Terminar sessão'**
  String get settingsLogout;

  /// Settings logout dialog title
  ///
  /// In pt, this message translates to:
  /// **'Terminar sessão'**
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
  /// **'Orçamento e Contas'**
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
  /// **'NÚMERO DE DEPENDENTES'**
  String get settingsDependentsLabel;

  /// Settings social security rate display
  ///
  /// In pt, this message translates to:
  /// **'Segurança Social: {rate}'**
  String settingsSocialSecurityRate(String rate);

  /// Settings salary active toggle label
  ///
  /// In pt, this message translates to:
  /// **'Ativo'**
  String get settingsSalaryActive;

  /// Settings label: gross monthly salary
  ///
  /// In pt, this message translates to:
  /// **'SALÁRIO BRUTO MENSAL'**
  String get settingsGrossMonthlySalary;

  /// Settings label: holiday subsidies
  ///
  /// In pt, this message translates to:
  /// **'SUBSÍDIOS DE FÉRIAS E NATAL (DUODÉCIMOS)'**
  String get settingsSubsidyHoliday;

  /// Settings label: other exempt income
  ///
  /// In pt, this message translates to:
  /// **'OUTROS RENDIMENTOS ISENTOS DE IRS'**
  String get settingsOtherExemptLabel;

  /// Settings label: meal allowance
  ///
  /// In pt, this message translates to:
  /// **'SUBSÍDIO DE ALIMENTAÇÃO'**
  String get settingsMealAllowanceLabel;

  /// Settings label: amount per day
  ///
  /// In pt, this message translates to:
  /// **'VALOR/DIA'**
  String get settingsAmountPerDay;

  /// Settings label: days per month
  ///
  /// In pt, this message translates to:
  /// **'DIAS/MÊS'**
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
  /// **'Estas definições são guardadas neste dispositivo.'**
  String get settingsDeviceLocal;

  /// Settings label: visible sections
  ///
  /// In pt, this message translates to:
  /// **'SECÇÕES VISÍVEIS'**
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
  /// **'Índice de Tranquilidade'**
  String get settingsDashStressIndex;

  /// Settings dashboard toggle: summary cards
  ///
  /// In pt, this message translates to:
  /// **'Cartões de resumo'**
  String get settingsDashSummaryCards;

  /// Settings dashboard toggle: salary breakdown
  ///
  /// In pt, this message translates to:
  /// **'Detalhe por vencimento'**
  String get settingsDashSalaryBreakdown;

  /// Settings dashboard toggle: food spending
  ///
  /// In pt, this message translates to:
  /// **'Alimentação'**
  String get settingsDashFood;

  /// Settings dashboard toggle: purchase history
  ///
  /// In pt, this message translates to:
  /// **'Histórico de compras'**
  String get settingsDashPurchaseHistory;

  /// Settings dashboard toggle: expenses breakdown
  ///
  /// In pt, this message translates to:
  /// **'Breakdown despesas'**
  String get settingsDashExpensesBreakdown;

  /// Settings dashboard toggle: month review
  ///
  /// In pt, this message translates to:
  /// **'Revisão do mês'**
  String get settingsDashMonthReview;

  /// Settings dashboard toggle: charts
  ///
  /// In pt, this message translates to:
  /// **'Gráficos'**
  String get settingsDashCharts;

  /// Dashboard settings group label: overview
  ///
  /// In pt, this message translates to:
  /// **'VISÃO GERAL'**
  String get dashGroupOverview;

  /// Dashboard settings group label: financial detail
  ///
  /// In pt, this message translates to:
  /// **'DETALHE FINANCEIRO'**
  String get dashGroupFinancialDetail;

  /// Dashboard settings group label: history
  ///
  /// In pt, this message translates to:
  /// **'HISTÓRICO'**
  String get dashGroupHistory;

  /// Dashboard settings group label: charts
  ///
  /// In pt, this message translates to:
  /// **'GRÁFICOS'**
  String get dashGroupCharts;

  /// Settings label: visible charts
  ///
  /// In pt, this message translates to:
  /// **'GRÁFICOS VISÍVEIS'**
  String get settingsVisibleCharts;

  /// Settings favorites tip text
  ///
  /// In pt, this message translates to:
  /// **'Os produtos favoritos influenciam o plano de refeições — receitas com esses ingredientes ficam em prioridade.'**
  String get settingsFavTip;

  /// Settings label: my favorites
  ///
  /// In pt, this message translates to:
  /// **'OS MEUS FAVORITOS'**
  String get settingsMyFavorites;

  /// Settings label: product catalog
  ///
  /// In pt, this message translates to:
  /// **'CATÁLOGO DE PRODUTOS'**
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
  /// **'Adicionar à despensa'**
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
  /// **'Usar valor automático'**
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
  /// **'porções'**
  String get settingsPortions;

  /// Settings total portion equivalent
  ///
  /// In pt, this message translates to:
  /// **'Equivalente total: {total} porções'**
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
  /// **'Prioriza receitas da época atual'**
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
  /// **'Proteína diária'**
  String get settingsDailyProtein;

  /// Settings field: daily fiber
  ///
  /// In pt, this message translates to:
  /// **'Fibra diária'**
  String get settingsDailyFiber;

  /// Settings label: medical conditions
  ///
  /// In pt, this message translates to:
  /// **'CONDIÇÕES MÉDICAS'**
  String get settingsMedicalConditions;

  /// Settings label: active meals
  ///
  /// In pt, this message translates to:
  /// **'REFEIÇÕES ATIVAS'**
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
  /// **'RESTRIÇÕES DIETÉTICAS'**
  String get settingsDietaryRestrictions;

  /// Settings dietary restriction: egg free
  ///
  /// In pt, this message translates to:
  /// **'Sem ovos'**
  String get settingsEggFree;

  /// Settings label: sodium preference
  ///
  /// In pt, this message translates to:
  /// **'PREFERÊNCIA DE SÓDIO'**
  String get settingsSodiumPref;

  /// Settings label: disliked ingredients
  ///
  /// In pt, this message translates to:
  /// **'INGREDIENTES INDESEJADOS'**
  String get settingsDislikedIngredients;

  /// Settings label: excluded proteins
  ///
  /// In pt, this message translates to:
  /// **'PROTEÍNAS EXCLUÍDAS'**
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
  /// **'TEMPO MÁXIMO (MINUTOS)'**
  String get settingsMaxPrepTime;

  /// Settings label: max complexity
  ///
  /// In pt, this message translates to:
  /// **'COMPLEXIDADE MÁXIMA ({value}/5)'**
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
  /// **'DISTRIBUIÇÃO SEMANAL'**
  String get settingsWeeklyDistribution;

  /// Settings fish days per week display
  ///
  /// In pt, this message translates to:
  /// **'Peixe por semana: {count}'**
  String settingsFishPerWeek(String count);

  /// Settings no minimum label
  ///
  /// In pt, this message translates to:
  /// **'sem mínimo'**
  String get settingsNoMinimum;

  /// Settings legume days per week display
  ///
  /// In pt, this message translates to:
  /// **'Leguminosas por semana: {count}'**
  String settingsLegumePerWeek(String count);

  /// Settings red meat max per week display
  ///
  /// In pt, this message translates to:
  /// **'Carne vermelha máx/semana: {count}'**
  String settingsRedMeatPerWeek(String count);

  /// Settings no limit label
  ///
  /// In pt, this message translates to:
  /// **'sem limite'**
  String get settingsNoLimit;

  /// Settings label: available equipment
  ///
  /// In pt, this message translates to:
  /// **'EQUIPAMENTO DISPONÍVEL'**
  String get settingsAvailableEquipment;

  /// Settings toggle: batch cooking
  ///
  /// In pt, this message translates to:
  /// **'Batch cooking'**
  String get settingsBatchCooking;

  /// Settings label: max batch days
  ///
  /// In pt, this message translates to:
  /// **'MÁXIMO DE DIAS POR RECEITA'**
  String get settingsMaxBatchDays;

  /// Settings toggle: reuse leftovers
  ///
  /// In pt, this message translates to:
  /// **'Reaproveitar sobras'**
  String get settingsReuseLeftovers;

  /// Settings toggle: minimize waste
  ///
  /// In pt, this message translates to:
  /// **'Minimizar desperdício'**
  String get settingsMinimizeWaste;

  /// Settings toggle: prioritize low cost
  ///
  /// In pt, this message translates to:
  /// **'Priorizar custo baixo'**
  String get settingsPrioritizeLowCost;

  /// Settings toggle desc: prioritize low cost
  ///
  /// In pt, this message translates to:
  /// **'Preferir receitas mais económicas'**
  String get settingsPrioritizeLowCostDesc;

  /// Settings label: new ingredients per week
  ///
  /// In pt, this message translates to:
  /// **'INGREDIENTES NOVOS POR SEMANA ({count})'**
  String settingsNewIngredientsPerWeek(int count);

  /// Settings toggle: lunchbox lunches
  ///
  /// In pt, this message translates to:
  /// **'Almoços de marmita'**
  String get settingsLunchboxLunches;

  /// Settings toggle desc: lunchbox lunches
  ///
  /// In pt, this message translates to:
  /// **'Apenas receitas transportáveis ao almoço'**
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
  /// **'A key é guardada localmente no dispositivo e nunca é partilhada. Usa o modelo GPT-4o mini (~€0,00008 por análise).'**
  String get settingsApiKeyInfo;

  /// Settings label: invite code
  ///
  /// In pt, this message translates to:
  /// **'CÓDIGO DE CONVITE'**
  String get settingsInviteCodeLabel;

  /// Settings generate invite code
  ///
  /// In pt, this message translates to:
  /// **'Gerar código de convite'**
  String get settingsGenerateInvite;

  /// Settings share invite code info
  ///
  /// In pt, this message translates to:
  /// **'Partilha com membros do agregado'**
  String get settingsShareWithMembers;

  /// Settings new code tooltip
  ///
  /// In pt, this message translates to:
  /// **'Novo código'**
  String get settingsNewCode;

  /// Settings invite code validity info
  ///
  /// In pt, this message translates to:
  /// **'O código é válido por 7 dias. Partilha-o com quem queres adicionar ao agregado.'**
  String get settingsCodeValidInfo;

  /// Settings field: name
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get settingsName;

  /// Settings field: age group
  ///
  /// In pt, this message translates to:
  /// **'Faixa etária'**
  String get settingsAgeGroup;

  /// Settings field: activity level
  ///
  /// In pt, this message translates to:
  /// **'Nível de atividade'**
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
  /// **'França'**
  String get countryFR;

  /// Country name: United Kingdom
  ///
  /// In pt, this message translates to:
  /// **'Reino Unido'**
  String get countryUK;

  /// Language name: Portuguese
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get langPT;

  /// Language name: English
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get langEN;

  /// Language name: French
  ///
  /// In pt, this message translates to:
  /// **'Français'**
  String get langFR;

  /// Language name: Spanish
  ///
  /// In pt, this message translates to:
  /// **'Español'**
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
  /// **'Contribuição social'**
  String get taxSocialContribution;

  /// Tax label: IRS (Portugal)
  ///
  /// In pt, this message translates to:
  /// **'IRS'**
  String get taxIRS;

  /// Tax label: Social Security (Portugal)
  ///
  /// In pt, this message translates to:
  /// **'Segurança Social'**
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
  /// **'Impôt sur le Revenu'**
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
  /// **'És um analista financeiro pessoal para utilizadores portugueses. Responde sempre em português europeu. Sê directo e analítico — usa sempre números concretos do contexto fornecido. Estrutura a resposta exactamente nas 3 partes pedidas. Não introduzas dados, benchmarks ou referências externas que não foram fornecidos.'**
  String get aiCoachSystemPrompt;

  /// AI coach invalid API key error
  ///
  /// In pt, this message translates to:
  /// **'API key inválida. Verifica nas Definições.'**
  String get aiCoachInvalidApiKey;

  /// AI coach mid-month system prompt
  ///
  /// In pt, this message translates to:
  /// **'És um consultor de orçamento doméstico português. Responde sempre em português europeu. Sê prático e directo.'**
  String get aiCoachMidMonthSystem;

  /// AI meal planner system prompt
  ///
  /// In pt, this message translates to:
  /// **'És um chef português. Responde sempre em português europeu. Responde APENAS com JSON válido, sem texto extra.'**
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
  /// **'Março'**
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
  /// **'Bem-vindo ao seu orçamento'**
  String get setupWizardWelcomeTitle;

  /// Setup wizard welcome screen subtitle
  ///
  /// In pt, this message translates to:
  /// **'Vamos configurar o essencial para que o seu painel fique pronto a usar.'**
  String get setupWizardWelcomeSubtitle;

  /// Setup wizard welcome bullet 1
  ///
  /// In pt, this message translates to:
  /// **'Calcular o seu salário líquido'**
  String get setupWizardBullet1;

  /// Setup wizard welcome bullet 2
  ///
  /// In pt, this message translates to:
  /// **'Organizar as suas despesas'**
  String get setupWizardBullet2;

  /// Setup wizard welcome bullet 3
  ///
  /// In pt, this message translates to:
  /// **'Ver quanto sobra cada mês'**
  String get setupWizardBullet3;

  /// Reassurance text shown on welcome screen
  ///
  /// In pt, this message translates to:
  /// **'Pode alterar tudo mais tarde nas definições.'**
  String get setupWizardReassurance;

  /// Start button on welcome screen
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get setupWizardStart;

  /// Skip all button on welcome screen
  ///
  /// In pt, this message translates to:
  /// **'Saltar configuração'**
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
  /// **'Predefinição do sistema'**
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
  /// **'França'**
  String get setupWizardCountryFR;

  /// UK country name
  ///
  /// In pt, this message translates to:
  /// **'Reino Unido'**
  String get setupWizardCountryUK;

  /// Personal info step title
  ///
  /// In pt, this message translates to:
  /// **'Informação pessoal'**
  String get setupWizardPersonalTitle;

  /// Personal info step subtitle
  ///
  /// In pt, this message translates to:
  /// **'Usamos isto para calcular os seus impostos com mais precisão.'**
  String get setupWizardPersonalSubtitle;

  /// Privacy note on personal info step
  ///
  /// In pt, this message translates to:
  /// **'Os seus dados ficam na sua conta e nunca são partilhados.'**
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
  /// **'Qual é o seu salário?'**
  String get setupWizardSalaryTitle;

  /// Salary step subtitle
  ///
  /// In pt, this message translates to:
  /// **'Introduza o valor bruto mensal. Calculamos o líquido automaticamente.'**
  String get setupWizardSalarySubtitle;

  /// Gross salary field label
  ///
  /// In pt, this message translates to:
  /// **'Salário bruto mensal'**
  String get setupWizardSalaryGross;

  /// Inline net salary estimate
  ///
  /// In pt, this message translates to:
  /// **'Líquido estimado: {amount}'**
  String setupWizardNetEstimate(String amount);

  /// Info text on salary step
  ///
  /// In pt, this message translates to:
  /// **'Pode adicionar mais fontes de rendimento mais tarde.'**
  String get setupWizardSalaryMoreLater;

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
  /// **'Valores sugeridos para o seu país. Ajuste conforme necessário.'**
  String get setupWizardExpensesSubtitle;

  /// Info text on expenses step
  ///
  /// In pt, this message translates to:
  /// **'Pode adicionar mais categorias mais tarde.'**
  String get setupWizardExpensesMoreLater;

  /// Net salary label on expenses step
  ///
  /// In pt, this message translates to:
  /// **'Líquido: {amount}'**
  String setupWizardNetLabel(String amount);

  /// Total expenses label
  ///
  /// In pt, this message translates to:
  /// **'Despesas: {amount}'**
  String setupWizardTotalExpenses(String amount);

  /// Available amount label on completion screen
  ///
  /// In pt, this message translates to:
  /// **'Disponível: {amount}'**
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
  /// **'O seu orçamento está configurado. Pode ajustar tudo nas definições a qualquer momento.'**
  String get setupWizardCompleteReassurance;

  /// Button to go to dashboard from completion screen
  ///
  /// In pt, this message translates to:
  /// **'Ver o meu orçamento'**
  String get setupWizardGoToDashboard;

  /// Hint when salary not configured
  ///
  /// In pt, this message translates to:
  /// **'Configure o seu salário nas definições para ver o cálculo completo.'**
  String get setupWizardConfigureSalaryHint;

  /// Rent expense category
  ///
  /// In pt, this message translates to:
  /// **'Renda / Prestação'**
  String get setupWizardExpRent;

  /// Groceries expense category
  ///
  /// In pt, this message translates to:
  /// **'Alimentação'**
  String get setupWizardExpGroceries;

  /// Transport expense category
  ///
  /// In pt, this message translates to:
  /// **'Transportes'**
  String get setupWizardExpTransport;

  /// Utilities expense category
  ///
  /// In pt, this message translates to:
  /// **'Utilidades (luz, água, gás)'**
  String get setupWizardExpUtilities;

  /// Telecom expense category
  ///
  /// In pt, this message translates to:
  /// **'Telecomunicações'**
  String get setupWizardExpTelecom;

  /// Health expense category
  ///
  /// In pt, this message translates to:
  /// **'Saúde'**
  String get setupWizardExpHealth;

  /// Leisure expense category
  ///
  /// In pt, this message translates to:
  /// **'Lazer'**
  String get setupWizardExpLeisure;

  /// Budget vs actual card title
  ///
  /// In pt, this message translates to:
  /// **'ORÇAMENTO VS REAL'**
  String get expenseTrackerTitle;

  /// Budgeted label
  ///
  /// In pt, this message translates to:
  /// **'Orçamentado'**
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
  /// **'Acima do orçamento'**
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
  /// **'Sem despesas este mês.\nToca + para adicionar a primeira.'**
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
  /// **'Descrição (opcional)'**
  String get addExpenseDescription;

  /// Custom category hint
  ///
  /// In pt, this message translates to:
  /// **'Categoria personalizada'**
  String get addExpenseCustomCategory;

  /// Invalid amount error
  ///
  /// In pt, this message translates to:
  /// **'Introduza um valor válido'**
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
  /// **'Orçamento vs Real'**
  String get settingsDashBudgetVsActual;

  /// Settings section: appearance
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
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
  /// **'Contas Mensais'**
  String get recurringExpenses;

  /// Add recurring expense
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Conta'**
  String get recurringExpenseAdd;

  /// Edit recurring expense
  ///
  /// In pt, this message translates to:
  /// **'Editar Conta'**
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
  /// **'Descrição (opcional)'**
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
  /// **'Sem contas mensais.\nAdicione para gerar automaticamente todos os meses.'**
  String get recurringExpenseEmpty;

  /// Delete confirmation
  ///
  /// In pt, this message translates to:
  /// **'Eliminar esta conta?'**
  String get recurringExpenseDeleteConfirm;

  /// Badge for auto-created expenses
  ///
  /// In pt, this message translates to:
  /// **'Criada automaticamente'**
  String get recurringExpenseAutoCreated;

  /// Manage recurring button
  ///
  /// In pt, this message translates to:
  /// **'Gerir contas'**
  String get recurringExpenseManage;

  /// Toggle to mark expense as recurring
  ///
  /// In pt, this message translates to:
  /// **'Marcar como conta mensal'**
  String get recurringExpenseMarkRecurring;

  /// Snackbar when recurring populated
  ///
  /// In pt, this message translates to:
  /// **'Contas mensais geradas para este mês'**
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
  /// **'Conta guardada'**
  String get recurringExpenseSaved;

  /// No description provided for @billsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} contas'**
  String billsCount(int count);

  /// No description provided for @billsNone.
  ///
  /// In pt, this message translates to:
  /// **'Sem contas'**
  String get billsNone;

  /// No description provided for @billsPerMonth.
  ///
  /// In pt, this message translates to:
  /// **'{count} contas · {amount}/mês'**
  String billsPerMonth(int count, String amount);

  /// No description provided for @billsExceedBudget.
  ///
  /// In pt, this message translates to:
  /// **'Contas ({amount}) excedem orçamento'**
  String billsExceedBudget(String amount);

  /// No description provided for @billsAddBill.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Conta'**
  String get billsAddBill;

  /// No description provided for @billsBudgetSettings.
  ///
  /// In pt, this message translates to:
  /// **'Configuração do Orçamento'**
  String get billsBudgetSettings;

  /// No description provided for @billsRecurringBills.
  ///
  /// In pt, this message translates to:
  /// **'Contas Recorrentes'**
  String get billsRecurringBills;

  /// No description provided for @billsDescription.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
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
  /// **'Tendências de Despesas'**
  String get expenseTrends;

  /// Button to open trends
  ///
  /// In pt, this message translates to:
  /// **'Ver Tendências'**
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
  /// **'Orçamentado'**
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
  /// **'Sem dados suficientes para mostrar tendências.'**
  String get expenseTrendsNoData;

  /// Total label
  ///
  /// In pt, this message translates to:
  /// **'Total'**
  String get expenseTrendsTotal;

  /// Average label
  ///
  /// In pt, this message translates to:
  /// **'Média'**
  String get expenseTrendsAverage;

  /// Overview tab label
  ///
  /// In pt, this message translates to:
  /// **'Visão Geral'**
  String get expenseTrendsOverview;

  /// Monthly label
  ///
  /// In pt, this message translates to:
  /// **'Mensal'**
  String get expenseTrendsMonthly;

  /// Savings goals title
  ///
  /// In pt, this message translates to:
  /// **'Objetivos de Poupança'**
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
  /// **'{percent}% alcançado'**
  String savingsGoalProgress(String percent);

  /// Remaining amount
  ///
  /// In pt, this message translates to:
  /// **'Faltam {amount}'**
  String savingsGoalRemaining(String amount);

  /// Goal completed message
  ///
  /// In pt, this message translates to:
  /// **'Objetivo alcançado!'**
  String get savingsGoalCompleted;

  /// Empty state
  ///
  /// In pt, this message translates to:
  /// **'Sem objetivos de poupança.\nCrie um para acompanhar o progresso.'**
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
  /// **'Valor da contribuição'**
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
  /// **'Histórico de Contribuições'**
  String get savingsGoalContributionHistory;

  /// See all goals button
  ///
  /// In pt, this message translates to:
  /// **'Ver todos'**
  String get savingsGoalSeeAll;

  /// Surplus suggestion card
  ///
  /// In pt, this message translates to:
  /// **'Tiveste {amount} de excedente no mês passado — queres alocar a um objetivo?'**
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
  /// **'Contribuição registada'**
  String get savingsGoalContributionSaved;

  /// Dashboard toggle for savings goals
  ///
  /// In pt, this message translates to:
  /// **'Objetivos de Poupança'**
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
  /// **'Custos de Refeições'**
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
  /// **'Total do Mês'**
  String get mealCostTotal;

  /// Savings indicator
  ///
  /// In pt, this message translates to:
  /// **'Poupança'**
  String get mealCostSavings;

  /// Overrun indicator
  ///
  /// In pt, this message translates to:
  /// **'Excesso'**
  String get mealCostOverrun;

  /// No meal purchase data
  ///
  /// In pt, this message translates to:
  /// **'Sem dados de compras para refeições.'**
  String get mealCostNoData;

  /// Button to open reconciliation
  ///
  /// In pt, this message translates to:
  /// **'Custos'**
  String get mealCostViewCosts;

  /// Checkbox label in finalize
  ///
  /// In pt, this message translates to:
  /// **'Compra para refeições'**
  String get mealCostIsMealPurchase;

  /// Vs budget label
  ///
  /// In pt, this message translates to:
  /// **'vs orçamento'**
  String get mealCostVsBudget;

  /// On track message
  ///
  /// In pt, this message translates to:
  /// **'Dentro do orçamento'**
  String get mealCostOnTrack;

  /// Over budget message
  ///
  /// In pt, this message translates to:
  /// **'Acima do orçamento'**
  String get mealCostOver;

  /// Under budget message
  ///
  /// In pt, this message translates to:
  /// **'Abaixo do orçamento'**
  String get mealCostUnder;

  /// Variation label for AI recipe content
  ///
  /// In pt, this message translates to:
  /// **'Variação'**
  String get mealVariation;

  /// Pairing suggestion label
  ///
  /// In pt, this message translates to:
  /// **'Acompanhamento'**
  String get mealPairing;

  /// Storage info label
  ///
  /// In pt, this message translates to:
  /// **'Conservação'**
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
  /// **'Nutrição Semanal'**
  String get mealWeeklySummary;

  /// Batch cooking prep guide button
  ///
  /// In pt, this message translates to:
  /// **'Guia de Preparação'**
  String get mealBatchPrepGuide;

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
  /// **'Não gostei'**
  String get mealFeedbackDislike;

  /// Label for skipped meal feedback button
  ///
  /// In pt, this message translates to:
  /// **'Saltar'**
  String get mealFeedbackSkip;

  /// Notifications title
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get notifications;

  /// Notification settings title
  ///
  /// In pt, this message translates to:
  /// **'Definições de Notificações'**
  String get notificationSettings;

  /// Bill reminders toggle
  ///
  /// In pt, this message translates to:
  /// **'Lembretes de contas'**
  String get notificationBillReminders;

  /// Days before bill due
  ///
  /// In pt, this message translates to:
  /// **'Dias antes do vencimento'**
  String get notificationBillReminderDays;

  /// Budget alerts toggle
  ///
  /// In pt, this message translates to:
  /// **'Alertas de orçamento'**
  String get notificationBudgetAlerts;

  /// Budget alert threshold
  ///
  /// In pt, this message translates to:
  /// **'Limite de alerta ({percent}%)'**
  String notificationBudgetThreshold(String percent);

  /// Meal plan reminder toggle
  ///
  /// In pt, this message translates to:
  /// **'Lembrete de plano de refeições'**
  String get notificationMealPlanReminder;

  /// Meal plan reminder description
  ///
  /// In pt, this message translates to:
  /// **'Notifica se não há plano para o mês atual'**
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
  /// **'Título'**
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
  /// **'Diário'**
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
  /// **'Não repetir'**
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
  /// **'Conta a vencer: {name}'**
  String notificationBillTitle(String name);

  /// Bill notification body
  ///
  /// In pt, this message translates to:
  /// **'{amount} vence em {days} dias'**
  String notificationBillBody(String amount, String days);

  /// Budget alert title
  ///
  /// In pt, this message translates to:
  /// **'Alerta de orçamento'**
  String get notificationBudgetTitle;

  /// Budget alert body
  ///
  /// In pt, this message translates to:
  /// **'Já gastaste {percent}% do orçamento mensal'**
  String notificationBudgetBody(String percent);

  /// Meal plan notification title
  ///
  /// In pt, this message translates to:
  /// **'Plano de refeições'**
  String get notificationMealPlanTitle;

  /// Meal plan notification body
  ///
  /// In pt, this message translates to:
  /// **'Ainda não geraste o plano de refeições deste mês'**
  String get notificationMealPlanBody;

  /// Permission required message
  ///
  /// In pt, this message translates to:
  /// **'Permissão de notificações necessária'**
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
  /// **'Azul-petróleo'**
  String get paletteTeal;

  /// Sunset palette name
  ///
  /// In pt, this message translates to:
  /// **'Pôr do sol'**
  String get paletteSunset;

  /// Export button tooltip
  ///
  /// In pt, this message translates to:
  /// **'Exportar'**
  String get exportTooltip;

  /// Export sheet title
  ///
  /// In pt, this message translates to:
  /// **'Exportar mês'**
  String get exportTitle;

  /// PDF export option
  ///
  /// In pt, this message translates to:
  /// **'Relatório PDF'**
  String get exportPdf;

  /// PDF export description
  ///
  /// In pt, this message translates to:
  /// **'Relatório formatado com orçamento vs real'**
  String get exportPdfDesc;

  /// CSV export option
  ///
  /// In pt, this message translates to:
  /// **'Dados CSV'**
  String get exportCsv;

  /// CSV export description
  ///
  /// In pt, this message translates to:
  /// **'Dados brutos para folha de cálculo'**
  String get exportCsvDesc;

  /// PDF report title
  ///
  /// In pt, this message translates to:
  /// **'Relatório Mensal de Despesas'**
  String get exportReportTitle;

  /// Budget vs actual section header
  ///
  /// In pt, this message translates to:
  /// **'Orçamento vs Real'**
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
  /// **'Pesquisar por descrição...'**
  String get searchExpensesHint;

  /// Date range label
  ///
  /// In pt, this message translates to:
  /// **'Período'**
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
  /// **'Variável'**
  String get expenseVariable;

  /// Monthly budget hint with month name
  ///
  /// In pt, this message translates to:
  /// **'Orçamento para {month}'**
  String monthlyBudgetHint(String month);

  /// Warning for unset variable budgets
  ///
  /// In pt, this message translates to:
  /// **'{count} orçamentos variáveis por definir'**
  String unsetBudgetsWarning(int count);

  /// CTA to set budgets in settings
  ///
  /// In pt, this message translates to:
  /// **'Definir nas definições'**
  String get unsetBudgetsCta;

  /// Projected spending amount
  ///
  /// In pt, this message translates to:
  /// **'Projeção: {amount}'**
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
  /// **'Começar'**
  String get onbGetStarted;

  /// No description provided for @onbSlide0Title.
  ///
  /// In pt, this message translates to:
  /// **'O seu orçamento, num relance'**
  String get onbSlide0Title;

  /// No description provided for @onbSlide0Body.
  ///
  /// In pt, this message translates to:
  /// **'O painel mostra a sua liquidez mensal, despesas e Índice de Serenidade.'**
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
  /// **'Obtenha uma análise em 3 partes baseada no seu orçamento real — não conselhos genéricos.'**
  String get onbSlide3Body;

  /// No description provided for @onbSlide4Title.
  ///
  /// In pt, this message translates to:
  /// **'Planeie refeições no orçamento'**
  String get onbSlide4Title;

  /// No description provided for @onbSlide4Body.
  ///
  /// In pt, this message translates to:
  /// **'Gere um plano mensal ajustado ao seu orçamento alimentar e agregado familiar.'**
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
  /// **'Índice de Serenidade'**
  String get onbTourDash2Title;

  /// No description provided for @onbTourDash2Body.
  ///
  /// In pt, this message translates to:
  /// **'Pontuação de saúde financeira 0–100. Toque para ver os fatores.'**
  String get onbTourDash2Body;

  /// No description provided for @onbTourDash3Title.
  ///
  /// In pt, this message translates to:
  /// **'Orçamento vs real'**
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
  /// **'Navegação'**
  String get onbTourDash5Title;

  /// No description provided for @onbTourDash5Body.
  ///
  /// In pt, this message translates to:
  /// **'5 secções: Orçamento, Supermercado, Lista, Coach, Refeições.'**
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
  /// **'Adicionar à lista'**
  String get onbTourGrocery2Title;

  /// No description provided for @onbTourGrocery2Body.
  ///
  /// In pt, this message translates to:
  /// **'Toque + num produto para o adicionar à lista de compras.'**
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
  /// **'Histórico de compras'**
  String get onbTourShopping3Title;

  /// No description provided for @onbTourShopping3Body.
  ///
  /// In pt, this message translates to:
  /// **'Veja todas as sessões de compras anteriores aqui.'**
  String get onbTourShopping3Body;

  /// No description provided for @onbTourCoach1Title.
  ///
  /// In pt, this message translates to:
  /// **'Analisar o meu orçamento'**
  String get onbTourCoach1Title;

  /// No description provided for @onbTourCoach1Body.
  ///
  /// In pt, this message translates to:
  /// **'Toque para gerar uma análise baseada nos seus dados reais.'**
  String get onbTourCoach1Body;

  /// No description provided for @onbTourCoach2Title.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de análises'**
  String get onbTourCoach2Title;

  /// No description provided for @onbTourCoach2Body.
  ///
  /// In pt, this message translates to:
  /// **'As análises guardadas aparecem aqui, mais recentes primeiro.'**
  String get onbTourCoach2Body;

  /// No description provided for @onbTourMeals1Title.
  ///
  /// In pt, this message translates to:
  /// **'Gerar plano'**
  String get onbTourMeals1Title;

  /// No description provided for @onbTourMeals1Body.
  ///
  /// In pt, this message translates to:
  /// **'Cria um mês completo de refeições dentro do orçamento alimentar.'**
  String get onbTourMeals1Body;

  /// No description provided for @onbTourMeals2Title.
  ///
  /// In pt, this message translates to:
  /// **'Vista semanal'**
  String get onbTourMeals2Title;

  /// No description provided for @onbTourMeals2Body.
  ///
  /// In pt, this message translates to:
  /// **'Navegue refeições por semana. Toque num dia para ver a receita.'**
  String get onbTourMeals2Body;

  /// No description provided for @onbTourMeals3Title.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar à lista de compras'**
  String get onbTourMeals3Title;

  /// No description provided for @onbTourMeals3Body.
  ///
  /// In pt, this message translates to:
  /// **'Envie os ingredientes da semana para a lista com um toque.'**
  String get onbTourMeals3Body;

  /// No description provided for @onbTourExpenseTracker1Title.
  ///
  /// In pt, this message translates to:
  /// **'Navegação mensal'**
  String get onbTourExpenseTracker1Title;

  /// No description provided for @onbTourExpenseTracker1Body.
  ///
  /// In pt, this message translates to:
  /// **'Alterne entre meses para ver ou adicionar despesas de qualquer período.'**
  String get onbTourExpenseTracker1Body;

  /// No description provided for @onbTourExpenseTracker2Title.
  ///
  /// In pt, this message translates to:
  /// **'Resumo do orçamento'**
  String get onbTourExpenseTracker2Title;

  /// No description provided for @onbTourExpenseTracker2Body.
  ///
  /// In pt, this message translates to:
  /// **'Veja o orçado vs real e o saldo restante de relance.'**
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
  /// **'Cada cartão mostra o progresso em direção ao objetivo. Toque para ver detalhes e adicionar contribuições.'**
  String get onbTourSavings1Body;

  /// No description provided for @onbTourSavings2Title.
  ///
  /// In pt, this message translates to:
  /// **'Criar objetivo'**
  String get onbTourSavings2Title;

  /// No description provided for @onbTourSavings2Body.
  ///
  /// In pt, this message translates to:
  /// **'Toque + para definir um novo objetivo de poupança com valor alvo e prazo opcional.'**
  String get onbTourSavings2Body;

  /// No description provided for @onbTourRecurring1Title.
  ///
  /// In pt, this message translates to:
  /// **'Despesas recorrentes'**
  String get onbTourRecurring1Title;

  /// No description provided for @onbTourRecurring1Body.
  ///
  /// In pt, this message translates to:
  /// **'Contas fixas mensais como renda, subscrições e serviços. São incluídas automaticamente no orçamento.'**
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
  /// **'O seu atalho para ações rápidas. Toque para adicionar despesas, mudar definições, navegar e mais u2014 basta escrever o que precisa.'**
  String get onbTourAssistant1Body;

  /// No description provided for @taxDeductionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Deduções IRS'**
  String get taxDeductionTitle;

  /// No description provided for @taxDeductionSeeDetail.
  ///
  /// In pt, this message translates to:
  /// **'Ver detalhe'**
  String get taxDeductionSeeDetail;

  /// No description provided for @taxDeductionEstimated.
  ///
  /// In pt, this message translates to:
  /// **'dedução estimada'**
  String get taxDeductionEstimated;

  /// No description provided for @taxDeductionMaxOf.
  ///
  /// In pt, this message translates to:
  /// **'Máx. de {amount}'**
  String taxDeductionMaxOf(String amount);

  /// No description provided for @taxDeductionDetailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Deduções IRS — Detalhe'**
  String get taxDeductionDetailTitle;

  /// No description provided for @taxDeductionDeductibleTitle.
  ///
  /// In pt, this message translates to:
  /// **'CATEGORIAS DEDUTÍVEIS'**
  String get taxDeductionDeductibleTitle;

  /// No description provided for @taxDeductionNonDeductibleTitle.
  ///
  /// In pt, this message translates to:
  /// **'CATEGORIAS NÃO DEDUTÍVEIS'**
  String get taxDeductionNonDeductibleTitle;

  /// No description provided for @taxDeductionTotalLabel.
  ///
  /// In pt, this message translates to:
  /// **'DEDUÇÃO IRS ESTIMADA'**
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
  /// **'Não dedutível'**
  String get taxDeductionNotDeductible;

  /// No description provided for @taxDeductionDisclaimer.
  ///
  /// In pt, this message translates to:
  /// **'Estes valores são estimativas baseadas nas despesas registadas. As deduções reais dependem das faturas registadas no e-Fatura. Consulte um profissional fiscal para valores definitivos.'**
  String get taxDeductionDisclaimer;

  /// No description provided for @settingsDashTaxDeductions.
  ///
  /// In pt, this message translates to:
  /// **'Deduções fiscais (PT)'**
  String get settingsDashTaxDeductions;

  /// No description provided for @settingsDashUpcomingBills.
  ///
  /// In pt, this message translates to:
  /// **'Contas a pagar'**
  String get settingsDashUpcomingBills;

  /// No description provided for @settingsDashBudgetStreaks.
  ///
  /// In pt, this message translates to:
  /// **'Séries de orçamento'**
  String get settingsDashBudgetStreaks;

  /// No description provided for @upcomingBillsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Contas a Pagar'**
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
  /// **'Amanhã'**
  String get billDueTomorrow;

  /// No description provided for @billDueInDays.
  ///
  /// In pt, this message translates to:
  /// **'Em {days} dias'**
  String billDueInDays(int days);

  /// No description provided for @savingsProjectionReachedBy.
  ///
  /// In pt, this message translates to:
  /// **'Atingido até {date}'**
  String savingsProjectionReachedBy(String date);

  /// No description provided for @savingsProjectionNeedPerMonth.
  ///
  /// In pt, this message translates to:
  /// **'Precisa {amount}/mês para cumprir prazo'**
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
  /// **'Adicione contribuições para ver projeção'**
  String get savingsProjectionNoData;

  /// No description provided for @savingsProjectionAvgContribution.
  ///
  /// In pt, this message translates to:
  /// **'Média {amount}/mês'**
  String savingsProjectionAvgContribution(String amount);

  /// No description provided for @taxSimTitle.
  ///
  /// In pt, this message translates to:
  /// **'Simulador Fiscal'**
  String get taxSimTitle;

  /// No description provided for @taxSimPresets.
  ///
  /// In pt, this message translates to:
  /// **'CENÁRIOS RÁPIDOS'**
  String get taxSimPresets;

  /// No description provided for @taxSimPresetRaise.
  ///
  /// In pt, this message translates to:
  /// **'+€200 aumento'**
  String get taxSimPresetRaise;

  /// No description provided for @taxSimPresetMeal.
  ///
  /// In pt, this message translates to:
  /// **'Cartão vs dinheiro'**
  String get taxSimPresetMeal;

  /// No description provided for @taxSimPresetTitular.
  ///
  /// In pt, this message translates to:
  /// **'Único vs conjunto'**
  String get taxSimPresetTitular;

  /// No description provided for @taxSimParameters.
  ///
  /// In pt, this message translates to:
  /// **'PARÂMETROS'**
  String get taxSimParameters;

  /// No description provided for @taxSimGross.
  ///
  /// In pt, this message translates to:
  /// **'Salário bruto'**
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
  /// **'Tipo de subsídio de alimentação'**
  String get taxSimMealType;

  /// No description provided for @taxSimMealAmount.
  ///
  /// In pt, this message translates to:
  /// **'Subsídio alim./dia'**
  String get taxSimMealAmount;

  /// No description provided for @taxSimComparison.
  ///
  /// In pt, this message translates to:
  /// **'ATUAL VS SIMULADO'**
  String get taxSimComparison;

  /// No description provided for @taxSimNetTakeHome.
  ///
  /// In pt, this message translates to:
  /// **'Líquido a receber'**
  String get taxSimNetTakeHome;

  /// No description provided for @taxSimIRS.
  ///
  /// In pt, this message translates to:
  /// **'Retenção IRS'**
  String get taxSimIRS;

  /// No description provided for @taxSimSS.
  ///
  /// In pt, this message translates to:
  /// **'Segurança social'**
  String get taxSimSS;

  /// No description provided for @taxSimDelta.
  ///
  /// In pt, this message translates to:
  /// **'Diferença mensal:'**
  String get taxSimDelta;

  /// No description provided for @taxSimButton.
  ///
  /// In pt, this message translates to:
  /// **'Simulador Fiscal'**
  String get taxSimButton;

  /// No description provided for @streakTitle.
  ///
  /// In pt, this message translates to:
  /// **'Séries de Orçamento'**
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
  /// **'Dentro do orçamento'**
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
  /// **'ORÇAMENTO BASE'**
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
  /// **'Deixe vazio para usar o orçamento base'**
  String get expenseAdjustMonthHint;

  /// No description provided for @settingsPersonalTip.
  ///
  /// In pt, this message translates to:
  /// **'O estado civil e dependentes afetam o escalão de IRS, que determina o imposto retido no salário.'**
  String get settingsPersonalTip;

  /// No description provided for @settingsSalariesTip.
  ///
  /// In pt, this message translates to:
  /// **'O salário bruto é usado para calcular o rendimento líquido após impostos e segurança social. Adicione vários salários se o agregado tiver mais que um rendimento.'**
  String get settingsSalariesTip;

  /// No description provided for @settingsExpensesTip.
  ///
  /// In pt, this message translates to:
  /// **'Defina o orçamento mensal para cada categoria. Pode ajustar para meses específicos na vista de detalhe da categoria.'**
  String get settingsExpensesTip;

  /// No description provided for @settingsMealHouseholdTip.
  ///
  /// In pt, this message translates to:
  /// **'Número de pessoas que fazem refeições em casa. Isto ajusta receitas e porções no plano alimentar.'**
  String get settingsMealHouseholdTip;

  /// No description provided for @settingsHouseholdTip.
  ///
  /// In pt, this message translates to:
  /// **'Convide membros da família para partilhar dados do orçamento entre dispositivos. Todos veem as mesmas despesas e orçamentos.'**
  String get settingsHouseholdTip;

  /// Subscription section title
  ///
  /// In pt, this message translates to:
  /// **'Subscrição'**
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
  /// **'Família'**
  String get subscriptionFamily;

  /// Trial active label
  ///
  /// In pt, this message translates to:
  /// **'Período de teste ativo'**
  String get subscriptionTrialActive;

  /// No description provided for @subscriptionTrialDaysLeft.
  ///
  /// In pt, this message translates to:
  /// **'{count} dias restantes'**
  String subscriptionTrialDaysLeft(int count);

  /// Trial expired label
  ///
  /// In pt, this message translates to:
  /// **'Período de teste expirado'**
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
  /// **'Gerir Subscrição'**
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
  /// **'Último dia do seu teste gratuito!'**
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
  /// **'/mês'**
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
  /// **'Começar Premium'**
  String get subscriptionStartPremium;

  /// Start family button
  ///
  /// In pt, this message translates to:
  /// **'Começar Família'**
  String get subscriptionStartFamily;

  /// Continue free button
  ///
  /// In pt, this message translates to:
  /// **'Continuar Gratuito'**
  String get subscriptionContinueFree;

  /// Trial ended title
  ///
  /// In pt, this message translates to:
  /// **'O seu período de teste terminou'**
  String get subscriptionTrialEnded;

  /// Choose plan subtitle
  ///
  /// In pt, this message translates to:
  /// **'Escolha um plano para manter todos os seus dados e funcionalidades'**
  String get subscriptionChoosePlan;

  /// Unlock subtitle
  ///
  /// In pt, this message translates to:
  /// **'Desbloqueie todo o poder do seu orçamento'**
  String get subscriptionUnlockPower;

  /// No description provided for @subscriptionRequiresPaid.
  ///
  /// In pt, this message translates to:
  /// **'{feature} requer uma subscrição paga'**
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
  /// **'Sugere receitas que podem ser preparadas com antecedência para várias refeições'**
  String get subtitleBatchCooking;

  /// No description provided for @subtitleReuseLeftovers.
  ///
  /// In pt, this message translates to:
  /// **'Planeia refeições que reutilizam ingredientes de dias anteriores'**
  String get subtitleReuseLeftovers;

  /// No description provided for @subtitleMinimizeWaste.
  ///
  /// In pt, this message translates to:
  /// **'Prioriza o uso de todos os ingredientes comprados antes de expirarem'**
  String get subtitleMinimizeWaste;

  /// No description provided for @subtitleMealTypeInclude.
  ///
  /// In pt, this message translates to:
  /// **'Incluir esta refeição no plano semanal'**
  String get subtitleMealTypeInclude;

  /// No description provided for @subtitleShowHeroCard.
  ///
  /// In pt, this message translates to:
  /// **'Resumo da liquidez líquida no topo'**
  String get subtitleShowHeroCard;

  /// No description provided for @subtitleShowStressIndex.
  ///
  /// In pt, this message translates to:
  /// **'Pontuação (0-100) que mede a pressão de despesas vs rendimento'**
  String get subtitleShowStressIndex;

  /// No description provided for @subtitleShowMonthReview.
  ///
  /// In pt, this message translates to:
  /// **'Resumo comparativo deste mês com os anteriores'**
  String get subtitleShowMonthReview;

  /// No description provided for @subtitleShowUpcomingBills.
  ///
  /// In pt, this message translates to:
  /// **'Despesas recorrentes nos próximos 30 dias'**
  String get subtitleShowUpcomingBills;

  /// No description provided for @subtitleShowSummaryCards.
  ///
  /// In pt, this message translates to:
  /// **'Rendimento, deduções, despesas e taxa de poupança'**
  String get subtitleShowSummaryCards;

  /// No description provided for @subtitleShowBudgetVsActual.
  ///
  /// In pt, this message translates to:
  /// **'Comparação lado a lado por categoria de despesa'**
  String get subtitleShowBudgetVsActual;

  /// No description provided for @subtitleShowExpensesBreakdown.
  ///
  /// In pt, this message translates to:
  /// **'Gráfico circular de despesas por categoria'**
  String get subtitleShowExpensesBreakdown;

  /// No description provided for @subtitleShowSavingsGoals.
  ///
  /// In pt, this message translates to:
  /// **'Progresso em relação aos seus objetivos de poupança'**
  String get subtitleShowSavingsGoals;

  /// No description provided for @subtitleShowTaxDeductions.
  ///
  /// In pt, this message translates to:
  /// **'Deduções fiscais elegíveis estimadas este ano'**
  String get subtitleShowTaxDeductions;

  /// No description provided for @subtitleShowBudgetStreaks.
  ///
  /// In pt, this message translates to:
  /// **'Quantos meses consecutivos ficou dentro do orçamento'**
  String get subtitleShowBudgetStreaks;

  /// No description provided for @subtitleShowPurchaseHistory.
  ///
  /// In pt, this message translates to:
  /// **'Compras recentes da lista de compras e custos'**
  String get subtitleShowPurchaseHistory;

  /// No description provided for @subtitleShowCharts.
  ///
  /// In pt, this message translates to:
  /// **'Gráficos de tendência de orçamento, despesas e rendimento'**
  String get subtitleShowCharts;

  /// No description provided for @subtitleChartExpensesPie.
  ///
  /// In pt, this message translates to:
  /// **'Distribuição de despesas por categoria'**
  String get subtitleChartExpensesPie;

  /// No description provided for @subtitleChartIncomeVsExpenses.
  ///
  /// In pt, this message translates to:
  /// **'Rendimento mensal comparado com despesas totais'**
  String get subtitleChartIncomeVsExpenses;

  /// No description provided for @subtitleChartDeductions.
  ///
  /// In pt, this message translates to:
  /// **'Discriminação de despesas dedutíveis nos impostos'**
  String get subtitleChartDeductions;

  /// No description provided for @subtitleChartNetIncome.
  ///
  /// In pt, this message translates to:
  /// **'Tendência do rendimento líquido ao longo do tempo'**
  String get subtitleChartNetIncome;

  /// No description provided for @subtitleChartSavingsRate.
  ///
  /// In pt, this message translates to:
  /// **'Percentagem de rendimento poupado por mês'**
  String get subtitleChartSavingsRate;

  /// No description provided for @helperCountry.
  ///
  /// In pt, this message translates to:
  /// **'Determina o sistema fiscal, moeda e taxas de segurança social'**
  String get helperCountry;

  /// No description provided for @helperLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Substituir o idioma do sistema. \"Sistema\" segue a definição do dispositivo'**
  String get helperLanguage;

  /// No description provided for @helperMaritalStatus.
  ///
  /// In pt, this message translates to:
  /// **'Afeta o cálculo do escalão de IRS'**
  String get helperMaritalStatus;

  /// No description provided for @helperMealObjective.
  ///
  /// In pt, this message translates to:
  /// **'Define o padrão alimentar: omnívoro, vegetariano, pescatariano, etc.'**
  String get helperMealObjective;

  /// No description provided for @helperSodiumPreference.
  ///
  /// In pt, this message translates to:
  /// **'Filtra receitas pelo nível de teor de sódio'**
  String get helperSodiumPreference;

  /// No description provided for @subtitleDietaryRestriction.
  ///
  /// In pt, this message translates to:
  /// **'Exclui receitas que contêm {ingredient}'**
  String subtitleDietaryRestriction(String ingredient);

  /// No description provided for @subtitleExcludedProtein.
  ///
  /// In pt, this message translates to:
  /// **'Remove {protein} de todas as sugestões de refeições'**
  String subtitleExcludedProtein(String protein);

  /// No description provided for @subtitleKitchenEquipment.
  ///
  /// In pt, this message translates to:
  /// **'Ativa receitas que requerem {equipment}'**
  String subtitleKitchenEquipment(String equipment);

  /// No description provided for @helperVeggieDays.
  ///
  /// In pt, this message translates to:
  /// **'Número de dias totalmente vegetarianos por semana'**
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
  /// **'Recomendado: máximo 2 vezes por semana'**
  String get helperRedMeatDays;

  /// No description provided for @helperMaxPrepTime.
  ///
  /// In pt, this message translates to:
  /// **'Tempo máximo de confeção para refeições de semana (minutos)'**
  String get helperMaxPrepTime;

  /// No description provided for @helperMaxComplexity.
  ///
  /// In pt, this message translates to:
  /// **'Nível de dificuldade das receitas para dias de semana'**
  String get helperMaxComplexity;

  /// No description provided for @helperWeekendPrepTime.
  ///
  /// In pt, this message translates to:
  /// **'Tempo máximo de confeção para refeições de fim de semana (minutos)'**
  String get helperWeekendPrepTime;

  /// No description provided for @helperWeekendComplexity.
  ///
  /// In pt, this message translates to:
  /// **'Nível de dificuldade das receitas para fins de semana'**
  String get helperWeekendComplexity;

  /// No description provided for @helperMaxBatchDays.
  ///
  /// In pt, this message translates to:
  /// **'Quantos dias uma refeição preparada em lote pode ser reutilizada'**
  String get helperMaxBatchDays;

  /// No description provided for @helperNewIngredients.
  ///
  /// In pt, this message translates to:
  /// **'Limita quantos ingredientes novos aparecem por semana'**
  String get helperNewIngredients;

  /// No description provided for @helperGrossSalary.
  ///
  /// In pt, this message translates to:
  /// **'Salário total antes de impostos e deduções'**
  String get helperGrossSalary;

  /// No description provided for @helperExemptIncome.
  ///
  /// In pt, this message translates to:
  /// **'Rendimento adicional não sujeito a IRS (ex.: subsídios)'**
  String get helperExemptIncome;

  /// No description provided for @helperMealAllowance.
  ///
  /// In pt, this message translates to:
  /// **'Subsídio de refeição diário do empregador'**
  String get helperMealAllowance;

  /// No description provided for @helperWorkingDays.
  ///
  /// In pt, this message translates to:
  /// **'Típico: 22. Afeta o cálculo do subsídio de refeição'**
  String get helperWorkingDays;

  /// No description provided for @helperSalaryLabel.
  ///
  /// In pt, this message translates to:
  /// **'Um nome para identificar esta fonte de rendimento'**
  String get helperSalaryLabel;

  /// No description provided for @helperExpenseAmount.
  ///
  /// In pt, this message translates to:
  /// **'Montante mensal orçamentado para esta categoria'**
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
  /// **'Compara os gastos reais com o seu orçamento. Intervalos de pontuação:\n\n0-30: Confortável - gastos bem dentro do orçamento\n30-60: Moderado - a aproximar-se dos limites do orçamento\n60-100: Crítico - gastos excedem significativamente o orçamento'**
  String get infoStressIndex;

  /// No description provided for @infoBudgetStreak.
  ///
  /// In pt, this message translates to:
  /// **'Meses consecutivos em que a despesa total ficou dentro do orçamento total.'**
  String get infoBudgetStreak;

  /// No description provided for @infoUpcomingBills.
  ///
  /// In pt, this message translates to:
  /// **'Mostra despesas recorrentes nos próximos 30 dias com base nas suas despesas mensais.'**
  String get infoUpcomingBills;

  /// No description provided for @infoSalaryBreakdown.
  ///
  /// In pt, this message translates to:
  /// **'Mostra como o salário bruto é dividido em imposto IRS, contribuições para a segurança social, rendimento líquido e subsídio de refeição.'**
  String get infoSalaryBreakdown;

  /// No description provided for @infoBudgetVsActual.
  ///
  /// In pt, this message translates to:
  /// **'Compara o que orçamentou por categoria com o que realmente gastou. Verde significa abaixo do orçamento, vermelho significa acima do orçamento.'**
  String get infoBudgetVsActual;

  /// No description provided for @infoSavingsGoals.
  ///
  /// In pt, this message translates to:
  /// **'Progresso em relação a cada objetivo de poupança com base nas contribuições efetuadas.'**
  String get infoSavingsGoals;

  /// No description provided for @infoTaxDeductions.
  ///
  /// In pt, this message translates to:
  /// **'Despesas dedutíveis estimadas (saúde, educação, habitação). Estas são apenas estimativas - consulte um profissional fiscal para valores precisos.'**
  String get infoTaxDeductions;

  /// No description provided for @infoPurchaseHistory.
  ///
  /// In pt, this message translates to:
  /// **'Total gasto em compras da lista de compras este mês.'**
  String get infoPurchaseHistory;

  /// No description provided for @infoExpensesBreakdown.
  ///
  /// In pt, this message translates to:
  /// **'Discriminação visual das suas despesas por categoria no mês atual.'**
  String get infoExpensesBreakdown;

  /// No description provided for @infoCharts.
  ///
  /// In pt, this message translates to:
  /// **'Dados de tendência ao longo do tempo. Toque em qualquer gráfico para uma vista detalhada.'**
  String get infoCharts;

  /// No description provided for @infoExpenseTrackerSummary.
  ///
  /// In pt, this message translates to:
  /// **'Orçamentado = despesa mensal planeada. Real = o que gastou até agora. Restante = orçamento menos real.'**
  String get infoExpenseTrackerSummary;

  /// No description provided for @infoExpenseTrackerProgress.
  ///
  /// In pt, this message translates to:
  /// **'Verde: abaixo de 75% do orçamento. Amarelo: 75-100%. Vermelho: acima do orçamento.'**
  String get infoExpenseTrackerProgress;

  /// No description provided for @infoExpenseTrackerFilter.
  ///
  /// In pt, this message translates to:
  /// **'Filtre despesas por texto, categoria ou intervalo de datas.'**
  String get infoExpenseTrackerFilter;

  /// No description provided for @infoSavingsProjection.
  ///
  /// In pt, this message translates to:
  /// **'Baseado nas suas contribuições mensais médias. \"No caminho certo\" significa que o ritmo atual atinge o objetivo no prazo. \"Atrasado\" significa que precisa de aumentar as contribuições.'**
  String get infoSavingsProjection;

  /// No description provided for @infoSavingsRequired.
  ///
  /// In pt, this message translates to:
  /// **'O montante que precisa de poupar por mês a partir de agora para atingir o objetivo no prazo.'**
  String get infoSavingsRequired;

  /// No description provided for @infoCoachModes.
  ///
  /// In pt, this message translates to:
  /// **'Eco: gratuito, sem memória de conversa.\nPlus: 1 crédito por mensagem, lembra as últimas 5 mensagens.\nPro: 2 créditos por mensagem, memória de conversa completa.'**
  String get infoCoachModes;

  /// No description provided for @infoCoachCredits.
  ///
  /// In pt, this message translates to:
  /// **'Os créditos são usados nos modos Plus e Pro. Recebe créditos iniciais ao registar-se. O modo Eco é sempre gratuito.'**
  String get infoCoachCredits;

  /// No description provided for @helperWizardGrossSalary.
  ///
  /// In pt, this message translates to:
  /// **'O seu salário mensal total antes de impostos'**
  String get helperWizardGrossSalary;

  /// No description provided for @helperWizardMealAllowance.
  ///
  /// In pt, this message translates to:
  /// **'Subsídio de refeição diário do empregador (se aplicável)'**
  String get helperWizardMealAllowance;

  /// No description provided for @helperWizardRent.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento mensal de habitação'**
  String get helperWizardRent;

  /// No description provided for @helperWizardGroceries.
  ///
  /// In pt, this message translates to:
  /// **'Orçamento mensal de alimentação e produtos domésticos'**
  String get helperWizardGroceries;

  /// No description provided for @helperWizardTransport.
  ///
  /// In pt, this message translates to:
  /// **'Custos mensais de transporte (combustível, transportes públicos, etc.)'**
  String get helperWizardTransport;

  /// No description provided for @helperWizardUtilities.
  ///
  /// In pt, this message translates to:
  /// **'Eletricidade, água e gás mensais'**
  String get helperWizardUtilities;

  /// No description provided for @helperWizardTelecom.
  ///
  /// In pt, this message translates to:
  /// **'Internet, telefone e TV mensais'**
  String get helperWizardTelecom;
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
