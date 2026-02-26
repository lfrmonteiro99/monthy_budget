import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../models/coach_insight.dart';
import '../models/purchase_record.dart';
import '../utils/stress_index.dart';

class AiCoachService {
  static const _apiKeyPref = 'openai_api_key';
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';
  static const _maxInsights = 20;

  final _client = Supabase.instance.client;

  // ── API key (device-local) ─────────────────────────────────────────────────

  Future<String> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPref) ?? '';
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, key.trim());
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
  Future<({CoachInsight insight, List<CoachInsight> history})> analyze({
    required String apiKey,
    required String householdId,
    required AppSettings settings,
    required BudgetSummary summary,
    required PurchaseHistory purchaseHistory,
  }) async {
    final stress = calculateStressIndex(
      summary: summary,
      purchaseHistory: purchaseHistory,
      settings: settings,
    );
    final prompt = _buildPrompt(settings, summary, purchaseHistory, stress);

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
                'content':
                    'És um analista financeiro pessoal para utilizadores portugueses. '
                    'Responde sempre em português europeu. Sê directo e analítico — '
                    'usa sempre números concretos do contexto fornecido. '
                    'Estrutura a resposta exactamente nas 3 partes pedidas. '
                    'Não introduzas dados, benchmarks ou referências externas que não foram fornecidos.',
              },
              {'role': 'user', 'content': prompt},
            ],
            'max_tokens': 1000,
            'temperature': 0.5,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      if (response.statusCode == 401) {
        throw Exception('API key inválida. Verifica nas Definições.');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = (body['error'] as Map?)?['message'] ?? 'Erro ${response.statusCode}';
      throw Exception(msg);
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final content = (data['choices'] as List).first['message']['content'] as String;

    final insight = CoachInsight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      content: content,
      stressScore: stress.score,
    );
    final history = await _persistInsight(insight, householdId);
    return (insight: insight, history: history);
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
    buf.writeln('ÍNDICE DE TRANQUILIDADE: ${stress.score}/100 — ${stress.label}$deltaStr');
    buf.writeln('Factores (pontuação 0–100, peso):');
    final weights = [35, 30, 20, 15];
    for (var i = 0; i < stress.factors.length; i++) {
      final f = stress.factors[i];
      final pts = (f.normalizedScore * weights[i] / 100).round();
      final status = f.ok ? '✓' : '⚠';
      buf.writeln(
          '  $status ${f.label}: ${f.valueLabel} '
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
