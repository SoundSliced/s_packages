// ignore_for_file: library_private_types_in_public_api

part of 's_modal_libs.dart';

/// Global flag to control debug print visibility
/// Set via Modal.appBuilder's showDebugPrints parameter
bool _showDebugPrints = false;

/// Modal System Implementation
///
/// A flexible, modular system for displaying various types of modal overlays
/// with rich customization options and intuitive gesture controls.
///
/// Supported modal types:
/// - Bottom Sheets: Slide up from bottom with interactive height adjustment
/// - Dialog boxes: Center-positioned modal windows
/// - Snackbars: Brief notifications that appear at screen edges
/// - Custom implementations: Build your own specialized modal experiences
///
/// Key features:
/// - Background blurring and dimming with customizable intensity
/// - Interactive dismissal gestures (swipe, tap outside)
/// - Customizable animations with natural motion
/// - Various positioning options for different UX patterns
/// - State preservation during transitions
/// - Memory-efficient implementation
/// - **Independent lifecycle per modal type** - Snackbars don't interfere with dialogs
///
/// Architecture:
/// - Uses states_rebuilder for reactive state management
/// - **Separate controllers per modal type** for independent lifecycle management
/// - Layered rendering: Snackbars always render above dialogs/bottomsheets
/// - Each modal type has its own dismissal state to prevent conflicts
//************************************************ */
// Type-Specific Controller Architecture
//
// Each modal type (dialog, bottomSheet, snackbar) has its own controller
// to ensure independent lifecycle management and prevent state conflicts.
//************************************************ */

/// Controller for dialog modals
///
/// Manages dialog-specific state independently from other modal types.
final _dialogController = RM.inject<_ModalContent?>(
  () => null,
  autoDisposeWhenNotUsed: true,
);

/// Controller for sheet modals (bottom, top, and side sheets)
///
/// Manages sheet-specific state independently from other modal types.
/// Used for all sheet types: bottomSheet, topSheet, and sideSheet.
final _sheetController = RM.inject<_ModalContent?>(
  () => null,
  autoDisposeWhenNotUsed: true,
);

/// Controller for side sheet modals
///
/// Manages side sheet-specific state independently from other modal types.
final _sideSheetController = RM.inject<_ModalContent?>(
  () => null,
  autoDisposeWhenNotUsed: true,
);

/// Controller for snackbar modals
///
/// Manages snackbar-specific state independently from other modal types.
/// Works in conjunction with the snackbar queue for stacking.
final _snackbarController = RM.inject<_ModalContent?>(
  () => null,
  autoDisposeWhenNotUsed: true,
);

/// Active modal controller - tracks the currently displayed modal
///
/// Stores the current modal's configuration and content.
/// When null, no modal is being displayed.
/// For type-specific access, use _dialogController, _sheetController, or _snackbarController.
final _activeModalController = RM.inject<_ModalContent?>(
  () => null,
  autoDisposeWhenNotUsed: true,
);

/// Hot reload counter - incremented on every hot reload
///
/// This forces widgets listening to this notifier to rebuild completely,
/// which ensures that builder functions are re-executed with updated code.
/// This is necessary because closures captured before hot reload don't
/// automatically get their bytecode updated.
final _hotReloadCounter = RM.inject<int>(() => 0);

//************************************************ */
// Type-Specific Dismissal State
//
// Each modal type tracks its own dismissal state independently.
// This prevents conflicts when, for example, dismissing a dialog
// while showing a snackbar.
//************************************************ */

/// Tracks if a dialog dismissal is in progress
final _dialogDismissingNotifier = RM.inject<bool>(() => false);

/// Tracks if a sheet dismissal is in progress
/// Used for all sheet types: bottomSheet, topSheet, and sideSheet
final _sheetDismissingNotifier = RM.inject<bool>(() => false);

/// Tracks which snackbar IDs are currently being dismissed
/// Uses a Set instead of a boolean to allow each snackbar to have independent dismissal state.
/// This prevents the issue where dismissing one snackbar causes newly shown snackbars
/// to also receive the dismissing state.
final _snackbarDismissingIdsNotifier = RM.inject<Set<String>>(() => {});

/// Legacy accessor for backward compatibility - returns true if ANY snackbar is dismissing
/// Prefer using _isSnackbarDismissing(id) for per-snackbar dismissal checks
final _snackbarDismissingNotifier = RM.inject<bool>(() => false);

/// Check if a specific snackbar is being dismissed
bool _isSnackbarDismissing(String? snackbarId) {
  if (snackbarId == null) return false;
  return _snackbarDismissingIdsNotifier.state.contains(snackbarId);
}

/// Mark a snackbar as dismissing
void _setSnackbarDismissing(String snackbarId, bool isDismissing) {
  final currentSet = Set<String>.from(_snackbarDismissingIdsNotifier.state);
  if (isDismissing) {
    currentSet.add(snackbarId);
  } else {
    currentSet.remove(snackbarId);
  }
  _snackbarDismissingIdsNotifier.state = currentSet;
  // Also update the legacy boolean notifier for any code that still uses it
  _snackbarDismissingNotifier.state = currentSet.isNotEmpty;
}

/// Clear all snackbar dismissing states
void _clearAllSnackbarDismissing() {
  _snackbarDismissingIdsNotifier.state = {};
  _snackbarDismissingNotifier.state = false;
}

/// Tracks the dismissal animation state
///
/// When true, a modal is in the process of being dismissed.
/// Used to coordinate animations during dismissal.
final _dismissModalAnimationController = RM.inject<bool>(() => false);

//************************************************ */
// Type-Specific Animation Controllers
//************************************************ */

// Type-specific animation notifiers
// Note: For future enhancement - type-specific background animations could be added here
// Currently, the shared _backgroundLayerAnimationNotifier handles all background effects
// to maintain visual consistency across modal types.

/// Animation controller for the background effects
///
/// Handles:
/// - Background blur intensity
/// - Scale effects
/// - Opacity changes
/// - Position adjustments
final _backgroundLayerAnimationNotifier = RM.inject<double>(() => 0.0);

/// Notifier specifically for blur animation state
///
/// This is separate from the main background animation notifier to ensure
/// blur only animates when Modal.isActive changes (activation/deactivation),
/// not on every drag update. This prevents unnecessary blur recomputation
/// during user drag interactions with the modal.
///
/// Uses a double (0.0 to 1.0) instead of boolean to allow smooth animations
/// when blur state changes during modal replacement.
final _blurAnimationStateNotifier = RM.inject<double>(() => 0.0);

/// Notifier for height animation state
///
/// Tracks if the sheet height is being animated due to modal content change.
/// Used to trigger smooth height transitions when a new modal with different
/// height is shown while another modal is already active.
final _heightAnimationTriggerNotifier = RM.inject<int>(() => 0);

/// Notifier for blur amount animation
///
/// Tracks the current animated blur amount (0.0 to 20.0 typically).
/// When the blurAmount parameter changes on modal replacement, this notifier
/// animates smoothly from the old value to the new value over 300ms.
final _blurAmountNotifier = RM.inject<double>(() => 3.0);

/// Queue for managing multiple stacked snackbars per position
///
/// Stores snackbar content in order of display, grouped by Alignment.
/// When snackbar display mode is "staggered", multiple snackbars
/// can be visible simultaneously at different stack indices within the same position.
/// Snackbars at different positions are treated as separate stacks.
final _snackbarQueueNotifier =
    RM.inject<Map<Alignment, List<_ModalContent>>>(() => {});

//************************************************ */
// Snackbar Animation Controllers Registry
//
// Each snackbar instance has its own dedicated animation controller.
// This registry allows dismiss methods to find and call the correct
// controller imperatively, without relying on reactive state changes.
//************************************************ */

/// Registry of snackbar animation controllers mapped by their unique ID
///
/// When a snackbar is created, its controller is registered here.
/// When dismissing a snackbar by ID, we can look up its controller
/// and call playDismissAnimation directly.
final _snackbarControllersRegistry =
    RM.inject<Map<String, SnackbarModalController>>(() => {});

/// Registers a snackbar's controller in the registry
void _registerSnackbarController(
    String id, SnackbarModalController controller) {
  final registry = Map<String, SnackbarModalController>.from(
      _snackbarControllersRegistry.state);
  registry[id] = controller;
  _snackbarControllersRegistry.state = registry;
  if (_showDebugPrints) {
    debugPrint('SnackbarController Registry: registered controller for id=$id');
  }
}

/// Unregisters a snackbar's controller from the registry
void _unregisterSnackbarController(String id) {
  final registry = Map<String, SnackbarModalController>.from(
      _snackbarControllersRegistry.state);
  registry.remove(id);
  _snackbarControllersRegistry.state = registry;
  if (_showDebugPrints) {
    debugPrint(
        'SnackbarController Registry: unregistered controller for id=$id');
  }
}

/// Gets a snackbar's controller from the registry
SnackbarModalController? _getSnackbarController(String id) {
  return _snackbarControllersRegistry.state[id];
}

//************************************************ */
// Modal Registry
//
// Central registry tracking all active modal IDs and their types.
// This enables reliable ID-based dismissal and prevents cross-modal conflicts.
//************************************************ */

/// Registry of all active modals mapped by their unique ID to their type
///
/// This registry is the source of truth for what modals are currently active.
/// It enables:
/// - Fast lookup of modal type by ID
/// - Reliable ID-based dismissal
/// - Prevention of duplicate modal IDs
/// - Bulk operations (dismissAll, dismissAllSnackbars, etc.)
final _modalRegistry = RM.inject<Map<String, ModalType>>(() => {});

/// Registers a modal in the registry
void _registerModal(String id, ModalType type) {
  final registry = Map<String, ModalType>.from(_modalRegistry.state);
  registry[id] = type;
  _modalRegistry.state = registry;
  if (_showDebugPrints) {
    debugPrint(
        'Modal Registry: registered $type with id=$id. Active: ${registry.keys.toList()}');
  }
}

/// Unregisters a modal from the registry
void _unregisterModal(String id) {
  final registry = Map<String, ModalType>.from(_modalRegistry.state);
  final type = registry.remove(id);
  _modalRegistry.state = registry;
  if (type != null && _showDebugPrints) {
    debugPrint(
        'Modal Registry: unregistered $type with id=$id. Active: ${registry.keys.toList()}');
  }
}

/// Unregisters multiple modals from the registry
void _unregisterModals(List<String> ids) {
  final registry = Map<String, ModalType>.from(_modalRegistry.state);
  for (final id in ids) {
    registry.remove(id);
  }
  _modalRegistry.state = registry;
  if (_showDebugPrints) {
    debugPrint(
        'Modal Registry: unregistered ${ids.length} modals. Active: ${registry.keys.toList()}');
  }
}

/// Gets the type of a modal by its ID, or null if not found
ModalType? _getModalType(String id) {
  return _modalRegistry.state[id];
}

/// Gets all modal IDs of a specific type
List<String> _getModalIdsByType(ModalType type) {
  return _modalRegistry.state.entries
      .where((e) => e.value == type)
      .map((e) => e.key)
      .toList();
}

/// Helper to remove a snackbar from the queue after its dismiss animation completes
///
/// This is called by the dismiss methods after the animation controller finishes.
/// It handles:
/// - Removing from queue
/// - Unregistering from modal registry
/// - Clearing dismissing state
/// - Activating next snackbar if available
/// - Calling dismiss callbacks
void _removeSnackbarAfterDismiss(
    Alignment position, String uniqueId, VoidCallback? onDismissed) {
  // Re-fetch queue map as it might have changed during animation
  final currentQueueMap = _snackbarQueueNotifier.state;
  final queueAtPosition = currentQueueMap[position] ?? [];
  final matchIndex = queueAtPosition.indexWhere(
    (content) => content.uniqueId == uniqueId,
  );

  if (matchIndex < 0) {
    // debugPrint(
    //     '_removeSnackbarAfterDismiss: snackbar $uniqueId not found in queue');
    return;
  }

  final snackbar = queueAtPosition[matchIndex];

  // Remove from queue
  final updatedQueue = List<_ModalContent>.from(queueAtPosition);
  updatedQueue.removeAt(matchIndex);

  final updatedQueueMap =
      Map<Alignment, List<_ModalContent>>.from(currentQueueMap);
  if (updatedQueue.isEmpty) {
    updatedQueueMap.remove(position);
  } else {
    updatedQueueMap[position] = updatedQueue;
  }

  _snackbarQueueNotifier.state = updatedQueueMap;

  // Unregister from modal registry
  final updatedRegistry = Map<String, ModalType>.from(_modalRegistry.state);
  updatedRegistry.remove(uniqueId);
  _modalRegistry.state = updatedRegistry;

  // Clear dismissing state for this specific snackbar
  _setSnackbarDismissing(uniqueId, false);

  // Activate next snackbar in queue if available
  if (updatedQueueMap.isNotEmpty) {
    for (final pos in updatedQueueMap.keys) {
      if (updatedQueueMap[pos]!.isNotEmpty) {
        final nextSnackbar = updatedQueueMap[pos]!.first;
        _snackbarController.state = nextSnackbar;
        // Only set as active modal if no dialog/bottom sheet is active
        if (!Modal.isDialogActive && !Modal.isSheetActive) {
          _activeModalController.state = nextSnackbar;
        }
        break;
      }
    }
  } else {
    // Queue is empty
    _snackbarController.refresh();
    // Only clear active modal if no other modals active
    if (!Modal.isDialogActive && !Modal.isSheetActive) {
      if (_activeModalController.state?.modalType == ModalType.snackbar) {
        _activeModalController.refresh();
        // Reset background/blur if nothing else is active
        _backgroundLayerAnimationNotifier.state = 0.0;
        _blurAnimationStateNotifier.state = 0.0;
      }
    } else if (Modal.isDialogActive) {
      _activeModalController.state = _dialogController.state;
    } else if (Modal.isSheetActive) {
      _activeModalController.state = _sheetController.state;
    }
  }

  // Run callbacks
  onDismissed?.call();
  snackbar.onDismissed?.call();

  if (_showDebugPrints) {
    debugPrint('_removeSnackbarAfterDismiss: removed snackbar $uniqueId');
  }
}

/// Current stack index for the active snackbar
///
/// Used to position snackbars vertically when staggered mode is enabled.
/// Increments as new snackbars are added to the queue.
final _snackbarStackIndexNotifier = RM.inject<int>(() => 0);

/// Tracks the swipe direction for snackbar dismiss animations
///
/// Used to animate snackbars out in the direction they were swiped
/// instead of reverting to default up/down animations.
/// Values: 'left', 'right', or '' (for no swipe)
final _snackbarSwipeDismissDirectionNotifier = RM.inject<String>(() => '');

/// Tracks whether the staggered snackbar view is expanded to show all snackbars
///
/// When true, staggered snackbars are displayed in a scrollable list view
/// where all snackbars are visible with the same width and can be individually dismissed.
/// When false, snackbars are displayed in the normal staggered view.
/// Tracks which position's staggered snackbars are expanded (null = none)
///
/// Previously a boolean controlling all groups at once; now stores the
/// specific `Alignment` of the expanded group so only one group expands at a time.
final _staggeredExpandedNotifier = RM.inject<Alignment?>(() => null);

//************************************************ */
// Configuration Enums

/// Defines the type of modal to display
///
/// - `bottomSheet`: A modal that slides up from the bottom of the screen
/// - `sheet`: A modal that slides in from an edge (position determined by SheetPosition)
/// - `dialog`: A centered modal dialog box
/// - `snackbar`: A brief notification that appears at the bottom
/// - `custom`: A custom implementation with user-defined behavior
enum ModalType { sheet, dialog, snackbar, custom }

/// Defines the position/edge from which a sheet modal appears
///
/// - `bottom`: Sheet slides in from the bottom (traditional bottom sheet)
/// - `left`: Sheet slides in from the left side
/// - `right`: Sheet slides in from the right side
/// - `top`: Sheet slides in from the top
enum SheetPosition { bottom, left, right, top }

/// Defines how the modal animates when appearing/disappearing
///
/// - `fade`: Gradually changes opacity
/// - `scale`: Grows or shrinks in size
/// - `slide`: Moves into position from off-screen
/// - `rotate`: Spins into view (use sparingly)
enum ModalAnimationType { fade, scale, slide, rotate }

/// Defines how multiple snackbars are displayed when shown simultaneously
///
/// - `stacked`: Snackbars stack visually on top of each other with offset
/// - `queued`: Shows one snackbar at a time, queuing others to show after dismiss
/// - `replace`: New snackbar replaces any existing one immediately
/// How multiple snackbars are displayed when one is already active
enum SnackbarDisplayMode {
  /// Snackbars stack on top of each other in a staggered layer
  staggered,

  /// Snackbars display as a notification bubble with count badge
  notificationBubble,

  /// New snackbars are queued and shown one after another
  queued,

  /// New snackbars replace the current one
  replace,
}

/// Direction for the snackbar duration indicator animation
enum DurationIndicatorDirection {
  /// Progress bar shrinks from right to left (remaining time shown on left)
  leftToRight,

  /// Progress bar shrinks from left to right (remaining time shown on right)
  rightToLeft,
}

/// Type definition for widget builder function
///
/// Returns a widget to display in the modal.
/// The builder is called within a Builder widget that provides a valid BuildContext,
/// so you can access Theme.of(context) and other inherited widgets within your widget.
///
/// Example:
/// ```dart
/// builder: () => Text(
///   'Hello',
///   style: Theme.of(context).textTheme.headlineSmall,
/// ),
/// ```
typedef ModalWidgetBuilder = Widget Function();

/// Internal configuration class for modal content and behavior
///
/// This class is used internally to encapsulate all modal settings.
/// Users should not create instances of this class directly - instead use
/// the Modal.show() method with direct parameters.
class _ModalContent {
  /// A builder function that creates the widget to display within the modal
  ///
  /// The builder is called each time the modal needs to rebuild,
  /// which enables hot reload support during development.
  ///
  /// Example:
  /// ```dart
  /// ModalContent(
  ///   builder: () => MyWidget(),
  /// )
  /// ```
  final ModalWidgetBuilder builder;

  /// Whether to apply a blur effect to content behind the modal
  ///
  /// When true, creates a depth effect by blurring the background.
  /// This can add visual hierarchy but has a small performance cost.
  final bool shouldBlurBackground;

  /// The intensity of the blur effect applied to the background
  ///
  /// Only used when [shouldBlurBackground] is true.
  /// Higher values create more blur (more blurred appearance).
  /// Typical range: 0.0 to 20.0 (default: 3.0)
  ///
  /// Examples:
  /// - 1.0: Very subtle blur
  /// - 3.0: Moderate blur (default)
  /// - 5.0: Strong blur
  /// - 10.0+: Extremely blurred background
  final double blurAmount;

  /// Optional callback function that runs when the modal is dismissed
  ///
  /// Useful for cleanup or state updates after the modal closes.
  /// Will be executed regardless of how the modal was dismissed (gesture or programmatically).
  final Function? onDismissed;

  /// Optional callback function that runs when the modal is expanded
  ///
  /// Triggered when the user expands the bottom sheet by dragging up.
  /// Useful for loading additional content or updating state when the view expands.
  /// Only applies to bottom sheet modals with drag-to-expand enabled.
  final Function? onExpanded;

  /// Optional callback function that runs when the snackbar is tapped
  ///
  /// Useful for handling tap interactions on snackbars.
  /// In staggered mode, tapping a stacked snackbar will also expand the view.
  final VoidCallback? onTap;

  /// The type of modal to display (bottom sheet, dialog, etc.)
  ///
  /// Controls both appearance and behavior patterns:
  /// - bottomSheet: Slides up from bottom with drag handle
  /// - dialog: Appears centered on screen
  /// - snackbar: Brief bottom notification
  /// - custom: User-defined behavior
  final ModalType modalType;

  /// Where on screen the modal should be positioned
  ///
  /// Different modal types may have different default positions.
  /// Only relevant for dialog and custom types; bottom sheets always appear at bottom.
  final Alignment modalPosition;

  /// The animation style used for entry and exit
  ///
  /// Controls how the modal appears and disappears:
  /// - fade: Opacity transition
  /// - scale: Size transition
  /// - slide: Position transition
  /// - rotate: Spin transition
  final ModalAnimationType modalAnimationType;

  /// Whether the modal can be dismissed by the user
  ///
  /// When true, allows tap-outside and gesture dismissal.
  /// Set to false for critical interactions that require explicit confirmation.
  final bool isDismissable;

  /// Whether to block all tap interactions with the background content
  ///
  /// When true, taps on the modal background will not pass through to
  /// interactive elements (buttons, etc.) in the underlying app content.
  /// All taps will either dismiss the modal (if [isDismissable] is true)
  /// or be absorbed (if [isDismissable] is false).
  ///
  /// When false (default), taps can still interact with buttons and other
  /// interactive elements visible behind the modal overlay. The modal will
  /// only dismiss when tapping on non-interactive background areas.
  ///
  /// Set to true when you want the modal to fully capture user attention
  /// and prevent any background interactions.
  final bool blockBackgroundInteraction;

  /// Whether the modal can be dragged by the user
  ///
  /// When true, allows the modal to be dragged around the screen.
  /// Only applies to non-bottomSheet modals (dialogs, etc.).
  /// Bottom sheets have their own drag behavior for expansion.
  final bool isDraggable;

  /// Whether the sheet can be expanded by dragging
  ///
  /// When true, allows sheets (bottom/side/top) to expand from their initial [size]
  /// to the [expandedPercentageSize]. Users can drag in the expansion direction to
  /// increase the sheet's dimension.
  ///
  /// Only applies to sheet modals (bottomSheet, sideSheet, topSheet).
  /// Set to false if you want a fixed-size sheet with no expansion capability.
  final bool isExpandable;

  /// The initial size of the sheet in logical pixels
  ///
  /// For bottomSheet/topSheet: This is the height
  /// For sideSheet: This is the width
  ///
  /// If null, the size will be automatically calculated based on the widget's intrinsic dimensions.
  /// This is useful for sheets with dynamic content that doesn't have a fixed size.
  final double? size;

