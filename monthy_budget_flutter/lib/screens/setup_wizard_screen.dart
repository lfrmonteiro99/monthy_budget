import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../data/tax/tax_system.dart';
import '../data/tax/tax_factory.dart';
import '../utils/calculations.dart';
import '../utils/formatters.dart';
import '../main.dart' show appLocaleNotifier;
import '../theme/app_colors.dart';

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
  int _step = 0; // 0=welcome, 1=country, 2=personal, 3=salary, 4=expenses, 5=completion
  late PageController _pageController;
  static const _dataSteps = 4; // for progress display (steps 1-4)

  // Expense controllers for step 4
  final _expenseControllers = <String, TextEditingController>{};

  // Salary controller for step 3
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
    if (_step < 5) {
      setState(() => _step++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipAll() {
    widget.onComplete(_draft);
  }

  void _finishExpenses() {
    // Build expense items from controllers
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

  ExpenseCategory _expenseCategory(String key) {
    switch (key) {
      case 'rent': return ExpenseCategory.habitacao;
      case 'groceries': return ExpenseCategory.alimentacao;
      case 'transport': return ExpenseCategory.transportes;
      case 'utilities': return ExpenseCategory.energia;
      case 'telecom': return ExpenseCategory.telecomunicacoes;
      case 'health': return ExpenseCategory.saude;
      case 'leisure': return ExpenseCategory.lazer;
      default: return ExpenseCategory.outros;
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
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: _step >= 1 && _step <= 4
          ? AppBar(
              backgroundColor: AppColors.surface(context),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _back,
              ),
              title: Text(
                S.of(context).setupWizardStepOf(_step, _dataSteps),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: _step / _dataSteps,
                  backgroundColor: AppColors.border(context),
                  color: AppColors.primary(context),
                  minHeight: 4,
                ),
              ),
            )
          : null,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _WelcomeStep(onStart: _next, onSkip: _skipAll),
          _CountryStep(
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
          ),
          _PersonalStep(
            draft: _draft,
            onChanged: (d) => setState(() => _draft = d),
            onNext: _next,
          ),
          _SalaryStep(
            draft: _draft,
            onChanged: (d) => setState(() => _draft = d),
            onNext: _next,
            onSkip: _next,
            salaryController: _salaryController,
            mealAllowanceController: _mealAllowanceController,
          ),
          _ExpensesStep(
            draft: _draft,
            controllers: _expenseControllers,
            expenseKeyOrder: _expenseKeyOrder(),
            expenseIcon: _expenseIcon,
            expenseLabel: (key) => _expenseL10nLabel(S.of(context), key),
            onFinish: _finishExpenses,
          ),
          _CompletionStep(
            draft: _draft,
            onGoToDashboard: _finish,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Screen 0 -- Welcome
// ============================================================
class _WelcomeStep extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onSkip;
  const _WelcomeStep({required this.onStart, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Icon(Icons.account_balance_wallet_outlined,
                size: 64, color: AppColors.primary(context)),
            const SizedBox(height: 24),
            Text(
              l10n.setupWizardWelcomeTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.setupWizardWelcomeSubtitle,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _BulletRow(icon: Icons.payments_outlined, text: l10n.setupWizardBullet1),
            const SizedBox(height: 12),
            _BulletRow(icon: Icons.receipt_long_outlined, text: l10n.setupWizardBullet2),
            const SizedBox(height: 12),
            _BulletRow(icon: Icons.savings_outlined, text: l10n.setupWizardBullet3),
            const SizedBox(height: 24),
            Text(
              l10n.setupWizardReassurance,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 3),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(l10n.setupWizardStart,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            TextButton(
              onPressed: onSkip,
              child: Text(l10n.setupWizardSkipAll,
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted(context))),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BulletRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary(context)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
        ),
      ],
    );
  }
}

// ============================================================
// Screen 1 -- Country + Language
// ============================================================
class _CountryStep extends StatelessWidget {
  final AppSettings draft;
  final ValueChanged<AppSettings> onChanged;
  final VoidCallback onNext;

  const _CountryStep({
    required this.draft,
    required this.onChanged,
    required this.onNext,
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
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(l10n.setupWizardCountryTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(l10n.setupWizardCountrySubtitle,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary(context))),
              const SizedBox(height: 20),
              ..._countries.map((entry) {
                final (country, flag) = entry;
                final selected = draft.country == country;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: selected ? AppColors.infoBackground(context) : AppColors.surface(context),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        final newLocale = _localeForCountry(country);
                        onChanged(draft.copyWith(
                          country: country,
                          localeOverride: newLocale,
                        ));
                        appLocaleNotifier.value =
                            newLocale != null ? Locale(newLocale) : null;
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary(context)
                                : AppColors.border(context),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(flag, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_countryName(l10n, country),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      )),
                                  Text(country.currencySymbol,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted(context))),
                                ],
                              ),
                            ),
                            Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: selected
                                  ? AppColors.primary(context)
                                  : AppColors.borderMuted(context),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              Text(l10n.setupWizardLanguage,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted(context),
                      letterSpacing: 1.2)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: draft.localeOverride,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.border(context))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.border(context))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: AppColors.primary(context), width: 2)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(l10n.setupWizardLangSystem),
                  ),
                  DropdownMenuItem(value: 'pt', child: Text(l10n.languagePortuguese)),
                  DropdownMenuItem(value: 'en', child: Text(l10n.languageEnglish)),
                  DropdownMenuItem(value: 'fr', child: Text(l10n.languageFrench)),
                  DropdownMenuItem(value: 'es', child: Text(l10n.languageSpanish)),
                ],
                onChanged: (value) {
                  onChanged(draft.copyWith(localeOverride: value));
                  appLocaleNotifier.value =
                      value != null ? Locale(value) : null;
                },
              ),
            ],
          ),
        ),
        _BottomButton(
          label: l10n.setupWizardContinue,
          onPressed: onNext,
        ),
      ],
    );
  }
}

