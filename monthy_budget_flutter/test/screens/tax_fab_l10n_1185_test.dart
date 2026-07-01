import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations_en.dart';

void main() {
  late SEn en;
  setUpAll(() { en = SEn(); });

  group('tax_simulator + command_chat_fab l10n keys (#1185)', () {
    test('fiscal eyebrow includes year', () {
      final result = en.taxSimFiscalEyebrow('2026');
      expect(result, contains('2026'));
      expect(result, contains('FISCAL'));
    });

    test('fiscal eyebrow works with different year', () {
      final result = en.taxSimFiscalEyebrow('2027');
      expect(result, contains('2027'));
    });

    test('command fab close label is EN', () {
      expect(en.commandFabClose, contains('Close'));
      expect(en.commandFabClose, isNot(contains('Fechar')));
    });

    test('command fab open label is EN', () {
      expect(en.commandFabOpen, contains('Open'));
      expect(en.commandFabOpen, isNot(contains('Abrir')));
    });
  });
}
