import 'dart:developer';
import 'package:flutter/material.dart';

import '../states_rebuilder_extended.dart';

/// Central tag registry to support tag-based selective rebuilds across
/// nullable and non-nullable Injected extensions.
class _TagRegistry {
  static final Map<Injected<dynamic>, String?> _tags =
      <Injected<dynamic>, String?>{};

  static void set(Injected<dynamic> inj, String? tag) {
    _tags[inj] = tag;
  }

  static void clear(Injected<dynamic> inj) {
    _tags.remove(inj);
  }

  static String? get(Injected<dynamic> inj) => _tags[inj];
}

/// Lightweight access to current tag for any Injected instance in this library.
extension _TagAccess on Injected<dynamic> {
  String? get currentNotificationTag => _TagRegistry.get(this);
}

/// Internal static widgets & cached factories used by the builder extensions.
class _StaticBuilderWidgets {
  static const waitingWidget = Center(child: CircularProgressIndicator());
  static const emptyWidget = SizedBox.shrink();
  static const errorTextStyle = TextStyle(color: Colors.red);

  static final Map<String, Widget> _errorWidgetCache = <String, Widget>{};

  static Widget getErrorWidget(dynamic error) {
    final errorString = 'Error: $error';
    return _errorWidgetCache.putIfAbsent(
      errorString,
      () => Text(errorString, style: errorTextStyle),
    );
  }
}

/// Predicate type used to decide whether widgets should rebuild.
typedef ShouldRebuild = bool Function(
  SnapState<dynamic> oldSnap,
  SnapState<dynamic> newSnap,
);

