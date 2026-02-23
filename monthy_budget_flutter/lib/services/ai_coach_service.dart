import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../models/grocery_data.dart';

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
    required GroceryData groceryData,
  }) async {
    final prompt = _buildPrompt(settings, summary, groceryData);

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

  String _buildPrompt(AppSettings settings, BudgetSummary summary, GroceryData groceryData) {
    final buf = StringBuffer();

    buf.writeln('Os meus dados financeiros mensais:');
    buf.writeln();
    buf.writeln('ORÇAMENTO');
    buf.writeln('- Rendimento bruto: ${summary.totalGross.toStringAsFixed(2)}€');
    buf.writeln('- Rendimento líquido (c/ subsídio): ${summary.totalNetWithMeal.toStringAsFixed(2)}€');
    buf.writeln('- IRS retido: ${summary.totalIRS.toStringAsFixed(2)}€');
    buf.writeln('- Segurança Social: ${summary.totalSS.toStringAsFixed(2)}€');
    buf.writeln('- Total despesas fixas: ${summary.totalExpenses.toStringAsFixed(2)}€');
    buf.writeln('- Disponível/poupança: ${summary.netLiquidity.toStringAsFixed(2)}€');
    buf.writeln('- Taxa de poupança: ${summary.savingsRate.toStringAsFixed(1)}%');
    buf.writeln();

    final expByCategory = <String, double>{};
    for (final e in settings.expenses.where((e) => e.enabled && e.amount > 0)) {
      expByCategory.update(e.category.label, (v) => v + e.amount, ifAbsent: () => e.amount);
    }
    if (expByCategory.isNotEmpty) {
      buf.writeln('DESPESAS POR CATEGORIA');
      final sorted = expByCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      for (final e in sorted) {
        buf.writeln('- ${e.key}: ${e.value.toStringAsFixed(2)}€');
      }
      buf.writeln();
    }

    if (groceryData.decoIndex.rankings.isNotEmpty) {
      buf.writeln('SUPERMERCADOS (Índice DECO PROteste)');
      for (final r in groceryData.decoIndex.rankings.take(4)) {
        final diff = r.index - groceryData.decoIndex.rankings.first.index;
        final label = diff == 0 ? 'mais barato' : '+$diff%';
        buf.writeln('- ${r.store}: índice ${r.index} ($label)');
      }
      buf.writeln();
    }

    if (groceryData.categorySummary.isNotEmpty) {
      buf.writeln('CATEGORIAS COM MAIOR POUPANÇA POTENCIAL');
      final savingsData = groceryData.categorySummary
          .where((c) => c.stores.length >= 2)
          .map((c) {
            final sorted = c.stores.entries.toList()
              ..sort((a, b) => a.value.avgPrice.compareTo(b.value.avgPrice));
            final saving = sorted.last.value.avgPrice - sorted.first.value.avgPrice;
            return (cat: c.category, cheap: sorted.first.key, saving: saving);
          })
          .toList()
        ..sort((a, b) => b.saving.compareTo(a.saving));

      for (final d in savingsData.take(4)) {
        buf.writeln('- ${d.cat}: comprar em ${d.cheap} (diferença média: ${d.saving.toStringAsFixed(2)}€/produto)');
      }
      buf.writeln();
    }

    buf.writeln('Com base nestes dados reais, dá-me 4-5 conselhos financeiros personalizados e acionáveis.');
    return buf.toString();
  }
}
