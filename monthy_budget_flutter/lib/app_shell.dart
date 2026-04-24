import 'package:flutter/material.dart';

import 'theme/app_colors.dart';

class AppShellController extends ChangeNotifier {
  AppShellController({
    Locale? locale,
    ThemeMode themeMode = ThemeMode.system,
    AppColorPalette colorPalette = AppColorPalette.calm,
  }) : _locale = locale,
       _themeMode = themeMode,
       _colorPalette = colorPalette {
    AppColors.palette = colorPalette;
  }

  Locale? _locale;
  ThemeMode _themeMode;
  AppColorPalette _colorPalette;

  Locale? get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  AppColorPalette get colorPalette => _colorPalette;

  void setLocale(Locale? locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  void setLocaleCode(String? localeCode) {
    setLocale(localeCode == null ? null : Locale(localeCode));
  }

  void setThemeMode(ThemeMode themeMode) {
    if (_themeMode == themeMode) return;
    _themeMode = themeMode;
    notifyListeners();
  }

  void setColorPalette(AppColorPalette colorPalette) {
    if (_colorPalette == colorPalette) return;
    _colorPalette = colorPalette;
    AppColors.palette = colorPalette;
    notifyListeners();
  }
}

class AppShellScope extends InheritedNotifier<AppShellController> {
  const AppShellScope({
    super.key,
    required AppShellController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppShellController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppShellScope>();
    assert(scope != null, 'AppShellScope not found in context');
    return scope!.notifier!;
  }

  static AppShellController read(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<AppShellScope>();
    final scope = element?.widget as AppShellScope?;
    assert(scope != null, 'AppShellScope not found in context');
    return scope!.notifier!;
  }
}
