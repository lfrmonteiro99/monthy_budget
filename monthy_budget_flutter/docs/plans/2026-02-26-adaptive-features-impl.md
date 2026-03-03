# Adaptive Features Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add mid-month budget alerts, end-of-month reviews, and minimalist dashboard preset to transform the app into an adaptive decision system.

**Architecture:** Three independent features layered onto the existing dashboard. Feature 1 adds a pure function + alert banner below the food card. Feature 2 adds a pure function + card + bottom sheet for monthly reviews. Feature 3 adds factory constructors and preset buttons. All AI calls gated behind `canUseAI()` for future tier support.

**Tech Stack:** Flutter, fl_chart (existing), Supabase (existing expense_snapshots), SharedPreferences (existing LocalDashboardConfig)

---

### Task 1: Budget Pace — Pure Function

**Files:**
- Modify: `lib/utils/stress_index.dart` — add `BudgetPaceResult` class and `checkBudgetPace()` function after the existing `calculateStressIndex()` function (after line 118)

**Step 1: Add `BudgetPaceResult` and `checkBudgetPace()`**

Append to `lib/utils/stress_index.dart` after line 118:

```dart
class BudgetPaceResult {
  final double dailyPace;
  final double expectedPace;
  final double projectedTotal;
  final double projectedOverspend;
  final bool isOverPace;
  final String severity; // 'ok' | 'warning' | 'danger'
  final int daysElapsed;
  final int daysRemaining;

  const BudgetPaceResult({
    required this.dailyPace,
    required this.expectedPace,
    required this.projectedTotal,
    required this.projectedOverspend,
    required this.isOverPace,
    required this.severity,
    required this.daysElapsed,
    required this.daysRemaining,
  });
}

BudgetPaceResult checkBudgetPace({
  required double foodBudget,
  required double foodSpent,
  required DateTime now,
}) {
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final daysElapsed = now.day;
  final daysRemaining = daysInMonth - daysElapsed;

  final dailyPace = daysElapsed > 0 ? foodSpent / daysElapsed : 0.0;
  final expectedPace = foodBudget / daysInMonth;
  final projectedTotal = foodSpent + (dailyPace * daysRemaining);
  final projectedOverspend = projectedTotal - foodBudget;

  final paceRatio = expectedPace > 0 ? dailyPace / expectedPace : 0.0;
  final severity = paceRatio <= 1.0
      ? 'ok'
      : paceRatio <= 1.2
          ? 'warning'
          : 'danger';

  return BudgetPaceResult(
    dailyPace: dailyPace,
    expectedPace: expectedPace,
    projectedTotal: projectedTotal,
    projectedOverspend: projectedOverspend,
    isOverPace: paceRatio > 1.0,
    severity: severity,
    daysElapsed: daysElapsed,
    daysRemaining: daysRemaining,
  );
}
```

**Step 2: Verify**

Run: `flutter analyze lib/utils/stress_index.dart`
Expected: No new errors.

---

### Task 2: Budget Pace — Dashboard Alert Banner

**Files:**
- Modify: `lib/screens/dashboard_screen.dart`
  - Add `_BudgetPaceAlert` widget (new private widget class at the end of the file)
  - Insert it right after `_buildFoodSpendingCard(context)` call (~line 147)

**Step 1: Add `_BudgetPaceAlert` widget**

Append at the end of `lib/screens/dashboard_screen.dart` (before the last `}`... actually after `_ExemptIncomeRow`):

