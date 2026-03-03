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

  const NotificationPreferences({
    this.billReminders = false,
    this.billReminderDaysBefore = 1,
    this.budgetAlerts = false,
    this.budgetAlertThreshold = 80,
    this.mealPlanReminders = false,
    this.customReminders = const [],
  });

  NotificationPreferences copyWith({
    bool? billReminders,
    int? billReminderDaysBefore,
    bool? budgetAlerts,
    int? budgetAlertThreshold,
    bool? mealPlanReminders,
    List<CustomReminder>? customReminders,
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
      });

  factory NotificationPreferences.fromJsonString(String s) {
    final json = jsonDecode(s) as Map<String, dynamic>;
    return NotificationPreferences(
      billReminders: json['billReminders'] as bool? ?? false,
      billReminderDaysBefore:
          json['billReminderDaysBefore'] as int? ?? 1,
      budgetAlerts: json['budgetAlerts'] as bool? ?? false,
      budgetAlertThreshold:
          json['budgetAlertThreshold'] as int? ?? 80,
      mealPlanReminders: json['mealPlanReminders'] as bool? ?? false,
      customReminders: (json['customReminders'] as List<dynamic>?)
              ?.map((e) =>
                  CustomReminder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
