import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/services/meal_planner_service.dart';

void main() {
  group('Plan undo', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('savePreviousPlan stores plan in SharedPreferences', () async {
      final service = MealPlannerService();
      final plan = MealPlan(
        month: 3,
        year: 2026,
        nPessoas: 2,
        monthlyBudget: 300,
        days: [],
        totalEstimatedCost: 0,
        generatedAt: DateTime(2026, 3, 1),
      );
      await service.savePreviousPlan(plan);
      final restored = await service.loadPreviousPlan(3, 2026);
      expect(restored, isNotNull);
      expect(restored!.month, 3);
      expect(restored.year, 2026);
      expect(restored.nPessoas, 2);
    });

    test('loadPreviousPlan returns null when no backup exists', () async {
      final service = MealPlannerService();
      final result = await service.loadPreviousPlan(3, 2026);
      expect(result, isNull);
    });

    test('clearPreviousPlan removes backup', () async {
      final service = MealPlannerService();
      final plan = MealPlan(
        month: 3,
        year: 2026,
        nPessoas: 2,
        monthlyBudget: 300,
        days: [],
        totalEstimatedCost: 0,
        generatedAt: DateTime(2026, 3, 1),
      );
      await service.savePreviousPlan(plan);
      await service.clearPreviousPlan(3, 2026);
      final result = await service.loadPreviousPlan(3, 2026);
      expect(result, isNull);
    });

    test('only one previous plan kept per month/year', () async {
      final service = MealPlannerService();
      final plan1 = MealPlan(
        month: 3,
        year: 2026,
        nPessoas: 2,
        monthlyBudget: 300,
        days: [],
        totalEstimatedCost: 100,
        generatedAt: DateTime(2026, 3, 1),
      );
      final plan2 = MealPlan(
        month: 3,
        year: 2026,
        nPessoas: 4,
        monthlyBudget: 600,
        days: [],
        totalEstimatedCost: 200,
        generatedAt: DateTime(2026, 3, 15),
      );
      await service.savePreviousPlan(plan1);
      await service.savePreviousPlan(plan2);
      final restored = await service.loadPreviousPlan(3, 2026);
      expect(restored!.nPessoas, 4); // plan2 overwrites plan1
    });
  });
}
