# ticker_free_circular_progress_indicator

[![pub package](https://img.shields.io/pub/v/ticker_free_circular_progress_indicator.svg)](https://pub.dev/packages/ticker_free_circular_progress_indicator)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A hot-restart safe circular progress indicator that doesn't use `TickerProviderStateMixin`, using manual frame callbacks for animations.

## Features

- 🚀 **Hot-restart safe**: No `TickerProviderStateMixin` required
- 🎯 **Manual animations**: Uses `Timer.periodic` for frame callbacks
- 📊 **Dual modes**: Supports both determinate and indeterminate progress
- ⏱️ **Delay support**: Optional delay with default widget after timeout
- 🎨 **Customizable**: Colors, stroke width, stroke cap, and alignment
- 🔄 **Smooth animations**: Matches Flutter's native progress indicator behavior

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  ticker_free_circular_progress_indicator: ^1.0.0
```

Or install via command line:

```bash
flutter pub add ticker_free_circular_progress_indicator
```

## Usage

### Basic Indeterminate Progress Indicator

```dart
import 'package:ticker_free_circular_progress_indicator/ticker_free_circular_progress_indicator.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const TickerFreeCircularProgressIndicator();
  }
}
```

### Determinate Progress Indicator

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TickerFreeCircularProgressIndicator(
      value: 0.75, // 75% progress
    );
  }
}
```

### Custom Styled Progress Indicator

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TickerFreeCircularProgressIndicator(
      color: Colors.blue,
      backgroundColor: Colors.blue.withValues(alpha: 0.2),
      strokeWidth: 6.0,
      strokeAlign: -1.0, // Inside stroke
      strokeCap: StrokeCap.round,
    );
  }
}
```

### With Delay and Default Widget

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TickerFreeCircularProgressIndicator(
      delay: const Duration(seconds: 5),
      defaultWidgetAfterDelay: const Text('Taking longer than expected...'),
    );
  }
}
```

## API Reference

### Constructor Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `key` | `Key?` | `null` | Widget key |
| `value` | `double?` | `null` | Progress value (0.0 to 1.0). If null, shows indeterminate progress |
| `backgroundColor` | `Color?` | `null` | Background track color |
| `color` | `Color?` | `null` | Progress indicator color (uses theme primary if null) |
| `strokeWidth` | `double` | `4.0` | Width of the progress stroke |
| `strokeAlign` | `double` | `0.0` | Stroke alignment (-1.0 = inside, 0.0 = center, 1.0 = outside) |
| `strokeCap` | `StrokeCap?` | `null` | Stroke cap style |
| `semanticsLabel` | `String?` | `null` | Accessibility label |
| `semanticsValue` | `String?` | `null` | Accessibility value |
| `delay` | `Duration?` | `null` | Delay before showing default widget |
| `defaultWidgetAfterDelay` | `Widget?` | `null` | Widget to show after delay expires |

## Why Ticker-Free?

Traditional Flutter progress indicators require a `TickerProviderStateMixin` in their state class. This can cause issues during hot restart in development, as the ticker provider may not be properly disposed and recreated.

This package solves this by:
- Using `Timer.periodic` for frame callbacks instead of `Ticker`
- Manually managing animation timing
- Providing the same visual behavior as Flutter's native `CircularProgressIndicator`

## Performance

- Minimal CPU usage with 60fps animation updates
- No dependency on animation framework
- Lightweight implementation with manual memory management

## Example App

Run the example app to see all features in action:

```bash
cd example
flutter run
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Issues

If you encounter any issues or have feature requests, please file them on the [GitHub issue tracker](https://github.com/SoundSliced/ticker_free_circular_progress_indicator/issues).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