/// Extension on `Injected<T?>` adding safer update & rich builder helpers.
extension StateRebuilderExtension<T extends Object> on Injected<T?> {
  /// Safer update for nullable injected types.
  /// Always specify the generic parameter explicitly matching `T?`.
  void update<R extends T?>(
    dynamic Function(R s) mutator, {
    bool shouldNotify = true,
    String? tag,
  }) {
    final bool rIsNullable = null is R;
    assert(rIsNullable == true,
        'Type mismatch: update<$R> called on Injected<$T?>. The type parameter must be nullable (T?).');

    final R stateAsR = state as R; // cast current state for mutator
    final result = mutator(stateAsR);

    if (result is T || result == null) {
      try {
        state = result;
      } catch (e) {
        log('StateRebuilderExtension.update error: $e');
      }
      if (shouldNotify && WidgetsBinding.instance.isRootWidgetAttached) {
        _TagRegistry.set(this, tag);
        notify();
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _TagRegistry.clear(this));
      }
    }
  }

  /// Simple builder without passing state.
  Widget builder(
    Widget Function() builder, {
    void Function()? initState,
    void Function(SnapState<T?> state)? onSetState,
    void Function()? onAfterBuild,
    void Function()? dispose,
    ShouldRebuild? shouldRebuild,
    Object? Function()? watch,
    String? debugPrintWhenRebuild,
    String? tag,
  }) {
    SideEffects<T?>? sideEffects;
    if (initState != null ||
        onSetState != null ||
        onAfterBuild != null ||
        dispose != null) {
      sideEffects = SideEffects<T?>(
        initState: initState,
        onSetState: onSetState,
        onAfterBuild: onAfterBuild,
        dispose: dispose,
      );
    }

    return OnBuilder<T?>(
      listenTo: this,
      sideEffects: sideEffects,
      shouldRebuild: (oldSnap, newSnap) {
        final currentTag = currentNotificationTag;
        if (tag != null && currentTag != null && tag != currentTag) {
          return false;
        }
        return shouldRebuild?.call(oldSnap, newSnap) ?? true;
      },
      watch: watch,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
      builder: builder,
    );
  }

  /// Builder that exposes `SnapState`.
  Widget builderState(
    Widget Function(SnapState<T?> state) builder, {
    void Function()? initState,
    void Function(SnapState<T?> state)? onSetState,
    void Function()? onAfterBuild,
    void Function()? dispose,
    ShouldRebuild? shouldRebuild,
    Object? Function()? watch,
    String? debugPrintWhenRebuild,
    String? tag,
  }) {
    SideEffects<T?>? sideEffects = SideEffects<T?>(
      initState: initState,
      onSetState: onSetState,
      onAfterBuild: onAfterBuild,
      dispose: dispose,
    );

    return OnBuilder<T?>(
      listenTo: this,
      sideEffects: sideEffects,
      shouldRebuild: (oldSnap, newSnap) {
        final currentTag = currentNotificationTag;
        if (tag != null && currentTag != null && tag != currentTag) {
          return false;
        }
        return shouldRebuild?.call(oldSnap, newSnap) ?? true;
      },
      watch: watch,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
      builder: () => builder(snapState),
    );
  }

  /// Data builder handling waiting/error/data states uniformly.
  Widget builderData<R>(
    Widget Function(R data) builder, {
    Widget Function()? onWaiting,
    Widget Function(dynamic error)? onError,
    void Function()? initState,
    void Function(SnapState<T?> state)? onSetState,
    void Function(R data)? onSetStateData,
    void Function()? onAfterBuild,
    void Function()? dispose,
    bool Function(SnapState<dynamic>, SnapState<dynamic>)? shouldRebuild,
    Object? Function()? watch,
    String? debugPrintWhenRebuild,
    String? tag,
  }) {
    SideEffects<T?>? sideEffects;
    if (initState != null ||
        onSetState != null ||
        onAfterBuild != null ||
        onSetStateData != null ||
        dispose != null) {
      void Function(SnapState<T?> state)? onBuilderSetState;
      if (onSetState != null || onSetStateData != null) {
        onBuilderSetState = (SnapState<T?> state) {
          onSetState?.call(state);
          if (onSetStateData != null) {
            final data = state.data;
            if (data is R || (data == null && null is R)) {
              onSetStateData(data as R);
            }
          }
        };
      }
      sideEffects = SideEffects<T?>(
        initState: initState,
        onSetState: onBuilderSetState,
        onAfterBuild: onAfterBuild,
        dispose: dispose,
      );
    }

    return OnBuilder<T?>(
      listenTo: this,
      sideEffects: sideEffects,
      shouldRebuild: (oldSnap, newSnap) {
        final currentTag = currentNotificationTag;
        if (tag != null && currentTag != null && tag != currentTag) {
          return false;
        }
        return shouldRebuild?.call(oldSnap, newSnap) ?? true;
      },
      watch: watch,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
      builder: () {
        final state = snapState;
        if (state.isWaiting) {
          return onWaiting?.call() ?? _StaticBuilderWidgets.waitingWidget;
        }
        if (state.hasError) {
          return onError?.call(state.snapError) ??
              _StaticBuilderWidgets.getErrorWidget(state.snapError);
        }
        final data = state.data;
        if (data is R ||
            (data == null && null is R) ||
            (data != null && R == Object)) {
          return builder(data as R);
        }
        return _StaticBuilderWidgets.emptyWidget;
      },
    );
  }
}

/// Extension for non-nullable injected instances.
extension NonNullableStateRebuilderExtension<T extends Object> on Injected<T> {
  void update<R extends T>(
    dynamic Function(R s) mutator, {
    bool shouldNotify = true,
    String? tag,
  }) {
    assert(R == T,
        'Type mismatch: update<$R> called on Injected<$T>. The type parameter must match exactly (no subtype).');
    final R stateAsR = state as R;
    final result = mutator(stateAsR);
    if (result is T) {
      try {
        state = result;
      } catch (_) {}
    }
    if (shouldNotify && WidgetsBinding.instance.isRootWidgetAttached) {
      _TagRegistry.set(this, tag);
      notify();
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _TagRegistry.clear(this));
    }
  }
}

