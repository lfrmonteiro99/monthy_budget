import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'onboarding_state.g.dart';

@JsonSerializable()
class OnboardingState {
  final bool welcomeSeen;
  final Map<String, bool> toursCompleted;

  const OnboardingState({
    this.welcomeSeen = false,
    this.toursCompleted = const {},
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingState &&
          welcomeSeen == other.welcomeSeen &&
          _mapsEqual(toursCompleted, other.toursCompleted);

  @override
  int get hashCode => Object.hash(welcomeSeen, Object.hashAll(toursCompleted.entries));

  static bool _mapsEqual(Map<String, bool> a, Map<String, bool> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

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

  Map<String, dynamic> toJson() => _$OnboardingStateToJson(this);

  factory OnboardingState.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStateFromJson(json);

  factory OnboardingState.fromJsonString(String s) =>
      OnboardingState.fromJson(jsonDecode(s) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());
}
