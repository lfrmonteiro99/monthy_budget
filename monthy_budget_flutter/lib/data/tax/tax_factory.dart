import 'tax_system.dart';
import 'pt_tax_system.dart';
import 'es_tax_system.dart';
import 'fr_tax_system.dart';
import 'uk_tax_system.dart';

TaxSystem getTaxSystem(Country country) {
  switch (country) {
    case Country.pt:
      return PtTaxSystem();
    case Country.es:
      return EsTaxSystem();
    case Country.fr:
      return FrTaxSystem();
    case Country.uk:
      return UkTaxSystem();
  }
}
