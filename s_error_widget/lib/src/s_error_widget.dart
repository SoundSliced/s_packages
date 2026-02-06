import 'package:flutter/material.dart';

/// A widget that displays an error message with customizable styles.
///
/// The [SErrorWidget] is designed to show an error header and exception
/// text. You can customize the header, the exception text style, the
/// background color, and the header text style.
///
/// You can provide custom text styles for both the header and the exception
/// message, or use the default styles. The widget ensures the error is displayed
/// in a visually distinct manner for a better user experience.
///
/// Properties:
/// - [headerText]: The text to display in the header. Defaults to "Error!" if not provided.
/// - [headerTextStyle]: The style for the header text. Defaults to a white, bold text style.
/// - [exceptionText]: The text that describes the exception or error. This is a required field.
/// - [exceptionTextStyle]: The style for the exception text. Defaults to black, normal-weight text style.
/// - [backgroundColor]: The background color for the widget. Defaults to a green color if not provided.
/// - [icon]: A custom widget to display above the header. Defaults to a warning icon if not provided.
/// - [onRetry]: A callback to execute when the retry button is pressed.
/// - [retryText]: Text to display on the retry button. Defaults to "Retry".
/// - [retryButtonStyle]: Custom style for the retry button.
/// - [exceptionBuilder]: A builder to customize the exception display.
class SErrorWidget extends StatelessWidget {
  /// The text to display in the header.
  /// Defaults to "Error!" if not provided.
  final String? headerText;

  /// The style for the header text.
  /// Defaults to a white, bold text style.
  final TextStyle? headerTextStyle;

  /// The text that describes the exception or error. This is a required field.
  final String exceptionText;

  /// The style for the exception text.
  /// Defaults to black, normal-weight text style.
  final TextStyle? exceptionTextStyle;

  /// The background color for the widget.
  /// Defaults to a green color if not provided.
  final Color? backgroundColor;

  /// A custom icon to display above the text.
  /// Defaults to a warning icon if not provided.
  final Widget? icon;

  /// Callback for the retry button.
  /// If provided, a button will be shown below the error text.
  final VoidCallback? onRetry;

  /// Text for the retry button.
  /// Defaults to "Retry".
  final String? retryText;

  /// Custom style for the retry button.
  final ButtonStyle? retryButtonStyle;

  /// A builder to customize the exception display.
  final Widget Function(BuildContext context, String exceptionText)?
      exceptionBuilder;

  /// The main widget constructor
  const SErrorWidget({
    super.key,
    required this.exceptionText,
    this.exceptionTextStyle,
    this.headerText,
    this.headerTextStyle,
    this.backgroundColor,
    this.icon,
    this.onRetry,
    this.retryText,
    this.retryButtonStyle,
    this.exceptionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? const Color(0xFF38C071),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null)
                icon!
              else
                Text(
                  "\u26A0",
                  style: headerTextStyle?.copyWith(fontSize: 40) ??
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                      ),
                ),
              const SizedBox(height: 8),
              Text(
                headerText ?? "Error!",
                textAlign: TextAlign.center,
                style: headerTextStyle ??
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: exceptionBuilder != null
                    ? exceptionBuilder!(context, exceptionText)
                    : SelectableText(
                        exceptionText,
                        textDirection: TextDirection.ltr,
                        cursorColor: Colors.white,
                        textAlign: TextAlign.center,
                        style: exceptionTextStyle ??
                            const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                      ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onRetry,
                  style: retryButtonStyle ??
                      ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 2,
                      ),
                  child: Text(retryText ?? "Retry"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