  /// Maximum expanded size as percentage of screen dimension (0-100)
  ///
  /// For bottomSheet/topSheet: Percentage of screen height (e.g., 85 = 85% of screen height)
  /// For sideSheet: Percentage of screen width (e.g., 85 = 85% of screen width)
  ///
  /// Only applies to sheet modals when [isExpandable] is true.
  /// Determines the maximum size the sheet can expand to when dragged.
  final double expandedPercentageSize;

  /// Padding on the side opposite to the drag handle
  ///
  /// This padding is automatically positioned based on sheet position:
  /// - Bottom sheets: padding at top
  /// - Top sheets: padding at bottom
  /// - Left sheets: padding at right
  /// - Right sheets: padding at left
  /// Default is 35.0 (the height/width of the drag handle area).
  final double contentPaddingByDragHandle;

  /// Whether the snackbar can be dismissed by swiping
  ///
  /// When true (and isDismissable is also true), allows the snackbar to be swiped away.
  /// This parameter only controls the swipe gesture - for snackbars, use isDismissable
  /// to control all dismissal methods including programmatic and swipe dismissal.
  /// Only applies to snackbar modals. Default is true.
  ///
  /// Note: For snackbars, isDismissable takes precedence. If isDismissable is false,
  /// the snackbar cannot be swiped regardless of this setting.
  final bool isSwipeable;

  /// Duration before the snackbar auto-dismisses
  ///
  /// If null, the snackbar will not auto-dismiss.
  /// Only applies to snackbar modals.
  final Duration? autoDismissDuration;

  /// How multiple snackbars should be displayed
  ///
  /// - [SnackbarDisplayMode.staggered]: Snackbars stack in staggered layers
  /// - [SnackbarDisplayMode.notificationBubble]: Collapsible bubble with counter
  /// - [SnackbarDisplayMode.queued]: Shows one at a time, queuing others
  /// - [SnackbarDisplayMode.replace]: New snackbar replaces the current one
  final SnackbarDisplayMode snackbarDisplayMode;

  /// Maximum number of stacked snackbars visible at once
  ///
  /// Only applies when [snackbarDisplayMode] is [SnackbarDisplayMode.staggered].
  /// Default is 3.
  final int maxStackedSnackbars;

  /// Optional background color for the bottom sheet
  ///
  /// If null, the default theme color will be used.
  /// Only applies to bottom sheet modals.
  final Color? backgroundColor;

  /// Width of the snackbar
  ///
  /// If <= 1.0, it is treated as a percentage of screen width (e.g. 0.8 = 80%).
  /// If > 1.0, it is treated as a fixed width in logical pixels.
  ///
  /// If null, defaults are applied based on screen size and position:
  /// - Mobile Center: 90% of screen width
  /// - Mobile Corners/Sides: 60% of screen width
  /// - Desktop/Tablet: Min(400px, 90% of screen width)
  final double? snackbarWidth;

  //******************************************************* */

  /// Unified sheet position for both bottom sheets and side sheets
  ///
  /// This determines which edge of the screen the sheet appears from.
  /// For bottomSheet modals, defaults to [SheetPosition.bottom].
  /// For bottom/side sheet modals. Defaults to [SheetPosition.bottom].
  ///
  /// This field enables the unified sheet implementation to handle
  /// sheets from any edge using the same logic.
  final SheetPosition? sheetPosition;

  //******************************************************* */

  /// The color of the background dismiss overlay
  ///
  /// Defaults to [Colors.transparent].
  final Color barrierColor;

  /// Optional offset for fine-tuned positioning
  ///
  /// This offset is applied relative to the position specified by [modalPosition].
  /// For example, if [modalPosition] is [Alignment.topCenter] and [offset]
  /// is `Offset(0, 50)`, the modal will appear 50 logical pixels below the top center.
  ///
  /// Useful for:
  /// - Offsetting from screen edges (e.g., below a status bar)
  /// - Creating asymmetric layouts
  /// - Fine-tuning position for specific design requirements
  ///
  /// Example:
  /// ```dart
  /// Modal.showSnackbar(
  ///   text: 'Notification',
  ///   position: Alignment.topCenter,
  ///   offset: Offset(0, 60), // 60px below top
  /// );
  /// ```
  final Offset? offset;

  /// Optional builder ID for hot reload support
  ///
  /// When set, the modal will look up the builder from the registry
  /// instead of using the stored builder. This enables hot reload
  /// of modal content when used with [ModalBuilderScope].
  final String? builderId;

  /// Optional ID for programmatic dismissal and tracking
  ///
  /// Allows you to dismiss a specific modal/snackbar by ID,
  /// useful in staggered or queued display modes where multiple
  /// modals of the same type may be active.
  ///
  /// If not provided, a unique ID will be auto-generated and accessible
  /// via the [uniqueId] getter.
  ///
  /// Example:
  /// ```dart
  /// Modal.showSnackbar(
  ///   text: 'Notification 1',
  ///   id: 'notification_1',
  /// );
  /// // Later...
  /// Modal.dismissById('notification_1');
  /// ```
  final String? id;

  /// Gets the widget by calling the builder
  ///
  /// If a builderId is set and registered, uses that builder.
  /// Otherwise falls back to the stored builder.
  ///
  /// Wraps the content in a Builder widget to ensure a fresh, valid
  /// BuildContext is available, preventing "deactivated widget ancestor" errors
  /// when the modal rebuilds during state changes.
  Widget buildContent() {
    return Builder(
      builder: (context) {
        if (builderId != null && _modalBuilderRegistry.containsKey(builderId)) {
          return _modalBuilderRegistry[builderId]!();
        }
        return builder();
      },
    );
  }

  /// Creates a new modal content configuration
  ///
  /// The [builder] parameter is required and provides the widget content.
  /// All other parameters have sensible defaults for a standard bottom sheet.
  /// Customize any aspect to create different modal experiences.
  ///
  /// Example:
  /// ```dart
  /// final config = ModalContent(
  ///   builder: () => MyCustomWidget(),
  ///   modalType: ModalType.dialog,
  ///   height: 300,
  /// );
  /// ```
  /// Internal unique identifier for this modal instance
  /// Auto-generated if not provided via [id] parameter
  late final String _internalId;

  /// Creates a new modal content configuration
  ///
  /// The [builder] parameter is required and provides the widget content.
  /// All other parameters have sensible defaults for a standard bottom sheet.
  /// Customize any aspect to create different modal experiences.
  ///
  /// If [id] is not provided, a unique ID will be auto-generated.
  _ModalContent({
    required this.builder,
    this.builderId,
    this.id,
    this.shouldBlurBackground = false,
    this.blurAmount = 3.0,
    this.onDismissed,
    this.onExpanded,
    this.onTap,
    this.modalType = ModalType.sheet,
    this.modalPosition = Alignment.bottomCenter,
    this.modalAnimationType = ModalAnimationType.fade,
    this.isDismissable = true,
    this.blockBackgroundInteraction = false,
    this.isDraggable = false,
    this.isExpandable = false,
    this.size,
    this.expandedPercentageSize = 85,
    this.contentPaddingByDragHandle = 35.0,
    bool isSwipeable = true,
    Duration? autoDismissDuration,
    this.snackbarDisplayMode = SnackbarDisplayMode.staggered,
    this.maxStackedSnackbars = 3,
    this.backgroundColor,
    this.snackbarWidth,
    this.barrierColor = Colors.transparent,
    this.offset,
    SheetPosition? sheetPosition,
  })  : // For snackbars: isSwipeable should match isDismissable
        // This ensures consistent behavior across all dismissal methods
        isSwipeable =
            (modalType == ModalType.snackbar ? isDismissable : isSwipeable),
        autoDismissDuration = (
            // For snackbars: nullify autoDismissDuration if isDismissable is false
            // because a non-dismissible snackbar should not auto-dismiss
            (modalType == ModalType.snackbar && !isDismissable)
                ? null
                : (snackbarDisplayMode == SnackbarDisplayMode.staggered
                    ? null
                    : autoDismissDuration)),
        _internalId = _generateModalId(id),
        // Default sheetPosition to bottom if not provided
        sheetPosition = sheetPosition ?? SheetPosition.bottom {
    // debugPrint('ModalContent created: type=$modalType, id=$uniqueId');
  }

  /// Gets the unique identifier for this modal
  ///
  /// Returns the user-provided [id] if set, otherwise returns the auto-generated internal ID.
  String get uniqueId => id ?? _internalId;

  /// Factory constructor for a default snackbar with simplified API
  ///
  /// Creates a pre-styled snackbar with optional prefix/suffix icons.
  /// Use this for quick snackbar creation without building custom UI.
  ///
  /// Parameters:
  /// - `text`: The message text to display (required)
  /// - `prefixIcon`: Optional icon to display before the text
  /// - `showSuffixIcon`: Whether to show a close (X) icon (default: true)
  /// - `backgroundColor`: Background color of the snackbar (default: grey.shade800)
  /// - `textColor`: Text color (default: white)
  /// - `iconColor`: Icon color (default: white)
  /// - `position`: Where on screen the snackbar appears (default: topCenter)
  /// - `autoDismissDuration`: Duration before auto-dismiss (default: 4 seconds)
  /// - `isSwipeable`: Whether user can swipe to dismiss (default: true)
  ///
  /// Example:
  /// ```dart
  /// Modal.showSnackbar(
  ///   ModalContent.defaultSnackbar(
  ///     text: 'Item saved successfully!',
  ///     prefixIcon: Icons.check_circle,
  ///     backgroundColor: Colors.green,
  ///   ),
  /// );
  /// ```
  factory _ModalContent.defaultSnackbar({
    required String text,
    IconData? prefixIcon,
    bool showSuffixIcon = true,
    Color? backgroundColor,
    Color textColor = Colors.white,
    Color iconColor = Colors.white,
    Alignment position = Alignment.topCenter,
    Duration? duration = const Duration(seconds: 4),
    bool isDismissible = true,
    Color barrierColor = Colors.transparent,
    String? id,
    double? width,
    Offset? offset,
    SnackbarDisplayMode displayMode = SnackbarDisplayMode.replace,
    int maxStackedSnackbars = 3,
    Function? onDismissed,
    VoidCallback? onTap,
    bool showDurationTimer = true,
    Color? durationTimerColor,
    DurationIndicatorDirection durationTimerDirection =
        DurationIndicatorDirection.leftToRight,
  }) {
    final bgColor = backgroundColor ?? Colors.grey.shade800;
    // Generate the unique ID upfront so we can capture it in the builder closure
    final snackbarId = _generateModalId(id);

    return _ModalContent(
      builder: () {
        // Build the main snackbar content
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main content row
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (prefixIcon != null) ...[
                      Icon(prefixIcon, color: iconColor, size: 24),
                      const SizedBox(width: 12),
                    ],
                    Flexible(
                      child: Text(
                        text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (showSuffixIcon) ...[
                      GestureDetector(
                        onTap: () {
                          // Dismiss this specific snackbar by its ID (captured in closure)
                          Modal.dismissById(snackbarId);
                        },
                        child: Icon(Icons.close, color: iconColor, size: 20),
                      ),
                    ] else ...[
                      SizedBox(width: 20),
                    ],
                  ],
                ),
              ),
              // Duration indicator at the bottom (only if duration is set and showDurationTimer is true and isDismissible is true)
              if (showDurationTimer && duration != null && isDismissible)
                SnackbarDurationIndicator(
                  duration: duration,
                  color: durationTimerColor ?? Colors.amber,
                  backgroundColor: (durationTimerColor ?? Colors.amber)
                      .withValues(alpha: 0.3),
                  direction: durationTimerDirection,
                ),
            ],
          ),
        );
      },
      modalType: ModalType.snackbar,
      modalPosition: position,
      autoDismissDuration: duration,
      isDismissable: isDismissible,
      // For snackbars, isSwipeable is now controlled by isDismissible
      isSwipeable: isDismissible,
      snackbarDisplayMode: displayMode,
      maxStackedSnackbars: maxStackedSnackbars,
      id: snackbarId, // Use the pre-generated ID
      snackbarWidth: width,
      barrierColor: barrierColor,
      offset: offset,
      onDismissed: onDismissed,
      onTap: onTap,
    );
  }
}

//************************************************ */
// Hot Reload Support for Modal Builders
//************************************************ */

/// Global registry for modal builders that supports hot reload
///
/// This registry stores builders by ID so they can be re-registered
/// with updated bytecode when hot reload occurs.
final Map<String, ModalWidgetBuilder> _modalBuilderRegistry = {};

/// Counter for auto-generating unique builder IDs
int _autoBuilderIdCounter = 0;

/// Counter for auto-generating unique modal IDs
int _autoModalIdCounter = 0;

/// Generates a unique ID for a modal
///
/// If an ID is provided, returns it as-is.
/// Otherwise, generates a unique ID using counter and timestamp.
String _generateModalId([String? providedId]) {
  if (providedId != null && providedId.isNotEmpty) {
    return providedId;
  }
  return 'modal_${_autoModalIdCounter++}_${DateTime.now().millisecondsSinceEpoch}';
}

/// Checks if the current active modal should block background interactions
///
/// Returns true if any active modal (dialog, bottom sheet, or snackbar)
/// has `blockBackgroundInteraction` set to true.
bool _shouldBlockBackgroundInteraction() {
  // Check dialog
  if (_dialogController.state?.blockBackgroundInteraction ?? false) {
    return true;
  }
  // Check sheet (bottom, top, side)
  if (_sheetController.state?.blockBackgroundInteraction ?? false) {
    return true;
  }
  // Check snackbar (from the main controller when snackbar is active)
  if (_snackbarController.state?.blockBackgroundInteraction ?? false) {
    return true;
  }
  return false;
}

/// A widget that shows modals with hot reload support
///
/// This is the **recommended way** to show modals in your app. It provides:
/// - Hot reload support during development
/// - Clean, declarative API with minimal boilerplate
/// - Automatic builder registration and cleanup
///
/// ## When to use `ModalBuilder` vs `Modal.show()`
///
/// | Use Case | Approach |
/// |----------|----------|
/// | Button/tap triggers modal | `ModalBuilder` ✅ |
/// | Programmatic/conditional showing | `Modal.show()` |
/// | Modal replacement | `Modal.show()` |
/// | Reactive content with state management | `Modal.show()` with reactive wrapper |
///
/// ## Basic Usage
///
/// You can pass either a `Widget` directly or a builder function:
///
/// ```dart
/// // With a widget directly (simpler)
/// ModalBuilder(
///   content: MyModalContent(),
///   child: ElevatedButton(child: Text('Show Modal')),
/// )
///
/// // With a builder function (for complex content)
/// ModalBuilder(
///   builder: () => MyModalContent(),
///   child: ElevatedButton(child: Text('Show Modal')),
/// )
/// ```
///
/// ## Bottom Sheet (default)
///
/// ```dart
/// ModalBuilder(
///   content: MyContent(),
///   height: 300,
///   shouldBlurBackground: true,
///   child: MyButton(),
/// )
/// ```
///
/// ## Dialog
///
/// ```dart
/// ModalBuilder.dialog(
///   content: MyDialogContent(),
///   shouldBlurBackground: true,
///   child: MyButton(),
/// )
/// ```
///
/// ## With Callbacks
///
/// ```dart
/// ModalBuilder(
///   content: MyContent(),
///   onPressed: () => print('Opening modal'),
///   onDismissed: () => print('Modal closed'),
///   child: MyButton(),
/// )
/// ```
class ModalBuilder extends StatefulWidget {
  /// Builder function that creates the modal content widget
  ///
  /// This function is called each time the modal is shown, ensuring
  /// that hot reload works correctly during development.
  ///
  /// If null, a default template is shown (Modal.bottomSheetTemplate).
  ///
  /// Example:
  /// ```dart
  /// ModalBuilder(
  ///   builder: () => MyContentWidget(),
  ///   child: MyButton(),
  /// )
  /// ```
  final ModalWidgetBuilder? builder;

  /// The child widget - typically a button that triggers the modal
  /// Tapping this widget will automatically show the modal.
  final Widget child;

  /// Whether to apply a blur effect to content behind the modal
  final bool shouldBlurBackground;

  /// The intensity of the blur effect (0.0 to 20.0, default: 3.0)
  final double blurAmount;

  /// Callback when the modal is dismissed
  final Function? onDismissed;

  /// Callback when a bottom sheet is expanded
  final Function? onExpanded;

  /// The type of modal (bottomSheet, dialog, etc.)
  final ModalType modalType;

  /// Position of the modal on screen
  final Alignment modalPosition;

  /// Animation style for entry/exit
  final ModalAnimationType modalAnimationType;

  /// Whether the modal can be dismissed by the user
  final bool isDismissable;

  /// Whether the modal can be dragged by the user (for dialogs)
  final bool isDraggable;

  /// Whether the sheet can be expanded by dragging (for sheets)
  final bool isExpandable;

  /// The initial size of the sheet (height for bottom/top, width for side sheets)
  final double? size;

  /// Maximum expanded size as percentage of screen dimension (0-100)
  final double expandedPercentageSize;

  /// Padding on the side where the drag handle is located
  final double contentPaddingByDragHandle;

  /// Whether the snackbar can be swiped to dismiss (snackbars only)
  final bool isSwipeable;

  /// Auto-dismiss duration for snackbars (null means no auto-dismiss)
  final Duration? autoDismissDuration;

  /// How multiple snackbars are displayed
  final SnackbarDisplayMode snackbarDisplayMode;

  /// Maximum stacked snackbars visible at once
  final int maxStackedSnackbars;

  /// Optional background color for the bottom sheet
  final Color? modalColor;

  /// The color of the background dismiss overlay
  final Color barrierColor;

  /// Whether to block all tap interactions with the background content
  ///
  /// When true, taps on the modal background will not pass through to
  /// interactive elements (buttons, etc.) in the underlying app content.
  final bool blockBackgroundInteraction;

  /// Width of the snackbar (percentage of screen width, 0-1)
  ///
  /// If null, defaults to 90% of screen width.
  /// Only applies to snackbar modals.
  final double? snackbarWidth;

  /// Optional ID for programmatic dismissal and tracking
  ///ent
  /// Allows you to dismiss a specific modal by ID.
  /// If not provided, a unique ID will be auto-generated.
  final String? id;

  /// Creates a ModalBuilder for bottom sheet modals (default)
  const ModalBuilder({
    super.key,
    this.builder,
    required this.child,
    this.shouldBlurBackground = false,
    this.blurAmount = 3.0,
    this.onDismissed,
    this.onExpanded,
    this.modalType = ModalType.sheet,
    this.modalPosition = Alignment.bottomCenter,
    this.modalAnimationType = ModalAnimationType.fade,
    this.isDismissable = true,
    this.isDraggable = false,
    this.isExpandable = false,
    this.size,
    this.expandedPercentageSize = 85,
    this.contentPaddingByDragHandle = 35.0,
    this.isSwipeable = true,
    this.autoDismissDuration,
    this.snackbarDisplayMode = SnackbarDisplayMode.staggered,
    this.maxStackedSnackbars = 3,
    this.modalColor,
    this.barrierColor = Colors.transparent,
    this.blockBackgroundInteraction = false,
    this.snackbarWidth,
    this.id,
  });

  /// Creates a ModalBuilder for bottom sheet modals
  ///
  /// This is an alias for the default constructor with clearer intent.
  const ModalBuilder.bottomSheet({
    super.key,
    this.builder,
    required this.child,
    this.shouldBlurBackground = false,
    this.blurAmount = 3.0,
    this.onDismissed,
    this.onExpanded,
    this.isDismissable = true,
    this.isExpandable = false,
    this.size,
    this.expandedPercentageSize = 85,
    this.contentPaddingByDragHandle = 35.0,
    this.modalColor,
    this.barrierColor = Colors.transparent,
    this.blockBackgroundInteraction = false,
    this.id,
  })  : modalType = ModalType.sheet,
        modalPosition = Alignment.bottomCenter,
        modalAnimationType = ModalAnimationType.fade,
        isDraggable = false,
        isSwipeable = true,
        autoDismissDuration = null,
        snackbarDisplayMode = SnackbarDisplayMode.staggered,
        maxStackedSnackbars = 3,
        snackbarWidth = null;

  /// Creates a ModalBuilder for dialog modals
  ///
  /// Dialogs appear centered on screen by default.
  ///
  /// ```dart
  /// ModalBuilder.dialog(
  ///   builder: () => MyDialogContent(),
  ///   shouldBlurBackground: true,
  ///   child: ElevatedButton(child: Text('Show Dialog')),
  /// )
  /// ```
  const ModalBuilder.dialog({
    super.key,
    this.builder,
    required this.child,
    this.shouldBlurBackground = true,
    this.blurAmount = 3.0,
    this.onDismissed,
    this.isDismissable = true,
    this.isDraggable = false,
    this.size,
    this.modalPosition = Alignment.center,
    this.modalAnimationType = ModalAnimationType.fade,
    this.barrierColor = Colors.transparent,
    this.blockBackgroundInteraction = false,
    this.id,
  })  : modalType = ModalType.dialog,
        onExpanded = null,
        isExpandable = false,
        expandedPercentageSize = 85,
        contentPaddingByDragHandle = 35.0,
        isSwipeable = true,
        autoDismissDuration = null,
        snackbarDisplayMode = SnackbarDisplayMode.staggered,
        maxStackedSnackbars = 3,
        modalColor = null,
        snackbarWidth = null;

