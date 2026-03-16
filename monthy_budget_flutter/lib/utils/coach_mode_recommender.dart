import '../models/subscription_state.dart';

/// Keywords that signal a complex financial query → [CoachMode.pro].
const _proKeywords = <String, List<String>>{
  'pt': [
    'imposto', 'irs', 'simulação', 'simular', 'investimento', 'investir',
    'hipoteca', 'empréstimo', 'dedução', 'reforma', 'independente',
    'mais-valias', 'arrendamento', 'amortização', 'crédito habitação',
  ],
  'en': [
    'tax', 'irs', 'simulation', 'simulate', 'investment', 'invest',
    'mortgage', 'loan', 'deduction', 'retirement', 'freelance',
    'capital gains', 'rental income', 'amortization', 'housing credit',
  ],
  'es': [
    'impuesto', 'irpf', 'simulación', 'simular', 'inversión', 'invertir',
    'hipoteca', 'préstamo', 'deducción', 'jubilación', 'autónomo',
    'plusvalía', 'alquiler', 'amortización', 'crédito hipotecario',
  ],
  'fr': [
    'impôt', 'irpp', 'simulation', 'simuler', 'investissement', 'investir',
    'hypothèque', 'emprunt', 'déduction', 'retraite', 'indépendant',
    'plus-value', 'loyer', 'amortissement', 'crédit immobilier',
  ],
};

/// Keywords that signal an analytical query → [CoachMode.plus].
const _plusKeywords = <String, List<String>>{
  'pt': [
    'análise', 'analisar', 'tendência', 'comparar', 'objetivo',
    'orçamento', 'categoria', 'poupar', 'estratégia', 'planear',
    'reduzir', 'otimizar', 'mensal', 'despesas',
  ],
  'en': [
    'analysis', 'analyze', 'trend', 'compare', 'goal',
    'budget', 'category', 'save', 'strategy', 'plan',
    'reduce', 'optimize', 'monthly', 'expenses',
  ],
  'es': [
    'análisis', 'analizar', 'tendencia', 'comparar', 'objetivo',
    'presupuesto', 'categoría', 'ahorrar', 'estrategia', 'planificar',
    'reducir', 'optimizar', 'mensual', 'gastos',
  ],
  'fr': [
    'analyse', 'analyser', 'tendance', 'comparer', 'objectif',
    'budget', 'catégorie', 'épargner', 'stratégie', 'planifier',
    'réduire', 'optimiser', 'mensuel', 'dépenses',
  ],
};

/// Recommend a [CoachMode] based on [message] content and [locale].
///
/// Falls back to checking all languages when the given [locale] has no
/// keyword match, ensuring multilingual users are not penalized.
CoachMode recommendMode(String message, {String locale = 'pt'}) {
  final lower = message.toLowerCase();
  final len = message.length;
  final lang = locale.split('_').first.toLowerCase();

  // Check pro keywords — primary locale first, then all others.
  if (_matchesAny(lower, _proKeywords[lang])) return CoachMode.pro;
  if (_matchesAnyLocale(lower, _proKeywords, exclude: lang)) return CoachMode.pro;
  if (len > 200) return CoachMode.pro;

  // Check plus keywords — same strategy.
  if (_matchesAny(lower, _plusKeywords[lang])) return CoachMode.plus;
  if (_matchesAnyLocale(lower, _plusKeywords, exclude: lang)) return CoachMode.plus;
  if (len > 80) return CoachMode.plus;

  return CoachMode.eco;
}

bool _matchesAny(String text, List<String>? keywords) {
  if (keywords == null) return false;
  return keywords.any((k) => text.contains(k));
}

bool _matchesAnyLocale(String text, Map<String, List<String>> map, {required String exclude}) {
  for (final entry in map.entries) {
    if (entry.key == exclude) continue;
    if (entry.value.any((k) => text.contains(k))) return true;
  }
  return false;
}
