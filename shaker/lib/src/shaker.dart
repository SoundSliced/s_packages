import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A widget that applies a shake animation effect to its child.
///
/// The [Shaker] widget wraps a child widget and can trigger a shake animation
/// when [isShaking] is true. The shake effect can be customized with various
/// parameters including duration, curve, frequency, rotation, and offset.
///
/// Example:
/// ```dart
/// Shaker(
///   isShaking: true,
///   duration: Duration(milliseconds: 1000),
///   child: Text('Shake me!'),
/// )
/// ```
class Shaker extends StatelessWidget {
  /// The widget to apply the shake effect to.
  final Widget child;

  /// Whether the shake animation should be active.
  ///
  /// When true, the shake animation will be applied to the [child].
  /// Defaults to false.
  final bool isShaking;

  /// The duration of the shake animation.
  ///
  /// If not specified, defaults to 1500 milliseconds.
  final Duration? duration;

  /// Callback function called when the shake animation completes.
  final Function? onComplete;

  /// The curve to use for the shake animation.
  ///
  /// If not specified, defaults to [Curves.easeInOut].
  final Curve? curve;

  /// The frequency of the shake in hertz (cycles per second).
  ///
  /// Higher values result in faster shaking. If not specified, defaults to 4.
  final double? hz;

  /// The rotation angle applied during the shake effect.
  ///
  /// The value is in radians. If not specified, defaults to -0.03.
  final double? rotation;

  /// The positional offset applied during the shake effect.
  ///
  /// Determines how far the widget moves during shaking.
  /// If not specified, defaults to Offset(0.2, 0.5).
  final Offset? offset;

  /// Creates a [Shaker] widget.
  ///
  /// The [child] parameter must not be null.
  const Shaker({
    super.key,
    required this.child,
    this.isShaking = false,
    this.duration,
    this.onComplete,
    this.curve,
    this.hz,
    this.rotation,
    this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return child.animate(
      effects: isShaking == true
          ? [
              ShakeEffect(
                duration: duration ?? const Duration(milliseconds: 1500),
                curve: curve ?? Curves.easeInOut,
                hz: hz ?? 4,
                rotation: rotation ?? -0.03,
                offset: offset ?? const Offset(0.2, 0.5),
              ),
            ]
          : null,
      onComplete: (controller) => onComplete?.call(),
    );
  }
}
