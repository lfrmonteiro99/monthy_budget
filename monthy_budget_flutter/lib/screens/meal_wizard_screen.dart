import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/meal_settings.dart';
import '../theme/app_colors.dart';

class MealWizardScreen extends StatefulWidget {
  final MealSettings initial;
  final ValueChanged<MealSettings> onComplete;

  const MealWizardScreen({
    super.key,
    required this.initial,
    required this.onComplete,
  });

  @override
  State<MealWizardScreen> createState() => _MealWizardScreenState();
}

class _MealWizardScreenState extends State<MealWizardScreen> {
  late MealSettings _draft;
  int _step = 0;
  final _pageController = PageController();

  static const _totalSteps = 5;

  List<String> _stepTitles(S l10n) => [
    l10n.wizardStepMeals,
    l10n.wizardStepObjective,
    l10n.wizardStepRestrictions,
    l10n.wizardStepKitchen,
    l10n.wizardStepStrategy,
  ];

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
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

  void _finish() {
    final completed = _draft.copyWith(wizardCompleted: true);
    widget.onComplete(completed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _back,
              )
            : null,
        title: Text(
          _stepTitles(l10n)[_step],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / _totalSteps,
            backgroundColor: AppColors.border(context),
            color: AppColors.primary(context),
            minHeight: 4,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Step1Meals(
                  draft: _draft,
                  onChanged: (s) => setState(() => _draft = s),
                ),
                _Step2Objective(
                  draft: _draft,
                  onChanged: (s) => setState(() => _draft = s),
                ),
                _Step3Restrictions(
                  draft: _draft,
                  onChanged: (s) => setState(() => _draft = s),
                ),
                _Step4Kitchen(
                  draft: _draft,
                  onChanged: (s) => setState(() => _draft = s),
                ),
                _Step5Strategy(
                  draft: _draft,
                  onChanged: (s) => setState(() => _draft = s),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  if (_step == _totalSteps - 1)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                            child: Text(
                              l10n.wizardSettingsInfo,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF1E40AF)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary(context),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        _step == _totalSteps - 1 ? l10n.wizardGeneratePlan : l10n.wizardContinue,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.wizardStepOf(_step + 1, _totalSteps),
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textMuted(context)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Step 1: Refeições ---
class _Step1Meals extends StatelessWidget {
  final MealSettings draft;
  final ValueChanged<MealSettings> onChanged;
  const _Step1Meals({required this.draft, required this.onChanged});

  static const _weights = {
    MealType.breakfast: '10%',
    MealType.lunch: '35%',
    MealType.snack: '15%',
    MealType.dinner: '40%',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          l10n.wizardMealsQuestion,
          style: TextStyle(fontSize: 15, color: AppColors.textLabel(context)),
        ),
        const SizedBox(height: 20),
        ...MealType.values.map((mt) {
          final enabled = draft.enabledMeals.contains(mt);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: enabled
                    ? AppColors.primary(context)
                    : AppColors.border(context),
                width: enabled ? 2 : 1,
              ),
            ),
            child: SwitchListTile(
              value: enabled,
              onChanged: (v) {
                final newSet = Set<MealType>.from(draft.enabledMeals);
                if (v) {
                  newSet.add(mt);
                } else {
                  newSet.remove(mt);
                }
                if (newSet.isEmpty) return; // must have at least 1
                onChanged(draft.copyWith(enabledMeals: newSet));
              },
              title: Text(mt.localizedLabel(l10n),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(l10n.wizardBudgetWeight(_weights[mt]!),
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textMuted(context))),
              activeTrackColor: AppColors.primary(context),
            ),
          );
        }),
      ],
    );
  }
}

// --- Step 2: Objetivo ---
class _Step2Objective extends StatelessWidget {
  final MealSettings draft;
  final ValueChanged<MealSettings> onChanged;
  const _Step2Objective({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          l10n.wizardObjectiveQuestion,
          style: TextStyle(fontSize: 15, color: AppColors.textLabel(context)),
        ),
        const SizedBox(height: 20),
        ...MealObjective.values.map((obj) {
          final selected = draft.objective == obj;
          final label = obj.localizedLabel(l10n);
          return Semantics(
            button: true,
            label: selected ? l10n.wizardSelected(label) : label,
            child: Material(
            color: selected ? AppColors.infoBackground(context) : AppColors.surface(context),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
            onTap: () {
              var updated = draft.copyWith(objective: obj);
              if (obj == MealObjective.vegetarian) {
                updated = updated.copyWith(veggieDaysPerWeek: 7);
              }
              onChanged(updated);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
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
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected
                        ? AppColors.primary(context)
                        : AppColors.borderMuted(context),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selected
                            ? AppColors.textPrimary(context)
                            : AppColors.textLabel(context),
                      )),
                ],
              ),
            ),
          ),
          ),
          );
        }),
      ],
    );
  }
}

