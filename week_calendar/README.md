# week_calendar

[![pub package](https://img.shields.io/pub/v/week_calendar.svg)](https://pub.dev/packages/week_calendar)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A highly customizable Flutter package that provides a horizontally scrollable weekly calendar widget with multiple visual styles and extensive configuration options.


## Screenshots

![Week Calendar Example](https://raw.githubusercontent.com/SoundSliced/week_calendar/main/example/assets/example.gif)


## Features

- **Multiple Calendar Types**: Standard (circular), Outlined, Minimal (text-based), and Elevated styles
- **Flexible Week Configuration**: Start week on any day (Monday-Sunday)
- **Customizable Styling**: Colors, sizes, fonts, borders, shadows, and animations
- **Rich Interactions**: Date selection, month navigation, header callbacks, and today button
- **Animation Control**: Configurable duration, curves, and enable/disable options
- **UTC/Local Date Support**: Handle both UTC and local time zones
- **Comprehensive Callbacks**: Track all user interactions
- **Material Design**: Follows Flutter's design principles

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  week_calendar: ^1.1.0
```

Then run:

```bash
flutter pub get
```

## Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:week_calendar/week_calendar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _initialDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Week Calendar'),
      ),
      body: Column(
        children: [
          WeekCalendar(
            initialDate: _initialDate,
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            onNextMonth: () {
              setState(() {
                _initialDate = DateTime(
                  _initialDate.year,
                  _initialDate.month + 1,
                );
              });
            },
            onPreviousMonth: () {
              setState(() {
                _initialDate = DateTime(
                  _initialDate.year,
                  _initialDate.month - 1,
                );
              });
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Selected: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
```

## Calendar Types

### Standard Calendar (Default)
```dart
WeekCalendar(
  initialDate: DateTime.now(),
  selectedDate: DateTime.now(),
  onDateSelected: (date) => print('Selected: $date'),
  onNextMonth: () => print('Next month'),
  onPreviousMonth: () => print('Previous month'),
)
```

### Outlined Calendar
```dart
WeekCalendar.outlined(
  initialDate: DateTime.now(),
  selectedDate: DateTime.now(),
  onDateSelected: (date) => print('Selected: $date'),
  onNextMonth: () => print('Next month'),
  onPreviousMonth: () => print('Previous month'),
)
```

### Minimal Calendar
```dart
WeekCalendar.minimal(
  initialDate: DateTime.now(),
  selectedDate: DateTime.now(),
  onDateSelected: (date) => print('Selected: $date'),
  onNextMonth: () => print('Next month'),
  onPreviousMonth: () => print('Previous month'),
)
```

### Elevated Calendar
```dart
WeekCalendar(
  calendarType: WeekCalendarType.elevated,
  initialDate: DateTime.now(),
  selectedDate: DateTime.now(),
  onDateSelected: (date) => print('Selected: $date'),
  onNextMonth: () => print('Next month'),
  onPreviousMonth: () => print('Previous month'),
)
```

## Advanced Usage

### Custom Styling
```dart
WeekCalendar(
  initialDate: DateTime.now(),
  selectedDate: DateTime.now(),
  calendarStyle: const WeekCalendarStyle(
    monthHeaderStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.blue,
    ),
    dayNameStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.blueAccent,
    ),
    dayNumberStyle: const TextStyle(fontSize: 18),
    selectedDayTextStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    inactiveDayTextStyle: const TextStyle(
      fontSize: 16,
      color: Colors.grey,
    ),
    activeDayColor: Colors.blueAccent,
    dayIndicatorColor: Colors.blue.shade50,
    dayIndicatorSize: 40,
    selectionAnimationDuration: Duration(milliseconds: 400),
    selectionAnimationCurve: Curves.elasticOut,
  ),
  onDateSelected: (date) => print('Selected: $date'),
  onNextMonth: () => print('Next month'),
  onPreviousMonth: () => print('Previous month'),
)
```

### Custom Week Starting Day
```dart
WeekCalendar(
  initialDate: DateTime.now(),
  selectedDate: DateTime.now(),
  startingDay: Weekday.sunday, // Start week on Sunday
  onDateSelected: (date) => print('Selected: $date'),
  onNextMonth: () => print('Next month'),
  onPreviousMonth: () => print('Previous month'),
)
```

### Animation Controls
```dart
WeekCalendar(
  initialDate: DateTime.now(),
  selectedDate: DateTime.now(),
  enableAnimations: true,
  animationDuration: const Duration(milliseconds: 500),
  animationCurve: Curves.bounceOut,
  onDateSelected: (date) => print('Selected: $date'),
  onNextMonth: () => print('Next month'),
  onPreviousMonth: () => print('Previous month'),
)
```

### Rich Callbacks
```dart
WeekCalendar(
  initialDate: DateTime.now(),
  selectedDate: DateTime.now(),
  onDateSelected: (date) => print('Date selected: $date'),
  onNextMonth: () => print('Navigated to next month'),
  onPreviousMonth: () => print('Navigated to previous month'),
  onNextWeek: () => print('Navigated to next week'),
  onPreviousWeek: () => print('Navigated to previous week'),
  onHeaderDateTapped: (position) {
    print('Header tapped at position: $position');
    // Show calendar picker dialog
  },
  onHeaderTodayDate: (position) {
    print('Today button tapped at position: $position');
    // Jump to today's date
  },
)
```

### UTC Date Support
```dart
WeekCalendar(
  initialDate: DateTime.utc(2024, 1, 1),
  selectedDate: DateTime.utc(2024, 1, 15),
  isUtc: true, // Use UTC dates
  onDateSelected: (date) => print('Selected UTC date: $date'),
  onNextMonth: () => print('Next month'),
  onPreviousMonth: () => print('Previous month'),
)
```

## API Reference

### WeekCalendar

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `initialDate` | `DateTime` | Required | Initial month to display |
| `selectedDate` | `DateTime` | Required | Currently selected date |
| `onDateSelected` | `ValueChanged<DateTime>` | Required | Callback when date is selected |
| `calendarType` | `WeekCalendarType` | `WeekCalendarType.standard` | Visual style of the calendar |
| `calendarStyle` | `WeekCalendarStyle` | `WeekCalendarStyle()` | Complete styling configuration |
| `animationDuration` | `Duration?` | `null` | Custom animation duration |
| `animationCurve` | `Curve?` | `null` | Custom animation curve |
| `showMonthHeader` | `bool` | `true` | Show/hide month header |
| `previousMonthIcon` | `IconData?` | `Icons.chevron_left` | Previous month navigation icon |
| `nextMonthIcon` | `IconData?` | `Icons.chevron_right` | Next month navigation icon |
| `iconColor` | `Color?` | `null` | Color for navigation icons |
| `startingDay` | `Weekday?` | `null` | First day of the week |
| `enableAnimations` | `bool` | `true` | Enable/disable all animations |
| `onNextMonth` | `VoidCallback?` | `null` | Callback for next month navigation |
| `onPreviousMonth` | `VoidCallback?` | `null` | Callback for previous month navigation |
| `onNextWeek` | `VoidCallback?` | `null` | Callback for next week navigation |
| `onPreviousWeek` | `VoidCallback?` | `null` | Callback for previous week navigation |
| `onHeaderDateTapped` | `Function(Offset)?` | `null` | Callback when header date is tapped |
| `onHeaderTodayDate` | `Function(Offset)?` | `null` | Callback when today button is tapped |
| `isUtc` | `bool` | `true` | Use UTC dates instead of local |
| `showCalendarPopupOnHeaderTap` | `bool` | `true` | Show calendar popup on header tap |

### WeekCalendarType

- `standard`: Default circular day indicators
- `outlined`: Outlined containers with borders
- `minimal`: Simplified text-based display
- `elevated`: Material-elevated containers

### Weekday

- `monday`, `tuesday`, `wednesday`, `thursday`, `friday`, `saturday`, `sunday`

### WeekCalendarStyle

Complete styling configuration with properties for colors, sizes, fonts, borders, shadows, and animations.

## Example App

For a comprehensive demonstration of all features, run the example app:

```bash
cd example
flutter run
```

The example app includes:
- All calendar types and styles
- Interactive customization options
- Real-time style updates
- Complete code examples

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Issues

If you encounter any issues or have feature requests, please file them on the [GitHub Issues](https://github.com/SoundSliced/week_calendar/issues) page.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.</content>
<parameter name="filePath">/Users/christophechanteur/Development/Flutter_projects/my_extensions/week_calendar/README.md