  /// Creates a ModalBuilder for snackbar modals
  ///
  /// Snackbars appear at the bottom of the screen by default,
  /// designed for brief notifications and messages.
  ///
  /// Features:
  /// - [isDismissable]: Controls whether snackbar can be dismissed by swipe or tap (default: true)
  /// - [autoDismissDuration]: Auto-dismiss after duration (default: 4 seconds, null if isDismissable is false)
  /// - [snackbarDisplayMode]: How multiple snackbars stack (staggered/notificationBubble)
  /// - [maxStackedSnackbars]: Max visible stacked snackbars (default: 3)
  /// - [barrierColor]: Background barrier color (default: transparent)
  ///
  /// Note: For snackbars, isDismissable controls all dismissal methods including swipe.
  /// If isDismissable is false, autoDismissDuration is treated as null.
  ///
  /// ```dart
  /// ModalBuilder.snackbar(
  ///   builder: () => MySnackbarContent(),
  ///   autoDismissDuration: Duration(seconds: 3),
  ///   isDismissable: true,
  ///   barrierColor: Colors.black.withValues(alpha: 0.2),
  ///   child: ElevatedButton(child: Text('Show Snackbar')),
  /// )
  /// ```
  const ModalBuilder.snackbar({
    super.key,
    this.builder,
    required this.child,
    this.shouldBlurBackground = false,
    this.blurAmount = 3.0,
    this.onDismissed,
    this.isDismissable = true,
    this.size,
    this.modalPosition = Alignment.bottomCenter,
    this.modalAnimationType = ModalAnimationType.slide,
    this.isSwipeable = true,
    this.autoDismissDuration = const Duration(seconds: 4),
    this.snackbarDisplayMode = SnackbarDisplayMode.replace,
    this.maxStackedSnackbars = 3,
    this.barrierColor = Colors.transparent,
    this.blockBackgroundInteraction = false,
    this.snackbarWidth,
    this.id,
  })  : modalType = ModalType.snackbar,
        onExpanded = null,
        isExpandable = false,
        expandedPercentageSize = 85,
        contentPaddingByDragHandle = 0.0,
        isDraggable = false,
        modalColor = null;

  @override
  State<ModalBuilder> createState() => _ModalBuilderState();
}

class _ModalBuilderState extends State<ModalBuilder> {
  late final String builderId;

  /// Returns the effective builder, using default template if none provided
  ModalWidgetBuilder get effectiveBuilder =>
      widget.builder ?? () => Modal.bottomSheetTemplate;

  @override
  void initState() {
    super.initState();
    builderId = 'auto_modal_${_autoBuilderIdCounter++}';
    registerBuilder();
  }

  @override
  void didUpdateWidget(ModalBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    registerBuilder();
  }

  @override
  void reassemble() {
    super.reassemble();
    // Re-register the builder on hot reload
    // widget.builder now points to updated bytecode
    registerBuilder();

    // If THIS modal is active, trigger a rebuild
    if (Modal.isActive && Modal.controller.state?.builderId == builderId) {
      _hotReloadCounter.state = _hotReloadCounter.state + 1;
    }
  }

  void registerBuilder() {
    _modalBuilderRegistry[builderId] = effectiveBuilder;
  }

  void showModal() {
    // Create a ModalContent with all the parameters
    // Note: Modal._showInternal() handles checking for existing modals with same id/builderId
    // and will call updateParams if needed, so ModalBuilder gets that behavior for free
    Modal._showInternal(_ModalContent(
      id: widget.id,
      builder: effectiveBuilder,
      builderId: builderId,
      shouldBlurBackground: widget.shouldBlurBackground,
      blurAmount: widget.blurAmount,
      onDismissed: widget.onDismissed,
      onExpanded: widget.onExpanded,
      modalType: widget.modalType,
      modalPosition: widget.modalPosition,
      modalAnimationType: widget.modalAnimationType,
      isDismissable: widget.isDismissable,
      blockBackgroundInteraction: widget.blockBackgroundInteraction,
      isDraggable: widget.isDraggable,
      isExpandable: widget.isExpandable,
      size: widget.size,
      expandedPercentageSize: widget.expandedPercentageSize,
      contentPaddingByDragHandle: widget.contentPaddingByDragHandle,
      isSwipeable: widget.isSwipeable,
      autoDismissDuration: widget.autoDismissDuration,
      snackbarDisplayMode: widget.snackbarDisplayMode,
      maxStackedSnackbars: widget.maxStackedSnackbars,
      snackbarWidth: widget.snackbarWidth,
      backgroundColor: widget.modalColor,
      barrierColor: widget.barrierColor,
    ));
  }

  @override
  void dispose() {
    _modalBuilderRegistry.remove(builderId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the child to intercept tap/press events
    return SInkButton(
      onTap: (pos) => showModal(),
      child: AbsorbPointer(
        // Prevent the child's own onPressed from firing
        absorbing: true,
        child: widget.child,
      ),
    );
  }
}

//************************************************ */

/// The main modal system API
///
/// This class provides a comprehensive interface for managing modals throughout
/// your application with simple, intuitive methods and properties.
///
/// Key features:
/// - [show]: Display modals with flexible configuration
/// - [dismiss]: Close modals with optional callbacks
/// - [isActive]: Check if a modal is currently visible
/// - [activator]: Set up the modal system in your widget tree
///
/// Implementation details:
/// - Uses states_rebuilder for state management
/// - Handles all animation coordination internally
/// - Manages background effects like blur and scaling
/// - Provides graceful fallbacks for edge cases
///
/// Basic usage:
/// ```dart
/// // Show a default bottom sheet
/// Modal.show();
///
/// // Show a custom modal with specific configuration
/// Modal.show(ModalContent(
///   widget: MyCustomWidget(),
///   modalType: ModalType.dialog,
///
/// ));
///
/// // Dismiss the current modal
/// Modal.dismiss();
///
/// // Check if a modal is currently showing
/// if (Modal.isActive) {
///   // Do something when modal is visible
/// }
/// ```
///
/// Setup in your app (typically in your main widget):
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return MaterialApp(
///     builder: Modal.appBuilder,
///     home: MyHomePage(),
///   );
/// }
/// ```
// Sentinel value for offset updates to distinguish between "not provided" and "null"
const Offset _noOffsetChange = Offset(double.infinity, double.infinity);

class Modal {
  //==================================================
  // Internal installation / bootstrap
  //==================================================

  /// Tracks whether Modal.appBuilder has been installed in the widget tree.
  ///
  /// This is set when [appBuilder] runs and is used to provide fast feedback
  /// in debug builds if the app forgot to wrap `MaterialApp.builder`.
  static bool _appBuilderInstalled = false;

  /// Whether [Modal.appBuilder] has already been installed in the widget tree.
  ///
  /// Other packages (e.g. s_connectivity) can check this before calling
  /// [appBuilder] again to avoid double-wrapping the activator widget.
  ///
  /// ```dart
  /// if (!Modal.isAppBuilderInstalled) {
  ///   // safe to call Modal.appBuilder
  /// }
  /// ```
  static bool get isAppBuilderInstalled => _appBuilderInstalled;

  /// Hook for `MaterialApp.builder` / `WidgetsApp.builder`.
  ///
  /// This is the supported way to ensure `_ActivatorWidget` becomes a **parent**
  /// of your app's widget tree (no overlays, no runtime re-parenting).
  ///
  /// Usage:
  /// ```dart
  /// MaterialApp(
  ///   builder: Modal.appBuilder,
  ///   home: ...,
  /// )
  /// ```
  ///
  static Widget appBuilder(
    /// The build context of the app
    BuildContext context,

    /// The child widget: the app background behind the modal
    Widget? child, {
    /// The border radius to apply to the modal's corners when [ModalType] is [ModalType.sheet] and when a sheet is active/showing
    BorderRadius? borderRadius,

    /// Whether the modal background should bounce when the dismiss barrier is tapped
    bool shouldBounceOnTap = true,

    /// The background color when [ModalType.sheet] sheet is active/showing, when the background layer is scaled
    Color backgroundColor = Colors.black,

    /// Whether to show debug prints for modal events
    bool showDebugPrints = false,
  }) {
    assert(
      child != null,
      'Modal.appBuilder requires the MaterialApp/WidgetsApp builder child. '
      'Make sure your app builder passes the provided child into Modal.appBuilder.',
    );

    // Idempotent: if appBuilder was already installed, return the child as-is
    // to prevent double-nesting of _ActivatorWidget.
    if (_appBuilderInstalled) {
      return child ?? const SizedBox.shrink();
    }

    _appBuilderInstalled = true;
    _showDebugPrints = showDebugPrints;
    return _ActivatorWidget(
      borderRadius: borderRadius ?? BorderRadius.zero,
      shouldBounce: shouldBounceOnTap,
      backgroundColor: backgroundColor,
      child: child ?? const SizedBox.shrink(),
    );
  }
  //--------------------------------------------------//
  // Configuration Parameters
  //--------------------------------------------------//

  /// Background barrier color for the expanded staggered snackbar view
  ///
  /// This color is applied to the background layer in `_buildExpandedStaggeredView`
  /// when snackbars are expanded to show the full list. Users can customize this
  /// to match their app's design.
  ///
  /// Example:
  /// ```dart
  /// Modal.snackStaggeredViewDismissBarrierColor = Colors.red.withValues(alpha:0.7);
  /// ```
  ///
  /// Default: Colors.black87
  static Color snackStaggeredViewDismissBarrierColor = Colors.black87;

  //--------------------------------------------------//
  // Type-Specific Controllers
  //
  // Each modal type has its own controller for independent lifecycle management.
  // This ensures that dismissing a dialog doesn't affect snackbars, etc.
  //--------------------------------------------------//

  /// Controller for dialog modals
  ///
  /// Use this to check if a dialog is active or access its content.
  static Injected<_ModalContent?> get dialogController => _dialogController;

  /// Controller for sheet modals (bottom, top, and side sheets)
  ///
  /// Use this to check if any sheet is active or access its content.
  static Injected<_ModalContent?> get sheetController => _sheetController;

  /// Controller for snackbar modals
  ///
  /// Use this to check if snackbars are active or access current snackbar content.
  static Injected<_ModalContent?> get snackbarController => _snackbarController;

  /// Access to the side sheet controller
  ///
  /// Manages side sheet-specific state independently from other modal types.
  static Injected<_ModalContent?> get sideSheetController =>
      _sideSheetController;

  //--------------------------------------------------//
  // Type-Specific State Checks
  //--------------------------------------------------//

  /// Returns true if a dialog is currently active
  static bool get isDialogActive => _dialogController.state != null;

  /// Returns true if a bottom sheet is currently active
  static bool get isSheetActive => _sheetController.state != null;

  /// Returns true if a side sheet is currently active
  /// Side sheets use the sheet controller with left/right positions
  static bool get isSideSheetActive {
    if (_sheetController.state == null) return false;
    final position = _sheetController.state!.sheetPosition;
    return position == SheetPosition.left || position == SheetPosition.right;
  }

  /// Returns true if a top sheet is currently active
  /// Top sheets use the sheet controller with top position
  static bool get isTopSheetActive {
    if (_sheetController.state == null) return false;
    final position = _sheetController.state!.sheetPosition;
    return position == SheetPosition.top;
  }

  /// Returns true if a bottom sheet is currently active
  /// Bottom sheets use the sheet controller with bottom position
  static bool get isBottomSheetActive {
    if (_sheetController.state == null) return false;
    final position = _sheetController.state!.sheetPosition;
    return position == SheetPosition.bottom;
  }

  /// Returns true if any snackbars are currently active
  static bool get isSnackbarActive =>
      _snackbarController.state != null ||
      _snackbarQueueNotifier.state.isNotEmpty;

  /// Returns true if a dialog dismissal is in progress
  static bool get isDialogDismissing => _dialogDismissingNotifier.state;

  /// Returns true if a sheet dismissal is in progress
  static bool get isSheetDismissing => _sheetDismissingNotifier.state;

  /// Returns true if a side sheet dismissal is in progress
  /// Side sheets use the sheet dismissing notifier
  static bool get isSideSheetDismissing {
    if (!isSheetDismissing) return false;
    // If sheet is dismissing, check if it's actually a side sheet
    final position = _sheetController.state?.sheetPosition;
    return position == SheetPosition.left || position == SheetPosition.right;
  }

  /// Returns true if a top sheet dismissal is in progress
  /// Top sheets use the sheet dismissing notifier
  static bool get isTopSheetDismissing {
    if (!isSheetDismissing) return false;
    // If sheet is dismissing, check if it's actually a top sheet
    final position = _sheetController.state?.sheetPosition;
    return position == SheetPosition.top;
  }

  /// Returns true if a bottom sheet dismissal is in progress
  /// Bottom sheets use the sheet dismissing notifier
  static bool get isBottomSheetDismissing {
    if (!isSheetDismissing) return false;
    // If sheet is dismissing, check if it's actually a bottom sheet
    final position = _sheetController.state?.sheetPosition;
    return position == SheetPosition.bottom;
  }

  /// Returns true if snackbar dismissal is in progress
  static bool get isSnackbarDismissing => _snackbarDismissingNotifier.state;

  //--------------------------------------------------//
  // Public Accessors
  //--------------------------------------------------//

  /// Access to the active modal controller
  ///
  /// Tracks the currently displayed modal of any type.
  /// For type-specific access, use dialogController, sheetController, or snackbarController.
  static Injected<_ModalContent?> get controller => _activeModalController;

  /// Returns a default modal configuration
  ///
  /// Useful as a starting point for creating custom modals
  static Widget get bottomSheetTemplate => Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: const Text('Default Sheet'),
        ),
      );

  /// Indicates whether any modal is currently being shown
  ///
  /// Returns `true` if any modal type is active, `false` otherwise.
  /// For type-specific checks, use isDialogActive, isBottomSheetActive, isSideSheetActive, or isSnackbarActive.
  static bool get isActive =>
      _activeModalController.state != null ||
      isDialogActive ||
      isSheetActive ||
      isSnackbarActive;

  /// Controller that tracks the modal dismissal animation state
  ///
  /// Used internally to coordinate dismissal animations
  static Injected<bool> get dismissModalAnimationController =>
      _dismissModalAnimationController;

  /// Access to the snackbar queue
  ///
  /// Used internally to manage multiple stacked snackbars per position
  static Injected<Map<Alignment, List<_ModalContent>>> get snackbarQueue =>
      _snackbarQueueNotifier;

  /// Access to the current snackbar stack index
  ///
  /// Indicates which position in the stack the active snackbar occupies
  static Injected<int> get snackbarStackIndex => _snackbarStackIndexNotifier;

  //--------------------------------------------------//
  // ID-Based Modal Management
  //--------------------------------------------------//

  /// Returns the unique ID of the currently active modal
  ///
  /// Returns null if no modal is active.
  /// This is useful for programmatic tracking and conditional logic.
  ///
  /// Example:
  /// ```dart
  /// if (Modal.activeModalId == 'myDialog') {
  ///   // Handle specific modal
  /// }
  /// ```
  static String? get activeModalId => _activeModalController.state?.uniqueId;

  /// Checks if a modal with the given ID exists and is active
  ///
  /// Searches the active modal and snackbar queue for a matching ID.
  /// Returns true if found, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// if (Modal.isModalActive('notification_123')) {
  ///   // Don't show duplicate notification
  ///   return;
  /// }
  /// Modal.showSnackbar(text: 'Hello', id: 'notification_123');
  /// ```
  static bool isModalActiveById(String id) {
    // Check active modal
    if (_activeModalController.state != null) {
      final activeModal = _activeModalController.state!;
      if (activeModal.id == id || activeModal.uniqueId == id) {
        return true;
      }
    }

    // Check snackbar queue
    final queueMap = _snackbarQueueNotifier.state;
    for (final queue in queueMap.values) {
      for (final snackbar in queue) {
        if (snackbar.id == id || snackbar.uniqueId == id) {
          return true;
        }
      }
    }

    return false;
  }

  /// Gets all currently active modal IDs
  ///
  /// Returns a list of unique IDs for all active modals from the registry.
  /// This is the authoritative source of truth for active modals.
  ///
  /// Useful for debugging or managing complex modal states.
  static List<String> get allActiveModalIds =>
      _modalRegistry.state.keys.toList();

  /// Gets the registry of all active modals
  ///
  /// Returns a map of modal ID to modal type for all currently active modals.
  /// This is useful for debugging or advanced modal management.
  static Map<String, ModalType> get activeModalRegistry =>
      Map.unmodifiable(_modalRegistry.state);

  /// Gets the type of an active modal by its ID
  ///
  /// Returns null if no modal with that ID is currently active.
  static ModalType? getModalTypeById(String id) => _getModalType(id);

  /// Gets all active modal IDs of a specific type
  ///
  /// Useful for operations like "dismiss all snackbars" or checking
  /// how many dialogs are active.
  static List<String> getActiveIdsByType(ModalType type) =>
      _getModalIdsByType(type);

  /// Gets the ID of the currently active dialog (if any)
  static String? get activeDialogId => _dialogController.state?.uniqueId;

  /// Gets the ID of the currently active sheet (if any)
  static String? get activeSheetId => _sheetController.state?.uniqueId;

  /// Gets all IDs of active snackbars
  static List<String> get activeSnackbarIds =>
      _getModalIdsByType(ModalType.snackbar);

  //--------------------------------------------------//
  // Core Modal functionality

  // Commented out feature for tracking new modal displays
  // static final _newModalNotifier = RM.inject<String>(() => '');

  /// Displays a modal on screen
  ///
  /// This is the main entry point for showing modals in the application.
  ///
  /// Parameters:
  /// - `content`: Optional [ModalContent] configuration for the modal.
  ///   If not provided, uses the default template.
  ///
  /// Behavior:
  /// - If no modal is currently active, shows the new modal
  /// - If a modal is already active, replaces it with the new one
  /// - Optimized to avoid unnecessary state changes
  /// - Auto-update: If a modal with the same ID and type is already active, updates it instead of replacing
  ///
  /// Example:
  /// ```dart
  /// // Show a simple bottom sheet
  /// Modal.show();
  ///
  /// // Show a custom dialog
  /// Modal.show(ModalContent(
  ///   widget: MyDialogContent(),
  ///   modalType: ModalType.dialog,
  /// ));
  /// ```
  ///

  /// Displays a modal on screen with simplified API
  ///
  /// This is the main entry point for showing modals in the application.
  /// All parameters from ModalContent are now available directly.
  ///
  /// Example:
  /// ```dart
  /// // Show a simple bottom sheet
  /// Modal.show(
  ///   builder: ([_]) => Text('Hello!'),
  /// );
  ///
  /// // Show a dialog with custom styling
  /// Modal.show(
  ///   builder: ([_]) => MyDialogContent(),
  ///   modalType: ModalType.dialog,
  ///   shouldBlurBackground: true,
  ///   blurAmount: 5.0,
  /// );
  ///
  /// // Show a side sheet
  /// Modal.show(
  ///   builder: ([_]) => MySideMenu(),
  ///   modalType: ModalType.sideSheet,
  ///   sheetPosition: SheetPosition.right,
  ///   width: 300,
  /// );
  /// ```
  static void show({
    BuildContext? context,
    required ModalWidgetBuilder builder,
    String? id,
    ModalType modalType = ModalType.sheet,
    Alignment modalPosition = Alignment.bottomCenter,
    ModalAnimationType modalAnimationType = ModalAnimationType.fade,
    bool shouldBlurBackground = false,
    double blurAmount = 3.0,
    bool isDismissable = true,
    bool blockBackgroundInteraction = false,
    bool isDraggable = false,
    bool isExpandable = false,
    double? size,
    double expandedPercentageSize = 85,
    double contentPaddingByDragHandle = 35.0,
    bool isSwipeable = true,
    Duration? autoDismissDuration,
    SnackbarDisplayMode snackbarDisplayMode = SnackbarDisplayMode.staggered,
    int maxStackedSnackbars = 3,
    Color? backgroundColor,
    double? snackbarWidth,
    Color barrierColor = Colors.transparent,
    Offset? offset,
    SheetPosition? sheetPosition,
    Function? onDismissed,
    VoidCallback? onExpanded,
    VoidCallback? onTap,
  }) {
    // Create internal ModalContent with all the parameters
    final content = _ModalContent(
      builder: builder,
      id: id,
      modalType: modalType,
      modalPosition: modalPosition,
      modalAnimationType: modalAnimationType,
      shouldBlurBackground: shouldBlurBackground,
      blurAmount: blurAmount,
      isDismissable: isDismissable,
      blockBackgroundInteraction: blockBackgroundInteraction,
      isDraggable: isDraggable,
      isExpandable: isExpandable,
      size: size,
      expandedPercentageSize: expandedPercentageSize,
      contentPaddingByDragHandle: contentPaddingByDragHandle,
      isSwipeable: isSwipeable,
      autoDismissDuration: autoDismissDuration,
      snackbarDisplayMode: snackbarDisplayMode,
      maxStackedSnackbars: maxStackedSnackbars,
      backgroundColor: backgroundColor,
      snackbarWidth: snackbarWidth,
      barrierColor: barrierColor,
      offset: offset,
      sheetPosition: sheetPosition,
      onDismissed: onDismissed,
      onExpanded: onExpanded,
      onTap: onTap,
    );

    _showInternal(content, context: context);
  }

