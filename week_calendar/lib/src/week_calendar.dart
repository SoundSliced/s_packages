// ignore: unused_import
import 'dart:developer';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:s_disabled/s_disabled.dart';
import 'package:s_ink_button/s_ink_button.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';

/// Defines visual variations of the horizontal calendar
enum WeekCalendarType {
  /// Default circular day indicators
  standard,

  /// Outlined containers with border
  outlined,

  /// Simplified text-based display
  minimal,

  /// Material-elevated containers
  elevated,
}

/// Represents days of the week with ISO 8601 numbering (Monday = 1)
enum Weekday {
  /// Sets the first day of the week to monday
  monday(1),

  /// Sets the first day of the week to Tuesday
  tuesday(2),

  /// Sets the first day of the week to Wednesday
  wednesday(3),

  /// Sets the first day of the week to Thursday
  thursday(4),

  /// Sets the first day of the week to Friday
  friday(5),

  /// Sets the first day of the week to Saturday
  saturday(6),

  /// Sets the first day of the week to Sunday
  sunday(7);

  /// Gets the value of the day
  final int value;
  const Weekday(this.value);

  /// Converts DateTime.weekday (1-7) to Weekday enum
  static Weekday fromDateTime(int weekday) {
    return Weekday.values.firstWhere((w) => w.value == weekday);
  }
}

/// Contains all visual styling parameters for the calendar
class WeekCalendarStyle {
  /// Style for month/year header text
  final TextStyle monthHeaderStyle;

  /// Style for weekday abbreviation labels
  final TextStyle dayNameStyle;

  /// Base style for day numbers
  final TextStyle dayNumberStyle;

  /// Style for selected day numbers
  final TextStyle selectedDayTextStyle;

  /// Style for non-selected days in current month
  final TextStyle inactiveDayTextStyle;

  /// Primary color for selected states
  final Color activeDayColor;

  /// Background color for day indicators
  final Color dayIndicatorColor;

  /// Diameter of day indicator circles
  final double dayIndicatorSize;

  /// Custom border for day indicators
  final Border? dayIndicatorBorder;

  /// Shadow effect for elevated variants
  final BoxShadow? dayIndicatorShadow;

  /// Enables particle effects on selection (if implemented)
  final bool showParticles;

  /// Duration for selection animations
  final Duration selectionAnimationDuration;

  /// Curve for selection animations
  final Curve selectionAnimationCurve;

  /// Creates a style configuration for the calendar
  const WeekCalendarStyle({
    this.monthHeaderStyle =
        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    this.dayNameStyle = const TextStyle(fontSize: 12),
    this.dayNumberStyle = const TextStyle(fontSize: 16),
    this.activeDayColor = Colors.blueAccent,
    this.dayIndicatorColor = Colors.transparent,
    this.dayIndicatorSize = 28,
    this.dayIndicatorBorder,
    this.dayIndicatorShadow,
    this.selectedDayTextStyle =
        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    this.inactiveDayTextStyle = const TextStyle(fontSize: 16),
    this.showParticles = false,
    this.selectionAnimationDuration = const Duration(milliseconds: 300),
    this.selectionAnimationCurve = Curves.easeOutBack,
  });
}

/// A horizontally scrollable weekly calendar widget with multiple visual styles
class WeekCalendar extends StatefulWidget {
  /// Initial displayed month
  final DateTime initialDate;

  /// Currently selected date
  final DateTime selectedDate;

  /// Callback when user selects a date
  final ValueChanged<DateTime> onDateSelected;

  /// Callback when calendar advances to next month
  final VoidCallback? onNextMonth;

  /// Callback when calendar returns to previous month
  final VoidCallback? onPreviousMonth;

  /// Callback when calendar returns to previous week
  final VoidCallback? onPreviousWeek;

  /// Callback when calendar advances to next week
  final VoidCallback? onNextWeek;

  /// Visual variant of the calendar
  final WeekCalendarType calendarType;

  /// Complete styling configuration
  final WeekCalendarStyle calendarStyle;

  /// Custom duration for month transition animations
  final Duration? animationDuration;

