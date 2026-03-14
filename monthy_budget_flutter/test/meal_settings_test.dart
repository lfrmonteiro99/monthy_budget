import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/meal_settings.dart';

void main() {
  group('MealSettings', () {
    test('fromJson uses sane defaults when payload is empty', () {
      final settings = MealSettings.fromJson(const {});

      expect(settings.enabledMeals, {MealType.lunch, MealType.dinner});
      expect(settings.objective, MealObjective.balancedHealth);
      expect(settings.availableEquipment, {
        KitchenEquipment.oven,
        KitchenEquipment.microwave,
      });
      expect(settings.maxPrepMinutes, 60);
    });

    test('copyWith supports clearing nullable fields through sentinels', () {
      final base = const MealSettings(
        householdSize: 4,
        preferredCookingWeekday: 3,
        dailyCalorieTarget: 2200,
      );

      final updated = base.copyWith(
        householdSize: null,
        preferredCookingWeekday: null,
        dailyCalorieTarget: null,
      );

      expect(updated.householdSize, isNull);
      expect(updated.preferredCookingWeekday, isNull);
      expect(updated.dailyCalorieTarget, isNull);
    });

    test('toJson and fromJson preserve key fields', () {
      const settings = MealSettings(
        enabledMeals: {MealType.breakfast, MealType.dinner},
        objective: MealObjective.highProtein,
        glutenFree: true,
        batchCookingEnabled: true,
        maxBatchDays: 3,
        eatingOutWeekdays: {6, 7},
        pinnedMeals: {'1_dinner': 'frango_assado'},
      );

      final decoded = MealSettings.fromJson(settings.toJson());

      expect(decoded.enabledMeals, {MealType.breakfast, MealType.dinner});
      expect(decoded.objective, MealObjective.highProtein);
      expect(decoded.glutenFree, isTrue);
      expect(decoded.batchCookingEnabled, isTrue);
      expect(decoded.maxBatchDays, 3);
      expect(decoded.eatingOutWeekdays, {6, 7});
      expect(decoded.pinnedMeals['1_dinner'], 'frango_assado');
    });
  });

  group('HouseholdMember', () {
    test('portionEquivalent multiplies age and activity factors', () {
      const member = HouseholdMember(
        name: 'Teen Active',
        ageGroup: AgeGroup.teen,
        activityLevel: ActivityLevel.active,
      );

      expect(member.portionEquivalent, 1.25);
    });

    test('fromJson falls back to defaults for unknown enums', () {
      final member = HouseholdMember.fromJson(const {
        'name': 'X',
        'ageGroup': 'invalid',
        'activityLevel': 'invalid',
      });

      expect(member.ageGroup, AgeGroup.adult);
      expect(member.activityLevel, ActivityLevel.moderate);
    });
  });
}
