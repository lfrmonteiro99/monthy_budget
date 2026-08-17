import '../../models/meal_planner.dart';
import '../local/qa_local_store.dart';
import '../meal_repository.dart';
import 'qa_collections.dart';

class QaMealPlanRepository implements MealPlanRepository {
  QaMealPlanRepository(this._store, {required DateTime Function() now})
    : _now = now;

  final QaLocalStore _store;
  final DateTime Function() _now;

  static String _docId(int month, int year) => '$year-$month';

  /// Intentionally empty: returning no remote recipes makes
  /// [MealPlannerService.loadCatalog] fall through to its bundled-asset tier,
  /// which already ships a full deterministic catalog.
  @override
  Future<List<Map<String, dynamic>>> loadRecipeRows() async => const [];

  @override
  Future<MealPlan?> loadPlan(String householdId, int month, int year) async {
    final row = await _store.get(
      QaCollections.mealPlans,
      householdId,
      _docId(month, year),
    );
    if (row == null) return null;
    try {
      return MealPlan.fromJsonString(row['plan_json'] as String);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> savePlan(MealPlan plan, String householdId) {
    return _store
        .put(QaCollections.mealPlans, householdId, _docId(plan.month, plan.year), {
          'household_id': householdId,
          'month': plan.month,
          'year': plan.year,
          'plan_json': plan.toJsonString(),
          'updated_at': _now().toIso8601String(),
        });
  }

  @override
  Future<void> clearPlan(String householdId, int month, int year) {
    return _store.delete(
      QaCollections.mealPlans,
      householdId,
      _docId(month, year),
    );
  }
}

/// There is no AI backend in QA. Returning a stable non-200 keeps callers on
/// their existing failure paths instead of faking generated content.
class QaMealPlannerAiRepository implements MealPlannerAiRepository {
  const QaMealPlannerAiRepository();

  @override
  Future<({int status, Object? data})> invokeChat(
    Map<String, dynamic> body,
  ) async {
    return (
      status: 503,
      data: <String, dynamic>{'error': 'AI is unavailable in QA mode'},
    );
  }
}
