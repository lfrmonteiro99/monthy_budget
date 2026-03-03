# Índice de Tranquilidade Financeira — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Adicionar um card no Dashboard com um score 0–100 (Índice de Tranquilidade) baseado em 4 factores financeiros, com histórico mensal persistido em AppSettings.

**Architecture:** Pure function `calculateStressIndex()` em `lib/utils/stress_index.dart` — testável sem Flutter. Score guardado em `AppSettings.stressHistory` (Map<String,int>, chave "YYYY-MM") dentro do `settings_json` existente no Supabase. Card `_StressIndexCard` StatefulWidget inserido no Dashboard imediatamente abaixo do hero de liquidez.

**Tech Stack:** Flutter/Dart, `flutter_test` (package:orcamento_mensal), BudgetSummary + PurchaseHistory models existentes.

---

### Task 1: Adicionar `stressHistory` a `AppSettings`

**Files:**
- Modify: `lib/models/app_settings.dart`

**Context:** `AppSettings` é a classe central de estado da app. Usa o padrão `copyWith` + serialização JSON manual. Ver linhas 364–436.

**Step 1: Adicionar field, constructor param, copyWith, toJson, fromJson**

Em `lib/models/app_settings.dart`, aplicar as 5 alterações seguintes:

1a. Adicionar field na classe `AppSettings` (após `final MealSettings mealSettings;`):
```dart
  final Map<String, int> stressHistory;
```

1b. Adicionar ao constructor de `AppSettings` (após `this.mealSettings = const MealSettings(),`):
```dart
    this.stressHistory = const {},
```

1c. Adicionar ao `copyWith` de `AppSettings` — parâmetro (após `MealSettings? mealSettings,`):
```dart
    Map<String, int>? stressHistory,
```

1d. Adicionar ao `copyWith` de `AppSettings` — body (após `mealSettings: mealSettings ?? this.mealSettings,`):
```dart
      stressHistory: stressHistory ?? this.stressHistory,
```

1e. Em `toJsonString()`, adicionar ao map (após `'mealSettings': mealSettings.toJson(),`):
```dart
      'stressHistory': stressHistory,
```

1f. Em `fromJsonString()`, adicionar ao constructor (após `mealSettings: MealSettings.fromJson(...),`):
```dart
      stressHistory: (map['stressHistory'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          const {},
```

**Step 2: Verificar análise estática**

```bash
cd monthy_budget_flutter && flutter analyze --no-pub 2>&1 | grep -E "error|warning"
```
Expected: sem erros novos.

---

### Task 2: Criar `lib/utils/stress_index.dart` com lógica pura

**Files:**
- Create: `lib/utils/stress_index.dart`
- Create: `test/stress_index_test.dart`

**Context:** Função pura, sem dependências Flutter, totalmente testável. Usa `BudgetSummary` (em `lib/models/budget_summary.dart`), `PurchaseHistory` (em `lib/models/purchase_record.dart`), `AppSettings` (em `lib/models/app_settings.dart`). Importar com `package:orcamento_mensal/...` nos testes.

**Step 1: Escrever o teste primeiro** (`test/stress_index_test.dart`):

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/app_settings.dart';
import 'package:orcamento_mensal/models/budget_summary.dart';
import 'package:orcamento_mensal/models/purchase_record.dart';
import 'package:orcamento_mensal/utils/stress_index.dart';

