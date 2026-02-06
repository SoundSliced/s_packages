# S Maintenance Button Example

This example app demonstrates all features of the `s_maintenance_button` package, including both basic and advanced usage scenarios.

## Running the Example

To run the example application:

```bash
cd example
flutter run
```

## Features Demonstrated

The example app features an **Interactive Playground** where you can dynamically adjust settings:

- **Maintenance Mode Toggle**: Switch maintenance mode on/off to see the animation.
- **Callback Control**: Enable or disable the button's tap action.
- **Glow Color Selection**: Choose from various colors (Yellow, Orange, Purple, Cyan, Red) to customize the appearance.
- **Real-time Preview**: See changes instantly on a large preview button and within the App Bar.
- **Tap Counter**: Track interaction events when the callback is enabled.

## Key Characteristics

- ✓ Only visible in debug/profile mode
- ✓ Automatic glow animation when active
- ✓ Customizable glow color
- ✓ Optional tap callback
- ✓ Visual state indicator
- ✓ Zero impact in release builds

## Note

The maintenance button is designed to be visible only during development (debug and profile modes) and will automatically hide in release builds.
