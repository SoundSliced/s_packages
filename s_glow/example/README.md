# s_glow Example

This example demonstrates the usage of the s_glow package, showcasing both Glow1 and Glow2 widgets with various configurations.

## Features Demonstrated

### Glow1 Examples (Left Column)
- Basic breathing glow effect
- Custom color variations
- Button with glow effect
- Toggle glow on/off
- Different animation durations and opacity levels

### Glow2 Examples (Right Column)
- Basic ripple effect with circular shape
- Multiple wave configurations
- Rectangle shape with rounded corners and **interactive slider**
- Real-time `glowRadiusFactor` adjustment (v1.1.0 feature)
- Toggle ripple on/off
- Avatar with ripple effect
- Custom glow colors and durations

## New in v1.1.0

### Interactive Controls
- **Adjustable Glow Factor**: Use the slider in the "Rectangle Shape with Adjustable Factor" example to see how `glowRadiusFactor` affects the glow expansion in real-time
- **Side-by-Side Layout**: Glow1 and Glow2 examples are now displayed side by side for easy comparison

### Visual Demonstrations
The example app includes GIF recordings showing:
- `glow1.gif` - Breathing effect animations
- `glow2.gif` - Ripple effect animations

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

## Code Structure

- `main.dart` - Main example application with all demonstrations
- Each example is contained in an `ExampleCard` widget for easy navigation
- Toggle switches allow you to enable/disable effects in real-time

## Customization

Feel free to modify the example code to experiment with different:
- Colors
- Animation durations
- Opacity values
- Scale factors
- Wave counts
- Shapes and border radius
