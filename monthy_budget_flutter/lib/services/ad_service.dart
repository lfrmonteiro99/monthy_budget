import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/subscription_state.dart';

class AdService {
  AdService._();

  static bool _initialized = false;
  static bool _adsAvailable = false;

  @visibleForTesting
  static void setAdsAvailableForTesting(bool value) {
    _adsAvailable = value;
  }

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final platform = defaultTargetPlatform;
    final isSupportedMobile =
        !kIsWeb &&
        (platform == TargetPlatform.android || platform == TargetPlatform.iOS);
    if (!isSupportedMobile) return;

    try {
      await MobileAds.instance.initialize();
      _adsAvailable = true;
    } on MissingPluginException {
      _adsAvailable = false;
    } catch (_) {
      _adsAvailable = false;
    }
  }

  static bool shouldShowAds(SubscriptionState subscription) {
    return _adsAvailable && !subscription.canAccess(PremiumFeature.noAds);
  }
}
