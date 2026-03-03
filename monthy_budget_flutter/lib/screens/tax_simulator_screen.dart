import 'package:flutter/material.dart';
import '../data/tax/tax_system.dart';
import '../data/tax/tax_factory.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../theme/app_colors.dart';
import '../utils/calculations.dart';
import '../utils/formatters.dart';

class TaxSimulatorScreen extends StatefulWidget {
  final AppSettings settings;

  const TaxSimulatorScreen({
    super.key,
    required this.settings,
  });

  @override
  State<TaxSimulatorScreen> createState() => _TaxSimulatorScreenState();
}

class _TaxSimulatorScreenState extends State<TaxSimulatorScreen> {
  late double _grossAmount;
  late MaritalStatus _maritalStatus;
  late int _titulares;
  late int _dependentes;
  late MealAllowanceType _mealType;
  late double _mealPerDay;

  late SalaryCalculation _currentCalc;
  late SalaryCalculation _simCalc;

  @override
  void initState() {
    super.initState();
    final salary = widget.settings.salaries.firstWhere(
      (s) => s.enabled,
      orElse: () => const SalaryInfo(),
    );
    _grossAmount = salary.grossAmount;
    _maritalStatus = widget.settings.personalInfo.maritalStatus;
    _titulares = salary.titulares;
    _dependentes = widget.settings.personalInfo.dependentes;
    _mealType = salary.mealAllowanceType;
    _mealPerDay = salary.mealAllowancePerDay;

    _recalculate();
  }

  void _recalculate() {
    final taxSystem = getTaxSystem(widget.settings.country);

    // Current
    final currentSalary = widget.settings.salaries.firstWhere(
      (s) => s.enabled,
      orElse: () => const SalaryInfo(),
    );
    _currentCalc = calculateNetSalary(
      currentSalary,
      widget.settings.personalInfo,
      taxSystem,
    );

    // Simulated
    final simSalary = currentSalary.copyWith(
      grossAmount: _grossAmount,
      titulares: _titulares,
      mealAllowanceType: _mealType,
      mealAllowancePerDay: _mealPerDay,
    );
    final simPersonal = widget.settings.personalInfo.copyWith(
      maritalStatus: _maritalStatus,
      dependentes: _dependentes,
    );
    _simCalc = calculateNetSalary(simSalary, simPersonal, taxSystem);
  }