void main() {
  group('calculateStressIndex', () {
    final goodSummary = const BudgetSummary(
      savingsRate: 0.20,       // 80/100 ponderado a 35%
      netLiquidity: 400.0,     // 80/100 ponderado a 30%
      totalNetWithMeal: 2000,
      totalExpenses: 1000,     // ratio 0.5 → 50/100 ponderado a 15%
    );
    final emptyHistory = const PurchaseHistory();
    final settings = const AppSettings(
      expenses: [
        ExpenseItem(
          id: 'food',
          label: 'Alimentação',
          amount: 400,
          category: ExpenseCategory.alimentacao,
          enabled: true,
        ),
      ],
    );

    test('score is between 0 and 100', () {
      final result = calculateStressIndex(
        summary: goodSummary,
        purchaseHistory: emptyHistory,
        settings: settings,
      );
      expect(result.score, inInclusiveRange(0, 100));
    });

    test('label is Excelente when score >= 80', () {
      // savingsRate=0.25 → 100pts×35%, liquidity=500→100pts×30%,
      // food=0 spent→100pts×20%, expenses=0→100pts×15% = 100
      const perfectSummary = BudgetSummary(
        savingsRate: 0.25,
        netLiquidity: 500,
        totalNetWithMeal: 2000,
        totalExpenses: 0,
      );
      final result = calculateStressIndex(
        summary: perfectSummary,
        purchaseHistory: emptyHistory,
        settings: settings,
      );
      expect(result.score, 100);
      expect(result.label, 'Excelente');
    });

    test('label is Crítico when score < 40', () {
      const badSummary = BudgetSummary(
        savingsRate: 0,
        netLiquidity: 0,
        totalNetWithMeal: 1000,
        totalExpenses: 1000,
      );
      final result = calculateStressIndex(
        summary: badSummary,
        purchaseHistory: const PurchaseHistory(records: [
          PurchaseRecord(
            id: 'r1',
            date: DateTime(2026, 2, 1),
            amount: 500, // > foodBudget 400 → ratio > 1
            itemCount: 5,
          ),
        ]),
        settings: settings,
      );
      expect(result.score, lessThan(40));
      expect(result.label, 'Crítico');
    });

    test('delta is null when no previous month in history', () {
      final result = calculateStressIndex(
        summary: goodSummary,
        purchaseHistory: emptyHistory,
        settings: settings,
      );
      expect(result.delta, isNull);
    });

    test('delta is computed when previous month exists in history', () {
      final prevKey = () {
        final now = DateTime.now();
        final pm = now.month == 1 ? 12 : now.month - 1;
        final py = now.month == 1 ? now.year - 1 : now.year;
        return '$py-${pm.toString().padLeft(2, '0')}';
      }();
      final settingsWithHistory = AppSettings(
        expenses: settings.expenses,
        stressHistory: {prevKey: 60},
      );
      final result = calculateStressIndex(
        summary: goodSummary,
        purchaseHistory: emptyHistory,
        settings: settingsWithHistory,
      );
      expect(result.delta, isNotNull);
      expect(result.previousScore, 60);
    });

    test('food factor is N/D when no food budget configured', () {
      const noFoodSettings = AppSettings();
      final result = calculateStressIndex(
        summary: goodSummary,
        purchaseHistory: emptyHistory,
        settings: noFoodSettings,
      );
      final foodFactor = result.factors.firstWhere((f) => f.label == 'Orçamento alimentação');
      expect(foodFactor.valueLabel, 'N/D');
    });
  });
}
```

**Step 2: Correr o teste para confirmar que falha**

```bash
cd monthy_budget_flutter && flutter test test/stress_index_test.dart 2>&1 | tail -10
```
Expected: FAIL — "Target file not found" ou "stress_index.dart not found".

**Step 3: Criar `lib/utils/stress_index.dart`**

```dart
import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../models/purchase_record.dart';

class StressFactorResult {
  final String label;
  final String valueLabel;
  final bool ok;
  final double normalizedScore;

  const StressFactorResult({
    required this.label,
    required this.valueLabel,
    required this.ok,
    required this.normalizedScore,
  });
}

class StressIndexResult {
  final int score;
  final String label;
  final List<StressFactorResult> factors;
  final int? previousScore;

  const StressIndexResult({
    required this.score,
    required this.label,
    required this.factors,
    this.previousScore,
  });

  int? get delta => previousScore != null ? score - previousScore! : null;
}

