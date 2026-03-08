import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/household_activity_event.dart';
import 'package:orcamento_mensal/screens/household_activity_screen.dart';
import 'package:orcamento_mensal/services/household_activity_service.dart';
import 'package:orcamento_mensal/l10n/generated/app_localizations.dart';

/// Fake service that returns canned data without touching Supabase.
class FakeHouseholdActivityService extends HouseholdActivityService {
  final List<HouseholdActivityEvent> events;
  FakeHouseholdActivityService([this.events = const []]);

  @override
  Future<List<HouseholdActivityEvent>> getRecent(
    String householdId, {
    int limit = 50,
  }) async => events.take(limit).toList();

  @override
  Future<List<HouseholdActivityEvent>> getByDomain(
    String householdId,
    ActivityDomain domain, {
    int limit = 50,
  }) async => events
      .where((e) => e.domain == domain)
      .take(limit)
      .toList();

  @override
  Future<void> append({
    required String householdId,
    required ActivityDomain domain,
    required ActivityAction action,
    required String subjectId,
    required String subjectLabel,
    Map<String, dynamic> metadata = const {},
  }) async {}
}

void main() {
  // ─── Unit: Serialization / Deserialization ────────────────────────

  group('HouseholdActivityEvent model', () {
    test('fromSupabase parses a complete row', () {
      final row = {
        'id': 'evt-001',
        'household_id': 'hh-123',
        'actor_user_id': 'user-1',
        'actor_display_name': 'Maria',
        'domain': 'shopping',
        'action': 'added',
        'subject_id': 'item-42',
        'subject_label': 'Milk',
        'metadata': <String, dynamic>{'store': 'Lidl'},
        'created_at': '2026-03-08T10:30:00Z',
      };

      final event = HouseholdActivityEvent.fromSupabase(row);

      expect(event.id, 'evt-001');
      expect(event.householdId, 'hh-123');
      expect(event.actorUserId, 'user-1');
      expect(event.actorDisplayName, 'Maria');
      expect(event.domain, ActivityDomain.shopping);
      expect(event.action, ActivityAction.added);
      expect(event.subjectId, 'item-42');
      expect(event.subjectLabel, 'Milk');
      expect(event.metadata, {'store': 'Lidl'});
      expect(event.createdAt, DateTime.utc(2026, 3, 8, 10, 30));
    });

    test('fromSupabase handles null optional fields', () {
      final row = {
        'id': 'evt-002',
        'household_id': 'hh-123',
        'actor_user_id': 'user-1',
        'actor_display_name': 'Joao',
        'domain': 'meals',
        'action': 'swapped',
        'subject_id': null,
        'subject_label': null,
        'metadata': null,
        'created_at': '2026-03-08T12:00:00Z',
      };

      final event = HouseholdActivityEvent.fromSupabase(row);

      expect(event.subjectId, '');
      expect(event.subjectLabel, '');
      expect(event.metadata, isEmpty);
    });

    test('fromSupabase defaults unknown domain/action', () {
      final row = {
        'id': 'evt-003',
        'household_id': 'hh-123',
        'actor_user_id': 'user-1',
        'actor_display_name': 'Ana',
        'domain': 'unknown_domain',
        'action': 'unknown_action',
        'subject_id': '',
        'subject_label': '',
        'metadata': <String, dynamic>{},
        'created_at': '2026-03-08T12:00:00Z',
      };

      final event = HouseholdActivityEvent.fromSupabase(row);

      expect(event.domain, ActivityDomain.shopping);
      expect(event.action, ActivityAction.added);
    });

    test('toSupabase produces correct map', () {
      final event = HouseholdActivityEvent(
        id: 'evt-004',
        householdId: 'hh-123',
        actorUserId: 'user-2',
        actorDisplayName: 'Ana',
        domain: ActivityDomain.expenses,
        action: ActivityAction.updated,
        subjectId: 'exp-1',
        subjectLabel: 'Groceries',
        metadata: const {'amount': 42.5},
        createdAt: DateTime(2026, 3, 8),
      );

      final map = event.toSupabase();

      expect(map['household_id'], 'hh-123');
      expect(map['actor_user_id'], 'user-2');
      expect(map['actor_display_name'], 'Ana');
      expect(map['domain'], 'expenses');
      expect(map['action'], 'updated');
      expect(map['subject_id'], 'exp-1');
      expect(map['subject_label'], 'Groceries');
      expect(map['metadata'], {'amount': 42.5});
      // id and createdAt are server-generated, not in toSupabase
      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('created_at'), isFalse);
    });

    test('readableSummary formats correctly', () {
      final event = HouseholdActivityEvent(
        id: 'e1',
        householdId: 'hh',
        actorUserId: 'u1',
        actorDisplayName: 'Maria',
        domain: ActivityDomain.shopping,
        action: ActivityAction.added,
        subjectId: 'i1',
        subjectLabel: 'Milk',
        createdAt: DateTime.now(),
      );

      expect(event.readableSummary(), 'Added Milk by Maria');
    });

    test('inlineAttribution formats correctly for each action', () {
      for (final action in ActivityAction.values) {
        final event = HouseholdActivityEvent(
          id: 'e1',
          householdId: 'hh',
          actorUserId: 'u1',
          actorDisplayName: 'Joao',
          domain: ActivityDomain.meals,
          action: action,
          subjectId: 's1',
          subjectLabel: 'Dinner',
          createdAt: DateTime.now(),
        );

        final attribution = event.inlineAttribution();
        expect(attribution, endsWith('by Joao'));
        expect(attribution, isNotEmpty);
      }
    });

    test('equality is based on id and householdId', () {
      final a = HouseholdActivityEvent(
        id: 'e1',
        householdId: 'hh',
        actorUserId: 'u1',
        actorDisplayName: 'Maria',
        domain: ActivityDomain.shopping,
        action: ActivityAction.added,
        subjectId: 'i1',
        subjectLabel: 'Milk',
        createdAt: DateTime(2026, 1, 1),
      );
      final b = HouseholdActivityEvent(
        id: 'e1',
        householdId: 'hh',
        actorUserId: 'u2',
        actorDisplayName: 'Joao',
        domain: ActivityDomain.meals,
        action: ActivityAction.removed,
        subjectId: 'i2',
        subjectLabel: 'Bread',
        createdAt: DateTime(2026, 2, 1),
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('roundtrip: fromSupabase -> toSupabase preserves data', () {
      final original = {
        'id': 'evt-rt',
        'household_id': 'hh-999',
        'actor_user_id': 'user-rt',
        'actor_display_name': 'Test User',
        'domain': 'pantry',
        'action': 'removed',
        'subject_id': 'pantry-item-1',
        'subject_label': 'Rice',
        'metadata': <String, dynamic>{'kg': 2},
        'created_at': '2026-03-08T15:00:00Z',
      };

      final event = HouseholdActivityEvent.fromSupabase(original);
      final map = event.toSupabase();

      expect(map['household_id'], original['household_id']);
      expect(map['actor_user_id'], original['actor_user_id']);
      expect(map['actor_display_name'], original['actor_display_name']);
      expect(map['domain'], original['domain']);
      expect(map['action'], original['action']);
      expect(map['subject_id'], original['subject_id']);
      expect(map['subject_label'], original['subject_label']);
      expect(map['metadata'], original['metadata']);
    });
  });

  // ─── Unit: ActivityDomain enum ────────────────────────────────────

  group('ActivityDomain', () {
    test('all expected values exist', () {
      expect(ActivityDomain.values, containsAll([
        ActivityDomain.shopping,
        ActivityDomain.meals,
        ActivityDomain.expenses,
        ActivityDomain.pantry,
        ActivityDomain.settings,
      ]));
    });
  });

  group('ActivityAction', () {
    test('all expected values exist', () {
      expect(ActivityAction.values, containsAll([
        ActivityAction.added,
        ActivityAction.removed,
        ActivityAction.swapped,
        ActivityAction.updated,
        ActivityAction.checked,
        ActivityAction.unchecked,
      ]));
    });
  });

  // ─── Widget: HouseholdActivityScreen ──────────────────────────────

  group('HouseholdActivityScreen', () {
    late FakeHouseholdActivityService fakeService;

    Widget buildTestApp({
      required Widget child,
    }) {
      return MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        locale: const Locale('en'),
        home: child,
      );
    }

    setUp(() {
      fakeService = FakeHouseholdActivityService();
    });

    testWidgets('renders filter chips', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: HouseholdActivityScreen(
          householdId: 'test-hh',
          service: fakeService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('renders title in app bar', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: HouseholdActivityScreen(
          householdId: 'test-hh',
          service: fakeService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Household Activity'), findsOneWidget);
    });

    testWidgets('filter chips include all domain labels', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: HouseholdActivityScreen(
          householdId: 'test-hh',
          service: fakeService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Meals'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Pantry'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows empty state when no events', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: HouseholdActivityScreen(
          householdId: 'test-hh',
          service: fakeService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No activity yet'), findsOneWidget);
      expect(find.text('Shared actions from your household will appear here.'),
          findsOneWidget);
    });

    testWidgets('renders event tiles when events exist', (tester) async {
      final now = DateTime.now();
      final service = FakeHouseholdActivityService([
        HouseholdActivityEvent(
          id: 'e1',
          householdId: 'test-hh',
          actorUserId: 'u1',
          actorDisplayName: 'Maria',
          domain: ActivityDomain.shopping,
          action: ActivityAction.added,
          subjectId: 'i1',
          subjectLabel: 'Milk',
          createdAt: now,
        ),
        HouseholdActivityEvent(
          id: 'e2',
          householdId: 'test-hh',
          actorUserId: 'u2',
          actorDisplayName: 'Joao',
          domain: ActivityDomain.meals,
          action: ActivityAction.swapped,
          subjectId: 'm1',
          subjectLabel: 'Dinner',
          createdAt: now.subtract(const Duration(minutes: 30)),
        ),
      ]);

      await tester.pumpWidget(buildTestApp(
        child: HouseholdActivityScreen(
          householdId: 'test-hh',
          service: service,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Added Milk by Maria'), findsOneWidget);
      expect(find.text('Swapped Dinner by Joao'), findsOneWidget);
    });

    testWidgets('tapping filter chip changes selection', (tester) async {
      final service = FakeHouseholdActivityService([
        HouseholdActivityEvent(
          id: 'e1',
          householdId: 'test-hh',
          actorUserId: 'u1',
          actorDisplayName: 'Maria',
          domain: ActivityDomain.shopping,
          action: ActivityAction.added,
          subjectId: 'i1',
          subjectLabel: 'Milk',
          createdAt: DateTime.now(),
        ),
        HouseholdActivityEvent(
          id: 'e2',
          householdId: 'test-hh',
          actorUserId: 'u2',
          actorDisplayName: 'Joao',
          domain: ActivityDomain.meals,
          action: ActivityAction.swapped,
          subjectId: 'm1',
          subjectLabel: 'Dinner',
          createdAt: DateTime.now(),
        ),
      ]);

      await tester.pumpWidget(buildTestApp(
        child: HouseholdActivityScreen(
          householdId: 'test-hh',
          service: service,
        ),
      ));
      await tester.pumpAndSettle();

      // Both events visible initially
      expect(find.text('Added Milk by Maria'), findsOneWidget);
      expect(find.text('Swapped Dinner by Joao'), findsOneWidget);

      // Tap Shopping filter
      await tester.tap(find.text('Shopping'));
      await tester.pumpAndSettle();

      // Only shopping event visible
      expect(find.text('Added Milk by Maria'), findsOneWidget);
      expect(find.text('Swapped Dinner by Joao'), findsNothing);
    });

    testWidgets('inline attribution rendering', (tester) async {
      final now = DateTime.now();
      final service = FakeHouseholdActivityService([
        HouseholdActivityEvent(
          id: 'e1',
          householdId: 'test-hh',
          actorUserId: 'u1',
          actorDisplayName: 'Ana',
          domain: ActivityDomain.expenses,
          action: ActivityAction.updated,
          subjectId: 'exp-1',
          subjectLabel: 'Rent',
          createdAt: now,
        ),
      ]);

      await tester.pumpWidget(buildTestApp(
        child: HouseholdActivityScreen(
          householdId: 'test-hh',
          service: service,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Updated Rent by Ana'), findsOneWidget);
    });
  });

  // ─── Unit: inline attribution label derivation ────────────────────

  group('Inline attribution derivation', () {
    test('each action produces a distinct verb', () {
      final verbs = <String>{};
      for (final action in ActivityAction.values) {
        final event = HouseholdActivityEvent(
          id: 'e',
          householdId: 'hh',
          actorUserId: 'u',
          actorDisplayName: 'X',
          domain: ActivityDomain.shopping,
          action: action,
          subjectId: '',
          subjectLabel: 'Item',
          createdAt: DateTime.now(),
        );
        final summary = event.readableSummary();
        final verb = summary.split(' ').first;
        verbs.add(verb);
      }
      // Each action should produce a unique verb
      expect(verbs.length, ActivityAction.values.length);
    });
  });
}
