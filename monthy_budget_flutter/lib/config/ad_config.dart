import 'package:flutter/foundation.dart';

class AdConfig {
  AdConfig._();

  static const String appId = String.fromEnvironment(
    'ADMOB_APP_ID',
    defaultValue: '',
  );

  /// Production banner ad unit ID injected via --dart-define.
  static const String _bannerAdUnitIdProd = String.fromEnvironment(
    'ADMOB_BANNER_AD_UNIT_ID',
    defaultValue: '',
  );

  static String get bannerAdUnitId {
    if (kReleaseMode) {
      return _bannerAdUnitIdProd;
    }
    // Google-provided test banner unit ID — debug and profile modes
    return 'ca-app-pub-3940256099942544/6300978111';
  }
}
