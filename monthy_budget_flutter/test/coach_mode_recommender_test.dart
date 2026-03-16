import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/subscription_state.dart';
import 'package:monthly_management/utils/coach_mode_recommender.dart';

void main() {
  group('recommendMode', () {
    group('Portuguese (default)', () {
      test('detects pro keywords', () {
        expect(recommendMode('Quero simular investimento'),
            CoachMode.pro);
        expect(recommendMode('Dedução de IRS'),
            CoachMode.pro);
      });

      test('detects plus keywords', () {
        expect(recommendMode('Analisar despesas'),
            CoachMode.plus);
        expect(recommendMode('Qual a minha tendência mensal?'),
            CoachMode.plus);
      });

      test('short generic message returns eco', () {
        expect(recommendMode('Olá'), CoachMode.eco);
      });
    });

    group('English', () {
      test('detects pro keywords', () {
        expect(recommendMode('How to reduce my tax burden?', locale: 'en'),
            CoachMode.pro);
        expect(recommendMode('Simulate mortgage payments', locale: 'en'),
            CoachMode.pro);
        expect(recommendMode('Should I invest in ETFs?', locale: 'en'),
            CoachMode.pro);
      });

      test('detects plus keywords', () {
        expect(recommendMode('Analyze my monthly expenses', locale: 'en'),
            CoachMode.plus);
        expect(recommendMode('Compare budget categories', locale: 'en'),
            CoachMode.plus);
      });

      test('short generic message returns eco', () {
        expect(recommendMode('Hello', locale: 'en'), CoachMode.eco);
      });
    });

    group('Spanish', () {
      test('detects pro keywords', () {
        expect(recommendMode('Cómo reducir mi impuesto?', locale: 'es'),
            CoachMode.pro);
        expect(recommendMode('Simular hipoteca', locale: 'es'),
            CoachMode.pro);
      });

      test('detects plus keywords', () {
        expect(recommendMode('Analizar mis gastos', locale: 'es'),
            CoachMode.plus);
        expect(recommendMode('Comparar presupuesto mensual', locale: 'es'),
            CoachMode.plus);
      });

      test('short generic message returns eco', () {
        expect(recommendMode('Hola', locale: 'es'), CoachMode.eco);
      });
    });

    group('French', () {
      test('detects pro keywords', () {
        expect(recommendMode('Comment réduire mon impôt?', locale: 'fr'),
            CoachMode.pro);
        expect(recommendMode('Simuler un emprunt immobilier', locale: 'fr'),
            CoachMode.pro);
      });

      test('detects plus keywords', () {
        expect(recommendMode('Analyser mes dépenses', locale: 'fr'),
            CoachMode.plus);
        expect(recommendMode('Comparer le budget mensuel', locale: 'fr'),
            CoachMode.plus);
      });

      test('short generic message returns eco', () {
        expect(recommendMode('Bonjour', locale: 'fr'), CoachMode.eco);
      });
    });

    group('cross-locale fallback', () {
      test('PT keyword detected even when locale is EN', () {
        expect(recommendMode('Quero simular investimento', locale: 'en'),
            CoachMode.pro);
      });

      test('EN keyword detected even when locale is PT', () {
        expect(recommendMode('I want to invest in stocks', locale: 'pt'),
            CoachMode.pro);
      });
    });

    group('length heuristics', () {
      test('message >200 chars returns pro', () {
        final long = 'a' * 201;
        expect(recommendMode(long), CoachMode.pro);
      });

      test('message >80 chars returns plus', () {
        final medium = 'a' * 81;
        expect(recommendMode(medium), CoachMode.plus);
      });

      test('message <=80 chars without keywords returns eco', () {
        final short = 'a' * 80;
        expect(recommendMode(short), CoachMode.eco);
      });
    });

    test('unknown locale falls back to cross-locale check', () {
      expect(recommendMode('Simulate my investment', locale: 'de'),
          CoachMode.pro);
    });
  });
}
