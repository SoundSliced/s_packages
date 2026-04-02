/// Modal Snackbar Implementation
/// This file contains components for snackbar-style notifications
/// with swipe-to-dismiss and auto-dismiss functionality.
part of '../s_modal_libs.dart';

//************************************************ */
// Snackbar Modal Controller
//************************************************ */

/// Controller for imperatively managing snackbar animations
///
/// This controller allows external code to trigger entrance and exit
/// animations directly, rather than relying on reactive state changes.
/// Each snackbar instance should have its own unique controller.
class SnackbarModalController {
  _SnackbarModalState? _state;

  /// Attach this controller to a snackbar's internal state
  void _attach(_SnackbarModalState state) {
    // Capture a reference to the internal state for imperative control.
    _state = state;
  }

  /// Detach when the snackbar is disposed
  void _detach() {
    // Clear state reference to avoid leaks.
    _state = null;
  }

  /// Whether this controller is attached to a snackbar
  bool get isAttached => _state != null;

  /// Play the entrance animation
  void playEntranceAnimation() {
    // Forward to the snackbar state.
    _state?._playEntranceAnimation();
  }

  /// Play the dismiss animation and call the callback when complete
  void playDismissAnimation({
    String direction = '',
    VoidCallback? onComplete,
  }) {
    // Forward to the snackbar state with optional direction.
    _state?._playDismissAnimation(direction: direction, onComplete: onComplete);
  }

  /// Whether the dismiss animation is currently playing
  bool get isDismissing => _state?._isDismissAnimating ?? false;
}

//************************************************ */
// Snackbar Modal Widget
//************************************************ */

/// A modal widget specifically designed for snackbar-style notifications
///
/// Features:
/// - Swipe-to-dismiss (left/right/up/down)
/// - Auto-dismiss with optional duration
/// - Slide-in animation from bottom or top
/// - Support for stacking multiple snackbars
/// - Smooth fade animations during swipe gestures
/// - **Internal animation controllers for each snackbar instance**
class SnackbarModal extends StatefulWidget {
  /// Content to display inside the snackbar
  final Widget child;

  /// Where on screen the snackbar should be positioned
  final Alignment position;

  /// Whether the snackbar is currently being dismissed
  /// NOTE: This is now primarily used for initial state. For imperative
  /// dismiss, use the [controller]'s playDismissAnimation method instead.
  final bool isDismissing;

  /// Whether the snackbar can be swiped to dismiss
  /// Note: This is now controlled by the parent modal's isDismissable property.
  /// If isDismissable is false, the snackbar cannot be swiped regardless of this setting.
  final bool isSwipeable;

  /// Duration before auto-dismiss (null means no auto-dismiss)
  final Duration? autoDismissDuration;

  /// Absolute deadline for auto-dismiss.
  ///
  /// When provided, this takes precedence over [autoDismissDuration] so rebuilt
  /// widgets continue using the original countdown.
  final DateTime? autoDismissDeadline;

  /// Called when the snackbar is dismissed by swipe, with direction ('left' or 'right')
  final Function(String direction)? onSwipeDismiss;

  /// Stack index for staggered display (0 = front, 1+ = behind)
  final int stackIndex;

  /// Maximum snackbars to display in staggered mode
  final int maxStacked;

  /// Swipe direction for the dismiss animation ('left', 'right', or '')
  /// NOTE: This is now snackbar-specific and should not affect other snackbars
  final String swipeDirection;

  /// Width of the snackbar (default: 90% of screen width)
  final double? width;

  /// Optional offset for fine-tuned positioning
  final Offset? offset;

  /// Called when the snackbar is tapped
  /// In staggered mode, used to expand the view when a stacked snackbar is tapped
  final VoidCallback? onTap;

  /// Unique identifier for this snackbar instance
  /// Used to create unique animation keys to prevent animation conflicts
  final String? snackbarId;

  /// Controller for imperatively managing this snackbar's animations
  /// Each snackbar should have its own unique controller to avoid conflicts
  final SnackbarModalController? controller;

  /// The color of the background barrier (defaults to transparent)
  /// This barrier is displayed behind the snackbar and fades in/out with animations
  final Color barrierColor;

  /// Whether the snackbar barrier should block taps to widgets behind it.
  ///
  /// When false, the barrier remains visual only and pointer events can pass
  /// through to the underlying app content.
  final bool blockBackgroundInteraction;

