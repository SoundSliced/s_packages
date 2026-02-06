import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:ticker_free_circular_progress_indicator/ticker_free_circular_progress_indicator.dart';

/// The type of transition animation to apply when showing/hiding content.
enum SOffstageTransition {
  /// Only fade animation (opacity change).
  fade,

  /// Only scale animation (size change).
  scale,

  /// Both fade and scale animations combined.
  fadeAndScale,

  /// Slide animation with fade.
  slide,

  /// Rotation animation with fade.
  rotation,
}

/// A custom widget that provides a loading state with smooth fade transitions.
///
/// [SOffstage] displays a circular progress indicator while content is loading
/// and smoothly fades in the actual content when it's ready to be displayed.
/// This widget combines the functionality of [Offstage] with [AnimatedOpacity]
/// to create a polished loading experience.
///
/// **Use Cases:**
/// - Loading screens for data fetching operations
/// - Smooth transitions between loading and content states
/// - Any scenario where you need to show a spinner while content is being prepared
///
/// **Example:**
/// ```dart
/// MyOffstage(
///   isOffstage: isLoading,
///   fadeDuration: Duration(milliseconds: 500),
///   child: YourContentWidget(),
/// )
/// ```
///
/// **Example with custom loading indicator:**
/// ```dart
/// MyOffstage(
///   isOffstage: isLoading,
///   loadingIndicator: CircularProgressIndicator(
///     color: Colors.blue,
///     strokeWidth: 3.0,
///   ),
///   child: YourContentWidget(),
/// )
/// ```
class SOffstage extends StatefulWidget {
  /// The duration of the fade animation when transitioning between loading and content states.
  ///
  /// Defaults to 400 milliseconds for a smooth but responsive transition.
  final Duration fadeDuration;

  /// Controls the visibility and loading state of the widget.
  ///
  /// When `true`:
  /// - Shows the circular progress indicator
  /// - Hides the child widget (opacity 0.0 and offstage)
  ///
  /// When `false`:
  /// - Hides the progress indicator
  /// - Shows the child widget with fade-in animation (opacity 1.0)
  final bool isOffstage;

  /// Controls whether to display the loading indicator during the loading state.
  ///
  /// When `true` (default): Shows the loading indicator when [isOffstage] is true.
  /// When `false`: Hides the loading indicator, showing only the content transition.
  ///
  /// Useful for scenarios where you want smooth content transitions without a spinner.
  final bool showLoadingIndicator;

  /// The content widget to display when loading is complete.
  ///
  /// This widget will be hidden (offstage) and transparent while [isOffstage] is true,
  /// and will fade in smoothly when [isOffstage] becomes false.
  final Widget child;

  /// A custom loading indicator widget to display during the loading state.
  ///
  /// If provided, this widget will be shown instead of the default [CircularProgressIndicator].
  /// Only displayed when both [showLoadingIndicator] is true and [isOffstage] is true.
  ///
  /// **Examples:**
  /// - Custom spinner: `CircularProgressIndicator(color: Colors.blue)`
  /// - Text indicator: `Text('Loading...', style: TextStyle(fontSize: 16))`
  /// - Custom animation: `SpinKitFadingCircle(color: Colors.red)`
  ///
  /// If null (default), uses the built-in styled [CircularProgressIndicator].
  final Widget? loadingIndicator;

  /// A callback that is triggered whenever the offstage state changes.
  ///
  /// The callback receives a boolean parameter:
  /// - `true` when the widget becomes offstage (hidden with opacity 0)
  /// - `false` when the widget comes back onscreen (visible with opacity 1)
  ///
  /// **Example:**
  /// ```dart
  /// SOffstage(
  ///   isOffstage: isLoading,
  ///   onChanged: (isOffstage) {
  ///     print('Widget is now ${isOffstage ? 'hidden' : 'visible'}');
  ///   },
  ///   child: YourContentWidget(),
  /// )
  /// ```
  final void Function(bool isOffstage)? onChanged;

