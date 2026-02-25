import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../models/purchase_record.dart';
import '../utils/stress_index.dart';

class AiCoachService {
  static const _apiKeyPref = 'openai_api_key';
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';

  Future<String> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPref) ?? '';
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, key.trim());
  }

  Future<String> analyze({
    required String apiKey,
    required AppSettings settings,
    required BudgetSummary summary,
    required PurchaseHistory purchaseHistory,
  }) async {
    final prompt = _buildPrompt(settings, summary, purchaseHistory);

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
                    'És um consultor financeiro pessoal para utilizadores portugueses. '
                    'Responde sempre em português europeu. Sê direto, usa números concretos '
                    'do contexto fornecido e organiza os conselhos com bullet points (•). '
                    'Não introduzas dados que não foram fornecidos.',
              },
              {'role': 'user', 'content': prompt},
            ],
            'max_tokens': 700,
            'temperature': 0.7,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return (data['choices'] as List).first['message']['content'] as String;
    } else if (response.statusCode == 401) {
      throw Exception('API key inválida. Verifica nas Definições.');
    } else {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = (body['error'] as Map?)?['message'] ?? 'Erro ${response.statusCode}';
      throw Exception(msg);
    }
  }

  String _buildPrompt(
      AppSettings settings, BudgetSummary summary, PurchaseHistory purchaseHistory) {
    final now = DateTime.now();
    final monthNames = [
      '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    final monthLabel = '${monthNames[now.month]} ${now.year}';
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = daysInMonth - now.day;

    final stress = calculateStressIndex(
      summary: summary,
      purchaseHistory: purchaseHistory,
      settings: settings,
    );

    final buf = StringBuffer();
    buf.writeln('CONTEXTO: Orçamento pessoal mensal — $monthLabel');
    buf.writeln();

    // Stress index
    final prevMonth = now.month == 1 ? 12 : now.month - 1;
    final prevYear = now.month == 1 ? now.year - 1 : now.year;
    final prevKey = '$prevYear-${prevMonth.toString().padLeft(2, '0')}';
    final prevScore = settings.stressHistory[prevKey];
    final deltaStr = prevScore != null
        ? ' (${stress.score >= prevScore ? '+' : ''}${stress.score - prevScore} vs ${monthNames[prevMonth]})'
        : '';
    buf.writeln('ÍNDICE DE TRANQUILIDADE: ${stress.score}/100 — ${stress.label}$deltaStr');
    buf.writeln('Factores (pontuação 0–100, peso, estado):');
    final weights = [35, 30, 20, 15];
    for (var i = 0; i < stress.factors.length; i++) {
      final f = stress.factors[i];
      final pts = (f.normalizedScore * weights[i] / 100).toStringAsFixed(0);
      final status = f.ok ? '✓' : '⚠';
      buf.writeln(
          '  $status ${f.label}: ${f.valueLabel} → ${f.normalizedScore.toStringAsFixed(0)}/100 '
          '(contribui $pts/${weights[i]} pts)');
    }
    buf.writeln();

    // Budget
    buf.writeln('RENDIMENTO');
    buf.writeln('  Bruto: ${summary.totalGross.toStringAsFixed(2)}€');
    buf.writeln('  Líquido (c/ subsídio alim.): ${summary.totalNetWithMeal.toStringAsFixed(2)}€');
    buf.writeln('  IRS: ${summary.totalIRS.toStringAsFixed(2)}€ | SS: ${summary.totalSS.toStringAsFixed(2)}€');
    buf.writeln();

    // Expenses by category
    final expByCategory = <String, double>{};
    for (final e in settings.expenses.where((e) => e.enabled && e.amount > 0)) {
      expByCategory.update(e.category.label, (v) => v + e.amount, ifAbsent: () => e.amount);
    }
    if (expByCategory.isNotEmpty) {
      buf.writeln('DESPESAS FIXAS (total: ${summary.totalExpenses.toStringAsFixed(2)}€)');
      final sorted = expByCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      for (final e in sorted) {
        final pct = summary.totalNetWithMeal > 0
            ? (e.value / summary.totalNetWithMeal * 100).toStringAsFixed(1)
            : '0';
        buf.writeln('  ${e.key}: ${e.value.toStringAsFixed(2)}€ ($pct% do líquido)');
      }
      buf.writeln();
    }

    // Purchase history this month
    final foodBudget = settings.expenses
        .where((e) => e.category == ExpenseCategory.alimentacao && e.enabled)
        .fold(0.0, (s, e) => s + e.amount);
    final foodSpent = purchaseHistory.spentInMonth(now.year, now.month);
    final monthRecords =
        purchaseHistory.records.where((r) => r.date.year == now.year && r.date.month == now.month).toList();
    if (monthRecords.isNotEmpty || foodBudget > 0) {
      buf.writeln('COMPRAS DE SUPERMERCADO — $monthLabel');
      buf.writeln('  Compras realizadas: ${monthRecords.length}');
      if (monthRecords.isNotEmpty) {
        final avg = foodSpent / monthRecords.length;
        buf.writeln('  Valor médio por compra: ${avg.toStringAsFixed(2)}€');
      }
      if (foodBudget > 0) {
        final remaining = foodBudget - foodSpent;
        final projected = daysLeft > 0 && now.day > 1
            ? foodSpent / now.day * daysInMonth
            : foodSpent;
        buf.writeln('  Orçamento alimentação: ${foodBudget.toStringAsFixed(2)}€/mês');
        buf.writeln('  Gasto até hoje: ${foodSpent.toStringAsFixed(2)}€ '
            '(${(foodSpent / foodBudget * 100).toStringAsFixed(0)}%)');
        buf.writeln('  Restante: ${remaining.toStringAsFixed(2)}€ | '
            'Projeção fim do mês: ${projected.toStringAsFixed(2)}€');
        buf.writeln('  Dias restantes no mês: $daysLeft');
      }
      buf.writeln();
    }

    buf.writeln('DISPONÍVEL/POUPANÇA: ${summary.netLiquidity.toStringAsFixed(2)}€ '
        '(taxa: ${(summary.savingsRate * 100).toStringAsFixed(1)}%)');
    buf.writeln();

    buf.writeln(
        'Com base EXCLUSIVAMENTE nestes dados (sem inventar informação externa):\n'
        '1. Identifica os 2 factores com pior pontuação e explica em 1 frase cada um '
        'porquê estão fracos — usa os números exactos fornecidos.\n'
        '2. Para cada factor fraco, propõe UMA ação concreta com um valor-alvo '
        'específico em euros ou percentagem e estima o impacto no score.\n'
        '3. Indica 1 oportunidade de melhoria imediata para $monthLabel.\n'
        'Sê cirúrgico. Zero conselhos genéricos. Zero introdução ou conclusão. '
        'Responde directamente ao ponto 1, depois 2, depois 3.');
    return buf.toString();
  }
}