  /// Custom curve for month transition animations
  final Curve? animationCurve;

  /// Toggles month header visibility
  final bool showMonthHeader;

  /// Custom icon for previous month navigation
  final IconData? previousMonthIcon;

  /// Custom icon for next month navigation
  final IconData? nextMonthIcon;

  /// Color for navigation icons
  final Color? iconColor;

  /// Override default week starting day
  final Weekday? startingDay;

  /// Global toggle for all animations
  final bool enableAnimations;

  /// Callback when the header date is tapped
  final Function(Offset widgetPosition)? onHeaderDateTapped;

  /// Callback when the header today's date is tapped
  final Function(Offset widgetPosition)? onHeaderTodayDate;

  /// Indicates if the calendar is in UTC mode
  final bool isUtc;

  /// Toggles the display of the calendar popup on header tap
  final bool showCalendarPopupOnHeaderTap;

  /// Default constructor for standard calendar
  const WeekCalendar({
    super.key,
    required this.initialDate,
    required this.selectedDate,
    required this.onDateSelected,
    this.onNextMonth,
    this.onPreviousMonth,
    this.onPreviousWeek,
    this.onNextWeek,
    this.calendarType = WeekCalendarType.standard,
    this.calendarStyle = const WeekCalendarStyle(),
    this.animationDuration,
    this.animationCurve,
    this.showMonthHeader = true,
    this.previousMonthIcon = Icons.chevron_left,
    this.nextMonthIcon = Icons.chevron_right,
    this.iconColor,
    this.startingDay,
    this.enableAnimations = true,
    this.onHeaderDateTapped,
    this.onHeaderTodayDate,
    this.isUtc = true,
    this.showCalendarPopupOnHeaderTap = true,
  });

  /// Preconfigured constructor for outlined variant
  const WeekCalendar.outlined({
    super.key,
    required this.initialDate,
    required this.selectedDate,
    required this.onDateSelected,
    this.onNextMonth,
    this.onPreviousMonth,
    this.onPreviousWeek,
    this.onNextWeek,
    this.calendarStyle = const WeekCalendarStyle(),
    this.animationDuration,
    this.animationCurve,
    this.showMonthHeader = true,
    this.previousMonthIcon = Icons.chevron_left,
    this.nextMonthIcon = Icons.chevron_right,
    this.iconColor,
    this.startingDay,
    this.enableAnimations = true,
    this.onHeaderDateTapped,
    this.onHeaderTodayDate,
    this.isUtc = true,
    this.showCalendarPopupOnHeaderTap = true,
  }) : calendarType = WeekCalendarType.outlined;

