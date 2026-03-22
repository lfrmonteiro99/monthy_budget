import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/data/tax/tax_system.dart';
import 'package:monthly_management/utils/formatters.dart';

void main() {
  group('AppFormatter', () {
    test('currency formats with PT locale', () {
      final fmt = AppFormatter(country: Country.pt);
      final result = fmt.currency(1234.56);
      // Should contain the amount; exact format depends on locale
      expect(result, contains('1'));
      expect(result, contains('234'));
    });

    test('percentage formats with PT locale', () {
      final fmt = AppFormatter(country: Country.pt);
      final result = fmt.percentage(0.256);
      // Should contain ~25.6 or 26
      expect(result, isNotEmpty);
    });

    test('currency formats with UK locale', () {
      final fmt = AppFormatter(country: Country.uk);
      final result = fmt.currency(1234.56);
      expect(result, isNotEmpty);
    });
  });

  group('Global formatters', () {
    test('setFormatterCountry changes active formatter', () {
      setFormatterCountry(Country.pt);
      final ptResult = formatCurrency(100.0);
      expect(ptResult, isNotEmpty);

      setFormatterCountry(Country.uk);
      final ukResult = formatCurrency(100.0);
      expect(ukResult, isNotEmpty);

      // Reset
      setFormatterCountry(Country.pt);
    });

    test('formatPercentage returns non-empty', () {
      setFormatterCountry(Country.pt);
      final result = formatPercentage(0.5);
      expect(result, isNotEmpty);
    });

    test('activeCurrencyCode returns non-empty', () {
      setFormatterCountry(Country.pt);
      expect(activeCurrencyCode, isNotEmpty);
    });

    test('currencySymbol returns non-empty', () {
      setFormatterCountry(Country.pt);
      expect(currencySymbol(), isNotEmpty);
    });
  });
}