/// Boolean helpers for nullable boolean injected instances.
extension BooleanStateRebuilderExtension on Injected<bool?> {
  /// Toggles the boolean state, defaulting to false if null.
  void toggle({bool shouldNotify = true, String? tag}) {
    state = !(state ?? false);
    if (shouldNotify && WidgetsBinding.instance.isRootWidgetAttached) {
      _TagRegistry.set(this, tag);
      notify();
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _TagRegistry.clear(this));
    }
  }
}

/// Boolean helpers for non-nullable boolean injected instances.
extension NonNullableBooleanStateRebuilderExtension on Injected<bool> {
  void toggle({bool shouldNotify = true, String? tag}) {
    state = !state;
    if (shouldNotify && WidgetsBinding.instance.isRootWidgetAttached) {
      _TagRegistry.set(this, tag);
      notify();
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _TagRegistry.clear(this));
    }
  }
}

/// Safe refresh helper to ignore disposed exceptions.
extension SafeRefresh on Injected<dynamic> {
  void safeRefresh() {
    try {
      refresh();
    } catch (e) {
      assert(() {
        // ignore: avoid_print
        print('safeRefresh ignored: $e');
        return true;
      }());
    }
  }
}

/// Mixin forcing a widget to rebuild on hot reload (useful for web).
mixin RebuildOnHotReloadMixin<T extends StatefulWidget> on State<T> {
  @override
  void reassemble() {
    super.reassemble();
    if (mounted) {
      setState(() {});
    }
  }
}

