// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomReminder _$CustomReminderFromJson(Map<String, dynamic> json) =>
    CustomReminder(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      hour: (json['hour'] as num?)?.toInt() ?? 9,
      minute: (json['minute'] as num?)?.toInt() ?? 0,
      repeat:
          $enumDecodeNullable(
            _$ReminderRepeatEnumMap,
            json['repeat'],
            unknownValue: ReminderRepeat.none,
          ) ??
          ReminderRepeat.none,
      repeatDays:
          (json['repeatDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CustomReminderToJson(CustomReminder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'hour': instance.hour,
      'minute': instance.minute,
      'repeat': _$ReminderRepeatEnumMap[instance.repeat]!,
      'repeatDays': instance.repeatDays,
    };

const _$ReminderRepeatEnumMap = {
  ReminderRepeat.none: 'none',
  ReminderRepeat.daily: 'daily',
  ReminderRepeat.weekly: 'weekly',
  ReminderRepeat.monthly: 'monthly',
};

NotificationPreferences _$NotificationPreferencesFromJson(
  Map<String, dynamic> json,
) => NotificationPreferences(
  dailyExpenseReminder: json['dailyExpenseReminder'] as bool? ?? true,
  billReminders: json['billReminders'] as bool? ?? false,
  billReminderDaysBefore:
      (json['billReminderDaysBefore'] as num?)?.toInt() ?? 1,
  budgetAlerts: json['budgetAlerts'] as bool? ?? false,
  budgetAlertThreshold: json['budgetAlertThreshold'] == null
      ? 80
      : NotificationPreferences._budgetAlertThresholdFromJson(
          json['budgetAlertThreshold'],
        ),
  mealPlanReminders: json['mealPlanReminders'] as bool? ?? false,
  customReminders:
      (json['customReminders'] as List<dynamic>?)
          ?.map((e) => CustomReminder.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  preferredHour: (json['preferredHour'] as num?)?.toInt() ?? 9,
  preferredMinute: (json['preferredMinute'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$NotificationPreferencesToJson(
  NotificationPreferences instance,
) => <String, dynamic>{
  'dailyExpenseReminder': instance.dailyExpenseReminder,
  'billReminders': instance.billReminders,
  'billReminderDaysBefore': instance.billReminderDaysBefore,
  'budgetAlerts': instance.budgetAlerts,
  'budgetAlertThreshold': instance.budgetAlertThreshold,
  'mealPlanReminders': instance.mealPlanReminders,
  'customReminders': instance.customReminders,
  'preferredHour': instance.preferredHour,
  'preferredMinute': instance.preferredMinute,
};
