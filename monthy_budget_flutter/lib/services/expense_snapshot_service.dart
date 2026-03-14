import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_settings.dart';
import '../models/expense_snapshot.dart';

class ExpenseSnapshotService {
  final _client = Supabase.instance.client;

  /// Upserts expense snapshots for the given month if they differ from current values.
  Future<void> snapshotIfNeeded(
    String householdId,
    String month,
    List<ExpenseItem> expenses,
  ) async {
    // Check if snapshot already exists for this month
    final existing = await _client
        .from('expense_snapshots')
        .select('expense_id, amount, enabled')
        .eq('household_id', householdId)
        .eq('month', month);

    final existingMap = <String, Map<String, dynamic>>{};
    for (final row in existing) {
      existingMap[row['expense_id'] as String] = row;
    }

    // Build list of rows that need upsert
    final toUpsert = <Map<String, dynamic>>[];
    for (final e in expenses) {
      final ex = existingMap[e.id];
      if (ex == null ||
          (ex['amount'] as num).toDouble() != e.amount ||
          (ex['enabled'] as bool) != e.enabled) {
        toUpsert.add({
          'household_id': householdId,
          'month': month,
          'expense_id': e.id,
          'label': e.label,
          'category': e.category,
          'amount': e.amount,
          'enabled': e.enabled,
        });
      }
    }

    if (toUpsert.isNotEmpty) {
      await _client
          .from('expense_snapshots')
          .upsert(toUpsert, onConflict: 'household_id,month,expense_id');
    }
  }

  /// Loads expense snapshots for the last [months] months, grouped by month key.
  Future<Map<String, List<ExpenseSnapshot>>> loadHistory(
    String householdId, {
    int months = 12,
  }) async {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month - months + 1);
    final cutoffKey = '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}';

    final rows = await _client
        .from('expense_snapshots')
        .select()
        .eq('household_id', householdId)
        .gte('month', cutoffKey)
        .order('month', ascending: true);

    final result = <String, List<ExpenseSnapshot>>{};
    for (final row in rows) {
      final month = row['month'] as String;
      result.putIfAbsent(month, () => []);
      result[month]!.add(ExpenseSnapshot.fromJson(row));
    }
    return result;
  }
}
