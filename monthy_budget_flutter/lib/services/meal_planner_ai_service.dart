import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meal_planner.dart';

class MealPlannerAiService {
  final _client = Supabase.instance.client;

  // In-memory cache: recipeId → content
  final Map<String, RecipeAiContent> _cache = {};

  Future<RecipeAiContent?> enrichRecipe({
    required Recipe recipe,
    required Map<String, Ingredient> ingredientMap,
    required int nPessoas,
  }) async {
    if (_client.auth.currentUser == null) return null;
    if (_cache.containsKey(recipe.id)) return _cache[recipe.id];

    final ingList = recipe.ingredients.map((ri) {
      final ing = ingredientMap[ri.ingredientId];
      if (ing == null) return '';
      final scaled = ri.quantity * nPessoas / recipe.servings;
      return '${ing.name} ${scaled.toStringAsFixed(1)} ${ing.unit}';
    }).where((s) => s.isNotEmpty).join(', ');

    final prompt = '''
Receita: ${recipe.name}
Para $nPessoas pessoas.
Ingredientes: $ingList

Responde APENAS em JSON válido com esta estrutura:
{
  "steps": ["passo 1", "passo 2", "passo 3"],
  "tip": "uma dica curta",
  "variation": "uma variação possível"
}
''';

    try {
      final response = await _client.functions.invoke(
        'ai-chat',
        body: {
          'messages': [
            {
              'role': 'system',
              'content': 'És um chef português. Responde sempre em português europeu. '
                  'Responde APENAS com JSON válido, sem texto extra.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 400,
          'temperature': 0.7,
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        final content = data['content'] as String;
        final clean = content.replaceAll(RegExp(r'```json|```'), '').trim();
        final parsed = jsonDecode(clean) as Map<String, dynamic>;
        final result = RecipeAiContent.fromJson(parsed);
        _cache[recipe.id] = result;
        return result;
      }
    } catch (_) {
      // Enrichment is best-effort; fail silently
    }
    return null;
  }
}
