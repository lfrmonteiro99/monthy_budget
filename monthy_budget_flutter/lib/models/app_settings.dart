import 'dart:convert';
import 'meal_settings.dart';
import '../data/tax/tax_system.dart';
import '../l10n/generated/app_localizations.dart';

enum MaritalStatus {
  solteiro,
  casado,
  uniaoFacto,
  divorciado,
  viuvo;

  String get label {
    switch (this) {
      case MaritalStatus.solteiro:
        return 'Solteiro(a)';
      case MaritalStatus.casado:
        return 'Casado(a)';
      case MaritalStatus.uniaoFacto:
        return 'Uniao de Facto';
      case MaritalStatus.divorciado:
        return 'Divorciado(a)';
      case MaritalStatus.viuvo:
        return 'Viuvo(a)';
    }
  }

  String get jsonValue {
    switch (this) {
      case MaritalStatus.solteiro:
        return 'solteiro';
      case MaritalStatus.casado:
        return 'casado';
      case MaritalStatus.uniaoFacto:
        return 'uniao_facto';
      case MaritalStatus.divorciado:
        return 'divorciado';
      case MaritalStatus.viuvo:
        return 'viuvo';
    }
  }

  static MaritalStatus fromJson(String value) {
    switch (value) {
      case 'casado':
        return MaritalStatus.casado;
      case 'uniao_facto':
        return MaritalStatus.uniaoFacto;
      case 'divorciado':
        return MaritalStatus.divorciado;
      case 'viuvo':
        return MaritalStatus.viuvo;
      default:
        return MaritalStatus.solteiro;
    }
  }

  String localizedLabel(S l10n) {
    switch (this) {
      case MaritalStatus.solteiro: return l10n.enumMaritalSolteiro;
      case MaritalStatus.casado: return l10n.enumMaritalCasado;
      case MaritalStatus.uniaoFacto: return l10n.enumMaritalUniaoFacto;
      case MaritalStatus.divorciado: return l10n.enumMaritalDivorciado;
      case MaritalStatus.viuvo: return l10n.enumMaritalViuvo;
    }
  }
}

enum SubsidyMode {
  none,   // sem duodécimos — fator 1.0
  full,   // com duodécimos férias+natal — fator 14/12
  half;   // com duodécimos a 50% — fator 13/12

  double get monthlyFactor {
    switch (this) {
      case SubsidyMode.none: return 1.0;
      case SubsidyMode.full: return 14 / 12;
      case SubsidyMode.half: return 13 / 12;
    }
  }

  String get label {
    switch (this) {
      case SubsidyMode.none: return 'Sem duodécimos';
      case SubsidyMode.full: return 'Com duodécimos';
      case SubsidyMode.half: return '50% duodécimos';
    }
  }

  String get shortLabel {
    switch (this) {
      case SubsidyMode.none: return 'Sem';
      case SubsidyMode.full: return 'Com';
      case SubsidyMode.half: return '50%';
    }
  }

  String localizedLabel(S l10n) {
    switch (this) {
      case SubsidyMode.none: return l10n.enumSubsidyNone;
      case SubsidyMode.full: return l10n.enumSubsidyFull;
      case SubsidyMode.half: return l10n.enumSubsidyHalf;
    }
  }
  String localizedShortLabel(S l10n) {
    switch (this) {
      case SubsidyMode.none: return l10n.enumSubsidyNoneShort;
      case SubsidyMode.full: return l10n.enumSubsidyFullShort;
      case SubsidyMode.half: return l10n.enumSubsidyHalfShort;
    }
  }
}

enum MealAllowanceType {
  none,
  card,
  cash;

  String get label {
    switch (this) {
      case MealAllowanceType.none:
        return 'Sem';
      case MealAllowanceType.card:
        return 'Cartao';
      case MealAllowanceType.cash:
        return 'Com base';
    }
  }

  String localizedLabel(S l10n) {
    switch (this) {
      case MealAllowanceType.none: return l10n.enumMealAllowanceNone;
      case MealAllowanceType.card: return l10n.enumMealAllowanceCard;
      case MealAllowanceType.cash: return l10n.enumMealAllowanceCash;
    }
  }
}

enum ExpenseCategory {
  telecomunicacoes,
  energia,
  agua,
  alimentacao,
  educacao,
  habitacao,
  transportes,
  saude,
  lazer,
  outros;

  String get label {
    switch (this) {
      case ExpenseCategory.telecomunicacoes:
        return 'Telecomunicações';
      case ExpenseCategory.energia:
        return 'Energia';
      case ExpenseCategory.agua:
        return 'Água';
      case ExpenseCategory.alimentacao:
        return 'Alimentação';
      case ExpenseCategory.educacao:
        return 'Educação';
      case ExpenseCategory.habitacao:
        return 'Habitação';
      case ExpenseCategory.transportes:
        return 'Transportes';
      case ExpenseCategory.saude:
        return 'Saúde';
      case ExpenseCategory.lazer:
        return 'Lazer';
      case ExpenseCategory.outros:
        return 'Outros';
    }
  }

