import 'package:flutter/services.dart';

/// Supported quick-action intents dispatched from Android app shortcuts
/// or the in-app quick-add launcher.
enum QuickAction {
  addExpense('quick_add_expense'),
  addShopping('quick_add_shopping'),
  openMeals('open_meals'),
  openAssistant('open_assistant');

  const QuickAction(this.type);
  final String type;

  static QuickAction? fromType(String? type) {
    if (type == null) return null;
    for (final action in values) {
      if (action.type == type) return action;
    }
    return null;
  }
}

/// Listens for quick-action intents delivered via a platform [MethodChannel].
///
/// On Android, static shortcuts declared in `shortcuts.xml` launch the app
/// with an extra that is forwarded here through `MainActivity`.
class QuickActionService {
  QuickActionService._();
  static final instance = QuickActionService._();

  static const _channel = MethodChannel('com.orcamentomensal/quick_actions');

  void Function(QuickAction action)? _handler;

  /// The action that was pending when the handler was not yet attached.
  QuickAction? _pending;

  /// Start listening. Call once from [initState] of the shell widget.
  void init({required void Function(QuickAction action) onAction}) {
    _handler = onAction;

    // Deliver any action that arrived before init.
    if (_pending != null) {
      _handler?.call(_pending!);
      _pending = null;
    }

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'quickAction') {
        final action = QuickAction.fromType(call.arguments as String?);
        if (action != null) {
          _handler?.call(action);
        }
      }
    });
  }

  /// Deliver an action from cold-start (before handler is attached).
  void deliverInitialAction(String? type) {
    final action = QuickAction.fromType(type);
    if (action == null) return;

    if (_handler != null) {
      _handler!(action);
    } else {
      _pending = action;
    }
  }

  void dispose() {
    _handler = null;
    _channel.setMethodCallHandler(null);
  }
}
