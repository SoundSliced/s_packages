# keystroke_listener

A comprehensive Flutter package for capturing and handling keystroke events with support for basic and advanced keyboard shortcuts. This package provides a `KeystrokeListener` widget that wraps your Flutter widgets with keyboard event detection, making it easy to implement keyboard-driven interactions.

## Demo
![Demo](https://raw.githubusercontent.com/SoundSliced/keystroke_listener/main/example/assets/example.gif)



## Features

- 🎹 **Comprehensive Intent System**: 18+ built-in Intents for common keyboard actions
- ⌨️ **Keyboard Shortcut Handling**: Support for standard shortcuts (Ctrl/Cmd+S, Ctrl/Cmd+C, etc.)
- 🎯 **FocusNode Management**: Automatic focus handling with custom FocusNode support
- 🐛 **Visual Debug Mode**: Optional visual feedback for debugging keyboard events
- 🌐 **Web Compatible**: Special handling for Flutter Web focus requirements
- ♿ **Accessible**: Built-in accessibility support through Flutter's FocusableActionDetector
- 📱 **Cross-Platform**: Works on Android, iOS, Web, Windows, macOS, and Linux

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  keystroke_listener: ^1.1.2
```

Then run:
```bash
flutter pub get
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:keystroke_listener/keystroke_listener.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: KeystrokeListener(
          onKeyEvent: (event) {
            print('Key pressed: ${event.logicalKey.keyLabel}');
          },
          child: const Center(
            child: Text('Press any key!'),
          ),
        ),
      ),
    );
  }
}
```

## Available Intents

### Basic Navigation Intents
- **NavigateUpIntent**: Arrow up key
- **NavigateDownIntent**: Arrow down key
- **NavigateLeftIntent**: Arrow left key
- **NavigateRightIntent**: Arrow right key

### System Intents
- **EscapeIntent**: Escape key
- **SubmitIntent**: Enter/Return key
- **DeleteIntent**: Backspace key
- **SpaceIntent**: Space key
- **TabIntent**: Tab key
- **ReverseTabIntent**: Shift + Tab

### Edit Intents (Ctrl/Cmd + key)
- **SaveIntent**: Ctrl/Cmd + S
- **UndoIntent**: Ctrl/Cmd + Z
- **RedoIntent**: Ctrl/Cmd + Y
- **SelectAllIntent**: Ctrl/Cmd + A
- **CopyIntent**: Ctrl/Cmd + C
- **PasteIntent**: Ctrl/Cmd + V
- **CutIntent**: Ctrl/Cmd + X
- **ToggleCommentIntent**: Ctrl/Cmd + /

### Function Key Intents
- **HelpIntent**: F1 key

## Usage Examples

### Basic Usage with Event Callback

```dart
KeystrokeListener(
  onKeyEvent: (event) {
    debugPrint('Key: ${event.logicalKey.keyLabel}');
    debugPrint('Is pressed: ${event is KeyDownEvent}');
  },
  child: MyWidget(),
)
```

### With Visual Debug Mode

Enable visual feedback (SnackBar) when keys are pressed:

```dart
KeystrokeListener(
  enableVisualDebug: true,
  onKeyEvent: (event) {
    // Your key handling logic
  },
  child: MyWidget(),
)
```

### With Custom FocusNode

Manage focus programmatically:

```dart
final focusNode = FocusNode();