  String localizedLabel(S l10n) {
    switch (this) {
      case ExpenseCategory.telecomunicacoes: return l10n.enumCatTelecomunicacoes;
      case ExpenseCategory.energia: return l10n.enumCatEnergia;
      case ExpenseCategory.agua: return l10n.enumCatAgua;
      case ExpenseCategory.alimentacao: return l10n.enumCatAlimentacao;
      case ExpenseCategory.educacao: return l10n.enumCatEducacao;
      case ExpenseCategory.habitacao: return l10n.enumCatHabitacao;
      case ExpenseCategory.transportes: return l10n.enumCatTransportes;
      case ExpenseCategory.saude: return l10n.enumCatSaude;
      case ExpenseCategory.lazer: return l10n.enumCatLazer;
      case ExpenseCategory.outros: return l10n.enumCatOutros;
    }
  }

  static ExpenseCategory fromJson(String value) {
    for (final cat in ExpenseCategory.values) {
      if (cat.name == value) return cat;
    }
    return ExpenseCategory.outros;
  }
}

enum ChartType {
  expensesPie,
  incomeVsExpenses,
  netIncomeBar,
  deductionsBreakdown,
  savingsRate;

  String get label {
    switch (this) {
      case ChartType.expensesPie:
        return 'Despesas por Categoria';
      case ChartType.incomeVsExpenses:
        return 'Rendimento vs Despesas';
      case ChartType.netIncomeBar:
        return 'Rendimento Líquido';
      case ChartType.deductionsBreakdown:
        return 'Descontos (IRS + SS)';
      case ChartType.savingsRate:
        return 'Taxa de Poupança';
    }
  }

  String localizedLabel(S l10n) {
    switch (this) {
      case ChartType.expensesPie: return l10n.enumChartExpensesPie;
      case ChartType.incomeVsExpenses: return l10n.enumChartIncomeVsExpenses;
      case ChartType.netIncomeBar: return l10n.enumChartNetIncome;
      case ChartType.deductionsBreakdown: return l10n.enumChartDeductions;
      case ChartType.savingsRate: return l10n.enumChartSavingsRate;
    }
  }

  String get jsonValue {
    switch (this) {
      case ChartType.expensesPie:
        return 'expenses_pie';
      case ChartType.incomeVsExpenses:
        return 'income_vs_expenses';
      case ChartType.netIncomeBar:
        return 'net_income_bar';
      case ChartType.deductionsBreakdown:
        return 'deductions_breakdown';
      case ChartType.savingsRate:
        return 'savings_rate';
    }
  }

  static ChartType fromJson(String value) {
    switch (value) {
      case 'expenses_pie':
        return ChartType.expensesPie;
      case 'income_vs_expenses':
        return ChartType.incomeVsExpenses;
      case 'net_income_bar':
        return ChartType.netIncomeBar;
      case 'deductions_breakdown':
        return ChartType.deductionsBreakdown;
      case 'savings_rate':
        return ChartType.savingsRate;
      default:
        return ChartType.expensesPie;
    }
  }
}

class PersonalInfo {
  final MaritalStatus maritalStatus;
  final int dependentes;
  final bool deficiente;

  const PersonalInfo({
    this.maritalStatus = MaritalStatus.solteiro,
    this.dependentes = 0,
    this.deficiente = false,
  });

  PersonalInfo copyWith({
    MaritalStatus? maritalStatus,
    int? dependentes,
    bool? deficiente,
  }) {
    return PersonalInfo(
      maritalStatus: maritalStatus ?? this.maritalStatus,
      dependentes: dependentes ?? this.dependentes,
      deficiente: deficiente ?? this.deficiente,
    );
  }

  Map<String, dynamic> toJson() => {
        'maritalStatus': maritalStatus.jsonValue,
        'dependentes': dependentes,
        'deficiente': deficiente,
      };

  factory PersonalInfo.fromJson(Map<String, dynamic> json) => PersonalInfo(
        maritalStatus: MaritalStatus.fromJson(json['maritalStatus'] ?? 'solteiro'),
        dependentes: json['dependentes'] ?? 0,
        deficiente: json['deficiente'] ?? false,
      );
}

class SalaryInfo {
  final String label;
  final double grossAmount;
  final bool enabled;
  final int titulares;
  final MealAllowanceType mealAllowanceType;
  final double mealAllowancePerDay;
  final int workingDaysPerMonth;
  final SubsidyMode subsidyMode;
  final double otherExemptIncome;

