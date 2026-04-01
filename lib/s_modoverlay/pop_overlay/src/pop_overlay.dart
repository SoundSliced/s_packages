// ignore_for_file: unnecessary_import

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';
// ignore: unused_import
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:s_packages/s_modoverlay/pop_overlay/src/escape_key_listener.dart';
import 'package:s_packages/s_packages.dart';
import 'package:sizer/sizer.dart';

part 'pop_overlay_activator.dart';
part 'popoverlay_frame_design.dart';

/// Pop Overlay System
///
/// A flexible system for displaying customizable pop-up notifications, alerts,
/// and overlay UI elements with support for:
/// - Multiple overlays with automatic stacking
/// - Background blur effects
/// - Auto-dismissal with configurable durations
/// - Background tap dismissal
/// - Customizable animations
/// - Priority-based display ordering
///
/// This file contains the complete implementation of the pop overlay system,
/// including the public API, content configuration, and rendering components.
///
/// ## Mental model for new contributors
/// 1) Callers create a [PopOverlayContent] and pass it to [PopOverlay.addPop].
/// 2) The content is stored in [_controller] (and optionally [_invisibleController]).
/// 3) The activator widget (_PopOverlayActivator) listens to those controllers
///    and builds the overlay stack.
/// 4) Each overlay is rendered by _AnimatedVisibilityWrapper -> _PopupContent,
///    which handles blur, barrier, and popup animations.
/// 5) Dismissals either remove the entry or move it to the invisible list,
///    depending on [PopOverlayContent.shouldMakeInvisibleOnDismiss].
//************************************************ */
// Global State Management

/// Custom ValueNotifier for drag state that only notifies on meaningful changes
///
/// **Performance Optimization**: This custom implementation prevents unnecessary
/// notifications and rebuilds by only notifying listeners during meaningful
/// state transitions (true/false), not when setting to null.
class _DragStateNotifier extends ValueNotifier<bool?> {
  _DragStateNotifier() : super(null);

  bool? _actualValue;
  bool _isDisposed = false;
  Timer? _resetTimer;

  /// Sets the value with controlled notification behavior
  ///
  /// **Optimization**: Only triggers notifications for meaningful state changes
  void setState(bool? newValue) {
    if (_isDisposed) return;

    // Early return if value hasn't actually changed
    if (_actualValue == newValue) return;

    _actualValue = newValue;

    // Cancel any pending reset timer
    _resetTimer?.cancel();

    // Performance optimization: Only notify for true/false transitions
    // This prevents unnecessary widget rebuilds when setting to null
    if (newValue == true) {
      super.value = newValue;
    } else if (newValue == false) {
      super.value = newValue;
      // Set up a timer to reset to null after a longer delay
      _resetTimer = Timer(const Duration(milliseconds: 1500), () {
        if (!_isDisposed && _actualValue == false) {
          _actualValue = null;
          // Don't notify when setting to null to prevent rebuilds
        }
      });
    }
  }

  /// Override value getter to return the actual value
  @override
  bool? get value => _actualValue;

  /// Override value setter to use controlled notification
  @override
  set value(bool? newValue) => setState(newValue);

  /// Optimized dispose method
  @override
  void dispose() {
    // Mark disposed and cancel timers.
    _isDisposed = true;
    _resetTimer?.cancel();
    super.dispose();
  }
}

/// Main controller that manages all active pop overlays
///
/// **Performance Optimization**: Stores a list of all currently displayed overlays
/// in stack order with efficient memory management and auto-disposal.
/// The last item in the list is the one displayed on top.
final _controller = RM.inject<List<PopOverlayContent>>(
  () => <PopOverlayContent>[], // Type-safe empty list initialization
  autoDisposeWhenNotUsed: true, // Automatic memory cleanup
);

/// Controller that manages the list of invisible pop overlays
///
/// Overlays in this list remain allocated (so they can be restored quickly)
/// but are considered hidden by the rendering layer and dismiss logic.
final _invisibleController = RM.inject<List<String>>(
  () => <String>[], // Empty list of invisible overlay IDs
  autoDisposeWhenNotUsed: true,
);

void _debugPopOverlayLog(String message) {
  // Debug-only logger (stripped in release builds).
  assert(() {
    debugPrint('[PopOverlay] $message');
    return true;
  }());
}

//************************************************ */

/// Configuration class for pop overlay content and behavior
///
/// This class encapsulates all settings for how a pop overlay should appear,
/// behave, and interact with user input. It serves as the primary configuration
/// object passed to the PopOverlay.addPop method.
class PopOverlayContent {
  /// The actual widget to display within the pop overlay
  final Widget widget;

  /// Unique identifier for this pop overlay
  /// Used for finding, managing, and removing the overlay
  final String id;

  /// Whether to apply a blur effect to content behind the overlay
  final bool shouldBlurBackground;

  /// Whether tapping the background should dismiss this overlay
  /// When true, allows users to tap outside the popup to dismiss it
  final bool shouldDismissOnBackgroundTap;

  /// Optional auto-dismissal duration
  /// When provided, the overlay will automatically dismiss after this time period
  final Duration? duration;

  /// Optional callback function that runs when the overlay is dismissed
  /// Useful for cleanup or state updates after the overlay closes
  final Function? onDismissed;

  /// Color of the dismissible background barrier
  /// Only visible when shouldDismissOnBackgroundTap is true
  final Color? dismissBarrierColor;

  /// Whether to animate the popup when appearing/disappearing
  /// When false, the overlay appears and disappears instantly
  final bool shouldAnimatePopup;

  /// Internal animation controller to handle entry and exit animations
  /// Uses a boolean state: false for entry, true for exit
  final animationController = RM.inject<bool>(() => false);

  /// Internal position controller for draggable functionality
  /// Tracks the current position offset of the popup
  final positionController = RM.inject<Offset>(() => Offset.zero);

  /// Internal drag state controller using ValueNotifier for precise control
  /// Uses nullable bool: null = animations enabled, true = dragging, false = just finished dragging
  /// Only notifies listeners when transitioning to true or false, not when setting to null
  final isDraggingController = _DragStateNotifier();

  /// Timer for auto-dismissal
  /// Stored to allow cancellation when popup is manually dismissed
  Timer? _autoDismissTimer;

  final Offset? popPositionOffset;

  /// Optional offset from which the popup should animate from
  /// When provided, the popup will animate from this global position to its final position
  /// (either center or popPositionOffset if provided)
  final Offset? offsetToPopFrom;

