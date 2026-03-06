import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/command_action.dart';
import 'package:orcamento_mensal/widgets/command_chat_panel.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('shows capabilities sheet from header action', (tester) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        Stack(
          children: [
            CommandChatPanel(
              onMinimize: () {},
              onSendCommand: (_) async => CommandAction.conversational(''),
              onExecuteAction: (_) async =>
                  CommandResult.success(message: 'ok'),
              onCachePattern: (input, action, params) {},
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('What can I do?').first);
    await tester.pumpAndSettle();

    expect(find.text('Available actions'), findsOneWidget);
    expect(find.text('Add an expense'), findsOneWidget);
    expect(find.text('Add a shopping item'), findsOneWidget);
    expect(
      find.text("We're still adding more. If it isn't listed here yet, it may not work."),
      findsOneWidget,
    );
  });
}
