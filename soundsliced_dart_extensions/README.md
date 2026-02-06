# soundsliced_dart_extensions

A comprehensive collection of Dart & Flutter extensions to simplify everyday development tasks and enhance code readability. It includes rich utilities for time, formatting, collections, UI layout, JSON, colors, and more.

## Features

This package provides extensive extensions for:

### DateTime & Duration
- **Duration shortcuts**: `5.seconds`, `2.minutes`, `1.hours`, `3.days`
- **DateTime utilities**: Convert to date, adjust time, round to nearest minute
- **String parsing**: Convert time strings to DateTime
- **Formatting**: Easy string conversions with customizable formats

### String Extensions
- **Type conversion**: Parse booleans, convert to lists
- **Formatting**: Capitalize sentences, beautify JSON
- **JSON utilities**: Decode and beautify JSON strings

### List Extensions
- **Safe access**: Null-safe element access with index checking
- **Chunking**: Split lists into smaller chunks
- **Sorting**: Alphanumeric sorting for string lists

### Color Extensions
- **Manipulation**: Lighten and darken colors
- **Conversion**: Convert to hex strings

### EdgeInsets Extensions
- **Fluent API**: Chain padding modifications
- **Smart padding**: Apply first non-zero padding value
- **Modification**: Add to existing padding values

### TimeOfDay Extensions
- **JSON support**: Serialize/deserialize
- **Conversion**: Convert to Duration, DateTime, formatted strings
- **Manipulation**: Add/subtract minutes, round to intervals

### Additional Utilities
- **Offset utilities**: Calculate distance, check direction
- **Map extensions**: Convert to lists
- **Scroll controller**: Animate to bottom
- **Type conversions**: String to URI, various type parsers

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  soundsliced_dart_extensions: ^1.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

Import the package:

```dart
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';
```

### Duration Examples

```dart
// Create durations with intuitive syntax
final duration1 = 5.seconds;
final duration2 = 2.minutes;
final duration3 = 1.hours;
final duration4 = 3.days;

// Convert Duration to easy-read string
final formatted = duration1.convertToEasyReadString(); // "05 sec"
```

### DateTime Examples

```dart
// Round datetime to nearest interval
final now = DateTime.now();
final rounded = now.toNearestMinute(nearestMinute: 15);

// Convert to date only (remove time)
final dateOnly = now.convertToDate();

// Get month name
final monthName = now.convertToMonthString(); // "JAN", "FEB", etc.
```

### String Extensions

```dart
// Capitalize sentences
final text = "hello world. how are you?";
final capitalized = text.capitalizeFirstLetterOfEverySentence();
// "Hello world. How are you?"

// Parse boolean
final boolValue = "true".parseBool(); // true

// Convert string to list
final listString = "[item1, item2, item3]";
final list = listString.convertToListString();
```

### Color Extensions

```dart
// Lighten/darken colors
final color = Colors.blue;
final lighter = color.lighten(0.2); // 20% lighter
final darker = color.darken(0.3);   // 30% darker

// Convert to hex
final hexColor = toHex(Colors.red); // "#FFFF0000"
```

### EdgeInsets & Layout Extensions
Fluent & tuple based syntaxes:

```dart
final p1 = 12.leftPad; // EdgeInsets.only(left: 12)
final p2 = (8, 16).leftPad.rightPad; // left=8, right=16
final p3 = (5, 10, 15).leftPad.topPad.rightPad; // left=5, top=10, right=15
final p4 = (4, 8, 12, 16).leftPad.topPad.rightPad.bottomPad; // left=4, top=8, right=12, bottom=16

final fluent = EdgeInsets.all(10)
  .addToTop(5)
  .leftPad // copies first non-zero to left
  .rightPad; // copies that same value to right
```

```dart
// Fluent padding API
final padding = EdgeInsets.all(10.0)
    .withLeft(20.0)
    .addToTop(5.0);

// Smart padding (use first non-zero value)
final base = EdgeInsets.only(left: 10.0);
final samePadding = base.rightPad; // Uses left value for right
```

### TimeOfDay Extensions

```dart
// Convert to Duration
final time = TimeOfDay(hour: 14, minute: 30);
final duration = time.convertToDuration(); // 14h 30min

// Format as string
final formatted = time.convertToStringTime(); // "14:30"

// Add/subtract minutes
final later = time.addMinutes(45); // 15:15
final earlier = time.subtractMinutes(30); // 14:00

// Round to interval
final rounded = time.toNearestMinute(nearestMinute: 15);
```

### List & Iterable Extensions
```dart
final list = [1,2,3];
final safeValue = list.safe[10]; // null (out of range)
final firstEven = list.findFirstWhereOrNull((e) => e.isEven); // 2
```

```dart
// Safe element access
final list = [1, 2, 3];
final element = list.safe[10]; // null instead of error

// Check if index exists
if (list.doesIndexExist(5)) {
  print(list[5]);
}

// Split into chunks
final letters = ['a', 'b', 'c', 'd', 'e'];
final chunks = letters.splitInChunks(2); // [[a, b], [c, d], [e]]
```

### JSON Beautifier & Parsing
Beautify maps & lists with embedded JSON strings:

```dart
final raw = {
  'id': '123',
  'payload': '{"value":42,"inner":"{\\"x\\":1}"}'
};
final pretty = raw.beautifiedJson; // formatted, nested JSON decoded

final jsonString = '{"id":"123","payload":{"value":42,"inner":{"x":1}}}';
final decoded = jsonString.decodeBeautifiedJsonMap; // nested structure recovered
```

### BorderRadius Helpers
```dart
final circle = 12.allRad; // BorderRadius.circular(12)
final topCorners = 8.topRad; // Only top corners 8
```

## Requirements

- Dart SDK: `>=3.0.0 <4.0.0`
- Flutter: `>=3.0.0`

## Dependencies

- `fpdart: ^1.2.0`
- `intl: ^0.20.2`
- `sizer: ^3.1.3`
- `xid: ^1.2.1`
- `collection: ^1.19.1`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Issues

Please file issues on the [GitHub repository](https://github.com/SoundSliced/soundsliced_dart_extensions/issues).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Repository

https://github.com/SoundSliced/soundsliced_dart_extensions

## Example Project
See `example/lib/main.dart` for a concise runnable showcase of the core extensions.
