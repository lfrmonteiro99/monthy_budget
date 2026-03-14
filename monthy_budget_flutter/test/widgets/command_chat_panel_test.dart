import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/command_action.dart';
import 'package:monthly_management/widgets/command_chat_panel.dart';

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
    await tester.scrollUntilVisible(
      find.text('Delete an expense', skipOffstage: false),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Check or uncheck a shopping item', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Delete an expense', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text("We're still adding more. If it isn't listed here yet, it may not work."),
      findsOneWidget,
    );
  });
}
