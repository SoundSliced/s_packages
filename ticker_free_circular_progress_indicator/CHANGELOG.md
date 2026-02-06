# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-20

### Changed
- **STABLE RELEASE**: Promoted to version 1.0.0 after thorough testing
- Updated documentation to reflect stable API
- Enhanced README with comprehensive examples and API reference
- Improved example app with better demonstrations
- Updated LICENSE to ensure MIT compliance

### Verified
- All features tested and verified to work correctly
- Hot-restart safety confirmed across multiple scenarios
- Performance optimized for production use
- API is stable and ready for production use

## [0.0.2] - 2025-11-18

### Changed
- Updated package version for republishing

## [0.0.1] - 2025-11-18

### Added
- **TickerFreeCircularProgressIndicator**: A hot-restart safe circular progress indicator widget
- **Manual frame callbacks**: Uses `Timer.periodic` instead of `TickerProviderStateMixin` for animation
- **Dual mode support**: Supports both determinate and indeterminate progress indicators
- **Customizable styling**: Colors, stroke width, stroke alignment, stroke cap, and background colors
- **Delay support**: Optional delay with custom widget after timeout
- **Accessibility**: Proper semantics labels and values
- **Complete example app**: Demonstrates all features and usage patterns
- **Comprehensive tests**: 9 test cases covering various configurations and behaviors

### Features
- 🚀 **Hot-restart safe**: No `TickerProviderStateMixin` required - perfect for development
- 🎯 **Manual animations**: Uses `Timer.periodic` for consistent 60fps animation updates
- 📊 **Flexible progress**: Supports determinate (with value) and indeterminate modes
- ⏱️ **Delay functionality**: Optional delay with fallback widget after timeout
- 🎨 **Full customization**: Colors, stroke properties, alignment, and styling options
- 🔄 **Smooth animations**: Matches Flutter's native `CircularProgressIndicator` behavior
- 📱 **Cross-platform**: Works on all Flutter platforms
- 🧪 **Well tested**: Comprehensive test suite ensuring reliability

### Technical Details
- **Animation System**: Manual frame callbacks using `Timer.periodic` at 60fps
- **Memory Management**: Proper cleanup and disposal of timers and resources
- **Performance**: Lightweight implementation with minimal CPU usage
- **Compatibility**: Flutter 3.0+ and Dart 3.0+ support

### Example Usage
```dart
// Indeterminate progress
TickerFreeCircularProgressIndicator()

// Determinate progress
TickerFreeCircularProgressIndicator(value: 0.75)

// Custom styled
TickerFreeCircularProgressIndicator(
  value: 0.5,
  color: Colors.blue,
  backgroundColor: Colors.blue.withValues(alpha: 0.2),
  strokeWidth: 6.0,
  strokeAlign: -1.0, // Inside stroke
  strokeCap: StrokeCap.round,
)

// With delay
TickerFreeCircularProgressIndicator(
  delay: Duration(seconds: 5),
  defaultWidgetAfterDelay: Text('Taking longer than expected...'),
)
```