KeystrokeListener(
  focusNode: focusNode,
  onKeyEvent: (event) {
    // Your key handling logic
  },
  requestFocusOnInit: true,
  autoFocus: true,
  child: MyWidget(),
)
```

### With State Management

Integrate with your app's state management:

```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  void _handleKeyEvent(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.pop(context);
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      _submitForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeystrokeListener(
      onKeyEvent: _handleKeyEvent,
      child: MyFormWidget(),
    );
  }
}
```

## Advanced Usage

### Custom Intent Actions

While `KeystrokeListener` provides default actions, you can override them:

```dart
// The widget automatically handles shortcuts through FocusableActionDetector
// with default CallbackActions that log to debug output
```

### Focus Management

The widget handles focus automatically but provides customization:

```dart
KeystrokeListener(
  requestFocusOnInit: true,  // Request focus when widget initializes
  autoFocus: true,            // Set autofocus on the FocusableActionDetector
  child: MyWidget(),
)
```

### Integration with Forms

Perfect for custom form navigation:

```dart
KeystrokeListener(
  onKeyEvent: (event) {
    if (event.logicalKey == LogicalKeyboardKey.tab) {
      FocusScope.of(context).nextFocus();
    } else if (event.logicalKey == LogicalKeyboardKey.shiftLeft &&
               event is KeyDownEvent) {
      FocusScope.of(context).previousFocus();
    }
  },
  child: Form(
    child: Column(
      children: [
        TextFormField(label: Text('Field 1')),
        TextFormField(label: Text('Field 2')),
      ],
    ),
  ),
)
```

## How It Works

The `KeystrokeListener` widget:

1. **Creates a FocusableActionDetector** to capture keyboard shortcuts
2. **Manages FocusNode** automatically or uses your provided FocusNode
3. **Maps keyboard events** to Intent objects
4. **Executes Actions** associated with each Intent
5. **Provides callbacks** through the optional `onKeyEvent` parameter
6. **Includes a hidden TextField** to ensure focus on Flutter Web (often hidden via SOffstage)

The widget is transparent to your UI layout, adding no visual overhead.

## Properties

```dart
KeystrokeListener({
  required Widget child,
  void Function(KeyDownEvent keyDownEvent)? onKeyEvent,
  bool enableVisualDebug = false,
  FocusNode? focusNode,
  bool requestFocusOnInit = true,
  bool autoFocus = true,
  Key? key,
})
```

- **child**: The widget to wrap with keyboard event handling
- **onKeyEvent**: Optional callback when a key event occurs
- **enableVisualDebug**: Show SnackBar with pressed key name
- **focusNode**: Custom FocusNode for advanced focus management
- **requestFocusOnInit**: Request focus when the widget initializes
- **autoFocus**: Set autofocus on the FocusableActionDetector

## Platform-Specific Notes

### Flutter Web
The widget includes a hidden TextField to ensure focus works properly on Web, as the browser doesn't auto-focus widgets by default.

### Mobile (Android/iOS)
Works well but may need explicit focus management depending on your UI design. The keyboard will still be accessible through the standard platform behavior.

### Desktop (Windows/macOS/Linux)
Full keyboard support with all shortcuts working as expected.

## Testing

The package includes comprehensive unit tests covering:
- Intent creation and validation
- Widget building and lifecycle
- FocusNode management
- Callback invocation
- Edge cases and state changes

Run tests with:
```bash
flutter test
```

## Example App

Check the `example/` directory for a complete working example demonstrating:
- Basic keystroke handling
- Navigation with arrow keys
- Keyboard shortcuts (Save, Copy, Paste, etc.)
- Visual debug mode
- Event logging

Run the example:
```bash
cd example
flutter run
```

## Best Practices

1. **Use with Focus**: Ensure your widget tree has proper focus management
2. **Avoid Nesting**: Don't nest multiple KeystrokeListener widgets - it can cause conflicts
3. **Platform Testing**: Test on your target platforms as keyboard behavior varies
4. **Custom Actions**: For complex keyboard handling, implement custom Intent/Action pairs
5. **Accessibility**: Always provide alternative input methods for accessibility

## Troubleshooting

### Keys not being captured on Web
- Ensure the KeystrokeListener has focus
- The widget includes a hidden TextField to help with Web focus
- Consider wrapping your entire app's main widget with KeystrokeListener

### FocusNode disposal errors
- If providing a custom FocusNode, dispose it properly in your State's dispose method
- The widget will handle disposal if you don't provide a focusNode

### Multiple widgets receiving key events
- Only one widget with primary focus receives key events
- Ensure proper focus management if you have multiple KeystrokeListener instances

## License

This package is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2025 SoundSliced Ltd

## Contributing

Contributions are welcome! Please feel free to submit issues and enhancement requests.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes in each release.
