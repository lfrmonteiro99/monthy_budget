import 'package:drift/drift.dart';

import 'app_database.dart';

/// Local SQLite storage for coach chat messages (#763).
///
/// Replaces the SharedPreferences JSON blob with a proper relational table
/// that supports pruning and efficient queries.
class CoachMessageStorage {
  final AppDatabase _db;

  CoachMessageStorage(this._db);

  /// Load all messages for a household, ordered by timestamp ascending.
  Future<List<CoachMessage>> loadMessages(String householdId) {
    return (_db.select(_db.coachMessages)
          ..where((t) => t.householdId.equals(householdId))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
  }

  /// Insert a single message and enforce the 100-message-per-household cap.
  Future<void> insertMessage({
    required String id,
    required String householdId,
    required String role,
    required String content,
    required DateTime timestamp,
  }) async {
    await _db.into(_db.coachMessages).insert(
          CoachMessagesCompanion.insert(
            id: id,
            householdId: householdId,
            role: role,
            content: content,
            timestamp: timestamp,
          ),
        );
    await pruneMessages(householdId);
  }

  /// Insert multiple messages in a batch (used for migration).
  Future<void> insertAll(List<CoachMessagesCompanion> entries) async {
    await _db.batch((batch) {
      batch.insertAll(_db.coachMessages, entries);
    });
  }

  /// Delete all messages for a household.
  Future<void> clearMessages(String householdId) {
    return (_db.delete(_db.coachMessages)
          ..where((t) => t.householdId.equals(householdId)))
        .go();
  }

  /// Keep only the most recent [maxMessages] per household.
  static const maxMessages = 100;

  Future<void> pruneMessages(String householdId) async {
    final allMessages = await (_db.select(_db.coachMessages)
          ..where((t) => t.householdId.equals(householdId))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();

    if (allMessages.length <= maxMessages) return;

    final toDelete = allMessages.sublist(maxMessages);
    final idsToDelete = toDelete.map((m) => m.id).toList();

    await (_db.delete(_db.coachMessages)
          ..where((t) => t.id.isIn(idsToDelete)))
        .go();
  }

  /// Count messages for a household.
  Future<int> countMessages(String householdId) async {
    final rows = await (_db.select(_db.coachMessages)
          ..where((t) => t.householdId.equals(householdId)))
        .get();
    return rows.length;
  }
}
