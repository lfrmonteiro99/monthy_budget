import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../l10n/generated/app_localizations.dart';
import '../models/notification_preferences.dart';
import '../models/recurring_expense.dart';

S _l10n() {
  final code = intl.Intl.getCurrentLocale().split('_').first;
  return lookupS(Locale(code));
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  Future<void> _refreshChain = Future.value();
  bool _budgetAlertTriggered = false;

  static const _channelId = 'budget_notifications';
  static const _channelName = 'Budget Notifications';

  // Notification ID ranges
  static const _billBaseId = 1000;
  static const _budgetAlertId = 2000;
  static const _mealPlanId = 2001;
  static const _customBaseId = 3000;

  Future<void> init() async {
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

    if (prefs.mealPlanReminders && !hasMealPlan) {
      await _scheduleMealPlanReminder();
    }

    for (int i = 0; i < prefs.customReminders.length; i++) {
      await _scheduleCustomReminder(prefs.customReminders[i], i);
    }
  }

  Future<void> _scheduleBillReminders({
    required List<RecurringExpense> recurringExpenses,
    required int daysBefore,
  }) async {
    final active = recurringExpenses
        .where((r) => r.isActive && r.dayOfMonth != null)
        .toList();

    for (int i = 0; i < active.length; i++) {
      final expense = active[i];
      final l10n = _l10n();
      final now = DateTime.now();
      final dueDay = expense.dayOfMonth!.clamp(1, 31);
      var dueDate = DateTime(now.year, now.month, dueDay, 9);

      // If due date already passed this month, schedule for next month
      if (dueDate.isBefore(now)) {
        dueDate = DateTime(now.year, now.month + 1, dueDay, 9);
      }

      var reminderDate = dueDate.subtract(Duration(days: daysBefore));

      // If we're already inside the reminder window (e.g. tomorrow is due and
      // today has already started), schedule a near-future notification so the
      // user still gets warned.
      if (!reminderDate.isAfter(now) && dueDate.isAfter(now)) {
        reminderDate = now.add(const Duration(minutes: 1));
      }

      if (!reminderDate.isAfter(now)) continue;

      try {
        await _plugin.zonedSchedule(
          _billBaseId + i,
          l10n.notificationBillTitle(expense.description ?? expense.category),
          l10n.notificationBillBody(
            expense.amount.toStringAsFixed(2),
            '$daysBefore',
          ),
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
    final l10n = _l10n();
    final body = categoryName == null
        ? l10n.notificationBudgetBody('$usagePercent')
        : l10n.notificationBudgetCategoryBody(categoryName, '$usagePercent');
    try {
      await _plugin.show(
        _budgetAlertId,
        l10n.notificationBudgetTitle,
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

  Future<void> _scheduleMealPlanReminder() async {
    // Schedule for next Monday at 9am
    final now = DateTime.now();
    var nextMonday = now.add(Duration(days: (8 - now.weekday) % 7));
    if (nextMonday.isBefore(now) ||
        nextMonday.difference(now).inHours < 1) {
      nextMonday = nextMonday.add(const Duration(days: 7));
    }
    final scheduledDate =
        DateTime(nextMonday.year, nextMonday.month, nextMonday.day, 9);

    try {
      final l10n = _l10n();
      await _plugin.zonedSchedule(
        _mealPlanId,
        l10n.notificationMealPlanTitle,
        l10n.notificationMealPlanBody,
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
