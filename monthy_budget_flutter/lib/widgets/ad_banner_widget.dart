import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart';
import '../services/analytics_service.dart';

class AdBannerWidget extends StatefulWidget {
  final bool showAd;

  const AdBannerWidget({super.key, required this.showAd});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  int? _lastWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.showAd) return;

    final width = MediaQuery.of(context).size.width.truncate();
    if (_lastWidth != width) {
      // First load or orientation changed — reload with new size
      _lastWidth = width;
      _reloadAd(width);
    }
  }

  @override
  void didUpdateWidget(AdBannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAd && !oldWidget.showAd) {
      final width = MediaQuery.of(context).size.width.truncate();
      _lastWidth = width;
      _reloadAd(width);
    } else if (!widget.showAd && oldWidget.showAd) {
      _disposeAd();
    }
  }

  void _disposeAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoading = false;
    if (mounted) setState(() => _isLoaded = false);
  }

  Future<void> _reloadAd(int width) async {
    if (_isLoading) return;
    _isLoading = true;

    // Dispose previous ad before loading new one
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;

    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );
    if (size == null || !mounted) {
      _isLoading = false;
      return;
    }

    final ad = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isLoading = false;
          unawaited(
            AnalyticsService.instance.trackEvent(
              'ad_impression',
              properties: {'format': 'adaptive_banner', 'width': width},
            ),
          );
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          _isLoading = false;
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
