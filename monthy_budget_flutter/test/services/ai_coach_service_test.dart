import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:monthly_management/constants/app_constants.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/budget_summary.dart';
import 'package:monthly_management/models/coach_insight.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/models/subscription_state.dart';
import 'package:monthly_management/repositories/household_repository.dart';
import 'package:monthly_management/services/ai_coach_service.dart';
import 'package:monthly_management/services/edge_function_client.dart';
import 'package:monthly_management/utils/stress_index.dart';

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

  group('canUseAI — subscription-based gate', () {
    final trialState = SubscriptionState(
      trialStartDate: DateTime.now().subtract(const Duration(days: 5)),
    );
    final premiumState = SubscriptionState(
      trialStartDate: AppConstants.farPastDate,
      tier: SubscriptionTier.premium,
    );
    final freeState = SubscriptionState(
      trialStartDate: AppConstants.farPastDate,
      trialUsed: true,
    );

    test('free tier without API key is blocked', () {
      expect(
        AiCoachService.canUseAI(freeState, apiKey: ''),
        isFalse,
      );
    });

    test('trial-active user is allowed without API key', () {
      expect(
        AiCoachService.canUseAI(trialState, apiKey: ''),
        isTrue,
      );
    });

    test('premium user is allowed without API key', () {
      expect(
        AiCoachService.canUseAI(premiumState, apiKey: ''),
        isTrue,
      );
    });

    test('free tier with local API key is allowed', () {
      expect(
        AiCoachService.canUseAI(freeState, apiKey: 'sk-abc123'),
        isTrue,
      );
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
        history: [
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

  group('AiCoachService response language', () {
    const settings = AppSettings();
    const summary = BudgetSummary();
    const purchaseHistory = PurchaseHistory();
    const pace = BudgetPaceResult(
      dailyPace: 20,
      expectedPace: 25,
      projectedTotal: 500,
      projectedOverspend: 100,
      isOverPace: true,
      severity: 'warning',
      daysElapsed: 15,
      daysRemaining: 15,
    );

    Future<String> chatSystemPrompt({
      String languageCode = 'pt',
      CoachMode? effectiveMode,
    }) async {
      final built = _buildCapturingService();
      await built.service.sendChatMessage(
        apiKey: 'sk-test',
        userMessage: 'Como poupar mais?',
        history: [],
        contextWindow: 4,
        settings: settings,
        summary: summary,
        purchaseHistory: purchaseHistory,
        effectiveMode: effectiveMode,
        languageCode: languageCode,
      );
      return _capturedSystemPrompt(built.edge);
    }

    test('sendChatMessage with en instructs an English reply', () async {
      final prompt = await chatSystemPrompt(languageCode: 'en');
      expect(prompt, contains('English'));
      expect(prompt, isNot(contains('portugues europeu')));
    });

    test('sendChatMessage with fr instructs a French reply', () async {
      final prompt = await chatSystemPrompt(languageCode: 'fr');
      expect(prompt, contains('français'));
    });

    test('sendChatMessage with es instructs a Spanish reply', () async {
      final prompt = await chatSystemPrompt(languageCode: 'es');
      expect(prompt, contains('español'));
    });

    test('sendChatMessage with pt keeps the European Portuguese instruction',
        () async {
      final prompt = await chatSystemPrompt(languageCode: 'pt');
      expect(prompt, contains('português europeu'));
    });

    test('sendChatMessage without languageCode defaults to pt', () async {
      final built = _buildCapturingService();
      await built.service.sendChatMessage(
        apiKey: 'sk-test',
        userMessage: 'Como poupar mais?',
        history: [],
        contextWindow: 4,
        settings: settings,
        summary: summary,
        purchaseHistory: purchaseHistory,
      );
      expect(_capturedSystemPrompt(built.edge), contains('português europeu'));
    });

    test('sendChatMessage with unknown languageCode falls back to pt',
        () async {
      final prompt = await chatSystemPrompt(languageCode: 'de');
      expect(prompt, contains('português europeu'));
    });

    test('delimiter tokens stay literal regardless of response language',
        () async {
      final prompt = await chatSystemPrompt(
        languageCode: 'en',
        effectiveMode: CoachMode.pro,
      );
      expect(prompt, contains('[SESSION_INSIGHT]'));
      expect(prompt, contains('[/SESSION_INSIGHT]'));
      expect(prompt, contains('[MICRO_ACTION]'));
      expect(prompt, contains('[/MICRO_ACTION]'));
    });

    test('analyze with en instructs an English reply', () async {
      final built = _buildCapturingService();
      await built.service.analyze(
        apiKey: 'sk-test',
        householdId: 'hh1',
        settings: settings,
        summary: summary,
        purchaseHistory: purchaseHistory,
        languageCode: 'en',
      );
      expect(_capturedSystemPrompt(built.edge), contains('English'));
    });

    test('analyzeMidMonth with fr instructs a French reply', () async {
      final built = _buildCapturingService();
      await built.service.analyzeMidMonth(
        apiKey: 'sk-test',
        householdId: 'hh1',
        settings: settings,
        summary: summary,
        purchaseHistory: purchaseHistory,
        pace: pace,
        languageCode: 'fr',
      );
      expect(_capturedSystemPrompt(built.edge), contains('français'));
    });

    test('contextWindow still bounds history when languageCode is passed',
        () async {
      final built = _buildCapturingService();
      await built.service.sendChatMessage(
        apiKey: 'sk-test',
        userMessage: 'nova pergunta',
        history: [
          CoachChatMessage(
            role: 'user',
            content: 'm1',
            timestamp: DateTime(2026, 1, 1),
          ),
          CoachChatMessage(
            role: 'assistant',
            content: 'm2',
            timestamp: DateTime(2026, 1, 2),
          ),
        ],
        contextWindow: 1,
        settings: settings,
        summary: summary,
        purchaseHistory: purchaseHistory,
        languageCode: 'en',
      );
      final messages = built.edge.lastBody!['messages'] as List<dynamic>;
      final contents =
          messages.map((m) => (m as Map)['content'] as String).toList();
      expect(contents, hasLength(3));
      expect(contents[1], 'm2'); // only the latest history message survives
      // The user turn is the grounded prompt wrapping the raw question.
      expect(contents[2], contains('nova pergunta'));
    });

    test('Pro micro-action continuity context is still injected', () async {
      final built = _buildCapturingService();
      await built.service.sendChatMessage(
        apiKey: 'sk-test',
        userMessage: 'Olá',
        history: [],
        contextWindow: 4,
        settings: settings,
        summary: summary,
        purchaseHistory: purchaseHistory,
        effectiveMode: CoachMode.pro,
        lastMicroAction: 'Poupa 10 euros',
        lastMicroActionDate: DateTime(2026, 8, 1),
        languageCode: 'en',
      );
      final messages = built.edge.lastBody!['messages'] as List<dynamic>;
      final userMsg = messages.last as Map;
      expect(userMsg['content'] as String,
          contains('[Contexto de continuidade]'));
      expect(userMsg['content'] as String, contains('Poupa 10 euros'));
    });
  });
}

class _FakeCoachInsightRepository implements CoachInsightRepository {
  @override
  Future<List<CoachInsight>> loadInsights(String householdId,
          {int limit = 20}) async =>
      [];
  @override
  Future<List<CoachInsight>> saveInsight(
          CoachInsight insight, String householdId) async =>
      [];
  @override
  Future<List<CoachInsight>> deleteInsight(
          String id, String householdId) async =>
      [];
  @override
  Future<void> clearInsights(String householdId) async {}
}

class _CapturingEdgeClient extends EdgeFunctionClient {
  _CapturingEdgeClient()
      : super(
          httpClient: http_testing.MockClient(
            (_) async => http.Response('{}', 200),
          ),
        );

  Map<String, dynamic>? lastBody;

  @override
  Future<EdgeFunctionResponse> invoke(Map<String, dynamic> body) async {
    lastBody = body;
    return const EdgeFunctionResponse(status: 200, data: {'content': 'ok'});
  }
}

({AiCoachService service, _CapturingEdgeClient edge}) _buildCapturingService() {
  final edge = _CapturingEdgeClient();
  final service = AiCoachService(
    insightRepository: _FakeCoachInsightRepository(),
    httpClient: http_testing.MockClient((_) async => http.Response('{}', 200)),
    edgeClient: edge,
  );
  return (service: service, edge: edge);
}

String _capturedSystemPrompt(_CapturingEdgeClient edge) {
  final messages = edge.lastBody!['messages'] as List<dynamic>;
  return (messages.first as Map)['content'] as String;
}
