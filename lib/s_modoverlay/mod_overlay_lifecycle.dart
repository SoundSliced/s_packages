import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Identifies which overlay subsystem produced a lifecycle event.
enum ModOverlayLifecycleSource { popOverlay, modal }

/// Lightweight public metadata for global overlay/modal lifecycle hooks.
///
/// [id] is the effective ID used by the underlying subsystem. For modals this
/// is the same value accepted by dismissal APIs when a caller-provided ID was
/// supplied, otherwise it is the generated modal ID.
class ModOverlayLifecycleEvent {
  const ModOverlayLifecycleEvent({
    required this.id,
    required this.source,
    this.semanticId,
    this.modalType,
    this.modalPosition,
    this.stackLevel,
    this.activationOrder,
    this.isVisible,
  });

  /// Effective ID for the pop or modal instance.
  final String id;

  /// Optional caller-provided/semantic ID when it differs from the effective ID.
  final String? semanticId;

  /// Subsystem that emitted this event.
  final ModOverlayLifecycleSource source;

  /// Modal type metadata when [source] is [ModOverlayLifecycleSource.modal].
  ///
  /// Kept as [Object?] so this global coordinator remains independent from the
  /// s_modal implementation library and avoids circular public imports.
  final Object? modalType;

  /// Modal position metadata when available.
  final Alignment? modalPosition;

  /// Rendering stack level at the time of the event, when available.
  final int? stackLevel;

  /// Activation order at the time of the event, when available.
  final int? activationOrder;

  /// Pop-overlay visibility metadata when available.
  final bool? isVisible;

  @override
  String toString() {
    return 'ModOverlayLifecycleEvent('
        'id: $id, '
        'semanticId: $semanticId, '
        'source: $source, '
        'modalType: $modalType, '
        'modalPosition: $modalPosition, '
        'stackLevel: $stackLevel, '
        'activationOrder: $activationOrder, '
        'isVisible: $isVisible'
        ')';
  }
}

/// Callback invoked for global overlay/modal lifecycle events.
typedef ModOverlayLifecycleCallback = void Function(ModOverlayLifecycleEvent event);

/// Global coordinator for the s_modoverlay package.
///
/// Set [onInit] and/or [onDismiss] once to observe every PopOverlay and Modal
/// show/dismiss lifecycle transition without wiring individual call sites.
class ModOverlay {
  const ModOverlay._();

  /// Called whenever a pop overlay or modal is shown/initialized.
  static ModOverlayLifecycleCallback? onInit;

  /// Called whenever a pop overlay or modal is dismissed/hidden/removed.
  static ModOverlayLifecycleCallback? onDismiss;

  /// Dispatches a global init event.
  ///
  /// Public mainly for package-level integrations; app code should usually set
  /// [onInit] rather than calling this directly.
  static void dispatchInit(ModOverlayLifecycleEvent event) {
    _safeDispatch(onInit, event, 'onInit');
  }

  /// Dispatches a global dismiss event.
  ///
  /// Public mainly for package-level integrations; app code should usually set
  /// [onDismiss] rather than calling this directly.
  static void dispatchDismiss(ModOverlayLifecycleEvent event) {
    _safeDispatch(onDismiss, event, 'onDismiss');
  }

  /// Clears all global lifecycle callbacks.
  ///
  /// Useful in tests and during teardown.
  static void clearLifecycleHooks() {
    onInit = null;
    onDismiss = null;
  }

  static void _safeDispatch(ModOverlayLifecycleCallback? callback, ModOverlayLifecycleEvent event, String hookName) {
    if (callback == null) return;
    try {
      callback(event);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 's_modoverlay',
          context: ErrorDescription('while dispatching ModOverlay.$hookName'),
          informationCollector: () => <DiagnosticsNode>[DiagnosticsProperty<ModOverlayLifecycleEvent>('event', event)],
        ),
      );
    }
  }
}