  /// A callback that is triggered when the fade animation completes.
  ///
  /// The callback receives a boolean parameter indicating the final state:
  /// - `true` when fade-out animation completes (now fully hidden)
  /// - `false` when fade-in animation completes (now fully visible)
  ///
  /// Useful for chaining actions after transitions complete.
  ///
  /// **Example:**
  /// ```dart
  /// SOffstage(
  ///   isOffstage: isLoading,
  ///   onAnimationComplete: (isOffstage) {
  ///     if (!isOffstage) {
  ///       print('Content is now fully visible!');
  ///     }
  ///   },
  ///   child: YourContentWidget(),
  /// )
  /// ```
  final void Function(bool isOffstage)? onAnimationComplete;

  /// The curve to use for the fade-in animation when content becomes visible.
  ///
  /// Defaults to [Curves.easeInOut] for a smooth transition.
  final Curve fadeInCurve;

  /// The curve to use for the fade-out animation when content becomes hidden.
  ///
  /// Defaults to [Curves.easeInOut] for a smooth transition.
  final Curve fadeOutCurve;

  /// The curve to use for the scale animation.
  ///
  /// Defaults to [Curves.fastEaseInToSlowEaseOut] for a natural feeling transition.
  final Curve scaleCurve;

  /// Delay before showing the content when transitioning from offstage to visible.
  ///
  /// Useful for preventing quick flashes when state changes rapidly.
  /// Defaults to [Duration.zero] (no delay).
  ///
  /// **Example:**
  /// ```dart
  /// SOffstage(
  ///   isOffstage: isLoading,
  ///   delayBeforeShow: Duration(milliseconds: 100),
  ///   child: YourContentWidget(),
  /// )
  /// ```
  final Duration delayBeforeShow;

  /// Delay before hiding the content when transitioning from visible to offstage.
  ///
  /// Useful for preventing quick flashes when state changes rapidly.
  /// Defaults to [Duration.zero] (no delay).
  ///
  /// **Example:**
  /// ```dart
  /// SOffstage(
  ///   isOffstage: isLoading,
  ///   delayBeforeHide: Duration(milliseconds: 100),
  ///   child: YourContentWidget(),
  /// )
  /// ```
  final Duration delayBeforeHide;

  /// Only show the loading indicator if the widget remains offstage longer than this duration.
  ///
  /// This prevents flashing the loading indicator for very quick transitions.
  /// Defaults to [Duration.zero] (show immediately).
  ///
  /// **Example:**
  /// ```dart
  /// SOffstage(
  ///   isOffstage: isLoading,
  ///   showLoadingAfter: Duration(milliseconds: 300),
  ///   child: YourContentWidget(),
  /// )
  /// ```
  final Duration showLoadingAfter;

  /// Whether to maintain the child's state when it goes offstage.
  ///
  /// When `true`, the child widget's state will be preserved even when offstage.
  /// When `false` (default), the child widget may lose its state when offstage.
  ///
  /// This uses the [Offstage] widget's behavior with state management.
  final bool maintainState;

  /// Whether to maintain animations in the child when it goes offstage.
  ///
  /// When `true`, animations in the child continue even when offstage.
  /// When `false` (default), animations may be paused or reset.
  final bool maintainAnimation;

  /// The type of transition effect to apply.
  ///
  /// Options:
  /// - [SOffstageTransition.fade]: Only fade animation (default)
  /// - [SOffstageTransition.scale]: Only scale animation
  /// - [SOffstageTransition.fadeAndScale]: Both fade and scale (current behavior)
  /// - [SOffstageTransition.slide]: Slide animation with fade
  /// - [SOffstageTransition.rotation]: Rotation animation with fade
  final SOffstageTransition transition;

  /// The direction for slide transitions when [transition] is [transition.slide].
  ///
  /// Defaults to [AxisDirection.down].
  final AxisDirection slideDirection;

  /// The offset multiplier for slide transitions.
  ///
  /// A value of 1.0 means slide the full widget height/width.
  /// Defaults to 0.3 for a subtle slide effect.
  final double slideOffset;

  /// Whether to show the hidden content placeholder when offstage.
  ///
  /// If `true`, the [hiddenContent] (or a default placeholder) will be shown
  /// instead of the [loadingIndicator] when the widget is offstage.
  /// This is useful for scenarios where you want to indicate that content is
  /// hidden rather than loading.
  final bool showHiddenContent;

  /// A custom widget to display when [showHiddenContent] is true and the widget is offstage.
  ///
  /// If null, a default "Content Hidden" placeholder will be used.
  final Widget? hiddenContent;

