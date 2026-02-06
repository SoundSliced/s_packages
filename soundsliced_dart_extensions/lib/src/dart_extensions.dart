library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart' as collection;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:xid/xid.dart';

//*******************************************  */

/// Recursively processes a value to decode any embedded JSON strings.
/// Handles objects, arrays, and nested structures.
dynamic _processValue(dynamic value) {
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      try {
        final decoded = jsonDecode(value);
        return _processValue(decoded); // Recurse to handle nested JSON
      } catch (e) {
        // If not valid JSON, keep as string
        debugPrint("JSON Beautifier | _processValue | Error decoding JSON: $e");
        return value;
      }
    }
    return value;
  } else if (value is Map<String, dynamic>) {
    return value.map((key, val) => MapEntry(key, _processValue(val)));
  } else if (value is List) {
    return value.map(_processValue).toList();
  } else {
    return value;
  }
}

//*******************************************  */

extension BeautifiedJson on Map<String, dynamic> {
  /// Returns a processed map with decoded JSON strings.
  Map<String, dynamic> get _processedMap =>
      _processValue(this) as Map<String, dynamic>;

  /// Returns a beautified JSON string representation.
  String get beautifiedJson {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(_processedMap);
  }
}

//*******************************************  */

extension ListJsonBeautifier on List<Map<String, dynamic>> {
  /// Returns a beautified JSON string representation of the list.
  String get beautifiedJson {
    final processedList = map((map) => map._processedMap).toList();
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(processedList);
  }
}

//*******************************************  */

extension DecodeBeautifiedJson on String {
  /// Decodes a JSON string and returns the processed Map with embedded JSON decoded.
  Map<String, dynamic> get decodeBeautifiedJsonMap {
    try {
      final decoded = jsonDecode(this);
      return _processValue(decoded) as Map<String, dynamic>;
    } catch (e) {
      debugPrint("JSON Beautifier | decodeBeautifiedJsonMap | Error: $e");
      return {};
    }
  }

  /// Decodes a JSON string and returns the processed List of Maps with embedded JSON decoded.
  List<Map<String, dynamic>> get decodeBeautifiedJsonList {
    try {
      final decoded = jsonDecode(this);
      final processed = _processValue(decoded);
      if (processed is List) {
        return processed.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("JSON Beautifier | decodeBeautifiedJsonList | Error: $e");
      return [];
    }
  }
}

//*******************************************  */

//copied and tweaked from:
//https://pub.dev/packages/easy_duration

/// Return Duration base on int input
///
/// ex: 1.seconds -> Duration(seconds: 1);
extension MyEasyDurationInt on int {
  /// Returns current int in Duration of seconds
  Duration get seconds {
    return Duration(seconds: this);
  }

  /// Short-hand for [seconds]
  Duration get sec {
    return Duration(seconds: this);
  }

  /// Return current int in Duration of miliseconds
  Duration get miliseconds {
    return Duration(milliseconds: this);
  }

  /// Short-hand for miliseconds
  Duration get milSec {
    return Duration(milliseconds: this);
  }

  /// Return curretn int in  Duration of microseconds
  Duration get microseconds {
    return Duration(microseconds: this);
  }

  /// Short-hand for microseconds
  Duration get micSec {
    return Duration(microseconds: this);
  }

  /// Return current int in Duration of minutes
  Duration get minutes {
    return Duration(minutes: this);
  }

  /// Short-hand for minutes
  Duration get min {
    return Duration(minutes: this);
  }

  /// Return current int in Duration of hours
  Duration get hours {
    return Duration(hours: this);
  }

  /// Short-hand for hours
  Duration get hr {
    return Duration(hours: this);
  }

  /// Return current int in Duration of days
  Duration get day {
    return Duration(days: this);
  }

  /// Short-hand for days
  Duration get dd {
    return Duration(days: this);
  }

  /// Return current int in Duration of month (30 days / month)
  Duration get months {
    return Duration(days: 30 * this);
  }

  /// Short-hand for months
  Duration get mm {
    return Duration(days: 30 * this);
  }

  /// Return current int in Duration of years (356 days/ year)
  Duration get years {
    return Duration(days: 365 * this);
  }

  /// Short-hand for years
  Duration get yy {
    return Duration(days: 365 * this);
  }

  /// Return current int in Duration of weeks (7 days/ week)
  Duration get weeks {
    return Duration(days: 7 * this);
  }

  /// Short-hand for weeks
  Duration get wk {
    return Duration(days: 7 * this);
  }

  /// Return current int in Duration of circles (You decide circle length)
  ///
  /// ex: 2.circles(2.s) means -> 2 cicles of 2s = 4s
  Duration circles(Duration circleLength) {
    final inUs = circleLength.inMicroseconds;
    return (this * inUs).micSec;
  }

  //convert month index to String
  String convertToMonthString() {
    if (this == 01) {
      return 'JAN';
    } else if (this == 02) {
      return 'FEB';
    } else if (this == 03) {
      return 'MAR';
    } else if (this == 04) {
      return 'APR';
    } else if (this == 05) {
      return 'MAY';
    } else if (this == 06) {
      return 'JUN';
    } else if (this == 07) {
      return 'JUL';
    } else if (this == 08) {
      return 'AUG';
    } else if (this == 09) {
      return 'SEP';
    } else if (this == 10) {
      return 'OCT';
    } else if (this == 11) {
      return 'NOV';
    } else if (this == 12) {
      return 'DEC';
    }
    return '';
  }
}

extension EasyDurationDouble on double {
  /// Returns current int in Duration of seconds
  ///
  /// It will be convert to ms first
  ///
  /// 1.5s --> 1500ms
  Duration get seconds {
    final ms = (this * 1000).floor();
    return Duration(milliseconds: ms);
  }

  /// Short-hand for [seconds]
  Duration get sec {
    final ms = (this * 1000).floor();
    return Duration(milliseconds: ms);
  }

  /// Return current int in Duration of miliseconds
  Duration get miliseconds {
    final us = (this * 1000).floor();
    return Duration(microseconds: us);
  }

  /// Short-hand for miliseconds
  Duration get milSec {
    final us = (this * 1000).floor();
    return Duration(microseconds: us);
  }

  /// Return curretn int in  Duration of microseconds
  ///
  /// This will be truncate()
  ///
  /// ex: 1.2 ms --> 1 ms
  ///
  /// 1.7ms --> 1ms
  Duration get microseconds {
    final us = toInt();
    return Duration(microseconds: us);
  }

  /// Short-hand for microseconds
  Duration get micSec {
    final us = toInt();
    return Duration(microseconds: us);
  }

  /// Return current int in Duration of minutes
  ///
  /// It will be convert to second the truncate()
  ///
  /// 1.5m -> 90s = 90s
  ///
  /// 1.2m -> 72s = 72s
  ///
  /// 1.02m -> 61.2s = 61s
  Duration get minutes {
    final secs = (this * 60).toInt();
    return Duration(seconds: secs);
  }

  /// Short-hand for minutes
  Duration get min {
    final secs = (this * 60).toInt();
    return Duration(seconds: secs);
  }

  /// Return current int in Duration of hours
  Duration get hours {
    final mins = (this * 60).toInt();
    return Duration(minutes: mins);
  }

  /// Short-hand for hours
  Duration get hr {
    final mins = (this * 60).toInt();
    return Duration(minutes: mins);
  }

  /// Return current int in Duration of days
  Duration get days {
    final hours = (this * 24).toInt();
    return Duration(hours: hours);
  }

  /// Short-hand for days
  Duration get dd {
    final hours = (this * 24).toInt();
    return Duration(hours: hours);
  }

  /// Return current int in Duration of month (30 days / month)
  Duration get months {
    final days = (this * 30).toInt();
    return Duration(days: days);
  }

  /// Short-hand for months
  Duration get mm {
    final days = (this * 30).toInt();
    return Duration(days: days);
  }

  /// Return current int in Duration of years (356 days/ year)
  Duration get years {
    return Duration(days: (365 * this).toInt());
  }

  /// Short-hand for years
  Duration get yy {
    return Duration(days: (365 * this).toInt());
  }

  /// Return current int in Duration of weeks (7 days/ week)
  Duration get weeks {
    return Duration(days: (7 * this).toInt());
  }

  /// Short-hand for weeks
  Duration get wk {
    return Duration(days: (7 * this).toInt());
  }

  /// Return current int in Duration of circles (You decide circle length)
  ///
  /// ex: 2.circles(2.s) means -> 2 cicles of 2s = 4s
  Duration circles(Duration circleLength) {
    final inUs = circleLength.inMicroseconds;
    return (this * inUs).milSec;
  }
}

/// Return the day after [currentDate]
DateTime theDayAfter(DateTime currentDate) {
  return currentDate.add(1.dd);
}

/// Return the day before [currentDate]
DateTime theDayBefore(DateTime currentDate) {
  return currentDate.subtract(1.dd);
}

//********************************************* */

//https://stackoverflow.com/questions/54775097/formatting-a-duration-like-hhmmss
//https://stackoverflow.com/questions/54852585/how-to-convert-a-duration-like-string-to-a-real-duration-in-flutter
//https://stackoverflow.com/questions/68679539/string-is-not-a-subtype-of-duration-in-flutter?noredirect=1&lq=1
//https://stackoverflow.com/questions/68682573/flutter-dart-format-duration-to-show-just-minutes-seconds-and-milliseconds?noredirect=1&lq=1

//Extension to convert Duration to DateTime
extension DurationExtensions<dynamics extends Duration> on Duration {
//extension to convert a Duration to DateTime type
  DateTime convertToDateTime() {
    int hr = inHours > 0 ? inHours : 0,
        min = inMinutes.remainder(60),
        sec = inSeconds.remainder(60),
        milSec = inMilliseconds.remainder(1000);

    return DateTime(0, 0, 0, hr, min, sec, milSec, 0);
  }

//converts a Duration to a String '## sec', or '##:##', or '##:##:##' as appropriate
  String convertToEasyReadString() {
    String hours = inHours.toString().padLeft(0, '2'),
        minutes = inMinutes.remainder(60).toString().padLeft(2, '0'),
        seconds = inSeconds.remainder(60).toString().padLeft(2, '0');

    if (inHours == 0) {
      if (inMinutes == 0) {
        return "$seconds sec";
      } else {
        return "$minutes:$seconds";
      }
    } else {
      return "$hours:$minutes:$seconds";
    }
  }

  double convertTimeIntoHourDecimal([int decimalPoint = 1]) {
    return (inMinutes / 60).roundDoubleToDecimalPlace(decimalPoint);
  }
}

//Extension to convert Duration to DateTime
extension DurationExtensions2<dynamics extends Duration?> on Duration? {
//extension to convert a Duration to DateTime type
  DateTime? convertToDateTime() {
    if (this != null) {
      int hr = this!.inHours > 0 ? this!.inHours : 0,
          min = this!.inMinutes.remainder(60),
          sec = this!.inSeconds.remainder(60),
          milSec = this!.inMilliseconds.remainder(1000);

      return DateTime(0, 0, 0, hr, min, sec, milSec, 0);
    } else {
      debugPrint("the Duration to convert to DateTime is NULL");
      return null;
    }
  }

//converts a Duration to a String '## sec', or '##:##', or '##:##:##' as appropriate
  String convertToString() {
    if (this != null) {
      String hours = this!.inHours.toString().padLeft(0, '2'),
          minutes = this!.inMinutes.remainder(60).toString().padLeft(2, '0'),
          seconds = this!.inSeconds.remainder(60).toString().padLeft(2, '0');

      if (this!.inHours == 0) {
        if (this!.inMinutes == 0) {
          return "$seconds sec";
        } else {
          return "$minutes:$seconds";
        }
      } else {
        return "$hours:$minutes:$seconds";
      }
    } else {
      debugPrint("the Duration to convert to DateTime is NULL");
      return "Null Duration";
    }
  }

  double convertTimeIntoDecimalOfHour([int decimalPoint = 1]) {
    if (this != null) {
      return (this!.inMinutes / 60).roundDoubleToDecimalPlace(decimalPoint);
    }
    return 0.0;
  }
}

//*********************************************** */

//Extension to add Material Widget when needed
extension DateTimeExtensions<dynamics extends DateTime> on DateTime {
  bool isDateWithinTodaysMonth() =>
      eqvMonth(DateTime.now().toUtc()) && eqvYear(DateTime.now().toUtc());

//extension to convert a RangeSlider Duration to a BetterPlayer Duration format
  Duration convertToDuration() {
    int hr = hour > 0 ? hour : 0,
        min = minute.remainder(60),
        sec = second.remainder(60),
        milSec = millisecond.remainder(1000);

    return Duration(
      hours: hr,
      minutes: min,
      seconds: sec,
      milliseconds: milSec,
    );
  }

  //extension to convert a RangeSlider DateTime to a formated String
  String convertSliderDateTimeToString() {
    int hr = hour > 0 ? hour : 0,
        min = minute.remainder(60),
        sec = second.remainder(60),
        milSec = millisecond.remainder(1000);

    return "$hr:$min:$sec.$milSec";
  }

  String convertToStringTime(
      {bool showSeconds = false,
      bool showUtcSymbol = false,
      bool preferUtcSymbolThanZ = false,
      bool showSeparatorSymbol = true}) {
    String separatorSymbol() => showSeparatorSymbol ? ':' : '';

    String hourString = hour == 0
            ? "00"
            : hour < 10
                ? "0$hour"
                : "$hour",
        minString = minute == 0
            ? "00"
            : minute < 10
                ? "0$minute"
                : "$minute",
        secString = second == 0
            ? "00"
            : second < 10
                ? "0$second"
                : "$second";
    return showSeconds
        ? "$hourString${separatorSymbol()}$minString${separatorSymbol()}$secString${showUtcSymbol ? preferUtcSymbolThanZ ? ' UTC' : ' z' : ''}"
        : "$hourString${separatorSymbol()}$minString${showUtcSymbol ? preferUtcSymbolThanZ ? ' UTC' : ' z' : ''}";
  }

  double convertTimeIntoDecimalOfHour([int decimalPoint = 1]) {
    return (hour + minute / 60).roundDoubleToDecimalPlace(decimalPoint);
  }

//https://copyprogramming.com/howto/how-to-round-up-the-date-time-nearest-to-30-min-interval-in-dart-flutter
  DateTime toNearestMinute(
      {int nearestMinute = 5, bool isroundDownTo = false, bool isUTC = true}) {
    final double ticksPer5Minutes = nearestMinute * 60000000;
    final double ticks = microsecondsSinceEpoch.toDouble();
    final int roundedTicks = isroundDownTo == true
        ? (ticks / ticksPer5Minutes).truncateToDouble().toInt() *
            ticksPer5Minutes.toInt()
        : (ticks / ticksPer5Minutes).round() * ticksPer5Minutes.toInt();

    // debugPrint("toNearestMinute | ${DateTime.fromMicrosecondsSinceEpoch(roundedTicks, isUtc: true)}");

    return DateTime.fromMicrosecondsSinceEpoch(roundedTicks, isUtc: isUTC);
  }

//https://www.appsloveworld.com/flutter/100/16/how-to-round-time-to-the-nearest-quarter-hour-in-dart-and-flutter
  DateTime roundDown(
      {Duration durationToRoundDown = const Duration(minutes: 5),
      bool isUTC = true}) {
    DateTime roundedDown = DateTime.fromMillisecondsSinceEpoch(
        millisecondsSinceEpoch -
            millisecondsSinceEpoch % durationToRoundDown.inMilliseconds,
        isUtc: isUTC);

    // debugPrint("roundDown | $roundedDown");

    return roundedDown;
  }

