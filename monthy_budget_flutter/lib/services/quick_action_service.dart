import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';

import '../navigation/app_route.dart';

/// Listens for incoming app links and converts them into typed app routes.
///
/// Deep links may arrive before the authenticated shell exists. In that case
/// the route is held until [init] attaches a handler from [AppHome].
class QuickActionService {
  QuickActionService({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  static final instance = QuickActionService();

  final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;
  void Function(AppRoute route)? _handler;
  AppRoute? _pendingRoute;
  bool _initialized = false;

  Future<void> init({required void Function(AppRoute route) onAction}) async {
    _handler = onAction;
    _dispatchPending();

    if (_initialized) return;
    _initialized = true;

    try {
      final initialUri = await _appLinks.getInitialLink();
      _queueRoute(AppRoute.fromUri(initialUri));
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }

    _subscription = _appLinks.uriLinkStream.listen(
      (uri) => _queueRoute(AppRoute.fromUri(uri)),
      onError: (_) {},
    );
  }

  void dispose() {
    _handler = null;
    _subscription?.cancel();
    _subscription = null;
    _initialized = false;
  }

  static AppRoute? routeFromUri(Uri? uri) => AppRoute.fromUri(uri);

  void _queueRoute(AppRoute? route) {
    if (route == null) return;
    if (_handler != null) {
      _handler!(route);
      return;
    }
    _pendingRoute = route;
  }

  void _dispatchPending() {
    if (_handler == null || _pendingRoute == null) return;
    _handler!(_pendingRoute!);
    _pendingRoute = null;
  }
}
