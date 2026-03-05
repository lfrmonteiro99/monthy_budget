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
  });
}