  const SalaryInfo({
    this.label = '',
    this.grossAmount = 0,
    this.enabled = true,
    this.titulares = 1,
    this.mealAllowanceType = MealAllowanceType.none,
    this.mealAllowancePerDay = 0,
    this.workingDaysPerMonth = 22,
    this.subsidyMode = SubsidyMode.none,
    this.otherExemptIncome = 0,
  });

  SalaryInfo copyWith({
    String? label,
    double? grossAmount,
    bool? enabled,
    int? titulares,
    MealAllowanceType? mealAllowanceType,
    double? mealAllowancePerDay,
    int? workingDaysPerMonth,
    SubsidyMode? subsidyMode,
    double? otherExemptIncome,
  }) {
    return SalaryInfo(
      label: label ?? this.label,
      grossAmount: grossAmount ?? this.grossAmount,
      enabled: enabled ?? this.enabled,
      titulares: titulares ?? this.titulares,
      mealAllowanceType: mealAllowanceType ?? this.mealAllowanceType,
      mealAllowancePerDay: mealAllowancePerDay ?? this.mealAllowancePerDay,
      workingDaysPerMonth: workingDaysPerMonth ?? this.workingDaysPerMonth,
      subsidyMode: subsidyMode ?? this.subsidyMode,
      otherExemptIncome: otherExemptIncome ?? this.otherExemptIncome,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'grossAmount': grossAmount,
        'enabled': enabled,
        'titulares': titulares,
        'mealAllowanceType': mealAllowanceType.name,
        'mealAllowancePerDay': mealAllowancePerDay,
        'workingDaysPerMonth': workingDaysPerMonth,
        'subsidyMode': subsidyMode.name,
        'otherExemptIncome': otherExemptIncome,
      };

  factory SalaryInfo.fromJson(Map<String, dynamic> json) => SalaryInfo(
        label: json['label'] ?? '',
        grossAmount: (json['grossAmount'] ?? 0).toDouble(),
        enabled: json['enabled'] ?? true,
        titulares: json['titulares'] ?? 1,
        mealAllowanceType: MealAllowanceType.values.firstWhere(
          (e) => e.name == json['mealAllowanceType'],
          orElse: () => MealAllowanceType.none,
        ),
        mealAllowancePerDay: (json['mealAllowancePerDay'] ?? 0).toDouble(),
        workingDaysPerMonth: json['workingDaysPerMonth'] ?? 22,
        subsidyMode: SubsidyMode.values.firstWhere(
          (e) => e.name == json['subsidyMode'],
          orElse: () => SubsidyMode.none,
        ),
        otherExemptIncome: (json['otherExemptIncome'] ?? 0).toDouble(),
      );
}

class ExpenseItem {
  final String id;
  final String label;
  final double amount;
  final ExpenseCategory category;
  final bool enabled;
  final bool isFixed;

  const ExpenseItem({
    required this.id,
    this.label = '',
    this.amount = 0,
    this.category = ExpenseCategory.outros,
    this.enabled = true,
    this.isFixed = true,
  });

