import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/subscription_state.dart';
import 'package:orcamento_mensal/utils/coach_mode_recommender.dart';

void main() {
  group('recommendMode', () {
    group('pro keywords', () {
      test('returns pro for "imposto" keyword', () {
        expect(recommendMode('Como funciona o imposto sobre rendimentos?'),
            CoachMode.pro);
      });

      test('returns pro for "irs" keyword', () {
        expect(recommendMode('Quanto vou pagar de IRS?'), CoachMode.pro);
      });

      test('returns pro for "simulação" keyword', () {
        expect(recommendMode('Faz uma simulação do meu crédito'),
            CoachMode.pro);
      });

      test('returns pro for "investimento" keyword', () {
        expect(recommendMode('Qual o melhor investimento?'), CoachMode.pro);
      });

      test('returns pro for "hipoteca" keyword', () {
        expect(recommendMode('Devo amortizar a hipoteca?'), CoachMode.pro);
      });

      test('returns pro for "mais-valias" keyword', () {
        expect(recommendMode('Como declarar mais-valias?'), CoachMode.pro);
      });

      test('returns pro for "crédito habitação" keyword', () {
        expect(recommendMode('Quero simular crédito habitação'),
            CoachMode.pro);
      });
    });

    group('plus keywords', () {
      test('returns plus for "análise" keyword', () {
        expect(recommendMode('Faz análise das despesas'), CoachMode.plus);
      });

      test('returns plus for "orçamento" keyword', () {
        expect(recommendMode('Qual é o meu orçamento?'), CoachMode.plus);
      });

      test('returns plus for "poupar" keyword', () {
        expect(recommendMode('Como poupar mais?'), CoachMode.plus);
      });

      test('returns plus for "despesas" keyword', () {
        expect(recommendMode('Mostra as despesas'), CoachMode.plus);
      });

      test('returns plus for "categoria" keyword', () {
        expect(recommendMode('Qual a categoria mais cara?'), CoachMode.plus);
      });
    });

    group('length thresholds', () {
      test('returns pro for messages over 200 chars', () {
        final longMessage = 'a' * 201;
        expect(recommendMode(longMessage), CoachMode.pro);
      });

      test('returns plus for messages over 80 chars', () {
        final mediumMessage = 'a' * 81;
        expect(recommendMode(mediumMessage), CoachMode.plus);
      });

      test('returns eco for short messages without keywords', () {
        expect(recommendMode('Olá'), CoachMode.eco);
      });

      test('returns eco for messages exactly 80 chars without keywords', () {
        final msg = 'a' * 80;
        expect(recommendMode(msg), CoachMode.eco);
      });
    });

    group('edge cases', () {
      test('returns eco for empty string', () {
        expect(recommendMode(''), CoachMode.eco);
      });

      test('pro keyword takes priority over plus keyword', () {
        expect(
            recommendMode('Análise do imposto sobre rendimentos'),
            CoachMode.pro);
      });

      test('case insensitive matching', () {
        expect(recommendMode('IMPOSTO'), CoachMode.pro);
        expect(recommendMode('ANÁLISE'), CoachMode.plus);
      });

      test('pro keyword overrides length-based plus', () {
        // Short message with pro keyword
        expect(recommendMode('IRS anual'), CoachMode.pro);
      });
    });
  });
}
