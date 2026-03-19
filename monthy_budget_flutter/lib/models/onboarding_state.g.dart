// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnboardingState _$OnboardingStateFromJson(Map<String, dynamic> json) =>
    OnboardingState(
      welcomeSeen: json['welcomeSeen'] as bool? ?? false,
      toursCompleted:
          (json['toursCompleted'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const {},
    );

Map<String, dynamic> _$OnboardingStateToJson(OnboardingState instance) =>
    <String, dynamic>{
      'welcomeSeen': instance.welcomeSeen,
      'toursCompleted': instance.toursCompleted,
    };
