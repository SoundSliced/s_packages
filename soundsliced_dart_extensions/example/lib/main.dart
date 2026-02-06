import 'package:flutter/material.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';

// A minimal example showcasing several extensions.
// Run this inside a Flutter app's main() or copy snippets where needed.
void main() {
  // Duration shortcuts
  final d = 5.seconds + 2.minutes + 1.hours;
  debugPrint('Duration easy read: ${d.convertToEasyReadString()}');

  // DateTime rounding & conversion
  final now = DateTime.now();
  final nearest15 = now.toNearestMinute(nearestMinute: 15);
  debugPrint(
      'Rounded to 15 min: ${nearest15.convertToStringTime(showSeconds: true)}');

  // String capitalization
  final text = 'hello world. how are you? this is dart!';
  debugPrint(text.capitalizeFirstLetterOfEverySentence());

  // Safe list access
  final list = [1, 2, 3];
  debugPrint('Safe index 10 => ${list.safe[10]}');

  // JSON beautifier
  final raw = {'id': '123', 'payload': '{"value":42,"inner":"{\\"x\\":1}"}'};
  debugPrint('Beautified JSON:\n${raw.beautifiedJson}');

  // TimeOfDay utilities
  final time =
      const TimeOfDay(hour: 14, minute: 7).toNearestMinute(nearestMinute: 15);
  debugPrint('Time rounded => ${time.convertToStringTime()}');

  // EdgeInsets tuple & fluent chaining
  final tupleInsets = (5, 10, 15, 20)
      .leftPad
      .topPad
      .rightPad
      .bottomPad; // left=5 top=10 right=15 bottom=20
  final fluentInsets = EdgeInsets.all(12)
      .addToTop(4)
      .leftPad
      .rightPad; // copies first non-zero value
  debugPrint('Tuple insets: $tupleInsets | Fluent insets: $fluentInsets');

  // BorderRadius helper
  final radius = 8.topRad;
  debugPrint('BorderRadius topRad => $radius');

  // Finish
  debugPrint('Example completed.');
}
