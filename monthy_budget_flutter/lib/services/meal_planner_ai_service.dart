import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meal_planner.dart';

class MealPlannerAiService {
  static const _edgeFunctionName = 'openai-chat';
  static const _model = 'gpt-4o-mini';
  static const _cacheKey = 'ai_recipe_cache';
  final _client = Supabase.instance.client;

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
      final content = await _requestChatCompletion(
        messages: [
          {'role': 'system', 'content': _systemPrompt(locale)},
          {'role': 'user', 'content': prompt},
        ],
        maxTokens: 600,
        temperature: 0.7,
      );
      final clean = content.replaceAll(RegExp(r'```json|```'), '').trim();
      final parsed = jsonDecode(clean) as Map<String, dynamic>;
      final result = RecipeAiContent.fromJson(parsed);
      _cache[cacheKey] = result;
      _persistCache(); // fire-and-forget
      return result;
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
    if (weekRecipes.isEmpty) return null;

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
      final content = await _requestChatCompletion(
        messages: [
          {'role': 'system', 'content': _systemPrompt(locale)},
          {'role': 'user', 'content': prompt},
        ],
        maxTokens: 400,
        temperature: 0.5,
      );
      final clean = content.replaceAll(RegExp(r'```json|```'), '').trim();
      final parsed = jsonDecode(clean) as Map<String, dynamic>;
      return WeeklyNutritionSummary.fromJson(parsed);
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
    if (batchRecipes.isEmpty) return null;

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
      final content = await _requestChatCompletion(
        messages: [
          {'role': 'system', 'content': _systemPrompt(locale)},
          {'role': 'user', 'content': prompt},
        ],
        maxTokens: 600,
        temperature: 0.6,
      );
      final clean = content.replaceAll(RegExp(r'```json|```'), '').trim();
      final parsed = jsonDecode(clean) as Map<String, dynamic>;
      final plan = BatchCookingPlan.fromJson(parsed);
      if (plan.prepOrder.isNotEmpty) return plan;
    } catch (_) {
      // Fall back to a deterministic local guide when AI is unavailable.
    }
    return buildLocalBatchPlan(
      batchRecipes: batchRecipes,
      nPessoas: nPessoas,
      locale: locale,
    );
  }

  /// Adapt a recipe's prep steps and quantities after substituting an ingredient.
  /// Returns adapted prep steps or null on failure.
  Future<List<String>?> adaptRecipeForSubstitution({
    required String apiKey,
    required Recipe recipe,
    required Ingredient oldIngredient,
    required Ingredient newIngredient,
    required Map<String, Ingredient> ingredientMap,
    required int nPessoas,
    String locale = 'pt',
  }) async {
    final ingList = recipe.ingredients.map((ri) {
      final ing = ingredientMap[ri.ingredientId];
      if (ing == null) return '';
      final scaled = ri.quantity * nPessoas / recipe.servings;
      final name = ri.ingredientId == oldIngredient.id ? newIngredient.name : ing.name;
      return '$name ${scaled.toStringAsFixed(1)} ${ing.unit}';
    }).where((s) => s.isNotEmpty).join(', ');

    final prompt = '''
Recipe: ${recipe.name}
For $nPessoas people.
Original ingredient: ${oldIngredient.name}
Replacement ingredient: ${newIngredient.name}
Updated ingredients: $ingList

Adapt the cooking steps for this substitution. Respond ONLY with valid JSON:
{
  "steps": ["step 1", "step 2", "step 3"]
}
''';

    try {
      final content = await _requestChatCompletion(
        messages: [
          {'role': 'system', 'content': _systemPrompt(locale)},
          {'role': 'user', 'content': prompt},
        ],
        maxTokens: 400,
        temperature: 0.6,
      );
      final clean = content.replaceAll(RegExp(r'```json|```'), '').trim();
      final parsed = jsonDecode(clean) as Map<String, dynamic>;
      final steps = (parsed['steps'] as List<dynamic>?)?.cast<String>();
      return steps;
    } catch (_) {
      // Best-effort; return null on failure
    }
    return null;
  }

  Future<String> _requestChatCompletion({
    required List<Map<String, String>> messages,
    int maxTokens = 600,
    double temperature = 0.6,
  }) async {
    final authHeaders = _buildEdgeAuthHeaders();
    final response = await _client.functions.invoke(
      _edgeFunctionName,
      headers: authHeaders,
      body: {
        'model': _model,
        'messages': messages,
        'max_tokens': maxTokens,
        'temperature': temperature,
      },
    );
    final data = response.data;
    if (response.status != 200 || data is! Map<String, dynamic>) {
      throw Exception('Falha ao processar pedido de IA');
    }
    final content = data['content']?.toString().trim() ?? '';
    if (content.isEmpty) {
      throw Exception('Resposta vazia da IA');
    }
    return content;
  }

  Map<String, String> _buildEdgeAuthHeaders() {
    final accessToken = _client.auth.currentSession?.accessToken;
    if (accessToken == null || accessToken.trim().isEmpty) {
      throw Exception(
        'Sessao expirada ou utilizador nao autenticado. '
        'Inicie sessao novamente para usar o Planeador de Refeicoes.',
      );
    }
    return {'Authorization': 'Bearer $accessToken'};
  }

  static BatchCookingPlan buildLocalBatchPlan({
    required List<Recipe> batchRecipes,
    required int nPessoas,
    String locale = 'pt',
  }) {
    final recipes = batchRecipes.toSet().toList()
      ..sort((a, b) {
        final prepDiff = b.prepMinutes.compareTo(a.prepMinutes);
        if (prepDiff != 0) return prepDiff;
        return a.name.compareTo(b.name);
      });

    final recipeNames = recipes.map((r) => r.name).toList(growable: false);
    final sharedIngredients = _sharedIngredientIds(recipes);
    final hasOven = recipes.any((r) => r.requiresEquipment.contains('oven'));
    final activeMinutes = recipes.fold<int>(0, (sum, r) => sum + r.prepMinutes);
    final longestRecipeMinutes = recipes.fold<int>(
      0,
      (max, r) => r.prepMinutes > max ? r.prepMinutes : max,
    );
    final estimatedMinutes = recipes.length == 1
        ? activeMinutes
        : longestRecipeMinutes +
            ((activeMinutes - longestRecipeMinutes) * 0.6).round();

    final prepOrder = <String>[
      if (hasOven)
        _batchText(
          locale,
          pt:
              'Aquece o forno e prepara recipientes para ${recipeNames.join(', ')}.',
          en:
              'Preheat the oven and set out containers for ${recipeNames.join(', ')}.',
          es:
              'Precalienta el horno y prepara recipientes para ${recipeNames.join(', ')}.',
          fr:
              'Préchauffe le four et prépare des boîtes pour ${recipeNames.join(', ')}.',
        ),
      _batchText(
        locale,
        pt:
            'Separa todos os ingredientes e ajusta as quantidades para $nPessoas pessoas antes de começares.',
        en:
            'Measure all ingredients and scale the quantities for $nPessoas people before starting.',
        es:
            'Separa todos los ingredientes y ajusta las cantidades para $nPessoas personas antes de empezar.',
        fr:
            'Prépare tous les ingrédients et ajuste les quantités pour $nPessoas personnes avant de commencer.',
      ),
      if (sharedIngredients.isNotEmpty)
        _batchText(
          locale,
          pt:
              'Prepara primeiro os ingredientes repetidos (${sharedIngredients.join(', ')}) para os usares em várias receitas.',
          en:
              'Prep the repeated ingredients first (${sharedIngredients.join(', ')}) so you can reuse them across recipes.',
          es:
              'Prepara primero los ingredientes repetidos (${sharedIngredients.join(', ')}) para reutilizarlos en varias recetas.',
          fr:
              'Prépare d\'abord les ingrédients communs (${sharedIngredients.join(', ')}) pour les réutiliser dans plusieurs recettes.',
        ),
      ...recipes.map((recipe) => _recipePrepStep(recipe, locale, nPessoas)),
      _batchText(
        locale,
        pt:
            'Divide as porções em caixas, deixa arrefecer e guarda no frigorífico para os próximos dias.',
        en:
            'Portion everything into containers, let it cool, and refrigerate it for the next few days.',
        es:
            'Reparte las porciones en recipientes, deja enfriar y guarda en la nevera para los próximos días.',
        fr:
            'Répartis les portions en boîtes, laisse refroidir et garde au réfrigérateur pour les prochains jours.',
      ),
    ];

    final parallelTips = <String>[
      if (recipes.length > 1)
        _batchText(
          locale,
          pt:
              'Enquanto a receita mais demorada cozinha, avança com os cortes e bases das restantes.',
          en:
              'While the longest recipe cooks, use that time to prep the remaining dishes.',
          es:
              'Mientras se cocina la receta más larga, adelanta los cortes y bases de las demás.',
          fr:
              'Pendant que la recette la plus longue cuit, avance sur les découpes et bases des autres.',
        ),
      if (hasOven)
        _batchText(
          locale,
          pt:
              'Agrupa tudo o que vai ao forno na mesma fase para evitar pré-aquecimentos repetidos.',
          en:
              'Group all oven work together to avoid repeated preheating cycles.',
          es:
              'Agrupa todo lo que va al horno en la misma fase para evitar precalentados repetidos.',
          fr:
              'Regroupe tout ce qui va au four dans la même phase pour éviter plusieurs préchauffages.',
        ),
      if (sharedIngredients.isNotEmpty)
        _batchText(
          locale,
          pt:
              'Guarda parte dos aromáticos e legumes já preparados para acelerar os reaquecimentos durante a semana.',
          en:
              'Keep part of the prepped aromatics and vegetables ready to speed up reheating later in the week.',
          es:
              'Guarda parte de los aromáticos y verduras ya preparados para acelerar el recalentado durante la semana.',
          fr:
              'Garde une partie des aromatiques et légumes déjà prêts pour accélérer les réchauffages pendant la semaine.',
        ),
    ];

    return BatchCookingPlan(
      prepOrder: prepOrder,
      totalTimeEstimate: _formatDuration(estimatedMinutes),
      parallelTips: parallelTips,
    );
  }

  static List<String> _sharedIngredientIds(List<Recipe> recipes) {
    final counts = <String, int>{};
    for (final recipe in recipes) {
      for (final ingredient in recipe.ingredients
          .map((ri) => ri.ingredientId)
          .toSet()) {
        counts.update(ingredient, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    final shared = counts.entries
        .where((entry) => entry.value > 1)
        .map((entry) => entry.key.replaceAll('_', ' '))
        .toList()
      ..sort();
    return shared.take(3).toList(growable: false);
  }

  static String _recipePrepStep(Recipe recipe, String locale, int nPessoas) {
    final equipment = recipe.requiresEquipment.isEmpty
        ? _batchText(
            locale,
            pt: 'no fogão ou bancada',
            en: 'on the hob or main workstation',
            es: 'en los fuegos o en la encimera',
            fr: 'sur les plaques ou le plan de travail',
          )
        : _equipmentText(recipe.requiresEquipment, locale);
    return _batchText(
      locale,
      pt:
          'Cozinha ${recipe.name} ($equipment) e deixa $nPessoas porções prontas. Tempo base: ${recipe.prepMinutes} min.',
      en:
          'Cook ${recipe.name} ($equipment) and portion it for $nPessoas servings. Base prep time: ${recipe.prepMinutes} min.',
      es:
          'Cocina ${recipe.name} ($equipment) y deja $nPessoas raciones listas. Tiempo base: ${recipe.prepMinutes} min.',
      fr:
          'Prépare ${recipe.name} ($equipment) et laisse $nPessoas portions prêtes. Temps de base : ${recipe.prepMinutes} min.',
    );
  }

  static String _equipmentText(List<String> equipment, String locale) {
    return equipment.map((item) {
      switch (item) {
        case 'oven':
          return _batchText(
            locale,
            pt: 'forno',
            en: 'oven',
            es: 'horno',
            fr: 'four',
          );
        case 'airFryer':
          return _batchText(
            locale,
            pt: 'air fryer',
            en: 'air fryer',
            es: 'freidora de aire',
            fr: 'air fryer',
          );
        case 'pressureCooker':
          return _batchText(
            locale,
            pt: 'panela de pressão',
            en: 'pressure cooker',
            es: 'olla a presión',
            fr: 'cocotte-minute',
          );
        case 'microwave':
          return _batchText(
            locale,
            pt: 'micro-ondas',
            en: 'microwave',
            es: 'microondas',
            fr: 'micro-ondes',
          );
        case 'foodProcessor':
          return _batchText(
            locale,
            pt: 'robot de cozinha',
            en: 'food processor',
            es: 'robot de cocina',
            fr: 'robot culinaire',
          );
        default:
          return item;
      }
    }).join(', ');
  }

  static String _formatDuration(int minutes) {
    if (minutes <= 60) return '${minutes}min';
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (remainder == 0) return '${hours}h';
    return '${hours}h${remainder.toString().padLeft(2, '0')}';
  }

  static String _batchText(
    String locale, {
    required String pt,
    required String en,
    required String es,
    required String fr,
  }) {
    switch (locale) {
      case 'pt':
        return pt;
      case 'es':
        return es;
      case 'fr':
        return fr;
      default:
        return en;
    }
  }
}
