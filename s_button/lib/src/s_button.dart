import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bubble_label/bubble_label.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';
import 'package:ticker_free_circular_progress_indicator/ticker_free_circular_progress_indicator.dart';
import 'package:s_ink_button/s_ink_button.dart';
import 'package:s_disabled/s_disabled.dart';

part 'bubble_label_mixin.dart';

/// A simple delayed widget
class Delayed extends StatefulWidget {
  final Duration? delay;
  final Widget Function(BuildContext context, bool initialized) builder;

  const Delayed({
    super.key,
    this.delay,
    required this.builder,
  });

  @override
  State<Delayed> createState() => _DelayedState();
}

class _DelayedState extends State<Delayed> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
        }
      });
    } else {
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _initialized);
  }
}

/// A customizable button widget that supports various interactions and visual effects.
///
/// Features:
/// - Splash effects
/// - Bounce animation
/// - Bubble labels
/// - Double tap support
/// - Long press support
/// - Custom shapes (circle or rectangle)
/// - Haptic feedback
/// - Loading state
/// - Error handling
/// - Custom hit test behavior
class SButton extends StatefulWidget {
  const SButton({
    super.key,
    required this.child,
    this.splashColor,
    this.alignment,
    this.ignoreChildWidgetOnTap = false,
    this.isCircleButton = false,
    this.shouldBounce = true,
    this.bounceScale = 0.98,
    this.bubbleLabelContent,
    this.selectedColor,
    this.onDoubleTap,
    this.onTap,
    this.splashOpacity,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.delay,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.enableHapticFeedback = true,
    this.hapticFeedbackType = HapticFeedbackType.lightImpact,
    this.isLoading = false,
    this.loadingWidget,
    this.onError,
    this.errorBuilder,
    this.isActive = true,
    this.borderRadius,
    this.tooltipMessage,
    this.disableOpacityChange = false,
    this.opacityWhenDisabled = 0.3,
    this.onTappedWhenDisabled,
  });

  final Widget child;
  final Color? splashColor;

  /// The color overlay displayed when the button is in a selected state.
  final Color? selectedColor;

  final double? splashOpacity;
  final double bounceScale;

  /// The border radius applied to the button.
  /// This clips the child widget and is used for splash effects and selected overlay.
  /// If [isCircleButton] is true, this is ignored.
  final BorderRadius? borderRadius;

  final AlignmentGeometry? alignment;
  final bool ignoreChildWidgetOnTap;
  final bool isCircleButton;
  final bool shouldBounce;
  final bool isActive;
  final BubbleLabelContent? bubbleLabelContent;
  final Duration? delay;
  final void Function(Offset onTapPosition)? onTap;
  final void Function(Offset onTapPosition)? onDoubleTap;
  final void Function(LongPressStartDetails)? onLongPressStart;
  final void Function(LongPressEndDetails)? onLongPressEnd;
  final HitTestBehavior hitTestBehavior;
  final bool enableHapticFeedback;
  final HapticFeedbackType hapticFeedbackType;
  final bool isLoading;
  final Widget? loadingWidget;
  final Function(Object error)? onError;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final String? tooltipMessage;

  /// If true, opacity won't change when disabled
  final bool disableOpacityChange;

  /// Custom opacity level when disabled (0.0 - 1.0)
  final double? opacityWhenDisabled;

  /// Callback when disabled widget is tapped, receives tap position
  final void Function(Offset)? onTappedWhenDisabled;

  @override
  State<SButton> createState() => _SButtonState();
}

class _SButtonState extends State<SButton> with BubbleLabelMixin {
  final _widgetKey = GlobalKey();

  @override
  GlobalKey get widgetKey => _widgetKey;

  bool _isMounted = false;

  bool get _hasLabel => widget.bubbleLabelContent != null;
  bool get _isWebWithoutLongPress =>
      kIsWeb &&
      _hasLabel &&
      !widget.bubbleLabelContent!.shouldActivateOnLongPressOnAllPlatforms;

  bool ignoreChildWidgetOnTap = false;

