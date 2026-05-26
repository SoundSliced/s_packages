part of '../signals_watch.dart';

typedef _LifecycleInvoker<T> = void Function(T value, T? previous);

_LifecycleInvoker<T>? _toLifecycleInvoker<T>(Function? callback) {
  if (callback == null) return null;

  if (callback is void Function(T, T?)) {
    return callback;
  }
  if (callback is void Function(T)) {
    return (value, _) => callback(value);
  }
  if (callback is void Function()) {
    return (_, __) => callback();
  }

  if (callback is void Function(dynamic, dynamic)) {
    return (value, previous) => callback(value, previous);
  }
  if (callback is void Function(dynamic)) {
    return (value, _) => callback(value);
  }

  return (value, previous) {
    try {
      Function.apply(callback, [value, previous]);
    } catch (_) {
      try {
        Function.apply(callback, [value]);
      } catch (_) {
        try {
          Function.apply(callback, []);
        } catch (_) {
          // Ignore callback errors to preserve update flow.
        }
      }
    }
  };
}

/// Metadata storage for signals to enable signal-level lifecycle callbacks
/// and support utilities like `.reset()`.
class _SignalMetadata<T> {
  _SignalMetadata({
    this.initialValue,
    this.onInit,
    this.onValueUpdated,
    this.onAfterBuild,
    this.onDispose,
    this.debugTrace = false,
    this.metadata,
  }) : onValueUpdatedInvoker = _toLifecycleInvoker<T>(onValueUpdated);

  final T? initialValue;
  final Function? onInit;
  final Function? onValueUpdated;
  final _LifecycleInvoker<T>? onValueUpdatedInvoker;
  final Function? onAfterBuild;
  final Function? onDispose;
  final bool debugTrace;
  final Map<String, dynamic>? metadata;

  /// Store the effect cleanup function so we can dispose it
  void Function()? _effectCleanup;

  /// Track previous value for change detection
  T? _previousValue;

  /// Track how many widgets are currently overriding the onValueUpdated callback
  int _overrideCount = 0;
}

/// Global registry mapping signals to their metadata
final Map<ReadonlySignal<dynamic>, _SignalMetadata<dynamic>> _signalMetadata =
    <ReadonlySignal<dynamic>, _SignalMetadata<dynamic>>{};

/// Store metadata for a signal
void _storeSignalMetadata<T>(
  ReadonlySignal<T> signal,
  _SignalMetadata<T> metadata,
) {
  _signalMetadata[signal] = metadata;

  // Set up an effect to watch for value changes and fire onValueUpdated callback
  // This ensures the callback fires once per signal change when no widgets override it
  if (metadata.onValueUpdated != null) {
    metadata._previousValue = signal.peek();

    final cleanup = s.effect(
      () {
        final currentValue = signal.value;
        final previousValue = metadata._previousValue;

        // Only fire callback if:
        // 1. Value actually changed
        // 2. No widgets are overriding this callback
        if (currentValue != previousValue && metadata._overrideCount == 0) {
          metadata.onValueUpdatedInvoker?.call(currentValue, previousValue);
        }

        metadata._previousValue = currentValue;
      },
    );

    metadata._effectCleanup = cleanup;
  }

  // Clean up metadata when signal is disposed
  signal.onDispose(
    () {
      metadata._effectCleanup?.call();
      _signalMetadata.remove(signal);
    },
  );
}

/// Retrieve metadata for a signal (if any)
_SignalMetadata<T>? _getSignalMetadata<T>(ReadonlySignal<T> signal) {
  return _signalMetadata[signal] as _SignalMetadata<T>?;
}

/// Extension to add `.reset()` to signals
extension SignalNotifyExtension<T> on Signal<T> {
  /// Reset the signal to its initial value (if metadata exists)
  ///
  /// Example:
  /// ```dart
  /// final counter = SignalsWatch.signal(0);
  /// counter.value = 10;
  /// counter.reset(); // back to 0
  /// ```
  void reset() {
    final metadata = _getSignalMetadata(this);
    if (metadata != null && metadata.initialValue != null) {
      value = metadata.initialValue as T;
    }
  }
}
