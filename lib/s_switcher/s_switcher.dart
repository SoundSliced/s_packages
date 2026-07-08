import 'package:flutter/material.dart';
import '../s_bounceable/s_bounceable.dart';
import '../s_disabled/s_disabled.dart';

/// A widget that displays a value with decrement (-) and increment (+) buttons.
/// It is composed of a prefix widget (title or custom prefix),
/// a value widget (text or custom value widget), and a suffix widget (suffix text or custom suffix).
class SSwitcher extends StatefulWidget {
  /// Optional title displayed on the left.
  final String? title;
  final TextStyle? titleStyle;

  /// Optional tooltip for the title.
  final String? titleTooltip;

  /// Custom prefix widget to display instead of the title.
  final Widget? customPrefix;

  /// Callback when the decrement (-) button is tapped.
  final VoidCallback? onDecrement;

  /// Callback when the increment (+) button is tapped.
  final VoidCallback? onIncrement;

  /// Whether the decrement button is enabled. Defaults to true.
  final bool enableDecrement;

  /// Whether the increment button is enabled. Defaults to true.
  final bool enableIncrement;

  /// The value to display in the center.
  final String value;
  final TextStyle? valueTextStyle;

  /// Optional suffix text displayed on the right.
  final String? suffixText;
  final TextStyle? suffixTextStyle;

  /// Custom suffix widget to display instead of the suffix text.
  final Widget? customSuffix;

  /// Decoration for the outer container.
  final Decoration? containerDecoration;
  final EdgeInsetsGeometry containerPadding;

  /// Decoration for the value container.
  final Decoration? valueContainerDecoration;
  final EdgeInsetsGeometry valueContainerPadding;
  final EdgeInsetsGeometry valueContainerMargin;
  final double valueMinWidth;

  /// Custom icon data for decrement button
  final IconData decrementIcon;

  /// Custom icon data for increment button
  final IconData incrementIcon;

  final double iconSize;
  final Color? iconColor;

  const SSwitcher({
    super.key,
    required this.value,
    this.title,
    this.titleStyle,
    this.titleTooltip,
    this.customPrefix,
    this.onDecrement,
    this.onIncrement,
    this.enableDecrement = true,
    this.enableIncrement = true,
    this.suffixText,
    this.suffixTextStyle,
    this.customSuffix,
    this.containerDecoration,
    this.containerPadding =
        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    this.valueContainerDecoration,
    this.valueContainerPadding =
        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.valueContainerMargin = const EdgeInsets.symmetric(horizontal: 8),
    this.valueMinWidth = 26,
    this.decrementIcon = Icons.remove_circle_outline_rounded,
    this.incrementIcon = Icons.add_circle_outline_rounded,
    this.iconSize = 18,
    this.iconColor,
    this.valueTextStyle,
  });

  @override
  State<SSwitcher> createState() => _SSwitcherState();
}

class _SSwitcherState extends State<SSwitcher> {
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant SSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default decorations if none provided
    final defaultContainerDecoration = BoxDecoration(
      color: Colors.black.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
    );

    final defaultValueDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
    );

    final defaultTitleStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
      color: Colors.black87,
    );

    final defaultValueStyle = TextStyle(
        fontWeight: FontWeight.w700, fontSize: 11, color: Colors.black87);

    final defaultSuffixStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Colors.black.withValues(alpha: 0.6),
    );

    Widget prefixWidget = const SizedBox.shrink();
    if (widget.customPrefix != null) {
      prefixWidget = widget.customPrefix!;
    } else if (widget.title != null) {
      final titleText = Text(
        widget.title!,
        style: widget.titleStyle ?? defaultTitleStyle,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      );
      prefixWidget = widget.titleTooltip != null
          ? Tooltip(message: widget.titleTooltip!, child: titleText)
          : titleText;
    }

    Widget suffixWidget = const SizedBox.shrink();
    if (widget.customSuffix != null) {
      suffixWidget = widget.customSuffix!;
    } else if (widget.suffixText != null) {
      suffixWidget = Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(widget.suffixText!, style: widget.suffixTextStyle ?? defaultSuffixStyle),
      );
    }

    return Container(
      padding: widget.containerPadding,
      decoration: widget.containerDecoration ?? defaultContainerDecoration,
      child: Row(
        children: [
          if (widget.customPrefix != null || widget.title != null)
            Flexible(
              child: prefixWidget,
            )
          else
            prefixWidget,
          if (widget.customPrefix != null || widget.title != null) const SizedBox(width: 4),
          SDisabled(
            isDisabled: !widget.enableDecrement,
            opacityWhenDisabled: 0.4,
            child: SBounceable(
              scaleFactor: 0.99,
              onTap: widget.enableDecrement ? widget.onDecrement : null,
              child: Icon(widget.decrementIcon, size: widget.iconSize, color: widget.iconColor),
            ),
          ),
          Flexible(
            child: Container(
              margin: widget.valueContainerMargin,
              padding: widget.valueContainerPadding,
              decoration: widget.valueContainerDecoration ?? defaultValueDecoration,
              alignment: Alignment.center,
              child: Text(
                _currentValue,
                style: widget.valueTextStyle ?? defaultValueStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SDisabled(
            isDisabled: !widget.enableIncrement,
            opacityWhenDisabled: 0.4,
            child: SBounceable(
              scaleFactor: 0.99,
              onTap: widget.enableIncrement ? widget.onIncrement : null,
              child: Icon(widget.incrementIcon, size: widget.iconSize, color: widget.iconColor),
            ),
          ),
          if (widget.suffixText != null || widget.customSuffix != null)
            Flexible(child: suffixWidget)
          else
            suffixWidget,
        ],
      ),
    );
  }
}
