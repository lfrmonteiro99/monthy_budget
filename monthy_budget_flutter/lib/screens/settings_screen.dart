import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_settings.dart';
import '../models/product.dart';
import '../data/irs_tables.dart';
import '../data/tax/tax_system.dart';
import '../data/tax/tax_factory.dart';
import '../utils/formatters.dart';
import '../services/household_service.dart';
import '../models/meal_settings.dart';
import '../models/local_dashboard_config.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../main.dart';
import '../services/local_config_service.dart';

class SettingsScreen extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onSave;
  final List<String> favorites;
  final ValueChanged<List<String>> onSaveFavorites;
  final String apiKey;
  final ValueChanged<String> onSaveApiKey;
  final bool isAdmin;
  final String householdId;
  final List<Product> products;
  final String? initialSection;
  final LocalDashboardConfig? dashboardConfig;
  final ValueChanged<LocalDashboardConfig>? onSaveDashboardConfig;
  final VoidCallback? onOpenNotificationSettings;
  final Map<String, double> monthlyBudgets;
  final ValueChanged<Map<String, double>>? onSaveMonthlyBudgets;

  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onSave,
    required this.favorites,
    required this.onSaveFavorites,
    required this.apiKey,
    required this.onSaveApiKey,
    required this.isAdmin,
    required this.householdId,
    this.products = const [],
    this.initialSection,
    this.dashboardConfig,
    this.onSaveDashboardConfig,
    this.onOpenNotificationSettings,
    this.monthlyBudgets = const {},
    this.onSaveMonthlyBudgets,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _draft;
  late List<String> _favorites;
  late TextEditingController _apiKeyController;
  String? _openSection = 'salaries';
  late LocalDashboardConfig _localDashboard;
  String? _inviteCode;
  late Map<String, double> _monthlyBudgetsDraft;

  String _favSearch = '';

  @override
  void initState() {
    super.initState();
    _draft = widget.settings;
    _favorites = List<String>.from(widget.favorites);
    _apiKeyController = TextEditingController(text: widget.apiKey);
    if (widget.initialSection != null) {
      _openSection = widget.initialSection;
    }
    _localDashboard = widget.dashboardConfig ?? const LocalDashboardConfig();
    _monthlyBudgetsDraft = Map<String, double>.from(widget.monthlyBudgets);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  bool get _isCasado =>
      _draft.personalInfo.maritalStatus == MaritalStatus.casado ||
      _draft.personalInfo.maritalStatus == MaritalStatus.uniaoFacto;

  void _toggleSection(String section) {
    setState(() {
      _openSection = _openSection == section ? null : section;
    });
  }

  void _handleSave() {
    if (!widget.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(S.of(context).settingsAdminOnly)),
      );
      return;
    }
    widget.onSave(_draft);
    widget.onSaveFavorites(_favorites);
    widget.onSaveApiKey(_apiKeyController.text.trim());
    widget.onSaveDashboardConfig?.call(_localDashboard);
    widget.onSaveMonthlyBudgets?.call(_monthlyBudgetsDraft);
    Navigator.of(context).pop();
  }

  Future<void> _generateInvite() async {
    final code =
        await HouseholdService().generateInviteCode(widget.householdId);
    setState(() => _inviteCode = code);
  }

  void _toggleFavorite(String product) {
    setState(() {
      final lower = product.toLowerCase();
      final idx = _favorites.indexWhere((f) => f.toLowerCase() == lower);
      if (idx >= 0) {
        _favorites.removeAt(idx);
      } else {
        _favorites.add(product);
      }
    });
  }


  void _addExpense() {
    setState(() {
      _draft = _draft.copyWith(
        expenses: [
          ..._draft.expenses,
          ExpenseItem(id: 'expense_${DateTime.now().millisecondsSinceEpoch}'),
        ],
      );
    });
  }

  void _removeExpense(String id) {
    setState(() {
      _draft = _draft.copyWith(
        expenses: _draft.expenses.where((e) => e.id != id).toList(),
      );
    });
  }

  void _updateExpense(String id, ExpenseItem Function(ExpenseItem) updater) {
    setState(() {
      _draft = _draft.copyWith(
        expenses: _draft.expenses.map((e) => e.id == id ? updater(e) : e).toList(),
      );
    });
  }

  int _autoHouseholdSize() {
    final titulares = _draft.salaries
        .where((s) => s.enabled)
        .fold(0, (sum, s) => sum + s.titulares);
    return titulares + _draft.personalInfo.dependentes;
  }

  void _updateSalary(int idx, SalaryInfo Function(SalaryInfo) updater) {
    setState(() {
      final newSalaries = List<SalaryInfo>.from(_draft.salaries);
      newSalaries[idx] = updater(newSalaries[idx]);
      _draft = _draft.copyWith(salaries: newSalaries);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.surface(context),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: AppColors.textLabel(context)),
                  ),
                  Expanded(
                    child: Text(
                      l10n.settingsTitle,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context), letterSpacing: -0.3),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _handleSave,
                    icon: const Icon(Icons.check, size: 16),
                    label: Text(l10n.save),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      foregroundColor: AppColors.onPrimary(context),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.surfaceVariant(context)),
            // Body
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _SectionHeader(
                      icon: Icons.account_balance_wallet,
                      title: l10n.settingsSalariesSection,
                      subtitle: formatCurrency(
                        _draft.salaries
                            .where((s) => s.enabled)
                            .fold(0.0, (sum, s) => sum + s.grossAmount),
                      ),
                      isOpen: _openSection == 'salaries',
                      onTap: () => _toggleSection('salaries'),
                    ),
                    if (_openSection == 'salaries') _buildSalariesSection(),
                    _SectionHeader(
                      icon: Icons.receipt_long,
                      title: l10n.settingsExpensesMonthly,
                      subtitle: '(${_draft.expenses.where((e) => e.enabled).length})',
                      isOpen: _openSection == 'expenses',
                      onTap: () => _toggleSection('expenses'),
                    ),
                    if (_openSection == 'expenses') _buildExpensesSection(),
                    _SectionHeader(
                      icon: Icons.restaurant,
                      title: l10n.settingsMeals,
                      isOpen: _openSection == 'meals',
                      onTap: () => _toggleSection('meals'),
                    ),
                    if (_openSection == 'meals') _buildMealsSection(),
                    _SectionHeader(
                      icon: Icons.favorite,
                      title: l10n.settingsFavorites,
                      subtitle: '(${_favorites.length})',
                      isOpen: _openSection == 'favorites',
                      onTap: () => _toggleSection('favorites'),
                    ),
                    if (_openSection == 'favorites') _buildFavoritesSection(),
                    // Appearance section
                    _SectionHeader(
                      icon: Icons.palette_outlined,
                      title: l10n.settingsAppearance,
                      isOpen: _openSection == 'appearance',
                      onTap: () => _toggleSection('appearance'),
                    ),
                    if (_openSection == 'appearance') _buildAppearanceSection(),
                    _SectionHeader(
                      icon: Icons.dashboard,
                      title: l10n.settingsDashboard,
                      isOpen: _openSection == 'dashboard',
                      onTap: () => _toggleSection('dashboard'),
                    ),
                    if (_openSection == 'dashboard') _buildDashboardSection(),
                    _SectionHeader(
                      icon: Icons.person,
                      title: l10n.settingsPersonal,
                      isOpen: _openSection == 'profile',
                      onTap: () => _toggleSection('profile'),
                    ),
                    if (_openSection == 'profile') _buildProfileSection(),
                    _SectionHeader(
                      icon: Icons.psychology_outlined,
                      title: l10n.settingsCoachOpenAi,
                      isOpen: _openSection == 'coach',
                      onTap: () => _toggleSection('coach'),
                    ),
                    if (_openSection == 'coach') _buildCoachSection(),
                    _SectionHeader(
                      icon: Icons.people_outline,
                      title: l10n.settingsHousehold,
                      isOpen: _openSection == 'household',
                      onTap: () => _toggleSection('household'),
                    ),
                    if (_openSection == 'household') _buildHouseholdSection(),
                    // Notifications navigation
                    ListTile(
                      leading: Icon(Icons.notifications_outlined,
                          color: AppColors.textSecondary(context)),
                      title: Text(l10n.notifications,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(context))),
                      trailing: Icon(Icons.chevron_right,
                          color: AppColors.textMuted(context)),
                      onTap: () {
                        if (widget.onOpenNotificationSettings != null) {
                          widget.onOpenNotificationSettings!();
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Supabase.instance.client.auth.signOut();
                            if (context.mounted) {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            }
                          },
                          icon: const Icon(Icons.logout, size: 18),
                          label: Text(l10n.settingsLogout),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error(context),
                            side: const BorderSide(color: Color(0xFFFECACA)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _countryLabel(Country c, S l10n) {
    switch (c) {
      case Country.pt: return l10n.countryPT;
      case Country.es: return l10n.countryES;
      case Country.fr: return l10n.countryFR;
      case Country.uk: return l10n.countryUK;
    }
  }

  String _languageLabel(String? code, S l10n) {
    switch (code) {
      case 'pt': return l10n.langPT;
      case 'en': return l10n.langEN;
      case 'fr': return l10n.langFR;
      case 'es': return l10n.langES;
      default: return l10n.langSystem;
    }
  }

  Widget _buildAppearanceSection() {
    final l10n = S.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: AppColors.surface(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: appThemeModeNotifier,
            builder: (context, currentMode, _) {
              return SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text(l10n.themeSystem),
                    icon: const Icon(Icons.brightness_auto),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text(l10n.themeLight),
                    icon: const Icon(Icons.light_mode),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text(l10n.themeDark),
                    icon: const Icon(Icons.dark_mode),
                  ),
                ],
                selected: {currentMode},
                onSelectionChanged: (newSelection) {
                  final newMode = newSelection.first;
                  appThemeModeNotifier.value = newMode;
                  LocalConfigService().saveThemeMode(newMode);
                },
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            l10n.settingsColorPalette.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary(context),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<AppColorPalette>(
            valueListenable: appColorPaletteNotifier,
            builder: (context, currentPalette, _) {
              return Wrap(
                spacing: 16,
                runSpacing: 12,
                children: AppColorPalette.values.map((p) {
                  final isSelected = p == currentPalette;
                  final color = AppColors.primaryStatic(p, isDark);
                  return GestureDetector(
                    onTap: () {
                      appColorPaletteNotifier.value = p;
                      LocalConfigService().saveColorPalette(p);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.textPrimary(context),
                                    width: 2.5,
                                  )
                                : Border.all(
                                    color: AppColors.border(context),
                                    width: 1,
                                  ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 20,
                                  color: AppColors.primaryStatic(
                                    p,
                                    isDark,
                                  ).computeLuminance() > 0.5
                                      ? Colors.black
                                      : Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _paletteLabel(p, l10n),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.textPrimary(context)
                                : AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _paletteLabel(AppColorPalette palette, S l10n) {
    return switch (palette) {
      AppColorPalette.ocean => l10n.paletteOcean,
      AppColorPalette.emerald => l10n.paletteEmerald,
      AppColorPalette.violet => l10n.paletteViolet,
      AppColorPalette.teal => l10n.paletteTeal,
      AppColorPalette.sunset => l10n.paletteSunset,
    };
  }

  Widget _buildProfileSection() {
    final l10n = S.of(context);
    return Container(
      color: AppColors.surface(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Region content
          _label(l10n.settingsCountry),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(context)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Country>(
                value: _draft.country,
                isExpanded: true,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textLabel(context)),
                items: Country.values.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text('${_countryLabel(c, l10n)} (${c.currencySymbol})'),
                )).toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _draft = _draft.copyWith(country: v));
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          _label(l10n.settingsLanguage),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(context)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _draft.localeOverride,
                isExpanded: true,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textLabel(context)),
                items: [null, 'pt', 'en', 'fr', 'es'].map((code) => DropdownMenuItem(
                  value: code,
                  child: Text(_languageLabel(code, l10n)),
                )).toList(),
                onChanged: (v) {
                  setState(() => _draft = _draft.copyWith(localeOverride: v));
                },
              ),
            ),
          ),
          // Divider between region and personal
          const SizedBox(height: 16),
          Divider(color: AppColors.border(context)),
          const SizedBox(height: 16),
          // Personal content
          _label(l10n.settingsMaritalStatusLabel),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(context)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<MaritalStatus>(
                value: _draft.personalInfo.maritalStatus,
                isExpanded: true,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textLabel(context)),
                items: MaritalStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.localizedLabel(l10n)))).toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _draft = _draft.copyWith(personalInfo: _draft.personalInfo.copyWith(maritalStatus: v));
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          _label(l10n.settingsDependentsLabel),
          const SizedBox(height: 8),
          Row(
            children: [
              _counterButton('-', () {
                if (_draft.personalInfo.dependentes > 0) {
                  setState(() {
                    _draft = _draft.copyWith(
                      personalInfo: _draft.personalInfo.copyWith(dependentes: _draft.personalInfo.dependentes - 1),
                    );
                  });
                }
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${_draft.personalInfo.dependentes}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context)),
                ),
              ),
              _counterButton('+', () {
                setState(() {
                  _draft = _draft.copyWith(
                    personalInfo: _draft.personalInfo.copyWith(dependentes: _draft.personalInfo.dependentes + 1),
                  );
                });
              }),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.infoBackground(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryLight(context)),
            ),
            child: Text(
              l10n.settingsSocialSecurityRate(formatPercentage(getTaxSystem(_draft.country).socialContributionRate)),
              style: TextStyle(fontSize: 12, color: AppColors.primary(context)),
            ),
          ),
        ],
      ),
    );
  }

  void _addSalary() {
    setState(() {
      final newSalaries = List<SalaryInfo>.from(_draft.salaries);
      newSalaries.add(SalaryInfo(label: S.of(context).settingsSalaryN(newSalaries.length + 1)));
      _draft = _draft.copyWith(salaries: newSalaries);
    });
  }

  void _removeSalary(int idx) {
    if (_draft.salaries.length <= 1) return;
    setState(() {
      final newSalaries = List<SalaryInfo>.from(_draft.salaries)..removeAt(idx);
      _draft = _draft.copyWith(salaries: newSalaries);
    });
  }

  Widget _buildSalariesSection() {
    final l10n = S.of(context);
    return Container(
      color: AppColors.surface(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ...List.generate(_draft.salaries.length, (idx) {
            final salary = _draft.salaries[idx];
            return Container(
              margin: EdgeInsets.only(bottom: idx < _draft.salaries.length - 1 ? 16 : 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: salary.enabled ? AppColors.surface(context) : AppColors.background(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: salary.enabled ? AppColors.border(context) : AppColors.surfaceVariant(context),
                  width: 2,
                ),
              ),
              child: Opacity(
                opacity: salary.enabled ? 1.0 : 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: salary.label)
                              ..selection = TextSelection.collapsed(offset: salary.label.length),
                            onChanged: (v) => _updateSalary(idx, (s) => s.copyWith(label: v)),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textLabel(context)),
                            decoration: InputDecoration(
                              hintText: l10n.settingsSalaryN(idx + 1),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_draft.salaries.length > 1)
                          IconButton(
                            onPressed: () => _removeSalary(idx),
                            icon: Icon(Icons.remove_circle_outline, size: 18, color: AppColors.borderMuted(context)),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                        Row(
                          children: [
                            Text(l10n.settingsSalaryActive, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                            const SizedBox(width: 4),
                            Switch(
                              value: salary.enabled,
                              onChanged: (v) => _updateSalary(idx, (s) => s.copyWith(enabled: v)),
                              activeTrackColor: AppColors.primary(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _label(l10n.settingsGrossMonthlySalary),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: salary.grossAmount > 0 ? salary.grossAmount.toString() : '',
                      onChanged: (v) => _updateSalary(idx, (s) => s.copyWith(grossAmount: double.tryParse(v) ?? 0)),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration('0.00', suffix: _draft.country.currencyCode),
                    ),
                    if (_draft.country.hasSubsidies) ...[
                      const SizedBox(height: 12),
                      _label(l10n.settingsSubsidyHoliday),
                      const SizedBox(height: 8),
                      Row(
                        children: SubsidyMode.values.map((mode) {
                          final isSelected = salary.subsidyMode == mode;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: mode != SubsidyMode.half ? 6 : 0),
                              child: OutlinedButton(
                                onPressed: () => _updateSalary(idx, (s) => s.copyWith(subsidyMode: mode)),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: isSelected ? AppColors.primary(context) : AppColors.surface(context),
                                  foregroundColor: isSelected ? AppColors.onPrimary(context) : AppColors.textSecondary(context),
                                  side: BorderSide(color: isSelected ? AppColors.primary(context) : AppColors.border(context), width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                                child: Text(mode.localizedShortLabel(l10n)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _label(l10n.settingsOtherExemptLabel),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: salary.otherExemptIncome > 0 ? salary.otherExemptIncome.toString() : '',
                      onChanged: (v) => _updateSalary(idx, (s) => s.copyWith(otherExemptIncome: double.tryParse(v) ?? 0)),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration('0.00', suffix: _draft.country.currencyCode),
                    ),
                    if (_draft.country.hasMealAllowance) ...[
                      const SizedBox(height: 12),
                      _label(l10n.settingsMealAllowanceLabel),
                      const SizedBox(height: 8),
                      Row(
                        children: MealAllowanceType.values.map((type) {
                          final isSelected = salary.mealAllowanceType == type;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: type != MealAllowanceType.cash ? 6 : 0),
                              child: OutlinedButton(
                                onPressed: () => _updateSalary(idx, (s) => s.copyWith(mealAllowanceType: type)),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: isSelected ? AppColors.primary(context) : AppColors.surface(context),
                                  foregroundColor: isSelected ? AppColors.onPrimary(context) : AppColors.textSecondary(context),
                                  side: BorderSide(color: isSelected ? AppColors.primary(context) : AppColors.border(context), width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                child: Text(type.localizedLabel(l10n)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (salary.mealAllowanceType != MealAllowanceType.none) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label(l10n.settingsAmountPerDay),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    initialValue: salary.mealAllowancePerDay > 0 ? salary.mealAllowancePerDay.toString() : '',
                                    onChanged: (v) => _updateSalary(idx, (s) => s.copyWith(mealAllowancePerDay: double.tryParse(v) ?? 0)),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: _inputDecoration('0.00', suffix: _draft.country.currencyCode),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 96,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label(l10n.settingsDaysPerMonth),
                                const SizedBox(height: 4),
                                TextFormField(
                                  initialValue: salary.workingDaysPerMonth > 0 ? salary.workingDaysPerMonth.toString() : '',
                                  onChanged: (v) => _updateSalary(idx, (s) => s.copyWith(workingDaysPerMonth: int.tryParse(v) ?? 0)),
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration('22'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ],
                    ],
                    if (_draft.country.hasTitulares && _isCasado) ...[
                      const SizedBox(height: 12),
                      _label(l10n.settingsTitularesLabel),
                      const SizedBox(height: 8),
                      Row(
                        children: [1, 2].map((n) {
                          final isSelected = salary.titulares == n;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: n == 1 ? 8 : 0),
                              child: OutlinedButton(
                                onPressed: () => _updateSalary(idx, (s) => s.copyWith(titulares: n)),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: isSelected ? AppColors.primary(context) : AppColors.surface(context),
                                  foregroundColor: isSelected ? AppColors.onPrimary(context) : AppColors.textSecondary(context),
                                  side: BorderSide(color: isSelected ? AppColors.primary(context) : AppColors.border(context), width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                child: Text(l10n.settingsTitularCount(n, n > 1 ? 'es' : '')),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    if (_draft.country == Country.pt) ...[
                      const SizedBox(height: 12),
                      Builder(builder: (_) {
                        final table = getApplicableTable(
                          _draft.personalInfo.maritalStatus.jsonValue,
                          salary.titulares,
                          _draft.personalInfo.dependentes,
                        );
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.background(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${table.label} — ${table.description}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addSalary,
              icon: const Icon(Icons.add, size: 16),
              label: Text(l10n.settingsAddSalaryButton),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary(context),
                side: BorderSide(color: AppColors.primary(context)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesSection() {
    final l10n = S.of(context);
    return Container(
      color: AppColors.surface(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ..._draft.expenses.map((expense) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: expense.enabled ? AppColors.surface(context) : AppColors.background(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: expense.enabled ? AppColors.border(context) : AppColors.surfaceVariant(context),
                  width: 2,
                ),
              ),
              child: Opacity(
                opacity: expense.enabled ? 1.0 : 0.5,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Switch(
                          value: expense.enabled,
                          onChanged: (v) => _updateExpense(expense.id, (e) => e.copyWith(enabled: v)),
                          activeTrackColor: AppColors.primary(context),
                        ),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: expense.label)
                              ..selection = TextSelection.collapsed(offset: expense.label.length),
                            onChanged: (v) => _updateExpense(expense.id, (e) => e.copyWith(label: v)),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textLabel(context)),
                            decoration: InputDecoration(
                              hintText: l10n.settingsExpenseName,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeExpense(expense.id),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          color: AppColors.dragHandle(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border(context)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<ExpenseCategory>(
                                value: expense.category,
                                isExpanded: true,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textLabel(context)),
                                items: ExpenseCategory.values
                                    .map((c) => DropdownMenuItem(value: c, child: Text(c.localizedLabel(l10n))))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    _updateExpense(expense.id, (e) => e.copyWith(category: v));
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border(context)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _fixedVariableChip(
                                label: l10n.expenseFixed,
                                selected: expense.isFixed,
                                onTap: () => _updateExpense(expense.id, (e) => e.copyWith(isFixed: true)),
                              ),
                              _fixedVariableChip(
                                label: l10n.expenseVariable,
                                selected: !expense.isFixed,
                                onTap: () => _updateExpense(expense.id, (e) => e.copyWith(isFixed: false)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (expense.isFixed)
                      SizedBox(
                        width: double.infinity,
                        child: TextFormField(
                          initialValue: expense.amount > 0 ? expense.amount.toString() : '',
                          onChanged: (v) => _updateExpense(expense.id, (e) => e.copyWith(amount: double.tryParse(v) ?? 0)),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: _inputDecoration('0.00', suffix: _draft.country.currencyCode),
                        ),
                      )
                    else ...[
                      Text(
                        l10n.monthlyBudgetHint(_currentMonthLabel(l10n)),
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: TextFormField(
                          initialValue: _monthlyBudgetsDraft[expense.category.name]?.toString() ?? '',
                          onChanged: (v) {
                            final amount = double.tryParse(v) ?? 0;
                            setState(() {
                              if (amount > 0) {
                                _monthlyBudgetsDraft[expense.category.name] = amount;
                              } else {
                                _monthlyBudgetsDraft.remove(expense.category.name);
                              }
                            });
                          },
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: _inputDecoration('0.00', suffix: _draft.country.currencyCode),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          OutlinedButton.icon(
            onPressed: _addExpense,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.settingsAddExpenseButton),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade400,
              side: BorderSide(color: Colors.grey.shade200, width: 2, style: BorderStyle.solid),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 0),
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSection() {
    final l10n = S.of(context);
    return Container(
      color: AppColors.surface(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.infoBackground(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.phone_android, size: 16, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.settingsDeviceLocal,
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _label(l10n.settingsVisibleSections),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _localDashboard = LocalDashboardConfig.minimalist()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary(context),
                    side: BorderSide(color: AppColors.border(context)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(l10n.settingsMinimalist, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _localDashboard = LocalDashboardConfig.full()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary(context),
                    side: BorderSide(color: AppColors.border(context)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(l10n.settingsFull, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _groupLabel(l10n.dashGroupOverview),
          _dashToggle(l10n.settingsDashMonthlyLiquidity, _localDashboard.showHeroCard,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showHeroCard: v))),
          _dashToggle(l10n.settingsDashStressIndex, _localDashboard.showStressIndex,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showStressIndex: v))),
          _dashToggle(l10n.settingsDashMonthReview, _localDashboard.showMonthReview,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showMonthReview: v))),
          _dashToggle(l10n.settingsDashSummaryCards, _localDashboard.showSummaryCards,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showSummaryCards: v))),
          const SizedBox(height: 8),
          _groupLabel(l10n.dashGroupFinancialDetail),
          _dashToggle(l10n.settingsDashSalaryBreakdown, _localDashboard.showSalaryBreakdown,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showSalaryBreakdown: v))),
          _dashToggle(l10n.settingsDashBudgetVsActual, _localDashboard.showBudgetVsActual,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showBudgetVsActual: v))),
          _dashToggle(l10n.settingsDashExpensesBreakdown, _localDashboard.showExpensesBreakdown,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showExpensesBreakdown: v))),
          _dashToggle(l10n.savingsGoals, _localDashboard.showSavingsGoals,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showSavingsGoals: v))),
          const SizedBox(height: 8),
          _groupLabel(l10n.dashGroupHistory),
          _dashToggle(l10n.settingsDashPurchaseHistory, _localDashboard.showPurchaseHistory,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showPurchaseHistory: v))),
          const SizedBox(height: 8),
          _groupLabel(l10n.dashGroupCharts),
          _dashToggle(l10n.settingsDashCharts, _localDashboard.showCharts,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showCharts: v))),
          if (_localDashboard.showCharts) ...[
            const SizedBox(height: 16),
            _label(l10n.settingsVisibleCharts),
            const SizedBox(height: 8),
            ...ChartType.values.map((chart) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(chart.localizedLabel(l10n), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textLabel(context))),
                  value: _localDashboard.enabledCharts.contains(chart),
                  activeColor: AppColors.primary(context),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (_) {
                    final enabled = List<ChartType>.from(_localDashboard.enabledCharts);
                    if (enabled.contains(chart)) {
                      enabled.remove(chart);
                    } else {
                      enabled.add(chart);
                    }
                    setState(() => _localDashboard = _localDashboard.copyWith(enabledCharts: enabled));
                  },
                )),
          ],
        ],
      ),
    );
  }

  Widget _dashToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textLabel(context))),
      value: value,
      activeTrackColor: AppColors.primary(context),
      onChanged: onChanged,
    );
  }

  String _currentMonthLabel(S l10n) {
    final now = DateTime.now();
    return '${localizedMonthFull(l10n, now.month)} ${now.year}';
  }

  Widget _fixedVariableChip({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary(context).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.primary(context) : AppColors.textMuted(context),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesSection() {
    final l10n = S.of(context);
    // All product names from catalog, filtered by search
    final allNames = widget.products.map((p) => p.name).toList();
    final filtered = _favSearch.isEmpty
        ? allNames
        : allNames
            .where((n) =>
                n.toLowerCase().contains(_favSearch.toLowerCase()))
            .toList();

    return Container(
      color: AppColors.surface(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates,
                    size: 18, color: Color(0xFFF97316)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.settingsFavTip,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade800,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_favorites.isNotEmpty) ...[
            _label(l10n.settingsMyFavorites),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _favorites
                  .map((f) => _buildFavoriteChip(f, isSelected: true))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
          _label(l10n.settingsProductCatalog),
          const SizedBox(height: 8),
          TextField(
            onChanged: (v) => setState(() => _favSearch = v),
            decoration: _inputDecoration(l10n.settingsSearchProduct).copyWith(
              prefixIcon: Icon(Icons.search,
                  size: 18, color: AppColors.textMuted(context)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          if (widget.products.isEmpty)
            Text(l10n.settingsLoadingProducts,
                style:
                    TextStyle(fontSize: 12, color: AppColors.textMuted(context)))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filtered.map((name) {
                final isSelected = _favorites
                    .any((f) => f.toLowerCase() == name.toLowerCase());
                return _buildFavoriteChip(name, isSelected: isSelected);
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _showAddDislikedDialog() {
    final l10n = S.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsAddIngredient),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.settingsIngredientName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final ms = _draft.mealSettings;
                final updated = List<String>.from(ms.dislikedIngredients)..add(name);
                setState(() => _draft = _draft.copyWith(
                    mealSettings: ms.copyWith(dislikedIngredients: updated)));
              }
              Navigator.pop(ctx);
            },
            child: Text(l10n.settingsAddButton),
          ),
        ],
      ),
    );
  }

  void _showAddPantryDialog() {
    final l10n = S.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsAddToPantry),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.settingsIngredientName),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final ms = _draft.mealSettings;
                final updated = List<String>.from(ms.pantryIngredients)..add(name);
                setState(() => _draft = _draft.copyWith(
                    mealSettings: ms.copyWith(pantryIngredients: updated)));
              }
              Navigator.pop(ctx);
            },
            child: Text(l10n.settingsAddButton),
          ),
        ],
      ),
    );
  }

  Widget _groupLabel(String title) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.border(context)),
        const SizedBox(height: 8),
        Text(title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primary(context),
            letterSpacing: 1.0,
          ),
        ),
      ],
    ),
  );

  Widget _buildMealsSection() {
    final l10n = S.of(context);
    final ms = _draft.mealSettings;
    return Container(
      color: AppColors.surface(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Group A: AGREGADO (no divider, first group) ──
          _label(l10n.settingsHouseholdPeople),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border(context)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    initialValue: ms.householdSize?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: _autoHouseholdSize().toString(),
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      suffixText: ms.householdSize == null ? l10n.settingsAutomatic : null,
                      suffixStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    ),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    onChanged: (v) {
                      final parsed = int.tryParse(v);
                      setState(() => _draft = _draft.copyWith(
                          mealSettings: ms.copyWith(
                              householdSize: (parsed != null && parsed > 0) ? parsed : null)));
                    },
                  ),
                ),
              ),
              if (ms.householdSize != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.restart_alt, size: 20, color: AppColors.textMuted(context)),
                  tooltip: l10n.settingsUseAutoValue,
                  onPressed: () => setState(() => _draft = _draft.copyWith(
                      mealSettings: ms.copyWith(householdSize: null))),
                ),
              ],
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: Text(
              ms.householdSize != null
                  ? l10n.settingsManualValue(ms.householdSize!)
                  : l10n.settingsAutoValue(_autoHouseholdSize()),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
          ),
          _label(l10n.settingsHouseholdMembers),
          const SizedBox(height: 8),
          if (ms.householdMembers.isNotEmpty) ...[
            ...ms.householdMembers.asMap().entries.map((entry) {
              final i = entry.key;
              final m = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          Text(
                            '${m.ageGroup.localizedLabel(l10n)} \u2022 ${m.activityLevel.localizedLabel(l10n)} \u2022 ${m.portionEquivalent.toStringAsFixed(2)} ${l10n.settingsPortions}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 18, color: AppColors.error(context)),
                      onPressed: () {
                        final updated = List<HouseholdMember>.from(ms.householdMembers)..removeAt(i);
                        setState(() => _draft = _draft.copyWith(
                            mealSettings: ms.copyWith(householdMembers: updated)));
                      },
                    ),
                  ],
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.settingsTotalEquivalent(ms.householdMembers.fold(0.0, (sum, m) => sum + m.portionEquivalent).toStringAsFixed(1)),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary(context)),
              ),
            ),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAddMemberDialog(),
              icon: const Icon(Icons.person_add_outlined, size: 18),
              label: Text(l10n.settingsAddMember, style: const TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary(context),
                side: BorderSide(color: AppColors.border(context)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // ── Group B: OBJETIVO E REFEICOES ──
          _groupLabel('OBJETIVO E REFEIÇÕES'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsPreferSeasonal,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text(l10n.settingsPreferSeasonalDesc,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted(context))),
            value: ms.preferSeasonal,
            activeTrackColor: AppColors.primary(context),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(preferSeasonal: v))),
          ),
          const SizedBox(height: 16),
          _label(l10n.settingsObjective),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(context)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<MealObjective>(
                value: ms.objective,
                isExpanded: true,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLabel(context)),
                items: MealObjective.values
                    .map((o) =>
                        DropdownMenuItem(value: o, child: Text(o.localizedLabel(l10n))))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  var updated = ms.copyWith(objective: v);
                  if (v == MealObjective.vegetarian) {
                    updated = updated.copyWith(veggieDaysPerWeek: 7);
                  }
                  setState(() =>
                      _draft = _draft.copyWith(mealSettings: updated));
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          _label(l10n.settingsActiveMeals),
          const SizedBox(height: 8),
          ...MealType.values.map((mt) => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(mt.localizedLabel(l10n),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                value: ms.enabledMeals.contains(mt),
                activeTrackColor: AppColors.primary(context),
                onChanged: (v) {
                  final newSet = Set<MealType>.from(ms.enabledMeals);
                  if (v) {
                    newSet.add(mt);
                  } else {
                    newSet.remove(mt);
                  }
                  if (newSet.isEmpty) return;
                  setState(() => _draft = _draft.copyWith(
                      mealSettings: ms.copyWith(enabledMeals: newSet)));
                },
              )),
          const SizedBox(height: 16),
          _label(l10n.settingsVeggieDays),
          Slider(
            value: ms.veggieDaysPerWeek.toDouble(),
            min: 0,
            max: 7,
            divisions: 7,
            label: '${ms.veggieDaysPerWeek}',
            activeColor: AppColors.primary(context),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(veggieDaysPerWeek: v.round()))),
          ),
          const SizedBox(height: 8),
          _label(l10n.settingsEatingOutDays),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final entry in {1: l10n.wizardWeekdayMon, 2: l10n.wizardWeekdayTue, 3: l10n.wizardWeekdayWed, 4: l10n.wizardWeekdayThu, 5: l10n.wizardWeekdayFri, 6: l10n.wizardWeekdaySat, 7: l10n.wizardWeekdaySun}.entries)
                FilterChip(
                  label: Text(entry.value, style: const TextStyle(fontSize: 13)),
                  selected: ms.eatingOutWeekdays.contains(entry.key),
                  selectedColor: AppColors.primary(context).withValues(alpha: 0.15),
                  checkmarkColor: AppColors.primary(context),
                  onSelected: (v) {
                    final updated = Set<int>.from(ms.eatingOutWeekdays);
                    if (v) { updated.add(entry.key); } else { updated.remove(entry.key); }
                    setState(() => _draft = _draft.copyWith(
                        mealSettings: ms.copyWith(eatingOutWeekdays: updated)));
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          _label(l10n.settingsWeeklyDistribution),
          const SizedBox(height: 4),
          Text(l10n.settingsFishPerWeek(ms.fishDaysPerWeek == 0 ? l10n.settingsNoMinimum : '${ms.fishDaysPerWeek}'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Slider(
            value: ms.fishDaysPerWeek.toDouble(),
            min: 0, max: 5, divisions: 5,
            label: ms.fishDaysPerWeek == 0 ? l10n.settingsNoMinimum : '${ms.fishDaysPerWeek}',
            activeColor: AppColors.primary(context),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(fishDaysPerWeek: v.round()))),
          ),
          Text(l10n.settingsLegumePerWeek(ms.legumeDaysPerWeek == 0 ? l10n.settingsNoMinimum : '${ms.legumeDaysPerWeek}'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Slider(
            value: ms.legumeDaysPerWeek.toDouble(),
            min: 0, max: 5, divisions: 5,
            label: ms.legumeDaysPerWeek == 0 ? l10n.settingsNoMinimum : '${ms.legumeDaysPerWeek}',
            activeColor: AppColors.primary(context),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(legumeDaysPerWeek: v.round()))),
          ),
          Text(l10n.settingsRedMeatPerWeek(ms.redMeatMaxPerWeek >= 7 ? l10n.settingsNoLimit : '${ms.redMeatMaxPerWeek}'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Slider(
            value: ms.redMeatMaxPerWeek.toDouble(),
            min: 0, max: 7, divisions: 7,
            label: ms.redMeatMaxPerWeek >= 7 ? l10n.settingsNoLimit : '${ms.redMeatMaxPerWeek}',
            activeColor: AppColors.primary(context),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(redMeatMaxPerWeek: v.round()))),
          ),

          // ── Group C: RESTRICOES E PREFERENCIAS ──
          _groupLabel('RESTRIÇÕES E PREFERÊNCIAS'),
          _label(l10n.settingsDietaryRestrictions),
          ...[
            (l10n.wizardGlutenFree, ms.glutenFree,
                (bool v) => setState(() => _draft = _draft.copyWith(
                    mealSettings: ms.copyWith(glutenFree: v)))),
            (l10n.wizardLactoseFree, ms.lactoseFree,
                (bool v) => setState(() => _draft = _draft.copyWith(
                    mealSettings: ms.copyWith(lactoseFree: v)))),
            (l10n.wizardNutFree, ms.nutFree,
                (bool v) => setState(() => _draft = _draft.copyWith(
                    mealSettings: ms.copyWith(nutFree: v)))),
            (l10n.wizardShellfishFree, ms.shellfishFree,
                (bool v) => setState(() => _draft = _draft.copyWith(
                    mealSettings: ms.copyWith(shellfishFree: v)))),
            (l10n.settingsEggFree, ms.eggFree,
                (bool v) => setState(() => _draft = _draft.copyWith(
                    mealSettings: ms.copyWith(eggFree: v)))),
          ].map((item) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.$1,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                value: item.$2,
                activeColor: AppColors.primary(context),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) => item.$3(v ?? false),
              )),
          const SizedBox(height: 16),
          _label(l10n.settingsSodiumPref),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(context)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<SodiumPreference>(
                value: ms.sodiumPreference,
                isExpanded: true,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textLabel(context)),
                items: SodiumPreference.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.localizedLabel(l10n))))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _draft = _draft.copyWith(
                      mealSettings: ms.copyWith(sodiumPreference: v)));
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          _label(l10n.settingsDislikedIngredients),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ...ms.dislikedIngredients.map((d) => Chip(
                label: Text(d, style: const TextStyle(fontSize: 13)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  final updated = List<String>.from(ms.dislikedIngredients)..remove(d);
                  setState(() => _draft = _draft.copyWith(
                      mealSettings: ms.copyWith(dislikedIngredients: updated)));
                },
              )),
              ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: Text(l10n.settingsAddButton, style: const TextStyle(fontSize: 13)),
                onPressed: () => _showAddDislikedDialog(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _label(l10n.settingsExcludedProteins),
          const SizedBox(height: 8),
          ...{
            'frango': l10n.settingsProteinChicken,
            'carne_picada': l10n.settingsProteinGroundMeat,
            'porco': l10n.settingsProteinPork,
            'pescada': l10n.settingsProteinHake,
            'bacalhau': l10n.settingsProteinCod,
            'sardinha': l10n.settingsProteinSardine,
            'atum_lata': l10n.settingsProteinTuna,
            'ovo': l10n.settingsProteinEgg,
          }.entries.map((entry) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(entry.value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                value: ms.excludedProteins.contains(entry.key),
                activeColor: AppColors.primary(context),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) {
                  final updated = List<String>.from(ms.excludedProteins);
                  if (v == true) {
                    updated.add(entry.key);
                  } else {
                    updated.remove(entry.key);
                  }
                  setState(() => _draft = _draft.copyWith(
                      mealSettings: ms.copyWith(excludedProteins: updated)));
                },
              )),

          // ── Group D: NUTRICAO E SAUDE ──
          _groupLabel('NUTRIÇÃO E SAÚDE'),
          _label(l10n.settingsNutritionalGoals),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: ms.dailyCalorieTarget?.toString() ?? '',
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(l10n.settingsCalorieHint, suffix: l10n.settingsKcalPerDay).copyWith(
              suffixIcon: ms.dailyCalorieTarget != null
                  ? IconButton(
                      icon: Icon(Icons.close, size: 18, color: AppColors.textMuted(context)),
                      onPressed: () => setState(() => _draft = _draft.copyWith(
                          mealSettings: ms.copyWith(dailyCalorieTarget: null))),
                    )
                  : null,
            ),
            onChanged: (v) {
              final parsed = int.tryParse(v);
              setState(() => _draft = _draft.copyWith(
                  mealSettings: ms.copyWith(
                      dailyCalorieTarget: (parsed != null && parsed > 0) ? parsed : null)));
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: ms.dailyProteinTargetG?.toString() ?? '',
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(l10n.settingsProteinHint, suffix: l10n.settingsGramsPerDay).copyWith(
              labelText: l10n.settingsDailyProtein,
              labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              suffixIcon: ms.dailyProteinTargetG != null
                  ? IconButton(
                      icon: Icon(Icons.close, size: 18, color: AppColors.textMuted(context)),
                      onPressed: () => setState(() => _draft = _draft.copyWith(
                          mealSettings: ms.copyWith(dailyProteinTargetG: null))),
                    )
                  : null,
            ),
            onChanged: (v) {
              final parsed = int.tryParse(v);
              setState(() => _draft = _draft.copyWith(
                  mealSettings: ms.copyWith(
                      dailyProteinTargetG: (parsed != null && parsed > 0) ? parsed : null)));
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: ms.dailyFiberTargetG?.toString() ?? '',
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(l10n.settingsFiberHint, suffix: l10n.settingsGramsPerDay).copyWith(
              labelText: l10n.settingsDailyFiber,
              labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              suffixIcon: ms.dailyFiberTargetG != null
                  ? IconButton(
                      icon: Icon(Icons.close, size: 18, color: AppColors.textMuted(context)),
                      onPressed: () => setState(() => _draft = _draft.copyWith(
                          mealSettings: ms.copyWith(dailyFiberTargetG: null))),
                    )
                  : null,
            ),
            onChanged: (v) {
              final parsed = int.tryParse(v);
              setState(() => _draft = _draft.copyWith(
                  mealSettings: ms.copyWith(
                      dailyFiberTargetG: (parsed != null && parsed > 0) ? parsed : null)));
            },
          ),
          const SizedBox(height: 16),
          _label(l10n.settingsMedicalConditions),
          const SizedBox(height: 8),
          ...MedicalCondition.values.map((mc) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(mc.localizedLabel(l10n),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                value: ms.medicalConditions.contains(mc),
                activeColor: AppColors.primary(context),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) {
                  final updated = Set<MedicalCondition>.from(ms.medicalConditions);
                  if (v == true) {
                    updated.add(mc);
                  } else {
                    updated.remove(mc);
                  }
                  setState(() => _draft = _draft.copyWith(
                      mealSettings: ms.copyWith(medicalConditions: updated)));
                },
              )),

          // ── Group E: PREPARACAO E COZINHA ──
          _groupLabel('PREPARAÇÃO E COZINHA'),
          _label(l10n.settingsMaxPrepTime),
          Slider(
            value: ms.maxPrepMinutes.toDouble(),
            min: 15,
            max: 60,
            divisions: 3,
            label: ms.maxPrepMinutes == 60 ? '60+' : '${ms.maxPrepMinutes}',
            activeColor: AppColors.primary(context),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(maxPrepMinutes: v.round()))),
          ),
          _label(l10n.settingsMaxComplexity(ms.maxComplexity)),
          Slider(
            value: ms.maxComplexity.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: '${ms.maxComplexity}',
            activeColor: AppColors.primary(context),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(maxComplexity: v.round()))),
          ),
          const SizedBox(height: 8),
          _label(l10n.settingsWeekendPrepTime),
          Slider(
            value: ms.maxPrepMinutesWeekend.toDouble(),
            min: 15,
            max: 120,
            divisions: 7,
            label: ms.maxPrepMinutesWeekend >= 120 ? '120+' : '${ms.maxPrepMinutesWeekend}',
            activeColor: AppColors.primary(context),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(maxPrepMinutesWeekend: v.round()))),
          ),
          _label(l10n.settingsWeekendComplexity(ms.maxComplexityWeekend)),
          Slider(
            value: ms.maxComplexityWeekend.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: '${ms.maxComplexityWeekend}',
            activeColor: AppColors.primary(context),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(maxComplexityWeekend: v.round()))),
          ),
          const SizedBox(height: 8),
          _label(l10n.settingsAvailableEquipment),
          ...KitchenEquipment.values.map((eq) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(eq.localizedLabel(l10n),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                value: ms.availableEquipment.contains(eq),
                activeColor: AppColors.primary(context),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) {
                  final updated =
                      Set<KitchenEquipment>.from(ms.availableEquipment);
                  if (v == true) {
                    updated.add(eq);
                  } else {
                    updated.remove(eq);
                  }
                  setState(() => _draft = _draft.copyWith(
                      mealSettings: ms.copyWith(availableEquipment: updated)));
                },
              )),

          // ── Group F: EFICIENCIA E CUSTOS ──
          _groupLabel('EFICIÊNCIA E CUSTOS'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsBatchCooking,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            value: ms.batchCookingEnabled,
            activeTrackColor: AppColors.primary(context),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(batchCookingEnabled: v))),
          ),
          if (ms.batchCookingEnabled) ...[
            _label(l10n.settingsMaxBatchDays),
            Slider(
              value: ms.maxBatchDays.toDouble(),
              min: 1,
              max: 4,
              divisions: 3,
              label: '${ms.maxBatchDays}',
              activeColor: AppColors.primary(context),
              onChanged: (v) => setState(() => _draft = _draft.copyWith(
                  mealSettings: ms.copyWith(maxBatchDays: v.round()))),
            ),
          ],
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsReuseLeftovers,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            value: ms.reuseLeftovers,
            activeTrackColor: AppColors.primary(context),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(reuseLeftovers: v))),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsMinimizeWaste,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            value: ms.minimizeWaste,
            activeTrackColor: AppColors.primary(context),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(minimizeWaste: v))),
          ),
          if (ms.minimizeWaste) ...[
            _label(l10n.settingsNewIngredientsPerWeek(ms.maxNewIngredientsPerWeek)),
            Slider(
              value: ms.maxNewIngredientsPerWeek.toDouble(),
              min: 3,
              max: 10,
              divisions: 7,
              label: ms.maxNewIngredientsPerWeek == 10 ? l10n.settingsNoLimit : '${ms.maxNewIngredientsPerWeek}',
              activeColor: AppColors.primary(context),
              onChanged: (v) => setState(() => _draft = _draft.copyWith(
                  mealSettings: ms.copyWith(maxNewIngredientsPerWeek: v.round()))),
            ),
          ],
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsPrioritizeLowCost,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text(l10n.settingsPrioritizeLowCostDesc,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted(context))),
            value: ms.prioritizeLowCost,
            activeTrackColor: AppColors.primary(context),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(prioritizeLowCost: v))),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsLunchboxLunches,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text(l10n.settingsLunchboxLunchesDesc,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted(context))),
            value: ms.lunchboxLunches,
            activeTrackColor: AppColors.primary(context),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(lunchboxLunches: v))),
          ),
          const SizedBox(height: 16),
          _label(l10n.settingsPantry),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ...ms.pantryIngredients.map((p) => Chip(
                label: Text(p, style: const TextStyle(fontSize: 13)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  final updated = List<String>.from(ms.pantryIngredients)..remove(p);
                  setState(() => _draft = _draft.copyWith(
                      mealSettings: ms.copyWith(pantryIngredients: updated)));
                },
              )),
              ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: Text(l10n.settingsAddButton, style: const TextStyle(fontSize: 13)),
                onPressed: () => _showAddPantryDialog(),
              ),
            ],
          ),

          // ── Group G: ASSISTENTE ──
          _groupLabel('ASSISTENTE'),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _draft = _draft.copyWith(
                  mealSettings: ms.copyWith(wizardCompleted: false))),
              icon: const Icon(Icons.restart_alt, size: 18),
              label: Text(l10n.settingsResetWizard),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary(context),
                side: BorderSide(color: AppColors.border(context)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachSection() {
    final l10n = S.of(context);
    final hasKey = _apiKeyController.text.trim().isNotEmpty;
    return Container(
      color: AppColors.surface(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(l10n.settingsApiKey),
          const SizedBox(height: 8),
          TextField(
            controller: _apiKeyController,
            obscureText: true,
            onChanged: (_) => setState(() {}),
            decoration: _inputDecoration('sk-...').copyWith(
              hintText: 'sk-...',
              suffixIcon: hasKey
                  ? Icon(Icons.check_circle, color: AppColors.success(context), size: 20)
                  : Icon(Icons.key_outlined, color: AppColors.borderMuted(context), size: 20),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.settingsApiKeyInfo,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted(context), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteChip(String label, {required bool isSelected}) {
    final l10n = S.of(context);
    return Semantics(
      button: true,
      label: isSelected ? l10n.wizardSelected(label) : label,
      child: Material(
      color: isSelected ? AppColors.error(context).withValues(alpha: 0.08) : AppColors.surface(context),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
      onTap: () => _toggleFavorite(label),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.error(context).withValues(alpha: 0.4) : AppColors.border(context),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.favorite : Icons.favorite_border,
              size: 14,
              color: isSelected ? AppColors.error(context) : AppColors.borderMuted(context),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.error(context) : AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    ),
    ),
    );
  }

  Widget _buildHouseholdSection() {
    final l10n = S.of(context);
    return Container(
      color: AppColors.surface(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(l10n.settingsInviteCodeLabel),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.link, color: AppColors.primary(context)),
            title: Text(l10n.settingsGenerateInvite),
            subtitle: _inviteCode != null
                ? SelectableText(
                    _inviteCode!,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                        color: AppColors.textPrimary(context)),
                  )
                : Text(l10n.settingsShareWithMembers),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.settingsNewCode,
              onPressed: _generateInvite,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.settingsCodeValidInfo,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted(context), height: 1.5),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog() {
    final l10n = S.of(context);
    String name = '';
    AgeGroup ageGroup = AgeGroup.adult;
    ActivityLevel activityLevel = ActivityLevel.moderate;
    final ms = _draft.mealSettings;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.settingsAddMember),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: l10n.settingsName),
                onChanged: (v) => name = v,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AgeGroup>(
                initialValue: ageGroup,
                decoration: InputDecoration(labelText: l10n.settingsAgeGroup),
                items: AgeGroup.values.map((a) =>
                  DropdownMenuItem(value: a, child: Text(a.localizedLabel(l10n)))).toList(),
                onChanged: (v) { if (v != null) ageGroup = v; },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ActivityLevel>(
                initialValue: activityLevel,
                decoration: InputDecoration(labelText: l10n.settingsActivityLevel),
                items: ActivityLevel.values.map((a) =>
                  DropdownMenuItem(value: a, child: Text(a.localizedLabel(l10n)))).toList(),
                onChanged: (v) { if (v != null) activityLevel = v; },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () {
                if (name.trim().isEmpty) return;
                final member = HouseholdMember(name: name.trim(), ageGroup: ageGroup, activityLevel: activityLevel);
                final updated = [...ms.householdMembers, member];
                setState(() => _draft = _draft.copyWith(
                  mealSettings: ms.copyWith(householdMembers: updated)));
                Navigator.pop(ctx);
              },
              child: Text(l10n.settingsAddButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 1.2),
      );

  Widget _counterButton(String text, VoidCallback onTap) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border(context), width: 2),
            ),
            child: Center(
              child: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textSecondary(context))),
            ),
          ),
        ),
      );

  InputDecoration _inputDecoration(String hint, {String? suffix}) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.dragHandle(context)),
        suffixText: suffix,
        suffixStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade400),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border(context))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border(context))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary(context), width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        isDense: true,
      );
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isOpen;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isOpen ? AppColors.background(context) : AppColors.surface(context),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.surfaceVariant(context)))),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary(context)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textLabel(context))),
                    if (subtitle != null)
                      Text(subtitle!, style: TextStyle(fontSize: 11, color: AppColors.textMuted(context))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isOpen ? AppColors.infoBackground(context) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 16,
                  color: isOpen ? AppColors.primary(context) : AppColors.dragHandle(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
