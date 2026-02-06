import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week_calendar/week_calendar.dart';

void main() {
  testWidgets(
      'WeekCalendar.outlined should not crash during selection animation',
      (WidgetTester tester) async {
    // Use a non-uniform border color scenario if possible, or just standard usage which was crashing
    // The user reported crash happened with default outlined style (which uses Border.all and borderRadius)

    DateTime selectedDate = DateTime(2026, 1, 3); // Today - not disabled
    final initialDate = DateTime(2026, 1, 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return WeekCalendar.outlined(
                initialDate: initialDate,
                selectedDate: selectedDate,
                onDateSelected: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    // Initial pump
    await tester.pump();

    // Find a different date to tap that's not in the future (e.g., 2nd)
    final dayFinder = find.text('2');
    expect(dayFinder, findsOneWidget);

    // Tap to trigger selection change and animation
    await tester.tapAt(tester.getCenter(dayFinder));

    // Pump frames to simulate animation
    // We need to pump enough frames to cover the animation duration
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    // If we reach here without exception, the fix is working
    expect(find.text('2'), findsOneWidget);
  });
}
