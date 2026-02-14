import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:s_packages/s_modal/src/s_modal_libs.dart';
import 'package:s_packages/soundsliced_dart_extensions/src/dart_extensions.dart';

ValueNotifier<bool> _connectionNotifier = ValueNotifier<bool>(false);

class AppInternetConnectivity {
  // Increment when debugging web hot-restart issues to ensure you are running
  // the latest compiled JS.
  static const int _debugApiRevision = 1;
  static bool _isDisposed = false;
  static int _generation = 0;
  static VoidCallback? _onConnectedCallback;
  static VoidCallback? _onDisconnectedCallback;
  static bool _showDebugPrint = false;
  // Simple, synchronous dedupe of noisy status events.
  // No timers/futures: we only react when the value actually changes.
  static bool? _lastEmitted;
  static bool _showNoInternetSnackbar = false;

  /// Current connectivity state.
  ///
  /// This reads from the internal ValueNotifier (single source of truth).
  static bool get isConnected => _connectionNotifier.value;

  /// Preferred listener for new code.
  ///
  /// Example:
  /// `ValueListenableBuilder(valueListenable: AppInternetConnectivity.listenable, ...)`
  static ValueListenable<bool> get listenable => _connectionNotifier;

  static NoInternetSnackbar _noInternetSnackbar = NoInternetSnackbar(
    dismissBarrierColor: Colors.red.shade200.withValues(alpha: 0.5),
    snackBackgroundColor: Colors.red.shade900,
    prefixIcon: Icons.wifi_off,
    snackMessage: "No Internet Connection",
  );

  /// Whether the no-internet snackbar overlay is enabled.
  static set showNoInternetSnackbar(bool value) {
    _showNoInternetSnackbar = value;
    if (!value) {
      // Dismiss any active snackbar when disabled
      Modal.dismissById("_NoInternetConnectionSnack_");
    } else if (!isConnected) {
      // Show snackbar immediately if currently offline
      toggleConnectivitySnackbar(false);
    }
  }

  static StreamSubscription<InternetStatus>? _onConnectivityChangedSubs;

  static Future<void> initialiseInternetConnectivityListener({
    VoidCallback? onConnected,
    VoidCallback? onDisconnected,
    bool showDebugLog = false,
    bool showNoInternetSnackbar = false,
    NoInternetSnackbar? customNoInternetSnackbar,
    bool emitInitialStatus = false,
  }) async {
    // Touch debug revision so it's not tree-shaken during analysis.
    // ignore: avoid_print
    if (showDebugLog) {
      _showDebugPrint = true;
      debugPrint('AppInternetConnectivity revision=$_debugApiRevision');
    }

    // if the user wants to show the no internet snackbar (or to show their own custom one)
    if (showNoInternetSnackbar || customNoInternetSnackbar != null) {
      _showNoInternetSnackbar = true;

      if (customNoInternetSnackbar != null) {
        _noInternetSnackbar = customNoInternetSnackbar;
      }
    }

    // Allow re-initialization safely.
    _isDisposed = false;
    final int myGeneration = ++_generation;

    // Hard reset internal notifier on every init.
    // On Flutter Web hot restart, keeping the same notifier instance can leave
    // old listeners dangling across EngineFlutterView teardown.
    final previous = _connectionNotifier;
    final initialValue = previous.value;
    _connectionNotifier = ValueNotifier<bool>(initialValue);
    // Best-effort cleanup: dispose old notifier to detach listeners.
    try {
      previous.dispose();
    } catch (_) {}

    _onConnectedCallback = onConnected;
    _onDisconnectedCallback = onDisconnected;
    // Keep both sources in sync.
    _lastEmitted = _connectionNotifier.value;

    await _onConnectivityChangedSubs?.cancel();

    _onConnectivityChangedSubs = InternetConnection().onStatusChange.listen(
      (status) {
        // Ignore callbacks from an older subscription after hot restart/reinit.
        if (_isDisposed || myGeneration != _generation) return;
        _handleConnectivityChange(status == InternetStatus.connected);
      },
      onError: (Object e, StackTrace st) {
        // Avoid throwing from stream zone; just log.
        debugPrint('Connectivity stream error: $e');
      },
    );

    if (emitInitialStatus) {
      // No Futures/Timers: simply emit the currently known state.
      // If you need a real probe, call `emitCurrentStateNow()` from your app
      // after your UI is stable.
      emitCurrentStateNow();
    }
  }