  /// Creates a snackbar modal
  const SnackbarModal({
    super.key,
    required this.child,
    required this.position,
    required this.isDismissing,
    this.isSwipeable = true,
    this.autoDismissDuration,
    this.autoDismissDeadline,
    this.onSwipeDismiss,
    this.stackIndex = 0,
    this.maxStacked = 3,
    this.swipeDirection = '',
    this.width,
    this.offset,
    this.onTap,
    this.snackbarId,
    this.controller,
    this.barrierColor = Colors.transparent,
    this.blockBackgroundInteraction = false,
  });

  @override
  State<SnackbarModal> createState() => _SnackbarModalState();
}

class _SnackbarModalState extends State<SnackbarModal>
    with SingleTickerProviderStateMixin {
  static const Duration _interactionSettleDuration =
      Duration(milliseconds: 200);

  /// Internal animation controller for entrance and exit animations
  /// This controller is owned by this snackbar instance, ensuring
  /// animations don't conflict with other snackbars
  late AnimationController _animationController;

  /// Animation for entrance/exit effects (fade + slide)
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  /// Current animation direction (entrance or dismiss)
  bool _isDismissAnimating = false;

  /// Current vertical swipe offset (for vertical dismiss only)
  double _verticalSwipeOffset = 0.0;

  /// Current horizontal swipe offset (tracked for smooth opacity fade)
  double _horizontalSwipeOffset = 0.0;

  /// Timer for auto-dismiss (can be cancelled)
  Timer? _autoDismissTimer;

  /// Timer used to restart auto-dismiss after a drag interaction settles
  Timer? _autoDismissResumeTimer;

  /// Generation counter for timer callbacks
  /// Incremented each time the timer is restarted to invalidate old callbacks
  int _timerGeneration = 0;

  /// Whether the user is currently swiping vertically
  bool _isSwipingVertically = false;

  /// Whether the user is currently swiping horizontally
  bool _isSwipingHorizontally = false;

  /// Threshold to trigger vertical dismiss (percentage of height)
  /// Lower than horizontal because vertical drag space is limited near edges
  static const double _verticalDismissThreshold = 0.05;

  /// Threshold to trigger horizontal dismiss (percentage of width)
  static const double _horizontalDismissThreshold = 0.25;

  /// Local swipe direction for this snackbar's dismiss animation
  /// This prevents animation conflicts between different snackbars
  String _localSwipeDirection = '';

  /// Whether this snackbar is being dismissed (local state)
  /// This is used to prevent re-entry and ensure clean animations
  bool _isLocallyDismissing = false;

  /// Flag to track if this widget has been disposed
  /// Used to prevent operations after disposal
  bool _isDisposed = false;

  /// Internal controller for this snackbar's animations
  /// Created in initState and registered in the global registry
  late SnackbarModalController _internalController;

  @override
  void initState() {
    // Initialize animation controller and register controller.
    super.initState();

    // Initialize the animation controller for this snackbar instance
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Set up entrance animations (will be updated for dismiss)
    _setupEntranceAnimations();

    // Create and register internal controller
    // This allows Modal.dismissById to find and call our dismiss animation
    _internalController = SnackbarModalController();
    _internalController._attach(this);

    // Register in global registry so dismiss methods can find us
    if (widget.snackbarId != null) {
      // Register for id-based dismissal.
      // debugPrint(
      //     '[snackbar_debug] SnackbarModal.initState: registering controller for id=${widget.snackbarId}');
      _registerSnackbarController(widget.snackbarId!, _internalController);
    }

    // Also attach external controller if provided
    widget.controller?._attach(this);

    // If not already dismissing, play entrance animation
    if (!widget.isDismissing) {
      // Play entry animation on initial show.
      _playEntranceAnimation();
    }

    _startAutoDismissTimer();
  }

  /// Set up entrance animation curves and values
  void _setupEntranceAnimations() {
    // Configure fade and slide-in animations.
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    final slideBegin = Offset(0, _isFromTop ? -0.5 : 0.5);
    _slideAnimation =
        Tween<Offset>(begin: slideBegin, end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  /// Set up dismiss animation curves and values
  void _setupDismissAnimations(String direction) {
    // Configure fade and slide-out animations.
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    final slideEnd = _getSlideEndOffset(direction);
    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: slideEnd).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInQuad,
      ),
    );
  }

  /// Get the slide end offset based on dismiss direction
  Offset _getSlideEndOffset(String direction) {
    // Choose slide-out direction based on swipe or position.
    switch (direction) {
      case 'left':
        return const Offset(-0.5, 0);
      case 'right':
        return const Offset(0.5, 0);
      case 'up':
        return const Offset(0, -0.5);
      case 'down':
        return const Offset(0, 0.5);
      default:
        // Default based on position
        return Offset(0, _isFromTop ? -0.4 : 0.4);
    }
  }

  /// Play the entrance animation
  void _playEntranceAnimation() {
    // Reset to entrance curves and play forward.
    if (!mounted || _isDisposed) return;
    _isDismissAnimating = false;
    _setupEntranceAnimations();
    _animationController.forward(from: 0.0);
  }

  /// Play the dismiss animation
  void _playDismissAnimation({
    String direction = '',
    VoidCallback? onComplete,
  }) {
    // Run dismiss animation once, then call completion callback.
    if (!mounted || _isDisposed || _isDismissAnimating) return;

    _isDismissAnimating = true;
    _isLocallyDismissing = true;
    _autoDismissTimer?.cancel();
    _autoDismissResumeTimer?.cancel();

    // Set up dismiss animations from current state
    _setupDismissAnimations(direction);

    // Reset and play forward for dismiss
    _animationController.forward(from: 0.0).then((_) {
      // Use _isDisposed (set at start of dispose()) rather than mounted.
      // mounted can be briefly false during temporary deactivate/activate cycles
      // (overlay rearrange, GlobalKey reparenting) even while the widget is still
      // logically alive. _isDisposed is only set true when permanently removed.
      onComplete?.call();
    }).catchError((error) {
      // Silently catch TickerCanceled or other errors from disposal mid-animation.
      // Still fire onComplete so the Completer in dismissById doesn't hang forever
      // and the queue entry gets cleaned up even if the widget was disposed.
      onComplete?.call();
    });
  }

  /// Start or restart the auto-dismiss timer
  void _startAutoDismissTimer() {
    // Start or restart the auto-dismiss timer safely.
    // Cancel any existing timer and increment generation to invalidate old callbacks
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    _timerGeneration++;
    final currentGeneration = _timerGeneration;

    // Resolve effective remaining time.
    Duration? remainingDuration;
    if (widget.autoDismissDeadline != null) {
      remainingDuration =
          widget.autoDismissDeadline!.difference(DateTime.now());
      if (remainingDuration.isNegative) {
        remainingDuration = Duration.zero;
      }
    } else {
      remainingDuration = widget.autoDismissDuration;
    }

    // Only start timer if we have remaining duration and not already dismissing
    if (remainingDuration != null &&
        !widget.isDismissing &&
        !_isDismissAnimating) {
      _autoDismissTimer = Timer(remainingDuration, () {
        // Ignore stale timer callbacks.
        // Guard: Check if this callback is still valid (generation matches)
        // This prevents stale callbacks from firing after the timer was restarted
        if (_timerGeneration != currentGeneration || _isDisposed) {
          return;
        }

        // Double-check mounted status before calling callback
        if (mounted &&
            !_isDisposed &&
            !widget.isDismissing &&
            !_isDismissAnimating) {
          // If a global dismissal is happening, delay to avoid conflicts.
          // Guard: If a global dismissal is in progress (e.g. bottom sheet closing),
          // defer the auto-dismiss to avoid state conflicts and visual glitches.
          if (Modal.isDismissing) {
            // Retry after a short delay (enough for dismissal to complete)
            _autoDismissTimer = Timer(const Duration(milliseconds: 500), () {
              // Retry after a short delay.
              if (_timerGeneration != currentGeneration || _isDisposed) return;
              if (mounted &&
                  !_isDisposed &&
                  !widget.isDismissing &&
                  !_isDismissAnimating) {
                _autoDismissTimer = null;
                // Play dismiss animation FIRST, then notify parent when complete
                _playDismissAnimation(
                  direction: '', // Auto-dismiss uses default direction
                  onComplete: () {
                    widget.onSwipeDismiss?.call('');
                  },
                );
              }
            });
            return;
          }

          // Cancel the timer reference since it has fired
          _autoDismissTimer = null;
          // Play dismiss animation FIRST, then notify parent when complete
          // Empty direction means auto-dismiss (default slide direction based on position)
          _playDismissAnimation(
            direction: '', // Auto-dismiss uses default direction
            onComplete: () {
              widget.onSwipeDismiss?.call('');
            },
          );
        }
      });
    }
  }

  /// Pauses auto-dismiss while the user is interacting with the snackbar.
  void _pauseAutoDismissTimerForInteraction() {
    // Pause auto-dismiss during user interaction.
    _autoDismissTimer?.cancel();
    _autoDismissResumeTimer?.cancel();
    _autoDismissResumeTimer = null;
  }

  /// Restarts auto-dismiss after a drag interaction has settled back.
  void _scheduleAutoDismissTimerRestartAfterInteraction() {
    // Resume auto-dismiss after a short settle delay.
    final hasAutoDismiss = widget.autoDismissDuration != null ||
        widget.autoDismissDeadline != null;

    if (!hasAutoDismiss ||
        widget.isDismissing ||
        _isDismissAnimating ||
        _isLocallyDismissing) {
      return;
    }

    _autoDismissResumeTimer?.cancel();
    _autoDismissResumeTimer = Timer(_interactionSettleDuration, () {
      // Restart only if still valid.
      if (!mounted ||
          _isDisposed ||
          widget.isDismissing ||
          _isDismissAnimating ||
          _isLocallyDismissing) {
        return;
      }
      _startAutoDismissTimer();
    });
  }

  @override
  void didUpdateWidget(SnackbarModal oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restart timers only when relevant inputs change.
    // Only restart timer if dismissing state or duration actually changed.
    // Don't restart on every rebuild - widget.child reference may change even
    // if the content is identical, causing unnecessary timer restarts.
    if (oldWidget.isDismissing != widget.isDismissing ||
        oldWidget.autoDismissDuration != widget.autoDismissDuration ||
        oldWidget.autoDismissDeadline != widget.autoDismissDeadline) {
      if (widget.isDismissing) {
        _autoDismissTimer?.cancel();
        _autoDismissTimer = null;
      } else {
        _startAutoDismissTimer();
      }
    }

    // Coalesce local swipe-state resets into a single setState.
    final shouldResetSwipeState =
        (!widget.isSwipeable && oldWidget.isSwipeable) ||
            (widget.position != oldWidget.position);

    if (shouldResetSwipeState) {
      // Reset swipe offsets/flags on config change.
      setState(() {
        _verticalSwipeOffset = 0.0;
        _horizontalSwipeOffset = 0.0;
        _isSwipingVertically = false;
        _isSwipingHorizontally = false;
        if (widget.position != oldWidget.position) {
          _localSwipeDirection = '';
        }
      });
    }
  }

  @override
  void deactivate() {
    // NOTE: Do NOT stop the animation controller here. deactivate() is called
    // during temporary tree removals (e.g. overlay rearrange, GlobalKey moves)
    // and stopping the animation would kill an in-progress dismiss animation,
    // preventing its onComplete callback from ever firing.
    // Animation cleanup happens in dispose(), which is called only on permanent removal.
    super.deactivate();
  }

  @override
  void dispose() {
    // Dispose timers, controllers, and registry entries.
    // Set disposed flag first to prevent any operations after disposal
    _isDisposed = true;

    // debugPrint(
    // 'SnackbarModal.dispose: key=${widget.key}, id=${widget.snackbarId}');

    // Cancel any pending timer first
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    _autoDismissResumeTimer?.cancel();
    _autoDismissResumeTimer = null;

    // Unregister from global controller registry
    if (widget.snackbarId != null) {
      // Remove from global controller registry.
      // debugPrint(
      //     '[snackbar_debug] SnackbarModal.dispose: unregistering controller for id=${widget.snackbarId}');
      _unregisterSnackbarController(widget.snackbarId!);
    }

    // Detach internal controller BEFORE disposing animation controller
    _internalController._detach();

    // Detach external controller if provided
    widget.controller?._detach();

    // CRITICAL: Properly clean up animation controller to prevent frame callbacks
    // after disposal. This prevents the "Trying to render a disposed EngineFlutterView" error.
    //
    // The issue occurs when:
    // 1. Animation controller schedules a frame callback
    // 2. Widget is removed from tree and dispose() is called
    // 3. Frame callback fires and tries to render the disposed view
    //
    // Solution: Ensure the controller is in a stable state before disposing
    try {
      // Ensure controller isn't animating before disposal.
      // Stop any active animation immediately (should already be stopped in deactivate)
      if (_animationController.isAnimating) {
        _animationController.stop(canceled: true);
      }
      // Reset clears any scheduled frame callbacks
      _animationController.reset();
      // Now safe to dispose
      _animationController.dispose();
    } catch (e) {
      // Ignore disposal errors (already disposed).
      // Catch any errors during disposal (e.g., if already disposed)
      // debugPrint(
      // 'SnackbarModal.dispose: Error disposing animation controller: $e');
    }

    super.dispose();
  }

  /// Called when a horizontal swipe starts.
  void _onHorizontalDragStart(DragStartDetails details) {
    // Begin horizontal swipe gesture.
    if (!widget.isSwipeable || _isLocallyDismissing) return;
    setState(() {
      _isSwipingHorizontally = true;
    });
    _pauseAutoDismissTimerForInteraction();
  }

  /// Called while a horizontal swipe is in progress.
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    // Update horizontal swipe offset and pause auto-dismiss.
    if (!widget.isSwipeable || _isLocallyDismissing) return;

    final dragDelta = details.primaryDelta ?? details.delta.dx;

    setState(() {
      _isSwipingHorizontally = true;
      _horizontalSwipeOffset += dragDelta;
    });

    _pauseAutoDismissTimerForInteraction();
  }

  /// Called when a horizontal swipe ends.
  void _onHorizontalDragEnd(DragEndDetails details) {
    // Decide whether to dismiss based on swipe distance/velocity.
    if (!widget.isSwipeable || _isLocallyDismissing) return;

    final screenWidth = max(_modalViewportSizeOf(context).width, 1.0);
    final swipePercent = _horizontalSwipeOffset.abs() / screenWidth;
    final velocity = details.primaryVelocity ?? 0.0;
    final shouldDismiss =
        swipePercent > _horizontalDismissThreshold || velocity.abs() > 700.0;

    if (shouldDismiss) {
      // Dismiss immediately in the swipe direction.
      _isLocallyDismissing = true;
      _isDismissAnimating = true;
      _autoDismissTimer?.cancel();
      _autoDismissResumeTimer?.cancel();

      _localSwipeDirection = _horizontalSwipeOffset < 0 ? 'left' : 'right';

      setState(() {
        _isSwipingHorizontally = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSwipeDismiss?.call('dismiss_immediate');
      });
    } else {
      // Snap back and resume auto-dismiss.
      setState(() {
        _horizontalSwipeOffset = 0.0;
        _isSwipingHorizontally = false;
      });
      _scheduleAutoDismissTimerRestartAfterInteraction();
    }
  }

  /// Called if the horizontal swipe gesture is canceled.
  void _onHorizontalDragCancel() {
    // Reset swipe state on cancel.
    if (!widget.isSwipeable || _isLocallyDismissing) return;
    setState(() {
      _horizontalSwipeOffset = 0.0;
      _isSwipingHorizontally = false;
    });
    _scheduleAutoDismissTimerRestartAfterInteraction();
  }

  void _onVerticalDragStart(DragStartDetails details) {
    // Begin vertical swipe gesture.
    if (!widget.isSwipeable || _isLocallyDismissing) return;
    setState(() {
      _isSwipingVertically = true;
    });
    // Pause auto-dismiss while swiping
    _pauseAutoDismissTimerForInteraction();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    // Update vertical offset for allowed swipe direction.
    if (!widget.isSwipeable || _isLocallyDismissing) return;

    // Only allow drag in the allowed direction based on position
    final isTopPosition = _isFromTop;
    final dragDelta = details.delta.dy;

    // Top positions: only allow upward (negative) drag
    // Bottom positions: only allow downward (positive) drag
    if ((isTopPosition && dragDelta < 0) || (!isTopPosition && dragDelta > 0)) {
      setState(() {
        _verticalSwipeOffset += dragDelta;
      });
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    // Decide dismiss vs snap-back for vertical swipes.
    if (!widget.isSwipeable || _isLocallyDismissing) return;

    final screenHeight = max(_modalViewportSizeOf(context).height, 1.0);
    final swipePercent = _verticalSwipeOffset.abs() / screenHeight;

    if (swipePercent > _verticalDismissThreshold) {
      // Dismiss immediately without snapping back.
      // Mark as locally dismissing to prevent re-entry
      _isLocallyDismissing = true;
      _autoDismissTimer?.cancel();

      // Set local direction for this snackbar's animation
      _localSwipeDirection = _verticalSwipeOffset < 0 ? 'up' : 'down';

      // DON'T reset _verticalSwipeOffset here - keep the snackbar at its
      // current dragged position until the widget is removed from the tree.
      // This prevents the visual "snap back" glitch.
      setState(() {
        _isSwipingVertically = false;
      });

      // Defer dismissal to next frame to avoid "disposed view" error
      // Use 'dismiss_immediate' to skip the parent's SlideEffect animation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSwipeDismiss?.call('dismiss_immediate');
      });
    } else {
      // Snap back and resume auto-dismiss.
      // Snap back
      setState(() {
        _verticalSwipeOffset = 0.0;
        _isSwipingVertically = false;
      });
      // Resume auto-dismiss
      _scheduleAutoDismissTimerRestartAfterInteraction();
    }
  }

  void _onVerticalDragCancel() {
    // Reset vertical swipe state on cancel.
    if (!widget.isSwipeable || _isLocallyDismissing) return;
    setState(() {
      _verticalSwipeOffset = 0.0;
      _isSwipingVertically = false;
    });
    _scheduleAutoDismissTimerRestartAfterInteraction();
  }

  /// Whether the snackbar appears from the top
  bool get _isFromTop =>
      widget.position == Alignment.topCenter ||
      widget.position == Alignment.topLeft ||
      widget.position == Alignment.topRight;

  @override
  Widget build(BuildContext context) {
    // Build snackbar content with stagger offsets and gesture handling.
    // Calculate stagger offset (each snackbar behind shifts up/down and scales)
    final double staggerVerticalOffset = widget.stackIndex * 12.0;
    final double staggerScale = 1.0 - (widget.stackIndex * 0.05);

    // Determine vertical padding based on position
    // When offset is provided, we still need to apply stagger offset via Transform
    final edgePadding = widget.offset != null
        ? EdgeInsets.zero
        : EdgeInsets.only(
            top: _isFromTop ? 24.0 + staggerVerticalOffset : 0,
            bottom: !_isFromTop ? 24.0 + staggerVerticalOffset : 0,
            left: 16.0,
            right: 16.0,
          );

    // Calculate stagger translation for offset-based positioning
    // When offset is used, we apply stagger via Transform.translate instead of padding
    final staggerTranslation = widget.offset != null
        ? Offset(0, _isFromTop ? staggerVerticalOffset : -staggerVerticalOffset)
        : Offset.zero;

    Widget snackbarContent = AnimatedPadding(
      duration: 400.ms,
      curve: Curves.easeOutCubic,
      padding: edgePadding,
      child: AnimatedScale(
        duration: 400.ms,
        curve: Curves.easeOutCubic,
        scale: staggerScale,
        alignment: _isFromTop ? Alignment.topCenter : Alignment.bottomCenter,
        child: widget.child,
      ),
    );

    // Apply stagger translation when using offset-based positioning
    if (widget.offset != null && staggerTranslation != Offset.zero) {
      // Apply stagger translation when offset-based positioning is used.
      snackbarContent = STweenAnimationBuilder<Offset>(
        tween:
            Tween<Offset>(begin: staggerTranslation, end: staggerTranslation),
        duration: 400.ms,
        curve: Curves.easeOutCubic,
        builder: (context, offset, child) {
          return Transform.translate(
            offset: offset,
            child: child,
          );
        },
        child: snackbarContent,
      );
    }

    // Wrap with gesture handling for horizontal and vertical swipe-to-dismiss.
    if (widget.isSwipeable && !_isLocallyDismissing) {
      // Wire swipe gesture handlers and apply opacity based on drag.
      // Calculate opacity based on swipe progress (both vertical and horizontal)
      final viewportSize = _modalViewportSizeOf(context);
      final screenHeight = max(viewportSize.height, 1.0);
      final screenWidth = max(viewportSize.width, 1.0);

      // Vertical swipe opacity
      final verticalSwipeOpacity = _isSwipingVertically
          ? (1.0 -
                  (_verticalSwipeOffset.abs() / screenHeight * 2)
                      .clamp(0.0, 0.6))
              .clamp(0.4, 1.0)
          : 1.0;

      // Horizontal swipe opacity
      final horizontalSwipeOpacity = _isSwipingHorizontally
          ? (1.0 -
                  (_horizontalSwipeOffset.abs() / screenWidth * 1.5)
                      .clamp(0.0, 0.6))
              .clamp(0.4, 1.0)
          : 1.0;

      // Combined opacity (use minimum for smooth fade during any swipe)
      final combinedOpacity =
          (verticalSwipeOpacity * horizontalSwipeOpacity).clamp(0.4, 1.0);

      // Wrap content with vertical gesture detection first
      Widget verticalSwipeWrapper = GestureDetector(
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        onVerticalDragCancel: _onVerticalDragCancel,
        child: Transform.translate(
          offset: Offset(0, _verticalSwipeOffset),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 50),
            opacity: combinedOpacity,
            child: snackbarContent,
          ),
        ),
      );

      // Wrap with a horizontal drag detector so swipe-abort recovery is owned
      // by this widget instead of depending on Dismissible internals.
      snackbarContent = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        onHorizontalDragCancel: _onHorizontalDragCancel,
        child: Transform.translate(
          offset: Offset(_horizontalSwipeOffset, 0),
          child: verticalSwipeWrapper,
        ),
      );
    } else if (_isLocallyDismissing) {
      // Show a dimmed, non-interactive snackbar while dismissing.
      // When locally dismissing, show content with current transform but no gestures
      snackbarContent = Transform.translate(
        offset: Offset(0, _verticalSwipeOffset),
        child: Opacity(
          opacity: 0.4,
          child: snackbarContent,
        ),
      );
    }

    // Wrap with tap handler if onTap is provided
    if (widget.onTap != null) {
      // Optional tap handler (e.g., expand stacked view).
      snackbarContent = GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: snackbarContent,
      );
    }

    // Calculate max width
    double maxWidth;
    if (widget.width != null) {
      // Explicit width override.
      maxWidth = widget.width!;
    } else {
      final screenWidth = _modalViewportSizeOf(context).width;
      final isDesktop = screenWidth > 600; // Breakpoint for tablet/desktop

      if (isDesktop) {
        // Desktop/Tablet: Fixed width or small percentage
        // Using 400px as a reasonable max width for snackbars on large screens
        maxWidth = 400.0;
        // Ensure it doesn't exceed screen width (unlikely but safe)
        if (maxWidth > screenWidth * 0.9) {
          maxWidth = screenWidth * 0.9;
        }
      } else {
        // Mobile
        final isCenter = widget.position == Alignment.topCenter ||
            widget.position == Alignment.bottomCenter ||
            widget.position == Alignment.center;

        if (isCenter) {
          maxWidth = screenWidth * 0.9;
        } else {
          // Corners and sides
          maxWidth = screenWidth * 0.6; // Smaller width
        }
      }
    }

    // Check if this is an immediate dismiss (from Dismissible horizontal swipe or vertical swipe)
    // In that case, the widget has already been animated off-screen visually
    final isImmediateDismiss = widget.swipeDirection == 'dismiss_immediate' ||
        _localSwipeDirection.isNotEmpty;

    // Apply animation to the snackbar content BEFORE positioning
    // This ensures Positioned/Align is a direct child of Stack for proper positioning
    // Uses the internal animation controller for each snackbar instance
    Widget animatedContent;
    if (isImmediateDismiss) {
      // Skip animations when dismissed via immediate swipe.
      // For immediate dismiss, show content with zero opacity
      animatedContent = Opacity(
        opacity: 0.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: snackbarContent,
        ),
      );
    } else {
      // AnimatedBuilder ties fade/slide to the internal controller.
      // Use AnimatedBuilder with internal animation controller
      // This ensures each snackbar has its own independent animation
      animatedContent = AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: child,
            ),
          );
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: snackbarContent,
        ),
      );
    }

    // Position the snackbar: use absolute positioning if offset provided, otherwise use alignment
    // CRITICAL: The Positioned/Align wrapper must be OUTSIDE the animation to work correctly
    // as a direct child of the parent Stack
    Widget positionedSnackbar;
    if (widget.offset != null) {
      // Absolute positioning via offset.
      // Absolute positioning from top-left corner (ignores position/alignment)
      positionedSnackbar = Positioned(
        left: widget.offset!.dx,
        top: widget.offset!.dy,
        child: animatedContent,
      );
    } else {
      // Alignment-based positioning.
      // Use Align instead of Positioned.fill so that each snackbar only takes up
      // as much space as needed, allowing taps to pass through to snackbars behind
      positionedSnackbar = Align(
        alignment: widget.position,
        child: animatedContent,
      );
    }

    // Wrap with animated barrier color if provided and not transparent
    final shouldCaptureBarrierTaps = _shouldCaptureModalBarrierTaps(
      isDismissable: widget.isSwipeable,
      blockBackgroundInteraction: widget.blockBackgroundInteraction,
    );

    if (widget.barrierColor != Colors.transparent) {
      // Build an animated barrier behind the snackbar.
      return Stack(
        fit: StackFit.expand,
        children: [
          // Animated barrier color layer
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              // Compute barrier opacity based on current animation state.
              // Sync barrier fade-in with snackbar entrance animation.
              // Keep dismiss fade-out behavior tied to dismiss animation.
              final barrierOpacity = _isDismissAnimating
                  ? (_fadeAnimation.value * widget.barrierColor.a)
                  : (Curves.easeOutCubic.transform(
                          _animationController.value.clamp(0.0, 1.0)) *
                      widget.barrierColor.a);
              final barrierChild = _buildModalBarrierSurface(
                widget.barrierColor,
                barrierOpacity,
              );

              if (!shouldCaptureBarrierTaps) {
                // Barrier is visual-only; allow taps to pass through.
                return IgnorePointer(
                  ignoring: true,
                  child: barrierChild,
                );
              }

              return SInkButton(
                scaleFactor: 1,
                color: widget.barrierColor.darken(0.2),
                child: barrierChild,
              );
            },
          ),
          // Snackbar on top of barrier
          positionedSnackbar,
        ],
      );
    }

    return positionedSnackbar;
  }
}