  /// Whether to show a reveal/hide button overlay.
  ///
  /// If `true`:
  /// - When content is visible, shows a 'visibility_off' icon to hide it.
  /// - When content is hidden, shows a 'visibility' icon to reveal it (if using default hidden content).
  /// - Tapping the icon toggles the offstage state.
  final bool showRevealButton;

  /// Creates a [SOffstage] widget.
  ///
  /// The [isOffstage] and [child] parameters are required.
  /// All other parameters are optional with sensible defaults.
  const SOffstage({
    super.key,
    this.fadeDuration = const Duration(milliseconds: 400),
    required this.isOffstage,
    required this.child,
    this.showLoadingIndicator = true,
    this.loadingIndicator,
    this.onChanged,
    this.onAnimationComplete,
    this.fadeInCurve = Curves.easeInOut,
    this.fadeOutCurve = Curves.easeInOut,
    this.scaleCurve = Curves.fastEaseInToSlowEaseOut,
    this.delayBeforeShow = Duration.zero,
    this.delayBeforeHide = Duration.zero,
    this.showLoadingAfter = Duration.zero,
    this.maintainState = true,
    this.maintainAnimation = false,
    this.transition = SOffstageTransition.fadeAndScale,
    this.slideDirection = AxisDirection.down,
    this.slideOffset = 0.3,
    this.showHiddenContent = false,
    this.hiddenContent,
    this.showRevealButton = false,
  });

  @override
  State<SOffstage> createState() => _SOffstageState();
}

