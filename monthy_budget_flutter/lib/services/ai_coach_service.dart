import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../models/coach_insight.dart';
import '../models/purchase_record.dart';
import '../models/subscription_state.dart';
import '../utils/stress_index.dart';

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
  final raw = error.toString().replaceFirst('Exception: ', '').trim();
  if (isEdgeFunctionAuthError(error)) {
    return 'Sessao expirada ou utilizador nao autenticado. '
        'Inicie sessao novamente para usar o AI Coach.';
  }
  if (shouldFallbackFromEdgeFunctionError(error)) {
    if (hasApiKey) {
      return 'Serviço de IA indisponível no servidor. Verifique se a Edge Function '
          '"openai-chat" está publicada no projeto Supabase.';
    }
    return 'Serviço de IA indisponível no servidor. Adicione uma API key OpenAI '
        'em Definições > AI Coach ou publique a Edge Function "openai-chat".';
  }
  if (raw.isEmpty) return 'Falha ao processar pedido de IA.';
  return raw;
}

class AiCoachService {
  static const _apiKeyPref = 'openai_api_key';
  static const _edgeFunctionName = 'openai-chat';
  static const _model = 'gpt-4o-mini';
  static const _maxInsights = 20;

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

  // ── Analysis ───────────────────────────────────────────────────────────────

  /// Returns the new [CoachInsight] and the updated full list.
  Future<({CoachInsight insight, List<CoachInsight> history, String? threadId})> analyze({
    required String apiKey,
    required String householdId,
    required AppSettings settings,
    required BudgetSummary summary,
    required PurchaseHistory purchaseHistory,
    int maxTokens = 1000,
    CoachMode? coachMode,
    String? coachThreadId,
    int? coachContextWindow,
    CoachMode? requestedCoachMode,
    bool coachUsedFallback = false,
    String? coachFallbackReason,
  }) async {
    final stress = calculateStressIndex(
      summary: summary,
      purchaseHistory: purchaseHistory,
      settings: settings,
    );
    final prompt = _buildPrompt(settings, summary, purchaseHistory, stress);

    final completion = await _requestChatCompletion(
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
      coachMemory: {
        'mode': (coachMode ?? CoachMode.eco).name,
        'requested_mode': (requestedCoachMode ?? coachMode ?? CoachMode.eco).name,
        'used_fallback': coachUsedFallback,
        'fallback_reason': coachFallbackReason,
        'thread_id': coachThreadId,
        'context_window': coachContextWindow,
        'user_message': prompt,
        'household_id': householdId,
      },
    );

    final insight = CoachInsight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      content: completion.content,
      stressScore: stress.score,
    );
    final history = await _persistInsight(insight, householdId);
    return (
      insight: insight,
      history: history,
      threadId: completion.threadId,
    );
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

    final completion = await _requestChatCompletion(
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
      content: completion.content,
      stressScore: stress.score,
    );
    final history = await _persistInsight(insight, householdId);
    return (insight: insight, history: history);
  }

  Future<({String content, String? threadId})> _requestChatCompletion({
    required String apiKey,
    required List<Map<String, String>> messages,
    int maxTokens = 800,
    double temperature = 0.5,
    Map<String, dynamic>? coachMemory,
  }) async {
    final hasApiKey = apiKey.trim().isNotEmpty;
    try {
      final authHeaders = _buildEdgeAuthHeaders();
      final response = await _client.functions.invoke(
        _edgeFunctionName,
        headers: authHeaders,
        body: {
          'model': _model,
          'messages': messages,
          'max_tokens': maxTokens,
          'temperature': temperature,
          if (coachMemory != null) 'coach_memory': coachMemory,
        },
      );

      final data = response.data;
      if (response.status != 200 || data is! Map<String, dynamic>) {
        if (response.status == 404 && hasApiKey) {
          final direct = await _requestDirectOpenAiCompletion(
            apiKey: apiKey,
            messages: messages,
            maxTokens: maxTokens,
            temperature: temperature,
          );
          return (content: direct, threadId: null);
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
      return (
        content: content,
        threadId: data['thread_id']?.toString(),
      );
    } catch (e) {
      if (hasApiKey && shouldFallbackFromEdgeFunctionError(e)) {
        try {
          final direct = await _requestDirectOpenAiCompletion(
            apiKey: apiKey,
            messages: messages,
            maxTokens: maxTokens,
            temperature: temperature,
          );
          return (content: direct, threadId: null);
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

  Map<String, String> _buildEdgeAuthHeaders() {
    final accessToken = _client.auth.currentSession?.accessToken;
    if (accessToken == null || accessToken.trim().isEmpty) {
      throw Exception(
        'Sessao expirada ou utilizador nao autenticado. '
        'Inicie sessao novamente para usar o AI Coach.',
      );
    }
    return {'Authorization': 'Bearer $accessToken'};
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
}
