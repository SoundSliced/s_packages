import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week_calendar/week_calendar.dart';

void main() {
  group('WeekCalendarStyle Tests', () {
    test('WeekCalendarStyle should have default values', () {
      const style = WeekCalendarStyle();

      expect(style.monthHeaderStyle.fontSize, 18);
      expect(style.monthHeaderStyle.fontWeight, FontWeight.bold);
      expect(style.dayNameStyle.fontSize, 12);
      expect(style.dayNumberStyle.fontSize, 16);
      expect(style.selectedDayTextStyle.fontSize, 16);
      expect(style.selectedDayTextStyle.fontWeight, FontWeight.bold);
      expect(style.inactiveDayTextStyle.fontSize, 16);
      expect(style.activeDayColor, Colors.blueAccent);
      expect(style.dayIndicatorColor, Colors.transparent);
      expect(style.dayIndicatorSize, 28);
      expect(style.dayIndicatorBorder, isNull);
      expect(style.dayIndicatorShadow, isNull);
      expect(style.showParticles, false);
      expect(
          style.selectionAnimationDuration, const Duration(milliseconds: 300));
      expect(style.selectionAnimationCurve, Curves.easeOutBack);
    });

    test('WeekCalendarStyle should accept custom values', () {
      const customStyle = WeekCalendarStyle(
        monthHeaderStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        dayNameStyle: TextStyle(fontSize: 14, color: Colors.purple),
        dayNumberStyle: TextStyle(fontSize: 18, color: Colors.black),
        selectedDayTextStyle: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        inactiveDayTextStyle: TextStyle(fontSize: 16, color: Colors.grey),
        activeDayColor: Colors.purple,
        dayIndicatorColor: Colors.purple,
        dayIndicatorSize: 40,
        showParticles: true,
        selectionAnimationDuration: Duration(milliseconds: 500),
        selectionAnimationCurve: Curves.bounceOut,
      );

      expect(customStyle.monthHeaderStyle.fontSize, 24);
      expect(customStyle.monthHeaderStyle.fontWeight, FontWeight.w600);
      expect(customStyle.dayNameStyle.fontSize, 14);
      expect(customStyle.dayNameStyle.color, Colors.purple);
      expect(customStyle.dayNumberStyle.fontSize, 18);
      expect(customStyle.dayNumberStyle.color, Colors.black);
      expect(customStyle.selectedDayTextStyle.fontSize, 20);
      expect(customStyle.selectedDayTextStyle.fontWeight, FontWeight.bold);
      expect(customStyle.selectedDayTextStyle.color, Colors.white);
      expect(customStyle.inactiveDayTextStyle.fontSize, 16);
      expect(customStyle.inactiveDayTextStyle.color, Colors.grey);
      expect(customStyle.activeDayColor, Colors.purple);
      expect(customStyle.dayIndicatorColor, Colors.purple);
      expect(customStyle.dayIndicatorSize, 40);
      expect(customStyle.showParticles, true);
      expect(customStyle.selectionAnimationDuration,
          const Duration(milliseconds: 500));
      expect(customStyle.selectionAnimationCurve, Curves.bounceOut);
    });

    test('WeekCalendarStyle should accept custom border', () {
      const customBorder = Border.fromBorderSide(
        BorderSide(color: Colors.red, width: 2),
      );

      const style = WeekCalendarStyle(
        dayIndicatorBorder: customBorder,
      );

      expect(style.dayIndicatorBorder, customBorder);
      expect(style.dayIndicatorBorder!.top.color, Colors.red);
      expect(style.dayIndicatorBorder!.top.width, 2);
    });

    test('WeekCalendarStyle should accept custom shadow', () {
      const customShadow = BoxShadow(
        color: Colors.black26,
        blurRadius: 4,
        offset: Offset(0, 2),
      );

      const style = WeekCalendarStyle(
        dayIndicatorShadow: customShadow,
      );

      expect(style.dayIndicatorShadow, customShadow);
      expect(style.dayIndicatorShadow!.color, Colors.black26);
      expect(style.dayIndicatorShadow!.blurRadius, 4);
      expect(style.dayIndicatorShadow!.offset, const Offset(0, 2));
    });

    test('WeekCalendarStyle should support different animation durations', () {
      const fast = WeekCalendarStyle(
        selectionAnimationDuration: Duration(milliseconds: 100),
      );
      const slow = WeekCalendarStyle(
        selectionAnimationDuration: Duration(milliseconds: 1000),
      );

      expect(fast.selectionAnimationDuration.inMilliseconds, 100);
      expect(slow.selectionAnimationDuration.inMilliseconds, 1000);
    });

    test('WeekCalendarStyle should support different animation curves', () {
      const linear = WeekCalendarStyle(
        selectionAnimationCurve: Curves.linear,
      );
      const elastic = WeekCalendarStyle(
        selectionAnimationCurve: Curves.elasticOut,
      );
      const bounce = WeekCalendarStyle(
        selectionAnimationCurve: Curves.bounceOut,
      );

      expect(linear.selectionAnimationCurve, Curves.linear);
      expect(elastic.selectionAnimationCurve, Curves.elasticOut);
      expect(bounce.selectionAnimationCurve, Curves.bounceOut);
    });

    test('WeekCalendarStyle should support different colors', () {
      const redStyle = WeekCalendarStyle(activeDayColor: Colors.red);
      const blueStyle = WeekCalendarStyle(activeDayColor: Colors.blue);
      const greenStyle = WeekCalendarStyle(activeDayColor: Colors.green);

      expect(redStyle.activeDayColor, Colors.red);
      expect(blueStyle.activeDayColor, Colors.blue);
      expect(greenStyle.activeDayColor, Colors.green);
    });

    test('WeekCalendarStyle should support different indicator sizes', () {
      const small = WeekCalendarStyle(dayIndicatorSize: 24);
      const medium = WeekCalendarStyle(dayIndicatorSize: 32);
      const large = WeekCalendarStyle(dayIndicatorSize: 48);

      expect(small.dayIndicatorSize, 24);
      expect(medium.dayIndicatorSize, 32);
      expect(large.dayIndicatorSize, 48);
    });

    test('WeekCalendarStyle particle effect flag should work', () {
      const withParticles = WeekCalendarStyle(showParticles: true);
      const withoutParticles = WeekCalendarStyle(showParticles: false);

      expect(withParticles.showParticles, true);
      expect(withoutParticles.showParticles, false);
    });

    test('WeekCalendarStyle should be const constructible', () {
      const style1 = WeekCalendarStyle();
      const style2 = WeekCalendarStyle();

      // Const objects with same values should be identical
      expect(identical(style1, style2), true);
    });

    test('WeekCalendarStyle should support text style inheritance', () {
      const baseStyle = TextStyle(
        fontFamily: 'Roboto',
        letterSpacing: 1.2,
      );

      final customStyle = WeekCalendarStyle(
        monthHeaderStyle:
            baseStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        dayNameStyle: baseStyle.copyWith(fontSize: 12),
        dayNumberStyle: baseStyle.copyWith(fontSize: 16),
      );

      expect(customStyle.monthHeaderStyle.fontFamily, 'Roboto');
      expect(customStyle.monthHeaderStyle.letterSpacing, 1.2);
      expect(customStyle.monthHeaderStyle.fontSize, 20);
      expect(customStyle.dayNameStyle.fontFamily, 'Roboto');
      expect(customStyle.dayNumberStyle.fontFamily, 'Roboto');
    });
  });
}
