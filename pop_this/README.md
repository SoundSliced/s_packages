# pop_this

A powerful and customizable Flutter package for managing popups, toasts, and overlays. `pop_this` provides an easy-to-use API for displaying widgets on top of your application with support for animations, stacking (navigation history within popups), auto-dismissal timers, and preset success/error overlays.

![Example](https://raw.githubusercontent.com/SoundSliced/pop_this/main/example/assets/example.gif)

## Features

- **Easy Popup Management**: Show any widget as a popup with a single function call.
- **Automatic Setup**: No manual wrapper required! PopThis automatically sets up the overlay system when first used.
- **Stacked Popups**: Open multiple popups on top of each other. The package automatically handles navigation history, allowing users to go back to previous popups.
- **Auto-Dismissal**: Built-in timer support to automatically dismiss popups after a specified duration.
- **Customizable Animations**: Control entry and exit animations, durations, and curves.
- **Styling**: Extensive customization options for background overlays, shadows, border radius, and colors.
- **Preset Overlays**: Quickly show success or error messages with pre-styled overlays.
- **Blur Support**: Optional background blur effect.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  pop_this: ^2.0.1
```

## Usage

### Setup

**No setup required!** PopThis automatically handles the overlay system initialization when you first call `PopThis.pop()`.

If you're using `Sizer` for responsive sizing (optional), simply wrap your `MaterialApp`:

```dart
import 'package:flutter/material.dart';
import 'package:pop_this/pop_this.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        // No wrapper needed - PopThis handles everything automatically!
        return MaterialApp(
          title: 'PopThis Example',
          home: const MyHomePage(),
        );
      },
    );
  }
}
```

### Basic Usage

Import the package:

```dart
import 'package:pop_this/pop_this.dart';
```

Show a simple popup:

```dart
PopThis.pop(
  context: context,
  child: Container(
    padding: EdgeInsets.all(20),
    color: Colors.white,
    child: Text("Hello from PopThis!"),
  ),
);
```

### Auto-Dismiss with Timer

```dart
PopThis.pop(
  context: context,
  duration: Duration(seconds: 3),
  showTimer: true, // Shows a circular countdown timer
  child: Container(
    padding: EdgeInsets.all(20),
    child: Text("I will disappear in 3 seconds"),
  ),
);
```

### Success and Error Overlays

```dart
// Show a success message
PopThis.showSuccessOverlay(
  successMessage: "Data saved successfully!",
  duration: Duration(seconds: 2),
);

// Show an error message
PopThis.showErrorOverlay(
  errorMessage: "Failed to connect to server.",
  duration: Duration(seconds: 2),
);
```

### Stacked Popups

```dart
PopThis.pop(
  context: context,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('First Popup'),
      ElevatedButton(
        onPressed: () {
          PopThis.pop(
            context: context,
            child: Text('Second Popup - Use back button to go back!'),
          );
        },
        child: Text('Open Another Popup'),
      ),
    ],
  ),
);
```

### Advanced Customization

```dart
PopThis.pop(
  context: context,
  shouldBlurBackgroundOverlayLayer: true, // Blur the background
  dismissBarrierColor: Colors.black.withValues(alpha: 0.5),
  popBackgroundColor: Colors.purple.shade50,
  popUpAnimationDuration: 0.5, // Animation duration in seconds
  hasShadow: true,
  shadowColor: Colors.purple,
  popPositionOffset: Offset(20, 100), // Custom position
  child: YourCustomWidget(),
);
```

### Dismissing Popups

```dart
// Dismiss the current popup
PopThis.dismissPopThis();

// Dismiss with animation
PopThis.animatedDismissPopThis();

// Go back to previous popup in the stack
PopThis.animatedDismissPopThis(shouldPopBackToPreviousWidget: true);

// Check if a popup is currently active
if (PopThis.isPopThisActive()) {
  // Do something
}
```

## Examples

Check out the [example folder](https://github.com/SoundSliced/pop_this/tree/main/example) for a complete working example demonstrating all features:

- Simple popups
- Auto-dismiss with timer
- Success and error overlays
- Stacked popups with navigation
- Custom styled popups
- Positioned popups

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


## Repository

https://github.com/SoundSliced/pop_this
