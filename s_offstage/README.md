# s_offstage

A Flutter package that provides smooth animated transitions for showing and hiding widgets using the `Offstage` widget, with advanced animated transitions (fade, scale, slide, rotation) - a powerful alternative to Visibility.

## Demo
![Demo](https://raw.githubusercontent.com/SoundSliced/s_offstage/main/example/assets/example.gif)

## Key Features

- **Performance-optimized**: Uses `Offstage` to completely remove hidden widgets from the render tree
- **Multiple transition types**: Fade, scale, slide, rotation, or combinations
- **Smooth animations**: Automatically animates opacity and other effects when transitioning
- **Advanced animation control**: Custom curves, delays, and completion callbacks
- **Alternative to Visibility**: Provides similar functionality to `Visibility` but with smooth transitions
- **Customizable**: Optional loading indicators, hidden content placeholders, and reveal buttons
- **Zero layout space**: Hidden widgets take up no space in the layout (unlike `Opacity` alone)
- **State callbacks**: Track visibility changes and animation completion

## How it works

`SOffstage` combines the best of both worlds:

1. When hiding a widget (`isOffstage: true`):
   - Smoothly animates the opacity from 1.0 to 0.0
   - Places the widget offstage (removed from render tree, takes no space)
   - Optionally shows a loading indicator

2. When revealing a widget (`isOffstage: false`):
   - Brings the widget back from offstage
   - Smoothly animates the opacity from 0.0 to 1.0
   - Hides the loading indicator

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  s_offstage: ^1.3.0
```


## Usage

Import the package:

```dart
import 'package:s_offstage/s_offstage.dart';
```

### Basic Example

```dart
SOffstage(
  isOffstage: isLoading,
  child: YourContentWidget(),
)
```

### Transition Types

Choose from multiple transition effects:

```dart
// Fade only
SOffstage(
  isOffstage: isLoading,
  transition: SOffstageTransition.fade,
  child: YourContentWidget(),
)

// Scale only
SOffstage(
  isOffstage: isLoading,
  transition: SOffstageTransition.scale,
  child: YourContentWidget(),
)

// Fade and Scale (default)
SOffstage(
  isOffstage: isLoading,
  transition: SOffstageTransition.fadeAndScale,
  child: YourContentWidget(),
)

// Slide with fade
SOffstage(
  isOffstage: isLoading,
  transition: SOffstageTransition.slide,
  slideDirection: AxisDirection.up,
  slideOffset: 0.5,
  child: YourContentWidget(),
)

// Rotation with fade
SOffstage(
  isOffstage: isLoading,
  transition: SOffstageTransition.rotation,
  child: YourContentWidget(),
)
```

### Advanced Animation Control

```dart
SOffstage(
  isOffstage: isLoading,
  // Custom animation curves
  fadeInCurve: Curves.easeOut,
  fadeOutCurve: Curves.easeIn,
  scaleCurve: Curves.elasticOut,
  
  // Animation duration
  fadeDuration: Duration(milliseconds: 500),
  
  // Delay before transitions
  delayBeforeShow: Duration(milliseconds: 100),
  delayBeforeHide: Duration(milliseconds: 50),
  
  child: YourContentWidget(),
)
```

### Callbacks

```dart
SOffstage(
  isOffstage: isLoading,
  // Called when visibility state changes
  onChanged: (isOffstage) {
    print('Widget is now ${isOffstage ? 'hidden' : 'visible'}');
  },
  // Called when animation completes
  onAnimationComplete: (isOffstage) {
    print('Animation finished: ${isOffstage ? 'hidden' : 'visible'}');
    // Chain other actions here
  },
  child: YourContentWidget(),
)
```

### Conditional Loading Indicator

Prevent loading indicator flash for quick transitions:

```dart
SOffstage(
  isOffstage: isLoading,
  // Only show loading indicator if loading takes longer than 300ms
  showLoadingAfter: Duration(milliseconds: 300),
  loadingIndicator: CircularProgressIndicator(
    color: Colors.blue,
  ),
  child: YourContentWidget(),
)
```

### Hidden Content & Reveal Button

Instead of a loading indicator, you can show a placeholder widget when content is offstage:

```dart
SOffstage(
  isOffstage: isHidden,
  // Show a placeholder instead of a loader
  showHiddenContent: true,
  // Optional: Custom placeholder widget
  hiddenContent: Text('Content is hidden'),
  // Add a button to toggle visibility manually
  showRevealButton: true,
  child: YourContentWidget(),
)
```

### State Management Options

```dart
SOffstage(
  isOffstage: isLoading,
  // Preserve widget state when hidden
  maintainState: true,
  // Keep animations running when hidden
  maintainAnimation: true,
  child: YourStatefulWidget(),
)
```

See [`example/lib/main.dart`](example/lib/main.dart) for a complete runnable example:

```dart
import 'package:flutter/material.dart';
import 'package:s_offstage/s_offstage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOffstage Example',
      home: const ExampleHome(),
    );
  }
}

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key});

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SOffstage Example')),
      body: Center(
        child: SOffstage(
          isOffstage: _loading,
          child: Container(
            padding: const EdgeInsets.all(24),
            color: Colors.green.shade100,
            child: const Text(
              'Loaded content!',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
```


## API Reference

### SOffstage Parameters

#### Required
- `isOffstage`: Controls the visibility and loading state
- `child`: The widget to show/hide

#### Animation
- `fadeDuration`: Duration of animations (default: 400ms)
- `fadeInCurve`: Curve for fade-in animation (default: Curves.easeInOut)
- `fadeOutCurve`: Curve for fade-out animation (default: Curves.easeInOut)
- `scaleCurve`: Curve for scale animation (default: Curves.fastEaseInToSlowEaseOut)
- `transition`: Type of transition effect (default: SOffstageTransition.fadeAndScale)
- `slideDirection`: Direction for slide transitions (default: AxisDirection.down)
- `slideOffset`: Offset multiplier for slides (default: 0.3)

#### Timing
- `delayBeforeShow`: Delay before revealing content (default: Duration.zero)
- `delayBeforeHide`: Delay before hiding content (default: Duration.zero)
- `showLoadingAfter`: Delay before showing loading indicator (default: Duration.zero)

#### Loading Indicator
- `showLoadingIndicator`: Whether to show loading indicator (default: true)
- `loadingIndicator`: Custom loading indicator widget (optional)

#### Hidden Content & Reveal
- `showHiddenContent`: Show a placeholder instead of loading indicator (default: false)
- `hiddenContent`: Custom widget to show when hidden (optional)
- `showRevealButton`: Show a toggle button to reveal/hide content (default: false)

#### State Management
- `maintainState`: Preserve widget state when offstage (default: false)
- `maintainAnimation`: Keep animations running when offstage (default: false)

#### Callbacks
- `onChanged`: Called when visibility state changes
- `onAnimationComplete`: Called when transition animation completes

### SOffstageTransition Enum
- `SOffstageTransition.fade`: Opacity animation only
- `SOffstageTransition.scale`: Scale animation only
- `SOffstageTransition.fadeAndScale`: Both fade and scale (default)
- `SOffstageTransition.slide`: Slide with fade
- `SOffstageTransition.rotation`: Rotation with fade


## License

MIT License. See [LICENSE](LICENSE) for details.


## Repository

https://github.com/SoundSliced/s_offstage

## Interactive Example

The package includes a comprehensive example app that demonstrates all features:
- Toggle visibility to see entrance/exit animations
- Switch between all transition types (Fade, Scale, Slide, Rotation)
- Toggle the loading indicator on/off
- Switch between default and custom loading indicators
- View real-time status updates and callbacks

To run the example:
1. Clone the repository
2. Go to the `example` folder
3. Run `flutter run`