//************************************************ */
// Snackbar Duration Indicator
//************************************************ */

/// A widget that displays a linear progress indicator showing remaining duration
///
/// This is displayed at the bottom of a snackbar when [showDurationTimer] is true
/// and the snackbar has a finite duration. The progress bar animates from full
/// width to zero as time elapses.
class SnackbarDurationIndicator extends StatefulWidget {
  /// The total duration of the snackbar
  final Duration duration;

  /// Absolute deadline when the snackbar should auto-dismiss.
  ///
  /// When provided, the indicator resumes from the correct remaining progress
  /// on rebuild/remount instead of restarting from full duration.
  final DateTime? deadline;

  /// The height of the progress indicator
  final double height;

  /// The color of the progress indicator
  final Color? color;

  /// The background color of the progress track
  final Color? backgroundColor;

  /// Border radius to match the snackbar's corners
  final BorderRadius? borderRadius;

  /// Direction of the progress animation
  /// leftToRight: bar shrinks from right (remaining time on left)
  /// rightToLeft: bar shrinks from left (remaining time on right)
  final DurationIndicatorDirection direction;

  const SnackbarDurationIndicator({
    super.key,
    required this.duration,
    this.deadline,
    this.height = 3.0,
    this.color,
    this.backgroundColor,
    this.borderRadius,
    this.direction = DurationIndicatorDirection.leftToRight,
  });

