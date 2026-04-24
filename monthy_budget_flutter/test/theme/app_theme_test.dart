import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';
import 'package:monthly_management/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('app_theme', () {
    testWidgets('lightTheme configures expected core properties', (tester) async {
      final theme = lightTheme(AppColorPalette.calm);
      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF8F7F3));
      expect(theme.navigationBarTheme.height, 72);
      expect(theme.bottomSheetTheme.backgroundColor, Colors.white);
    });

    testWidgets('darkTheme configures expected core properties', (tester) async {
      final theme = darkTheme(AppColorPalette.calm);
      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF12100D));
      expect(theme.navigationBarTheme.height, 72);
      expect(theme.bottomSheetTheme.backgroundColor, const Color(0xFF1F1D19));
    });

    testWidgets('themes are buildable for all palettes', (tester) async {
      for (final palette in AppColorPalette.values) {
        expect(lightTheme(palette).colorScheme.brightness, Brightness.light);
        expect(darkTheme(palette).colorScheme.brightness, Brightness.dark);
      }
    });
  });
}
