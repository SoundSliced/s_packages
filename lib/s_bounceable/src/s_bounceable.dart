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
  });

  @override
  State<SBounceable> createState() => _SBounceableState();
}

class _SBounceableState extends State<SBounceable> {
  double _scale = 1.0;

  double get _scaleFactor => widget.scaleFactor ?? 0.95;
  Duration get _duration =>
      widget.duration ?? const Duration(milliseconds: 200);

  void _onPointerDown(PointerDownEvent event) {
    if (widget.isBounceEnabled) {
      setState(() {
        _scale = _scaleFactor;
      });
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (widget.isBounceEnabled) {
      setState(() {
        _scale = 1.0;
      });
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (widget.isBounceEnabled) {
      setState(() {
        _scale = 1.0;
      });
    }
  }

  void _handleTap() {
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: GestureDetector(
        onTap: widget.onTap != null ? _handleTap : null,
        onDoubleTap: widget.onDoubleTap,
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
