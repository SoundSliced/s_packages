import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';

void main() {
  group('Duration Extensions', () {
    test('convertToEasyReadString formats duration correctly', () {
      expect(
          Duration(hours: 2, minutes: 30).convertToEasyReadString(), '2:30:00');
      expect(Duration(minutes: 45).convertToEasyReadString(), '45:00');
      expect(Duration(seconds: 30).convertToEasyReadString(), '30 sec');
    });

    test('convertToDateTime converts duration to DateTime', () {
      final duration = Duration(hours: 2, minutes: 30);
      final dateTime = duration.convertToDateTime();
      expect(dateTime.hour, 2);
      expect(dateTime.minute, 30);
    });
  });

  group('EdgeInsets Extensions', () {
    test('tuple extensions create EdgeInsets correctly', () {
      final padding1 = (10, 20).leftPad.rightPad;
      expect(padding1.left, 10);
      expect(padding1.right, 20);

      final padding2 = (5, 10, 15).leftPad.topPad.rightPad;
      expect(padding2.left, 5);
      expect(padding2.top, 10);
      expect(padding2.right, 15);
    });

    test('4-value tuple chaining order is respected', () {
      final padding = (4, 8, 12, 16).leftPad.topPad.rightPad.bottomPad;
      expect(padding.left, 4);
      expect(padding.top, 8);
      expect(padding.right, 12);
      expect(padding.bottom, 16);
    });
  });

  group('Basic Library Import', () {
    test('library can be imported without errors', () {
      // This test simply verifies the library imports successfully
      expect(true, true);
    });
  });

  group('SafeListAccessor', () {
    test('returns null for out-of-range index', () {
      final list = [1, 2, 3];
      expect(list.safe[10], isNull);
      expect(list.safe[1], 2);
    });
  });

  group('JSON Beautifier', () {
    test('beautifiedJson decodes embedded JSON', () {
      final raw = {
        'id': '123',
        'payload': '{"value":42,"inner":"{\\"x\\":1}"}'
      };
      final pretty = raw.beautifiedJson;
      // Should contain formatted value key and decoded inner structure
      expect(pretty.contains('"value"'), isTrue);
      expect(pretty.contains('"inner"'), isTrue);
    });

    test('decodeBeautifiedJsonMap parses nested JSON', () {
      final jsonString = '{"id":"123","payload":{"value":42,"inner":{"x":1}}}';
      final decoded = jsonString.decodeBeautifiedJsonMap;
      expect(decoded['id'], '123');
      expect(decoded['payload'], isA<Map<String, dynamic>>());
      expect((decoded['payload'] as Map<String, dynamic>)['value'], 42);
    });
  });

  group('TimeOfDay Extensions', () {
    test('toNearestMinute rounds correctly', () {
      final t = const TimeOfDay(hour: 14, minute: 7)
          .toNearestMinute(nearestMinute: 15);
      expect(t.hour, 14);
      expect(t.minute, 15);
    });

    test('subtractMinutes wraps before midnight', () {
      final t = const TimeOfDay(hour: 0, minute: 10).subtractMinutes(20);
      expect(t.hour, 23);
      expect(t.minute, 50);
    });
  });

  group('String capitalization', () {
    test('capitalizeFirstLetterOfEverySentence works', () {
      final input = 'hello world. how are you? this is dart!';
      final output = input.capitalizeFirstLetterOfEverySentence();
      expect(output, 'Hello world. How are you? This is dart!');
    });
  });
}