  void _applyPreset(String preset) {
    setState(() {
      switch (preset) {
        case 'raise200':
          _grossAmount = _grossAmount + 200;
          break;
        case 'mealToggle':
          _mealType = _mealType == MealAllowanceType.card
              ? MealAllowanceType.cash
              : MealAllowanceType.card;
          break;
        case 'titularToggle':
          _titulares = _titulares == 1 ? 2 : 1;
          break;
      }
      _recalculate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final country = widget.settings.country;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.surface(context),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back,
                        color: AppColors.textLabel(context)),
                  ),
                  Expanded(
                    child: Text(
                      l10n.taxSimTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.surfaceVariant(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick presets
                    Text(
                      l10n.taxSimPresets,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted(context),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _PresetChip(
                          label: l10n.taxSimPresetRaise,
                          onTap: () => _applyPreset('raise200'),
                        ),
                        if (country.hasMealAllowance)
                          _PresetChip(
                            label: l10n.taxSimPresetMeal,
                            onTap: () => _applyPreset('mealToggle'),
                          ),
                        if (country.hasTitulares)
                          _PresetChip(
                            label: l10n.taxSimPresetTitular,
                            onTap: () => _applyPreset('titularToggle'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Parameters
                    _buildParameterSection(l10n, country),
                    const SizedBox(height: 20),

                    // Comparison
                    _buildComparisonCard(context, l10n),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterSection(S l10n, Country country) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.taxSimParameters,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted(context),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),

          // Gross salary slider
          _SliderRow(
            label: l10n.taxSimGross,
            value: _grossAmount,
            min: 0,
            max: 10000,
            step: 50,
            format: formatCurrency,
            onChanged: (v) => setState(() {
              _grossAmount = v;
              _recalculate();
            }),
          ),

          // Marital status
          if (country.maritalStatusAffectsTax) ...[
            const SizedBox(height: 12),
            _SegmentedRow(
              label: l10n.taxSimMarital,
              options: [
                MaritalStatus.solteiro.localizedLabel(l10n),
                MaritalStatus.casado.localizedLabel(l10n),
                MaritalStatus.uniaoFacto.localizedLabel(l10n),
              ],
              selected: _maritalStatus == MaritalStatus.solteiro
                  ? 0
                  : _maritalStatus == MaritalStatus.casado
                      ? 1
                      : 2,
              onSelected: (i) => setState(() {
                _maritalStatus = i == 0
                    ? MaritalStatus.solteiro
                    : i == 1
                        ? MaritalStatus.casado
                        : MaritalStatus.uniaoFacto;
                _recalculate();
              }),
            ),
          ],

          // Titulares
          if (country.hasTitulares) ...[
            const SizedBox(height: 12),
            _SegmentedRow(
              label: l10n.taxSimTitulares,
              options: const ['1', '2'],
              selected: _titulares - 1,
              onSelected: (i) => setState(() {
                _titulares = i + 1;
                _recalculate();
              }),
            ),
          ],

          // Dependentes
          const SizedBox(height: 12),
          _StepperRow(
            label: l10n.taxSimDependentes,
            value: _dependentes,
            min: 0,
            max: 6,
            onChanged: (v) => setState(() {
              _dependentes = v;
              _recalculate();
            }),
          ),

          // Meal allowance
          if (country.hasMealAllowance) ...[
            const SizedBox(height: 12),
            _SegmentedRow(
              label: l10n.taxSimMealType,
              options: [
                MealAllowanceType.none.localizedLabel(l10n),
                MealAllowanceType.card.localizedLabel(l10n),
                MealAllowanceType.cash.localizedLabel(l10n),
              ],
              selected: _mealType.index,
              onSelected: (i) => setState(() {
                _mealType = MealAllowanceType.values[i];
                _recalculate();
              }),
            ),
            if (_mealType != MealAllowanceType.none) ...[
              const SizedBox(height: 12),
              _SliderRow(
                label: l10n.taxSimMealAmount,
                value: _mealPerDay,
                min: 0,
                max: 15,
                step: 0.5,
                format: formatCurrency,
                onChanged: (v) => setState(() {
                  _mealPerDay = v;
                  _recalculate();
                }),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildComparisonCard(BuildContext context, S l10n) {
    final netDelta = _simCalc.totalNetWithMeal - _currentCalc.totalNetWithMeal;
    final isPositive = netDelta >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.taxSimComparison,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted(context),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          // Net take-home comparison
          _ComparisonRow(
            label: l10n.taxSimNetTakeHome,
            current: _currentCalc.totalNetWithMeal,
            simulated: _simCalc.totalNetWithMeal,
          ),
          const SizedBox(height: 10),
          _ComparisonRow(
            label: l10n.taxSimIRS,
            current: _currentCalc.irsRetention,
            simulated: _simCalc.irsRetention,
            invertColor: true,
          ),
          const SizedBox(height: 10),
          _ComparisonRow(
            label: l10n.taxSimSS,
            current: _currentCalc.socialSecurity,
            simulated: _simCalc.socialSecurity,
            invertColor: true,
          ),
          const Divider(height: 24),
          // Delta summary
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.taxSimDelta,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted(context),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${netDelta >= 0 ? '+' : ''}${formatCurrency(netDelta)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isPositive
                      ? AppColors.success(context)
                      : AppColors.error(context),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 18,
                color: isPositive
                    ? AppColors.success(context)
                    : AppColors.error(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label,
          style: TextStyle(fontSize: 12, color: AppColors.primary(context))),
      backgroundColor: AppColors.primaryLight(context),
      side: BorderSide(color: AppColors.primary(context).withValues(alpha: 0.3)),
      onPressed: onTap,
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final double step;
  final String Function(double) format;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.format,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary(context))),
            const Spacer(),
            Text(format(value),
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context))),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: ((max - min) / step).round(),
          activeColor: AppColors.primary(context),
          onChanged: (v) => onChanged((v / step).round() * step),
        ),
      ],
    );
  }
}

class _SegmentedRow extends StatelessWidget {
  final String label;
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelected;

  const _SegmentedRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary(context))),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<int>(
            segments: List.generate(
              options.length,
              (i) => ButtonSegment(value: i, label: Text(options[i],
                  style: const TextStyle(fontSize: 11))),
            ),
            selected: {selected},
            onSelectionChanged: (s) => onSelected(s.first),
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.primaryLight(context),
              selectedForegroundColor: AppColors.primary(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepperRow extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _StepperRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary(context))),
        ),
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline, size: 22),
          color: AppColors.primary(context),
        ),
        Text('$value',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context))),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline, size: 22),
          color: AppColors.primary(context),
        ),
      ],
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String label;
  final double current;
  final double simulated;
  final bool invertColor;

  const _ComparisonRow({
    required this.label,
    required this.current,
    required this.simulated,
    this.invertColor = false,
  });

  @override
  Widget build(BuildContext context) {
    final delta = simulated - current;
    final isPositive = invertColor ? delta <= 0 : delta >= 0;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(context))),
        ),
        Expanded(
          flex: 2,
          child: Text(
            formatCurrency(current),
            style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted(context)),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.arrow_forward, size: 12, color: AppColors.textMuted(context)),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            formatCurrency(simulated),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 50,
          child: delta != 0
              ? Text(
                  '${delta > 0 ? '+' : ''}${formatCurrency(delta)}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isPositive
                        ? AppColors.success(context)
                        : AppColors.error(context),
                  ),
                  textAlign: TextAlign.right,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
