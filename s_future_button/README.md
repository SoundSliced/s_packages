# SFutureButton

A powerful Flutter package that provides a customizable `SFutureButton` widget for handling asynchronous operations with automatic state management. It elegantly handles loading, success, error, and reset states with smooth animations.

[![pub package](https://img.shields.io/pub/v/s_future_button.svg)](https://pub.dev/packages/s_future_button)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/[A/s_future_button/blob/main/LICENSE)

## Demo
![Demo](https://raw.githubusercontent.com/SoundSliced/s_future_button/main/example/assets/example.gif)


## Features

✨ **Automatic State Management**
- Seamlessly handles loading, success, error, and reset states
- Smart result interpretation based on Future return values
- Smooth animations for all state transitions

🎨 **Fully Customizable UI**
- Configurable dimensions (height and width)
- Custom colors for background and icons
- Adjustable border radius
- Toggle between elevated and flat button styles
- Optional error message display

⚡ **Advanced Async Handling**
- Returns `true` → Shows success animation with green checkmark
- Returns `false` → Shows validation error with message
- Returns `null` → Silent dismissal without animation
- Throws exception → Shows error state with exception message

🎯 **Rich Callbacks**
- `onPostSuccess` - Called after successful operation completion
- `onPostError` - Called after error state display with error message
- `onTap` - Main async operation handler returning `Future<bool?>`

♿ **Accessibility**
- FocusNode support for keyboard navigation
- Focus change callbacks
- Proper disabled state handling

🎬 **Beautiful Animations**
- Squeeze animation when tapped
- Loading spinner with configurable size
- Bounce effect for success/error states
- Auto-reset after error display (1.5 seconds)

💾 **State Persistence**
- Button state survives hot reload during development

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  s_future_button: ^1.0.0
```

Then run:
```bash
flutter pub get
```

## Usage

### Import the package

```dart
import 'package:s_future_button/s_future_button.dart';
```

### Basic Example

The simplest way to use `SFutureButton`:

```dart
SFutureButton(
  onTap: () async {
    // Perform your async operation here
    final success = await loginUser();
    return success; // true = success, false = validation error, null = silent dismiss
  },
  label: 'Login',
  onPostSuccess: () {
    print('Login successful!');
  },
)
```

### Success Operation

```dart
SFutureButton(
  onTap: () async {
    // Simulate network request
    await Future.delayed(const Duration(seconds: 2));
    return true; // Shows success animation
  },
  label: 'Submit',
  bgColor: Colors.blue.shade700,
  onPostSuccess: () {
    Navigator.pop(context);
  },
)
```

### Validation Failure

```dart
SFutureButton(
  onTap: () async {
    final isValid = validateForm();
    if (!isValid) {
      return false; // Shows validation error message
    }
    
    await submitForm();
    return true;
  },
  label: 'Register',
  onPostError: (errorMessage) {
    // Handle error (e.g., show snackbar, log error)
    print('Validation error: $errorMessage');
  },
)
```

### Exception Handling

```dart
SFutureButton(
  onTap: () async {
    try {
      final response = await fetchData();
      return true;
    } catch (e) {
      throw Exception('Failed to load data: ${e.toString()}');
    }
  },
  label: 'Fetch Data',
  onPostError: (errorMessage) {
    print('Error: $errorMessage');
  },
)
```

### Silent Dismissal

```dart
SFutureButton(
  onTap: () async {
    // Check if user cancelled the operation
    final shouldProceed = await showDialog(...);
    
    if (!shouldProceed) {
      return null; // Silent dismissal - no animation
    }
    
    await processData();
    return true;
  },
  label: 'Process',
  showErrorMessage: false,
)
```

### Custom Styling

```dart
SFutureButton(
  onTap: () async {
    await uploadFile();
    return true;
  },
  label: 'Upload',
  height: 56,
  width: 200,
  borderRadius: 12,
  bgColor: Colors.green.shade600,
  iconColor: Colors.white,
  isElevatedButton: true,
  showErrorMessage: true,
)
```

### Icon Button

```dart
SFutureButton(
  onTap: () async {
    await saveData();
    return true;
  },
  icon: const Icon(
    Icons.check,
    color: Colors.white,
    size: 24,
  ),
  height: 50,
  width: 50,
  borderRadius: 25,
  bgColor: Colors.blue,
  onPostSuccess: () {
    print('Data saved!');
  },
)
```

### With Focus Support

```dart
final focusNode = FocusNode();

SFutureButton(
  onTap: () async {
    await submitForm();
    return true;
  },
  label: 'Submit',
  focusNode: focusNode,
  onFocusChange: (isFocused) {
    if (isFocused) {
      print('Button is focused');
    }
  },
)
```

### Advanced Configuration

```dart
SFutureButton(
  onTap: _performAsyncTask,
  label: 'Advanced',
  
  // Dimensions
  height: 48,
  width: 300,
  
  // Styling
  bgColor: Colors.blue.shade700,
  iconColor: Colors.white,
  borderRadius: 8,
  isElevatedButton: true,
  
  // State
  isEnabled: true,
  showErrorMessage: true,
  
  // Loading indicator
  loadingCircleSize: 24,
  
  // Callbacks
  onPostSuccess: () {
    print('Success!');
  },
  onPostError: (error) {
    print('Error: $error');
  },
  
  // Focus management
  focusNode: _focusNode,
  onFocusChange: (isFocused) {
    setState(() {
      _isButtonFocused = isFocused;
    });
  },
)
```

## API Reference

### SFutureButton Constructor Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `onTap` | `Future<bool?> Function()?` | `null` | Async callback that returns Future result |
| `label` | `String?` | `null` | Button text label |
| `icon` | `Widget?` | `null` | Custom icon widget (overrides label) |
| `height` | `double?` | `70` | Button height |
| `width` | `double?` | `150` | Button width |
| `bgColor` | `Color?` | `Colors.blue.shade800` | Background color |
| `iconColor` | `Color?` | `Colors.white` | Icon/text color |
| `borderRadius` | `double?` | `35` | Border radius |
| `isElevatedButton` | `bool` | `true` | Whether button has elevation shadow |
| `isEnabled` | `bool` | `true` | Whether button is interactive |
| `showErrorMessage` | `bool` | `true` | Show error message below button |
| `loadingCircleSize` | `double?` | `24` | Loading indicator size |
| `onPostSuccess` | `VoidCallback?` | `null` | Callback after success |
| `onPostError` | `ValueChanged<String>?` | `null` | Callback after error with message |
| `focusNode` | `FocusNode?` | `null` | Custom focus node |
| `onFocusChange` | `void Function(bool)?` | `null` | Focus change callback |

### Return Value Handling

The `onTap` callback should return a `Future<bool?>`:

| Return Value | Behavior |
|--------------|----------|
| `true` | Shows success animation (green checkmark), calls `onPostSuccess` |
| `false` | Shows error state with "Validation failed" message, calls `onPostError` |
| `null` | Silent reset - no animation or callback |
| Exception | Shows error state with exception message, calls `onPostError` |

## State Flow Diagram

```
Idle
  ↓ (tap) → Loading (squeeze animation)
  ↓
Success/Error (bounce animation)
  ↓ (after 1.5s delay)
  ↓ (callback execution)
  ↓
Reset to Idle
```

## Complete Example App

A full example application demonstrating all features is available in the `example/` directory. Run it with:

```bash
cd example
flutter run
```

The example demonstrates:
- ✅ Basic success operations
- ❌ Validation failures
- 🚨 Exception handling
- 🤫 Silent dismissal
- 🎨 Custom styling
- 🖼️ Icon buttons
- ⌨️ Focus management
- ♿ Disabled states

## Dependencies

- **Flutter**: >=3.0.0
- **Dart**: >=3.0.0
- **assorted_layout_widgets**: ^11.0.0
- **nb_utils**: ^7.1.8
- **soundsliced_dart_extensions**: ^1.0.1
- **s_disabled**: ^1.0.0
- **states_rebuilder_extended**: ^1.0.3
- **rxdart**: ^0.28.0
- **ticker_free_circular_progress_indicator**: ^1.0.0
- **soundsliced_tween_animation_builder**: ^1.2.0

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues on [GitHub](https://github.com/[A/s_future_button).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues, questions, or suggestions, please visit the [issue tracker](https://github.com/[A/s_future_button/issues).

---

**Built with ❤️ by SoundSliced**
