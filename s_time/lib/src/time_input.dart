import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:dart_helper_utils/dart_helper_utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keystroke_listener/keystroke_listener.dart';

import 'package:s_widgets/s_widgets.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';

/// Custom TextEditingController that handles cursor positioning during text transitions
///
/// This controller provides atomic text and cursor updates, ensuring that when text
/// changes occur (especially during formatting transitions), the cursor is positioned
/// correctly without flickering or jumping to unexpected positions.
///
/// Key features:
/// - Atomic text/cursor updates via [setTextWithCursor]
/// - Automatic cursor position clamping to valid ranges
/// - Prevents cursor position loss during text transformations
class TimeTextEditingController extends TextEditingController {
  TimeTextEditingController({super.text});

  /// Sets text and cursor position atomically
  ///
  /// This method ensures that both text and cursor position are updated
  /// together, preventing intermediate states where the cursor might be
  /// positioned incorrectly.
  ///
  /// [newText] - The new text content
  /// [cursorPosition] - The desired cursor position (will be clamped to valid range)
  void setTextWithCursor(String newText, int cursorPosition) {
    final clampedPosition = cursorPosition.clamp(0, newText.length);
    value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: clampedPosition),
    );
  }

  /// Sets text while preserving the current selection
  ///
  /// This method updates the text content while maintaining the current
  /// text selection state, which is important for "select all" operations.
  ///
  /// [newText] - The new text content
  void setTextPreservingSelection(String newText) {
    final currentSelection = selection;
    final clampedSelection = TextSelection(
      baseOffset: currentSelection.baseOffset.clamp(0, newText.length),
      extentOffset: currentSelection.extentOffset.clamp(0, newText.length),
    );

    value = TextEditingValue(
      text: newText,
      selection: clampedSelection,
    );
  }
}

/// Helper class to determine timezone suffix for time display
class TimezoneSuffixHelper {
  /// Returns the appropriate timezone suffix based on UTC status and user preference
  ///
  /// [isUtc] - Whether the time is in UTC
  /// [showLocalIndicator] - Whether to show 'L' indicator for local time
  ///
  /// Returns:
  /// - ' z' for UTC time
  /// - ' ʟ' (small capital L) for local time when showLocalIndicator is true
  /// - '' (empty) for local time when showLocalIndicator is false
  static String getSuffix(
      {required bool isUtc, bool showLocalIndicator = false}) {
    if (isUtc) {
      return ' z';
    } else {
      // Using Unicode small capital L (U+029F) for a visually smaller indicator
      return showLocalIndicator ? ' ʟ' : '';
    }
  }
}

/// Optimized Time Input Text Field Component
///
/// A specialized text input widget for time entry that provides intuitive user experience
/// with smart cursor positioning, automatic formatting, and robust focus management.
///
/// ## Key Features:
/// - **Smart Cursor Positioning**: Always places cursor where user taps, even after focus changes
/// - **Dual Text Modes**: Displays formatted time (HH:MM z/L) when unfocused, digits-only when focused
/// - **Automatic Formatting**: Converts user input to proper time format on focus loss
/// - **Keyboard Navigation**: Supports Enter (submit) and Escape (revert) keys
/// - **Input Validation**: Real-time validation with helpful error messages
/// - **Performance Optimized**: Uses cached regex patterns and efficient character code checks
/// - **Timezone Display**: Shows 'z' for UTC, 'L' for local (optional), or no suffix by default
///
/// ## Usage:
/// ```dart
/// TimeInput(
///   title: "Start Time",
///   time: DateTime.now(),
///   onSubmitted: (timeOfDay) => print("Selected: $timeOfDay"),
///   onChanged: (timeOfDay) => print("Changed: $timeOfDay"), // Optional
///   autoFocus: true, // Optional
///   isUtc: false, // Use local time
///   showLocalIndicator: true, // Show 'L' for local time
/// )
/// ```
///
/// ## Behavior:
/// 1. **On Focus**: Shows digits-only text (e.g., "1030" for 10:30)
/// 2. **On Blur**: Shows formatted text (e.g., "10:30 z" for UTC, "10:30 ʟ" or "10:30" for local)
/// 3. **On Tap**: Positions cursor at equivalent position in digits-only text
/// 4. **On Enter**: Formats current input and submits
/// 5. **On Escape**: Reverts to original value and submits
///
/// ## Technical Improvements:
/// - Enhanced cursor handling with proper position management
/// - Custom TextInputFormatter for consistent input formatting
/// - Reduced redundant formatting calls with cached regex patterns
/// - Simplified state management with efficient focus tracking
/// - Better focus event handling and cursor positioning
/// - Optimized performance with static regex patterns and character code checks
/// - Cleaner separation of concerns between input and display formatting
class TimeInput extends StatefulWidget {
  const TimeInput({
    required this.title,
    required this.onSubmitted,
    super.key,
    this.time,
    this.defaultTime,
    this.isUtc = true,
    this.autoFocus = false,
    this.replaceAllTextOnAutoFocus = false,
    this.onChanged,
    this.inputDecoration,
    this.colorPerTitle,
    this.contentPadding,
    this.inputFontSize,
    this.borderRadius,
    this.isEmptyWhenTimeNull = false,
    this.showClearButton = false,
    this.focusRole,
    this.showLocalIndicator = false,
  });

