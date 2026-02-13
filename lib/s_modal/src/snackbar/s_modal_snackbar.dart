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
    _state = state;
  }

  /// Detach when the snackbar is disposed
  void _detach() {
    _state = null;
  }

  /// Whether this controller is attached to a snackbar
  bool get isAttached => _state != null;

  /// Play the entrance animation
  void playEntranceAnimation() {
    _state?._playEntranceAnimation();
  }

  /// Play the dismiss animation and call the callback when complete
  void playDismissAnimation({
    String direction = '',
    VoidCallback? onComplete,
  }) {
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

  /// Creates a snackbar modal
  const SnackbarModal({
    super.key,
    required this.child,
    required this.position,
    required this.isDismissing,
    this.isSwipeable = true,
    this.autoDismissDuration,
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
  });

  @override
  State<SnackbarModal> createState() => _SnackbarModalState();
}

class _SnackbarModalState extends State<SnackbarModal>
    with SingleTickerProviderStateMixin {
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

  /// Generation counter for timer callbacks
  /// Incremented each time the timer is restarted to invalidate old callbacks
  int _timerGeneration = 0;

  /// Whether the user is currently swiping vertically
  bool _isSwipingVertically = false;

  /// Whether the user is currently swiping horizontally (via Dismissible)
  bool _isSwipingHorizontally = false;

  /// Threshold to trigger vertical dismiss (percentage of height)
  /// Lower than horizontal because vertical drag space is limited near edges
  static const double _verticalDismissThreshold = 0.05;

  /// Unique key for Dismissible widget
  /// Uses snackbarId to ensure unique keys per snackbar instance
  late Key _dismissibleKey;

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
    super.initState();

    // Initialize the animation controller for this snackbar instance
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Set up entrance animations (will be updated for dismiss)
    _setupEntranceAnimations();

    // Create and register internal controller
    // This allows Modal.dismissById to find and call our dismiss animation
    _internalController = SnackbarModalController();
    _internalController._attach(this);

    // Register in global registry so dismiss methods can find us
    if (widget.snackbarId != null) {
      _registerSnackbarController(widget.snackbarId!, _internalController);
    }

    // Also attach external controller if provided
    widget.controller?._attach(this);

    // Use snackbarId if available for stable key, otherwise generate unique key
    _dismissibleKey = widget.snackbarId != null
        ? ValueKey('dismissible_${widget.snackbarId}')
        : UniqueKey();

    // If not already dismissing, play entrance animation
    if (!widget.isDismissing) {
      _playEntranceAnimation();
    }

    _startAutoDismissTimer();
  }

  /// Set up entrance animation curves and values
  void _setupEntranceAnimations() {
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
    if (!mounted || _isDisposed || _isDismissAnimating) return;

    _isDismissAnimating = true;
    _isLocallyDismissing = true;
    _autoDismissTimer?.cancel();

    // Set up dismiss animations from current state
    _setupDismissAnimations(direction);

    // Reset and play forward for dismiss
    _animationController.forward(from: 0.0).then((_) {
      // CRITICAL: Guard against calling completion callback after disposal
      // This prevents "disposed view" errors when the callback tries to rebuild
      if (mounted && !_isDisposed) {
        onComplete?.call();
      }
    }).catchError((error) {
      // Silently catch any errors from the animation completing after disposal
      // This is expected behavior when the widget is removed during animation
      // debugPrint('SnackbarModal: Animation error (likely disposed): $error');
    });
  }

  /// Start or restart the auto-dismiss timer
  void _startAutoDismissTimer() {
    // Cancel any existing timer and increment generation to invalidate old callbacks
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    _timerGeneration++;
    final currentGeneration = _timerGeneration;

    // Only start timer if we have a duration and not already dismissing
    if (widget.autoDismissDuration != null &&
        !widget.isDismissing &&
        !_isDismissAnimating) {
      _autoDismissTimer = Timer(widget.autoDismissDuration!, () {
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
          // Guard: If a global dismissal is in progress (e.g. bottom sheet closing),
          // defer the auto-dismiss to avoid state conflicts and visual glitches.
          if (Modal.isDismissing) {
            // Retry after a short delay (enough for dismissal to complete)
            _autoDismissTimer = Timer(const Duration(milliseconds: 500), () {
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

  @override
  void didUpdateWidget(SnackbarModal oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only restart timer if dismissing state or duration actually changed.
    // Don't restart on every rebuild - widget.child reference may change even
    // if the content is identical, causing unnecessary timer restarts.
    if (oldWidget.isDismissing != widget.isDismissing ||
        oldWidget.autoDismissDuration != widget.autoDismissDuration) {
      if (widget.isDismissing) {
        _autoDismissTimer?.cancel();
        _autoDismissTimer = null;
      } else {
        _startAutoDismissTimer();
      }
    }

    // Reset swipe offset when isSwipeable is disabled
    // This ensures the snackbar snaps back to its base position
    if (!widget.isSwipeable && oldWidget.isSwipeable) {
      setState(() {
        _verticalSwipeOffset = 0.0;
        _horizontalSwipeOffset = 0.0;
        _isSwipingVertically = false;
        _isSwipingHorizontally = false;
      });
    }

    // Reset swipe offset when position changes
    // This ensures the snackbar appears cleanly at the new position
    if (widget.position != oldWidget.position) {
      setState(() {
        _verticalSwipeOffset = 0.0;
        _horizontalSwipeOffset = 0.0;
        _isSwipingVertically = false;
        _isSwipingHorizontally = false;
        _localSwipeDirection = '';
      });
    }

    // Update dismissible key if snackbarId changes
    if (widget.snackbarId != oldWidget.snackbarId &&
        widget.snackbarId != null) {
      _dismissibleKey = ValueKey('dismissible_${widget.snackbarId}');
    }
  }

  @override
  void deactivate() {
    // CRITICAL: When the widget is being removed from the tree, cancel any
    // pending animations immediately to prevent frame callbacks from firing
    // after the widget is deactivated. This prevents the "disposed view" error.
    if (_animationController.isAnimating) {
      _animationController.stop(canceled: true);
    }
    super.deactivate();
  }

  @override
  void dispose() {
    // Set disposed flag first to prevent any operations after disposal
    _isDisposed = true;

    // debugPrint(
    // 'SnackbarModal.dispose: key=${widget.key}, id=${widget.snackbarId}');

    // Cancel any pending timer first
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;

    // Unregister from global controller registry
    if (widget.snackbarId != null) {
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
      // Stop any active animation immediately (should already be stopped in deactivate)
      if (_animationController.isAnimating) {
        _animationController.stop(canceled: true);
      }
      // Reset clears any scheduled frame callbacks
      _animationController.reset();
      // Now safe to dispose
      _animationController.dispose();
    } catch (e) {
      // Catch any errors during disposal (e.g., if already disposed)
      // debugPrint(
      // 'SnackbarModal.dispose: Error disposing animation controller: $e');
    }

    super.dispose();
  }

  /// Called when swipe-to-dismiss completes via Dismissible
  /// For horizontal swipes, Dismissible already animated the exit,
  /// so we pass 'dismiss_immediate' to skip the parent's SlideEffect animation.
  void _onDismissed(DismissDirection direction) {
    if (_isLocallyDismissing || _isDismissAnimating) return; // Prevent re-entry
    _isLocallyDismissing = true;
    _isDismissAnimating = true;
    _autoDismissTimer?.cancel();

    // Set local direction for this snackbar's animation
    _localSwipeDirection =
        direction == DismissDirection.startToEnd ? 'left' : 'right';

    // Use special marker to tell parent to skip dismiss animation
    // since Dismissible already handled the visual exit
    widget.onSwipeDismiss?.call('dismiss_immediate');
  }

  /// Called when Dismissible is being dragged - pause auto-dismiss and track offset
  void _onDismissibleUpdate(DismissUpdateDetails details) {
    if (details.reached) return; // Already past threshold

    // Track horizontal swipe state for opacity animation
    setState(() {
      _isSwipingHorizontally = details.progress > 0;
      // Approximate horizontal offset based on progress
      // Progress is 0-1, so multiply by screen width for offset
      final screenWidth = MediaQuery.of(context).size.width;
      _horizontalSwipeOffset = details.progress *
          screenWidth *
          (details.direction == DismissDirection.startToEnd ? 1 : -1);
    });

    // Pause timer while dragging
    _autoDismissTimer?.cancel();
  }

  void _onVerticalDragStart(DragStartDetails details) {
    if (!widget.isSwipeable || _isLocallyDismissing) return;
    setState(() {
      _isSwipingVertically = true;
    });
    // Pause auto-dismiss while swiping
    _autoDismissTimer?.cancel();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
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
    if (!widget.isSwipeable || _isLocallyDismissing) return;

    final screenHeight = MediaQuery.of(context).size.height;
    final swipePercent = _verticalSwipeOffset.abs() / screenHeight;

    if (swipePercent > _verticalDismissThreshold) {
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
      // Snap back
      setState(() {
        _verticalSwipeOffset = 0.0;
        _isSwipingVertically = false;
      });
      // Resume auto-dismiss
      _startAutoDismissTimer();
    }
  }

  void _onVerticalDragCancel() {
    if (!widget.isSwipeable || _isLocallyDismissing) return;
    setState(() {
      _verticalSwipeOffset = 0.0;
      _isSwipingVertically = false;
    });
    _startAutoDismissTimer();
  }

  /// Whether the snackbar appears from the top
  bool get _isFromTop =>
      widget.position == Alignment.topCenter ||
      widget.position == Alignment.topLeft ||
      widget.position == Alignment.topRight;

  @override
  Widget build(BuildContext context) {
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
      snackbarContent = TweenAnimationBuilder<Offset>(
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

    // Wrap with horizontal Dismissible for swipe-to-dismiss (left/right)
    // and GestureDetector for vertical swipe (up/down based on position)
    if (widget.isSwipeable && !_isLocallyDismissing) {
      // Calculate opacity based on swipe progress (both vertical and horizontal)
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;

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

      // Wrap with Dismissible for horizontal swipe
      snackbarContent = Dismissible(
        key: _dismissibleKey,
        direction: DismissDirection.horizontal,
        onUpdate: _onDismissibleUpdate,
        onDismissed: _onDismissed,
        confirmDismiss: (direction) async {
          // Don't allow dismiss if already dismissing
          return !_isLocallyDismissing && !widget.isDismissing;
        },
        dismissThresholds: const {
          DismissDirection.startToEnd: 0.25,
          DismissDirection.endToStart: 0.25,
        },
        movementDuration: const Duration(milliseconds: 200),
        resizeDuration:
            null, // Disable resize animation (we handle removal ourselves)
        behavior: HitTestBehavior.opaque,
        child: verticalSwipeWrapper,
      );
    } else if (_isLocallyDismissing) {
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
      snackbarContent = GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: snackbarContent,
      );
    }

    // Calculate max width
    double maxWidth;
    if (widget.width != null) {
      maxWidth = widget.width!;
    } else {
      final screenWidth = MediaQuery.of(context).size.width;
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
      // Absolute positioning from top-left corner (ignores position/alignment)
      positionedSnackbar = Positioned(
        left: widget.offset!.dx,
        top: widget.offset!.dy,
        child: animatedContent,
      );
    } else {
      // Use Align instead of Positioned.fill so that each snackbar only takes up
      // as much space as needed, allowing taps to pass through to snackbars behind
      positionedSnackbar = Align(
        alignment: widget.position,
        child: animatedContent,
      );
    }

    // Wrap with animated barrier color if provided and not transparent
    if (widget.barrierColor != Colors.transparent) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // Animated barrier color layer
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              // Fade the barrier with the snackbar animation
              final barrierOpacity =
                  _fadeAnimation.value * widget.barrierColor.a;
              return SInkButton(
                scaleFactor: 1,
                color: widget.barrierColor.darken(0.2),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color:
                        widget.barrierColor.withValues(alpha: barrierOpacity),
                  ),
                ),
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    // Start the animation immediately
    _controller.forward();
  }

  @override
  void didUpdateWidget(SnackbarDurationIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If duration changes, update the controller
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