  Color? _splashColor;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _cacheComputedValues();
    _initializeWidget();
  }

  void _cacheComputedValues() {
    _splashColor = widget.splashColor;
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void _initializeWidget() {
    if (!_isMounted) return;

    _isButtonOrNot();
  }

  void _isButtonOrNot() {
    if (!widget.isActive || widget.ignoreChildWidgetOnTap) {
      ignoreChildWidgetOnTap = true;
    }
  }

  @override
  void didUpdateWidget(covariant SButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool shouldUpdate = false;

    final shouldUpdateIgnorePointer =
        oldWidget.ignoreChildWidgetOnTap != widget.ignoreChildWidgetOnTap ||
            oldWidget.isActive != widget.isActive;

    final shouldUpdateCache = oldWidget.borderRadius != widget.borderRadius ||
        oldWidget.splashColor != widget.splashColor ||
        oldWidget.splashOpacity != widget.splashOpacity ||
        oldWidget.selectedColor != widget.selectedColor;

    if (shouldUpdateCache) {
      _cacheComputedValues();
      shouldUpdate = true;
    }

    if (shouldUpdateIgnorePointer) {
      _isButtonOrNot();
      shouldUpdate = true;
    }

    if (shouldUpdate) {
      setState(() {});
    }
  }

  void _handleTap(Offset offset) {
    if (widget.isLoading || !widget.isActive) return;
    widget.onTap?.call(offset);
  }

  @override
  Widget build(BuildContext context) {
    return _hasLabel
        ? _isWebWithoutLongPress
            ? _WebBubbleLabel(
                widgetKey: _widgetKey,
                widget: widget,
                child: _buildSimplifiedButton(wrapLongPressForBubble: false),
              )
            : _MobileBubbleLabel(
                widgetKey: _widgetKey,
                widget: widget,
                child: _buildSimplifiedButton(wrapLongPressForBubble: true),
              )
        : _buildSimplifiedButton(wrapLongPressForBubble: false);
  }

  Widget _buildSimplifiedButton({required bool wrapLongPressForBubble}) {
    final animationDuration = (widget.delay != null &&
            widget.delay! > const Duration(milliseconds: 100))
        ? const Duration(milliseconds: 200)
        : const Duration(milliseconds: 150);

    return Delayed(
      key: _widgetKey,
      delay: widget.delay,
      builder: (context, initialized) => AnimatedSwitcher(
        duration: animationDuration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: initialized
            ? _buildButtonContent(
                wrapLongPressForBubble: wrapLongPressForBubble)
            : SizedBox(),
      ),
    );
  }

  /// Gets the effective border radius
  BorderRadius? get _effectiveBorderRadius => widget.borderRadius;

  void _handleLongPressStartWithBubble(LongPressStartDetails details) {
    if (!widget.isActive) return;
    widget.onLongPressStart?.call(details);
    if (widget.bubbleLabelContent != null) {
      BubbleLabel.show(
        context: context,
        bubbleContent: widget.bubbleLabelContent!,
        /*  anchorKey: widget.bubbleLabelContent!.positionOverride != null
            ? null
            : _widgetKey, */
      );
    }
  }

  void _handleLongPressEndWithBubble(LongPressEndDetails details) {
    if (!widget.isActive) return;
    widget.onLongPressEnd?.call(details);
    if (widget.bubbleLabelContent != null) {
      BubbleLabel.dismiss();
    }
  }

  Widget _buildButtonContent({bool wrapLongPressForBubble = false}) {
    if (widget.isLoading) {
      return widget.loadingWidget ??
          const TickerFreeCircularProgressIndicator();
    }

    // Build the child, optionally clipped
    Widget child = widget.child;
    if (!widget.isCircleButton && _effectiveBorderRadius != null) {
      child = ClipRRect(
        borderRadius: _effectiveBorderRadius!,
        child: child,
      );
    } else if (widget.isCircleButton) {
      child = ClipOval(child: child);
    }

    // Wrap with selected overlay if needed (inside SInkButton so it bounces together)
    Widget buttonChild = child;
    if (widget.selectedColor != null) {
      buttonChild = Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: widget.selectedColor?.withValues(alpha: 0.8),
                  shape: widget.isCircleButton
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                  borderRadius:
                      widget.isCircleButton ? null : _effectiveBorderRadius,
                ),
              ).animate(effects: [FadeEffect(duration: 0.3.sec)]),
            ),
          ),
        ],
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(),
      child: SDisabled(
        isDisabled: !widget.isActive,
        disableOpacityChange: widget.disableOpacityChange,
        opacityWhenDisabled: widget.opacityWhenDisabled,
        onTappedWhenDisabled: widget.onTappedWhenDisabled,
        child: SInkButton(
          hitTestBehavior: widget.hitTestBehavior,
          onTap: _handleTap,
          onDoubleTap: widget.onDoubleTap,
          onLongPressStart: wrapLongPressForBubble
              ? _handleLongPressStartWithBubble
              : widget.onLongPressStart,
          onLongPressEnd: wrapLongPressForBubble
              ? _handleLongPressEndWithBubble
              : widget.onLongPressEnd,
          color: _splashColor,
          scaleFactor:
              widget.shouldBounce && !ignoreChildWidgetOnTap && widget.isActive
                  ? widget.bounceScale
                  : 1.0,
          enableHapticFeedback: widget.enableHapticFeedback,
          hapticFeedbackType: widget.hapticFeedbackType,
          hoverAndSplashBorderRadius: _effectiveBorderRadius,
          isActive: widget.isActive,
          isCircleButton: widget.isCircleButton,
          tooltipMessage: widget.tooltipMessage,
          child: buttonChild,
        ),
      ),
    );
  }
}