  //convert month index to String
  String convertToMonthString() {
    if (month == 01) {
      return 'JAN';
    } else if (month == 02) {
      return 'FEB';
    } else if (month == 03) {
      return 'MAR';
    } else if (month == 04) {
      return 'APR';
    } else if (month == 05) {
      return 'MAY';
    } else if (month == 06) {
      return 'JUN';
    } else if (month == 07) {
      return 'JUL';
    } else if (month == 08) {
      return 'AUG';
    } else if (month == 09) {
      return 'SEP';
    } else if (month == 10) {
      return 'OCT';
    } else if (month == 11) {
      return 'NOV';
    }
    return 'DEC';
  }

  String toAtcDateString(
      {bool atcFormat = true,
      bool withSeparators = true,
      String separator = "/"}) {
    if (atcFormat) {
      return DateFormat('yyyy${separator}MM${separator}dd').format(this);
    }

    //else
    return DateFormat('dd${separator}MM${separator}yyyy').format(this);
  }

  String getDayName() {
    final DateFormat formatter = DateFormat('EEE');
    final String dayName = formatter.format(this);
    return dayName;
  }

  DateTime convertToDate({bool isUtc = true, DateTime? date}) {
    DateTime convertedDate = date ?? this;
    // First create a date-only version (midnight) in local time to avoid day shift
    DateTime localMidnight = DateTime(
      convertedDate.year,
      convertedDate.month,
      convertedDate.day,
    );

    // Convert to UTC by default, but preserve the same date
    // (not using toUtc() directly to avoid timezone shifts at midnight)
    if (isUtc) {
      return DateTime.utc(
        localMidnight.year,
        localMidnight.month,
        localMidnight.day,
      );
    }

    return localMidnight;
  }

  DateTime adjustTimeToDateHourAndMinutesOnly(
      {bool isUtc = true, DateTime? date}) {
    DateTime convertedDate = date ?? this;
    if (isUtc) {
      convertedDate = convertedDate.toUtc();
    }

    return convertedDate.copyWith(
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
  }

  DateTime adjustTimeToDateHourOnly({bool isUtc = true, DateTime? date}) {
    DateTime convertedDate = date ?? this;
    if (isUtc) {
      convertedDate = convertedDate.toUtc();
    }

    return convertedDate.copyWith(
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
  }
}

//********************************************* */

extension ListOfDateTimeExtensions on List<DateTime> {
  List<String> convertToStringList() {
    List<String> stringList = [];
    for (var element in this) {
      stringList.add(element.convertToStringTime());
    }
    return stringList;
  }
}

extension StringTimeToDateTime on String {
  DateTime convertHHMMTimeStringToDateTime(DateTime? dateTheTimeIsBasedOn) {
    final trimmed = trim();
    final parts = trimmed.split(':');
    if (parts.length != 2) {
      throw const FormatException('Unrecognized date format');
    }
    bool isNumeric(String s) =>
        s.isNotEmpty && s.codeUnits.every((c) => c >= 48 && c <= 57);
    if (!isNumeric(parts[0]) ||
        !isNumeric(parts[1]) ||
        parts[0].length > 2 ||
        parts[1].length > 2) {
      throw const FormatException('Unrecognized date format');
    }
    final int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);

    if (dateTheTimeIsBasedOn != null) {
      return dateTheTimeIsBasedOn.copyWith(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        microsecond: 0,
        isUtc: true,
      );
    }

    //else, return the time in DateTime based on now's date
    return DateTime.now().toUtc().copyWith(
          hour: hour,
          minute: minute,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
  }
}

//********************************************* */

//Extension for nullable DateTime objects to safely handle difference operation
extension NullableDateTimeExtensions on DateTime? {
  /// Safely calculates the difference between two nullable DateTime objects
  /// Returns null if either this or other is null, otherwise returns the Duration difference
  Duration? differenceTo(DateTime? other) {
    if (this != null && other != null) {
      return this!.difference(other);
    }
    return null;
  }

  /// Safely calculates the difference between two nullable DateTime objects as TimeOfDay
  /// Returns null if either this or other is null, otherwise returns the TimeOfDay difference
  TimeOfDay? differenceToTimeOfDay(DateTime? other) {
    if (this != null && other != null) {
      final duration = this!.difference(other);
      final totalMinutes = duration.inMinutes
          .abs(); // Use absolute value to handle negative differences
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return TimeOfDay(hour: hours, minute: minutes);
    }
    return null;
  }
}

//Extension for non-null DateTime objects to handle nullable DateTime parameter in difference method
extension DateTimeNullableParameterExtensions on DateTime {
  /// Safely calculates the difference with a nullable DateTime
  /// Returns null if other is null, otherwise returns the Duration difference
  Duration? differenceWith(DateTime? other) {
    if (other != null) {
      return difference(other);
    }
    return null;
  }

  /// Safely calculates the difference with a nullable DateTime as TimeOfDay
  /// Returns null if other is null, otherwise returns the TimeOfDay difference
  TimeOfDay? differenceWithAsTimeOfDay(DateTime? other) {
    if (other != null) {
      final duration = difference(other);
      final totalMinutes = duration.inMinutes
          .abs(); // Use absolute value to handle negative differences
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return TimeOfDay(hour: hours, minute: minutes);
    }
    return null;
  }
}

//********************************************* */

//extension to get the value of a map at a given index
extension GetByKeyIndex<K, V> on Map<K, V> {
  /// Returns the value at the given zero-based [index] in iteration order.
  /// Throws if the index is out of range.
  V elementAtIntIndex(int index) => values.elementAt(index);
}

//********************************************* */

//extension to Sort a list of Strings in alphabetical or numerical order
extension AlphaNumericSortingListOfString on List<String> {
  List<String> sortInAlphaNumericalOrder() {
    //https://stackoverflow.com/questions/61434038/is-there-a-way-to-sort-string-lists-by-numbers-inside-of-the-strings
    sort(collection.compareNatural);
    return this;
  }
}

//****************************** */

extension ExtraDoubleExtensions on double {
  double roundDoubleToDecimalPlace([int decimalPlaceToRoundTo = 0]) {
    double mod = pow(10.0, decimalPlaceToRoundTo) as double;
    return ((this * mod).round().toDouble() / mod);
  }

  double degreeToRadiansAngle() => this * pi / 180;
}

//********************************* */

extension ExtraInteExtensions on int {
  double degreeToRadiansAngle() => this * pi / 180;
}

//********************************* */

extension ToggleExtension on bool {
  bool toggle() => !this;
}

//********************************** */

extension StringExtensions on String {
  bool parseBool() {
    if (toLowerCase() == 'true') {
      return true;
    } else if (toLowerCase() == 'false') {
      return false;
    }

    throw '"$this" can not be parsed to boolean.';
  }

  /// Capitalizes the first letter of every sentence
  /// Sentences are determined by periods (.), exclamation marks (!), and question marks (?)
  String capitalizeFirstLetterOfEverySentence() {
    if (isEmpty) return this;

    StringBuffer result = StringBuffer();
    bool capitalizeNext = true;

    bool isAsciiLetter(String ch) {
      if (ch.length != 1) return false;
      final int code = ch.codeUnitAt(0);
      return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
    }

    for (int i = 0; i < length; i++) {
      String char = this[i];

      if (char == '.' || char == '!' || char == '?') {
        result.write(char);
        capitalizeNext = true;
      } else if (capitalizeNext && isAsciiLetter(char)) {
        result.write(char.toUpperCase());
        capitalizeNext = false;
      } else {
        result.write(char);
        if (char.trim().isNotEmpty && !isAsciiLetter(char)) {
          // keep capitalizeNext unchanged for whitespace; nothing needed
        }
      }
    }

    return result.toString();
  }

  // Helper method to parse a list of strings from a String value
  List<String> convertToListString() {
    //if the String is only "[]" or empty, return an empty list
    if (this == '[]' || isEmpty) {
      return [];
    }

    //first check if the String is a valid list format
    if (!startsWith('[') || !endsWith(']')) {
      throw FormatException(
          'StringExtensions.convertToListString() | String is not in a valid list format: $this');
    }

    //otherwise, remove the first and last characters (the "[" and "]" characters)
    //and split the String by the ", " characters
    //and return the list of Strings
    return substring(1, length - 1).split(', ');
  }
}

//********************************** */

//extension which make a list of chunks of specific number of items, of an original list
//https://stackoverflow.com/questions/22274033/how-do-i-split-or-chunk-a-list-into-equal-parts-with-dart
//eg. var letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g'];
//The output is: [[a, b], [c, d], [e, f], [g]]

extension ListChunk<T> on List<T> {
  List<List<T>> splitInChunks(int chunkSize) => [
        for (var i = 0; i < length; i += chunkSize)
          [for (var j = 0; j < chunkSize && i + j < length; j++) this[i + j]]
      ];
}

//********************************** */

//https://stackoverflow.com/questions/58360989/programmatically-lighten-or-darken-a-hex-color-in-dart
extension ColorExtensions on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}

//********************************** */

extension OffsetExtensions on Offset {
  double distanceTo(Offset offset) {
    return sqrt(pow(offset.dx - dx, 2) + pow(offset.dy - dy, 2));
  }

  double distanceFrom(Offset offset) {
    return sqrt(pow(dx - offset.dx, 2) + pow(dy - offset.dy, 2));
  }

  bool isInDirection(Offset other, Offset direction, [int count = 1]) {
    final diff = other - this;
    final normalized = direction / direction.distance;
    return count == 1
        ? diff == normalized
        : diff.distance <= normalized.distance * count;
  }
}

//********************************** */

//extension on Map type, to convert a Map to a List
extension OnMapExtensions on Map<dynamic, dynamic> {
  //https://www.bezkoder.com/dart-convert-list-map/#Convert_Map_to_List_in_DartFlutter
  List<dynamic> convertMapToList() {
    return entries.map((e) => MapEntry(e.key, e.value)).toList();
  }
}

//********************************** */

//https://stackoverflow.com/questions/72276120/convert-string-to-list-of-dates-in-flutter
List<DateTime?> convertStringIntoDateTimeList(String datesString) {
  List<DateTime?> datetimeList = [];

  //datesString.length <= 2 means the String is only "[]"
  //or empty or has 1 character (meaning definitely not a DateTime string)
  //therefore return an empty list
  //Furthermore, because the String received from the database
  //is of format "[date1, date2, ...]"
  //therefore when converting it, omit the first and last characters
  //(eg. the "[" and "]" characters of the String)
  //furthermore, each date is separated by the folowing two characters ", "
  datetimeList = datesString.length <= 2
      ? []
      : datesString
          .substring(1, datesString.length - 1)
          .split(', ')
          .map((dateString) =>
              dateString == "null" ? null : DateTime.parse(dateString))
          .toList();

  return datetimeList;
}

//method to convert a String into a list of Strings
//https://stackoverflow.com/questions/52288553/flutter-how-to-convert-string-to-liststring
List<String> convertStringIntoStringList(String string) {
  List<String> stringList = [];

  //stringList.length <= 2 means the String is only "[]"
  //or empty or has 1 character (meaning definitely not a list of String which would have minimum 2 characters for an empty list [])
  //therefore return an empty list
  //Furthermore, because the String received from the database
  //is of format "[string1, string2, ...]"
  //therefore when converting it, omit the first and last characters
  //(eg. the "[" and "]" characters of the String)
  //furthermore, each date is separated by the folowing two characters ", "
  stringList = string.length <= 2
      ? []
      : string.substring(1, string.length - 1).split(', ');

  return stringList;
}

//***************************************************** */

List<double> convertStringIntoDoubleList(String string) {
  List<String> stringList = [];
  List<double> doubleList = [];

//convert the String into a list of Strings
  stringList = convertStringIntoStringList(string);

  //then convert the list of String into a list of double
  for (String s in stringList) {
    doubleList.add(double.tryParse(s) ?? 0.0);
  }

  return doubleList;
}

//********************************************** */

extension MyScrollExtension on ScrollController {
  /// Scroll to bottom with given animation duration
  Future<void> animToBottomWithCurve({
    Duration? duration,
    Curve? curve,
  }) async {
    animateTo(
      position.maxScrollExtent,
      duration: duration ?? Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInOut,
    );
  }
}

//********************************************** */

extension MyStringExtension on String {
  //method to convert a String into a list of Strings
//https://stackoverflow.com/questions/52288553/flutter-how-to-convert-string-to-liststring
  List<String> convertStringIntoStringList() {
    List<String> stringList = [];

    //stringList.length <= 2 means the String is only "[]"
    //or empty or has 1 character (meaning definitely not a list of String which would have minimum 2 characters for an empty list [])
    //therefore return an empty list
    //Furthermore, because the String received from the database
    //is of format "[string1, string2, ...]"
    //therefore when converting it, omit the first and last characters
    //(eg. the "[" and "]" characters of the String)
    //furthermore, each date is separated by the folowing two characters ", "
    stringList = length <= 2 ? [] : substring(1, length - 1).split(', ');

    return stringList;
  }
}

//********************************************** */

// extension MyHexColor on Color {
String _generateAlpha({required int alpha, required bool withAlpha}) {
  if (withAlpha) {
    return alpha.toRadixString(16).padLeft(2, '0');
  } else {
    return '';
  }
}

String toHex(Color color,
        {bool leadingHashSign = true, bool withAlpha = true}) =>
    '${leadingHashSign ? '#' : ''}'
    '${_generateAlpha(alpha: ((color.a * 255.0).round() & 0xff), withAlpha: withAlpha)}'
    '${((color.r * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0').toUpperCase()}'
    '${((color.g * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0').toUpperCase()}'
    '${((color.b * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0').toUpperCase()}' /*  .toUpperCase() */;

//******************************************************* */

//https://www.perplexity.ai/?login-source=oneTapHome
Uint8List convertListMapToUint8List(
        List<Map<String, dynamic>> supabaseDatabaseValues) =>
    Uint8List.fromList(utf8.encode(json.encode(supabaseDatabaseValues)));

//******************************************************* */

