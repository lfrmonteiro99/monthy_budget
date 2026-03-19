// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommandAction _$CommandActionFromJson(Map<String, dynamic> json) =>
    CommandAction(
      action: json['action'] as String?,
      params: json['params'] as Map<String, dynamic>?,
      message: json['message'] as String? ?? '',
    );

Map<String, dynamic> _$CommandActionToJson(CommandAction instance) =>
    <String, dynamic>{
      'action': ?instance.action,
      'params': ?instance.params,
      'message': instance.message,
    };
