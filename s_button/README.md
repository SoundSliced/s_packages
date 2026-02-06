# SButton

[![Pub Version](https://img.shields.io/pub/v/s_button)](https://pub.dev/packages/s_button)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A highly customizable Flutter button widget with rich animations, visual effects, and interaction modes. Perfect for creating engaging user interfaces with splash effects, bounce animations, haptic feedback, and more.

## Demo
![Demo](https://raw.githubusercontent.com/SoundSliced/s_button/main/example/assets/example.gif)

## 📋 Features

- **Rich Animations**
  - Bounce animation with configurable scale
  - Splash effects with custom colors and opacity
  - Smooth color transitions and overlays
  - Delayed initialization support

- **Multiple Interaction Modes**
  - Single tap with offset detection
  - Double tap support
  - Long press with start/end callbacks
  - Customizable hit test behavior

- **Visual Customization**
  - Circle or rectangle button shapes
  - Custom border radius
  - Splashcolor and selected state overlays
  - Loading state with customizable loading widget
  - Error state handling with error builder

- **Enhanced User Feedback**
  - Bubble label tooltips (platform-aware)
  - Haptic feedback (multiple feedback types)
  - Tooltip messages
  - Active/inactive state management

- **Advanced Features**
  - Comprehensive state management
  - Custom animation controls
  - Flexible child widget support
  - Error handling and recovery
  - Built with Material Design principles

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  s_button: ^1.2.1
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

### Basic Usage

```dart
import 'package:s_button/s_button.dart';

SButton(
  onTap: (offset) {
    print('Button tapped at: $offset');
  },
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Text(
      'Tap Me',
      style: TextStyle(color: Colors.white),
    ),
  ),
)
```

### With Splash Effect

```dart
SButton(
  onTap: (offset) => print('Tapped'),
  splashColor: Colors.blue.withValues(alpha: 0.3),
  splashOpacity: 0.5,
  shouldBounce: true,
  bounceScale: 0.95,
  child: const Padding(
    padding: EdgeInsets.all(16.0),
    child: Text('Click Me'),
  ),
)
```

### Circle Button

```dart
SButton(
  isCircleButton: true,
  onTap: (offset) => print('Circular button tapped'),
  child: Container(
    width: 60,
    height: 60,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.green,
    ),
    child: const Icon(Icons.add, color: Colors.white),
  ),
)
```

## 📚 Comprehensive Usage

### Advanced Interaction Handling

```dart
SButton(
  onTap: (offset) {
    print('Single tap at: ${offset.dx}, ${offset.dy}');
  },
  onDoubleTap: (offset) {
    print('Double tapped at: $offset');
  },
  onLongPressStart: (details) {
    print('Long press started');
  },
  onLongPressEnd: (details) {
    print('Long press ended');
  },
  child: const Padding(
    padding: EdgeInsets.all(16.0),
    child: Text('Multiple Interactions'),
  ),
)
```

### With Bubble Label (Tooltip)

```dart
SButton(
  onTap: (offset) => print('Tapped'),
  bubbleLabelContent: BubbleLabelContent(
    child: const Text('This is a helpful tooltip!'),
    shouldActivateOnLongPressOnAllPlatforms: false,
  ),
  child: const Padding(
    padding: EdgeInsets.all(16.0),
    child: Icon(Icons.info),
  ),
)
```

### Loading State

```dart
SButton(
  isLoading: isLoading,
  onTap: (offset) async {
    // Handle loading state
  },
  loadingWidget: const CircularProgressIndicator(),
  child: const Padding(
    padding: EdgeInsets.all(16.0),
    child: Text('Loading...'),
  ),
)
```

### With Error Handling

```dart
SButton(
  onTap: (offset) {
    try {
      // Perform operation
    } catch (e) {
      widget.onError?.call(e);
    }
  },
  onError: (error) {
    print('Error occurred: $error');
  },
  errorBuilder: (context, error) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.red,
      child: Text('Error: $error'),
    );
  },
  child: const Text('Operation'),
)
```

### Haptic Feedback

```dart
SButton(
  onTap: (offset) => print('Tapped with feedback'),
  enableHapticFeedback: true,
  hapticFeedbackType: HapticFeedbackType.mediumImpact,
  child: const Padding(
    padding: EdgeInsets.all(16.0),
    child: Text('Haptic Button'),
  ),
)
```

### Full Example with All Features

```dart
SButton(
  // Styling
  splashColor: Colors.blue,
  splashOpacity: 0.4,
  selectedColor: Colors.blue.withValues(alpha: 0.2),
  borderRadius: BorderRadius.circular(12), // Clips child and applies to splash/overlay
  
  // Animations
  shouldBounce: true,
  bounceScale: 0.97,
  delay: const Duration(milliseconds: 200),
  
  // Interactions
  onTap: (offset) => _handleTap(offset),
  onDoubleTap: (offset) => _handleDoubleTap(offset),
  onLongPressStart: (details) => _handleLongPressStart(details),
  onLongPressEnd: (details) => _handleLongPressEnd(details),
  
  // States
  isActive: true,
  isLoading: isLoading,
  isCircleButton: false,
  
  // Feedback
  enableHapticFeedback: true,
  hapticFeedbackType: HapticFeedbackType.lightImpact,
  tooltipMessage: 'Press to perform action',
  bubbleLabelContent: BubbleLabelContent(
    child: const Text('Long press for more info'),
  ),
  
  // Error handling
  onError: (error) => _handleError(error),
  errorBuilder: (context, error) => _buildErrorWidget(context, error),
  
  // Custom loading widget
  loadingWidget: const SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(strokeWidth: 2),
  ),
  
  // Behavior
  hitTestBehavior: HitTestBehavior.opaque,
  
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Text(
      'Advanced Button',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
)
```

## 🎨 Customization

### All Available Properties

```dart
SButton(
  // Required
  required Widget child,
  
  // Shape & Border Radius
  BorderRadius? borderRadius, // Clips child and applies to splash/selected overlay
  bool isCircleButton = false,
  AlignmentGeometry? alignment,
  
  // Splash Effects
  Color? splashColor,
  double? splashOpacity,
  
  // Animation
  bool shouldBounce = true,
  double bounceScale = 0.98,
  Duration? delay,
  
  // Interactions
  void Function(Offset)? onTap,
  void Function(Offset)? onDoubleTap,
  void Function(LongPressStartDetails)? onLongPressStart,
  void Function(LongPressEndDetails)? onLongPressEnd,
  
  // State
  bool isActive = true,
  bool isLoading = false,
  Color? selectedColor,
  
  // Feedback
  bool enableHapticFeedback = true,
  HapticFeedbackType hapticFeedbackType = HapticFeedbackType.lightImpact,
  String? tooltipMessage,
  BubbleLabelContent? bubbleLabelContent,
  
  // Loading & Error
  Widget? loadingWidget,
  Function(Object)? onError,
  Widget Function(BuildContext, Object)? errorBuilder,
  
  // Behavior
  HitTestBehavior hitTestBehavior = HitTestBehavior.opaque,
  bool ignoreChildWidgetOnTap = false,
)
```

## 🖼️ Examples

Check the `example/` folder for a complete Flutter application demonstrating:
- Basic button usage
- Advanced interactions
- Custom styling
- Loading and error states
- Multiple button variations

## 🧪 Testing

The package includes comprehensive unit tests. Run tests with:

```bash
flutter test
```

## 📱 Platform Support

- ✅ iOS
- ✅ Android
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

## 🔗 Dependencies

- `flutter_animate` - For advanced animations
- `soundsliced_tween_animation_builder` - Custom tween animations
- `bubble_label` - Bubble label tooltips
- `ticker_free_circular_progress_indicator` - Loading indicators
- `s_ink_button` - Underlying ink button effects
- `s_disabled` - Disabled state management
- `soundsliced_dart_extensions` - Utility extensions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For issues, questions, or suggestions:
- GitHub Issues: [s_button issues](https://github.com/SoundSliced/s_button/issues)
- Email: [contact@soundsliced.com](mailto:contact@soundsliced.com)

## 🎯 Roadmap

- [ ] Web-specific optimizations
- [ ] Additional haptic feedback patterns
- [ ] More bubble label customization options
- [ ] Animation preset library
- [ ] Accessibility improvements

---

Made with ❤️ by [SoundSliced](https://github.com/SoundSliced)
