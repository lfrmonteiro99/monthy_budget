import 'dart:convert';

enum ReminderRepeat { none, daily, weekly, monthly }

class CustomReminder {
  final String id;
  final String title;
  final String body;
  final int hour;
  final int minute;
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'hour': hour,
        'minute': minute,
        'repeat': repeat.name,
        'repeatDays': repeatDays,
      };

  factory CustomReminder.fromJson(Map<String, dynamic> json) =>
      CustomReminder(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        hour: json['hour'] as int? ?? 9,
        minute: json['minute'] as int? ?? 0,
        repeat: ReminderRepeat.values.firstWhere(
          (r) => r.name == (json['repeat'] as String?),
          orElse: () => ReminderRepeat.none,
        ),
        repeatDays: (json['repeatDays'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [],
      );
}

class NotificationPreferences {
  final bool billReminders;
  final int billReminderDaysBefore;
  final bool budgetAlerts;
  final int budgetAlertThreshold; // percentage 0-100
  final bool mealPlanReminders;
  final List<CustomReminder> customReminders;
  final int preferredHour;
  final int preferredMinute;

  NotificationPreferences({
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
          billReminders == other.billReminders &&
          billReminderDaysBefore == other.billReminderDaysBefore &&
          budgetAlerts == other.budgetAlerts &&
          budgetAlertThreshold == other.budgetAlertThreshold &&
          mealPlanReminders == other.mealPlanReminders &&
          preferredHour == other.preferredHour &&
          preferredMinute == other.preferredMinute;

  @override
  int get hashCode => Object.hash(
        billReminders, billReminderDaysBefore,
        budgetAlerts, budgetAlertThreshold, mealPlanReminders,
        preferredHour, preferredMinute,
      );

  NotificationPreferences copyWith({
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
        'billReminders': billReminders,
        'billReminderDaysBefore': billReminderDaysBefore,
        'budgetAlerts': budgetAlerts,
        'budgetAlertThreshold': budgetAlertThreshold,
        'mealPlanReminders': mealPlanReminders,
        'customReminders':
            customReminders.map((r) => r.toJson()).toList(),
        'preferredHour': preferredHour,
        'preferredMinute': preferredMinute,
      });

  factory NotificationPreferences.fromJsonString(String s) {
    final json = jsonDecode(s) as Map<String, dynamic>;
    final rawThreshold = json['budgetAlertThreshold'] as int? ?? 80;
    return NotificationPreferences(
      billReminders: json['billReminders'] as bool? ?? false,
      billReminderDaysBefore:
          json['billReminderDaysBefore'] as int? ?? 1,
      budgetAlerts: json['budgetAlerts'] as bool? ?? false,
      budgetAlertThreshold: rawThreshold.clamp(0, 100),
      mealPlanReminders: json['mealPlanReminders'] as bool? ?? false,
      customReminders: (json['customReminders'] as List<dynamic>?)
              ?.map((e) =>
                  CustomReminder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      preferredHour: json['preferredHour'] as int? ?? 9,
      preferredMinute: json['preferredMinute'] as int? ?? 0,
    );
  }
}
