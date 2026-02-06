part of 's_expendable_menu.dart';

/// A widget that displays an animated arrow icon for expandable menus.
///
/// The [SExpandableHandles] widget can operate in two modes:
///
/// **Standalone Mode** (Simple):
/// When [expandsRight] and [expandsDown] are not provided, the widget manages
/// its own internal expansion state. Simply provide [onTap] callback and the
/// widget will automatically animate between states when tapped or when
/// [triggerOnTap] changes.
///
/// ```dart
/// SExpandableHandles(
///   width: 70,
///   height: 70,
///   iconColor: Colors.white,
///   onTap: () => print('Tapped!'),
/// )
/// ```
///
/// **Controlled Mode** (Advanced):
/// When [expandsRight] or [expandsDown] is provided, you control the expansion
/// state via [isExpanded]. This is useful when the handle needs to reflect
/// the state of an external expandable menu.
///
/// ```dart
/// SExpandableHandles(
///   width: 70,
///   height: 70,
///   iconColor: Colors.white,
///   isExpanded: _isMenuExpanded,
///   expandsRight: true,
///   onTap: () => setState(() => _isMenuExpanded = !_isMenuExpanded),
/// )
/// ```
class SExpandableHandles extends StatefulWidget {
  /// Callback invoked when the icon is tapped.
  final VoidCallback onTap;

  /// Width of the button container.
  final double width;

  /// Height of the button container.
  final double height;

  /// Color applied to the arrow icon.
  final Color iconColor;

  /// Whether the menu is currently expanded.
  final bool isExpanded;

  /// If true, menu expands to the right (horizontal).
  final bool? expandsRight;

  /// If true, menu expands downward (vertical).
  final bool? expandsDown;

  /// Controls the animation state externally (true = reverse/collapse).
  final bool? shoulAutodReverseHamburgerAnimationWhenComplete;

  /// Callback fired when the animation completes.
  final Function(bool? state)? onHamburgerStateAnimationCompleted;

  /// If true, triggers the animation on the next frame.
  final bool? triggerOnTap;

  const SExpandableHandles({
    super.key,
    required this.onTap,
    required this.width,
    required this.height,
    required this.iconColor,
    this.isExpanded = false,
    this.expandsRight,
    this.expandsDown,
    this.shoulAutodReverseHamburgerAnimationWhenComplete,
    this.onHamburgerStateAnimationCompleted,
    this.triggerOnTap,
  });

  @override
  State<SExpandableHandles> createState() => _SExpandableHandlesState();
}

class _SExpandableHandlesState extends State<SExpandableHandles> {
  bool _isAnimating = false;
  bool _internalExpandedState = false;

  /// Returns true if this widget is managing its own expansion state
  bool get _isStandaloneMode =>
      widget.expandsRight == null && widget.expandsDown == null;

  @override
  void didUpdateWidget(SExpandableHandles oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle reverse animation trigger
    if (widget.shoulAutodReverseHamburgerAnimationWhenComplete !=
            oldWidget.shoulAutodReverseHamburgerAnimationWhenComplete &&
        widget.shoulAutodReverseHamburgerAnimationWhenComplete != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _triggerAnimation(
            reverse: widget.shoulAutodReverseHamburgerAnimationWhenComplete!);
      });
    }

    // Handle external tap trigger - trigger on any change
    if (widget.triggerOnTap != oldWidget.triggerOnTap &&
        widget.triggerOnTap != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _handleTap();
      });
    }
  }

  /// Handles tap event, ensuring animation is not already in progress
  void _handleTap() {
    if (!_isAnimating) {
      widget.onTap();

      // In standalone mode, toggle internal state
      if (_isStandaloneMode) {
        setState(() {
          _internalExpandedState = !_internalExpandedState;
        });
      }

      _triggerAnimation();
    }
  }

  /// Triggers the animation with optional state reversal
  void _triggerAnimation({bool? reverse}) {
    if (!mounted) return;

    _isAnimating = true;

    // Reset animation lock after animation duration
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _isAnimating = false;
        widget.onHamburgerStateAnimationCompleted?.call(null);
      }
    });
  }

  IconData _getIconData() {
    // Use internal state if in standalone mode, otherwise use widget state
    final isExpanded =
        _isStandaloneMode ? _internalExpandedState : widget.isExpanded;

    // Determine if horizontal or vertical
    if (widget.expandsRight != null) {
      // Horizontal expansion
      if (widget.expandsRight!) {
        // Expands right: show left arrow when expanded, right arrow when collapsed
        return isExpanded
            ? Icons.keyboard_arrow_left_rounded
            : Icons.keyboard_arrow_right_rounded;
      } else {
        // Expands left: show right arrow when expanded, left arrow when collapsed
        return isExpanded
            ? Icons.keyboard_arrow_right_rounded
            : Icons.keyboard_arrow_left_rounded;
      }
    } else if (widget.expandsDown != null) {
      // Vertical expansion
      if (widget.expandsDown!) {
        // Expands down: show up arrow when expanded, down arrow when collapsed
        return isExpanded
            ? Icons.keyboard_arrow_up_rounded
            : Icons.keyboard_arrow_down_rounded;
      } else {
        // Expands up: show down arrow when expanded, up arrow when collapsed
        return isExpanded
            ? Icons.keyboard_arrow_down_rounded
            : Icons.keyboard_arrow_up_rounded;
      }
    }

    // Default: left expansion (standalone mode or no direction specified)
    return isExpanded
        ? Icons.keyboard_arrow_right_rounded
        : Icons.keyboard_arrow_left_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SInkButton(
        isCircleButton: true,
        color: Colors.amber.withValues(alpha: .2),
        hoverAndSplashBorderRadius:
            BorderRadius.all(Radius.circular(widget.width)),
        onTap: (pos) => _handleTap(),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: Tween<double>(begin: 0.5, end: 0.0).animate(animation),
              child: child,
            );
          },
          child: Icon(
            _getIconData(),
            key: ValueKey(_getIconData()),
            color: widget.iconColor,
            size: widget.height * 0.7,
          ),
        ),
      ),
    );
  }
}