```dart
class _BudgetPaceAlert extends StatelessWidget {
  final BudgetPaceResult pace;
  final VoidCallback? onAskAI;

  const _BudgetPaceAlert({required this.pace, this.onAskAI});

  @override
  Widget build(BuildContext context) {
    final isWarning = pace.severity == 'warning';
    final borderColor = isWarning ? const Color(0xFFFBBF24) : const Color(0xFFEF4444);
    final bgColor = isWarning ? const Color(0xFFFFFBEB) : const Color(0xFFFEF2F2);
    final iconColor = isWarning ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);
    final title = isWarning
        ? 'A gastar mais rápido que o previsto'
        : 'Risco de ultrapassar orçamento alimentar';

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ritmo', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                    const SizedBox(height: 2),
                    Text(
                      '${pace.dailyPace.toStringAsFixed(1)}€/dia vs ${pace.expectedPace.toStringAsFixed(1)}€/dia',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Projeção', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                    const SizedBox(height: 2),
                    Text(
                      '+${pace.projectedOverspend.toStringAsFixed(0)}€',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: iconColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onAskAI != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAskAI,
                icon: const Icon(Icons.auto_awesome, size: 14),
                label: const Text('Pedir sugestão'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

**Step 2: Wire into dashboard**

In `dashboard_screen.dart`, add import at top:
```dart
// Already imported: stress_index.dart — checkBudgetPace is there now
```

In the `build()` method, compute pace (after `stressResult` is computed, around line 46):

```dart
    final foodBudget = settings.expenses
        .where((e) => e.category == ExpenseCategory.alimentacao && e.enabled)
        .fold(0.0, (s, e) => s + e.amount);
    final foodSpent = purchaseHistory.spentInMonth(now.year, now.month);
    final paceResult = foodBudget > 0 && foodSpent > 0
        ? checkBudgetPace(foodBudget: foodBudget, foodSpent: foodSpent, now: now)
        : null;
```

Then after `if (dashboardConfig.showFoodSpending) _buildFoodSpendingCard(context),` (~line 147), insert:

```dart
                      if (paceResult != null && paceResult.isOverPace)
                        _BudgetPaceAlert(pace: paceResult),
```

Note: `paceResult` needs to be accessible. Since `DashboardScreen` is a `StatelessWidget` and `build()` has all the variables, just compute it inside `build()` and pass it.

**Step 3: Verify**

Run: `flutter analyze lib/screens/dashboard_screen.dart`
Expected: No new errors.

---

### Task 3: AI Coach — `canUseAI()` and Mid-Month Prompt

**Files:**
- Modify: `lib/services/ai_coach_service.dart`
  - Add `canUseAI()` method (after `saveApiKey`, ~line 29)
  - Add `analyzeMidMonth()` method (after `analyze`, ~line 144)

**Step 1: Add `canUseAI()`**

After `saveApiKey()` (line 29), add:

```dart
  /// Gate for AI features. Currently checks API key existence.
  /// Future: replace with subscription tier check.
  Future<bool> canUseAI() async {
    final key = await loadApiKey();
    return key.isNotEmpty;
  }
