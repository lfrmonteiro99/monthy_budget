# AdMob Banner Ads Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Show an adaptive banner ad on the Dashboard for free-tier users after trial expires; no ads for Premium/Family/trial users.

**Architecture:** `AdService` singleton handles initialization and ad loading. `AdBannerWidget` renders the ad or nothing. The widget is inserted in `main.dart`'s dashboard Column, gated by `subscription.canAccess(PremiumFeature.noAds)`.

**Tech Stack:** `google_mobile_ads` Flutter plugin, Google AdMob.

---

### Task 1: Add google_mobile_ads dependency

**Files:**
- Modify: `monthy_budget_flutter/pubspec.yaml:28` (after `tutorial_coach_mark`)

**Step 1: Add dependency**

In `pubspec.yaml`, add after `tutorial_coach_mark: ^1.2.11` (line 28):

```yaml
  google_mobile_ads: ^5.3.0
```

**Step 2: Install**

Run: `cd monthy_budget_flutter && flutter pub get`
Expected: resolves successfully, `pubspec.lock` updated.

---

### Task 2: Android manifest configuration

**Files:**
- Modify: `monthy_budget_flutter/android/app/src/main/AndroidManifest.xml`

**Step 1: Add AdMob application ID**

Inside the `<application>` tag, after the `flutterEmbedding` meta-data (last `<meta-data>` before `</application>`), add:

```xml
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-3940256099942544~3347511713"/>
```

> Note: `ca-app-pub-3940256099942544~3347511713` is Google's official **test application ID**. Replace with real ID when AdMob account is set up.

**Step 2: Verify build compiles**

Run: `cd monthy_budget_flutter && flutter build apk --debug 2>&1 | tail -5`
Expected: BUILD SUCCESSFUL

---

### Task 3: Create ad config

**Files:**
- Create: `monthy_budget_flutter/lib/config/ad_config.dart`

**Step 1: Create file**

```dart
import 'package:flutter/foundation.dart';

class AdConfig {
  AdConfig._();

  /// Google's official test Application ID.
  /// Replace with real AdMob App ID when going to production.
  static const String appId = 'ca-app-pub-3940256099942544~3347511713';

  /// Banner ad unit ID.
  /// Test ID in debug, real ID in release.
  static String get bannerAdUnitId {
    if (kDebugMode) {
      // Google-provided test banner unit ID — always returns test ads
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    // TODO: Replace with real AdMob banner unit ID
    return 'ca-app-pub-3940256099942544/6300978111';
  }
}
```

---

### Task 4: Create AdService

**Files:**
- Create: `monthy_budget_flutter/lib/services/ad_service.dart`
- Test: `monthy_budget_flutter/test/ad_service_test.dart`

**Step 1: Write the test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/subscription_state.dart';
import 'package:orcamento_mensal/services/ad_service.dart';