/// Extension for performing operations on multiple injected instances.
extension MultipleStateRebuilderExtension on List<Injected<dynamic>> {
  void update<R>(
    dynamic Function(R state) mutator, {
    int index = 0,
    bool shouldNotify = true,
    String? tag,
  }) {
    assert(isNotEmpty, 'Cannot update an empty list of injected instances');
    if (isEmpty) {
      throw StateError('Cannot update an empty list of injected instances');
    }
    if (index < 0 || index >= length) {
      throw RangeError.index(index, this, 'index', 'Index out of bounds');
    }

    final injected = this[index];
    if (injected.state is R) {
      final R currentState = injected.state as R;
      final result = mutator(currentState);
      if (result != null) {
        injected.state = result;
      }
    }
    if (shouldNotify && WidgetsBinding.instance.isRootWidgetAttached) {
      for (final inj in this) {
        _TagRegistry.set(inj, tag);
      }
      for (final inj in this) {
        inj.notify();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final inj in this) {
          _TagRegistry.clear(inj);
        }
      });
    }
  }

  void updateAll<R>(
    dynamic Function(R state) mutator, {
    bool shouldNotify = true,
    String? tag,
  }) {
    assert(
        isNotEmpty, 'Cannot updateAll on an empty list of injected instances');
    if (isEmpty) {
      throw StateError(
          'Cannot updateAll on an empty list of injected instances');
    }
    for (int i = 0; i < length; i++) {
      final injected = this[i];
      assert(injected.state is R,
          'All injected instances must be of type $R. Instance at index $i has type ${injected.state.runtimeType}');
    }
    for (final injected in this) {
      final R currentState = injected.state as R;
      final result = mutator(currentState);
      if (result != null) {
        injected.state = result;
      }
    }
    if (shouldNotify && WidgetsBinding.instance.isRootWidgetAttached) {
      for (final injected in this) {
        _TagRegistry.set(injected, tag);
      }
      for (final injected in this) {
        injected.notify();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final injected in this) {
          _TagRegistry.clear(injected);
        }
      });
    }
  }

  void notify({String? tag}) {
    assert(isNotEmpty, 'Cannot notify an empty list of injected instances');
    if (isEmpty) {
      throw StateError('Cannot notify an empty list of injected instances');
    }
    if (WidgetsBinding.instance.isRootWidgetAttached) {
      for (final injected in this) {
        _TagRegistry.set(injected, tag);
      }
      for (final injected in this) {
        injected.notify();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final injected in this) {
          _TagRegistry.clear(injected);
        }
      });
    }
  }

  /// Builds a widget that listens to all injected instances in this list.
  Widget builder(
    Widget Function() builder, {
    void Function()? initState,
    void Function()? onAfterBuild,
    void Function()? dispose,
    ShouldRebuild? shouldRebuild,
    Object? Function()? watch,
    String? debugPrintWhenRebuild,
    String? tag,
  }) {
    final observables = this;
    SideEffects<dynamic>? sideEffects;
    if (initState != null || onAfterBuild != null || dispose != null) {
      sideEffects = SideEffects<dynamic>(
        initState: initState,
        onAfterBuild: onAfterBuild,
        dispose: dispose,
      );
    }
    return OnBuilder<dynamic>(
      listenToMany: observables,
      sideEffects: sideEffects,
      shouldRebuild: (oldSnap, newSnap) {
        bool shouldRebuildBasedOnTag = true;
        if (tag != null) {
          shouldRebuildBasedOnTag = any((injected) {
            final currentTag = injected.currentNotificationTag;
            return currentTag == null || tag == currentTag;
          });
          if (!shouldRebuildBasedOnTag) {
            return false;
          }
        }
        return shouldRebuild?.call(oldSnap, newSnap) ?? true;
      },
      watch: watch,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
      builder: builder,
    );
  }

  Widget builderState(
    Widget Function(List<SnapState<dynamic>>) builder, {
    void Function()? initState,
    void Function()? onAfterBuild,
    void Function()? dispose,
    ShouldRebuild? shouldRebuild,
    Object? Function()? watch,
    String? debugPrintWhenRebuild,
    String? tag,
  }) {
    final observables = this;
    SideEffects<dynamic>? sideEffects;
    if (initState != null || onAfterBuild != null || dispose != null) {
      sideEffects = SideEffects<dynamic>(
        initState: initState,
        onAfterBuild: onAfterBuild,
        dispose: dispose,
      );
    }
    return OnBuilder<dynamic>(
      listenToMany: observables,
      sideEffects: sideEffects,
      shouldRebuild: (oldSnap, newSnap) {
        bool shouldRebuildBasedOnTag = true;
        if (tag != null) {
          shouldRebuildBasedOnTag = any((injected) {
            final currentTag = injected.currentNotificationTag;
            return currentTag == null || tag == currentTag;
          });
          if (!shouldRebuildBasedOnTag) {
            return false;
          }
        }
        return shouldRebuild?.call(oldSnap, newSnap) ?? true;
      },
      watch: watch,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
      builder: () {
        final states = map((injected) => injected.snapState).toList();
        return builder(states);
      },
    );
  }

  Widget builderData(
    Widget Function(List<dynamic> dataList) builder, {
    Widget Function()? onWaiting,
    Widget Function(dynamic error)? onError,
    void Function()? initState,
    void Function()? onAfterBuild,
    void Function()? dispose,
    ShouldRebuild? shouldRebuild,
    Object? Function()? watch,
    String? debugPrintWhenRebuild,
    String? tag,
  }) {
    final observables = this;
    SideEffects<dynamic>? sideEffects = SideEffects<dynamic>(
      initState: initState,
      onAfterBuild: onAfterBuild,
      dispose: dispose,
    );
    return OnBuilder<dynamic>(
      listenToMany: observables,
      sideEffects: sideEffects,
      shouldRebuild: (oldSnap, newSnap) {
        bool shouldRebuildBasedOnTag = true;
        if (tag != null) {
          shouldRebuildBasedOnTag = any((injected) {
            final currentTag = injected.currentNotificationTag;
            return currentTag == null || tag == currentTag;
          });
          if (!shouldRebuildBasedOnTag) {
            return false;
          }
        }
        return shouldRebuild?.call(oldSnap, newSnap) ?? true;
      },
      watch: watch,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
      builder: () {
        final states = map((injected) => injected.snapState).toList();
        if (states.any((s) => s.isWaiting)) {
          return onWaiting?.call() ?? _StaticBuilderWidgets.waitingWidget;
        }
        final errorState = states.firstWhere(
          (s) => s.hasError,
          orElse: () => states.first,
        );
        if (errorState.hasError) {
          return onError?.call(errorState.snapError) ??
              _StaticBuilderWidgets.getErrorWidget(errorState.snapError);
        }
        final dataList = <dynamic>[];
        for (final s in states) {
          if (s.data != null) {
            dataList.add(s.data);
          } else {
            return _StaticBuilderWidgets.emptyWidget;
          }
        }
        return builder(dataList);
      },
    );
  }

  Widget builderDataIndexed(
    Widget Function(int index, dynamic data) builder, {
    Widget Function()? onWaiting,
    Widget Function(dynamic error)? onError,
    void Function()? initState,
    void Function()? onAfterBuild,
    void Function()? dispose,
    ShouldRebuild? shouldRebuild,
    Object? Function()? watch,
    String? debugPrintWhenRebuild,
    String? tag,
  }) {
    return builderData(
      (dataList) => Column(
        children: dataList
            .asMap()
            .entries
            .map((e) => builder(e.key, e.value))
            .toList(),
      ),
      onWaiting: onWaiting,
      onError: onError,
      initState: initState,
      onAfterBuild: onAfterBuild,
      dispose: dispose,
      shouldRebuild: shouldRebuild,
      watch: watch,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
      tag: tag,
    );
  }
}

