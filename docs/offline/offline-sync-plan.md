## Offline Sync Architecture (Issue #647)

1. **Local models.** Mirror Supabase tables (shopping_items, expenses, meal_plans, goals) with Drift tables under `lib/repositories/local/`. Keep canonical fields (`id`, timestamps, checked/verified flags) so syncing is deterministic.

2. **Repository layer.** Each service (shopping list, expenses, meal plans) gets both a local DAO and the existing remote `Supabase...Repository`. A sync orchestrator routes writes through the local DAO first and records the operation in a `sync_queue` table for reconciliation.

3. **Connectivity monitor.** `ConnectivityService` watches `connectivity_plus` and exposes `Future<bool> checkConnectivity()` plus a broadcast stream. UI elements can subscribe to show offline banners or “pending sync” badges.

4. **Sync supervisor.** A `SyncService` runs on app startup and network changes, reads queued operations, attempts to replay them against Supabase, and marks items as synced or failed. Conflicts use last-write-wins based on stored timestamps.

5. **UI indicators.** Reuse existing banner placeholders (e.g., `OfflineBanner` in shared widgets) to show offline state, plus a badge on pending items that have `pending_sync` true.

6. **Testing strategy.** Unit tests cover DAOs, sync queue handling, conflict resolution, and connectivity-state transitions. Integration tests simulate offline/online toggles and verify the queue drains when connectivity returns.
