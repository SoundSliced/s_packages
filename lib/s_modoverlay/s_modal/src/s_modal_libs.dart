import 'dart:math';
import 'dart:ui';

// Add the ui prefix for lerpDouble clarification if not already done in imports
import 'dart:ui' as ui;

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:s_packages/s_packages.dart';

part 's_modal.dart';
part 'sheet/s_modal_sheet.dart';
part 'sheet/s_sheet_animations.dart';
part 'dialog/s_modal_dialog.dart';
part 'snackbar/s_modal_snackbar.dart';

/// The kind of lifecycle transition reported for a modal.
enum ModalLifecycleEventType {
  created,
  dismissed,
}

/// Lightweight public information about a modal lifecycle transition.
///
/// This intentionally exposes only stable metadata so callers can react to
/// modal creation and dismissal without depending on internal modal content.
class ModalLifecycleEvent {
  const ModalLifecycleEvent({
    required this.id,
    required this.modalType,
    required this.eventType,
    required this.modalPosition,
    required this.stackLevel,
  });

  /// Unique identifier of the modal involved in the event.
  final String id;

  /// Type of modal involved in the event.
  final ModalType modalType;

  /// Whether the event represents a creation or dismissal transition.
  final ModalLifecycleEventType eventType;

  /// Screen alignment used by the modal when it was created or dismissed.
  final Alignment modalPosition;

  /// Rendering stack level of the modal when the event occurred.
  final int stackLevel;
}

/// Callback invoked for modal lifecycle events.
typedef ModalLifecycleCallback = void Function(ModalLifecycleEvent event);

/// Predicate callback used to filter lifecycle notifications.
typedef ModalLifecycleShouldNotify = bool Function(ModalLifecycleEvent event);

class _ModalLifecycleListener {
  _ModalLifecycleListener({
    required this.onCreated,
    required this.onDismissed,
    required this.modalTypes,
    required this.shouldNotify,
  });

  final ModalLifecycleCallback? onCreated;
  final ModalLifecycleCallback? onDismissed;
  final Set<ModalType>? modalTypes;
  final ModalLifecycleShouldNotify? shouldNotify;

  bool _matches(ModalLifecycleEvent event) {
    // Filter by modal type and predicate (if provided).
    final matchesType =
        modalTypes == null || modalTypes!.contains(event.modalType);
    final matchesPredicate = shouldNotify?.call(event) ?? true;
    return matchesType && matchesPredicate;
  }

  void dispatch(ModalLifecycleEvent event) {
    // Guard against listeners that don't match the event.
    if (!_matches(event)) return;
    try {
      switch (event.eventType) {
        case ModalLifecycleEventType.created:
          onCreated?.call(event);
          break;
        case ModalLifecycleEventType.dismissed:
          onDismissed?.call(event);
          break;
      }
    } catch (_) {
      // Listener failures are isolated so one bad listener cannot break the dispatch chain.
    }
  }
}

final Map<int, _ModalLifecycleListener> _modalLifecycleListeners = {};
int _nextModalLifecycleListenerId = 1;

ModalLifecycleEvent _buildModalLifecycleEvent(
  _ModalContent content,
  ModalLifecycleEventType eventType,
) {
  // Assemble a stable, public lifecycle event payload.
  return ModalLifecycleEvent(
    id: content.uniqueId,
    modalType: content.modalType,
    eventType: eventType,
    modalPosition: content.modalPosition,
    stackLevel: content.stackLevel,
  );
}

void _dispatchModalLifecycleEvent(ModalLifecycleEvent event) {
  // Decide whether appBuilder callbacks should run for this event.
  final shouldDispatch = (_appBuilderLifecycleModalTypes == null ||
          _appBuilderLifecycleModalTypes!.contains(event.modalType)) &&
      (_appBuilderLifecycleShouldNotify?.call(event) ?? true);

  for (final listener
      in List<_ModalLifecycleListener>.from(_modalLifecycleListeners.values)) {
    try {
      // Dispatch to registered listeners.
      listener.dispatch(event);
    } catch (_) {
      // Keep dispatch resilient even if a listener throws unexpectedly.
    }
  }

  final appBuilderListener = event.eventType == ModalLifecycleEventType.created
      ? _appBuilderOnModalCreated
      : _appBuilderOnModalDismissed;
  if (shouldDispatch && appBuilderListener != null) {
    try {
      // Dispatch to appBuilder-level callbacks.
      appBuilderListener(event);
    } catch (_) {
      // Keep appBuilder callback failures isolated from the dispatch pipeline.
    }
  }
}

void _dispatchModalLifecycleEvents(
  Iterable<_ModalContent> contents,
  ModalLifecycleEventType eventType,
) {
  // Emit unique lifecycle events per modal id.
  final seenIds = <String>{};
  for (final content in contents) {
    if (seenIds.add(content.uniqueId)) {
      _dispatchModalLifecycleEvent(
          _buildModalLifecycleEvent(content, eventType));
    }
  }
}

int _addModalLifecycleListener({
  ModalLifecycleCallback? onCreated,
  ModalLifecycleCallback? onDismissed,
  Set<ModalType>? modalTypes,
  ModalLifecycleShouldNotify? shouldNotify,
}) {
  // Allocate and register a new listener id.
  final listenerId = _nextModalLifecycleListenerId++;
  _modalLifecycleListeners[listenerId] = _ModalLifecycleListener(
    onCreated: onCreated,
    onDismissed: onDismissed,
    modalTypes:
        modalTypes == null ? null : Set<ModalType>.unmodifiable(modalTypes),
    shouldNotify: shouldNotify,
  );
  return listenerId;
}

bool _removeModalLifecycleListener(int listenerId) {
  // Remove by id; return whether a listener was removed.
  final removed = _modalLifecycleListeners.remove(listenerId) != null;
  return removed;
}

void _clearModalLifecycleListeners() {
  // Clear all registered listeners.
  _modalLifecycleListeners.clear();
}

ModalLifecycleCallback? _appBuilderOnModalCreated;
ModalLifecycleCallback? _appBuilderOnModalDismissed;
Set<ModalType>? _appBuilderLifecycleModalTypes;
ModalLifecycleShouldNotify? _appBuilderLifecycleShouldNotify;

/// Returns true when a modal barrier should intercept taps.
///
/// The rule is shared across dialog, sheet, and snackbar barriers so the
/// visual barrier and pointer behavior stay decoupled but consistent.
bool _shouldCaptureModalBarrierTaps({
  required bool isDismissable,
  required bool blockBackgroundInteraction,
}) {
  // Capture taps when dismissal is allowed or background is blocked.
  return isDismissable || blockBackgroundInteraction;
}

/// Builds the visual portion of a modal barrier.
Widget _buildModalBarrierSurface(Color barrierColor, double opacity) {
  // Render a colored fullscreen barrier surface.
  return SizedBox.expand(
    child: ColoredBox(
      color: barrierColor.withValues(alpha: opacity),
    ),
  );
}

// Helper function for safe lerping
double lerpDouble(double? a, double? b, double t) {
  // Safe lerp with null-handling and clamping.
  // Provide default values for null parameters
  a ??= 0.0;
  b ??= 0.0;

  // Ensure t is within valid range to prevent errors
  t = t.clamp(0.0, 1.0);

  try {
    // Use standard lerpDouble from dart:ui with safety checks
    // Use standard lerpDouble from dart:ui with safety checks
    final result = ui.lerpDouble(a, b, t);
    return result ?? b; // Fallback to 'b' if lerp returns null
  } catch (e) {
    // Fallback to the target value on any unexpected error.
    return b; // Return the target value as a sensible default
  }
}