class _SOffstageState extends State<SOffstage>
    with SingleTickerProviderStateMixin {
  bool _actualOffstageState = false;
  bool _effectiveOffstage = false;
  bool _loaderOffstage = false;
  bool _showLoading = false;
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _actualOffstageState = widget.isOffstage;
    _effectiveOffstage = widget.isOffstage;
    _loaderOffstage = !widget.isOffstage;
    _showLoading =
        widget.isOffstage && widget.showLoadingAfter == Duration.zero;

    // Initialize animation controller for tracking animation completion
    _animationController = AnimationController(
      duration: widget.fadeDuration,
      vsync: this,
    );

    _animationController!.addStatusListener(_onAnimationStatusChanged);

    if (!_shouldBeOffstage) {
      _animationController!.value = 1.0;
    }
  }

  bool get _shouldBeOffstage => widget.isOffstage;

  @override
  void dispose() {
    _animationController?.removeStatusListener(_onAnimationStatusChanged);
    _animationController?.dispose();
    super.dispose();
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      widget.onAnimationComplete?.call(_actualOffstageState);

      if (status == AnimationStatus.dismissed) {
        setState(() {
          _effectiveOffstage = true;
          _loaderOffstage = false;
        });
      } else if (status == AnimationStatus.completed) {
        setState(() {
          _effectiveOffstage = false;
          _loaderOffstage = true;
        });
      }
    }
  }

  @override
  void didUpdateWidget(SOffstage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation controller duration if it changed
    if (oldWidget.fadeDuration != widget.fadeDuration) {
      _animationController?.duration = widget.fadeDuration;
    }

    // Trigger callback when offstage state changes
    final bool oldShouldBeOffstage = oldWidget.isOffstage;
    final bool newShouldBeOffstage = _shouldBeOffstage;

    if (oldShouldBeOffstage != newShouldBeOffstage) {
      widget.onChanged?.call(newShouldBeOffstage);

      // Handle delays
      final delay =
          newShouldBeOffstage ? widget.delayBeforeHide : widget.delayBeforeShow;

      void updateState() {
        if (mounted) {
          setState(() {
            _actualOffstageState = newShouldBeOffstage;
            _effectiveOffstage = false;
            _loaderOffstage = false;
          });
          _updateAnimation();
        }
      }

      if (delay > Duration.zero) {
        Future.delayed(delay, updateState);
      } else {
        updateState();
      }

      // Handle conditional loading indicator
      if (newShouldBeOffstage && widget.showLoadingAfter > Duration.zero) {
        Future.delayed(widget.showLoadingAfter, () {
          if (mounted && newShouldBeOffstage) {
            setState(() {
              _showLoading = true;
            });
          }
        });
      } else {
        setState(() {
          _showLoading = newShouldBeOffstage;
        });
      }
    }
  }

  void _updateAnimation() {
    if (_actualOffstageState) {
      _animationController?.reverse();
    } else {
      _animationController?.forward();
    }
  }

  void _toggleVisibility() {
    setState(() {
      _actualOffstageState = !_actualOffstageState;
      // If we are becoming visible (not offstage), we need to ensure effective offstage is false immediately
      // so animation can play.
      if (!_actualOffstageState) {
        _effectiveOffstage = false;
      } else {
        // If we are becoming hidden (offstage), we need to ensure loader is visible immediately
        // so animation can play.
        _loaderOffstage = false;
        _showLoading = true;
      }
    });
    _updateAnimation();
    widget.onChanged?.call(_actualOffstageState);
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 1. Child Content
            _TransitionContainer(
              isVisible: !_actualOffstageState,
              offstage: _effectiveOffstage,
              maintainState: widget.maintainState,
              transition: widget.transition,
              fadeDuration: widget.fadeDuration,
              fadeInCurve: widget.fadeInCurve,
              fadeOutCurve: widget.fadeOutCurve,
              scaleCurve: widget.scaleCurve,
              slideDirection: widget.slideDirection,
              slideOffset: widget.slideOffset,
              child: widget.child,
            ),

            // 2. Alternative Content (Loader / HiddenContent)
            if (_showLoading &&
                (widget.showLoadingIndicator || widget.showHiddenContent))
              _TransitionContainer(
                isVisible: _actualOffstageState,
                offstage: _loaderOffstage,
                maintainState: false,
                transition: widget.transition,
                fadeDuration: widget.fadeDuration,
                fadeInCurve: widget.fadeInCurve,
                fadeOutCurve: widget.fadeOutCurve,
                scaleCurve: widget.scaleCurve,
                slideDirection: widget.slideDirection,
                slideOffset: widget.slideOffset,
                child: _buildAlternativeContent(),
              ),

            // 3. Reveal Button Overlay
            if (widget.showRevealButton) _buildRevealButtonOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildAlternativeContent() {
    if (widget.showHiddenContent) {
      if (widget.hiddenContent != null) {
        if (widget.showRevealButton) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // The custom hidden content with an overlayed reveal button
              widget.hiddenContent!,

              // The reveal button InkWell button and effect
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.blue.withValues(alpha: 0.1),
                    highlightColor: Colors.blue.withValues(alpha: 0.1),
                    hoverColor: Colors.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    onTap: _toggleVisibility,
                  ),
                ),
              ),

              // The visibility icon in the top-right corner
              Positioned(
                top: 4,
                right: 4,
                child: IgnorePointer(
                  child: Icon(
                    Icons.visibility,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                ),
              ),
            ],
          );
        }
        return widget.hiddenContent!;
      }
      return _DefaultHiddenContent(
        showRevealButton: widget.showRevealButton,
        onTap: widget.showRevealButton ? _toggleVisibility : null,
      );
    }
    return widget.loadingIndicator ??
        TickerFreeCircularProgressIndicator(
          color: Colors.grey[700]!,
          backgroundColor: Colors.grey[200],
        );
  }

  Widget _buildRevealButtonOverlay() {
    // If content is hidden (offstage) and we are using hidden content (default or custom),
    // the reveal button is handled within _buildAlternativeContent, so we don't need an overlay.
    if (_actualOffstageState && widget.showHiddenContent) {
      return const SizedBox.shrink();
    }

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.blue.withValues(alpha: 0.1),
        highlightColor: Colors.blue.withValues(alpha: 0.1),
        hoverColor: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        onTap: _toggleVisibility,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            _actualOffstageState ? Icons.visibility : Icons.visibility_off,
            color: _actualOffstageState
                ? Colors.green.shade600
                : Colors.red.shade900.withValues(alpha: 0.8),
            size: 20,
          ),
        ),
      ),
    );

    // If hidden (and not using hidden content, i.e. using loader), we center the reveal button
    // to align with the loader.
    // If using a custom loader, we offset it slightly to the top-right
    // so it doesn't obscure the center of the loader.
    // If using the default loader, we keep it centered.
    if (_actualOffstageState) {
      final bool isCustomLoader = widget.loadingIndicator != null;

      if (isCustomLoader) {
        return Transform.translate(
          offset: const Offset(40, -40),
          child: button,
        );
      }
      return button;
    }

    // If visible, we position the hide button in the top-right corner
    // to avoid obstructing the content.
    return Positioned(
      top: 4,
      right: 4,
      child: button,
    );
  }
}

