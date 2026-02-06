// ignore_for_file: unused_local_variable

/// Modal Bottom Sheet Implementation
/// This file contains the components needed to create interactive bottom sheets
/// with drag-to-dismiss functionality and animations.
///
/// The implementation includes:
/// - Drag handle widget for user interaction
/// - Bottom sheet template for quick testing
/// - Main bottom sheet container with animation support
part of '../s_modal_libs.dart';

//******************************************************* */
// Global state management

/// Tracks the current vertical drag offset of the modal
/// Used to synchronize the position between the drag handle and the sheet
final _modalDragOffsetNotifier = RM.inject<double>(() => 0.0);

/// Whether the user is currently interacting with the sheet via drag.
/// Used to temporarily disable entrance/exit effects while dragging to avoid
/// visual jitter from competing animations.
final _modalIsInteractingNotifier = RM.inject<bool>(() => false);

/// Stores the current height of the bottom sheet
/// Used to dynamically calculate drag thresholds based on sheet size
final _modalSheetHeightNotifier = RM.inject<double>(() => 0.0);

/// A draggable handle at the top of the bottom sheet.
///
/// This widget provides an interactive UI element that:
/// - Shows a visual indicator for draggability (horizontal bar)
/// - Allows users to dismiss the sheet by dragging down
/// - Dismisses automatically if dragged with sufficient velocity or distance
/// - Provides haptic feedback during interaction (through animation controllers)
/// - Animates the background layer opacity in sync with the drag gesture
class _DragHandle extends StatefulWidget {
  /// Maximum height when expanded (as percentage of screen height)
  final double? expandedHeight;

  /// Maximum width when expanded (as percentage of screen width)
  final double? expandedWidth;

  /// Whether the sheet can be expanded by dragging
  final bool isExpandable;

  /// Whether the drag handle is in horizontal orientation (for left/right sheets)
  final bool isHorizontal;

  /// The position of the sheet (bottom, top, left, right)
  final SheetPosition position;

  const _DragHandle({
    this.expandedHeight,
    this.expandedWidth,
    this.isExpandable = false,
    this.isHorizontal = false,
    required this.position,
  });

  @override
  State<_DragHandle> createState() => _DragHandleState();
}

class _DragHandleState extends State<_DragHandle> {
  /// Tracks the current drag position (vertical for bottom/top, horizontal for left/right)
  /// Used to calculate animation progress and dismiss thresholds
  double dragDistance = 0;

  /// Direction of the drag: positive for down/right, negative for up/left
  double dragDirection = 0;

  /// Original dimension of the sheet before expansion (height for vertical, width for horizontal)
  double originalSheetDimension = 0;

  /// Tracks cumulative downward movement when expanded
  /// Used to detect small drags that should trigger collapse
  double cumulativeDownwardDrag = 0;

  /// Tracks if the sheet is currently expanded
  bool isExpanded = false;

  // Tracks whether the current drag gesture started while the sheet was expanded
  bool _dragStartedFromExpanded = false;

  // Constant thresholds and configuration values
  /// Threshold in pixels for triggering collapse with small drag from expanded state
  /// For side sheets, this represents horizontal drag distance
  /// For bottom sheets, this represents vertical drag distance
  static const double kSmallDragCollapseThreshold = 40.0;

  /// Threshold factor for dismissal (percentage of max distance)
  /// Must drag beyond this threshold to trigger dismiss instead of collapse
  static const double kDismissThresholdFactor = 0.15;

  /// Velocity threshold for flick-to-dismiss (pixels per second)
  static const double kFlickVelocityThreshold = 300.0;

  /// Whether to use haptic feedback during drag interactions
  static const bool kEnableHapticFeedback = true;

  /// Max dimension the sheet can be expanded to (height for vertical, width for horizontal)
  double get maxExpandedDimension {
    // Get screen dimensions safely using MediaQuery
    final mediaQuerySize = MediaQuery.maybeOf(context)?.size;

    // For horizontal sheets (left/right), use width percentage
    // For vertical sheets (top/bottom), use height percentage
    if (widget.isHorizontal) {
      final screenWidth = mediaQuerySize?.width ?? 1000.0;
      return screenWidth * (widget.expandedWidth ?? 85) / 100;
    } else {
      final screenHeight = mediaQuerySize?.height ?? 1000.0;
      return screenHeight * (widget.expandedHeight ?? 85) / 100;
    }
  }

  /// Calculates the maximum drag distance for background animation effects
  ///
  /// This is dynamically based on the bottom sheet's actual height:
  /// - Uses the current sheet height from the shared notifier
  /// - Defaults to 200 logical pixels if height is unavailable
  /// - This threshold controls when background animations reach their maximum
  double get maxDragDistance {
    // Get the actual sheet height from the notifier, with a minimum value
    double sheetHeight = _modalSheetHeightNotifier.state;
    // Use the sheet height for the animation threshold (minimum 200)
    return sheetHeight > 0 ? sheetHeight : 200;
  }

  /// Calculates the maximum distance the modal can be dragged
  ///
  /// This is dynamically based on the sheet height:
  /// - Uses the current height from the shared notifier
  /// - Defaults to 400 logical pixels if height is unavailable
  /// - This limit prevents excessive dragging beyond what's needed
  double get maxModalDragDistance {
    double sheetHeight = _modalSheetHeightNotifier.state;
    // Use full sheet height for maximum drag (minimum 400)
    return sheetHeight > 0 ? sheetHeight : 400;
  }

  // Helper to safely update the drag offset notifier. Clamps negative
  // values to 0 and logs unexpected inputs.
  void _setModalDragOffset(double value, {String reason = ''}) {
    final double normalized = (value.isFinite && value > 0) ? value : 0.0;
    if (_modalDragOffsetNotifier.state != normalized) {
      if (value < 0 && _showDebugPrints) {
        debugPrint(
            '[OFFSET_CLAMP] raw=$value -> clamped=$normalized reason=$reason');
      } else if (_showDebugPrints) {
        debugPrint(
            '[OFFSET] updating modal offset: from ${_modalDragOffsetNotifier.state} to $normalized reason=$reason');
      }
      _modalDragOffsetNotifier.state = normalized;
    }
  }