  /// The label text displayed above the input field
  final String title;

  /// Initial time value to display (defaults to current time if null)
  final DateTime? time;

  /// Optional color mapping for title styling based on title text
  final Map<String, Color>? colorPerTitle;

  final TimeOfDay? defaultTime;

  /// Callback triggered when time input is submitted (Enter key or focus loss)
  /// Called with the parsed TimeOfDay or null if invalid
  final Function(TimeOfDay? time) onSubmitted;

  /// Optional callback triggered during text changes while focused
  /// Useful for real-time validation or preview
  final Function(TimeOfDay? time)? onChanged;

  /// Whether the input should automatically gain focus when widget is created
  final bool autoFocus, replaceAllTextOnAutoFocus, isUtc;

  /// Custom input decoration (uses default styling if null)
  final InputDecoration? inputDecoration;

  /// Optional content padding for the input field
  final EdgeInsetsGeometry? contentPadding;

  /// Optional font size for the input field label
  final double? inputFontSize;

  /// Optional border radius for the input field
  final double? borderRadius;

  final bool isEmptyWhenTimeNull, showClearButton;

  /// Whether to show 'ʟ' (small capital L) indicator for local time when isUtc is false
  /// If false (default), local time is displayed without suffix (e.g., "12:56")
  /// If true, local time is displayed with 'ʟ' suffix (e.g., "12:56 ʟ")
  /// UTC time always shows 'z' suffix regardless of this setting
  final bool showLocalIndicator;

  /// Optional role string used to tag the internal FocusNode for traversal policies.
  final String? focusRole;

  @override
  State<TimeInput> createState() => _TimeInputState();
}

class _TimeInputState extends State<TimeInput> {
  /// Custom controller for atomic text and cursor updates
  late TimeTextEditingController tfc;

  /// Focus node for managing input focus state and keyboard events
  late final RoleFocusNode _focusNode;

  /// Stores the original digits-only value when focus is gained (for Escape key)
  String _originalValue = '';

  /// Prevents recursive formatting calls during text updates
  bool _isFormatting = false;

  /// Tracks if widget was unfocused before current interaction
  /// Used to detect focus gain from tap vs programmatic focus changes
  bool _wasUnfocused = true;

