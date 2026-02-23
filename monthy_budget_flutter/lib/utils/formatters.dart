import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.currency(
  locale: 'pt_PT',
  symbol: '€',
  decimalDigits: 2,
);

final _percentFormat = NumberFormat.percentPattern('pt_PT')
  ..minimumFractionDigits = 1
  ..maximumFractionDigits = 1;

String formatCurrency(double value) => _currencyFormat.format(value);

String formatPercentage(double value) => _percentFormat.format(value);
