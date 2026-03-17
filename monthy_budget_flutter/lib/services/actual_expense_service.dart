import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/actual_expense.dart';
import 'log_service.dart';

class ActualExpenseService {
  final _client = Supabase.instance.client;

  Future<List<ActualExpense>> loadMonth(
      String householdId, String monthKey) async {
    final rows = await _client
        .from('actual_expenses')
        .select()
        .eq('household_id', householdId)
        .eq('month_key', monthKey)
        .order('expense_date', ascending: false);

    return (rows as List<dynamic>)
        .map((r) => ActualExpense.fromSupabase(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(ActualExpense expense, String householdId) async {
    await _client
        .from('actual_expenses')
        .insert(expense.toSupabase(householdId));
  }

  Future<void> update(ActualExpense expense) async {
    await _client.from('actual_expenses').update({
      'category': expense.category,
      'amount': expense.amount,
      'expense_date':
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}',
      'description': expense.description,
      'month_key': expense.monthKey,
      'attachment_urls': expense.attachmentUrls,
      'location_lat': expense.locationLat,
      'location_lng': expense.locationLng,
      'location_address': expense.locationAddress,
    }).eq('id', expense.id);
  }

  /// Uploads [files] to Supabase Storage under
  /// `expense-attachments/$householdId/$expenseId/` and returns the public URLs.
  ///
  /// Handles missing bucket gracefully by logging and returning an empty list.
  Future<List<String>> uploadAttachments(
    List<File> files,
    String householdId,
    String expenseId,
  ) async {
    if (files.isEmpty) return [];

    final urls = <String>[];
    const bucket = 'expense-attachments';

    for (final file in files) {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final storagePath = '$householdId/$expenseId/$fileName';

      try {
        await _client.storage.from(bucket).upload(
              storagePath,
              file,
              fileOptions: const FileOptions(upsert: true),
            );
        final publicUrl =
            _client.storage.from(bucket).getPublicUrl(storagePath);
        urls.add(publicUrl);
      } catch (e) {
        LogService.error('Failed to upload attachment $fileName', e);
        // Continue with remaining files rather than aborting the whole batch.
      }
    }

    return urls;
  }

  Future<void> delete(String id) async {
    await _client.from('actual_expenses').delete().eq('id', id);
  }

  Future<Map<String, List<ActualExpense>>> loadHistory(
      String householdId, {int months = 12}) async {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month - months + 1);
    final cutoffKey = '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}';

    final rows = await _client
        .from('actual_expenses')
        .select()
        .eq('household_id', householdId)
        .gte('month_key', cutoffKey)
        .order('expense_date', ascending: false);

    final expenses = (rows as List<dynamic>)
        .map((r) => ActualExpense.fromSupabase(r as Map<String, dynamic>))
        .toList();

    final map = <String, List<ActualExpense>>{};
    for (final e in expenses) {
      map.putIfAbsent(e.monthKey, () => []).add(e);
    }
    return map;
  }
}
