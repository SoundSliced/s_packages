import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:s_packages/s_packages.dart';

// A fixed UTC-4 clock reading, independent of the test machine's timezone.
// These calendar fields and UTC instant reproduce the owner's measurement.
class _AstEvening extends Fake implements DateTime {
  @override
  int get year => 2026;
  @override
  int get month => 10;
  @override
  int get day => 26;
  @override
  DateTime toUtc() => DateTime.utc(2026, 10, 27, 1, 52);
}

class _FixedClockCalendar extends WeekCalendar {
  const _FixedClockCalendar({
    required this.now,
    required super.initialDate,
    required super.selectedDate,
    required super.onDateSelected,
    super.startingDay,
    super.isUtc,
    super.minDate,
    super.maxDate,
    super.showMonthHeader = false,
  }) : super(enableAnimations: false);

  final DateTime now;

  @override
  DateTime get currentDateTime => now;
}

Future<void> _pumpCalendar(
  WidgetTester tester, {
  Weekday? startingDay,
  bool isUtc = true,
  DateTime? selectedDate,
  DateTime? minDate,
  DateTime? maxDate,
  bool showMonthHeader = false,
  required ValueChanged<DateTime> onDateSelected,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: _FixedClockCalendar(
          now: _AstEvening(),
          initialDate: DateTime.utc(2026, 10),
          selectedDate: selectedDate ?? DateTime.utc(2026, 10, 26),
          onDateSelected: onDateSelected,
          startingDay: startingDay,
          isUtc: isUtc,
          minDate: minDate,
          maxDate: maxDate,
          showMonthHeader: showMonthHeader,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

SDisabled _dayCell(WidgetTester tester, int day) => tester.widget<SDisabled>(
  find.ancestor(of: find.text('$day'), matching: find.byType(SDisabled)),
);

void main() {
  for (final startingDay in [null, Weekday.monday]) {
    final layout = startingDay == null ? 'default weeks' : 'Monday weeks';

    testWidgets('UTC today is enabled and UTC tomorrow disabled ($layout)', (
      tester,
    ) async {
      final selected = <DateTime>[];
      await _pumpCalendar(
        tester,
        startingDay: startingDay,
        onDateSelected: selected.add,
      );

      expect(_dayCell(tester, 27).isDisabled, isFalse);
      expect(_dayCell(tester, 28).isDisabled, isTrue);
      await tester.tap(find.text('27'));
      await tester.pumpAndSettle();
      expect(selected, [DateTime.utc(2026, 10, 27)]);
      expect(selected.single.isUtc, isTrue);

      await tester.tap(find.text('28'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(selected, hasLength(1));
    });

    testWidgets('UTC date bounds include their boundary day ($layout)', (
      tester,
    ) async {
      final selected = <DateTime>[];
      await _pumpCalendar(
        tester,
        startingDay: startingDay,
        minDate: DateTime.utc(2026, 10, 27),
        maxDate: DateTime.utc(2026, 10, 27),
        onDateSelected: selected.add,
      );

      expect(_dayCell(tester, 26).isDisabled, isTrue);
      expect(_dayCell(tester, 27).isDisabled, isFalse);
      expect(_dayCell(tester, 28).isDisabled, isTrue);
      await tester.tap(find.text('27'));
      await tester.pumpAndSettle();
      expect(selected, [DateTime.utc(2026, 10, 27)]);
    });

    testWidgets('local today and callback stay local ($layout)', (
      tester,
    ) async {
      final selected = <DateTime>[];
      await _pumpCalendar(
        tester,
        startingDay: startingDay,
        isUtc: false,
        selectedDate: DateTime(2026, 10, 26),
        minDate: DateTime(2026, 10, 26),
        maxDate: DateTime(2026, 10, 26),
        onDateSelected: selected.add,
      );

      expect(_dayCell(tester, 26).isDisabled, isFalse);
      expect(_dayCell(tester, 27).isDisabled, isTrue);
      await tester.tap(find.text('26'));
      await tester.pumpAndSettle();
      expect(selected, [DateTime(2026, 10, 26)]);
      expect(selected.single.isUtc, isFalse);
    });
  }

  testWidgets('Today button selects UTC today when local date is yesterday', (
    tester,
  ) async {
    final selected = <DateTime>[];
    await _pumpCalendar(
      tester,
      showMonthHeader: true,
      onDateSelected: selected.add,
    );

    expect(find.text('Today'), findsOneWidget);
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(selected, [DateTime.utc(2026, 10, 27)]);
    expect(selected.single.isUtc, isTrue);
  });

  testWidgets('header popup allows the UTC day ahead of the local date', (
    tester,
  ) async {
    // Leave room for the dialog's month label with Flutter's wide test font.
    tester.platformDispatcher.textScaleFactorTestValue = 0.7;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pumpCalendar(tester, showMonthHeader: true, onDateSelected: (_) {});

    await tester.tap(find.textContaining('October', findRichText: true));
    await tester.pumpAndSettle();
    final picker = tester.widget<CalendarDatePicker2>(
      find.byType(CalendarDatePicker2),
    );
    // The picker normalizes its bound to local midnight, retaining the fields.
    final lastDate = picker.config.lastDate;
    expect((lastDate.year, lastDate.month, lastDate.day), (2026, 10, 27));
    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();
  });

  testWidgets('Today button is hidden when UTC today is already selected', (
    tester,
  ) async {
    await _pumpCalendar(
      tester,
      selectedDate: DateTime.utc(2026, 10, 27),
      showMonthHeader: true,
      onDateSelected: (_) {},
    );

    expect(find.text('Today'), findsNothing);
  });
}
