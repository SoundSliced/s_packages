# s_modal

[![pub package](https://img.shields.io/pub/v/s_modal.svg)](https://pub.dev/packages/s_modal)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive, production-ready Flutter package for displaying beautiful and highly customizable modal overlays including sheets, dialogs, and snackbars with independent lifecycle management.

![s_modal Demo](https://raw.githubusercontent.com/SoundSliced/s_modal/main/example/assets/example.gif)

## ✨ Features

### 🎯 Three Core Modal Types

#### **Sheets** (Bottom, Top, Left, Right)

- 📍 Slide in from any edge (bottom, top, left, right)
- 📐 Expandable with drag-to-expand functionality
- 🎨 Customizable size, colors, and borders
- 👆 Interactive drag handle
- 📱 Auto-sizing based on content

#### **Dialogs**

- 🎯 Centered positioning with optional offset
- 🖱️ Optional draggable functionality
- 🎭 Smooth fade and scale animations
- 🎨 Fully customizable styling

#### **Snackbars**

- 📍 Position anywhere on screen (9 alignment options + custom offset)
- 📚 Multiple display modes: staggered, notification bubble, queued, replace
- ⏱️ Auto-dismiss with visual duration indicator
- 👆 Swipe-to-dismiss (horizontal and vertical) with `isDismissible` control
- 🎨 Rich customization with icons, colors, actions, and barrier colors
- 🎭 Animated barrier color support with fade in/out

### 🚀 Advanced Features

- **Independent Lifecycles**: Each modal type has its own controller - snackbars don't interfere with dialogs!
- **Live Updates**: Modify modal properties in real-time with `updateParams()`
- **ID-Based Management**: Dismiss specific modals by ID, check which are active
- **Hot Reload Support**: `ModalBuilder` widget for seamless development
- **Background Effects**: Blur and dim background with customizable intensity
- **Smart Dismissal**: Tap outside, swipe, or programmatic control
- **Callbacks**: `onDismissed`, `onExpanded`, and `onTap` hooks
- **Type-Safe API**: Enums for positions, animations, and display modes
- **Zero Dependencies Conflicts**: Carefully selected dependencies for maximum compatibility

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  s_modal: ^2.1.1
```

Then run:

```bash
flutter pub get
```

> **⚠️ BREAKING CHANGES in v2.0.0:**
>
> - `Modal.activator()` removed → use `MaterialApp.builder: Modal.appBuilder` instead
> - `Modal.initialiseActivator()` removed → no longer needed
> - Several dependencies removed (`sizer`, `dart_helper_utils`, `soundsliced_tween_animation_builder`)
> - See [CHANGELOG](CHANGELOG.md#200) for full migration guide

## 🚀 Quick Start

### 1. Add Modal.appBuilder to your MaterialApp

```dart
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: Modal.appBuilder,  // Add this line!
      home: MyHomePage(),
    );
  }
}
```

    > **Note:** In debug builds, `Modal.show` will assert if `Modal.appBuilder` is not installed.

**Optional:** For advanced customization:

```dart
MaterialApp(
  builder: (context, child) => Modal.appBuilder(
    context,
    child,
    backgroundColor: Colors.black,
    borderRadius: BorderRadius.circular(24),
    showDebugPrints: false,
  ),
  home: MyHomePage(),
)
```

### 2. Show your first modal

```dart
// Simple bottom sheet
Modal.show(
  builder: () => Container(
    padding: EdgeInsets.all(20),
    child: Text('Hello, Modal!'),
  ),
);

