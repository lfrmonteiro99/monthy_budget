import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/command_action.dart';

void main() {
  group('CommandAction', () {
    group('fromJson', () {
      test('with valid action and params', () {
        final json = {
          'action': 'add_expense',
          'params': {'category': 'food', 'amount': 50.0},
          'message': 'Added expense of 50 to food.',
        };

        final cmd = CommandAction.fromJson(json);

        expect(cmd.action, 'add_expense');
        expect(cmd.params, {'category': 'food', 'amount': 50.0});
        expect(cmd.message, 'Added expense of 50 to food.');
        expect(cmd.hasAction, true);
      });

      test('with null action (conversational)', () {
        final json = {
          'action': null,
          'params': null,
          'message': 'Here is your summary.',
        };

        final cmd = CommandAction.fromJson(json);

        expect(cmd.action, isNull);
        expect(cmd.params, isNull);
        expect(cmd.message, 'Here is your summary.');
        expect(cmd.hasAction, false);
      });

      test('with missing keys defaults gracefully', () {
        final json = <String, dynamic>{};

        final cmd = CommandAction.fromJson(json);

        expect(cmd.action, isNull);
        expect(cmd.params, isNull);
        expect(cmd.message, '');
        expect(cmd.hasAction, false);
      });

      test('with empty action string hasAction is false', () {
        final json = {
          'action': '',
          'params': <String, dynamic>{},
          'message': 'Some message.',
        };

        final cmd = CommandAction.fromJson(json);

        expect(cmd.action, '');
        expect(cmd.hasAction, false);
      });
    });

    group('conversational', () {
      test('creates instance with null action and params', () {
        final cmd = CommandAction.conversational('Just a reply.');

        expect(cmd.action, isNull);
        expect(cmd.params, isNull);
        expect(cmd.message, 'Just a reply.');
        expect(cmd.hasAction, false);
      });
    });

    group('withAction', () {
      test('creates instance with action and params', () {
        final cmd = CommandAction.withAction(
          action: 'delete_category',
          params: {'id': 'cat_1'},
          message: 'Deleted category cat_1.',
        );

        expect(cmd.action, 'delete_category');
        expect(cmd.params, {'id': 'cat_1'});
        expect(cmd.message, 'Deleted category cat_1.');
        expect(cmd.hasAction, true);
      });
    });

    group('equality (#752)', () {
      test('equal when action, message and params match', () {
        final a = CommandAction.withAction(
          action: 'add_expense',
          params: {'amount': 10.0, 'category': 'food'},
          message: 'ok',
        );
        final b = CommandAction.withAction(
          action: 'add_expense',
          params: {'amount': 10.0, 'category': 'food'},
          message: 'ok',
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when params differ', () {
        final a = CommandAction.withAction(
          action: 'add_expense',
          params: {'amount': 10.0, 'category': 'food'},
          message: 'ok',
        );
        final b = CommandAction.withAction(
          action: 'add_expense',
          params: {'amount': 20.0, 'category': 'food'},
          message: 'ok',
        );
        expect(a, isNot(equals(b)));
      });

      test('equal when both params are null', () {
        final a = CommandAction.conversational('hi');
        final b = CommandAction.conversational('hi');
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when one has params and other does not', () {
        const a = CommandAction(action: 'x', params: null, message: 'ok');
        final b = CommandAction.withAction(
          action: 'x',
          params: {'key': 'val'},
          message: 'ok',
        );
        expect(a, isNot(equals(b)));
      });
    });
  });

  group('CommandResult', () {
    group('success', () {
      test('with undoAction', () {
        var undoCalled = false;
        final result = CommandResult.success(
          message: 'Expense added.',
          undoAction: () async {
            undoCalled = true;
          },
        );

        expect(result.succeeded, true);
        expect(result.message, 'Expense added.');
        expect(result.undoAction, isNotNull);

        // Verify the undo callback works
        result.undoAction!();
        expect(undoCalled, true);
      });

      test('without undoAction', () {
        final result = CommandResult.success(message: 'Done.');

        expect(result.succeeded, true);
        expect(result.message, 'Done.');
        expect(result.undoAction, isNull);
      });
    });

    group('failure', () {
      test('has no undo', () {
        final result = CommandResult.failure(message: 'Something went wrong.');

        expect(result.succeeded, false);
        expect(result.message, 'Something went wrong.');
        expect(result.undoAction, isNull);
      });
    });
  });
}
