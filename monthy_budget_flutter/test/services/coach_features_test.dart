import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/coach_insight.dart';
import 'package:monthly_management/models/subscription_state.dart';
import 'package:monthly_management/repositories/household_repository.dart';
import 'package:monthly_management/repositories/local/app_database.dart';
import 'package:monthly_management/repositories/local/coach_message_storage.dart';
import 'package:monthly_management/services/ai_coach_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stub repository that avoids Supabase dependency.
class _FakeCoachInsightRepository implements CoachInsightRepository {
  @override
  Future<List<CoachInsight>> loadInsights(String householdId,
          {int limit = 20}) async =>
      [];
  @override
  Future<List<CoachInsight>> saveInsight(
          CoachInsight insight, String householdId) async =>
      [insight];
  @override
  Future<List<CoachInsight>> deleteInsight(
          String id, String householdId) async =>
      [];
  @override
  Future<void> clearInsights(String householdId) async {}
}

void main() {
  // ---------------------------------------------------------------------------
  // #763 -- CoachMessages table & storage
  // ---------------------------------------------------------------------------
  group('#763: CoachMessageStorage (SQLite)', () {
    late AppDatabase db;
    late CoachMessageStorage storage;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      storage = CoachMessageStorage(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('inserts and loads messages in timestamp order', () async {
      final t1 = DateTime(2026, 3, 1, 10, 0);
      final t2 = DateTime(2026, 3, 1, 10, 1);
      final t3 = DateTime(2026, 3, 1, 10, 2);

      await storage.insertMessage(
        id: 'msg-1',
        householdId: 'hh-1',
        role: 'user',
        content: 'Hello',
        timestamp: t1,
      );
      await storage.insertMessage(
        id: 'msg-2',
        householdId: 'hh-1',
        role: 'assistant',
        content: 'Hi there',
        timestamp: t2,
      );
      await storage.insertMessage(
        id: 'msg-3',
        householdId: 'hh-1',
        role: 'user',
        content: 'Thanks',
        timestamp: t3,
      );

      final messages = await storage.loadMessages('hh-1');
      expect(messages.length, 3);
      expect(messages[0].content, 'Hello');
      expect(messages[1].content, 'Hi there');
      expect(messages[2].content, 'Thanks');
    });

    test('clearMessages removes all for a household', () async {
      await storage.insertMessage(
        id: 'msg-1',
        householdId: 'hh-1',
        role: 'user',
        content: 'A',
        timestamp: DateTime(2026, 1, 1),
      );
      await storage.insertMessage(
        id: 'msg-2',
        householdId: 'hh-2',
        role: 'user',
        content: 'B',
        timestamp: DateTime(2026, 1, 1),
      );

      await storage.clearMessages('hh-1');

      final hh1 = await storage.loadMessages('hh-1');
      final hh2 = await storage.loadMessages('hh-2');
      expect(hh1, isEmpty);
      expect(hh2.length, 1);
    });

    test('pruneMessages keeps only the 100 most recent', () async {
      final companions = List.generate(
        105,
        (i) => CoachMessagesCompanion.insert(
          id: 'msg-$i',
          householdId: 'hh-1',
          role: i.isEven ? 'user' : 'assistant',
          content: 'Message $i',
          timestamp: DateTime(2026, 1, 1, 0, i),
        ),
      );
      await storage.insertAll(companions);
      await storage.pruneMessages('hh-1');

      final remaining = await storage.loadMessages('hh-1');
      expect(remaining.length, 100);
      expect(remaining.first.content, 'Message 5');
      expect(remaining.last.content, 'Message 104');
    });

    test('insertMessage auto-prunes beyond 100', () async {
      final companions = List.generate(
        100,
        (i) => CoachMessagesCompanion.insert(
          id: 'msg-$i',
          householdId: 'hh-1',
          role: 'user',
          content: 'Message $i',
          timestamp: DateTime(2026, 1, 1, 0, i),
        ),
      );
      await storage.insertAll(companions);

      await storage.insertMessage(
        id: 'msg-100',
        householdId: 'hh-1',
        role: 'user',
        content: 'Message 100',
        timestamp: DateTime(2026, 1, 1, 1, 40),
      );

      final count = await storage.countMessages('hh-1');
      expect(count, 100);
    });

    test('different households are isolated during prune', () async {
      for (var i = 0; i < 50; i++) {
        await storage.insertMessage(
          id: 'hh1-$i',
          householdId: 'hh-1',
          role: 'user',
          content: 'HH1 msg $i',
          timestamp: DateTime(2026, 1, 1, 0, i),
        );
        await storage.insertMessage(
          id: 'hh2-$i',
          householdId: 'hh-2',
          role: 'user',
          content: 'HH2 msg $i',
          timestamp: DateTime(2026, 1, 1, 0, i),
        );
      }

      final hh1 = await storage.countMessages('hh-1');
      final hh2 = await storage.countMessages('hh-2');
      expect(hh1, 50);
      expect(hh2, 50);
    });
  });

  // ---------------------------------------------------------------------------
  // #763 -- Migration from SharedPreferences to SQLite
  // ---------------------------------------------------------------------------
  group('#763: AiCoachService conversation migration', () {
    late AppDatabase db;
    late CoachMessageStorage storage;
    late AiCoachService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase.forTesting(NativeDatabase.memory());
      storage = CoachMessageStorage(db);
      service = AiCoachService(
        messageStorage: storage,
        insightRepository: _FakeCoachInsightRepository(),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('migrates legacy SharedPreferences data to SQLite on first load',
        () async {
      final legacyMessages = [
        {
          'role': 'user',
          'content': 'Old message 1',
          'timestamp': '2026-03-01T10:00:00.000',
        },
        {
          'role': 'assistant',
          'content': 'Old reply 1',
          'timestamp': '2026-03-01T10:01:00.000',
        },
      ];

      SharedPreferences.setMockInitialValues({
        'coach_chat_v2_messages_hh-1': jsonEncode(legacyMessages),
      });

      final loaded = await service.loadConversation('hh-1');
      expect(loaded.length, 2);
      expect(loaded[0].role, 'user');
      expect(loaded[0].content, 'Old message 1');
      expect(loaded[1].role, 'assistant');
      expect(loaded[1].content, 'Old reply 1');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('coach_chat_v2_messages_hh-1'), isNull);
      expect(
        prefs.getBool('coach_chat_migrated_to_sqlite:hh-1'),
        isTrue,
      );
    });

    test('does not re-migrate after migration flag is set', () async {
      SharedPreferences.setMockInitialValues({
        'coach_chat_migrated_to_sqlite:hh-1': true,
      });

      final loaded = await service.loadConversation('hh-1');
      expect(loaded, isEmpty);
    });

    test('saves and loads conversation via SQLite', () async {
      SharedPreferences.setMockInitialValues({});

      final messages = [
        CoachChatMessage(
          role: 'user',
          content: 'Q1',
          timestamp: DateTime(2026, 3, 1, 10),
        ),
        CoachChatMessage(
          role: 'assistant',
          content: 'A1',
          timestamp: DateTime(2026, 3, 1, 10, 1),
        ),
      ];

      await service.saveConversation('hh-1', messages);
      final loaded = await service.loadConversation('hh-1');
      expect(loaded.length, 2);
      expect(loaded[0].content, 'Q1');
      expect(loaded[1].content, 'A1');
    });

    test('clearConversation empties SQLite storage', () async {
      SharedPreferences.setMockInitialValues({});

      await service.saveConversation('hh-1', [
        CoachChatMessage(
          role: 'user',
          content: 'X',
          timestamp: DateTime(2026, 1, 1),
        ),
      ]);

      await service.clearConversation('hh-1');
      final loaded = await service.loadConversation('hh-1');
      expect(loaded, isEmpty);
    });

    test('corrupt SharedPreferences data does not crash migration', () async {
      SharedPreferences.setMockInitialValues({
        'coach_chat_v2_messages_hh-1': 'not-valid-json{{{',
      });

      final loaded = await service.loadConversation('hh-1');
      expect(loaded, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // #768 -- Multi-turn context history with tier-based windowing
  // ---------------------------------------------------------------------------
  group('#768: Tier-based message history windowing', () {
    test('eco mode uses 5-message context window', () {
      expect(coachModeMessageWindow[CoachMode.eco], 5);

      final state = SubscriptionState(
        trialStartDate: DateTime(2026, 1, 1),
      );
      expect(state.contextWindowForMode(CoachMode.eco), 5);
    });

    test('plus mode uses 20-message context window', () {
      expect(coachModeMessageWindow[CoachMode.plus], 20);

      final state = SubscriptionState(
        trialStartDate: DateTime(2026, 1, 1),
      );
      expect(state.contextWindowForMode(CoachMode.plus), 20);
    });

    test('pro mode uses 40-message context window', () {
      expect(coachModeMessageWindow[CoachMode.pro], 40);

      final state = SubscriptionState(
        trialStartDate: DateTime(2026, 1, 1),
      );
      expect(state.contextWindowForMode(CoachMode.pro), 40);
    });

    test('buildBoundedChatMessages trims to eco window (5)', () {
      final history = List.generate(
        10,
        (i) => CoachChatMessage(
          role: i.isEven ? 'user' : 'assistant',
          content: 'msg_$i',
          timestamp: DateTime(2026, 1, 1, 10, i),
        ),
      );

      final messages = AiCoachService.buildBoundedChatMessages(
        history: history,
        userMessage: 'new_question',
        contextWindow: 5,
        systemPrompt: 'system',
      );

      // system + 5 history + new user = 7
      expect(messages.length, 7);
      expect(messages[0]['role'], 'system');
      expect(messages[1]['content'], 'msg_5');
      expect(messages[5]['content'], 'msg_9');
      expect(messages[6]['content'], 'new_question');
    });

    test('buildBoundedChatMessages trims to plus window (20)', () {
      final history = List.generate(
        30,
        (i) => CoachChatMessage(
          role: i.isEven ? 'user' : 'assistant',
          content: 'msg_$i',
          timestamp: DateTime(2026, 1, 1, 10, i),
        ),
      );

      final messages = AiCoachService.buildBoundedChatMessages(
        history: history,
        userMessage: 'new_question',
        contextWindow: 20,
        systemPrompt: 'system',
      );

      // system + 20 history + new user = 22
      expect(messages.length, 22);
      expect(messages[1]['content'], 'msg_10');
      expect(messages[20]['content'], 'msg_29');
    });

    test('buildBoundedChatMessages trims to pro window (40)', () {
      final history = List.generate(
        50,
        (i) => CoachChatMessage(
          role: i.isEven ? 'user' : 'assistant',
          content: 'msg_$i',
          timestamp: DateTime(2026, 1, 1, 10, i),
        ),
      );

      final messages = AiCoachService.buildBoundedChatMessages(
        history: history,
        userMessage: 'new_question',
        contextWindow: 40,
        systemPrompt: 'system',
      );

      // system + 40 history + new user = 42
      expect(messages.length, 42);
      expect(messages[1]['content'], 'msg_10');
      expect(messages[40]['content'], 'msg_49');
    });

    test('history smaller than window passes all messages through', () {
      final history = List.generate(
        3,
        (i) => CoachChatMessage(
          role: 'user',
          content: 'msg_$i',
          timestamp: DateTime(2026, 1, 1, 10, i),
        ),
      );

      final messages = AiCoachService.buildBoundedChatMessages(
        history: history,
        userMessage: 'question',
        contextWindow: 5,
        systemPrompt: 'system',
      );

      // system + 3 history + new user = 5
      expect(messages.length, 5);
    });

    test('empty-content messages are filtered from history', () {
      final history = [
        CoachChatMessage(
          role: 'user',
          content: 'real msg',
          timestamp: DateTime(2026, 1, 1),
        ),
        CoachChatMessage(
          role: 'assistant',
          content: '   ',
          timestamp: DateTime(2026, 1, 1, 0, 1),
        ),
      ];

      final messages = AiCoachService.buildBoundedChatMessages(
        history: history,
        userMessage: 'test',
        contextWindow: 5,
        systemPrompt: 'system',
      );

      // system + 1 valid history + new user = 3
      expect(messages.length, 3);
    });
  });

  // ---------------------------------------------------------------------------
  // #770 -- Free coaching trial (3 interactions/month)
  // ---------------------------------------------------------------------------
  group('#770: Free coaching trial', () {
    late AppDatabase db;
    late CoachMessageStorage storage;
    late AiCoachService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase.forTesting(NativeDatabase.memory());
      storage = CoachMessageStorage(db);
      service = AiCoachService(
        messageStorage: storage,
        insightRepository: _FakeCoachInsightRepository(),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('maxFreeInteractionsPerMonth is 3', () {
      expect(AiCoachService.maxFreeInteractionsPerMonth, 3);
    });

    test('initial usage is 0, remaining is 3', () async {
      expect(await service.getFreeTrialUsage(), 0);
      expect(await service.getFreeTrialRemaining(), 3);
      expect(await service.hasFreeTrialRemaining(), isTrue);
    });

    test('consuming 3 interactions exhausts the trial', () async {
      expect(await service.consumeFreeTrialInteraction(), isTrue);
      expect(await service.consumeFreeTrialInteraction(), isTrue);
      expect(await service.consumeFreeTrialInteraction(), isTrue);

      // 4th should fail
      expect(await service.consumeFreeTrialInteraction(), isFalse);
      expect(await service.getFreeTrialRemaining(), 0);
      expect(await service.hasFreeTrialRemaining(), isFalse);
    });

    test('usage tracks correctly per interaction', () async {
      await service.consumeFreeTrialInteraction();
      expect(await service.getFreeTrialUsage(), 1);
      expect(await service.getFreeTrialRemaining(), 2);

      await service.consumeFreeTrialInteraction();
      expect(await service.getFreeTrialUsage(), 2);
      expect(await service.getFreeTrialRemaining(), 1);
    });

    test('resets counter on new month', () async {
      final now = DateTime.now();
      final prevMonth = now.month == 1
          ? '${now.year - 1}-12'
          : '${now.year}-${(now.month - 1).toString().padLeft(2, '0')}';

      SharedPreferences.setMockInitialValues({
        'coach_free_trial_usage': 3,
        'coach_free_trial_month': prevMonth,
      });
      service = AiCoachService(
        messageStorage: storage,
        insightRepository: _FakeCoachInsightRepository(),
      );

      expect(await service.getFreeTrialUsage(), 0);
      expect(await service.getFreeTrialRemaining(), 3);
      expect(await service.hasFreeTrialRemaining(), isTrue);
    });

    test('same month retains count', () async {
      final now = DateTime.now();
      final currentMonth =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';

      SharedPreferences.setMockInitialValues({
        'coach_free_trial_usage': 2,
        'coach_free_trial_month': currentMonth,
      });
      service = AiCoachService(
        messageStorage: storage,
        insightRepository: _FakeCoachInsightRepository(),
      );

      expect(await service.getFreeTrialUsage(), 2);
      expect(await service.getFreeTrialRemaining(), 1);
    });
  });

  // ---------------------------------------------------------------------------
  // #763 -- Database schema version
  // ---------------------------------------------------------------------------
  group('#763: Database schema', () {
    test('schema version is 2 (includes CoachMessages)', () {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      expect(db.schemaVersion, 2);
      db.close();
    });

    test('CoachMessages table exists and has expected columns', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final storage = CoachMessageStorage(db);

      await storage.insertMessage(
        id: 'test-1',
        householdId: 'hh-1',
        role: 'user',
        content: 'schema test',
        timestamp: DateTime(2026, 3, 1),
      );

      final rows = await storage.loadMessages('hh-1');
      expect(rows.length, 1);
      expect(rows.first.id, 'test-1');
      expect(rows.first.householdId, 'hh-1');
      expect(rows.first.role, 'user');
      expect(rows.first.content, 'schema test');

      await db.close();
    });
  });
}