void main() {
  group('AdService.shouldShowAds', () {
    test('returns false during active trial', () {
      final state = SubscriptionState(
        trialStartDate: DateTime.now(),
      );
      expect(AdService.shouldShowAds(state), false);
    });

    test('returns true for free tier after trial', () {
      final state = SubscriptionState(
        trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
      );
      expect(AdService.shouldShowAds(state), true);
    });

    test('returns true for free tier with trialUsed', () {
      final state = SubscriptionState(
        trialStartDate: DateTime.now(),
        trialUsed: true,
      );
      expect(AdService.shouldShowAds(state), true);
    });

    test('returns false for premium tier', () {
      final state = SubscriptionState(
        tier: SubscriptionTier.premium,
        trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        trialUsed: true,
      );
      expect(AdService.shouldShowAds(state), false);
    });

    test('returns false for family tier', () {
      final state = SubscriptionState(
        tier: SubscriptionTier.family,
        trialStartDate: DateTime.now().subtract(const Duration(days: 30)),
        trialUsed: true,
      );
      expect(AdService.shouldShowAds(state), false);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd monthy_budget_flutter && flutter test test/ad_service_test.dart`
Expected: FAIL — `ad_service.dart` doesn't exist yet.

**Step 3: Write the implementation**

```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/subscription_state.dart';

class AdService {
  AdService._();

  static bool _initialized = false;

  /// Initialize the Mobile Ads SDK. Call once at app startup.
  static Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  /// Whether ads should be displayed for the given subscription state.
  static bool shouldShowAds(SubscriptionState subscription) {
    return !subscription.canAccess(PremiumFeature.noAds);
  }
}
```

**Step 4: Run test to verify it passes**

Run: `cd monthy_budget_flutter && flutter test test/ad_service_test.dart`
Expected: All 5 tests PASS.

---

### Task 5: Create AdBannerWidget

**Files:**
- Create: `monthy_budget_flutter/lib/widgets/ad_banner_widget.dart`
- Test: `monthy_budget_flutter/test/widgets/ad_banner_widget_test.dart`

**Step 1: Write the test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/widgets/ad_banner_widget.dart';

void main() {
  group('AdBannerWidget', () {
    testWidgets('renders nothing when showAd is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdBannerWidget(showAd: false),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
      // No ad container should be present
      expect(find.byKey(const Key('ad_banner_container')), findsNothing);
    });

    testWidgets('renders container when showAd is true', (tester) async {
      // In test environment, MobileAds is not initialized,
      // so the ad won't load — but the container should exist
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdBannerWidget(showAd: true),
          ),
        ),
      );

      // The widget attempts to show but gracefully handles no ad
      expect(find.byType(AdBannerWidget), findsOneWidget);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd monthy_budget_flutter && flutter test test/widgets/ad_banner_widget_test.dart`
Expected: FAIL — file doesn't exist.

**Step 3: Write the implementation**

```dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart';

/// Adaptive banner ad widget. Shows nothing if [showAd] is false
/// or if the ad fails to load.
class AdBannerWidget extends StatefulWidget {
  final bool showAd;

  const AdBannerWidget({super.key, required this.showAd});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.showAd) _loadAd();
  }

  @override
  void didUpdateWidget(AdBannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAd && !oldWidget.showAd) {
      _loadAd();
    } else if (!widget.showAd && oldWidget.showAd) {
      _bannerAd?.dispose();
      _bannerAd = null;
      if (mounted) setState(() => _isLoaded = false);
    }
  }

  Future<void> _loadAd() async {
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    );
    if (size == null) return;

    final ad = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    );

    _bannerAd = ad;
    await ad.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showAd || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      key: const Key('ad_banner_container'),
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `cd monthy_budget_flutter && flutter test test/widgets/ad_banner_widget_test.dart`
Expected: PASS.

---

### Task 6: Integrate into Dashboard

**Files:**
- Modify: `monthy_budget_flutter/lib/main.dart:1-5` (imports), `lib/main.dart:850` (widget insertion)

**Step 1: Add imports**

At the top of `lib/main.dart`, add with the other imports:

```dart
import 'services/ad_service.dart';
import 'widgets/ad_banner_widget.dart';
```

**Step 2: Initialize AdService in main()**

In the `main()` function (`lib/main.dart:68-79`), add before `runApp()`:

```dart
  await AdService.initialize();
```

So it becomes:
```dart
  await NotificationService().init();
  await AdService.initialize();
  runApp(const OrcamentoMensalApp());
```

**Step 3: Insert AdBannerWidget in dashboard Column**

In `_AppHomeState`, the dashboard tab is at lines 829-852:

```dart
      body: _currentIndex == 0
          ? Column(
              children: [
                // Trial banner on dashboard
                if (_subscription.isTrialActive)
                  TrialBanner(
                    subscription: _subscription,
                    onUpgrade: _openPaywall,
                  ),
                // Feature discovery nudge
                if (_subscription.isTrialActive &&
                    _subscription.nextFeatureToDiscover != null)
                  FeatureDiscoveryCard(
                    subscription: _subscription,
                    onExploreFeature: _navigateToFeature,
                    onDismiss: () {
                      final next = _subscription.nextFeatureToDiscover;
                      if (next != null) _trackFeature(next);
                    },
                  ),
                Expanded(child: screens[0]),
              ],
            )
```

Add the `AdBannerWidget` **after** `Expanded(child: screens[0])` (line 850):

```dart
                Expanded(child: screens[0]),
                // Banner ad for free tier (after trial)
                AdBannerWidget(
                  showAd: AdService.shouldShowAds(_subscription),
                ),
              ],
```

**Step 4: Verify**

Run: `cd monthy_budget_flutter && flutter analyze --no-fatal-infos`
Expected: 0 errors.

Run: `cd monthy_budget_flutter && flutter test`
Expected: All tests pass.

---

### Task 7: Commit all changes

**Files changed:**
- `pubspec.yaml` (dependency added)
- `pubspec.lock` (auto-updated)
- `android/app/src/main/AndroidManifest.xml` (AdMob app ID)
- `lib/config/ad_config.dart` (new)
- `lib/services/ad_service.dart` (new)
- `lib/widgets/ad_banner_widget.dart` (new)
- `lib/main.dart` (imports + initialization + widget)
- `test/ad_service_test.dart` (new)
- `test/widgets/ad_banner_widget_test.dart` (new)

Run:
```bash
git add pubspec.yaml pubspec.lock \
  android/app/src/main/AndroidManifest.xml \
  lib/config/ad_config.dart \
  lib/services/ad_service.dart \
  lib/widgets/ad_banner_widget.dart \
  lib/main.dart \
  test/ad_service_test.dart \
  test/widgets/ad_banner_widget_test.dart

git commit -m "claude/budget-calculator-app: add AdMob banner ads for free tier after trial"
git push
```

---

## Post-Implementation: Production Checklist

Before publishing to Google Play with real ads:

1. Create an AdMob account at [admob.google.com](https://admob.google.com)
2. Create an app → get real **Application ID** (replace test ID in `AndroidManifest.xml`)
3. Create a **Banner ad unit** → get real **Ad Unit ID** (replace in `ad_config.dart` release branch)
4. Link AdMob to Play Console for app-ads.txt verification
5. Add `app-ads.txt` to your website domain (if required by AdMob)
6. Update Play Console Data Safety section to declare ad SDK data collection
