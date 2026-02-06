# s_time

A comprehensive Flutter package for intuitive time selection with two powerful widgets: **TimeSpinner** for wheel-based selection and **TimeInput** for text-based input.

[![pub package](https://img.shields.io/pub/v/s_time.svg)](https://pub.dev/packages/s_time)
[![GitHub](https://img.shields.io/badge/GitHub-SoundSliced%2Fs_time-blue?logo=github)](https://github.com/SoundSliced/s_time)

## Features

### TimeSpinner Widget
- 🎡 **Infinite Scroll Wheels**: Smooth, continuous scrolling for hours and minutes
- 🕐 **Dual Format Support**: 12-hour (with AM/PM) and 24-hour formats
- 🎨 **Extensive Customization**: Custom colors, text styles, borders, and dimensions
- 🔧 **Custom Values**: Define your own hour/minute values (e.g., every 2 hours, every 15 minutes)
- 🚫 **Value Exclusion**: Discard specific hours or minutes (e.g., lunch breaks)
- ⌨️ **Keyboard Editing**: Double-tap to type time directly
- 🔄 **Real-time Callbacks**: Get updates as user selects time
- ⭕ **No-Selection Dots**: Toggle visual indicators for selections

### TimeInput Widget
- ⌨️ **Smart Cursor Positioning**: Cursor always placed where user taps
- 🔤 **Dual Text Modes**: Shows formatted time (HH:MM z) when unfocused, digits-only when focused
- 🎯 **Auto-Formatting**: Converts input like "1030" to "10:30" automatically
- ⌨️ **Keyboard Navigation**: Enter to submit, Escape to revert
- ✅ **Input Validation**: Real-time validation with helpful error messages
- 🎨 **Fully Customizable**: Colors, sizes, padding, border radius, and input decoration
- 🌍 **UTC/Local Time**: Choose between UTC and local time
- 📝 **Optional Values**: Support for null/empty time inputs
- 🔔 **Change Callbacks**: Optional onChanged and onSubmitted callbacks

## Screenshots

![TimeSpinner and TimeInput Demo](https://raw.githubusercontent.com/SoundSliced/s_time/main/example/assets/example.gif)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  s_time: ^1.0.5
```

Then run:
```bash
flutter pub get
```

## Basic Usage

### TimeSpinner - Wheel Time Picker

```dart
import 'package:s_time/s_time.dart';

class TimePickerDemo extends StatefulWidget {
  @override
  State<TimePickerDemo> createState() => _TimePickerDemoState();
}

class _TimePickerDemoState extends State<TimePickerDemo> {
  TimeOfDay? selectedTime = const TimeOfDay(hour: 10, minute: 30);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TimeSpinner Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TimeSpinner(
              initTime: selectedTime,
              is24HourFormat: false,
              onChangedSelectedTime: (time) {
                setState(() {
                  selectedTime = time;
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Selected: ${selectedTime?.hour}:${selectedTime?.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
```

### TimeInput - Text Field Time Input

```dart
import 'package:s_time/s_time.dart';

class TimeInputDemo extends StatefulWidget {
  @override
  State<TimeInputDemo> createState() => _TimeInputDemoState();
}

class _TimeInputDemoState extends State<TimeInputDemo> {
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TimeInput Demo')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TimeInput(
              title: 'Start Time',
              time: selectedTime,
              onSubmitted: (time) {
                setState(() {
                  selectedTime = time;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selected: $time')),
                );
              },
            ),
            const SizedBox(height: 32),
            if (selectedTime != null)
              Text(
                'Time: ${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
```

## Advanced Usage

### TimeSpinner with Custom Configuration

```dart
TimeSpinner(
  initTime: const TimeOfDay(hour: 14, minute: 30),
  is24HourFormat: true,
  spinnerHeight: 150,
  spinnerWidth: 80,
  digitHeight: 50,
  // Custom hour values: every 2 hours (0, 2, 4, ..., 22)
  hrValues: List.generate(12, (i) => i * 2),
  // Custom minute values: every 15 minutes
  minValues: const [0, 15, 30, 45],
  // Discard lunch hours (13-17)
  discardedHrValues: const [13, 14, 15, 16, 17],
  selectedTextStyle: const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
  nonSelectedTextStyle: const TextStyle(
    fontSize: 20,
    color: Colors.grey,
  ),
  spinnerBgColor: const Color(0xFFF5F5F5),
  borderRadius: BorderRadius.circular(16),
  spinnerBorder: Border.all(color: Colors.blue, width: 2),
  amPmButtonStyle: AmPmButtonStyle(
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    selectedColor: Colors.blue.withValues(alpha: 0.2),
    borderColor: Colors.blue,
    borderRadius: BorderRadius.circular(8),
  ),
  onChangedSelectedTime: (time) {
    print('Selected time: $time');
  },
)
```

### TimeInput with Custom Styling

```dart
TimeInput(
  title: 'Meeting Time',
  time: DateTime(2024, 1, 1, 14, 30),
  autoFocus: true,
  colorPerTitle: const {'Meeting Time': Colors.purple},
  inputFontSize: 18,
  borderRadius: 16,
  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
  inputDecoration: InputDecoration(
    fillColor: Colors.purple.withValues(alpha: 0.05),
    filled: true,
    hintText: 'Enter time (HHMM)',
    labelText: 'Select Time',
    prefixIcon: const Icon(Icons.access_time),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.purple, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.purple, width: 2),
    ),
  ),
  onSubmitted: (time) {
    print('Time submitted: $time');
  },
)
```

### TimeInput with Optional/Nullable Values

```dart
TimeInput(
  title: 'Optional Reminder',
  time: null, // Can be null
  isEmptyWhenTimeNull: true, // Show empty field for null
  showClearButton: true, // Add clear button
  defaultTime: const TimeOfDay(hour: 9, minute: 0), // Fallback if invalid
  onSubmitted: (time) {
    if (time == null) {
      print('No time selected');
    } else {
      print('Time: $time');
    }
  },
)
```

### TimeInput with Local Time

```dart
TimeInput(
  title: 'Local Time',
  time: DateTime.now(),
  isUtc: false, // Use local time instead of UTC
  onSubmitted: (time) {
    print('Local time: $time');
  },
)
```

## API Reference

### TimeSpinner Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `initTime` | `TimeOfDay?` | `null` | Initial time value |
| `is24HourFormat` | `bool` | `false` | Use 24-hour format (no AM/PM) |
| `spinnerHeight` | `double` | `120` | Height of the spinner |
| `spinnerWidth` | `double` | `60` | Width of each digit column |
| `elementsSpace` | `double` | `8` | Space between hour and minute |
| `digitHeight` | `double` | `40` | Height of each digit |
| `spinnerBgColor` | `Color` | `Color(0xFFF5F5F5)` | Background color |
| `selectedTextStyle` | `TextStyle` | Blue 24px Bold | Style for selected value |
| `nonSelectedTextStyle` | `TextStyle` | Grey 18px | Style for non-selected values |
| `hrValues` | `List<int>?` | `null` | Custom hour values |
| `minValues` | `List<int>?` | `null` | Custom minute values |
| `discardedHrValues` | `List<int>` | `[]` | Hours to exclude from selection |
| `discardedMinValues` | `List<int>` | `[]` | Minutes to exclude from selection |
| `borderRadius` | `BorderRadiusGeometry?` | `null` | Border radius of spinner |
| `spinnerBorder` | `BoxBorder?` | `null` | Border of spinner |
| `showNoSelectionDots` | `bool` | `true` | Show selection dots |
| `amPmButtonStyle` | `AmPmButtonStyle?` | `null` | Custom AM/PM button styling |
| `onChangedSelectedTime` | `Function(TimeOfDay?)` | Required | Callback when time changes |

### TimeInput Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `title` | `String` | Required | Label for the input field |
| `time` | `DateTime?` | `null` | Initial time value |
| `autoFocus` | `bool` | `false` | Auto-focus on widget |
| `replaceAllTextOnAutoFocus` | `bool` | `true` | Replace all text when auto-focused |
| `isEmptyWhenTimeNull` | `bool` | `false` | Show empty field when time is null |
| `showClearButton` | `bool` | `false` | Show clear button |
| `defaultTime` | `TimeOfDay?` | `null` | Fallback time for invalid input |
| `isUtc` | `bool` | `true` | Use UTC (false for local time) |
| `colorPerTitle` | `Map<String, Color>?` | `null` | Color per title |
| `inputFontSize` | `double?` | `null` | Font size for input text |
| `borderRadius` | `double?` | `null` | Border radius of input |
| `contentPadding` | `EdgeInsets?` | `null` | Padding inside input |
| `inputDecoration` | `InputDecoration?` | `null` | Custom input decoration |
| `onSubmitted` | `Function(TimeOfDay?)?` | `null` | Callback when submitted |
| `onChanged` | `Function(TimeOfDay?)?` | `null` | Callback when changed |

## Keyboard Shortcuts

### TimeInput
- **Enter**: Submit current input
- **Escape**: Revert to previous value and submit
- **Double-tap** (TimeSpinner): Switch to keyboard editing mode

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues, feature requests, or questions, please visit the [GitHub Issues](https://github.com/SoundSliced/s_time/issues) page.

---

Made with ❤️ by [SoundSliced](https://github.com/SoundSliced)
