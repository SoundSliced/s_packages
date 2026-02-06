# Week Calendar Example App

A comprehensive example application demonstrating all features of the `week_calendar` package.

## Features Demonstrated

This example app showcases every feature and customization option available in the week_calendar package:

### 1. **Standard Calendar** (`/standard`)
- Default circular day indicators
- Basic month navigation
- Simple date selection

### 2. **Outlined Calendar** (`/outlined`)
- Outlined containers with borders
- Clean, modern appearance
- Custom border styling

### 3. **Minimal Calendar** (`/minimal`)
- Simplified text-based display
- Compact design
- Minimal visual elements

### 4. **Elevated Calendar** (`/elevated`)
- Material-elevated containers
- Shadow effects
- Depth and dimension

### 5. **Custom Styles** (`/custom-styles`)
- Custom colors and theming
- Text style customization
- Custom indicator sizes
- Animation timing and curves

### 6. **Starting Day Options** (`/starting-day`)
- Week starting on any day (Monday through Sunday)
- ISO 8601 standard support
- Flexible week configuration

### 7. **Animation Controls** (`/animations`)
- Enable/disable animations
- Custom animation duration
- Multiple animation curves (ease, bounce, elastic, etc.)
- Smooth transitions

### 8. **Callbacks Demo** (`/callbacks`)
- Date selection callbacks
- Month navigation callbacks
- Header interaction callbacks
- Event logging and tracking

### 9. **All Features Combined** (`/all-features`)
- Interactive playground
- Real-time customization
- All options in one place
- Live configuration updates

## Running the Example

```bash
# Navigate to the example directory
cd example

# Get dependencies
flutter pub get

# Run on your preferred device
flutter run
```

## Navigation

Use the drawer menu (hamburger icon) to navigate between different example screens. Each screen demonstrates specific features and includes:

- Visual demonstration of the calendar
- Interactive controls (where applicable)
- Selected date display
- Feature descriptions

## Key Features Showcased

### Calendar Types
- **Standard**: Default circular indicators
- **Outlined**: Border-based design
- **Minimal**: Text-only simplified view
- **Elevated**: Material shadow effects

### Customization Options
- **Colors**: Custom active, inactive, and background colors
- **Sizes**: Configurable indicator dimensions
- **Typography**: Full text style control
- **Borders**: Custom border styles
- **Shadows**: Shadow effects for depth
- **Icons**: Custom navigation icons

### Behavioral Features
- **Starting Day**: Choose any day to start the week
- **Animations**: Configurable transitions and timing
- **UTC Support**: Handle UTC or local dates
- **Callbacks**: Comprehensive event handling
- **Header Control**: Toggle header visibility
- **Today Button**: Quick navigation to current date

### Interaction Features
- **Date Selection**: Tap to select dates
- **Month Navigation**: Previous/next month controls
- **Header Tap**: Custom header interactions
- **Today Navigation**: Quick jump to current date
- **Disabled Dates**: Future date restrictions

## Code Examples

Each screen in the example app includes complete, working code that you can reference for your own implementation. The code is well-commented and follows Flutter best practices.

## Learning Path

We recommend exploring the examples in this order:

1. **Standard Calendar** - Understand the basics
2. **Outlined/Minimal/Elevated** - Explore visual variants
3. **Custom Styles** - Learn styling options
4. **Starting Day** - Configure week layout
5. **Animations** - Control motion and timing
6. **Callbacks** - Handle user interactions
7. **All Features** - See everything together

## Additional Resources

- [Package README](../README.md) - Full package documentation
- [API Documentation](../lib/week_calendar.dart) - Detailed API reference
- [Tests](../test/) - Comprehensive test examples

## Support

For issues, feature requests, or questions:
- GitHub Issues: [week_calendar/issues](https://github.com/SoundSliced/week_calendar/issues)
- Documentation: See the main package README

## License

This example app is part of the week_calendar package and shares the same license.
