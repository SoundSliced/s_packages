# S Animated Tabs

A professional, highly customizable animated tab switcher widget for Flutter that follows Material 3 principles and provides smooth, polished animations.

## Features

- Smooth animated indicator with multiple animation styles
- Material 3 friendly styling and color scheme presets
- Optional haptic feedback and elevation
- Customizable sizing, padding, border radius, and typography
- Fully configurable colors or preset color schemes
- Enhanced animations with scale and bounce effects

![Example app preview](https://raw.githubusercontent.com/SoundSliced/s_animated_tabs/main/example/assets/example.gif)

## Installation

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  s_animated_tabs: ^1.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

```dart
import 'package:s_animated_tabs/s_animated_tabs.dart';

SAnimatedTabs(
  tabTitles: const ['Overview', 'Details', 'Reviews'],
  onTabSelected: (index) {
    // Handle selection
  },
)
```

## Advanced configuration

```dart
SAnimatedTabs(
  tabTitles: const ['Overview', 'Details', 'Reviews'],
  onTabSelected: (index) {},
  initialIndex: 1,
  height: 52,
  width: 320,
  padding: const EdgeInsets.all(4),
  borderRadius: 12,
  animationDuration: const Duration(milliseconds: 320),
  animationCurve: Curves.easeOutQuart,
  enableHapticFeedback: true,
  enableElevation: true,
  elevation: 2,
  textSize: TabTextSize.medium,
  colorScheme: TabColorScheme.primary,
  enableEnhancedAnimations: true,
  animationStyle: TabAnimationStyle.smooth,
)
```

## API highlights

- `tabTitles` and `onTabSelected` are required.
- `TabTextSize` presets: `small`, `medium`, `large`.
- `TabColorScheme` presets: `primary`, `secondary`, `surface`, `outline`, `tertiary`.
- `TabAnimationStyle` presets: `smooth`, `bouncy`, `snappy`, `elastic`.

## Example

Run the example app to explore a **basic** and **advanced** demo with live toggles:

```bash
cd example
flutter run
```

## License

MIT — see the `LICENSE` file for details.
