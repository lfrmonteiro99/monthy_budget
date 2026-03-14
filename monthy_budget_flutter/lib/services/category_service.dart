import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/custom_category.dart';

class CategoryService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<CustomCategory>> load(String householdId) async {
    final rows = await _client
        .from('custom_categories')
        .select()
        .eq('household_id', householdId)
        .order('sort_order');

    return (rows as List<dynamic>)
        .map((r) =>
            CustomCategory.fromSupabase(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(CustomCategory category, String householdId) async {
    await _client
        .from('custom_categories')
        .upsert(category.toSupabase(householdId));
  }

  Future<void> delete(String id) async {
    await _client.from('custom_categories').delete().eq('id', id);
  }
}
