# PopThis Example

This example demonstrates the features of the `pop_this` package, a powerful and customizable Flutter package for managing popups, toasts, and overlays.

## Features Demonstrated

### Basic Features
- **Simple Popup**: Display any widget as a popup
- **Auto-Dismiss with Timer**: Popups that automatically dismiss after a duration
- **Success/Error Overlays**: Pre-styled overlays for quick user feedback
- **Stacked Popups**: Navigate through multiple popups with back button support

### Advanced Features
- **Custom Animations**: Control animation duration and curves
- **Background Blur**: Optional blur effect on the background
- **Custom Styling**: Customize colors, shadows, borders, and more
- **Timer Display**: Visual countdown timer for auto-dismissing popups

## Running the Example

1. Navigate to the example directory:
   ```bash
   cd example
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Example Code Highlights

### Simple Popup
```dart
PopThis.pop(
  context: context,
  child: Container(
    height: 200,
    width: 300,
    alignment: Alignment.center,
    child: const Text('Simple Popup'),
  ),
);
```

### Popup with Timer
```dart
PopThis.pop(
  context: context,
  duration: const Duration(seconds: 3),
  showTimer: true,
  child: Container(
    height: 150,
    width: 250,
    alignment: Alignment.center,
    child: const Text('Auto Dismiss with Timer'),
  ),
);
```

### Success Overlay
```dart
PopThis.showSuccessOverlay(
  successMessage: 'Operation Successful!',
  duration: const Duration(seconds: 2),
);
```

### Stacked Popups
```dart
PopThis.pop(
  context: context,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('First Popup'),
      ElevatedButton(
        onPressed: () {
          PopThis.pop(
            context: context,
            child: const Text('Second Popup (Stacked)'),
          );
        },
        child: const Text('Open Another Popup'),
      ),
    ],
  ),
);
```

## Assets

The example includes a GIF animation showing the package in action. See `assets/example.gif`.