  ExpenseItem copyWith({
    String? id,
    String? label,
    double? amount,
    ExpenseCategory? category,
    bool? enabled,
    bool? isFixed,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      label: label ?? this.label,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      enabled: enabled ?? this.enabled,
      isFixed: isFixed ?? this.isFixed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'amount': amount,
        'category': category.name,
        'enabled': enabled,
        'isFixed': isFixed,
      };

  factory ExpenseItem.fromJson(Map<String, dynamic> json) => ExpenseItem(
        id: json['id'] ?? 'expense_${DateTime.now().millisecondsSinceEpoch}',
        label: json['label'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        category: ExpenseCategory.fromJson(json['category'] ?? 'outros'),
        enabled: json['enabled'] ?? true,
        isFixed: json['isFixed'] ?? true,
      );
}

class DashboardConfig {
  final bool showSummaryCards;
  final List<ChartType> enabledCharts;

  const DashboardConfig({
    this.showSummaryCards = true,
    this.enabledCharts = const [
      ChartType.expensesPie,
      ChartType.incomeVsExpenses,
      ChartType.deductionsBreakdown,
      ChartType.savingsRate,
    ],
  });

  DashboardConfig copyWith({
    bool? showSummaryCards,
    List<ChartType>? enabledCharts,
  }) {
    return DashboardConfig(
      showSummaryCards: showSummaryCards ?? this.showSummaryCards,
      enabledCharts: enabledCharts ?? this.enabledCharts,
    );
  }

  Map<String, dynamic> toJson() => {
        'showSummaryCards': showSummaryCards,
        'enabledCharts': enabledCharts.map((c) => c.jsonValue).toList(),
      };

  factory DashboardConfig.fromJson(Map<String, dynamic> json) => DashboardConfig(
        showSummaryCards: json['showSummaryCards'] ?? true,
        enabledCharts: (json['enabledCharts'] as List<dynamic>?)
                ?.map((e) => ChartType.fromJson(e as String))
                .toList() ??
            const [
              ChartType.expensesPie,
              ChartType.incomeVsExpenses,
              ChartType.deductionsBreakdown,
              ChartType.savingsRate,
            ],
      );
}

class AppSettings {
  final PersonalInfo personalInfo;
  final List<SalaryInfo> salaries;
  final List<ExpenseItem> expenses;
  /// @deprecated Use LocalDashboardConfig (stored in SharedPreferences) instead.
  /// Kept for backwards compatibility with existing serialized data.
  final DashboardConfig dashboardConfig;
  final MealSettings mealSettings;
  final Map<String, int> stressHistory;
  final Country country;
  final String? localeOverride;
  final bool setupWizardCompleted;

  const AppSettings({
    this.personalInfo = const PersonalInfo(),
    this.salaries = const [
      SalaryInfo(label: 'Vencimento 1', enabled: true),
      SalaryInfo(label: 'Vencimento 2', enabled: false),
    ],
    this.expenses = const [
      ExpenseItem(id: 'vodafone', label: 'Vodafone', category: ExpenseCategory.telecomunicacoes),
      ExpenseItem(id: 'eletricidade', label: 'Eletricidade', category: ExpenseCategory.energia),
      ExpenseItem(id: 'agua', label: 'Água', category: ExpenseCategory.agua),
      ExpenseItem(id: 'compras', label: 'Compras / Alimentação', category: ExpenseCategory.alimentacao),
      ExpenseItem(id: 'escola', label: 'Escola', category: ExpenseCategory.educacao),
    ],
    this.dashboardConfig = const DashboardConfig(),
    this.mealSettings = const MealSettings(),
    this.stressHistory = const {},
    this.country = Country.pt,
    this.localeOverride,
    this.setupWizardCompleted = false,
  });

  static const Object _sentinel = Object();

  AppSettings copyWith({
    PersonalInfo? personalInfo,
    List<SalaryInfo>? salaries,
    List<ExpenseItem>? expenses,
    DashboardConfig? dashboardConfig,
    MealSettings? mealSettings,
    Map<String, int>? stressHistory,
    Country? country,
    Object? localeOverride = _sentinel,
    bool? setupWizardCompleted,
  }) {
    return AppSettings(
      personalInfo: personalInfo ?? this.personalInfo,
      salaries: salaries ?? this.salaries,
      expenses: expenses ?? this.expenses,
      dashboardConfig: dashboardConfig ?? this.dashboardConfig,
      mealSettings: mealSettings ?? this.mealSettings,
      stressHistory: stressHistory ?? this.stressHistory,
      country: country ?? this.country,
      localeOverride: localeOverride == _sentinel
          ? this.localeOverride
          : localeOverride as String?,
      setupWizardCompleted: setupWizardCompleted ?? this.setupWizardCompleted,
    );
  }

  String toJsonString() {
    final map = {
      'personalInfo': personalInfo.toJson(),
      'salaries': salaries.map((s) => s.toJson()).toList(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'dashboardConfig': dashboardConfig.toJson(),
      'mealSettings': mealSettings.toJson(),
      'stressHistory': stressHistory,
      'country': country.name,
      'localeOverride': localeOverride,
      'setupWizardCompleted': setupWizardCompleted,
    };
    return jsonEncode(map);
  }

  factory AppSettings.fromJsonString(String jsonStr) {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return AppSettings(
      personalInfo: PersonalInfo.fromJson(map['personalInfo'] ?? {}),
      salaries: (map['salaries'] as List<dynamic>?)
              ?.map((s) => SalaryInfo.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [
            SalaryInfo(label: 'Vencimento 1', enabled: true),
            SalaryInfo(label: 'Vencimento 2', enabled: false),
          ],
      expenses: (map['expenses'] as List<dynamic>?)
              ?.map((e) => ExpenseItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      dashboardConfig: DashboardConfig.fromJson(map['dashboardConfig'] ?? {}),
      mealSettings: MealSettings.fromJson(
        (map['mealSettings'] as Map<String, dynamic>?) ?? {},
      ),
      stressHistory: (map['stressHistory'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          const {},
      country: Country.fromJson(map['country'] as String?),
      localeOverride: map['localeOverride'] as String?,
      // Existing users (row exists but key missing) → true; new users → false
      setupWizardCompleted: map.containsKey('setupWizardCompleted')
          ? (map['setupWizardCompleted'] ?? false)
          : true,
    );
  }
}
