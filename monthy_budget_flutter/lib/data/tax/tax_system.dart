import 'dart:math' as math;

enum Country {
  pt,
  es,
  fr,
  uk;

  String get currencySymbol {
    switch (this) {
      case Country.pt:
      case Country.es:
      case Country.fr:
        return '\u20AC';
      case Country.uk:
        return '\u00A3';
    }
  }

  String get currencyCode {
    switch (this) {
      case Country.pt:
      case Country.es:
      case Country.fr:
        return 'EUR';
      case Country.uk:
        return 'GBP';
    }
  }

  String get locale {
    switch (this) {
      case Country.pt:
        return 'pt_PT';
      case Country.es:
        return 'es_ES';
      case Country.fr:
        return 'fr_FR';
      case Country.uk:
        return 'en_GB';
    }
  }

  bool get hasSubsidies {
    switch (this) {
      case Country.pt:
      case Country.es:
        return true;
      case Country.fr:
      case Country.uk:
        return false;
    }
  }

  bool get hasMealAllowance => this == Country.pt;

  bool get hasTitulares => this == Country.pt;

  bool get maritalStatusAffectsTax => this == Country.pt;

  static Country fromJson(String? value) {
    if (value == null) return Country.pt;
    for (final c in Country.values) {
      if (c.name == value) return c;
    }
    return Country.pt;
  }
}

class TaxResult {
  final double incomeTax;
  final double incomeTaxRate;
  final double socialContribution;
  final double socialContributionRate;
  final double netSalary;

  const TaxResult({
    required this.incomeTax,
    required this.incomeTaxRate,
    required this.socialContribution,
    required this.socialContributionRate,
    required this.netSalary,
  });

  double get totalDeductions => incomeTax + socialContribution;
}

double round2(double v) => (v * 100).roundToDouble() / 100;

abstract class TaxSystem {
  Country get country;
  double get socialContributionRate;

  TaxResult calculateTax({
    required double grossSalary,
    required String maritalStatus,
    required int titulares,
    required int dependentes,
  });

  double calculateSocialContribution(double grossSalary) {
    if (grossSalary <= 0) return 0;
    return round2(grossSalary * socialContributionRate);
  }
}

class TaxBracket {
  final double upTo;
  final double rate;

  const TaxBracket({required this.upTo, required this.rate});

  static double applyBrackets(double income, List<TaxBracket> brackets) {
    double tax = 0;
    double remaining = income;
    double previousLimit = 0;

    for (final bracket in brackets) {
      if (remaining <= 0) break;
      final taxableInBracket = math.min(remaining, bracket.upTo - previousLimit);
      tax += taxableInBracket * bracket.rate;
      remaining -= taxableInBracket;
      previousLimit = bracket.upTo;
    }

    return round2(tax);
  }
}
