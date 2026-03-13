import 'package:flutter/material.dart';
import '../models/app_settings.dart';

enum AppColorPalette { ocean, emerald, violet, teal, sunset }

/// Centralized semantic colors for light and dark themes.
///
/// Usage: `AppColors.primary(context)` — resolves based on current brightness.
class AppColors {
  AppColors._();

  static AppColorPalette palette = AppColorPalette.ocean;

  // ── Helpers ──────────────────────────────────────────────────────────

  static Brightness _brightness(BuildContext context) =>
      Theme.of(context).brightness;

  static bool _isDark(BuildContext context) =>
      _brightness(context) == Brightness.dark;

  // ── Brand / Primary ─────────────────────────────────────────────────

  static const _primaryColors = {
    AppColorPalette.ocean:   (light: Color(0xFF2563EB), dark: Color(0xFF60A5FA)),
    AppColorPalette.emerald: (light: Color(0xFF059669), dark: Color(0xFF34D399)),
    AppColorPalette.violet:  (light: Color(0xFF7C3AED), dark: Color(0xFFA78BFA)),
    AppColorPalette.teal:    (light: Color(0xFF0D9488), dark: Color(0xFF2DD4BF)),
    AppColorPalette.sunset:  (light: Color(0xFFEA580C), dark: Color(0xFFFB923C)),
  };

  static const _primaryLightColors = {
    AppColorPalette.ocean:   (light: Color(0xFFEFF6FF), dark: Color(0xFF1E3A5F)),
    AppColorPalette.emerald: (light: Color(0xFFD1FAE5), dark: Color(0xFF064E3B)),
    AppColorPalette.violet:  (light: Color(0xFFEDE9FE), dark: Color(0xFF2E1065)),
    AppColorPalette.teal:    (light: Color(0xFFCCFBF1), dark: Color(0xFF134E4A)),
    AppColorPalette.sunset:  (light: Color(0xFFFFF7ED), dark: Color(0xFF431407)),
  };

  static const _onPrimaryColors = {
    AppColorPalette.ocean:   (light: Color(0xFFFFFFFF), dark: Color(0xFF0F172A)),
    AppColorPalette.emerald: (light: Color(0xFFFFFFFF), dark: Color(0xFF022C22)),
    AppColorPalette.violet:  (light: Color(0xFFFFFFFF), dark: Color(0xFF1E1B4B)),
    AppColorPalette.teal:    (light: Color(0xFFFFFFFF), dark: Color(0xFF042F2E)),
    AppColorPalette.sunset:  (light: Color(0xFFFFFFFF), dark: Color(0xFF1C1917)),
  };

  static Color primary(BuildContext context) {
    final c = _primaryColors[palette]!;
    return _isDark(context) ? c.dark : c.light;
  }

  static Color primaryStatic(AppColorPalette p, bool isDark) {
    final c = _primaryColors[p]!;
    return isDark ? c.dark : c.light;
  }

  static Color primaryLight(BuildContext context) {
    final c = _primaryLightColors[palette]!;
    return _isDark(context) ? c.dark : c.light;
  }

  static Color onPrimary(BuildContext context) {
    final c = _onPrimaryColors[palette]!;
    return _isDark(context) ? c.dark : c.light;
  }

  // ── Text ─────────────────────────────────────────────────────────────

  static Color textPrimary(BuildContext context) =>
      _isDark(context) ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);

  static Color textSecondary(BuildContext context) =>
      _isDark(context) ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  static Color textMuted(BuildContext context) =>
      _isDark(context) ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  static Color textLabel(BuildContext context) =>
      _isDark(context) ? const Color(0xFFCBD5E1) : const Color(0xFF475569);

  // ── Surfaces ─────────────────────────────────────────────────────────

  static Color surface(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1E293B) : Colors.white;

  static Color background(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

  static Color surfaceVariant(BuildContext context) =>
      _isDark(context) ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

  // ── Borders ──────────────────────────────────────────────────────────

  static Color border(BuildContext context) =>
      _isDark(context) ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  static Color borderMuted(BuildContext context) =>
      _isDark(context) ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

  // ── Status ───────────────────────────────────────────────────────────

  static Color success(BuildContext context) =>
      _isDark(context) ? const Color(0xFF34D399) : const Color(0xFF10B981);

  static Color error(BuildContext context) =>
      _isDark(context) ? const Color(0xFFF87171) : const Color(0xFFEF4444);

  static Color warning(BuildContext context) =>
      _isDark(context) ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);

  // ── Status Backgrounds ───────────────────────────────────────────────

  static Color infoBackground(BuildContext context) =>
      _isDark(context) ? const Color(0xFF172554) : const Color(0xFFEFF6FF);

  static Color infoBorder(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1E3A5F) : const Color(0xFFDBEAFE);

  static Color successBackground(BuildContext context) =>
      _isDark(context) ? const Color(0xFF064E3B) : const Color(0xFFECFDF5);

  static Color errorBackground(BuildContext context) =>
      _isDark(context) ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2);

  static Color warningBackground(BuildContext context) =>
      _isDark(context) ? const Color(0xFF451A03) : const Color(0xFFFFFBEB);

  // ── Misc ─────────────────────────────────────────────────────────────

  static Color shimmer(BuildContext context) =>
      _isDark(context) ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03);

  static Color navIndicator(BuildContext context) {
    final c = _primaryLightColors[palette]!;
    return _isDark(context) ? c.dark : c.light;
  }

  static Color dragHandle(BuildContext context) =>
      _isDark(context) ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

  /// Chip selected background — mockup: #EFF6FF light
  static Color chipSelected(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF);

  /// Settings list item icon color — mockup: #475569
  static Color settingsIcon(BuildContext context) =>
      _isDark(context) ? const Color(0xFF94A3B8) : const Color(0xFF475569);

  /// Settings list item trailing arrow — mockup: #CBD5E1
  static Color settingsArrow(BuildContext context) =>
      _isDark(context) ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

  // ── Status Borders ─────────────────────────────────────────────────

  static Color errorBorder(BuildContext context) =>
      _isDark(context) ? const Color(0xFF7F1D1D) : const Color(0xFFFCA5A5);

  static Color warningBorder(BuildContext context) =>
      _isDark(context) ? const Color(0xFF78350F) : const Color(0xFFFCD34D);

  // ── Expense Category Colors ────────────────────────────────────────

  static const _expenseCategoryColors = {
    ExpenseCategory.telecomunicacoes: Color(0xFF818CF8),
    ExpenseCategory.energia: Color(0xFFFBBF24),
    ExpenseCategory.agua: Color(0xFF60A5FA),
    ExpenseCategory.alimentacao: Color(0xFF34D399),
    ExpenseCategory.educacao: Color(0xFFA78BFA),
    ExpenseCategory.habitacao: Color(0xFFF87171),
    ExpenseCategory.transportes: Color(0xFFFB923C),
    ExpenseCategory.saude: Color(0xFFF472B6),
    ExpenseCategory.lazer: Color(0xFF2DD4BF),
    ExpenseCategory.outros: Color(0xFF94A3B8),
  };

  static const _defaultCategoryColor = Color(0xFF94A3B8);

  static Color categoryColor(ExpenseCategory category) =>
      _expenseCategoryColors[category] ?? _defaultCategoryColor;

  static Color categoryColorByName(String name) {
    final cat = ExpenseCategory.values.where((e) => e.name == name);
    return cat.isEmpty ? _defaultCategoryColor : categoryColor(cat.first);
  }
}
