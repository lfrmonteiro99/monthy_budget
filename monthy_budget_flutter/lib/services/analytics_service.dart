import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/subscription_state.dart';
import '../theme/app_colors.dart';

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  static const _posthogApiKey = String.fromEnvironment('POSTHOG_API_KEY');
  static const _posthogHost = String.fromEnvironment(
    'POSTHOG_HOST',
    defaultValue: 'https://us.i.posthog.com',
  );
  static const _installTimestampKey = 'analytics_install_timestamp';
  static const _lastOpenedTimestampKey = 'analytics_last_opened_timestamp';

  final NavigatorObserver navigatorObserver = _AnalyticsNavigatorObserver();

  AnalyticsClient _client = PostHogAnalyticsClient();
  Future<PackageInfo> Function() _packageInfoLoader = PackageInfo.fromPlatform;
  Future<SharedPreferences> Function() _sharedPreferencesLoader =
      SharedPreferences.getInstance;
  DateTime Function() _now = DateTime.now;
  bool? _enabledOverride;
  bool _initialized = false;
  bool _initializing = false;
  final List<Future<void> Function()> _pendingActions = [];

  bool get enabled {
    if (_enabledOverride != null) return _enabledOverride!;
    final supportedPlatform =
        !kIsWeb &&
        switch (defaultTargetPlatform) {
          TargetPlatform.android => true,
          TargetPlatform.iOS => true,
          TargetPlatform.macOS => true,
          _ => false,
        };
    return supportedPlatform && !kDebugMode && _posthogApiKey.isNotEmpty;
  }

  Future<void> init() async {
    if (_initialized || _initializing || !enabled) return;
    _initializing = true;

    try {
      final config = AnalyticsConfig(
        apiKey: _posthogApiKey,
        host: _posthogHost,
        debug: !kReleaseMode,
        captureApplicationLifecycleEvents: true,
        anonymousOnly: true,
      );

      await _client.setup(config);
      _initialized = true;

      await _registerStaticProperties();
      await trackAppOpened();
      await _flushPendingActions();
    } finally {
      _initializing = false;
    }
  }

  Future<void> trackEvent(
    String eventName, {
    Map<String, Object?> properties = const {},
  }) async {
    await _runOrQueue(() {
      return _client.capture(eventName, _sanitizeProperties(properties));
    });
  }

  Future<void> trackScreen(
    String screenName, {
    Map<String, Object?> properties = const {},
  }) async {
    await _runOrQueue(() {
      return _client.screen(screenName, _sanitizeProperties(properties));
    });
  }

  Future<void> trackError({
    required String category,
    Object? error,
    Map<String, Object?> properties = const {},
  }) async {
    final payload = <String, Object?>{
      'category': category,
      'error_type': error?.runtimeType.toString() ?? 'unknown',
      ...properties,
    };
    await _runOrQueue(() {
      return _client.capture('service_error', _sanitizeProperties(payload));
    });
  }

  Future<void> trackAppOpened() async {
    if (!_initialized || !enabled) return;
    final prefs = await _sharedPreferencesLoader();
    final now = _now();
    final lastOpenedAt = _readTimestamp(
      prefs,
      _lastOpenedTimestampKey,
      fallback: now,
    );
    final installAt = await _ensureInstallTimestamp(prefs, now);
    await _client.capture(
      'app_opened',
      _sanitizeProperties({
        'days_since_last_use': _daysBetween(lastOpenedAt, now),
        'days_since_install': _daysBetween(installAt, now),
      }),
    );
    await prefs.setInt(_lastOpenedTimestampKey, now.millisecondsSinceEpoch);
  }

  Future<void> updateContext({
    required AppSettings settings,
    required SubscriptionState subscription,
    required ThemeMode themeMode,
    required AppColorPalette colorPalette,
    required bool isAdmin,
  }) async {
    final localeCode = _localeCodeFor(settings);
    final prefs = await _sharedPreferencesLoader();
    final installAt = await _ensureInstallTimestamp(prefs, _now());
    final daysSinceInstall = _daysBetween(installAt, _now());

    final properties = <String, Object?>{
      'subscription_tier': subscription.tier.name,
      'trial_active': subscription.isTrialActive,
      'trial_days_remaining': subscription.trialDaysRemaining,
      'country': settings.country.name,
      'language': localeCode,
      'theme_mode': themeMode.name,
      'color_palette': colorPalette.name,
      'is_admin': isAdmin,
      'days_since_install': daysSinceInstall,
      'setup_wizard_completed': settings.setupWizardCompleted,
    };

    await _runOrQueue(() async {
      for (final entry in properties.entries) {
        await _client.register(entry.key, entry.value!);
      }
    });
  }

  Future<void> reset() async {
    _pendingActions.clear();
    if (!_initialized || !enabled) return;
    await _client.reset();
    await _registerStaticProperties();
  }

  Future<void> _runOrQueue(Future<void> Function() action) async {
    if (!enabled) return;
    if (!_initialized) {
      _pendingActions.add(action);
      return;
    }
    await action();
  }

  Future<void> _flushPendingActions() async {
    if (_pendingActions.isEmpty) return;
    final pendingActions = List<Future<void> Function()>.from(_pendingActions);
    _pendingActions.clear();
    for (final action in pendingActions) {
      await action();
    }
  }

  Future<void> _registerStaticProperties() async {
    final info = await _packageInfoLoader();
    final prefs = await _sharedPreferencesLoader();
    final installAt = await _ensureInstallTimestamp(prefs, _now());
    final daysSinceInstall = _daysBetween(installAt, _now());

    await _client.register('app_version', info.version);
    await _client.register('app_build', info.buildNumber);
    await _client.register('platform', defaultTargetPlatform.name);
    await _client.register('days_since_install', daysSinceInstall);
  }

  Future<DateTime> _ensureInstallTimestamp(
    SharedPreferences prefs,
    DateTime now,
  ) async {
    final existing = prefs.getInt(_installTimestampKey);
    if (existing != null) {
      return DateTime.fromMillisecondsSinceEpoch(existing);
    }
    await prefs.setInt(_installTimestampKey, now.millisecondsSinceEpoch);
    return now;
  }

  DateTime _readTimestamp(
    SharedPreferences prefs,
    String key, {
    required DateTime fallback,
  }) {
    final value = prefs.getInt(key);
    if (value == null) return fallback;
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  int _daysBetween(DateTime earlier, DateTime later) {
    final diff = later.difference(earlier).inDays;
    return diff < 0 ? 0 : diff;
  }

  String _localeCodeFor(AppSettings settings) {
    final override = settings.localeOverride;
    if (override != null && override.isNotEmpty) {
      return override.split('_').first;
    }
    return settings.country.locale.split('_').first;
  }

  Map<String, Object> _sanitizeProperties(Map<String, Object?> properties) {
    final sanitized = <String, Object>{};
    for (final entry in properties.entries) {
      final value = entry.value;
      if (value == null) continue;
      sanitized[entry.key] = switch (value) {
        Enum enumValue => enumValue.name,
        DateTime dateTime => dateTime.toIso8601String(),
        num number => number,
        bool boolean => boolean,
        String string => string,
        List<dynamic> list => list.map((item) => item.toString()).toList(),
        Map<dynamic, dynamic> map => map.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        ),
        _ => value.toString(),
      };
    }
    return sanitized;
  }

  @visibleForTesting
  void configureForTesting({
    AnalyticsClient? client,
    bool enabled = true,
    Future<PackageInfo> Function()? packageInfoLoader,
    Future<SharedPreferences> Function()? sharedPreferencesLoader,
    DateTime Function()? now,
    bool initialized = true,
  }) {
    if (client != null) {
      _client = client;
    }
    if (packageInfoLoader != null) {
      _packageInfoLoader = packageInfoLoader;
    }
    if (sharedPreferencesLoader != null) {
      _sharedPreferencesLoader = sharedPreferencesLoader;
    }
    if (now != null) {
      _now = now;
    }
    _enabledOverride = enabled;
    _initialized = initialized;
  }

  @visibleForTesting
  void resetForTesting() {
    _client = PostHogAnalyticsClient();
    _packageInfoLoader = PackageInfo.fromPlatform;
    _sharedPreferencesLoader = SharedPreferences.getInstance;
    _now = DateTime.now;
    _enabledOverride = null;
    _initialized = false;
    _initializing = false;
    _pendingActions.clear();
  }
}