  final EdgeInsetsGeometry? padding;

  final bool hasBoxShadow;

  final Color? frameColor;
  final double frameWidth;

  final bool isDraggeable;

  final bool shouldMakeInvisibleOnDismiss;

  /// Whether the [popPositionOffset] is a global coordinate (relative to screen top-left)
  /// or relative to the screen center (default).
  final bool useGlobalPosition;

  /// Whether the popup should start in invisible state when first added
  /// When true and shouldMakeInvisibleOnDismiss is also true, the popup will be added
  /// to the invisible list immediately upon creation
  final bool shouldStartInvisible;

  final FrameDesign? frameDesign;

  final Function? onMadeInvisible, onMadeVisible, initState;

  /// Optional callback invoked when dragging starts
  final Function? onDragStart;

  /// Optional callback invoked when dragging ends
  final Function? onDragEnd;

  /// Whether pressing the Escape key should dismiss this overlay.
  /// Defaults to `true`. Set to `false` for critical confirmation dialogs
  /// that should not be dismissed via Escape.
  final bool shouldDismissOnEscapeKey;

  /// Optional [Rect] that constrains how far the popup can be dragged
  /// from its base position. The rect values represent offset limits:
  /// - `left` / `top` = minimum offset (typically negative)
  /// - `right` / `bottom` = maximum offset (typically positive)
  ///
  /// Use `Rect.fromCenter(center: Offset.zero, width: …, height: …)`
  /// to create symmetric bounds around the original position.
  final Rect? dragBounds;

  /// Rendering order among active overlays.
  ///
  /// Higher values render above lower values.
  int stackLevel;

  /// Global activation order used to preserve show-call ordering across
  /// PopOverlay and s_modal when stack levels are equal.
  final int activationOrder;

  final Duration? popPositionAnimationDuration;

  /// Optional Animation Curve for the popup position animation
  final Curve? popPositionAnimationCurve;

  /// Optional [borderRadius] border radius for the popup
  final BorderRadiusGeometry? borderRadius;

  /// Optional [alignment] for the popup. Defaults to [Alignment.center]
  final AlignmentGeometry? alignment;

  /// Optional [TapRegion.groupId] for the popup content.
  ///
  /// When provided, the popup joins that tap region group so interactions inside
  /// the popup are treated as inside that composite region.
  final Object? tapRegionGroupId;

  /// Optional callback invoked when a tap occurs outside the popup's tap region.
  final TapRegionCallback? onTapRegionOutside;

  /// Optional callback invoked when a tap occurs inside the popup's tap region.
  final TapRegionCallback? onTapRegionInside;

  /// Hit test behavior for the optional popup [TapRegion].
  final HitTestBehavior tapRegionBehavior;

  /// Whether the popup tap region should consume outside taps in the gesture arena.
  final bool tapRegionConsumeOutsideTaps;

  /// Creates a new pop overlay content configuration
  ///
  /// Parameters:
  /// - [widget]: The widget to display in the overlay (required)
  /// - [id]: Unique identifier for this overlay (required)
  /// - [shouldBlurBackground]: Whether to blur content behind the overlay
  /// - [duration]: Time after which the overlay auto-dismisses
  /// - [shouldDismissOnBackgroundTap]: Whether tapping outside dismisses the overlay
  /// - [onDismissed]: Function called when the overlay is dismissed
  /// - [dismissBarrierColor]: Color for the background barrier when tappable
  /// - [shouldAnimatePopup]: Whether to use animations for the overlay
  /// - [popPositionOffset]: Optional offset for the popup position
  /// - [offsetToPopFrom]: Optional offset for the popup start animation position
  /// - [frameColor]: Color for the frame around the overlay content
  /// - [frameWidth]: Width of the frame around the overlay content
  /// - [isDraggeable]: Whether the popup can be dragged around the screen
  /// - [shouldMakeInvisibleOnDismiss]: Whether the popup should become invisible instead of being removed when dismissed
  /// - [shouldStartInvisible]: Whether the popup should start in invisible state (requires shouldMakeInvisibleOnDismiss to be true)
  /// - [frameDesign]: Optional frame design template to wrap the widget with a standardized UI
  /// - [alignment]: Optional alignment for the popup. Defaults to [Alignment.center]
  /// - [shouldDismissOnEscapeKey]: Whether pressing Escape should dismiss this overlay (defaults to true)
  /// - [dragBounds]: Optional [Rect] to constrain dragging within a region
  /// - [onMadeVisible]: Callback invoked when the overlay becomes visible again
  /// - [onDragStart]: Callback invoked when dragging starts
  /// - [onDragEnd]: Callback invoked when dragging ends
  /// - [tapRegionGroupId]: Optional [TapRegion.groupId] for the popup content
  /// - [onTapRegionOutside]: Optional callback for taps outside the popup tap region
  /// - [onTapRegionInside]: Optional callback for taps inside the popup tap region
  /// - [tapRegionBehavior]: Hit test behavior for the popup tap region
  /// - [tapRegionConsumeOutsideTaps]: Whether the popup tap region consumes outside taps
  PopOverlayContent({
    required this.widget,
    required this.id,
    this.shouldBlurBackground = false,
    this.duration,
    this.shouldDismissOnBackgroundTap = true,
    this.onDismissed,
    this.dismissBarrierColor,
    this.shouldAnimatePopup = true,
    this.popPositionOffset,
    this.offsetToPopFrom,
    this.padding,
    this.hasBoxShadow = true,
    this.frameColor,
    this.frameWidth = 0.5,
    this.isDraggeable = false,
    this.frameDesign,
    this.shouldMakeInvisibleOnDismiss = false,
    this.shouldStartInvisible = false,
    this.useGlobalPosition = false,
    this.onMadeInvisible,
    this.onMadeVisible,
    this.initState,
    this.shouldDismissOnEscapeKey = true,
    this.dragBounds,
    this.stackLevel = PopOverlayStackLevels.overlay,
    int? activationOrder,
    this.onDragStart,
    this.onDragEnd,
    this.popPositionAnimationDuration,
    this.popPositionAnimationCurve,
    this.borderRadius,
    this.alignment = Alignment.center,
    this.tapRegionGroupId,
    this.onTapRegionOutside,
    this.onTapRegionInside,
    this.tapRegionBehavior = HitTestBehavior.deferToChild,
    this.tapRegionConsumeOutsideTaps = false,
  }) : activationOrder = activationOrder ?? OverlayActivationOrder.next();

