import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_public_config.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../models/coach_insight.dart';
import '../models/purchase_record.dart';
import '../utils/stress_index.dart';

S _l10n() {
  final code = intl.Intl.getCurrentLocale().split('_').first;
  return lookupS(Locale(code));
}

bool shouldFallbackFromEdgeFunctionError(Object error) {
  final raw = error.toString().toLowerCase();
  return raw.contains('functionexception') &&
      (raw.contains('status: 404') ||
          raw.contains('not_found') ||
          raw.contains('404'));
}

bool isEdgeFunctionAuthError(Object error) {
  final raw = error.toString().toLowerCase();
  return raw.contains('status: 401') ||
      raw.contains('status: 403') ||
      raw.contains('unauthorized') ||
      raw.contains('jwt') ||
      raw.contains('invalid token');
}

String buildAiCoachRequestErrorMessage(
  Object error, {
  required bool hasApiKey,
}) {
  final l10n = _l10n();
  final raw = error.toString().replaceFirst('Exception: ', '').trim();
  if (isEdgeFunctionAuthError(error)) {
    return l10n.aiCoachAuthExpired;
  }
  if (shouldFallbackFromEdgeFunctionError(error)) {
    if (hasApiKey) {
      return l10n.aiCoachServerUnavailableWithKey;
    }
    return l10n.aiCoachServerUnavailableWithoutKey;
  }
  if (raw.isEmpty) return l10n.aiCoachRequestFailed;
  return raw;
}

class AiCoachService {
  static const _apiKeyPref = 'openai_api_key';
  static const _edgeFunctionName = 'openai-chat';
  static const _model = 'gpt-4o-mini';
  static const _maxInsights = 20;
  static const _chatPrefKeyPrefix = 'coach_chat_v2_messages_';

  final SupabaseClient _client;
  final http.Client _httpClient;

  AiCoachService({
    SupabaseClient? client,
    http.Client? httpClient,
  })  : _client = client ?? Supabase.instance.client,
        _httpClient = httpClient ?? http.Client();

  // ── API key (device-local) ─────────────────────────────────────────────────