class AnalyticsConfig {
  const AnalyticsConfig({
    required this.apiKey,
    required this.host,
    required this.debug,
    required this.captureApplicationLifecycleEvents,
    required this.anonymousOnly,
  });

  final String apiKey;
  final String host;
  final bool debug;
  final bool captureApplicationLifecycleEvents;
  final bool anonymousOnly;
}

abstract class AnalyticsClient {
  Future<void> setup(AnalyticsConfig config);
  Future<void> capture(String eventName, Map<String, Object> properties);
  Future<void> screen(String screenName, Map<String, Object> properties);
  Future<void> register(String key, Object value);
  Future<void> reset();
}

class PostHogAnalyticsClient implements AnalyticsClient {
  final Posthog _posthog = Posthog();

  @override
  Future<void> setup(AnalyticsConfig config) async {
    final postHogConfig = PostHogConfig(config.apiKey);
    postHogConfig.host = config.host;
    postHogConfig.debug = config.debug;
    postHogConfig.captureApplicationLifecycleEvents =
        config.captureApplicationLifecycleEvents;
    if (config.anonymousOnly) {
      postHogConfig.personProfiles = PostHogPersonProfiles.never;
    }
    await _posthog.setup(postHogConfig);
  }

  @override
  Future<void> capture(String eventName, Map<String, Object> properties) {
    return _posthog.capture(eventName: eventName, properties: properties);
  }

  @override
  Future<void> screen(String screenName, Map<String, Object> properties) {
    return _posthog.screen(screenName: screenName, properties: properties);
  }

  @override
  Future<void> register(String key, Object value) {
    return _posthog.register(key, value);
  }

  @override
  Future<void> reset() {
    return _posthog.reset();
  }
}

class _AnalyticsNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _track(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _track(previousRoute);
    }
  }

  void _track(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty) return;
    unawaited(AnalyticsService.instance.trackScreen(name));
  }
}