  /// Optimized dispose method to clean up resources
  void dispose() {
    // Cancel timers and dispose controllers owned by this overlay.
    _autoDismissTimer?.cancel();
    animationController.dispose();
    positionController.dispose();
    isDraggingController.dispose();
  }

  /// Performance check - returns true if this overlay has expensive features enabled
  bool get hasExpensiveFeatures =>
      shouldBlurBackground || shouldAnimatePopup || isDraggeable;

  /// Memory-efficient equality check for duplicate prevention
  @override
  bool operator ==(Object other) {
    // Equality is based on id to prevent duplicates.
    if (identical(this, other)) return true;
    return other is PopOverlayContent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Inherited scope used by popup content to expose a shared tap-region group.
///
/// Widgets inside a popup can read this scope and enroll their own overlay
/// surfaces into the same [TapRegion] group, which keeps interactions like
/// dropdown menus from being misclassified as outside taps.
class PopOverlayTapRegionScope extends InheritedWidget {
  final Object? tapRegionGroupId;

  const PopOverlayTapRegionScope({
    super.key,
    required this.tapRegionGroupId,
    required super.child,
  });

  static Object? maybeOf(BuildContext context) {
    // Look up the nearest PopOverlayTapRegionScope.
    return context
        .dependOnInheritedWidgetOfExactType<PopOverlayTapRegionScope>()
        ?.tapRegionGroupId;
  }

  @override
  bool updateShouldNotify(covariant PopOverlayTapRegionScope oldWidget) {
    // Notify when the group id changes.
    return oldWidget.tapRegionGroupId != tapRegionGroupId;
  }
}

/// Default rendering stack levels for pop overlays.
///
/// Higher values render above lower values.
class PopOverlayStackLevels {
  static const int overlay = 100;
  static const int critical = 1000;
}

/// Suggested stack-level bands for consistent overlay layering.
class PopOverlayStackLevelBands {
  static const int normalMin = 0;
  static const int normalMax = 499;
  static const int priorityMin = 500;
  static const int priorityMax = 999;
  static const int criticalMin = 1000;
}

//************************************************ */

/// Main API for the pop overlay system
///
/// This class provides static methods and properties for:
/// - Displaying pop overlays (`addPop`)
/// - Dismissing overlays (`removePop`)
/// - Checking overlay state (`isActive`)
/// - Auto-installing the overlay system (internal)
///
/// Usage:
/// ```dart
/// // Show a simple overlay
/// PopOverlay.addPop(PopOverlayContent(
///   id: "notification_1",
///   widget: MyNotificationWidget(),
/// ));
///
/// // Dismiss a specific overlay
/// PopOverlay.removePop("notification_1");
/// ```
class PopOverlay {
  //--------------------------------------------------//
  // Internal key for the overlay area, used for global-to-local coordinate conversion
  // (e.g. when the app is constrained by ForcePhoneSizeOnWeb / FlutterWebFrame).
  static final GlobalKey _overlayAreaKey = GlobalKey();

  //--------------------------------------------------//
  // Public accessors for pop overlay state

  /// Access to the underlying overlay controller
  ///
  /// Primarily for internal use and advanced customization.
  /// Most applications should use the simpler `addPop` and `removePop` methods.
  static Injected<List<PopOverlayContent>> get controller => _controller;
  static Injected<List<String>> get hiddenPopsController =>
      _invisibleController;

  /// Promotes the PopOverlay host entry in the root overlay.
  static void bringOverlayHostToFront({BuildContext? context}) {
    // Request the PopOverlay host to be the top overlay entry.
    _PopOverlayBootstrapper.bringToFront(context: context);
  }

  /// Returns a default frame design pop overlay for testing
  ///
  /// Useful for quick testing and demonstration
  static Widget get template => _PopOverlayWidgetCache.getOrCreate(
        'default_frame_template',
        () => const _FrameDesignTemplatePop(title: "Template"),
      );

  static Widget infoButton(
          {required String popContentId, required String info}) =>
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: SInkButton(
          onTap: (pos) => PopOverlay.addPop(
            PopOverlayContent(
              id: "info_$popContentId",
              dismissBarrierColor: Colors.black.withValues(alpha: 0.8),
              widget: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    info,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
              frameDesign: FrameDesign(
                title: "Info",
                showCloseButton: true,
                showBottomButtonBar: false,
                titleBarHeight: 30,
                height: 100,
                width: 300,
              ),
            ),
          ),
          child: Icon(Icons.info, color: Colors.blue[100]),
        ),
      );

  static Widget closeButton(String popoverlayName) =>
      _PopOverlayWidgetCache.getOrCreate(
        'closeButton_$popoverlayName',
        () => SInkButton(
          onTap: (pos) {
            // Close button respects invisible-on-dismiss behavior.
            final popContent = PopOverlay.getActiveById(popoverlayName);
            if (popContent != null && popContent.shouldMakeInvisibleOnDismiss) {
              PopOverlay._makePopOverlayInvisible(popContent);
            } else {
              PopOverlay.removePop(popoverlayName);
            }
          },
          child: Icon(Icons.close, color: Colors.red[100]),
        ),
      );

  /// Indicates whether any pop overlay is currently being shown
  ///
  /// Returns `true` if at least one overlay is active, `false` otherwise
  static bool get isActive => _controller.state.isNotEmpty;

  /// Indicates whether any pop overlay is currently being shown and visible
  ///
  /// Returns `true` if at least one overlay is active and visible (not all overlays are invisible),
  /// Returns `false` if no overlays are active OR if all active overlays are invisible
  static bool get isActiveAndVisible {
    if (_controller.state.isEmpty) return false;

    // Check if all active overlays are invisible
    final allActiveIds = _controller.state.map((overlay) => overlay.id).toSet();
    final invisibleIds = _invisibleController.state.toSet();

    // Return true if at least one active overlay is not in the invisible list
    return !allActiveIds.every((id) => invisibleIds.contains(id));
  }

  static bool isActiveById(String id) =>
      _controller.state.any((element) => element.id == id);

  /// Returns the current stack level for an active overlay ID.
  static int? getStackLevel(String id) {
    // Lookup the active overlay and return its stack level.
    final content = getActiveById(id);
    return content?.stackLevel;
  }

  /// Returns active overlay IDs sorted by effective stack level (bottom to top).
  static List<String> get activeIdsByStackOrder {
    // Return active ids ordered by effective stack (bottom -> top).
    final sorted = List<PopOverlayContent>.from(_controller.state);
    _sortPopList(sorted);
    return sorted.map((e) => e.id).toList();
  }

  /// Sets stack level for an active overlay by ID.
  ///
  /// Returns true if updated.
  static bool setStackLevel(String id, int stackLevel) {
    // Update the stack level and keep ordering consistent.
    final index = _controller.state.indexWhere((e) => e.id == id);
    if (index == -1) return false;

    _debugWarnForOverlayStackLevel(id: id, level: stackLevel);

    _controller.update<List<PopOverlayContent>>((state) {
      final idx = state.indexWhere((e) => e.id == id);
      if (idx != -1) {
        state[idx].stackLevel = stackLevel;
        PopOverlay._sortPopList(state);
      }
      return state;
    });

    return true;
  }

  /// Brings an active overlay above all current overlays.
  static bool bringToFront(String id, {int step = 1}) {
    // Raise an overlay above the current topmost entry.
    final current = getStackLevel(id);
    if (current == null) return false;
    final top = _controller.state
        .map((e) => _effectiveStackLevel(e))
        .fold<int>(current, (prev, next) => next > prev ? next : prev);
    return setStackLevel(id, top + (step < 1 ? 1 : step));
  }

  /// Sends an active overlay below all current overlays.
  static bool sendToBack(String id, {int step = 1}) {
    // Push an overlay below the current bottom entry.
    final current = getStackLevel(id);
    if (current == null) return false;
    final bottom = _controller.state
        .map((e) => _effectiveStackLevel(e))
        .fold<int>(current, (prev, next) => next < prev ? next : prev);
    return setStackLevel(id, bottom - (step < 1 ? 1 : step));
  }

  static PopOverlayContent? getActiveById(String id) {
    // Retrieve active overlay by id, if present.
    if (isActiveById(id)) {
      return _controller.state.firstWhere((element) => element.id == id);
    }
    return null;
  }

  /// Returns `true` if the overlay with [id] is both active and currently visible
  /// (i.e. not in the invisible list).
  static bool isVisibleById(String id) =>
      isActiveById(id) && !_invisibleController.state.contains(id);

  /// Returns only the currently visible (non-invisible) overlays.
  static List<PopOverlayContent> getVisiblePops() => _controller.state
      .where((o) => !_invisibleController.state.contains(o.id))
      .toList();

  /// Returns only the currently invisible overlays.
  static List<PopOverlayContent> getInvisiblePops() => _controller.state
      .where((o) => _invisibleController.state.contains(o.id))
      .toList();

  /// The number of currently visible overlays.
  static int get visibleCount => getVisiblePops().length;

  /// The number of currently invisible overlays.
  static int get invisibleCount => getInvisiblePops().length;

  /// The newest activation order among active pop overlays.
  static int get latestActivationOrder {
    // Return newest activation order (or -1 if empty).
    if (_controller.state.isEmpty) return -1;
    return _controller.state
        .map((content) => content.activationOrder)
        .reduce(max);
  }

  //--------------------------------------------------//
  // Core Pop Overlay functionality

  /// Displays a pop overlay on screen
  ///
  /// This is the main entry point for showing overlays in the application.
  ///
  /// Features:
  /// - Prevents duplicate overlays (checks by ID)
  /// - Automatically sorts overlays based on priority rules
  /// - Supports auto-dismissal when duration is provided
  ///
  /// Parameters:
  /// - `popContent`: The [PopOverlayContent] configuration for the overlay.
  ///
  /// Example:
  /// ```dart
  /// // Show a notification overlay
  /// PopOverlay.addPop(PopOverlayContent(
  ///   id: "notification_1",
  ///   widget: NotificationWidget(message: "Update complete"),
  ///   duration: Duration(seconds: 3),
  ///   shouldDismissOnBackgroundTap: true,
  /// ));
  /// ```
  static void addPop(PopOverlayContent popContent, {BuildContext? context}) {
    // Main entrypoint for showing a popup.
    // Ensure the overlay system is installed before adding content
    _PopOverlayBootstrapper.ensureInstalled(context: context);
    // If s_modal is active and interleaving is disabled, we later promote
    // the overlay host to ensure the new popup is visually on top.
    final shouldPromoteHost =
        Modal.isActive && !OverlayInterleaveManager.enabled;

    _debugPopOverlayLog(
      'addPop(start) id=${popContent.id} stack=${popContent.stackLevel} '
      'active=${_controller.state.map((e) => e.id).toList()} '
      'invisible=${_invisibleController.state}',
    );

    _debugWarnForOverlayStackLevel(
        id: popContent.id, level: popContent.stackLevel);

    // Check if the overlay is already active but invisible
    if (PopOverlay.isActiveById(popContent.id) &&
        _invisibleController.state.contains(popContent.id)) {
      // Re-show an existing invisible overlay (refresh if needed).
      final existingOverlay = PopOverlay.getActiveById(popContent.id);
      if (existingOverlay != null) {
        // Check if offsetToPopFrom has changed
        final hasOffsetChanged =
            existingOverlay.offsetToPopFrom != popContent.offsetToPopFrom;
        final hasStackLevelChanged =
            existingOverlay.stackLevel != popContent.stackLevel;

        _debugPopOverlayLog(
          'addPop(existing-invisible) id=${popContent.id} '
          'offsetChanged=$hasOffsetChanged stackChanged=$hasStackLevelChanged',
        );

        if (hasOffsetChanged || hasStackLevelChanged) {
          // Replace the existing overlay instance to update properties.
          // Replace the existing overlay with the new one (which has updated offsetToPopFrom)
          _controller.update<List<PopOverlayContent>>((state) {
            final index =
                state.indexWhere((element) => element.id == popContent.id);
            if (index != -1) {
              final previousOverlay = state[index];

              // Copy the animation and position controllers from the old popup to the new one
              popContent.animationController.state =
                  existingOverlay.animationController.state;
              popContent.positionController.state =
                  existingOverlay.positionController.state;
              popContent.isDraggingController.value =
                  existingOverlay.isDraggingController.value;

              // Replace the old popup with the new one
              state[index] = popContent;

              // Keep ordering aligned with stack levels.
              PopOverlay._sortPopList(state);

              // Prevent leaks from the replaced instance.
              previousOverlay.dispose();
            }
            return state;
          });
        }

        // Make the overlay visible (either the updated one or the existing one)
        final overlayToShow = (hasOffsetChanged || hasStackLevelChanged)
            ? popContent
            : existingOverlay;
        PopOverlay._makePopOverlayVisible(overlayToShow);
        _registerInterleavedLayerForPop(overlayToShow, context: context);
        _debugPopOverlayLog(
          'addPop(existing-invisible) id=${popContent.id} '
          'madeVisible=${overlayToShow.id} active=${_controller.state.map((e) => e.id).toList()} '
          'invisible=${_invisibleController.state}',
        );
        if (shouldPromoteHost) {
          _PopOverlayBootstrapper.bringToFront();
        }
      }
      return;
    }

    // If an overlay with this ID is already active and visible,
    // treat this call as a refresh/re-show instead of a no-op.
    if (PopOverlay.isActiveById(popContent.id)) {
      // Refresh an already-visible overlay by replacing its content.
      popContent.initState?.call();

      _controller.update<List<PopOverlayContent>>((state) {
        final index =
            state.indexWhere((element) => element.id == popContent.id);
        if (index != -1) {
          final previousOverlay = state[index];
          state[index] = popContent;
          PopOverlay._sortPopList(state);
          previousOverlay.dispose();
        }
        return state;
      });

      _invisibleController.update<List<String>>((state) {
        state.remove(popContent.id);
        return state;
      });

      _registerInterleavedLayerForPop(popContent, context: context);
      _debugPopOverlayLog(
        'addPop(existing-visible-refresh) id=${popContent.id} active=${_controller.state.map((e) => e.id).toList()}',
      );

      if (shouldPromoteHost) {
        _PopOverlayBootstrapper.bringToFront();
      }
      return;
    }

    // Only add if an overlay with this ID doesn't already exist
    if (PopOverlay.isActiveById(popContent.id) == false) {
      // Create a brand-new overlay entry.
      // If onBeforeCreatingPop callback is provided, call it before adding the overlay
      popContent.initState?.call();

      // Update the controller's state with the new overlay
      _controller.update<List<PopOverlayContent>>((state) {
        // Add the new overlay to the list
        state.add(popContent);

        // // Sort the list based on priority rules
        PopOverlay._sortPopList(state);
        _debugPopOverlayLog(
          'addPop(added) id=${popContent.id} sortedActive=${state.map((e) => e.id).toList()}',
        );
        return state;
      });

      _registerInterleavedLayerForPop(popContent, context: context);

      // If shouldStartInvisible is true and shouldMakeInvisibleOnDismiss is also true,
      // immediately make the popup invisible
      if (popContent.shouldStartInvisible &&
          popContent.shouldMakeInvisibleOnDismiss) {
        // Immediately hide if configured to start invisible.
        PopOverlay._makePopOverlayInvisible(popContent);
      }

      // Handle auto-dismissal if duration is specified
      if (popContent.duration != null) {
        // Auto-dismiss after the configured duration.
        // Cancel any existing timer for this popup
        popContent._autoDismissTimer?.cancel();

        // Create a new timer for auto-dismissal
        popContent._autoDismissTimer = Timer(popContent.duration!, () {
          // Timer fired: dismiss if still active and visible.
          _debugPopOverlayLog(
            'autoDismiss fired id=${popContent.id} active=${PopOverlay.isActiveById(popContent.id)} '
            'invisible=${_invisibleController.state.contains(popContent.id)}',
          );
          // Check if popup still exists and is visible before dismissing
          if (PopOverlay.isActiveById(popContent.id) &&
              !_invisibleController.state.contains(popContent.id)) {
            if (popContent.shouldMakeInvisibleOnDismiss) {
              _makePopOverlayInvisible(popContent);
              popContent.onDismissed?.call();
            } else {
              removePop(popContent.id);
            }
          }
        });
      }

      if (shouldPromoteHost) {
        _PopOverlayBootstrapper.bringToFront();
      }
    }
  }

  //--------------------------------------------------//

  /// Dismisses a specific pop overlay by ID
  ///
  /// This method handles the complete dismissal process including:
  /// - Triggering exit animations
  /// - Removing the overlay from the controller
  /// - Running any registered dismissal callbacks
  /// - Re-sorting the remaining overlays
  ///
  /// The dismissal is animated, with a short delay to allow
  /// animations to complete before removing the overlay from the list.
  ///
  /// Parameters:
  /// - `id`: The unique identifier of the overlay to dismiss
  ///
  /// Example:
  /// ```dart
  /// // Dismiss the notification overlay
  /// PopOverlay.removePop("notification_1");
  /// ```
  static void removePop(String id) {
    // Dismiss an overlay by id with animation.
    // Early return if no overlay with this ID exists
    if (PopOverlay.isActiveById(id) == false) {
      _debugPopOverlayLog('removePop(skip) id=$id not active');
      return;
    }

    _debugPopOverlayLog(
      'removePop(start) id=$id active=${_controller.state.map((e) => e.id).toList()} '
      'invisible=${_invisibleController.state}',
    );

    // Find the popup content by ID
    final popupIndex =
        _controller.state.indexWhere((element) => element.id == id);
    if (popupIndex != -1) {
      final popContent = _controller.state[popupIndex];

      _debugPopOverlayLog(
        'removePop(found) id=$id shouldMakeInvisible=${popContent.shouldMakeInvisibleOnDismiss} '
        'isAnimated=${popContent.shouldAnimatePopup}',
      );

      // Trigger the exit animation by setting the animation controller state
      popContent.animationController.state = true;

      // Wait for the animation to finish before removing from the list
      // This creates a smooth dismissal experience
      Future.delayed(const Duration(milliseconds: 450), () {
        // Wait for exit animation to finish before removing.
        // Delay avoids tearing during exit animations. We also re-check the
        // identity to prevent removing a newer overlay that reused the same id.
        // Double-check that the same overlay instance still exists.
        // This prevents a delayed dismissal from removing a newer overlay
        // that reused the same ID after the original one started exiting.
        final currentOverlay = PopOverlay.getActiveById(id);
        _debugPopOverlayLog(
          'removePop(delay-finished) id=$id currentOverlay=${currentOverlay?.id} '
          'sameInstance=${identical(currentOverlay, popContent)}',
        );
        if (identical(currentOverlay, popContent)) {
          _controller.update<List<PopOverlayContent>>((state) {
            // Remove the overlay and call its dismissal callback
            state.removeWhere((element) {
              if (element.id == id) {
                // Execute the onDismissed callback if provided
                element.onDismissed?.call();
                // Clean up resources
                element.dispose();
              }
              return element.id == id;
            });
            _unregisterInterleavedLayerForPopId(id);

            // Remove the overlay from the invisible list
            //if it's being dismissed
            _invisibleController.update<List<String>>((invisibleState) {
              invisibleState.remove(id);

              return invisibleState;
            });

            // Re-sort the remaining overlays
            PopOverlay._sortPopList(state);
            _debugPopOverlayLog(
              'removePop(done) id=$id remaining=${state.map((e) => e.id).toList()} '
              'invisible=${_invisibleController.state}',
            );
            final popLatest = PopOverlay.latestActivationOrder;
            final modalLatest = Modal.latestActivationOrder;
            // Promote whichever system has the newest activation when not interleaving.
            if (!OverlayInterleaveManager.enabled && modalLatest > popLatest) {
              Modal.bringOverlayHostToFront();
            } else if (!OverlayInterleaveManager.enabled &&
                popLatest > modalLatest) {
              PopOverlay.bringOverlayHostToFront();
            }
            return state;
          });
        }
      });
    }
  }

  /// Dismisses a popup respecting its shouldMakeInvisibleOnDismiss setting
  ///
  /// This method automatically checks if the popup should be made invisible
  /// or completely removed based on its shouldMakeInvisibleOnDismiss flag.
  ///
  /// Parameters:
  /// - `id`: The unique identifier of the overlay to dismiss
  static void dismissPop(String id) {
    // Dismiss while respecting shouldMakeInvisibleOnDismiss.
    final popContent = getActiveById(id);
    if (popContent != null) {
      if (popContent.shouldMakeInvisibleOnDismiss) {
        _makePopOverlayInvisible(popContent);
      } else {
        removePop(id);
      }
    }
  }

  /// Dismisses all active pop overlays, respecting each overlay's
  /// `shouldMakeInvisibleOnDismiss` setting.
  ///
  /// Overlays with `shouldMakeInvisibleOnDismiss` set to `true` will be made
  /// invisible rather than removed. All other overlays will be fully removed.
  ///
  /// If [includeInvisible] is `true`, overlays that are already invisible
  /// will also be fully removed.
  ///
  /// Example:
  /// ```dart
  /// PopOverlay.dismissAllPops();
  /// PopOverlay.dismissAllPops(includeInvisible: true);
  /// ```
  static void dismissAllPops(
      {bool includeInvisible = false, List<String> except = const []}) {
    // Dismiss multiple overlays, optionally including hidden ones.
    if (includeInvisible) {
      // Remove all overlays including invisible ones
      final allIds = _controller.state
          .map((overlay) => overlay.id)
          .where((id) => !except.contains(id))
          .toList();
      for (final id in allIds) {
        removePop(id);
      }
    } else {
      // Only dismiss visible overlays, respecting shouldMakeInvisibleOnDismiss
      final visibleIds = _controller.state
          .where((overlay) =>
              !_invisibleController.state.contains(overlay.id) &&
              !except.contains(overlay.id))
          .map((overlay) => overlay.id)
          .toList();
      for (final id in visibleIds) {
        dismissPop(id);
      }
    }
  }

  /// Atomically replaces an existing overlay with a new one.
  ///
  /// The overlay identified by [id] is removed (without animation) and
  /// [newContent] is added in its place. If no overlay with [id] exists,
  /// [newContent] is simply added.
  static void replacePop(String id, PopOverlayContent newContent) {
    // Replace an existing overlay without running exit animations.
    if (isActiveById(id)) {
      // Remove old overlay immediately without animation
      _controller.update<List<PopOverlayContent>>((state) {
        state.removeWhere((element) {
          if (element.id == id) {
            _unregisterInterleavedLayerForPopId(element.id);
            element.dispose();
          }
          return element.id == id;
        });
        return state;
      });
      _invisibleController.update<List<String>>((state) {
        state.remove(id);
        return state;
      });
    }
    addPop(newContent);
  }

  //--------------------------------------------------//
  static void _makePopOverlayInvisible(PopOverlayContent popContent) {
    // Move the overlay to the invisible list (keeps it allocated).
    // Find the popup content by ID
    if (PopOverlay.isActiveById(popContent.id)) {
      final popupIndex = PopOverlay.controller.state
          .indexWhere((element) => element.id == popContent.id);
      if (popupIndex > -1) {
        // Cancel the auto-dismiss timer when manually dismissing
        popContent._autoDismissTimer?.cancel();

        // Trigger fade-out animation if animations are enabled
        if (popContent.shouldAnimatePopup) {
          popContent.animationController.state = true;
        }

        _invisibleController.update<List<String>>((state) {
          if (!state.contains(popContent.id)) {
            state.add(popContent.id);
            popContent.onMadeInvisible?.call();
            _debugPopOverlayLog(
              '_makePopOverlayInvisible id=${popContent.id} invisible=$state',
            );
          }
          return state;
        });
      }
    }
  }

  static void _makePopOverlayVisible(PopOverlayContent popContent) {
    // Remove the overlay from the invisible list and re-animate entry.
    // Find the popup content by ID
    if (PopOverlay.isActiveById(popContent.id)) {
      final popupIndex = PopOverlay.controller.state
          .indexWhere((element) => element.id == popContent.id);
      if (popupIndex > -1) {
        // Reset animation controller to trigger entrance animation
        popContent.animationController.state = false;

        _invisibleController.update<List<String>>((state) {
          state.remove(popContent.id);
          popContent.onMadeVisible?.call();
          _debugPopOverlayLog(
            '_makePopOverlayVisible id=${popContent.id} invisible=$state',
          );
          return state;
        });
      }
    }
  }

  /// Access to the invisible overlays controller for reactive updates
  static Injected<List<String>> get invisibleController => _invisibleController;

  //--------------------------------------------------//

  /* 
    Functionality Check
      1.	“NoInternetConnectionPopup” Always Last:
          •	The function searches for the index of `"NoInternetConnectionPopup"`.
          •	If it exists, it removes the element from its current position and appends it to the end of the list.
          •	This ensures that `"NoInternetConnectionPopup"` is always at the last position.
      2.	"Database Offline" Second to Last (if “NoInternetConnectionPopup” Exists):
          •	The function searches for `"Database Offline"`.
          •	If it exists, it removes the element from its current position.
          •	It checks if `"NoInternetConnectionPopup"` exists:
          •	If true, `"Database Offline"` is inserted at the second-to-last position.
          •	Otherwise, it is appended to the end of the list.
          •	This ensures that `"Database Offline"` is second to last if `"NoInternetConnectionPopup"` exists or last if it does not.
      3.	“UnderMaintenancePopup” Third to Last (if Both Other Popups Exist):
          •	The function searches for `"UnderMaintenancePopup"`.
          •	If it exists, it removes the element from its current position.
          •	It checks whether `"NoInternetConnectionPopup"` and `"Database Offline"` exist:
          •	If both exist, `"UnderMaintenancePopup"` is inserted at the third-to-last position.
          •	If only one exists, `"UnderMaintenancePopup"` is inserted at the second-to-last position.
          •	If neither exists, `"UnderMaintenancePopup"` is appended to the end of the list.
          •	This ensures that `"UnderMaintenancePopup"` is correctly positioned based on the existence of other popups.
    */

  // Legacy priority bonuses to preserve historical overlay ordering behavior.
  // These are additive to stackLevel and can still be overridden via explicit stack levels.
  static const Map<String, int> _legacyPriorityBonuses = {
    "UnderMaintenancePopup": 700,
    "Database Offline": 800,
    "NoInternetConnectionPopup": 900,
  };

  static int _effectiveStackLevel(PopOverlayContent content) {
    // Apply legacy priority bonuses to the configured stack level.
    return content.stackLevel + (_legacyPriorityBonuses[content.id] ?? 0);
  }

  static String _interleavedLayerIdFor(String id) => 'pop:$id';

  static void _registerInterleavedLayerForPop(
    PopOverlayContent popContent, {
    BuildContext? context,
  }) {
    if (!OverlayInterleaveManager.enabled) return;

    // Register a lightweight layer into the shared interleave host.
    OverlayInterleaveManager.registerLayer(
      id: _interleavedLayerIdFor(popContent.id),
      activationOrder: popContent.activationOrder,
      stackLevel: _effectiveStackLevel(popContent),
      context: context,
      builder: () => _InterleavedPopLayer(popId: popContent.id),
    );
  }

  static void _unregisterInterleavedLayerForPopId(String id) {
    if (!OverlayInterleaveManager.enabled) return;
    // Remove the interleaved layer for this overlay.
    OverlayInterleaveManager.unregisterLayer(_interleavedLayerIdFor(id));
  }

  static void _debugWarnForOverlayStackLevel(
      {required String id, required int level}) {
    // Always keep this lightweight and debug-only.
    assert(() {
      // Warn when using critical band outside legacy ids.
      if (level >= PopOverlayStackLevelBands.criticalMin &&
          !_legacyPriorityBonuses.containsKey(id)) {
        debugPrint(
          'PopOverlay stack level warning: id=$id, level=$level is in CRITICAL band. '
          'Reserve critical levels for blocking/system overlays.',
        );
      }
      return true;
    }());
  }

  // Sort the list of popups based on priority - OPTIMIZED VERSION
  static void _sortPopList(List<PopOverlayContent> list) {
    // Sort by effective stack level, then activation order, then insertion.
    // Early return if list is empty or has only one element
    if (list.length <= 1) return;

    // Stable sort: lower effective levels first (rendered below), preserving insertion order on ties.
    final indexed = list.asMap().entries.toList();
    indexed.sort((a, b) {
      final aLevel = _effectiveStackLevel(a.value);
      final bLevel = _effectiveStackLevel(b.value);
      final byLevel = aLevel.compareTo(bLevel);
      if (byLevel != 0) return byLevel;
      final byOrder =
          a.value.activationOrder.compareTo(b.value.activationOrder);
      if (byOrder != 0) return byOrder;
      return a.key.compareTo(b.key);
    });

    list
      ..clear()
      ..addAll(indexed.map((e) => e.value));
  }

  //-------------------------------------------------//

  /// Performance monitoring - returns metrics about current overlays
  static Map<String, dynamic> get performanceMetrics {
    // Gather lightweight overlay stats for profiling.
    final overlays = _controller.state;
    final expensiveOverlays =
        overlays.where((o) => o.hasExpensiveFeatures).length;

    return {
      'totalOverlays': overlays.length,
      'expensiveOverlays': expensiveOverlays,
      'memoryEfficient': expensiveOverlays == 0,
      'activeBlurEffects': overlays.where((o) => o.shouldBlurBackground).length,
      'draggableOverlays': overlays.where((o) => o.isDraggeable).length,
      'animatedOverlays': overlays.where((o) => o.shouldAnimatePopup).length,
    };
  }

  /// Batch removal of multiple overlays for better performance
  static void removeMultiplePops(List<String> ids) {
    if (ids.isEmpty) return;

    // Remove multiple overlays in one controller update.
    _controller.update<List<PopOverlayContent>>((state) {
      // Find overlays to remove and clean them up
      final toRemove = <PopOverlayContent>[];
      for (final element in state) {
        if (ids.contains(element.id)) {
          element.onDismissed?.call();
          element.dispose();
          toRemove.add(element);
        }
      }

      // Remove all at once for better performance
      for (final element in toRemove) {
        _unregisterInterleavedLayerForPopId(element.id);
        state.remove(element);
      }

      // Re-sort the remaining overlays
      PopOverlay._sortPopList(state);
      return state;
    });

    // Remove these overlays from the invisible list as well
    _invisibleController.update<List<String>>((state) {
      for (final id in ids) {
        state.remove(id);
      }
      return state;
    });
  }

  /// Clear all overlays efficiently
  static void clearAll() {
    // Clear overlays and cached widgets.
    _controller.update<List<PopOverlayContent>>((state) {
      // Dispose all overlays first
      for (final overlay in state) {
        _unregisterInterleavedLayerForPopId(overlay.id);
      }
      for (final overlay in state) {
        overlay.dispose();
      }
      // Clear the widget cache
      _PopOverlayWidgetCache.clear();
      // Clear the list
      state.clear();
      return state;
    });

    // Clear the invisible overlays list
    _invisibleController.update<List<String>>((state) {
      state.clear();
      return state;
    });
  }
}

/// Internal bootstrapper that installs the PopOverlay activator into the root overlay.
class _PopOverlayBootstrapper {
  static OverlayEntry? _entry;
  static bool _installScheduled = false;

