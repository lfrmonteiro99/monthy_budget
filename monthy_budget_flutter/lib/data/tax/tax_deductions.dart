import 'dart:math' as math;
import 'tax_system.dart';

/// Family type for IRS deduction cap calculation.
///
/// Affects the "despesas gerais familiares" cap:
/// - single: 250 per taxpayer
/// - couple: 500 (joint taxation)
/// - singleParent: 335 (familia monoparental)
enum FamilyType {
  single,
  couple,
  singleParent;

  /// Cap for "despesas gerais familiares" based on family type.
  double get despesasGeraisCap {
    switch (this) {
      case FamilyType.single:
        return 250;
      case FamilyType.couple:
        return 500;
      case FamilyType.singleParent:
        return 335;
    }
  }

  /// Derives [FamilyType] from marital status string and number of dependents.
  static FamilyType fromMaritalStatus(
      String maritalStatus, int dependentes) {
    if (maritalStatus == 'casado' || maritalStatus == 'uniao_facto') {
      return FamilyType.couple;
    }
    if (dependentes > 0) {
      return FamilyType.singleParent;
    }
    return FamilyType.single;
  }
}

/// A single IRS deduction rule for an expense category.
class DeductionRule {
  final String category; // ExpenseCategory.name
  final String irsCategory; // Human-readable IRS category name
  final double rate; // Deduction rate (e.g. 0.15 for 15%)
  final double annualCap; // Max annual deduction in euros
  final bool isVatBased; // true = deduct rate × vatRate × amount
  final double vatRate; // Only used when isVatBased is true
  final String? sharedCapGroup; // If non-null, this category shares a cap group

  const DeductionRule({
    required this.category,
    required this.irsCategory,
    required this.rate,
    required this.annualCap,
    this.isVatBased = false,
    this.vatRate = 0,
    this.sharedCapGroup,
  });

  bool get isDeductible => rate > 0;
}

/// Result of deduction calculation for a single category.
class CategoryDeductionResult {
  final String category;
  final String irsCategory;
  final double spent;
  final double rawDeduction;
  final double cappedDeduction;
  final double finalDeduction; // After shared-cap adjustments
  final double annualCap;
  final bool isDeductible;

  const CategoryDeductionResult({
    required this.category,
    required this.irsCategory,
    required this.spent,
    required this.rawDeduction,
    required this.cappedDeduction,
    required this.finalDeduction,
    required this.annualCap,
    required this.isDeductible,
  });

  double get capUsedPercent =>
      annualCap > 0 ? (finalDeduction / annualCap).clamp(0.0, 1.0) : 0;
}

/// Summary of all deductions for a tax year.
class YearlyDeductionSummary {
  final int year;
  final List<CategoryDeductionResult> categories;
  final double totalDeduction;
  final double maxPossibleDeduction;

  const YearlyDeductionSummary({
    required this.year,
    required this.categories,
    required this.totalDeduction,
    required this.maxPossibleDeduction,
  });

  List<CategoryDeductionResult> get deductible =>
      categories.where((c) => c.isDeductible).toList();

  List<CategoryDeductionResult> get nonDeductible =>
      categories.where((c) => !c.isDeductible).toList();

  List<CategoryDeductionResult> get topCategories {
    final d = deductible..sort((a, b) => b.finalDeduction.compareTo(a.finalDeduction));
    return d.take(3).toList();
  }
}

/// Abstract tax deduction system — each country can implement its own rules.
abstract class TaxDeductionSystem {
  Country get country;
  List<DeductionRule> get rules;

  YearlyDeductionSummary calculate({
    required Map<String, double> spentByCategory,
    required int year,
    FamilyType familyType = FamilyType.single,
  });
}

/// Factory function to get the deduction system for a country.
/// Returns null if the country doesn't have a deduction system.
TaxDeductionSystem? getTaxDeductionSystem(Country country) {
  switch (country) {
    case Country.pt:
      return PtTaxDeductionSystem();
    default:
      return null;
  }
}

/// Portuguese IRS 2026 tax deduction system.
///
/// Categories and rules (Art. 78 CIRS):
/// 1. Despesas gerais familiares: 35%, cap 250/500/335 by family type
/// 2. Saude: 15%, cap 1000
/// 3. Educacao: 30%, cap 800
/// 4. Habitacao (rendas): 15%, cap 700
/// 5. IVA setorial: 15% of VAT, cap 250
class PtTaxDeductionSystem extends TaxDeductionSystem {
  @override
  Country get country => Country.pt;

