part of '../signals_watch.dart';

/// A unified class that bundles:
/// - Advanced reactive widget (formerly WatchValue)
/// - Signals registry utilities
/// - Selective signals observer initializer
/// - Auto-registering signal/computed factories
class SignalsWatch<T> extends StatefulWidget {
  /// Create a SignalsWatch with a custom read function.
  const SignalsWatch({
    super.key,
    required T Function() read,
    required this.builder,
    this.onInit,
    this.onValueUpdated,
    this.onAfterBuild,
    this.onDispose,
    this.shouldRebuild,
    this.shouldNotify,
    this.equals,
    this.debounce,
    this.throttle,
    this.onError,
    this.errorBuilder,
    this.loadingBuilder,
    this.debugLabel,
    this.debugPrint = false,
  })  : assert(
          debounce == null || throttle == null,
          'Cannot use both debounce and throttle simultaneously',
        ),
        _read = read,
        _signal = null,
        _signals = null,
        _combine = null,
        _selector = null;

  /// Create a SignalsWatch from a single signal.
  const SignalsWatch.fromSignal(
    ReadonlySignal<T> signal, {
    super.key,
    required this.builder,
    this.onInit,
    this.onValueUpdated,
    this.onAfterBuild,
    this.onDispose,
    this.shouldRebuild,
    this.shouldNotify,
    this.equals,
    this.debounce,
    this.throttle,
    this.onError,
    this.errorBuilder,
    this.loadingBuilder,
    this.debugLabel,
    this.debugPrint = false,
  })  : assert(
          debounce == null || throttle == null,
          'Cannot use both debounce and throttle simultaneously',
        ),
        _signal = signal,
        _signals = null,
        _combine = null,
        _read = null,
        _selector = null;

  /// Create a SignalsWatch from multiple signals with batch updates.
  SignalsWatch.fromSignals(
    List<ReadonlySignal<dynamic>> signals, {
    super.key,
    required T Function(List<dynamic> values) combine,
    required this.builder,
    this.onInit,
    this.onValueUpdated,
    this.onAfterBuild,
    this.onDispose,
    this.shouldRebuild,
    this.shouldNotify,
    this.equals,
    this.debounce,
    this.throttle,
    this.onError,
    this.errorBuilder,
    this.loadingBuilder,
    this.debugLabel,
    this.debugPrint = false,
  })  : assert(signals.isNotEmpty, 'signals list cannot be empty'),
        assert(
          debounce == null || throttle == null,
          'Cannot use both debounce and throttle simultaneously',
        ),
        _signals = signals,
        _combine = combine,
        _signal = null,
        _read = null,
        _selector = null;

  /// Create a SignalsWatch with a selector for efficient updates.
  /// Only rebuilds when the selected value changes (compared via equals).
  const SignalsWatch.select(
    ReadonlySignal<dynamic> signal, {
    super.key,
    required T Function(dynamic value) selector,
    required this.builder,
    this.onInit,
    this.onValueUpdated,
    this.onAfterBuild,
    this.onDispose,
    this.shouldRebuild,
    this.shouldNotify,
    this.equals,
    this.debounce,
    this.throttle,
    this.onError,
    this.errorBuilder,
    this.loadingBuilder,
    this.debugLabel,
    this.debugPrint = false,
  })  : assert(
          debounce == null || throttle == null,
          'Cannot use both debounce and throttle simultaneously',
        ),
        _signal = signal,
        _selector = selector,
        _signals = null,
        _combine = null,
        _read = null;

  // ==== Registry (formerly SignalsRegistry) ====
  /// Registers a signal/computed and sets up automatic removal on dispose.
  /// Returns the SAME instance passed in (preserves concrete type).
  static S register<S extends s.ReadonlySignal<dynamic>>(S signal) =>
      _registerSignal(signal);

  /// Disposes all tracked signals (manual global teardown).
  static void disposeAll() => _registryDisposeAll();

  /// Number of currently registered signals/computeds.
  static int get size => _registrySize();

  /// Manually unregister (rarely needed; dispose normally handles this).
  static void unregister(s.ReadonlySignal<dynamic> signal) =>
      _registryUnregister(signal);

