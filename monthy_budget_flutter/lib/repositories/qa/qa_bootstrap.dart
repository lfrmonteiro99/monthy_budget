import '../../config/qa_mode.dart';
import '../../models/onboarding_state.dart';
import '../../services/household_service.dart';
import '../../services/local_config_service.dart';
import '../../services/subscription_service.dart';
import '../local/app_database.dart';
import '../local/qa_local_store.dart';
import '../repository_factory.dart';
import 'qa_repository_provider.dart';
import 'qa_seed.dart';

/// One-shot QA-mode wiring: open the local database, seed it, and point
/// [RepositoryFactory] at the sqlite-backed repositories.
///
/// Called only from the `if (kQaMode)` branch in `main()`, so a normal build
/// tree-shakes this file and everything it reaches.
class QaBootstrap {
  QaBootstrap._(this.profile, this.seeded);

  /// Profile handed straight to the app shell, skipping [AuthGate].
  final HouseholdProfile profile;

  /// False when a previous run's sqlite data was reused (browser reload).
  final bool seeded;

  /// Coach-mark tours that would otherwise dim the first screen they appear on.
  /// Keys mirror the `isTourDone('…')` call sites in `app_home.dart` and
  /// `dashboard_container.dart`.
  static const _tourKeys = [
    'dashboard',
    'expense_tracker',
    'shopping',
    'grocery',
    'meals',
    'coach',
    'savings_goals',
    'command_assistant',
  ];

  static Future<QaBootstrap> initialize({
    AppDatabase? database,
    DateTime? now,
  }) async {
    // A fixed clock would make month keys drift out of the real "current month"
    // the UI computes from DateTime.now(); instead we pin one instant per boot
    // and derive every seeded date from it, which is what makes the dataset
    // reproducible within a run.
    final instant = now ?? DateTime.now();
    final store = QaLocalStore(database ?? AppDatabase.instance);

    final seeded = await QaSeed(
      store: store,
      householdId: kQaHouseholdId,
      userId: kQaUserId,
      userEmail: kQaUserEmail,
      now: instant,
    ).runIfNeeded();

    RepositoryFactory.instance = QaRepositoryProvider(
      store: store,
      householdId: kQaHouseholdId,
      userId: kQaUserId,
      userEmail: kQaUserEmail,
      now: () => instant,
    );

    await _suppressFirstRunOverlays();

    return QaBootstrap._(
      const HouseholdProfile(
        householdId: kQaHouseholdId,
        householdName: QaSeed.householdName,
        role: 'admin',
      ),
      seeded,
    );
  }

  /// Marks the welcome tour, every coach-mark tour and the trial-expired notice
  /// as already seen.
  ///
  /// These live in SharedPreferences, not in the seeded database, and each one
  /// renders a modal or a dimming overlay on first launch — which would leave a
  /// browser-based tester judging a greyed-out screen and unable to reach the
  /// tabs behind it.
  static Future<void> _suppressFirstRunOverlays() async {
    await LocalConfigService().saveOnboardingState(
      OnboardingState(
        welcomeSeen: true,
        toursCompleted: {for (final key in _tourKeys) key: true},
      ),
    );
    await SubscriptionService().markTrialEndNoticeSeen();
  }
}