/// Quick injection helpers on any object value.
extension InjectExtension<T extends Object> on T {
  /// Injects this value as an `Injected<T>` with optional side effects.
  Injected<T> inject<R extends T>({
    bool autoDispose = true,
    void Function()? initState,
    void Function(SnapState<T> state)? onSetState,
    void Function()? onAfterBuild,
    void Function()? onDispose,
  }) {
    return RM.inject<T>(
      () => this,
      autoDisposeWhenNotUsed: autoDispose,
      sideEffects: SideEffects<T>(
        initState: initState,
        onSetState: onSetState,
        onAfterBuild: onAfterBuild,
        dispose: onDispose,
      ),
    );
  }

  /// Injects this value as an auto-disposable `Injected<T>` with optional side effects.
  Injected<T> injectDisposable({
    void Function()? initState,
    void Function(SnapState<T> state)? onSetState,
    void Function()? onAfterBuild,
    void Function()? onDispose,
  }) {
    return RM.inject<T>(
      () => this,
      autoDisposeWhenNotUsed: true,
      sideEffects: SideEffects<T>(
        initState: initState,
        onSetState: onSetState,
        onAfterBuild: onAfterBuild,
        dispose: onDispose,
      ),
    );
  }
}

/// Helper for injecting nullable values.
class MyNull {
  static Injected<T?> inject<T extends Object?>({
    bool autoDispose = true,
    void Function()? initState,
    void Function(SnapState<T?> state)? onSetState,
    void Function()? onAfterBuild,
    void Function()? onDispose,
  }) {
    return RM.inject<T?>(
      () => null,
      autoDisposeWhenNotUsed: autoDispose,
      sideEffects: SideEffects<T?>(
        initState: initState,
        onSetState: onSetState,
        onAfterBuild: onAfterBuild,
        dispose: onDispose,
      ),
    );
  }

  static Injected<T?> injectDisposable<T extends Object?>({
    void Function()? initState,
    void Function(SnapState<T?> state)? onSetState,
    void Function()? onAfterBuild,
    void Function()? onDispose,
  }) =>
      inject<T>(
        autoDispose: true,
        initState: initState,
        onSetState: onSetState,
        onAfterBuild: onAfterBuild,
        onDispose: onDispose,
      );
}
