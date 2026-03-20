import 'package:drift/drift.dart';

Future<QueryExecutor> openDatabaseConnection() async {
  throw UnsupportedError(
    'Database connection is not supported on this platform.',
  );
}
