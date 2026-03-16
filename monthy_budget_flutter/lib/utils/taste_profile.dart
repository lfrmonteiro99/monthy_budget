import '../models/meal_planner.dart';

/// Analyzes liked/disliked recipes to extract taste preferences.
/// Used as a soft-boost during meal plan generation.
class TasteProfile {
  /// Protein IDs that appear frequently in liked recipes, ordered by frequency.
  final List<String> preferredProteins;

  /// Complexity range [min, max] preferred based on liked recipes.
  final int minComplexity;
  final int maxComplexity;

  /// Prep time range [min, max] preferred based on liked recipes.
  final int minPrepMinutes;
  final int maxPrepMinutes;

  /// Ingredient IDs that appear in disliked recipes but not in liked ones.
  final Set<String> avoidedIngredients;

  const TasteProfile({
    this.preferredProteins = const [],
    this.minComplexity = 1,
    this.maxComplexity = 5,
    this.minPrepMinutes = 0,
    this.maxPrepMinutes = 120,
    this.avoidedIngredients = const {},
  });

  bool get isEmpty => preferredProteins.isEmpty && avoidedIngredients.isEmpty;

  /// Score a recipe against this profile. Higher = better match.
  /// Range: 0.0 to 1.0.
  double scoreRecipe(Recipe recipe) {
    if (isEmpty) return 0.5; // neutral

    double score = 0.5;
    double weight = 0;

    // Protein preference: +0.3 if protein is in top 3 preferred
    if (preferredProteins.isNotEmpty) {
      final proteinIdx = preferredProteins.indexOf(recipe.proteinId);
      if (proteinIdx >= 0 && proteinIdx < 3) {
        score += 0.3 * (1.0 - proteinIdx / 3);
      }
      weight += 0.3;
    }

    // Complexity match: +0.2 if within preferred range
    if (recipe.complexity >= minComplexity && recipe.complexity <= maxComplexity) {
      score += 0.2;
    }
    weight += 0.2;

    // Prep time match: +0.2 if within preferred range
    if (recipe.prepMinutes >= minPrepMinutes && recipe.prepMinutes <= maxPrepMinutes) {
      score += 0.2;
    }
    weight += 0.2;

    // Avoided ingredients: -0.3 if recipe contains avoided ingredients
    if (avoidedIngredients.isNotEmpty) {
      final hasAvoided = recipe.ingredients.any(
        (ri) => avoidedIngredients.contains(ri.ingredientId),
      );
      if (hasAvoided) score -= 0.3;
      weight += 0.3;
    }

    return weight > 0 ? score.clamp(0.0, 1.0) : 0.5;
  }

  /// Build a TasteProfile from feedback history and the recipe catalog.
  ///
  /// [ratings] maps recipeId to 1-5 star rating. When present, ratings
  /// override feedback: rating >= 4 counts as liked, rating <= 2 as disliked.
  /// 5-star ratings give 2x weight to protein preference counting.
  static TasteProfile fromFeedback({
    required Map<String, MealFeedback> feedback,
    required Map<String, Recipe> recipeMap,
    Map<String, int> ratings = const {},
  }) {
    if (feedback.isEmpty && ratings.isEmpty) return const TasteProfile();

    final likedRecipes = <Recipe>[];
    final dislikedRecipes = <Recipe>[];

    // Collect all recipe IDs from both feedback and ratings
    final allIds = <String>{...feedback.keys, ...ratings.keys};
    for (final id in allIds) {
      final recipe = recipeMap[id];
      if (recipe == null) continue;
      final rating = ratings[id];
      final fb = feedback[id];
      if (rating != null) {
        // Rating takes precedence
        if (rating >= 4) likedRecipes.add(recipe);
        if (rating <= 2) dislikedRecipes.add(recipe);
      } else if (fb != null) {
        if (fb == MealFeedback.liked) likedRecipes.add(recipe);
        if (fb == MealFeedback.disliked) dislikedRecipes.add(recipe);
      }
    }

    if (likedRecipes.isEmpty && dislikedRecipes.isEmpty) {
      return const TasteProfile();
    }

    // Preferred proteins: frequency-sorted from liked recipes, weighted by rating
    final proteinCounts = <String, double>{};
    for (final r in likedRecipes) {
      final rating = ratings[r.id] ?? 4; // default liked = 4
      final weight = rating >= 5 ? 2.0 : 1.0; // 5-star = 2x weight
      proteinCounts.update(r.proteinId, (v) => v + weight, ifAbsent: () => weight);
    }
    final preferredProteins = proteinCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Complexity range from liked recipes
    int minComplexity = 1;
    int maxComplexity = 5;
    if (likedRecipes.isNotEmpty) {
      final complexities = likedRecipes.map((r) => r.complexity).toList()..sort();
      minComplexity = complexities.first;
      maxComplexity = complexities.last;
    }

    // Prep time range from liked recipes
    int minPrep = 0;
    int maxPrep = 120;
    if (likedRecipes.isNotEmpty) {
      final preps = likedRecipes.map((r) => r.prepMinutes).toList()..sort();
      minPrep = preps.first;
      maxPrep = preps.last;
    }

    // Avoided ingredients: in disliked but not in liked
    final likedIngredients = <String>{};
    for (final r in likedRecipes) {
      for (final ri in r.ingredients) {
        likedIngredients.add(ri.ingredientId);
      }
    }
    final dislikedIngredients = <String>{};
    for (final r in dislikedRecipes) {
      for (final ri in r.ingredients) {
        dislikedIngredients.add(ri.ingredientId);
      }
    }
    final avoided = dislikedIngredients.difference(likedIngredients);

    return TasteProfile(
      preferredProteins: preferredProteins.map((e) => e.key).toList(),
      minComplexity: minComplexity,
      maxComplexity: maxComplexity,
      minPrepMinutes: minPrep,
      maxPrepMinutes: maxPrep,
      avoidedIngredients: avoided,
    );
  }
}