  /// Static regex pattern for detecting formatted text (contains ':', 'z', 'L', or 'ʟ')
  /// Cached for better performance across all widget instances
  // Replaced deprecated RegExp with manual contains checks via helper
  static bool _containsFormatChars(String text) {
    // return true if any of ':', 'z', 'L', or 'ʟ' (U+029F small capital L) present
    for (var i = 0; i < text.length; i++) {
      final c = text.codeUnitAt(i);
      if (c == 58 /* ':' */ ||
          c == 122 /* 'z' */ ||
          c == 76 /* 'L' */ ||
          c == 671 /* 'ʟ' U+029F */) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    // first, format the given time or now time, to "HH:MM z/L" or "HH:MM" for display

    final initialText = (widget.isEmptyWhenTimeNull && widget.time == null)
        ? ''
        : TimeInputControllers.formatTimeInput(
            (widget.time ?? defaultTime)
                .convertToStringTime(showSeparatorSymbol: false),
            isUtc: widget.isUtc,
            showLocalIndicator: widget.showLocalIndicator,
          );

    // then, Initialize controller with formatted time text
    tfc = TimeTextEditingController(text: initialText);

    // Store digits-only version for Escape key functionality
    _originalValue = TimeInputControllers.keepDigitsOnly(initialText);

    // Set up focus management and keyboard event handling
    _focusNode =
        RoleFocusNode((widget.focusRole ?? widget.title).toUpperCase());
    _focusNode.addListener(_onFocusChange);
    _focusNode.onKeyEvent = _handleKeyEvent;

    // Auto-focus if requested - using manual approach to override default selection behavior
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNode.canRequestFocus) {
          _focusNode.requestFocus();
          _wasUnfocused = false; // Mark as focused now that we requested focus

          // Override Flutter's default "select all" behavior with a delayed cursor positioning
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              if (widget.replaceAllTextOnAutoFocus) {
                // Select all text for replacement
                if (tfc.text.isNotEmpty) {
                  tfc.selection = TextSelection(
                      baseOffset: 0, extentOffset: tfc.text.length);
                }
              } else {
                // Position cursor at the end
                if (tfc.text.isNotEmpty) {
                  tfc.selection =
                      TextSelection.collapsed(offset: tfc.text.length);
                }
              }
            }
          });
        }
      });
    }

    // role focus node already contains role label
  }

  DateTime get defaultTime {
    // If no default time is provided, use current time
    final now = (widget.isUtc ? DateTime.now().toUtc() : DateTime.now());
    final defaultTime = widget.defaultTime;
    final defaultTimeDateTime = defaultTime != null
        ? widget.isUtc
            ? DateTime.utc(now.year, now.month, now.day, defaultTime.hour,
                defaultTime.minute)
            : DateTime(now.year, now.month, now.day, defaultTime.hour,
                defaultTime.minute)
        : now;

    return defaultTimeDateTime;
  }

  /// Handles focus state changes between focused and unfocused states
  ///
  /// **On Focus Gain:**
  /// - Stores original value for Escape key functionality
  /// - Converts formatted text to digits-only if focus gained programmatically
  /// - Maintains formatted text if focus gained via tap (handled in _handleTap)
  ///
  /// **On Focus Loss:**
  /// - Formats the current input text (digits → "HH:MM z/L" or "HH:MM")
  /// - Triggers onSubmitted callback with parsed TimeOfDay
  /// - Marks widget as unfocused for next interaction
  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // print('TimeInput: Focus gained. Was unfocused: $_wasUnfocused');

      // When gaining focus, store the original value for escape key
      _originalValue = TimeInputControllers.keepDigitsOnly(tfc.text);

      // If focus was gained programmatically (not via tap), clean the text
      if (!_wasUnfocused && _containsFormatChars(tfc.text)) {
        final digitsOnlyText = TimeInputControllers.keepDigitsOnly(tfc.text);

        // Handle auto-focus behavior
        if (widget.autoFocus) {
          if (widget.replaceAllTextOnAutoFocus) {
            // Select all text for replacement
            tfc.value = TextEditingValue(
              text: digitsOnlyText,
              selection: TextSelection(
                  baseOffset: 0, extentOffset: digitsOnlyText.length),
            );
          } else {
            // Position cursor at the end
            tfc.setTextWithCursor(digitsOnlyText, digitsOnlyText.length);
          }
        } else {
          tfc.value = TextEditingValue(
            text: digitsOnlyText,
            selection: TextSelection.collapsed(offset: digitsOnlyText.length),
          );
        }
        _wasUnfocused = false;
      }
    } else {
      // print('TimeInput: Focus lost, formatting text');
      // When losing focus, format the text and trigger callback
      _formatAndNotify();
      _wasUnfocused = true;
    }
  }

  /// Formats current input text and triggers onSubmitted callback
  ///
  /// Converts digits-only text (e.g., "1030") to formatted text (e.g., "10:30 z", "10:30 L", or "10:30")
  /// and calls the onSubmitted callback with the parsed TimeOfDay.
  /// Uses [_isFormatting] flag to prevent recursive calls.
  void _formatAndNotify() {
    if (_isFormatting) return;

    _isFormatting = true;

    // Store current selection before formatting
    final currentSelection = tfc.selection;
    final hasSelection = currentSelection.start != currentSelection.end;
    final isSelectAllSelection = hasSelection &&
        currentSelection.start == 0 &&
        currentSelection.end == tfc.text.length;

    // Check if field is empty and should return null
    if (widget.isEmptyWhenTimeNull && tfc.text.trim().isEmpty) {
      // Keep the field empty and notify with null
      tfc.value = const TextEditingValue(
        selection: TextSelection.collapsed(offset: 0),
      );
      widget.onSubmitted(null);
      _isFormatting = false;
      return;
    }

    // then format it to "HH:MM z/L" or "HH:MM" for display
    final timeText = TimeInputControllers.formatTimeInput(
      tfc.text,
      isUtc: widget.isUtc,
      showLocalIndicator: widget.showLocalIndicator,
    );

    // Update the controller text while preserving "select all" selections
    if (isSelectAllSelection) {
      // For "select all" selections, select the entire new formatted text
      tfc.value = TextEditingValue(
        text: timeText,
        selection: TextSelection(baseOffset: 0, extentOffset: timeText.length),
      );
    } else {
      // For other cases, just update the text (this typically happens on focus loss)
      tfc.value = TextEditingValue(
        text: timeText,
        selection: TextSelection.collapsed(offset: timeText.length),
      );
    }

    // Notify the parent widget with the parsed TimeOfDay
    final tOd = TimeInputControllers.convertToTimeOfDay(
      timeText,
      isUtc: widget.isUtc,
      defaultTime: (defaultTime, widget.defaultTime),
    );
    widget.onSubmitted(tOd);

    // reset formatting flag
    _isFormatting = false;
  }

  /// Handles keyboard events for Enter and Escape keys
  ///
  /// **Enter Key**: Formats current input, submits, and unfocuses
  /// **Escape Key**: Reverts to original value, formats, and unfocuses
  ///
  /// Returns [KeyEventResult.handled] for processed keys,
  /// [KeyEventResult.ignored] for unhandled keys
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        // Format & submit but allow global Shortcuts (Enter -> NextFocusIntent) to advance.
        _handleEnterKey();
        return KeyEventResult.ignored; // let parent Shortcuts handle traversal
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _handleEscapeKey();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  /// Handles Enter key press: format current input and submit
  ///
  /// If input is empty, uses current time as default.
  /// Formats the input and unfocuses the field.
  void _handleEnterKey() {
    var input = tfc.text.trim();

    // Check if field is empty and should return null
    if (widget.isEmptyWhenTimeNull && input.isEmpty) {
      tfc.value = const TextEditingValue(
        selection: TextSelection.collapsed(offset: 0),
      );
      _focusNode.unfocus();
      return;
    }

    if (input.isEmpty) {
      input = TimeInputControllers.formatTimeInput(
        defaultTime.convertToStringTime(),
        isUtc: widget.isUtc,
        showLocalIndicator: widget.showLocalIndicator,
      );
    }

    final formattedText = TimeInputControllers.formatTimeInput(
      input,
      isUtc: widget.isUtc,
      showLocalIndicator: widget.showLocalIndicator,
    );
    tfc.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
    // Keep focus so global NextFocusIntent mapping can advance after this handler.
  }

  /// Handles Escape key press: revert to original value and submit
  ///
  /// Restores the original value that was present when focus was gained,
  /// formats it, and unfocuses the field.
  void _handleEscapeKey() {
    // Restore original value and format it
    final formattedText = TimeInputControllers.formatTimeInput(
      _originalValue,
      isUtc: widget.isUtc,
      showLocalIndicator: widget.showLocalIndicator,
    );
    tfc.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
    // Escape keeps previous behavior: revert and stay (do not auto-advance).
    _focusNode.unfocus();
  }

  /// Handles tap events with smart cursor positioning
  ///
  /// This method ensures the cursor is always positioned where the user taps,
  /// even when transitioning between formatted and digits-only text modes.
  ///
  /// **Behavior:**
  /// 1. **First tap (unfocused → focused)**: Converts formatted text to digits-only
  ///    and positions cursor at equivalent position
  /// 2. **Subsequent taps (already focused)**: Positions cursor at tap location
  ///
  /// **Algorithm:**
  /// - Detects if text is currently formatted using regex
  /// - Calculates equivalent cursor position in digits-only text
  /// - Uses custom controller to atomically update text and cursor position
  /// - Preserves text selections appropriately
  void _handleTap() {
    // print('TimeInput: Tap detected. Was unfocused: $_wasUnfocused, Text: "${tfc.text}"');

    // Check if the text is formatted using regex for better performance
    final isFormattedText = _containsFormatChars(tfc.text);

    if (_wasUnfocused || isFormattedText) {
      // Widget was unfocused and is gaining focus from tap - handle cursor positioning
      final currentSelection = tfc.selection;
      final formattedText = tfc.text;

      // Calculate target position in digits-only text
      final targetPosition =
          _calculateDigitsPosition(currentSelection.start, formattedText);

      // Convert text to digits only and set cursor position
      final digitsOnlyText = TimeInputControllers.keepDigitsOnly(formattedText);
      final clampedPosition = targetPosition.clamp(0, digitsOnlyText.length);

      // Use the custom controller to set text with cursor position
      tfc.setTextWithCursor(digitsOnlyText, clampedPosition);

      // print('TimeInput: Cursor positioned at $clampedPosition in "$digitsOnlyText"');

      // Mark as focused now that we've handled the tap
      _wasUnfocused = false;
    }
    // For subsequent taps on already focused field, let Flutter handle cursor positioning naturally
    // This preserves "select all" behavior and other native text selection behaviors
  }

  /// Calculates the equivalent cursor position in digits-only text
  ///
  /// When transitioning from formatted text (e.g., "10:30 z") to digits-only text (e.g., "1030"),
  /// this method determines where the cursor should be positioned in the new text.
  ///
  /// **Algorithm:**
  /// 1. Count all digit characters before the tap position in formatted text
  /// 2. Return this count as the equivalent position in digits-only text
  ///
  /// **Example:**
  /// - Formatted text: "10:30 z" (tap at position 4, after ":")
  /// - Digits before position 4: "10" = 2 digits
  /// - Result: cursor position 2 in "1030"
  ///
  /// **Performance:** Uses character code checks (48-57 for '0'-'9') instead of regex
  /// for better performance in the cursor positioning hot path.
  ///
  /// [tapPosition] - The cursor position in the formatted text
  /// [formattedText] - The formatted text containing separators
  ///
  /// Returns the equivalent position in digits-only text
  int _calculateDigitsPosition(int tapPosition, String formattedText) {
    // Early return for edge cases
    if (tapPosition <= 0) return 0;
    if (formattedText.isEmpty) return 0;

    var digitCount = 0;
    final endIndex =
        tapPosition < formattedText.length ? tapPosition : formattedText.length;

    // Count digits using character code for better performance
    for (var i = 0; i < endIndex; i++) {
      final charCode = formattedText.codeUnitAt(i);
      if (charCode >= 48 && charCode <= 57) {
        // '0' to '9'
        digitCount++;
      }
    }

    // print('TimeInput: Position $tapPosition in "$formattedText" → digits position $digitCount');
    return digitCount;
  }

  /// Handles taps outside the input field
  ///
  /// Formats the current input and removes focus when user taps elsewhere
  void _handleTapOutside(PointerDownEvent event) {
    _formatAndNotify();
    _focusNode.unfocus();
  }

  /// Handles text changes during user input
  ///
  /// Provides real-time feedback via onChanged callback while the user is typing.
  /// Only processes changes when the field is focused to avoid interference with formatting.
  ///
  /// **Process:**
  /// 1. Extract digits-only text from current input
  /// 2. Format it for validation
  /// 3. Parse to TimeOfDay and call onChanged if valid
  ///
  /// [input] - The new text content from user input
  void _handleTextChanged(String input) {
    if (widget.onChanged == null || _isFormatting) return;

    // Only process changes during focus to avoid interference with formatting
    if (_focusNode.hasFocus) {
      final digitsOnly = TimeInputControllers.keepDigitsOnly(input);
      final formattedInput = TimeInputControllers.formatTimeInput(
        digitsOnly,
        isUtc: widget.isUtc,
        showLocalIndicator: widget.showLocalIndicator,
      );
      final tOd = TimeInputControllers.convertToTimeOfDay(
        formattedInput,
        isUtc: widget.isUtc,
        defaultTime: (defaultTime, widget.defaultTime),
      );

      widget.onChanged!(tOd);
    }
  }

  @override
  void didUpdateWidget(TimeInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    final timeText = (widget.isEmptyWhenTimeNull && widget.time == null)
        ? ''
        : TimeInputControllers.formatTimeInput(
            (widget.time ?? defaultTime)
                .convertToStringTime(showSeparatorSymbol: false),
            isUtc: widget.isUtc,
            showLocalIndicator: widget.showLocalIndicator,
          );

    // Update text when time prop changes
    // or if the new time text differs from the current controller text
    if (widget.time != oldWidget.time || timeText != tfc.text) {
      tfc.value = TextEditingValue(
        text: timeText,
        selection: TextSelection.collapsed(offset: timeText.length),
      );
      _originalValue = TimeInputControllers.keepDigitsOnly(timeText);
    }
  }

  @override
  void dispose() {
    tfc.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Box(
        height: 80,
        // alignment: Alignment.center,
        child: TextFormField(
          controller: tfc,
          focusNode: _focusNode,
          // autofocus: widget.autoFocus, // Using manual focus to control cursor positioning
          keyboardType: TextInputType.number,
          inputFormatters: [
            TimeInputFormatter(),
          ],
          textAlign: TextAlign.center,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: TimeInputControllers.timeInputValidator,
          onTap: _handleTap,
          onTapOutside: _handleTapOutside,
          onChanged: _handleTextChanged,
          onFieldSubmitted: (_) => _handleEnterKey(), // Mobile/IME submit path
          style: TextStyle(
            fontSize: widget.inputFontSize ?? 16,
            // color: widget.colorPerTitle?[widget.title] ?? Colors.red.shade800,
          ),
          decoration: widget.inputDecoration ??
              InputDecoration(
                fillColor: Colors.white.withValues(alpha: 0.6),
                filled: true,
                hintText: '(e.g., 1030)',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
                labelText: widget.title,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: widget.colorPerTitle?[widget.title] ??
                      Colors.red.shade800,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(widget.borderRadius ?? 12),
                  borderSide: const BorderSide(
                    color: Colors.blueAccent,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(widget.borderRadius ?? 12),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(widget.borderRadius ?? 12),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(widget.borderRadius ?? 12),
                  borderSide: const BorderSide(
                    color: Colors.red,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(widget.borderRadius ?? 12),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                  ),
                ),
                contentPadding: widget.contentPadding ??
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                suffixIcon: widget.showClearButton
                    ? TextFormFieldClearButton(onPressed: () {
                        // Clear the text field and notify with null
                        tfc.clear();
                        _formatAndNotify();
                      })
                    : null,
                suffixIconConstraints: widget.showClearButton
                    ? const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      )
                    : null,
              ),
        ),
      );
}

