import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

import '../../services/log_service.dart';

/// Opens the sqlite3 WASM build served from `web/`.
///
/// Replaces the deprecated `drift/web.dart` `WebDatabase` (sql.js), which needed
/// a `sql-wasm.js` asset that was never shipped — so the web build had no
/// working local database at all.
///
/// ## Asset versions are pinned to pubspec.lock — do not mix them
///
/// Both assets are compiled artefacts that must match the resolved package
/// versions, because the Dart side declares the exact imports the binary has to
/// provide. Mixing versions fails at load with an opaque
/// `WebAssembly.instantiate(): Import #N "env" ...` TypeError.
///
/// | asset             | must match       | download from                                                   |
/// |-------------------|------------------|-----------------------------------------------------------------|
/// | `web/sqlite3.wasm`| `sqlite3` in lock| github.com/simolus3/sqlite3.dart/releases/tag/sqlite3-`<version>`|
/// | `web/drift_worker.js` | `drift` in lock | github.com/simolus3/drift/releases/tag/drift-`<version>`      |
///
/// So after bumping either package, re-download the matching asset.
Future<QueryExecutor> openDatabaseConnection() async {
  final WasmDatabaseResult result;
  try {
    result = await WasmDatabase.open(
      databaseName: 'monthly_budget',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
  } catch (e, stack) {
    Error.throwWithStackTrace(
      StateError(
        'Failed to open the web database. web/sqlite3.wasm and '
        'web/drift_worker.js must match the sqlite3 and drift versions in '
        'pubspec.lock — an "Import #N env" TypeError means they do not. '
        'Underlying error: $e',
      ),
      stack,
    );
  }

  // Persistence degrades rather than failing the boot: drift has already fallen
  // back to the best storage the browser supports (in-memory in the worst case),
  // so this is reported, not thrown.
  if (result.missingFeatures.isNotEmpty) {
    LogService.warning(
      'Browser is missing storage features — local database is using '
      '${result.chosenImplementation.name}',
      category: 'storage.web',
      data: {
        'missing_features': result.missingFeatures.map((f) => f.name).toList(),
      },
    );
  }

  return result.resolvedExecutor;
}