  /// Internal method that handles the actual modal display logic
  ///
  /// This method is used by both the new simplified API and legacy code.
  static void _showInternal(_ModalContent content, {BuildContext? context}) {
    final modalContent = content;
    if (_showDebugPrints) {
      debugPrint(
          'Modal.show called: type=${modalContent.modalType}, id=${modalContent.uniqueId}');
    }

    assert(
      _appBuilderInstalled,
      'Modal.appBuilder must be set on MaterialApp.builder (or WidgetsApp.builder) '
      'before showing modals. Wrap your app builder with Modal.appBuilder.',
    );

    // AUTO-UPDATE FEATURE: Check if a modal of the same type with the same user-provided ID
    // is already active. If so, use updateParams instead of replacing the modal.
    // This prevents unnecessary modal recreation when just updating content.
    if (Modal.isActive && modalContent.id != null) {
      _ModalContent? existingModal;

      // Check the appropriate type-specific controller for an existing modal with same ID
      switch (modalContent.modalType) {
        case ModalType.dialog:
          if (Modal.isDialogActive &&
              _dialogController.state?.id == modalContent.id) {
            existingModal = _dialogController.state;
          }
          break;
        case ModalType.sheet:
          if (Modal.isSheetActive &&
              _sheetController.state?.id == modalContent.id) {
            existingModal = _sheetController.state;
          }
          break;
        case ModalType.snackbar:
          if (Modal.isSnackbarActive &&
              _snackbarController.state?.id == modalContent.id) {
            existingModal = _snackbarController.state;
          }
          break;
        case ModalType.custom:
          if (Modal.controller.state?.id == modalContent.id &&
              Modal.controller.state?.modalType == ModalType.custom) {
            existingModal = Modal.controller.state;
          }
          break;
      }

      // If we found an existing modal with the same ID and type, update it instead
      if (existingModal != null) {
        if (_showDebugPrints) {
          debugPrint(
              'Modal.show: Found existing modal with same ID (${modalContent.id}), using updateParams instead');
        }
        Modal.updateParams(
          id: existingModal.uniqueId,
          builder: modalContent.builder,
          builderId: modalContent.builderId,
          blurAmount: modalContent.blurAmount,
          shouldBlurBackground: modalContent.shouldBlurBackground,
          isExpandable: modalContent.isExpandable,
          size: modalContent.size,
          expandedPercentageSize: modalContent.expandedPercentageSize,
          contentPaddingByDragHandle: modalContent.contentPaddingByDragHandle,
          sheetPosition: modalContent.sheetPosition,
          isDismissable: modalContent.isDismissable,
          blockBackgroundInteraction: modalContent.blockBackgroundInteraction,
          isDraggable: modalContent.isDraggable,
          onDismissed: modalContent.onDismissed,
          onExpanded: modalContent.onExpanded,
          modalPosition: modalContent.modalPosition,
          modalAnimationType: modalContent.modalAnimationType,
          isSwipeable: modalContent.isSwipeable,
          autoDismissDuration: modalContent.autoDismissDuration,
          snackbarDisplayMode: modalContent.snackbarDisplayMode,
          maxStackedSnackbars: modalContent.maxStackedSnackbars,
          backgroundColor: modalContent.backgroundColor,
          snackbarWidth: modalContent.snackbarWidth,
          barrierColor: modalContent.barrierColor,
        );
        return;
      }
    }

    // Helper to set the appropriate type-specific controller
    void setTypeController(_ModalContent modalContent) {
      switch (modalContent.modalType) {
        case ModalType.dialog:
          _dialogController.state = modalContent;
          _dialogDismissingNotifier.state = false;
          break;
        case ModalType.sheet:
          _sheetController.state = modalContent;
          _sheetDismissingNotifier.state = false;
          break;
        case ModalType.snackbar:
          _snackbarController.state = modalContent;
          // Clear dismissing state for the new snackbar (it's being shown, not dismissed)
          _setSnackbarDismissing(modalContent.uniqueId, false);
          break;
        case ModalType.custom:
          // Custom modals use only the active modal controller
          break;
      }
    }

    if (!Modal.isActive) {
      // Case: No modal is currently active
      // 1. Ensure dismiss animation is reset
      Modal.dismissModalAnimationController.state = false;

      // 2. Reset the animation value to 0 - it will be animated to 1 in onSetState
      _backgroundLayerAnimationNotifier.state = 0.0;

      // 3. Reset blur state to 0 - it will be animated in onSetState based on shouldBlurBackground
      _blurAnimationStateNotifier.state = 0.0;

      // 4. Initialize blur amount from the content
      _blurAmountNotifier.state = modalContent.blurAmount;

      // 5. For snackbars, initialize the queue at this position
      if (modalContent.modalType == ModalType.snackbar) {
        _snackbarQueueNotifier.state = {
          modalContent.modalPosition: [modalContent]
        };
        _snackbarStackIndexNotifier.state = 0;
      }

      // 6. Set type-specific controller
      setTypeController(modalContent);

      // 7. Register the modal in the registry
      _registerModal(modalContent.uniqueId, modalContent.modalType);

      // 8. Set the active modal controller
      Modal.controller.state = modalContent;
    } else if (Modal.controller.state != modalContent) {
      // Case: Replace existing modal with new content
      // For snackbars, this clears the queue and starts fresh (replaces all)
      if (modalContent.modalType == ModalType.snackbar) {
        _snackbarQueueNotifier.state = {
          modalContent.modalPosition: [modalContent]
        };
        _snackbarStackIndexNotifier.state = 0;
      }
      // IMPORTANT: Do NOT clear snackbar queue when showing dialogs or bottom sheets.
      // Snackbars are independent and should remain visible when other modals are shown.
      // Only clear snackbar queue if we're replacing a snackbar with another snackbar (handled above)
      // or if the user explicitly wants to dismiss snackbars.

      // Handle type-specific controller updates
      final previousType = Modal.controller.state?.modalType;
      if (previousType != null && previousType == modalContent.modalType) {
        // SAME TYPE: Replace the existing modal of this type
        // Unregister the previous modal before replacing
        if (Modal.controller.state != null) {
          _unregisterModal(Modal.controller.state!.uniqueId);
        }

        // For same-type replacement, we just update the controller (handled by setTypeController below)
        // The old modal of this type gets replaced by the new one
      }
      // DIFFERENT TYPE: Dialogs, bottom sheets, and snackbars can coexist
      // Do NOT clear the previous type's controller - it should remain active
      // Do NOT unregister the previous modal - it's still showing

      // Set new type-specific controller
      setTypeController(modalContent);

      // Register the new modal
      _registerModal(modalContent.uniqueId, modalContent.modalType);

      // Update active modal controller
      Modal.controller.state = modalContent;
    }
    // Otherwise: Same modal content, no action needed (performance optimization)
  }

  /// Shows a snackbar with support for multiple stacked snackbars
  ///
  /// This method handles snackbar display differently than regular modals.
  /// Depending on the [displayMode] parameter, snackbars can be:
  ///
  /// - `staggered`: Multiple snackbars stack vertically with staggered animation
  /// - `queued`: Only one snackbar shows at a time, others wait in queue
  /// - `notificationBubble`: Snackbars collapse into a bubble showing count
  /// - `replace`: New snackbar replaces current one (like [show])
  ///
  /// Parameters:
  /// - `content`: The snackbar ModalContent to display
  /// - `displayMode`: How to display when snackbars are already active
  ///   Defaults to [SnackbarDisplayMode.replace]
  ///
  /// Example:
  /// ```dart
  /// // Show a snackbar that stacks with others
  /// Modal.showSnackbar(
  ///   ModalBuilder.snackbar(
  ///     child: Text('Notification 1'),
  ///     displayMode: SnackbarDisplayMode.staggered,
  ///   ),
  /// );
  ///
  /// // Show another snackbar - it will appear above the first
  /// Modal.showSnackbar(
  ///   ModalBuilder.snackbar(
  ///     child: Text('Notification 2'),
  ///     displayMode: SnackbarDisplayMode.staggered,
  ///   ),
  /// );
  /// ```
  /// Shows a snackbar with flexible parameters
  ///
  /// Can be called with simplified inline parameters for quick snackbars:
  /// ```dart
  /// Modal.showSnackbar(
  ///   text: 'Item saved!',
  ///   prefixIcon: Icons.check_circle,
  ///   backgroundColor: Colors.green,
  /// );
  /// ```
  ///
  /// Or with a custom builder for full control:
  /// ```dart
  /// Modal.showSnackbar(
  ///   builder: () => Container(
  ///     decoration: BoxDecoration(...),
  ///     child: Row(children: [...]),
  ///   ),
  ///   position: Alignment.topCenter,
  /// );
  /// ```
  static void showSnackbar({
    BuildContext? context,
    // Simplified API parameters
    String? text,
    IconData? prefixIcon,
    bool showCloseIcon = true,
    Color? backgroundColor,
    Color textColor = Colors.white,
    Color iconColor = Colors.white,

    // Custom builder API
    ModalWidgetBuilder? builder,

    // Common parameters
    Alignment position = Alignment.topCenter,
    Duration? duration = const Duration(seconds: 4),
    bool isDismissible = true,
    Color barrierColor = Colors.transparent,
    SnackbarDisplayMode displayMode = SnackbarDisplayMode.replace,
    String? id,
    double? width,
    Offset? offset,
    int maxStackedSnackbars = 3,
    Function? onDismissed,
    VoidCallback? onTap,
    bool showDurationTimer = true,
    Color? durationTimerColor,
    DurationIndicatorDirection durationTimerDirection =
        DurationIndicatorDirection.leftToRight,
    bool handleDurationTimerManually = false,
  }) {
    if (_showDebugPrints) {
      debugPrint(
          'Modal.showSnackbar called: text=$text, id=$id, position=$position');
    }

    // For staggered and notificationBubble modes, snackbars have infinite duration
    // Only queued and replace modes have auto-dismiss duration
    final effectiveDuration = (displayMode == SnackbarDisplayMode.staggered ||
            displayMode == SnackbarDisplayMode.notificationBubble)
        ? null
        : duration;

    // Check if a snackbar with this ID already exists (active or in queue)
    if (id != null && Modal.isModalActiveById(id)) {
      // debugPrint(
      //     'Modal.showSnackbar: Found existing snackbar with ID=$id, updating params');
      Modal.updateParams(
        id: id,
        // Update content if provided
        builder: builder ??
            (text != null
                ? ([_]) => _ModalContent.defaultSnackbar(
                      text: text,
                      prefixIcon: prefixIcon,
                      showSuffixIcon: showCloseIcon,
                      backgroundColor: backgroundColor,
                      textColor: textColor,
                      iconColor: iconColor,
                      position: position,
                      duration: effectiveDuration,
                      isDismissible: isDismissible,
                      barrierColor: barrierColor,
                      id: id,
                      width: width,
                      offset: offset,
                      displayMode: displayMode,
                      maxStackedSnackbars: maxStackedSnackbars,
                      showDurationTimer: showDurationTimer,
                      durationTimerColor: durationTimerColor,
                      durationTimerDirection: durationTimerDirection,
                    ).buildContent()
                : null),
        // Update other params
        modalPosition: position,
        autoDismissDuration: effectiveDuration,
        isDismissable: isDismissible,
        snackbarDisplayMode: displayMode,
        maxStackedSnackbars: maxStackedSnackbars,
        snackbarWidth: width,
        backgroundColor: backgroundColor,
        barrierColor: barrierColor,
        offset: offset,
      );
      return;
    }

    // Determine which API is being used
    if (text != null && builder == null) {
      // Simplified inline API
      final content = _ModalContent.defaultSnackbar(
        text: text,
        prefixIcon: prefixIcon,
        showSuffixIcon: showCloseIcon,
        backgroundColor: backgroundColor,
        textColor: textColor,
        iconColor: iconColor,
        position: position,
        duration: effectiveDuration,
        isDismissible: isDismissible,
        barrierColor: barrierColor,
        id: id,
        width: width,
        offset: offset,
        displayMode: displayMode,
        maxStackedSnackbars: maxStackedSnackbars,
        onDismissed: onDismissed,
        onTap: onTap,
        showDurationTimer: showDurationTimer,
        durationTimerColor: durationTimerColor,
        durationTimerDirection: durationTimerDirection,
      );
      _showSnackbarContent(content, displayMode);
    } else if (builder != null && text == null) {
      // Custom builder API
      // Wrap the builder with duration indicator if not handling manually
      final effectiveBuilder = (showDurationTimer &&
              !handleDurationTimerManually &&
              effectiveDuration != null)
          ? () => _wrapWithDurationIndicator(
                builder(),
                effectiveDuration,
                durationTimerColor,
                durationTimerDirection,
              )
          : builder;

      final content = _ModalContent(
        builder: effectiveBuilder,
        modalType: ModalType.snackbar,
        modalPosition: position,
        autoDismissDuration: effectiveDuration,
        isDismissable: isDismissible,
        // For snackbars, isSwipeable is controlled by isDismissible
        isSwipeable: isDismissible,
        snackbarDisplayMode: displayMode,
        maxStackedSnackbars: maxStackedSnackbars,
        id: id,
        snackbarWidth: width,
        barrierColor: barrierColor,
        offset: offset,
        onDismissed: onDismissed,
        onTap: onTap,
      );
      _showSnackbarContent(content, displayMode);
    } else if (builder != null && text != null) {
      throw ArgumentError(
        'Cannot specify both text and builder. Use text for simple snackbars or builder for custom UI.',
      );
    } else {
      throw ArgumentError(
        'Must specify either text or builder parameter.',
      );
    }
  }

  /// Creates a duration indicator widget for use in custom snackbar builders
  ///
  /// This provides a convenient way to add a progress bar to custom snackbars
  /// when using `handleDurationTimerManually: true`. The indicator shows
  /// the remaining time before the snackbar auto-dismisses.
  ///
  /// Example usage with a custom builder:
  /// ```dart
  /// Modal.showSnackbar(
  ///   handleDurationTimerManually: true,
  ///   duration: const Duration(seconds: 4),
  ///   builder: ([_]) => Column(
  ///     mainAxisSize: MainAxisSize.min,
  ///     children: [
  ///       // Your custom content here
  ///       Container(
  ///         padding: const EdgeInsets.all(16),
  ///         child: Text('Custom snackbar'),
  ///       ),
  ///       // Add the duration indicator at the bottom (or anywhere you want)
  ///       Modal.durationIndicator(
  ///         duration: const Duration(seconds: 4),
  ///         color: Colors.blue,
  ///       ),
  ///     ],
  ///   ),
  /// );
  /// ```
  ///
  /// Parameters:
  /// - [duration]: The total duration of the snackbar (required)
  /// - [height]: Height of the progress bar (default: 3.0)
  /// - [color]: Color of the progress bar (default: amber)
  /// - [backgroundColor]: Background track color (default: color with 30% opacity)
  /// - [borderRadius]: Border radius for the indicator
  /// - [direction]: Direction of progress animation (leftToRight or rightToLeft)
  Widget durationIndicator({
    required Duration duration,
    double height = 3.0,
    Color? color,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    DurationIndicatorDirection direction =
        DurationIndicatorDirection.leftToRight,
  }) {
    final effectiveColor = color ?? Colors.amber;
    return SnackbarDurationIndicator(
      duration: duration,
      height: height,
      color: effectiveColor,
      backgroundColor: backgroundColor ?? effectiveColor.withValues(alpha: 0.3),
      borderRadius: borderRadius,
      direction: direction,
    );
  }

