import 'package:flutter/material.dart';
import 'package:soundsliced_tween_animation_builder/soundsliced_tween_animation_builder.dart';

class Glow1 extends StatefulWidget {
  /// The child widget that will have the glow effect
  final Widget child;

  /// Whether the glow effect is enabled
  final bool isEnabled;

  /// Maximum opacity of the glow effect (0.0 to 1.0)
  final double opacity;

  /// Color of the glow effect
  final Color? color;

  /// Whether the animation should repeat continuously
  final bool repeatAnimation;

  /// Border radius for the glow effect
  final BorderRadiusGeometry? borderRadius;

  /// Alignment of the stack
  final AlignmentGeometry alignment;

  /// Duration of the glow animation
  final Duration animationDuration;

  /// Animation curve for the glow effect
  final Curve animationCurve;

  /// Blur radius for the glow effect
  final double startScaleRadius, endScaleRadius;

  const Glow1({
    super.key,
    required this.child,
    this.isEnabled = true,
    this.opacity = 0.4,
    this.color,
    this.alignment = Alignment.center,
    this.borderRadius,
    this.repeatAnimation = true,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.animationCurve = Curves.fastEaseInToSlowEaseOut,
    this.startScaleRadius = 1.08,
    this.endScaleRadius = 1.1,
  }) : assert(opacity >= 0.0 && opacity <= 1.0,
            'glowOpacity must be between 0.0 and 1.0');

  @override
  State<Glow1> createState() => _Glow1State();
}

class _Glow1State extends State<Glow1> {
  double _animationValue = 0.0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEnabled) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(Glow1 oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isEnabled != oldWidget.isEnabled) {
      if (widget.isEnabled) {
        _startAnimation();
      } else {
        setState(() {
          _isAnimating = false;
          _animationValue = 0.0;
        });
      }
    }
  }

  void _startAnimation() {
    if (!_isAnimating && mounted) {
      setState(() {
        _isAnimating = true;
        _animationValue = 1.0;
      });
    }
  }

  void _onAnimationEnd() {
    if (!mounted) return;

    if (widget.repeatAnimation && widget.isEnabled) {
      // Restart animation after a brief delay
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && widget.isEnabled) {
          setState(() {
            _animationValue = 0.0;
          });
          // Trigger restart
          Future.microtask(() {
            if (mounted && widget.isEnabled) {
              setState(() {
                _animationValue = 1.0;
              });
            }
          });
        }
      });
    } else {
      setState(() {
        _isAnimating = false;
      });
    }
  }

  double _calculateScale(double t) {
    // Breathing effect: go up then back down
    if (t < 0.5) {
      return widget.startScaleRadius +
          (widget.endScaleRadius - widget.startScaleRadius) * (t * 2);
    } else {
      return widget.endScaleRadius -
          (widget.endScaleRadius - widget.startScaleRadius) * ((t - 0.5) * 2);
    }
  }

  double _calculateOpacity(double t) {
    // Fade in, peak, then fade out
    if (t < 0.2) {
      return (widget.opacity * 0.3) * (t / 0.2);
    } else if (t < 0.5) {
      double localT = (t - 0.2) / 0.3;
      return widget.opacity * 0.3 + (widget.opacity * 0.7) * localT;
    } else if (t < 0.75) {
      double localT = (t - 0.5) / 0.25;
      return widget.opacity - (widget.opacity * 0.3) * localT;
    } else {
      double localT = (t - 0.75) / 0.25;
      return widget.opacity * 0.7 * (1.0 - localT);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) {
      return widget.child;
    }

    return STweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: _animationValue),
      duration: widget.animationDuration,
      curve: Curves.easeInOut,
      onEnd: _onAnimationEnd,
      autoRepeat: widget.repeatAnimation,
      builder: (context, value, child) {
        final scale = _calculateScale(value);
        final opacity = _calculateOpacity(value);

        return SizedBox.fromSize(
          size: null,
          child: Stack(
            fit: StackFit.passthrough,
            clipBehavior: Clip.hardEdge,
            children: [
              widget.child,
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: Align(
                    alignment: widget.alignment,
                    child: Transform.scale(
                      scaleX: scale * 1.1,
                      scaleY: scale * 1.13,
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.color ?? Colors.blue.shade400,
                            borderRadius: widget.borderRadius ??
                                BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: (widget.color ?? Colors.blue.shade400)
                                    .withValues(alpha: opacity * 0.8),
                                blurRadius: 8.0,
                                spreadRadius: 2.0,
                              ),
                              BoxShadow(
                                color: (widget.color ?? Colors.blue.shade400)
                                    .withValues(alpha: opacity * 0.4),
                                blurRadius: 16.0,
                                spreadRadius: 4.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