  @override
  void initState() {
    super.initState();
    // Store the original dimension when the drag handle is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        originalSheetDimension = _modalSheetHeightNotifier.state;
        // Ensure we rebuild after storing the dimension so canExpand logic works
        if (originalSheetDimension > 0) {
          setState(() {});
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant _DragHandle oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if expandedHeight was changed via updateParams
    if (widget.expandedHeight != oldWidget.expandedHeight) {
      // Calculate new max expanded dimension using MediaQuery
      final mediaQuerySize = MediaQuery.maybeOf(context)?.size;
      final newMaxExpanded = widget.isHorizontal
          ? (mediaQuerySize?.width ?? 1000.0) *
              (widget.expandedWidth ?? 85) /
              100
          : (mediaQuerySize?.height ?? 1000.0) *
              (widget.expandedHeight ?? 85) /
              100;
      final currentHeight = _modalSheetHeightNotifier.state;

      // If sheet is currently expanded but the new max is now at or below
      // the original dimension, we need to collapse it
      if (isExpanded && originalSheetDimension > 0) {
        // If new expanded dimension <= original dimension, expansion is disabled
        if (newMaxExpanded <= originalSheetDimension) {
          // Collapse the sheet back to original dimension
          _collapseSheet();
        }
        // If we're expanded beyond the new max, also collapse
        else if (currentHeight > newMaxExpanded) {
          // Animate to new max or collapse
          _modalSheetHeightNotifier.state = originalSheetDimension;
          _modalSheetHeightNotifier.notify();
          setState(() {
            isExpanded = false;
            dragDistance = 0;
          });
          _modalDragOffsetNotifier.state = 0;
        }
      }
      // If expansion was just enabled (new max > original), update tracking
      else if (!isExpanded && newMaxExpanded > originalSheetDimension) {
        // Just update the originalSheetDimension in case it wasn't set properly
        if (originalSheetDimension == 0 && currentHeight > 0) {
          originalSheetDimension = currentHeight;
        }
      }
    }
  }

  // Using the k-prefixed constants defined above

  /// Normalizes the delta based on sheet position
  /// The convention is:
  /// - negative normalized delta = expansion direction
  /// - positive normalized delta = dismiss direction
  ///
  /// For bottom sheets: drag up (negative delta) expands, drag down (positive delta) dismisses
  /// For top sheets: drag down (positive delta) expands, drag up (negative delta) dismisses (REVERSED)
  /// For right sheet: drag left (negative delta) expands, drag right (positive delta) dismisses
  /// For left sheet: drag right (positive delta) expands, drag left (negative delta) dismisses (REVERSED)
  double _normalizeDelta(double delta) {
    switch (widget.position) {
      case SheetPosition.bottom:
      case SheetPosition.right:
        return delta; // Already in correct convention
      case SheetPosition.top:
      case SheetPosition.left:
        return -delta; // Flip the sign for top and left positions
    }
  }

  /// If the sheet has reached (or slightly exceeded) its maximum expanded
  /// dimension during a drag, lock it to the exact expanded value and
  /// synchronize internal state to avoid transient jitter while the user
  /// is still dragging. Returns true when a lock was applied.
  bool _lockToExpandedIfNeeded(double sheetHeight) {
    const double tolerance = 1.0; // pixels
    if (sheetHeight >= maxExpandedDimension - tolerance) {
      if (_showDebugPrints) {
        debugPrint(
            '[LOCK] lockToExpanded triggered: sheetHeight=$sheetHeight max=$maxExpandedDimension original=$originalSheetDimension');
      }
      final collapseDistance = maxExpandedDimension - originalSheetDimension;

      // Ensure precise final height (avoid tiny FP differences)
      _modalSheetHeightNotifier.state = maxExpandedDimension;
      _modalSheetHeightNotifier.notify();

      if (!isExpanded) {
        setState(() {
          isExpanded = true;
        });
      }

      // Mark the drag as originating from expanded state
      dragDistance = -collapseDistance;
      _dragStartedFromExpanded = true;

      // No visual displacement (offset) while locked at expanded size
      _modalDragOffsetNotifier.state = 0;

      // Ensure derived UI state (background fade, etc.) matches
      _updateUIFromDragDistance(dragDistance);

      if (_showDebugPrints) {
        debugPrint(
            '[LOCK] locked: dragDistance=$dragDistance _modalSheetHeightNotifier=${_modalSheetHeightNotifier.state} _modalDragOffsetNotifier=${_modalDragOffsetNotifier.state}');
      }

      return true;
    }
    return false;
  }

  /// Handles an upward/leftward drag for sheet expansion
  /// Returns the new drag distance
  /// Note: deltaY should be normalized via _normalizeDelta before calling
  double _handleUpwardDrag(double deltaY, double sheetHeight) {
    // If we're already at (or very near) max expanded dimension, lock to it
    if (_lockToExpandedIfNeeded(sheetHeight)) {
      return dragDistance;
    }

    // Calculate how much more we need to expand
    double expansionNeeded = maxExpandedDimension - originalSheetDimension;

    // Convert dragDistance to represent expansion progress
    double newDistance =
        (dragDistance + deltaY).clamp(-expansionNeeded, 0).toDouble();

    // Immediately apply dimension change during drag for real-time feedback
    double newHeight = originalSheetDimension -
        newDistance; // Negative drag means increasing dimension
    _modalSheetHeightNotifier.state = newHeight;
    _modalSheetHeightNotifier.notify();

    // Check if we've reached expanded size during this drag and lock to it
    if (newHeight >= maxExpandedDimension) {
      _lockToExpandedIfNeeded(newHeight);
    }

    return newDistance;
  }

  /// Handles a downward drag while the sheet is expanded
  /// Returns the new drag distance or null if quick collapse was triggered
  /// Note: deltaY should be normalized via _normalizeDelta before calling
  double? _handleExpandedDownwardDrag(double deltaY, double collapseDistance) {
    // During collapse phase: dragDistance goes from -collapseDistance (fully expanded) to 0 (collapsed)
    // During dismiss phase: dragDistance goes from 0 (collapsed) to positive (dismissing)

    double newDragDistance = dragDistance + deltaY;

    // Clamp to valid range: from fully expanded (-collapseDistance) to max dismiss distance
    return newDragDistance
        .clamp(-collapseDistance, maxModalDragDistance)
        .toDouble();
  }

  /// Immediately collapses the sheet to its original dimension
  void _collapseSheet() {
    _modalSheetHeightNotifier.state = originalSheetDimension;
    _modalSheetHeightNotifier.notify();
    setState(() {
      isExpanded = false;
      dragDistance = 0;
    });

    // Provide haptic feedback for collapse action
    if (kEnableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    cumulativeDownwardDrag = 0; // Reset for next time
  }

  /// Updates the UI state based on the new drag distance
  void _updateUIFromDragDistance(double newDragDistance) {
    // Calculate the effective height based on drag
    double effectiveHeight;

    if (newDragDistance < 0) {
      // Expanding or collapsing from expanded state
      // newDragDistance ranges from -collapseDistance (fully expanded) to 0 (collapsed)
      effectiveHeight = originalSheetDimension - newDragDistance;
      _modalSheetHeightNotifier.state = effectiveHeight;
      _modalSheetHeightNotifier.notify();
    } else {
      // Normal dismiss drag (never was expanded, or already collapsed)
      effectiveHeight = originalSheetDimension;
      // Sheet stays at original size, drag offset handles the visual movement
    }

    // Sync the drag position with other components
    // Only apply offset for dismiss phase (positive dragDistance)
    final newOffset = newDragDistance > 0 ? newDragDistance : 0.0;
    _setModalDragOffset(newOffset,
        reason: 'dragUpdate(newDragDistance=$newDragDistance)');

    // Update local state
    setState(() {
      dragDistance = newDragDistance;
      isExpanded = effectiveHeight > originalSheetDimension;
    }); // Update background animation for downward/rightward drag
    if (newDragDistance >= 0) {
      double animationDragDistance = newDragDistance.clamp(0, maxDragDistance);
      double progress = animationDragDistance / maxDragDistance;

      // Update background animation (1 = fully visible, 0 = fully faded)
      _backgroundLayerAnimationNotifier.state = 1 - progress;

      // Strategic haptic feedback at key interaction points
      // Provides subtle feedback when approaching dismiss threshold
      if (kEnableHapticFeedback) {
        // First feedback at 50% of dismiss threshold
        if (progress > 0.5 && progress < 0.52) {
          HapticFeedback.selectionClick();
        }
        // Stronger feedback at 80% of dismiss threshold (almost dismissing)
        else if (progress > 0.8 && progress < 0.82) {
          HapticFeedback.lightImpact();
        }
        // Final feedback when passing dismiss threshold
        else if (progress > kDismissThresholdFactor &&
            progress < kDismissThresholdFactor + 0.02) {
          HapticFeedback.mediumImpact();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Common drag update logic for both orientations
    void handleDragUpdate(double delta) {
      // Debug: log incoming drag deltas and current dimensions
      if (_showDebugPrints) {
        debugPrint(
            '[DRAG_UPDATE] rawDelta=$delta | dragDistance(before)=$dragDistance | original=$originalSheetDimension | notifier=${_modalSheetHeightNotifier.state} | max=$maxExpandedDimension');
      }

      // For horizontal sheets, the delta sign is opposite, normalize it here
      // (sheetHeight will be read below)

      // Capture whether this drag started from an expanded state
      // IMPORTANT: Only check actual dimension, NOT the isExpanded flag,
      // because the flag may not be updated yet after a collapse animation.
      if (!_dragStartedFromExpanded) {
        final startDim = _modalSheetHeightNotifier.state;
        // Only consider the actual visual dimension to detect expanded state
        // Use a tolerance of 5px to account for floating point differences
        if (startDim >= maxExpandedDimension - 5) {
          _dragStartedFromExpanded = true;
          if (_showDebugPrints) {
            debugPrint(
                '[DRAG_UPDATE] Detected drag started from expanded state (dim=$startDim, max=$maxExpandedDimension)');
          }
        }
      }
      // Track drag direction
      dragDirection = delta;

      // Mark as interacting for the duration of the drag so other widgets
      // can temporarily disable entrance/exit animations that might collide
      // with the user's drag gestures.
      if (!_modalIsInteractingNotifier.state) {
        _modalIsInteractingNotifier.state = true;
      }

      // Current sheet height from notifier
      double sheetHeight = _modalSheetHeightNotifier.state;

      // Store original dimension if not yet stored (and sheet has been measured)
      if (originalSheetDimension == 0 && sheetHeight > 0) {
        originalSheetDimension = sheetHeight;
      }

      // Check if we can expand the sheet
      // IMPORTANT: Only allow expansion if:
      // 1. isExpandable flag is true (sheet was configured to be expandable)
      // 2. originalSheetDimension has been properly initialized to the actual rendered sheet size
      // 3. There is room to expand (originalSheetDimension < maxExpandedDimension)
      bool canExpand = widget.isExpandable &&
          originalSheetDimension > 0 &&
          originalSheetDimension < maxExpandedDimension;

      // debugPrint(
      // '[DRAG] canExpand=$canExpand | isExpandable=${widget.isExpandable} | original=$originalSheetDimension | sheetHeight=$sheetHeight | max=$maxExpandedDimension');

      // Normalize delta based on sheet position so that:
      // - negative delta always means expansion direction
      // - positive delta always means dismiss direction
      double normalizedDelta = _normalizeDelta(delta);

      double? newDragDistance;

      // Handle different drag scenarios based on direction and state
      if (normalizedDelta < 0 && canExpand) {
        // Expansion direction drag
        newDragDistance = _handleUpwardDrag(normalizedDelta, sheetHeight);
        if (_showDebugPrints) {
          debugPrint(
              '[DRAG_UPDATE] expansion delta normalized=$normalizedDelta -> newDragDistance=$newDragDistance');
        }
      } else if (isExpanded) {
        // Dismiss direction drag while expanded - collapse or dismiss
        double collapseDistance = maxExpandedDimension - originalSheetDimension;
        newDragDistance =
            _handleExpandedDownwardDrag(normalizedDelta, collapseDistance);
        if (newDragDistance == null) {
          if (_showDebugPrints) {
            debugPrint(
                '[DRAG_UPDATE] quick collapse triggered by downward drag');
          }
        } else {
          if (_showDebugPrints) {
            debugPrint(
                '[DRAG_UPDATE] expanded-down delta normalized=$normalizedDelta -> newDragDistance=$newDragDistance');
          }
        }
        if (newDragDistance == null) return; // Quick collapse was triggered
      } else {
        // Normal dismiss direction drag for dismissal
        newDragDistance = (dragDistance + normalizedDelta)
            .clamp(0, maxModalDragDistance)
            .toDouble();
        if (_showDebugPrints) {
          debugPrint(
              '[DRAG_UPDATE] dismiss delta normalized=$normalizedDelta -> newDragDistance=$newDragDistance');
        }
      }

      // Only update if there's a meaningful change (performance optimization)
      if (newDragDistance != dragDistance) {
        if (_showDebugPrints) {
          debugPrint(
              '[DRAG_UPDATE] applying newDragDistance: from $dragDistance to $newDragDistance');
        }
        _updateUIFromDragDistance(newDragDistance);
      }
    }

    // Common drag end logic for both orientations
    void handleDragEnd(double velocity) {
      // Normalize velocity the same way we normalize delta
      // For top/left sheets, positive velocity means expansion, negative means dismiss
      // We need to flip the sign so positive velocity always means dismiss direction
      final normalizedVelocity = _normalizeDelta(velocity);

      // Capture and reset the drag-start-expanded flag after processing
      final startedExpanded = _dragStartedFromExpanded;
      _dragStartedFromExpanded = false;

      // NOTE: Do NOT call restoreHeightAnimation() here at the start!
      // It will be called selectively in specific code paths that need it.
      // Calling it too early causes AnimatedContainer to start animating
      // before we've determined the correct end state, causing jitter.

      // Reset cumulative tracking when drag ends
      cumulativeDownwardDrag = 0;

      // User is no longer interacting
      if (_modalIsInteractingNotifier.state) {
        _modalIsInteractingNotifier.state = false;
      }

      // Get current dimension to check actual sheet state
      final currentDimension = _modalSheetHeightNotifier.state;
      final isCurrentlyExpanded =
          currentDimension >= maxExpandedDimension - 5; // 5px tolerance

      // Calculate how far we've dragged FROM the expanded position
      final dragFromExpanded = (isCurrentlyExpanded || startedExpanded)
          ? (maxExpandedDimension - currentDimension).abs()
          : 0.0;

      if (_showDebugPrints) {
        debugPrint(
            '[DRAG_END] isExpanded=$isExpanded | isCurrentlyExpanded=$isCurrentlyExpanded | startedExpanded=$startedExpanded | currentDim=$currentDimension | dragDistance=$dragDistance | dragFromExpanded=$dragFromExpanded | smallThreshold=$kSmallDragCollapseThreshold');
      }

      // If drag started from expanded and user dragged outward (toward collapse/dismiss),
      // we should handle collapse logic, NOT snap back to expanded.
      // dragFromExpanded > 0 means user moved the sheet away from expanded position.
      if (startedExpanded && dragFromExpanded > 0) {
        // User started from expanded and dragged outward - handle collapse cases
        final smallDragThreshold = kSmallDragCollapseThreshold; // 80px
        final dismissThreshold = maxDragDistance *
            kDismissThresholdFactor; // 55% of max drag distance

        if (_showDebugPrints) {
          debugPrint(
              '[DRAG_END] Started expanded, dragged outward: dragFromExpanded=$dragFromExpanded | smallThreshold=$smallDragThreshold | dismissThreshold=$dismissThreshold');
        }

        // STAGE 1: Small drag from expanded position (< 80px) = COLLAPSE back to original size
        if (dragFromExpanded < smallDragThreshold) {
          if (_showDebugPrints) {
            debugPrint(
                '[DRAG_END] Collapsing to original size (small drag from expanded)');
          }

          final endHeight = originalSheetDimension;
          if (_showDebugPrints) {
            debugPrint('[DRAG_END] Small-collapse: animating to $endHeight');
          }

          _Sheet.animateToSize(
            endHeight,
            duration: const Duration(milliseconds: 300),
            onComplete: () {
              if (_showDebugPrints) {
                debugPrint('[DRAG_END] Small-collapse animation complete');
              }
              if (mounted) {
                setState(() {
                  isExpanded = false;
                  dragDistance = 0;
                });
                _setModalDragOffset(0, reason: 'small-collapse onComplete');
              }
            },
          );

          _backgroundLayerAnimationNotifier.state = 1.0;
          return;
        }

        // STAGE 2: Mid-range drag - collapse to original (not dismiss)
        // If we haven't passed the dismiss threshold, collapse
        if (dragDistance <= dismissThreshold) {
          if (_showDebugPrints) {
            debugPrint(
                '[DRAG_END] Collapsing to original size (mid-range drag)');
          }

          final endHeight = originalSheetDimension;
          if (_showDebugPrints) {
            debugPrint(
                '[DRAG_END] Mid-range collapse: animating to $endHeight');
          }

          _Sheet.animateToSize(
            endHeight,
            duration: const Duration(milliseconds: 300),
            onComplete: () {
              if (_showDebugPrints) {
                debugPrint('[DRAG_END] Mid-range collapse animation complete');
              }
              if (mounted) {
                setState(() {
                  isExpanded = false;
                  dragDistance = 0;
                });
                _setModalDragOffset(0, reason: 'mid-range collapse onComplete');
              }
            },
          );

          _backgroundLayerAnimationNotifier.state = 1.0;
          return;
        } // End of if (dragDistance <= dismissThreshold)
      } // End of if (startedExpanded && dragFromExpanded > 0)

      // If we were expanding (negative drag) AND NOT coming from expanded state
      // This handles the case where user starts from original size and drags to expand
      if (dragDistance < 0 && !startedExpanded) {
        // Calculate how far we've dragged toward expansion (from original size)
        final dragTowardExpansion =
            (currentDimension - originalSheetDimension).abs();
        final smallDragThreshold = kSmallDragCollapseThreshold; // 80px

        // debugPrint(
        // '[DRAG_END] Started collapsed, dragging to expand: dragTowardExpansion=$dragTowardExpansion | smallThreshold=$smallDragThreshold');

        // Small drag toward expansion (< 80px) = SNAP TO EXPANDED
        // This makes it easy to expand with just a small gesture
        if (dragTowardExpansion > 0 &&
            dragTowardExpansion < smallDragThreshold) {
          // debugPrint(
          // '[DRAG_END] Expanding to max (small drag toward expansion)');

          final endHeight = maxExpandedDimension;
          // debugPrint('[DRAG_END] Small-expand: animating to $endHeight');

          setState(() {
            isExpanded = true;
          });

          _Sheet.animateToSize(
            endHeight,
            duration: const Duration(milliseconds: 150),
            onComplete: () {
              // debugPrint('[DRAG_END] Small-expand animation complete');
              if (mounted) {
                setState(() {
                  dragDistance =
                      -(maxExpandedDimension - originalSheetDimension);
                });
                // Fire onExpanded after animation completion
                Modal.controller.state?.onExpanded?.call();
              }
            },
          );

          return;
        }

        // Larger drag toward expansion = also SNAP TO EXPANDED
        // (Any intentional expansion gesture should complete the expansion)
        if (dragTowardExpansion >= smallDragThreshold) {
          // debugPrint(
          // '[DRAG_END] Expanding to max (larger drag toward expansion)');

          final endHeight = maxExpandedDimension;
          // debugPrint('[DRAG_END] Larger-expand: animating to $endHeight');

          setState(() {
            isExpanded = true;
          });

          _Sheet.animateToSize(
            endHeight,
            duration: const Duration(milliseconds: 150),
            onComplete: () {
              if (mounted) {
                setState(() {
                  dragDistance =
                      -(maxExpandedDimension - originalSheetDimension);
                });
                Modal.controller.state?.onExpanded?.call();
              }
            },
          );

          return;
        }

        // If dragTowardExpansion is 0 or very small, just reset
        // (This handles edge cases where the gesture didn't really move the sheet)
        // debugPrint('[DRAG_END] Minimal expansion drag, resetting to original');
        _modalSheetHeightNotifier.state = originalSheetDimension;
        setState(() {
          dragDistance = 0;
        });
        return;
      }

      // Define threshold for dismiss
      final dismissThreshold =
          maxDragDistance * kDismissThresholdFactor; // 55% of max drag distance

      // Check if we should dismiss based on:
      // - Fast flick in dismiss direction (normalized velocity > threshold pixels/second)
      // - OR dragged more than threshold distance
      if (normalizedVelocity > kFlickVelocityThreshold ||
          dragDistance > dismissThreshold) {
        //
        // --- DISMISS THE SHEET ---
        //

        // Ensure the modal drag notifier reflects the exact finger position
        final currentDragOffset = dragDistance;
        // debugPrint(
        // '[🚀 DISMISS START] dragOffset=$currentDragOffset | velocity=$normalizedVelocity | threshold=$dismissThreshold');

        _setModalDragOffset(currentDragOffset,
            reason: 'dismiss currentDragOffset');

        // Call the proper dismiss method which handles all cleanup and animation
        Modal.dismissBottomSheet();
      } else {
        //
        // --- SNAP BACK OR COLLAPSE ---
        //

        // Reset background to fully visible
        _backgroundLayerAnimationNotifier.state = 1.0;

        // If expanded and dragged in dismiss direction, collapse to original size
        // This makes the collapse behavior more lenient - any outward drag that doesn't
        // meet the dismiss threshold will collapse back to original size
        if ((isExpanded || startedExpanded) && dragDistance > 0) {
          // debugPrint('[DRAG_END] Collapsing to original size (mid-range drag)');

          // Calculate animation values
          final startHeight = _modalSheetHeightNotifier.state;
          final endHeight = originalSheetDimension;
          // debugPrint(
          // '[DRAG_END] Starting mid-range collapse animation: start=$startHeight end=$endHeight');

          createSmoothAnimation(
            startValue: startHeight,
            endValue: endHeight,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            onUpdate: (double height) {
              if (mounted) {
                _modalSheetHeightNotifier.state = height;
              }
            },
            onComplete: () {
              // debugPrint('[DRAG_END] Mid-range collapse animation complete');
              if (mounted) {
                setState(() {
                  isExpanded = false;
                  dragDistance = 0;
                });
                _setModalDragOffset(0, reason: 'mid-range collapse finalize');
              }
            },
          );

          _backgroundLayerAnimationNotifier.state = 1.0;
          return;
        }

        // If we got here without returning, it means we should snapback
        // Not expanded, just snap back to current position
        // Animate the drag offset back to 0 smoothly
        final originalDragDistance = dragDistance;

        // If the original drag distance is negative (expansion), there is
        // no positive offset to animate back — just ensure notifier is zero.
        final double startOffset =
            originalDragDistance > 0 ? originalDragDistance : 0.0;

        if (startOffset == 0.0) {
          // Simply ensure offset is zero
          _setModalDragOffset(0, reason: 'snapback startOffset==0');
          setState(() {
            dragDistance = 0;
          });
        } else {
          // Animate the offset back to 0 smoothly
          // debugPrint('[🔄 SNAPBACK] Animating offset from $startOffset to 0');

          createSmoothAnimation(
            startValue: startOffset,
            endValue: 0.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            onUpdate: (double offset) {
              if (mounted) {
                _setModalDragOffset(offset, reason: 'snapback animation');
              }
            },
            onComplete: () {
              // debugPrint('[🔄 SNAPBACK] Animation complete');
              if (mounted) {
                setState(() {
                  dragDistance = 0;
                });
                _setModalDragOffset(0, reason: 'snapback complete');
              }
            },
          );
        }
      }
    } // End of handleDragEnd

    // Common drag cancel logic
    void handleDragCancel() {
      // Reset the drag-start-expanded flag when the drag is cancelled
      _dragStartedFromExpanded = false;
      // Reset background layer to fully visible
      _backgroundLayerAnimationNotifier.state = 1.0;

      // If expanded, stay expanded
      if (!isExpanded) {
        // Reset the drag distance to original position
        setState(() {
          dragDistance = 0;
        });
      }

      // Clear interacting flag
      if (_modalIsInteractingNotifier.state) {
        _modalIsInteractingNotifier.state = false;
      }
    }

    return GestureDetector(
      // Handle continuous drag gestures - vertical for bottom sheets, horizontal for side sheets
      onVerticalDragUpdate: widget.isHorizontal
          ? null
          : (details) {
              handleDragUpdate(details.delta.dy);
            },
      onHorizontalDragUpdate: widget.isHorizontal
          ? (details) {
              handleDragUpdate(details.delta.dx);
            }
          : null,

      /// Handles what happens when the user releases the drag gesture
      onVerticalDragEnd: widget.isHorizontal
          ? null
          : (details) {
              handleDragEnd(details.velocity.pixelsPerSecond.dy);
            },
      onHorizontalDragEnd: widget.isHorizontal
          ? (details) {
              handleDragEnd(details.velocity.pixelsPerSecond.dx);
            }
          : null,

      /// Handles interrupted or cancelled drag gestures
      onVerticalDragCancel: widget.isHorizontal ? null : handleDragCancel,
      onHorizontalDragCancel: widget.isHorizontal ? handleDragCancel : null,

      // Visual representation of the drag handle
      child: Semantics(
        label: 'Drag to dismiss',
        hint: 'Drag down to close the bottom sheet',
        button: true,
        excludeSemantics: true,
        child: Box(
          height:
              widget.isHorizontal ? null : 35, // Only fixed height for vertical
          width: widget.isHorizontal
              ? 35
              : null, // Only fixed width for horizontal
          color:
              Colors.black.withValues(alpha: 0.0), // Transparent touch surface
          alignment: Alignment.center, // Center the visual indicator
          child: Padding(
            padding: widget.isHorizontal
                ? const EdgeInsets.symmetric(horizontal: 8.0)
                : const EdgeInsets.symmetric(vertical: 8.0), // Spacing
            child: Container(
              width: widget.isHorizontal
                  ? 4
                  : 40, // Width of the visual handle indicator
              height: widget.isHorizontal
                  ? 40
                  : 4, // Height of the visual handle indicator
              decoration: BoxDecoration(
                color: Colors.grey.shade600, // Subtle gray for the handle
                borderRadius: BorderRadius.circular(2), // Rounded corners
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//************************************************ */
/// Main container for bottom sheet modals
///
/// This widget:
/// - Positions the sheet at the bottom of the screen
/// - Handles the sheet appearance (styling, shadow, border radius)
/// - Manages entry and exit animations
/// - Integrates with the drag handle for interactive dismissal
/// - Updates shared state for height-based calculations
class _Sheet extends StatefulWidget {
  // Static reference to access the current sheet state
  static _SheetState? currentState;

  /// Animate the sheet to a target size
  static void animateToSize(double targetSize,
      {Duration? duration, VoidCallback? onComplete}) {
    currentState?.animateSheetSize(targetSize,
        duration: duration, onComplete: onComplete);
  }

  /// Content to display inside the bottom sheet
  final Widget child;

  /// Optional fixed height for the sheet (used for bottom position)
  /// If null, the sheet will size to fit its content
  final double? height;

  /// Optional fixed width for the sheet (used for left/right positions)
  /// If null, the sheet will size to fit its content
  final double? width;

  /// Maximum height when the sheet is expanded (as percentage of screen height)
  /// Default is 86% of screen height (used for bottom position)
  final double? expandedHeight;

  /// Maximum width when the sheet is expanded (as percentage of screen width)
  /// Default is 86% of screen width (used for left/right positions)
  final double? expandedWidth;

  /// Whether the sheet is currently being dismissed
  /// Controls which animation set is applied
  final bool isDismissing;

  /// Padding on the side where the drag handle is located
  /// Default is 35.0 (the size of the drag handle area)
  /// Automatically applied to the correct edge based on SheetPosition:
  /// - bottom: padding at top
  /// - top: padding at bottom
  /// - left: padding at right
  /// - right: padding at left
  final double contentPaddingByDragHandle;

  /// Optional background color for the bottom sheet
  /// If null, defaults to a light brown color
  final Color? backgroundColor;

  /// Position of the sheet (bottom, left, right, top)
  /// Determines orientation and animation direction
  final SheetPosition position;

  /// Whether the sheet can be expanded by dragging
  final bool isExpandable;

  /// Unique identifier for this sheet instance
  /// Used to create unique animation keys to prevent animation conflicts between sheets
  final String? sheetId;

  /// Creates a bottom sheet with the specified content and behavior
  const _Sheet({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.expandedHeight,
    this.expandedWidth,
    required this.isDismissing,
    this.contentPaddingByDragHandle = 35.0,
    this.backgroundColor,
    this.position = SheetPosition.bottom,
    this.isExpandable = false,
    this.sheetId,
  });

  @override
  State<_Sheet> createState() => _SheetState();
}

class _SheetState extends State<_Sheet> with SingleTickerProviderStateMixin {
  // Track the current sheet size to rebuild when it changes
  // (height for vertical sheets, width for horizontal sheets)
  double? currentSheetSize;

  // Observer for size changes
  dynamic heightObserver;
  // Observer for drag offset changes
  dynamic offsetObserver;
  // Observer for interaction state changes (used to start/stop frame logging)
  dynamic interactionObserver;

  // Key to measure content height when height is null (auto-sizing)
  final GlobalKey contentKey = GlobalKey();
  // Key used to read sheet's RenderBox for frame-by-frame logging
  final GlobalKey sheetKey = GlobalKey();

  // Flag to track if we've measured the auto-height
  bool hasMeasuredAutoHeight = false;

  // Animation controller for smooth size transitions
  late AnimationController sizeAnimationController;
  Animation<double>? sizeAnimation;

  // Track if we're currently animating to avoid observer interference
  bool _isAnimatingSize = false;

  // Track if the initial show animation has completed
  bool _hasCompletedInitialShow = false;

  /// Animate the sheet size smoothly to a target dimension
  void animateSheetSize(double targetSize,
      {Duration? duration, VoidCallback? onComplete}) {
    final currentSize = _modalSheetHeightNotifier.state;
    if (currentSize == targetSize) {
      onComplete?.call();
      return;
    }

    // debugPrint('[🎬 SIZE_ANIM] Animating from $currentSize to $targetSize');

    _isAnimatingSize = true;

    sizeAnimation = Tween<double>(
      begin: currentSize,
      end: targetSize,
    ).animate(CurvedAnimation(
      parent: sizeAnimationController,
      curve: Curves
          .easeInOutQuad, // Smoother, more linear curve to reduce jitter perception
    ))
      ..addListener(() {
        if (mounted) {
          // Update state in a way that batches with the animation frame
          // to prevent layout jitter
          setState(() {
            _modalSheetHeightNotifier.state = sizeAnimation!.value;
          });
        }
      });

    sizeAnimationController.duration =
        duration ?? const Duration(milliseconds: 300);
    sizeAnimationController.forward(from: 0).then((_) {
      _isAnimatingSize = false;
      onComplete?.call();
    });
  }

  // Start frame logging while user is interacting to capture transient shifts
  void startFrameLogging() {
    void logFrame(Duration _) {
      if (!mounted) return;
      if (sheetKey.currentContext != null) {
        final RenderBox rb =
            sheetKey.currentContext!.findRenderObject() as RenderBox;
        final topLeft = rb.localToGlobal(Offset.zero);

        // debugPrint('[🎯 FRAME] pos=${widget.position.name} | '
        // 'topLeft=(x:${topLeft.dx.toStringAsFixed(1)}, y:${topLeft.dy.toStringAsFixed(1)}) | '
        // 'size=(w:${rb.size.width.toStringAsFixed(1)}, h:${rb.size.height.toStringAsFixed(1)}) | '
        // 'dragOffset=${_modalDragOffsetNotifier.state.toStringAsFixed(1)} | '
        // 'notifierDim=${_modalSheetHeightNotifier.state.toStringAsFixed(1)}');
      }
      // Continue logging frames while interacting
      if (_modalIsInteractingNotifier.state) {
        WidgetsBinding.instance.addPostFrameCallback(logFrame);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback(logFrame);
  }

  // Helper method to get current size - ensures values are always fresh
  // Returns height for vertical sheets, width for horizontal sheets
  double? getCurrentSize() {
    return _modalSheetHeightNotifier.state > 0
        ? _modalSheetHeightNotifier.state
        : widget.height;
  }

  /// Measure the main dimension of the sheet (height for vertical, width for horizontal)
  void measureContentDimension() {
    // Only measure when we don't have a fixed dimension
    final needsMeasure = (widget.position == SheetPosition.left ||
            widget.position == SheetPosition.right)
        ? widget.width == null
        : widget.height == null;
    if (needsMeasure && !hasMeasuredAutoHeight) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && contentKey.currentContext != null) {
          final RenderBox? renderBox =
              contentKey.currentContext!.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            if (widget.position == SheetPosition.left ||
                widget.position == SheetPosition.right) {
              final measuredWidth = renderBox.size.width;
              final totalWidth =
                  measuredWidth + widget.contentPaddingByDragHandle;
              if (_modalSheetHeightNotifier.state != totalWidth) {
                // debugPrint(
                // '[_BottomSheet] _measureContentDimension: measuredWidth=$totalWidth');
                _modalSheetHeightNotifier.state = totalWidth;
                hasMeasuredAutoHeight = true;
              }
            } else {
              final measuredHeight = renderBox.size.height;
              final totalHeight =
                  measuredHeight + widget.contentPaddingByDragHandle;
              if (_modalSheetHeightNotifier.state != totalHeight) {
                // debugPrint(
                // '[_BottomSheet] _measureContentDimension: measuredHeight=$totalHeight');
                _modalSheetHeightNotifier.state = totalHeight;
                hasMeasuredAutoHeight = true;
              }
            }
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Register this instance as the current state
    _Sheet.currentState = this;

    // Initialize animation controller
    sizeAnimationController = AnimationController(vsync: this);

    // Initialize with the provided dimension if available
    // For vertical sheets (bottom/top), use height
    // For horizontal sheets (left/right), use width
    final isHorizontal = widget.position == SheetPosition.left ||
        widget.position == SheetPosition.right;
    final initialDimension = isHorizontal ? widget.width : widget.height;

    // debugPrint(
    // '[INIT] isHorizontal=$isHorizontal | width=${widget.width} | height=${widget.height} | initialDimension=$initialDimension | notifierState=${_modalSheetHeightNotifier.state}');

    if (initialDimension != null && initialDimension > 0) {
      // Set the dimension immediately without animating to avoid visual jump
      _modalSheetHeightNotifier.state = initialDimension;
    }

    // Store initial size
    currentSheetSize = _modalSheetHeightNotifier.state;

    // States_rebuilder observer to rebuild immediately when size changes
    // Skip during size animations to prevent layout jitter
    heightObserver = _modalSheetHeightNotifier.addObserver(listener: (state) {
      if (mounted &&
          !_isAnimatingSize &&
          currentSheetSize != _modalSheetHeightNotifier.state) {
        setState(() {
          currentSheetSize = _modalSheetHeightNotifier.state;
        });
      }
    });

    // Observe drag offset changes for debugging unexpected shifts
    offsetObserver = _modalDragOffsetNotifier.addObserver(listener: (state) {
      // debugPrint('[OBSERVER] modalDragOffset changed: $state');
    });

    // Observe when user starts/stops interacting so we can log frames
    interactionObserver =
        _modalIsInteractingNotifier.addObserver(listener: (_) {
      final isInteracting = _modalIsInteractingNotifier.state;
      // debugPrint('[INTERACT] isInteracting=$isInteracting');
      if (isInteracting) {
        startFrameLogging();
      }
    });
  }

  @override
  void dispose() {
    // Clear the static reference if this is the current instance
    if (_Sheet.currentState == this) {
      _Sheet.currentState = null;
    }

    // Dispose animation controller
    sizeAnimationController.dispose();

    // Clean up the observer when the widget is disposed
    if (heightObserver != null) {
      if (heightObserver is Function) {
        heightObserver();
      } else {
        try {
          heightObserver.dispose();
        } catch (e) {
          // Silently handle if dispose is not available
        }
      }
    }
    if (offsetObserver != null) {
      if (offsetObserver is Function) {
        offsetObserver();
      } else {
        try {
          offsetObserver.dispose();
        } catch (e) {
          // ignore
        }
      }
    }
    if (interactionObserver != null) {
      if (interactionObserver is Function) {
        interactionObserver();
      } else {
        try {
          interactionObserver.dispose();
        } catch (e) {
          // ignore
        }
      }
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(_Sheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Determine if this is a horizontal sheet
    final isHorizontal = widget.position == SheetPosition.left ||
        widget.position == SheetPosition.right;

    // Handle dimension changes between modals
    final oldDimension = isHorizontal ? oldWidget.width : oldWidget.height;
    final newDimension = isHorizontal ? widget.width : widget.height;

    if (newDimension != oldDimension) {
      if (newDimension != null) {
        // New modal has fixed dimension - set it immediately
        _modalSheetHeightNotifier.state = newDimension;
      } else {
        // New modal has auto-dimension - reset flag and measure
        hasMeasuredAutoHeight = false;
        measureContentDimension();
      }
    }
    // Handle case where both dimensions are null but content changed
    else if (newDimension == null &&
        oldDimension == null &&
        widget.child != oldWidget.child) {
      // Reset measurement flag and re-measure for new content
      hasMeasuredAutoHeight = false;
      measureContentDimension();
    }
  }

  // NOTE: _measureContentHeight has been consolidated into _measureContentDimension

  @override
  Widget build(BuildContext context) {
    // For regular bottom sheet modals
    double dragOffset = _modalDragOffsetNotifier.state;

    // Force rebuild on each state access by wrapping in a function call
    // This ensures we always use the latest size value
    final currentSize = getCurrentSize();

    // Log current position if we have a render box
    if (sheetKey.currentContext != null) {
      final RenderBox? rb =
          sheetKey.currentContext!.findRenderObject() as RenderBox?;
      if (rb != null) {
        final topLeft = rb.localToGlobal(Offset.zero);
        // debugPrint('[📐 BUILD] pos=${widget.position.name} | '
        // 'currentSize=$currentSize | dragOffset=$dragOffset | isDismiss=${widget.isDismissing} | '
        // 'renderPos=(x:${topLeft.dx.toStringAsFixed(1)}, y:${topLeft.dy.toStringAsFixed(1)}) | '
        // 'renderSize=(w:${rb.size.width.toStringAsFixed(1)}, h:${rb.size.height.toStringAsFixed(1)})');
      }
    } else {
      // debugPrint(
      // '[📐 BUILD] pos=${widget.position.name} | currentSize=$currentSize | dragOffset=$dragOffset | isDismiss=${widget.isDismissing}');
    }

    // Determine if this is a horizontal sheet (left/right position)
    final isHorizontal = widget.position == SheetPosition.left ||
        widget.position == SheetPosition.right;

    // Measure content height for auto-sizing
    final needsMeasure =
        isHorizontal ? widget.width == null : widget.height == null;
    if (needsMeasure) {
      measureContentDimension();
    }

    // Get the appropriate dimension based on orientation
    // IMPORTANT: Always use currentSize (from notifier) for BOTH orientations
    // because the notifier stores width for horizontal sheets and height for vertical
    final mainDimension = currentSize;

    // Calculate padding based on sheet position (opposite side of drag handle)
    final EdgeInsets contentPadding = switch (widget.position) {
      SheetPosition.bottom =>
        EdgeInsets.only(top: widget.contentPaddingByDragHandle),
      SheetPosition.top =>
        EdgeInsets.only(bottom: widget.contentPaddingByDragHandle),
      SheetPosition.left =>
        EdgeInsets.only(right: widget.contentPaddingByDragHandle),
      SheetPosition.right =>
        EdgeInsets.only(left: widget.contentPaddingByDragHandle),
    };

    // debugPrint(
    // '[BUILD] isHorizontal=$isHorizontal | mainDimension=$mainDimension | widget.width=${widget.width} | widget.height=${widget.height} | notifierState=${_modalSheetHeightNotifier.state}');

    // For AnimatedContainer constraints, we need finite values to avoid interpolation errors.
    // Do NOT rely on Sizer here (tests/apps may not wrap with Sizer).
    // Fall back to MediaQuery when available, otherwise use a conservative default.
    final mediaQuerySize = MediaQuery.maybeOf(context)?.size;
    final fallbackDimension = isHorizontal
        ? (mediaQuerySize?.width ?? 1000.0)
        : (mediaQuerySize?.height ?? 1000.0);
    final constraintDimension = mainDimension ?? fallbackDimension;

    // Build the sheet widget - use Container with explicit constraints
    // Avoid SizedBox wrapper to prevent layout jumps during animation
    Widget sheetWidget = Container(
      key: sheetKey,
      // Use explicit constraints for smooth animations
      constraints: isHorizontal
          ? BoxConstraints.tightFor(
              width: constraintDimension,
              height: null, // Allow vertical expansion
            )
          : BoxConstraints.tightFor(
              width: null, // Allow horizontal expansion
              height: constraintDimension,
            ),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.brown.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: isHorizontal ? Offset(-5, 0) : Offset(0, -5),
            blurRadius: 40,
            spreadRadius: -5,
          ),
        ],
        border: Border.all(
          color: Colors.black,
          width: 1.5,
        ),
      ),
      alignment: isHorizontal ? Alignment.centerLeft : Alignment.topCenter,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          // Ensure Stack fills available space so Positioned children can use full dimensions
          fit: StackFit.expand,
          children: [
            // Bottom sheet content widget
            // If dimension is null, use IntrinsicHeight/Width to auto-size to content
            (widget.height == null && !isHorizontal) ||
                    (widget.width == null && isHorizontal)
                ? isHorizontal
                    ? IntrinsicWidth(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: Pad.zero,
                          child: ClipRRect(
                            key: contentKey,
                            borderRadius: BorderRadius.circular(10),
                            child: Box(
                              color: widget.backgroundColor ??
                                  Colors.brown.shade100,
                              child: Padding(
                                padding: contentPadding,
                                child: widget.child,
                              ),
                            ),
                          ),
                        ),
                      )
                    : IntrinsicHeight(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: Pad.zero,
                          child: ClipRRect(
                            key: contentKey,
                            borderRadius: BorderRadius.circular(10),
                            child: Box(
                              color: widget.backgroundColor ??
                                  Colors.brown.shade100,
                              child: Padding(
                                padding: contentPadding,
                                child: widget.child,
                              ),
                            ),
                          ),
                        ),
                      )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: Pad.zero,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Box(
                        color: widget.backgroundColor ?? Colors.brown.shade100,
                        child: Padding(
                          padding: contentPadding,
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),

            // Drag handle widget - positioned on opposite side of sheet and centered on perpendicular axis
            Positioned(
              // For side sheets (horizontal): position on inner edge and stretch vertically
              // For top/bottom sheets: position at inner edge and stretch horizontally
              left: isHorizontal
                  ? (widget.position == SheetPosition.right ? 0 : null)
                  : 0, // Stretch horizontally for bottom/top sheets
              right: isHorizontal
                  ? (widget.position == SheetPosition.left ? 0 : null)
                  : 0, // Stretch horizontally for bottom/top sheets
              top: isHorizontal
                  ? 0 // Stretch vertically for side sheets
                  : (widget.position == SheetPosition.bottom ? 0 : null),
              bottom: isHorizontal
                  ? 0 // Stretch vertically for side sheets
                  : (widget.position == SheetPosition.top ? 0 : null),
              child: isHorizontal
                  ? Center(
                      child: _DragHandle(
                        expandedHeight: widget.expandedHeight,
                        expandedWidth: widget.expandedWidth,
                        isExpandable: widget.isExpandable,
                        isHorizontal: isHorizontal,
                        position: widget.position,
                      ),
                    )
                  : Align(
                      alignment: Alignment.topCenter,
                      child: _DragHandle(
                        expandedHeight: widget.expandedHeight,
                        expandedWidth: widget.expandedWidth,
                        isExpandable: widget.isExpandable,
                        isHorizontal: isHorizontal,
                        position: widget.position,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );

    // Wrap in Positioned based on position
    Widget positionedSheet;
    // Always base the sheet's static offset on the drag offset. This ensures
    // the sheet doesn't jump to a different layout position when dismissing
    // is triggered during a drag — preventing visual jitter.
    // Note: We use Positioned (not AnimatedPositioned) because the sheet widget
    // is wrapped with flutter_animate effects (Transform, etc.) which breaks
    // AnimatedPositioned's requirement to be a direct Stack child.

    // For horizontal sheets, we need to compensate for width changes during animations
    // to prevent visual jitter. When the width changes, the left edge position shifts
    // because the right edge is anchored. We'll wrap in a Transform to offset this.
    final isAnimatingSize = sizeAnimation?.isAnimating ?? false;
    Widget finalSheet = sheetWidget;

    // Apply transform compensation for horizontal sheets during size animations
    if (isHorizontal && isAnimatingSize && sizeAnimation != null) {
      // Calculate how much the width has changed from the start of animation
      // The visual shift happens because changing width moves the left edge
      // when right edge is anchored
      finalSheet = sheetWidget; // For now, keep it simple
    }

    switch (widget.position) {
      case SheetPosition.bottom:
        positionedSheet = Positioned(
          bottom: -dragOffset,
          left: 0,
          right: 0,
          child: finalSheet,
        );
        break;
      case SheetPosition.left:
        positionedSheet = Positioned(
          left: -dragOffset,
          top: 0,
          bottom: 0,
          child: finalSheet,
        );
        break;
      case SheetPosition.right:
        positionedSheet = Positioned(
          right: -dragOffset,
          top: 0,
          bottom: 0,
          child: finalSheet,
        );
        break;
      case SheetPosition.top:
        positionedSheet = Positioned(
          top: -dragOffset,
          left: 0,
          right: 0,
          child: finalSheet,
        );
        break;
    }

    // While user is actively dragging, avoid running entrance/exit effects
    // because they can interfere with precise drag interactions and cause
    // brief visual shifts. Effects are re-enabled when interaction ends.
    if (_modalIsInteractingNotifier.state) {
      return positionedSheet;
    }

    // Apply show effects only on first appearance, not during expand/collapse
    // or after size animations. Mark as shown after first build with effects.
    final shouldApplyShowEffects =
        !widget.isDismissing && !_hasCompletedInitialShow;

    // Create unique animation key using sheetId to prevent animation conflicts between sheets
    final animationKeyId =
        widget.sheetId ?? widget.key?.toString() ?? 'unknown';

    if (shouldApplyShowEffects) {
      return positionedSheet.animate(
        key: ValueKey("sheet_anim_${animationKeyId}_show"),
        effects: getShowEffects(),
        onComplete: (controller) {
          // Mark as shown only after the animation completes
          if (mounted) {
            setState(() {
              _hasCompletedInitialShow = true;
            });
          }
        },
      );
    }

    // Apply dismiss effects when dismissing
    if (widget.isDismissing) {
      return positionedSheet.animate(
        key: ValueKey("sheet_anim_${animationKeyId}_dismissing"),
        effects: getDismissEffects(dragOffset),
      );
    }

    // No effects for expand/collapse or normal state
    return positionedSheet;
  }

  /// Get dismiss animation effects based on sheet position
  List<Effect> getDismissEffects(double dragOffset) {
    switch (widget.position) {
      case SheetPosition.bottom:
        return [
          MoveEffect(
            duration: 0.3.sec,
            // Start from zero transform (sheet already offset by -dragOffset in Positioned)
            begin: Offset(0, 0),
            // End offset should include dragOffset so final visual end matches off-screen target
            end: Offset(
                0,
                (MediaQuery.maybeOf(context)?.size.height ?? 1000.0) +
                    dragOffset),
            curve: Curves.fastEaseInToSlowEaseOut,
          ),
        ];
      case SheetPosition.top:
        return [
          MoveEffect(
            duration: 0.3.sec,
            begin: Offset(0, 0),
            end: Offset(
                0,
                -(MediaQuery.maybeOf(context)?.size.height ?? 1000.0) -
                    dragOffset),
            curve: Curves.fastEaseInToSlowEaseOut,
          ),
        ];
      case SheetPosition.left:
        return [
          MoveEffect(
            duration: 0.3.sec,
            begin: Offset(0, 0),
            end: Offset(
                -(MediaQuery.maybeOf(context)?.size.width ?? 1000.0) -
                    dragOffset,
                0),
            curve: Curves.fastEaseInToSlowEaseOut,
          ),
        ];
      case SheetPosition.right:
        return [
          MoveEffect(
            duration: 0.3.sec,
            begin: Offset(0, 0),
            end: Offset(
                (MediaQuery.maybeOf(context)?.size.width ?? 1000.0) +
                    dragOffset,
                0),
            curve: Curves.fastEaseInToSlowEaseOut,
          ),
        ];
    }
  }

  /// Get show animation effects based on sheet position
  List<Effect> getShowEffects() {
    switch (widget.position) {
      case SheetPosition.bottom:
        return [
          MoveEffect(
            duration: 0.4.sec,
            begin:
                Offset(0, MediaQuery.maybeOf(context)?.size.height ?? 1000.0),
            end: Offset(0, 0),
            curve: Curves.fastEaseInToSlowEaseOut,
          ),
        ];
      case SheetPosition.top:
        return [
          MoveEffect(
            duration: 0.4.sec,
            begin: Offset(
                0, -(MediaQuery.maybeOf(context)?.size.height ?? 1000.0)),
            end: Offset(0, 0),
            curve: Curves.fastEaseInToSlowEaseOut,
          ),
        ];
      case SheetPosition.left:
        return [
          MoveEffect(
            duration: 0.4.sec,
            begin:
                Offset(-(MediaQuery.maybeOf(context)?.size.width ?? 1000.0), 0),
            end: Offset(0, 0),
            curve: Curves.fastEaseInToSlowEaseOut,
          ),
        ];
      case SheetPosition.right:
        return [
          MoveEffect(
            duration: 0.4.sec,
            begin: Offset(MediaQuery.maybeOf(context)?.size.width ?? 1000.0, 0),
            end: Offset(0, 0),
            curve: Curves.fastEaseInToSlowEaseOut,
          ),
        ];
    }
  }
}
