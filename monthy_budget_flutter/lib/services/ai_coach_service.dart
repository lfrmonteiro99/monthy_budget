import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../models/coach_insight.dart';
import '../models/purchase_record.dart';
import '../repositories/household_repository.dart';
import '../repositories/local/app_database.dart';
import '../repositories/local/coach_message_storage.dart';
import '../utils/category_helpers.dart';
import '../utils/stress_index.dart';
import 'edge_function_client.dart';
import 'revenuecat_service.dart';
import '../models/subscription_state.dart';

/// Delegates to [EdgeFunctionClient.isFunctionNotFoundError].
bool shouldFallbackFromEdgeFunctionError(Object error) =>
    EdgeFunctionClient.isFunctionNotFoundError(error);

/// Delegates to [EdgeFunctionClient.isAuthError].
bool isEdgeFunctionAuthError(Object error) =>
    EdgeFunctionClient.isAuthError(error);

/// Delegates to [EdgeFunctionClient.buildErrorMessage].
String buildAiCoachRequestErrorMessage(
  Object error, {
  required bool hasApiKey,
}) =>
    EdgeFunctionClient.buildErrorMessage(error, hasApiKey: hasApiKey);

class AiCoachService {
  static const _apiKeyPref = 'openai_api_key';
  // Key used to store obfuscated API key (#769)
  static const _apiKeyObfuscatedPref = 'openai_api_key_b64';
  static const _model = 'gpt-4o-mini';
  static const _maxInsights = 20;
  static final _uuid = Uuid();
  static const _chatPrefKeyPrefix = 'coach_chat_v2_messages_';
  /// SharedPreferences key that flags migration has been completed (#763).
  static const _chatMigratedPrefKey = 'coach_chat_migrated_to_sqlite';
  static const _maxUserMessageLength = 2000;

  /// SharedPreferences key prefix for free coaching trial usage (#770).
  static const _freeTrialUsagePrefKey = 'coach_free_trial_usage';
  static const _freeTrialMonthPrefKey = 'coach_free_trial_month';

  /// Maximum free coaching interactions per month for free-tier users (#770).
  static const maxFreeInteractionsPerMonth = 3;

  /// HTTP request timeout for AI coach API calls.
  @visibleForTesting
  static Duration get httpTimeout => EdgeFunctionClient.httpTimeout;
  @visibleForTesting
  static set httpTimeout(Duration value) =>
      EdgeFunctionClient.httpTimeout = value;

  final CoachInsightRepository _insightRepository;
  final EdgeFunctionClient _edgeClient;
  final http.Client _httpClient;
  final CoachMessageStorage _messageStorage;

  AiCoachService({
    CoachInsightRepository? insightRepository,
    http.Client? httpClient,
    EdgeFunctionClient? edgeClient,
    CoachMessageStorage? messageStorage,
  })  : _insightRepository =
           insightRepository ?? SupabaseCoachInsightRepository(),
        _httpClient = httpClient ?? http.Client(),
        _edgeClient = edgeClient ??
            EdgeFunctionClient(httpClient: httpClient ?? http.Client()),
        _messageStorage =
            messageStorage ?? CoachMessageStorage(AppDatabase.instance);

  /// Sanitize user input before interpolating into prompts.
  ///
  /// Truncates to [_maxUserMessageLength] and strips sequences that could
  /// be mistaken for prompt boundaries (e.g. system-role injections).
  static String sanitizeUserInput(String input) {
    var sanitized = input.trim();
    if (sanitized.length > _maxUserMessageLength) {
      sanitized = sanitized.substring(0, _maxUserMessageLength);
    }
    // Strip common prompt-injection patterns
    sanitized = sanitized.replaceAll(RegExp(r'```system\b', caseSensitive: false), '');
    sanitized = sanitized.replaceAll(RegExp(r'\[SYSTEM\]', caseSensitive: false), '');
    sanitized = sanitized.replaceAll(RegExp(r'\[INST\]', caseSensitive: false), '');
    sanitized = sanitized.replaceAll(RegExp(r'<\|im_start\|>', caseSensitive: false), '');
    sanitized = sanitized.replaceAll(RegExp(r'<\|im_end\|>', caseSensitive: false), '');
    return sanitized;
  }

  // ── API key (device-local, base64-obfuscated) ─────────────────────────────
  // TODO(#769): Migrate to flutter_secure_storage for proper at-rest encryption.
  //             Base64 is only obfuscation — not cryptographic protection.

