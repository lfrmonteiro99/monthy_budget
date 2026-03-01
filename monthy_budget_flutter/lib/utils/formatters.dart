import 'package:intl/intl.dart';
import '../data/tax/tax_system.dart';
import '../l10n/generated/app_localizations.dart';

class AppFormatter {
  final Country country;
  late final NumberFormat _currencyFormat;
  late final NumberFormat _percentFormat;

  AppFormatter({this.country = Country.pt}) {
    _currencyFormat = NumberFormat.currency(
      locale: country.locale,
      symbol: country.currencySymbol,
      decimalDigits: 2,
    );
    _percentFormat = NumberFormat.percentPattern(country.locale)
      ..minimumFractionDigits = 1
      ..maximumFractionDigits = 1;
  }

  String currency(double value) => _currencyFormat.format(value);
  String percentage(double value) => _percentFormat.format(value);
}

// Global formatter — updated when country changes via setFormatterCountry()
AppFormatter _defaultFormatter = AppFormatter();

void setFormatterCountry(Country country) {
  _defaultFormatter = AppFormatter(country: country);
}

String formatCurrency(double value) => _defaultFormatter.currency(value);
String formatPercentage(double value) => _defaultFormatter.percentage(value);
String get activeCurrencyCode => _defaultFormatter.country.currencyCode;
String currencySymbol() => _defaultFormatter.country.currencySymbol;

/// Returns the full localized month name (1-based index).
String localizedMonthFull(S l10n, int month) {
  switch (month) {
    case 1: return l10n.monthFullJan;
    case 2: return l10n.monthFullFeb;
    case 3: return l10n.monthFullMar;
    case 4: return l10n.monthFullApr;
    case 5: return l10n.monthFullMay;
    case 6: return l10n.monthFullJun;
    case 7: return l10n.monthFullJul;
    case 8: return l10n.monthFullAug;
    case 9: return l10n.monthFullSep;
    case 10: return l10n.monthFullOct;
    case 11: return l10n.monthFullNov;
    case 12: return l10n.monthFullDec;
    default: return '';
  }
}

/// Returns the abbreviated localized month name (1-based index).
String localizedMonthAbbr(S l10n, int month) {
  switch (month) {
    case 1: return l10n.monthAbbrJan;
    case 2: return l10n.monthAbbrFeb;
    case 3: return l10n.monthAbbrMar;
    case 4: return l10n.monthAbbrApr;
    case 5: return l10n.monthAbbrMay;
    case 6: return l10n.monthAbbrJun;
    case 7: return l10n.monthAbbrJul;
    case 8: return l10n.monthAbbrAug;
    case 9: return l10n.monthAbbrSep;
    case 10: return l10n.monthAbbrOct;
    case 11: return l10n.monthAbbrNov;
    case 12: return l10n.monthAbbrDec;
    default: return '';
  }
}
