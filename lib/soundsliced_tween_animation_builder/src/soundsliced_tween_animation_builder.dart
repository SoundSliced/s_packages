import 'dart:async';

import 'package:flutter/material.dart';

/// A drop-in replacement for [TweenAnimationBuilder] that avoids relying on
/// ticker providers so it survives hot restarts without engine assertions.
class STweenAnimationBuilder<T> extends StatefulWidget {
  const STweenAnimationBuilder({
    super.key,
    required this.tween,
    required this.duration,
    required this.builder,
    this.child,
    this.curve = Curves.linear,
    this.onEnd,
    this.animationKey,
    this.autoRepeat = false,
    this.delay,
    this.repeatCount,
  });

  final Tween<T> tween;
  final Duration duration;
  final Curve curve;
  final Widget? child;
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final VoidCallback? onEnd;
  final Object? animationKey;
  final bool autoRepeat;

  /// Delay before the animation starts. Applied on initial build
  /// and each time the animation restarts (key change, repeat).
  final Duration? delay;

  /// Number of times to repeat the animation. If null and [autoRepeat]
  /// is true, repeats indefinitely. Ignored when [autoRepeat] is false.
  final int? repeatCount;

  @override
  State<STweenAnimationBuilder<T>> createState() =>
      _STweenAnimationBuilderState<T>();
}

class _STweenAnimationBuilderState<T> extends State<STweenAnimationBuilder<T>> {
  static const _frameInterval = Duration(milliseconds: 16);

  Timer? _ticker;
  Timer? _delayTimer;
  late T _currentValue;
  DateTime? _startTime;
  int _repeatsDone = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.tween.transform(widget.curve.transform(0.0));
    _startAnimation();
  }

  @override
  void didUpdateWidget(covariant STweenAnimationBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hasChangedTween = _hasTweenChanged(widget.tween, oldWidget.tween);
    final keyChanged = widget.animationKey != oldWidget.animationKey;
    final durationChanged = widget.duration != oldWidget.duration;
    final curveChanged = widget.curve != oldWidget.curve;

    if (hasChangedTween || keyChanged || durationChanged || curveChanged) {
      _repeatsDone = 0;
      _startAnimation();
      return;
    }

    if (widget.autoRepeat && !oldWidget.autoRepeat && _ticker == null) {
      _startAnimation();
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (mounted) {
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _stopAnimation();
    _delayTimer?.cancel();
    super.dispose();
  }

  bool get _canRepeat {
    if (!widget.autoRepeat) return false;
    if (widget.repeatCount == null) return true;
    return _repeatsDone < widget.repeatCount!;
  }

  void _startAnimation() {
    _stopAnimation();

    if (!mounted) {
      return;
    }

    if (widget.delay != null && widget.delay! > Duration.zero) {
      _delayTimer?.cancel();
      _delayTimer = Timer(widget.delay!, () {
        if (mounted) _startAnimationImmediate();
      });
      return;
    }

    _startAnimationImmediate();
  }

  void _startAnimationImmediate() {
    if (widget.duration <= Duration.zero) {
      _setProgress(1.0);
      widget.onEnd?.call();
      if (_canRepeat) {
        _repeatsDone++;
        WidgetsBinding.instance.addPostFrameCallback((_) => _startAnimation());
      }
      return;
    }

    _startTime = DateTime.now();
    _setProgress(0.0);

    _ticker = Timer.periodic(_frameInterval, (timer) {
      if (!mounted || _startTime == null) {
        timer.cancel();
        _ticker = null;
        return;
      }

      final elapsed = DateTime.now().difference(_startTime!);
      final totalMicros = widget.duration.inMicroseconds;
      final nextProgress =
          (elapsed.inMicroseconds / totalMicros).clamp(0.0, 1.0);

      if (!mounted) {
        timer.cancel();
        _ticker = null;
        return;
      }

      _setProgress(nextProgress);

      if (nextProgress >= 1.0) {
        timer.cancel();
        _ticker = null;
        widget.onEnd?.call();
        if (_canRepeat && mounted) {
          _repeatsDone++;
          _startAnimation();
        }
      }
    });
  }

  void _stopAnimation() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _setProgress(double progress) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final curvedProgress = widget.curve.transform(clampedProgress);

    setState(() {
      _currentValue = widget.tween.transform(curvedProgress);
    });
  }

  bool _hasTweenChanged(Tween<T> a, Tween<T> b) {
    if (a.runtimeType != b.runtimeType) {
      return true;
    }
    return a.begin != b.begin || a.end != b.end;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentValue, widget.child);
  }
}