//********************************* */

/// Utility class for time input processing and validation
///
/// Provides static methods for:
/// - Time input formatting (digits → "HH:MM z")
/// - Input validation and parsing
/// - Text processing utilities
///
/// All methods use cached regex patterns for optimal performance.
class TimeInputControllers {
  /// Static regex pattern for removing non-digit characters
  /// Cached for better performance across all method calls
  // Manual digit filtering replacing deprecated RegExp
  static String _removeNonDigits(String input) {
    if (input.isEmpty) return input;
    final buf = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final c = input.codeUnitAt(i);
      if (c >= 48 && c <= 57) {
        // '0'-'9'
        buf.writeCharCode(c);
      }
    }
    return buf.toString();
  }

  // Exposed for formatter usage without needing RegExp

  //-------------------------------------------//

  /// Formats time input text into display format
  ///
  /// Converts digits-only input into formatted time string with appropriate timezone suffix.
  ///
  /// **Examples (UTC):**
  /// - "1" → "01:00 z"
  /// - "12" → "12:00 z"
  /// - "25" → "01:00 z" (hour 25 wraps to 01)
  /// - "200" → "20:00 z" (HH:M0 format, valid hour)
  /// - "100" → "10:00 z" (HH:M0 format, valid hour)
  /// - "230" → "23:00 z" (HH:M0 format, valid hour)
  /// - "240" → "00:00 z" (hour 24 wraps to 00)
  /// - "250" → "01:00 z" (hour 25 wraps to 01)
  /// - "253" → "01:30 z" (hour 25 wraps to 01, M0 = 30)
  /// - "330" → "03:30 z" (0H:MM format, hour 33 > 25 so use first digit as hour)
  /// - "300" → "03:00 z" (0H:MM format, hour 30 > 25)
  /// - "945" → "09:45 z" (0H:MM format, hour 94 > 25)
  /// - "1234" → "12:34 z"
  /// - "2440" → "00:40 z" (hour 24 wraps to 00)
  /// - "2530" → "01:30 z" (hour 25 wraps to 01)
  ///
  /// **3-digit logic:**
  /// - If first two digits form a valid hour (0-23), treat as HH:M0 format
  /// - If first two digits are 24-29, wrap the hour (% 24) and treat as HH:M0 format
  /// - If first two digits >= 30 and last two digits form valid minutes (0-59), treat as 0H:MM format
  /// - Otherwise, wrap the hours and use HH:M0 format
  ///
  /// **Examples:**
  /// - "253" → "01:30 z" (hour 25, wrap to 01, M0 = 30)
  /// - "264" → "02:40 z" (hour 26, wrap to 02, M0 = 40)
  /// - "297" → "05:70 z" (hour 29, wrap to 05, M0 = 70 - invalid but formatted)
  ///
  /// **Hour wrapping:**
  /// - Hours 24-99 are wrapped using modulo 24 (e.g., 25 → 01, 48 → 00)
  /// - Applied to 2-digit, 3-digit (hours 24-25), and 4-digit inputs
  ///
  /// **Examples (Local with indicator):**
  /// - "1234" → "12:34 ʟ"
  ///
  /// **Examples (Local without indicator):**
  /// - "1234" → "12:34"
  ///
  /// **Process:**
  /// 1. Remove all non-digit characters
  /// 2. Handle empty input
  /// 3. Pad with zeros to ensure proper formatting
  /// 4. Format based on length (1-4 digits) with intelligent 3-digit handling
  /// 5. Wrap hours > 23 using modulo 24
  /// 6. Add appropriate timezone suffix
  ///
  /// [input] - Raw input string (may contain non-digits)
  /// [isUtc] - Whether the time is in UTC (defaults to true)
  /// [showLocalIndicator] - Whether to show 'L' for local time (defaults to false)
  /// Returns formatted time string (e.g., "HH:MM z", "HH:MM L", or "HH:MM") or empty string
  static String formatTimeInput(
    String input, {
    bool isUtc = true,
    bool showLocalIndicator = false,
  }) {
    // Strip all non-digit characters using cached regex
    input = _removeNonDigits(input);

    // Handle empty input
    if (input.isEmpty) {
      return '';
    }

    // Get the appropriate suffix
    final suffix = TimezoneSuffixHelper.getSuffix(
      isUtc: isUtc,
      showLocalIndicator: showLocalIndicator,
    );

    // Format based on length
    if (input.length == 1) {
      return '0${input[0]}:00$suffix';
    } else if (input.length == 2) {
      // For 2 digits, treat as hours and wrap if > 23
      var hours = int.parse(input);
      if (hours > 23) {
        hours = hours % 24;
      }
      return '${hours.toString().padLeft(2, '0')}:00$suffix';
    } else if (input.length == 3) {
      // For 3 digits, intelligently choose between HH:M0 and 0H:MM formats
      final hoursAsHHM = int.parse(input.substring(0, 2));
      final minutesAs0HMM = int.parse(input.substring(1, 3));

      if (hoursAsHHM <= 23) {
        // Valid hour when treating as HH:M0 format
        // e.g., "200" → "20:00", "100" → "10:00", "230" → "23:00"
        return '${input.substring(0, 2)}:${input[2]}0$suffix';
      } else if (hoursAsHHM <= 29) {
        // Hours 24-29: wrap the hour and use HH:M0 format
        // e.g., "240" → "00:00", "253" → "01:30", "264" → "02:40", "297" → "05:70" invalid
        // For 297, minutes 70 is invalid, but we handle that in validation
        final wrappedHours = hoursAsHHM % 24;
        return '${wrappedHours.toString().padLeft(2, '0')}:${input[2]}0$suffix';
      } else if (minutesAs0HMM <= 59) {
        // Hours >= 30 with valid minutes: use 0H:MM format
        // e.g., "330" → "03:30", "300" → "03:00", "945" → "09:45"
        return '0${input[0]}:${input.substring(1, 3)}$suffix';
      } else {
        // Hours >= 30 AND minutes > 59: wrap hours and use HH:M0
        // e.g., "396" → "15:60" still invalid, but at least hours are wrapped
        final wrappedHours = hoursAsHHM % 24;
        return '${wrappedHours.toString().padLeft(2, '0')}:${input[2]}0$suffix';
      }
    } else if (input.length >= 4) {
      // For 4+ digits, check if hours need wrapping
      var hours = int.parse(input.substring(0, 2));
      final minutes = input.substring(2, 4);
      if (hours > 23) {
        hours = hours % 24;
      }
      return '${hours.toString().padLeft(2, '0')}:$minutes$suffix';
    }
    return input;
  }

  //------------------------------------------//

  /// Extracts only digit characters from input string
  ///
  /// Removes all non-digit characters and whitespace.
  /// Used to convert formatted text back to digits-only for editing.
  ///
  /// **Example:** "10:30 z" → "1030"
  ///
  /// [input] - Input string that may contain non-digits
  /// Returns string containing only digits
  static String keepDigitsOnly(String input) =>
      _removeNonDigits(input).removeWhiteSpaces;

  //------------------------------------------//

  /// Validates time input format and values
  ///
  /// Checks if the input represents a valid time in 24-hour format.
  ///
  /// **Validation Rules:**
  /// - Must contain 3-4 digits (e.g., "930" or "1030")
  /// - Hours must be 00-23
  /// - Minutes must be 00-59
  ///
  /// **Examples:**
  /// - "1030" → null (valid)
  /// - "2530" → "Invalid time" (25 hours)
  /// - "1070" → "Invalid time" (70 minutes)
  /// - "12" → "format: HrMn" (too short)
  ///
  /// [input] - Input string to validate
  /// Returns null if valid, error message if invalid
  static String? timeInputValidator(String? input) {
    if (input == null || input.isEmpty) {
      return 'Empty';
    }

    // Remove all non digits characters
    input = _removeNonDigits(input);

    if (input.length < 3 || input.length > 4) {
      return 'HHMM';
    }

    int hours;
    int minutes;

    if (input.length == 3) {
      // For 3 digits: intelligently choose between HH:M0 and 0H:MM formats
      final hoursAsHHM = int.parse(input.substring(0, 2));
      final minutesAs0HMM = int.parse(input.substring(1, 3));

      if (hoursAsHHM <= 23) {
        // Valid hour when treating as HH:M0 format
        hours = hoursAsHHM;
        minutes = int.parse(input[2]) * 10;
      } else if (hoursAsHHM <= 29) {
        // Hours 24-29: wrap and use HH:M0 format
        hours = hoursAsHHM % 24;
        minutes = int.parse(input[2]) * 10;
      } else if (minutesAs0HMM <= 59) {
        // Hours >= 30 with valid minutes: use 0H:MM format
        hours = int.parse(input[0]);
        minutes = minutesAs0HMM;
      } else {
        // Hours >= 30 AND minutes > 59: wrap hours and use HH:M0
        hours = hoursAsHHM % 24;
        minutes = int.parse(input[2]) * 10;
      }
    } else {
      // For 4 digits: standard HH:MM format with hour wrapping
      hours = int.parse(input.substring(0, 2));
      if (hours > 23) {
        hours = hours % 24;
      }
      minutes = int.parse(input.substring(2, 4));
    }

    if (hours > 23 || minutes > 59) {
      return 'Invalid time';
    }
    return null;
  }

  //------------------------------------------//

  /// Converts formatted time string to TimeOfDay object
  ///
  /// Parses a formatted time string (e.g., "10:30 z", "10:30 ʟ", or "10:30") into a TimeOfDay object.
  ///
  /// **Process:**
  /// 1. Remove timezone suffix ("z", "L", or "ʟ") and whitespace
  /// 2. Split on colon separator
  /// 3. Parse hours and minutes
  /// 4. Validate ranges (0-23 hours, 0-59 minutes)
  /// 5. Return TimeOfDay or error
  ///
  /// **Examples:**
  /// - "10:30 z" → (TimeOfDay(10, 30), null)
  /// - "10:30 ʟ" → (TimeOfDay(10, 30), null)
  /// - "10:30" → (TimeOfDay(10, 30), null)
  /// - "25:00 z" → (null, "Invalid time: 25:00")
  /// - "invalid" → (null, "Invalid format: invalid")
  ///
  /// [timeString] - Formatted time string with optional timezone suffix
  /// Returns tuple of (TimeOfDay?, String?) where second element is error message
  static TimeOfDay convertToTimeOfDay(String timeString,
      {bool isUtc = true,
      (DateTime?, TimeOfDay?) defaultTime = const (null, null)}) {
    final dfT =
        defaultTime.$1 ?? (isUtc ? DateTime.now().toUtc() : DateTime.now());
    var timeOfDay = TimeOfDay(hour: dfT.hour, minute: dfT.minute);

    if (timeString != 'null' && timeString.isNotEmpty) {
      // Remove timezone suffixes ('z', 'L', or 'ʟ') and trim any whitespace
      timeString = timeString
          .replaceAll(' z', '')
          .replaceAll(' L', '')
          .replaceAll(' ʟ', '')
          .trim();

      // Split the string into hours and minutes
      final parts = timeString.split(':');

      if (parts.length == 2) {
        var hours = int.tryParse(parts[0]);
        var minutes = int.tryParse(parts[1]);

        // Validate hours and minutes
        if (hours == null || hours < 0 || hours > 23) {
          hours = defaultTime.$2 != null ? defaultTime.$2!.hour : dfT.hour;
        }
        if (minutes == null || minutes < 0 || minutes > 59) {
          minutes =
              defaultTime.$2 != null ? defaultTime.$2!.minute : dfT.minute;
        }

        timeOfDay = TimeOfDay(hour: hours, minute: minutes);
      }
    }

    // Create a DateTime object for today with the specified time
    return timeOfDay;
  }

  //------------------------------------------//
}

