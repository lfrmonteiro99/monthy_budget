# AdMob Banner Ads for Free Tier — Design

## Goal

Show a non-intrusive adaptive banner ad on the Dashboard for free-tier users after the trial expires. Premium and Family tiers see no ads.

## Who sees ads

| User state | Sees ads? |
|---|---|
| Trial active (first 14 days) | No |
| Trial expired, free tier | Yes |
| `trialUsed: true`, free tier | Yes |
| Premium tier | No |
| Family tier | No |

Condition: `!subscription.isTrialActive && subscription.tier == SubscriptionTier.free`

## Where

Single adaptive banner at the bottom of the Dashboard screen (tab 0), above the bottom navigation bar. Adaptive banners auto-size to screen width.

## Architecture

```
lib/
  services/
    ad_service.dart          ← Singleton. Init AdMob, load/dispose banner, expose showAds bool
  widgets/
    ad_banner_widget.dart    ← Stateful widget wrapping AdWidget. Shows nothing when no ad
  config/
    ad_config.dart           ← Ad unit IDs (test vs prod via kReleaseMode)
```

- `AdService` initializes `MobileAds.instance.initialize()` once at app startup
- `AdService.shouldShowAds(SubscriptionState)` → single source of truth
- `AdBannerWidget` loads an `AdaptiveBannerAd`, handles load failure gracefully (shows nothing)
- Dashboard inserts `AdBannerWidget` at the bottom of its content

## Dependencies

- `google_mobile_ads: ^5.3.0` in `pubspec.yaml`
- Android `AndroidManifest.xml`: `<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="..."/>`
- iOS `Info.plist`: `GADApplicationIdentifier` (future)

## Ad Unit IDs

- Test IDs during development (Google-provided, no real ads)
- Real IDs from AdMob account in `ad_config.dart`
- Switch via `kReleaseMode`

## UX Behavior

- Banner loads asynchronously — dashboard renders normally, banner appears when ready
- If ad fails to load: nothing shows, no error visible
- ~50-60px height at bottom of dashboard content area
- Paywall "No ads" feature for Premium/Family is now enforced

## CI Impact

None. AdService won't initialize in test environment. Widget tests mock the ad service.
