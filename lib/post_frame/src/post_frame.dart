import 'dart:async';
// ignore: unused_import
import 'dart:developer'; // Kept for potential future diagnostic logging.

import 'package:flutter/material.dart';

/// Optional global error handler for all PostFrame operations.
/// If set, this will be invoked whenever a PostFrame action throws an error.
typedef PostFrameErrorHandler = void Function(
  Object error,
  StackTrace stackTrace,
  String operation,
);

/// Optional predicate function to determine if a PostFrame action should execute.
/// Return `true` to proceed with execution, `false` to skip.
typedef PostFramePredicate = bool Function();

/// Utility entry point for scheduling work after the initial frame and (optionally)
/// after one or more end-of-frame passes and scroll metric stabilization.
///
/// This class provides a single static method [postFrame] which allows you to:
/// * Run a callback only after the first frame has rendered.
/// * Wait for multiple [ScrollController] instances to obtain stable metrics
///   (e.g. `maxScrollExtent`, `viewportDimension`).
/// * Wait for additional `endOfFrame` passes to give asynchronous layout or
///   animations time to settle.
///
/// The returned [Future] completes when the action runs or completes with an
/// error if the callback throws.
class PostFrame {
  /// Global error handler for all PostFrame operations.
  static PostFrameErrorHandler? errorHandler;

  /// Map of debounce keys to their pending tasks for debounced operations.
  static final Map<Object, PostFrameTask> _debouncedTasks = {};

  /// Schedule [action] to run after the current frame.
  ///
  /// Parameters:
  /// * [scrollControllers] - A list of controllers whose metrics you depend on.
  ///   Each controller is waited on until it has clients and its metrics appear
  ///   stable for up to [maxWaitFrames] frame passes. Provide multiple controllers
  ///   if your callback needs both (e.g. nested horizontal & vertical lists).
  /// * [maxWaitFrames] - Upper bound on frame waits for stabilization; protects
  ///   against indefinite waiting if metrics never settle. A value of 0 skips
  ///   metric waiting entirely.
  /// * [waitForEndOfFrame] - If true, awaits [WidgetsBinding.endOfFrame] for
  ///   each of the computed [endOfFramePasses] passes before evaluating scroll
  ///   controller metrics or executing the action.
  /// * [endOfFramePasses] - Number of additional end-of-frame completions to
  ///   await. Clamped to the range `1..maxWaitFrames` to avoid pointless waits.
  ///
  /// The function tolerates layout changes that happen during the stabilization
  /// window: if scroll metrics change (extent or viewport size) the wait ends
  /// early since a change often implies metrics are now ready for use.
  static Future<void> postFrame(
    FutureOr<void> Function() action, {
    List<ScrollController> scrollControllers = const [],
    int maxWaitFrames = 5,
    bool waitForEndOfFrame = true,
    int endOfFramePasses = 2,
  }) {
    final completer = Completer<void>();
    final binding = WidgetsBinding.instance;

    // Using addPostFrameCallback ensures we schedule AFTER first frame render.
    binding.addPostFrameCallback((_) async {
      try {
        // Optionally wait for extra end-of-frame passes.
        if (waitForEndOfFrame) {
          final passes = maxWaitFrames <= 0
              ? 0 // If we are not allowed frames, skip waiting entirely.
              : endOfFramePasses.clamp(1, maxWaitFrames);
          for (var i = 0; i < passes; i++) {
            await binding.endOfFrame; // Wait for pipeline to fully drain.
          }
        }

        // Wait for scroll controller metrics stabilization.
        for (final controller in scrollControllers) {
          await _waitForControllerMetrics(
            controller,
            maxWaitFrames,
            endOfFramePasses,
          );
        }

        // Execute user callback once; Future.sync preserves sync errors.
        if (!completer.isCompleted) {
          await Future.sync(action);
          completer.complete();
        }
      } catch (error, stackTrace) {
        // Propagate errors to the returned future for testability and chaining.
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      }
    });

    return completer.future;
  }

