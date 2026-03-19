import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'notification_preferences.g.dart';

enum ReminderRepeat { none, daily, weekly, monthly }

@JsonSerializable()
class CustomReminder {
  final String id;
  final String title;
  final String body;
  final int hour;
  final int minute;
  @JsonKey(unknownEnumValue: ReminderRepeat.none)
  final ReminderRepeat repeat;
  final List<int> repeatDays; // 1=Mon..7=Sun for weekly

  const CustomReminder({
    required this.id,
    required this.title,
    required this.body,
    this.hour = 9,
    this.minute = 0,
    this.repeat = ReminderRepeat.none,
    this.repeatDays = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomReminder &&
          id == other.id &&
          title == other.title &&
          body == other.body &&
          hour == other.hour &&
          minute == other.minute &&
          repeat == other.repeat;

  @override
  int get hashCode => Object.hash(id, title, body, hour, minute, repeat);

  factory CustomReminder.fromJson(Map<String, dynamic> json) =>
      _$CustomReminderFromJson(json);

  Map<String, dynamic> toJson() => _$CustomReminderToJson(this);
}

@JsonSerializable()
class NotificationPreferences {
  final bool dailyExpenseReminder;
  final bool billReminders;
  final int billReminderDaysBefore;
  final bool budgetAlerts;
  @JsonKey(fromJson: _budgetAlertThresholdFromJson)
  final int budgetAlertThreshold; // percentage 0-100
  final bool mealPlanReminders;
  final List<CustomReminder> customReminders;
  final int preferredHour;
  final int preferredMinute;

  NotificationPreferences({
    this.dailyExpenseReminder = true,
    this.billReminders = false,
    this.billReminderDaysBefore = 1,
    this.budgetAlerts = false,
    this.budgetAlertThreshold = 80,
    this.mealPlanReminders = false,
    this.customReminders = const [],
    this.preferredHour = 9,
    this.preferredMinute = 0,
  }) : assert(
         budgetAlertThreshold >= 0 && budgetAlertThreshold <= 100,
         'budgetAlertThreshold must be between 0 and 100',
       );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferences &&
          dailyExpenseReminder == other.dailyExpenseReminder &&
          billReminders == other.billReminders &&
          billReminderDaysBefore == other.billReminderDaysBefore &&
          budgetAlerts == other.budgetAlerts &&
          budgetAlertThreshold == other.budgetAlertThreshold &&
          mealPlanReminders == other.mealPlanReminders &&
          preferredHour == other.preferredHour &&
          preferredMinute == other.preferredMinute;

  @override
  int get hashCode => Object.hash(
        dailyExpenseReminder, billReminders, billReminderDaysBefore,
        budgetAlerts, budgetAlertThreshold, mealPlanReminders,
        preferredHour, preferredMinute,
      );

  NotificationPreferences copyWith({
    bool? dailyExpenseReminder,
    bool? billReminders,
    int? billReminderDaysBefore,
    bool? budgetAlerts,
    int? budgetAlertThreshold,
    bool? mealPlanReminders,
    List<CustomReminder>? customReminders,
    int? preferredHour,
    int? preferredMinute,
  }) {
    return NotificationPreferences(
      dailyExpenseReminder:
          dailyExpenseReminder ?? this.dailyExpenseReminder,
      billReminders: billReminders ?? this.billReminders,
      billReminderDaysBefore:
          billReminderDaysBefore ?? this.billReminderDaysBefore,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      budgetAlertThreshold:
          budgetAlertThreshold ?? this.budgetAlertThreshold,
      mealPlanReminders: mealPlanReminders ?? this.mealPlanReminders,
      customReminders: customReminders ?? this.customReminders,
      preferredHour: preferredHour ?? this.preferredHour,
      preferredMinute: preferredMinute ?? this.preferredMinute,
    );
  }

  String toJsonString() => jsonEncode({
        ...toJson(),
      });

  factory NotificationPreferences.fromJsonString(String s) {
    return NotificationPreferences.fromJson(jsonDecode(s) as Map<String, dynamic>);
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPreferencesToJson(this);

  static int _budgetAlertThresholdFromJson(Object? value) {
    final rawValue = value as int? ?? 80;
    return rawValue.clamp(0, 100);
  }
}