  /// Auto-registering replacement for `signals.signal`.
  ///
  /// Optionally accepts lifecycle callbacks that will be used as defaults
  /// when observing this signal (widget-level callbacks override these).
  static s.Signal<T> signal<T>(
    T initialValue, {
    String? debugLabel,
    bool autoDispose = false,
    Function? onInit,
    Function? onValueUpdated,
    Function? onAfterBuild,
    Function? onDispose,
    bool debugTrace = false,
    Map<String, dynamic>? metadata,
  }) {
    final created = s.signal<T>(
      initialValue,
      debugLabel: debugLabel,
      autoDispose: autoDispose,
    );

    // Store metadata if any lifecycle callbacks or metadata provided
    if (onInit != null ||
        onValueUpdated != null ||
        onAfterBuild != null ||
        onDispose != null ||
        debugTrace ||
        metadata != null) {
      _storeSignalMetadata(
        created,
        _SignalMetadata<T>(
          initialValue: initialValue,
          onInit: onInit,
          onValueUpdated: onValueUpdated,
          onAfterBuild: onAfterBuild,
          onDispose: onDispose,
          debugTrace: debugTrace,
          metadata: metadata,
        ),
      );
    }

    return register(created);
  }

  /// Auto-registering replacement for `signals.computed`.
  ///
  /// Optionally accepts lifecycle callbacks that will be used as defaults
  /// when observing this signal (widget-level callbacks override these).
  static s.Computed<T> computed<T>(
    T Function() compute, {
    String? debugLabel,
    bool autoDispose = false,
    Function? onInit,
    Function? onValueUpdated,
    Function? onAfterBuild,
    Function? onDispose,
    bool debugTrace = false,
    Map<String, dynamic>? metadata,
  }) {
    final created = s.computed<T>(
      compute,
      debugLabel: debugLabel,
      autoDispose: autoDispose,
    );

    // Store metadata if any lifecycle callbacks or metadata provided
    if (onInit != null ||
        onValueUpdated != null ||
        onAfterBuild != null ||
        onDispose != null ||
        debugTrace ||
        metadata != null) {
      _storeSignalMetadata(
        created,
        _SignalMetadata<T>(
          onInit: onInit,
          onValueUpdated: onValueUpdated,
          onAfterBuild: onAfterBuild,
          onDispose: onDispose,
          debugTrace: debugTrace,
          metadata: metadata,
        ),
      );
    }

    return register(created);
  }

  /// Create a signal from a Future.
  ///
  /// Optionally accepts lifecycle callbacks that will be used as defaults
  /// when observing this signal (widget-level callbacks override these).
  static s.Signal<T?> fromFuture<T>(
    Future<T> future, {
    T? initialValue,
    String? debugLabel,
    bool autoDispose = false,
    void Function(Object error, StackTrace stackTrace)? onError,
    Function? onInit,
    Function? onValueUpdated,
    Function? onAfterBuild,
    Function? onDispose,
    bool debugTrace = false,
    Map<String, dynamic>? metadata,
  }) =>
      _signalFromFuture<T>(
        future,
        initialValue: initialValue,
        debugLabel: debugLabel,
        autoDispose: autoDispose,
        onError: onError,
        onInit: onInit,
        onValueUpdated: onValueUpdated,
        onAfterBuild: onAfterBuild,
        onDispose: onDispose,
        debugTrace: debugTrace,
        metadata: metadata,
      );

  /// Create a signal from a Stream.
  ///
  /// Optionally accepts lifecycle callbacks that will be used as defaults
  /// when observing this signal (widget-level callbacks override these).
  static s.Signal<T?> fromStream<T>(
    Stream<T> stream, {
    T? initialValue,
    String? debugLabel,
    bool autoDispose = false,
    bool cancelOnError = false,
    void Function(Object error, StackTrace stackTrace)? onError,
    Function? onInit,
    Function? onValueUpdated,
    Function? onAfterBuild,
    Function? onDispose,
    bool debugTrace = false,
    Map<String, dynamic>? metadata,
  }) =>
      _signalFromStream<T>(
        stream,
        initialValue: initialValue,
        debugLabel: debugLabel,
        autoDispose: autoDispose,
        cancelOnError: cancelOnError,
        onError: onError,
        onInit: onInit,
        onValueUpdated: onValueUpdated,
        onAfterBuild: onAfterBuild,
        onDispose: onDispose,
        debugTrace: debugTrace,
        metadata: metadata,
      );

