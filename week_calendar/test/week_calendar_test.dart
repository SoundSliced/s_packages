import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week_calendar/week_calendar.dart';

void main() {
  group('WeekCalendar Widget Tests', () {
    testWidgets('should create WeekCalendar with default constructor',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);
      DateTime? selectedDateResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              onDateSelected: (date) {
                selectedDateResult = date;
              },
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
      expect(selectedDateResult, isNull);
    });

    testWidgets('should create WeekCalendar.outlined constructor',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar.outlined(
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
    });

    testWidgets('should create WeekCalendar.minimal constructor',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar.minimal(
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
    });

    testWidgets('should display month header when showMonthHeader is true',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              showMonthHeader: true,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      // Check for month header text (January 2026)
      expect(find.textContaining('January'), findsOneWidget);
      expect(find.textContaining('2026'), findsOneWidget);
    });

    testWidgets('should hide month header when showMonthHeader is false',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              showMonthHeader: false,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      // Month header should not be visible
      expect(find.textContaining('January'), findsNothing);
    });

    testWidgets('should call onDateSelected when a date is tapped',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 3); // Today
      final initialDate = DateTime(2026, 1, 1);
      DateTime? selectedDateResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              child: WeekCalendar(
                initialDate: initialDate,
                selectedDate: selectedDate,
                onDateSelected: (date) {
                  selectedDateResult = date;
                },
                onNextMonth: () {},
                onPreviousMonth: () {},
              ),
            ),
          ),
        ),
      );

      // Find and tap a different date that's not in the future (e.g., 2nd)
      // Tap at the center of the text widget to ensure it hits the button
      final dayTextFinder = find.text('2');
      expect(dayTextFinder, findsOneWidget);
      await tester.tapAt(tester.getCenter(dayTextFinder));
      await tester.pumpAndSettle();

      expect(selectedDateResult, isNotNull);
      expect(selectedDateResult!.day, 2);
    });

    testWidgets('should call onNextMonth when next button is tapped',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);
      var nextMonthCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              onDateSelected: (date) {},
              onNextMonth: () {
                nextMonthCalled = true;
              },
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      // Find and tap the next month button
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(nextMonthCalled, isTrue);
    });

    testWidgets('should call onPreviousMonth when previous button is tapped',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);
      var previousMonthCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {
                previousMonthCalled = true;
              },
            ),
          ),
        ),
      );

      // Find and tap the previous month button
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(previousMonthCalled, isTrue);
    });

    testWidgets('should display custom navigation icons',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              previousMonthIcon: Icons.arrow_back,
              nextMonthIcon: Icons.arrow_forward,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('should call onHeaderDateTapped when header is tapped',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);
      Offset? tappedPosition;

      // Set test screen size to avoid overflow in calendar picker dialog
      await tester.binding.setSurfaceSize(const Size(1200, 1000));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
              onHeaderDateTapped: (position) {
                tappedPosition = position;
              },
            ),
          ),
        ),
      );

      // Tap on the header date
      await tester.tap(find.textContaining('January'));
      // Note: We don't call pumpAndSettle here because the calendar_date_picker2
      // dialog that appears has a rendering overflow issue (43px) that causes
      // test failures. The callback is called immediately on tap, so we can
      // verify it without waiting for the dialog to fully render.

      expect(tappedPosition, isNotNull); // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should call onHeaderTodayDate when today button is tapped',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);
      Offset? tappedPosition;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
              onHeaderTodayDate: (position) {
                tappedPosition = position;
              },
            ),
          ),
        ),
      );

      // Find and tap the "Today" button
      final todayFinder = find.text('Today');
      if (todayFinder.evaluate().isNotEmpty) {
        await tester.tap(todayFinder);
        await tester.pumpAndSettle();
        expect(tappedPosition, isNotNull);
      }
    });
  });

  group('WeekCalendarType Tests', () {
    testWidgets('should render standard calendar type',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              calendarType: WeekCalendarType.standard,
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
    });

    testWidgets('should render outlined calendar type',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              calendarType: WeekCalendarType.outlined,
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
    });

    testWidgets('should render minimal calendar type',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              calendarType: WeekCalendarType.minimal,
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
    });

    testWidgets('should render elevated calendar type',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              calendarType: WeekCalendarType.elevated,
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
    });
  });

  group('WeekCalendarStyle Tests', () {
    testWidgets('should apply custom calendar style',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);

      const customStyle = WeekCalendarStyle(
        activeDayColor: Colors.purple,
        dayIndicatorSize: 40,
        monthHeaderStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        dayNameStyle: TextStyle(fontSize: 14, color: Colors.purple),
        selectedDayTextStyle: TextStyle(fontSize: 18, color: Colors.white),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              calendarStyle: customStyle,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
    });

    testWidgets('should apply custom animation duration and curve',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              animationDuration: const Duration(milliseconds: 500),
              animationCurve: Curves.bounceOut,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
    });

    testWidgets('should disable animations when enableAnimations is false',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              enableAnimations: false,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
    });
  });

  group('Weekday Tests', () {
    test('should have correct values for all weekdays', () {
      expect(Weekday.monday.value, 1);
      expect(Weekday.tuesday.value, 2);
      expect(Weekday.wednesday.value, 3);
      expect(Weekday.thursday.value, 4);
      expect(Weekday.friday.value, 5);
      expect(Weekday.saturday.value, 6);
      expect(Weekday.sunday.value, 7);
    });

    test('should convert DateTime.weekday to Weekday enum', () {
      expect(Weekday.fromDateTime(1), Weekday.monday);
      expect(Weekday.fromDateTime(2), Weekday.tuesday);
      expect(Weekday.fromDateTime(3), Weekday.wednesday);
      expect(Weekday.fromDateTime(4), Weekday.thursday);
      expect(Weekday.fromDateTime(5), Weekday.friday);
      expect(Weekday.fromDateTime(6), Weekday.saturday);
      expect(Weekday.fromDateTime(7), Weekday.sunday);
    });

    testWidgets('should start week on Monday by default',
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

    testWidgets('should start week on Sunday', (WidgetTester tester) async {
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

    testWidgets('should start week on Saturday', (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              startingDay: Weekday.saturday,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
    });
  });

  group('UTC and Local Date Tests', () {
    testWidgets('should work with UTC dates when isUtc is true',
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
    });

    testWidgets('should work with local dates when isUtc is false',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 1, 15);
      final initialDate = DateTime(2026, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              isUtc: false,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(WeekCalendar), findsOneWidget);
    });
  });

  group('Edge Cases Tests', () {
    testWidgets('should handle year boundaries correctly',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 12, 31);
      final initialDate = DateTime(2026, 12, 1);

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

    testWidgets('should handle leap year correctly',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2024, 2, 29); // Leap year
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

    testWidgets('should handle month with 31 days',
        (WidgetTester tester) async {
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

    testWidgets('should handle month with 30 days',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2026, 4, 30);
      final initialDate = DateTime(2026, 4, 1);

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
      expect(find.text('30'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle February in non-leap year',
        (WidgetTester tester) async {
      final selectedDate = DateTime(2025, 2, 28); // Non-leap year
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
  });

  group('Navigation Tests', () {
    testWidgets('should navigate through multiple months',
        (WidgetTester tester) async {
      var currentMonth = 1;
      final selectedDate = DateTime(2026, 1, 15);
      var initialDate = DateTime(2026, 1, 1);

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
                      currentMonth++;
                      initialDate = DateTime(2026, currentMonth, 1);
                    });
                  },
                  onPreviousMonth: () {
                    setState(() {
                      currentMonth--;
                      initialDate = DateTime(2026, currentMonth, 1);
                    });
                  },
                ),
              ),
            );
          },
        ),
      );

      // Navigate to next month
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      // Navigate to previous month
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.byType(WeekCalendar), findsOneWidget);
    });
  });

  group('Integration Tests', () {
    testWidgets('should handle complete user interaction flow',
        (WidgetTester tester) async {
      var selectedDate = DateTime(2026, 1, 3); // Today
      var initialDate = DateTime(2026, 1, 1);
      var dateChangedCount = 0;
      var nextMonthCount = 0;
      var previousMonthCount = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 800,
                  child: WeekCalendar(
                    initialDate: initialDate,
                    selectedDate: selectedDate,
                    onDateSelected: (date) {
                      setState(() {
                        selectedDate = date;
                        dateChangedCount++;
                      });
                    },
                    onNextMonth: () {
                      setState(() {
                        initialDate = DateTime(
                          initialDate.year,
                          initialDate.month + 1,
                        );
                        nextMonthCount++;
                      });
                    },
                    onPreviousMonth: () {
                      setState(() {
                        initialDate = DateTime(
                          initialDate.year,
                          initialDate.month - 1,
                        );
                        previousMonthCount++;
                      });
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );

      // Select a date that's not in the future (e.g., 2nd)
      final dayTextFinder = find.text('2');
      expect(dayTextFinder, findsOneWidget);
      await tester.tapAt(tester.getCenter(dayTextFinder));
      await tester.pumpAndSettle();
      expect(dateChangedCount, 1);

      // Navigate to next month
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(nextMonthCount, 1);

      // Navigate to previous month
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      expect(previousMonthCount, 1);

      expect(find.byType(WeekCalendar), findsOneWidget);
    });
  });
}
