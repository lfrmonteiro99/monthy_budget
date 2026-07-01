import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';

void main() {
  late S l10n;

  setUpAll(() async {
    l10n = await S.delegate.load(const Locale('en'));
  });

  group('coach_screen l10n #1147', () {
    test('coachSuggestionsEyebrow exists and is not hardcoded PT', () {
      final value = l10n.coachSuggestionsEyebrow;
      expect(value, isNotEmpty);
      expect(value.toUpperCase(), isNot(equals('SUGESTÕES')));
    });
  });
}