//https://www.perplexity.ai/search/Dart-convert-String-TNgGFR6VR_iaf9p5T9uonA#4cd80615-1e95-47f8-9a7f-da794fdba89c
List<Map<String, dynamic>> convertUint8ListToListMap(Uint8List data) {
  List<Map<String, dynamic>> listOfMaps = [];

  try {
    final decodedString = utf8.decode(data);

    listOfMaps = (json.decode((decodedString)) as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  } on Exception catch (e) {
    /*  PopThis.showErrorOverlay(
      duration: 3.sec,
      errorMessage:
          "SupabaseDB.downloadMonthDataFromSupabase | CATCH ERROR: impossible to download file - reason: \n $e \n",
    ); */
    debugPrint("convertUint8ListIntoSupabaseDatabase | Error: $e");
  }

  return listOfMaps;
}

//******************************************************* */

const Map<String, String> mimeType = {
  "x3d": "application/vnd.hzn-3d-crossword",
  "3gp": "video/3gpp",
  "3g2": "video/3gpp2",
  "mseq": "application/vnd.mseq",
  "pwn": "application/vnd.3m.post-it-notes",
  "plb": "application/vnd.3gpp.pic-bw-large",
  "psb": "application/vnd.3gpp.pic-bw-small",
  "pvb": "application/vnd.3gpp.pic-bw-var",
  "tcap": "application/vnd.3gpp2.tcap",
  "7z": "application/x-7z-compressed",
  "abw": "application/x-abiword",
  "ace": "application/x-ace-compressed",
  "acc": "application/vnd.americandynamics.acc",
  "acu": "application/vnd.acucobol",
  "atc": "application/vnd.acucorp",
  "adp": "audio/adpcm",
  "aab": "application/x-authorware-bin",
  "aam": "application/x-authorware-map",
  "aas": "application/x-authorware-seg",
  "air": "application/vnd.adobe.air-application-installer-package+zip",
  "swf": "application/x-shockwave-flash",
  "fxp": "application/vnd.adobe.fxp",
  "pdf": "application/pdf",
  "ppd": "application/vnd.cups-ppd",
  "dir": "application/x-director",
  "xdp": "application/vnd.adobe.xdp+xml",
  "xfdf": "application/vnd.adobe.xfdf",
  "aac": "audio/x-aac",
  "ahead": "application/vnd.ahead.space",
  "azf": "application/vnd.airzip.filesecure.azf",
  "azs": "application/vnd.airzip.filesecure.azs",
  "azw": "application/vnd.amazon.ebook",
  "ami": "application/vnd.amiga.ami",
  "N/A": "application/andrew-inset",
  "apk": "application/vnd.android.package-archive",
  "cii": "application/vnd.anser-web-certificate-issue-initiation",
  "fti": "application/vnd.anser-web-funds-transfer-initiation",
  "atx": "application/vnd.antix.game-component",
  "dmg": "application/x-apple-diskimage",
  "mpkg": "application/vnd.apple.installer+xml",
  "aw": "application/applixware",
  "mp3": "audio/mpeg",
  "les": "application/vnd.hhe.lesson-player",
  "swi": "application/vnd.aristanetworks.swi",
  "s": "text/x-asm",
  "atomcat": "application/atomcat+xml",
  "atomsvc": "application/atomsvc+xml",
  "atom": "application/atom+xml",
  "ac": "application/pkix-attr-cert",
  "aif": "audio/x-aiff",
  "avi": "video/x-msvideo",
  "aep": "application/vnd.audiograph",
  "dxf": "image/vnd.dxf",
  "dwf": "model/vnd.dwf",
  "par": "text/plain-bas",
  "bcpio": "application/x-bcpio",
  "bin": "application/octet-stream",
  "bmp": "image/bmp",
  "torrent": "application/x-bittorrent",
  "cod": "application/vnd.rim.cod",
  "mpm": "application/vnd.blueice.multipass",
  "bmi": "application/vnd.bmi",
  "sh": "application/x-sh",
  "btif": "image/prs.btif",
  "rep": "application/vnd.businessobjects",
  "bz": "application/x-bzip",
  "bz2": "application/x-bzip2",
  "csh": "application/x-csh",
  "c": "text/x-c",
  "cdxml": "application/vnd.chemdraw+xml",
  "css": "text/css",
  "cdx": "chemical/x-cdx",
  "cml": "chemical/x-cml",
  "csml": "chemical/x-csml",
  "cdbcmsg": "application/vnd.contact.cmsg",
  "cla": "application/vnd.claymore",
  "c4g": "application/vnd.clonk.c4group",
  "sub": "image/vnd.dvb.subtitle",
  "cdmia": "application/cdmi-capability",
  "cdmic": "application/cdmi-container",
  "cdmid": "application/cdmi-domain",
  "cdmio": "application/cdmi-object",
  "cdmiq": "application/cdmi-queue",
  "c11amc": "application/vnd.cluetrust.cartomobile-config",
  "c11amz": "application/vnd.cluetrust.cartomobile-config-pkg",
  "ras": "image/x-cmu-raster",
  "dae": "model/vnd.collada+xml",
  "csv": "text/csv",
  "cpt": "application/mac-compactpro",
  "wmlc": "application/vnd.wap.wmlc",
  "cgm": "image/cgm",
  "ice": "x-conference/x-cooltalk",
  "cmx": "image/x-cmx",
  "xar": "application/vnd.xara",
  "cmc": "application/vnd.cosmocaller",
  "cpio": "application/x-cpio",
  "clkx": "application/vnd.crick.clicker",
  "clkk": "application/vnd.crick.clicker.keyboard",
  "clkp": "application/vnd.crick.clicker.palette",
  "clkt": "application/vnd.crick.clicker.template",
  "clkw": "application/vnd.crick.clicker.wordbank",
  "wbs": "application/vnd.criticaltools.wbs+xml",
  "cryptonote": "application/vnd.rig.cryptonote",
  "cif": "chemical/x-cif",
  "cmdf": "chemical/x-cmdf",
  "cu": "application/cu-seeme",
  "cww": "application/prs.cww",
  "curl": "text/vnd.curl",
  "dcurl": "text/vnd.curl.dcurl",
  "mcurl": "text/vnd.curl.mcurl",
  "scurl": "text/vnd.curl.scurl",
  "car": "application/vnd.curl.car",
  "pcurl": "application/vnd.curl.pcurl",
  "cmp": "application/vnd.yellowriver-custom-menu",
  "dssc": "application/dssc+der",
  "xdssc": "application/dssc+xml",
  "deb": "application/x-debian-package",
  "uva": "audio/vnd.dece.audio",
  "uvi": "image/vnd.dece.graphic",
  "uvh": "video/vnd.dece.hd",
  "uvm": "video/vnd.dece.mobile",
  "uvu": "video/vnd.uvvu.mp4",
  "uvp": "video/vnd.dece.pd",
  "uvs": "video/vnd.dece.sd",
  "uvv": "video/vnd.dece.video",
  "dvi": "application/x-dvi",
  "seed": "application/vnd.fdsn.seed",
  "dtb": "application/x-dtbook+xml",
  "res": "application/x-dtbresource+xml",
  "ait": "application/vnd.dvb.ait",
  "svc": "application/vnd.dvb.service",
  "eol": "audio/vnd.digital-winds",
  "djvu": "image/vnd.djvu",
  "dtd": "application/xml-dtd",
  "mlp": "application/vnd.dolby.mlp",
  "wad": "application/x-doom",
  "dpg": "application/vnd.dpgraph",
  "dra": "audio/vnd.dra",
  "dfac": "application/vnd.dreamfactory",
  "dts": "audio/vnd.dts",
  "dtshd": "audio/vnd.dts.hd",
  "dwg": "image/vnd.dwg",
  "geo": "application/vnd.dynageo",
  "es": "application/ecmascript",
  "mag": "application/vnd.ecowin.chart",
  "mmr": "image/vnd.fujixerox.edmics-mmr",
  "rlc": "image/vnd.fujixerox.edmics-rlc",
  "exi": "application/exi",
  "mgz": "application/vnd.proteus.magazine",
  "epub": "application/epub+zip",
  "eml": "message/rfc822",
  "nml": "application/vnd.enliven",
  "xpr": "application/vnd.is-xpr",
  "xif": "image/vnd.xiff",
  "xfdl": "application/vnd.xfdl",
  "emma": "application/emma+xml",
  "ez2": "application/vnd.ezpix-album",
  "ez3": "application/vnd.ezpix-package",
  "fst": "image/vnd.fst",
  "fvt": "video/vnd.fvt",
  "fbs": "image/vnd.fastbidsheet",
  "fe_launch": "application/vnd.denovo.fcselayout-link",
  "f4v": "video/x-f4v",
  "flv": "video/x-flv",
  "fpx": "image/vnd.fpx",
  "npx": "image/vnd.net-fpx",
  "flx": "text/vnd.fmi.flexstor",
  "fli": "video/x-fli",
  "ftc": "application/vnd.fluxtime.clip",
  "fdf": "application/vnd.fdf",
  "f": "text/x-fortran",
  "mif": "application/vnd.mif",
  "fm": "application/vnd.framemaker",
  "fh": "image/x-freehand",
  "fsc": "application/vnd.fsc.weblaunch",
  "fnc": "application/vnd.frogans.fnc",
  "ltf": "application/vnd.frogans.ltf",
  "ddd": "application/vnd.fujixerox.ddd",
  "xdw": "application/vnd.fujixerox.docuworks",
  "xbd": "application/vnd.fujixerox.docuworks.binder",
  "oas": "application/vnd.fujitsu.oasys",
  "oa2": "application/vnd.fujitsu.oasys2",
  "oa3": "application/vnd.fujitsu.oasys3",
  "fg5": "application/vnd.fujitsu.oasysgp",
  "bh2": "application/vnd.fujitsu.oasysprs",
  "spl": "application/x-futuresplash",
  "fzs": "application/vnd.fuzzysheet",
  "g3": "image/g3fax",
  "gmx": "application/vnd.gmx",
  "gtw": "model/vnd.gtw",
  "txd": "application/vnd.genomatix.tuxedo",
  "ggb": "application/vnd.geogebra.file",
  "ggt": "application/vnd.geogebra.tool",
  "gdl": "model/vnd.gdl",
  "gex": "application/vnd.geometry-explorer",
  "gxt": "application/vnd.geonext",
  "g2w": "application/vnd.geoplan",
  "g3w": "application/vnd.geospace",
  "gsf": "application/x-font-ghostscript",
  "bdf": "application/x-font-bdf",
  "gtar": "application/x-gtar",
  "texinfo": "application/x-texinfo",
  "gnumeric": "application/x-gnumeric",
  "kml": "application/vnd.google-earth.kml+xml",
  "kmz": "application/vnd.google-earth.kmz",
  "gqf": "application/vnd.grafeq",
  "gif": "image/gif",
  "gv": "text/vnd.graphviz",
  "gac": "application/vnd.groove-account",
  "ghf": "application/vnd.groove-help",
  "gim": "application/vnd.groove-identity-message",
  "grv": "application/vnd.groove-injector",
  "gtm": "application/vnd.groove-tool-message",
  "tpl": "application/vnd.groove-tool-template",
  "vcg": "application/vnd.groove-vcard",
  "h261": "video/h261",
  "h263": "video/h263",
  "h264": "video/h264",
  "hpid": "application/vnd.hp-hpid",
  "hps": "application/vnd.hp-hps",
  "hdf": "application/x-hdf",
  "rip": "audio/vnd.rip",
  "hbci": "application/vnd.hbci",
  "jlt": "application/vnd.hp-jlyt",
  "pcl": "application/vnd.hp-pcl",
  "hpgl": "application/vnd.hp-hpgl",
  "hvs": "application/vnd.yamaha.hv-script",
  "hvd": "application/vnd.yamaha.hv-dic",
  "hvp": "application/vnd.yamaha.hv-voice",
  "sfd-hdstx": "application/vnd.hydrostatix.sof-data",
  "stk": "application/hyperstudio",
  "hal": "application/vnd.hal+xml",
  "html": "text/html",
  "irm": "application/vnd.ibm.rights-management",
  "sc": "application/vnd.ibm.secure-container",
  "ics": "text/calendar",
  "icc": "application/vnd.iccprofile",
  "ico": "image/x-icon",
  "igl": "application/vnd.igloader",
  "ief": "image/ief",
  "ivp": "application/vnd.immervision-ivp",
  "ivu": "application/vnd.immervision-ivu",
  "rif": "application/reginfo+xml",
  "3dml": "text/vnd.in3d.3dml",
  "spot": "text/vnd.in3d.spot",
  "igs": "model/iges",
  "i2g": "application/vnd.intergeo",
  "cdy": "application/vnd.cinderella",
  "xpw": "application/vnd.intercon.formnet",
  "fcs": "application/vnd.isac.fcs",
  "ipfix": "application/ipfix",
  "cer": "application/pkix-cert",
  "pki": "application/pkixcmp",
  "crl": "application/pkix-crl",
  "pkipath": "application/pkix-pkipath",
  "igm": "application/vnd.insors.igm",
  "rcprofile": "application/vnd.ipunplugged.rcprofile",
  "irp": "application/vnd.irepository.package+xml",
  "jad": "text/vnd.sun.j2me.app-descriptor",
  "jar": "application/java-archive",
  "class": "application/java-vm",
  "jnlp": "application/x-java-jnlp-file",
  "ser": "application/java-serialized-object",
  "java": "text/x-java-source,java",
  "js": "application/javascript",
  "json": "application/json",
  "joda": "application/vnd.joost.joda-archive",
  "jpm": "video/jpm",
  "jpeg": "image/x-citrix-jpeg",
  "jpg": "image/x-citrix-jpeg",
  "pjpeg": "image/pjpeg",
  "jpgv": "video/jpeg",
  "ktz": "application/vnd.kahootz",
  "mmd": "application/vnd.chipnuts.karaoke-mmd",
  "karbon": "application/vnd.kde.karbon",
  "chrt": "application/vnd.kde.kchart",
  "kfo": "application/vnd.kde.kformula",
  "flw": "application/vnd.kde.kivio",
  "kon": "application/vnd.kde.kontour",
  "kpr": "application/vnd.kde.kpresenter",
  "ksp": "application/vnd.kde.kspread",
  "kwd": "application/vnd.kde.kword",
  "htke": "application/vnd.kenameaapp",
  "kia": "application/vnd.kidspiration",
  "kne": "application/vnd.kinar",
  "sse": "application/vnd.kodak-descriptor",
  "lasxml": "application/vnd.las.las+xml",
  "latex": "application/x-latex",
  "lbd": "application/vnd.llamagraphics.life-balance.desktop",
  "lbe": "application/vnd.llamagraphics.life-balance.exchange+xml",
  "jam": "application/vnd.jam",
  "123": "application/vnd.lotus-1-2-3",
  "apr": "application/vnd.lotus-approach",
  "pre": "application/vnd.lotus-freelance",
  "nsf": "application/vnd.lotus-notes",
  "org": "application/vnd.lotus-organizer",
  "scm": "application/vnd.lotus-screencam",
  "lwp": "application/vnd.lotus-wordpro",
  "lvp": "audio/vnd.lucent.voice",
  "m3u": "audio/x-mpegurl",
  "m4v": "video/x-m4v",
  "hqx": "application/mac-binhex40",
  "portpkg": "application/vnd.macports.portpkg",
  "mgp": "application/vnd.osgeo.mapguide.package",
  "mrc": "application/marc",
  "mrcx": "application/marcxml+xml",
  "mxf": "application/mxf",
  "nbp": "application/vnd.wolfram.player",
  "ma": "application/mathematica",
  "mathml": "application/mathml+xml",
  "mbox": "application/mbox",
  "mc1": "application/vnd.medcalcdata",
  "mscml": "application/mediaservercontrol+xml",
  "cdkey": "application/vnd.mediastation.cdkey",
  "mwf": "application/vnd.mfer",
  "mfm": "application/vnd.mfmp",
  "msh": "model/mesh",
  "mads": "application/mads+xml",
  "mets": "application/mets+xml",
  "mods": "application/mods+xml",
  "meta4": "application/metalink4+xml",
  "mcd": "application/vnd.mcd",
  "flo": "application/vnd.micrografx.flo",
  "igx": "application/vnd.micrografx.igx",
  "es3": "application/vnd.eszigno3+xml",
  "mdb": "application/x-msaccess",
  "asf": "video/x-ms-asf",
  "exe": "application/x-ms-application",
  "cil": "application/vnd.ms-artgalry",
  "cab": "application/vnd.ms-cab-compressed",
  "ims": "application/vnd.ms-ims",
  "application": "application/x-ms-application",
  "clp": "application/x-msclip",
  "mdi": "image/vnd.ms-modi",
  "eot": "application/vnd.ms-fontobject",
  "xls": "application/vnd.ms-excel",
  "xlam": "application/vnd.ms-excel.addin.macroenabled.12",
  "xlsb": "application/vnd.ms-excel.sheet.binary.macroenabled.12",
  "xltm": "application/vnd.ms-excel.template.macroenabled.12",
  "xlsm": "application/vnd.ms-excel.sheet.macroenabled.12",
  "chm": "application/vnd.ms-htmlhelp",
  "crd": "application/x-mscardfile",
  "lrm": "application/vnd.ms-lrm",
  "mvb": "application/x-msmediaview",
  "mny": "application/x-msmoney",
  "pptx":
      "application/vnd.openxmlformats-officedocument.presentationml.presentation",
  "sldx": "application/vnd.openxmlformats-officedocument.presentationml.slide",
  "ppsx":
      "application/vnd.openxmlformats-officedocument.presentationml.slideshow",
  "potx":
      "application/vnd.openxmlformats-officedocument.presentationml.template",
  "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  "xltx":
      "application/vnd.openxmlformats-officedocument.spreadsheetml.template",
  "docx":
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  "dotx":
      "application/vnd.openxmlformats-officedocument.wordprocessingml.template",
  "obd": "application/x-msbinder",
  "thmx": "application/vnd.ms-officetheme",
  "onetoc": "application/onenote",
  "pya": "audio/vnd.ms-playready.media.pya",
  "pyv": "video/vnd.ms-playready.media.pyv",
  "ppt": "application/vnd.ms-powerpoint",
  "ppam": "application/vnd.ms-powerpoint.addin.macroenabled.12",
  "sldm": "application/vnd.ms-powerpoint.slide.macroenabled.12",
  "pptm": "application/vnd.ms-powerpoint.presentation.macroenabled.12",
  "ppsm": "application/vnd.ms-powerpoint.slideshow.macroenabled.12",
  "potm": "application/vnd.ms-powerpoint.template.macroenabled.12",
  "mpp": "application/vnd.ms-project",
  "pub": "application/x-mspublisher",
  "scd": "application/x-msschedule",
  "xap": "application/x-silverlight-app",
  "stl": "application/vnd.ms-pki.stl",
  "cat": "application/vnd.ms-pki.seccat",
  "vsd": "application/vnd.visio",
  "vsdx": "application/vnd.visio2013",
  "wm": "video/x-ms-wm",
  "wma": "audio/x-ms-wma",
  "wax": "audio/x-ms-wax",
  "wmx": "video/x-ms-wmx",
  "wmd": "application/x-ms-wmd",
  "wpl": "application/vnd.ms-wpl",
  "wmz": "application/x-ms-wmz",
  "wmv": "video/x-ms-wmv",
  "wvx": "video/x-ms-wvx",
  "wmf": "application/x-msmetafile",
  "trm": "application/x-msterminal",
  "doc": "application/msword",
  "docm": "application/vnd.ms-word.document.macroenabled.12",
  "dotm": "application/vnd.ms-word.template.macroenabled.12",
  "wri": "application/x-mswrite",
  "wps": "application/vnd.ms-works",
  "xbap": "application/x-ms-xbap",
  "xps": "application/vnd.ms-xpsdocument",
  "mid": "audio/midi",
  "mpy": "application/vnd.ibm.minipay",
  "afp": "application/vnd.ibm.modcap",
  "rms": "application/vnd.jcp.javame.midlet-rms",
  "tmo": "application/vnd.tmobile-livetv",
  "prc": "application/x-mobipocket-ebook",
  "mbk": "application/vnd.mobius.mbk",
  "dis": "application/vnd.mobius.dis",
  "plc": "application/vnd.mobius.plc",
  "mqy": "application/vnd.mobius.mqy",
  "msl": "application/vnd.mobius.msl",
  "txf": "application/vnd.mobius.txf",
  "daf": "application/vnd.mobius.daf",
  "fly": "text/vnd.fly",
  "mpc": "application/vnd.mophun.certificate",
  "mpn": "application/vnd.mophun.application",
  "mj2": "video/mj2",
  "mpga": "audio/mpeg",
  "mxu": "video/vnd.mpegurl",
  "mpeg": "video/mpeg",
  "m21": "application/mp21",
  "mp4a": "audio/mp4",
  "mp4": "video/mp4",
  "m3u8": "application/vnd.apple.mpegurl",
  "mus": "application/vnd.musician",
  "msty": "application/vnd.muvee.style",
  "mxml": "application/xv+xml",
  "ngdat": "application/vnd.nokia.n-gage.data",
  "n-gage": "application/vnd.nokia.n-gage.symbian.install",
  "ncx": "application/x-dtbncx+xml",
  "nc": "application/x-netcdf",
  "nlu": "application/vnd.neurolanguage.nlu",
  "dna": "application/vnd.dna",
  "nnd": "application/vnd.noblenet-directory",
  "nns": "application/vnd.noblenet-sealer",
  "nnw": "application/vnd.noblenet-web",
  "rpst": "application/vnd.nokia.radio-preset",
  "rpss": "application/vnd.nokia.radio-presets",
  "n3": "text/n3",
  "edm": "application/vnd.novadigm.edm",
  "edx": "application/vnd.novadigm.edx",
  "ext": "application/vnd.novadigm.ext",
  "gph": "application/vnd.flographit",
  "ecelp4800": "audio/vnd.nuera.ecelp4800",
  "ecelp7470": "audio/vnd.nuera.ecelp7470",
  "ecelp9600": "audio/vnd.nuera.ecelp9600",
  "oda": "application/oda",
  "ogx": "application/ogg",
  "oga": "audio/ogg",
  "ogv": "video/ogg",
  "dd2": "application/vnd.oma.dd2+xml",
  "oth": "application/vnd.oasis.opendocument.text-web",
  "opf": "application/oebps-package+xml",
  "qbo": "application/vnd.intu.qbo",
  "oxt": "application/vnd.openofficeorg.extension",
  "osf": "application/vnd.yamaha.openscoreformat",
  "weba": "audio/webm",
  "webm": "video/webm",
  "odc": "application/vnd.oasis.opendocument.chart",
  "otc": "application/vnd.oasis.opendocument.chart-template",
  "odb": "application/vnd.oasis.opendocument.database",
  "odf": "application/vnd.oasis.opendocument.formula",
  "odft": "application/vnd.oasis.opendocument.formula-template",
  "odg": "application/vnd.oasis.opendocument.graphics",
  "otg": "application/vnd.oasis.opendocument.graphics-template",
  "odi": "application/vnd.oasis.opendocument.image",
  "oti": "application/vnd.oasis.opendocument.image-template",
  "odp": "application/vnd.oasis.opendocument.presentation",
  "otp": "application/vnd.oasis.opendocument.presentation-template",
  "ods": "application/vnd.oasis.opendocument.spreadsheet",
  "ots": "application/vnd.oasis.opendocument.spreadsheet-template",
  "odt": "application/vnd.oasis.opendocument.text",
  "odm": "application/vnd.oasis.opendocument.text-master",
  "ott": "application/vnd.oasis.opendocument.text-template",
  "ktx": "image/ktx",
  "sxc": "application/vnd.sun.xml.calc",
  "stc": "application/vnd.sun.xml.calc.template",
  "sxd": "application/vnd.sun.xml.draw",
  "std": "application/vnd.sun.xml.draw.template",
  "sxi": "application/vnd.sun.xml.impress",
  "sti": "application/vnd.sun.xml.impress.template",
  "sxm": "application/vnd.sun.xml.math",
  "sxw": "application/vnd.sun.xml.writer",
  "sxg": "application/vnd.sun.xml.writer.global",
  "stw": "application/vnd.sun.xml.writer.template",
  "otf": "application/x-font-otf",
  "osfpvg": "application/vnd.yamaha.openscoreformat.osfpvg+xml",
  "dp": "application/vnd.osgi.dp",
  "pdb": "application/vnd.palm",
  "p": "text/x-pascal",
  "paw": "application/vnd.pawaafile",
  "pclxl": "application/vnd.hp-pclxl",
  "efif": "application/vnd.picsel",
  "pcx": "image/x-pcx",
  "psd": "image/vnd.adobe.photoshop",
  "prf": "application/pics-rules",
  "pic": "image/x-pict",
  "chat": "application/x-chat",
  "p10": "application/pkcs10",
  "p12": "application/x-pkcs12",
  "p7m": "application/pkcs7-mime",
  "p7s": "application/pkcs7-signature",
  "p7r": "application/x-pkcs7-certreqresp",
  "p7b": "application/x-pkcs7-certificates",
  "p8": "application/pkcs8",
  "plf": "application/vnd.pocketlearn",
  "pnm": "image/x-portable-anymap",
  "pbm": "image/x-portable-bitmap",
  "pcf": "application/x-font-pcf",
  "pfr": "application/font-tdpfr",
  "pgn": "application/x-chess-pgn",
  "pgm": "image/x-portable-graymap",
  "png": "image/x-png",
  "ppm": "image/x-portable-pixmap",
  "pskcxml": "application/pskc+xml",
  "pml": "application/vnd.ctc-posml",
  "ai": "application/postscript",
  "pfa": "application/x-font-type1",
  "pbd": "application/vnd.powerbuilder6",
  "pgp": "application/pgp-signature",
  "box": "application/vnd.previewsystems.box",
  "ptid": "application/vnd.pvi.ptid1",
  "pls": "application/pls+xml",
  "str": "application/vnd.pg.format",
  "ei6": "application/vnd.pg.osasli",
  "dsc": "text/prs.lines.tag",
  "psf": "application/x-font-linux-psf",
  "qps": "application/vnd.publishare-delta-tree",
  "wg": "application/vnd.pmi.widget",
  "qxd": "application/vnd.quark.quarkxpress",
  "esf": "application/vnd.epson.esf",
  "msf": "application/vnd.epson.msf",
  "ssf": "application/vnd.epson.ssf",
  "qam": "application/vnd.epson.quickanime",
  "qfx": "application/vnd.intu.qfx",
  "qt": "video/quicktime",
  "rar": "application/x-rar-compressed",
  "ram": "audio/x-pn-realaudio",
  "rmp": "audio/x-pn-realaudio-plugin",
  "rsd": "application/rsd+xml",
  "rm": "application/vnd.rn-realmedia",
  "bed": "application/vnd.realvnc.bed",
  "mxl": "application/vnd.recordare.musicxml",
  "musicxml": "application/vnd.recordare.musicxml+xml",
  "rnc": "application/relax-ng-compact-syntax",
  "rdz": "application/vnd.data-vision.rdz",
  "rdf": "application/rdf+xml",
  "rp9": "application/vnd.cloanto.rp9",
  "jisp": "application/vnd.jisp",
  "rtf": "application/rtf",
  "rtx": "text/richtext",
  "link66": "application/vnd.route66.link66+xml",
  "rss": "application/rss+xml",
  "shf": "application/shf+xml",
  "st": "application/vnd.sailingtracker.track",
  "svg": "image/svg+xml",
  "sus": "application/vnd.sus-calendar",
  "sru": "application/sru+xml",
  "setpay": "application/set-payment-initiation",
  "setreg": "application/set-registration-initiation",
  "sema": "application/vnd.sema",
  "semd": "application/vnd.semd",
  "semf": "application/vnd.semf",
  "see": "application/vnd.seemail",
  "snf": "application/x-font-snf",
  "spq": "application/scvp-vp-request",
  "spp": "application/scvp-vp-response",
  "scq": "application/scvp-cv-request",
  "scs": "application/scvp-cv-response",
  "sdp": "application/sdp",
  "etx": "text/x-setext",
  "movie": "video/x-sgi-movie",
  "ifm": "application/vnd.shana.informed.formdata",
  "itp": "application/vnd.shana.informed.formtemplate",
  "iif": "application/vnd.shana.informed.interchange",
  "ipk": "application/vnd.shana.informed.package",
  "tfi": "application/thraud+xml",
  "shar": "application/x-shar",
  "rgb": "image/x-rgb",
  "slt": "application/vnd.epson.salt",
  "aso": "application/vnd.accpac.simply.aso",
  "imp": "application/vnd.accpac.simply.imp",
  "twd": "application/vnd.simtech-mindmapper",
  "csp": "application/vnd.commonspace",
  "saf": "application/vnd.yamaha.smaf-audio",
  "mmf": "application/vnd.smaf",
  "spf": "application/vnd.yamaha.smaf-phrase",
  "teacher": "application/vnd.smart.teacher",
  "svd": "application/vnd.svd",
  "rq": "application/sparql-query",
  "srx": "application/sparql-results+xml",
  "gram": "application/srgs",
  "grxml": "application/srgs+xml",
  "ssml": "application/ssml+xml",
  "skp": "application/vnd.koan",
  "sgml": "text/sgml",
  "sdc": "application/vnd.stardivision.calc",
  "sda": "application/vnd.stardivision.draw",
  "sdd": "application/vnd.stardivision.impress",
  "smf": "application/vnd.stardivision.math",
  "sdw": "application/vnd.stardivision.writer",
  "sgl": "application/vnd.stardivision.writer-global",
  "sm": "application/vnd.stepmania.stepchart",
  "sit": "application/x-stuffit",
  "sitx": "application/x-stuffitx",
  "sdkm": "application/vnd.solent.sdkm+xml",
  "xo": "application/vnd.olpc-sugar",
  "au": "audio/basic",
  "wqd": "application/vnd.wqd",
  "sis": "application/vnd.symbian.install",
  "smi": "application/smil+xml",
  "xsm": "application/vnd.syncml+xml",
  "bdm": "application/vnd.syncml.dm+wbxml",
  "xdm": "application/vnd.syncml.dm+xml",
  "sv4cpio": "application/x-sv4cpio",
  "sv4crc": "application/x-sv4crc",
  "sbml": "application/sbml+xml",
  "tsv": "text/tab-separated-values",
  "tiff": "image/tiff",
  "tao": "application/vnd.tao.intent-module-archive",
  "tar": "application/x-tar",
  "tcl": "application/x-tcl",
  "tex": "application/x-tex",
  "tfm": "application/x-tex-tfm",
  "tei": "application/tei+xml",
  "txt": "text/plain",
  "dxp": "application/vnd.spotfire.dxp",
  "sfs": "application/vnd.spotfire.sfs",
  "tsd": "application/timestamped-data",
  "tpt": "application/vnd.trid.tpt",
  "mxs": "application/vnd.triscape.mxs",
  "t": "text/troff",
  "tra": "application/vnd.trueapp",
  "ttf": "application/x-font-ttf",
  "ttl": "text/turtle",
  "umj": "application/vnd.umajin",
  "uoml": "application/vnd.uoml+xml",
  "unityweb": "application/vnd.unity",
  "ufd": "application/vnd.ufdl",
  "uri": "text/uri-list",
  "utz": "application/vnd.uiq.theme",
  "ustar": "application/x-ustar",
  "uu": "text/x-uuencode",
  "vcs": "text/x-vcalendar",
  "vcf": "text/x-vcard",
  "vcd": "application/x-cdlink",
  "vsf": "application/vnd.vsf",
  "wrl": "model/vrml",
  "vcx": "application/vnd.vcx",
  "mts": "model/vnd.mts",
  "vtu": "model/vnd.vtu",
  "vis": "application/vnd.visionary",
  "viv": "video/vnd.vivo",
  "ccxml": "application/ccxml+xml,",
  "vxml": "application/voicexml+xml",
  "src": "application/x-wais-source",
  "wbxml": "application/vnd.wap.wbxml",
  "wbmp": "image/vnd.wap.wbmp",
  "wav": "audio/x-wav",
  "davmount": "application/davmount+xml",
  "woff": "application/x-font-woff",
  "wspolicy": "application/wspolicy+xml",
  "webp": "image/webp",
  "wtb": "application/vnd.webturbo",
  "wgt": "application/widget",
  "hlp": "application/winhlp",
  "wml": "text/vnd.wap.wml",
  "wmls": "text/vnd.wap.wmlscript",
  "wmlsc": "application/vnd.wap.wmlscriptc",
  "wpd": "application/vnd.wordperfect",
  "stf": "application/vnd.wt.stf",
  "wsdl": "application/wsdl+xml",
  "xbm": "image/x-xbitmap",
  "xpm": "image/x-xpixmap",
  "xwd": "image/x-xwindowdump",
  "der": "application/x-x509-ca-cert",
  "fig": "application/x-xfig",
  "xhtml": "application/xhtml+xml",
  "xml": "application/xml",
  "xdf": "application/xcap-diff+xml",
  "xenc": "application/xenc+xml",
  "xer": "application/patch-ops-error+xml",
  "rl": "application/resource-lists+xml",
  "rs": "application/rls-services+xml",
  "rld": "application/resource-lists-diff+xml",
  "xslt": "application/xslt+xml",
  "xop": "application/xop+xml",
  "xpi": "application/x-xpinstall",
  "xspf": "application/xspf+xml",
  "xul": "application/vnd.mozilla.xul+xml",
  "xyz": "chemical/x-xyz",
  "yaml": "text/yaml",
  "yang": "application/yang",
  "yin": "application/yin+xml",
  "zir": "application/vnd.zul",
  "zip": "application/zip",
  "zmm": "application/vnd.handheld-entertainment+xml",
  "zaz": "application/vnd.zzazz.deck+xml"
};

//******************************************************* */

const List<String> months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

//******************************************************* */

extension UriString on String {
  Uri get toUri => Uri.parse(this);
}

//******************************************************* */

/// Extension providing a `findFirstWhereOrNull` function to find the first element satisfying a condition.
///
/// This extension adds a method `findFirstWhereOrNull` to iterables, allowing you to find the first
/// element that satisfies the provided condition, or `null` if no such element exists.
extension MyfindFirstWhereOrNullExt<T> on Iterable<T> {
  /// Finds the first element satisfying the provided condition, or `null` if none is found.
  T? findFirstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

//******************************************************* */

extension MyBuildContextExtension on BuildContext {
  static Rect? getTheWidgetBounds(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    return (box != null) ? box.semanticBounds : null;
  }

  static Offset? getTheWidgetLocalToGlobal(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    return (box != null) ? box.localToGlobal(Offset.zero) : null;
  }
}

extension ListExtension on List<dynamic> {
  bool doesIndexExist(int index) => asMap().containsKey(index);

  /// Get the safe accessor for this list that returns null for invalid indices
  /// Usage: list.safe[2] // returns null if index 2 doesn't exist
  SafeListAccessor get safe => SafeListAccessor(this);
}

/// A wrapper class that provides safe access to list elements using [] operator
/// Returns null instead of throwing exception for invalid indices
class SafeListAccessor {
  final List<dynamic> _list;

  SafeListAccessor(this._list);

  /// Safely access element at index, returns null if index doesn't exist
  dynamic operator [](int index) {
    if (index >= 0 && index < _list.length) {
      return _list[index];
    }
    return null;
  }
}

//******************************************************* */

extension OffsetToAlignment on Offset {
  Alignment toAlignment() {
    // Convert offset to alignment
    return Alignment(
      (2 * dx / 100.w) - 1,
      (2 * dy / 100.h) - 1,
    );
  }
}

//******************************************************* */

extension TimeOfDayExtension on TimeOfDay {
  String toJson() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  static TimeOfDay fromJson(String json) {
    final parts = json.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  /// Convert TimeOfDay to Duration since midnight
  Duration convertToDuration() {
    return Duration(hours: hour, minutes: minute);
  }

  /// Convert TimeOfDay to formatted string
  String convertToStringTime({
    bool showSeconds = false,
    bool showUtcSymbol = false,
    bool preferUtcSymbolThanZ = false,
    bool showSeparatorSymbol = true,
    bool use24HourFormat = true,
  }) {
    String separatorSymbol() => showSeparatorSymbol ? ':' : '';

    if (use24HourFormat) {
      String hourString = hour.toString().padLeft(2, '0');
      String minString = minute.toString().padLeft(2, '0');
      String secString = "00"; // TimeOfDay doesn't have seconds

      return showSeconds
          ? "$hourString${separatorSymbol()}$minString${separatorSymbol()}$secString${showUtcSymbol ? preferUtcSymbolThanZ ? ' UTC' : ' z' : ''}"
          : "$hourString${separatorSymbol()}$minString${showUtcSymbol ? preferUtcSymbolThanZ ? ' UTC' : ' z' : ''}";
    } else {
      // 12-hour format
      int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      String period = hour >= 12 ? 'PM' : 'AM';
      String hourString = displayHour.toString().padLeft(2, '0');
      String minString = minute.toString().padLeft(2, '0');

      return "$hourString${separatorSymbol()}$minString $period";
    }
  }

  /// Convert time into decimal of hour (e.g., 14:30 = 14.5)
  double convertTimeIntoDecimalOfHour([int decimalPoint = 1]) {
    return (hour + minute / 60).roundDoubleToDecimalPlace(decimalPoint);
  }

  /// Round time to the next (ceiling) or previous (floor) minute interval.
  /// When [isRoundDownTo] is false, 14:07 with nearestMinute 15 becomes 14:15.
  /// When true, it becomes 14:00.
  TimeOfDay toNearestMinute({
    int nearestMinute = 5,
    bool isRoundDownTo = false,
  }) {
    assert(nearestMinute > 0);
    final totalMinutes = hour * 60 + minute;
    final remainder = totalMinutes % nearestMinute;
    final base = totalMinutes - remainder; // floor multiple
    final roundedMinutes = isRoundDownTo
        ? base
        : (remainder == 0 ? base : base + nearestMinute); // ceiling multiple
    final clampedMinutes = roundedMinutes % (24 * 60);
    return TimeOfDay(
      hour: clampedMinutes ~/ 60,
      minute: clampedMinutes % 60,
    );
  }

  /// Round down time by a duration interval
  TimeOfDay roundDown(
      {Duration durationToRoundDown = const Duration(minutes: 5)}) {
    final totalMinutes = hour * 60 + minute;
    final intervalMinutes = durationToRoundDown.inMinutes;
    final roundedMinutes = (totalMinutes ~/ intervalMinutes) * intervalMinutes;

    return TimeOfDay(
      hour: roundedMinutes ~/ 60,
      minute: roundedMinutes % 60,
    );
  }

  /// Convert TimeOfDay to DateTime on a specific date
  DateTime toDateTime(DateTime date, {bool isUtc = true}) {
    if (isUtc) {
      return DateTime.utc(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );
    } else {
      return DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );
    }
  }

  /// Add minutes to TimeOfDay
  TimeOfDay addMinutes(int minutes) {
    final totalMinutes = (hour * 60 + minute + minutes) % (24 * 60);
    return TimeOfDay(
      hour: totalMinutes ~/ 60,
      minute: totalMinutes % 60,
    );
  }

  /// Subtract minutes from TimeOfDay with proper wrap-around before midnight.
  TimeOfDay subtractMinutes(int minutes) {
    final totalMinutes = hour * 60 + minute - minutes;
    final adjustedMinutes = (totalMinutes % (24 * 60) + (24 * 60)) % (24 * 60);
    return TimeOfDay(
      hour: adjustedMinutes ~/ 60,
      minute: adjustedMinutes % 60,
    );
  }

  /// Add hours to TimeOfDay
  TimeOfDay addHours(int hours) {
    return addMinutes(hours * 60);
  }

  /// Subtract hours from TimeOfDay
  TimeOfDay subtractHours(int hours) {
    return subtractMinutes(hours * 60);
  }

  /// Check if this time is before another time
  bool isBefore(TimeOfDay other) {
    if (hour != other.hour) {
      return hour < other.hour;
    }
    return minute < other.minute;
  }

  /// Check if this time is after another time
  bool isAfter(TimeOfDay other) {
    if (hour != other.hour) {
      return hour > other.hour;
    }
    return minute > other.minute;
  }

  /// Check if this time equals another time
  bool isEqualTo(TimeOfDay other) {
    return hour == other.hour && minute == other.minute;
  }

  /// Comparison operators for TimeOfDay
  /// Greater than operator
  bool operator >(TimeOfDay other) {
    return isAfter(other);
  }

  /// Less than operator
  bool operator <(TimeOfDay other) {
    return isBefore(other);
  }

  /// Greater than or equal operator
  bool operator >=(TimeOfDay other) {
    return isAfter(other) || isEqualTo(other);
  }

  /// Less than or equal operator
  bool operator <=(TimeOfDay other) {
    return isBefore(other) || isEqualTo(other);
  }

  /// Get difference in minutes between two TimeOfDay instances
  int differenceInMinutes(TimeOfDay other) {
    final thisMinutes = hour * 60 + minute;
    final otherMinutes = other.hour * 60 + other.minute;
    return thisMinutes - otherMinutes;
  }

  /// Get absolute difference in minutes between two TimeOfDay instances
  int absoluteDifferenceInMinutes(TimeOfDay other) {
    return differenceInMinutes(other).abs();
  }

  /// Check if time is within a range
  bool isWithinRange(TimeOfDay start, TimeOfDay end) {
    // Handle case where range crosses midnight
    if (start.isAfter(end)) {
      return isAfter(start) ||
          isBefore(end) ||
          isEqualTo(start) ||
          isEqualTo(end);
    }
    return (isAfter(start) || isEqualTo(start)) &&
        (isBefore(end) || isEqualTo(end));
  }

  /// Check if this is AM time
  bool get isAM => hour < 12;

  /// Check if this is PM time
  bool get isPM => hour >= 12;

  /// Check if this is midnight (00:00)
  bool get isMidnight => hour == 0 && minute == 0;

  /// Check if this is noon (12:00)
  bool get isNoon => hour == 12 && minute == 0;

  /// Get total minutes since midnight
  int get totalMinutes => hour * 60 + minute;

  /// Create TimeOfDay from total minutes since midnight
  static TimeOfDay fromTotalMinutes(int totalMinutes) {
    final clampedMinutes = totalMinutes % (24 * 60);
    return TimeOfDay(
      hour: clampedMinutes ~/ 60,
      minute: clampedMinutes % 60,
    );
  }

  /// Convert to ATC time format (HHMM)
  String toAtcTimeString({bool withSeparator = false}) {
    final hourStr = hour.toString().padLeft(2, '0');
    final minStr = minute.toString().padLeft(2, '0');
    return withSeparator ? '$hourStr:$minStr' : '$hourStr$minStr';
  }

  /// Static method to create a TimeOfDay representing zero time (00:00)
  static TimeOfDay get zero => const TimeOfDay(hour: 0, minute: 0);
}

//******************************************************* */

extension TimeOfDayExtensions2<dynamics extends TimeOfDay?> on TimeOfDay? {
  /// Convert nullable TimeOfDay to Duration since midnight
  Duration? convertToDuration() {
    if (this != null) {
      return Duration(hours: this!.hour, minutes: this!.minute);
    } else {
      debugPrint("the Duration to convert to DateTime is NULL");
      return null;
    }
  }

  /// Convert nullable TimeOfDay to formatted string
  String convertToString({
    bool showSeconds = false,
    bool showUtcSymbol = false,
    bool preferUtcSymbolThanZ = false,
    bool showSeparatorSymbol = true,
    bool use24HourFormat = true,
  }) {
    if (this != null) {
      return this!.convertToStringTime(
        showSeconds: showSeconds,
        showUtcSymbol: showUtcSymbol,
        preferUtcSymbolThanZ: preferUtcSymbolThanZ,
        showSeparatorSymbol: showSeparatorSymbol,
        use24HourFormat: use24HourFormat,
      );
    } else {
      debugPrint("the Duration to convert to DateTime is NULL");
      return "Null Duration";
    }
  }

  /// Convert nullable time into decimal of hour
  double convertTimeIntoDecimalOfHour([int decimalPoint = 1]) {
    if (this != null) {
      return (this!.hour + this!.minute / 60)
          .roundDoubleToDecimalPlace(decimalPoint);
    }
    return 0.0;
  }

  /// Convert nullable TimeOfDay to DateTime on a specific date
  DateTime? toDateTime(DateTime date, {bool isUtc = true}) {
    if (this != null) {
      return this!.toDateTime(date, isUtc: isUtc);
    } else {
      debugPrint("the TimeOfDay to convert to DateTime is NULL");
      return null;
    }
  }

  /// Add minutes to nullable TimeOfDay
  TimeOfDay? addMinutes(int minutes) {
    if (this != null) {
      return this!.addMinutes(minutes);
    }
    return null;
  }

  /// Subtract minutes from nullable TimeOfDay
  TimeOfDay? subtractMinutes(int minutes) {
    if (this != null) {
      return this!.subtractMinutes(minutes);
    }
    return null;
  }

  /// Check if nullable time is before another time
  bool? isBefore(TimeOfDay? other) {
    if (this != null && other != null) {
      return this!.isBefore(other);
    }
    return null;
  }

  /// Check if nullable time is after another time
  bool? isAfter(TimeOfDay? other) {
    if (this != null && other != null) {
      return this!.isAfter(other);
    }
    return null;
  }

  /// Get difference in minutes between two nullable TimeOfDay instances
  int? differenceInMinutes(TimeOfDay? other) {
    if (this != null && other != null) {
      return this!.differenceInMinutes(other);
    }
    return null;
  }

  /// Get total minutes since midnight for nullable TimeOfDay
  int? get totalMinutes {
    if (this != null) {
      return this!.totalMinutes;
    }
    return null;
  }

  /// Convert nullable TimeOfDay to ATC time format
  String? toAtcTimeString({bool withSeparator = false}) {
    if (this != null) {
      return this!.toAtcTimeString(withSeparator: withSeparator);
    }
    return null;
  }

  /// Check if nullable TimeOfDay is AM
  bool? get isAM {
    if (this != null) {
      return this!.isAM;
    }
    return null;
  }

  /// Check if nullable TimeOfDay is PM
  bool? get isPM {
    if (this != null) {
      return this!.isPM;
    }
    return null;
  }
}

//******************************************************* */

extension ListOfTimeOfDayExtensions on List<TimeOfDay> {
  /// Convert list of TimeOfDay to list of strings
  List<String> convertToStringList({
    bool showSeconds = false,
    bool showUtcSymbol = false,
    bool preferUtcSymbolThanZ = false,
    bool showSeparatorSymbol = true,
    bool use24HourFormat = true,
  }) {
    List<String> stringList = [];
    for (var element in this) {
      stringList.add(element.convertToStringTime(
        showSeconds: showSeconds,
        showUtcSymbol: showUtcSymbol,
        preferUtcSymbolThanZ: preferUtcSymbolThanZ,
        showSeparatorSymbol: showSeparatorSymbol,
        use24HourFormat: use24HourFormat,
      ));
    }
    return stringList;
  }

  /// Sort TimeOfDay list chronologically
  List<TimeOfDay> sortChronologically() {
    sort((a, b) {
      if (a.hour != b.hour) {
        return a.hour.compareTo(b.hour);
      }
      return a.minute.compareTo(b.minute);
    });
    return this;
  }

  /// Find earliest time in the list
  TimeOfDay? get earliest {
    if (isEmpty) return null;
    TimeOfDay earliest = first;
    for (var time in this) {
      if (time.isBefore(earliest)) {
        earliest = time;
      }
    }
    return earliest;
  }

  /// Find latest time in the list
  TimeOfDay? get latest {
    if (isEmpty) return null;
    TimeOfDay latest = first;
    for (var time in this) {
      if (time.isAfter(latest)) {
        latest = time;
      }
    }
    return latest;
  }

  /// Convert all TimeOfDay to DateTime on a specific date
  List<DateTime> toDateTimeList(DateTime date, {bool isUtc = true}) {
    return map((time) => time.toDateTime(date, isUtc: isUtc)).toList();
  }
}

//******************************************************* */

extension StringTimeToTimeOfDay on String {
  /// Convert HH:MM or HHMM string to TimeOfDay
  TimeOfDay convertHHMMTimeStringToTimeOfDay() {
    final raw = trim();
    bool isNumeric(String s) =>
        s.isNotEmpty && s.codeUnits.every((c) => c >= 48 && c <= 57);

    String hourStr;
    String minuteStr;

    if (raw.contains(':')) {
      final parts = raw.split(':');
      if (parts.length != 2) {
        throw const FormatException(
            'Unrecognized time format. Expected HH:MM or HHMM');
      }
      hourStr = parts[0];
      minuteStr = parts[1];
    } else {
      // Expect HHMM or HMM (e.g. 930 for 9:30, 1230 for 12:30)
      if (raw.length < 3 || raw.length > 4) {
        throw const FormatException(
            'Unrecognized time format. Expected HH:MM or HHMM');
      }
      hourStr = raw.substring(0, raw.length - 2);
      minuteStr = raw.substring(raw.length - 2);
    }

    if (!isNumeric(hourStr) || !isNumeric(minuteStr)) {
      throw const FormatException(
          'Unrecognized time format. Expected digits only');
    }
    if (hourStr.length > 2 || minuteStr.length != 2) {
      throw const FormatException(
          'Unrecognized time format. Expected HH:MM or HHMM');
    }

    final hour = int.parse(hourStr);
    final minute = int.parse(minuteStr);

    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Convert 12-hour format string (e.g., "2:30 PM") to TimeOfDay
  TimeOfDay convertTo12HourTimeOfDay() {
    final raw = trim().toUpperCase();
    bool isNumeric(String s) =>
        s.isNotEmpty && s.codeUnits.every((c) => c >= 48 && c <= 57);

    if (!(raw.endsWith('AM') || raw.endsWith('PM'))) {
      throw const FormatException(
          'Invalid 12-hour time format. Expected format: H:MM AM/PM');
    }

    final period = raw.substring(raw.length - 2); // AM or PM
    String timePart = raw.substring(0, raw.length - 2).trim(); // remove period

    if (!timePart.contains(':')) {
      throw const FormatException(
          'Invalid 12-hour time format. Missing colon.');
    }
    final parts = timePart.split(':');
    if (parts.length != 2) {
      throw const FormatException(
          'Invalid 12-hour time format. Expected single colon.');
    }

    final hourStr = parts[0];
    final minuteStr = parts[1];
    if (!isNumeric(hourStr) ||
        !isNumeric(minuteStr) ||
        minuteStr.length != 2 ||
        hourStr.length > 2) {
      throw const FormatException(
          'Invalid 12-hour time format. Non-numeric components.');
    }
    int hour = int.parse(hourStr);
    int minute = int.parse(minuteStr);

    // Convert to 24-hour format
    if (period == 'AM') {
      if (hour == 12) hour = 0; // 12 AM is 00:00
    } else {
      // PM
      if (hour != 12) hour += 12; // Add 12 except for 12 PM
    }

    return TimeOfDay(hour: hour, minute: minute);
  }
}

//******************************************************* */

extension MapStringTimeOfDayJsonExtension on Map<String, TimeOfDay> {
  String toJson() {
    Map<String, String> jsonMap = {};
    forEach((key, value) {
      jsonMap[key] = value.toJson();
    });
    return (jsonMap as Map<String, dynamic>).beautifiedJson;
  }

  static Map<String, TimeOfDay> fromJson(String json) {
    Map<String, dynamic> jsonMap = json.decodeBeautifiedJsonMap;
    return jsonMap
        .map((key, value) => MapEntry(key, TimeOfDayExtension.fromJson(value)));
  }
}

//*************************************************** */

class MyFocusManager {
  static FocusNode? getCurrentFocus() {
    return FocusManager.instance.primaryFocus;
  }
}

//******************************************************* */

class TfcParameters {
  TextEditingController tfc = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>(debugLabel: Xid.string());
  FocusNode focusNode = FocusNode();
  TfcParameters();

  //email field validator
  static bool callTfcValidator(GlobalKey<FormState> formKey) {
    //emailInputValidationKey.state.currentState!.validate() will execute the validator function of the formfield the key of formstate is attached to

    if (formKey.currentState == null) {
      return false;
    }
    return formKey.currentState!.validate();
  }

  static bool? callTfcNullableValidator(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate();
  }

  static void resetTfcValidator(GlobalKey<FormState> formKey) =>
      formKey.currentState!.reset();
}

//********************************** */

class LoginCredentials {
  String email;
  String pwd;

  LoginCredentials(
      {this.email = '', this.pwd = ''}); // Constructor with default values
}

//********************************** */

void mydebugPrint(String log) {
  debugPrint(log, wrapWidth: 1024);
}

//********************************** */

/// Extension on int to create EdgeInsetsGeometry with fluent syntax
extension EdgeInsetsInt on int {
  /// Creates EdgeInsets with all sides equal to this value
  EdgeInsets get allPad => EdgeInsets.all(toDouble());

  /// Creates EdgeInsets with only left padding
  EdgeInsets get leftPad => EdgeInsets.only(left: toDouble());

  /// Creates EdgeInsets with only right padding
  EdgeInsets get rightPad => EdgeInsets.only(right: toDouble());

  /// Creates EdgeInsets with only top padding
  EdgeInsets get topPad => EdgeInsets.only(top: toDouble());

  /// Creates EdgeInsets with only bottom padding
  EdgeInsets get bottomPad => EdgeInsets.only(bottom: toDouble());

  /// Creates EdgeInsets with horizontal (left and right) sides equal to this value
  EdgeInsets get horiPad => EdgeInsets.symmetric(horizontal: toDouble());

  /// Creates EdgeInsets with vertical (top and bottom) sides equal to this value
  EdgeInsets get vertPad => EdgeInsets.symmetric(vertical: toDouble());
}

/// Extension on double to create EdgeInsetsGeometry with fluent syntax
extension EdgeInsetsDouble on double {
  /// Creates EdgeInsets with all sides equal to this value
  EdgeInsets get allPad => EdgeInsets.all(this);

  /// Creates EdgeInsets with only left padding
  EdgeInsets get leftPad => EdgeInsets.only(left: this);

  /// Creates EdgeInsets with only right padding
  EdgeInsets get rightPad => EdgeInsets.only(right: this);

  /// Creates EdgeInsets with only top padding
  EdgeInsets get topPad => EdgeInsets.only(top: this);

  /// Creates EdgeInsets with only bottom padding
  EdgeInsets get bottomPad => EdgeInsets.only(bottom: this);

  /// Creates EdgeInsets with horizontal (left and right) sides equal to this value
  EdgeInsets get horiPad => EdgeInsets.symmetric(horizontal: this);

  /// Creates EdgeInsets with vertical (top and bottom) sides equal to this value
  EdgeInsets get vertPad => EdgeInsets.symmetric(vertical: this);
}

/// Fluent EdgeInsets class that extends EdgeInsets and supports chaining
class FluentEdgeInsets extends EdgeInsets {
  final List<double> _tupleValues;
  final int _currentIndex;
  final double _leftValue;
  final double _topValue;
  final double _rightValue;
  final double _bottomValue;

  const FluentEdgeInsets._fromTuple(this._tupleValues)
      : _currentIndex = 0,
        _leftValue = 0,
        _topValue = 0,
        _rightValue = 0,
        _bottomValue = 0,
        super.all(0);

  const FluentEdgeInsets._withValues({
    required super.left,
    required super.top,
    required super.right,
    required super.bottom,
    required List<double> tupleValues,
    required int currentIndex,
  })  : _tupleValues = tupleValues,
        _currentIndex = currentIndex,
        _leftValue = left,
        _topValue = top,
        _rightValue = right,
        _bottomValue = bottom,
        super.only();

  FluentEdgeInsets _withLeft() {
    if (_currentIndex < _tupleValues.length) {
      return FluentEdgeInsets._withValues(
        left: _tupleValues[_currentIndex],
        top: _topValue,
        right: _rightValue,
        bottom: _bottomValue,
        tupleValues: _tupleValues,
        currentIndex: _currentIndex + 1,
      );
    }
    return this;
  }

  FluentEdgeInsets _withRight() {
    if (_currentIndex < _tupleValues.length) {
      return FluentEdgeInsets._withValues(
        left: _leftValue,
        top: _topValue,
        right: _tupleValues[_currentIndex],
        bottom: _bottomValue,
        tupleValues: _tupleValues,
        currentIndex: _currentIndex + 1,
      );
    }
    return this;
  }

  FluentEdgeInsets _withTop() {
    if (_currentIndex < _tupleValues.length) {
      return FluentEdgeInsets._withValues(
        left: _leftValue,
        top: _tupleValues[_currentIndex],
        right: _rightValue,
        bottom: _bottomValue,
        tupleValues: _tupleValues,
        currentIndex: _currentIndex + 1,
      );
    }
    return this;
  }

  FluentEdgeInsets _withBottom() {
    if (_currentIndex < _tupleValues.length) {
      return FluentEdgeInsets._withValues(
        left: _leftValue,
        top: _topValue,
        right: _rightValue,
        bottom: _tupleValues[_currentIndex],
        tupleValues: _tupleValues,
        currentIndex: _currentIndex + 1,
      );
    }
    return this;
  }

  /// Chainable getters that use next value from tuple
  FluentEdgeInsets get leftPad => _withLeft();
  FluentEdgeInsets get rightPad => _withRight();
  FluentEdgeInsets get topPad => _withTop();
  FluentEdgeInsets get bottomPad => _withBottom();
}

/// Extension on 2-value tuple for EdgeInsets with different values like (12, 15).leftPad.rightPad
extension EdgeInsetsTuple2 on (num, num) {
  /// Apply first value to left, can be chained to apply second value to next direction
  FluentEdgeInsets get leftPad =>
      FluentEdgeInsets._fromTuple([this.$1.toDouble(), this.$2.toDouble()])
          ._withLeft();

  /// Apply first value to right, can be chained to apply second value to next direction
  FluentEdgeInsets get rightPad =>
      FluentEdgeInsets._fromTuple([this.$1.toDouble(), this.$2.toDouble()])
          ._withRight();

  /// Apply first value to top, can be chained to apply second value to next direction
  FluentEdgeInsets get topPad =>
      FluentEdgeInsets._fromTuple([this.$1.toDouble(), this.$2.toDouble()])
          ._withTop();

  /// Apply first value to bottom, can be chained to apply second value to next direction
  FluentEdgeInsets get bottomPad =>
      FluentEdgeInsets._fromTuple([this.$1.toDouble(), this.$2.toDouble()])
          ._withBottom();
}

/// Extension on 3-value tuple for EdgeInsets like (12, 15, 20).leftPad.rightPad.bottomPad
extension EdgeInsetsTuple3 on (num, num, num) {
  /// Apply first value to left, can be chained to apply subsequent values
  FluentEdgeInsets get leftPad => FluentEdgeInsets._fromTuple(
      [this.$1.toDouble(), this.$2.toDouble(), this.$3.toDouble()])._withLeft();

  /// Apply first value to right, can be chained to apply subsequent values
  FluentEdgeInsets get rightPad => FluentEdgeInsets._fromTuple(
          [this.$1.toDouble(), this.$2.toDouble(), this.$3.toDouble()])
      ._withRight();

  /// Apply first value to top, can be chained to apply subsequent values
  FluentEdgeInsets get topPad => FluentEdgeInsets._fromTuple(
      [this.$1.toDouble(), this.$2.toDouble(), this.$3.toDouble()])._withTop();

  /// Apply first value to bottom, can be chained to apply subsequent values
  FluentEdgeInsets get bottomPad => FluentEdgeInsets._fromTuple(
          [this.$1.toDouble(), this.$2.toDouble(), this.$3.toDouble()])
      ._withBottom();
}

/// Extension on 4-value tuple for EdgeInsets like (12, 15, 20, 8).leftPad.rightPad.bottomPad.topPad
extension EdgeInsetsTuple4 on (num, num, num, num) {
  /// Apply first value to left, can be chained to apply subsequent values
  FluentEdgeInsets get leftPad => FluentEdgeInsets._fromTuple([
        this.$1.toDouble(),
        this.$2.toDouble(),
        this.$3.toDouble(),
        this.$4.toDouble()
      ])._withLeft();

  /// Apply first value to right, can be chained to apply subsequent values
  FluentEdgeInsets get rightPad => FluentEdgeInsets._fromTuple([
        this.$1.toDouble(),
        this.$2.toDouble(),
        this.$3.toDouble(),
        this.$4.toDouble()
      ])._withRight();

  /// Apply first value to top, can be chained to apply subsequent values
  FluentEdgeInsets get topPad => FluentEdgeInsets._fromTuple([
        this.$1.toDouble(),
        this.$2.toDouble(),
        this.$3.toDouble(),
        this.$4.toDouble()
      ])._withTop();

  /// Apply first value to bottom, can be chained to apply subsequent values
  FluentEdgeInsets get bottomPad => FluentEdgeInsets._fromTuple([
        this.$1.toDouble(),
        this.$2.toDouble(),
        this.$3.toDouble(),
        this.$4.toDouble()
      ])._withBottom();
}

/// Internal builder class to support chaining syntax like 12.left.bottom
class EdgeInsetsBuilder {
  double _left = 0;
  double _top = 0;
  double _right = 0;
  double _bottom = 0;

  EdgeInsetsBuilder();

  /// Adds left padding and returns builder for chaining
  EdgeInsetsBuilder withLeft(double value) {
    _left = value;
    return this;
  }

  /// Adds right padding and returns builder for chaining
  EdgeInsetsBuilder withRight(double value) {
    _right = value;
    return this;
  }

  /// Adds top padding and returns builder for chaining
  EdgeInsetsBuilder withTop(double value) {
    _top = value;
    return this;
  }

  /// Adds bottom padding and returns builder for chaining
  EdgeInsetsBuilder withBottom(double value) {
    _bottom = value;
    return this;
  }

  /// Chainable getters with new naming
  EdgeInsetsBuilder get leftPad => withLeft(_left > 0 ? _left : 0);
  EdgeInsetsBuilder get rightPad => withRight(_right > 0 ? _right : 0);
  EdgeInsetsBuilder get topPad => withTop(_top > 0 ? _top : 0);
  EdgeInsetsBuilder get bottomPad => withBottom(_bottom > 0 ? _bottom : 0);

  /// Implicit conversion to EdgeInsets
  EdgeInsets toEdgeInsets() => EdgeInsets.only(
        left: _left,
        top: _top,
        right: _right,
        bottom: _bottom,
      );

  /// Call operator to make builder callable and return EdgeInsets
  EdgeInsets call() => toEdgeInsets();
}

/// Extension to allow implicit conversion from builder to EdgeInsets
extension EdgeInsetsBuilderConversion on EdgeInsetsBuilder {
  /// Converts builder to EdgeInsets
  EdgeInsets get insets => toEdgeInsets();

  /// Allows implicit conversion to EdgeInsetsGeometry
  EdgeInsetsGeometry get geometry => toEdgeInsets();

  /// Allows chaining with new value for left padding
  EdgeInsetsBuilder leftPadWith(double value) => EdgeInsetsBuilder()
      .withLeft(value)
      .withRight(_right)
      .withTop(_top)
      .withBottom(_bottom);

  /// Allows chaining with new value for right padding
  EdgeInsetsBuilder rightPadWith(double value) => EdgeInsetsBuilder()
      .withLeft(_left)
      .withRight(value)
      .withTop(_top)
      .withBottom(_bottom);

  /// Allows chaining with new value for top padding
  EdgeInsetsBuilder topPadWith(double value) => EdgeInsetsBuilder()
      .withLeft(_left)
      .withRight(_right)
      .withTop(value)
      .withBottom(_bottom);

  /// Allows chaining with new value for bottom padding
  EdgeInsetsBuilder bottomPadWith(double value) => EdgeInsetsBuilder()
      .withLeft(_left)
      .withRight(_right)
      .withTop(_top)
      .withBottom(value);
}

/// Extension on EdgeInsetsGeometry to allow chaining of insets
extension EdgeInsetsGeometryChaining on EdgeInsetsGeometry {
  /// Adds left padding to existing EdgeInsetsGeometry
  EdgeInsetsGeometry addLeft(double value) {
    return EdgeInsetsDirectional.only(start: value).add(this);
  }

  /// Adds right padding to existing EdgeInsetsGeometry
  EdgeInsetsGeometry addRight(double value) {
    return EdgeInsetsDirectional.only(end: value).add(this);
  }

  /// Adds top padding to existing EdgeInsetsGeometry
  EdgeInsetsGeometry addTop(double value) {
    return EdgeInsets.only(top: value).add(this);
  }

  /// Adds bottom padding to existing EdgeInsetsGeometry
  EdgeInsetsGeometry addBottom(double value) {
    return EdgeInsets.only(bottom: value).add(this);
  }

  /// Adds horizontal padding to existing EdgeInsetsGeometry
  EdgeInsetsGeometry addHorizontal(double value) {
    return EdgeInsets.symmetric(horizontal: value).add(this);
  }

  /// Adds vertical padding to existing EdgeInsetsGeometry
  EdgeInsetsGeometry addVertical(double value) {
    return EdgeInsets.symmetric(vertical: value).add(this);
  }

  // Chainable getters for fluent syntax like someInset.left.bottom
  /// Adds left padding to existing EdgeInsetsGeometry (chainable)
  EdgeInsetsGeometry get left {
    return EdgeInsetsDirectional.only(start: 0).add(this);
  }

  /// Adds right padding to existing EdgeInsetsGeometry (chainable)
  EdgeInsetsGeometry get right {
    return EdgeInsetsDirectional.only(end: 0).add(this);
  }

  /// Adds top padding to existing EdgeInsetsGeometry (chainable)
  EdgeInsetsGeometry get top {
    return EdgeInsets.only(top: 0).add(this);
  }

  /// Adds bottom padding to existing EdgeInsetsGeometry (chainable)
  EdgeInsetsGeometry get bottom {
    return EdgeInsets.only(bottom: 0).add(this);
  }
}

/// Extension on EdgeInsets to allow fluent chaining and modification
extension EdgeInsetsChaining on EdgeInsets {
  /// Creates new EdgeInsets with specified left padding
  EdgeInsets withLeft(double value) => copyWith(left: value);

  /// Creates new EdgeInsets with specified top padding
  EdgeInsets withTop(double value) => copyWith(top: value);

  /// Creates new EdgeInsets with specified right padding
  EdgeInsets withRight(double value) => copyWith(right: value);

  /// Creates new EdgeInsets with specified bottom padding
  EdgeInsets withBottom(double value) => copyWith(bottom: value);

  /// Adds the specified value to the existing left padding
  EdgeInsets addToLeft(double value) => copyWith(left: this.left + value);

  /// Adds the specified value to the existing top padding
  EdgeInsets addToTop(double value) => copyWith(top: top + value);

  /// Adds the specified value to the existing right padding
  EdgeInsets addToRight(double value) => copyWith(right: this.right + value);

  /// Adds the specified value to the existing bottom padding
  EdgeInsets addToBottom(double value) => copyWith(bottom: bottom + value);

  /// Allows implicit conversion to EdgeInsetsGeometry
  EdgeInsetsGeometry get geometry => this;

  /// Chainable padding extensions that use the first non-zero padding value as base
  EdgeInsets get leftPad {
    double baseValue = this.left > 0
        ? this.left
        : (this.right > 0 ? this.right : (top > 0 ? top : bottom));
    return copyWith(left: baseValue);
  }

  EdgeInsets get rightPad {
    double baseValue = this.left > 0
        ? this.left
        : (this.right > 0 ? this.right : (top > 0 ? top : bottom));
    return copyWith(right: baseValue);
  }

  EdgeInsets get topPad {
    double baseValue = this.left > 0
        ? this.left
        : (this.right > 0 ? this.right : (top > 0 ? top : bottom));
    return copyWith(top: baseValue);
  }

  EdgeInsets get bottomPad {
    double baseValue = this.left > 0
        ? this.left
        : (this.right > 0 ? this.right : (top > 0 ? top : bottom));
    return copyWith(bottom: baseValue);
  }
}

/// Extension on EdgeInsetsDirectional to allow fluent chaining and modification
extension EdgeInsetsDirectionalChaining on EdgeInsetsDirectional {
  /// Creates new EdgeInsetsDirectional with specified start padding
  EdgeInsetsDirectional withLeft(double value) => copyWith(start: value);

  /// Creates new EdgeInsetsDirectional with specified end padding
  EdgeInsetsDirectional withRight(double value) => copyWith(end: value);

  /// Creates new EdgeInsetsDirectional with specified top padding
  EdgeInsetsDirectional withTop(double value) => copyWith(top: value);

  /// Creates new EdgeInsetsDirectional with specified bottom padding
  EdgeInsetsDirectional withBottom(double value) => copyWith(bottom: value);

  /// Adds the specified value to the existing start padding
  EdgeInsetsDirectional addToLeft(double value) =>
      copyWith(start: start + value);

  /// Adds the specified value to the existing end padding
  EdgeInsetsDirectional addToRight(double value) => copyWith(end: end + value);

  /// Adds the specified value to the existing top padding
  EdgeInsetsDirectional addToTop(double value) => copyWith(top: top + value);

  /// Adds the specified value to the existing bottom padding
  EdgeInsetsDirectional addToBottom(double value) =>
      copyWith(bottom: bottom + value);
}

//********************************** */

/// Extension on int to create BorderRadius with fluent syntax
extension BorderRadiusInt on int {
  /// Creates BorderRadius with all corners equal to this value
  BorderRadius get allRad => BorderRadius.circular(toDouble());

  /// Creates BorderRadius with only topLeft radius
  BorderRadius get tLeftRad =>
      BorderRadius.only(topLeft: Radius.circular(toDouble()));

  /// Creates BorderRadius with only topRight radius
  BorderRadius get tRightRad =>
      BorderRadius.only(topRight: Radius.circular(toDouble()));

  /// Creates BorderRadius with only bottomLeft radius
  BorderRadius get bLeftRad =>
      BorderRadius.only(bottomLeft: Radius.circular(toDouble()));

  /// Creates BorderRadius with only bottomRight radius
  BorderRadius get bRightRad =>
      BorderRadius.only(bottomRight: Radius.circular(toDouble()));

  /// Creates BorderRadius with top corners (topLeft and topRight) equal to this value
  BorderRadius get topRad => BorderRadius.only(
        topLeft: Radius.circular(toDouble()),
        topRight: Radius.circular(toDouble()),
      );

  /// Creates BorderRadius with bottom corners (bottomLeft and bottomRight) equal to this value
  BorderRadius get bottomRad => BorderRadius.only(
        bottomLeft: Radius.circular(toDouble()),
        bottomRight: Radius.circular(toDouble()),
      );

  /// Creates BorderRadius with left corners (topLeft and bottomLeft) equal to this value
  BorderRadius get leftRad => BorderRadius.only(
        topLeft: Radius.circular(toDouble()),
        bottomLeft: Radius.circular(toDouble()),
      );

  /// Creates BorderRadius with right corners (topRight and bottomRight) equal to this value
  BorderRadius get rightRad => BorderRadius.only(
        topRight: Radius.circular(toDouble()),
        bottomRight: Radius.circular(toDouble()),
      );
}

/// Extension on double to create BorderRadius with fluent syntax
extension BorderRadiusDouble on double {
  /// Creates BorderRadius with all corners equal to this value
  BorderRadius get allRad => BorderRadius.circular(this);

  /// Creates BorderRadius with only topLeft radius
  BorderRadius get tLeftRad =>
      BorderRadius.only(topLeft: Radius.circular(this));

  /// Creates BorderRadius with only topRight radius
  BorderRadius get tRightRad =>
      BorderRadius.only(topRight: Radius.circular(this));

  /// Creates BorderRadius with only bottomLeft radius
  BorderRadius get bLeftRad =>
      BorderRadius.only(bottomLeft: Radius.circular(this));

  /// Creates BorderRadius with only bottomRight radius
  BorderRadius get bRightRad =>
      BorderRadius.only(bottomRight: Radius.circular(this));

  /// Creates BorderRadius with top corners (topLeft and topRight) equal to this value
  BorderRadius get topRad => BorderRadius.only(
        topLeft: Radius.circular(this),
        topRight: Radius.circular(this),
      );

  /// Creates BorderRadius with bottom corners (bottomLeft and bottomRight) equal to this value
  BorderRadius get bottomRad => BorderRadius.only(
        bottomLeft: Radius.circular(this),
        bottomRight: Radius.circular(this),
      );

  /// Creates BorderRadius with left corners (topLeft and bottomLeft) equal to this value
  BorderRadius get leftRad => BorderRadius.only(
        topLeft: Radius.circular(this),
        bottomLeft: Radius.circular(this),
      );

  /// Creates BorderRadius with right corners (topRight and bottomRight) equal to this value
  BorderRadius get rightRad => BorderRadius.only(
        topRight: Radius.circular(this),
        bottomRight: Radius.circular(this),
      );
}

/// Fluent BorderRadius class that extends BorderRadius and supports chaining
class FluentBorderRadius extends BorderRadius {
  final List<double> _tupleValues;
  final int _currentIndex;
  final double _topLeftValue;
  final double _topRightValue;
  final double _bottomLeftValue;
  final double _bottomRightValue;

  const FluentBorderRadius._fromTuple(this._tupleValues)
      : _currentIndex = 0,
        _topLeftValue = 0,
        _topRightValue = 0,
        _bottomLeftValue = 0,
        _bottomRightValue = 0,
        super.all(Radius.zero);

  FluentBorderRadius._withValues({
    required double topLeft,
    required double topRight,
    required double bottomLeft,
    required double bottomRight,
    required List<double> tupleValues,
    required int currentIndex,
  })  : _tupleValues = tupleValues,
        _currentIndex = currentIndex,
        _topLeftValue = topLeft,
        _topRightValue = topRight,
        _bottomLeftValue = bottomLeft,
        _bottomRightValue = bottomRight,
        super.only(
          topLeft: Radius.circular(topLeft),
          topRight: Radius.circular(topRight),
          bottomLeft: Radius.circular(bottomLeft),
          bottomRight: Radius.circular(bottomRight),
        );

  FluentBorderRadius _withTopLeft() {
    if (_currentIndex < _tupleValues.length) {
      return FluentBorderRadius._withValues(
        topLeft: _tupleValues[_currentIndex],
        topRight: _topRightValue,
        bottomLeft: _bottomLeftValue,
        bottomRight: _bottomRightValue,
        tupleValues: _tupleValues,
        currentIndex: _currentIndex + 1,
      );
    }
    return this;
  }

  FluentBorderRadius _withTopRight() {
    if (_currentIndex < _tupleValues.length) {
      return FluentBorderRadius._withValues(
        topLeft: _topLeftValue,
        topRight: _tupleValues[_currentIndex],
        bottomLeft: _bottomLeftValue,
        bottomRight: _bottomRightValue,
        tupleValues: _tupleValues,
        currentIndex: _currentIndex + 1,
      );
    }
    return this;
  }

  FluentBorderRadius _withBottomLeft() {
    if (_currentIndex < _tupleValues.length) {
      return FluentBorderRadius._withValues(
        topLeft: _topLeftValue,
        topRight: _topRightValue,
        bottomLeft: _tupleValues[_currentIndex],
        bottomRight: _bottomRightValue,
        tupleValues: _tupleValues,
        currentIndex: _currentIndex + 1,
      );
    }
    return this;
  }

  FluentBorderRadius _withBottomRight() {
    if (_currentIndex < _tupleValues.length) {
      return FluentBorderRadius._withValues(
        topLeft: _topLeftValue,
        topRight: _topRightValue,
        bottomLeft: _bottomLeftValue,
        bottomRight: _tupleValues[_currentIndex],
        tupleValues: _tupleValues,
        currentIndex: _currentIndex + 1,
      );
    }
    return this;
  }

  /// Chainable getters that use next value from tuple
  FluentBorderRadius get tLeftRad => _withTopLeft();
  FluentBorderRadius get tRightRad => _withTopRight();
  FluentBorderRadius get bLeftRad => _withBottomLeft();
  FluentBorderRadius get bRightRad => _withBottomRight();
}

/// Extension on 2-value tuple for BorderRadius with different values like (8, 12).tLeftRad.bRightRad
extension BorderRadiusTuple2 on (num, num) {
  /// Apply first value to top-left, can be chained to apply second value to next corner
  FluentBorderRadius get tLeftRad =>
      FluentBorderRadius._fromTuple([this.$1.toDouble(), this.$2.toDouble()])
          ._withTopLeft();

  /// Apply first value to top-right, can be chained to apply second value to next corner
  FluentBorderRadius get tRightRad =>
      FluentBorderRadius._fromTuple([this.$1.toDouble(), this.$2.toDouble()])
          ._withTopRight();

  /// Apply first value to bottom-left, can be chained to apply second value to next corner
  FluentBorderRadius get bLeftRad =>
      FluentBorderRadius._fromTuple([this.$1.toDouble(), this.$2.toDouble()])
          ._withBottomLeft();

  /// Apply first value to bottom-right, can be chained to apply second value to next corner
  FluentBorderRadius get bRightRad =>
      FluentBorderRadius._fromTuple([this.$1.toDouble(), this.$2.toDouble()])
          ._withBottomRight();
}

/// Extension on 3-value tuple for BorderRadius like (8, 12, 16).tLeftRad.tRightRad.bLeftRad
extension BorderRadiusTuple3 on (num, num, num) {
  /// Apply first value to top-left, can be chained to apply subsequent values
  FluentBorderRadius get tLeftRad => FluentBorderRadius._fromTuple(
          [this.$1.toDouble(), this.$2.toDouble(), this.$3.toDouble()])
      ._withTopLeft();

  /// Apply first value to top-right, can be chained to apply subsequent values
  FluentBorderRadius get tRightRad => FluentBorderRadius._fromTuple(
          [this.$1.toDouble(), this.$2.toDouble(), this.$3.toDouble()])
      ._withTopRight();

  /// Apply first value to bottom-left, can be chained to apply subsequent values
  FluentBorderRadius get bLeftRad => FluentBorderRadius._fromTuple(
          [this.$1.toDouble(), this.$2.toDouble(), this.$3.toDouble()])
      ._withBottomLeft();

  /// Apply first value to bottom-right, can be chained to apply subsequent values
  FluentBorderRadius get bRightRad => FluentBorderRadius._fromTuple(
          [this.$1.toDouble(), this.$2.toDouble(), this.$3.toDouble()])
      ._withBottomRight();
}

/// Extension on 4-value tuple for BorderRadius like (8, 12, 16, 20).tLeftRad.tRightRad.bLeftRad.bRightRad
extension BorderRadiusTuple4 on (num, num, num, num) {
  /// Apply first value to top-left, can be chained to apply subsequent values
  FluentBorderRadius get tLeftRad => FluentBorderRadius._fromTuple([
        this.$1.toDouble(),
        this.$2.toDouble(),
        this.$3.toDouble(),
        this.$4.toDouble()
      ])._withTopLeft();

  /// Apply first value to top-right, can be chained to apply subsequent values
  FluentBorderRadius get tRightRad => FluentBorderRadius._fromTuple([
        this.$1.toDouble(),
        this.$2.toDouble(),
        this.$3.toDouble(),
        this.$4.toDouble()
      ])._withTopRight();

  /// Apply first value to bottom-left, can be chained to apply subsequent values
  FluentBorderRadius get bLeftRad => FluentBorderRadius._fromTuple([
        this.$1.toDouble(),
        this.$2.toDouble(),
        this.$3.toDouble(),
        this.$4.toDouble()
      ])._withBottomLeft();

  /// Apply first value to bottom-right, can be chained to apply subsequent values
  FluentBorderRadius get bRightRad => FluentBorderRadius._fromTuple([
        this.$1.toDouble(),
        this.$2.toDouble(),
        this.$3.toDouble(),
        this.$4.toDouble()
      ])._withBottomRight();
}

/// Internal builder class to support chaining syntax like 12.tLeftRad.bRightRad
class BorderRadiusBuilder {
  double _topLeft = 0;
  double _topRight = 0;
  double _bottomLeft = 0;
  double _bottomRight = 0;

  BorderRadiusBuilder();

  /// Adds topLeft radius and returns builder for chaining
  BorderRadiusBuilder withTopLeft(double value) {
    _topLeft = value;
    return this;
  }

  /// Adds topRight radius and returns builder for chaining
  BorderRadiusBuilder withTopRight(double value) {
    _topRight = value;
    return this;
  }

  /// Adds bottomLeft radius and returns builder for chaining
  BorderRadiusBuilder withBottomLeft(double value) {
    _bottomLeft = value;
    return this;
  }

  /// Adds bottomRight radius and returns builder for chaining
  BorderRadiusBuilder withBottomRight(double value) {
    _bottomRight = value;
    return this;
  }

  /// Chainable getters with "Rad" suffix
  BorderRadiusBuilder get tLeftRad => withTopLeft(_topLeft > 0 ? _topLeft : 0);
  BorderRadiusBuilder get tRightRad =>
      withTopRight(_topRight > 0 ? _topRight : 0);
  BorderRadiusBuilder get bLeftRad =>
      withBottomLeft(_bottomLeft > 0 ? _bottomLeft : 0);
  BorderRadiusBuilder get bRightRad =>
      withBottomRight(_bottomRight > 0 ? _bottomRight : 0);

  /// Convenience getters for multiple corners with "Rad" suffix
  BorderRadiusBuilder get topRad {
    _topLeft = _topLeft > 0 ? _topLeft : 0;
    _topRight = _topRight > 0 ? _topRight : 0;
    return this;
  }

  BorderRadiusBuilder get bottomRad {
    _bottomLeft = _bottomLeft > 0 ? _bottomLeft : 0;
    _bottomRight = _bottomRight > 0 ? _bottomRight : 0;
    return this;
  }

  BorderRadiusBuilder get leftRad {
    _topLeft = _topLeft > 0 ? _topLeft : 0;
    _bottomLeft = _bottomLeft > 0 ? _bottomLeft : 0;
    return this;
  }

  BorderRadiusBuilder get rightRad {
    _topRight = _topRight > 0 ? _topRight : 0;
    _bottomRight = _bottomRight > 0 ? _bottomRight : 0;
    return this;
  }

  /// Implicit conversion to BorderRadius
  BorderRadius toBorderRadius() => BorderRadius.only(
        topLeft: Radius.circular(_topLeft),
        topRight: Radius.circular(_topRight),
        bottomLeft: Radius.circular(_bottomLeft),
        bottomRight: Radius.circular(_bottomRight),
      );
}

/// Extension to allow implicit conversion from builder to BorderRadius
extension BorderRadiusBuilderConversion on BorderRadiusBuilder {
  /// Converts builder to BorderRadius
  BorderRadius get radius => toBorderRadius();

  /// Allows implicit conversion to BorderRadiusGeometry
  BorderRadiusGeometry get geometry => toBorderRadius();
}

/// Extension on BorderRadius to allow fluent chaining and modification
extension BorderRadiusChaining on BorderRadius {
  /// Creates new BorderRadius with specified topLeft radius
  BorderRadius withTopLeft(double value) =>
      copyWith(topLeft: Radius.circular(value));

  /// Creates new BorderRadius with specified topRight radius
  BorderRadius withTopRight(double value) =>
      copyWith(topRight: Radius.circular(value));

  /// Creates new BorderRadius with specified bottomLeft radius
  BorderRadius withBottomLeft(double value) =>
      copyWith(bottomLeft: Radius.circular(value));

  /// Creates new BorderRadius with specified bottomRight radius
  BorderRadius withBottomRight(double value) =>
      copyWith(bottomRight: Radius.circular(value));

  /// Adds the specified value to the existing topLeft radius
  BorderRadius addToTopLeft(double value) => copyWith(
        topLeft: Radius.circular(topLeft.x + value),
      );

  /// Adds the specified value to the existing topRight radius
  BorderRadius addToTopRight(double value) => copyWith(
        topRight: Radius.circular(topRight.x + value),
      );

  /// Adds the specified value to the existing bottomLeft radius
  BorderRadius addToBottomLeft(double value) => copyWith(
        bottomLeft: Radius.circular(bottomLeft.x + value),
      );

  /// Adds the specified value to the existing bottomRight radius
  BorderRadius addToBottomRight(double value) => copyWith(
        bottomRight: Radius.circular(bottomRight.x + value),
      );

  /// Allows implicit conversion to BorderRadiusGeometry
  BorderRadiusGeometry get geometry => this;

  /// Chainable radius extensions that use the first non-zero radius value as base
  BorderRadius get tLeftRad {
    double baseValue = topLeft.x > 0
        ? topLeft.x
        : (topRight.x > 0
            ? topRight.x
            : (bottomLeft.x > 0 ? bottomLeft.x : bottomRight.x));
    return copyWith(topLeft: Radius.circular(baseValue));
  }

  BorderRadius get tRightRad {
    double baseValue = topLeft.x > 0
        ? topLeft.x
        : (topRight.x > 0
            ? topRight.x
            : (bottomLeft.x > 0 ? bottomLeft.x : bottomRight.x));
    return copyWith(topRight: Radius.circular(baseValue));
  }

  BorderRadius get bLeftRad {
    double baseValue = topLeft.x > 0
        ? topLeft.x
        : (topRight.x > 0
            ? topRight.x
            : (bottomLeft.x > 0 ? bottomLeft.x : bottomRight.x));
    return copyWith(bottomLeft: Radius.circular(baseValue));
  }

  BorderRadius get bRightRad {
    double baseValue = topLeft.x > 0
        ? topLeft.x
        : (topRight.x > 0
            ? topRight.x
            : (bottomLeft.x > 0 ? bottomLeft.x : bottomRight.x));
    return copyWith(bottomRight: Radius.circular(baseValue));
  }
}

/// Convenience class for creating BorderRadius with named parameters
class Radius2 extends BorderRadius {
  /// Creates BorderRadius with all corners equal to [all], or individual corners
  Radius2({
    double all = 0.0,
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) : super.only(
          topLeft: Radius.circular(topLeft ?? top ?? left ?? all),
          topRight: Radius.circular(topRight ?? top ?? right ?? all),
          bottomLeft: Radius.circular(bottomLeft ?? bottom ?? left ?? all),
          bottomRight: Radius.circular(bottomRight ?? bottom ?? right ?? all),
        );

  /// Creates BorderRadius with all corners equal to [value]
  Radius2.all(super.value) : super.circular();

  /// Creates BorderRadius with top corners equal to [value]
  Radius2.top(double value)
      : super.only(
          topLeft: Radius.circular(value),
          topRight: Radius.circular(value),
        );

  /// Creates BorderRadius with bottom corners equal to [value]
  Radius2.bottom(double value)
      : super.only(
          bottomLeft: Radius.circular(value),
          bottomRight: Radius.circular(value),
        );

  /// Creates BorderRadius with left corners equal to [value]
  Radius2.left(double value)
      : super.only(
          topLeft: Radius.circular(value),
          bottomLeft: Radius.circular(value),
        );

  /// Creates BorderRadius with right corners equal to [value]
  Radius2.right(double value)
      : super.only(
          topRight: Radius.circular(value),
          bottomRight: Radius.circular(value),
        );

  /// Creates BorderRadius with only topLeft corner
  Radius2.topLeft(double value)
      : super.only(
          topLeft: Radius.circular(value),
        );

  /// Creates BorderRadius with only topRight corner
  Radius2.topRight(double value)
      : super.only(
          topRight: Radius.circular(value),
        );

  /// Creates BorderRadius with only bottomLeft corner
  Radius2.bottomLeft(double value)
      : super.only(
          bottomLeft: Radius.circular(value),
        );

  /// Creates BorderRadius with only bottomRight corner
  Radius2.bottomRight(double value)
      : super.only(
          bottomRight: Radius.circular(value),
        );
}

//********************************** */

/// Extension providing comparison operators for DateTime objects
/// Adds <=, >=, >, < operators for DateTime with DateTime? comparison
extension DateTimeComparisonExtensions on DateTime {
  /// Less than or equal operator for DateTime with nullable DateTime
  /// Returns false if [other] is null
  bool operator <=(DateTime? other) {
    if (other == null) return false;
    return isBefore(other) || isAtSameMomentAs(other);
  }

  /// Greater than or equal operator for DateTime with nullable DateTime
  /// Returns false if [other] is null
  bool operator >=(DateTime? other) {
    if (other == null) return false;
    return isAfter(other) || isAtSameMomentAs(other);
  }

  /// Greater than operator for DateTime with nullable DateTime
  /// Returns false if [other] is null
  bool operator >(DateTime? other) {
    if (other == null) return false;
    return isAfter(other);
  }

  /// Less than operator for DateTime with nullable DateTime
  /// Returns false if [other] is null
  bool operator <(DateTime? other) {
    if (other == null) return false;
    return isBefore(other);
  }

  /// Check if this DateTime equals another nullable DateTime
  /// Returns false if [other] is null
  bool isEqualTo(DateTime? other) {
    if (other == null) return false;
    return isAtSameMomentAs(other);
  }

  /// Check if this DateTime is between two other DateTimes (inclusive)
  /// Returns false if any of the DateTimes is null
  bool isBetween(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    return this >= start && this <= end;
  }

  /// Check if this DateTime is between two other DateTimes (exclusive)
  /// Returns false if any of the DateTimes is null
  bool isBetweenExclusive(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    return this > start && this < end;
  }
}

/// Extension providing comparison operators for nullable DateTime objects
/// Adds <=, >=, >, < operators for DateTime? with DateTime and DateTime?
extension NullableDateTimeComparisonExtensions on DateTime? {
  /// Less than or equal operator for nullable DateTime with DateTime
  /// Returns false if this is null
  bool operator <=(DateTime? other) {
    if (this == null) return false;
    if (other == null) return false;
    return this!.isBefore(other) || this!.isAtSameMomentAs(other);
  }

  /// Greater than or equal operator for nullable DateTime with DateTime
  /// Returns false if this is null
  bool operator >=(DateTime? other) {
    if (this == null) return false;
    if (other == null) return false;
    return this!.isAfter(other) || this!.isAtSameMomentAs(other);
  }

  /// Greater than operator for nullable DateTime with DateTime
  /// Returns false if this is null
  bool operator >(DateTime? other) {
    if (this == null) return false;
    if (other == null) return false;
    return this!.isAfter(other);
  }

  /// Less than operator for nullable DateTime with DateTime
  /// Returns false if this is null
  bool operator <(DateTime? other) {
    if (this == null) return false;
    if (other == null) return false;
    return this!.isBefore(other);
  }

  /// Check if this nullable DateTime equals another nullable DateTime
  /// Returns true only if both are null or both have same moment
  bool isEqualTo(DateTime? other) {
    if (other == null && this == null) return true;
    if (other == null || this == null) return false;
    return this!.isAtSameMomentAs(other);
  }

  /// Safe comparison method that returns null if either operand is null
  /// Useful when you want to explicitly handle null cases
  int? compareToSafely(DateTime? other) {
    if (this == null || other == null) return null;
    return this!.compareTo(other);
  }

  /// Check if this DateTime is between two other DateTimes (inclusive)
  /// Returns false if any of the DateTimes is null
  bool isBetween(DateTime? start, DateTime? end) {
    if (this == null || start == null || end == null) return false;
    return this! >= start && this! <= end;
  }

  /// Check if this DateTime is between two other DateTimes (exclusive)
  /// Returns false if any of the DateTimes is null
  bool isBetweenExclusive(DateTime? start, DateTime? end) {
    if (this == null || start == null || end == null) return false;
    return this! > start && this! < end;
  }
}

//********************************** */

/// Extension providing copyWith method for Alignment
extension AlignmentCopyWith on Alignment {
  /// Creates a copy of this Alignment with optionally modified x and/or y values
  ///
  /// Example usage:
  /// ```dart
  /// Alignment.center.copyWith(x: -0.5) // Creates Alignment(-0.5, 0.0)
  /// Alignment.topLeft.copyWith(y: 0.5) // Creates Alignment(-1.0, 0.5)
  /// ```
  Alignment copyWith({double? x, double? y}) {
    return Alignment(
      x ?? this.x,
      y ?? this.y,
    );
  }
}

/// Extension providing add method for Alignment
extension AlignmentAdd on Alignment {
  /// Creates a new Alignment by adding the specified x and/or y values to this alignment
  ///
  /// Example usage:
  /// ```dart
  /// Alignment.center.addOffset(x: -0.3) // Creates Alignment(0.0 - 0.3, 0.0) = Alignment(-0.3, 0.0)
  /// Alignment.topLeft.addOffset(x: 0.5, y: 0.2) // Creates Alignment(-1.0 + 0.5, -1.0 + 0.2) = Alignment(-0.5, -0.8)
  /// ```
  Alignment addOffset({double x = 0.0, double y = 0.0}) {
    return Alignment(
      this.x + x,
      this.y + y,
    );
  }
}

//********************************** */
