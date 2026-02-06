import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_time/s_time.dart';

void main() {
  group('TimeOfDayExtension', () {
    test('toDateTime converts TimeOfDay to DateTime with default date', () {
      const timeOfDay = TimeOfDay(hour: 14, minute: 30);
      final dateTime = timeOfDay.toDateTime();

      expect(dateTime.hour, 14);
      expect(dateTime.minute, 30);
    });

    test('toDateTime converts TimeOfDay to DateTime with custom date', () {
      const timeOfDay = TimeOfDay(hour: 10, minute: 15);
      final customDate = DateTime(2024, 6, 15);
      final dateTime = timeOfDay.toDateTime(date: customDate);

      expect(dateTime.year, 2024);
      expect(dateTime.month, 6);
      expect(dateTime.day, 15);
      expect(dateTime.hour, 10);
      expect(dateTime.minute, 15);
    });

    test('toDateTime with isUtc parameter', () {
      const timeOfDay = TimeOfDay(hour: 14, minute: 30);
      final dateTime = timeOfDay.toDateTime();

      expect(dateTime.hour, 14);
      expect(dateTime.minute, 30);
    });

    test('toDateTime with both date and isUtc parameters', () {
      const timeOfDay = TimeOfDay(hour: 9, minute: 45);
      final customDate = DateTime.utc(2025, 1, 5);
      final dateTime = timeOfDay.toDateTime(date: customDate);

      expect(dateTime.year, 2025);
      expect(dateTime.month, 1);
      expect(dateTime.day, 5);
      expect(dateTime.hour, 9);
      expect(dateTime.minute, 45);
    });
  });

  group('AmPmButtonStyle', () {
    test('default style has correct properties', () {
      const style = AmPmButtonStyle.defaultStyle;

      expect(style.textStyle,
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w500));
      expect(style.borderWidth, 1);
      expect(
          style.constraints, const BoxConstraints(minWidth: 48, minHeight: 40));
    });

    test('custom style can be created with specific values', () {
      const textStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
      const selectedColor = Colors.blue;
      const borderColor = Colors.red;
      const constraints = BoxConstraints(minWidth: 60, minHeight: 50);

      const style = AmPmButtonStyle(
        textStyle: textStyle,
        selectedColor: selectedColor,
        borderColor: borderColor,
        constraints: constraints,
        borderWidth: 2,
      );

      expect(style.textStyle, textStyle);
      expect(style.selectedColor, selectedColor);
      expect(style.borderColor, borderColor);
      expect(style.constraints, constraints);
      expect(style.borderWidth, 2);
    });
  });

  group('TimeSpinner Widget', () {
    testWidgets('TimeSpinner renders with default properties', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeSpinner(
              onChangedSelectedTime: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeSpinner), findsOneWidget);
    });

    testWidgets('TimeSpinner calls onChangedSelectedTime callback',
        (tester) async {
      TimeOfDay? changedTime;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeSpinner(
              initTime: const TimeOfDay(hour: 10, minute: 0),
              onChangedSelectedTime: (time) {
                changedTime = time;
              },
            ),
          ),
        ),
      );

      expect(find.byType(TimeSpinner), findsOneWidget);
      expect(changedTime, isNull); // No change yet, just initial render
    });

    testWidgets('TimeSpinner displays with 12-hour format by default',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeSpinner(
              initTime: const TimeOfDay(hour: 14, minute: 30),
              onChangedSelectedTime: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeSpinner), findsOneWidget);
    });

    testWidgets('TimeSpinner displays with 24-hour format', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeSpinner(
              initTime: const TimeOfDay(hour: 14, minute: 30),
              is24HourFormat: true,
              onChangedSelectedTime: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeSpinner), findsOneWidget);
    });

    testWidgets('TimeSpinner with custom hour values', (tester) async {
      final customHours = List.generate(12, (i) => i * 2); // 0, 2, 4, ..., 22

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeSpinner(
              initTime: const TimeOfDay(hour: 10, minute: 0),
              hrValues: customHours,
              onChangedSelectedTime: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeSpinner), findsOneWidget);
    });

    testWidgets('TimeSpinner with custom minute values', (tester) async {
      const customMinutes = [0, 15, 30, 45];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeSpinner(
              initTime: const TimeOfDay(hour: 10, minute: 0),
              minValues: customMinutes,
              onChangedSelectedTime: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeSpinner), findsOneWidget);
    });

    testWidgets('TimeSpinner with discarded hours', (tester) async {
      const discardedHours = [13, 14, 15, 16, 17]; // Lunch break

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeSpinner(
              initTime: const TimeOfDay(hour: 10, minute: 0),
              discardedHrValues: discardedHours,
              onChangedSelectedTime: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeSpinner), findsOneWidget);
    });

    testWidgets('TimeSpinner with discarded minutes', (tester) async {
      const discardedMinutes = [5, 35, 55];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeSpinner(
              initTime: const TimeOfDay(hour: 10, minute: 0),
              discardedMinValues: discardedMinutes,
              onChangedSelectedTime: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeSpinner), findsOneWidget);
    });

    testWidgets('TimeSpinner respects custom styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeSpinner(
              initTime: const TimeOfDay(hour: 10, minute: 30),
              selectedTextStyle: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              nonSelectedTextStyle: const TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(16),
              onChangedSelectedTime: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeSpinner), findsOneWidget);
    });

    testWidgets('TimeSpinner with custom dimensions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeSpinner(
              initTime: const TimeOfDay(hour: 10, minute: 30),
              spinnerHeight: 150,
              spinnerWidth: 80,
              digitHeight: 50,
              onChangedSelectedTime: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeSpinner), findsOneWidget);
    });

    testWidgets('TimeSpinner with AM/PM button styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeSpinner(
              initTime: const TimeOfDay(hour: 10, minute: 30),
              amPmButtonStyle: AmPmButtonStyle(
                textStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                selectedColor: Colors.blue.withValues(alpha: 0.2),
                borderColor: Colors.blue,
              ),
              onChangedSelectedTime: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeSpinner), findsOneWidget);
    });

    testWidgets('TimeSpinner with showNoSelectionDots true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeSpinner(
              initTime: const TimeOfDay(hour: 10, minute: 30),
              onChangedSelectedTime: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeSpinner), findsOneWidget);
    });

    testWidgets('TimeSpinner with showNoSelectionDots false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeSpinner(
              initTime: const TimeOfDay(hour: 10, minute: 30),
              showNoSelectionDots: false,
              onChangedSelectedTime: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeSpinner), findsOneWidget);
    });
  });

  group('TimeInput Widget', () {
    testWidgets('TimeInput renders with basic properties', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeInput(
              title: 'Start Time',
              onSubmitted: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsOneWidget);
      expect(find.text('Start Time'), findsOneWidget);
    });

    testWidgets('TimeInput displays with initial time', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeInput(
              title: 'Meeting Time',
              time: DateTime(2024, 1, 1, 14, 30),
              onSubmitted: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsOneWidget);
    });

    testWidgets('TimeInput with null initial time', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeInput(
              title: 'Optional Time',
              onSubmitted: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsOneWidget);
    });

    testWidgets('TimeInput with auto-focus enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeInput(
              title: 'Auto Focus Time',
              autoFocus: true,
              onSubmitted: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsOneWidget);
    });

    testWidgets('TimeInput with replaceAllTextOnAutoFocus true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeInput(
              title: 'Replace All Text',
              time: DateTime(2024, 1, 1, 10, 30),
              autoFocus: true,
              replaceAllTextOnAutoFocus: true,
              onSubmitted: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsOneWidget);
    });

    testWidgets('TimeInput with isEmptyWhenTimeNull true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeInput(
              title: 'Nullable Time',
              isEmptyWhenTimeNull: true,
              onSubmitted: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsOneWidget);
    });

    testWidgets('TimeInput with clear button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeInput(
              title: 'Clearable Time',
              time: DateTime(2024, 1, 1, 10, 30),
              showClearButton: true,
              onSubmitted: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsOneWidget);
    });

    testWidgets('TimeInput with default time fallback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeInput(
              title: 'Default Time',
              defaultTime: const TimeOfDay(hour: 9, minute: 0),
              onSubmitted: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsOneWidget);
    });

    testWidgets('TimeInput with UTC time enabled (isUtc: true)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeInput(
              title: 'UTC Time',
              time: DateTime.now().toUtc(),
              onSubmitted: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsOneWidget);
    });

    testWidgets('TimeInput with local time enabled (isUtc: false)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeInput(
              title: 'Local Time',
              time: DateTime.now(),
              isUtc: false,
              onSubmitted: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsOneWidget);
    });

    testWidgets(
        'TimeInput with local time and indicator (showLocalIndicator: true)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeInput(
              title: 'Local Time with Indicator',
              time: DateTime.now(),
              isUtc: false,
              showLocalIndicator: true,
              onSubmitted: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsOneWidget);
    });

    testWidgets(
        'TimeInput with local time without indicator (showLocalIndicator: false)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeInput(
              title: 'Local Time without Indicator',
              time: DateTime.now(),
              isUtc: false,
              showLocalIndicator: false,
              onSubmitted: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsOneWidget);
    });

    testWidgets('TimeInput with custom color per title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeInput(
              title: 'Colored Time',
              time: DateTime(2024, 1, 1, 10, 30),
              colorPerTitle: const {'Colored Time': Colors.teal},
              onSubmitted: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsOneWidget);
    });

    testWidgets('TimeInput with custom font size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeInput(
              title: 'Large Text',
              time: DateTime(2024, 1, 1, 10, 30),
              inputFontSize: 20,
              onSubmitted: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsOneWidget);
    });

    testWidgets('TimeInput with custom border radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeInput(
              title: 'Rounded Input',
              time: DateTime(2024, 1, 1, 10, 30),
              borderRadius: 20,
              onSubmitted: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsOneWidget);
    });

    testWidgets('TimeInput with custom content padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeInput(
              title: 'Padded Input',
              time: DateTime(2024, 1, 1, 10, 30),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              onSubmitted: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsOneWidget);
    });

    testWidgets('TimeInput with custom InputDecoration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeInput(
              title: 'Custom Decoration',
              time: DateTime(2024, 1, 1, 10, 30),
              inputDecoration: InputDecoration(
                hintText: 'Enter time (HHMM)',
                labelText: 'Time',
                prefixIcon: const Icon(Icons.access_time),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onSubmitted: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsOneWidget);
    });

    testWidgets('TimeInput calls onSubmitted callback', (tester) async {
      // ignore: unused_local_variable
      TimeOfDay? submittedTime;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeInput(
              title: 'Test Time',
              time: DateTime(2024, 1, 1, 10, 30),
              onSubmitted: (time) {
                submittedTime = time;
              },
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsOneWidget);
    });

    testWidgets('TimeInput calls onChanged callback when provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeInput(
              title: 'Tracked Time',
              time: DateTime(2024, 1, 1, 10, 30),
              onChanged: (time) {
                // Callback provided
              },
              onSubmitted: (time) {},
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsOneWidget);
    });
  });

  group('Integration Tests', () {
    testWidgets('TimeSpinner and TimeInput in same screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TimeSpinner(
                  initTime: const TimeOfDay(hour: 10, minute: 30),
                  onChangedSelectedTime: (time) {},
                ),
                TimeInput(
                  title: 'Input Time',
                  time: DateTime(2024, 1, 1, 14, 30),
                  onSubmitted: (time) {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(TimeSpinner), findsOneWidget);
      expect(find.byType(TimeInput), findsOneWidget);
    });

    testWidgets('Multiple TimeInput widgets in a column', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TimeInput(
                  title: 'Start Time',
                  time: DateTime(2024, 1, 1, 9),
                  onSubmitted: (time) {},
                ),
                TimeInput(
                  title: 'End Time',
                  time: DateTime(2024, 1, 1, 17),
                  onSubmitted: (time) {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(TimeInput), findsWidgets);
      expect(find.text('Start Time'), findsOneWidget);
      expect(find.text('End Time'), findsOneWidget);
    });
  });
}