  /// Initialize the global SignalsObserver with a selective logger
  /// that only logs labeled signals.
  static void initializeSignalsObserver() {
    SignalsObserver.instance = _SelectiveSignalsObserver();
  }

  final T Function()? _read;
  final ReadonlySignal? _signal;
  final List<ReadonlySignal<dynamic>>? _signals;
  final T Function(List<dynamic>)? _combine;
  final T Function(dynamic)? _selector;

  /// Builds the UI with the current value.
  final Widget Function(T value) builder;

  /// Called once when initialized. Signature: (T value) or (T value, T? previous).
  final Function? onInit;

  /// Called when value changes. Signature: (T value) or (T value, T? previous).
  final Function? onValueUpdated;

  /// Called post-frame after every build. Signature: (T value) or (T value, T? previous).
  final Function? onAfterBuild;

  /// Called when disposed. Signature: (T value) or (T value, T? previous).
  final Function? onDispose;

  /// Determines if the widget should rebuild. Return false to skip rebuild.
  final bool Function(T newValue, T oldValue)? shouldRebuild;

  /// Determines if onValueUpdated should fire. Defaults to checking equality.
  final bool Function(T newValue, T oldValue)? shouldNotify;

  /// Custom equality check. Defaults to `==`.
  final bool Function(T a, T b)? equals;

  /// Debounce duration. Waits after last change before updating. Default: null (immediate).
  final Duration? debounce;

  /// Throttle duration. Ignores changes within this duration. Default: null (no throttle).
  final Duration? throttle;

  /// Called when an error occurs during read.
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// Builder for error states. Defaults to Text with error message.
  final Widget Function(Object error)? errorBuilder;

  /// Builder for loading/pending states. Defaults to CircularProgressIndicator.
  final Widget Function()? loadingBuilder;

  /// Debug label for logging.
  final String? debugLabel;

  /// Auto-log all lifecycle events.
  final bool debugPrint;

  @override
  State<SignalsWatch<T>> createState() => _SignalsWatchState<T>();
}

class _SignalsWatchState<T> extends State<SignalsWatch<T>> {
  late T _currentValue;
  T? _previousValue;
  bool _isFirstBuild = true;
  Object? _error;
  bool _isLoading = false;
  Widget? _cachedBuiltWidget;

  Timer? _debounceTimer;
  Timer? _throttleTimer;

  // Cache merged callbacks
  Function? _effectiveOnInit;
  Function? _effectiveOnValueUpdated;
  Function? _effectiveOnAfterBuild;
  Function? _effectiveOnDispose;

  // Track if this widget is overriding the signal's onValueUpdated
  bool _isOverridingCallback = false;

  /// Get effective callbacks by merging widget-level and signal-level callbacks.
  /// Widget-level callbacks take precedence over signal-level ones.
  void _initializeCallbacks() {
    // Try to get signal-level callbacks if we're watching a single signal
    _SignalMetadata<dynamic>? signalMetadata;
    if (widget._signal != null) {
      signalMetadata = _getSignalMetadata(widget._signal!);
    }

    // Widget callbacks override signal callbacks
    _effectiveOnInit = widget.onInit ?? signalMetadata?.onInit;
    _effectiveOnValueUpdated =
        widget.onValueUpdated ?? signalMetadata?.onValueUpdated;
    _effectiveOnAfterBuild =
        widget.onAfterBuild ?? signalMetadata?.onAfterBuild;
    _effectiveOnDispose = widget.onDispose ?? signalMetadata?.onDispose;

    // Track if we're overriding the signal's callback
    if (widget.onValueUpdated != null &&
        signalMetadata?.onValueUpdated != null) {
      _isOverridingCallback = true;
      signalMetadata?._overrideCount++;
    }
  }

  bool _valuesEqual(T a, T b) {
    if (widget.equals != null) {
      return widget.equals!(a, b);
    }
    return a == b;
  }

  T _readValue() {
    try {
      if (widget._signal != null) {
        if (widget._selector != null) {
          // Selector mode
          return widget._selector!(widget._signal!.value);
        }
        // Single signal mode
        return widget._signal!.value;
      } else if (widget._signals != null) {
        // Multiple signals mode (batch)
        final values = widget._signals!.map((s) => s.value).toList();
        return widget._combine!(values);
      } else {
        // Custom read mode
        return widget._read!();
      }
    } catch (e, stack) {
      _error = e;
      widget.onError?.call(e, stack);
      if (widget.debugPrint) {
        debugPrint('[${widget.debugLabel ?? 'SignalsWatch'}] Error: $e');
      }
      rethrow;
    }
  }

