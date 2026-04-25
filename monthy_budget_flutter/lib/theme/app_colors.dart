import 'package:flutter/material.dart';
import '../models/app_settings.dart';

/// Calm palette — NEW redesign tokens.
///
/// Mapped 1:1 from `tokens.css` in the Monthly Budget Redesign prototype.
/// Usage: `AppColors.bg(context)`, `AppColors.ink(context)`, etc.
///
/// The legacy `AppColorPalette` enum + old `primary()`/`background()` helpers
/// are kept below so existing call sites keep compiling while we migrate.
enum AppColorPalette { calm }

class AppColors {
  AppColors._();

  static AppColorPalette palette = AppColorPalette.calm;

  static Brightness _brightness(BuildContext context) =>
      Theme.of(context).brightness;
  static bool _isDark(BuildContext context) =>
      _brightness(context) == Brightness.dark;

  // ── Calm palette ────────────────────────────────────────────────────
  //   Source of truth: Monthly Budget Redesign → tokens.css

  /// Page background (warm off-white in light, near-black warm in dark).
  static Color bg(BuildContext c) =>
      _isDark(c) ? const Color(0xFF12100D) : const Color(0xFFF8F7F3);

  /// Slightly-sunk panel background (grouped lists, rails).
  static Color bgSunk(BuildContext c) =>
      _isDark(c) ? const Color(0xFF1A1815) : const Color(0xFFF1EFE9);

  /// Card / elevated surface.
  static Color card(BuildContext c) =>
      _isDark(c) ? const Color(0xFF1F1D19) : Colors.white;

  /// Primary text.
  static Color ink(BuildContext c) =>
      _isDark(c) ? const Color(0xFFF5F2EC) : const Color(0xFF0B0E14);

  /// Secondary text (70%).
  static Color ink70(BuildContext c) =>
      _isDark(c) ? const Color(0xFFB8B2A5) : const Color(0xFF4A5464);

  /// Muted / placeholder text (50%).
  static Color ink50(BuildContext c) =>
      _isDark(c) ? const Color(0xFF807A6D) : const Color(0xFF8B93A3);

  /// Hairline / disabled tint (20%).
  static Color ink20(BuildContext c) =>
      _isDark(c) ? const Color(0xFF3A3730) : const Color(0xFFDCDED6);

  /// Hairline border with subtle alpha.
  static Color line(BuildContext c) => _isDark(c)
      ? const Color(0xFFF5F2EC).withValues(alpha: 0.08)
      : const Color(0xFF0B0E14).withValues(alpha: 0.07);

  /// Accent (calm indigo).
  static Color accent(BuildContext c) =>
      _isDark(c) ? const Color(0xFF8B9BFF) : const Color(0xFF2F4CDD);

  /// Accent soft fill (chip/selected backgrounds).
  static Color accentSoft(BuildContext c) => _isDark(c)
      ? const Color(0xFF8B9BFF).withValues(alpha: 0.14)
      : const Color(0xFFEAEEFF);

  // ── Calm money redesign tokens (Wave T) ─────────────────────────────
  //   §0 of the Calm redesign frontend spec.

  /// Text/icon colour on dark fills (centre FAB, dark avatar).
  /// Light: white. Dark: near-black so dark FAB stays visually grounded.
  static Color inkInverse(BuildContext c) =>
      _isDark(c) ? const Color(0xFF0B0E14) : const Color(0xFFFFFFFF);

  /// Fill for elements that must remain near-black on both themes
  /// (centre FAB, dark avatar circle). Semantically distinct from [ink]
  /// — in dark mode [ink] is light but [inkSurface] stays near-black.
  static Color inkSurface(BuildContext c) =>
      _isDark(c) ? const Color(0xFFF5F2EC) : const Color(0xFF0B0E14);

  /// Warm cream background for the "Plano Plus" subscription pill.
  /// Distinct from [accentSoft] (too cold/blue). In dark mode uses a
  /// 18%-alpha overlay of the accent colour for legibility.
  static Color pillCream(BuildContext c) => _isDark(c)
      ? const Color(0xFF8B9BFF).withValues(alpha: 0.18)
      : const Color(0xFFF4ECD8);

  /// Text colour inside [pillCream].
  static Color pillCreamInk(BuildContext c) =>
      _isDark(c) ? const Color(0xFFF0DFA8) : const Color(0xFF5C4A1E);

  // Semantic status
  static Color ok(BuildContext c) =>
      _isDark(c) ? const Color(0xFF4ADE80) : const Color(0xFF0E9F6E);
  static Color warn(BuildContext c) =>
      _isDark(c) ? const Color(0xFFF59E0B) : const Color(0xFFC2410C);
  static Color bad(BuildContext c) =>
      _isDark(c) ? const Color(0xFFF87171) : const Color(0xFFB91C1C);

  // ── Legacy aliases (KEEP until all call sites migrated) ─────────────
  //
  // These map the old API to the new Calm tokens so screens that still
  // call `AppColors.primary(context)` don't break during the rollout.
  // Delete once grep finds no more usages.

