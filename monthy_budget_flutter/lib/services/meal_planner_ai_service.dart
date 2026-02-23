import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_planner.dart';

class MealPlannerAiService {
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';

  // In-memory cache: recipeId → content
  final Map<String, RecipeAiContent> _cache = {};

  Future<RecipeAiContent?> enrichRecipe({
    required String apiKey,
    required Recipe recipe,
    required Map<String, Ingredient> ingredientMap,
    required int nPessoas,
  }) async {
    if (apiKey.isEmpty) return null;
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
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: jsonEncode({
              'model': _model,
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
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final content = (data['choices'] as List).first['message']['content'] as String;
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
