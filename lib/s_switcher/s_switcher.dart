import 'package:flutter/material.dart';
import '../s_bounceable/s_bounceable.dart';
import '../s_disabled/s_disabled.dart';

/// A widget that displays a value with decrement (-) and increment (+) buttons.
/// It is composed of a prefix widget (title or custom prefix),
/// a value widget (text or custom value widget), and a suffix widget (suffix text or custom suffix).
class SSwitcher extends StatelessWidget {
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

  /// The text to display in the center (the value).
  final String valueText;
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
    required this.valueText,
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
    if (customPrefix != null) {
      prefixWidget = customPrefix!;
    } else if (title != null) {
      final titleText = Text(
        title!,
        style: titleStyle ?? defaultTitleStyle,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      );
      prefixWidget = titleTooltip != null
          ? Tooltip(message: titleTooltip!, child: titleText)
          : titleText;
    }

    Widget suffixWidget = const SizedBox.shrink();
    if (customSuffix != null) {
      suffixWidget = customSuffix!;
    } else if (suffixText != null) {
      suffixWidget = Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(suffixText!, style: suffixTextStyle ?? defaultSuffixStyle),
      );
    }

    return Container(
      padding: containerPadding,
      decoration: containerDecoration ?? defaultContainerDecoration,
      child: Row(
        children: [
          if (customPrefix != null || title != null)
            Flexible(
              child: prefixWidget,
            )
          else
            prefixWidget,
          if (customPrefix != null || title != null) const SizedBox(width: 4),
          SDisabled(
            isDisabled: !enableDecrement,
            opacityWhenDisabled: 0.4,
            child: SBounceable(
              scaleFactor: 0.99,
              onTap: enableDecrement ? onDecrement : null,
              child: Icon(decrementIcon, size: iconSize, color: iconColor),
            ),
          ),
          Flexible(
            child: Container(
              margin: valueContainerMargin,
              padding: valueContainerPadding,
              decoration: valueContainerDecoration ?? defaultValueDecoration,
              alignment: Alignment.center,
              child: Text(
                valueText,
                style: valueTextStyle ?? defaultValueStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SDisabled(
            isDisabled: !enableIncrement,
            opacityWhenDisabled: 0.4,
            child: SBounceable(
              scaleFactor: 0.99,
              onTap: enableIncrement ? onIncrement : null,
              child: Icon(incrementIcon, size: iconSize, color: iconColor),
            ),
          ),
          if (suffixText != null || customSuffix != null)
            Flexible(child: suffixWidget)
          else
            suffixWidget,
        ],
      ),
    );
  }
}
