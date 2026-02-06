# soundsliced_tween_animation_builder

A Flutter package providing a custom `TweenAnimationBuilder` that uses Timer-based animations instead of ticker providers, making it resilient to hot restarts and engine assertions.

## Features

- **Drop-in replacement** for Flutter's `TweenAnimationBuilder`
- **Timer-based animation** that survives hot restarts without engine assertions
- **Auto-repeat support** for continuous animations
- **Animation key** to programmatically restart animations
- **Curve support** for custom easing functions
- **Callback on animation end** for chaining animations

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  soundsliced_tween_animation_builder: ^1.2.0
```

Then run:

```bash
flutter pub get
```

## Breaking change in 1.2.0

The widget has been renamed to `STweenAnimationBuilder`.

Migration:

- Replace any previous widget name from earlier versions with `STweenAnimationBuilder`.
- The constructor parameters and behavior are unchanged.

## Usage

Import the package:

```dart
import 'package:soundsliced_tween_animation_builder/soundsliced_tween_animation_builder.dart';
```

### Basic Example

Here's the example from the `example/` directory:

```dart
import 'package:flutter/material.dart';
import 'package:soundsliced_tween_animation_builder/soundsliced_tween_animation_builder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Example')),
        body: Center(
          child: STweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: const Text('Animated Text'),
              );
            },
          ),
        ),
      ),
    );
  }
}
```

### Auto-Repeat Animation

```dart
STweenAnimationBuilder<double>(
  tween: Tween<double>(begin: 0.0, end: 360.0),
  duration: Duration(seconds: 2),
  autoRepeat: true,
  builder: (context, value, child) {
    return Transform.rotate(
      angle: value * 3.14159 / 180, // Convert to radians
      child: Container(
        width: 100,
        height: 100,
        color: Colors.red,
        child: Center(child: Text('Spinning')),
      ),
    );
  },
)
```

### Restart Animation with Key

```dart
class RestartableAnimation extends StatefulWidget {
  @override
  _RestartableAnimationState createState() => _RestartableAnimationState();
}

class _RestartableAnimationState extends State<RestartableAnimation> {
  Object? _animationKey;

  void _restartAnimation() {
    setState(() {
      _animationKey = Object(); // New key restarts animation
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        STweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 100.0),
          duration: Duration(seconds: 1),
          animationKey: _animationKey,
          builder: (context, value, child) {
            return Container(
              width: value,
              height: 50,
              color: Colors.green,
            );
          },
        ),
        ElevatedButton(
          onPressed: _restartAnimation,
          child: Text('Restart Animation'),
        ),
      ],
    );
  }
}
```

## API Reference

### STweenAnimationBuilder<T>

A widget that animates a value of type `T` using a `Tween`.

#### Constructor Parameters

- `tween`: The `Tween<T>` that defines the animation range
- `duration`: The duration of the animation
- `builder`: A function that builds the widget based on the current animation value
- `curve`: The curve to apply to the animation (default: `Curves.linear`)
- `child`: An optional child widget to pass to the builder
- `onEnd`: Callback function called when the animation completes
- `animationKey`: Key to restart the animation when changed
- `autoRepeat`: Whether to automatically repeat the animation (default: false)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Repository

https://github.com/Soundsliced/soundsliced_tween_animation_builder
