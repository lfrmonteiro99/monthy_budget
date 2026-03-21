import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/services/connectivity_service.dart';

/// Tests ConnectivityStateSource contract via a minimal fake.
/// The real ConnectivityService wraps connectivity_plus which cannot be
/// unit-tested without a plugin host; the convert logic is covered
/// indirectly via integration tests in sync_service_test.dart.
class _FakeConnectivitySource implements ConnectivityStateSource {
  bool _online;
  final _controller = StreamController<bool>.broadcast();

  _FakeConnectivitySource({bool online = true}) : _online = online;

  @override
  Stream<bool> get onStatusChange => _controller.stream;

  @override
  Future<bool> checkConnectivity() async => _online;

  void setOnline(bool v) {
    _online = v;
    _controller.add(v);
  }

  Future<void> dispose() async => _controller.close();
}

void main() {
  group('ConnectivityStateSource contract', () {
    late _FakeConnectivitySource source;

    setUp(() {
      source = _FakeConnectivitySource(online: true);
    });

    tearDown(() async {
      await source.dispose();
    });

    test('checkConnectivity returns true when online', () async {
      expect(await source.checkConnectivity(), true);
    });

    test('checkConnectivity returns false when offline', () async {
      source.setOnline(false);
      expect(await source.checkConnectivity(), false);
    });

    test('onStatusChange emits transitions', () async {
      final results = <bool>[];
      final sub = source.onStatusChange.listen(results.add);

      source.setOnline(false);
      source.setOnline(true);
      source.setOnline(false);

      await Future.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(results, [false, true, false]);
    });

    test('multiple listeners receive same events', () async {
      final r1 = <bool>[];
      final r2 = <bool>[];
      final s1 = source.onStatusChange.listen(r1.add);
      final s2 = source.onStatusChange.listen(r2.add);

      source.setOnline(false);
      await Future.delayed(const Duration(milliseconds: 50));

      await s1.cancel();
      await s2.cancel();

      expect(r1, [false]);
      expect(r2, [false]);
    });
  });
}