  static void ensureInstalled({BuildContext? context}) {
    // Lazily install the PopOverlay OverlayEntry.
    // If an entry already exists, keep it unless we can prove it's stale.
    if (_entry != null) {
      if (_entry!.mounted) return;
      if (_installScheduled) return;
      _entry = null;
    }

    if (_installScheduled) return;
    _installScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Complete installation after the current frame.
      _installScheduled = false;

      // Another call may have installed the entry while this callback queued.
      if (_entry != null) return;

      final overlayState = _resolveRootOverlay(context);
      if (overlayState == null) return;

      final entry = OverlayEntry(
          maintainState: true,
          builder: (context) => const _PopOverlayBootstrapperEntry());

      overlayState.insert(entry);
      _entry = entry;
    });
  }

  static void bringToFront({BuildContext? context}) {
    // Promote the overlay host entry.
    final entry = _entry;
    if (entry == null) {
      _debugPopOverlayLog('bringToFront: no entry, calling ensureInstalled');
      ensureInstalled(context: context);
      return;
    }

    final overlayState = _resolveRootOverlay(context);
    if (overlayState == null) {
      _debugPopOverlayLog('bringToFront: overlayState is null, skipping');
      return;
    }

    _debugPopOverlayLog(
        'bringToFront: rearranging entry mounted=${entry.mounted}');
    if (entry.mounted) {
      // Deterministically promote by re-inserting the same entry at top.
      entry.remove();
      overlayState.insert(entry);
      return;
    }

    // Entry not mounted. If install is queued, let it finish.
    if (_installScheduled) return;

    // Recover from stale unmounted references.
    _entry = null;
    ensureInstalled(context: context);
  }

  static OverlayState? _resolveRootOverlay(BuildContext? context) {
    // Resolve the most appropriate root overlay.
    if (context != null) {
      final rootOverlay = Overlay.maybeOf(context, rootOverlay: true);
      if (rootOverlay != null) return rootOverlay;

      // Fallback to the nearest overlay only if a root overlay is unavailable.
      // This keeps PopOverlay aligned with s_modal when both packages are active,
      // while still allowing local overlays in unusual embedding scenarios.
      final nearestOverlay = Overlay.maybeOf(context, rootOverlay: false);
      if (nearestOverlay != null) return nearestOverlay;
    }

    final rootElement = WidgetsBinding.instance.rootElement;
    if (rootElement == null) return null;

    // When no context is supplied, prefer the true root overlay first.
    // This avoids accidentally attaching to nested Navigator overlays such as
    // the one created by s_modal's app builder wrapper.
    final rootOverlay = Overlay.maybeOf(rootElement, rootOverlay: true);
    if (rootOverlay != null) return rootOverlay;

    OverlayState? found;

    void visit(Element element) {
      // DFS search for any overlay as a last resort.
      if (found != null) return;
      if (element is StatefulElement && element.state is OverlayState) {
        found = element.state as OverlayState;
        return;
      }
      element.visitChildElements(visit);
    }

    visit(rootElement);
    return found;
  }
}

