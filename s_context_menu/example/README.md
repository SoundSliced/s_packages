# s_context_menu Example

This example demonstrates the features and usage patterns of the `s_context_menu` package.

## Running the Example

### Prerequisites

- Flutter SDK installed
- A device or emulator ready

### Desktop (Web, Windows, macOS, Linux)

```bash
flutter run
```

Right-click on any box to see the context menu.

### Mobile (iOS/Android)

```bash
flutter run
```

Long-press on any box to see the context menu.

## What's Included

### Basic Example (main.dart)

The main example demonstrates:

1. **Basic Context Menu** - Simple menu with Edit, Copy, Delete options
2. **Themed Menu** - Custom styled context menu with gradient background
3. **Multiple Items** - Menu with many options that scrolls automatically
4. **Status Display** - Shows the last action triggered
5. **Instructions** - User-friendly guide for how to use the menus

### Advanced Examples (advanced_examples.dart)

More complex usage patterns including:

1. **Multi-Select List** - Selecting/deselecting items with context menu
2. **Dynamic Menu** - Menu that adapts based on application state
3. **Custom Themed Menu** - Premium custom styling with gradients and shadows

## Features Demonstrated

- ✅ Right-click (desktop) and long-press (mobile) triggers
- ✅ Custom theming
- ✅ Destructive action styling
- ✅ Menu callbacks (`onOpened`, `onButtonPressed`, etc.)
- ✅ Keyboard navigation (arrow keys, ESC)
- ✅ Automatic overflow scrolling
- ✅ Dynamic menu generation based on state
- ✅ Status tracking with `onButtonPressed` callback

## Files

- `lib/main.dart` - Main example application with basic and themed examples
- `lib/advanced_examples.dart` - Advanced usage patterns
- `pubspec.yaml` - Example app dependencies

## Key Interactions

### Desktop
- **Right-Click**: Opens context menu at cursor position
- **Arrow Keys**: Navigate menu items
- **Enter/Space**: Activate selected item
- **ESC**: Close menu

### Mobile
- **Long-Press**: Opens context menu at touch position
- **Tap Item**: Activate menu item
- **Tap Outside**: Close menu

## Tips

1. Try right-clicking/long-pressing on different colored boxes to see various styles
2. Notice how the menu automatically positions itself to stay on screen
3. Experiment with keyboard navigation on desktop
4. Try the scrolling behavior with the "Multiple Items" example

## Customization

To customize the example:

1. Modify `pubspec.yaml` to change dependencies
2. Edit `lib/main.dart` to add new example sections
3. Adjust `SContextMenuTheme` properties to see styling effects
4. Add more `SContextMenuItem` buttons to test overflow behavior

For more information, check the main [README.md](../README.md) in the package root.