// ============================================================
// Screen 2 -- Personal
// ============================================================
class _PersonalStep extends StatelessWidget {
  final AppSettings draft;
  final ValueChanged<AppSettings> onChanged;
  final VoidCallback onNext;

  const _PersonalStep({
    required this.draft,
    required this.onChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isCasado = draft.personalInfo.maritalStatus == MaritalStatus.casado;
    final showTitulares = draft.country.hasTitulares && isCasado;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(l10n.setupWizardPersonalTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(l10n.setupWizardPersonalSubtitle,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary(context))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SelectionCard(
                      label: l10n.setupWizardSingle,
                      icon: Icons.person_outlined,
                      selected: !isCasado,
                      onTap: () => onChanged(draft.copyWith(
                        personalInfo: draft.personalInfo.copyWith(
                          maritalStatus: MaritalStatus.solteiro,
                        ),
                      )),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SelectionCard(
                      label: l10n.setupWizardMarried,
                      icon: Icons.people_outlined,
                      selected: isCasado,
                      onTap: () => onChanged(draft.copyWith(
                        personalInfo: draft.personalInfo.copyWith(
                          maritalStatus: MaritalStatus.casado,
                        ),
                      )),
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.setupWizardTitulares,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted(context),
                              letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      Row(
                        children: [1, 2].map((t) {
                          final selected =
                              draft.salaries.isNotEmpty && draft.salaries[0].titulares == t;
                          return Padding(
                            padding: EdgeInsets.only(right: t == 1 ? 8 : 0),
                            child: Material(
                              color: selected
                                  ? AppColors.primary(context)
                                  : AppColors.surface(context),
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                onTap: () {
                                  final salaries =
                                      List<SalaryInfo>.from(draft.salaries);
                                  if (salaries.isNotEmpty) {
                                    salaries[0] =
                                        salaries[0].copyWith(titulares: t);
                                  }
                                  onChanged(draft.copyWith(salaries: salaries));
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 48,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary(context)
                                          : AppColors.border(context),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$t',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? AppColors.onPrimary(context)
                                          : AppColors.textLabel(context),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                crossFadeState: showTitulares
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
              const SizedBox(height: 20),
              Text(l10n.setupWizardDependents,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted(context),
                      letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _CounterButton(
                    icon: Icons.remove,
                    onPressed: draft.personalInfo.dependentes > 0
                        ? () => onChanged(draft.copyWith(
                              personalInfo: draft.personalInfo.copyWith(
                                dependentes:
                                    draft.personalInfo.dependentes - 1,
                              ),
                            ))
                        : null,
                  ),
                  SizedBox(
                    width: 48,
                    child: Text(
                      '${draft.personalInfo.dependentes}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                  ),
                  _CounterButton(
                    icon: Icons.add,
                    onPressed: () => onChanged(draft.copyWith(
                      personalInfo: draft.personalInfo.copyWith(
                        dependentes: draft.personalInfo.dependentes + 1,
                      ),
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _InfoBox(text: l10n.setupWizardPrivacyNote),
            ],
          ),
        ),
        _BottomButton(
          label: l10n.setupWizardContinue,
          onPressed: onNext,
        ),
      ],
    );
  }
}

// ============================================================
// Screen 3 -- Salary
// ============================================================
class _SalaryStep extends StatelessWidget {
  final AppSettings draft;
  final ValueChanged<AppSettings> onChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final TextEditingController salaryController;
  final TextEditingController mealAllowanceController;

  const _SalaryStep({
    required this.draft,
    required this.onChanged,
    required this.onNext,
    required this.onSkip,
    required this.salaryController,
    required this.mealAllowanceController,
  });

  double get _grossAmount =>
      draft.salaries.isNotEmpty ? draft.salaries[0].grossAmount : 0;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final country = draft.country;
    final showMealAllowance = country.hasMealAllowance;
    final showSubsidies = country.hasSubsidies;

    // Calculate net estimate
    String? netEstimate;
    if (_grossAmount > 0) {
      final taxSystem = getTaxSystem(country);
      final result = taxSystem.calculateTax(
        grossSalary: _grossAmount,
        maritalStatus: draft.personalInfo.maritalStatus.jsonValue,
        titulares: draft.salaries.isNotEmpty ? draft.salaries[0].titulares : 1,
        dependentes: draft.personalInfo.dependentes,
      );
      netEstimate = l10n.setupWizardNetEstimate(formatCurrency(result.netSalary));
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(l10n.setupWizardSalaryTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(l10n.setupWizardSalarySubtitle,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary(context))),
              const SizedBox(height: 20),
              TextField(
                controller: salaryController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.setupWizardSalaryGross,
                  prefixText: '${country.currencySymbol} ',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.border(context))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: AppColors.primary(context), width: 2)),
                ),
                onChanged: (value) {
                  final amount =
                      double.tryParse(value.replaceAll(',', '.')) ?? 0;
                  final salaries = List<SalaryInfo>.from(draft.salaries);
                  if (salaries.isNotEmpty) {
                    salaries[0] = salaries[0].copyWith(grossAmount: amount);
                  }
                  onChanged(draft.copyWith(salaries: salaries));
                },
              ),
              if (netEstimate != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up,
                          size: 16, color: Color(0xFF16A34A)),
                      const SizedBox(width: 8),
                      Text(netEstimate,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF15803D))),
                    ],
                  ),
                ),
              ],
              if (showMealAllowance) ...[
                const SizedBox(height: 20),
                Text(l10n.setupWizardMealAllowanceHeading,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted(context),
                        letterSpacing: 1.2)),
                const SizedBox(height: 8),
                Row(
                  children: MealAllowanceType.values.map((type) {
                    final selected = draft.salaries.isNotEmpty &&
                        draft.salaries[0].mealAllowanceType == type;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: type != MealAllowanceType.cash ? 8 : 0),
                        child: Material(
                          color: selected
                              ? AppColors.primary(context)
                              : AppColors.surface(context),
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: () {
                              final salaries =
                                  List<SalaryInfo>.from(draft.salaries);
                              if (salaries.isNotEmpty) {
                                salaries[0] = salaries[0]
                                    .copyWith(mealAllowanceType: type);
                              }
                              onChanged(draft.copyWith(salaries: salaries));
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary(context)
                                      : AppColors.border(context),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                type.localizedLabel(l10n),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? AppColors.onPrimary(context)
                                      : AppColors.textLabel(context),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (draft.salaries.isNotEmpty &&
                    draft.salaries[0].mealAllowanceType !=
                        MealAllowanceType.none) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: mealAllowanceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                    ],
                    decoration: InputDecoration(
                      labelText:
                          '${country.currencySymbol} ${l10n.settingsMealAllowancePerDay}',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: AppColors.border(context))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: AppColors.primary(context), width: 2)),
                    ),
                    onChanged: (value) {
                      final amount =
                          double.tryParse(value.replaceAll(',', '.')) ?? 0;
                      final salaries =
                          List<SalaryInfo>.from(draft.salaries);
                      if (salaries.isNotEmpty) {
                        salaries[0] = salaries[0]
                            .copyWith(mealAllowancePerDay: amount);
                      }
                      onChanged(draft.copyWith(salaries: salaries));
                    },
                  ),
                ],
              ],
              if (showSubsidies) ...[
                const SizedBox(height: 20),
                Text(l10n.setupWizardSubsidyHeading,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted(context),
                        letterSpacing: 1.2)),
                const SizedBox(height: 8),
                Row(
                  children: SubsidyMode.values.map((mode) {
                    final selected = draft.salaries.isNotEmpty &&
                        draft.salaries[0].subsidyMode == mode;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: mode != SubsidyMode.half ? 8 : 0),
                        child: Material(
                          color: selected
                              ? AppColors.primary(context)
                              : AppColors.surface(context),
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: () {
                              final salaries =
                                  List<SalaryInfo>.from(draft.salaries);
                              if (salaries.isNotEmpty) {
                                salaries[0] =
                                    salaries[0].copyWith(subsidyMode: mode);
                              }
                              onChanged(draft.copyWith(salaries: salaries));
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary(context)
                                      : AppColors.border(context),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                mode.localizedShortLabel(l10n),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? AppColors.onPrimary(context)
                                      : AppColors.textLabel(context),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 20),
              _InfoBox(text: l10n.setupWizardSalaryMoreLater),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              children: [
                TextButton(
                  onPressed: onSkip,
                  child: Text(l10n.setupWizardSalarySkip,
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textMuted(context))),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onNext,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(l10n.setupWizardContinue,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Screen 4 -- Expenses
// ============================================================
class _ExpensesStep extends StatelessWidget {
  final AppSettings draft;
  final Map<String, TextEditingController> controllers;
  final List<String> expenseKeyOrder;
  final IconData Function(String key) expenseIcon;
  final String Function(String key) expenseLabel;
  final VoidCallback onFinish;

  const _ExpensesStep({
    required this.draft,
    required this.controllers,
    required this.expenseKeyOrder,
    required this.expenseIcon,
    required this.expenseLabel,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    // Calculate totals for summary line
    double totalExpenses = 0;
    for (final key in expenseKeyOrder) {
      totalExpenses +=
          double.tryParse(controllers[key]?.text ?? '') ?? 0;
    }

    // Net salary from draft
    double? netSalary;
    if (draft.salaries.isNotEmpty && draft.salaries[0].grossAmount > 0) {
      final taxSystem = getTaxSystem(draft.country);
      final summary = calculateBudgetSummary(
        draft.salaries,
        draft.personalInfo,
        draft.expenses,
        taxSystem,
      );
      netSalary = summary.totalNetWithMeal;
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(l10n.setupWizardExpensesTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(l10n.setupWizardExpensesSubtitle,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary(context))),
              if (netSalary != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.setupWizardNetLabel(formatCurrency(netSalary)),
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textLabel(context))),
                      Text(
                          l10n.setupWizardTotalExpenses(
                              formatCurrency(totalExpenses)),
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textLabel(context))),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ...expenseKeyOrder.map((key) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Icon(expenseIcon(key),
                            size: 20, color: AppColors.textSecondary(context)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(expenseLabel(key),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: controllers[key],
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[\d.,]')),
                            ],
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              prefixText: '${draft.country.currencySymbol} ',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: AppColors.border(context))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: AppColors.border(context))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: AppColors.primary(context), width: 2)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 12),
              _InfoBox(text: l10n.setupWizardExpensesMoreLater),
            ],
          ),
        ),
        _BottomButton(
          label: l10n.setupWizardFinish,
          onPressed: onFinish,
        ),
      ],
    );
  }
}

