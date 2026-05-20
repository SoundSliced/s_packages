import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A Bounceable widget that supports both single tap and double tap
class SBounceable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final double? scaleFactor;
  final Duration? duration;
  final bool isBounceEnabled;

  /// The animation curve for the bounce effect.
  /// Defaults to [Curves.easeInOut].
  final Curve curve;

  /// Whether to trigger haptic feedback on tap.
  final bool enableHapticFeedback;

  /// When both [onTap] and [onDoubleTap] are provided, defer [onTap] until
  /// Flutter's double-tap timeout has elapsed.
  ///
  /// This prevents the first tap of a double tap from triggering single-tap
  /// state changes before [onDoubleTap] gets a chance to run.
  final bool deferTapWhenDoubleTapEnabled;

  const SBounceable({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.scaleFactor,
    this.duration,
    this.isBounceEnabled = true,
    this.curve = Curves.easeInOut,
    this.enableHapticFeedback = false,
    this.deferTapWhenDoubleTapEnabled = true,
  });

  @override
  State<SBounceable> createState() => _SBounceableState();
}

class _SBounceableState extends State<SBounceable> {
  double _scale = 1.0;

  int? _activePointer;
  Offset? _pointerDownPosition;
  bool _tapCanceledByMove = false;
  bool _longPressFired = false;

  DateTime? _lastTapAt;
  Offset? _lastTapPosition;

  bool _pendingSingleTap = false;
  VoidCallback? _pendingSingleTapCallback;
  Timer? _pendingSingleTapTimer;
  Timer? _longPressTimer;

  double get _scaleFactor => widget.scaleFactor ?? 0.95;
  Duration get _duration =>
      widget.duration ?? const Duration(milliseconds: 200);

  bool get _hasTap => widget.onTap != null;
  bool get _hasDoubleTap => widget.onDoubleTap != null;

  void _onPointerDown(PointerDownEvent event) {
    if (!mounted) return;

    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons != kPrimaryMouseButton) {
      return;
    }

    if (_activePointer != null) return;

    _activePointer = event.pointer;
    _pointerDownPosition = event.position;
    _tapCanceledByMove = false;
    _longPressFired = false;

    if (widget.isBounceEnabled) {
      setState(() {
        _scale = _scaleFactor;
      });
    }

    _startLongPressTimer();
  }

  void _startLongPressTimer() {
    _longPressTimer?.cancel();
    if (widget.onLongPress == null) return;

    _longPressTimer = Timer(kLongPressTimeout, () {
      if (!mounted || _activePointer == null || _tapCanceledByMove) return;
      _longPressFired = true;
      widget.onLongPress?.call();
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.pointer != _activePointer || _pointerDownPosition == null) return;

    final maxDistanceSquared = kTouchSlop * kTouchSlop;
    final movedTooFar =
        (event.position - _pointerDownPosition!).distanceSquared >
            maxDistanceSquared;
    if (!movedTooFar) return;

    _tapCanceledByMove = true;
    _longPressTimer?.cancel();
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!mounted) return;
    if (event.pointer != _activePointer) return;

    if (widget.isBounceEnabled) {
      setState(() {
        _scale = 1.0;
      });
    }

    _longPressTimer?.cancel();

    final shouldProcessTap = !_tapCanceledByMove && !_longPressFired;
    if (shouldProcessTap) {
      _handleTapUp(event.position);
    }

    _activePointer = null;
    _pointerDownPosition = null;
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!mounted) return;
    if (event.pointer != _activePointer) return;

    if (widget.isBounceEnabled) {
      setState(() {
        _scale = 1.0;
      });
    }

    _longPressTimer?.cancel();
    _activePointer = null;
    _pointerDownPosition = null;
  }

  void _handleTapUp(Offset position) {
    if (!_hasTap && !_hasDoubleTap) return;

    if (_hasDoubleTap) {
      final now = DateTime.now();
      final maxDistanceSquared = kDoubleTapSlop * kDoubleTapSlop;
      final isDoubleTap = _lastTapAt != null &&
          _lastTapPosition != null &&
          now.difference(_lastTapAt!) <= kDoubleTapTimeout &&
          (position - _lastTapPosition!).distanceSquared <= maxDistanceSquared;

      if (isDoubleTap) {
        _lastTapAt = null;
        _lastTapPosition = null;
        _cancelPendingSingleTap();
        _handleDoubleTap();
        return;
      }

      _lastTapAt = now;
      _lastTapPosition = position;

      if (_hasTap) {
        if (widget.deferTapWhenDoubleTapEnabled) {
          _schedulePendingSingleTap();
        } else {
          _runTapCallback();
        }
      }
      return;
    }

    _runTapCallback();
  }

  void _schedulePendingSingleTap() {
    _cancelPendingSingleTap();

    _pendingSingleTap = true;
    _pendingSingleTapCallback = _runTapCallback;
    _pendingSingleTapTimer = Timer(
      kDoubleTapTimeout + const Duration(milliseconds: 1),
      () {
        if (!_pendingSingleTap) return;

        _pendingSingleTap = false;
        final pendingCallback = _pendingSingleTapCallback;
        _pendingSingleTapCallback = null;
        pendingCallback?.call();
      },
    );
  }

  void _cancelPendingSingleTap() {
    _pendingSingleTapTimer?.cancel();
    _pendingSingleTapTimer = null;
    _pendingSingleTap = false;
    _pendingSingleTapCallback = null;
  }

  void _handleDoubleTap() {
    _cancelPendingSingleTap();
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onDoubleTap?.call();
  }

  void _runTapCallback() {
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _pendingSingleTapTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: AnimatedScale(
        scale: widget.isBounceEnabled ? _scale : 1.0,
        duration: _duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }
}
