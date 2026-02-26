import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_settings.dart';
import '../models/product.dart';
import '../data/irs_tables.dart';
import '../utils/formatters.dart';
import '../services/household_service.dart';
import '../models/meal_settings.dart';
import '../models/local_dashboard_config.dart';

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
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _draft;
  late List<String> _favorites;
  late TextEditingController _apiKeyController;
  String? _openSection = 'personal';
  late LocalDashboardConfig _localDashboard;
  String? _inviteCode;

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
        const SnackBar(
            content: Text(
                'Apenas o administrador pode alterar as definições.')),
      );
      return;
    }
    widget.onSave(_draft);
    widget.onSaveFavorites(_favorites);
    widget.onSaveApiKey(_apiKeyController.text.trim());
    widget.onSaveDashboardConfig?.call(_localDashboard);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF475569)),
                  ),
                  const Expanded(
                    child: Text(
                      'Definições',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B), letterSpacing: -0.3),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _handleSave,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            // Body
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _SectionHeader(
                      icon: Icons.person,
                      title: 'Dados Pessoais',
                      isOpen: _openSection == 'personal',
                      onTap: () => _toggleSection('personal'),
                    ),
                    if (_openSection == 'personal') _buildPersonalSection(),
                    _SectionHeader(
                      icon: Icons.account_balance_wallet,
                      title: 'Vencimentos',
                      isOpen: _openSection == 'salaries',
                      onTap: () => _toggleSection('salaries'),
                    ),
                    if (_openSection == 'salaries') _buildSalariesSection(),
                    _SectionHeader(
                      icon: Icons.receipt_long,
                      title: 'Despesas Mensais',
                      isOpen: _openSection == 'expenses',
                      onTap: () => _toggleSection('expenses'),
                    ),
                    if (_openSection == 'expenses') _buildExpensesSection(),
                    _SectionHeader(
                      icon: Icons.dashboard,
                      title: 'Dashboard',
                      isOpen: _openSection == 'dashboard',
                      onTap: () => _toggleSection('dashboard'),
                    ),
                    if (_openSection == 'dashboard') _buildDashboardSection(),
                    _SectionHeader(
                      icon: Icons.favorite,
                      title: 'Produtos Favoritos',
                      isOpen: _openSection == 'favorites',
                      onTap: () => _toggleSection('favorites'),
                    ),
                    if (_openSection == 'favorites') _buildFavoritesSection(),
                    _SectionHeader(
                      icon: Icons.restaurant,
                      title: 'Refeições',
                      isOpen: _openSection == 'meals',
                      onTap: () => _toggleSection('meals'),
                    ),
                    if (_openSection == 'meals') _buildMealsSection(),
                    _SectionHeader(
                      icon: Icons.psychology_outlined,
                      title: 'Coach IA (OpenAI)',
                      isOpen: _openSection == 'coach',
                      onTap: () => _toggleSection('coach'),
                    ),
                    if (_openSection == 'coach') _buildCoachSection(),
                    _SectionHeader(
                      icon: Icons.people_outline,
                      title: 'Agregado',
                      isOpen: _openSection == 'household',
                      onTap: () => _toggleSection('household'),
                    ),
                    if (_openSection == 'household') _buildHouseholdSection(),
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
                          label: const Text('Terminar Sessão'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
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

  Widget _buildPersonalSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('ESTADO CIVIL'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<MaritalStatus>(
                value: _draft.personalInfo.maritalStatus,
                isExpanded: true,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                items: MaritalStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
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
          _label('NUMERO DE DEPENDENTES'),
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
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
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
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDBEAFE)),
            ),
            child: Text(
              'Segurança Social: ${formatPercentage(socialSecurityRate)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF3B82F6)),
            ),
          ),
        ],
      ),
    );
  }

  void _addSalary() {
    setState(() {
      final newSalaries = List<SalaryInfo>.from(_draft.salaries);
      newSalaries.add(SalaryInfo(label: 'Vencimento ${newSalaries.length + 1}'));
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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ...List.generate(_draft.salaries.length, (idx) {
            final salary = _draft.salaries[idx];
            return Container(
              margin: EdgeInsets.only(bottom: idx < _draft.salaries.length - 1 ? 16 : 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: salary.enabled ? Colors.white : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: salary.enabled ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
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
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                            decoration: InputDecoration(
                              hintText: 'Vencimento ${idx + 1}',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_draft.salaries.length > 1)
                          IconButton(
                            onPressed: () => _removeSalary(idx),
                            icon: const Icon(Icons.remove_circle_outline, size: 18, color: Color(0xFFCBD5E1)),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                        Row(
                          children: [
                            Text('Ativo', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                            const SizedBox(width: 4),
                            Switch(
                              value: salary.enabled,
                              onChanged: (v) => _updateSalary(idx, (s) => s.copyWith(enabled: v)),
                              activeTrackColor: const Color(0xFF3B82F6),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _label('SALARIO BRUTO MENSAL'),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: salary.grossAmount > 0 ? salary.grossAmount.toString() : '',
                      onChanged: (v) => _updateSalary(idx, (s) => s.copyWith(grossAmount: double.tryParse(v) ?? 0)),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration('0.00', suffix: 'EUR'),
                    ),
                    const SizedBox(height: 12),
                    _label('SUBSÍDIOS DE FÉRIAS E NATAL (DUODÉCIMOS)'),
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
                                backgroundColor: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                                foregroundColor: isSelected ? Colors.white : const Color(0xFF64748B),
                                side: BorderSide(color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0), width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              child: Text(mode.shortLabel),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    _label('OUTROS RENDIMENTOS ISENTOS DE IRS'),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: salary.otherExemptIncome > 0 ? salary.otherExemptIncome.toString() : '',
                      onChanged: (v) => _updateSalary(idx, (s) => s.copyWith(otherExemptIncome: double.tryParse(v) ?? 0)),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration('0.00', suffix: 'EUR'),
                    ),
                    const SizedBox(height: 12),
                    _label('SUBSÍDIO DE ALIMENTAÇÃO'),
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
                                backgroundColor: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                                foregroundColor: isSelected ? Colors.white : const Color(0xFF64748B),
                                side: BorderSide(color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0), width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              child: Text(type.label),
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
                                _label('VALOR/DIA'),
                                const SizedBox(height: 4),
                                TextFormField(
                                  initialValue: salary.mealAllowancePerDay > 0 ? salary.mealAllowancePerDay.toString() : '',
                                  onChanged: (v) => _updateSalary(idx, (s) => s.copyWith(mealAllowancePerDay: double.tryParse(v) ?? 0)),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: _inputDecoration('0.00', suffix: 'EUR'),
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
                                _label('DIAS/MES'),
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
                    if (_isCasado) ...[
                      const SizedBox(height: 12),
                      _label('N. TITULARES'),
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
                                  backgroundColor: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                                  foregroundColor: isSelected ? Colors.white : const Color(0xFF64748B),
                                  side: BorderSide(color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0), width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                child: Text('$n Titular${n > 1 ? "es" : ""}'),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
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
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${table.label} — ${table.description}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      );
                    }),
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
              label: const Text('Adicionar vencimento'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                side: const BorderSide(color: Color(0xFF3B82F6)),
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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ..._draft.expenses.map((expense) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: expense.enabled ? Colors.white : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: expense.enabled ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
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
                          activeTrackColor: const Color(0xFF3B82F6),
                        ),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: expense.label)
                              ..selection = TextSelection.collapsed(offset: expense.label.length),
                            onChanged: (v) => _updateExpense(expense.id, (e) => e.copyWith(label: v)),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                            decoration: const InputDecoration(
                              hintText: 'Nome da despesa',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeExpense(expense.id),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          color: Colors.grey.shade300,
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
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<ExpenseCategory>(
                                value: expense.category,
                                isExpanded: true,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                                items: ExpenseCategory.values
                                    .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
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
                        SizedBox(
                          width: 112,
                          child: TextFormField(
                            initialValue: expense.amount > 0 ? expense.amount.toString() : '',
                            onChanged: (v) => _updateExpense(expense.id, (e) => e.copyWith(amount: double.tryParse(v) ?? 0)),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _inputDecoration('0.00', suffix: 'EUR'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          OutlinedButton.icon(
            onPressed: _addExpense,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Adicionar Despesa'),
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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.phone_android, size: 16, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Estas definições são guardadas neste dispositivo.',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _label('SECÇÕES VISÍVEIS'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _localDashboard = LocalDashboardConfig.minimalist()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Minimalista', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _localDashboard = LocalDashboardConfig.full()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Completo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _dashToggle('Liquidez mensal', _localDashboard.showHeroCard,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showHeroCard: v))),
          _dashToggle('Índice de Tranquilidade', _localDashboard.showStressIndex,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showStressIndex: v))),
          _dashToggle('Cartões de resumo', _localDashboard.showSummaryCards,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showSummaryCards: v))),
          _dashToggle('Detalhe por vencimento', _localDashboard.showSalaryBreakdown,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showSalaryBreakdown: v))),
          _dashToggle('Alimentação', _localDashboard.showFoodSpending,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showFoodSpending: v))),
          _dashToggle('Histórico de compras', _localDashboard.showPurchaseHistory,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showPurchaseHistory: v))),
          _dashToggle('Breakdown despesas', _localDashboard.showExpensesBreakdown,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showExpensesBreakdown: v))),
          _dashToggle('Gráficos', _localDashboard.showCharts,
              (v) => setState(() => _localDashboard = _localDashboard.copyWith(showCharts: v))),
          if (_localDashboard.showCharts) ...[
            const SizedBox(height: 16),
            _label('GRÁFICOS VISÍVEIS'),
            const SizedBox(height: 8),
            ...ChartType.values.map((chart) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(chart.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
                  value: _localDashboard.enabledCharts.contains(chart),
                  activeColor: const Color(0xFF3B82F6),
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
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
      value: value,
      activeTrackColor: const Color(0xFF3B82F6),
      onChanged: onChanged,
    );
  }

  Widget _buildFavoritesSection() {
    // All product names from catalog, filtered by search
    final allNames = widget.products.map((p) => p.name).toList();
    final filtered = _favSearch.isEmpty
        ? allNames
        : allNames
            .where((n) =>
                n.toLowerCase().contains(_favSearch.toLowerCase()))
            .toList();

    return Container(
      color: Colors.white,
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
                    'Os produtos favoritos influenciam o plano de refeicoes — receitas com esses ingredientes ficam em prioridade.',
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
            _label('OS MEUS FAVORITOS'),
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
          _label('CATALOGO DE PRODUTOS'),
          const SizedBox(height: 8),
          TextField(
            onChanged: (v) => setState(() => _favSearch = v),
            decoration: _inputDecoration('Pesquisar produto...').copyWith(
              prefixIcon: const Icon(Icons.search,
                  size: 18, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          if (widget.products.isEmpty)
            const Text('A carregar produtos...',
                style:
                    TextStyle(fontSize: 12, color: Color(0xFF94A3B8)))
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

  Widget _buildMealsSection() {
    final ms = _draft.mealSettings;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('AGREGADO (PESSOAS)'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    initialValue: ms.householdSize?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: _autoHouseholdSize().toString(),
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      suffixText: ms.householdSize == null ? '(auto)' : null,
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
                  icon: const Icon(Icons.restart_alt, size: 20, color: Color(0xFF94A3B8)),
                  tooltip: 'Usar valor automático',
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
                  ? 'Valor manual: ${ms.householdSize} pessoas'
                  : 'Calculado automaticamente: ${_autoHouseholdSize()} (titulares + dependentes)',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
          ),
          _label('REFEIÇÕES ATIVAS'),
          const SizedBox(height: 8),
          ...MealType.values.map((mt) => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(mt.label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                value: ms.enabledMeals.contains(mt),
                activeTrackColor: const Color(0xFF3B82F6),
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
          _label('OBJETIVO'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<MealObjective>(
                value: ms.objective,
                isExpanded: true,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569)),
                items: MealObjective.values
                    .map((o) =>
                        DropdownMenuItem(value: o, child: Text(o.label)))
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
          _label('DIAS VEGETARIANOS POR SEMANA'),
          Slider(
            value: ms.veggieDaysPerWeek.toDouble(),
            min: 0,
            max: 7,
            divisions: 7,
            label: '${ms.veggieDaysPerWeek}',
            activeColor: const Color(0xFF3B82F6),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(veggieDaysPerWeek: v.round()))),
          ),
          const SizedBox(height: 8),
          _label('RESTRIÇÕES DIETÉTICAS'),
          ...[
            ('Sem glúten', ms.glutenFree,
                (bool v) => setState(() => _draft = _draft.copyWith(
                    mealSettings: ms.copyWith(glutenFree: v)))),
            ('Sem lactose', ms.lactoseFree,
                (bool v) => setState(() => _draft = _draft.copyWith(
                    mealSettings: ms.copyWith(lactoseFree: v)))),
            ('Sem frutos secos', ms.nutFree,
                (bool v) => setState(() => _draft = _draft.copyWith(
                    mealSettings: ms.copyWith(nutFree: v)))),
            ('Sem marisco', ms.shellfishFree,
                (bool v) => setState(() => _draft = _draft.copyWith(
                    mealSettings: ms.copyWith(shellfishFree: v)))),
          ].map((item) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.$1,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                value: item.$2,
                activeColor: const Color(0xFF3B82F6),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) => item.$3(v ?? false),
              )),
          const SizedBox(height: 16),
          _label('TEMPO MÁXIMO (MINUTOS)'),
          Slider(
            value: ms.maxPrepMinutes.toDouble(),
            min: 15,
            max: 60,
            divisions: 3,
            label: ms.maxPrepMinutes == 60 ? '60+' : '${ms.maxPrepMinutes}',
            activeColor: const Color(0xFF3B82F6),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(maxPrepMinutes: v.round()))),
          ),
          _label('COMPLEXIDADE MÁXIMA (${ms.maxComplexity}/5)'),
          Slider(
            value: ms.maxComplexity.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: '${ms.maxComplexity}',
            activeColor: const Color(0xFF3B82F6),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(maxComplexity: v.round()))),
          ),
          const SizedBox(height: 8),
          _label('EQUIPAMENTO DISPONÍVEL'),
          ...KitchenEquipment.values.map((eq) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(eq.label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                value: ms.availableEquipment.contains(eq),
                activeColor: const Color(0xFF3B82F6),
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
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Batch cooking',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            value: ms.batchCookingEnabled,
            activeTrackColor: const Color(0xFF3B82F6),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(batchCookingEnabled: v))),
          ),
          if (ms.batchCookingEnabled) ...[
            _label('MÁXIMO DE DIAS POR RECEITA'),
            Slider(
              value: ms.maxBatchDays.toDouble(),
              min: 1,
              max: 4,
              divisions: 3,
              label: '${ms.maxBatchDays}',
              activeColor: const Color(0xFF3B82F6),
              onChanged: (v) => setState(() => _draft = _draft.copyWith(
                  mealSettings: ms.copyWith(maxBatchDays: v.round()))),
            ),
          ],
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reaproveitar sobras',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            value: ms.reuseLeftovers,
            activeTrackColor: const Color(0xFF3B82F6),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(reuseLeftovers: v))),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Minimizar desperdício',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            value: ms.minimizeWaste,
            activeTrackColor: const Color(0xFF3B82F6),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(
                mealSettings: ms.copyWith(minimizeWaste: v))),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _draft = _draft.copyWith(
                  mealSettings: ms.copyWith(wizardCompleted: false))),
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('Repor Wizard'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
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
    final hasKey = _apiKeyController.text.trim().isNotEmpty;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('OPENAI API KEY'),
          const SizedBox(height: 8),
          TextField(
            controller: _apiKeyController,
            obscureText: true,
            onChanged: (_) => setState(() {}),
            decoration: _inputDecoration('sk-...').copyWith(
              hintText: 'sk-...',
              suffixIcon: hasKey
                  ? const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20)
                  : const Icon(Icons.key_outlined, color: Color(0xFFCBD5E1), size: 20),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'A key é guardada localmente no dispositivo e nunca é partilhada. Usa o modelo GPT-4o mini (~€0,00008 por análise).',
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteChip(String label, {required bool isSelected}) {
    return Semantics(
      button: true,
      label: '$label${isSelected ? ", selecionado" : ""}',
      child: Material(
      color: isSelected ? const Color(0xFFEF4444).withValues(alpha: 0.08) : Colors.white,
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
            color: isSelected ? const Color(0xFFEF4444).withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.favorite : Icons.favorite_border,
              size: 14,
              color: isSelected ? const Color(0xFFEF4444) : const Color(0xFFCBD5E1),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFFEF4444) : const Color(0xFF64748B),
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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('CÓDIGO DE CONVITE'),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.link, color: Color(0xFF3B82F6)),
            title: const Text('Gerar código de convite'),
            subtitle: _inviteCode != null
                ? SelectableText(
                    _inviteCode!,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                        color: Color(0xFF1E293B)),
                  )
                : const Text('Partilha com membros do agregado'),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Novo código',
              onPressed: _generateInvite,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'O código é válido por 7 dias. Partilha-o com quem queres adicionar ao agregado.',
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), height: 1.5),
          ),
        ],
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
              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            ),
            child: Center(
              child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
            ),
          ),
        ),
      );

  InputDecoration _inputDecoration(String hint, {String? suffix}) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade300),
        suffixText: suffix,
        suffixStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade400),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        isDense: true,
      );
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isOpen;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isOpen ? const Color(0xFFF8FAFC) : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          margin: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF3B82F6)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isOpen ? const Color(0xFFEFF6FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 16,
                  color: isOpen ? const Color(0xFF3B82F6) : Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