// ============================================================
// Screen 5 -- Completion
// ============================================================
class _CompletionStep extends StatefulWidget {
  final AppSettings draft;
  final VoidCallback onGoToDashboard;

  const _CompletionStep({
    required this.draft,
    required this.onGoToDashboard,
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
      duration: const Duration(milliseconds: 500),
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

    // Compute summary
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
        available >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    size: 48, color: Color(0xFF16A34A)),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.setupWizardCompleteTitle,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            // Summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(countryFlags[draft.country] ?? '',
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(countryName(draft.country),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Divider(height: 20),
                  if (hasSalary) ...[
                    _SummaryRow(
                      label: l10n.setupWizardNetLabel('').replaceAll(': ', ''),
                      value: formatCurrency(summary.totalNetWithMeal),
                    ),
                    const SizedBox(height: 6),
                    _SummaryRow(
                      label: l10n.setupWizardTotalExpenses('').replaceAll(': ', ''),
                      value: formatCurrency(summary.totalExpenses),
                    ),
                    const SizedBox(height: 6),
                    _SummaryRow(
                      label: l10n.setupWizardAvailableLabel('').replaceAll(': ', ''),
                      value: formatCurrency(available),
                      valueColor: availableColor,
                      bold: true,
                    ),
                  ] else ...[
                    Text(l10n.setupWizardConfigureSalaryHint,
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary(context)),
                        textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.setupWizardCompleteReassurance,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
                textAlign: TextAlign.center),
            const Spacer(flex: 3),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: widget.onGoToDashboard,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(l10n.setupWizardGoToDashboard,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Shared widgets
// ============================================================

class _BottomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _BottomButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary(context),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(label,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.infoBackground(context) : AppColors.surface(context),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primary(context)
                  : AppColors.border(context),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 28,
                  color: selected
                      ? AppColors.primary(context)
                      : AppColors.textMuted(context)),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? AppColors.textPrimary(context)
                        : AppColors.textLabel(context),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const _CounterButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed != null ? AppColors.surface(context) : AppColors.surfaceVariant(context),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Icon(icon,
              size: 18,
              color: onPressed != null
                  ? AppColors.textLabel(context)
                  : AppColors.borderMuted(context)),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String text;
  const _InfoBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.infoBackground(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryLight(context)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              size: 16, color: AppColors.primary(context)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF1E40AF))),
          ),
        ],
      ),
    );
  }
}

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
              color: AppColors.textSecondary(context),
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            )),
        Text(value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary(context),
            )),
      ],
    );
  }
}