/// Custom TextInputFormatter for time input fields
///
/// This formatter ensures that only digits are accepted and limits input to 4 digits maximum.
/// It also handles cursor positioning during input to maintain a smooth user experience.
///
/// **Features:**
/// - Filters out all non-digit characters
/// - Limits input to maximum 4 digits (HHMM format)
/// - Maintains proper cursor positioning during filtering
/// - Uses cached regex for optimal performance
///
/// **Usage:**
/// Applied automatically by TimeInput widget to ensure consistent input handling.
class TimeInputFormatter extends TextInputFormatter {
  /// Formats text input by filtering digits and managing cursor position
  ///
  /// Called automatically by Flutter's text input system when user types.
  ///
  /// **Process:**
  /// 1. Extract only digits from new input
  /// 2. Limit to 4 digits maximum
  /// 3. Calculate appropriate cursor position
  /// 4. Return formatted TextEditingValue
  ///
  /// **Cursor Logic:**
  /// - Counts difference in digit count between old and new values
  /// - Adjusts cursor position based on this difference
  /// - Clamps position to valid range
  ///
  /// [oldValue] - Previous TextEditingValue
  /// [newValue] - New TextEditingValue from user input
  /// Returns filtered and formatted TextEditingValue
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Keep only digits using cached regex - use local regex to avoid conflicts
    final digitsOnly = TimeInputControllers._removeNonDigits(newValue.text);

