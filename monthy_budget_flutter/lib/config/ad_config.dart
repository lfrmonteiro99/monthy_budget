import 'package:flutter/foundation.dart';

class AdConfig {
  AdConfig._();

  static const String appId = 'ca-app-pub-4120103483325005~7509407312';

  static String get bannerAdUnitId {
    if (kReleaseMode) {
      return 'ca-app-pub-4120103483325005/8024412636';
    }
    // Google-provided test banner unit ID — debug and profile modes
    return 'ca-app-pub-3940256099942544/6300978111';
  }
}