// --- Step 3: Restrições ---
class _Step3Restrictions extends StatefulWidget {
  final MealSettings draft;
  final ValueChanged<MealSettings> onChanged;
  const _Step3Restrictions({required this.draft, required this.onChanged});

  @override
  State<_Step3Restrictions> createState() => _Step3RestrictionsState();
}

class _Step3RestrictionsState extends State<_Step3Restrictions> {
  final _dislikedCtrl = TextEditingController();

  @override
  void dispose() {
    _dislikedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final d = widget.draft;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _sectionLabel(context, l10n.wizardDietaryRestrictions),
        const SizedBox(height: 8),
        ...[
          (l10n.wizardGlutenFree, d.glutenFree,
              (bool v) => widget.onChanged(d.copyWith(glutenFree: v))),
          (l10n.wizardLactoseFree, d.lactoseFree,
              (bool v) => widget.onChanged(d.copyWith(lactoseFree: v))),
          (l10n.wizardNutFree, d.nutFree,
              (bool v) => widget.onChanged(d.copyWith(nutFree: v))),
          (l10n.wizardShellfishFree, d.shellfishFree,
              (bool v) => widget.onChanged(d.copyWith(shellfishFree: v))),
        ].map(
          (item) => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.$1,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
            value: item.$2,
            activeColor: AppColors.primary(context),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (v) => item.$3(v ?? false),
          ),
        ),
        const SizedBox(height: 20),
        _sectionLabel(context, l10n.wizardDislikedIngredients),
        const SizedBox(height: 8),
        if (d.dislikedIngredients.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: d.dislikedIngredients
                .map((name) => Chip(
                      label: Text(name,
                          style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () {
                        final updated =
                            List<String>.from(d.dislikedIngredients)
                              ..remove(name);
                        widget.onChanged(
                            d.copyWith(dislikedIngredients: updated));
                      },
                    ))
                .toList(),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _dislikedCtrl,
                decoration: InputDecoration(
                  hintText: l10n.wizardDislikedHint,
                  hintStyle: TextStyle(color: AppColors.borderMuted(context)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: AppColors.border(context))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: AppColors.border(context))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: AppColors.primary(context), width: 2)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () {
                final text = _dislikedCtrl.text.trim();
                if (text.isEmpty) return;
                final updated = [...d.dislikedIngredients, text];
                widget.onChanged(d.copyWith(dislikedIngredients: updated));
                _dislikedCtrl.clear();
              },
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary(context)),
            ),
          ],
        ),
      ],
    );
  }
}