  Future<String> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPref) ?? '';
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, key.trim());
  }

  /// Gate for AI features. Currently checks API key existence.
  /// Future: replace with subscription tier check.
  Future<bool> canUseAI() async {
    return true;
  }

  // ── Insight history (household-shared via Supabase) ────────────────────────

  Future<List<CoachInsight>> loadInsights(String householdId) async {
    try {
      final rows = await _client
          .from('household_coach_insights')
          .select()
          .eq('household_id', householdId)
          .order('created_at', ascending: false)
          .limit(_maxInsights);
      return (rows as List<dynamic>).map((r) {
        final m = r as Map<String, dynamic>;
        return CoachInsight(
          id: m['id'] as String,
          timestamp: DateTime.parse(m['created_at'] as String),
          content: m['content'] as String,
          stressScore: (m['stress_score'] as num).toInt(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<CoachInsight>> _persistInsight(
      CoachInsight insight, String householdId) async {
    await _client.from('household_coach_insights').insert({
      'id': insight.id,
      'household_id': householdId,
      'created_at': insight.timestamp.toIso8601String(),
      'content': insight.content,
      'stress_score': insight.stressScore,
    });
    return loadInsights(householdId);
  }

  Future<List<CoachInsight>> deleteInsight(
      String id, String householdId) async {
    await _client.from('household_coach_insights').delete().eq('id', id);
    return loadInsights(householdId);
  }

  Future<void> clearInsights(String householdId) async {
    await _client
        .from('household_coach_insights')
        .delete()
        .eq('household_id', householdId);
  }

  Future<List<CoachChatMessage>> loadConversation(String householdId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_chatPrefKeyPrefix$householdId');
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((item) => CoachChatMessage.fromJson(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveConversation(
    String householdId,
    List<CoachChatMessage> messages,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = messages.map((m) => m.toJson()).toList();
    await prefs.setString(
      '$_chatPrefKeyPrefix$householdId',
      jsonEncode(payload),
    );
  }

  Future<void> clearConversation(String householdId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_chatPrefKeyPrefix$householdId');
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
  }) async {
    final groundedUserMessage = _buildGroundedUserMessage(
      userMessage: userMessage,
      settings: settings,
      summary: summary,
      purchaseHistory: purchaseHistory,
    );
    final messages = buildBoundedChatMessages(
      history: history,
      userMessage: groundedUserMessage,
      contextWindow: contextWindow,
      systemPrompt: _buildChatSystemPrompt(
        settings: settings,
        summary: summary,
        purchaseHistory: purchaseHistory,
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
  }) {
    final now = DateTime.now();
    final monthRecords = purchaseHistory.records
        .where((r) => r.date.year == now.year && r.date.month == now.month)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final topExpenses = settings.expenses
        .where((e) => e.enabled && e.amount > 0)
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final topExpensesText = topExpenses
        .take(6)
        .map((e) => '- ${e.category.label}: ${e.amount.toStringAsFixed(2)} EUR')
        .join('\n');

    final recentPurchasesText = monthRecords
        .take(8)
        .map(
          (r) =>
              '- ${r.date.day.toString().padLeft(2, '0')}/${r.date.month.toString().padLeft(2, '0')}: '
              '${r.amount.toStringAsFixed(2)} EUR (${r.itemCount} itens)',
        )
        .join('\n');

    return '''
Pergunta do utilizador:
$userMessage

Dados reais da app (usar estes valores na resposta):
- Liquido mensal: ${summary.totalNetWithMeal.toStringAsFixed(2)} EUR
- Despesas fixas: ${summary.totalExpenses.toStringAsFixed(2)} EUR
- Poupanca mensal: ${summary.netLiquidity.toStringAsFixed(2)} EUR

Top categorias de despesa:
${topExpensesText.isEmpty ? '- sem dados' : topExpensesText}

Compras recentes deste mes:
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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
            ? (data['error']?.toString() ?? _l10n().aiCoachRequestFailed)
            : _l10n().aiCoachRequestFailed;
        throw Exception(msg);
      }

      final content = data['content']?.toString().trim() ?? '';
      if (content.isEmpty) {
        throw Exception(_l10n().aiCoachEmptyResponse);
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
    final headers = _buildEdgeAuthHeaders();
    final response = await _httpClient.post(
      Uri.parse('$supabaseUrl/functions/v1/$_edgeFunctionName'),
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    Object? data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = {'error': response.body};
    }
    return (status: response.statusCode, data: data);
  }

  Map<String, String> _buildEdgeAuthHeaders() {
    final jwt = supabaseAnonKey.trim();
    if (jwt.isEmpty) {
      throw Exception(_l10n().aiCoachMissingJwt);
    }
    return {
      'Authorization': 'Bearer $jwt',
      'apikey': supabaseAnonKey,
    };
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
    );

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
              _l10n().aiCoachRequestFailed)
          : _l10n().aiCoachRequestFailed;
      throw Exception(errorMessage);
    }

    final choices = data?['choices'];
    if (choices is! List || choices.isEmpty) {
      throw Exception(_l10n().aiCoachEmptyResponse);
    }
    final message = choices.first['message'];
    if (message is! Map<String, dynamic>) {
      throw Exception(_l10n().aiCoachEmptyResponse);
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
    throw Exception(_l10n().aiCoachEmptyResponse);
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
    final daysLeft = daysInMonth - now.day;

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
      expByCategory.update(e.category.label, (v) => v + e.amount, ifAbsent: () => e.amount);
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
        .where((e) => e.category == ExpenseCategory.alimentacao && e.enabled)
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
  }) {
    final stress = calculateStressIndex(
      summary: summary,
      purchaseHistory: purchaseHistory,
      settings: settings,
    );
    final now = DateTime.now();
    final foodBudget = settings.expenses
        .where((e) => e.category == ExpenseCategory.alimentacao && e.enabled)
        .fold(0.0, (s, e) => s + e.amount);
    final foodSpent = purchaseHistory.spentInMonth(now.year, now.month);
    final fixedExpenseRatio = summary.totalNetWithMeal > 0
        ? (summary.totalExpenses / summary.totalNetWithMeal * 100)
        : 0.0;
    final savingsRate = summary.savingsRate * 100;
    return 'Es um coach financeiro pessoal para utilizadores portugueses. '
        'Responde sempre em portugues europeu, de forma direta e pratica, '
        'respondendo primeiro a pergunta exata do utilizador. '
        'Evita formatos fixos (nao responder em "3 partes" a menos que seja pedido). '
        'Mantem continuidade da conversa e usa o historico para responder. '
        'Nunca inventes dados externos; usa apenas o contexto e o que o utilizador disser. '
        'Quando houver dados numericos no pedido, cita esses numeros na resposta. '
        'Se faltar dado para algo pedido, diz explicitamente que nao tens esse dado. '
        'Contexto financeiro atual:\n'
        '- Liquido mensal: ${summary.totalNetWithMeal.toStringAsFixed(2)} EUR\n'
        '- Despesas fixas: ${summary.totalExpenses.toStringAsFixed(2)} EUR (${fixedExpenseRatio.toStringAsFixed(1)}%)\n'
        '- Poupanca mensal: ${summary.netLiquidity.toStringAsFixed(2)} EUR (${savingsRate.toStringAsFixed(1)}%)\n'
        '- Orcamento alimentar: ${foodBudget.toStringAsFixed(2)} EUR\n'
        '- Gasto alimentar atual: ${foodSpent.toStringAsFixed(2)} EUR\n'
        '- Indice de tranquilidade: ${stress.score}/100';
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


