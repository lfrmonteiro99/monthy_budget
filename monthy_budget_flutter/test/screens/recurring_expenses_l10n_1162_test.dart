// TDD for issue #1162 — recurring_expenses_screen l10n
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations_en.dart';

void main() {
  late SEn en;

  setUpAll(() {
    en = SEn();
  });

  tearDownAll(() {});

  test('recurringActivePill singular is not hardcoded PT', () {
    final v = en.recurringActivePill(1);
    expect(v, isNotNull);
    expect(v, isNot('1 ativa'));
  });

  test('recurringActivePill plural contains count', () {
    final v = en.recurringActivePill(3);
    expect(v, contains('3'));
  });

  test('recurringTotalMonthlyEyebrow exists', () {
    expect(en.recurringTotalMonthlyEyebrow, isNotNull);
    expect(en.recurringTotalMonthlyEyebrow, isNot('TOTAL MENSAL'));
  });

  test('recurringActiveTitle exists', () {
    expect(en.recurringActiveTitle, isNotNull);
  });

  test('recurringSubscriptionCount singular is not hardcoded PT', () {
    final v = en.recurringSubscriptionCount(1);
    expect(v, isNotNull);
    expect(v, isNot('1 subscrição'));
  });

  test('recurringSubscriptionCount plural contains count', () {
    final v = en.recurringSubscriptionCount(5);
    expect(v, contains('5'));
  });

  test('recurringPausedTitle exists', () {
    expect(en.recurringPausedTitle, isNotNull);
  });

  test('recurringDayOfMonth contains day number', () {
    final v = en.recurringDayOfMonth(15);
    expect(v, contains('15'));
  });

  test('recurringEmptyTitle is not hardcoded PT', () {
    expect(en.recurringEmptyTitle, isNot('Sem pagamentos recorrentes'));
  });

  test('recurringEmptyBody is not hardcoded PT', () {
    expect(en.recurringEmptyBody, isNot('Adicione para gerar automaticamente todos os meses.'));
  });

  test('recurringEyebrow exists', () {
    expect(en.recurringEyebrow, isNotNull);
    expect(en.recurringEyebrow, isNot('RECORRENTES'));
  });

  test('recurringHeroSubtitle singular is not hardcoded PT', () {
    final v = en.recurringHeroSubtitle(1);
    expect(v, isNotNull);
    expect(v, isNot('1 subscrição ativa'));
  });

  test('recurringHeroSubtitle plural contains count', () {
    final v = en.recurringHeroSubtitle(4);
    expect(v, contains('4'));
  });

  test('recurringActiveGroupLabel exists', () {
    expect(en.recurringActiveGroupLabel, isNotNull);
    expect(en.recurringActiveGroupLabel, isNot('ATIVAS'));
  });

  test('recurringPausedGroupLabel exists', () {
    expect(en.recurringPausedGroupLabel, isNotNull);
    expect(en.recurringPausedGroupLabel, isNot('PAUSADAS'));
  });
}
