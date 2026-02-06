import 'dart:async';

import 'package:flutter/material.dart';
import 'post_frame.dart';

/// Convenient BuildContext extensions for PostFrame operations.
extension PostFrameContext on BuildContext {
  /// Schedule [action] to run after the current frame with default parameters.
  ///
  /// Includes a built-in predicate that checks if the widget is still mounted.
  Future<void> postFrame(
    FutureOr<void> Function() action, {
    List<ScrollController> scrollControllers = const [],
    int maxWaitFrames = 5,
    bool waitForEndOfFrame = true,
    int endOfFramePasses = 2,
  }) {
    return PostFrame.postFrame(
      action,
      scrollControllers: scrollControllers,
      maxWaitFrames: maxWaitFrames,
      waitForEndOfFrame: waitForEndOfFrame,
      endOfFramePasses: endOfFramePasses,
    );
  }

  /// Advanced post-frame run with context-aware mounted check predicate.
  ///
  /// Automatically includes a predicate that checks if the widget is still
  /// mounted before executing the action. You can provide an additional
  /// [predicate] that will be AND-ed with the mounted check.
  PostFrameTask<T> postFrameRun<T>(
    FutureOr<T> Function() action, {
    List<ScrollController> scrollControllers = const [],
    int maxWaitFrames = 5,
    bool waitForEndOfFrame = true,
    int endOfFramePasses = 2,
    Duration? timeout,
    PostFramePredicate? predicate,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    // Capture the element for mounted check.
    final element = this as Element;

    return PostFrame.run<T>(
      action,
      scrollControllers: scrollControllers,
      maxWaitFrames: maxWaitFrames,
      waitForEndOfFrame: waitForEndOfFrame,
      endOfFramePasses: endOfFramePasses,
      timeout: timeout,
      predicate: () {
        // Check if widget is still mounted.
        if (!element.mounted) return false;
        // Apply additional predicate if provided.
        return predicate?.call() ?? true;
      },
      onError: onError,
    );
  }

  /// Debounced post-frame run with context-aware mounted check.
  ///
  /// Similar to [postFrameRun] but with debouncing capability.
  PostFrameTask<T> postFrameDebounced<T>(
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
    // Capture the element for mounted check.
    final element = this as Element;

    return PostFrame.debounced<T>(
      action,
      debounceKey: debounceKey,
      scrollControllers: scrollControllers,
      maxWaitFrames: maxWaitFrames,
      waitForEndOfFrame: waitForEndOfFrame,
      endOfFramePasses: endOfFramePasses,
      timeout: timeout,
      predicate: () {
        // Check if widget is still mounted.
        if (!element.mounted) return false;
        // Apply additional predicate if provided.
        return predicate?.call() ?? true;
      },
      onError: onError,
    );
  }

  /// Wait for a widget's layout to stabilize using its GlobalKey.
  ///
  /// Convenience wrapper around [PostFrame.onLayout] with context access.
  Future<Size?> awaitLayout(
    GlobalKey key, {
    int maxWaitFrames = 20,
    int stabilityFrames = 2,
    bool waitForEndOfFrame = true,
  }) {
    return PostFrame.onLayout(
      key,
      maxWaitFrames: maxWaitFrames,
      stabilityFrames: stabilityFrames,
      waitForEndOfFrame: waitForEndOfFrame,
    );
  }
}

/// Common predicates for conditional PostFrame execution.
class PostFramePredicates {
  /// Returns a predicate that checks if a [BuildContext] is still mounted.
  static PostFramePredicate mounted(BuildContext context) {
    final element = context as Element;
    return () => element.mounted;
  }

  /// Returns a predicate that checks if a [State] is still mounted.
  static PostFramePredicate stateMounted(State state) {
    return () => state.mounted;
  }

  /// Returns a predicate that checks if the current route is still active.
  ///
  /// Uses [ModalRoute.of] to check if the route is current.
  static PostFramePredicate routeActive(BuildContext context) {
    return () {
      final route = ModalRoute.of(context);
      return route != null && route.isCurrent;
    };
  }

  /// Returns a predicate that checks if a [ScrollController] has clients.
  static PostFramePredicate scrollControllerHasClients(
    ScrollController controller,
  ) {
    return () => controller.hasClients;
  }

  /// Returns a predicate that checks if a [ScrollController]'s position
  /// has a certain minimum scroll extent.
  static PostFramePredicate scrollExtentAtLeast(
    ScrollController controller,
    double minExtent,
  ) {
    return () =>
        controller.hasClients &&
        controller.position.maxScrollExtent >= minExtent;
  }

  /// Returns a predicate that combines multiple predicates with AND logic.
  static PostFramePredicate all(List<PostFramePredicate> predicates) {
    return () => predicates.every((p) => p());
  }

  /// Returns a predicate that combines multiple predicates with OR logic.
  static PostFramePredicate any(List<PostFramePredicate> predicates) {
    return () => predicates.any((p) => p());
  }

  /// Returns a predicate that negates another predicate.
  static PostFramePredicate not(PostFramePredicate predicate) {
    return () => !predicate();
  }
}
