# s_error_widget

A highly customizable and reusable error widget for Flutter applications. `s_error_widget` allows you to display error states with headers, icons, exception details, and retry actions in a consistent and visually appealing way.

![s_error_widget example](https://raw.githubusercontent.com/SoundSliced/s_error_widget/main/example/assets/example.gif)

## Features

*   **Customizable Structure**: Configurable header text, exception message, and icons.
*   **Flexible Styling**: Control colors and text styles for every element.
*   **Retry Mechanism**: Built-in support for retry callbacks and button customization.
*   **Advanced Builders**: Use `exceptionBuilder` to take full control over how complex errors are rendered.
*   **Dynamic Sizing**: Adapts to parent constraints, suitable for full-screen errors or small component placeholders.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  s_error_widget: ^1.0.1
```

## Usage

### Basic Usage

The simplest way to use `SErrorWidget` is to provide the `exceptionText`. This displays a default error icon and header.

```dart
import 'package:s_error_widget/s_error_widget.dart';

SErrorWidget(
  exceptionText: 'Something went wrong. Please try again.',
)
```

### Advanced Usage

#### Customizing Appearance

You can customize almost every aspect of the widget, including colors, text styles, and the header icon.

```dart
SErrorWidget(
  headerText: 'Connection Failed',
  headerTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
  exceptionText: 'Unable to reach the server. Please check your internet.',
  exceptionTextStyle: TextStyle(color: Colors.white70),
  backgroundColor: Colors.redAccent,
  icon: Icon(Icons.wifi_off, size: 50, color: Colors.white),
)
```

#### Adding a Retry Action

Provide an `onRetry` callback to show a retry button.

```dart
SErrorWidget(
  exceptionText: 'Network timeout.',
  onRetry: () {
    // Refresh your data here
    print('Retrying...');
  },
  retryText: 'Try Again',
  retryButtonStyle: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.red,
  ),
)
```

#### Custom Exception Rendering (Builder)

For complete control over how the error message is displayed (e.g., rendering code blocks, HTML, or expandable text), use the `exceptionBuilder`.

```dart
SErrorWidget(
  headerText: 'Syntax Error',
  exceptionText: 'Unexpected token "}" at line 42.',
  exceptionBuilder: (context, text) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.black12,
      child: Text(
        text,
        style: TextStyle(fontFamily: 'Courier', color: Colors.yellow),
      ),
    );
  },
)
```

## Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `headerText` | `String?` | Text displayed in the header. | "Error!" |
| `headerTextStyle` | `TextStyle?` | Style for the header text. | White, Bold, 18sp |
| `exceptionText` | `String` | The main error message to display. | Required |
| `exceptionTextStyle` | `TextStyle?` | Style for the exception text. | Black, 14sp |
| `backgroundColor` | `Color?` | Background color of the widget. | Green (`0xFF38C071`) |
| `icon` | `Widget?` | Widget displayed above the header. | Warning Icon (`\u26A0`) |
| `onRetry` | `VoidCallback?` | Callback for the retry button. If null, button is hidden. | null |
| `retryText` | `String?` | Label for the retry button. | "Retry" |
| `retryButtonStyle` | `ButtonStyle?` | Style for the retry button. | Default ElevatedButton style |
| `exceptionBuilder` | `Widget Function?` | Builder to replace default exception text rendering. | null |
