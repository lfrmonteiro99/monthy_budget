import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations_en.dart';

void main() {
  late SEn en;
  setUpAll(() { en = SEn(); });

  group('month_review util l10n keys (#1182)', () {
    test('on-track suggestion is in EN not PT', () {
      expect(en.monthReviewSuggestionOnTrack, isNot(contains('previsto')));
      expect(en.monthReviewSuggestionOnTrack, isNotEmpty);
    });

    test('over-budget suggestion formats amount', () {
      final result = en.monthReviewSuggestionOverBudget('50');
      expect(result, contains('50'));
      expect(result, isNot(contains('superaram')));
    });

    test('under-budget suggestion formats amount', () {
      final result = en.monthReviewSuggestionUnderBudget('100');
      expect(result, contains('100'));
      expect(result, isNot(contains('Poupou')));
    });

    test('food over suggestion formats percent', () {
      final result = en.monthReviewSuggestionFoodOver('15');
      expect(result, contains('15'));
      expect(result, isNot(contains('Alimentação')));
    });
  });
}
