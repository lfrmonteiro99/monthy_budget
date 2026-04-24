import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monthly_management/data/tax/tax_system.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/subscription_state.dart';
import 'package:monthly_management/services/analytics_service.dart';
import 'package:monthly_management/theme/app_colors.dart';

void main() {
  late _FakeAnalyticsClient client;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    client = _FakeAnalyticsClient();
    AnalyticsService.instance.configureForTesting(
      client: client,
      enabled: true,
      packageInfoLoader: () async => PackageInfo(
        appName: 'Monthly Management',
        packageName: 'com.example.monthly',
        version: '1.2.3',
        buildNumber: '42',
        buildSignature: '',
      ),
      sharedPreferencesLoader: SharedPreferences.getInstance,
      now: () => DateTime(2026, 3, 19, 12),
      initialized: true,
    );
  });

  tearDown(() {
    AnalyticsService.instance.resetForTesting();
  });

  test('trackError records service_error with context', () async {
    await AnalyticsService.instance.trackError(
      category: 'service.notifications',
      error: StateError('failed'),
      properties: {'retry': true},
    );

    expect(client.events, hasLength(1));
    expect(client.events.single.name, 'service_error');
    expect(
      client.events.single.properties['category'],
      'service.notifications',
    );
    expect(client.events.single.properties['error_type'], 'StateError');
    expect(client.events.single.properties['retry'], true);
  });

  test('updateContext registers anonymous analytics properties', () async {
    await AnalyticsService.instance.updateContext(
      settings: const AppSettings(country: Country.fr, localeOverride: 'fr'),
      subscription: SubscriptionState(
        tier: SubscriptionTier.family,
        trialStartDate: DateTime(2026, 3, 1),
      ),
      themeMode: ThemeMode.dark,
      colorPalette: AppColorPalette.calm,
      isAdmin: true,
    );

    expect(client.registered['subscription_tier'], 'family');
    expect(client.registered['country'], 'fr');
    expect(client.registered['language'], 'fr');
    expect(client.registered['theme_mode'], 'dark');
    expect(client.registered['color_palette'], 'calm');
    expect(client.registered['is_admin'], true);
  });

  test('navigator observer tracks named routes', () async {
    final route = MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'coach'),
      builder: (_) => const SizedBox(),
    );

    AnalyticsService.instance.navigatorObserver.didPush(route, null);
    await Future<void>.delayed(Duration.zero);

    expect(client.screens, hasLength(1));
    expect(client.screens.single.name, 'coach');
  });

  test('queues context and screen tracking until init completes', () async {
    AnalyticsService.instance.configureForTesting(
      client: client,
      enabled: true,
      packageInfoLoader: () async => PackageInfo(
        appName: 'Monthly Management',
        packageName: 'com.example.monthly',
        version: '1.2.3',
        buildNumber: '42',
        buildSignature: '',
      ),
      sharedPreferencesLoader: SharedPreferences.getInstance,
      now: () => DateTime(2026, 3, 19, 12),
      initialized: false,
    );

    await AnalyticsService.instance.updateContext(
      settings: const AppSettings(country: Country.pt),
      subscription: SubscriptionState(trialStartDate: DateTime(2026, 3, 1)),
      themeMode: ThemeMode.light,
      colorPalette: AppColorPalette.calm,
      isAdmin: false,
    );
    await AnalyticsService.instance.trackScreen('dashboard');

    expect(client.registered, isEmpty);
    expect(client.screens, isEmpty);

    await AnalyticsService.instance.init();

    expect(client.registered['country'], 'pt');
    expect(client.registered['theme_mode'], 'light');
    expect(client.screens.map((screen) => screen.name), contains('dashboard'));
  });
}

class _FakeAnalyticsClient implements AnalyticsClient {
  final List<_CapturedEvent> events = [];
  final List<_CapturedEvent> screens = [];
  final Map<String, Object> registered = {};

  @override
  Future<void> capture(String eventName, Map<String, Object> properties) async {
    events.add(_CapturedEvent(eventName, properties));
  }

  @override
  Future<void> register(String key, Object value) async {
    registered[key] = value;
  }

  @override
  Future<void> reset() async {
    events.clear();
    screens.clear();
    registered.clear();
  }

  @override
  Future<void> screen(String screenName, Map<String, Object> properties) async {
    screens.add(_CapturedEvent(screenName, properties));
  }

  @override
  Future<void> setup(AnalyticsConfig config) async {}
}

class _CapturedEvent {
  const _CapturedEvent(this.name, this.properties);

  final String name;
  final Map<String, Object> properties;
}
