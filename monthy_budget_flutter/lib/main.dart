import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_home.dart';
import 'app_shell.dart';
import 'config/supabase_public_config.dart';
import 'l10n/generated/app_localizations.dart';
import 'screens/auth/auth_gate.dart';
import 'services/ad_service.dart';
import 'services/analytics_service.dart';
import 'services/local_config_service.dart';
import 'services/log_service.dart';
import 'services/notification_service.dart';
import 'services/revenuecat_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

/// Non-null when Supabase failed to initialise (bad credentials, network, etc.).
String? supabaseInitError;

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  // --- Global error handlers ---

  // Catch Flutter framework errors (build, layout, paint).
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    LogService.error(
      'Unhandled Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
      category: 'runtime.flutter',
    );
  };

  // Catch unhandled async errors that escape Zones and Futures.
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    LogService.error(
      'Unhandled platform dispatcher error',
      error: error,
      stackTrace: stack,
      category: 'runtime.platform',
    );
    // Return true to prevent the runtime from terminating the app.
    return true;
  };

  // --- Critical path: only what's needed to show the login screen ---

  // Supabase + theme config in parallel
  final configService = LocalConfigService();
  final results = await Future.wait([
    _initSupabase(),
    configService.loadThemeMode(),
    configService.loadColorPalette(),
  ]);
  final appShellController = AppShellController(
    themeMode: results[1] as ThemeMode,
    colorPalette: results[2] as AppColorPalette,
  );

  // Show UI immediately - splash removed, login visible
  FlutterNativeSplash.remove();

  await LogService.initApp(() async {
    // Pre-warm Fraunces + Inter so the first hero number renders immediately
    // in the correct typeface. Timeout is intentionally short so offline
    // users are not blocked on splash; runtime fetching remains active.
    try {
      await GoogleFonts.pendingFonts([
        GoogleFonts.fraunces(),
        GoogleFonts.inter(),
      ]).timeout(const Duration(seconds: 3));
    } catch (e) {
      LogService.error(
        'Font pre-warm failed — will fall back to runtime fetching',
        error: e,
        category: 'theme.fonts',
      );
    }

    // Zone guard: last-resort catcher for errors that bypass all other handlers.
    runZonedGuarded(
      () {
        runApp(OrcamentoMensalApp(controller: appShellController));
        // Non-critical: defer to background after UI is on screen
        unawaited(_initDeferredServices());
      },
      (Object error, StackTrace stack) {
        LogService.error(
          'Unhandled zone error',
          error: error,
          stackTrace: stack,
          category: 'runtime.zone',
        );
      },
    );
  });
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
      LogService.error(
        'Supabase initialization failed',
        error: e,
        category: 'service.supabase',
      );
      supabaseInitError = 'Supabase init failed: $e';
    }
  }
}

Future<void> _initDeferredServices() async {
  await Future.wait([
    Future(() async {
      try {
        await AnalyticsService.instance.init();
      } catch (e) {
        LogService.error(
          'AnalyticsService initialization failed',
          error: e,
          category: 'service.analytics',
        );
      }
    }),
    Future(() async {
      try {
        await NotificationService().init();
      } catch (e) {
        LogService.error(
          'NotificationService initialization failed',
          error: e,
          category: 'service.notifications',
        );
      }
    }),
    Future(() async {
      try {
        await AdService.initialize();
      } catch (e) {
        LogService.error(
          'AdService initialization failed',
          error: e,
          category: 'service.ads',
        );
      }
    }),
    Future(() async {
      try {
        await RevenueCatService.initialize();
      } catch (e) {
        LogService.error(
          'RevenueCatService initialization failed',
          error: e,
          category: 'service.revenuecat',
        );
      }
    }),
  ]);
}

class OrcamentoMensalApp extends StatefulWidget {
  final AppShellController? controller;

  const OrcamentoMensalApp({super.key, this.controller});

  @override
  State<OrcamentoMensalApp> createState() => _OrcamentoMensalAppState();
}

class _OrcamentoMensalAppState extends State<OrcamentoMensalApp> {
  late final AppShellController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? AppShellController();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShellScope(
      controller: _controller,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => MaterialApp(
          title: 'Orçamento Mensal',
          debugShowCheckedModeBanner: false,
          navigatorObservers: [AnalyticsService.instance.navigatorObserver],
          locale: _controller.locale,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.supportedLocales,
          theme: lightTheme(_controller.colorPalette),
          darkTheme: darkTheme(_controller.colorPalette),
          themeMode: _controller.themeMode,
          home: supabaseInitError != null
              ? _SupabaseErrorScreen(error: supabaseInitError!)
              : AuthGate(
                  appBuilder: (profile) => AppHome(
                    householdId: profile.householdId,
                    isAdmin: profile.role == 'admin',
                  ),
                ),
        ),
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
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error(context),
              ),
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
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
