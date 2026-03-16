import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/utils/taste_profile.dart';

void main() {
  group('MealDay rating', () {
    test('rating stored and retrieved via JSON round-trip', () {
      final day = MealDay(dayIndex: 0, costEstimate: 5, rating: 4);
      final json = day.toJson();
      expect(json['rating'], 4);
      final restored = MealDay.fromJson(json);
      expect(restored.rating, 4);
    });

    test('rating null by default and omitted from JSON', () {
      final day = MealDay(dayIndex: 0, costEstimate: 5);
      expect(day.rating, isNull);
      final json = day.toJson();
      expect(json.containsKey('rating'), isFalse);
    });

    test('legacy JSON without rating field deserializes to null', () {
      final json = {
        'dayIndex': 1,
        'recipeId': 'frango_assado',
        'isLeftover': false,
        'costEstimate': 3.86,
        'mealType': 'dinner',
        'feedback': 'liked',
      };
      final day = MealDay.fromJson(json);
      expect(day.rating, isNull);
      expect(day.feedback, MealFeedback.liked);
    });

    test('effectiveRating uses rating when present', () {
      final day = MealDay(dayIndex: 0, costEstimate: 5, rating: 3);
      expect(day.effectiveRating, 3);
    });

    test('effectiveRating uses rating even when feedback also set', () {
      final day = MealDay(
        dayIndex: 0,
        costEstimate: 5,
        rating: 5,
        feedback: MealFeedback.disliked,
      );
      expect(day.effectiveRating, 5);
    });

    test('effectiveRating falls back to liked feedback as 4', () {
      final day = MealDay(
        dayIndex: 0,
        costEstimate: 5,
        feedback: MealFeedback.liked,
      );
      expect(day.effectiveRating, 4);
    });

    test('effectiveRating falls back to disliked feedback as 2', () {
      final day = MealDay(
        dayIndex: 0,
        costEstimate: 5,
        feedback: MealFeedback.disliked,
      );
      expect(day.effectiveRating, 2);
    });

    test('effectiveRating returns null when no feedback and no rating', () {
      final day = MealDay(dayIndex: 0, costEstimate: 5);
      expect(day.effectiveRating, isNull);
    });

    test('effectiveRating returns null for skipped feedback', () {
      final day = MealDay(
        dayIndex: 0,
        costEstimate: 5,
        feedback: MealFeedback.skipped,
      );
      expect(day.effectiveRating, isNull);
    });

    test('copyWith preserves rating', () {
      final day = MealDay(dayIndex: 0, costEstimate: 5, rating: 3);
      final copied = day.copyWith(feedback: MealFeedback.liked);
      expect(copied.rating, 3);
      expect(copied.feedback, MealFeedback.liked);
    });

    test('copyWith can set rating', () {
      final day = MealDay(dayIndex: 0, costEstimate: 5);
      final copied = day.copyWith(rating: 5);
      expect(copied.rating, 5);
    });
  });

  group('TasteProfile with ratings', () {
    Recipe makeRecipe(String id, String proteinId,
        {int complexity = 3, int prepMinutes = 30}) {
      return Recipe(
        id: id,
        name: id,
        proteinId: proteinId,
        type: RecipeType.carne,
        complexity: complexity,
        prepMinutes: prepMinutes,
        servings: 2,
        ingredients: [
          RecipeIngredient(ingredientId: '${proteinId}_ing', quantity: 200),
        ],
      );
    }

    test('5-star rating gives 2x weight to protein preference', () {
      final recipes = {
        'r1': makeRecipe('r1', 'chicken'),
        'r2': makeRecipe('r2', 'beef'),
      };
      final feedback = <String, MealFeedback>{
        'r1': MealFeedback.liked,
        'r2': MealFeedback.liked,
      };
      final ratings = <String, int>{
        'r1': 5, // 2x weight
        'r2': 4, // 1x weight
      };
      final profile = TasteProfile.fromFeedback(
        feedback: feedback,
        recipeMap: recipes,
        ratings: ratings,
      );
      // chicken should rank first due to 2x weight (2.0 vs 1.0)
      expect(profile.preferredProteins.first, 'chicken');
    });

    test('backward compat: liked without rating still works', () {
      final recipes = {
        'r1': makeRecipe('r1', 'chicken'),
        'r2': makeRecipe('r2', 'beef'),
      };
      final feedback = <String, MealFeedback>{
        'r1': MealFeedback.liked,
        'r2': MealFeedback.disliked,
      };
      final profile = TasteProfile.fromFeedback(
        feedback: feedback,
        recipeMap: recipes,
      );
      expect(profile.preferredProteins, contains('chicken'));
      expect(profile.avoidedIngredients, contains('beef_ing'));
    });

    test('rating overrides feedback: rated 5 but feedback disliked treated as liked', () {
      final recipes = {
        'r1': makeRecipe('r1', 'pork'),
      };
      final feedback = <String, MealFeedback>{
        'r1': MealFeedback.disliked,
      };
      final ratings = <String, int>{
        'r1': 5,
      };
      final profile = TasteProfile.fromFeedback(
        feedback: feedback,
        recipeMap: recipes,
        ratings: ratings,
      );
      // Rating 5 overrides disliked feedback -> treated as liked
      expect(profile.preferredProteins, contains('pork'));
      expect(profile.avoidedIngredients, isEmpty);
    });

    test('rating <= 2 treated as disliked', () {
      final recipes = {
        'r1': makeRecipe('r1', 'fish'),
      };
      final feedback = <String, MealFeedback>{
        'r1': MealFeedback.liked,
      };
      final ratings = <String, int>{
        'r1': 1,
      };
      final profile = TasteProfile.fromFeedback(
        feedback: feedback,
        recipeMap: recipes,
        ratings: ratings,
      );
      // Rating 1 overrides liked feedback -> treated as disliked
      expect(profile.preferredProteins, isEmpty);
      expect(profile.avoidedIngredients, contains('fish_ing'));
    });

    test('rating 3 is neutral: neither liked nor disliked', () {
      final recipes = {
        'r1': makeRecipe('r1', 'tofu'),
      };
      final feedback = <String, MealFeedback>{};
      final ratings = <String, int>{
        'r1': 3,
      };
      final profile = TasteProfile.fromFeedback(
        feedback: feedback,
        recipeMap: recipes,
        ratings: ratings,
      );
      // Rating 3 is neutral
      expect(profile.preferredProteins, isEmpty);
      expect(profile.avoidedIngredients, isEmpty);
    });

    test('ratings-only input with no feedback map still builds profile', () {
      final recipes = {
        'r1': makeRecipe('r1', 'chicken'),
      };
      final ratings = <String, int>{
        'r1': 5,
      };
      final profile = TasteProfile.fromFeedback(
        feedback: const {},
        recipeMap: recipes,
        ratings: ratings,
      );
      expect(profile.preferredProteins, contains('chicken'));
    });

    test('empty feedback and empty ratings returns empty profile', () {
      final profile = TasteProfile.fromFeedback(
        feedback: const {},
        recipeMap: const {},
        ratings: const {},
      );
      expect(profile.isEmpty, isTrue);
    });
  });
}
