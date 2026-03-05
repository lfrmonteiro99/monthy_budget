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

  group('AiCoachService bounded chat context', () {
    test('keeps only the latest N history messages', () {
      final history = List.generate(
        5,
        (i) => CoachChatMessage(
          role: i.isEven ? 'user' : 'assistant',
          content: 'msg_$i',
          timestamp: DateTime(2026, 1, 1, 10, i),
        ),
      );

      final messages = AiCoachService.buildBoundedChatMessages(
        history: history,
        userMessage: 'new_question',
        contextWindow: 2,
        systemPrompt: 'system',
      );

      expect(messages.length, 4);
      expect(messages[0]['role'], 'system');
      expect(messages[1]['content'], 'msg_3');
      expect(messages[2]['content'], 'msg_4');
      expect(messages[3]['content'], 'new_question');
    });

    test('always includes system + new user when context window is zero', () {
      final messages = AiCoachService.buildBoundedChatMessages(
        history: const [
          CoachChatMessage(
            role: 'assistant',
            content: 'old',
            timestamp: DateTime(2026, 1, 1),
          ),
        ],
        userMessage: 'hello',
        contextWindow: 0,
        systemPrompt: 'system',
      );

      expect(messages.length, 2);
      expect(messages[0]['role'], 'system');
      expect(messages[1]['role'], 'user');
      expect(messages[1]['content'], 'hello');
    });
  });
}
