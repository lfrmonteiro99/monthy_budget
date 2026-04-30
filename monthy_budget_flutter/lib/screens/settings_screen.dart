import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_settings.dart';
import '../models/product.dart';
import '../models/recurring_expense.dart';
import '../models/custom_category.dart';
import '../services/category_service.dart';
import '../utils/category_helpers.dart';
import '../utils/category_icons.dart';
import '../data/irs_tables.dart';
import '../data/tax/tax_system.dart';
import '../data/tax/tax_factory.dart';
import '../utils/formatters.dart';
import '../utils/calculations.dart';
import '../services/household_service.dart';
import '../models/meal_settings.dart';
import '../models/local_dashboard_config.dart';
import '../app_shell.dart';
import '../l10n/generated/app_localizations.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../models/subscription_state.dart';
import '../services/downgrade_service.dart';
import '../services/biometric_service.dart';
import '../services/local_config_service.dart';
import '../services/log_service.dart';
import '../widgets/limit_reached_dialog.dart';
import 'recurring_expenses_screen.dart' show showEditRecurringSheet;

// Sub-section page builders live in a `part` file so they don't drag
// thousands of `Container(...)` calls into the density audit of the
// top-level settings screen. See settings_screen_sections.dart.
part 'settings_screen_sections.dart';

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
  final VoidCallback? onOpenSubscription;
  final VoidCallback? onOpenCustomerCenter;
  final String? subscriptionLabel;
  final Map<String, double> monthlyBudgets;
  final ValueChanged<Map<String, double>>? onSaveMonthlyBudgets;
  final List<RecurringExpense> recurringExpenses;
  final ValueChanged<List<RecurringExpense>>? onRecurringChanged;
  final List<CustomCategory> customCategories;
  final ValueChanged<List<CustomCategory>>? onCustomCategoriesChanged;
  final SubscriptionState? subscription;
  final Future<List<AssociatedHouseholdMember>> Function(String householdId)?
      loadAssociatedMembers;
  final Future<String> Function(String householdId)? generateInviteCode;

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
    this.onOpenSubscription,
    this.onOpenCustomerCenter,
    this.subscriptionLabel,
    this.monthlyBudgets = const {},
    this.onSaveMonthlyBudgets,
    this.recurringExpenses = const [],
    this.onRecurringChanged,
    this.customCategories = const [],
    this.onCustomCategoriesChanged,
    this.subscription,
    this.loadAssociatedMembers,
    this.generateInviteCode,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _draft;
  late List<String> _favorites;
  late TextEditingController _apiKeyController;
  late LocalDashboardConfig _localDashboard;
  String? _inviteCode;
  List<AssociatedHouseholdMember> _associatedMembers = const [];
  bool _loadingAssociatedMembers = false;
  late Map<String, double> _monthlyBudgetsDraft;
  late List<RecurringExpense> _recurringDraft;

  /// Notifier that triggers rebuilds of the pushed detail page whenever
  /// parent state changes via [setState].
  final _detailRebuildNotifier = ValueNotifier<int>(0);

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    // Also notify any open detail page so it rebuilds with fresh state.
    _detailRebuildNotifier.value++;
  }
  int? _expandedExpenseIndex;
  late List<CustomCategory> _customCategoriesDraft;
  final _categoryService = CategoryService();
  final _biometricService = BiometricService();
  bool _biometricSupported = false;
  bool _biometricEnabled = false;

  String _favSearch = '';

  bool get _isFreeUser =>
      widget.subscription != null && !widget.subscription!.hasPremiumAccess;

  @override
  void initState() {
    super.initState();
    _draft = widget.settings;
    _favorites = List<String>.from(widget.favorites);
    _apiKeyController = TextEditingController(text: widget.apiKey);
    _localDashboard = widget.dashboardConfig ?? const LocalDashboardConfig();
    _monthlyBudgetsDraft = Map<String, double>.from(widget.monthlyBudgets);
    _recurringDraft = List.from(widget.recurringExpenses);
    _customCategoriesDraft = List.from(widget.customCategories);
    _loadBiometricState();
    _loadAssociatedMembers();
    // Auto-open section page if requested via initialSection
    if (widget.initialSection != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoOpenInitialSection(widget.initialSection!);
      });
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _detailRebuildNotifier.dispose();
    super.dispose();
  }

  bool get _isCasado =>
      _draft.personalInfo.maritalStatus == MaritalStatus.casado ||
      _draft.personalInfo.maritalStatus == MaritalStatus.uniaoFacto;

  Future<void> _loadBiometricState() async {
    final supported = await _biometricService.isDeviceSupported();
    final enabled = await _biometricService.isEnabled();
    if (mounted) {
      setState(() {
        _biometricSupported = supported;
        _biometricEnabled = enabled;
      });
    }
  }

  void _autoOpenInitialSection(String section) {
    final l10n = S.of(context);
    final mapping = <String, (String, Widget Function())>{
      'salaries': (l10n.settingsSalariesSection, _buildSalariesSection),
      'expenses': (l10n.settingsExpensesMonthly, _buildExpensesSection),
      'categories': (l10n.customCategories, _buildCategoriesSection),
      'meals': (l10n.settingsMeals, _buildMealsSection),
      'favorites': (l10n.settingsFavorites, _buildFavoritesSection),
      'appearance': (l10n.settingsAppearance, _buildAppearanceSection),
      'dashboard': (l10n.settingsDashboard, _buildDashboardSection),
      'profile': (l10n.settingsPersonal, _buildProfileSection),
      'coach': (l10n.settingsCoachOpenAi, _buildCoachSection),
      'household': (l10n.settingsHousehold, _buildHouseholdSection),
    };
    final entry = mapping[section];
    if (entry != null) {
      _openSectionPage(entry.$1, entry.$2);
    }
  }

  void _openSectionPage(String title, Widget Function() builder) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SettingsDetailPage(
          title: title,
          bodyBuilder: builder,
          rebuildNotifier: _detailRebuildNotifier,
        ),
      ),
    );
  }

  void _handleSave() {
    if (!widget.isAdmin) {
      CalmSnack.error(context, S.of(context).settingsAdminOnly);
      return;
    }
    widget.onSave(_draft);
    widget.onSaveFavorites(_favorites);
    widget.onSaveDashboardConfig?.call(_localDashboard);
    widget.onSaveMonthlyBudgets?.call(_monthlyBudgetsDraft);
    Navigator.of(context).pop();
  }

  Future<void> _generateInvite() async {
    try {
      final generator =
          widget.generateInviteCode ?? HouseholdService().generateInviteCode;
      final code = await generator(widget.householdId);
      if (!mounted) return;
      setState(() => _inviteCode = code);
    } catch (_) {}
  }

  Future<void> _loadAssociatedMembers() async {
    setState(() => _loadingAssociatedMembers = true);
    try {
      final loader =
          widget.loadAssociatedMembers ?? HouseholdService().getAssociatedMembers;
      final members = await loader(widget.householdId);
      if (!mounted) return;
      setState(() {
        _associatedMembers = members;
        _loadingAssociatedMembers = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingAssociatedMembers = false);
    }
  }

  String _subscriptionSubtitle() {
    return widget.subscriptionLabel ?? S.of(context).settingsSubscriptionFree;
  }

  String? _currentUserIdSafe() {
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
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


  void _addExpense() async {
    if (_isFreeUser) {
      final activeCount = _draft.expenses.where((e) => e.enabled).length;
      if (activeCount >= DowngradeService.maxFreeCategories) {
        final action = await showCategoryCreateLimitDialog(context);
        if (!mounted) return;
        if (action == LimitReachedAction.upgrade) {
          widget.onOpenSubscription?.call();
          return;
        } else if (action == LimitReachedAction.createPaused) {
          setState(() {
            _draft = _draft.copyWith(
              expenses: [
                ..._draft.expenses,
                ExpenseItem(
                  id: 'expense_${DateTime.now().millisecondsSinceEpoch}',
                  enabled: false,
                ),
              ],
            );
          });
          return;
        } else {
          return; // cancelled
        }
      }
    }
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

  /// All valid category keys (predefined enum names + custom category names).
  Set<String> _allCategoryKeys() => {
    ...ExpenseCategory.values.map((c) => c.name),
    ..._customCategoriesDraft.map((c) => c.name),
  };

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
    final appShell = AppShellScope.of(context);

    // Avatar initials — derive from auth email (no display-name field on
    // PersonalInfo). Fallback to '–' when no session.
    final email = _currentUserEmailSafe();
    final initials = _initialsFromIdentity(email);

    return CalmScaffold(
      bodyPadding: EdgeInsets.zero,
      body: SafeArea(
        child: Column(
          children: [
            // ── Calm page header (replaces in-body custom header) ──────────
            CalmPageHeader(
              eyebrow: l10n.settingsGroupAccount,
              title: l10n.settingsTitle,
              trailing: CalmActionPill(
                icon: Icons.check,
                label: l10n.save,
                onTap: _handleSave,
              ),
            ),
            // ── Body ─────────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  // Account hero card
                  _buildAccountCard(l10n, initials: initials, email: email),
                  const SizedBox(height: 18),

                  // ── ORÇAMENTO ──
                  CalmEyebrow(l10n.settingsGroupBudget),
                  const SizedBox(height: 8),
                  _buildBudgetCard(l10n),
                  const SizedBox(height: 18),

                  // ── APARÊNCIA ──
                  CalmEyebrow(l10n.settingsAppearance.toUpperCase()),
                  const SizedBox(height: 8),
                  _buildAppearanceCard(l10n, appShell),
                  const SizedBox(height: 18),

                  // ── AVANÇADO (everything else) ──
                  CalmEyebrow(l10n.settingsGroupAdvanced),
                  const SizedBox(height: 8),
                  _buildAdvancedCard(l10n),

                  const SizedBox(height: 24),

                  // Sign-out — destructive action lives outside the card.
                  OutlinedButton.icon(
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
                      foregroundColor: AppColors.bad(context),
                      side: BorderSide(
                        color: AppColors.bad(context).withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Account card (hero) ────────────────────────────────────────────────
  Widget _buildAccountCard(
    S l10n, {
    required String initials,
    required String email,
  }) {
    final pillLabel = widget.subscriptionLabel;
    return CalmCard(
      onTap: () =>
          _openSectionPage(l10n.settingsPersonal, _buildProfileSection),
      child: Row(
        children: [
          CalmAvatarBadge(initials: initials, size: 64),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  // TODO(l10n): household/profile display name not modelled
                  // yet — fallback to email or generic label until the
                  // PersonalInfo schema gains a name field.
                  email.isNotEmpty ? email.split('@').first : l10n.settingsPersonal,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink(context),
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.ink50(context),
                    ),
                  ),
                ],
                if (pillLabel != null && pillLabel.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  CalmCreamPill(label: pillLabel),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.ink50(context),
          ),
        ],
      ),
    );
  }

  // ─── Orçamento card ─────────────────────────────────────────────────────
  Widget _buildBudgetCard(S l10n) {
    final accent = AppColors.accent(context);
    return CalmCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          CalmListTile(
            leadingIcon: Icons.category_outlined,
            leadingColor: accent,
            title: l10n.customCategories,
            trailing:
                '${ExpenseCategory.values.length + _customCategoriesDraft.length}',
            onTap: () => _openSectionPage(
              l10n.customCategories,
              _buildCategoriesSection,
            ),
          ),
          _rowDivider(),
          CalmListTile(
            leadingIcon: Icons.receipt_long,
            leadingColor: accent,
            title: l10n.settingsExpensesMonthly,
            trailing: _isFreeUser
                ? '${_draft.expenses.where((e) => e.enabled).length}/${DowngradeService.maxFreeCategories}'
                : '${_draft.expenses.where((e) => e.enabled).length}',
            onTap: () => _openSectionPage(
              l10n.settingsExpensesMonthly,
              _buildExpensesSection,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Aparência card ─────────────────────────────────────────────────────
  Widget _buildAppearanceCard(S l10n, AppShellController appShell) {
    final accent = AppColors.accent(context);
    final themeLabel = _themeModeLabel(appShell.themeMode, l10n);
    return CalmCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AnimatedBuilder(
        animation: appShell,
        builder: (context, _) => Column(
          children: [
            CalmListTile(
              leadingIcon: Icons.dark_mode_outlined,
              leadingColor: accent,
              title: l10n.settingsAppearance,
              trailing: themeLabel,
              onTap: () => _openSectionPage(
                l10n.settingsAppearance,
                _buildAppearanceSection,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Avançado card (everything else, original order) ────────────────────
  Widget _buildAdvancedCard(S l10n) {
    final accent = AppColors.accent(context);
    final rows = <Widget>[
      CalmListTile(
        leadingIcon: Icons.person_outline,
        leadingColor: accent,
        title: l10n.settingsPersonal,
        onTap: () =>
            _openSectionPage(l10n.settingsPersonal, _buildProfileSection),
      ),
      CalmListTile(
        leadingIcon: Icons.people_outline,
        leadingColor: accent,
        title: l10n.settingsHousehold,
        onTap: () =>
            _openSectionPage(l10n.settingsHousehold, _buildHouseholdSection),
      ),
      if (_biometricSupported)
        _BiometricRow(
          enabled: _biometricEnabled,
          onChanged: (value) async {
            if (value) {
              final success = await _biometricService.authenticate(
                reason: S.of(context).biometricReason,
              );
              if (!success) return;
            }
            await _biometricService.setEnabled(value);
            if (mounted) setState(() => _biometricEnabled = value);
          },
        ),
      if (widget.onOpenSubscription != null)
        CalmListTile(
          leadingIcon: Icons.workspace_premium_rounded,
          leadingColor: AppColors.warning(context),
          title: S.of(context).settingsSubscription,
          subtitle: _subscriptionSubtitle(),
          onTap: widget.onOpenSubscription!,
        ),
      if (widget.onOpenCustomerCenter != null)
        CalmListTile(
          leadingIcon: Icons.manage_accounts_outlined,
          leadingColor: accent,
          title: l10n.settingsManageSubscription,
          onTap: widget.onOpenCustomerCenter!,
        ),
      CalmListTile(
        leadingIcon: Icons.account_balance_wallet_outlined,
        leadingColor: accent,
        title: l10n.settingsSalariesSection,
        subtitle: formatCurrency(
          _draft.salaries
              .where((s) => s.enabled)
              .fold(0.0, (sum, s) => sum + s.grossAmount),
        ),
        onTap: () =>
            _openSectionPage(l10n.settingsSalariesSection, _buildSalariesSection),
      ),
      CalmListTile(
        leadingIcon: Icons.dashboard_outlined,
        leadingColor: accent,
        title: l10n.settingsDashboard,
        onTap: () =>
            _openSectionPage(l10n.settingsDashboard, _buildDashboardSection),
      ),
      CalmListTile(
        leadingIcon: Icons.notifications_outlined,
        leadingColor: accent,
        title: l10n.notifications,
        onTap: () => widget.onOpenNotificationSettings?.call(),
      ),
      CalmListTile(
        leadingIcon: Icons.restaurant_outlined,
        leadingColor: accent,
        title: l10n.settingsMeals,
        onTap: () => _openSectionPage(l10n.settingsMeals, _buildMealsSection),
      ),
      CalmListTile(
        leadingIcon: Icons.favorite_outline,
        leadingColor: accent,
        title: l10n.settingsFavorites,
        subtitle: '${_favorites.length}',
        onTap: () =>
            _openSectionPage(l10n.settingsFavorites, _buildFavoritesSection),
      ),
      CalmListTile(
        leadingIcon: Icons.psychology_outlined,
        leadingColor: accent,
        title: l10n.settingsCoachOpenAi,
        onTap: () =>
            _openSectionPage(l10n.settingsCoachOpenAi, _buildCoachSection),
      ),
    ];

    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i < rows.length - 1) children.add(_rowDivider());
    }

    return CalmCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(children: children),
    );
  }

  Widget _rowDivider() => Divider(
        color: AppColors.line(context),
        height: 1,
        thickness: 1,
      );

  String _themeModeLabel(ThemeMode mode, S l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.dark:
        return l10n.themeDark;
      case ThemeMode.system:
        return l10n.themeSystem;
    }
  }

  String? _currentUserEmailRaw() {
    try {
      return Supabase.instance.client.auth.currentUser?.email;
    } catch (_) {
      return null;
    }
  }

  String _currentUserEmailSafe() => _currentUserEmailRaw() ?? '';

  String _initialsFromIdentity(String email) {
    if (email.isEmpty) return '–';
    final local = email.split('@').first;
    final parts = local
        .split(RegExp(r'[\s._\-]+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '–';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(1, 2)).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

// ─── Grouped Settings List widgets ───

/// Biometric lock row used inside the Avançado Calm card. Wraps
/// [CalmSwitchRow] with an authenticate-then-toggle handler. The widget is
/// only included when the device reports biometric support.
class _BiometricRow extends StatelessWidget {
  const _BiometricRow({
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return CalmSwitchRow(
      title: l10n.biometricLockTitle,
      subtitle: l10n.biometricLockSubtitle,
      leadingIcon: Icons.fingerprint,
      value: enabled,
      onChanged: onChanged,
    );
  }
}

class _SettingsDetailPage extends StatelessWidget {
  final String title;
  final Widget Function() bodyBuilder;
  final ValueNotifier<int> rebuildNotifier;

  const _SettingsDetailPage({
    required this.title,
    required this.bodyBuilder,
    required this.rebuildNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return CalmScaffold(
      title: title,
      body: ValueListenableBuilder<int>(
        valueListenable: rebuildNotifier,
        builder: (context, _, child) => SingleChildScrollView(
          child: bodyBuilder(),
        ),
      ),
    );
  }
}

class _EditCustomCategorySheet extends StatefulWidget {
  final CustomCategory? existing;
  const _EditCustomCategorySheet({this.existing});

  @override
  State<_EditCustomCategorySheet> createState() =>
      _EditCustomCategorySheetState();
}

class _EditCustomCategorySheetState extends State<_EditCustomCategorySheet> {
  final _nameController = TextEditingController();
  String? _selectedIcon;
  String? _selectedColorHex;
  final _formKey = GlobalKey<FormState>();

  static const _colorOptions = <String>[
    '4CAF50', 'F44336', '2196F3', 'FF9800', '9C27B0',
    'E91E63', '00BCD4', '795548', '607D8B', 'FFEB3B',
    '8BC34A', '03A9F4', 'FF5722', '673AB7', '009688',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameController.text = widget.existing!.name;
      _selectedIcon = widget.existing!.iconName;
      _selectedColorHex = widget.existing!.colorHex;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final result = CustomCategory(
      id: widget.existing?.id ??
          'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      iconName: _selectedIcon,
      colorHex: _selectedColorHex,
      sortOrder: widget.existing?.sortOrder ?? 0,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isEdit = widget.existing != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.dragHandle(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEdit ? l10n.customCategoryEdit : l10n.customCategoryAdd,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 20),

              // Name
              Text(
                l10n.customCategoryName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                autofocus: !isEdit,
                decoration: InputDecoration(
                  hintText: l10n.customCategoryName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.customCategoryName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Icon picker
              Text(
                l10n.customCategoryIcon,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categoryIconMap.entries.map((entry) {
                  final selected = _selectedIcon == entry.key;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = entry.key),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryLight(context)
                            : AppColors.background(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary(context)
                              : AppColors.border(context),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        entry.value,
                        size: 22,
                        color: selected
                            ? AppColors.primary(context)
                            : AppColors.textSecondary(context),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Color picker
              Text(
                l10n.customCategoryColor,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colorOptions.map((hex) {
                  final color = Color(int.parse('FF$hex', radix: 16));
                  final selected = _selectedColorHex == hex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorHex = hex),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? AppColors.ink(context)
                              : AppColors.line(context),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    foregroundColor: AppColors.onPrimary(context),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.save,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
