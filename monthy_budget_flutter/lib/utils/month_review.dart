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

MonthReviewResult? buildMonthReview({
  required Map<String, List<ExpenseSnapshot>> expenseHistory,
  required List<ExpenseItem> currentExpenses,
  required PurchaseHistory purchaseHistory,
  required DateTime now,
}) {
  if (now.day > 7) return null;

  final prevMonth = now.month == 1 ? 12 : now.month - 1;
  final prevYear = now.month == 1 ? now.year - 1 : now.year;
  final prevKey = '$prevYear-${prevMonth.toString().padLeft(2, '0')}';

  final snapshots = expenseHistory[prevKey];
  if (snapshots == null || snapshots.isEmpty) return null;

  final monthLabel = '${_monthNames[prevMonth]} $prevYear';

  final currentMap = <String, ExpenseItem>{};
  for (final e in currentExpenses) {
    currentMap[e.id] = e;
  }

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

  deviations.sort((a, b) => b.difference.abs().compareTo(a.difference.abs()));

  final foodActual = purchaseHistory.spentInMonth(prevYear, prevMonth);
  final totalDifference = totalActual - totalPlanned;

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
