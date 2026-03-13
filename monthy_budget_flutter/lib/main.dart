import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_public_config.dart';
import 'services/local_config_service.dart';
import 'services/notification_service.dart';
import 'services/ad_service.dart';
import 'services/revenuecat_service.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'screens/auth/auth_gate.dart';
import 'app_home.dart';

/// Global notifier for reactive locale changes from settings.
final appLocaleNotifier = ValueNotifier<Locale?>(null);

/// Global notifier for reactive theme changes.
final appThemeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

/// Global notifier for reactive color palette changes.
final appColorPaletteNotifier =
    ValueNotifier<AppColorPalette>(AppColorPalette.ocean);

/// Non-null when Supabase failed to initialise (bad credentials, network, etc.).
String? supabaseInitError;

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  // --- Critical path: only what's needed to show the login screen ---

  // Supabase + theme config in parallel
  final configService = LocalConfigService();
  final results = await Future.wait([
    _initSupabase(),
    configService.loadThemeMode(),
    configService.loadColorPalette(),
  ]);

  appThemeModeNotifier.value = results[1] as ThemeMode;
  final palette = results[2] as AppColorPalette;
  appColorPaletteNotifier.value = palette;
  AppColors.palette = palette;

  // Show UI immediately — splash removed, login visible
  FlutterNativeSplash.remove();
  runApp(const OrcamentoMensalApp());

  // --- Non-critical: defer to background after UI is on screen ---
  unawaited(_initDeferredServices());
}

Future<void> _initSupabase() async {
  if (supabaseUrl.isEmpty ||
      supabaseUrl.contains('example.supabase.co') ||
      supabaseUrl.contains('placeholder') ||
      supabaseAnonKey.isEmpty ||
      supabaseAnonKey == 'public-anon-key-placeholder' ||
      supabaseAnonKey == 'placeholder') {
    supabaseInitError =
        'Supabase credentials are missing or invalid.\n\n'
        'URL: ${supabaseUrl.isEmpty ? "(empty)" : supabaseUrl}\n'
        'Key length: ${supabaseAnonKey.length} chars';
  } else {
    try {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    } catch (e) {
      supabaseInitError = 'Supabase init failed: $e';
    }
  }
}

Future<void> _initDeferredServices() async {
  await Future.wait([
    Future(() async {
      try {
        await NotificationService().init();
      } catch (e) {
        debugPrint('NotificationService initialization failed: $e');
      }
    }),
    Future(() async {
      try {
        await AdService.initialize();
      } catch (e) {
        debugPrint('AdService initialization failed: $e');
      }
    }),
    Future(() async {
      try {
        await RevenueCatService.initialize();
      } catch (e) {
        debugPrint('RevenueCatService initialization failed: $e');
      }
    }),
  ]);
}

class OrcamentoMensalApp extends StatelessWidget {
  const OrcamentoMensalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeModeNotifier,
      builder: (_, themeMode, _) => ValueListenableBuilder<AppColorPalette>(
        valueListenable: appColorPaletteNotifier,
        builder: (_, palette, _) {
          AppColors.palette = palette;
          return ValueListenableBuilder<Locale?>(
            valueListenable: appLocaleNotifier,
            builder: (_, locale, _) => MaterialApp(
              title: 'Orçamento Mensal',
              debugShowCheckedModeBanner: false,
              locale: locale,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.supportedLocales,
              theme: lightTheme(palette),
              darkTheme: darkTheme(palette),
              themeMode: themeMode,
              home: supabaseInitError != null
                  ? _SupabaseErrorScreen(error: supabaseInitError!)
                  : AuthGate(
                      appBuilder: (profile) => AppHome(
                        householdId: profile.householdId,
                        isAdmin: profile.role == 'admin',
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _SupabaseErrorScreen extends StatelessWidget {
  final String error;
  const _SupabaseErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error(context)),
              const SizedBox(height: 16),
              // Hardcoded: l10n is unavailable here because this screen renders
              // before MaterialApp (and its localization delegates) are built.
              const Text(
                'Configuration Error',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
