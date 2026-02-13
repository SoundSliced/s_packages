import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
class SErrorWidget extends StatefulWidget {
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

  /// An optional error code displayed below the header (e.g., "404", "ERR_NETWORK").
  final String? errorCode;

  /// Optional stack trace text. When provided, an expandable section is shown
  /// allowing the user to view the full stack trace.
  final String? stackTrace;

  /// Whether to show a copy-to-clipboard button for the error text.
  final bool showCopyButton;

  /// Additional action buttons displayed below the retry button.
  final List<Widget>? actions;

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
    this.errorCode,
    this.stackTrace,
    this.showCopyButton = false,
    this.actions,
  });

  @override
  State<SErrorWidget> createState() => _SErrorWidgetState();
}

class _SErrorWidgetState extends State<SErrorWidget> {
  bool _stackTraceExpanded = false;

  void _copyErrorToClipboard() {
    final buffer = StringBuffer();
    buffer.writeln(widget.headerText ?? 'Error!');
    if (widget.errorCode != null) buffer.writeln('Code: ${widget.errorCode}');
    buffer.writeln(widget.exceptionText);
    if (widget.stackTrace != null) {
      buffer.writeln('\nStack Trace:');
      buffer.writeln(widget.stackTrace);
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error details copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.backgroundColor ?? const Color(0xFF38C071),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.icon != null)
                widget.icon!
              else
                Text(
                  "\u26A0",
                  style: widget.headerTextStyle?.copyWith(fontSize: 40) ??
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                      ),
                ),
              const SizedBox(height: 8),
              Text(
                widget.headerText ?? "Error!",
                textAlign: TextAlign.center,
                style: widget.headerTextStyle ??
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
              ),
              if (widget.errorCode != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Code: ${widget.errorCode}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Flexible(
                child: widget.exceptionBuilder != null
                    ? widget.exceptionBuilder!(context, widget.exceptionText)
                    : SelectableText(
                        widget.exceptionText,
                        textDirection: TextDirection.ltr,
                        cursorColor: Colors.white,
                        textAlign: TextAlign.center,
                        style: widget.exceptionTextStyle ??
                            const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                      ),
              ),
              if (widget.stackTrace != null) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(
                      () => _stackTraceExpanded = !_stackTraceExpanded),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _stackTraceExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _stackTraceExpanded
                            ? 'Hide Stack Trace'
                            : 'Show Stack Trace',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_stackTraceExpanded) ...[
                  const SizedBox(height: 8),
                  Flexible(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          widget.stackTrace!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
              if (widget.showCopyButton) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _copyErrorToClipboard,
                  icon: const Icon(Icons.copy, size: 16, color: Colors.white70),
                  label: const Text(
                    'Copy Error',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
              if (widget.onRetry != null) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: widget.onRetry,
                  style: widget.retryButtonStyle ??
                      ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 2,
                      ),
                  child: Text(widget.retryText ?? "Retry"),
                ),
              ],
              if (widget.actions != null) ...[
                const SizedBox(height: 8),
                ...widget.actions!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