    // Limit to 4 digits max
    final limitedText =
        digitsOnly.length > 4 ? digitsOnly.substring(0, 4) : digitsOnly;

    // Improved cursor position calculation
    final newCursorPosition =
        _calculateCorrectCursorPosition(oldValue, newValue, limitedText);

    return TextEditingValue(
      text: limitedText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }

  /// Calculates the correct cursor position after text filtering
  ///
  /// This method handles cursor positioning for all input operations including
  /// insertion, deletion, backspace, and full text replacement by tracking digit positions accurately.
  int _calculateCorrectCursorPosition(
    TextEditingValue oldValue,
    TextEditingValue newValue,
    String filteredText,
  ) {
    // Check if this was a "select all" operation where entire text was selected and replaced
    final oldHadFullSelection = oldValue.selection.start == 0 &&
        oldValue.selection.end == oldValue.text.length &&
        oldValue.selection.start != oldValue.selection.end;

    // If the old value had full selection and user typed something, position cursor at end
    if (oldHadFullSelection && filteredText.isNotEmpty) {
      return filteredText.length;
    }

    // Get digits-only versions of old and new text
    final oldDigits = TimeInputControllers._removeNonDigits(oldValue.text);
    final newDigits = TimeInputControllers._removeNonDigits(newValue.text);

    // If the text length increased (insertion), use the new cursor position
    if (newDigits.length > oldDigits.length) {
      // For insertions, count digits before cursor position in new value
      var digitsBefore = 0;
      final cursorPos = newValue.selection.baseOffset;

      for (var i = 0; i < cursorPos && i < newValue.text.length; i++) {
        final charCode = newValue.text.codeUnitAt(i);
        if (charCode >= 48 && charCode <= 57) {
          // '0' to '9'
          digitsBefore++;
        }
      }

      return digitsBefore.clamp(0, filteredText.length);
    }

    // For deletions/backspace, we need to be more careful
    // Count digits before the cursor in the old value
    var oldDigitsBefore = 0;
    final oldCursorPos = oldValue.selection.baseOffset;

    for (var i = 0; i < oldCursorPos && i < oldValue.text.length; i++) {
      final charCode = oldValue.text.codeUnitAt(i);
      if (charCode >= 48 && charCode <= 57) {
        // '0' to '9'
        oldDigitsBefore++;
      }
    }

    // For backspace (cursor moves left), decrease position by 1
    if (newDigits.length < oldDigits.length &&
        newValue.selection.baseOffset < oldValue.selection.baseOffset) {
      return (oldDigitsBefore - 1).clamp(0, filteredText.length);
    }

    // For delete (cursor stays same), keep same position
    if (newDigits.length < oldDigits.length &&
        newValue.selection.baseOffset == oldValue.selection.baseOffset) {
      return oldDigitsBefore.clamp(0, filteredText.length);
    }

    // Default case: maintain relative position
    return oldDigitsBefore.clamp(0, filteredText.length);
  }
}