// Simple snackbar
Modal.showSnackbar(
  text: 'Operation successful!',
  prefixIcon: Icons.check_circle,
  backgroundColor: Colors.green,
);
```

## 📖 Usage Examples

### Bottom Sheet

```dart
Modal.show(
  builder: () => YourContentWidget(),
  modalType: ModalType.sheet,
  size: 300, // Height in pixels
  isExpandable: true,
  expandedPercentageSize: 85, // Max 85% of screen height
  shouldBlurBackground: true,
  backgroundColor: Colors.white,
  onDismissed: () => print('Sheet dismissed'),
);
```

### Side Sheet (Left or Right)

```dart
Modal.show(
  builder: () => MenuWidget(),
  modalType: ModalType.sheet,
  sheetPosition: SheetPosition.left, // or .right
  size: 280, // Width in pixels
  shouldBlurBackground: true,
);
```

### Dialog

```dart
Modal.show(
  builder: () => AlertDialogContent(),
  modalType: ModalType.dialog,
  modalPosition: Alignment.center,
  isDraggable: true,
  shouldBlurBackground: true,
  blurAmount: 5.0,
);
```

### Snackbar with Duration Indicator

```dart
Modal.showSnackbar(
  text: 'File downloaded successfully',
  prefixIcon: Icons.download_done,
  backgroundColor: Colors.blue.shade800,
  duration: Duration(seconds: 3),
  position: Alignment.topCenter,
  showDurationTimer: true,
  durationTimerDirection: DurationIndicatorDirection.leftToRight,
  durationTimerColor: Colors.cyan,
  isDismissible: true, // Allow swipe-to-dismiss (default)
  barrierColor: Colors.black.withValues(alpha: 0.2), // Optional barrier
);
```

### Staggered Snackbars

```dart
// Show multiple snackbars that stack
Modal.showSnackbar(
  text: 'First notification',
  displayMode: SnackbarDisplayMode.staggered,
  maxStackedSnackbars: 5,
);

Modal.showSnackbar(
  text: 'Second notification',
  displayMode: SnackbarDisplayMode.staggered,
);
```

### Using ModalBuilder (Recommended for Development)

```dart
// With hot reload support!
ModalBuilder(
  builder: () => MyBottomSheetContent(),
  size: 350,
  shouldBlurBackground: true,
  onDismissed: () => print('Dismissed'),
  child: ElevatedButton(
    child: Text('Show Sheet'),
  ),
)

// Dialog variant
ModalBuilder.dialog(
  builder: () => MyDialogContent(),
  shouldBlurBackground: true,
  child: ElevatedButton(
    child: Text('Show Dialog'),
  ),
)
```

### Live Updates with updateParams()

```dart
// Show a dialog
Modal.show(
  id: 'my_dialog',
  builder: () => DialogContent(),
  modalType: ModalType.dialog,
  blurAmount: 3.0,
);

// Later, update it without recreation
Modal.updateParams(
  id: 'my_dialog',
  blurAmount: 8.0,
  isDraggable: true,
);
```

### ID-Based Dismissal

```dart
// Show modals with IDs
Modal.show(
  id: 'settings_sheet',
  builder: () => SettingsWidget(),
);

Modal.showSnackbar(
  id: 'notification_1',
  text: 'New message',
);

// Dismiss specific modal
await Modal.dismissById('settings_sheet');

// Check if active
if (Modal.isModalActiveById('notification_1')) {
  // Modal is showing
}
```

### Mixed Modal Interactions

```dart
// Show a sheet, then a snackbar
Modal.show(
  builder: () => BottomSheetContent(),
  modalType: ModalType.sheet,
);

// Snackbar appears above the sheet!
Modal.showSnackbar(
  text: 'Changes saved',
  position: Alignment.topCenter,
);
```

## 🎨 Customization

### Sheet Positions

```dart
// Available positions
SheetPosition.bottom  // Slides from bottom
SheetPosition.top     // Slides from top
SheetPosition.left    // Slides from left
SheetPosition.right   // Slides from right
```

### Snackbar Positions

```dart
// 9 Standard alignments
Alignment.topLeft
Alignment.topCenter
Alignment.topRight
Alignment.centerLeft
Alignment.center
Alignment.centerRight
Alignment.bottomLeft
Alignment.bottomCenter
Alignment.bottomRight

// Custom offset positioning
Modal.showSnackbar(
  text: 'Custom position',
  offset: Offset(100, 200), // x, y from top-left
);
```

### Snackbar Display Modes

```dart
SnackbarDisplayMode.staggered  // Stack visually with offset
SnackbarDisplayMode.notificationBubble  // Collapsible bubble with counter
SnackbarDisplayMode.queued  // Show one at a time, queue others
SnackbarDisplayMode.replace  // New snackbar replaces current
```

### Background Effects

```dart
Modal.show(
  builder: () => MyWidget(),
  shouldBlurBackground: true,
  blurAmount: 5.0, // 0-20, higher = more blur
  barrierColor: Colors.black.withValues(alpha: 0.5),
  blockBackgroundInteraction: true, // Block taps on background
);
```

## 🎯 Advanced Features

### Type-Specific Controllers

```dart
// Check specific modal types
if (Modal.isDialogActive) { /* ... */ }
if (Modal.isSheetActive) { /* ... */ }
if (Modal.isSnackbarActive) { /* ... */ }