```

**Step 2: Add `analyzeMidMonth()`**

After the `analyze()` method (after line 144), add:

```dart
  Future<({CoachInsight insight, List<CoachInsight> history})> analyzeMidMonth({
    required String apiKey,
    required String householdId,
    required AppSettings settings,
    required BudgetSummary summary,
    required PurchaseHistory purchaseHistory,
    required BudgetPaceResult pace,
  }) async {
    final stress = calculateStressIndex(
      summary: summary,
      purchaseHistory: purchaseHistory,
      settings: settings,
    );

    final now = DateTime.now();
    final prompt = StringBuffer();
    prompt.writeln('CONTEXTO: Alerta de desvio orçamental a meio do mês.');
    prompt.writeln('Dia do mês: ${now.day}/${DateTime(now.year, now.month + 1, 0).day}');
    prompt.writeln('Orçamento alimentar: ${pace.expectedPace * DateTime(now.year, now.month + 1, 0).day}€');
    prompt.writeln('Gasto até agora: ${(pace.dailyPace * pace.daysElapsed).toStringAsFixed(2)}€');
    prompt.writeln('Ritmo actual: ${pace.dailyPace.toStringAsFixed(2)}€/dia vs previsto ${pace.expectedPace.toStringAsFixed(2)}€/dia');
    prompt.writeln('Projeção fim mês: ${pace.projectedTotal.toStringAsFixed(2)}€ (excesso: +${pace.projectedOverspend.toStringAsFixed(2)}€)');
    prompt.writeln('Dias restantes: ${pace.daysRemaining}');
    prompt.writeln('Índice de Tranquilidade: ${stress.score}/100');
    prompt.writeln();
    prompt.writeln('PEDIDO: Dá 3 sugestões concretas e accionáveis para reduzir o gasto alimentar '
        'nos restantes ${pace.daysRemaining} dias. Cada sugestão deve incluir a poupança estimada em €. '
        'Sê directo e específico. Sem introdução nem conclusão.');

    final response = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: jsonEncode({
            'model': _model,
            'messages': [
              {
                'role': 'system',
                'content': 'És um consultor de orçamento doméstico português. '
                    'Responde sempre em português europeu. Sê prático e directo.',
              },
              {'role': 'user', 'content': prompt.toString()},
            ],
            'max_tokens': 500,
            'temperature': 0.5,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      if (response.statusCode == 401) {
        throw Exception('API key inválida. Verifica nas Definições.');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = (body['error'] as Map?)?['message'] ?? 'Erro ${response.statusCode}';
      throw Exception(msg);
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final content = (data['choices'] as List).first['message']['content'] as String;

    final insight = CoachInsight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      content: content,
      stressScore: stress.score,
    );
    final history = await _persistInsight(insight, householdId);
    return (insight: insight, history: history);
  }
```

Add import at top of `ai_coach_service.dart`:
```dart
import '../utils/stress_index.dart';  // for BudgetPaceResult
```

Note: `stress_index.dart` is already imported. Just need `BudgetPaceResult` which is now in that file.

**Step 3: Verify**

Run: `flutter analyze lib/services/ai_coach_service.dart`
Expected: No new errors.

---

### Task 4: Month Review — Pure Function

**Files:**
- Create: `lib/utils/month_review.dart`

**Step 1: Create the file**

```dart
import '../models/expense_snapshot.dart';
import '../models/app_settings.dart';
import '../models/purchase_record.dart';

class ExpenseDeviation {
  final String label;
  final String category;
  final double planned;
  final double actual;
  final double difference;
  final double percentChange;

  const ExpenseDeviation({
    required this.label,
    required this.category,
    required this.planned,
    required this.actual,
    required this.difference,
    required this.percentChange,
  });
}

class MonthReviewResult {
  final String monthLabel;
  final double totalPlanned;
  final double totalActual;
  final double totalDifference;
  final double foodBudget;
  final double foodActual;
  final List<ExpenseDeviation> deviations;
  final List<String> suggestions;

  const MonthReviewResult({
    required this.monthLabel,
    required this.totalPlanned,
    required this.totalActual,
    required this.totalDifference,
    required this.foodBudget,
    required this.foodActual,
    required this.deviations,
    required this.suggestions,
  });
}

const _monthNames = [
  '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
];

/// Builds a month review comparing previous month's snapshot to current expense values.
/// Returns null if no snapshot data exists for the previous month.
MonthReviewResult? buildMonthReview({
  required Map<String, List<ExpenseSnapshot>> expenseHistory,
  required List<ExpenseItem> currentExpenses,
  required PurchaseHistory purchaseHistory,
  required DateTime now,
}) {
  // Only show during first 7 days of a new month
  if (now.day > 7) return null;

  final prevMonth = now.month == 1 ? 12 : now.month - 1;
  final prevYear = now.month == 1 ? now.year - 1 : now.year;
  final prevKey = '$prevYear-${prevMonth.toString().padLeft(2, '0')}';

  final snapshots = expenseHistory[prevKey];
  if (snapshots == null || snapshots.isEmpty) return null;

  final monthLabel = '${_monthNames[prevMonth]} $prevYear';

  // Build lookup of current expense amounts by id
  final currentMap = <String, ExpenseItem>{};
  for (final e in currentExpenses) {
    currentMap[e.id] = e;
  }

  // Calculate deviations
  final deviations = <ExpenseDeviation>[];
  double totalPlanned = 0;
  double totalActual = 0;
  double foodBudget = 0;

  for (final snap in snapshots) {
    if (!snap.enabled) continue;
    final planned = snap.amount;
    totalPlanned += planned;

    final current = currentMap[snap.expenseId];
    final actual = (current != null && current.enabled) ? current.amount : 0.0;
    totalActual += actual;

    if (snap.category == 'alimentacao') {
      foodBudget = planned;
    }

    final diff = actual - planned;
    if (diff.abs() > 0.01) {
      deviations.add(ExpenseDeviation(
        label: snap.label,
        category: snap.category,
        planned: planned,
        actual: actual,
        difference: diff,
        percentChange: planned > 0 ? diff / planned : 0,
      ));
    }
  }

  // Sort by absolute difference descending
  deviations.sort((a, b) => b.difference.abs().compareTo(a.difference.abs()));

  // Food actual from purchase records
  final foodActual = purchaseHistory.spentInMonth(prevYear, prevMonth);

  final totalDifference = totalActual - totalPlanned;

  // Generate rule-based suggestions
  final suggestions = <String>[];
  if (foodBudget > 0 && foodActual > foodBudget * 1.1) {
    suggestions.add('Alimentação excedeu o orçamento em ${((foodActual / foodBudget - 1) * 100).toStringAsFixed(0)}% — considere rever porções ou frequência de compras.');
  }
  if (totalDifference > totalPlanned * 0.05) {
    suggestions.add('Despesas reais superaram o planeado em ${totalDifference.toStringAsFixed(0)}€ — ajustar valores nas definições?');
  }
  if (totalDifference < -totalPlanned * 0.15) {
    suggestions.add('Poupou ${totalDifference.abs().toStringAsFixed(0)}€ mais do que previsto — pode reforçar fundo de emergência.');
  }
  if (suggestions.isEmpty) {
    suggestions.add('Despesas dentro do previsto. Bom controlo orçamental.');
  }

  return MonthReviewResult(
    monthLabel: monthLabel,
    totalPlanned: totalPlanned,
    totalActual: totalActual,
    totalDifference: totalDifference,
    foodBudget: foodBudget,
    foodActual: foodActual,
    deviations: deviations,
    suggestions: suggestions,
  );
}
```

**Step 2: Verify**

Run: `flutter analyze lib/utils/month_review.dart`
Expected: No errors.

---

### Task 5: Month Review — Bottom Sheet Widget

**Files:**
- Create: `lib/widgets/month_review_sheet.dart`

**Step 1: Create the file**

```dart
import 'package:flutter/material.dart';
import '../utils/month_review.dart';
import '../utils/formatters.dart';

void showMonthReviewSheet({
  required BuildContext context,
  required MonthReviewResult review,
  VoidCallback? onAskAI,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) => _MonthReviewContent(
        scrollController: scrollController,
        review: review,
        onAskAI: onAskAI,
      ),
    ),
  );
}