/// Overlay entry content that hosts the PopOverlay activator without intercepting taps when idle.
class _PopOverlayBootstrapperEntry extends StatelessWidget {
  const _PopOverlayBootstrapperEntry();

  @override
  Widget build(BuildContext context) {
    // Watch both active and invisible controllers.
    return OnBuilder(
      listenTo: PopOverlay.controller,
      builder: () {
        return OnBuilder(
          listenTo: PopOverlay.invisibleController,
          builder: () {
            _debugPopOverlayLog(
              '_PopOverlayBootstrapperEntry build active=${PopOverlay.controller.state.map((e) => e.id).toList()} '
              'invisible=${PopOverlay.invisibleController.state} visible=${PopOverlay.isActiveAndVisible} '
              'interleave=${OverlayInterleaveManager.enabled}',
            );

            if (OverlayInterleaveManager.enabled) {
              // Ensure interleave host is installed and keep legacy host inert.
              // Fallback install path: addPop calls may not pass a BuildContext.
              // Bootstrapper entry is mounted in a real overlay, so its context
              // can always resolve the correct root overlay for the interleave host.
              OverlayInterleaveManager.ensureInstalled(context: context);

              // Interleaved mode renders PopOverlay layers via OverlayInterleaveManager.
              // Keep this legacy host inert to avoid duplicate layering/hit testing.
              return const IgnorePointer(
                ignoring: true,
                child: SizedBox.shrink(),
              );
            }

            return IgnorePointer(
              ignoring: !PopOverlay.isActiveAndVisible,
              child: _PopOverlayActivator(child: const SizedBox.shrink()),
            );
          },
        );
      },
    );
  }
}

