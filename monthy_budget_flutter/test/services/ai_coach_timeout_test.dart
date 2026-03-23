import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:monthly_management/models/coach_insight.dart';
import 'package:monthly_management/repositories/household_repository.dart';
import 'package:monthly_management/services/ai_coach_service.dart';

class _FakeInsightRepo implements CoachInsightRepository {
  @override
  Future<List<CoachInsight>> loadInsights(String householdId, {int limit = 20}) async => [];
  @override
  Future<List<CoachInsight>> saveInsight(CoachInsight insight, String householdId) async => [];
  @override
  Future<List<CoachInsight>> deleteInsight(String id, String householdId) async => [];
  @override
  Future<void> clearInsights(String householdId) async {}
}

void main() {
  group('AiCoachService HTTP timeout (#747)', () {
    test('httpTimeout defaults to 15 seconds', () {
      expect(AiCoachService.httpTimeout, const Duration(seconds: 15));
    });

    test('edge function call throws TimeoutException on slow response', () async {
      final originalTimeout = AiCoachService.httpTimeout;
      addTearDown(() => AiCoachService.httpTimeout = originalTimeout);

      AiCoachService.httpTimeout = const Duration(milliseconds: 1);

      final slowClient = MockClient((_) async {
        await Future<void>.delayed(const Duration(seconds: 30));
        return http.Response('{}', 200);
      });

      final service = AiCoachService(
        httpClient: slowClient,
        insightRepository: _FakeInsightRepo(),
      );

      await expectLater(
        service.invokeEdgeFunctionForTest(body: {'test': true}),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('direct OpenAI call throws TimeoutException on slow response', () async {
      final originalTimeout = AiCoachService.httpTimeout;
      addTearDown(() => AiCoachService.httpTimeout = originalTimeout);

      AiCoachService.httpTimeout = const Duration(milliseconds: 1);

      final slowClient = MockClient((_) async {
        await Future<void>.delayed(const Duration(seconds: 30));
        return http.Response('{}', 200);
      });

      final service = AiCoachService(
        httpClient: slowClient,
        insightRepository: _FakeInsightRepo(),
      );

      await expectLater(
        service.requestOpenAiCompletionForTest(
          apiKey: 'sk-test',
          messages: [
            {'role': 'user', 'content': 'hello'}
          ],
          maxTokens: 100,
          temperature: 0.7,
        ),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