  void _callCallback(Function? callback, T value, T? previous) {
    if (callback == null) return;

    try {
      // Try calling with both parameters
      Function.apply(callback, [value, previous]);
    } catch (_) {
      try {
        // Fallback to single parameter
        Function.apply(callback, [value]);
      } catch (e) {
        if (widget.debugPrint) {
          debugPrint(
            '[${widget.debugLabel ?? 'SignalsWatch'}] Callback error: $e',
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize merged callbacks
    _initializeCallbacks();

    try {
      _currentValue = _readValue();
      _error = null;
      if (widget.debugPrint) {
        debugPrint(
          '[${widget.debugLabel ?? 'SignalsWatch'}] Init: $_currentValue',
        );
      }
      _callCallback(_effectiveOnInit, _currentValue, null);
    } catch (e) {
      _error = e;
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    // Cancel timers first to prevent any callbacks after disposal
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _throttleTimer?.cancel();
    _throttleTimer = null;

    // Decrement override count if we were overriding
    if (_isOverridingCallback && widget._signal != null) {
      final signalMetadata = _getSignalMetadata(widget._signal!);
      if (signalMetadata != null && signalMetadata._overrideCount > 0) {
        signalMetadata._overrideCount--;
      }
    }

    // Call onDispose regardless of error state (user may want to cleanup)
    try {
      _callCallback(_effectiveOnDispose, _currentValue, null);
      if (widget.debugPrint) {
        debugPrint(
          '[${widget.debugLabel ?? 'SignalsWatch'}] Dispose: $_currentValue',
        );
      }
    } catch (e) {
      // Silently catch dispose errors to prevent dispose exceptions
      if (widget.debugPrint) {
        debugPrint(
          '[${widget.debugLabel ?? 'SignalsWatch'}] Dispose error: $e',
        );
      }
    }

    super.dispose();
  }

  bool _handleValueChange(T newValue) {
    final oldValue = _currentValue;

    // Check if values are equal
    final areEqual = _valuesEqual(newValue, oldValue);

    // Determine if we should rebuild
    bool shouldRebuildWidget =
        widget.shouldRebuild?.call(newValue, oldValue) ?? !areEqual;

    // Never trigger a "rebuild" decision due solely to an equal value on the very first build
    // even if a custom shouldRebuild returns true for equal values.
    if (_isFirstBuild && areEqual) {
      shouldRebuildWidget = true; // first build must build once
    }

    // Determine if we should notify
    final shouldNotifyCallback =
        widget.shouldNotify?.call(newValue, oldValue) ?? !areEqual;
    final effectiveShouldNotify = shouldNotifyCallback;

    if (widget.debugPrint && !areEqual) {
      debugPrint(
        '[${widget.debugLabel ?? 'SignalsWatch'}] Value changed: $oldValue -> $newValue',
      );
    }

    _previousValue = oldValue;
    _currentValue = newValue;

    // Handle notification with debounce/throttle
    // Call widget-level callback if explicitly set (signal-level is handled by effect)
    if (!_isFirstBuild &&
        effectiveShouldNotify &&
        widget.onValueUpdated != null) {
      if (widget.debounce != null) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(widget.debounce!, () {
          // Check if widget is still mounted before calling callback
          if (mounted) {
            _callCallback(_effectiveOnValueUpdated, newValue, oldValue);
          }
        });
      } else if (widget.throttle != null) {
        if (_throttleTimer == null || !_throttleTimer!.isActive) {
          // Allow call and start throttle window
          _callCallback(_effectiveOnValueUpdated, newValue, oldValue);
          _throttleTimer?.cancel();
          _throttleTimer = Timer(widget.throttle!, () {
            // Window ended; next change can trigger again
          });
        }
      } else {
        _callCallback(_effectiveOnValueUpdated, newValue, oldValue);
      }
    }

    return shouldRebuildWidget;
  }

  @override
  Widget build(BuildContext context) {
    // Handle error state
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!);
      }
      return Center(
        child: Text(
          'Error: $_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    // Handle loading state
    if (_isLoading) {
      if (widget.loadingBuilder != null) {
        return widget.loadingBuilder!();
      }
      return const Center(child: CircularProgressIndicator());
    }

    return Watch((ctx) {
      try {
        final newValue = _readValue();
        _error = null;

        final shouldRebuildWidget = _handleValueChange(newValue);

        if (_cachedBuiltWidget == null ||
            _isFirstBuild ||
            shouldRebuildWidget) {
          _cachedBuiltWidget = widget.builder(newValue);
        }

        // Schedule onAfterBuild post-frame
        if (_effectiveOnAfterBuild != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _callCallback(_effectiveOnAfterBuild, newValue, _previousValue);
            }
          });
        }

        _isFirstBuild = false;
        return _cachedBuiltWidget!;
      } catch (e) {
        _error = e;
        if (widget.errorBuilder != null) {
          return widget.errorBuilder!(e);
        }
        return Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
        );
      }
    });
  }
}

