import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/meal_planner.dart';

abstract class MealPlanRepository {
  Future<List<Map<String, dynamic>>> loadRecipeRows();
  Future<MealPlan?> loadPlan(String householdId, int month, int year);
  Future<void> savePlan(MealPlan plan, String householdId);
  Future<void> clearPlan(String householdId, int month, int year);
}

class SupabaseMealPlanRepository implements MealPlanRepository {
  final SupabaseClient _client;

  SupabaseMealPlanRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<List<Map<String, dynamic>>> loadRecipeRows() async {
    final rows = await _client
        .from('recipes')
        .select('*, recipe_ingredients(*)')
        .order('name');
    return (rows as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Future<MealPlan?> loadPlan(String householdId, int month, int year) async {
    final row = await _client
        .from('meal_plans')
        .select('plan_json')
        .eq('household_id', householdId)
        .eq('month', month)
        .eq('year', year)
        .maybeSingle();

    if (row == null) return null;
    try {
      return MealPlan.fromJsonString(row['plan_json'] as String);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> savePlan(MealPlan plan, String householdId) {
    return _client.from('meal_plans').upsert({
      'household_id': householdId,
      'month': plan.month,
      'year': plan.year,
      'plan_json': plan.toJsonString(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> clearPlan(String householdId, int month, int year) {
    return _client
        .from('meal_plans')
        .delete()
        .eq('household_id', householdId)
        .eq('month', month)
        .eq('year', year);
  }
}

abstract class MealPlannerAiRepository {
  Future<({int status, Object? data})> invokeChat(Map<String, dynamic> body);
}

class SupabaseMealPlannerAiRepository implements MealPlannerAiRepository {
  final SupabaseClient _client;
  final String _edgeFunctionName;

  SupabaseMealPlannerAiRepository({
    SupabaseClient? client,
    String edgeFunctionName = 'openai-chat',
  }) : _client = client ?? Supabase.instance.client,
       _edgeFunctionName = edgeFunctionName;

  @override
  Future<({int status, Object? data})> invokeChat(Map<String, dynamic> body) async {
    final accessToken = _client.auth.currentSession?.accessToken;
    if (accessToken == null || accessToken.trim().isEmpty) {
      throw Exception(
        'Sessao expirada ou utilizador nao autenticado. '
        'Inicie sessao novamente para usar o Planeador de Refeicoes.',
      );
    }

    final response = await _client.functions.invoke(
      _edgeFunctionName,
      headers: {'Authorization': 'Bearer $accessToken'},
      body: body,
    );
    return (status: response.status, data: response.data);
  }
}
