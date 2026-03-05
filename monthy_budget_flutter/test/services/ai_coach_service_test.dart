import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/services/ai_coach_service.dart';

void main() {
  group('AiCoachService edge-function fallback helpers', () {
    test('detects 404 function exception as fallback-eligible', () {
      final error =
          'FunctionException(status: 404, details: {code: NOT_FOUND})';

      expect(shouldFallbackFromEdgeFunctionError(error), isTrue);
    });

    test('does not mark non-404 errors for fallback', () {
      final error = 'FunctionException(status: 500, details: internal_error)';

      expect(shouldFallbackFromEdgeFunctionError(error), isFalse);
    });

    test('builds actionable message for 404 without API key', () {
      final error =
          'FunctionException(status: 404, details: {code: NOT_FOUND})';

      final message = buildAiCoachRequestErrorMessage(
        error,
        hasApiKey: false,
      );

      expect(message, contains('Adicione uma API key OpenAI'));
      expect(message, contains('"openai-chat"'));
    });

    test('keeps original message for non-404 errors', () {
      const rawError = 'Quota exceeded';
      final message = buildAiCoachRequestErrorMessage(
        rawError,
        hasApiKey: true,
      );

      expect(message, rawError);
    });

    test('detects auth errors from edge-function responses', () {
      const error = 'FunctionException(status: 401, details: unauthorized)';
      expect(isEdgeFunctionAuthError(error), isTrue);
    });

    test('builds actionable message for auth errors', () {
      const error = 'FunctionException(status: 403, details: invalid jwt)';
      final message = buildAiCoachRequestErrorMessage(
        error,
        hasApiKey: false,
      );
      expect(message, contains('Sessao expirada'));
      expect(message, contains('Inicie sessao novamente'));
    });
  });

  group('buildCoachMemoryExportJson', () {
    test('builds valid json with expected top-level fields', () {
      final jsonText = buildCoachMemoryExportJson(
        householdId: 'hh_1',
        memories: [
          {'type': 'goal', 'content': 'Reduzir restaurantes', 'importance': 4}
        ],
        summaries: [
          {'summary': 'Resumo semanal', 'window_start': '2026-03-01'}
        ],
        generatedAt: DateTime.utc(2026, 3, 5, 12),
      );

      final decoded = jsonDecode(jsonText) as Map<String, dynamic>;
      expect(decoded['household_id'], 'hh_1');
      expect(decoded['generated_at'], '2026-03-05T12:00:00.000Z');
      expect(decoded['memories'], isA<List<dynamic>>());
      expect(decoded['summaries'], isA<List<dynamic>>());
    });
  });
}
