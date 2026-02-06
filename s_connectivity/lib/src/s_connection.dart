import 'dart:async';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:sizer/sizer.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';

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

  /// Current connectivity state.
  ///
  /// This reads from the internal ValueNotifier (single source of truth).
  static bool get isConnected => _connectionNotifier.value;

  /// Preferred listener for new code.
  ///
  /// Example:
  /// `ValueListenableBuilder(valueListenable: AppInternetConnectivity.listenable, ...)`
  static ValueListenable<bool> get listenable => _connectionNotifier;
  static StreamSubscription<InternetStatus>? _onConnectivityChangedSubs;

  static Future<void> initialiseInternetConnectivityListener({
    VoidCallback? onConnected,
    VoidCallback? onDisconnected,
    bool showDebugLog = false,
    bool emitInitialStatus = false,
  }) async {
    // Touch debug revision so it's not tree-shaken during analysis.
    // ignore: avoid_print
    if (showDebugLog) {
      _showDebugPrint = true;
      debugPrint('AppInternetConnectivity revision=$_debugApiRevision');
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
      } catch (e) {
        debugPrint('Error in onConnected callback: $e');
      }
    } else {
      if (_showDebugPrint) {
        debugPrint("🔴 Offline");
      }
      try {
        _onDisconnectedCallback?.call();
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
}

///**************************************************** */

class NoInternetConnectionPopup extends StatelessWidget {
  const NoInternetConnectionPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        //background overlay
        Box(
          height: 100.h,
          width: 100.w,
          color: Colors.red.shade900.withValues(alpha: 0.3),
          child: Container(),
        ),

        // Popup
        //
        // Important (Flutter Web): avoid external ticker-driven animations here.
        // During hot restart / view detach, ticker frames can outlive the view and
        // trigger "Trying to render a disposed EngineFlutterView".
        //
        // These implicit animations are driven by the widget tree and stop when
        // the subtree is removed.
        AnimatedSlide(
          offset: const Offset(0, 0.20),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInBack,
          child: AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: Container(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "Offline ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        "No Internet connection",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
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
