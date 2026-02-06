# s_gridview

A lightweight, customizable grid-like Flutter widget with index-based scrolling and optional scroll indicators.

## 📱 Demo

![IndexScroll ListView Builder Demo](https://raw.githubusercontent.com/SoundSliced/s_gridview/main/example/assets/example.gif)


## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  s_gridview: ^2.0.1
```

For local development, point to the package path:

```yaml
dependencies:
  s_gridview:
    path: ../
```

## Usage example

```dart
import 'package:flutter/material.dart';
import 'package:s_gridview/s_gridview.dart';

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final IndexedScrollController _controller = IndexedScrollController();
  int _crossAxisItemCount = 3;
  bool _showScrollIndicators = true;
  Axis _direction = Axis.vertical;
  Color? _indicatorColor;
  int? _autoScrollToIndex;

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      30,
      (i) => Container(
        width: 100,
        height: 80,
        color: Colors.primaries[i % Colors.primaries.length],
        child: Center(child: Text('Item ${i + 1}')),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('s_gridview example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _crossAxisItemCount = (_crossAxisItemCount % 5) + 1),
                  child: Text('Columns: $_crossAxisItemCount'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _direction = _direction == Axis.vertical ? Axis.horizontal : Axis.vertical),
                  child: Text('Switch to ${_direction == Axis.vertical ? 'Horizontal' : 'Vertical'}'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _showScrollIndicators = !_showScrollIndicators),
                  child: Text(_showScrollIndicators ? 'Hide indicators' : 'Show indicators'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Programmatic scroll via controller
                    await _controller.scrollToIndex(20, alignmentOverride: 0.35);
                  },
                  child: const Text('Scroll to #21'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SGridView(
              controller: _controller,
              crossAxisItemCount: _crossAxisItemCount,
              mainAxisDirection: _direction,
              itemPadding: const EdgeInsets.all(6),
              autoScrollToIndex: _autoScrollToIndex,
              showScrollIndicators: _showScrollIndicators,
              indicatorColor: _indicatorColor,
              children: items,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            // Example auto-scroll: set to an index that demonstrates clamping
            _autoScrollToIndex = 50; // will clamp to max index
          });
        },
        label: const Text('Auto scroll out of bounds'),
        icon: const Icon(Icons.arrow_downward),
      ),
    );
  }
}
```

## Features

### 🎯 Interactive Scrolling
- **Tappable Scroll Indicators**: Tap top/left indicator to scroll backward, bottom/right to scroll forward with smooth animations.
- **Configurable Scroll Distance**: Control how far each indicator tap scrolls via `indicatorScrollFraction` (10% to 200% of viewport).
- **Smart Edge Navigation**: `initialIndicatorJump` provides intuitive multi-group jumps when tapping at list start/end positions.

### 🎨 Customization
- **Index-Based Scrolling**: Full programmatic control with `IndexedScrollController` — call `controller.scrollToIndex(target, alignmentOverride: 0.0..1.0)` to animate to any position.
- **Visual Indicators**: Built-in gradient indicators appear automatically when content is scrollable (appears when list has > `crossAxisItemCount * 3` children).
- **Flexible Layout**: Configure `crossAxisItemCount`, `mainAxisDirection` (vertical/horizontal), `itemPadding`, and more.
- **Custom Styling**: Control indicator color with `indicatorColor` and visibility with `showScrollIndicators`.

### ⚙️ Advanced Features
- **Auto-Scroll on Build**: Set `autoScrollToIndex` to scroll to a specific position when widget first renders (automatically clamped to valid range).
- **External Controller Support**: Inject your own `IndexedScrollController` or let `SGridView` manage it automatically.
- **Manual Scroll Tracking**: Indicators maintain accurate position tracking after user drag/scroll gestures.
- **Flutter Web Optimized**: Comprehensive lifecycle management prevents hot reload errors.

## Parameters

### Core Layout
- `crossAxisItemCount` (int, default: 2): Number of items per row (vertical) or column (horizontal).
- `children` (List<Widget>, required): The list of widgets to display in the grid.
- `mainAxisDirection` (Axis, default: Axis.vertical): Scroll direction - vertical or horizontal.
- `itemPadding` (EdgeInsetsGeometry, default: EdgeInsets.zero): Padding around each child widget.

### Scroll Control
- `controller` (IndexedScrollController?, optional): External controller for programmatic scrolling.
- `autoScrollToIndex` (int?, optional): Auto-scroll to this index on widget build (clamped to valid range).

### Indicator Configuration
- `showScrollIndicators` (bool, default: true): Show/hide the scroll indicators.
- `indicatorColor` (Color?, optional): Custom color for indicators (default: yellow).
- `indicatorScrollFraction` (double, default: 1.0): Scroll distance per indicator tap as fraction of viewport (0.1 to 2.0).
  - `0.5` = scroll half a viewport
  - `1.0` = scroll one full viewport (default)
  - `2.0` = scroll two viewports
- `initialIndicatorJump` (int, default: 2): Number of groups to jump when tapping forward at start or backward at end.

## Example App

The `example/` directory contains an interactive Flutter app showcasing all features, including:
- **Interactive Slider**: Adjust scroll distance in real-time (10% to 200% of viewport)
- **Programmatic Scrolling**: Controller-based navigation
- **Layout Changes**: Switch between vertical/horizontal, adjust columns
- **Indicator Customization**: Change colors, toggle visibility
- **Auto-Scroll Demo**: Out-of-bounds clamping demonstration

Open the `example` folder and run `flutter run`.

## Quick Code Snippets

### Basic Usage with Tappable Indicators

```dart
SGridView(
  crossAxisItemCount: 3,
  children: items,
  // Indicators are tappable by default!
  // Tap top to scroll up, bottom to scroll down
)
```

### Custom Scroll Distance

```dart
// User-controlled scroll distance
double _scrollFraction = 1.0; // 100% of viewport

Slider(
  value: _scrollFraction,
  min: 0.1,
  max: 2.0,
  onChanged: (value) => setState(() => _scrollFraction = value),
)

SGridView(
  crossAxisItemCount: 3,
  indicatorScrollFraction: _scrollFraction,
  children: items,
)
```

### Programmatic Scrolling with External Controller

```dart
final controller = IndexedScrollController();

SGridView(
  controller: controller,
  crossAxisItemCount: 3,
  children: items,
);

// Later (e.g. button press):
await controller.scrollToIndex(75, alignmentOverride: 0.3);
```

### Horizontal Layout

```dart
SGridView(
  mainAxisDirection: Axis.horizontal,
  crossAxisItemCount: 2,
  children: items,
  // Indicators appear on left/right for horizontal scrolling
)
```

### Custom Indicator Styling

```dart
SGridView(
  crossAxisItemCount: 3,
  indicatorColor: Colors.blue,
  indicatorScrollFraction: 0.5, // Half viewport per tap
  initialIndicatorJump: 3, // Jump 3 groups at edges
  children: items,
)
```

## License

This package is licensed under the MIT License — see the `LICENSE` file for details.

## Repository

https://github.com/SoundSliced/s_gridview
