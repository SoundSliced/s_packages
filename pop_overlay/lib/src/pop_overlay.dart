// ignore_for_file: unnecessary_import

import 'dart:async';
import 'dart:ui' as ui;
import 'dart:ui';
// ignore: unused_import
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pop_overlay/src/escape_key_listener.dart';
import 'package:s_disabled/s_disabled.dart';
import 'package:s_future_button/s_future_button.dart';
import 'package:s_ink_button/s_ink_button.dart';
import 'package:s_offstage/s_offstage.dart';
import 'package:s_widgets/s_widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';
import 'package:soundsliced_tween_animation_builder/soundsliced_tween_animation_builder.dart';
import 'package:states_rebuilder_extended/states_rebuilder_extended.dart';
import 'package:ticker_free_circular_progress_indicator/ticker_free_circular_progress_indicator.dart';

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
final _invisibleController = RM.inject<List<String>>(
  () => <String>[], // Empty list of invisible overlay IDs
  autoDisposeWhenNotUsed: true,
);

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

  /// Whether the popup should start in invisible state when first added
  /// When true and shouldMakeInvisibleOnDismiss is also true, the popup will be added
  /// to the invisible list immediately upon creation
  final bool shouldStartInvisible;

  final FrameDesign? frameDesign;

  final Function? onMadeInvisible, initState;

  final Duration? popPositionAnimationDuration;

  /// Optional [borderRadius] border radius for the popup
  final BorderRadiusGeometry? borderRadius;

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
  /// - [offsetToPopFrom]: Optional offset from which the popup should animate from (global position)
  /// - [frameColor]: Color for the frame around the overlay content
  /// - [frameWidth]: Width of the frame around the overlay content
  /// - [isDraggeable]: Whether the popup can be dragged around the screen
  /// - [shouldMakeInvisibleOnDismiss]: Whether the popup should become invisible instead of being removed when dismissed
  /// - [shouldStartInvisible]: Whether the popup should start in invisible state (requires shouldMakeInvisibleOnDismiss to be true)
  /// - [frameDesign]: Optional frame design template to wrap the widget with a standardized UI
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
    this.isDraggeable = true,
    this.frameDesign,
    this.shouldMakeInvisibleOnDismiss = false,
    this.shouldStartInvisible = false,
    this.onMadeInvisible,
    this.initState,
    this.popPositionAnimationDuration,
    this.borderRadius,
  });

  /// Optimized dispose method to clean up resources
  void dispose() {
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
    if (identical(this, other)) return true;
    return other is PopOverlayContent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
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
  // Public accessors for pop overlay state

  /// Access to the underlying overlay controller
  ///
  /// Primarily for internal use and advanced customization.
  /// Most applications should use the simpler `addPop` and `removePop` methods.
  static Injected<List<PopOverlayContent>> get controller => _controller;
  static Injected<List<String>> get hiddenPopsController =>
      _invisibleController;

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
          onTap: (pos) => PopOverlay.addPop(PopOverlayContent(
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
                    fontWeight: FontWeight.normal,
                  ),
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
          )),
          child: Icon(
            Icons.info,
            color: Colors.blue[100],
          ),
        ),
      );

  static Widget closeButton(String popoverlayName) =>
      _PopOverlayWidgetCache.getOrCreate(
        'closeButton_$popoverlayName',
        () => SInkButton(
          onTap: (pos) {
            final popContent = PopOverlay.getActiveById(popoverlayName);
            if (popContent != null && popContent.shouldMakeInvisibleOnDismiss) {
              PopOverlay._makePopOverlayInvisible(popContent);
            } else {
              PopOverlay.removePop(popoverlayName);
            }
          },
          child: Icon(
            Icons.close,
            color: Colors.red[100],
          ),
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

  static PopOverlayContent? getActiveById(String id) {
    if (isActiveById(id)) {
      return _controller.state.firstWhere((element) => element.id == id);
    }
    return null;
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
    // Ensure the overlay system is installed before adding content
    _PopOverlayBootstrapper.ensureInstalled(context: context);

    // Check if the overlay is already active but invisible
    if (PopOverlay.isActiveById(popContent.id) &&
        _invisibleController.state.contains(popContent.id)) {
      final existingOverlay = PopOverlay.getActiveById(popContent.id);
      if (existingOverlay != null) {
        // Check if offsetToPopFrom has changed
        final hasOffsetChanged =
            existingOverlay.offsetToPopFrom != popContent.offsetToPopFrom;

        if (hasOffsetChanged) {
          // Replace the existing overlay with the new one (which has updated offsetToPopFrom)
          _controller.update<List<PopOverlayContent>>((state) {
            final index =
                state.indexWhere((element) => element.id == popContent.id);
            if (index != -1) {
              // Copy the animation and position controllers from the old popup to the new one
              popContent.animationController.state =
                  existingOverlay.animationController.state;
              popContent.positionController.state =
                  existingOverlay.positionController.state;
              popContent.isDraggingController.value =
                  existingOverlay.isDraggingController.value;

              // Replace the old popup with the new one
              state[index] = popContent;
            }
            return state;
          });
        }

        // Make the overlay visible (either the updated one or the existing one)
        final overlayToShow = hasOffsetChanged ? popContent : existingOverlay;
        PopOverlay._makePopOverlayVisible(overlayToShow);
      }
      return;
    }

    // Only add if an overlay with this ID doesn't already exist
    if (PopOverlay.isActiveById(popContent.id) == false) {
      // If onBeforeCreatingPop callback is provided, call it before adding the overlay
      popContent.initState?.call();

      // Update the controller's state with the new overlay
      _controller.update<List<PopOverlayContent>>((state) {
        // Add the new overlay to the list
        state.add(popContent);

        // // Sort the list based on priority rules
        PopOverlay._sortPopList(state);
        return state;
      });

      // If shouldStartInvisible is true and shouldMakeInvisibleOnDismiss is also true,
      // immediately make the popup invisible
      if (popContent.shouldStartInvisible &&
          popContent.shouldMakeInvisibleOnDismiss) {
        PopOverlay._makePopOverlayInvisible(popContent);
      }

      // Handle auto-dismissal if duration is specified
      if (popContent.duration != null) {
        // Cancel any existing timer for this popup
        popContent._autoDismissTimer?.cancel();

        // Create a new timer for auto-dismissal
        popContent._autoDismissTimer = Timer(popContent.duration!, () {
          // Check if popup still exists and is visible before dismissing
          if (PopOverlay.isActiveById(popContent.id) &&
              !_invisibleController.state.contains(popContent.id)) {
            if (popContent.shouldMakeInvisibleOnDismiss) {
              _makePopOverlayInvisible(popContent);
            } else {
              removePop(popContent.id);
            }
            popContent.onDismissed?.call();
          }
        });
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
    // Early return if no overlay with this ID exists
    if (PopOverlay.isActiveById(id) == false) {
      return;
    }

    // Find the popup content by ID
    final popupIndex =
        _controller.state.indexWhere((element) => element.id == id);
    if (popupIndex != -1) {
      final popContent = _controller.state[popupIndex];

      // Trigger the exit animation by setting the animation controller state
      popContent.animationController.state = true;

      // Wait for the animation to finish before removing from the list
      // This creates a smooth dismissal experience
      Future.delayed(const Duration(milliseconds: 450), () {
        // Double-check that the overlay still exists (could have been removed by another process)
        if (PopOverlay.isActiveById(id)) {
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

            // Remove the overlay from the invisible list
            //if it's being dismissed
            _invisibleController.update<List<String>>((invisibleState) {
              invisibleState.remove(id);
              popContent.onMadeInvisible?.call();

              return invisibleState;
            });

            // Re-sort the remaining overlays
            PopOverlay._sortPopList(state);
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
    final popContent = getActiveById(id);
    if (popContent != null) {
      if (popContent.shouldMakeInvisibleOnDismiss) {
        _makePopOverlayInvisible(popContent);
      } else {
        removePop(id);
      }
    }
  }

  //--------------------------------------------------//
  static void _makePopOverlayInvisible(PopOverlayContent popContent) {
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
          }
          return state;
        });
      }
    }
  }

  static void _makePopOverlayVisible(PopOverlayContent popContent) {
    // Find the popup content by ID
    if (PopOverlay.isActiveById(popContent.id)) {
      final popupIndex = PopOverlay.controller.state
          .indexWhere((element) => element.id == popContent.id);
      if (popupIndex > -1) {
        // Reset animation controller to trigger entrance animation
        popContent.animationController.state = false;

        _invisibleController.update<List<String>>((state) {
          state.remove(popContent.id);
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

  // Cached priority IDs for better performance with large lists
  static const List<String> _priorityIds = [
    "UnderMaintenancePopup",
    "Database Offline",
    "NoInternetConnectionPopup"
  ];

  // Sort the list of popups based on priority - OPTIMIZED VERSION
  static void _sortPopList(List<PopOverlayContent> list) {
    // Early return if list is empty or has only one element
    if (list.length <= 1) return;

    // Use a more efficient approach: collect priority items first
    final Map<String, PopOverlayContent> priorityItems = {};
    final List<PopOverlayContent> regularItems = [];

    // Single pass to separate priority items from regular items
    for (final item in list) {
      if (_priorityIds.contains(item.id)) {
        priorityItems[item.id] = item;
      } else {
        regularItems.add(item);
      }
    }

    // Clear the list once and rebuild efficiently
    list.clear();
    list.addAll(regularItems);

    // Add priority items in correct order (reverse order since last is on top)
    for (final priorityId in _priorityIds) {
      if (priorityItems.containsKey(priorityId)) {
        list.add(priorityItems[priorityId]!);
      }
    }
  }

  //-------------------------------------------------//

  /// Performance monitoring - returns metrics about current overlays
  static Map<String, dynamic> get performanceMetrics {
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
    _controller.update<List<PopOverlayContent>>((state) {
      // Dispose all overlays first
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
    if (_entry?.mounted == true) return;

    if (_entry != null && _entry?.mounted != true) {
      _entry = null;
    }

    if (_installScheduled) return;
    _installScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _installScheduled = false;

      if (_entry?.mounted == true) return;

      final overlayState = _resolveRootOverlay(context);
      if (overlayState == null) return;

      final entry = OverlayEntry(
        builder: (context) => const _PopOverlayBootstrapperEntry(),
      );

      overlayState.insert(entry);
      _entry = entry;
    });
  }

  static OverlayState? _resolveRootOverlay(BuildContext? context) {
    if (context != null) {
      final overlay = Overlay.maybeOf(context, rootOverlay: true);
      if (overlay != null) return overlay;
    }

    final rootElement = WidgetsBinding.instance.rootElement;
    if (rootElement == null) return null;

    OverlayState? found;

    void visit(Element element) {
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
    return OnBuilder(
      listenTo: PopOverlay.controller,
      builder: () {
        return OnBuilder(
          listenTo: PopOverlay.invisibleController,
          builder: () {
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
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    // Clear cache if it gets too large
    if (_cache.length >= _maxCacheSize) {
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
                  color: Colors.red.shade900.withValues(alpha: 0.3),
                ),
                child: const SizedBox()),
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
                  offset: Offset(0, 5),
                  blurRadius: 15,
                  spreadRadius: -10,
                ),
              ],
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ).animate(
            effects: [
              MoveEffect(
                duration: 0.4.sec,
                begin: Offset(0, 0),
                end: Offset(0, 70),
                curve: Curves.easeInBack,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//************************************************ */
