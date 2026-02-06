# Settings Expandable Menu

[![pub package](https://img.shields.io/pub/v/settings_item.svg)](https://pub.dev/packages/settings_item)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A beautiful, customizable expandable menu widget for Flutter settings pages with smooth animations and Material Design 3 styling.

![Demo](https://raw.githubusercontent.com/SoundSliced/settings_item/main/example/assets/example.gif)

## Features

✨ **Three Operation Modes:**
- **Switch Mode**: Toggle switch for on/off settings
- **Expandable Mode**: Expandable content with smooth animations and up arrow
- **Button Mode**: Left arrow rotation without content expansion

🎨 **Highly Customizable:**
- Custom prefix icons with themed containers
- Custom title text with Material Design typography
- Custom suffix widgets for advanced interactions
- Custom expanded content widgets
- Theme-aware colors and styling

⚡ **Smooth Animations:**
- Butter-smooth expansion/collapse animations
- Rotating arrow indicators with easing curves
- Interactive bounce feedback with `s_bounceable`
- Elegant toggle switches with `s_toggle`

🎯 **Developer Friendly:**
- Simple, intuitive API
- **Two state management modes**: Internal (automatic) or external (controlled)
- Comprehensive documentation
- Type-safe parameter configuration
- Callback support for state changes and expansion events

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  settings_item: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### State Management (External State)

Example using external state management:

SettingsItem supports **two state management modes**:

1. **Internal State (Uncontrolled)** - Widget manages its own state automatically
2. **External State (Controlled)** - Parent widget controls the state

#### Internal State Management (Recommended for Simple Cases)

No need to manage state in your parent widget! Just set an optional `initialState`:

```dart
// Simple switch with internal state - no state variable needed!
SettingsItem(
  parameters: ExpandableParameters(
    prefixIcon: Icons.notifications_rounded,
    title: 'Notifications',
    isSwitch: true,
  ),
  initialState: true,  // Optional: defaults to false
  onChange: (value) {
    // Optional: listen to state changes
    print('Notifications: $value');
  },
)
```

#### External State Management (Controlled Mode)

Full control over state for complex scenarios:

```dart
class MySettingsPage extends StatefulWidget {
  @override
  State<MySettingsPage> createState() => _MySettingsPageState();
}

class _MySettingsPageState extends State<MySettingsPage> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return SettingsItem(
      parameters: ExpandableParameters(
        prefixIcon: Icons.notifications_rounded,
        title: 'Notifications',
        isSwitch: true,
      ),
      isActive: notificationsEnabled,  // Provide external state
      onChange: (value) {
        setState(() {
          notificationsEnabled = value;
        });
      },
    );
  }
}
```

### Basic Example - Switch Mode

```dart
import 'package:flutter/material.dart';
import 'package:settings_item/settings_item.dart';

class MySettingsPage extends StatefulWidget {
  @override
  State<MySettingsPage> createState() => _MySettingsPageState();
}

class _MySettingsPageState extends State<MySettingsPage> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          SettingsExpendableMenu(
            parameters: ExpandableParameters(
              prefixIcon: Icons.notifications_rounded,
              title: 'Notifications',
              isSwitch: true,
            ),
            isActive: notificationsEnabled,
            onChange: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
```Internal State

Simplest expandable menu - no state management needed:

```dart
SettingsItem(
  parameters: ExpandableParameters(
    prefixIcon: Icons.settings_rounded,
    title: 'Display Settings',
    isExpandeable: true,
    expandedWidget: Column(
      children: [
        ListTile(
          leading: Icon(Icons.brightness_6),
          title: Text('Brightness'),
          onTap: () {
            // Handle brightness
          },
        ),
        ListTile(
          leading: Icon(Icons.text_fields),
          title: Text('Font Size'),
          onTap: () {
            // Handle font size
          },
        ),
      ],
    ),
  ),
  // No isActive needed - widget manages its own state!
)
```

### Expandable Mode with Content (External State)

### Expandable Mode with Content

```dart
bool accountExpanded = false;

SettingsExpendableMenu(
  parameters: ExpandableParameters(
    prefixIcon: Icons.account_circle_rounded,
    title: 'Account Settings',
    isExpandeable: true,
    expandedWidget: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Edit Profile'),
          onTap: () {
            // Handle profile edit
          },
        ),
        ListTile(
          leading: Icon(Icons.lock),
          title: Text('Change Password'),
          onTap: () {
            // Handle password change
          },
        ),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('Sign Out'),
          onTap: () {
            // Handle sign out
          },
        ),
      ],
    ),
  ),
  isActive: accountExpanded,
  onChange: (value) {
    setState(() {
      accountExpanded = value;
    });
  },
)
```

### Button Mode (No Expansion)

```dart
bool themeButtonActive = false;

SettingsExpendableMenu(
  parameters: ExpandableParameters(
    prefixIcon: Icons.palette_rounded,
    title: 'Theme Settings',
    isExpandeable: false, // Only rotates arrow, doesn't expand
  ),
  isActive: themeButtonActive,
  onChange: (value) {
    setState(() {
      themeButtonActive = value;
    });
    // Navigate to theme settings page
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ThemeSettingsPage(),
    ));
  },
)
```

### Advanced Example - Custom Suffix Widget

```dart
bool privacyExpanded = false;
int privacyLevel = 2;

SettingsExpendableMenu(
  parameters: ExpandableParameters(
    prefixIcon: Icons.security_rounded,
    title: 'Privacy Level',
    isExpandeable: true,
    suffixWidget: Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        ['Low', 'Medium', 'High'][privacyLevel],
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    expandedWidget: Column(
      children: [
        RadioListTile(
          title: Text('Low'),
          value: 0,
          groupValue: privacyLevel,
          onChanged: (value) {
            setState(() {
              privacyLevel = value!;
            });
          },
        ),
        RadioListTile(
          title: Text('Medium'),
          value: 1,
          groupValue: privacyLevel,
          onChanged: (value) {
            setState(() {
              privacyLevel = value!;
            });?` | Current active/expanded state (optional - if null, uses internal state) |
| `initialState` | `bool` | Initial state when using internal state management (defaults to `false`)
          },
        ),
        RadioListTile(
          title: Text('High'),
          value: 2,
          groupValue: privacyLevel,
          onChanged: (value) {
            setState(() {
              privacyLevel = value!;
            });
          },
        ),
      ],
    ),
    onExpandedSectionToggle: () {
      print('Privacy section toggled!');
    },
  ),
  isActive: privacyExpanded,
  onChange: (value) {
    setState(() {
      privacyExpanded = value;
    });
  },
)
```

## Parameters

### SettingsExpendableMenu

| Parameter | Type | Description |
|-----------|------|-------------|
| `parameters` | `ExpandableParameters` | Configuration for the menu item |
| `isActive` | `bool` | Current active/expanded state |
| `onChange` | `Function(bool)?` | Callback when state changes |

### ExpandableParameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `prefixIcon` | `IconData?` | `null` | Icon displayed on the left |
| `title` | `String?` | `"Settings Item"` | Title text of the menu item |
| `isSwitch` | `bool` | `false` | Shows toggle switch when true |
| `isExpandeable` | `bool` | `true` | Enables content expansion when true |
| `expandedWidget` | `Widget?` | `null` | Content shown when expanded |
| `suffixWidget` | `Widget?` | `null` | Custom widget on the right (overrides default arrow/switch) |
| `onExpandedSectionToggle` | `VoidCallback?` | `null` | Called when expansion state changes |

## Dependencies

This package uses the following dependencies:

- [s_bounceable](https://pub.dev/packages/s_bounceable) ^2.0.0 - For interactive bounce feedback
- [s_toggle](https://pub.dev/packages/s_toggle) ^2.0.1 - For elegant toggle switches

## Example App

A complete example app demonstrating all features is available in the [example](example/) folder. Run it with:

```bash
cd example
flutter run
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**SoundSliced**
- GitHub: [@SoundSliced](https://github.com/SoundSliced)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.