  /// Internal helper to wait until [controller] has clients and its scroll
  /// metrics appear stable. Stability heuristic:
  /// * We poll (via endOfFrame waits) for up to [maxWaitFrames].
  /// * If `hasClients` becomes true we capture initial metrics.
  /// * Any change in `maxScrollExtent` or `viewportDimension` ends the wait early
  ///   (indicating a layout change just occurred, and metrics are now usable).
  ///
  /// Limitations: Rapid successive asynchronous builds may still modify metrics
  /// after we conclude. Consumers needing stronger guarantees should combine this
  /// with their own diffing or schedule another post-frame step.
  static Future<void> _waitForControllerMetrics(
    ScrollController controller,
    int maxWaitFrames,
    int endOfFramePasses,
  ) async {
    // Short-circuit if waiting disabled.
    if (maxWaitFrames <= 0) return;

    final binding = WidgetsBinding.instance;
    var remaining = maxWaitFrames;

    // Wait until controller attaches to at least one ScrollPosition.
    while (!controller.hasClients && remaining-- > 0) {
      await binding.endOfFrame;
    }
    if (!controller.hasClients) return; // Give up if unattached.

    final position = controller.position;
    var previousExtent = position.maxScrollExtent;
    var previousViewport = position.viewportDimension;

    remaining = maxWaitFrames;
    while (remaining-- > 0) {
      await binding.endOfFrame; // Poll once per frame.

      if (!controller.hasClients) return; // Detached mid-wait.

      if (position.maxScrollExtent != previousExtent ||
          position.viewportDimension != previousViewport) {
        // Metrics changed -> assume layout stabilized enough for usage.
        return;
      }
    }
  }

