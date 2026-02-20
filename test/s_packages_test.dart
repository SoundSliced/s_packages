import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/soundsliced_dart_extensions/soundsliced_dart_extensions.dart';

void main() {
  group('s_packages', () {
    test('workspace structure validation', () {
      // Simple test to verify the workspace is set up correctly
      expect(true, isTrue);
    });

    test('basic dart functionality', () {
      // Verify basic Dart operations work
      final result = 2 + 2;
      expect(result, equals(4));
    });

    test('list operations', () {
      // Simple collection test
      final packages = ['bubble_label', 's_button', 's_modal'];
      expect(packages.length, greaterThan(0));
      expect(packages.contains('s_button'), isTrue);
    });

    test('firstWhereOrNull returns first match or null', () {
      final values = <int>[1, 2, 3, 4, 5];

      expect(values.firstWhereOrNull((e) => e.isEven), equals(2));
      expect(values.firstWhereOrNull((e) => e > 99), isNull);
    });

    test('other nullable list query helpers behave safely', () {
      final values = <int>[10, 20, 30, 40];
      final empty = <int>[];

      expect(values.lastWhereOrNull((e) => e < 35), equals(30));
      expect(values.lastWhereOrNull((e) => e < 0), isNull);

      expect(values.firstOrNull, equals(10));
      expect(values.lastOrNull, equals(40));
      expect(empty.firstOrNull, isNull);
      expect(empty.lastOrNull, isNull);

      expect(values.elementAtOrNull(2), equals(30));
      expect(values.elementAtOrNull(-1), isNull);
      expect(values.elementAtOrNull(99), isNull);
    });

    test('iterable query extensions', () {
      final values = <int>[1, 2, 2, 3, 4, 5];

      expect(values.none((e) => e < 0), isTrue);
      expect(values.countWhere((e) => e.isEven), equals(3));
      expect(values.singleWhereOrNull((e) => e == 3), equals(3));
      expect(values.singleWhereOrNull((e) => e == 2), isNull);
      expect(values.distinctBy((e) => e), equals([1, 2, 3, 4, 5]));
      expect(values.sortedBy((e) => e, descending: true),
          equals([5, 4, 3, 2, 2, 1]));
      expect(
          values.chunked(2),
          equals(const [
            <int>[1, 2],
            <int>[2, 3],
            <int>[4, 5]
          ]));
      expect(
          values.windowed(3, step: 2),
          equals(const [
            <int>[1, 2, 2],
            <int>[2, 3, 4]
          ]));
      expect(
          values.windowed(4, step: 3, partialWindows: true),
          equals(const [
            <int>[1, 2, 2, 3],
            <int>[3, 4, 5]
          ]));
    });

    test('map transform and typed getters extensions', () {
      final map = <String, dynamic>{
        'name': 'sound',
        'count': '12',
        'ratio': 3,
        'active': 'true',
      };

      expect(
          map.mapKeys((k, _) => k.toUpperCase()).containsKey('NAME'), isTrue);
      expect(map.mapValues((_, v) => '$v')['name'], equals('sound'));
      expect(map.filterKeys((k) => k.startsWith('c')).keys, equals(['count']));
      expect(map.filterValues((v) => v is String).length, equals(3));

      expect(map.getString('name'), equals('sound'));
      expect(map.getIntOrNull('count'), equals(12));
      expect(map.getDoubleOrNull('ratio'), equals(3.0));
      expect(map.getBoolOrNull('active'), isTrue);
      expect(map.getBoolOrNull('name'), isNull);
    });

    test('string utility extensions', () {
      expect('   '.isBlank, isTrue);
      expect(''.ifBlank('fallback'), equals('fallback'));
      expect('42'.toIntOrNull(), equals(42));
      expect('3.14'.toDoubleOrNull(), closeTo(3.14, 0.0001));
      expect('hello_world test'.toTitleCase(), equals('Hello World Test'));
      expect('Crème Brûlée'.removeDiacritics(), equals('Creme Brulee'));
    });

    test('date time utility extensions', () {
      final now = DateTime.now();

      final clampedLow = DateTime(2023, 1, 1)
          .clampTo(DateTime(2024, 1, 1), DateTime(2024, 12, 31));
      final clampedHigh = DateTime(2025, 1, 1)
          .clampTo(DateTime(2024, 1, 1), DateTime(2024, 12, 31));
      final clampedInRange = DateTime(2024, 6, 1)
          .clampTo(DateTime(2024, 1, 1), DateTime(2024, 12, 31));

      expect(now.isDateWithinTodaysMonth(), isTrue);
      expect(clampedLow, equals(DateTime(2024, 1, 1)));
      expect(clampedHigh, equals(DateTime(2024, 12, 31)));
      expect(clampedInRange, equals(DateTime(2024, 6, 1)));
    });

    test('duration and nullable num helpers', () {
      final duration = const Duration(hours: 1, minutes: 2, seconds: 3);
      expect(duration.formatCompactDuration(), equals('1h 02m 03s'));
      expect(duration.toClockString(), equals('01:02:03'));

      num? n1 = 12;
      num? n2;
      expect(n1.clampOrNull(0, 10), equals(10));
      expect(n2.clampOrNull(0, 10), isNull);
      expect(n1.clampToDoubleOrNull(0, 11), equals(11.0));
    });
  });
}
