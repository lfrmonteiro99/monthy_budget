import 'dart:convert';

import 'package:drift/drift.dart';

import 'app_database.dart';

/// Generic JSON-document store backed by the existing drift [AppDatabase].
///
/// Deliberately uses drift's raw-SQL escape hatches instead of generated table
/// classes: the QA repositories need ~15 collections, and adding them as drift
/// tables would mean regenerating a 140 KB `app_database.g.dart` and bumping the
/// schema version for data that only exists in QA builds. One untyped table
/// keeps the production schema completely untouched while still being real
/// sqlite (so a browser reload keeps the seeded state).
class QaLocalStore {
  QaLocalStore(this._db);

  final AppDatabase _db;

  bool _tableReady = false;

  Future<void> _ensureTable() async {
    if (_tableReady) return;
    await _db.customStatement('''
      CREATE TABLE IF NOT EXISTS qa_documents (
        collection TEXT NOT NULL,
        household_id TEXT NOT NULL,
        doc_id TEXT NOT NULL,
        payload TEXT NOT NULL,
        PRIMARY KEY (collection, household_id, doc_id)
      )
    ''');
    _tableReady = true;
  }

  /// Upserts a single document. [payload] must be JSON-encodable.
  Future<void> put(
    String collection,
    String householdId,
    String docId,
    Map<String, dynamic> payload,
  ) async {
    await _ensureTable();
    await _db.customInsert(
      'INSERT OR REPLACE INTO qa_documents '
      '(collection, household_id, doc_id, payload) VALUES (?, ?, ?, ?)',
      variables: [
        Variable<String>(collection),
        Variable<String>(householdId),
        Variable<String>(docId),
        Variable<String>(jsonEncode(payload)),
      ],
    );
  }

  /// Upserts many documents keyed by doc id, in one transaction.
  Future<void> putAll(
    String collection,
    String householdId,
    Map<String, Map<String, dynamic>> documents,
  ) async {
    if (documents.isEmpty) return;
    await _ensureTable();
    await _db.transaction(() async {
      for (final entry in documents.entries) {
        await put(collection, householdId, entry.key, entry.value);
      }
    });
  }

  /// All documents in [collection] for [householdId], insertion order undefined
  /// — callers sort explicitly, mirroring the `.order(...)` the Supabase
  /// repositories use.
  Future<List<Map<String, dynamic>>> query(
    String collection,
    String householdId,
  ) async {
    await _ensureTable();
    final rows = await _db.customSelect(
      'SELECT payload FROM qa_documents '
      'WHERE collection = ? AND household_id = ? ORDER BY doc_id',
      variables: [Variable<String>(collection), Variable<String>(householdId)],
    ).get();
    return rows.map(_decode).toList();
  }

  /// Documents across every household — for collections that are global in
  /// Supabase (products, recipes, the merchant registry).
  Future<List<Map<String, dynamic>>> queryAll(String collection) async {
    await _ensureTable();
    final rows = await _db.customSelect(
      'SELECT payload FROM qa_documents WHERE collection = ? ORDER BY doc_id',
      variables: [Variable<String>(collection)],
    ).get();
    return rows.map(_decode).toList();
  }

  Future<Map<String, dynamic>?> get(
    String collection,
    String householdId,
    String docId,
  ) async {
    await _ensureTable();
    final rows = await _db.customSelect(
      'SELECT payload FROM qa_documents '
      'WHERE collection = ? AND household_id = ? AND doc_id = ? LIMIT 1',
      variables: [
        Variable<String>(collection),
        Variable<String>(householdId),
        Variable<String>(docId),
      ],
    ).get();
    if (rows.isEmpty) return null;
    return _decode(rows.first);
  }

  Future<void> delete(
    String collection,
    String householdId,
    String docId,
  ) async {
    await _ensureTable();
    await _db.customUpdate(
      'DELETE FROM qa_documents '
      'WHERE collection = ? AND household_id = ? AND doc_id = ?',
      variables: [
        Variable<String>(collection),
        Variable<String>(householdId),
        Variable<String>(docId),
      ],
      updateKind: UpdateKind.delete,
    );
  }

  /// Deletes every document in [collection] whose decoded payload satisfies
  /// [test]. The predicate runs in Dart because payloads are opaque JSON.
  Future<void> deleteWhere(
    String collection,
    String householdId,
    bool Function(Map<String, dynamic> payload) test,
  ) async {
    await _ensureTable();
    final rows = await _db.customSelect(
      'SELECT doc_id, payload FROM qa_documents '
      'WHERE collection = ? AND household_id = ?',
      variables: [Variable<String>(collection), Variable<String>(householdId)],
    ).get();
    final doomed = <String>[];
    for (final row in rows) {
      if (test(_decode(row))) doomed.add(row.read<String>('doc_id'));
    }
    if (doomed.isEmpty) return;
    await _db.transaction(() async {
      for (final docId in doomed) {
        await delete(collection, householdId, docId);
      }
    });
  }

  /// Deletes an entire collection for a household — used by the QA sign-out
  /// reset path.
  Future<void> clearCollection(String collection, String householdId) async {
    await _ensureTable();
    await _db.customUpdate(
      'DELETE FROM qa_documents WHERE collection = ? AND household_id = ?',
      variables: [Variable<String>(collection), Variable<String>(householdId)],
      updateKind: UpdateKind.delete,
    );
  }

  Map<String, dynamic> _decode(QueryRow row) =>
      jsonDecode(row.read<String>('payload')) as Map<String, dynamic>;
}
