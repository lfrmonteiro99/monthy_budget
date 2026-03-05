import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/theme/app_colors.dart';
import 'package:orcamento_mensal/theme/app_theme.dart';

void main() {
  group('app_theme', () {
    test('lightTheme configures expected core properties', () {
      final theme = lightTheme(AppColorPalette.ocean);
      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF8FAFC));
      expect(theme.navigationBarTheme.height, 72);
      expect(theme.bottomSheetTheme.backgroundColor, Colors.white);
    });

    test('darkTheme configures expected core properties', () {
      final theme = darkTheme(AppColorPalette.emerald);
      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF0F172A));
      expect(theme.navigationBarTheme.height, 72);
      expect(theme.bottomSheetTheme.backgroundColor, const Color(0xFF1E293B));
    });

    test('themes are buildable for all palettes', () {
      for (final palette in AppColorPalette.values) {
        expect(lightTheme(palette).colorScheme.brightness, Brightness.light);
        expect(darkTheme(palette).colorScheme.brightness, Brightness.dark);
      }
    });
  });
}

