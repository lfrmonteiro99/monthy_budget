import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../constants/app_constants.dart';
import '../models/notification_preferences.dart';
import '../models/recurring_expense.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  Future<void>? _initFuture;
  Future<void> _refreshChain = Future.value();
  bool _budgetAlertTriggered = false;

  static const _channelId = 'budget_notifications';
  static const _channelName = 'Budget Notifications';

  // Notification ID ranges
  static const _billBaseId = 1000;
  static const _budgetAlertId = 2000;
  static const _mealPlanId = 2001;
  static const _trialExpiryId = 2002;
  static const _dailyExpenseId = 2003;
  static const _customBaseId = 3000;

  Future<void> init() {
    _initFuture ??= _doInit();
    return _initFuture!;
  }

  Future<void> _doInit() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);
    _initialized = true;

    await requestPermission();
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> refreshAllSchedules({
    required NotificationPreferences prefs,
    required List<RecurringExpense> recurringExpenses,
    required double budgetUsagePercent,
    required bool hasMealPlan,
    String? topCategoryName,
    double? topCategoryUsagePercent,
  }) async {
    if (!_initialized) {
      if (_initFuture != null) {
        await _initFuture;
      } else {
        return; // init() never called — skip silently
      }
    }
    _refreshChain = _refreshChain.then((_) async {
      await _refreshAllSchedulesImpl(
        prefs: prefs,
        recurringExpenses: recurringExpenses,
        budgetUsagePercent: budgetUsagePercent,
        hasMealPlan: hasMealPlan,
        topCategoryName: topCategoryName,
        topCategoryUsagePercent: topCategoryUsagePercent,
      );
    }).catchError((e) {
      debugPrint('Failed to refresh notification schedules: $e');
    });
    await _refreshChain;
  }

  Future<void> _refreshAllSchedulesImpl({
    required NotificationPreferences prefs,
    required List<RecurringExpense> recurringExpenses,
    required double budgetUsagePercent,
    required bool hasMealPlan,
    String? topCategoryName,
    double? topCategoryUsagePercent,
  }) async {
    await cancelAll();

    if (prefs.billReminders) {
      await _scheduleBillReminders(
        recurringExpenses: recurringExpenses,
        daysBefore: prefs.billReminderDaysBefore,
        hour: prefs.preferredHour,
        minute: prefs.preferredMinute,
      );
    }

    final threshold = prefs.budgetAlertThreshold;
    final categoryExceeded =
        (topCategoryUsagePercent ?? 0) >= threshold;
    final overallExceeded = budgetUsagePercent >= threshold;
    final shouldAlert = prefs.budgetAlerts && (overallExceeded || categoryExceeded);

    if (!shouldAlert) {
      _budgetAlertTriggered = false;
    } else if (!_budgetAlertTriggered) {
      await _showBudgetAlert(
        usagePercent: overallExceeded
            ? budgetUsagePercent.round()
            : (topCategoryUsagePercent ?? budgetUsagePercent).round(),
        categoryName: categoryExceeded ? topCategoryName : null,
      );
      _budgetAlertTriggered = true;
    }

    if (prefs.dailyExpenseReminder) {
      await _scheduleDailyExpenseReminder(prefs);
    }

    if (prefs.mealPlanReminders && !hasMealPlan) {
      await _scheduleMealPlanReminder(
        hour: prefs.preferredHour,
        minute: prefs.preferredMinute,
      );
    }

    for (int i = 0; i < prefs.customReminders.length; i++) {
      await _scheduleCustomReminder(prefs.customReminders[i], i);
    }
  }

  Future<void> _scheduleDailyExpenseReminder(
      NotificationPreferences prefs) async {
    final now = DateTime.now();
    var scheduledDate =
        DateTime(now.year, now.month, now.day, prefs.preferredHour, prefs.preferredMinute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        _dailyExpenseId,
        'Don\'t forget your expenses!',
        'Take a moment to log today\'s expenses',
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Failed to schedule daily expense reminder: $e');
    }
  }

  Future<void> _scheduleBillReminders({
    required List<RecurringExpense> recurringExpenses,
    required int daysBefore,
    required int hour,
    required int minute,
  }) async {
    final active = recurringExpenses
        .where((r) => r.isActive && r.dayOfMonth != null)
        .toList();

    for (int i = 0; i < active.length; i++) {
      final expense = active[i];
      final now = DateTime.now();
      final dueDay = expense.dayOfMonth!.clamp(1, 31);
      var dueDate = DateTime(now.year, now.month, dueDay, hour, minute);

      // If due date already passed this month, schedule for next month
      if (dueDate.isBefore(now)) {
        dueDate = DateTime(now.year, now.month + 1, dueDay, hour, minute);
      }

      var reminderDate = dueDate.subtract(Duration(days: daysBefore));

      // If we're already inside the reminder window (e.g. tomorrow is due and
      // today has already started), schedule a near-future notification so the
      // user still gets warned.
      if (!reminderDate.isAfter(now) && dueDate.isAfter(now)) {
        reminderDate = now.add(AppConstants.nearFutureReminder);
      }

      if (!reminderDate.isAfter(now)) continue;

      final daysUntilDue = dueDate.difference(now).inDays.clamp(0, 365);

      try {
        await _plugin.zonedSchedule(
          _billBaseId + i,
          expense.description ?? expense.category,
          '${expense.amount.toStringAsFixed(2)} due in $daysUntilDue days',
          tz.TZDateTime.from(reminderDate, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
        );
      } catch (e) {
        debugPrint('Failed to schedule bill reminder: $e');
      }
    }
  }

  Future<void> _showBudgetAlert({
    required int usagePercent,
    String? categoryName,
  }) async {
    final body = categoryName == null
        ? 'You\'ve spent $usagePercent% of your monthly budget'
        : 'Category "$categoryName" reached $usagePercent% of budget';
    try {
      await _plugin.show(
        _budgetAlertId,
        'Budget alert',
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Failed to show budget alert: $e');
    }
  }

  Future<void> _scheduleMealPlanReminder({
    required int hour,
    required int minute,
  }) async {
    // Schedule for next Monday at preferred time
    final now = DateTime.now();
    var nextMonday = now.add(Duration(days: (8 - now.weekday) % 7));
    if (nextMonday.isBefore(now) ||
        nextMonday.difference(now).inHours < 1) {
      nextMonday = nextMonday.add(const Duration(days: 7));
    }
    final scheduledDate =
        DateTime(nextMonday.year, nextMonday.month, nextMonday.day, hour, minute);

    try {
      await _plugin.zonedSchedule(
        _mealPlanId,
        'Meal plan',
        'You haven\'t generated this month\'s meal plan yet',
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Failed to schedule meal plan reminder: $e');
    }
  }

  /// Schedule a pre-expiry notification for trial users.
  ///
  /// Fires when there are [daysBeforeExpiry] days left, showing the user
  /// how many categories and savings goals will be paused on downgrade.
  Future<void> scheduleTrialExpiryReminder({
    required DateTime trialEndDate,
    required int activeCategories,
    required int activeSavingsGoals,
    required int maxFreeCategories,
    required int maxFreeSavingsGoals,
    int daysBeforeExpiry = 10,
    int preferredHour = 10,
    int preferredMinute = 0,
  }) async {
    final reminderDate = trialEndDate.subtract(Duration(days: daysBeforeExpiry));
    final now = DateTime.now();

    if (!reminderDate.isAfter(now)) return;

    final excessCats = (activeCategories - maxFreeCategories).clamp(0, activeCategories);
    final excessGoals = (activeSavingsGoals - maxFreeSavingsGoals).clamp(0, activeSavingsGoals);

    final parts = <String>[];
    if (excessCats > 0) parts.add('$excessCats categories');
    if (excessGoals > 0) parts.add('$excessGoals savings goals');

    final body = parts.isEmpty
        ? 'Your trial ends in $daysBeforeExpiry days. Upgrade to keep all premium features.'
        : 'Your trial ends in $daysBeforeExpiry days. ${parts.join(' and ')} will be paused on the free plan.';

    try {
      await _plugin.zonedSchedule(
        _trialExpiryId,
        'Trial ending soon',
        body,
        tz.TZDateTime.from(
          DateTime(reminderDate.year, reminderDate.month, reminderDate.day, preferredHour, preferredMinute),
          tz.local,
        ),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Failed to schedule trial expiry reminder: $e');
    }
  }

  /// Build the body text for the trial expiry reminder notification.
  ///
  /// Exposed for testing since notification scheduling requires platform setup.
  static String buildTrialExpiryBody({
    required int daysBeforeExpiry,
    required int activeCategories,
    required int activeSavingsGoals,
    required int maxFreeCategories,
    required int maxFreeSavingsGoals,
  }) {
    final excessCats =
        (activeCategories - maxFreeCategories).clamp(0, activeCategories);
    final excessGoals =
        (activeSavingsGoals - maxFreeSavingsGoals).clamp(0, activeSavingsGoals);

    final parts = <String>[];
    if (excessCats > 0) parts.add('$excessCats categories');
    if (excessGoals > 0) parts.add('$excessGoals savings goals');

    if (parts.isEmpty) {
      return 'Your trial ends in $daysBeforeExpiry days. Upgrade to keep all premium features.';
    }
    return 'Your trial ends in $daysBeforeExpiry days. ${parts.join(' and ')} will be paused on the free plan.';
  }

  Future<void> _scheduleCustomReminder(
      CustomReminder reminder, int index) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
        now.year, now.month, now.day, reminder.hour, reminder.minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      final matchDateTimeComponents = switch (reminder.repeat) {
        ReminderRepeat.daily => DateTimeComponents.time,
        ReminderRepeat.weekly => DateTimeComponents.dayOfWeekAndTime,
        ReminderRepeat.monthly => DateTimeComponents.dayOfMonthAndTime,
        ReminderRepeat.none => null,
      };

      await _plugin.zonedSchedule(
        _customBaseId + index,
        reminder.title,
        reminder.body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    } catch (e) {
      debugPrint('Failed to schedule custom reminder: $e');
    }
  }
}
