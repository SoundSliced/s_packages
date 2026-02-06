import 'package:flutter_test/flutter_test.dart';
import 'package:week_calendar/week_calendar.dart';

void main() {
  group('Weekday Enum Tests', () {
    test('Weekday enum should have 7 values', () {
      expect(Weekday.values.length, 7);
    });

    test('Weekday.monday should have value 1', () {
      expect(Weekday.monday.value, 1);
      expect(Weekday.monday.name, 'monday');
    });

    test('Weekday.tuesday should have value 2', () {
      expect(Weekday.tuesday.value, 2);
      expect(Weekday.tuesday.name, 'tuesday');
    });

    test('Weekday.wednesday should have value 3', () {
      expect(Weekday.wednesday.value, 3);
      expect(Weekday.wednesday.name, 'wednesday');
    });

    test('Weekday.thursday should have value 4', () {
      expect(Weekday.thursday.value, 4);
      expect(Weekday.thursday.name, 'thursday');
    });

    test('Weekday.friday should have value 5', () {
      expect(Weekday.friday.value, 5);
      expect(Weekday.friday.name, 'friday');
    });

    test('Weekday.saturday should have value 6', () {
      expect(Weekday.saturday.value, 6);
      expect(Weekday.saturday.name, 'saturday');
    });

    test('Weekday.sunday should have value 7', () {
      expect(Weekday.sunday.value, 7);
      expect(Weekday.sunday.name, 'sunday');
    });

    test('fromDateTime should convert correctly for all days', () {
      expect(Weekday.fromDateTime(1), equals(Weekday.monday));
      expect(Weekday.fromDateTime(2), equals(Weekday.tuesday));
      expect(Weekday.fromDateTime(3), equals(Weekday.wednesday));
      expect(Weekday.fromDateTime(4), equals(Weekday.thursday));
      expect(Weekday.fromDateTime(5), equals(Weekday.friday));
      expect(Weekday.fromDateTime(6), equals(Weekday.saturday));
      expect(Weekday.fromDateTime(7), equals(Weekday.sunday));
    });

    test('fromDateTime should match DateTime.weekday values', () {
      final monday = DateTime(2026, 1, 5); // Monday
      final tuesday = DateTime(2026, 1, 6); // Tuesday
      final wednesday = DateTime(2026, 1, 7); // Wednesday
      final thursday = DateTime(2026, 1, 8); // Thursday
      final friday = DateTime(2026, 1, 9); // Friday
      final saturday = DateTime(2026, 1, 10); // Saturday
      final sunday = DateTime(2026, 1, 11); // Sunday

      expect(Weekday.fromDateTime(monday.weekday), Weekday.monday);
      expect(Weekday.fromDateTime(tuesday.weekday), Weekday.tuesday);
      expect(Weekday.fromDateTime(wednesday.weekday), Weekday.wednesday);
      expect(Weekday.fromDateTime(thursday.weekday), Weekday.thursday);
      expect(Weekday.fromDateTime(friday.weekday), Weekday.friday);
      expect(Weekday.fromDateTime(saturday.weekday), Weekday.saturday);
      expect(Weekday.fromDateTime(sunday.weekday), Weekday.sunday);
    });

    test('Weekday values should be in correct order', () {
      final values = Weekday.values;
      expect(values[0], Weekday.monday);
      expect(values[1], Weekday.tuesday);
      expect(values[2], Weekday.wednesday);
      expect(values[3], Weekday.thursday);
      expect(values[4], Weekday.friday);
      expect(values[5], Weekday.saturday);
      expect(values[6], Weekday.sunday);
    });

    test('Weekday should follow ISO 8601 standard (Monday = 1)', () {
      // ISO 8601 specifies Monday as 1, Sunday as 7
      expect(Weekday.monday.value, 1);
      expect(Weekday.sunday.value, 7);
    });
  });

  group('WeekCalendarType Enum Tests', () {
    test('WeekCalendarType should have 4 values', () {
      expect(WeekCalendarType.values.length, 4);
    });

    test('WeekCalendarType should contain all expected types', () {
      expect(WeekCalendarType.values, contains(WeekCalendarType.standard));
      expect(WeekCalendarType.values, contains(WeekCalendarType.outlined));
      expect(WeekCalendarType.values, contains(WeekCalendarType.minimal));
      expect(WeekCalendarType.values, contains(WeekCalendarType.elevated));
    });

    test('WeekCalendarType names should be correct', () {
      expect(WeekCalendarType.standard.name, 'standard');
      expect(WeekCalendarType.outlined.name, 'outlined');
      expect(WeekCalendarType.minimal.name, 'minimal');
      expect(WeekCalendarType.elevated.name, 'elevated');
    });

    test('WeekCalendarType values should be in expected order', () {
      final values = WeekCalendarType.values;
      expect(values[0], WeekCalendarType.standard);
      expect(values[1], WeekCalendarType.outlined);
      expect(values[2], WeekCalendarType.minimal);
      expect(values[3], WeekCalendarType.elevated);
    });
  });
}