  @override
  State<SnackbarDurationIndicator> createState() =>
      _SnackbarDurationIndicatorState();
}

class _SnackbarDurationIndicatorState extends State<SnackbarDurationIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  void _syncControllerWithDurationAndDeadline() {
    _controller.duration = widget.duration;

    if (widget.duration.inMilliseconds <= 0) {
      _controller.value = 1.0;
      return;
    }

    final deadline = widget.deadline;
    if (deadline == null) {
      _controller.value = 0.0;
      _controller.forward(from: 0.0);
      return;
    }

    final totalMs = widget.duration.inMilliseconds;
    final remainingMs = deadline.difference(DateTime.now()).inMilliseconds;
    final clampedRemainingMs = remainingMs.clamp(0, totalMs);
    final elapsedFraction =
        ((totalMs - clampedRemainingMs) / totalMs).clamp(0.0, 1.0);

    _controller.value = elapsedFraction;

    if (clampedRemainingMs > 0) {
      _controller.animateTo(
        1.0,
        duration: Duration(milliseconds: clampedRemainingMs),
        curve: Curves.linear,
      );
    }
  }

  @override
  void initState() {
    // Create controller and start progress animation.
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _syncControllerWithDurationAndDeadline();
  }

  @override
  void didUpdateWidget(SnackbarDurationIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-sync when timing inputs change.
    if (oldWidget.duration != widget.duration ||
        oldWidget.deadline != widget.deadline) {
      _syncControllerWithDurationAndDeadline();
    }
  }

  @override
  void dispose() {
    // Dispose controller on teardown.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Render a linear progress bar that shrinks over time.
    final effectiveColor = widget.color ?? Colors.white.withValues(alpha: 0.7);
    final effectiveBgColor =
        widget.backgroundColor ?? Colors.white.withValues(alpha: 0.2);
    final effectiveBorderRadius = widget.borderRadius ??
        const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        );

    // Determine alignment based on direction
    final alignment = widget.direction == DurationIndicatorDirection.leftToRight
        ? Alignment.centerLeft
        : Alignment.centerRight;

    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: SizedBox(
        height: widget.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Progress goes from 1.0 -> 0.0 as time elapses.
            // Progress goes from 1.0 (full) to 0.0 (empty) as time elapses
            final progress = 1.0 - _controller.value;
            return Stack(
              children: [
                // Background track
                Container(
                  width: double.infinity,
                  height: widget.height,
                  color: effectiveBgColor,
                ),
                // Progress bar - aligned based on direction
                Align(
                  alignment: alignment,
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: widget.height,
                      color: effectiveColor,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