  /// Emits callbacks for the currently known state.
  ///
  /// This does not perform any network probing. It simply triggers
  /// `onConnected`/`onDisconnected` for the current `isConnected` value.
  static void emitCurrentStateNow() {
    if (_isDisposed) return;
    _triggerCallback(isConnected);
  }

  /// Forcefully reset everything (useful for Flutter Web hot restart).
  ///
  /// Cancels the stream subscription, drops callbacks, and recreates the
  /// ValueNotifier to detach any stale listeners.
  static Future<void> hardReset() async {
    _generation++;
    _isDisposed = true;
    _lastEmitted = null;
    _onConnectedCallback = null;
    _onDisconnectedCallback = null;
    await _onConnectivityChangedSubs?.cancel();
    _onConnectivityChangedSubs = null;

    final previous = _connectionNotifier;
    final initialValue = previous.value;
    _connectionNotifier = ValueNotifier<bool>(initialValue);
    try {
      previous.dispose();
    } catch (_) {}
  }

  static void _handleConnectivityChange(bool newState) {
    if (_isDisposed) return;

    // Guard against duplicate emissions from the stream.
    if (_lastEmitted == newState) return;

    // Update state synchronously.
    try {
      _connectionNotifier.value = newState;
      _lastEmitted = newState;
      _triggerCallback(newState);
    } catch (e) {
      debugPrint('Error updating connectivity: $e');
    }
  }

  static void _triggerCallback(bool isConnected) {
    if (isConnected) {
      if (_showDebugPrint) {
        debugPrint("🟢 Online");
      }
      try {
        _onConnectedCallback?.call();

        toggleConnectivitySnackbar(true);
      } catch (e) {
        debugPrint('Error in onConnected callback: $e');
      }
    } else {
      if (_showDebugPrint) {
        debugPrint("🔴 Offline");
      }
      try {
        _onDisconnectedCallback?.call();
        if (_showNoInternetSnackbar) {
          toggleConnectivitySnackbar(false);
        }
      } catch (e) {
        debugPrint('Error in onDisconnected callback: $e');
      }
    }
  }

  static Future<void> disposeInternetConnectivityListener() async {
    _isDisposed = true;
    _lastEmitted = null;
    _onConnectedCallback = null;
    _onDisconnectedCallback = null;
    await _onConnectivityChangedSubs?.cancel();
    _onConnectivityChangedSubs = null;
  }

  //
  static void toggleConnectivitySnackbar(
    bool status,
  ) {
    if (status == false) {
      Modal.showSnackbar(
        id: "_NoInternetConnectionSnack_",
        barrierColor: _noInternetSnackbar.dismissBarrierColor,
        backgroundColor: _noInternetSnackbar.snackBackgroundColor,
        text: _noInternetSnackbar.snackMessage,
        isDismissible: false,
        showDurationTimer: false,
        showCloseIcon: false,
        displayMode: SnackbarDisplayMode.staggered,
        prefixIcon: _noInternetSnackbar.prefixIcon,
      );
    } else {
      Modal.dismissById("_NoInternetConnectionSnack_");
    }
  }
}

/// A convenience wrapper that sets up the Modal overlay system so that
/// [AppInternetConnectivity]'s "No Internet" snackbar (and any other
/// [Modal] features) work without the user having to know about
/// [Modal.appBuilder].
///
/// **Safe to use even if you already wrap with `Modal.appBuilder`.**
/// [Modal.appBuilder] is idempotent — calling it more than once simply
/// returns the child as-is, so no double-nesting can occur.
///
/// ## Usage
///
/// **Option 1 – static builder (simplest, replaces `Modal.appBuilder`):**
/// ```dart
/// MaterialApp(
///   builder: SConnectivityOverlay.appBuilder,
///   home: MyHomePage(),
/// )
/// ```
///
/// **Option 2 – widget wrapper (if you need to chain multiple builders or
/// customise Modal parameters):**
/// ```dart
/// MaterialApp(
///   builder: (context, child) {
///     return SConnectivityOverlay(
///       child: child!,
///     );
///   },
///   home: MyHomePage(),
/// )
/// ```
///
/// **Option 3 – used alongside an existing `Modal.appBuilder` (safe):**
/// ```dart
/// MaterialApp(
///   builder: (context, child) {
///     // Either order is fine — Modal.appBuilder is idempotent.
///     child = Modal.appBuilder(context, child);
///     return SConnectivityOverlay(child: child!);
///   },
///   home: MyHomePage(),
/// )
/// ```
///
/// In all cases the full Modal system (snackbars, dialogs, sheets) is
/// available throughout the app.
class SConnectivityOverlay extends StatelessWidget {
  /// The app content to wrap.
  final Widget child;

