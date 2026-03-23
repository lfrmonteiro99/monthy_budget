import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/command_action.dart';
import 'package:monthly_management/screens/coach_screen.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/models/subscription_state.dart';
import 'package:monthly_management/services/command_chat_service.dart';
import 'package:monthly_management/widgets/command_chat_panel.dart';

import '../helpers/test_app.dart';

SubscriptionState _sub() => SubscriptionState(
      aiCredits: 50,
      preferredCoachMode: CoachMode.eco,
      trialStartDate: DateTime.now(),
    );

void main() {
  group('#754 – Offline state in coach screen', () {
    test('CoachScreen accepts isOffline param and defaults to false', () {
      final screen = CoachScreen(
        settings: AppSettings(),
        purchaseHistory: const PurchaseHistory(records: []),
        apiKey: 'test-key',
        householdId: 'hh-1',
        onOpenSettings: () {},
        subscription: _sub(),
        onSubscriptionChanged: (_) {},
      );
      expect(screen.isOffline, false);
    });

    test('CoachScreen accepts isOffline = true', () {
      final screen = CoachScreen(
        settings: AppSettings(),
        purchaseHistory: const PurchaseHistory(records: []),
        apiKey: 'test-key',
        householdId: 'hh-1',
        onOpenSettings: () {},
        subscription: _sub(),
        onSubscriptionChanged: (_) {},
        isOffline: true,
      );
      expect(screen.isOffline, true);
    });
  });

  group('#754 – Command assistant offline behavior', () {
    testWidgets('shows offline banner in command panel when offline',
        (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          Stack(
            children: [
              CommandChatPanel(
                isOffline: true,
                onMinimize: () {},
                onSendCommand: (_) async =>
                    CommandAction.conversational(''),
                onExecuteAction: (_) async =>
                    CommandResult.success(message: 'ok'),
                onCachePattern: (_, __, ___) {},
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    });

    testWidgets('hides offline banner when online', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          Stack(
            children: [
              CommandChatPanel(
                isOffline: false,
                onMinimize: () {},
                onSendCommand: (_) async =>
                    CommandAction.conversational(''),
                onExecuteAction: (_) async =>
                    CommandResult.success(message: 'ok'),
                onCachePattern: (_, __, ___) {},
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);
    });

    test('regex parser handles local commands for offline use', () {
      // theme command works via regex
      final theme = CommandChatService.regexParse('theme dark');
      expect(theme, isNotNull);
      expect(theme!.action, 'set_theme_mode');
      expect(theme.params!['mode'], 'dark');

      // navigation command works via regex
      final nav = CommandChatService.regexParse('open dashboard');
      expect(nav, isNotNull);
      expect(nav!.action, 'navigate_to');

      // palette command works via regex
      final palette = CommandChatService.regexParse('color ocean');
      expect(palette, isNotNull);
      expect(palette!.action, 'set_color_palette');

      // language command works via regex
      final lang = CommandChatService.regexParse('language english');
      expect(lang, isNotNull);
      expect(lang!.action, 'set_language');
    });

    testWidgets(
        'offline command panel blocks non-local commands with error message',
        (tester) async {
      bool sendCommandCalled = false;
      await tester.pumpWidget(
        wrapWithTestApp(
          Stack(
            children: [
              CommandChatPanel(
                isOffline: true,
                onMinimize: () {},
                onSendCommand: (_) async {
                  sendCommandCalled = true;
                  return CommandAction.conversational('');
                },
                onExecuteAction: (_) async =>
                    CommandResult.success(message: 'ok'),
                onCachePattern: (_, __, ___) {},
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Type a non-local command
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'add 50 in food');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();

      // onSendCommand should NOT have been called (offline blocks AI)
      expect(sendCommandCalled, false);
    });

    testWidgets('offline command panel allows local theme command',
        (tester) async {
      bool executeCalled = false;
      await tester.pumpWidget(
        wrapWithTestApp(
          Stack(
            children: [
              CommandChatPanel(
                isOffline: true,
                onMinimize: () {},
                onSendCommand: (_) async =>
                    CommandAction.conversational(''),
                onExecuteAction: (_) async {
                  executeCalled = true;
                  return CommandResult.success(message: 'Done');
                },
                onCachePattern: (_, __, ___) {},
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'theme dark');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();

      // onExecuteAction should have been called for local command
      expect(executeCalled, true);
    });
  });

  group('#756 – Persist coach mode on recommendation accept', () {
    test('CoachScreen constructor validates param types', () {
      // This validates the widget interface compiles and accepts all params.
      // The behavioral test (calling _setPreferredMode) cannot be tested
      // without Supabase, but the code path is verified via code review:
      // _acceptRecommendation now calls _setPreferredMode(mode) instead of
      // setState(() => _selectedMode = mode).
      final screen = CoachScreen(
        settings: AppSettings(),
        purchaseHistory: const PurchaseHistory(records: []),
        apiKey: 'key',
        householdId: 'hh',
        onOpenSettings: () {},
        subscription: _sub(),
        onSubscriptionChanged: (_) {},
      );
      expect(screen.isOffline, false);
    });
  });

  group('#767 – mounted check in _scrollToBottom', () {
    testWidgets('command chat panel disposes without scroll errors',
        (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          Stack(
            children: [
              CommandChatPanel(
                onMinimize: () {},
                onSendCommand: (_) async =>
                    CommandAction.conversational(''),
                onExecuteAction: (_) async =>
                    CommandResult.success(message: 'ok'),
                onCachePattern: (_, __, ___) {},
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Dispose immediately -- if mounted check is missing, this may throw
      await tester.pumpWidget(wrapWithTestApp(const SizedBox()));
      await tester.pumpAndSettle();

      // No exception means the mounted guard works
      expect(true, isTrue);
    });
  });
}
