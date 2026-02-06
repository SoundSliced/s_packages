# s_bounceable

A Flutter package providing a bounceable widget with intelligent single and double tap detection, built on top of `flutter_bounceable`.

[![pub package](https://img.shields.io/pub/v/s_bounceable.svg)](https://pub.dev/packages/s_bounceable)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

✨ **Smooth Bounce Animation** - Provides satisfying visual feedback using scale animations

👆 **Smart Tap Detection** - Intelligently distinguishes between single and double taps

⚙️ **Customizable** - Configure scale factor to match your design requirements

🎯 **Easy to Use** - Simple API that wraps any Flutter widget

🧪 **Well Tested** - Comprehensive test coverage for reliable behavior

## Demo
![Demo](https://raw.githubusercontent.com/SoundSliced/s_bounceable/main/example/assets/example.gif)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  s_bounceable: ^2.1.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Example

Import the package:

```dart
import 'package:s_bounceable/s_bounceable.dart';
```

Wrap any widget with `SBounceable`:

```dart
SBounceable(
  onTap: () {
    debugPrint('Single tap!');
  },
  onDoubleTap: () {
    debugPrint('Double tap!');
  },
  child: Container(
    padding: const EdgeInsets.all(24.0),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Text(
      'Tap or Double Tap Me',
      style: TextStyle(color: Colors.white, fontSize: 18),
    ),
  ),
)
```

### Custom Scale Factor

Adjust the bounce intensity:

```dart
SBounceable(
  onTap: () => print('Tapped'),
  scaleFactor: 0.90, // More pronounced bounce (default is 0.95)
  child: YourWidget(),
)
```

### Single Tap Only

```dart
SBounceable(
  onTap: () => print('Tapped'),
  child: YourWidget(),
)
```

### Double Tap Only

```dart
SBounceable(
  onDoubleTap: () => print('Double tapped'),
  child: YourWidget(),
)
```

## Complete Example

See the full working example in the [`example`](example/lib/main.dart) directory:

```dart
import 'package:flutter/material.dart';
import 'package:s_bounceable/s_bounceable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('SBounceable Example')),
        body: Center(
          child: SBounceable(
            onTap: () {
              debugPrint('Single tap!');
            },
            onDoubleTap: () {
              debugPrint('Double tap!');
            },
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Tap or Double Tap Me',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

## How It Works

The `SBounceable` widget uses a smart tap detection algorithm:

- **Double Tap Threshold**: 300ms window to detect double taps
- **Single Tap Delay**: Waits for the threshold period before executing single tap to avoid false triggers
- **Triple Tap Prevention**: Resets state after double tap to prevent unintended triple taps

## API Reference

### SBounceable

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `child` | `Widget` | Yes | - | The widget to make bounceable |
| `onTap` | `VoidCallback?` | No | `null` | Callback for single tap |
| `onDoubleTap` | `VoidCallback?` | No | `null` | Callback for double tap |
| `scaleFactor` | `double?` | No | `0.95` | Scale factor for bounce effect (0.0 to 1.0) |

## Dependencies

This package depends on:
- [`flutter_bounceable`](https://pub.dev/packages/flutter_bounceable) ^1.2.0 - For the underlying bounce animation

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Christophe Chanteur

## Repository

https://github.com/SoundSliced/s_bounceable

## Issues

Please file issues at: https://github.com/SoundSliced/s_bounceable/issues