/// Optimized widget cache for better memory management
///
/// This cache is used internally to optimize widget creation for frequently
/// created widgets like close buttons and template widgets.
class _PopOverlayWidgetCache {
  static final Map<String, Widget> _cache = {};
  static const int _maxCacheSize = 10;

  /// Get a cached widget or create a new one
  ///
  /// Used internally by closeButton() and template getter to avoid
  /// recreating the same widgets repeatedly.
  static Widget getOrCreate(String key, Widget Function() factory) {
    // Return cached widget if it exists.
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    // Clear cache if it gets too large
    if (_cache.length >= _maxCacheSize) {
      // Simple eviction strategy: clear all when full.
      _cache.clear();
    }

    final widget = factory();
    _cache[key] = widget;
    return widget;
  }

  /// Clear the cache
  static void clear() => _cache.clear();
}

//************************************************ */

/// Default template for pop overlays used for testing and demonstration
///
/// This widget provides a simple styled notification popup with:
/// - Red background with semi-transparency
/// - Border styling and drop shadow
/// - Centered text content
/// - Built-in slide animation
///
/// This template is used when calling `PopOverlay.template` and serves
/// as a quick way to test the pop overlay system without creating custom widgets.
class _FrameDesignTemplatePop extends StatelessWidget {
  /// The text to display in the template pop overlay
  final String title;

  // ignore: unused_element
  /// Creates a new template pop overlay with the specified title
  // ignore: unused_element_parameter
  const _FrameDesignTemplatePop({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // Build the template popup UI with a simple entry animation.
    return SInkButton(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          //background overlay
          SizedBox(
            height: 100.h,
            width: 100.w,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: Colors.red.shade900.withValues(alpha: 0.3)),
              child: const SizedBox(),
            ),
          ),

          //popup
          Container(
            height: 70,
            width: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.red.shade300.withValues(alpha: 0.9),
              border: Border.all(color: Colors.red.shade700, width: 0.5),
              boxShadow: const [
                BoxShadow(
                    offset: Offset(0, 5), blurRadius: 15, spreadRadius: -10)
              ],
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ).animate(
            effects: [
              MoveEffect(
                  duration: 0.4.sec,
                  begin: Offset(0, 0),
                  end: Offset(0, 70),
                  curve: Curves.easeInBack)
            ],
          ),
        ],
      ),
    );
  }
}

//************************************************ */
