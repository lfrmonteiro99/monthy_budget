import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/subscription_state.dart';

class AdService {
  AdService._();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  static bool shouldShowAds(SubscriptionState subscription) {
    return !subscription.canAccess(PremiumFeature.noAds);
  }
}
