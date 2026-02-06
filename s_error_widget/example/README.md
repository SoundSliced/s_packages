# Example App for my_app_error_widget

This example demonstrates how to use the `MyAppErrorWidget` package in your Flutter applications.

## Features Demonstrated

This example app showcases various use cases of the `MyAppErrorWidget`:

1. **Default Error Widget** - Shows the widget with minimal configuration
2. **Custom Header** - Demonstrates how to customize the header text
3. **Custom Colors** - Shows how to change background and text colors
4. **Warning Style** - Example of using the widget for warnings
5. **Dark Theme** - Demonstrates a dark-themed error display
6. **Long Error Message** - Shows how the widget handles longer, multi-line error messages

## Running the Example

1. Navigate to the example directory:
   ```bash
   cd example
   ```

2. Get the dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Usage

The example app provides an interactive interface where you can:
- Switch between different error widget examples using the chips at the top
- See how each configuration looks
- Observe how the widget handles different text lengths and styles

## Code Example

Here's a simple example from the app:

```dart
import 'package:my_app_error_widget/s_error_widget.dart';

MyAppErrorWidget(
  headerText: 'Oops! Something went wrong',
  exceptionText: 'The server is currently unavailable.',
  backgroundColor: Color(0xFFFF5252),
  headerTextStyle: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 24,
  ),
  exceptionTextStyle: TextStyle(
    color: Colors.white,
    fontSize: 16,
  ),
)
```

## Customization Options

The `MyAppErrorWidget` supports the following customization options:

- **headerText**: Custom header text (defaults to "Error!")
- **exceptionText**: The error message to display (required)
- **backgroundColor**: Background color of the error widget
- **headerTextStyle**: Custom TextStyle for the header
- **exceptionTextStyle**: Custom TextStyle for the exception text