  /// Preconfigured constructor for minimal variant
  const WeekCalendar.minimal({
    super.key,
    required this.initialDate,
    required this.selectedDate,
    required this.onDateSelected,
    this.onNextMonth,
    this.onPreviousMonth,
    this.onPreviousWeek,
    this.onNextWeek,
    this.calendarStyle = const WeekCalendarStyle(
      dayIndicatorSize: 32,
      monthHeaderStyle: TextStyle(fontSize: 14),
      selectedDayTextStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
    this.animationDuration,
    this.animationCurve,
    this.showMonthHeader = true,
    this.previousMonthIcon = Icons.chevron_left,
    this.nextMonthIcon = Icons.chevron_right,
    this.iconColor,
    this.startingDay,
    this.enableAnimations = true,
    this.onHeaderDateTapped,
    this.onHeaderTodayDate,
    this.isUtc = true,
    this.showCalendarPopupOnHeaderTap = true,
  }) : calendarType = WeekCalendarType.minimal;

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

/// State class for calendar widget handling layout and interactions
class _WeekCalendarState extends State<WeekCalendar> {
  late PageController _pageController;
  late List<List<DateTime>> _weeks;
  late DateTime _headerDate;

  /// Generates week lists based on current month and starting day
  List<List<DateTime>> _generateWeeks(DateTime date) {
    final firstDayOfMonth = widget.isUtc
        ? DateTime.utc(date.year, date.month, 1)
        : DateTime(date.year, date.month, 1);
    final lastDayOfMonth = widget.isUtc
        ? DateTime.utc(date.year, date.month + 1, 0)
        : DateTime(date.year, date.month + 1, 0);

    if (widget.startingDay != null) {
      // Custom week start logic
      int daysToSubtract =
          (firstDayOfMonth.weekday - widget.startingDay!.value) % 7;
      DateTime weekStart =
          firstDayOfMonth.subtract(Duration(days: daysToSubtract));

      int daysToAdd =
          (widget.startingDay!.value + 6 - lastDayOfMonth.weekday) % 7;
      DateTime weekEnd = lastDayOfMonth.add(Duration(days: daysToAdd));

      final totalDays = weekEnd.difference(weekStart).inDays + 1;
      final numberOfWeeks = (totalDays / 7).ceil();

      return List.generate(numberOfWeeks, (weekIndex) {
        return List.generate(7, (dayIndex) {
          return weekStart.add(Duration(days: (weekIndex * 7) + dayIndex));
        });
      });
    } else {
      // Default month week generation
      final int totalDays = lastDayOfMonth.day;
      final int numberOfWeeks = (totalDays + 6) ~/ 7;
      List<List<DateTime>> weeks = [];

      for (int weekIndex = 0; weekIndex < numberOfWeeks; weekIndex++) {
        List<DateTime> week = [];
        for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
          final dayNumber = (weekIndex * 7) + dayOffset + 1;
          if (dayNumber > totalDays) break;
          week.add(DateTime(date.year, date.month, dayNumber));
        }
        weeks.add(week);
      }
      return weeks;
    }
  }

  /// Finds the week index containing a specific date
  int _findWeekIndex(List<List<DateTime>> weeks, DateTime date) {
    for (int i = 0; i < weeks.length; i++) {
      if (weeks[i].any((day) => _isSameDay(day, date))) return i;
    }
    return 0;
  }

  /// Date comparison helper
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  void initState() {
    super.initState();
    _headerDate = widget.initialDate;
    _weeks = _generateWeeks(_headerDate);
    _pageController = PageController(
      initialPage: _findWeekIndex(_weeks, widget.selectedDate),
      viewportFraction: 1,
    );
  }

  @override
  void didUpdateWidget(WeekCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startingDay != widget.startingDay ||
        oldWidget.selectedDate != widget.selectedDate) {
      // Check if selectedDate is in a different month/year than current headerDate
      final selectedMonth =
          DateTime(widget.selectedDate.year, widget.selectedDate.month);
      final currentMonth = DateTime(_headerDate.year, _headerDate.month);

      if (selectedMonth != currentMonth) {
        // Update headerDate to match selectedDate's month
        setState(() {
          _headerDate = widget.isUtc
              ? DateTime.utc(
                  widget.selectedDate.year, widget.selectedDate.month)
              : DateTime(widget.selectedDate.year, widget.selectedDate.month);
          _weeks = _generateWeeks(_headerDate);
        });
      } else {
        _weeks = _generateWeeks(_headerDate);
      }

      final newPage = _findWeekIndex(_weeks, widget.selectedDate);
      if (_pageController.hasClients) {
        _pageController.jumpToPage(newPage);
      }
    }
  }

