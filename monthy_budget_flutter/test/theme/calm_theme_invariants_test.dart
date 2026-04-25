import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';
import 'package:monthly_management/theme/app_theme.dart';

/// Files that currently contain hardcoded Color(0x...) literals outside
/// lib/theme/. Each file drops off this list when its owning screen is
/// redesigned and its literals are replaced with AppColors.* tokens.
///
/// Verified by:
///   grep -rEln "Color\(0x[A-Fa-f0-9]{6,8}\)" lib/ --include='*.dart' \
///     --exclude-dir=theme | sort
///
/// Last verified: 2026-04-25 (3 files).
const _grandfathered = <String>{
  'lib/app_home.dart',
  'lib/screens/settings_screen.dart',
  'lib/widgets/charts/budget_charts.dart',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Calm theme invariants', () {
    testWidgets('FilledButton uses ink (not accent) for primary CTA',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: lightTheme(AppColorPalette.calm),
        home: Scaffold(
          body: FilledButton(onPressed: () {}, child: const Text('x')),
        ),
      ));

      final ctx = tester.element(find.byType(FilledButton));
      final style = Theme.of(ctx).filledButtonTheme.style!;
      final bg = style.backgroundColor!.resolve(const <WidgetState>{})!;

      expect(
        bg,
        AppColors.ink(ctx),
        reason: 'Primary CTA background must be AppColors.ink — the Calm '
            'design rule is ink-filled buttons, not accent-filled.',
      );
    });

    test(
        'No new hard-coded Color(0x...) outside lib/theme/ or grandfathered '
        'files', () {
      final hits = <String>[];

      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;

        // Normalise to forward slashes so the set works on all platforms.
        final rel = entity.path.replaceAll(Platform.pathSeparator, '/');

        if (rel.startsWith('lib/theme/')) continue;
        if (_grandfathered.contains(rel)) continue;

        final lines = entity.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (RegExp(r'Color\(0x[A-Fa-f0-9]{6,8}\)').hasMatch(lines[i])) {
            hits.add('$rel:${i + 1}  ${lines[i].trim()}');
          }
        }
      }

      expect(
        hits,
        isEmpty,
        reason:
            'Use AppColors.* tokens instead of raw Color(0x...) literals.\n'
            'If this file is being redesigned, remove it from _grandfathered '
            'in test/theme/calm_theme_invariants_test.dart once all '
            'hardcoded colors are gone.\n\n'
            'Offending lines:\n${hits.join('\n')}',
      );
    });
  });
}
