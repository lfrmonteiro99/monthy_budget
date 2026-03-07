class CommandAction {
  final String? action;
  final Map<String, dynamic>? params;
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

  factory CommandAction.fromJson(Map<String, dynamic> json) {
    return CommandAction(
      action: json['action'] as String?,
      params: json['params'] as Map<String, dynamic>?,
      message: (json['message'] as String?) ?? '',
    );
  }

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