class _MonthReviewContent extends StatelessWidget {
  final ScrollController scrollController;
  final MonthReviewResult review;
  final VoidCallback? onAskAI;

  const _MonthReviewContent({
    required this.scrollController,
    required this.review,
    this.onAskAI,
  });

  @override
  Widget build(BuildContext context) {
    final isOver = review.totalDifference > 0;
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Center(
          child: Container(
            width: 40, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Text(
          'Resumo — ${review.monthLabel}',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),

        // ── Totals ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _stat('Planeado', formatCurrency(review.totalPlanned), const Color(0xFF64748B))),
                  Expanded(child: _stat('Real', formatCurrency(review.totalActual), const Color(0xFF1E293B))),
                  Expanded(
                    child: _stat(
                      'Diferença',
                      '${isOver ? '+' : ''}${formatCurrency(review.totalDifference)}',
                      isOver ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              if (review.foodBudget > 0) ...[
                const Divider(height: 24, color: Color(0xFFE2E8F0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Alimentação', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    Text(
                      '${formatCurrency(review.foodActual)} de ${formatCurrency(review.foodBudget)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: review.foodActual > review.foodBudget
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Top deviations ─────────────────────────────────────
        if (review.deviations.isNotEmpty) ...[
          const Text(
            'MAIORES DESVIOS',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8), letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          ...review.deviations.take(3).map((d) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          Text(
                            '${formatCurrency(d.planned)} → ${formatCurrency(d.actual)}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${d.difference > 0 ? '+' : ''}${formatCurrency(d.difference)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: d.difference > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                          ),
                        ),
                        Text(
                          '${d.difference > 0 ? '+' : ''}${(d.percentChange * 100).toStringAsFixed(0)}%',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
        ],

        // ── Suggestions ────────────────────────────────────────
        const Text(
          'SUGESTÕES',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8), letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        ...review.suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  Expanded(
                    child: Text(s, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  ),
                ],
              ),
            )),

        // ── AI button ──────────────────────────────────────────
        if (onAskAI != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAskAI,
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: const Text('Análise AI detalhada'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                side: const BorderSide(color: Color(0xFFBFDBFE)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}
```

**Step 2: Verify**

Run: `flutter analyze lib/widgets/month_review_sheet.dart`
Expected: No errors.

---

### Task 6: Month Review — Dashboard Card + Wiring

**Files:**
- Modify: `lib/screens/dashboard_screen.dart`
  - Add import for `month_review.dart` and `month_review_sheet.dart`
  - Compute `monthReview` in `build()`
  - Add `_MonthReviewCard` widget
  - Insert card at top of dashboard content (after header, before stress index)

**Step 1: Add imports**

At top of `dashboard_screen.dart`, add:
```dart
import '../utils/month_review.dart';
import '../widgets/month_review_sheet.dart';
```

**Step 2: Compute review in `build()`**

After `final monthKey = ...` (around line 47), add:

```dart
    final monthReview = buildMonthReview(
      expenseHistory: expenseHistory,
      currentExpenses: settings.expenses,
      purchaseHistory: purchaseHistory,
      now: now,
    );
```

**Step 3: Insert card in the column**

After `if (dashboardConfig.showStressIndex) const SizedBox(height: 16),` (~line 143) and BEFORE `if (dashboardConfig.showSummaryCards)` (~line 144), insert:

```dart
                      if (monthReview != null)
                        _MonthReviewCard(
                          review: monthReview,
                          onTap: () => showMonthReviewSheet(
                            context: context,
                            review: monthReview,
                          ),
                        ),
                      if (monthReview != null) const SizedBox(height: 16),
```

**Step 4: Add `_MonthReviewCard` widget**

Append to the file (before `_ExemptIncomeRow` or after it):

```dart
class _MonthReviewCard extends StatelessWidget {
  final MonthReviewResult review;
  final VoidCallback onTap;

  const _MonthReviewCard({required this.review, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOver = review.totalDifference > 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment_outlined, size: 16, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${review.monthLabel.toUpperCase()} — RESUMO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade400,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Planeado', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                      Text(formatCurrency(review.totalPlanned),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Real', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                      Text(formatCurrency(review.totalActual),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Diferença', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                      Text(
                        '${isOver ? '+' : ''}${formatCurrency(review.totalDifference)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isOver ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 5: Verify**

Run: `flutter analyze lib/screens/dashboard_screen.dart`
Expected: No new errors.

---

### Task 7: Minimalist Preset — Model + Settings UI

**Files:**
- Modify: `lib/models/local_dashboard_config.dart` — add `minimalist()` and `full()` factory constructors
- Modify: `lib/screens/settings_screen.dart` — add preset buttons above toggle list

**Step 1: Add factory constructors to `LocalDashboardConfig`**

In `lib/models/local_dashboard_config.dart`, add after the default constructor (after line 30):

```dart
  factory LocalDashboardConfig.minimalist() => const LocalDashboardConfig(
    showHeroCard: true,
    showStressIndex: false,
    showSummaryCards: false,
    showSalaryBreakdown: false,
    showFoodSpending: true,
    showPurchaseHistory: false,
    showExpensesBreakdown: false,
    showCharts: false,
    enabledCharts: [],
  );

  factory LocalDashboardConfig.full() => const LocalDashboardConfig();
```

**Step 2: Add preset buttons in settings**

In `lib/screens/settings_screen.dart`, in `_buildDashboardSection()`, after `_label('SECÇÕES VISÍVEIS'),` and before the first `_dashToggle(...)` (~line 783-785), insert:

```dart
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
```

**Step 3: Verify**

Run: `flutter analyze lib/models/local_dashboard_config.dart lib/screens/settings_screen.dart`
Expected: No new errors.

---

### Task 8: Build and Commit

**Step 1: Run full analysis**

Run: `flutter analyze lib/`
Expected: Only pre-existing warnings. Zero new errors.

**Step 2: Build the APK**

Run: `flutter build apk --release`
Expected: BUILD SUCCESSFUL.

**Step 3: Commit all changes**

Files to stage:
- `lib/utils/stress_index.dart`
- `lib/utils/month_review.dart`
- `lib/widgets/month_review_sheet.dart`
- `lib/screens/dashboard_screen.dart`
- `lib/services/ai_coach_service.dart`
- `lib/models/local_dashboard_config.dart`
- `lib/screens/settings_screen.dart`

Commit message: `claude/budget-calculator-app-TFWgZ: add mid-month budget alerts, month review, and minimalist dashboard preset`