//****************//

class _TransitionContainer extends StatelessWidget {
  final bool offstage;
  final bool maintainState;
  final Widget child;
  final SOffstageTransition transition;
  final bool isVisible;
  final Duration fadeDuration;
  final Curve fadeInCurve;
  final Curve fadeOutCurve;
  final Curve scaleCurve;
  final AxisDirection slideDirection;
  final double slideOffset;

  const _TransitionContainer({
    required this.offstage,
    required this.maintainState,
    required this.child,
    required this.transition,
    required this.isVisible,
    required this.fadeDuration,
    required this.fadeInCurve,
    required this.fadeOutCurve,
    required this.scaleCurve,
    required this.slideDirection,
    required this.slideOffset,
  });

  @override
  Widget build(BuildContext context) {
    final Widget childToRender =
        (offstage && !maintainState) ? const SizedBox.shrink() : child;

    Widget content = Offstage(
      offstage: offstage,
      child: childToRender,
    );

    final double targetOpacity = isVisible ? 1.0 : 0.0;
    final Curve opacityCurve = isVisible ? fadeInCurve : fadeOutCurve;

    switch (transition) {
      case SOffstageTransition.fade:
        content = AnimatedOpacity(
          curve: opacityCurve,
          duration: fadeDuration,
          opacity: targetOpacity,
          child: content,
        );
        break;

      case SOffstageTransition.scale:
        content = AnimatedScale(
          scale: isVisible ? 1.0 : 0.97,
          duration: fadeDuration,
          curve: scaleCurve,
          child: content,
        );
        break;

      case SOffstageTransition.fadeAndScale:
        content = AnimatedScale(
          scale: isVisible ? 1.0 : 0.97,
          duration: fadeDuration,
          curve: scaleCurve,
          child: AnimatedOpacity(
            curve: opacityCurve,
            duration: fadeDuration,
            opacity: targetOpacity,
            child: content,
          ),
        );
        break;

      case SOffstageTransition.slide:
        content = AnimatedSlide(
          offset: isVisible
              ? Offset.zero
              : _getSlideOffset(slideDirection, slideOffset),
          duration: fadeDuration,
          curve: scaleCurve,
          child: AnimatedOpacity(
            curve: opacityCurve,
            duration: fadeDuration,
            opacity: targetOpacity,
            child: content,
          ),
        );
        break;

      case SOffstageTransition.rotation:
        content = AnimatedRotation(
          turns: isVisible ? 0.0 : 0.05,
          duration: fadeDuration,
          curve: scaleCurve,
          child: AnimatedOpacity(
            curve: opacityCurve,
            duration: fadeDuration,
            opacity: targetOpacity,
            child: content,
          ),
        );
        break;
    }

    return content;
  }

  Offset _getSlideOffset(AxisDirection direction, double offset) {
    switch (direction) {
      case AxisDirection.up:
        return Offset(0, offset);
      case AxisDirection.down:
        return Offset(0, -offset);
      case AxisDirection.left:
        return Offset(offset, 0);
      case AxisDirection.right:
        return Offset(-offset, 0);
    }
  }
}

//****************//

/// A default placeholder widget shown when content is hidden and no custom
/// [hiddenContent] is provided.
///
/// Displays a "Content Hidden" message with an icon. If [showRevealButton] is enabled,
/// tapping this widget will toggle the visibility.
class _DefaultHiddenContent extends StatelessWidget {
  final bool showRevealButton;
  final VoidCallback? onTap;

  const _DefaultHiddenContent({
    required this.showRevealButton,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Colors.blue.withValues(alpha: 0.1);
    return IgnorePointer(
      ignoring: !showRevealButton,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: color,
            highlightColor: color,
            hoverColor: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 4,
                children: [
                  if (showRevealButton)
                    Icon(
                      Icons.visibility,
                      color: Colors.green.shade300,
                      size: 15,
                    ),
                  Flexible(
                    child: Text(
                      "Hidden Content",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