  // CRITICAL — read before changing:
  // In Calm, the primary CTA colour is INK, not accent. Accent is only for
  // selection/focus. So the legacy `primary()` alias intentionally returns
  // `ink(c)` — not `accent(c)` — so that existing `FilledButton`s driven by
  // `AppColors.primary()` render with the correct Calm treatment.
  //
  // If you want the indigo accent (e.g. a link, a selected chip border),
  // call `AppColors.accent(context)` explicitly.
  static Color primary(BuildContext c) => ink(c);
  static Color primaryLight(BuildContext c) => accentSoft(c);
  static Color onPrimary(BuildContext c) => bg(c);
  static Color primaryStatic(AppColorPalette p, bool isDark) =>
      isDark ? const Color(0xFFF5F2EC) : const Color(0xFF0B0E14);

  static Color textPrimary(BuildContext c) => ink(c);
  static Color textSecondary(BuildContext c) => ink70(c);
  static Color textMuted(BuildContext c) => ink50(c);
  static Color textLabel(BuildContext c) => ink70(c);

  static Color surface(BuildContext c) => card(c);
  static Color background(BuildContext c) => bg(c);
  static Color surfaceVariant(BuildContext c) => bgSunk(c);

  static Color border(BuildContext c) => line(c);
  static Color borderMuted(BuildContext c) => ink20(c);

  static Color success(BuildContext c) => ok(c);
  static Color error(BuildContext c) => bad(c);
  static Color warning(BuildContext c) => warn(c);

  static Color infoBackground(BuildContext c) => accentSoft(c);
  static Color infoBorder(BuildContext c) => accentSoft(c);
  static Color successBackground(BuildContext c) => _isDark(c)
      ? const Color(0xFF4ADE80).withValues(alpha: 0.12)
      : const Color(0xFFE8F6F0);
  static Color errorBackground(BuildContext c) => _isDark(c)
      ? const Color(0xFFF87171).withValues(alpha: 0.12)
      : const Color(0xFFFDECEC);
  static Color warningBackground(BuildContext c) => _isDark(c)
      ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
      : const Color(0xFFFEF3E7);
  static Color errorBorder(BuildContext c) => bad(c).withValues(alpha: 0.4);
  static Color warningBorder(BuildContext c) => warn(c).withValues(alpha: 0.4);

  static Color shimmer(BuildContext c) => _isDark(c)
      ? Colors.white.withValues(alpha: 0.03)
      : Colors.black.withValues(alpha: 0.03);

  static Color navIndicator(BuildContext c) => accentSoft(c);
  static Color dragHandle(BuildContext c) => ink20(c);
  static Color chipSelected(BuildContext c) => accentSoft(c);
  static Color settingsIcon(BuildContext c) => ink(c);
  static Color settingsArrow(BuildContext c) => ink50(c);

  // ── Chart-series palette ────────────────────────────────────────────
  //
  // Distinguishable per-series colours for budget charts. Unlike the
  // semantic ok/warn/bad tokens, these are tuned for legibility against
  // both light and dark surfaces in stacked/grouped bar charts.
  //
  // The base hex matches the original budget_charts.dart palette
  // (Tailwind 400-class greens/reds/ambers/indigos) and the dark-mode
  // variant nudges the value lighter to maintain contrast on dark
  // surfaces.
  static Color chartGreen(BuildContext c) =>
      _isDark(c) ? const Color(0xFF6EE7B7) : const Color(0xFF34D399);
  static Color chartRed(BuildContext c) =>
      _isDark(c) ? const Color(0xFFFCA5A5) : const Color(0xFFF87171);
  static Color chartAmber(BuildContext c) =>
      _isDark(c) ? const Color(0xFFFCD34D) : const Color(0xFFFBBF24);
  static Color chartIndigo(BuildContext c) =>
      _isDark(c) ? const Color(0xFFA5B4FC) : const Color(0xFF818CF8);
  static Color chartIndigoLight(BuildContext c) =>
      _isDark(c) ? const Color(0xFFC7D2FE) : const Color(0xFFC7D2FE);

  // ── Expense category swatches (Calm-tuned, warmer than legacy) ──────
  static const _expenseCategoryColors = {
    ExpenseCategory.habitacao:        Color(0xFFE8817F), // home — coral
    ExpenseCategory.alimentacao:      Color(0xFF5AB890), // food — sage
    ExpenseCategory.transportes:      Color(0xFFEDA05C), // transport — amber
    ExpenseCategory.energia:          Color(0xFFEBBF5C), // energy — sun
    ExpenseCategory.telecomunicacoes: Color(0xFF8590EB), // telecom — periwinkle
    ExpenseCategory.lazer:            Color(0xFF5ECBB8), // fun — mint
    ExpenseCategory.saude:            Color(0xFFE088B8), // health — rose
    ExpenseCategory.agua:             Color(0xFF7CB8E0), // water — sky
    ExpenseCategory.educacao:         Color(0xFFA78BFA), // edu — violet
    ExpenseCategory.outros:           Color(0xFF9AA2B1), // other — stone
  };
  static const _defaultCategoryColor = Color(0xFF9AA2B1);

  static Color categoryColor(ExpenseCategory category) =>
      _expenseCategoryColors[category] ?? _defaultCategoryColor;

  static Color categoryColorByName(String name) {
    final cat = ExpenseCategory.values.where((e) => e.name == name);
    return cat.isEmpty ? _defaultCategoryColor : categoryColor(cat.first);
  }
}
