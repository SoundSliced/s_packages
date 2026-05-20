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
  DateTime? _lastPointerDownAt;
  Offset? _lastPointerDownPosition;
  bool _suppressNextTap = false;
  bool _pendingSingleTap = false;
  VoidCallback? _pendingSingleTapCallback;

  double get _scaleFactor => widget.scaleFactor ?? 0.95;
  Duration get _duration =>
      widget.duration ?? const Duration(milliseconds: 200);

  bool get _shouldArbitrateTapAndDoubleTap =>
      widget.onTap != null &&
      widget.onDoubleTap != null &&
      widget.deferTapWhenDoubleTapEnabled;

  bool get _useGestureDoubleTapRecognizer =>
      widget.onDoubleTap != null && !_shouldArbitrateTapAndDoubleTap;

  bool get _useManualPointerDoubleTap =>
      widget.onDoubleTap != null &&
      (_shouldArbitrateTapAndDoubleTap || !widget.deferTapWhenDoubleTapEnabled);

  void _onPointerDown(PointerDownEvent event) {
    if (!mounted) return;
    if (widget.isBounceEnabled) {
      setState(() {
        _scale = _scaleFactor;
      });
    }

    if (_useManualPointerDoubleTap) {
      _detectDoubleTapFromPointerDown(event);
    }
  }

  void _detectDoubleTapFromPointerDown(PointerDownEvent event) {
    if (widget.onDoubleTap == null) return;

    final now = DateTime.now();
    final lastAt = _lastPointerDownAt;
    final lastPosition = _lastPointerDownPosition;
    final maxDistanceSquared = kDoubleTapSlop * kDoubleTapSlop;
    final isDoubleTap = lastAt != null &&
        lastPosition != null &&
        now.difference(lastAt) <= kDoubleTapTimeout &&
        (event.position - lastPosition).distanceSquared <= maxDistanceSquared;

    _lastPointerDownAt = now;
    _lastPointerDownPosition = event.position;

    if (!isDoubleTap) return;

    _lastPointerDownAt = null;
    _lastPointerDownPosition = null;
    _suppressNextTap = true;
    _handleDoubleTap();
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!mounted) return;
    if (widget.isBounceEnabled) {
      setState(() {
        _scale = 1.0;
      });
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!mounted) return;
    if (widget.isBounceEnabled) {
      setState(() {
        _scale = 1.0;
      });
    }
  }

  void _handleTap() {
    if (_suppressNextTap) {
      _suppressNextTap = false;
      return;
    }

    if (_shouldArbitrateTapAndDoubleTap) {
      // Defer single tap until double-tap timeout expires.
      _pendingSingleTap = true;
      _pendingSingleTapCallback = _runTapCallback;
      Future.delayed(kDoubleTapTimeout + const Duration(milliseconds: 1), () {
        if (_pendingSingleTap) {
          _pendingSingleTap = false;
          final pendingCallback = _pendingSingleTapCallback;
          _pendingSingleTapCallback = null;
          pendingCallback?.call();
        }
      });
    } else {
      _runTapCallback();
    }
  }

  void _handleDoubleTap() {
    if (_pendingSingleTap) {
      // Cancel pending single tap if double tap detected.
      _pendingSingleTap = false;
      _pendingSingleTapCallback = null;
    }
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
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onTap != null ? _handleTap : null,
        onDoubleTap: _useGestureDoubleTapRecognizer ? _handleDoubleTap : null,
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: widget.isBounceEnabled ? _scale : 1.0,
          duration: _duration,
          curve: widget.curve,
          child: widget.child,
        ),
      ),
    );
  }
}