/// Extension on [ReadonlySignal] to provide fluent observe API.
///
/// This allows calling `.observe()` directly on any signal for a more
/// ergonomic syntax:
///
/// ```dart
/// final counter = SignalsWatch.signal(0);
///
/// // Instead of:
/// SignalsWatch.fromSignal(counter, builder: (value) => Text('$value'))
///
/// // You can write:
/// counter.observe((value) => Text('$value'))
/// ```
extension SignalObserveExtension<T> on ReadonlySignal<T> {
  /// Observe this signal and rebuild when it changes.
  ///
  /// Example:
  /// ```dart
  /// counter.observe(
  ///   (value) => Text('$value'),
  ///   onValueUpdated: (value) => print('Counter: $value'),
  ///   debounce: Duration(milliseconds: 300),
  /// )
  /// ```
  SignalsWatch<T> observe(
    Widget Function(T) builder, {
    Key? key,
    void Function(T value)? onInit,
    Function? onValueUpdated,
    void Function(T value)? onAfterBuild,
    void Function(T value)? onDispose,
    bool Function(T newValue, T oldValue)? shouldRebuild,
    bool Function(T newValue, T oldValue)? shouldNotify,
    bool Function(T a, T b)? equals,
    Duration? debounce,
    Duration? throttle,
    void Function(Object error, StackTrace stack)? onError,
    Widget Function(Object error)? errorBuilder,
    Widget Function()? loadingBuilder,
    String? debugLabel,
    bool debugPrint = false,
  }) {
    return SignalsWatch<T>.fromSignal(
      this,
      key: key,
      builder: builder,
      onInit: onInit,
      onValueUpdated: onValueUpdated,
      onAfterBuild: onAfterBuild,
      onDispose: onDispose,
      shouldRebuild: shouldRebuild,
      shouldNotify: shouldNotify,
      equals: equals,
      debounce: debounce,
      throttle: throttle,
      onError: onError,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      debugLabel: debugLabel,
      debugPrint: debugPrint,
    );
  }

  /// Select a specific part of this signal's value and only rebuild when that part changes.
  ///
  /// Example:
  /// ```dart
  /// final user = SignalsWatch.signal(User(name: 'John', age: 25));
  ///
  /// // Only rebuilds when age changes, ignores name changes
  /// user.selectObserve(
  ///   (user) => user.age,
  ///   (age) => Text('Age: $age'),
  /// )
  /// ```
  SignalsWatch<S> selectObserve<S>(
    S Function(dynamic) selector,
    Widget Function(S) builder, {
    Key? key,
    void Function(S value)? onInit,
    Function? onValueUpdated,
    void Function(S value)? onAfterBuild,
    void Function(S value)? onDispose,
    bool Function(S newValue, S oldValue)? shouldRebuild,
    bool Function(S newValue, S oldValue)? shouldNotify,
    bool Function(S a, S b)? equals,
    Duration? debounce,
    Duration? throttle,
    void Function(Object error, StackTrace stack)? onError,
    Widget Function(Object error)? errorBuilder,
    Widget Function()? loadingBuilder,
    String? debugLabel,
    bool debugPrint = false,
  }) {
    return SignalsWatch<S>.select(
      this,
      selector: selector,
      key: key,
      builder: builder,
      onInit: onInit,
      onValueUpdated: onValueUpdated,
      onAfterBuild: onAfterBuild,
      onDispose: onDispose,
      shouldRebuild: shouldRebuild,
      shouldNotify: shouldNotify,
      equals: equals,
      debounce: debounce,
      throttle: throttle,
      onError: onError,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      debugLabel: debugLabel,
      debugPrint: debugPrint,
    );
  }

