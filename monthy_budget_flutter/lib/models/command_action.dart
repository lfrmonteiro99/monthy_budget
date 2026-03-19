import 'package:json_annotation/json_annotation.dart';

part 'command_action.g.dart';

@JsonSerializable(includeIfNull: false)
class CommandAction {
  final String? action;
  final Map<String, dynamic>? params;
  @JsonKey(defaultValue: '')
  final String message;

  const CommandAction({
    this.action,
    this.params,
    required this.message,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandAction &&
          action == other.action &&
          message == other.message;

  @override
  int get hashCode => Object.hash(action, message);

  bool get hasAction => action != null && action!.isNotEmpty;

  factory CommandAction.fromJson(Map<String, dynamic> json) =>
      _$CommandActionFromJson(json);

  factory CommandAction.conversational(String message) {
    return CommandAction(message: message);
  }

  factory CommandAction.withAction({
    required String action,
    required Map<String, dynamic> params,
    required String message,
  }) {
    return CommandAction(
      action: action,
      params: params,
      message: message,
    );
  }

  Map<String, dynamic> toJson() => _$CommandActionToJson(this);
}

class CommandResult {
  final bool succeeded;
  final String message;
  final Future<void> Function()? undoAction;

  const CommandResult({
    required this.succeeded,
    required this.message,
    this.undoAction,
  });

  factory CommandResult.success({
    required String message,
    Future<void> Function()? undoAction,
  }) {
    return CommandResult(
      succeeded: true,
      message: message,
      undoAction: undoAction,
    );
  }

  factory CommandResult.failure({required String message}) {
    return CommandResult(
      succeeded: false,
      message: message,
    );
  }
}
