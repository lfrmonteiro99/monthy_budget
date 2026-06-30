import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/local/app_database.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';

/// App-wide database singleton, exposed for provider wiring.
final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase.instance);

/// Owns the single [ConnectivityService] for the app (#632 increment 2).
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(service.dispose);
  return service;
});

/// Owns the single [SyncService]. `start()` wires the reconnect→sync listener
/// and runs an initial sync; the shopping repository reads this same instance,
/// so there is exactly one SyncService in the app.
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    database: ref.watch(appDatabaseProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );
  service.start();
  ref.onDispose(service.dispose);
  return service;
});

/// `true` when the device is offline. Seeds with an initial connectivity check,
/// then follows status changes.
final isOfflineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = ref.watch(connectivityServiceProvider);
  yield !(await connectivity.checkConnectivity());
  yield* connectivity.onStatusChange.map((online) => !online);
});

/// Pending sync-queue count for a household.
final pendingSyncCountProvider = StreamProvider.family<int, String>(
  (ref, householdId) =>
      ref.watch(syncServiceProvider).watchPendingCount(householdId),
);
