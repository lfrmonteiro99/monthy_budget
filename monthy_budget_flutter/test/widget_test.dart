import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/app_shell.dart';
import 'package:monthly_management/main.dart';
import 'package:monthly_management/theme/app_colors.dart';

void main() {
  tearDown(() {
    supabaseInitError = null;
  });

  testWidgets('OrcamentoMensalApp uses the provided shell controller', (
    tester,
  ) async {
    supabaseInitError = 'test error';
    final controller = AppShellController(
      locale: const Locale('fr'),
      themeMode: ThemeMode.dark,
      colorPalette: AppColorPalette.calm,
    );

    await tester.pumpWidget(OrcamentoMensalApp(controller: controller));

    var app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, const Locale('fr'));
    expect(app.themeMode, ThemeMode.dark);
    expect(AppColors.palette, AppColorPalette.calm);

    controller
      ..setLocaleCode('es')
      ..setThemeMode(ThemeMode.light)
      ..setColorPalette(AppColorPalette.calm);
    await tester.pump();

    app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, const Locale('es'));
    expect(app.themeMode, ThemeMode.light);
    expect(AppColors.palette, AppColorPalette.calm);
  });
}
