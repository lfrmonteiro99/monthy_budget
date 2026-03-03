import 'dart:convert';

class OnboardingState {
  final bool welcomeSeen;
  final Map<String, bool> toursCompleted;

  const OnboardingState({
    this.welcomeSeen = false,
    this.toursCompleted = const {},
  });

  bool isTourDone(String key) => toursCompleted[key] ?? false;

  OnboardingState copyWith({
    bool? welcomeSeen,
    Map<String, bool>? toursCompleted,
  }) {
    return OnboardingState(
      welcomeSeen: welcomeSeen ?? this.welcomeSeen,
      toursCompleted: toursCompleted ?? this.toursCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'welcomeSeen': welcomeSeen,
        'toursCompleted': toursCompleted,
      };

  factory OnboardingState.fromJson(Map<String, dynamic> json) {
    return OnboardingState(
      welcomeSeen: json['welcomeSeen'] as bool? ?? false,
      toursCompleted: (json['toursCompleted'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as bool)) ??
          const {},
    );
  }

  factory OnboardingState.fromJsonString(String s) =>
      OnboardingState.fromJson(jsonDecode(s) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());
}
