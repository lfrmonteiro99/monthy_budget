import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations_fr.dart';

void main() {
  late SFr fr;
  setUpAll(() {
    fr = SFr();
  });

  group('app_fr.arb mojibake fix (#1232)', () {
    // Bytes that only ever appear when a UTF-8 string got mis-decoded as
    // Latin-1/Windows-1252 and re-encoded — the mojibake pattern this issue
    // fixes. None of the corrected strings below should contain them.
    final mojibakePattern = RegExp(r'(Ã.|â€.|ââ€)');

    test('monthReviewExpensesExceeded shows € not mojibake', () {
      final result = fr.monthReviewExpensesExceeded('50');
      expect(result, contains('€'));
      expect(result, isNot(matches(mojibakePattern)));
    });

    test('monthReviewSavedMore shows € not mojibake', () {
      final result = fr.monthReviewSavedMore('50');
      expect(result, contains('€'));
      expect(result, isNot(matches(mojibakePattern)));
    });

    test('mealTotalCost shows € not mojibake', () {
      final result = fr.mealTotalCost('12');
      expect(result, contains('€'));
      expect(result, isNot(matches(mojibakePattern)));
    });

    test('wizardSettingsInfo shows → arrow not mojibake', () {
      expect(fr.wizardSettingsInfo, contains('→'));
      expect(fr.wizardSettingsInfo, isNot(matches(mojibakePattern)));
    });

    test('settingsSubsidyHoliday shows NOËL not mojibake', () {
      expect(fr.settingsSubsidyHoliday, contains('NOËL'));
      expect(fr.settingsSubsidyHoliday, isNot(matches(mojibakePattern)));
    });

    test('onbSlide0Title shows œ not mojibake', () {
      expect(fr.onbSlide0Title, contains('œil'));
      expect(fr.onbSlide0Title, isNot(matches(mojibakePattern)));
    });

    test('taxSimPresetRaise shows € not mojibake', () {
      expect(fr.taxSimPresetRaise, contains('€'));
      expect(fr.taxSimPresetRaise, isNot(matches(mojibakePattern)));
    });
  });
}