StressIndexResult calculateStressIndex({
  required BudgetSummary summary,
  required PurchaseHistory purchaseHistory,
  required AppSettings settings,
}) {
  final now = DateTime.now();
  final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  final prevMonth = now.month == 1 ? 12 : now.month - 1;
  final prevYear = now.month == 1 ? now.year - 1 : now.year;
  final prevKey = '$prevYear-${prevMonth.toString().padLeft(2, '0')}';
  final previousScore = settings.stressHistory[prevKey];

  // Factor 1 — Taxa de poupança (35%)
  final savingsRate = summary.savingsRate.clamp(0.0, 1.0);
  final savingsScore = (savingsRate / 0.25 * 100).clamp(0.0, 100.0);
  final savingsFactor = StressFactorResult(
    label: 'Taxa de poupança',
    valueLabel: '${(savingsRate * 100).toStringAsFixed(0)}%',
    ok: savingsRate >= 0.10,
    normalizedScore: savingsScore,
  );

  // Factor 2 — Margem de segurança / liquidez (30%)
  final liquidity = summary.netLiquidity;
  final liquidityScore = (liquidity / 500.0 * 100).clamp(0.0, 100.0);
  final liquidityFactor = StressFactorResult(
    label: 'Margem de segurança',
    valueLabel: '${liquidity.toStringAsFixed(0)}€',
    ok: liquidity >= 100,
    normalizedScore: liquidityScore,
  );

  // Factor 3 — Orçamento alimentação (20%)
  final foodBudget = settings.expenses
      .where((e) => e.category == ExpenseCategory.alimentacao && e.enabled)
      .fold(0.0, (s, e) => s + e.amount);
  final foodSpent = purchaseHistory.spentInMonth(now.year, now.month);
  final hasFoodBudget = foodBudget > 0;
  final foodRatio = hasFoodBudget
      ? (foodSpent / foodBudget).clamp(0.0, 2.0)
      : 0.0;
  final foodScore = ((1.0 - foodRatio) * 100).clamp(0.0, 100.0);
  final foodFactor = StressFactorResult(
    label: 'Orçamento alimentação',
    valueLabel: hasFoodBudget
        ? '${(foodRatio * 100).toStringAsFixed(0)}% usado'
        : 'N/D',
    ok: foodRatio <= 0.80,
    normalizedScore: foodScore,
  );

  // Factor 4 — Estabilidade despesas (15%)
  final totalNet = summary.totalNetWithMeal;
  final expenseRatio = totalNet > 0
      ? (summary.totalExpenses / totalNet).clamp(0.0, 1.5)
      : 1.0;
  final stabilityScore = ((1.0 - expenseRatio) * 100).clamp(0.0, 100.0);
  final stabilityFactor = StressFactorResult(
    label: 'Estabilidade despesas',
    valueLabel: expenseRatio <= 0.70 ? 'Estável' : 'Elevada',
    ok: expenseRatio <= 0.70,
    normalizedScore: stabilityScore,
  );

  final score = (savingsScore * 0.35 +
          liquidityScore * 0.30 +
          foodScore * 0.20 +
          stabilityScore * 0.15)
      .round()
      .clamp(0, 100);

  final label = score >= 80
      ? 'Excelente'
      : score >= 60
          ? 'Bom'
          : score >= 40
              ? 'Atenção'
              : 'Crítico';

  return StressIndexResult(
    score: score,
    label: label,
    factors: [savingsFactor, liquidityFactor, foodFactor, stabilityFactor],
    previousScore: previousScore,
  );
}
```

**Step 4: Correr os testes para confirmar que passam**

```bash
cd monthy_budget_flutter && flutter test test/stress_index_test.dart -v 2>&1 | tail -20
```
Expected: todos os testes PASS.

---

### Task 3: Adicionar `_StressIndexCard` e `onSaveSettings` ao `DashboardScreen`

**Files:**
- Modify: `lib/screens/dashboard_screen.dart`

**Context:** `DashboardScreen` é StatelessWidget em `lib/screens/dashboard_screen.dart`. Recebe `settings`, `summary`, `purchaseHistory`. O hero card está em `_buildHeroCard()`. O card deve ser inserido após o hero, antes de `_buildSummaryCards()`. O padrão de inserção do score usa `WidgetsBinding.instance.addPostFrameCallback` para não chamar `setState` durante o build.

**Step 1: Adicionar imports no topo do ficheiro**

Após os imports existentes (linha ~7 de `dashboard_screen.dart`), adicionar:
```dart
import '../models/purchase_record.dart';
import '../utils/stress_index.dart';
```

**Step 2: Adicionar `onSaveSettings` à classe `DashboardScreen`**

Na classe `DashboardScreen`, após `final VoidCallback onOpenSettings;`:
```dart
  final ValueChanged<AppSettings> onSaveSettings;
```

No constructor de `DashboardScreen`, após `required this.onOpenSettings,`:
```dart
    required this.onSaveSettings,