// --- Step 4: Cozinha ---
class _Step4Kitchen extends StatelessWidget {
  final MealSettings draft;
  final ValueChanged<MealSettings> onChanged;
  const _Step4Kitchen({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final prepOptions = [15, 30, 45, 60];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _sectionLabel(context, l10n.wizardMaxPrepTime),
        const SizedBox(height: 12),
        Row(
          children: prepOptions.map((mins) {
            final selected = draft.maxPrepMinutes == mins;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: mins != prepOptions.last ? 8 : 0),
                child: Material(
                  color: selected ? AppColors.primary(context) : AppColors.surface(context),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                  onTap: () =>
                      onChanged(draft.copyWith(maxPrepMinutes: mins)),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
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
                      mins == 60 ? l10n.wizardPrepMin60Plus : l10n.wizardPrepMin(mins),
                      style: TextStyle(
                        fontSize: 13,
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
        const SizedBox(height: 20),
        _sectionLabel(context, l10n.wizardMaxComplexity),
        const SizedBox(height: 12),
        Row(
          children: [
            (l10n.wizardComplexityEasy, 2),
            (l10n.wizardComplexityMedium, 3),
            (l10n.wizardComplexityAdvanced, 5),
          ].map(((String, int) item) {
            final selected = draft.maxComplexity == item.$2;
            return Expanded(
              child: Padding(
                padding:
                    EdgeInsets.only(right: item.$2 != 5 ? 8 : 0),
                child: Material(
                  color: selected ? AppColors.primary(context) : AppColors.surface(context),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                  onTap: () =>
                      onChanged(draft.copyWith(maxComplexity: item.$2)),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
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
                      item.$1,
                      style: TextStyle(
                        fontSize: 13,
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
        const SizedBox(height: 20),
        _sectionLabel(context, l10n.wizardEquipment),
        const SizedBox(height: 8),
        ...KitchenEquipment.values.map((eq) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(eq.localizedLabel(l10n),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              value: draft.availableEquipment.contains(eq),
              activeColor: AppColors.primary(context),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (v) {
                final updated =
                    Set<KitchenEquipment>.from(draft.availableEquipment);
                if (v == true) {
                  updated.add(eq);
                } else {
                  updated.remove(eq);
                }
                onChanged(draft.copyWith(availableEquipment: updated));
              },
            )),
      ],
    );
  }
}

// --- Step 5: Estratégia ---
class _Step5Strategy extends StatelessWidget {
  final MealSettings draft;
  final ValueChanged<MealSettings> onChanged;
  const _Step5Strategy({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final weekdays = [
      l10n.wizardWeekdayMon, l10n.wizardWeekdayTue, l10n.wizardWeekdayWed,
      l10n.wizardWeekdayThu, l10n.wizardWeekdayFri, l10n.wizardWeekdaySat,
      l10n.wizardWeekdaySun,
    ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.wizardBatchCooking,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: Text(l10n.wizardBatchCookingDesc,
              style:
                  TextStyle(fontSize: 12, color: AppColors.textMuted(context))),
          value: draft.batchCookingEnabled,
          activeTrackColor: AppColors.primary(context),
          onChanged: (v) =>
              onChanged(draft.copyWith(batchCookingEnabled: v)),
        ),
        if (draft.batchCookingEnabled) ...[
          const SizedBox(height: 12),
          _sectionLabel(context, l10n.wizardMaxBatchDays),
          Slider(
            value: draft.maxBatchDays.toDouble(),
            min: 1,
            max: 4,
            divisions: 3,
            label: l10n.wizardBatchDays(draft.maxBatchDays),
            activeColor: AppColors.primary(context),
            onChanged: (v) =>
                onChanged(draft.copyWith(maxBatchDays: v.round())),
          ),
          _sectionLabel(context, l10n.wizardPreferredCookingDay),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: List.generate(7, (i) {
              final selected = draft.preferredCookingWeekday == i;
              return ChoiceChip(
                label: Text(weekdays[i]),
                selected: selected,
                selectedColor: AppColors.primary(context),
                labelStyle: TextStyle(
                  color: selected
                      ? AppColors.onPrimary(context)
                      : AppColors.textLabel(context),
                  fontSize: 12,
                ),
                onSelected: (v) => onChanged(
                  draft.copyWith(
                      preferredCookingWeekday: v ? i : null),
                ),
              );
            }),
          ),
        ],
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.wizardReuseLeftovers,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: Text(
              l10n.wizardReuseLeftoversDesc,
              style:
                  TextStyle(fontSize: 12, color: AppColors.textMuted(context))),
          value: draft.reuseLeftovers,
          activeTrackColor: AppColors.primary(context),
          onChanged: (v) => onChanged(draft.copyWith(reuseLeftovers: v)),
        ),
        const SizedBox(height: 16),
        _sectionLabel(context, l10n.wizardMaxNewIngredients),
        Slider(
          value: draft.maxNewIngredientsPerWeek.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: draft.maxNewIngredientsPerWeek == 10
              ? l10n.wizardNoLimit
              : '${draft.maxNewIngredientsPerWeek}',
          activeColor: AppColors.primary(context),
          onChanged: (v) => onChanged(
              draft.copyWith(maxNewIngredientsPerWeek: v.round())),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.wizardMinimizeWaste,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: Text(
              l10n.wizardMinimizeWasteDesc,
              style:
                  TextStyle(fontSize: 12, color: AppColors.textMuted(context))),
          value: draft.minimizeWaste,
          activeTrackColor: AppColors.primary(context),
          onChanged: (v) => onChanged(draft.copyWith(minimizeWaste: v)),
        ),
      ],
    );
  }
}

Widget _sectionLabel(BuildContext context, String text) => Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary(context),
        letterSpacing: 0.5,
      ),
    );
