import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_planner.dart';

class MealPlannerAiService {
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';
  static const _cacheKey = 'ai_recipe_cache';

  // In-memory cache: recipeId -> content
  final Map<String, RecipeAiContent> _cache = {};

  static String _systemPrompt(String locale) {
    switch (locale) {
      case 'pt':
        return 'És um chef português. Responde sempre em português europeu. Responde APENAS com JSON válido, sem texto extra.';
      case 'es':
        return 'Eres un chef. Responde siempre en español. Responde SOLO con JSON válido, sin texto extra.';
      case 'fr':
        return 'Tu es un chef. Réponds toujours en français. Réponds UNIQUEMENT avec du JSON valide, sans texte supplémentaire.';
      default:
        return 'You are a chef. Always respond in English. Respond ONLY with valid JSON, no extra text.';
    }
  }

  /// Load persisted cache from SharedPreferences into memory.
  Future<void> loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in map.entries) {
          _cache[entry.key] =
              RecipeAiContent.fromJson(entry.value as Map<String, dynamic>);
        }
      }
    } catch (_) {
      // Cache load is best-effort
    }
  }

  Future<void> _persistCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = _cache.map((k, v) => MapEntry(k, v.toJson()));
      await prefs.setString(_cacheKey, jsonEncode(map));
    } catch (_) {
      // Persistence is best-effort
    }
  }

  /// Public getter for pre-populating UI from persisted cache.
  RecipeAiContent? getCached(String recipeId, {String locale = 'pt'}) =>
      _cache['${recipeId}_$locale'];

  Future<RecipeAiContent?> enrichRecipe({
    required String apiKey,
    required Recipe recipe,
    required Map<String, Ingredient> ingredientMap,
    required int nPessoas,
    String locale = 'pt',
  }) async {
    if (apiKey.isEmpty) return null;
    final cacheKey = '${recipe.id}_$locale';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey];

    final ingList = recipe.ingredients.map((ri) {
      final ing = ingredientMap[ri.ingredientId];
      if (ing == null) return '';
      final scaled = ri.quantity * nPessoas / recipe.servings;
      return '${ing.name} ${scaled.toStringAsFixed(1)} ${ing.unit}';
    }).where((s) => s.isNotEmpty).join(', ');

    final prompt = '''
Recipe: ${recipe.name}
For $nPessoas people.
Ingredients: $ingList

Respond ONLY with valid JSON matching this schema:
{
  "steps": ["step 1", "step 2", "step 3"],
  "tip": "a short cooking tip",
  "variation": "a possible variation",
  "leftoverIdea": "how to transform leftovers into a new dish",
  "pairingSuggestion": "a side dish or drink that pairs well",
  "storageInfo": "how to store and how long it keeps"
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
                  'content': _systemPrompt(locale),
                },
                {'role': 'user', 'content': prompt},
              ],
              'max_tokens': 600,
              'temperature': 0.7,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final content =
            (data['choices'] as List).first['message']['content'] as String;
        final clean = content.replaceAll(RegExp(r'```json|```'), '').trim();
        final parsed = jsonDecode(clean) as Map<String, dynamic>;
        final result = RecipeAiContent.fromJson(parsed);
        _cache[cacheKey] = result;
        _persistCache(); // fire-and-forget
        return result;
      }
    } catch (_) {
      // Enrichment is best-effort; fail silently
    }
    return null;
  }

  /// Analyze weekly nutrition against user targets.
  Future<WeeklyNutritionSummary?> analyzeWeeklyNutrition({
    required String apiKey,
    required List<Recipe> weekRecipes,
    required int nPessoas,
    int? targetKcal,
    int? targetProteinG,
    int? targetFiberG,
    String locale = 'pt',
  }) async {
    if (apiKey.isEmpty || weekRecipes.isEmpty) return null;

    int totalKcal = 0;
    double totalProtein = 0;
    double totalFiber = 0;
    int count = 0;

    for (final r in weekRecipes) {
      if (r.nutrition != null) {
        totalKcal += r.nutrition!.kcal;
        totalProtein += r.nutrition!.proteinG;
        totalFiber += r.nutrition!.fiberG;
        count++;
      }
    }

    if (count == 0) return null;

    final avgKcal = (totalKcal / count).round();
    final avgProtein = (totalProtein / count).round();
    final avgFiber = (totalFiber / count).round();

    final targetsInfo = StringBuffer();
    if (targetKcal != null) targetsInfo.write('Target kcal/meal: $targetKcal. ');
    if (targetProteinG != null) {
      targetsInfo.write('Target protein/meal: ${targetProteinG}g. ');
    }
    if (targetFiberG != null) {
      targetsInfo.write('Target fiber/meal: ${targetFiberG}g. ');
    }

    final prompt = '''
Weekly meal plan nutrition averages (per meal, for $nPessoas people):
- Average kcal: $avgKcal
- Average protein: ${avgProtein}g
- Average fiber: ${avgFiber}g
- Total meals: ${weekRecipes.length}
${targetsInfo.toString()}

Analyze this week's nutrition. Respond ONLY with valid JSON:
{
  "highlights": ["positive point 1", "positive point 2"],
  "concerns": ["concern 1", "concern 2"],
  "overallScore": 7
}

Score 1-10 where 10 is excellent balance. Max 3 highlights, max 3 concerns. Be specific and actionable.
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
                {'role': 'system', 'content': _systemPrompt(locale)},
                {'role': 'user', 'content': prompt},
              ],
              'max_tokens': 400,
              'temperature': 0.5,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final content =
            (data['choices'] as List).first['message']['content'] as String;
        final clean = content.replaceAll(RegExp(r'```json|```'), '').trim();
        final parsed = jsonDecode(clean) as Map<String, dynamic>;
        return WeeklyNutritionSummary.fromJson(parsed);
      }
    } catch (_) {
      // Best-effort
    }
    return null;
  }

  /// Generate batch cooking prep plan for the week.
  Future<BatchCookingPlan?> generateBatchPlan({
    required String apiKey,
    required List<Recipe> batchRecipes,
    required int nPessoas,
    String locale = 'pt',
  }) async {
    if (apiKey.isEmpty || batchRecipes.isEmpty) return null;

    final recipeList = batchRecipes
        .map((r) =>
            '- ${r.name} (${r.prepMinutes}min, serves ${r.servings}, scale to $nPessoas)')
        .join('\n');

    final prompt = '''
These recipes can be batch-cooked for the week:
$recipeList

Create an optimal batch cooking plan. Respond ONLY with valid JSON:
{
  "prepOrder": ["Step 1: description", "Step 2: description"],
  "totalTimeEstimate": "2h30",
  "parallelTips": ["tip about what to do while X cooks"]
}

Optimize for parallel cooking (e.g. while rice cooks, prep vegetables). Be specific with timing.
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
                {'role': 'system', 'content': _systemPrompt(locale)},
                {'role': 'user', 'content': prompt},
              ],
              'max_tokens': 600,
              'temperature': 0.6,
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final content =
            (data['choices'] as List).first['message']['content'] as String;
        final clean = content.replaceAll(RegExp(r'```json|```'), '').trim();
        final parsed = jsonDecode(clean) as Map<String, dynamic>;
        return BatchCookingPlan.fromJson(parsed);
      }
    } catch (_) {
      // Best-effort
    }
    return null;
  }
}