  /// Transform this signal's value and observe the result with error handling.
  ///
  /// This is perfect for transformations that might throw exceptions,
  /// such as validation, parsing, or computed values that can fail.
  ///
  /// Example:
  /// ```dart
  /// final numberSignal = SignalsWatch.signal(5);
  ///
  /// numberSignal.transform(
  ///   (value) {
  ///     if (value < 0) throw Exception('Negative!');
  ///     return value * 2;
  ///   },
  ///   builder: (doubled) => Text('$doubled'),
  ///   onError: (error, stack) => logError(error, stack),
  ///   errorBuilder: (error) => ErrorCard(error: error),
  /// )
  /// ```
  SignalsWatch<R> transform<R>(
    R Function(T) transform, {
    Key? key,
    required Widget Function(R) builder,
    void Function(R value)? onInit,
    Function? onValueUpdated,
    void Function(R value)? onAfterBuild,
    void Function(R value)? onDispose,
    bool Function(R newValue, R oldValue)? shouldRebuild,
    bool Function(R newValue, R oldValue)? shouldNotify,
    bool Function(R a, R b)? equals,
    Duration? debounce,
    Duration? throttle,
    void Function(Object error, StackTrace stack)? onError,
    Widget Function(Object error)? errorBuilder,
    Widget Function()? loadingBuilder,
    String? debugLabel,
    bool debugPrint = false,
  }) {
    return SignalsWatch<R>(
      key: key,
      read: () => transform(value),
      builder: builder,
      onInit: onInit,
      onValueUpdated: onValueUpdated,
      onAfterBuild: onAfterBuild,
      onDispose: onDispose,
      shouldRebuild: shouldRebuild,
      shouldNotify: shouldNotify,
      equals: equals,
      debounce: debounce,
      throttle: throttle,
      onError: onError,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      debugLabel: debugLabel,
      debugPrint: debugPrint,
    );
  }
}

/// Extension on [List<ReadonlySignal>] to provide fluent observe API for multiple signals.
///
/// This allows calling `.observe()` directly on a list of signals:
///
/// ```dart
/// final firstName = SignalsWatch.signal('John');
/// final lastName = SignalsWatch.signal('Doe');
///
/// // Instead of:
/// SignalsWatch.fromSignals([firstName, lastName], combine: ..., builder: ...)
///
/// // You can write:
/// [firstName, lastName].observe(
///   combine: (values) => '${values[0]} ${values[1]}',
///   builder: (fullName) => Text(fullName),
/// )
/// ```
extension SignalListObserveExtension on List<ReadonlySignal<dynamic>> {
  /// Observe multiple signals and rebuild when any changes.
  ///
  /// Example:
  /// ```dart
  /// [firstName, lastName].observe(
  ///   combine: (values) => '${values[0]} ${values[1]}',
  ///   builder: (fullName) => Text(fullName),
  ///   onValueUpdated: (fullName) => print(fullName),
  /// )
  /// ```
  SignalsWatch<R> observe<R>({
    Key? key,
    required R Function(List<dynamic>) combine,
    required Widget Function(R) builder,
    void Function(R value)? onInit,
    Function? onValueUpdated,
    void Function(R value)? onAfterBuild,
    void Function(R value)? onDispose,
    bool Function(R newValue, R oldValue)? shouldRebuild,
    bool Function(R newValue, R oldValue)? shouldNotify,
    bool Function(R a, R b)? equals,
    Duration? debounce,
    Duration? throttle,
    void Function(Object error, StackTrace stack)? onError,
    Widget Function(Object error)? errorBuilder,
    Widget Function()? loadingBuilder,
    String? debugLabel,
    bool debugPrint = false,
  }) {
    return SignalsWatch<R>.fromSignals(
      this,
      key: key,
      combine: combine,
      builder: builder,
      onInit: onInit,
      onValueUpdated: onValueUpdated,
      onAfterBuild: onAfterBuild,
      onDispose: onDispose,
      shouldRebuild: shouldRebuild,
      shouldNotify: shouldNotify,
      equals: equals,
      debounce: debounce,
      throttle: throttle,
      onError: onError,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      debugLabel: debugLabel,
      debugPrint: debugPrint,
    );
  }
}