  /// Border radius applied to the background when a sheet modal is active.
  final BorderRadius? borderRadius;

  /// Whether the modal background should bounce when the dismiss barrier
  /// is tapped.
  final bool shouldBounceOnTap;

  /// Background color visible behind the scaled app content when a sheet
  /// modal is active.
  final Color backgroundColor;

  /// Whether to print debug information for Modal events.
  final bool showDebugPrints;

  const SConnectivityOverlay({
    super.key,
    required this.child,
    this.borderRadius,
    this.shouldBounceOnTap = true,
    this.backgroundColor = Colors.black,
    this.showDebugPrints = false,
  });

  /// Drop-in replacement for [Modal.appBuilder] that can be passed directly
  /// to `MaterialApp(builder: ...)`.
  ///
  /// Safe to combine with an existing `Modal.appBuilder` — the call is
  /// idempotent and will not wrap a second time.
  ///
  /// ```dart
  /// MaterialApp(
  ///   builder: SConnectivityOverlay.appBuilder,
  ///   home: MyHomePage(),
  /// )
  /// ```
  static Widget appBuilder(BuildContext context, Widget? child) {
    assert(child != null,
        'SConnectivityOverlay.appBuilder requires a non-null child.');
    return Modal.appBuilder(context, child);
  }

  @override
  Widget build(BuildContext context) {
    return Modal.appBuilder(
      context,
      child,
      borderRadius: borderRadius,
      shouldBounceOnTap: shouldBounceOnTap,
      backgroundColor: backgroundColor,
      showDebugPrints: showDebugPrints,
    );
  }
}

/// class to enable the user to customize their own No Internet Snackbar
class NoInternetSnackbar {
  final Color dismissBarrierColor;
  final Color snackBackgroundColor;
  final String snackMessage;
  final IconData prefixIcon;
  const NoInternetSnackbar({
    required this.prefixIcon,
    required this.snackMessage,
    required this.snackBackgroundColor,
    required this.dismissBarrierColor,
  });
}

//********************************************** */

class NoInternetWidget extends StatefulWidget {
  final double size;
  final Color? backgroundColor, iconColor;
  final IconData? icon;
  final bool shouldShowWhenNoInternet;
  final bool shouldAnimate;
  const NoInternetWidget({
    super.key,
    this.size = 24,
    this.backgroundColor,
    this.iconColor,
    this.icon,
    this.shouldAnimate = true,
    this.shouldShowWhenNoInternet = true,
  });

  @override
  State<NoInternetWidget> createState() => _NoInternetWidgetState();
}

class _NoInternetWidgetState extends State<NoInternetWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(NoInternetWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the shouldShowWhenNoInternet flag changed, update visibility
    if (oldWidget.shouldShowWhenNoInternet != widget.shouldShowWhenNoInternet) {
      if (mounted) {
        _updateVisibility(AppInternetConnectivity.isConnected);
      }
    }
  }

  void _updateVisibility(bool isConnected) {
    // No longer needed: visibility is derived directly from the listenable
    // in build.
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppInternetConnectivity.listenable,
      builder: (context, isConnected, _) {
        if (!widget.shouldShowWhenNoInternet) {
          return const SizedBox.shrink();
        }

        final shouldShow = !isConnected;
        if (!shouldShow) {
          return const SizedBox.shrink();
        }

        return AnimatedOpacity(
          opacity: 1.0,
          duration: widget.shouldAnimate ? 0.4.seconds : Duration.zero,
          curve: Curves.easeInOut,
          child: AnimatedSlide(
            offset: const Offset(0, -0.05),
            duration: widget.shouldAnimate ? 0.4.seconds : Duration.zero,
            curve: Curves.easeInOut,
            child: _buildIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildIndicator() {
    return Container(
      height: widget.size,
      width: widget.size,
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            Colors.deepPurpleAccent.withValues(alpha: 0.7),
        shape: BoxShape.circle,
      ),
      child: Icon(
        widget.icon ?? Icons.wifi_off_rounded,
        size: widget.size <= 15 ? 10 : widget.size - 8,
        color: widget.iconColor ?? Colors.white.withAlpha(220),
      ),
    );
  }
}
