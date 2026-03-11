import '../models/subscription_state.dart';

CoachMode recommendMode(String message) {
  final lower = message.toLowerCase();
  final len = message.length;

  const proKeywords = [
    'imposto', 'irs', 'simulação', 'simular', 'investimento', 'investir',
    'hipoteca', 'empréstimo', 'dedução', 'reforma', 'independente',
    'mais-valias', 'arrendamento', 'amortização', 'crédito habitação',
  ];

  const plusKeywords = [
    'análise', 'analisar', 'tendência', 'comparar', 'objetivo',
    'orçamento', 'categoria', 'poupar', 'estratégia', 'planear',
    'reduzir', 'otimizar', 'mensal', 'despesas',
  ];

  if (proKeywords.any((k) => lower.contains(k))) return CoachMode.pro;
  if (len > 200) return CoachMode.pro;
  if (plusKeywords.any((k) => lower.contains(k))) return CoachMode.plus;
  if (len > 80) return CoachMode.plus;
  return CoachMode.eco;
}