```

**Step 3: Inserir cálculo + save + card no método `build()`**

No início do método `build()` de `DashboardScreen`, após `final isPositive = summary.netLiquidity >= 0;`, adicionar:

```dart
    // Stress Index
    final stressResult = calculateStressIndex(
      summary: summary,
      purchaseHistory: purchaseHistory,
      settings: settings,
    );
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    if (hasData && settings.stressHistory[monthKey] != stressResult.score) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final updated = Map<String, int>.from(settings.stressHistory)
          ..[monthKey] = stressResult.score;
        onSaveSettings(settings.copyWith(stressHistory: updated));
      });
    }
```

**Step 4: Inserir o card no Column do body**

Localizar no `build()` a secção `if (hasData) ...` com o `Padding` que contém os cards. Dentro desse Padding, após `_buildSalaryBreakdown()` e antes de `_buildFoodSpendingCard()`, inserir:

```dart
                      _StressIndexCard(result: stressResult),
                      const SizedBox(height: 16),
```

**Step 5: Adicionar `_StressIndexCard` StatefulWidget** — colar no fim do ficheiro, antes da última `}`:

```dart
class _StressIndexCard extends StatefulWidget {
  final StressIndexResult result;
  const _StressIndexCard({required this.result});

  @override
  State<_StressIndexCard> createState() => _StressIndexCardState();
}

class _StressIndexCardState extends State<_StressIndexCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final color = _scoreColor(result.score);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                'ÍNDICE DE TRANQUILIDADE',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade400,
                    letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${result.score}',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -1),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(result.label,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: color)),
                    ),
                    if (result.delta != null)
                      Row(
                        children: [
                          Icon(
                            result.delta! > 0
                                ? Icons.arrow_upward
                                : result.delta! < 0
                                    ? Icons.arrow_downward
                                    : Icons.remove,
                            size: 12,
                            color: result.delta! > 0
                                ? const Color(0xFF10B981)
                                : result.delta! < 0
                                    ? const Color(0xFFEF4444)
                                    : Colors.grey,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${result.delta! > 0 ? '+' : ''}${result.delta} vs mês passado',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: result.delta! > 0
                                  ? const Color(0xFF10B981)
                                  : result.delta! < 0
                                      ? const Color(0xFFEF4444)
                                      : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: result.score / 100.0,
            backgroundColor: const Color(0xFFE2E8F0),
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          if (_expanded) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 10),
            ...result.factors.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        f.ok
                            ? Icons.check_circle_outline
                            : Icons.warning_amber_outlined,
                        size: 16,
                        color: f.ok
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(f.label,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF475569))),
                      ),
                      Text(f.valueLabel,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B))),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _expanded ? 'Fechar' : 'Ver detalhes',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 4),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 60) return const Color(0xFF3B82F6);
    if (score >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
```

**Step 6: Verificar análise estática**

```bash
cd monthy_budget_flutter && flutter analyze --no-pub 2>&1 | grep -E "error|warning"
```
Expected: sem erros novos.

---

### Task 4: Passar `onSaveSettings` ao `DashboardScreen` em `main.dart`

**Files:**
- Modify: `lib/main.dart`

**Context:** `DashboardScreen` é construído em `_AppHomeState.build()` dentro da lista `screens`, linhas ~281–290 de `lib/main.dart`.

**Step 1: Atualizar a construção de `DashboardScreen`**

Localizar:
```dart
      DashboardScreen(
        settings: _settings,
        summary: summary,
        purchaseHistory: _purchaseHistory,
        onOpenSettings: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => _buildSettingsScreen()),
          );
        },
      ),
```

Substituir por:
```dart
      DashboardScreen(
        settings: _settings,
        summary: summary,
        purchaseHistory: _purchaseHistory,
        onSaveSettings: _saveSettings,
        onOpenSettings: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => _buildSettingsScreen()),
          );
        },
      ),
```

**Step 2: Correr todos os testes**

```bash
cd monthy_budget_flutter && flutter test 2>&1 | tail -10
```
Expected: todos os testes passam.

**Step 3: Build APK**

```bash
cd monthy_budget_flutter && flutter build apk --release --no-tree-shake-icons 2>&1 | tail -5
```
Expected: `✓ Built build/app/outputs/apk/release/gestao-mensal-v1.0.0.apk`

**Step 4: Commit**

```bash
cd monthy_budget_flutter && git add lib/models/app_settings.dart lib/utils/stress_index.dart lib/screens/dashboard_screen.dart lib/main.dart test/stress_index_test.dart && git commit -m "claude/budget-calculator-app-TFWgZ: add financial tranquility index to dashboard"
```
