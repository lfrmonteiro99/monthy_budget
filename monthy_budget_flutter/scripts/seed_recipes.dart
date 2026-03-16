// Script to generate seed SQL from local recipe JSON.
// Usage: dart run scripts/seed_recipes.dart > scripts/seed_recipes.sql
import 'dart:convert';
import 'dart:io';

void main() {
  final recipesJson =
      jsonDecode(File('assets/meal_planner/recipes.json').readAsStringSync())
          as List;

  print('-- Auto-generated seed data from local recipes');
  print('-- Generated at ${DateTime.now().toIso8601String()}');
  print('');
  print('BEGIN;');
  print('');

  for (final r in recipesJson) {
    final id = _escape(r['id'] as String);
    final name = _escape(r['name'] as String);
    final proteinId =
        r['proteinId'] != null ? "'${_escape(r['proteinId'] as String)}'" : 'NULL';
    final type = _escape(r['type'] as String);
    final nutrition =
        r['nutrition'] != null ? "'${_escape(jsonEncode(r['nutrition']))}'" : 'NULL';
    final prepSteps = r['prepSteps'] as List? ?? [];
    final suitableMealTypes =
        r['suitableMealTypes'] as List? ?? ['lunch', 'dinner'];
    final seasons = r['seasons'] as List? ?? [];
    final equipment = r['requiresEquipment'] as List? ?? [];

    print(
      "INSERT INTO public.recipes (id, name, protein_id, type, complexity, prep_minutes, servings, "
      "is_vegetarian, is_high_protein, is_low_carb, gluten_free, lactose_free, nut_free, shellfish_free, "
      "batch_cookable, max_batch_days, is_portable, suitable_meal_types, seasons, requires_equipment, "
      "nutrition, prep_steps, locale) VALUES ("
      "'$id', '$name', $proteinId, '$type', ${r['complexity'] ?? 3}, ${r['prepMinutes'] ?? 30}, "
      "${r['servings'] ?? 4}, ${r['isVegetarian'] ?? false}, ${r['isHighProtein'] ?? false}, "
      "${r['isLowCarb'] ?? false}, ${r['glutenFree'] ?? false}, ${r['lactoseFree'] ?? false}, "
      "${r['nutFree'] ?? true}, ${r['shellfishFree'] ?? true}, ${r['batchCookable'] ?? false}, "
      "${r['maxBatchDays'] ?? 2}, ${r['isPortable'] ?? false}, "
      "'{${suitableMealTypes.join(',')}}', '{${seasons.join(',')}}', '{${equipment.join(',')}}', "
      "${nutrition != 'NULL' ? '$nutrition::jsonb' : 'NULL'}, "
      "'{${prepSteps.map((s) => '"${_escape(s as String)}"').join(',')}}', 'pt') "
      "ON CONFLICT (id) DO NOTHING;",
    );

    // Insert ingredients
    final ingredients = r['ingredients'] as List? ?? [];
    for (final ing in ingredients) {
      print(
        "INSERT INTO public.recipe_ingredients (recipe_id, ingredient_id, quantity) VALUES ("
        "'$id', '${_escape(ing['ingredientId'] as String)}', ${ing['quantity']}) "
        "ON CONFLICT DO NOTHING;",
      );
    }
    print('');
  }

  print('COMMIT;');
}

String _escape(String s) => s.replaceAll("'", "''");
