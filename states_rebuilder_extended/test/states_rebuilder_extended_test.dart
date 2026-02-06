import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder_extended/states_rebuilder_extended.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StateRebuilderExtension', () {
    test('nullable update enforces explicit generic & works', () {
      final injected = MyNull.injectDisposable<int?>();
      injected.update<int?>((s) => (s ?? 0) + 1);
      expect(injected.state, 1);
      injected.update<int?>((s) => (s ?? 0) + 5);
      expect(injected.state, 6);
    });

    test('non-nullable update works', () {
      final injected = 0.inject<int>();
      injected.update<int>((s) => s + 2);
      expect(injected.state, 2);
    });

    test('update with tag stores tag', () {
      final injected = 0.inject<int>();
      injected.update<int>((s) => s + 1, tag: 'test-tag');
      expect(injected.state, 1);
    });
  });

  group('BooleanExtensions', () {
    test('boolean toggle nullable - null to true', () {
      final flag = MyNull.injectDisposable<bool?>();
      expect(flag.state, null);
      flag.toggle();
      expect(flag.state, true);
    });

    test('boolean toggle nullable - alternates', () {
      final flag = MyNull.injectDisposable<bool?>();
      flag.toggle();
      expect(flag.state, true);
      flag.toggle();
      expect(flag.state, false);
      flag.toggle();
      expect(flag.state, true);
    });

    test('boolean toggle non-nullable', () {
      final flag = false.inject<bool>();
      expect(flag.state, false);
      flag.toggle();
      expect(flag.state, true);
      flag.toggle();
      expect(flag.state, false);
    });

    test('boolean toggle with tag', () {
      final flag = false.inject<bool>();
      flag.toggle(tag: 'toggle-tag');
      expect(flag.state, true);
    });
  });

  group('MultipleStateRebuilderExtension', () {
    test('updateAll updates all injected instances', () {
      final a = 1.inject<int>();
      final b = 2.inject<int>();
      final c = 3.inject<int>();

      [a, b, c].updateAll<int>((v) => v + 10);

      expect(a.state, 11);
      expect(b.state, 12);
      expect(c.state, 13);
    });

    test('update with index updates specific instance', () {
      final a = 1.inject<int>();
      final b = 2.inject<int>();
      final c = 3.inject<int>();

      [a, b, c].update<int>((v) => v + 100, index: 1);

      expect(a.state, 1);
      expect(b.state, 102);
      expect(c.state, 3);
    });

    test('update with invalid index throws', () {
      final a = 1.inject<int>();
      final b = 2.inject<int>();

      expect(
        () => [a, b].update<int>((v) => v + 1, index: 5),
        throwsRangeError,
      );
    });

    test('notify on empty list throws', () {
      final a = 1.inject<int>();
      final emptyList = [a].where((e) => false).toList();
      expect(
        () => emptyList.notify(),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('InjectExtension', () {
    test('inject creates Injected instance', () {
      final value = 42.inject<int>();
      expect(value.state, 42);
    });

    test('injectDisposable creates auto-dispose Injected', () {
      final value = 'test'.injectDisposable();
      expect(value.state, 'test');
    });
  });

  group('MyNull', () {
    test('inject returns null initially', () {
      final s = MyNull.inject<String?>();
      expect(s.state, isNull);
    });

    test('injectDisposable returns null initially', () {
      final s = MyNull.injectDisposable<String?>();
      expect(s.state, isNull);
    });

    test('can update from null to value', () {
      final s = MyNull.injectDisposable<int?>();
      expect(s.state, null);
      s.update<int?>((v) => 42);
      expect(s.state, 42);
    });
  });

  group('SafeRefresh', () {
    test('safeRefresh does not throw on valid injected', () {
      final injected = 0.inject<int>();
      expect(() => injected.safeRefresh(), returnsNormally);
    });
  });
}
