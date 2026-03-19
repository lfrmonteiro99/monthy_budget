import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Tracks the current connectivity status and exposes a broadcast stream.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internals();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _statusController = StreamController<bool>.broadcast();

  ConnectivityService._internals() {
    _connectivity.onConnectivityChanged.listen((result) {
      _statusController.add(_convert(result));
    });
  }

  factory ConnectivityService() => _instance;

  Stream<bool> get onStatusChange => _statusController.stream;

  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return _convert(result);
  }

  bool _convert(ConnectivityResult result) =>
      result != ConnectivityResult.none && result != ConnectivityResult.bluetooth;

  void dispose() {
    _statusController.close();
  }
}