  /// Wraps custom snackbar content with a duration indicator at the bottom
  ///
  /// This helper is used when [showDurationTimer] is true but
  /// [handleDurationTimerManually] is false. It overlays the duration indicator
  /// at the bottom of the snackbar content using a Stack, so it appears as if
  /// it's part of the snackbar itself.
  ///
  /// The indicator is positioned at the bottom with matching horizontal margins
  /// (16px) plus internal padding (typically ~8px from snackbar bottom margin)
  /// to align with typical custom snackbar bounds. The bottom corners are rounded
  /// to match typical snackbar styling (12px radius).
  static Widget _wrapWithDurationIndicator(
    Widget content,
    Duration duration,
    Color? timerColor,
    DurationIndicatorDirection direction,
  ) {
    final effectiveColor = timerColor ?? Colors.amber;
    return Stack(
      children: [
        content,
        // Position the indicator at the bottom of the snackbar
        Positioned(
          left: 16, // Match typical snackbar horizontal margin
          right: 16,
          bottom: 8, // Match typical snackbar vertical margin
          child: ClipRRect(
            // Use bottom corners radius to match typical snackbar border radius
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: SnackbarDurationIndicator(
              duration: duration,
              height: 4.0,
              color: effectiveColor,
              backgroundColor: effectiveColor.withValues(alpha: 0.3),
              direction: direction,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Internal helper to show snackbar content
  ///
  /// Uses the snackbar-specific controller and dismissing state to ensure
  /// independence from dialog/bottomsheet lifecycle.
  static void _showSnackbarContent(
    _ModalContent content,
    SnackbarDisplayMode displayMode,
  ) {
    // debugPrint(
    //     'Modal._showSnackbarContent: id=${content.uniqueId}, mode=$displayMode');
    final currentQueueMap = Modal.snackbarQueue.state;
    final position = content.modalPosition;
    final positionQueue = currentQueueMap[position] ?? [];

    // Helper to check if any snackbars are currently displayed
    bool hasAnySnackbars() {
      for (final queue in currentQueueMap.values) {
        if (queue.isNotEmpty) return true;
      }
      return false;
    }

    // Helper to check if we should activate the snackbar
    // Snackbars use their own dismissing state, independent from dialogs/bottomsheets.
    // This means showing a snackbar while a dialog is dismissing will work correctly.
    bool shouldActivateSnackbar() {
      // Only block if SNACKBAR system itself is dismissing, not other modal types
      return !Modal.isSnackbarDismissing;
    }

    // Helper to activate a snackbar as the current snackbar modal
    // NOTE: Registration is handled separately when adding to queue
    void activateSnackbar(_ModalContent snackbarContent) {
      // Ensure this snackbar is not marked as dismissing (it's being activated)
      _setSnackbarDismissing(snackbarContent.uniqueId, false);
      _snackbarController.state = snackbarContent;

      // Also set active modal controller and reset animations
      Modal.dismissModalAnimationController.state = false;

      // CRITICAL: Only reset background/blur if no other modals are active.
      // If a bottom sheet or dialog is already showing, we must PRESERVE their
      // background blur effect. Snackbars are overlays that don't need their own blur.
      if (!Modal.isDialogActive && !Modal.isSheetActive) {
        _backgroundLayerAnimationNotifier.state = 0.0;
        _blurAnimationStateNotifier.state = 0.0;
        // Only set blur amount if no other modals - otherwise keep existing blur
        _blurAmountNotifier.state = snackbarContent.blurAmount;
      }
      // NOTE: We intentionally do NOT update _blurAmountNotifier when other modals
      // are active, as that would override their blur settings.

      Modal.controller.state = snackbarContent;
    }

    switch (displayMode) {
      case SnackbarDisplayMode.staggered:
        // Keep ALL snackbars in the queue - we only limit what's DISPLAYED,
        // not what's stored. This allows older snackbars to become visible
        // again when newer ones are dismissed.
        List<_ModalContent> newQueue = [...positionQueue, content];

        // Update stack index
        final newIndex = newQueue.length;
        _snackbarStackIndexNotifier.state = newIndex;

        // Update queue map
        final updatedQueueMap =
            Map<Alignment, List<_ModalContent>>.from(currentQueueMap);
        updatedQueueMap[position] = newQueue;
        _snackbarQueueNotifier.state = updatedQueueMap;

        // Register the snackbar in the registry when added to queue
        _registerModal(content.uniqueId, ModalType.snackbar);

        // If this is the first snackbar overall AND snackbar system is not dismissing,
        // show it immediately. Otherwise it stays in queue and will be shown
        // once the snackbar dismissal completes.
        if (!hasAnySnackbars() && shouldActivateSnackbar()) {
          activateSnackbar(content);
        }
        // Additional snackbars will be rendered separately in the UI
        break;

      case SnackbarDisplayMode.queued:
        // Add to queue regardless of limit; wait for others to finish
        final updatedQueueMap =
            Map<Alignment, List<_ModalContent>>.from(currentQueueMap);
        updatedQueueMap[position] = [...positionQueue, content];
        _snackbarQueueNotifier.state = updatedQueueMap;

        // Register the snackbar in the registry when added to queue
        _registerModal(content.uniqueId, ModalType.snackbar);

        if (!hasAnySnackbars() && shouldActivateSnackbar()) {
          // Show immediately if queue was empty AND snackbar system not dismissing
          activateSnackbar(content);
        }
        break;

      case SnackbarDisplayMode.notificationBubble:
        // NOTIFICATION BUBBLE: Accumulate unlimited snackbars, show first with count badge
        // No limit on queue size - all snackbars accumulate and the badge shows the count
        final newIndex = positionQueue.length;
        _snackbarStackIndexNotifier.state = newIndex;
        final updatedQueueMap =
            Map<Alignment, List<_ModalContent>>.from(currentQueueMap);
        updatedQueueMap[position] = [...positionQueue, content];
        _snackbarQueueNotifier.state = updatedQueueMap;

        // Register the snackbar in the registry when added to queue
        _registerModal(content.uniqueId, ModalType.snackbar);

        if (!hasAnySnackbars() && shouldActivateSnackbar()) {
          activateSnackbar(content);
        }
        break;

      case SnackbarDisplayMode.replace:
        // Clear queue and show new snackbar (standard modal show behavior)
        // First, unregister all existing snackbars being replaced
        for (final queue in currentQueueMap.values) {
          for (final snackbar in queue) {
            _unregisterModal(snackbar.uniqueId);
          }
        }

        _snackbarQueueNotifier.state = {
          position: [content]
        };
        _snackbarStackIndexNotifier.state = 0;

        // Register the new snackbar
        _registerModal(content.uniqueId, ModalType.snackbar);

        // Only activate if snackbar system is NOT currently dismissing.
        // If we are dismissing, the snackbar stays in queue and will be
        // shown automatically once the dismissal completes.
        if (shouldActivateSnackbar() &&
            (!Modal.isSnackbarActive ||
                Modal.snackbarController.state != content)) {
          activateSnackbar(content);
        }
        break;
    }
  }

  /// Removes a snackbar from the queue and shows the next one if available
  ///
  /// Called internally when a snackbar finishes its auto-dismiss timer
  /// or is swiped away by the user.
  ///
  /// The [position] parameter specifies which position's queue to remove from.
  /// If not provided, it uses the current modal's position.
  ///
  /// The [immediate] parameter, when true, skips the dismiss animation delay.
  /// This is used when `Dismissible` has already animated the snackbar out.
  static void _removeSnackbarFromQueue(
      [Alignment? position, bool immediate = false]) {
    if (_showDebugPrints) {
      debugPrint(
          'Modal._removeSnackbarFromQueue: position=$position, immediate=$immediate, isDismissing=${Modal.isSnackbarDismissing}, isBottomSheetDismissing=${Modal.isSheetDismissing}, isDialogDismissing=${Modal.isDialogDismissing}');
    }

    // Guard: If a dialog or bottom sheet is currently dismissing, defer snackbar removal
    // to avoid state conflicts. The snackbar can be removed after the dismissal completes.
    if (Modal.isSheetDismissing || Modal.isDialogDismissing) {
      if (_showDebugPrints) {
        debugPrint(
            'Modal._removeSnackbarFromQueue: deferred - another modal is dismissing');
      }
      // Schedule removal after dismissal completes
      _snackbarRetryTimer?.cancel();
      _snackbarRetryTimer = Timer(const Duration(milliseconds: 500), () {
        _snackbarRetryTimer = null;
        if (!Modal.isSheetDismissing && !Modal.isDialogDismissing) {
          _removeSnackbarFromQueue(position, immediate);
        }
      });
      return;
    }

    final currentQueueMap = Modal.snackbarQueue.state;
    final targetPosition = position ?? Modal.controller.state?.modalPosition;

    if (targetPosition == null) return;

    final positionQueue = currentQueueMap[targetPosition] ?? [];

    if (positionQueue.isNotEmpty) {
      // For staggered and notificationBubble modes, the LAST item in queue is the frontmost (newest) snackbar
      // that the user is interacting with. For other modes (queued, replace), it's the first item.
      final displayMode = positionQueue.first.snackbarDisplayMode;
      final showsNewest = displayMode == SnackbarDisplayMode.staggered ||
          displayMode == SnackbarDisplayMode.notificationBubble;

      final snackbarToRemove =
          showsNewest ? positionQueue.last : positionQueue.first;
      final snackbarToRemoveId = snackbarToRemove.uniqueId;
      final isActiveSnackbar =
          _snackbarController.state?.uniqueId == snackbarToRemoveId;

      // Capture the onDismissed callback before removal
      final onDismissedCallback = snackbarToRemove.onDismissed;

      // Helper to perform the actual removal
      void performRemoval() {
        // Re-fetch queue as it might have changed
        final currentQueueMap = Modal.snackbarQueue.state;
        final positionQueue = currentQueueMap[targetPosition] ?? [];
        if (positionQueue.isEmpty) return;

        // Remove the appropriate snackbar based on display mode
        // Staggered/notificationBubble: remove last (newest/frontmost)
        // Queued/replace: remove first (oldest/frontmost)
        final List<_ModalContent> updatedPositionQueue;
        if (showsNewest) {
          // Remove the last item (newest snackbar at the front)
          updatedPositionQueue =
              positionQueue.sublist(0, positionQueue.length - 1);
        } else {
          // Remove the first item
          updatedPositionQueue = positionQueue.sublist(1);
        }

        final updatedQueueMap =
            Map<Alignment, List<_ModalContent>>.from(currentQueueMap);

        if (updatedPositionQueue.isEmpty) {
          updatedQueueMap.remove(targetPosition);
        } else {
          updatedQueueMap[targetPosition] = updatedPositionQueue;
        }

        _snackbarQueueNotifier.state = updatedQueueMap;

        // Unregister the removed snackbar from the modal registry
        _unregisterModal(snackbarToRemoveId);

        // Check if any snackbars remain across all positions
        bool hasAnySnackbars = false;
        for (final queue in updatedQueueMap.values) {
          if (queue.isNotEmpty) {
            hasAnySnackbars = true;
            break;
          }
        }

        if (hasAnySnackbars) {
          // Still have snackbars visible
          // IMPORTANT: Prioritize snackbars from the SAME POSITION that just had one removed
          // This maintains position-specific queue semantics (queued/staggered at that position)
          final removedPosition = targetPosition;
          final nextSnackbarInSamePosition =
              updatedQueueMap[removedPosition]?.isNotEmpty == true
                  ? updatedQueueMap[removedPosition]!.first
                  : null;

          _ModalContent? nextSnackbar = nextSnackbarInSamePosition;

          // If no snackbars remain in the same position, find ANY snackbar from other positions
          if (nextSnackbar == null) {
            for (final entry in updatedQueueMap.entries) {
              if (entry.value.isNotEmpty) {
                nextSnackbar = entry.value.first;
                break;
              }
            }
          }

          if (nextSnackbar != null) {
            // Reset snackbar-specific dismiss state and activate the next snackbar
            _snackbarStackIndexNotifier.state = 0;
            if (Modal.dismissModalAnimationController.state != false) {
              Modal.dismissModalAnimationController.state = false;
            }

            // Only reset background/blur if no dialog or bottom sheet is active
            // Otherwise we must preserve their blur effect
            if (!Modal.isDialogActive && !Modal.isSheetActive) {
              _backgroundLayerAnimationNotifier.state = 0.0;
              _blurAnimationStateNotifier.state = 0.0;
              _blurAmountNotifier.state = nextSnackbar.blurAmount;
            }

            // Activate the next snackbar using the snackbar-specific controller
            // Clear dismissing state for this snackbar (it's now the active one)
            _setSnackbarDismissing(snackbarToRemoveId, false);
            _snackbarController.state = nextSnackbar;
            // Note: Snackbar should already be registered when added to queue,
            // but this call is a safety net (idempotent - just updates same key)

            // Also update the global active modal controller
            if (Modal.controller.state?.id != nextSnackbar.id) {
              Modal.controller.state = nextSnackbar;
            }
          }
        } else {
          // No more snackbars in any queue - clean up snackbar state only
          _snackbarController.refresh();
          _clearAllSnackbarDismissing();

          // Update active modal controller to point to remaining modal if any
          if (Modal.isDialogActive) {
            _activeModalController.state = _dialogController.state;
          } else if (Modal.isSheetActive) {
            _activeModalController.state = _sheetController.state;
          } else {
            // No other modals active - clear everything
            _activeModalController.refresh();
            _backgroundLayerAnimationNotifier.state = 0.0;
            _blurAnimationStateNotifier.state = 0.0;
          }
        }

        // Call the onDismissed callback if provided
        onDismissedCallback?.call();
      }

      if (isActiveSnackbar &&
          !_isSnackbarDismissing(snackbarToRemoveId) &&
          !immediate) {
        // Normal dismiss with animation delay - mark THIS SPECIFIC snackbar as dismissing
        _setSnackbarDismissing(snackbarToRemoveId, true);
        Future.delayed(0.3.sec, () {
          performRemoval();
          _setSnackbarDismissing(snackbarToRemoveId, false);
          // Reset swipe direction after removal
          _snackbarSwipeDismissDirectionNotifier.state = '';
        });
      } else {
        // Immediate removal (Dismissible already animated, or not the active snackbar)
        // Perform removal synchronously to avoid blocking new snackbars
        performRemoval();
        // Ensure dismissing state is reset for this specific snackbar
        _setSnackbarDismissing(snackbarToRemoveId, false);
        // Reset swipe direction immediately after immediate removal
        _snackbarSwipeDismissDirectionNotifier.state = '';
      }
    }
  }

  /// Removes a specific snackbar from the queue by its unique ID
  ///
  /// This is used when dismissing a specific snackbar from the expanded
  /// staggered view, where any snackbar in the list can be dismissed.
  static void _removeSnackbarByIdFromQueue(
      String snackbarId, Alignment position) {
    if (_showDebugPrints) {
      debugPrint(
          'Modal._removeSnackbarByIdFromQueue: id=$snackbarId, position=$position');
    }

    final currentQueueMap = Modal.snackbarQueue.state;
    final positionQueue = currentQueueMap[position] ?? [];

    if (positionQueue.isEmpty) return;

    // Find the snackbar with this ID
    final snackbarIndex =
        positionQueue.indexWhere((s) => s.uniqueId == snackbarId);
    if (snackbarIndex == -1) {
      // debugPrint(
      //     'Modal._removeSnackbarByIdFromQueue: snackbar not found in queue');
      return;
    }

    // Capture the onDismissed callback before removal
    final snackbarToRemove = positionQueue[snackbarIndex];
    final onDismissedCallback = snackbarToRemove.onDismissed;

    // Create new list without this snackbar
    final updatedPositionQueue = List<_ModalContent>.from(positionQueue)
      ..removeAt(snackbarIndex);

    final updatedQueueMap =
        Map<Alignment, List<_ModalContent>>.from(currentQueueMap);

    if (updatedPositionQueue.isEmpty) {
      updatedQueueMap.remove(position);
    } else {
      updatedQueueMap[position] = updatedPositionQueue;
    }

    _snackbarQueueNotifier.state = updatedQueueMap;

    // Unregister the removed snackbar from the modal registry
    _unregisterModal(snackbarId);

    // Check if any snackbars remain across all positions
    bool hasAnySnackbars = false;
    for (final queue in updatedQueueMap.values) {
      if (queue.isNotEmpty) {
        hasAnySnackbars = true;
        break;
      }
    }

    if (!hasAnySnackbars) {
      // No more snackbars - clean up state
      _snackbarController.refresh();
      _clearAllSnackbarDismissing();

      if (Modal.isDialogActive) {
        _activeModalController.state = _dialogController.state;
      } else if (Modal.isSheetActive) {
        _activeModalController.state = _sheetController.state;
      } else {
        _activeModalController.refresh();
        _backgroundLayerAnimationNotifier.state = 0.0;
        _blurAnimationStateNotifier.state = 0.0;
      }
    }

    // Call the onDismissed callback if provided
    onDismissedCallback?.call();
  }

  /// Updates specific parameters of an active modal without recreating the entire ModalContent
  ///
  /// This method allows you to update individual modal properties while maintaining
  /// the existing widget and other settings. All parameters are optional - only
  /// provide the ones you want to change.
  ///
  /// Parameters:
  /// - `blurAmount`: Update the background blur intensity (0.0 to 20.0)
  /// - `shouldBlurBackground`: Enable/disable background blur effect
  /// - `height`: Update the modal height
  /// - `widget`: Replace the modal's widget content
  /// - `expandedHeightPercent`: Update the expanded height percentage
  /// - `isDismissable`: Change whether the modal can be dismissed
  /// - `onDismissed`: Update the dismissal callback
  /// - `onExpanded`: Update the expansion callback
  ///
  /// Example:
  /// ```dart
  /// // Update blur amount only (for live slider updates)
  /// Modal.updateParams(id: 'my_modal_id', blurAmount: 7.5);
  ///
  /// // Toggle blur on/off
  /// Modal.updateParams(id: 'my_modal_id', shouldBlurBackground: true);
  ///
  /// // Update height
  /// Modal.updateParams(id: 'my_modal_id', height: 500);
  ///
  /// // Update multiple parameters at once
  /// Modal.updateParams(
  ///   id: 'my_modal_id',
  ///   blurAmount: 5.0,
  ///   height: 300,
  ///   isDismissable: false,
  /// );
  ///
  /// // Update snackbar-specific parameters
  /// Modal.updateParams(
  ///   id: 'my_modal_id',
  ///   isSwipeable: false,
  ///   autoDismissDuration: Duration(seconds: 5),
  /// );
  /// ```
  static void updateParams({
    required String id,
    // Content parameters
    ModalWidgetBuilder? builder,
    String? builderId,
    // Blur parameters
    double? blurAmount,
    bool? shouldBlurBackground,
    // Size parameters (unified for all sheet types)
    bool? isExpandable,
    double? size,
    bool resetSize = false,
    double? expandedPercentageSize,
    double? contentPaddingByDragHandle,
    SheetPosition? sheetPosition,
    // Behavior parameters
    bool? isDismissable,
    bool? blockBackgroundInteraction,
    bool? isDraggable,
    Function? onDismissed,
    Function? onExpanded,
    // Modal type and position (use with caution - changing type mid-display may cause issues)
    ModalType? modalType,
    Alignment? modalPosition,
    ModalAnimationType? modalAnimationType,
    // Snackbar-specific parameters
    bool? isSwipeable,
    Duration? autoDismissDuration,
    SnackbarDisplayMode? snackbarDisplayMode,
    int? maxStackedSnackbars,
    // Appearance parameters
    Color? backgroundColor,
    bool resetBackgroundColor = false,
    double? snackbarWidth,
    Color? barrierColor,
    Offset? offset = _noOffsetChange,
  }) {
    // 1. Find the target modal content
    _ModalContent? targetContent;
    bool isInQueue = false;
    Alignment? queuePosition;
    int? queueIndex;

    // Check active controllers
    if (_dialogController.state?.uniqueId == id ||
        _dialogController.state?.id == id) {
      targetContent = _dialogController.state;
    } else if (_sheetController.state?.uniqueId == id ||
        _sheetController.state?.id == id) {
      targetContent = _sheetController.state;
    } else if (_snackbarController.state?.uniqueId == id ||
        _snackbarController.state?.id == id) {
      targetContent = _snackbarController.state;
    } else if (Modal.controller.state?.uniqueId == id ||
        Modal.controller.state?.id == id) {
      // Fallback for custom or if active controller is set but specific one isn't
      targetContent = Modal.controller.state;
    }

    // Check snackbar queue if not found yet
    if (targetContent == null) {
      final queueMap = _snackbarQueueNotifier.state;
      for (final entry in queueMap.entries) {
        final index =
            entry.value.indexWhere((c) => c.uniqueId == id || c.id == id);
        if (index != -1) {
          targetContent = entry.value[index];
          isInQueue = true;
          queuePosition = entry.key;
          queueIndex = index;
          break;
        }
      }
    }

    if (targetContent == null) {
      if (_showDebugPrints) {
        debugPrint('Modal.updateParams: No modal found with ID=$id');
      }
      return;
    }

    final newModalType = modalType ?? targetContent.modalType;

    // Create a new ModalContent with updated parameters
    // IMPORTANT: Pass the original uniqueId to preserve widget identity
    final updatedContent = _ModalContent(
      // Preserve identity to avoid widget recreation
      id: targetContent.uniqueId,
      // Content parameters
      builder: builder ?? targetContent.builder,
      builderId: builderId ?? targetContent.builderId,
      // Blur parameters
      blurAmount: blurAmount ?? targetContent.blurAmount,
      shouldBlurBackground:
          shouldBlurBackground ?? targetContent.shouldBlurBackground,
      // Size parameters
      isExpandable: isExpandable ?? targetContent.isExpandable,
      size: resetSize ? null : (size ?? targetContent.size),
      expandedPercentageSize:
          expandedPercentageSize ?? targetContent.expandedPercentageSize,
      contentPaddingByDragHandle: contentPaddingByDragHandle ??
          targetContent.contentPaddingByDragHandle,
      sheetPosition: sheetPosition ?? targetContent.sheetPosition,
      // Behavior parameters
      isDismissable: isDismissable ?? targetContent.isDismissable,
      blockBackgroundInteraction: blockBackgroundInteraction ??
          targetContent.blockBackgroundInteraction,
      isDraggable: isDraggable ?? targetContent.isDraggable,
      onDismissed: onDismissed ?? targetContent.onDismissed,
      onExpanded: onExpanded ?? targetContent.onExpanded,
      // Modal type and position
      modalType: newModalType,
      modalPosition: modalPosition ?? targetContent.modalPosition,
      modalAnimationType:
          modalAnimationType ?? targetContent.modalAnimationType,
      // Snackbar-specific parameters
      isSwipeable: isSwipeable ?? targetContent.isSwipeable,
      autoDismissDuration:
          autoDismissDuration ?? targetContent.autoDismissDuration,
      snackbarDisplayMode:
          snackbarDisplayMode ?? targetContent.snackbarDisplayMode,
      maxStackedSnackbars:
          maxStackedSnackbars ?? targetContent.maxStackedSnackbars,
      // Appearance parameters
      backgroundColor: resetBackgroundColor
          ? null
          : (backgroundColor ?? targetContent.backgroundColor),
      offset: offset == _noOffsetChange ? targetContent.offset : offset,
      snackbarWidth: snackbarWidth ?? targetContent.snackbarWidth,
      barrierColor: barrierColor ?? targetContent.barrierColor,
    );

    // Apply update
    if (isInQueue && queuePosition != null && queueIndex != null) {
      // Update in queue
      final currentQueueMap = _snackbarQueueNotifier.state;
      final updatedQueue =
          List<_ModalContent>.from(currentQueueMap[queuePosition]!);
      updatedQueue[queueIndex] = updatedContent;

      final updatedQueueMap =
          Map<Alignment, List<_ModalContent>>.from(currentQueueMap);
      updatedQueueMap[queuePosition] = updatedQueue;
      _snackbarQueueNotifier.state = updatedQueueMap;
    } else {
      // Update active controller(s)
      // If it's the active global modal, update it
      if (Modal.controller.state?.uniqueId == targetContent.uniqueId) {
        Modal.controller.state = updatedContent;
      }

      // Update type-specific controller based on NEW modal type
      switch (newModalType) {
        case ModalType.dialog:
          _dialogController.state = updatedContent;
          // Clear other controllers if type changed
          if (targetContent.modalType != ModalType.dialog) {
            _sheetController.state = null;
            _snackbarController.state = null;
          }
          break;
        case ModalType.sheet:
          _sheetController.state = updatedContent;
          // Clear other controllers if type changed
          if (targetContent.modalType != ModalType.sheet) {
            _dialogController.state = null;
            _snackbarController.state = null;
          }
          break;
        case ModalType.snackbar:
          _snackbarController.state = updatedContent;
          // Clear other controllers if type changed
          if (targetContent.modalType != ModalType.snackbar) {
            _dialogController.state = null;
            _sheetController.state = null;
          }
          break;
        case ModalType.custom:
          // Custom modals use only active modal controller
          // Clear type-specific controllers if type changed
          if (targetContent.modalType != ModalType.custom) {
            _dialogController.state = null;
            _sheetController.state = null;
            _snackbarController.state = null;
          }
          break;
      }
    }
  }

  /// Callback reference for resetting the modal height measurement
  /// Used to clear cached height values when a modal is dismissed
  static VoidCallback? _resetHeightCallback;

  /// Registers a callback function to reset modal height measurements
  ///
  /// This method is used internally by the modal system to ensure
  /// that height measurements are properly reset between modal displays,
  /// especially when consecutive modals have different content heights.
  ///
  /// Parameters:
  /// - `callback`: A function to call when height needs to be reset
  static void registerHeightResetCallback(VoidCallback callback) {
    _resetHeightCallback = callback;
  }

  /// Flag to track if a dismissal operation is in progress
  /// Prevents multiple simultaneous dismissals
  static bool isDismissing = false;

  /// Timer for retrying snackbar removal
  static Timer? _snackbarRetryTimer;

  /// Timer for background animation during dismissal
  static Timer? _backgroundAnimationTimer;

  /// Dismisses the currently active modal
  ///
  /// This method handles the complete dismissal process including:
  /// - Running all registered callbacks
  /// - Triggering appropriate animations
  /// - Cleaning up resources after animation completes
  ///
  /// Parameters:
  /// - `onModalDismissed`: Optional callback that runs when dismissal completes.
  ///   This is in addition to any callback defined in the ModalContent.
  ///
  /// Returns:
  /// - `Future<void>` that completes when the dismissal process is finished
  ///
  /// Example:
  /// ```dart
  /// // Simple dismissal
  /// Modal.dismiss();
  ///
  /// // Dismissal with a callback
  /// Modal.dismiss(onModalDismissed: () {
  ///   print('Modal has been dismissed');
  /// });
  /// ```
  /// Dismisses the currently active modal (dialog or bottom sheet)
  ///
  /// Does NOT dismiss snackbars.
  /// If a snackbar is active, calling this will dismiss the snackbar.
  /// If no modal is active, this does nothing.
  ///
  /// Example:
  /// ```dart
  /// Modal.dismissCurrentModal();
  /// ```
  Future<void> dismissCurrentModal({VoidCallback? onModalDismissed}) async {
    final activeId = _activeModalController.state?.uniqueId;
    if (activeId != null) {
      await dismissById(activeId, onDismissed: onModalDismissed);
    }
  }

  /// Dismisses all snackbars while preserving other active modals
  ///
  /// Clears the snackbar queue without affecting dialogs or bottom sheets.
  /// This is the key benefit of the type-specific controller architecture -
  /// snackbar dismissal is completely independent from other modal types.
  ///
  /// Example:
  /// ```dart
  /// Modal.dismissAllSnackbars();
  /// ```
  static void dismissAllSnackbars() {
    final currentQueue = _snackbarQueueNotifier.state;
    if (currentQueue.isNotEmpty) {
      // CAPTURE IDs of all snackbars being dismissed for tracking
      final dismissedIds = <String>[];
      for (final position in currentQueue.keys) {
        for (final snackbar in currentQueue[position]!) {
          dismissedIds.add(snackbar.uniqueId);
        }
      }
      if (_showDebugPrints) {
        debugPrint(
            'Modal.dismissAllSnackbars: dismissing ${dismissedIds.length} snackbars: $dismissedIds');
      }

      // Unregister all snackbars from registry
      _unregisterModals(dismissedIds);

      _snackbarQueueNotifier.state = {};
      _snackbarStackIndexNotifier.state = 0;
      _snackbarController.refresh();
      _clearAllSnackbarDismissing();
      _staggeredExpandedNotifier.state = null;

      // If only snackbars were visible (no dialog/bottomsheet), also clear active modal controller
      if (Modal.controller.state?.modalType == ModalType.snackbar) {
        Modal.controller.refresh();
      }

      if (_showDebugPrints) {
        debugPrint(
            'Modal.dismissAllSnackbars: completed dismissing IDs: $dismissedIds');
      }
    }
  }

  /// Dismisses a specific snackbar by its ID
  ///
  /// This method searches through the snackbar queue for a snackbar matching
  /// the given ID and dismisses only that specific snackbar, preserving all
  /// other snackbars, dialogs, and bottom sheets.
  ///
  /// Parameters:
  /// - `id`: The ID of the snackbar to dismiss (required)
  /// - `onDismissed`: Optional callback executed after the snackbar is dismissed
  ///
  /// Returns `true` if a snackbar with the given ID was found and dismissed,
  /// `false` if no snackbar with that ID was found.
  ///
  /// Example:
  /// ```dart
  /// Modal.showSnackbar(text: 'Message', id: 'my_snack');
  /// // Later...
  /// await Modal.dismissSnackbar('my_snack');
  /// ```
  Future<bool> dismissSnackbar(String id, {VoidCallback? onDismissed}) async {
    return await dismissById(id, onDismissed: onDismissed);
  }

  /// Dismisses all active modals of all types immediately
  ///
  /// This method immediately clears all dialogs, bottom sheets, and snackbars
  /// without animations. Use this when you need to reset the modal state
  /// completely, such as before showing a new set of modals.
  ///
  /// For animated dismissal of specific modals, use the type-specific methods:
  /// - [dismissDialog] for dialogs
  /// - [dismissBottomSheet] for bottom sheets
  /// - [dismissById] for any modal by ID
  ///
  /// Parameters:
  /// - `onDismissed`: Optional callback executed after all modals are dismissed
  ///
  /// Example:
  /// ```dart
  /// // Dismiss everything immediately
  /// Modal.dismissAll();
  ///
  /// // Dismiss everything with callback
  /// Modal.dismissAll(onDismissed: () => print('All modals dismissed'));
  /// ```
  static void dismissAll({VoidCallback? onDismissed}) {
    if (_showDebugPrints) {
      debugPrint('Modal.dismissAll: dismissing all modals');
    }

    // Web/engine safety: Avoid mutating the overlay/widget tree in the middle of
    // a frame/scheduler callback. This prevents rare "Trying to render a disposed
    // EngineFlutterView" assertions when dismissAll is triggered during a draw.
    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        dismissAll(onDismissed: onDismissed);
      });
      return;
    }

    // Immediate reset - clear all controllers without animations
    _snackbarQueueNotifier.state = {};
    _snackbarController.refresh();
    _clearAllSnackbarDismissing();
    _snackbarStackIndexNotifier.state = 0;
    _staggeredExpandedNotifier.state = null;

    // Explicitly cancel any pending timers to prevent leaks and test failures
    _backgroundAnimationTimer?.cancel();
    _backgroundAnimationTimer = null;
    _snackbarRetryTimer?.cancel();
    _snackbarRetryTimer = null;

    _dialogController.refresh();
    _dialogDismissingNotifier.state = false;

    _sheetController.refresh();
    _sheetDismissingNotifier.state = false;
    _resetHeightCallback?.call();
    _modalSheetHeightNotifier.state = 0.0;
    _modalDragOffsetNotifier.state = 0.0;

    _activeModalController.refresh();
    _dismissModalAnimationController.state = false;
    _backgroundLayerAnimationNotifier.state = 0.0;
    _blurAnimationStateNotifier.state = 0.0;

    // Clear the entire modal registry
    _modalRegistry.state = {};

    Modal.isDismissing = false;

    onDismissed?.call();
    // debugPrint('Modal.dismissAll: completed');
  }

  /// Dismisses multiple modals by their IDs
  ///
  /// This method attempts to dismiss each modal in the provided list of IDs.
  /// It's useful when you need to clean up multiple modals at once.
  ///
  /// Parameters:
  /// - `ids`: List of modal IDs to dismiss
  /// - `onDismissed`: Optional callback executed after all modals are dismissed
  ///
  /// Returns a list of IDs that were successfully dismissed.
  ///
  /// Example:
  /// ```dart
  /// final dismissed = await Modal.dismissByIds(['modal1', 'modal2', 'modal3']);
  /// print('Dismissed: $dismissed');
  /// ```
  Future<List<String>> dismissByIds(List<String> ids,
      {VoidCallback? onDismissed}) async {
    if (_showDebugPrints) {
      debugPrint('Modal.dismissByIds: dismissing IDs: $ids');
    }
    final dismissedIds = <String>[];

    for (final id in ids) {
      final wasFound = await dismissById(id);
      if (wasFound) {
        dismissedIds.add(id);
      }
    }

    onDismissed?.call();
    if (_showDebugPrints) {
      debugPrint('Modal.dismissByIds: successfully dismissed: $dismissedIds');
    }
    return dismissedIds;
  }

  /// Dismisses only the dialog by its ID
  ///
  /// Parameters:
  /// - `id`: The ID of the dialog to dismiss (required)
  /// - `onDismissed`: Optional callback executed after the dialog is dismissed
  ///
  /// Example:
  /// ```dart
  /// // Dismiss current dialog (less safe)
  /// Modal.dismissDialog();
  ///
  /// // Dismiss specific dialog by ID (recommended)
  /// Modal.dismissDialog(id: 'settings_dialog');
  /// ```
  static Future<void> dismissDialog(
      {String? id, VoidCallback? onDismissed}) async {
    if (Modal.isDialogActive && !Modal.isDialogDismissing) {
      // CAPTURE the ID of the dialog we intend to dismiss at the START
      final targetDialogId = _dialogController.state?.uniqueId;
      final dialogId = _dialogController.state?.id;
      if (targetDialogId == null) {
        // debugPrint(
        //     'Modal.dismissDialog: WARNING - No dialog ID found, aborting');
        return;
      }

      // If an ID was provided, verify it matches before dismissing
      if (id != null && id != dialogId && id != targetDialogId) {
        // debugPrint(
        //     'Modal.dismissDialog: ID mismatch. Requested=$id, Active=$dialogId. Aborting.');
        return;
      }

      // debugPrint('Modal.dismissDialog: targeting dialog ID=$targetDialogId');
      Modal.isDismissing = true;
      _dialogDismissingNotifier.state = true;

      // Capture the modal type that is being dismissed NOW so we can clear
      // the correct type-specific controller after callbacks run.
      final originallyDismissedType = _activeModalController.state?.modalType;

      // Capture the modal type being dismissed so we clear the correct
      // type-specific controller even if callbacks change the active modal.
      // Note: We intentionally do not capture dismissed type here because
      // bottom sheet cleanup is handled below when we refresh the controller.

      // Reset blur animation state - BUT ONLY if no other blur-enabled modal remains active
      // If a bottom sheet with blur is still showing, we must preserve its blur
      final sheetNeedsBlur = Modal.isSheetActive &&
          (_sheetController.state?.shouldBlurBackground ?? false);
      if (!sheetNeedsBlur) {
        _blurAnimationStateNotifier.state = 0.0;
      }

      // Animate background out (if no other modals need it)
      if (!Modal.isSheetActive) {
        _backgroundAnimationTimer?.cancel();
        const animSteps = 10;
        const totalDuration = 300;
        final stepDuration = Duration(milliseconds: totalDuration ~/ animSteps);
        double startValue = _backgroundLayerAnimationNotifier.state;
        double step = startValue / animSteps;
        int currentStep = 0;

        _backgroundAnimationTimer = Timer.periodic(stepDuration, (timer) {
          currentStep++;
          if (currentStep > animSteps) {
            timer.cancel();
            _backgroundAnimationTimer = null;
            _backgroundLayerAnimationNotifier.state = 0.0;
          } else {
            _backgroundLayerAnimationNotifier.state =
                startValue - (step * currentStep);
          }
        });
      }

      // Animate out
      _dismissModalAnimationController.state = true;

      // Allow animation time, then perform cleanup and run callbacks AFTER
      // the modal is effectively torn down. This avoids race conditions
      // where callbacks show new snackbars and the cleanup later clears them.
      // debugPrint(
      //     'Modal.dismissDialog: start (activeId=${_activeModalController.state?.uniqueId}, dialogId=${_dialogController.state?.uniqueId})');
      await Future.delayed(0.4.sec, () {
        // VALIDATE: Check if the dialog ID still matches what we intended to dismiss
        final currentDialogId = _dialogController.state?.uniqueId;
        if (currentDialogId != null && currentDialogId != targetDialogId) {
          // debugPrint(
          //     'Modal.dismissDialog: WARNING - Dialog ID changed during animation! '
          //     'Target=$targetDialogId, Current=$currentDialogId. Aborting cleanup.');
          Modal.isDismissing = false;
          _dialogDismissingNotifier.state = false;
          return;
        }

        // debugPrint(
        //     'Modal.dismissDialog: animation complete, running cleanup for ID=$targetDialogId');
        // debugPrint(
        //     'Modal.dismissDialog: before cleanup: active=${Modal.controller.state?.modalType} activeId=${Modal.controller.state?.uniqueId} dialogId=${_dialogController.state?.uniqueId} snackbarQueue=${_snackbarQueueNotifier.state.length}');

        // Capture the dialog's onDismissed callback before we refresh the controller
        final dialogOnDismiss = _dialogController.state?.onDismissed;

        _dialogController.refresh();

        // Unregister from modal registry
        final updatedRegistry =
            Map<String, ModalType>.from(_modalRegistry.state);
        updatedRegistry.remove(targetDialogId);
        _modalRegistry.state = updatedRegistry;

        // Run callbacks now that the dialog has been cleaned up
        // debugPrint('Modal.dismissDialog: running callbacks (post-refresh)');
        onDismissed?.call();
        dialogOnDismiss?.call();

        // debugPrint(
        //     'Modal.dismissDialog: after callbacks: active=${Modal.controller.state?.modalType} activeId=${Modal.controller.state?.uniqueId} dialogId=${_dialogController.state?.uniqueId} snackbarQueue=${_snackbarQueueNotifier.state.length}');

        final currentQueue = _snackbarQueueNotifier.state;
        // debugPrint(
        //     'Modal.dismissDialog: snackbar queue has ${currentQueue.keys.length} positions');

        // IMPORTANT: Do NOT clear the snackbar queue when dismissing a dialog.
        // Snackbars are independent modals and should remain visible.
        // Only update the active modal controller to point to a remaining snackbar if any.
        if (currentQueue.isNotEmpty) {
          // debugPrint(
          //     'Modal.dismissDialog: snackbar queue not empty, preserving snackbars');
          // Find the first position with snackbars and make it the active modal
          Alignment? positionWithContent;
          for (final position in currentQueue.keys) {
            if (currentQueue[position]!.isNotEmpty) {
              positionWithContent = position;
              break;
            }
          }
          if (positionWithContent != null) {
            final snackbarToShow = currentQueue[positionWithContent]!.first;
            _snackbarController.state = snackbarToShow;
            Modal.controller.state = snackbarToShow;
            // Ensure the newly activated snackbar is not marked as dismissing
            _setSnackbarDismissing(snackbarToShow.uniqueId, false);
            Modal.dismissModalAnimationController.state = false;
          }
        }

        // Clear type-specific controllers based on what was dismissed
        // IMPORTANT: Only clear active modal controller if NO other modals are active
        if (currentQueue.isEmpty && !Modal.isSheetActive) {
          _snackbarController.refresh();
          _activeModalController.refresh();
        } else if (currentQueue.isEmpty && Modal.isSheetActive) {
          // Bottom sheet is still active - make it the active modal
          _snackbarController.refresh();
          Modal.controller.state = _sheetController.state;
        }
        if (originallyDismissedType == ModalType.dialog) {
          // Dialog was already refreshed above; just clear the dismissing flag
          _dialogDismissingNotifier.state = false;
        }

        // Reset dismiss animation controller if no other modals active
        if (!Modal.isSheetActive && !Modal.isSnackbarActive) {
          _dismissModalAnimationController.state = false;
        }

        // debugPrint('Modal.dismissDialog: finished');
        Modal.isDismissing = false;
        HapticFeedback.lightImpact();
      });
    }
  }

  /// Dismisses only the bottom sheet, preserving snackbars and dialogs
  ///
  /// If an `id` is provided, only dismisses if the active bottom sheet matches that ID.
  /// This provides extra safety to ensure you're dismissing the intended modal.
  ///
  /// Parameters:
  /// - `id`: Optional. If provided, only dismiss if the bottom sheet's ID matches.
  /// - `onDismissed`: Optional callback executed after the bottom sheet is dismissed.
  ///
  /// Example:
  /// ```dart
  /// // Dismiss current bottom sheet (less safe)
  /// Modal.dismissBottomSheet();
  ///
  /// // Dismiss specific bottom sheet by ID (recommended)
  /// Modal.dismissBottomSheet(id: 'settings_sheet');
  /// ```
  static Future<void> dismissBottomSheet(
      {String? id, VoidCallback? onDismissed}) async {
    if (Modal.isSheetActive && !Modal.isSheetDismissing) {
      // CAPTURE the ID of the bottom sheet we intend to dismiss at the START
      final targetSheetId = _sheetController.state?.uniqueId;
      final sheetId = _sheetController.state?.id;
      if (targetSheetId == null) {
        if (_showDebugPrints) {
          debugPrint(
              'Modal.dismissBottomSheet: WARNING - No bottom sheet ID found, aborting');
        }
        return;
      }

      // If an ID was provided, verify it matches before dismissing
      if (id != null && id != sheetId && id != targetSheetId) {
        if (_showDebugPrints) {
          debugPrint(
              'Modal.dismissBottomSheet: ID mismatch. Requested=$id, Active=$sheetId. Aborting.');
        }
        return;
      }

      if (_showDebugPrints) {
        debugPrint(
            'Modal.dismissBottomSheet: targeting sheet ID=$targetSheetId');
      }
      Modal.isDismissing = true;
      _sheetDismissingNotifier.state = true;

      // (intentionally not capturing dismissed type here) bottom sheet cleanup
      // is handled deterministically below when we refresh the controller.

      // Reset blur animation state - BUT ONLY if no other blur-enabled modal remains active
      // If a dialog with blur is still showing, we must preserve its blur
      final dialogNeedsBlur = Modal.isDialogActive &&
          (_dialogController.state?.shouldBlurBackground ?? false);
      if (!dialogNeedsBlur) {
        _blurAnimationStateNotifier.state = 0.0;
      }

      // Animate background out (if no other modals need it)
      if (!Modal.isDialogActive) {
        _backgroundAnimationTimer?.cancel();
        const animSteps = 10;
        const totalDuration = 300;
        final stepDuration = Duration(milliseconds: totalDuration ~/ animSteps);
        double startValue = _backgroundLayerAnimationNotifier.state;
        double step = startValue / animSteps;
        int currentStep = 0;

        _backgroundAnimationTimer = Timer.periodic(stepDuration, (timer) {
          currentStep++;
          if (currentStep > animSteps) {
            timer.cancel();
            _backgroundAnimationTimer = null;
            _backgroundLayerAnimationNotifier.state = 0.0;
          } else {
            _backgroundLayerAnimationNotifier.state =
                startValue - (step * currentStep);
          }
        });
      }

      // Animate out
      _dismissModalAnimationController.state = true;

      await Future.delayed(0.4.sec, () {
        // VALIDATE: Check if the sheet ID still matches what we intended to dismiss
        final currentSheetId = _sheetController.state?.uniqueId;
        if (currentSheetId != null && currentSheetId != targetSheetId) {
          if (_showDebugPrints) {
            debugPrint(
                'Modal.dismissBottomSheet: WARNING - Sheet ID changed during animation! '
                'Target=$targetSheetId, Current=$currentSheetId. Aborting cleanup.');
          }
          Modal.isDismissing = false;
          _sheetDismissingNotifier.state = false;
          return;
        }

        if (_showDebugPrints) {
          debugPrint('Modal.dismissBottomSheet: cleanup for ID=$targetSheetId');
        }
        _resetHeightCallback?.call();
        _modalSheetHeightNotifier.state = 0.0;
        _modalDragOffsetNotifier.state = 0.0;

        // Run callbacks after cleanup
        if (_showDebugPrints) {
          debugPrint('Modal.dismissBottomSheet: running callbacks');
        }
        onDismissed?.call();
        _sheetController.state?.onDismissed?.call();

        final currentQueue = _snackbarQueueNotifier.state;
        if (_showDebugPrints) {
          debugPrint(
              'Modal.dismissBottomSheet: snackbar queue has ${currentQueue.keys.length} positions');
        }

        // IMPORTANT: Do NOT clear the snackbar queue when dismissing a bottom sheet.
        // Snackbars are independent modals and should remain visible.
        // Only update the active modal controller to point to a remaining snackbar if any.
        if (currentQueue.isNotEmpty) {
          if (_showDebugPrints) {
            debugPrint(
                'Modal.dismissBottomSheet: snackbar queue not empty, preserving snackbars');
          }
          // Find the first position with snackbars and make it the active modal
          Alignment? positionWithContent;
          for (final position in currentQueue.keys) {
            if (currentQueue[position]!.isNotEmpty) {
              positionWithContent = position;
              break;
            }
          }
          if (positionWithContent != null) {
            final snackbarToShow = currentQueue[positionWithContent]!.first;
            // Only update if the snackbar content has actually changed
            if (_snackbarController.state?.id != snackbarToShow.id) {
              _snackbarController.state = snackbarToShow;
              Modal.controller.state = snackbarToShow;
            }
            // Ensure the newly activated snackbar is not marked as dismissing
            _setSnackbarDismissing(snackbarToShow.uniqueId, false);
            if (Modal.dismissModalAnimationController.state != false) {
              Modal.dismissModalAnimationController.state = false;
            }
          }
        }

        _sheetController.refresh();

        // Unregister from modal registry only if the ID exists
        if (_modalRegistry.state.containsKey(targetSheetId)) {
          final updatedRegistry =
              Map<String, ModalType>.from(_modalRegistry.state);
          updatedRegistry.remove(targetSheetId);
          _modalRegistry.state = updatedRegistry;
        }

        _sheetDismissingNotifier.state = false;

        // IMPORTANT: Only clear active modal controller if NO other modals are active
        if (currentQueue.isEmpty && !Modal.isDialogActive) {
          _snackbarController.refresh();
          _activeModalController.refresh();
        } else if (currentQueue.isEmpty && Modal.isDialogActive) {
          // Dialog is still active - make it the active modal
          _snackbarController.refresh();
          Modal.controller.state = _dialogController.state;
        }

        // Reset dismiss animation controller if no other modals active
        if (!Modal.isDialogActive && !Modal.isSnackbarActive) {
          if (_dismissModalAnimationController.state != false) {
            _dismissModalAnimationController.state = false;
          }
        }

        Modal.isDismissing = false;
        HapticFeedback.lightImpact();
      });
    }
  }

  /// Dismisses the active side sheet (if any)
  ///
  /// This method handles the complete dismissal lifecycle of a side sheet:
  /// - Animates the side sheet sliding out
  /// - Runs onDismissed callback
  /// - Cleans up internal state
  /// - Preserves other active modals (dialogs, snackbars, bottom sheets)
  ///
  /// If an `id` is provided, dismissal only occurs if the active side sheet
  /// matches that ID.
  ///
  /// Example:
  /// ```dart
  /// // Dismiss any active side sheet
  /// Modal.dismissSideSheet();
  ///
  /// // Dismiss specific side sheet by ID (recommended)
  /// Modal.dismissSideSheet(id: 'menu_sheet');
  /// ```
  static Future<void> dismissSideSheet(
      {String? id, VoidCallback? onDismissed}) async {
    // Side sheets now use the sheet controller
    // Check if the active sheet is actually a side sheet (has sheetPosition left/right)
    if (Modal.isSheetActive && !Modal.isSheetDismissing) {
      final content = _sheetController.state;
      final isSideSheet = content?.sheetPosition == SheetPosition.left ||
          content?.sheetPosition == SheetPosition.right;

      if (!isSideSheet) {
        if (_showDebugPrints) {
          debugPrint(
              'Modal.dismissSideSheet: Active bottom sheet is not a side sheet. Aborting.');
        }
        return;
      }

      // Call the unified dismiss method
      await dismissBottomSheet(id: id, onDismissed: onDismissed);
    } else {
      if (_showDebugPrints) {
        debugPrint(
            'Modal.dismissSideSheet: No side sheet active or already dismissing');
      }
    }
  }

  /// Dismisses the currently active top sheet
  ///
  /// This method dismisses a top sheet (modal that slides in from the top).
  /// Top sheets use the bottom sheet controller internally with SheetPosition.top.
  ///
  /// If an `id` is provided, will only dismiss if the active top sheet
  /// matches that ID.
  ///
  /// Example:
  /// ```dart
  /// // Dismiss any active top sheet
  /// Modal.dismissTopSheet();
  ///
  /// // Dismiss specific top sheet by ID (recommended)
  /// Modal.dismissTopSheet(id: 'notification_sheet');
  /// ```
  static Future<void> dismissTopSheet(
      {String? id, VoidCallback? onDismissed}) async {
    // Top sheets use the sheet controller
    // Check if the active sheet is actually a top sheet (has sheetPosition top)
    if (Modal.isSheetActive && !Modal.isSheetDismissing) {
      final content = _sheetController.state;
      final isTopSheet = content?.sheetPosition == SheetPosition.top;

      if (!isTopSheet) {
        if (_showDebugPrints) {
          debugPrint(
              'Modal.dismissTopSheet: Active bottom sheet is not a top sheet. Aborting.');
        }
        return;
      }

      // Call the unified dismiss method
      await dismissBottomSheet(id: id, onDismissed: onDismissed);
    } else {
      if (_showDebugPrints) {
        debugPrint(
            'Modal.dismissTopSheet: No top sheet active or already dismissing');
      }
    }
  }

  /// Dismisses snackbars at a specific position
  ///
  /// Useful when using staggered or queued snackbar display modes
  /// to clear notifications at a particular screen position.
  ///
  /// Example:
  /// ```dart
  /// Modal.dismissSnackbarAtPosition(Alignment.topCenter);
  /// ```
  static void dismissSnackbarAtPosition(Alignment position) {
    final currentQueueMap = _snackbarQueueNotifier.state;
    if (currentQueueMap.containsKey(position)) {
      // CAPTURE IDs of all snackbars being dismissed at this position
      final dismissedIds =
          currentQueueMap[position]!.map((s) => s.uniqueId).toList();
      if (_showDebugPrints) {
        debugPrint(
            'Modal.dismissSnackbarAtPosition: position=$position, dismissing IDs: $dismissedIds');
      }

      final updatedQueueMap =
          Map<Alignment, List<_ModalContent>>.from(currentQueueMap);
      updatedQueueMap.remove(position);
      _snackbarQueueNotifier.state = updatedQueueMap;

      // Unregister dismissed snackbars from modal registry
      final updatedRegistry = Map<String, ModalType>.from(_modalRegistry.state);
      for (final id in dismissedIds) {
        updatedRegistry.remove(id);
      }
      _modalRegistry.state = updatedRegistry;

      // If this was the only position with snackbars, clear the main modal
      if (updatedQueueMap.isEmpty &&
          Modal.isActive &&
          Modal.controller.state?.modalType == ModalType.snackbar) {
        Modal.controller.refresh();
      }

      if (_showDebugPrints) {
        debugPrint(
            'Modal.dismissSnackbarAtPosition: completed dismissing IDs: $dismissedIds');
      }
    }
  }

  /// Dismisses modals by type
  ///
  /// Allows selective dismissal:
  /// - `ModalType.snackbar`: Dismisses all snackbars
  /// - `ModalType.bottomSheet`: Dismisses current bottom sheet
  /// - `ModalType.dialog`: Dismisses current dialog
  ///
  /// Example:
  /// ```dart
  /// // Dismiss all snackbars
  /// Modal.dismissByType(ModalType.snackbar);
  ///
  /// // Dismiss current dialog
  /// Modal.dismissByType(ModalType.dialog);
  /// ```
  static Future<void> dismissByType(ModalType type) async {
    if (_showDebugPrints) {
      debugPrint('Modal.dismissByType called: $type');
    }
    switch (type) {
      case ModalType.snackbar:
        dismissAllSnackbars();
        break;
      case ModalType.sheet:
        await dismissBottomSheet();
        break;
      case ModalType.dialog:
        await dismissDialog();
        break;
      case ModalType.custom:
        // Custom modals - dismiss by ID if one is active
        if (Modal.isActive && Modal.controller.state?.modalType == type) {
          final customModalId = Modal.controller.state?.uniqueId;
          if (customModalId != null) {
            await dismissById(customModalId);
          }
        }
        break;
    }
  }

  /// Dismisses a specific modal by its ID (PRIMARY DISMISSAL METHOD)
  ///
  /// This is the recommended way to dismiss modals. It searches through all modals
  /// (dialogs, bottom sheets, and queued snackbars) for a matching ID and dismisses
  /// only that specific modal, leaving all other modals untouched.
  ///
  /// The method uses the appropriate type-specific dismissal logic internally,
  /// ensuring proper cleanup and preservation of other active modals.
  ///
  /// Parameters:
  /// - `id`: The ID of the modal to dismiss (as specified in `Modal.show()` or `Modal.showSnackbar()`)
  /// - `onDismissed`: Optional callback executed after the modal is dismissed
  ///
  /// Returns `true` if a modal with the given ID was found and dismissed,
  /// `false` if no modal with that ID was found.
  ///
  /// Example:
  /// ```dart
  /// // Show a bottom sheet with an ID
  /// Modal.show(
  ///   id: 'settings_sheet',
  ///   type: ModalType.bottomSheet,
  ///   child: SettingsSheet(),
  /// );
  ///
  /// // Later, dismiss it by ID
  /// await Modal.dismissById('settings_sheet');
  ///
  /// // Works with snackbars too
  /// Modal.showSnackbar(text: 'Message', id: 'my_snack');
  /// await Modal.dismissById('my_snack');
  /// ```
  static Future<bool> dismissById(String id,
      {VoidCallback? onDismissed}) async {
    if (_showDebugPrints) {
      debugPrint('Modal.dismissById called: id=$id');
    }

    // Check if this ID matches the active dialog
    if (Modal.isDialogActive && _dialogController.state != null) {
      final dialog = _dialogController.state!;
      if (dialog.id == id || dialog.uniqueId == id) {
        if (_showDebugPrints) {
          debugPrint(
              'Modal.dismissById: found dialog with ID=$id. Dismissing...');
        }
        await dismissDialog(onDismissed: onDismissed);
        return true;
      }
    }

    // Check if this ID matches the active sheet
    if (Modal.isSheetActive && _sheetController.state != null) {
      final sheet = _sheetController.state!;
      if (sheet.id == id || sheet.uniqueId == id) {
        if (_showDebugPrints) {
          debugPrint(
              'Modal.dismissById: found bottom sheet with ID=$id. Dismissing...');
        }
        await dismissBottomSheet(onDismissed: onDismissed);
        return true;
      }
    }

    // Check if this ID matches the active side sheet
    if (Modal.isSideSheetActive && _sideSheetController.state != null) {
      final sheet = _sideSheetController.state!;
      if (sheet.id == id || sheet.uniqueId == id) {
        if (_showDebugPrints) {
          debugPrint(
              'Modal.dismissById: found side sheet with ID=$id. Dismissing...');
        }
        await dismissSideSheet(onDismissed: onDismissed);
        return true;
      }
    }

    // Search for and remove from snackbar queue
    final currentQueueMap = _snackbarQueueNotifier.state;
    bool found = false;

    for (final position in currentQueueMap.keys.toList()) {
      if (found) break;

      final queueAtPosition = currentQueueMap[position]!;
      // Search using both id and uniqueId for flexibility
      final matchIndex = queueAtPosition.indexWhere(
        (content) => content.id == id || content.uniqueId == id,
      );

      if (matchIndex >= 0) {
        found = true;
        final snackbar = queueAtPosition[matchIndex];
        if (_showDebugPrints) {
          debugPrint(
              'Modal.dismissById: found snackbar with ID=$id (uniqueId=${snackbar.uniqueId}) at position=$position. Removing...');
        }

        // Check if this is the currently active snackbar
        final isActiveSnackbar =
            _snackbarController.state?.uniqueId == snackbar.uniqueId;

        // If this was the active snackbar, handle transition
        if (isActiveSnackbar) {
          // Try to use the snackbar's internal controller for dismiss animation
          final controller = _getSnackbarController(snackbar.uniqueId);

          if (controller != null && controller.isAttached) {
            // Use imperative dismiss via controller
            if (_showDebugPrints) {
              debugPrint(
                  'Modal.dismissById: Using controller to dismiss snackbar ${snackbar.uniqueId}');
            }

            final completer = Completer<void>();
            controller.playDismissAnimation(
              direction: '',
              onComplete: () {
                // Remove from queue after animation completes
                _removeSnackbarAfterDismiss(
                    position, snackbar.uniqueId, onDismissed);
                if (!completer.isCompleted) {
                  completer.complete();
                }
              },
            );

            // Wait for animation to complete
            await completer.future;
          } else {
            // Fallback: Use the old reactive approach
            if (_showDebugPrints) {
              debugPrint(
                  'Modal.dismissById: Controller not found, using fallback for snackbar ${snackbar.uniqueId}');
            }
            _setSnackbarDismissing(snackbar.uniqueId, true);

            await Future.delayed(0.3.sec, () {
              _removeSnackbarAfterDismiss(
                  position, snackbar.uniqueId, onDismissed);
            });
          }
        } else {
          // Not the active snackbar, remove immediately
          final updatedQueue = List<_ModalContent>.from(queueAtPosition);
          updatedQueue.removeAt(matchIndex);

          final updatedQueueMap =
              Map<Alignment, List<_ModalContent>>.from(currentQueueMap);
          if (updatedQueue.isEmpty) {
            updatedQueueMap.remove(position);
          } else {
            updatedQueueMap[position] = updatedQueue;
          }

          _snackbarQueueNotifier.state = updatedQueueMap;

          // Unregister from modal registry
          final updatedRegistry =
              Map<String, ModalType>.from(_modalRegistry.state);
          updatedRegistry.remove(snackbar.uniqueId);
          _modalRegistry.state = updatedRegistry;

          onDismissed?.call();
          snackbar.onDismissed?.call();
        }

        if (_showDebugPrints) {
          debugPrint('Modal.dismissById: successfully dismissed ID=$id');
        }
        return true;
      }
    }

    if (_showDebugPrints) {
      debugPrint(
          'Modal.dismissById: ID=$id not found in any active modal or snackbar queue');
    }
    return false;
  }

  /// Cleans up resources used by the modal system
  ///
  /// Call this when the modal system is no longer needed,
  /// typically during app shutdown or when the containing
  /// widget is being disposed.
  static void disposeActivator() {
    if (_showDebugPrints) {
      debugPrint("dispose Modal Activator"); // Debug logging
    }

    // Release resources
    _activeModalController.dispose();
    _dialogController.dispose();
    _sheetController.dispose();
    _snackbarController.dispose();

    // No overlay bootstrapper is used in the supported installation strategy.
  }

  //-------------------------------------------------//
}

class _ActivatorWidget extends StatefulWidget {
  /// The main application content to display behind modals
  final Widget child;
  final BorderRadius borderRadius;
  final bool shouldBounce;
  final Color backgroundColor;

  // Constructor for activator widget
  const _ActivatorWidget({
    required this.child,
    required this.borderRadius,
    this.shouldBounce = false,
    this.backgroundColor = Colors.black,
  });

  @override
  State<_ActivatorWidget> createState() => _ActivatorWidgetState();
}

class _ActivatorWidgetState extends State<_ActivatorWidget> {
  GlobalKey bottomSheetContentKey = GlobalKey();

  // Timers for animations
  Timer? _blurStateTimer;
  Timer? _blurAmountTimer;
  Timer? _backgroundTimer;

  @override
  void initState() {
    super.initState();
    // Reset the animation value on initialization
    _backgroundLayerAnimationNotifier.state = 0.0;
  }

  @override
  void dispose() {
    _blurStateTimer?.cancel();
    _blurAmountTimer?.cancel();
    _backgroundTimer?.cancel();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    // Older versions had editor-only hot reload helpers here.
    // This package already supports hot reload via [_hotReloadCounter] and
    // the reactive notifiers used throughout the activator.
    return;
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with Navigator to provide Overlay context for widgets
    // like Slider, TextField, DropdownButton that need overlay ancestors
    // for tooltips, autocomplete suggestions, and dropdown menus.
    // Use HeroControllerScope.none to prevent HeroController sharing
    // conflicts with the parent Navigator (e.g., from MaterialApp).
    return HeroControllerScope.none(
      child: Navigator(
        onDidRemovePage: (_) {},
        pages: [
          MaterialPage(
            child: Material(
              type: MaterialType.canvas,
              color: widget.backgroundColor,
              child: OnBuilder(
                listenToMany: [
                  Modal.controller,
                  Modal.dismissModalAnimationController,
                ],
                sideEffects: SideEffects(
                  initState: () {
                    // Just in case a modal is active (very unlikely), ensure controllers are reset.
                    Modal.dismissAll();
                  },
                  onSetState: (rebuilder) async {
                    if (Modal.isActive && mounted) {
                      // Guard: Don't animate in if we are currently dismissing.
                      if (Modal.isDismissing) return;

                      final currentModalType =
                          Modal.controller.state?.modalType;
                      final bool shouldPreserveExistingBlur;

                      if (currentModalType == ModalType.snackbar) {
                        // Snackbars never change background/blur - they're overlays.
                        shouldPreserveExistingBlur =
                            Modal.isDialogActive || Modal.isSheetActive;
                      } else {
                        // For other modal types, preserve if background animation already running.
                        shouldPreserveExistingBlur =
                            _backgroundLayerAnimationNotifier.state > 0;
                      }

                      if (!shouldPreserveExistingBlur) {
                        final shouldBlur =
                            Modal.controller.state?.shouldBlurBackground ??
                                false;
                        final targetBlurState = shouldBlur ? 1.0 : 0.0;
                        if (targetBlurState !=
                            _blurAnimationStateNotifier.state) {
                          _blurStateTimer?.cancel();
                          const int animSteps = 10;
                          const int totalDurationMs = 300;
                          final stepDuration = Duration(
                              milliseconds: totalDurationMs ~/ animSteps);

                          final double startValue =
                              _blurAnimationStateNotifier.state;
                          final double step =
                              (targetBlurState - startValue) / animSteps;
                          int currentStep = 0;

                          _blurStateTimer =
                              Timer.periodic(stepDuration, (timer) {
                            currentStep++;
                            if (currentStep > animSteps) {
                              timer.cancel();
                              _blurStateTimer = null;
                              if (mounted) {
                                _blurAnimationStateNotifier.state =
                                    targetBlurState;
                              }
                              return;
                            }
                            if (mounted) {
                              _blurAnimationStateNotifier.state =
                                  startValue + (step * currentStep);
                            } else {
                              timer.cancel();
                            }
                          });
                        }
                      }

                      if (!shouldPreserveExistingBlur) {
                        final newBlurAmount =
                            Modal.controller.state?.blurAmount ?? 3.0;
                        if (newBlurAmount != _blurAmountNotifier.state) {
                          _blurAmountTimer?.cancel();
                          const int animSteps = 10;
                          const int totalDurationMs = 300;
                          final stepDuration = Duration(
                              milliseconds: totalDurationMs ~/ animSteps);

                          final double startValue = _blurAmountNotifier.state;
                          final double step =
                              (newBlurAmount - startValue) / animSteps;
                          int currentStep = 0;

                          _blurAmountTimer =
                              Timer.periodic(stepDuration, (timer) {
                            currentStep++;
                            if (currentStep > animSteps) {
                              timer.cancel();
                              _blurAmountTimer = null;
                              if (mounted) {
                                _blurAmountNotifier.state = newBlurAmount;
                              }
                              return;
                            }
                            if (mounted) {
                              _blurAmountNotifier.state =
                                  startValue + (step * currentStep);
                            } else {
                              timer.cancel();
                            }
                          });
                        }
                      }

                      if (!shouldPreserveExistingBlur &&
                          currentModalType == ModalType.sheet) {
                        final currentContent = Modal.controller.state;
                        final newSize =
                            (currentContent?.modalType == ModalType.sheet)
                                ? currentContent?.size
                                : null;
                        if (newSize != null &&
                            _modalSheetHeightNotifier.state != newSize) {
                          _heightAnimationTriggerNotifier.state++;
                          _modalSheetHeightNotifier.state = newSize;
                        }
                      }

                      if (!shouldPreserveExistingBlur) {
                        _backgroundTimer?.cancel();
                        const int animSteps = 10;
                        const int totalDurationMs = 300;
                        final stepDuration = Duration(
                            milliseconds: totalDurationMs ~/ animSteps);

                        final double startValue =
                            _backgroundLayerAnimationNotifier.state;
                        const double endValue = 1.0;
                        final double step = (endValue - startValue) / animSteps;
                        int currentStep = 0;

                        _backgroundTimer =
                            Timer.periodic(stepDuration, (timer) {
                          currentStep++;
                          if (currentStep > animSteps) {
                            timer.cancel();
                            _backgroundTimer = null;
                            if (mounted) {
                              _backgroundLayerAnimationNotifier.state =
                                  endValue;
                            }
                            return;
                          }
                          if (mounted) {
                            _backgroundLayerAnimationNotifier.state =
                                startValue + (step * currentStep);
                          } else {
                            timer.cancel();
                          }
                        });
                      }
                    }
                  },
                ),
                builder: () {
                  final Widget backgroundLayer = OnBuilder(
                    listenToMany: [
                      _backgroundLayerAnimationNotifier,
                      _sheetController,
                    ],
                    builder: () {
                      final animValue = _backgroundLayerAnimationNotifier.state;

                      final sheetPos = _sheetController.state?.sheetPosition;

                      final double verticalOffset;
                      if (Modal.isSheetActive) {
                        verticalOffset = animValue * -8.5;
                      } else if (Modal.isTopSheetActive) {
                        verticalOffset = animValue * 8.5;
                      } else {
                        verticalOffset = 0.0;
                      }

                      final double leftPosition;
                      final double rightPosition;
                      if (Modal.isSideSheetActive && sheetPos != null) {
                        if (sheetPos == SheetPosition.right) {
                          leftPosition = 0.0;
                          rightPosition = animValue * 8.5;
                        } else {
                          leftPosition = animValue * 8.5;
                          rightPosition = 0.0;
                        }
                      } else {
                        leftPosition = 0.0;
                        rightPosition = 0.0;
                      }

                      final scaleValue = (Modal.isSheetActive ||
                              Modal.isSideSheetActive ||
                              Modal.isTopSheetActive)
                          ? 1 - (animValue * 0.02)
                          : 1.0;

                      return Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(
                            Modal.isSideSheetActive
                                ? (sheetPos == SheetPosition.right
                                    ? -leftPosition
                                    : rightPosition)
                                : 0.0,
                            verticalOffset,
                          ),
                          child: Transform.scale(
                            scale: scaleValue,
                            alignment: Modal.isSheetActive
                                ? Alignment.bottomCenter
                                : (Modal.isTopSheetActive
                                    ? Alignment.topCenter
                                    : (sheetPos == SheetPosition.right
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft)),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                borderRadius: Modal.isSheetActive
                                    ? widget.borderRadius
                                    : BorderRadius.zero,
                              ),
                              child: OnBuilder(
                                listenToMany: [
                                  _blurAnimationStateNotifier,
                                  _blurAmountNotifier,
                                  _activeModalController,
                                  _dialogController,
                                  _sheetController,
                                  _snackbarController,
                                ],
                                builder: () {
                                  // Calculate blur directly from notifiers
                                  final blurAmount = _blurAnimationStateNotifier
                                          .state *
                                      _backgroundLayerAnimationNotifier.state *
                                      _blurAmountNotifier.state;

                                  // Animate borderRadius using the background animation value
                                  // When sheet is active: lerp from zero to target radius
                                  // When sheet is inactive: lerp from target radius to zero
                                  final animValue =
                                      _backgroundLayerAnimationNotifier.state;
                                  final borderRadius = Modal.isSheetActive
                                      ? BorderRadius.lerp(
                                          BorderRadius.zero,
                                          widget.borderRadius,
                                          animValue,
                                        )!
                                      : BorderRadius.zero;

                                  //Define the tap handler for the barrier
                                  void onBarrierTap() {
                                    if (Modal.isDismissing) {
                                      if (_showDebugPrints) {
                                        debugPrint(
                                            'SBounceable.onTap ignored: Modal.isDismissing is true');
                                      }
                                      return;
                                    }
                                    if (Modal.isDialogActive &&
                                        (_dialogController
                                                .state?.isDismissable ??
                                            true)) {
                                      Modal.dismissDialog();
                                    } else if (Modal.isSheetActive &&
                                        (_sheetController
                                                .state?.isDismissable ??
                                            true)) {
                                      Modal.dismissBottomSheet();
                                    } else if (Modal.isSideSheetActive &&
                                        (_sideSheetController
                                                .state?.isDismissable ??
                                            true)) {
                                      Modal.dismissSideSheet();
                                    }
                                  }

                                  // Determine the effective barrier color based on active modal type
                                  final Color effectiveBarrierColor;
                                  if (Modal.isSheetActive) {
                                    effectiveBarrierColor =
                                        _sheetController.state?.barrierColor ??
                                            Colors.transparent;
                                  } else if (Modal.isSideSheetActive) {
                                    effectiveBarrierColor = _sideSheetController
                                            .state?.barrierColor ??
                                        Colors.transparent;
                                  } else if (Modal.isDialogActive) {
                                    effectiveBarrierColor =
                                        _dialogController.state?.barrierColor ??
                                            Colors.transparent;
                                  } else {
                                    effectiveBarrierColor =
                                        Modal.controller.state?.barrierColor ??
                                            Colors.transparent;
                                  }

                                  // The background layer with blur and tap handling
                                  return ImageFiltered(
                                    imageFilter: ImageFilter.blur(
                                      sigmaX: blurAmount,
                                      sigmaY: blurAmount,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: borderRadius,
                                      child: SInkButton(
                                        scaleFactor: (widget.shouldBounce &&
                                                (Modal.isSheetActive ||
                                                    Modal.isDialogActive))
                                            ? 0.985
                                            : 1,
                                        color:
                                            effectiveBarrierColor.darken(0.2),
                                        onTap: (pos) => onBarrierTap(),
                                        onLongPressEnd: (details) =>
                                            onBarrierTap(),
                                        child: SizedBox.expand(
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: RepaintBoundary(
                                                  child: AbsorbPointer(
                                                    absorbing:
                                                        _shouldBlockBackgroundInteraction(),
                                                    child: widget.child,
                                                  ),
                                                ),
                                              ),
                                              if (Modal.isActive)
                                                Positioned.fill(
                                                  child: IgnorePointer(
                                                    child: AnimatedContainer(
                                                      duration: const Duration(
                                                          milliseconds: 50),
                                                      curve: Curves.easeInOut,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            effectiveBarrierColor
                                                                .withValues(
                                                          alpha: _backgroundLayerAnimationNotifier
                                                                  .state *
                                                              effectiveBarrierColor
                                                                  .a,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );

                  final Widget modalLayer = OnBuilder(
                    listenToMany: [
                      _modalDragOffsetNotifier,
                      _dialogController,
                      _sheetController,
                      _dialogDismissingNotifier,
                      _sheetDismissingNotifier,
                      _hotReloadCounter,
                    ],
                    builder: () {
                      // ignore: unused_local_variable
                      final hotReloadValue = _hotReloadCounter.state;

                      final modals = <Widget>[];

                      if (Modal.isSheetActive) {
                        final content = _sheetController.state!;
                        final position =
                            content.sheetPosition ?? SheetPosition.bottom;
                        final isVertical = position == SheetPosition.bottom ||
                            position == SheetPosition.top;
                        final isHorizontal = position == SheetPosition.left ||
                            position == SheetPosition.right;

                        modals.add(
                          _Sheet(
                            key: ValueKey('sheet_${content.uniqueId}'),
                            sheetId: content.uniqueId,
                            height: isVertical ? content.size : null,
                            expandedHeight: (content.isExpandable && isVertical)
                                ? content.expandedPercentageSize
                                : null,
                            width: isHorizontal ? content.size : null,
                            expandedWidth:
                                (content.isExpandable && isHorizontal)
                                    ? content.expandedPercentageSize
                                    : null,
                            isDismissing: Modal.isSheetDismissing,
                            isExpandable: content.isExpandable,
                            contentPaddingByDragHandle:
                                content.contentPaddingByDragHandle,
                            backgroundColor: content.backgroundColor,
                            position: position,
                            child: content.buildContent(),
                          ),
                        );
                      }

                      if (Modal.isDialogActive) {
                        final content = _dialogController.state!;
                        modals.add(
                          DialogModal(
                            key: ValueKey('dialog_${content.uniqueId}'),
                            dialogId: content.uniqueId,
                            position: content.modalPosition,
                            isDismissing: Modal.isDialogDismissing,
                            isDraggable: content.isDraggable,
                            offset: content.offset,
                            child: content.buildContent(),
                          ),
                        );
                      }

                      if (modals.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Stack(children: modals);
                    },
                  );

                  final Widget snackbarLayer = OnBuilder(
                    listenToMany: [
                      _snackbarController,
                      _snackbarQueueNotifier,
                      _snackbarDismissingNotifier,
                      _snackbarDismissingIdsNotifier,
                      _staggeredExpandedNotifier,
                      _hotReloadCounter,
                    ],
                    builder: () {
                      // ignore: unused_local_variable
                      final hotReloadValue = _hotReloadCounter.state;

                      if (!Modal.isSnackbarActive) {
                        return const SizedBox.shrink();
                      }
                      // Render snackbars from all positions in the queue map
                      final queueMap = Modal.snackbarQueue.state;
                      final snackbars = <Widget>[];
                      final expandedSnackbars = <Widget>[];

                      // Iterate through each position's queue
                      for (final entry in queueMap.entries) {
                        final position = entry.key;
                        final queue = entry.value;

                        if (queue.isEmpty) continue;

                        // Get the display mode from the first snackbar in queue
                        // (all snackbars in a position should use the same mode)
                        final displayMode = queue.first.snackbarDisplayMode;

                        switch (displayMode) {
                          case SnackbarDisplayMode.queued:
                            // QUEUED: Only show the first snackbar, others wait in queue
                            final snackbarContent = queue.first;
                            final snackbarKey =
                                "snackbar_${position.x}_${position.y}_${snackbarContent.uniqueId}";

                            snackbars.add(
                              SnackbarModal(
                                key: ValueKey(snackbarKey),
                                snackbarId: snackbarContent.uniqueId,
                                position: snackbarContent.modalPosition,
                                // Use per-snackbar dismissing state instead of global flag
                                isDismissing: _isSnackbarDismissing(
                                    snackbarContent.uniqueId),
                                isSwipeable: snackbarContent.isSwipeable,
                                autoDismissDuration:
                                    snackbarContent.autoDismissDuration,
                                offset: snackbarContent.offset,
                                barrierColor: snackbarContent.barrierColor,
                                onSwipeDismiss: (direction) {
                                  final isImmediate =
                                      direction == 'dismiss_immediate';
                                  Modal._removeSnackbarFromQueue(
                                      position, isImmediate);
                                },
                                stackIndex: 0,
                                maxStacked: 1,
                                width: snackbarContent.snackbarWidth != null
                                    ? (snackbarContent.snackbarWidth! > 1.0
                                        ? snackbarContent.snackbarWidth!
                                        : MediaQuery.of(context).size.width *
                                            snackbarContent.snackbarWidth!)
                                    : null,
                                child: snackbarContent.buildContent(),
                              ),
                            );
                            break;

                          case SnackbarDisplayMode.notificationBubble:
                            // NOTIFICATION BUBBLE: Show first snackbar with a count badge
                            // Can expand to show all snackbars like staggered mode
                            final isExpanded =
                                _staggeredExpandedNotifier.state == position;
                            final isFromTop = position == Alignment.topCenter ||
                                position == Alignment.topLeft ||
                                position == Alignment.topRight;

                            // Use AnimatedSwitcher for smooth transitions (same as staggered)
                            final expandedView = Positioned.fill(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin:
                                            Offset(0, isFromTop ? -0.1 : 0.1),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      )),
                                      child: child,
                                    ),
                                  );
                                },
                                child: isExpanded
                                    ? _buildExpandedStaggeredView(
                                        key: const ValueKey('expanded'),
                                        context: context,
                                        queue: queue,
                                        position: position,
                                        isFromTop: isFromTop,
                                      )
                                    : _buildCollapsedNotificationBubbleView(
                                        // Use unique key per snackbar for AnimatedSwitcher to animate transitions
                                        key: ValueKey(
                                            'notification_bubble_${queue.last.uniqueId}'),
                                        context: context,
                                        queue: queue,
                                        position: position,
                                      ),
                              ),
                            );

                            // CRITICAL: When expanded, add to expandedSnackbars (will be rendered first/bottom)
                            // When collapsed, add to normal snackbars list
                            if (isExpanded) {
                              expandedSnackbars.add(expandedView);
                            } else {
                              snackbars.add(expandedView);
                            }
                            break;

                          case SnackbarDisplayMode.staggered:
                            // STAGGERED: Display snackbars stacked or expanded based on state
                            final isExpanded =
                                _staggeredExpandedNotifier.state == position;
                            final maxStacked = queue.first.maxStackedSnackbars;
                            final isFromTop = position == Alignment.topCenter ||
                                position == Alignment.topLeft ||
                                position == Alignment.topRight;

                            // Use AnimatedSwitcher for smooth transitions
                            // Wrap in Positioned.fill to get bounded constraints from parent Stack
                            // (AnimatedSwitcher's transitions wrap children)
                            final staggeredView = Positioned.fill(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin:
                                            Offset(0, isFromTop ? -0.1 : 0.1),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      )),
                                      child: child,
                                    ),
                                  );
                                },
                                child: isExpanded
                                    ? _buildExpandedStaggeredView(
                                        key: const ValueKey('expanded'),
                                        context: context,
                                        queue: queue,
                                        position: position,
                                        isFromTop: isFromTop,
                                      )
                                    : _buildCollapsedStaggeredView(
                                        key: const ValueKey('collapsed'),
                                        context: context,
                                        queue: queue,
                                        position: position,
                                        isFromTop: isFromTop,
                                        maxStacked: maxStacked,
                                      ),
                              ),
                            );

                            // CRITICAL: When expanded, add to expandedSnackbars (will be rendered first/bottom)
                            // When collapsed, add to normal snackbars list
                            if (isExpanded) {
                              expandedSnackbars.add(staggeredView);
                            } else {
                              snackbars.add(staggeredView);
                            }
                            break;

                          case SnackbarDisplayMode.replace:
                            // REPLACE: Show only the single snackbar (queue should have 1 item)
                            if (queue.isNotEmpty) {
                              final snackbarContent = queue.last;
                              final snackbarKey =
                                  "snackbar_${position.x}_${position.y}_${snackbarContent.uniqueId}";

                              snackbars.add(
                                SnackbarModal(
                                  key: ValueKey(snackbarKey),
                                  snackbarId: snackbarContent.uniqueId,
                                  position: snackbarContent.modalPosition,
                                  isDismissing: Modal.isSnackbarDismissing,
                                  isSwipeable: snackbarContent.isSwipeable,
                                  autoDismissDuration:
                                      snackbarContent.autoDismissDuration,
                                  offset: snackbarContent.offset,
                                  barrierColor: snackbarContent.barrierColor,
                                  onSwipeDismiss: (direction) {
                                    final isImmediate =
                                        direction == 'dismiss_immediate';
                                    Modal._removeSnackbarFromQueue(
                                        position, isImmediate);
                                  },
                                  stackIndex: 0,
                                  maxStacked: 1,
                                  width: snackbarContent.snackbarWidth != null
                                      ? (snackbarContent.snackbarWidth! > 1.0
                                          ? snackbarContent.snackbarWidth!
                                          : MediaQuery.of(context).size.width *
                                              snackbarContent.snackbarWidth!)
                                      : null,
                                  child: snackbarContent.buildContent(),
                                ),
                              );
                            }
                            break;
                        }
                      }

                      // If no snackbars in queue, return empty
                      if (snackbars.isEmpty && expandedSnackbars.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      // CRITICAL: Render collapsed snackbars FIRST (bottom layer), then expanded ones (top layer)
                      // In Flutter Stack, later children render on top. So we put collapsed first, expanded last.
                      // This ensures _buildExpandedStaggeredView always appears ABOVE other snackbars as the top layer.
                      // When a group is collapsed, it returns to its natural position in the snackbars list.
                      return Stack(
                        children: [...snackbars, ...expandedSnackbars],
                      );
                    },
                  );

                  final mediaQuerySize = MediaQuery.maybeOf(context)?.size;
                  final viewportHeight = mediaQuerySize?.height ?? 0.0;
                  final viewportWidth = mediaQuerySize?.width ?? 0.0;

                  return SizedBox(
                    height: viewportHeight > 0 ? viewportHeight : null,
                    width: viewportWidth > 0 ? viewportWidth : null,
                    child: Stack(
                      children: [
                        backgroundLayer,
                        modalLayer,
                        snackbarLayer,
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper to build the expanded staggered view (scrollable list of all snackbars)
Widget _buildExpandedStaggeredView({
  required Key key,
  required BuildContext context,
  required List<_ModalContent> queue,
  required Alignment position,
  required bool isFromTop,
}) {
  // Create a unique group ID for this expanded view
  final tapRegionGroupId =
      'expanded_snackbar_group_${position.x}_${position.y}';

  return Stack(
    key: key,
    alignment: Alignment.center,
    children: [
      // Background Layer - dismisses on tap
      Material(
        color: Colors.transparent,
        child: InkWell(
          splashFactory: InkRipple.splashFactory,
          highlightColor: Colors.white.withValues(alpha: 0.05),
          splashColor: Colors.white.withValues(alpha: 0.7),
          onTap: () {
            _staggeredExpandedNotifier.state = null;
          },
          child: Container(
            color: Modal.snackStaggeredViewDismissBarrierColor,
          ),
        ),
      ),

      // the expanded view - use LayoutBuilder for safe constraints
      LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight * 0.6;

          return Padding(
            padding: EdgeInsets.only(
              top: isFromTop ? 24.0 : 0,
              bottom: !isFromTop ? 24.0 : 0,
              left: 16.0,
              right: 16.0,
            ),
            child: TapRegion(
              groupId: tapRegionGroupId,
              behavior: HitTestBehavior.deferToChild,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  splashFactory: InkRipple.splashFactory,
                  highlightColor: Colors.white.withValues(alpha: 0.05),
                  splashColor: Colors.white.withValues(alpha: 0.1),
                  onTap: () {
                    _staggeredExpandedNotifier.state = null;
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: maxHeight,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Collapse button (icon only) - consumes tap to prevent dismissal
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 8.0, right: 8.0),
                            child: Material(
                              color: Colors.grey.shade600,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                splashFactory: InkRipple.splashFactory,
                                highlightColor:
                                    Colors.white.withValues(alpha: 0.1),
                                splashColor:
                                    Colors.white.withValues(alpha: 0.2),
                                onTap: () {
                                  _staggeredExpandedNotifier.state = null;
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Icon(
                                    Icons.unfold_less,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Scrollable list of snackbars - oldest at top, newest at bottom
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: false,
                              physics: const AlwaysScrollableScrollPhysics(),
                              reverse: false,
                              itemCount: queue.length,
                              itemBuilder: (context, index) {
                                final snackbarContent = queue[index];
                                final snackbarKey =
                                    "snackbar_expanded_${position.x}_${position.y}_${snackbarContent.uniqueId}";

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      // Consume tap to prevent dismissal, call snackbar's onTap if exists
                                      snackbarContent.onTap?.call();
                                    },
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        minHeight: 0,
                                        minWidth: double.infinity,
                                      ),
                                      child: Dismissible(
                                        key: ValueKey(snackbarKey),
                                        direction: DismissDirection.horizontal,
                                        onDismissed: (_) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            Modal._removeSnackbarByIdFromQueue(
                                              snackbarContent.uniqueId,
                                              position,
                                            );
                                            final remainingQueue = Modal
                                                .snackbarQueue.state[position];
                                            if (remainingQueue == null ||
                                                remainingQueue.length <= 1) {
                                              _staggeredExpandedNotifier.state =
                                                  null;
                                            }
                                          });
                                        },
                                        background: Container(
                                          alignment: Alignment.centerLeft,
                                          padding:
                                              const EdgeInsets.only(left: 20.0),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                        secondaryBackground: Container(
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.only(
                                              right: 20.0),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                        child: RepaintBoundary(
                                          child: snackbarContent.buildContent(),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ],
  );
}

/// Helper to build the collapsed staggered view (stacked snackbars with expand button)
Widget _buildCollapsedStaggeredView({
  required Key key,
  required BuildContext context,
  required List<_ModalContent> queue,
  required Alignment position,
  required bool isFromTop,
  required int maxStacked,
}) {
  final startIndex = (queue.length - maxStacked).clamp(0, queue.length);

  // Build a Stack with the staggered snackbars
  // We render them back-to-front (oldest first, newest/front last)
  // so the front snackbar is on top in the Stack
  final staggeredSnackbars = <Widget>[];

  for (int i = startIndex; i < queue.length; i++) {
    final snackbarContent = queue[i];
    final snackbarKey =
        "snackbar_${position.x}_${position.y}_${snackbarContent.uniqueId}";

    // Calculate stack index relative to visible snackbars only
    // The newest (last in queue) has index 0 (front)
    final stackIndex = queue.length - 1 - i;
    final isFrontSnackbar = stackIndex == 0;

    staggeredSnackbars.add(
      SnackbarModal(
        key: ValueKey(snackbarKey),
        snackbarId: snackbarContent.uniqueId,
        position: snackbarContent.modalPosition,
        // Use per-snackbar dismissing state instead of global flag
        isDismissing: _isSnackbarDismissing(snackbarContent.uniqueId),
        isSwipeable: isFrontSnackbar ? snackbarContent.isSwipeable : false,
        autoDismissDuration: snackbarContent.autoDismissDuration,
        offset: snackbarContent.offset,
        barrierColor: snackbarContent.barrierColor,
        onSwipeDismiss: (direction) {
          final isImmediate = direction == 'dismiss_immediate';
          Modal._removeSnackbarFromQueue(position, isImmediate);
        },
        stackIndex: stackIndex,
        maxStacked: snackbarContent.maxStackedSnackbars,
        width: snackbarContent.snackbarWidth != null
            ? (snackbarContent.snackbarWidth! > 1.0
                ? snackbarContent.snackbarWidth!
                : MediaQuery.of(context).size.width *
                    snackbarContent.snackbarWidth!)
            : null,
        onTap: snackbarContent.onTap,
        child: snackbarContent.buildContent(),
      ),
    );
  }

  // Add expand button if there are multiple snackbars
  // Use AnimatedPositioned to smoothly transition when snackbar width changes
  if (queue.length > 1) {
    // Get the width of the last snackbar (the one currently in view/front)
    final snackbarContent = queue.last;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate actual snackbar width
    final actualSnackbarWidth = snackbarContent.snackbarWidth != null
        ? (snackbarContent.snackbarWidth! > 1.0
            ? snackbarContent.snackbarWidth!
            : screenWidth * snackbarContent.snackbarWidth!)
        : null;

    // Default snackbar width (matches SnackbarModal default)
    final defaultSnackbarWidth = screenWidth - 32.0;
    final effectiveSnackbarWidth = actualSnackbarWidth ?? defaultSnackbarWidth;

    // Calculate the horizontal offset from screen edge to snackbar edge
    // This accounts for centering and padding
    final snackbarHorizontalPadding =
        (screenWidth - effectiveSnackbarWidth) / 2;

    // Get the snackbar's offset if provided (for custom positioning)
    final snackbarOffset = snackbarContent.offset;

    // Determine position based on alignment or absolute offset
    // When offset is provided, it overrides alignment-based positioning
    double? top;
    double? bottom;
    double? left;
    double? right;

    if (snackbarOffset != null) {
      // Absolute positioning based on offset (from top-left corner)
      // When offset is used, snackbar has EdgeInsets.zero (no padding)
      // So snackbar content starts at offset.dx, offset.dy
      // Button is 4px from snackbar left edge and 18px from top
      top = snackbarOffset.dy + 18.0;
      left = snackbarOffset.dx + 4.0;
    } else {
      // Alignment-based positioning (original logic)
      if (position == Alignment.topLeft) {
        top = 18.0;
        // Left-aligned snackbars are at screen edge (16px margin), button 4px from snackbar left edge
        left = 16.0 + 4.0;
      } else if (position == Alignment.topCenter) {
        top = 18.0;
        // Center-aligned snackbars: snackbar has 16px margin on each side, button 4px from snackbar left edge
        left = snackbarHorizontalPadding + 16.0 + 4.0;
      } else if (position == Alignment.topRight) {
        top = 18.0;
        // Right-aligned snackbars are at screen edge (16px margin), button 4px from snackbar right edge
        right = 16.0 + 4.0;
      } else if (position == Alignment.bottomLeft) {
        bottom = 70.0;
        // Left-aligned snackbars are at screen edge (16px margin), button 4px from snackbar left edge
        left = 16.0 + 4.0;
      } else if (position == Alignment.bottomCenter) {
        bottom = 70.0;
        // Center-aligned snackbars: snackbar has 16px margin on each side, button 4px from snackbar left edge
        left = snackbarHorizontalPadding + 16.0 + 4.0;
      } else if (position == Alignment.bottomRight) {
        bottom = 70.0;
        // Right-aligned snackbars are at screen edge (16px margin), button 4px from snackbar right edge
        right = 16.0 + 4.0;
      } else {
        // Default fallback
        top = 32.0;
        right = snackbarHorizontalPadding + 24.0;
      }
    }

    staggeredSnackbars.add(
      AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: IgnorePointer(
          ignoring: false,
          child: Material(
            color: Colors.grey.shade600,
            borderRadius: BorderRadius.circular(8),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                // Expand only this group's position
                _staggeredExpandedNotifier.state = position;
              },
              child: const Padding(
                padding: EdgeInsets.all(5.0),
                child: Icon(
                  Icons.unfold_more,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  return Stack(
    key: key,
    children: staggeredSnackbars,
  );
}

/// Helper to build the collapsed notification bubble view (single snackbar with count badge)
Widget _buildCollapsedNotificationBubbleView({
  required Key key,
  required BuildContext context,
  required List<_ModalContent> queue,
  required Alignment position,
}) {
  // Always show the LAST (newest/front) snackbar - same as staggered view
  final snackbarContent = queue.last;
  final queueCount = queue.length;

  // Calculate snackbar positioning for the badge
  final screenWidth = MediaQuery.of(context).size.width;

  // Calculate actual snackbar width
  final actualSnackbarWidth = snackbarContent.snackbarWidth != null
      ? (snackbarContent.snackbarWidth! > 1.0
          ? snackbarContent.snackbarWidth!
          : screenWidth * snackbarContent.snackbarWidth!)
      : null;

  // Default snackbar width (matches SnackbarModal default)
  final defaultSnackbarWidth = screenWidth - 32.0;
  final effectiveSnackbarWidth = actualSnackbarWidth ?? defaultSnackbarWidth;

  // Calculate the horizontal offset from screen edge to snackbar edge
  final snackbarHorizontalPadding = (screenWidth - effectiveSnackbarWidth) / 2;

  // Get the snackbar's offset if provided (for custom positioning)
  final snackbarOffset = snackbarContent.offset;

  // Determine badge position based on alignment or absolute offset
  // When offset is provided, it overrides alignment-based positioning
  // and incorporates custom offset if provided
  double? badgeTop;
  double? badgeBottom;
  double? badgeLeft;
  double? badgeRight;

  if (snackbarOffset != null) {
    // Absolute positioning based on offset (from top-left corner)
    // When offset is used, snackbar has EdgeInsets.zero (no padding)
    // So snackbar content starts at offset.dx, offset.dy
    // Badge is 4px from snackbar left edge and 18px from top
    badgeTop = snackbarOffset.dy + 18.0;
    badgeLeft = snackbarOffset.dx + 4.0;
  } else {
    // Alignment-based positioning (original logic)
    if (position == Alignment.topLeft) {
      badgeTop = 18.0;
      // Left-aligned snackbars are at screen edge (16px margin), badge 4px from snackbar left edge
      badgeLeft = 16.0 + 4.0;
    } else if (position == Alignment.topCenter) {
      badgeTop = 18.0;
      // Center-aligned snackbars: snackbar has 16px margin on each side, badge 4px from snackbar left edge
      badgeLeft = snackbarHorizontalPadding + 16.0 + 4.0;
    } else if (position == Alignment.topRight) {
      badgeTop = 18.0;
      // Right-aligned snackbars are at screen edge (16px margin), badge 4px from snackbar right edge
      badgeRight = 16.0 + 4.0;
    } else if (position == Alignment.bottomLeft) {
      badgeBottom = 70.0;
      // Left-aligned snackbars are at screen edge (16px margin), badge 4px from snackbar left edge
      badgeLeft = 16.0 + 4.0;
    } else if (position == Alignment.bottomCenter) {
      badgeBottom = 70.0;
      // Center-aligned snackbars: snackbar has 16px margin on each side, badge 4px from snackbar left edge
      badgeLeft = snackbarHorizontalPadding + 16.0 + 4.0;
    } else if (position == Alignment.bottomRight) {
      badgeBottom = 70.0;
      // Right-aligned snackbars are at screen edge (16px margin), badge 4px from snackbar right edge
      badgeRight = 16.0 + 4.0;
    } else {
      // Default fallback
      badgeTop = 18.0;
      badgeRight = snackbarHorizontalPadding + 4.0;
    }
  }

  // Wrap in a Stack like the staggered view for consistent animation behavior
  return Stack(
    key: key,
    children: [
      SnackbarModal(
        key: ValueKey(
            "snackbar_bubble_${position.x}_${position.y}_${snackbarContent.uniqueId}"),
        snackbarId: snackbarContent.uniqueId,
        position: snackbarContent.modalPosition,
        // Use per-snackbar dismissing state instead of global flag
        isDismissing: _isSnackbarDismissing(snackbarContent.uniqueId),
        isSwipeable: snackbarContent.isSwipeable,
        autoDismissDuration: snackbarContent.autoDismissDuration,
        offset: snackbarContent.offset,
        onSwipeDismiss: (direction) {
          final isImmediate = direction == 'dismiss_immediate';
          Modal._removeSnackbarFromQueue(position, isImmediate);
        },
        stackIndex: 0,
        maxStacked: 1,
        width: snackbarContent.snackbarWidth != null
            ? (snackbarContent.snackbarWidth! > 1.0
                ? snackbarContent.snackbarWidth!
                : MediaQuery.of(context).size.width *
                    snackbarContent.snackbarWidth!)
            : null,
        child: snackbarContent.buildContent(),
      ),
      // Badge showing count - positioned at top-right corner of snackbar with AnimatedPositioned
      if (queueCount > 1)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: badgeTop,
          bottom: badgeBottom,
          left: badgeLeft,
          right: badgeRight,
          child: GestureDetector(
            onTap: () {
              _staggeredExpandedNotifier.state = position;
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '$queueCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
