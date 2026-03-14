import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/data/tax/tax_system.dart';
import 'package:monthly_management/utils/formatters.dart';

void main() {
  group('formatters', () {
    test('currency metadata switches with selected country', () {
      setFormatterCountry(Country.pt);
      expect(activeCurrencyCode, 'EUR');
      expect(currencySymbol(), '\u20AC');

      setFormatterCountry(Country.uk);
      expect(activeCurrencyCode, 'GBP');
      expect(currencySymbol(), '\u00A3');
    });

    test('formatCurrency includes expected symbol for country', () {
      setFormatterCountry(Country.pt);
      expect(formatCurrency(1234.56), contains('\u20AC'));

      setFormatterCountry(Country.uk);
      expect(formatCurrency(1234.56), contains('\u00A3'));
    });

    test('formatPercentage outputs percent string', () {
      setFormatterCountry(Country.pt);
      final value = formatPercentage(0.1234);
      expect(value, contains('%'));
    });
  });
}
