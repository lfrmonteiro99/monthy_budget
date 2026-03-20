import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityStateSource {
  Stream<bool> get onStatusChange;
  Future<bool> checkConnectivity();
}

class ConnectivityService implements ConnectivityStateSource {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (!_statusController.isClosed) {
        _statusController.add(_convert(result));
      }
    });
  }

  final Connectivity _connectivity;
  final _statusController = StreamController<bool>.broadcast();
  StreamSubscription<ConnectivityResult>? _subscription;

  @override
  Stream<bool> get onStatusChange => _statusController.stream;

  @override
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return _convert(result);
  }

  bool _convert(ConnectivityResult result) =>
      result != ConnectivityResult.none &&
      result != ConnectivityResult.bluetooth;

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _statusController.close();
  }
}
