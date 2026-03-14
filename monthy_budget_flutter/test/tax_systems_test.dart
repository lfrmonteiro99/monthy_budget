import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/data/tax/es_tax_system.dart';
import 'package:monthly_management/data/tax/fr_tax_system.dart';
import 'package:monthly_management/data/tax/pt_tax_system.dart';
import 'package:monthly_management/data/tax/tax_factory.dart';
import 'package:monthly_management/data/tax/tax_system.dart';
import 'package:monthly_management/data/tax/uk_tax_system.dart';

void main() {
  group('Tax factory', () {
    test('returns expected system for each country', () {
      expect(getTaxSystem(Country.pt), isA<PtTaxSystem>());
      expect(getTaxSystem(Country.es), isA<EsTaxSystem>());
      expect(getTaxSystem(Country.fr), isA<FrTaxSystem>());
      expect(getTaxSystem(Country.uk), isA<UkTaxSystem>());
    });
  });

  group('Tax bracket math', () {
    test('applyBrackets computes progressive tax correctly', () {
      final tax = TaxBracket.applyBrackets(1500, const [
        TaxBracket(upTo: 1000, rate: 0.1),
        TaxBracket(upTo: 2000, rate: 0.2),
      ]);

      expect(tax, 200);
    });
  });

  group('Tax systems', () {
    test('all systems return zero tax for non-positive salary', () {
      for (final system in [
        getTaxSystem(Country.pt),
        getTaxSystem(Country.es),
        getTaxSystem(Country.fr),
        getTaxSystem(Country.uk),
      ]) {
        final result = system.calculateTax(
          grossSalary: 0,
          maritalStatus: 'solteiro',
          titulares: 1,
          dependentes: 0,
        );
        expect(result.incomeTax, 0);
        expect(result.socialContribution, 0);
        expect(result.netSalary, 0);
      }
    });

    test('positive salary yields positive deductions and lower net', () {
      for (final system in [
        getTaxSystem(Country.pt),
        getTaxSystem(Country.es),
        getTaxSystem(Country.fr),
        getTaxSystem(Country.uk),
      ]) {
        final result = system.calculateTax(
          grossSalary: 2500,
          maritalStatus: 'solteiro',
          titulares: 1,
          dependentes: 0,
        );
        expect(result.incomeTax, greaterThanOrEqualTo(0));
        expect(result.socialContribution, greaterThan(0));
        expect(result.netSalary, lessThan(2500));
      }
    });

    test('UK NI contribution scales for higher salary', () {
      final uk = UkTaxSystem();
      final low = uk.calculateSocialContribution(1200);
      final high = uk.calculateSocialContribution(6000);

      expect(high, greaterThan(low));
      expect(high, greaterThan(0));
    });
  });

  group('Country helpers', () {
    test('fromJson falls back to pt for invalid values', () {
      expect(Country.fromJson(null), Country.pt);
      expect(Country.fromJson('invalid'), Country.pt);
    });

    test('currency metadata is stable', () {
      expect(Country.pt.currencyCode, 'EUR');
      expect(Country.uk.currencyCode, 'GBP');
      expect(Country.es.hasSubsidies, isTrue);
      expect(Country.fr.hasSubsidies, isFalse);
      expect(Country.pt.hasMealAllowance, isTrue);
      expect(Country.uk.hasMealAllowance, isFalse);
    });
  });
}
