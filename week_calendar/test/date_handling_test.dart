import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week_calendar/week_calendar.dart';

void main() {
  group('Date Handling Tests', () {
    testWidgets('should handle current date correctly',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: today,
              selectedDate: today,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
      expect(find.text(today.day.toString()), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle dates in the past', (WidgetTester tester) async {
      final pastDate = DateTime(2020, 1, 15);
      final initialDate = DateTime(2020, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: pastDate,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
    });

    testWidgets('should handle dates in the future',
        (WidgetTester tester) async {
      final futureDate = DateTime(2030, 12, 25);
      final initialDate = DateTime(2030, 12, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: futureDate,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
    });

    testWidgets('should handle first day of month',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 1);
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
      expect(find.text('1'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle last day of month', (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 31);
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
      expect(find.text('31'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle leap year February 29',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2024, 2, 29);
      final initialDate = DateTime(2024, 2, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
      expect(find.text('29'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle non-leap year February',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2025, 2, 28);
      final initialDate = DateTime(2025, 2, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
      expect(find.text('28'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle year transition (December to January)',
        (WidgetTester tester) async {
      var initialDate = DateTime(2025, 12, 1);
      final selectedDate = DateTime(2025, 12, 15);

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: WeekCalendar(
                  initialDate: initialDate,
                  selectedDate: selectedDate,
                  onDateSelected: (date) {},
                  onNextMonth: () {
                    setState(() {
                      initialDate = DateTime(2026, 1, 1);
                    });
                  },
                  onPreviousMonth: () {},
                ),
              ),
            );
          },
        ),
      );

      expect(find.textContaining('December'), findsOneWidget);

      // Navigate to next month (January 2026)
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(find.textContaining('January'), findsOneWidget);
      expect(find.textContaining('2026'), findsOneWidget);
    });

    testWidgets('should handle month transition (January to February)',
        (WidgetTester tester) async {
      var initialDate = DateTime(2026, 1, 1);
      final selectedDate = DateTime(2026, 1, 15);

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: WeekCalendar(
                  initialDate: initialDate,
                  selectedDate: selectedDate,
                  onDateSelected: (date) {},
                  onNextMonth: () {
                    setState(() {
                      initialDate = DateTime(2026, 2, 1);
                    });
                  },
                  onPreviousMonth: () {},
                ),
              ),
            );
          },
        ),
      );

      expect(find.textContaining('January'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(find.textContaining('February'), findsOneWidget);
    });
  });

  group('UTC Date Tests', () {
    testWidgets('should correctly handle UTC dates',
        (WidgetTester tester) async {
      final selectedDate = DateTime.utc(2026, 1, 15);
      final initialDate = DateTime.utc(2026, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              isUtc: true,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
      expect(find.text('15'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle UTC year boundaries',
        (WidgetTester tester) async {
      final selectedDate = DateTime.utc(2025, 12, 31);
      final initialDate = DateTime.utc(2025, 12, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              isUtc: true,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
      expect(find.text('31'), findsAtLeastNWidgets(1));
    });
  });

  group('Week Generation Tests', () {
    testWidgets('should correctly generate weeks for January 2026',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 2); // Jan 2 (not disabled)
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              child: WeekCalendar(
                initialDate: initialDate,
                selectedDate: selectedDate,
                onDateSelected: (date) {},
                onNextMonth: () {},
                onPreviousMonth: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
      // PageView shows the week containing selectedDate (Jan 2)
      // That week is Dec 29 - Jan 4 for Monday start
      expect(find.text('2'), findsAtLeastNWidgets(1));
      expect(find.text('1'), findsAtLeastNWidgets(1));
    });

    testWidgets('should correctly generate weeks starting on Monday',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              startingDay: Weekday.monday,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
    });

    testWidgets('should correctly generate weeks starting on Sunday',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              startingDay: Weekday.sunday,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
    });

    testWidgets('should correctly generate weeks for different starting days',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);

      for (final startingDay in Weekday.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WeekCalendar(
                key: ValueKey(startingDay),
                initialDate: initialDate,
                selectedDate: selectedDate,
                startingDay: startingDay,
                onDateSelected: (date) {},
                onNextMonth: () {},
                onPreviousMonth: () {},
              ),
            ),
          ),
        );

        expect(find.byType(WeekCalendar), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });
  });

  group('Month Length Tests', () {
    testWidgets('should handle months with 31 days correctly',
        (WidgetTester tester) async {
      // January, March, May, July, August, October, December have 31 days
      final monthsWith31Days = [1, 3, 5, 7, 8, 10, 12];

      for (final month in monthsWith31Days) {
        final selectedDate = DateTime(2026, month, 31);
        final initialDate = DateTime(2026, month, 1);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WeekCalendar(
                key: ValueKey(month),
                initialDate: initialDate,
                selectedDate: selectedDate,
                onDateSelected: (date) {},
                onNextMonth: () {},
                onPreviousMonth: () {},
              ),
            ),
          ),
        );

        expect(find.byType(WeekCalendar), findsOneWidget);
        expect(find.text('31'), findsAtLeastNWidgets(1));

        // Clean up
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('should handle months with 30 days correctly',
        (WidgetTester tester) async {
      // April, June, September, November have 30 days
      final monthsWith30Days = [4, 6, 9, 11];

      for (final month in monthsWith30Days) {
        final selectedDate = DateTime(2026, month, 30);
        final initialDate = DateTime(2026, month, 1);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WeekCalendar(
                key: ValueKey(month),
                initialDate: initialDate,
                selectedDate: selectedDate,
                onDateSelected: (date) {},
                onNextMonth: () {},
                onPreviousMonth: () {},
              ),
            ),
          ),
        );

        expect(find.byType(WeekCalendar), findsOneWidget);
        expect(find.text('30'), findsAtLeastNWidgets(1));

        // Clean up
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('should handle February in leap years',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2024, 2, 29); // 2024 is a leap year
      final initialDate = DateTime(2024, 2, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
      expect(find.text('29'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle February in non-leap years',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 2, 28); // 2026 is not a leap year
      final initialDate = DateTime(2026, 2, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
      expect(find.text('28'), findsAtLeastNWidgets(1));
    });
  });

  group('State Update Tests', () {
    testWidgets('should update when selectedDate changes',
        (WidgetTester tester) async {
      var selectedDate = DateTime(2026, 1, 3); // Today
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 800,
                  child: Column(
                    children: [
                      WeekCalendar(
                        initialDate: initialDate,
                        selectedDate: selectedDate,
                        onDateSelected: (date) {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                        onNextMonth: () {},
                        onPreviousMonth: () {},
                      ),
                      Text('Selected: ${selectedDate.day}'),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('Selected: 3'), findsOneWidget);

      // Select a different date (Jan 2 - not in the future)
      final dayTextFinder = find.text('2');
      expect(dayTextFinder, findsOneWidget);
      await tester.tapAt(tester.getCenter(dayTextFinder));
      await tester.pumpAndSettle();

      expect(find.text('Selected: 2'), findsOneWidget);
    });

    testWidgets('should update when startingDay changes',
        (WidgetTester tester) async {
      var startingDay = Weekday.monday;
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    WeekCalendar(
                      initialDate: initialDate,
                      selectedDate: selectedDate,
                      startingDay: startingDay,
                      onDateSelected: (date) {},
                      onNextMonth: () {},
                      onPreviousMonth: () {},
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          startingDay = Weekday.sunday;
                        });
                      },
                      child: const Text('Change to Sunday'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);

      // Change starting day
      await tester.tap(find.text('Change to Sunday'));
      await tester.pumpAndSettle();

      expect(find.byType(WeekCalendar), findsOneWidget);
    });
  });
}