  /// Builds individual day indicator based on current style
  Widget _buildDayIndicator(DateTime day, bool isSelected) {
    final isMinimal = widget.calendarType == WeekCalendarType.minimal;
    final textStyle = isSelected
        ? widget.calendarStyle.selectedDayTextStyle
        : widget.calendarStyle.inactiveDayTextStyle;

    Widget content = Text(
      day.day.toString(),
      style: isMinimal
          ? textStyle.copyWith(
              color: isSelected ? widget.calendarStyle.activeDayColor : null,
              fontWeight: isSelected ? FontWeight.bold : null,
              fontSize: isSelected ? 16 : 10,
            )
          : textStyle.copyWith(
              color: isSelected
                  ? Colors.white
                  : Colors.black.withValues(alpha: 0.8),
              fontWeight: isSelected ? FontWeight.bold : null,
              fontSize: isSelected ? 15 : 12,
            ),
    );

    if (isMinimal) {
      return AnimatedContainer(
        duration: widget.calendarStyle.selectionAnimationDuration,
        decoration: BoxDecoration(
          border: isSelected
              ? Border(
                  bottom: BorderSide(
                    color: widget.calendarStyle.activeDayColor,
                    width: 2,
                  ),
                )
              : null,
        ),
        child: content,
      );
    }

    switch (widget.calendarType) {
      case WeekCalendarType.outlined:
        if (widget.calendarStyle.dayIndicatorBorder != null) {
          return AnimatedContainer(
            duration: widget.calendarStyle.selectionAnimationDuration,
            curve: widget.calendarStyle.selectionAnimationCurve,
            width: widget.calendarStyle.dayIndicatorSize,
            height: widget.calendarStyle.dayIndicatorSize,
            decoration: BoxDecoration(
              color: isSelected
                  ? widget.calendarStyle.activeDayColor
                  : Colors.transparent,
              border: widget.calendarStyle.dayIndicatorBorder,
              boxShadow: widget.calendarStyle.dayIndicatorShadow != null
                  ? [widget.calendarStyle.dayIndicatorShadow!]
                  : null,
            ),
            child: Center(child: content),
          );
        }
        return AnimatedContainer(
          duration: widget.calendarStyle.selectionAnimationDuration,
          curve: widget.calendarStyle.selectionAnimationCurve,
          width: widget.calendarStyle.dayIndicatorSize,
          height: widget.calendarStyle.dayIndicatorSize,
          decoration: ShapeDecoration(
            color: isSelected
                ? widget.calendarStyle.activeDayColor
                : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(widget.calendarStyle.dayIndicatorSize),
              side: BorderSide(
                color: isSelected
                    ? widget.calendarStyle.activeDayColor
                    : Colors.grey,
                width: 1.5,
              ),
            ),
            shadows: widget.calendarStyle.dayIndicatorShadow != null
                ? [widget.calendarStyle.dayIndicatorShadow!]
                : null,
          ),
          child: Center(child: content),
        );

      case WeekCalendarType.elevated:
        return Material(
          elevation: isSelected ? 8 : 1,
          borderRadius:
              BorderRadius.circular(widget.calendarStyle.dayIndicatorSize),
          child: AnimatedContainer(
            duration: widget.calendarStyle.selectionAnimationDuration,
            curve: widget.calendarStyle.selectionAnimationCurve,
            width: widget.calendarStyle.dayIndicatorSize,
            height: widget.calendarStyle.dayIndicatorSize,
            decoration: BoxDecoration(
              color: isSelected
                  ? widget.calendarStyle.activeDayColor
                  : Colors.white,
              borderRadius:
                  BorderRadius.circular(widget.calendarStyle.dayIndicatorSize),
            ),
            child: Center(child: content),
          ),
        );

      default:
        return AnimatedContainer(
          duration: widget.calendarStyle.selectionAnimationDuration,
          curve: widget.calendarStyle.selectionAnimationCurve,
          width: widget.calendarStyle.dayIndicatorSize,
          height: widget.calendarStyle.dayIndicatorSize,
          decoration: BoxDecoration(
            color: isSelected
                ? widget.calendarStyle.activeDayColor
                : widget.calendarStyle.dayIndicatorColor,
            shape: BoxShape.circle,
          ),
          child: Center(child: content),
        );
    }
  }

  /// Handles date selection logic and month transitions
  void _handleDaySelection(DateTime day) {
    widget.onDateSelected(day);
    final selectedMonth = DateTime(day.year, day.month);
    if (selectedMonth != DateTime(_headerDate.year, _headerDate.month)) {
      setState(() {
        _headerDate = selectedMonth;
        _weeks = _generateWeeks(_headerDate);
        final newPage = _findWeekIndex(_weeks, day);
        if (widget.enableAnimations) {
          _pageController.animateToPage(
            newPage,
            duration:
                widget.animationDuration ?? const Duration(milliseconds: 300),
            curve: widget.animationCurve ?? Curves.easeInOut,
          );
        } else {
          _pageController.jumpToPage(newPage);
        }
      });
      if (day.isBefore(_headerDate)) {
        widget.onPreviousMonth?.call();
      } else {
        widget.onNextMonth?.call();
      }
    }
    // AnimatedContainer automatically handles selection animation
  }

  /// Builds the month header with navigation controls
  Widget _buildMonthHeader() {
    final isMinimal = widget.calendarType == WeekCalendarType.minimal;

    return Padding(
      padding: isMinimal
          ? const EdgeInsets.symmetric(horizontal: 8)
          : const EdgeInsets.symmetric(horizontal: 16),
      child: Box(
        height: isMinimal ? 24 : 36,
        // color: Colors.yellow,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const Pad(horizontal: 11.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Previous Month Button
                    SInkButton(
                      color: Colors.blueAccent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.previousMonthIcon,
                          color: widget.iconColor,
                          size: isMinimal ? 20 : 24,
                        ),
                      ),
                      onTap: (pos) {
                        setState(() {
                          _headerDate =
                              DateTime(_headerDate.year, _headerDate.month - 1);
                          _weeks = _generateWeeks(_headerDate);
                          final newPage = _findWeekIndex(_weeks, _headerDate);
                          if (widget.enableAnimations) {
                            _pageController.animateToPage(
                              newPage,
                              duration: widget.animationDuration ??
                                  const Duration(milliseconds: 300),
                              curve: widget.animationCurve ?? Curves.easeInOut,
                            );
                          } else {
                            _pageController.jumpToPage(newPage);
                          }
                        });
                        widget.onPreviousMonth?.call();
                      },
                    ),

                    // Next Month Button and Today Button
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Date in Text format Header/button
                          SInkButton(
                            color: Colors.blueAccent,
                            onTap: (pos) async {
                              widget.onHeaderDateTapped?.call(pos);

                              if (widget.showCalendarPopupOnHeaderTap) {
                                final selectedDates =
                                    await showCalendarDatePicker2Dialog(
                                  context: context,
                                  config:
                                      CalendarDatePicker2WithActionButtonsConfig(
                                    calendarType:
                                        CalendarDatePicker2Type.single,
                                    selectedDayHighlightColor:
                                        widget.calendarStyle.activeDayColor,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                    currentDate: widget.selectedDate,
                                  ),
                                  dialogSize: const Size(325, 400),
                                  value: [widget.selectedDate],
                                  borderRadius: BorderRadius.circular(15),
                                );

                                if (selectedDates != null &&
                                    selectedDates.isNotEmpty) {
                                  final selectedDate = selectedDates.first;
                                  if (selectedDate != null) {
                                    _handleDaySelection(selectedDate);
                                  }
                                }
                              }
                            },
                            child: Padding(
                              padding: const Pad(horizontal: 8.0),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    if (!isMinimal)
                                      TextSpan(
                                        text: DateFormat('E  ').format(
                                            _headerDate.copyWith(
                                                day: widget.selectedDate.day)),
                                        style: widget
                                            .calendarStyle.monthHeaderStyle
                                            .copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    TextSpan(
                                      text: DateFormat(isMinimal
                                              ? '${_headerDate.month == widget.selectedDate.month && _headerDate.year == widget.selectedDate.year ? 'd' : ''} MMM y'
                                              : '${_headerDate.month == widget.selectedDate.month && _headerDate.year == widget.selectedDate.year ? 'dd' : ''} MMMM y')
                                          .format(_headerDate.copyWith(
                                              day: widget.selectedDate.day)),
                                      style: widget
                                          .calendarStyle.monthHeaderStyle
                                          .copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Today Button
                          if (!widget.selectedDate.isToday ||
                              (widget.selectedDate.month != _headerDate.month ||
                                  widget.selectedDate.year != _headerDate.year))
                            SInkButton(
                              color: Colors.blueAccent,
                              onTap: (pos) {
                                // Select today's date and navigate to it
                                final now = DateTime.now();
                                final today = widget.isUtc
                                    ? DateTime.utc(now.year, now.month, now.day)
                                    : DateTime(now.year, now.month, now.day);

                                // Select today's date
                                widget.onDateSelected(today);

                                // Update header date to today's month if different
                                final todayMonth = widget.isUtc
                                    ? DateTime.utc(today.year, today.month)
                                    : DateTime(today.year, today.month);

                                if (todayMonth.month != _headerDate.month ||
                                    todayMonth.year != _headerDate.year) {
                                  setState(() {
                                    _headerDate = todayMonth;
                                    _weeks = _generateWeeks(_headerDate);
                                    final newPage =
                                        _findWeekIndex(_weeks, today);
                                    if (widget.enableAnimations) {
                                      _pageController.animateToPage(
                                        newPage,
                                        duration: widget.animationDuration ??
                                            const Duration(milliseconds: 300),
                                        curve: widget.animationCurve ??
                                            Curves.easeInOut,
                                      );
                                    } else {
                                      _pageController.jumpToPage(newPage);
                                    }
                                  });
                                } else {
                                  // Same month, just animate to today's week
                                  final newPage = _findWeekIndex(_weeks, today);
                                  if (widget.enableAnimations) {
                                    _pageController.animateToPage(
                                      newPage,
                                      duration: widget.animationDuration ??
                                          const Duration(milliseconds: 300),
                                      curve: widget.animationCurve ??
                                          Curves.easeInOut,
                                    );
                                  } else {
                                    _pageController.jumpToPage(newPage);
                                  }
                                }

                                widget.onHeaderTodayDate?.call(pos);
                              },
                              child: SizedBox(
                                height: 35,
                                //width: 22,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Icon(
                                        Iconsax.calendar_1_outline,
                                        color: Colors.blue.shade800,
                                        size: 14,
                                      ),
                                    ),
                                    Text(
                                      "Today",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Colors.black.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Next Month Button
                    SInkButton(
                      color: Colors.blueAccent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.nextMonthIcon,
                          color: widget.iconColor,
                          size: isMinimal ? 20 : 24,
                        ),
                      ),
                      onTap: (pos) {
                        setState(() {
                          _headerDate = widget.isUtc
                              ? DateTime.utc(
                                  _headerDate.year, _headerDate.month + 1)
                              : DateTime(
                                  _headerDate.year, _headerDate.month + 1);
                          _weeks = _generateWeeks(_headerDate);
                          final newPage = _findWeekIndex(_weeks, _headerDate);
                          if (widget.enableAnimations) {
                            _pageController.animateToPage(
                              newPage,
                              duration: widget.animationDuration ??
                                  const Duration(milliseconds: 300),
                              curve: widget.animationCurve ?? Curves.easeInOut,
                            );
                          } else {
                            _pageController.jumpToPage(newPage);
                          }
                        });
                        widget.onNextMonth?.call();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Prev/Next Month Labels
            if (!isMinimal)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    "Prev Month",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                  ),
                  Text(
                    "Next Month",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = widget.isUtc
        ? DateTime.utc(now.year, now.month, now.day)
        : DateTime(now.year, now.month, now.day);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        // Month Header
        if (widget.showMonthHeader) _buildMonthHeader(),

        // the Calendar Days
        SizedBox(
          height: widget.calendarStyle.dayIndicatorSize * 2,
          child: Row(
            children: [
              // previous week button
              SInkButton(
                color: Colors.blueAccent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Icon(
                    Icons.skip_previous_outlined,
                    color: widget.iconColor,
                    size: 16,
                  ),
                ),
                onTap: (pos) {
                  setState(() {
                    // Jump to previous week
                    final currentPage = _pageController.page?.round() ?? 0;
                    if (currentPage == 0) {
                      // At start of month, jump to previous month
                      _headerDate = widget.isUtc
                          ? DateTime.utc(
                              _headerDate.year, _headerDate.month - 1)
                          : DateTime(_headerDate.year, _headerDate.month - 1);
                      _weeks = _generateWeeks(_headerDate);
                      final newPage =
                          _weeks.length - 1; // Last week of previous month
                      if (widget.enableAnimations) {
                        _pageController.animateToPage(
                          newPage,
                          duration: widget.animationDuration ??
                              const Duration(milliseconds: 300),
                          curve: widget.animationCurve ?? Curves.easeInOut,
                        );
                      } else {
                        _pageController.jumpToPage(newPage);
                      }
                      widget.onPreviousMonth?.call();
                    } else {
                      final previousPage =
                          (currentPage - 1).clamp(0, _weeks.length - 1);
                      if (widget.enableAnimations) {
                        _pageController.animateToPage(
                          previousPage,
                          duration: widget.animationDuration ??
                              const Duration(milliseconds: 300),
                          curve: widget.animationCurve ?? Curves.easeInOut,
                        );
                      } else {
                        _pageController.jumpToPage(previousPage);
                      }
                    }
                  });
                  widget.onPreviousWeek?.call();
                },
              ),

              // the Calendar Days
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _weeks.length,
                  itemBuilder: (context, index) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final dayWidth = constraints.maxWidth / 7;
                        return AnimatedSwitcher(
                          duration: widget.animationDuration ??
                              const Duration(milliseconds: 300),
                          switchInCurve:
                              widget.animationCurve ?? Curves.easeInOut,
                          child: Row(
                            key: ValueKey(_weeks[index]),
                            mainAxisAlignment: MainAxisAlignment.start,
                            children:
                                // Day Indicators
                                _weeks[index].map((day) {
                              final isSelected =
                                  _isSameDay(day, widget.selectedDate);

                              return Flexible(
                                child: SizedBox(
                                  width: dayWidth,
                                  child: SDisabled(
                                    isDisabled: day.isAfter(today),
                                    child: SInkButton(
                                      color: Colors.blueAccent,
                                      onTap: (pos) {
                                        _handleDaySelection(day);
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        spacing: 0,
                                        children: [
                                          if (widget.calendarType !=
                                              WeekCalendarType.minimal)
                                            Text(
                                              DateFormat('E')
                                                  .format(day)
                                                  .substring(0, 2),
                                              style: widget
                                                  .calendarStyle.dayNameStyle
                                                  .copyWith(
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : null,
                                                color: isSelected
                                                    ? widget.calendarStyle
                                                        .activeDayColor
                                                        .darken(0.2)
                                                    : null,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          Flexible(
                                              child: _buildDayIndicator(
                                                  day, isSelected)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // previous week button
              SInkButton(
                color: Colors.blueAccent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Icon(
                    Icons.skip_next_outlined,
                    color: widget.iconColor,
                    size: 16,
                  ),
                ),
                onTap: (pos) {
                  setState(() {
                    // Jump to next week
                    final currentPage = _pageController.page?.round() ?? 0;
                    if (currentPage == _weeks.length - 1) {
                      // At end of month, jump to next month
                      _headerDate = widget.isUtc
                          ? DateTime.utc(
                              _headerDate.year, _headerDate.month + 1)
                          : DateTime(_headerDate.year, _headerDate.month + 1);
                      _weeks = _generateWeeks(_headerDate);
                      final newPage = 0; // First week of next month
                      if (widget.enableAnimations) {
                        _pageController.animateToPage(
                          newPage,
                          duration: widget.animationDuration ??
                              const Duration(milliseconds: 300),
                          curve: widget.animationCurve ?? Curves.easeInOut,
                        );
                      } else {
                        _pageController.jumpToPage(newPage);
                      }
                      widget.onNextMonth?.call();
                    } else {
                      final nextPage =
                          (currentPage + 1).clamp(0, _weeks.length - 1);
                      if (widget.enableAnimations) {
                        _pageController.animateToPage(
                          nextPage,
                          duration: widget.animationDuration ??
                              const Duration(milliseconds: 300),
                          curve: widget.animationCurve ?? Curves.easeInOut,
                        );
                      } else {
                        _pageController.jumpToPage(nextPage);
                      }
                    }
                  });
                  widget.onNextWeek?.call();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

//**************************** */