  /// Unified advanced API returning a cancellable [PostFrameTask] with
  /// diagnostics encapsulated in a [PostFrameResult].
  ///
  /// If [predicate] is provided, it will be evaluated just before executing
  /// [action]. If the predicate returns `false`, the action is skipped and
  /// the result is marked as canceled.
  ///
  /// If [onError] is provided, it will be called when an error occurs in
  /// addition to the global [errorHandler] if set.
  static PostFrameTask<T> run<T>(
    FutureOr<T> Function() action, {
    List<ScrollController> scrollControllers = const [],
    int maxWaitFrames = 5,
    bool waitForEndOfFrame = true,
    int endOfFramePasses = 2,
    Duration? timeout,
    PostFramePredicate? predicate,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    final binding = WidgetsBinding.instance;
    final controllers = List<ScrollController>.unmodifiable(scrollControllers);
    final completer = Completer<PostFrameResult<T>>();
    final task = PostFrameTask<T>(completer.future);

    int endOfFramePassesWaited = 0;
    int scrollMetricWaitFrames = 0;
    int totalFramesWaited = 0;

    Timer? timeoutTimer;
    if (timeout != null) {
      timeoutTimer = Timer(timeout, () {
        if (!completer.isCompleted) {
          task.cancel();
          completer.complete(PostFrameResult<T>(
            canceled: true,
            error: TimeoutException('PostFrame.run timeout after $timeout'),
            stackTrace: StackTrace.current,
            value: null,
            endOfFramePassesWaited: endOfFramePassesWaited,
            scrollMetricWaitFrames: scrollMetricWaitFrames,
            totalFramesWaited: totalFramesWaited,
            controllers: controllers,
          ));
        }
      });
    }

    binding.addPostFrameCallback((_) async {
      try {
        if (task.isCanceled) {
          if (!completer.isCompleted) {
            completer.complete(PostFrameResult<T>(
              canceled: true,
              value: null,
              endOfFramePassesWaited: endOfFramePassesWaited,
              scrollMetricWaitFrames: scrollMetricWaitFrames,
              totalFramesWaited: totalFramesWaited,
              controllers: controllers,
            ));
          }
          return;
        }

        if (waitForEndOfFrame) {
          final passes =
              maxWaitFrames <= 0 ? 0 : endOfFramePasses.clamp(1, maxWaitFrames);
          for (var i = 0; i < passes; i++) {
            await binding.endOfFrame;
            endOfFramePassesWaited++;
            totalFramesWaited++;
            if (task.isCanceled) {
              completer.complete(PostFrameResult<T>(
                canceled: true,
                value: null,
                endOfFramePassesWaited: endOfFramePassesWaited,
                scrollMetricWaitFrames: scrollMetricWaitFrames,
                totalFramesWaited: totalFramesWaited,
                controllers: controllers,
              ));
              return;
            }
          }
        }

        if (maxWaitFrames > 0) {
          for (final controller in controllers) {
            var remaining = maxWaitFrames;
            while (!controller.hasClients && remaining-- > 0) {
              await binding.endOfFrame;
              scrollMetricWaitFrames++;
              totalFramesWaited++;
              if (task.isCanceled) {
                completer.complete(PostFrameResult<T>(
                  canceled: true,
                  value: null,
                  endOfFramePassesWaited: endOfFramePassesWaited,
                  scrollMetricWaitFrames: scrollMetricWaitFrames,
                  totalFramesWaited: totalFramesWaited,
                  controllers: controllers,
                ));
                return;
              }
            }
            if (!controller.hasClients) continue;
            final position = controller.position;
            var prevExtent = position.maxScrollExtent;
            var prevViewport = position.viewportDimension;
            remaining = maxWaitFrames;
            while (remaining-- > 0) {
              await binding.endOfFrame;
              scrollMetricWaitFrames++;
              totalFramesWaited++;
              if (task.isCanceled) {
                completer.complete(PostFrameResult<T>(
                  canceled: true,
                  value: null,
                  endOfFramePassesWaited: endOfFramePassesWaited,
                  scrollMetricWaitFrames: scrollMetricWaitFrames,
                  totalFramesWaited: totalFramesWaited,
                  controllers: controllers,
                ));
                return;
              }
              if (!controller.hasClients) break;
              if (position.maxScrollExtent != prevExtent ||
                  position.viewportDimension != prevViewport) {
                break;
              }
            }
          }
        }

        if (task.isCanceled) {
          if (!completer.isCompleted) {
            completer.complete(PostFrameResult<T>(
              canceled: true,
              value: null,
              endOfFramePassesWaited: endOfFramePassesWaited,
              scrollMetricWaitFrames: scrollMetricWaitFrames,
              totalFramesWaited: totalFramesWaited,
              controllers: controllers,
            ));
          }
          return;
        }

        // Check predicate before execution.
        if (predicate != null && !predicate()) {
          if (!completer.isCompleted) {
            completer.complete(PostFrameResult<T>(
              canceled: true,
              value: null,
              endOfFramePassesWaited: endOfFramePassesWaited,
              scrollMetricWaitFrames: scrollMetricWaitFrames,
              totalFramesWaited: totalFramesWaited,
              controllers: controllers,
            ));
          }
          return;
        }

        final value = await Future.sync(action);
        if (!completer.isCompleted) {
          completer.complete(PostFrameResult<T>(
            value: value,
            canceled: false,
            endOfFramePassesWaited: endOfFramePassesWaited,
            scrollMetricWaitFrames: scrollMetricWaitFrames,
            totalFramesWaited: totalFramesWaited,
            controllers: controllers,
          ));
        }
      } catch (error, stackTrace) {
        // Invoke error handlers.
        onError?.call(error, stackTrace);
        errorHandler?.call(error, stackTrace, 'PostFrame.run');

        if (!completer.isCompleted) {
          completer.complete(PostFrameResult<T>(
            canceled: task.isCanceled,
            error: error,
            stackTrace: stackTrace,
            value: null,
            endOfFramePassesWaited: endOfFramePassesWaited,
            scrollMetricWaitFrames: scrollMetricWaitFrames,
            totalFramesWaited: totalFramesWaited,
            controllers: controllers,
          ));
        }
      } finally {
        timeoutTimer?.cancel();
      }
    });

    return task;
  }

  /// Declarative builder helper returning a widget that executes a post-frame
  /// action and rebuilds with an [AsyncSnapshot] of [PostFrameResult].
  static Widget builder<T>({
    required FutureOr<T> Function() action,
    required Widget Function(BuildContext, AsyncSnapshot<PostFrameResult<T>>)
        builder,
    List<ScrollController> scrollControllers = const [],
    int maxWaitFrames = 5,
    bool waitForEndOfFrame = true,
    int endOfFramePasses = 2,
    Duration? timeout,
    bool runImmediately = true,
  }) {
    return _PostFrameBuilder<T>(
      action: action,
      builder: builder,
      scrollControllers: scrollControllers,
      maxWaitFrames: maxWaitFrames,
      waitForEndOfFrame: waitForEndOfFrame,
      endOfFramePasses: endOfFramePasses,
      timeout: timeout,
      runImmediately: runImmediately,
    );
  }

  /// Convenience builder returning common loading/data/error widgets.
  static Widget simpleBuilder<T>({
    Key? key,
    required FutureOr<T> Function() action,
    List<ScrollController> scrollControllers = const [],
    int maxWaitFrames = 5,
    bool waitForEndOfFrame = true,
    int endOfFramePasses = 2,
    Duration? timeout,
    Widget? loading,
    Widget Function(PostFrameResult<T> result)? errorBuilder,
    Widget Function(PostFrameResult<T> result)? dataBuilder,
  }) {
    return builder<T>(
      action: action,
      scrollControllers: scrollControllers,
      maxWaitFrames: maxWaitFrames,
      waitForEndOfFrame: waitForEndOfFrame,
      endOfFramePasses: endOfFramePasses,
      timeout: timeout,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loading ?? const Center(child: CircularProgressIndicator());
        }
        final result = snapshot.data!;
        if (result.canceled) {
          return errorBuilder?.call(result) ?? const Text('Canceled');
        }
        if (result.hasError) {
          return errorBuilder?.call(result) ?? Text('Error: ${result.error}');
        }
        return dataBuilder?.call(result) ?? Text('Value: ${result.value}');
      },
    );
  }

  // ---------------------------------------------------------------------------
  // New Feature: Repeat
  // ---------------------------------------------------------------------------
  /// Repeatedly schedules [action] to run on subsequent frames (optionally
  /// waiting for endOfFrame) until [maxIterations] is reached or canceled.
  ///
  /// The [action] receives the current 0-based iteration index.
  /// If [interval] is provided a timer delay is inserted between iterations
  /// (after the previous frame completes) allowing throttling.
  static PostFrameRepeater repeat(
    FutureOr<void> Function(int iteration) action, {
    int? maxIterations,
    Duration? interval,
    bool waitForEndOfFrame = false,
  }) {
    final binding = WidgetsBinding.instance;
    final repeater = PostFrameRepeater._(maxIterations: maxIterations);

    void scheduleNextFrame() => binding.scheduleFrame();

    void runIteration() async {
      if (repeater._canceled) return;
      if (repeater.maxIterations != null &&
          repeater.iterations >= repeater.maxIterations!) {
        repeater._complete();
        return;
      }
      try {
        if (waitForEndOfFrame) {
          await binding.endOfFrame;
        }
        final i = repeater.iterations;
        repeater.iterations++;
        await Future.sync(() => action(i));
        repeater._notifyIteration();
      } catch (e, st) {
        repeater._error = e;
        repeater._stackTrace = st;
        repeater.cancel();
        return;
      }
      if (!repeater._canceled) {
        if (repeater.maxIterations != null &&
            repeater.iterations >= repeater.maxIterations!) {
          repeater._complete();
          return;
        }
        if (interval != null) {
          Timer(interval, () {
            scheduleNextFrame();
            binding.addPostFrameCallback((_) => runIteration());
          });
        } else {
          scheduleNextFrame();
          binding.addPostFrameCallback((_) => runIteration());
        }
      }
    }

    // Schedule first iteration after current frame.
    binding.addPostFrameCallback((_) => runIteration());
    scheduleNextFrame();
    return repeater;
  }

  // ---------------------------------------------------------------------------
  // New Feature: Debounced
  // ---------------------------------------------------------------------------
  /// Schedule [action] to run after the current frame, canceling any previous
  /// pending action with the same [debounceKey].
  ///
  /// This is useful when multiple calls might occur in quick succession
  /// (e.g., during rapid rebuilds) and you only want the latest to execute.
  ///
  /// The [debounceKey] can be any object (typically a String or enum value).
  /// If omitted, the action itself is used as the key.
  static PostFrameTask<T> debounced<T>(
    FutureOr<T> Function() action, {
    Object? debounceKey,
    List<ScrollController> scrollControllers = const [],
    int maxWaitFrames = 5,
    bool waitForEndOfFrame = true,
    int endOfFramePasses = 2,
    Duration? timeout,
    PostFramePredicate? predicate,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    final key = debounceKey ?? action;

    // Cancel any existing task with this key.
    final existing = _debouncedTasks[key];
    if (existing != null && !existing.isCanceled) {
      existing.cancel();
    }

    // Schedule new task.
    final task = run<T>(
      action,
      scrollControllers: scrollControllers,
      maxWaitFrames: maxWaitFrames,
      waitForEndOfFrame: waitForEndOfFrame,
      endOfFramePasses: endOfFramePasses,
      timeout: timeout,
      predicate: predicate,
      onError: onError,
    );

    _debouncedTasks[key] = task;

    // Clean up from map when done.
    task.future.whenComplete(() => _debouncedTasks.remove(key));

    return task;
  }

  // ---------------------------------------------------------------------------
  // New Feature: onLayout
  // ---------------------------------------------------------------------------
  /// Waits for the widget associated with [key] to obtain a non-zero size and
  /// remain stable for [stabilityFrames] consecutive frame checks.
  /// Returns the final [Size] or `null` if not resolved within [maxWaitFrames].
  static Future<Size?> onLayout(
    GlobalKey key, {
    int maxWaitFrames = 20,
    int stabilityFrames = 2,
    bool waitForEndOfFrame = true,
  }) async {
    assert(stabilityFrames >= 1);
    final binding = WidgetsBinding.instance;
    int remaining = maxWaitFrames;
    Size? lastSize;
    int stableCount = 0;
    while (remaining-- > 0) {
      if (waitForEndOfFrame) {
        await binding.endOfFrame;
      } else {
        // microtask flush then next frame
        await Future.delayed(Duration.zero);
      }
      // Fetch and use the RenderObject directly without storing a BuildContext
      // variable (avoids use_build_context_synchronously lint false-positive).
      final renderObject = key.currentContext?.findRenderObject();
      if (renderObject is! RenderBox) continue;
      final size = renderObject.hasSize ? renderObject.size : null;
      if (size == null || size == Size.zero) {
        stableCount = 0;
        continue;
      }
      if (lastSize == size) {
        stableCount++;
        if (stableCount >= stabilityFrames) return size;
      } else {
        lastSize = size;
        stableCount = 1; // First stable observation.
        if (stableCount >= stabilityFrames) return size;
      }
    }
    return null; // Timed out.
  }

  // ---------------------------------------------------------------------------
  // New Feature: queueRun
  // ---------------------------------------------------------------------------
  static final List<_QueuedPostFrameAction> _queue = [];
  static bool _queueProcessing = false;

  /// Enqueue an advanced post-frame run ensuring sequential execution order.
  /// Tasks are processed one at a time; each waits for its own stabilization
  /// parameters. Useful when multiple callers need serialized layout-sensitive
  /// updates.
  static PostFrameTask<T> queueRun<T>(
    FutureOr<T> Function() action, {
    List<ScrollController> scrollControllers = const [],
    int maxWaitFrames = 5,
    bool waitForEndOfFrame = true,
    int endOfFramePasses = 2,
    Duration? timeout,
    PostFramePredicate? predicate,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    final entry = _QueuedPostFrameAction<T>(
      action: action,
      scrollControllers: scrollControllers,
      maxWaitFrames: maxWaitFrames,
      waitForEndOfFrame: waitForEndOfFrame,
      endOfFramePasses: endOfFramePasses,
      timeout: timeout,
      predicate: predicate,
      onError: onError,
    );
    _queue.add(entry);
    _processQueue();
    return entry.task; // Task is pre-created with its own completer.
  }

  /// Clears any queued (not yet started) tasks.
  static void clearQueue() {
    for (final q in _queue) {
      if (!q.started) {
        q.task.cancel();
        q.cancelWithResult();
      }
    }
    _queue.removeWhere((e) => !e.started);
  }

  static void _processQueue() {
    if (_queueProcessing) return;
    _queueProcessing = true;

    void next() {
      if (_queue.isEmpty) {
        _queueProcessing = false;
        return;
      }
      final current = _queue.removeAt(0);
      current.start(() => next());
    }

    next();
  }
}

/// Represents the outcome of a post-frame scheduled task.
class PostFrameResult<T> {
  final T? value;
  final bool canceled;
  final Object? error;
  final StackTrace? stackTrace;
  final int endOfFramePassesWaited;
  final int scrollMetricWaitFrames;
  final int totalFramesWaited;
  final List<ScrollController> controllers;

  const PostFrameResult({
    this.value,
    required this.canceled,
    this.error,
    this.stackTrace,
    required this.endOfFramePassesWaited,
    required this.scrollMetricWaitFrames,
    required this.totalFramesWaited,
    required this.controllers,
  });

  bool get hasError => error != null;
}

/// Handle returned by [PostFrame.run] enabling cancellation and exposing the
/// eventual [PostFrameResult].
class PostFrameTask<T> {
  final Future<PostFrameResult<T>> future;
  bool _canceled = false;
  bool get isCanceled => _canceled;
  void cancel() => _canceled = true;
  PostFrameTask(this.future);
}

/// Controller for a repeating post-frame action.
class PostFrameRepeater {
  final int? maxIterations;
  int iterations = 0;
  bool _canceled = false;
  Object? _error;
  StackTrace? _stackTrace;
  final _iterationController = StreamController<int>.broadcast();
  final _doneCompleter = Completer<void>();

  PostFrameRepeater._({this.maxIterations});

  bool get isCanceled => _canceled;
  Object? get error => _error;
  StackTrace? get stackTrace => _stackTrace;
  Stream<int> get iterationStream => _iterationController.stream;
  Future<void> get done => _doneCompleter.future;

  void cancel() {
    if (_canceled) return;
    _canceled = true;
    _complete();
  }

  void _notifyIteration() => _iterationController.add(iterations - 1);

  void _complete() {
    if (!_iterationController.isClosed) _iterationController.close();
    if (!_doneCompleter.isCompleted) _doneCompleter.complete();
  }
}

class _QueuedPostFrameAction<T> {
  final FutureOr<T> Function() action;
  final List<ScrollController> scrollControllers;
  final int maxWaitFrames;
  final bool waitForEndOfFrame;
  final int endOfFramePasses;
  final Duration? timeout;
  final PostFramePredicate? predicate;
  final void Function(Object error, StackTrace stackTrace)? onError;
  bool started = false;
  final completer = Completer<PostFrameResult<T>>();
  late final PostFrameTask<T> task = PostFrameTask<T>(completer.future);

  _QueuedPostFrameAction({
    required this.action,
    required this.scrollControllers,
    required this.maxWaitFrames,
    required this.waitForEndOfFrame,
    required this.endOfFramePasses,
    required this.timeout,
    this.predicate,
    this.onError,
  });

  void cancelWithResult() {
    if (!completer.isCompleted) {
      completer.complete(PostFrameResult<T>(
        canceled: true,
        value: null,
        endOfFramePassesWaited: 0,
        scrollMetricWaitFrames: 0,
        totalFramesWaited: 0,
        controllers: const [],
      ));
    }
  }

  void start(VoidCallback onComplete) {
    started = true;
    if (task.isCanceled) {
      completer.complete(PostFrameResult<T>(
        canceled: true,
        value: null,
        endOfFramePassesWaited: 0,
        scrollMetricWaitFrames: 0,
        totalFramesWaited: 0,
        controllers: const [],
      ));
      onComplete();
      return;
    }
    final runTask = PostFrame.run<T>(action,
        scrollControllers: scrollControllers,
        maxWaitFrames: maxWaitFrames,
        waitForEndOfFrame: waitForEndOfFrame,
        endOfFramePasses: endOfFramePasses,
        timeout: timeout,
        predicate: predicate,
        onError: onError);
    // Ensure next frame processing for queued sequence.
    WidgetsBinding.instance.scheduleFrame();
    runTask.future.then((result) {
      completer.complete(result);
      onComplete();
    }, onError: (error, stack) {
      completer.completeError(error, stack);
      onComplete();
    });
  }
}

// Private builder widget implementation used by PostFrame.builder/simpleBuilder.
class _PostFrameBuilder<T> extends StatefulWidget {
  final FutureOr<T> Function() action;
  final Widget Function(BuildContext, AsyncSnapshot<PostFrameResult<T>>)
      builder;
  final List<ScrollController> scrollControllers;
  final int maxWaitFrames;
  final bool waitForEndOfFrame;
  final int endOfFramePasses;
  final Duration? timeout;
  final bool runImmediately;

  const _PostFrameBuilder({
    required this.action,
    required this.builder,
    this.scrollControllers = const [],
    this.maxWaitFrames = 5,
    this.waitForEndOfFrame = true,
    this.endOfFramePasses = 2,
    this.timeout,
    this.runImmediately = true,
  });

  @override
  State<_PostFrameBuilder<T>> createState() => _PostFrameBuilderState<T>();
}

class _PostFrameBuilderState<T> extends State<_PostFrameBuilder<T>> {
  AsyncSnapshot<PostFrameResult<T>> _snapshot = const AsyncSnapshot.waiting();
  PostFrameTask<T>? _task;

  @override
  void initState() {
    super.initState();
    if (widget.runImmediately) _start();
  }

  void _start() {
    setState(() => _snapshot = const AsyncSnapshot.waiting());
    _task = PostFrame.run<T>(
      widget.action,
      scrollControllers: widget.scrollControllers,
      maxWaitFrames: widget.maxWaitFrames,
      waitForEndOfFrame: widget.waitForEndOfFrame,
      endOfFramePasses: widget.endOfFramePasses,
      timeout: widget.timeout,
    );
    _task!.future.then((result) {
      if (!mounted) return;
      setState(() =>
          _snapshot = AsyncSnapshot.withData(ConnectionState.done, result));
    }, onError: (error, stack) {
      if (!mounted) return;
      final result = PostFrameResult<T>(
        canceled: _task?.isCanceled ?? false,
        error: error,
        stackTrace: stack,
        value: null,
        endOfFramePassesWaited: 0,
        scrollMetricWaitFrames: 0,
        totalFramesWaited: 0,
        controllers: widget.scrollControllers,
      );
      setState(() =>
          _snapshot = AsyncSnapshot.withData(ConnectionState.done, result));
    });
  }

  @override
  void dispose() {
    _task?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _snapshot);
}
