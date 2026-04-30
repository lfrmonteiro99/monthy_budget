import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../data/tax/tax_system.dart';
import '../data/tax/tax_factory.dart';
import '../app_shell.dart';
import '../utils/calculations.dart';
import '../utils/formatters.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

// ── Progress bar (4 px, ≤ 30 LoC) ───────────────────────────────────────────
class _WizardProgress extends StatelessWidget {
  final int current;
  final int total;
  const _WizardProgress({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: LinearProgressIndicator(
        value: total > 0 ? current / total : 0,
        backgroundColor: AppColors.line(context),
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent(context)),
        minHeight: 4,
      ),
    );
  }
}

// ── Bottom CTA row ────────────────────────────────────────────────────────────
class _WizardBottomRow extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback? onBack;

  const _WizardBottomRow({
    required this.primaryLabel,
    required this.onPrimary,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Row(
          children: [
            if (onBack != null) ...[
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.ink20(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Anterior'), // TODO(l10n):
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              flex: onBack != null ? 2 : 1,
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: FilledButton(
                  onPressed: onPrimary,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ink(context),
                    foregroundColor: AppColors.inkInverse(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(primaryLabel, style: CalmText.amount(context, size: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Root wizard widget ────────────────────────────────────────────────────────
class SetupWizardScreen extends StatefulWidget {
  final AppSettings initial;
  final ValueChanged<AppSettings> onComplete;

  const SetupWizardScreen({
    super.key,
    required this.initial,
    required this.onComplete,
  });

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  late AppSettings _draft;
  int _step = 0; // 0=welcome+country, 1=salary+expenses, 2=completion
  late PageController _pageController;

  // Expense controllers for step 1
  final _expenseControllers = <String, TextEditingController>{};

  // Salary controller for step 1
  final _salaryController = TextEditingController();

  // Meal allowance controller
  final _mealAllowanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
    _pageController = PageController();
    _initExpenseDefaults();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _salaryController.dispose();
    _mealAllowanceController.dispose();
    for (final c in _expenseControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _initExpenseDefaults() {
    final defaults = _defaultExpenses(_draft.country);
    for (final entry in defaults.entries) {
      _expenseControllers[entry.key] =
          TextEditingController(text: entry.value > 0 ? entry.value.toString() : '');
    }
  }

  void _resetExpenseDefaults(Country country) {
    final defaults = _defaultExpenses(country);
    for (final entry in defaults.entries) {
      _expenseControllers[entry.key]?.text =
          entry.value > 0 ? entry.value.toString() : '';
    }
  }

  static Map<String, double> _defaultExpenses(Country country) {
    switch (country) {
      case Country.pt:
        return {
          'rent': 500, 'groceries': 300, 'transport': 100,
          'utilities': 120, 'telecom': 40, 'health': 30, 'leisure': 100,
        };
      case Country.es:
        return {
          'rent': 600, 'groceries': 280, 'transport': 80,
          'utilities': 100, 'telecom': 35, 'health': 20, 'leisure': 80,
        };
      case Country.fr:
        return {
          'rent': 700, 'groceries': 350, 'transport': 100,
          'utilities': 130, 'telecom': 40, 'health': 30, 'leisure': 100,
        };
      case Country.uk:
        return {
          'rent': 800, 'groceries': 300, 'transport': 120,
          'utilities': 150, 'telecom': 35, 'health': 0, 'leisure': 80,
        };
    }
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
      _pageController.nextPage(
        duration: AppConstants.animPageTransition,
        curve: Curves.easeInOut,
      );
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.previousPage(
        duration: AppConstants.animPageTransition,
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipAll() {
    widget.onComplete(_draft);
  }

  void _finishExpenses() {
    final l10nKeys = _expenseKeyOrder();
    final expenses = <ExpenseItem>[];
    for (final key in l10nKeys) {
      final amount = double.tryParse(_expenseControllers[key]?.text ?? '') ?? 0;
      if (amount > 0) {
        expenses.add(ExpenseItem(
          id: 'wizard_$key',
          label: _expenseLabelFallback(key),
          amount: amount,
          category: _expenseCategory(key),
        ));
      }
    }
    _draft = _draft.copyWith(
      expenses: expenses.isEmpty ? _draft.expenses : expenses,
    );
    _next();
  }

  void _finish() {
    widget.onComplete(_draft);
  }

  List<String> _expenseKeyOrder() =>
      ['rent', 'groceries', 'transport', 'utilities', 'telecom', 'health', 'leisure'];

  String _expenseLabelFallback(String key) {
    switch (key) {
      case 'rent': return 'Renda';
      case 'groceries': return 'Alimentação';
      case 'transport': return 'Transportes';
      case 'utilities': return 'Utilidades';
      case 'telecom': return 'Telecomunicações';
      case 'health': return 'Saúde';
      case 'leisure': return 'Lazer';
      default: return key;
    }
  }

  String _expenseCategory(String key) {
    switch (key) {
      case 'rent': return 'habitacao';
      case 'groceries': return 'alimentacao';
      case 'transport': return 'transportes';
      case 'utilities': return 'energia';
      case 'telecom': return 'telecomunicacoes';
      case 'health': return 'saude';
      case 'leisure': return 'lazer';
      default: return 'outros';
    }
  }

  IconData _expenseIcon(String key) {
    switch (key) {
      case 'rent': return Icons.home_outlined;
      case 'groceries': return Icons.shopping_cart_outlined;
      case 'transport': return Icons.directions_car_outlined;
      case 'utilities': return Icons.bolt_outlined;
      case 'telecom': return Icons.wifi_outlined;
      case 'health': return Icons.local_hospital_outlined;
      case 'leisure': return Icons.sports_esports_outlined;
      default: return Icons.receipt_outlined;
    }
  }

  String _expenseL10nLabel(S l10n, String key) {
    switch (key) {
      case 'rent': return l10n.setupWizardExpRent;
      case 'groceries': return l10n.setupWizardExpGroceries;
      case 'transport': return l10n.setupWizardExpTransport;
      case 'utilities': return l10n.setupWizardExpUtilities;
      case 'telecom': return l10n.setupWizardExpTelecom;
      case 'health': return l10n.setupWizardExpHealth;
      case 'leisure': return l10n.setupWizardExpLeisure;
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Block Android system back from popping the wizard mid-way (which would
    // exit without persisting partial state and re-show the wizard on next
    // launch). Step back via the page controller instead.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_pageController.hasClients && (_pageController.page ?? 0) > 0) {
          _back();
        }
      },
      child: CalmScaffold(
      bodyPadding: EdgeInsets.zero,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Step 0: Welcome message + Country selection
          _WelcomeAndCountryStep(
            draft: _draft,
            onChanged: (d) {
              final countryChanged = d.country != _draft.country;
              setState(() => _draft = d);
              if (countryChanged) {
                _resetExpenseDefaults(d.country);
                setFormatterCountry(d.country);
              }
            },
            onNext: _next,
            onSkip: _skipAll,
          ),
          // Step 1: Salary + Expenses
          _SalaryAndExpensesStep(
            draft: _draft,
            onChanged: (d) => setState(() => _draft = d),
            salaryController: _salaryController,
            mealAllowanceController: _mealAllowanceController,
            expenseControllers: _expenseControllers,
            expenseKeyOrder: _expenseKeyOrder(),
            expenseIcon: _expenseIcon,
            expenseLabel: (key) => _expenseL10nLabel(S.of(context), key),
            onFinish: _finishExpenses,
            onBack: _back,
          ),
          // Step 2: Completion
          _CompletionStep(
            draft: _draft,
            onGoToDashboard: _finish,
            onBack: _back,
          ),
        ],
      ),
      ),
    );
  }
}

// ============================================================
// Step 0 — Welcome + Country
// ============================================================
class _WelcomeAndCountryStep extends StatelessWidget {
  final AppSettings draft;
  final ValueChanged<AppSettings> onChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _WelcomeAndCountryStep({
    required this.draft,
    required this.onChanged,
    required this.onNext,
    required this.onSkip,
  });

  static const _countries = [
    (Country.pt, '🇵🇹'),
    (Country.es, '🇪🇸'),
    (Country.fr, '🇫🇷'),
    (Country.uk, '🇬🇧'),
  ];

  String _countryName(S l10n, Country c) {
    switch (c) {
      case Country.pt: return l10n.setupWizardCountryPT;
      case Country.es: return l10n.setupWizardCountryES;
      case Country.fr: return l10n.setupWizardCountryFR;
      case Country.uk: return l10n.setupWizardCountryUK;
    }
  }

  String? _localeForCountry(Country c) {
    switch (c) {
      case Country.pt: return 'pt';
      case Country.es: return 'es';
      case Country.fr: return 'fr';
      case Country.uk: return 'en';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final appShell = AppShellScope.of(context);
    return Column(
      children: [
        // Progress bar: step 0 of 2
        _WizardProgress(current: 0, total: 2),
        CalmPageHeader(
          eyebrow: 'PASSO 1 · 3', // TODO(l10n):
          title: l10n.setupWizardWelcomeTitle,
          showBack: false,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              Text(
                l10n.setupWizardWelcomeSubtitle,
                style: TextStyle(fontSize: 14, color: AppColors.ink70(context)),
              ),
              const SizedBox(height: 24),
              CalmCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.setupWizardCountryTitle,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink(context))),
                    const SizedBox(height: 12),
                    ..._countries.map((entry) {
                      final (country, flag) = entry;
                      final selected = draft.country == country;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _CountryTile(
                          flag: flag,
                          label: _countryName(l10n, country),
                          selected: selected,
                          onTap: () {
                            final newLocale = _localeForCountry(country);
                            onChanged(draft.copyWith(
                              country: country,
                              localeOverride: newLocale,
                            ));
                            appShell.setLocaleCode(newLocale);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        _WizardBottomRow(
          primaryLabel: l10n.setupWizardContinue,
          onPrimary: onNext,
        ),
        TextButton(
          onPressed: onSkip,
          child: Text(l10n.setupWizardSkipAll,
              style: TextStyle(fontSize: 13, color: AppColors.ink50(context))),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Country tile (replaces Container-based inline widget) ──────────────────
class _CountryTile extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CountryTile({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.accentSoft(context) : AppColors.card(context),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Text(label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                    color: AppColors.ink(context),
                  )),
              const Spacer(),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? AppColors.accent(context)
                    : AppColors.ink20(context),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Step 1 — Salary + Expenses
// ============================================================
class _SalaryAndExpensesStep extends StatelessWidget {
  final AppSettings draft;
  final ValueChanged<AppSettings> onChanged;
  final TextEditingController salaryController;
  final TextEditingController mealAllowanceController;
  final Map<String, TextEditingController> expenseControllers;
  final List<String> expenseKeyOrder;
  final IconData Function(String key) expenseIcon;
  final String Function(String key) expenseLabel;
  final VoidCallback onFinish;
  final VoidCallback onBack;
  final _formKey = GlobalKey<FormState>();

  _SalaryAndExpensesStep({
    required this.draft,
    required this.onChanged,
    required this.salaryController,
    required this.mealAllowanceController,
    required this.expenseControllers,
    required this.expenseKeyOrder,
    required this.expenseIcon,
    required this.expenseLabel,
    required this.onFinish,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final country = draft.country;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Progress bar: step 1 of 2
          _WizardProgress(current: 1, total: 2),
          CalmPageHeader(
            eyebrow: 'PASSO 2 · 3', // TODO(l10n):
            title: l10n.setupWizardSalaryTitle,
            showBack: false,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Text(l10n.setupWizardSalarySubtitle,
                    style: TextStyle(
                        fontSize: 14, color: AppColors.ink70(context))),
                const SizedBox(height: 16),
                // ── Salary card ──────────────────────────────────────
                CalmEyebrow('RENDIMENTO'), // TODO(l10n):
                const SizedBox(height: 8),
                CalmCard(
                  padding: const EdgeInsets.all(16),
                  child: CalmTextField(
                    controller: salaryController,
                    label: l10n.setupWizardSalaryGross,
                    prefixText: '${country.currencySymbol} ',
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                    ],
                    onChanged: (v) {
                      final amount =
                          double.tryParse(v.replaceAll(',', '.')) ?? 0;
                      if (amount > 0) {
                        final salaries = List<SalaryInfo>.from(
                            draft.salaries.isEmpty
                                ? [SalaryInfo(grossAmount: amount)]
                                : [
                                    draft.salaries[0]
                                        .copyWith(grossAmount: amount)
                                  ]);
                        onChanged(draft.copyWith(salaries: salaries));
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // ── Expenses card ────────────────────────────────────
                CalmEyebrow('DESPESAS MENSAIS'), // TODO(l10n):
                const SizedBox(height: 8),
                CalmCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.setupWizardExpensesTitle,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink(context))),
                      const SizedBox(height: 4),
                      Text(l10n.setupWizardExpensesSubtitle,
                          style: TextStyle(
                              fontSize: 13, color: AppColors.ink50(context))),
                      const SizedBox(height: 12),
                      ...expenseKeyOrder.map((key) {
                        final ctrl = expenseControllers[key]!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Icon(expenseIcon(key),
                                  size: 20, color: AppColors.accent(context)),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: Text(expenseLabel(key),
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.ink(context))),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 110,
                                child: CalmTextField(
                                  controller: ctrl,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[\d.,]')),
                                  ],
                                  prefixText: '${country.currencySymbol} ',
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          _WizardBottomRow(
            primaryLabel: l10n.setupWizardContinue,
            onPrimary: () {
              if (_formKey.currentState!.validate()) {
                onFinish();
              }
            },
            onBack: onBack,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Step 2 — Completion
// ============================================================
class _CompletionStep extends StatefulWidget {
  final AppSettings draft;
  final VoidCallback onGoToDashboard;
  final VoidCallback onBack;

  const _CompletionStep({
    required this.draft,
    required this.onGoToDashboard,
    required this.onBack,
  });

  @override
  State<_CompletionStep> createState() => _CompletionStepState();
}

class _CompletionStepState extends State<_CompletionStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: AppConstants.animBounce,
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final draft = widget.draft;

    final taxSystem = getTaxSystem(draft.country);
    final summary = calculateBudgetSummary(
      draft.salaries,
      draft.personalInfo,
      draft.expenses,
      taxSystem,
    );

    final hasSalary =
        draft.salaries.isNotEmpty && draft.salaries[0].grossAmount > 0;
    final available = summary.netLiquidity;
    final availableColor =
        available >= 0 ? AppColors.ok(context) : AppColors.bad(context);

    final countryFlags = {
      Country.pt: '🇵🇹',
      Country.es: '🇪🇸',
      Country.fr: '🇫🇷',
      Country.uk: '🇬🇧',
    };

    String countryName(Country c) {
      switch (c) {
        case Country.pt: return l10n.setupWizardCountryPT;
        case Country.es: return l10n.setupWizardCountryES;
        case Country.fr: return l10n.setupWizardCountryFR;
        case Country.uk: return l10n.setupWizardCountryUK;
      }
    }

    return Column(
      children: [
        // Progress bar: step 2 of 2 (complete)
        _WizardProgress(current: 2, total: 2),
        CalmPageHeader(
          eyebrow: 'PASSO 3 · 3', // TODO(l10n):
          title: l10n.setupWizardCompleteTitle,
          showBack: false,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 8),
              Center(
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.successBackground(context),
                    child: Icon(Icons.check_circle,
                        size: 40, color: AppColors.ok(context)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Summary card
              CalmCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(countryFlags[draft.country] ?? '',
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(countryName(draft.country),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink(context))),
                      ],
                    ),
                    Divider(height: 20, color: AppColors.line(context)),
                    if (hasSalary) ...[
                      _SummaryRow(
                        label: l10n
                            .setupWizardNetLabel('')
                            .replaceAll(': ', ''),
                        value: formatCurrency(summary.totalNetWithMeal),
                      ),
                      const SizedBox(height: 6),
                      _SummaryRow(
                        label: l10n
                            .setupWizardTotalExpenses('')
                            .replaceAll(': ', ''),
                        value: formatCurrency(summary.totalExpenses),
                      ),
                      const SizedBox(height: 6),
                      _SummaryRow(
                        label: l10n
                            .setupWizardAvailableLabel('')
                            .replaceAll(': ', ''),
                        value: formatCurrency(available),
                        valueColor: availableColor,
                        bold: true,
                      ),
                    ] else ...[
                      Text(l10n.setupWizardConfigureSalaryHint,
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.ink50(context)),
                          textAlign: TextAlign.center),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.setupWizardCompleteReassurance,
                  style:
                      TextStyle(fontSize: 12, color: AppColors.ink50(context)),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
        _WizardBottomRow(
          primaryLabel: l10n.setupWizardGoToDashboard, // "Concluir"-equiv.
          onPrimary: widget.onGoToDashboard,
          onBack: widget.onBack,
        ),
      ],
    );
  }
}

// ============================================================
// Shared helpers
// ============================================================

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.ink70(context),
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            )),
        Text(value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? AppColors.ink(context),
            )),
      ],
    );
  }
}
