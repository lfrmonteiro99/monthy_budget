import 'dart:convert';

import 'package:drift/drift.dart';

import 'database_connection_stub.dart'
    if (dart.library.io) 'database_connection_native.dart'
    if (dart.library.js_interop) 'database_connection_web.dart'
    as db_connection;

part 'app_database.g.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    final decoded = jsonDecode(fromDb);
    return (decoded as List<dynamic>).cast<String>();
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

class LocalShoppingItems extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get productName => text()();
  TextColumn get store => text().withDefault(const Constant(''))();
  RealColumn get price => real().withDefault(const Constant(0.0))();
  TextColumn get unitPrice => text().nullable()();
  BoolColumn get checked => boolean().withDefault(const Constant(false))();
  TextColumn get sourceMealLabels => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get preferredStore => text().nullable()();
  TextColumn get cheapestKnownStore => text().nullable()();
  RealColumn get cheapestKnownPrice => real().nullable()();
  RealColumn get quantity => real().nullable()();
  TextColumn get unit => text().nullable()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalExpenses extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get category => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text().nullable()();
  TextColumn get monthKey => text()();
  TextColumn get attachmentUrls => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  RealColumn get locationLat => real().nullable()();
  RealColumn get locationLng => real().nullable()();
  TextColumn get locationAddress => text().nullable()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalMealPlans extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get planJson => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueueEntries extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get domain => text()();
  TextColumn get action => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async => db_connection.openDatabaseConnection());
}

@DriftDatabase(
  tables: [LocalShoppingItems, LocalExpenses, LocalMealPlans, SyncQueueEntries],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  static final AppDatabase instance = AppDatabase._internal();

  @override
  int get schemaVersion => 1;
}
