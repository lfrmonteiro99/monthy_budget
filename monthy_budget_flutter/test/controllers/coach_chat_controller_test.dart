import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monthly_management/controllers/coach_chat_controller.dart';
import 'package:monthly_management/data/tax/tax_system.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/coach_insight.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/models/subscription_state.dart';
import 'package:monthly_management/repositories/household_repository.dart';
import 'package:monthly_management/services/ai_coach_service.dart';

/// In-memory repository that avoids Supabase initialization.
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

CoachChatController _buildController() {
  final fakeClient = http_testing.MockClient(
      (_) async => http.Response('{}', 200));
  final service = AiCoachService(
    insightRepository: _FakeCoachInsightRepository(),
    httpClient: fakeClient,
  );
  return CoachChatController(service: service);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CoachChatController controller;
  // Track whether dispose was manually called so tearDown doesn't double-dispose
  bool manuallyDisposed = false;

  SubscriptionState _baseSubscription() => SubscriptionState(
        trialStartDate: DateTime.now(),
        aiCredits: 50,
        preferredCoachMode: CoachMode.plus,
        trialStarterCreditsGranted: true,
      );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Provide a fake path_provider so drift doesn't crash in tests
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall call) async {
        if (call.method == 'getApplicationDocumentsDirectory') {
          return '.';
        }
        return null;
      },
    );
    controller = _buildController();
    manuallyDisposed = false;
  });

  tearDown(() {
    if (!manuallyDisposed) {
      controller.dispose();
    }
  });

  group('CoachChatController', () {
    group('init / updateSubscription', () {
      test('init sets subscription and mode', () {
        final sub = _baseSubscription();
        controller.init(sub);

        expect(controller.subscription, sub);
        expect(controller.selectedMode, CoachMode.plus);
      });

      test('updateSubscription updates state and notifies', () {
        controller.init(_baseSubscription());
        var notified = false;
        controller.addListener(() => notified = true);

        final updated = _baseSubscription().copyWith(aiCredits: 100);
        controller.updateSubscription(updated);

        expect(controller.subscription.aiCredits, 100);
        expect(notified, isTrue);
      });
    });

    group('state defaults', () {
      test('initial state is correct', () {
        controller.init(_baseSubscription());

        expect(controller.messages, isEmpty);
        expect(controller.loading, isFalse);
        expect(controller.error, isNull);
        expect(controller.lastModeResolution, isNull);
        expect(controller.lastParsedMicroAction, isNull);
        expect(controller.showRecommendation, isFalse);
        expect(controller.pendingRecommendation, isNull);
      });
    });

    group('clearError', () {
      test('clears error and notifies', () {
        controller.init(_baseSubscription());
        var notified = false;
        controller.addListener(() => notified = true);

        controller.clearError();

        expect(controller.error, isNull);
        expect(notified, isTrue);
      });
    });

    group('maxTokensForMode', () {
      test('eco returns 450', () {
        expect(CoachChatController.maxTokensForMode(CoachMode.eco), 450);
      });

      test('plus returns 900', () {
        expect(CoachChatController.maxTokensForMode(CoachMode.plus), 900);
      });

      test('pro returns 1200', () {
        expect(CoachChatController.maxTokensForMode(CoachMode.pro), 1200);
      });
    });

    group('loadConversation', () {
      test('loads messages from service and notifies', () async {
        SharedPreferences.setMockInitialValues({
          'coach_chat_v2_messages_hh1':
              '[{"role":"user","content":"hi","timestamp":"2026-01-01T10:00:00.000"}]',
        });
        controller.init(_baseSubscription());

        var notified = false;
        controller.addListener(() => notified = true);

        await controller.loadConversation('hh1');

        // Service may return extra messages from drift migration;
        // assert at least 1 message with expected content.
        expect(controller.messages, isNotEmpty);
        expect(controller.messages.any((m) => m.content == 'hi'), isTrue);
        expect(notified, isTrue);
      });

      test('returns empty list for missing conversation', () async {
        SharedPreferences.setMockInitialValues({});
        controller.init(_baseSubscription());

        await controller.loadConversation('nonexistent');

        expect(controller.messages, isEmpty);
      });
    });

    group('clearConversation', () {
      test('clears messages and notifies', () async {
        SharedPreferences.setMockInitialValues({
          'coach_chat_v2_messages_hh1':
              '[{"role":"user","content":"hi","timestamp":"2026-01-01T10:00:00.000"}]',
        });
        controller.init(_baseSubscription());
        await controller.loadConversation('hh1');
        // The service may load from both SharedPreferences and drift migration
        expect(controller.messages, isNotEmpty);

        var notified = false;
        controller.addListener(() => notified = true);

        await controller.clearConversation('hh1');

        expect(controller.messages, isEmpty);
        expect(notified, isTrue);
      });
    });

    group('sendMessage', () {
      test('returns true but does not send when text is empty', () async {
        controller.init(_baseSubscription());

        final result = await controller.sendMessage(
          text: '   ',
          apiKey: 'key',
          householdId: 'hh1',
          settings: _minimalSettings(),
          purchaseHistory: _emptyPurchaseHistory(),
          onSubscriptionChanged: (_) {},
        );

        expect(result, isTrue);
        expect(controller.messages, isEmpty);
        expect(controller.loading, isFalse);
      });
    });

    group('recommendation', () {
      test('dismisses recommendation when text is empty', () {
        controller.init(_baseSubscription());
        controller.checkRecommendation('', locale: 'pt');

        expect(controller.showRecommendation, isFalse);
        expect(controller.pendingRecommendation, isNull);
      });
    });

    group('dispose', () {
      test('cancels timers without errors', () {
        controller.init(_baseSubscription());
        controller.dispose();
        manuallyDisposed = true;
        // Should not throw
      });
    });
  });
}

AppSettings _minimalSettings() => const AppSettings(
      salaries: [],
      personalInfo: PersonalInfo(),
      expenses: [],
      country: Country.pt,
    );

PurchaseHistory _emptyPurchaseHistory() => const PurchaseHistory(records: []);
