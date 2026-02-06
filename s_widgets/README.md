# s_widgets

A comprehensive Flutter package providing a collection of custom widgets and utilities for building modern, responsive applications. Includes keyboard management, loading indicators, animation utilities, and more.

## Features

- **Keyboard Management** - Dismiss keyboards, add iOS-style done buttons to keyboard overlays
- **Loading Indicators** - Customizable animated loading indicators with transform support
- **State Management** - Safe state management utilities for mounted widgets
- **Widget Extensions** - Extensions for adding Material wrappers, tooltips, color filters, and styling
- **Responsive UI** - Force phone-sized frames on web, auto-scroll text fields during keyboard interaction
- **Animation Utilities** - Blur effects, animated blur transitions, smooth animations
- **Button Widgets** - Flexible text and icon buttons with customizable styling
- **UI Components** - Dividers, expand/collapse buttons, clear buttons for text fields
- **Helper Utilities** - Widget measurement, position detection, snackbar extensions
- **Performance Optimized** - Static widget caching and efficient rendering

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  s_widgets: ^1.1.1
```

Then run:

```bash
flutter pub get
```

## Usage

Import the package:

```dart
import 'package:s_widgets/s_widgets.dart';
```

## Basic Examples

### 1. Dismiss Keyboard on Tap

Wrap your widget tree to dismiss the keyboard when tapping anywhere:

```dart
DismissKeyboard(
  child: SingleChildScrollView(
    child: Column(
      children: [
        TextField(
          decoration: InputDecoration(hintText: 'Enter text'),
        ),
      ],
    ),
  ),
)
```

### 2. iOS-Style Done Button for Keyboard

Show a "Done" button above the keyboard:

```dart
TextField(
  onTap: () {
    KeyboardOverlay.showDoneButtonOverlay(
      context: context,
      onTap: () {
        print('Done tapped');
      },
    );
  },
  decoration: InputDecoration(hintText: 'Tap to show done button'),
)
```

### 3. Custom Loading Indicator

Display an animated loading indicator with custom styling:

```dart
SLoadingIndicator(
  indicatorType: Indicator.circleStrokeSpin,
  colors: [Colors.blue, Colors.cyan],
  scale: 1.5,
)
```

### 4. Custom Text Button

Create a flexible, customizable text button:

```dart
STextButton(
  buttonTitle: 'Submit',
  backgroundColor: Colors.blue,
  onTap: (offset) => print('Button tapped at $offset'),
  buttonBorderRadius: BorderRadius.circular(8),
  height: 48,
  width: 120,
)
```

### 5. Custom Icon Button

Create icon buttons with labels:

```dart
SIconButton(
  iconData: Icons.settings,
  label: 'Settings',
  color: Colors.blue,
  size: 24,
  onTap: (offset) => print('Settings tapped'),
)
```

### 6. Custom Divider

Add stylized dividers to your layouts:

```dart
SDivider(
  lineLength: 200,
  lineThickness: 2,
  lineColor: Colors.grey,
  lineOpacity: 0.5,
)
```

### 7. Snackbar Extension

Show snackbars easily using context:

```dart
context.showSnackBar(message: 'Success!', backgroundColor: Colors.green);
context.showErrorSnackBar(message: 'An error occurred');
```

### 8. Widget Extensions

Add styling to any widget:

```dart
// Add material wrapper
Text('Hello').addMaterialWidget()

// Add tooltip
Icon(Icons.info).addTooltipWidget('This is helpful')

// Add color filter
Image.asset('image.png').colorFilter(
  ColorFilter.mode(Colors.blue.withValues(alpha:0.3), BlendMode.multiply)
)

// Add border radius
ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: Image.asset('image.png'),
)

// Add box decoration
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [BoxShadow(blurRadius: 4)],
  ),
).boxDecoration()
```

## Advanced Examples

### 1. Auto-Scrolling Text Form Field

Automatically scroll a column when a text field receives focus:

```dart
ScrollTextFormFieldWhenKeyboardIsShown(
  child: Column(
    children: [
      SizedBox(height: 300),
      TextField(
        decoration: InputDecoration(hintText: 'This will auto-scroll'),
      ),
    ],
  ),
)
```

### 2. Safe State Management

Extend your stateful widgets from `MountedState` to prevent `setState` errors:

```dart
class MyWidget extends MountedState<MyStatefulWidget> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        // This won't error even if widget is unmounted
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Safe state management'),
      ),
    );
  }
}
```

### 3. Blur Effects

Add blur effects to widgets with animation support:

```dart
// Static blur
SBlur(
  isEnabled: true,
  blurAmountOnX: 10,
  blurAmountOnY: 10,
  child: Image.asset('image.png'),
)

// Animated blur
SAnimatedBlur(
  opacity: 0.8,
  borderRadius: BorderRadius.circular(12),
  child: Container(
    color: Colors.white,
    child: Text('Animated blur background'),
  ),
)
```

### 4. Force Phone Size on Web

Force your Flutter web app to display at phone dimensions:

```dart
ForcePhoneSizeOnWeb(
  size: Size(420, 812), // iPhone 12 Pro dimensions
  child: Scaffold(
    body: Center(
      child: Text('Displaying at phone size on web'),
    ),
  ),
)
```

### 5. Measure Widget Size

Dynamically measure a widget's size during layout:

```dart
MeasureChildSizeWidget(
  onChange: (size) {
    print('Widget size: ${size.width} x ${size.height}');
  },
  child: Container(
    width: 200,
    height: 100,
    color: Colors.blue,
  ),
)
```

### 6. Expand/Collapse Button

Add expand/collapse functionality with a button:

```dart
bool isExpanded = false;

ExpandCollapseButton(
  isExpanded: isExpanded,
  onTap: (expanded) {
    setState(() => isExpanded = expanded);
  },
)
```

### 7. Text Field Clear Button

Add a clear button to text fields:

```dart
TextFormField(
  decoration: InputDecoration(
    hintText: 'Enter text',
    suffixIcon: TextFormFieldClearButton(
      onPressed: () {
        // Clear the field
      },
    ),
  ),
)
```

### 8. Get Widget Position and Size

Retrieve widget position and size programmatically:

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  
  final position = getWidgetPosition(context);
  final size = getWidgetSize(context);
  
  print('Position: $position, Size: $size');
}
```

## API Reference

### Keyboard Management
- `DismissKeyboard` - Dismiss keyboard on tap
- `KeyboardOverlay` - Manage keyboard overlays
- `InputDoneView` - iOS-style done button

### Widgets
- `SLoadingIndicator` - Custom loading indicator
- `STextButton` - Flexible text button
- `SIconButton` - Icon button with label
- `SDivider` - Customizable divider
- `SBlur` - Static blur effect
- `SAnimatedBlur` - Animated blur effect
- `ForcePhoneSizeOnWeb` - Phone-sized frame for web
- `MeasureChildSizeWidget` - Measure widget size
- `ExpandCollapseButton` - Toggle button
- `TextFormFieldClearButton` - Clear button for text fields
- `ScrollTextFormFieldWhenKeyboardIsShown` - Auto-scrolling container

### State Management
- `MountedState<T>` - Safe state base class

### Extensions
- `GenericExtensions<Widget>` - Widget extensions for styling
- `ShowSnackBar` - BuildContext snackbar extension

### Utilities
- `getWidgetPosition(BuildContext)` - Get widget position
- `getWidgetSize(BuildContext)` - Get widget size

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues, feature requests, or contributions, please visit:
- GitHub Issues: https://github.com/SoundSliced/s_widgets/issues
- GitHub Repository: https://github.com/SoundSliced/s_widgets
