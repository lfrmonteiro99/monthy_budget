import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';

/// Localized label for a known [ExpenseCategory] name, falling back to the raw
/// name (e.g. a custom category) when no enum match exists.
String localizedExpenseCategory(String catName, S l10n) {
  try {
    final cat = ExpenseCategory.values.firstWhere((c) => c.name == catName);
    return cat.localizedLabel(l10n);
  } catch (_) {
    return catName;
  }
}