  /// Encode an API key for storage (base64 obfuscation).
  static String encodeApiKey(String key) => base64Encode(utf8.encode(key));

  /// Decode a stored API key. Handles legacy plain-text keys gracefully.
  static String decodeApiKey(String stored) {
    if (stored.isEmpty) return '';
    try {
      return utf8.decode(base64Decode(stored));
    } catch (_) {
      // Legacy plain-text key — return as-is for backward compatibility
      return stored;
    }
  }

  Future<String> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    // Try new obfuscated key first
    final obfuscated = prefs.getString(_apiKeyObfuscatedPref);
    if (obfuscated != null && obfuscated.isNotEmpty) {
      return decodeApiKey(obfuscated);
    }
    // Migrate legacy plain-text key if present
    final legacy = prefs.getString(_apiKeyPref) ?? '';
    if (legacy.isNotEmpty) {
      await prefs.setString(_apiKeyObfuscatedPref, encodeApiKey(legacy));
      await prefs.remove(_apiKeyPref);
    }
    return legacy;
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = key.trim();
    await prefs.setString(_apiKeyObfuscatedPref, encodeApiKey(trimmed));
    // Remove legacy plain-text key if it exists
    await prefs.remove(_apiKeyPref);
  }

  /// Gate for AI features.
  ///
  /// Returns `true` if the user has an active trial or a premium/family
  /// subscription via RevenueCat. Free-tier users without a trial are blocked.
  Future<bool> canUseAI() async {
    final tier = await RevenueCatService.getCurrentTier();
    if (tier == SubscriptionTier.premium || tier == SubscriptionTier.family) {
      return true;
    }
    // Free tier — allow only if the user has a local API key configured
    final key = await loadApiKey();
    return key.trim().isNotEmpty;
  }

  // ── Insight history (household-shared via Supabase) ────────────────────────

  Future<List<CoachInsight>> loadInsights(String householdId) async {
    try {
      return await _insightRepository.loadInsights(
        householdId,
        limit: _maxInsights,
      );
    } catch (_) {
      return [];
    }
  }

  Future<List<CoachInsight>> _persistInsight(
      CoachInsight insight, String householdId) async {
    return _insightRepository.saveInsight(insight, householdId);
  }

  Future<List<CoachInsight>> deleteInsight(
      String id, String householdId) async {
    return _insightRepository.deleteInsight(id, householdId);
  }

  Future<void> clearInsights(String householdId) async {
    await _insightRepository.clearInsights(householdId);
  }

  /// Load conversation from SQLite, migrating from SharedPreferences on first
  /// call if legacy data exists (#763).
  Future<List<CoachChatMessage>> loadConversation(String householdId) async {
    await _migrateConversationIfNeeded(householdId);
    final rows = await _messageStorage.loadMessages(householdId);
    return rows
        .map((r) => CoachChatMessage(
              role: r.role,
              content: r.content,
              timestamp: r.timestamp,
            ))
        .toList();
  }

  Future<void> saveConversation(
    String householdId,
    List<CoachChatMessage> messages,
  ) async {
    await _messageStorage.clearMessages(householdId);
    final companions = messages
        .map((m) => CoachMessagesCompanion.insert(
              id: _uuid.v4(),
              householdId: householdId,
              role: m.role,
              content: m.content,
              timestamp: m.timestamp,
            ))
        .toList();
    await _messageStorage.insertAll(companions);
    await _messageStorage.pruneMessages(householdId);
  }

  Future<void> clearConversation(String householdId) async {
    await _messageStorage.clearMessages(householdId);
  }

  /// Migrate legacy SharedPreferences conversation to SQLite (#763).
  Future<void> _migrateConversationIfNeeded(String householdId) async {
    final prefs = await SharedPreferences.getInstance();
    final migrationKey = '$_chatMigratedPrefKey:$householdId';
    if (prefs.getBool(migrationKey) == true) return;

    final raw = prefs.getString('$_chatPrefKeyPrefix$householdId');
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final messages = decoded
              .whereType<Map>()
              .map((item) => CoachChatMessage.fromJson(
                    item.map(
                        (key, value) => MapEntry(key.toString(), value)),
                  ))
              .toList();
          if (messages.isNotEmpty) {
            final companions = messages
                .map((m) => CoachMessagesCompanion.insert(
                      id: _uuid.v4(),
                      householdId: householdId,
                      role: m.role,
                      content: m.content,
                      timestamp: m.timestamp,
                    ))
                .toList();
            await _messageStorage.insertAll(companions);
            await _messageStorage.pruneMessages(householdId);
          }
        }
      } catch (_) {
        // Corrupt data -- skip migration, start fresh
      }
      await prefs.remove('$_chatPrefKeyPrefix$householdId');
    }
    await prefs.setBool(migrationKey, true);
  }

  // -- Free coaching trial (#770) ---------------------------------------------

  /// Returns the number of free interactions used this month.
  Future<int> getFreeTrialUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final currentMonth = _currentMonthKey();
    final storedMonth = prefs.getString(_freeTrialMonthPrefKey) ?? '';
    if (storedMonth != currentMonth) return 0;
    return prefs.getInt(_freeTrialUsagePrefKey) ?? 0;
  }

  /// Returns remaining free interactions this month.
  Future<int> getFreeTrialRemaining() async {
    final used = await getFreeTrialUsage();
    return (maxFreeInteractionsPerMonth - used)
        .clamp(0, maxFreeInteractionsPerMonth);
  }

  /// Consume one free interaction. Returns true if successful, false if
  /// exhausted.
  Future<bool> consumeFreeTrialInteraction() async {
    final prefs = await SharedPreferences.getInstance();
    final currentMonth = _currentMonthKey();
    final storedMonth = prefs.getString(_freeTrialMonthPrefKey) ?? '';

    int used;
    if (storedMonth != currentMonth) {
      used = 0;
      await prefs.setString(_freeTrialMonthPrefKey, currentMonth);
    } else {
      used = prefs.getInt(_freeTrialUsagePrefKey) ?? 0;
    }

    if (used >= maxFreeInteractionsPerMonth) return false;

    await prefs.setInt(_freeTrialUsagePrefKey, used + 1);
    return true;
  }

  /// Whether the free tier user has remaining trial interactions this month.
  Future<bool> hasFreeTrialRemaining() async {
    final remaining = await getFreeTrialRemaining();
    return remaining > 0;
  }

  static String _currentMonthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<String> sendChatMessage({
    required String apiKey,
    required String userMessage,
    required List<CoachChatMessage> history,
    required int contextWindow,
    required AppSettings settings,
    required BudgetSummary summary,
    required PurchaseHistory purchaseHistory,
    int maxTokens = 1000,
    CoachMode? effectiveMode,
    String? lastMicroAction,
    DateTime? lastMicroActionDate,
  }) async {
    final safeMessage = sanitizeUserInput(userMessage);
    var groundedUserMessage = _buildGroundedUserMessage(
      userMessage: safeMessage,
      settings: settings,
      summary: summary,
      purchaseHistory: purchaseHistory,
      effectiveMode: effectiveMode,
    );

    // Feature #5: Inject micro-action follow-up context for Pro mode
    if (effectiveMode == CoachMode.pro &&
        lastMicroAction != null &&
        history.isEmpty) {
      final dateStr = lastMicroActionDate != null
          ? '${lastMicroActionDate.day.toString().padLeft(2, '0')}/${lastMicroActionDate.month.toString().padLeft(2, '0')}/${lastMicroActionDate.year}'
          : '';
      groundedUserMessage =
          '[Contexto de continuidade] Na última sessão Pro ($dateStr), '
          'a micro-ação sugerida foi: "$lastMicroAction". '
          'Pergunta ao utilizador se conseguiu cumprir antes de prosseguir com a resposta.\n\n'
          '$groundedUserMessage';
    }

    final messages = buildBoundedChatMessages(
      history: history,
      userMessage: groundedUserMessage,
      contextWindow: contextWindow,
      systemPrompt: _buildChatSystemPrompt(
        settings: settings,
        summary: summary,
        purchaseHistory: purchaseHistory,
        effectiveMode: effectiveMode,
      ),
    );
    return _requestChatCompletion(
      apiKey: apiKey,
      messages: messages,
      maxTokens: maxTokens,
      temperature: 0.5,
    );
  }

  String _buildGroundedUserMessage({
    required String userMessage,
    required AppSettings settings,
    required BudgetSummary summary,
    required PurchaseHistory purchaseHistory,
    CoachMode? effectiveMode,
  }) {
    final now = DateTime.now();
    final monthRecords = purchaseHistory.records
        .where((r) => r.date.year == now.year && r.date.month == now.month)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // All enabled expense categories (no limit)
    final topExpenses = settings.expenses
        .where((e) => e.enabled && e.amount > 0)
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final topExpensesText = topExpenses
        .map((e) => '- ${categoryLabel(e.category)}: ${e.amount.toStringAsFixed(2)} EUR')
        .join('\n');

    // Transaction limit scales with mode
    final txLimit = switch (effectiveMode) {
      CoachMode.pro => 25,
      CoachMode.plus => 15,
      _ => 8,
    };

    final recentPurchasesText = monthRecords
        .take(txLimit)
        .map((r) {
          final date =
              '${r.date.day.toString().padLeft(2, '0')}/${r.date.month.toString().padLeft(2, '0')}';
          final itemNames =
              r.items.isNotEmpty ? ' [${r.items.join(", ")}]' : '';
          return '- $date: ${r.amount.toStringAsFixed(2)} EUR '
              '(${r.itemCount} itens)$itemNames';
        })
        .join('\n');

    return '''
Pergunta do utilizador:
$userMessage

Dados reais da app (usar estes valores na resposta):
- Liquido mensal: ${summary.totalNetWithMeal.toStringAsFixed(2)} EUR
- Despesas fixas: ${summary.totalExpenses.toStringAsFixed(2)} EUR
- Poupanca mensal: ${summary.netLiquidity.toStringAsFixed(2)} EUR

Categorias de despesa:
${topExpensesText.isEmpty ? '- sem dados' : topExpensesText}

Compras recentes deste mes ($txLimit mais recentes):
${recentPurchasesText.isEmpty ? '- sem compras registadas' : recentPurchasesText}
''';
  }

  // ── Analysis ───────────────────────────────────────────────────────────────

  /// Returns the new [CoachInsight] and the updated full list.
  Future<({CoachInsight insight, List<CoachInsight> history})> analyze({
    required String apiKey,
    required String householdId,
    required AppSettings settings,
    required BudgetSummary summary,
    required PurchaseHistory purchaseHistory,
    int maxTokens = 1000,
  }) async {
    final stress = calculateStressIndex(
      summary: summary,
      purchaseHistory: purchaseHistory,
      settings: settings,
    );
    final prompt = _buildPrompt(settings, summary, purchaseHistory, stress);

    final content = await _requestChatCompletion(
      apiKey: apiKey,
      messages: [
        {
          'role': 'system',
          'content':
              'És um analista financeiro pessoal para utilizadores portugueses. '
              'Responde sempre em português europeu. Sê directo e analítico — '
              'usa sempre números concretos do contexto fornecido. '
              'Estrutura a resposta exactamente nas 3 partes pedidas. '
              'Não introduzas dados, benchmarks ou referências externas que não foram fornecidos.',
        },
        {'role': 'user', 'content': prompt},
      ],
      maxTokens: maxTokens,
      temperature: 0.5,
    );

    final insight = CoachInsight(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      content: content,
      stressScore: stress.score,
    );
    final history = await _persistInsight(insight, householdId);
    return (insight: insight, history: history);
  }

  Future<({CoachInsight insight, List<CoachInsight> history})> analyzeMidMonth({
    required String apiKey,
    required String householdId,
    required AppSettings settings,
    required BudgetSummary summary,
    required PurchaseHistory purchaseHistory,
    required BudgetPaceResult pace,
  }) async {
    final stress = calculateStressIndex(
      summary: summary,
      purchaseHistory: purchaseHistory,
      settings: settings,
    );

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final prompt = StringBuffer();
    prompt.writeln('CONTEXTO: Alerta de desvio orçamental a meio do mês.');
    prompt.writeln('Dia do mês: ${now.day}/$daysInMonth');
    prompt.writeln('Orçamento alimentar: ${(pace.expectedPace * daysInMonth).toStringAsFixed(2)}€');
    prompt.writeln('Gasto até agora: ${(pace.dailyPace * pace.daysElapsed).toStringAsFixed(2)}€');
    prompt.writeln('Ritmo actual: ${pace.dailyPace.toStringAsFixed(2)}€/dia vs previsto ${pace.expectedPace.toStringAsFixed(2)}€/dia');
    prompt.writeln('Projeção fim mês: ${pace.projectedTotal.toStringAsFixed(2)}€ (excesso: +${pace.projectedOverspend.toStringAsFixed(2)}€)');
    prompt.writeln('Dias restantes: ${pace.daysRemaining}');
    prompt.writeln('Índice de Tranquilidade: ${stress.score}/100');
    prompt.writeln();
    prompt.writeln('PEDIDO: Dá 3 sugestões concretas e accionáveis para reduzir o gasto alimentar '
        'nos restantes ${pace.daysRemaining} dias. Cada sugestão deve incluir a poupança estimada em €. '
        'Sê directo e específico. Sem introdução nem conclusão.');

    final content = await _requestChatCompletion(
      apiKey: apiKey,
      messages: [
        {
          'role': 'system',
          'content': 'És um consultor de orçamento doméstico português. '
              'Responde sempre em português europeu. Sê prático e directo.',
        },
        {'role': 'user', 'content': prompt.toString()},
      ],
      maxTokens: 500,
      temperature: 0.5,
    );

    final insight = CoachInsight(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      content: content,
      stressScore: stress.score,
    );
    final history = await _persistInsight(insight, householdId);
    return (insight: insight, history: history);
  }

  Future<String> _requestChatCompletion({
    required String apiKey,
    required List<Map<String, String>> messages,
    int maxTokens = 800,
    double temperature = 0.5,
  }) async {
    final hasApiKey = apiKey.trim().isNotEmpty;
    try {
      final response = await _invokeEdgeFunctionDirect(
        body: {
          'model': _model,
          'messages': messages,
          'max_tokens': maxTokens,
          'temperature': temperature,
        },
      );

      final data = response.data;
      if (response.status != 200 || data is! Map<String, dynamic>) {
        if (response.status == 404 && hasApiKey) {
          return _requestDirectOpenAiCompletion(
            apiKey: apiKey,
            messages: messages,
            maxTokens: maxTokens,
            temperature: temperature,
          );
        }
        final msg = data is Map<String, dynamic>
            ? (data['error']?.toString() ?? 'Falha ao processar pedido de IA')
            : 'Falha ao processar pedido de IA';
        throw Exception(msg);
      }

      final content = data['content']?.toString().trim() ?? '';
      if (content.isEmpty) {
        throw Exception('Resposta vazia da IA.');
      }
      return content;
    } catch (e) {
      if (hasApiKey && shouldFallbackFromEdgeFunctionError(e)) {
        try {
          return await _requestDirectOpenAiCompletion(
            apiKey: apiKey,
            messages: messages,
            maxTokens: maxTokens,
            temperature: temperature,
          );
        } catch (fallbackError) {
          throw Exception(
            buildAiCoachRequestErrorMessage(
              fallbackError,
              hasApiKey: hasApiKey,
            ),
          );
        }
      }
      throw Exception(buildAiCoachRequestErrorMessage(e, hasApiKey: hasApiKey));
    }
  }

  Future<({int status, Object? data})> _invokeEdgeFunctionDirect({
    required Map<String, dynamic> body,
  }) async {
    final response = await _edgeClient.invoke(body);
    return (status: response.status, data: response.data);
  }

  Future<String> _requestDirectOpenAiCompletion({
    required String apiKey,
    required List<Map<String, String>> messages,
    required int maxTokens,
    required double temperature,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${apiKey.trim()}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'messages': messages,
        'max_tokens': maxTokens,
        'temperature': temperature,
      }),
    ).timeout(httpTimeout);

    Map<String, dynamic>? data;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {
      data = null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorMessage = data?['error'] is Map<String, dynamic>
          ? (data!['error']['message']?.toString() ??
              'Falha ao processar pedido de IA')
          : 'Falha ao processar pedido de IA';
      throw Exception(errorMessage);
    }

    final choices = data?['choices'];
    if (choices is! List || choices.isEmpty) {
      throw Exception('Resposta vazia da IA.');
    }
    final message = choices.first['message'];
    if (message is! Map<String, dynamic>) {
      throw Exception('Resposta vazia da IA.');
    }
    final content = message['content'];
    if (content is String && content.trim().isNotEmpty) {
      return content.trim();
    }
    if (content is List) {
      final textParts = content
          .whereType<Map<String, dynamic>>()
          .map((e) => e['text']?.toString() ?? '')
          .where((s) => s.trim().isNotEmpty)
          .join('\n')
          .trim();
      if (textParts.isNotEmpty) return textParts;
    }
    throw Exception('Resposta vazia da IA.');
  }

  // ── Prompt ─────────────────────────────────────────────────────────────────

  String _buildPrompt(
    AppSettings settings,
    BudgetSummary summary,
    PurchaseHistory purchaseHistory,
    StressIndexResult stress,
  ) {
    final now = DateTime.now();
    const monthNames = [
      '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    final monthLabel = '${monthNames[now.month]} ${now.year}';
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (daysInMonth - now.day).clamp(0, daysInMonth);

    final buf = StringBuffer();
    buf.writeln('CONTEXTO: Orçamento pessoal mensal — $monthLabel');
    buf.writeln();

    // ── Stress index ─────────────────────────────────────────────────────────
    final prevMonth = now.month == 1 ? 12 : now.month - 1;
    final prevYear = now.month == 1 ? now.year - 1 : now.year;
    final prevKey = '$prevYear-${prevMonth.toString().padLeft(2, '0')}';
    final prevScore = settings.stressHistory[prevKey];
    final deltaStr = prevScore != null
        ? ' (${stress.score >= prevScore ? '+' : ''}${stress.score - prevScore} vs ${monthNames[prevMonth]})'
        : ' (primeiro registo)';
    final levelName = stress.level.name;
    buf.writeln('ÍNDICE DE TRANQUILIDADE: ${stress.score}/100 — $levelName$deltaStr');
    buf.writeln('Factores (pontuação 0–100, peso):');
    final weights = [35, 30, 20, 15];
    for (var i = 0; i < stress.factors.length; i++) {
      final f = stress.factors[i];
      final pts = (f.normalizedScore * weights[i] / 100).round();
      final status = f.ok ? '✓' : '⚠';
      buf.writeln(
          '  $status ${f.type.name}: ${f.valueLabel} '
          '→ ${f.normalizedScore.toStringAsFixed(0)}/100 pts (peso ${weights[i]}%, contribui $pts pts)');
    }
    buf.writeln();

    // ── Stress history trend ──────────────────────────────────────────────────
    if (settings.stressHistory.length >= 2) {
      final sorted = settings.stressHistory.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key));
      buf.writeln('EVOLUÇÃO DO ÍNDICE (${sorted.length < 6 ? sorted.length : 6} meses):');
      for (final e in sorted.take(6)) {
        final parts = e.key.split('-');
        final mLabel = monthNames[int.parse(parts[1])];
        buf.writeln('  $mLabel ${parts[0]}: ${e.value}/100');
      }
      buf.writeln();
    }

    // ── Income ───────────────────────────────────────────────────────────────
    buf.writeln('RENDIMENTO');
    buf.writeln('  Bruto total: ${summary.totalGross.toStringAsFixed(2)}€');
    buf.writeln('  Líquido (c/ subsídio alim.): ${summary.totalNetWithMeal.toStringAsFixed(2)}€');
    buf.writeln('  IRS retido: ${summary.totalIRS.toStringAsFixed(2)}€'
        ' (${summary.totalGross > 0 ? (summary.totalIRS / summary.totalGross * 100).toStringAsFixed(1) : 0}% do bruto)');
    buf.writeln('  Seg. Social: ${summary.totalSS.toStringAsFixed(2)}€'
        ' (${summary.totalGross > 0 ? (summary.totalSS / summary.totalGross * 100).toStringAsFixed(1) : 0}% do bruto)');
    buf.writeln();

    // ── Fixed expenses ────────────────────────────────────────────────────────
    final expByCategory = <String, double>{};
    for (final e in settings.expenses.where((e) => e.enabled && e.amount > 0)) {
      expByCategory.update(categoryLabel(e.category), (v) => v + e.amount, ifAbsent: () => e.amount);
    }
    if (expByCategory.isNotEmpty) {
      final net = summary.totalNetWithMeal;
      buf.writeln(
          'DESPESAS FIXAS: ${summary.totalExpenses.toStringAsFixed(2)}€ '
          '(${net > 0 ? (summary.totalExpenses / net * 100).toStringAsFixed(1) : 0}% do líquido)');
      final sorted = expByCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      for (final e in sorted) {
        final pct = net > 0 ? (e.value / net * 100).toStringAsFixed(1) : '0';
        buf.writeln('  ${e.key}: ${e.value.toStringAsFixed(2)}€ ($pct%)');
      }
      buf.writeln();
    }

    // ── Food / purchase history ───────────────────────────────────────────────
    final foodBudget = settings.expenses
        .where((e) => e.category == 'alimentacao' && e.enabled)
        .fold(0.0, (s, e) => s + e.amount);
    final foodSpent = purchaseHistory.spentInMonth(now.year, now.month);
    final monthRecords = purchaseHistory.records
        .where((r) => r.date.year == now.year && r.date.month == now.month)
        .toList();
    if (monthRecords.isNotEmpty || foodBudget > 0) {
      buf.writeln('COMPRAS — $monthLabel');
      buf.writeln('  Compras realizadas: ${monthRecords.length}');
      if (monthRecords.isNotEmpty) {
        buf.writeln(
            '  Valor médio/compra: ${(foodSpent / monthRecords.length).toStringAsFixed(2)}€');
      }
      if (foodBudget > 0) {
        final remaining = foodBudget - foodSpent;
        final projected =
            now.day > 1 ? (foodSpent / now.day * daysInMonth) : foodSpent;
        buf.writeln('  Orçamento: ${foodBudget.toStringAsFixed(2)}€'
            ' | Gasto: ${foodSpent.toStringAsFixed(2)}€'
            ' (${(foodSpent / foodBudget * 100).toStringAsFixed(0)}%)');
        buf.writeln('  Restante: ${remaining.toStringAsFixed(2)}€'
            ' | Projeção fim mês: ${projected.toStringAsFixed(2)}€'
            ' | Dias restantes: $daysLeft');
      }
      buf.writeln();
    }

    // ── Bottom line ───────────────────────────────────────────────────────────
    buf.writeln('POSIÇÃO FINAL');
    buf.writeln('  Disponível/poupança: ${summary.netLiquidity.toStringAsFixed(2)}€/mês');
    buf.writeln('  Taxa de poupança: ${(summary.savingsRate * 100).toStringAsFixed(1)}%');
    if (summary.totalExpenses > 0 && summary.netLiquidity > 0) {
      final monthsCovered = (summary.netLiquidity / summary.totalExpenses).toStringAsFixed(1);
      buf.writeln('  Meses de despesas cobertos pela poupança mensal: $monthsCovered');
    }
    buf.writeln();

    // ── Directive ─────────────────────────────────────────────────────────────
    buf.writeln(
        'ANÁLISE PEDIDA — responde em 3 partes, sem introdução nem conclusão:\n'
        '\n'
        '**1. POSICIONAMENTO GERAL**\n'
        'Com base nos dados acima, avalia 3 dimensões:\n'
        '(a) Estrutura de custos: o rácio despesas fixas/líquido e o que implica para a margem de manobra;\n'
        '(b) Capacidade de absorção de imprevistos: a poupança mensal cobre quantas vezes as despesas fixas?\n'
        '(c) Trajectória: o índice está a melhorar, estável ou a deteriorar? Porquê (com os dados)?\n'
        '\n'
        '**2. FACTORES CRÍTICOS**\n'
        'Os 2 factores com pior pontuação no Índice. Para cada um:\n'
        '(a) 1 frase de diagnóstico com os números exactos do contexto;\n'
        '(b) 1 acção concreta com valor-alvo em € ou % e impacto estimado no score.\n'
        '\n'
        '**3. OPORTUNIDADE IMEDIATA — $monthLabel**\n'
        '1 acção aplicável ainda este mês com base nos dados actuais (compras restantes, orçamento, etc.).\n'
        '\n'
        'Sê cirúrgico. Zero conselhos genéricos. Usa EXCLUSIVAMENTE os números fornecidos.');
    return buf.toString();
  }

  String _buildChatSystemPrompt({
    required AppSettings settings,
    required BudgetSummary summary,
    required PurchaseHistory purchaseHistory,
    CoachMode? effectiveMode,
  }) {
    final stress = calculateStressIndex(
      summary: summary,
      purchaseHistory: purchaseHistory,
      settings: settings,
    );
    final now = DateTime.now();
    final foodBudget = settings.expenses
        .where((e) => e.category == 'alimentacao' && e.enabled)
        .fold(0.0, (s, e) => s + e.amount);
    final foodSpent = purchaseHistory.spentInMonth(now.year, now.month);
    final fixedExpenseRatio = summary.totalNetWithMeal > 0
        ? (summary.totalExpenses / summary.totalNetWithMeal * 100)
        : 0.0;
    final savingsRate = summary.savingsRate * 100;

    final buf = StringBuffer();
    buf.write('Es um coach financeiro pessoal para utilizadores portugueses. '
        'Responde sempre em portugues europeu, de forma direta e pratica, '
        'respondendo primeiro a pergunta exata do utilizador. '
        'Evita formatos fixos (nao responder em "3 partes" a menos que seja pedido). '
        'Mantem continuidade da conversa e usa o historico para responder. '
        'Nunca inventes dados externos; usa apenas o contexto e o que o utilizador disser. '
        'NUNCA uses exemplos hipoteticos nem valores inventados. Se os dados reais estao disponiveis, usa-os. Se nao, diz explicitamente que nao tens esse dado. '
        'Quando houver dados numericos no pedido, cita esses numeros na resposta. '
        'Contexto financeiro atual:\n'
        '- Liquido mensal: ${summary.totalNetWithMeal.toStringAsFixed(2)} EUR\n'
        '- Despesas fixas: ${summary.totalExpenses.toStringAsFixed(2)} EUR (${fixedExpenseRatio.toStringAsFixed(1)}%)\n'
        '- Poupanca mensal: ${summary.netLiquidity.toStringAsFixed(2)} EUR (${savingsRate.toStringAsFixed(1)}%)\n'
        '- Orcamento alimentar: ${foodBudget.toStringAsFixed(2)} EUR\n'
        '- Gasto alimentar atual: ${foodSpent.toStringAsFixed(2)} EUR\n'
        '- Indice de tranquilidade: ${stress.score}/100');

    // Feature #4: SESSION_INSIGHT delimiter instruction (all modes)
    buf.write('\n\n'
        'No final de cada resposta substantiva (não saudações), inclui um resumo breve delimitado:\n'
        '[SESSION_INSIGHT]tópico breve|valor monetário se aplicável[/SESSION_INSIGHT]\n\n'
        'Exemplos:\n'
        '[SESSION_INSIGHT]otimização de despesas alimentação|€47/mês[/SESSION_INSIGHT]\n'
        '[SESSION_INSIGHT]análise de subscrições|€23/mês[/SESSION_INSIGHT]\n'
        '[SESSION_INSIGHT]estratégia de poupança para entrada de casa|[/SESSION_INSIGHT]\n\n'
        'Se não houver valor monetário concreto, deixa o segundo campo vazio.\n'
        'Não incluas este delimitador em saudações ou respostas curtas.');

    // Feature #5: MICRO_ACTION delimiter instruction (Pro only)
    if (effectiveMode == CoachMode.pro) {
      buf.write('\n\n'
          'Quando dás um conselho prático, termina a resposta com uma micro-ação concreta delimitada:\n'
          '[MICRO_ACTION]ação específica com valor em EUR e prazo[/MICRO_ACTION]\n\n'
          'Exemplos:\n'
          '[MICRO_ACTION]Move €15 do orçamento de jantar fora para a poupança de emergência esta semana[/MICRO_ACTION]\n'
          '[MICRO_ACTION]Cancela a subscrição de streaming que não usas há 2 meses (poupança: €12/mês)[/MICRO_ACTION]\n\n'
          'Sê específico: inclui valores, prazos e ações concretas. Não incluas micro-ações para saudações.');
    }

    return buf.toString();
  }

  static List<Map<String, String>> buildBoundedChatMessages({
    required List<CoachChatMessage> history,
    required String userMessage,
    required int contextWindow,
    required String systemPrompt,
  }) {
    final cleanHistory = history
        .where((m) => m.content.trim().isNotEmpty)
        .toList(growable: false);
    final safeWindow = contextWindow < 0 ? 0 : contextWindow;
    final bounded = cleanHistory.length > safeWindow
        ? cleanHistory.sublist(cleanHistory.length - safeWindow)
        : cleanHistory;

    return [
      {'role': 'system', 'content': systemPrompt},
      ...bounded.map((m) => {'role': m.role, 'content': m.content}),
      {'role': 'user', 'content': userMessage.trim()},
    ];
  }

  /// Exposes [_invokeEdgeFunctionDirect] for timeout testing.
  @visibleForTesting
  Future<({int status, Object? data})> invokeEdgeFunctionForTest({
    required Map<String, dynamic> body,
  }) =>
      _invokeEdgeFunctionDirect(body: body);

  /// Exposes [_requestDirectOpenAiCompletion] for timeout testing.
  @visibleForTesting
  Future<String> requestOpenAiCompletionForTest({
    required String apiKey,
    required List<Map<String, String>> messages,
    required int maxTokens,
    required double temperature,
  }) =>
      _requestDirectOpenAiCompletion(
        apiKey: apiKey,
        messages: messages,
        maxTokens: maxTokens,
        temperature: temperature,
      );
}

class CoachChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  const CoachChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  factory CoachChatMessage.fromJson(Map<String, dynamic> json) {
    return CoachChatMessage(
      role: json['role']?.toString() ?? 'assistant',
      content: json['content']?.toString() ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
