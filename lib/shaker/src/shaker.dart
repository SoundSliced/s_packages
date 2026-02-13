import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A controller for programmatically triggering shake animations.
///
/// Use with [Shaker] by passing a [ShakeController] instance.
/// Call [shake] to trigger the animation and [stop] to cancel it.
class ShakeController extends ChangeNotifier {
  bool _isShaking = false;

  /// Whether a shake is currently active.
  bool get isShaking => _isShaking;

  /// Triggers a shake animation.
  void shake() {
    _isShaking = true;
    notifyListeners();
  }

  /// Stops the current shake animation.
  void stop() {
    _isShaking = false;
    notifyListeners();
  }
}

/// A widget that applies a shake animation effect to its child.
///
/// The [Shaker] widget wraps a child widget and can trigger a shake animation
/// when [isShaking] is true or via a [ShakeController].
///
/// Example:
/// ```dart
/// Shaker(
///   isShaking: true,
///   duration: Duration(milliseconds: 1000),
///   child: Text('Shake me!'),
/// )
/// ```
///
/// With controller:
/// ```dart
/// final controller = ShakeController();
/// Shaker(
///   controller: controller,
///   child: Text('Shake me!'),
/// )
/// // Later:
/// controller.shake();
/// ```
class Shaker extends StatefulWidget {
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

  /// Optional controller for programmatic shake triggering.
  final ShakeController? controller;

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
    this.controller,
  });

  @override
  State<Shaker> createState() => _ShakerState();
}

class _ShakerState extends State<Shaker> {
  bool _controllerShaking = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerChanged);
    _controllerShaking = widget.controller?.isShaking ?? false;
  }

  @override
  void didUpdateWidget(covariant Shaker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
      _controllerShaking = widget.controller?.isShaking ?? false;
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        _controllerShaking = widget.controller?.isShaking ?? false;
      });
    }
  }

  bool get _shouldShake => widget.isShaking || _controllerShaking;

  @override
  Widget build(BuildContext context) {
    return widget.child.animate(
      effects: _shouldShake
          ? [
              ShakeEffect(
                duration: widget.duration ?? const Duration(milliseconds: 1500),
                curve: widget.curve ?? Curves.easeInOut,
                hz: widget.hz ?? 4,
                rotation: widget.rotation ?? -0.03,
                offset: widget.offset ?? const Offset(0.2, 0.5),
              ),
            ]
          : null,
      onComplete: (controller) {
        widget.controller?.stop();
        widget.onComplete?.call();
      },
    );
  }
}
