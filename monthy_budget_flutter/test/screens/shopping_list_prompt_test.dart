import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Post-shopping prompt logic', () {
    test('all items checked returns true', () {
      final items = [
        _FakeItem(checked: true),
        _FakeItem(checked: true),
        _FakeItem(checked: true),
      ];
      expect(items.every((i) => i.checked), isTrue);
    });

    test('some items unchecked returns false', () {
      final items = [
        _FakeItem(checked: true),
        _FakeItem(checked: false),
      ];
      expect(items.every((i) => i.checked), isFalse);
    });

    test('empty list returns false for showing prompt', () {
      final items = <_FakeItem>[];
      expect(items.isNotEmpty && items.every((i) => i.checked), isFalse);
    });
  });
}

class _FakeItem {
  final bool checked;
  _FakeItem({required this.checked});
}