// Get active IDs by type
List<String> snackbarIds = Modal.getActiveIdsByType(ModalType.snackbar);

// Dismiss by type
await Modal.dismissByType(ModalType.dialog);
```

### Callbacks

```dart
Modal.show(
  builder: () => MyWidget(),
  onDismissed: () {
    print('Modal closed');
    // Cleanup or show next modal
  },
  onExpanded: () {
    print('Sheet expanded');
    // Load more content
  },
);

Modal.showSnackbar(
  text: 'Notification',
  onTap: () {
    print('Snackbar tapped');
    // Handle tap
  },
  onDismissed: () {
    print('Snackbar dismissed');
  },
);
```

### Reactive Content

```dart
// Using states_rebuilder for reactive content
final counter = RM.inject(() => 0);

Modal.show(
  builder: () => OnReactive(
    () => Text('Count: ${counter.state}'),
  ),
);

// Update triggers rebuild
counter.state++;
```

## 📚 API Reference

### Core Methods

| Method                  | Description                                    |
| ----------------------- | ---------------------------------------------- |
| `Modal.show()`          | Display any modal type with full customization |
| `Modal.showSnackbar()`  | Convenient snackbar with pre-styled options    |
| `Modal.dismiss()`       | Dismiss the active modal                       |
| `Modal.dismissById()`   | Dismiss a specific modal by ID                 |
| `Modal.dismissAll()`    | Dismiss all modals                             |
| `Modal.dismissByType()` | Dismiss all modals of a specific type          |
| `Modal.updateParams()`  | Update modal properties in real-time           |

### State Checks

| Property                  | Description                    |
| ------------------------- | ------------------------------ |
| `Modal.isActive`          | Any modal is currently showing |
| `Modal.isDialogActive`    | A dialog is showing            |
| `Modal.isSheetActive`     | A sheet is showing             |
| `Modal.isSnackbarActive`  | A snackbar is showing          |
| `Modal.activeModalId`     | ID of the current modal        |
| `Modal.allActiveModalIds` | List of all active modal IDs   |

### Enums

```dart
// Modal types
ModalType.sheet
ModalType.dialog
ModalType.snackbar
ModalType.custom

// Sheet positions
SheetPosition.bottom
SheetPosition.top
SheetPosition.left
SheetPosition.right

// Snackbar display modes
SnackbarDisplayMode.staggered
SnackbarDisplayMode.notificationBubble
SnackbarDisplayMode.queued
SnackbarDisplayMode.replace

// Duration indicator direction
DurationIndicatorDirection.leftToRight
DurationIndicatorDirection.rightToLeft
```

## 📦 Dependencies

Version 2.0.0 has minimal dependencies:

- `states_rebuilder_extended` ^1.0.3 - State management
- `assorted_layout_widgets` ^11.0.0 - Layout utilities
- `flutter_animate` ^4.5.2 - Smooth animations
- `soundsliced_dart_extensions` ^1.0.1 - Dart extensions
- `s_bounceable` ^2.0.0 - Bounce interactions
- `s_ink_button` ^1.1.0 - Ink button widget

**Removed in v2.0:**

- ~~`sizer`~~ - Now uses native MediaQuery
- ~~`dart_helper_utils`~~ - Unnecessary dependency
- ~~`soundsliced_tween_animation_builder`~~ - Built-in alternatives

## 🎓 Examples

Check out the [example](example/) folder for comprehensive demos including:

- **Sheet Configurator**: Interactive playground for all sheet types and options
- **Dialog Configurator**: Test all dialog features and configurations
- **Snackbar Configurator**: Explore all snackbar display modes and styles
- **Modal Mixing**: Examples of combining different modal types
- **Reactive State**: Using reactive state management with modals
- **Live Updates**: Dynamic parameter updates demo

Run the example app:

```bash
cd example
flutter run
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Built with:

- [states_rebuilder_extended](https://pub.dev/packages/states_rebuilder_extended) - State management
- [flutter_animate](https://pub.dev/packages/flutter_animate) - Smooth animations

## 📞 Support

- 🐛 [Report bugs](https://github.com/1.0.2/s_modal/issues)
- 💡 [Request features](https://github.com/1.0.2/s_modal/issues)
- 📖 [Documentation](https://github.com/1.0.2/s_modal)

---

Made with ❤️ by [SoundSliced ltd](https://github.com/SoundSliced)
