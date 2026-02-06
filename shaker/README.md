# Shaker

A Flutter package that provides an easy-to-use widget for adding shake animations to any Flutter widget. Built on top of the powerful `flutter_animate` package, Shaker offers a simple API with extensive customization options.

[![pub package](https://img.shields.io/pub/v/shaker.svg)](https://pub.dev/packages/shaker)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Demo

![Demo](https://raw.githubusercontent.com/SoundSliced/shaker/main/example/assets/example.gif)



## Features

✨ **Easy Integration** - Wrap any widget with `Shaker` to add shake animations

🎨 **Highly Customizable** - Control duration, frequency, rotation, offset, and animation curves

⚡ **Performance Optimized** - Built on flutter_animate for smooth, efficient animations

🎯 **Callback Support** - Execute actions when animations complete

📱 **Platform Independent** - Works seamlessly across all Flutter platforms

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  shaker: ^1.0.2
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:shaker/shaker.dart';

class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  bool _isShaking = false;

   void _triggerShake({bool autoReset = true}) {
    setState(() {
      _isShaking = true;
    });

    // Reset shake state after animation completes
    if (autoReset) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _isShaking = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Shaker(
          isShaking: _isShaking,
          child: Icon(Icons.favorite, size: 100, color: Colors.red),
        ),
        ElevatedButton(
          onPressed: _triggerShake,
          child: Text('Shake It!'),
        ),
      ],
    );
  }
}
```

### Advanced Example with Custom Parameters

```dart
Shaker(
  isShaking: _isShaking,
  duration: const Duration(milliseconds: 800),
  hz: 6, // Shake frequency
  rotation: -0.05, // Rotation angle
  offset: const Offset(0.3, 0.3), // Shake direction and intensity
  curve: Curves.bounceInOut, // Animation curve
  onComplete: () {
    print('Shake animation completed!');
    setState(() {
        _isShaking = false;
      });
  },
  child: Container(
    width: 100,
    height: 100,
    color: Colors.blue,
    child: Center(child: Text('Shake Me!')),
  ),
)
```

## API Reference

### Shaker Widget Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `child` | `Widget` | **required** | The widget to apply shake animation to |
| `isShaking` | `bool` | `false` | Controls whether the shake animation is active |
| `duration` | `Duration?` | `1500ms` | Duration of the shake animation |
| `hz` | `double?` | `4` | Frequency of the shake (higher = faster) |
| `rotation` | `double?` | `-0.03` | Rotation angle during shake |
| `offset` | `Offset?` | `Offset(0.2, 0.5)` | Direction and intensity of shake |
| `curve` | `Curve?` | `Curves.easeInOut` | Animation curve for easing |
| `onComplete` | `Function?` | `null` | Callback executed when animation completes |

## Example App

Check out the [example](example/) directory for a complete sample application demonstrating various use cases:

- Basic shake animation
- Custom shake parameters
- Different widget types (Icons, Containers, etc.)
- Animation callbacks

To run the example:

```bash
cd example
flutter run
```

## Testing

The package includes comprehensive tests. Run them with:

```bash
flutter test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Repository

https://github.com/SoundSliced/shaker

## Issues and Feedback

Please file issues, bugs, or feature requests in our [issue tracker](https://github.com/SoundSliced/shaker/issues).

## Credits

Built with ❤️ using [flutter_animate](https://pub.dev/packages/flutter_animate)
