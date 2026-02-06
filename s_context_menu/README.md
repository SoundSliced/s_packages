# s_context_menu

A professional highly-featured Flutter context menu widget built from scratch, offering advanced customization, accessibility, and smooth animations.

## Demo

![Demo](https://raw.githubusercontent.com/SoundSliced/s_context_menu/main/example/assets/example.gif)

## Features

- ✨ **Animated Transitions**: Smooth fade and scale animations for menu appearance and disappearance
- 🎯 **Smart Positioning**: Automatically positions the menu and arrow based on available space
- 📱 **Multi-Platform**: Works on desktop (right-click) and mobile (long-press) devices
- ♿ **Accessibility**: Built-in semantic labels and screen reader announcements
- 🎨 **Customizable Theme**: Comprehensive theming system for colors, blur, radii, shadows, and more
- ⌨️ **Keyboard Navigation**: Full keyboard support with arrow keys and ESC key to close
- 📜 **Overflow Handling**: Automatically scrolls menu content when it exceeds available space
- 🔄 **Multi-Open Mode**: Display multiple context menus simultaneously when enabled
- 🎮 **Lifecycle Callbacks**: `onOpened` and `onClosed` callbacks for menu state tracking
- 🛠️ **Programmatic Control**: Static methods for closing menus and checking menu state
- 💎 **Modern Design**: Glassmorphic effect with backdrop blur for a premium look

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  s_context_menu: ^1.0.0
```

Then import the package:

```dart
import 'package:s_context_menu/s_context_menu.dart';
```

## Basic Usage

Wrap any widget with `SContextMenu` and provide a list of context menu items:

```dart
SContextMenu(
  buttons: [
    SContextMenuItem(
      label: 'Edit',
      icon: Icons.edit,
      onPressed: () {
        print('Edit pressed');
      },
    ),
    SContextMenuItem(
      label: 'Delete',
      icon: Icons.delete,
      destructive: true,
      onPressed: () {
        print('Delete pressed');
      },
    ),
  ],
  child: Container(
    color: Colors.blue,
    height: 100,
    width: 100,
    child: Center(child: Text('Right-click or long-press me')),
  ),
)
```

## Advanced Usage

### Theming

Customize the appearance of your context menu:

```dart
SContextMenu(
  theme: const SContextMenuTheme(
    panelBorderRadius: 12,
    panelBlurSigma: 30,
    arrowBaseWidth: 12,
    arrowShape: ArrowShape.curved,
    showDuration: Duration(milliseconds: 250),
    hideDuration: Duration(milliseconds: 200),
  ),
  buttons: [
    SContextMenuItem(label: 'Option 1', icon: Icons.edit, onPressed: () {}),
  ],
  child: YourWidget(),
)
```

### Multiple Open Menus

Enable multiple context menus to be open simultaneously:

```dart
Column(
  children: [
    SContextMenu(
      allowMultipleMenus: true,
      buttons: [...],
      child: Container(...),
    ),
    SContextMenu(
      allowMultipleMenus: true,
      buttons: [...],
      child: Container(...),
    ),
  ],
)

// Later, close all menus programmatically:
SContextMenu.closeAllOpenMenus();
```

### Lifecycle Callbacks

Respond to menu state changes:

```dart
SContextMenu(
  buttons: [...],
  onOpened: () {
    print('Menu opened');
  },
  onClosed: () {
    print('Menu closed');
  },
  onButtonPressed: (label) {
    print('Button pressed: $label');
  },
  child: YourWidget(),
)
```

### Programmatic Control

Check and control menu state:

```dart
// Check if a menu is open
if (SContextMenu.hasOpenMenu) {
  print('A menu is currently open');
}

// Close the currently active menu
SContextMenu.closeOpenMenu();

// Check if any menus are open (works in multi-open mode)
if (SContextMenu.hasAnyOpenMenus) {
  print('At least one menu is open');
}

// Close all open menus
SContextMenu.closeAllOpenMenus();
```

### Destructive Actions

Mark dangerous actions with the `destructive: true` parameter for special styling:

```dart
SContextMenuItem(
  label: 'Delete Forever',
  icon: Icons.delete_forever,
  destructive: true,
  onPressed: () {
    // Handle deletion
  },
)
```

### Keep Menu Open

Use `keepMenuOpen: true` to prevent the menu from closing after a button press. Useful for multi-selection or toggle actions:

```dart
SContextMenuItem(
  label: 'Toggle Selection',
  icon: Icons.check_box,
  keepMenuOpen: true, // Menu stays open after press
  onPressed: () {
    // Toggle selection state
  },
)
```

### Custom Semantics

Provide custom semantic labels for better accessibility:

```dart
SContextMenuItem(
  label: 'Share',
  icon: Icons.share,
  semanticsLabel: 'Share this item with others',
  onPressed: () {
    // Handle share
  },
)
```

## Keyboard Navigation

When the context menu is open, you can:

- **Arrow Up/Down**: Navigate through menu items
- **Enter/Space**: Activate the currently highlighted item
- **ESC**: Close the menu

## API Reference

### SContextMenu

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `buttons` | `List<SContextMenuItem>` | `[]` | Menu items to display |
| `child` | `Widget` | required | The widget to attach the context menu to |
| `theme` | `SContextMenuTheme?` | `null` | Custom theme configuration |
| `followAnchor` | `bool` | `false` | Keep menu tethered to child widget |
| `showThrottle` | `Duration` | 70ms | Minimum time between menu shows |
| `allowMultipleMenus` | `bool` | `false` | Allow multiple menus open at once |
| `announceAccessibility` | `bool` | `true` | Enable screen reader announcements |
| `semanticsMenuLabel` | `String` | 'Context menu' | Semantic label for the menu |
| `onOpened` | `VoidCallback?` | `null` | Called when menu opens |
| `onClosed` | `VoidCallback?` | `null` | Called when menu closes via ESC or outside tap |
| `onButtonPressed` | `Function(String)?` | `null` | Called when any button is pressed |
| `backgroundOpacity` | `double?` | `null` | Background overlay opacity |
| `highlightColor` | `Color?` | `null` | Color for highlighted menu items |

### SContextMenuItem

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | `String` | required | Display text for the menu item |
| `icon` | `IconData?` | `null` | Icon to display beside the label |
| `onPressed` | `VoidCallback` | required | Callback when item is pressed |
| `destructive` | `bool` | `false` | Style as a destructive action (red) |
| `keepMenuOpen` | `bool` | `false` | Keep menu open after button press |
| `semanticsLabel` | `String?` | `null` | Custom semantic label for accessibility |
| `id` | `String?` | `null` | Stable identifier for the item |

### SContextMenuTheme

Customize appearance with these properties:

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `panelBorderRadius` | `double` | `8` | Corner radius of the menu panel |
| `panelBlurSigma` | `double` | `20` | Blur sigma for glassmorphic effect |
| `panelBackgroundColor` | `Color?` | `null` | Panel background color (auto-adaptive) |
| `panelBorderColor` | `Color?` | `null` | Panel border color (auto-adaptive) |
| `panelShadows` | `List<BoxShadow>?` | `null` | Custom shadows for panel |
| `arrowShape` | `ArrowShape` | `curved` | Shape of the pointer arrow |
| `arrowBaseWidth` | `double` | `10` | Base width of the arrow |
| `arrowCornerRadius` | `double` | `4` | Corner radius of arrow corners |
| `arrowTipGap` | `double` | `2` | Gap between arrow tip and panel |
| `arrowMaxLength` | `double` | `2` | Maximum arrow length |
| `showDuration` | `Duration` | `200ms` | Animation duration when showing |
| `hideDuration` | `Duration` | `150ms` | Animation duration when hiding |

## Example

A complete example is available in the `example/` directory. To run it:

```bash
cd example
flutter run
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests to help improve this package.

## Support

If you have any questions or issues, please open an issue on [GitHub](https://github.com/SoundSliced/s_context_menu/issues).
