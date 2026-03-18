import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:monthly_management/app_shell.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';
import 'package:monthly_management/theme/app_theme.dart';

Widget wrapWithTestApp(Widget child, {AppShellController? controller}) {
  final appShell = controller ?? AppShellController(locale: const Locale('en'));
  return AppShellScope(
    controller: appShell,
    child: AnimatedBuilder(
      animation: appShell,
      builder: (context, _) => MaterialApp(
        locale: appShell.locale ?? const Locale('en'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.supportedLocales,
        theme: lightTheme(appShell.colorPalette),
        darkTheme: darkTheme(appShell.colorPalette),
        themeMode: appShell.themeMode,
        home: child,
      ),
    ),
  );
}
