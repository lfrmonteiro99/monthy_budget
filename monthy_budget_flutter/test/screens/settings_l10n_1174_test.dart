import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations_en.dart';

void main() {
  late SEn en;
  setUpAll(() { en = SEn(); });
  tearDownAll(() {});

  group('settings_screen_sections l10n keys (#1174)', () {
    test('settingsAiKeyProtected is EN not PT', () {
      expect(en.settingsAiKeyProtected, isNotNull);
      expect(en.settingsAiKeyProtected, isNot(contains('protegida')));
    });
  });
}