  @override
  List<DeductionRule> get rules => const [
        DeductionRule(
          category: 'saude',
          irsCategory: 'Saude',
          rate: 0.15,
          annualCap: 1000,
        ),
        DeductionRule(
          category: 'educacao',
          irsCategory: 'Educacao',
          rate: 0.30,
          annualCap: 800,
        ),
        DeductionRule(
          category: 'habitacao',
          irsCategory: 'Habitacao',
          rate: 0.15,
          annualCap: 700,
        ),
        DeductionRule(
          category: 'transportes',
          irsCategory: 'Despesas Gerais',
          rate: 0.35,
          annualCap: 250,
          sharedCapGroup: 'despesas_gerais',
        ),
        DeductionRule(
          category: 'outros',
          irsCategory: 'Despesas Gerais',
          rate: 0.35,
          annualCap: 250,
          sharedCapGroup: 'despesas_gerais',
        ),
        DeductionRule(
          category: 'alimentacao',
          irsCategory: 'IVA Setorial',
          rate: 0.15,
          annualCap: 250,
          isVatBased: true,
          vatRate: 0.23,
        ),
        // Non-deductible categories
        DeductionRule(
          category: 'telecomunicacoes',
          irsCategory: '',
          rate: 0,
          annualCap: 0,
        ),
        DeductionRule(
          category: 'energia',
          irsCategory: '',
          rate: 0,
          annualCap: 0,
        ),
        DeductionRule(
          category: 'agua',
          irsCategory: '',
          rate: 0,
          annualCap: 0,
        ),
        DeductionRule(
          category: 'lazer',
          irsCategory: '',
          rate: 0,
          annualCap: 0,
        ),
      ];

  /// Computes total max possible deductions for a given family type.
  /// saude(1000) + educacao(800) + habitacao(700) + despesasGerais(cap) + iva(250)
  static double maxPossibleForFamily(FamilyType familyType) {
    return 1000 + 800 + 700 + familyType.despesasGeraisCap + 250;
  }

  @override
  YearlyDeductionSummary calculate({
    required Map<String, double> spentByCategory,
    required int year,
    FamilyType familyType = FamilyType.single,
  }) {
    final despesasGeraisCap = familyType.despesasGeraisCap;

    // Pass 1: per-category raw deduction
    final results = <String, _IntermediateResult>{};
    for (final rule in rules) {
      final spent = spentByCategory[rule.category] ?? 0;
      double raw = 0;
      if (rule.isDeductible && spent > 0) {
        if (rule.isVatBased) {
          raw = spent * rule.vatRate * rule.rate;
        } else {
          raw = spent * rule.rate;
        }
      }
      // Use family-type-aware cap for shared group members
      final effectiveCap = rule.sharedCapGroup == 'despesas_gerais'
          ? despesasGeraisCap
          : rule.annualCap;

      final capped = effectiveCap > 0 ? math.min(raw, effectiveCap) : raw;
      results[rule.category] = _IntermediateResult(
        rule: rule,
        spent: spent,
        raw: raw,
        capped: capped,
        final_: capped,
      );
    }

    // Pass 2: shared cap groups
    final groupTotals = <String, double>{};
    final groupMembers = <String, List<String>>{};
    for (final entry in results.entries) {
      final group = entry.value.rule.sharedCapGroup;
      if (group != null) {
        groupTotals[group] = (groupTotals[group] ?? 0) + entry.value.capped;
        groupMembers.putIfAbsent(group, () => []).add(entry.key);
      }
    }

    for (final group in groupTotals.keys) {
      // Use family-type-aware cap for despesas_gerais group
      final sharedCap = group == 'despesas_gerais'
          ? despesasGeraisCap
          : rules
              .firstWhere((r) => r.sharedCapGroup == group)
              .annualCap;
      final total = groupTotals[group]!;
      if (total > sharedCap) {
        final ratio = sharedCap / total;
        for (final member in groupMembers[group]!) {
          final r = results[member]!;
          results[member] = r.copyWith(final_: r.capped * ratio);
        }
      }
    }

    // Build results
    final categoryResults = results.entries.map((e) {
      final r = e.value;
      final effectiveCap = r.rule.sharedCapGroup == 'despesas_gerais'
          ? despesasGeraisCap
          : r.rule.annualCap;
      return CategoryDeductionResult(
        category: r.rule.category,
        irsCategory: r.rule.irsCategory,
        spent: r.spent,
        rawDeduction: r.raw,
        cappedDeduction: r.capped,
        finalDeduction: _round2(r.final_),
        annualCap: effectiveCap,
        isDeductible: r.rule.isDeductible,
      );
    }).toList();

    final totalDeduction =
        categoryResults.fold(0.0, (s, c) => s + c.finalDeduction);

    return YearlyDeductionSummary(
      year: year,
      categories: categoryResults,
      totalDeduction: _round2(totalDeduction),
      maxPossibleDeduction: maxPossibleForFamily(familyType),
    );
  }
}

double _round2(double v) => (v * 100).roundToDouble() / 100;

class _IntermediateResult {
  final DeductionRule rule;
  final double spent;
  final double raw;
  final double capped;
  final double final_;

  const _IntermediateResult({
    required this.rule,
    required this.spent,
    required this.raw,
    required this.capped,
    required this.final_,
  });

  _IntermediateResult copyWith({double? final_}) => _IntermediateResult(
        rule: rule,
        spent: spent,
        raw: raw,
        capped: capped,
        final_: final_ ?? this.final_,
      );
}
