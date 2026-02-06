import 'package:flutter/material.dart';

extension TimeOfDayExtension on TimeOfDay {
  /// Converts a [TimeOfDay] to a [DateTime].
  ///
  /// [date] - The date to use for the DateTime. Defaults to today if null.
  DateTime toDateTime({DateTime? date, bool isUtc = true}) {
    final baseDate = date ?? (isUtc ? DateTime.now().toUtc() : DateTime.now());
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      hour,
      minute,
    );
  }
}
