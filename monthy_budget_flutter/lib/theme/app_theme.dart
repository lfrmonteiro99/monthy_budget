import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Calm theme — translates tokens.css into Flutter ThemeData.
///
/// Type system:
///   - Body / UI:     Inter  (existing)
///   - Display nums:  Fraunces (serif, for large currency figures)
///
/// Use `Theme.of(context).textTheme.displayLarge.copyWith(fontFamily: 'Fraunces')`
/// — or the shortcut `CalmText.display(context, 42)` below — for hero amounts.

ThemeData lightTheme([AppColorPalette? _]) {
  const bg = Color(0xFFF8F7F3);
  const ink = Color(0xFF0B0E14);
  const ink70 = Color(0xFF4A5464);
  const ink50 = Color(0xFF8B93A3);
  const ink20 = Color(0xFFDCDED6);
  const accent = Color(0xFF2F4CDD);
  const accentSoft = Color(0xFFEAEEFF);
  const line = Color(0x120B0E14); // rgba(11,14,20,0.07)

  final colorScheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.light,
    surface: Colors.white,
    // ignore: deprecated_member_use
    background: bg,
  );

  final textTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme)
      .apply(bodyColor: ink, displayColor: ink);

  return _baseTheme(
    brightness: Brightness.light,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackground: bg,
    surface: Colors.white,
    ink: ink,
    ink70: ink70,
    ink50: ink50,
    ink20: ink20,
    accent: accent,
    accentSoft: accentSoft,
    line: line,
  );
}

ThemeData darkTheme([AppColorPalette? _]) {
  const bg = Color(0xFF12100D);
  const surface = Color(0xFF1F1D19);
  const ink = Color(0xFFF5F2EC);
  const ink70 = Color(0xFFB8B2A5);
  const ink50 = Color(0xFF807A6D);
  const ink20 = Color(0xFF3A3730);
  const accent = Color(0xFF8B9BFF);
  final accentSoft = accent.withValues(alpha: 0.14);
  final line = ink.withValues(alpha: 0.08);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.dark,
    surface: surface,
    // ignore: deprecated_member_use
    background: bg,
  );

  final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
      .apply(bodyColor: ink, displayColor: ink);

  return _baseTheme(
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackground: bg,
    surface: surface,
    ink: ink,
    ink70: ink70,
    ink50: ink50,
    ink20: ink20,
    accent: accent,
    accentSoft: accentSoft,
    line: line,
  );
}

ThemeData _baseTheme({
  required Brightness brightness,
  required ColorScheme colorScheme,
  required TextTheme textTheme,
  required Color scaffoldBackground,
  required Color surface,
  required Color ink,
  required Color ink70,
  required Color ink50,
  required Color ink20,
  required Color accent,
  required Color accentSoft,
  required Color line,
}) {
  final appBarFg = ink;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: scaffoldBackground,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: scaffoldBackground, // flush with page, no hard line
      foregroundColor: appBarFg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: appBarFg,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ink, // Calm uses ink as primary CTA, not accent
        foregroundColor: scaffoldBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        elevation: 0,
        minimumSize: const Size(0, 52),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ink,
        foregroundColor: scaffoldBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        elevation: 0,
        minimumSize: const Size(0, 52),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: ink20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        minimumSize: const Size(0, 52),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ink,
      foregroundColor: scaffoldBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      selectedColor: accentSoft,
      side: BorderSide(color: line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      labelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: ink70,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: accentSoft,
      height: 72,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.inter(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? ink : ink50,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? ink : ink50, size: 22);
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: ink, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.inter(fontSize: 15, color: ink50),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: ink,
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14, color: scaffoldBackground, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dividerTheme: DividerThemeData(color: line, thickness: 1, space: 1),
    tabBarTheme: TabBarThemeData(
      labelColor: ink,
      unselectedLabelColor: ink50,
      labelStyle:
          GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle:
          GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400),
      indicatorColor: ink,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: line,
      dividerHeight: 1,
    ),
  );
}

/// Helpers for the Fraunces display type used on hero amounts and big numbers.
///
/// Add `google_fonts` is already in pubspec — no extra dep.
class CalmText {
  CalmText._();

  /// Big currency number, serif, tight leading.
  static TextStyle display(BuildContext context, {double size = 44}) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: FontWeight.w500,
      height: 1.0,
      letterSpacing: -0.02 * size,
      color: AppColors.ink(context),
      fontFeatures: const [FontFeature.stylisticSet(1)],
    );
  }

  /// Tabular-number body style for amounts in lists.
  static TextStyle amount(BuildContext context,
      {double size = 15, FontWeight weight = FontWeight.w600}) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: AppColors.ink(context),
      fontFeatures: const [FontFeature.tabularFigures()],
      letterSpacing: -0.01,
    );
  }

  /// Small uppercase label / section eyebrow.
  static TextStyle eyebrow(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.ink50(context),
      letterSpacing: 1.2,
    );
  }
}
