import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';

/// A custom circular progress indicator that doesn't use any TickerProviderStateMixin.
/// This widget is hot-restart safe and uses manual frame callbacks for animations.
class TickerFreeCircularProgressIndicator extends StatefulWidget {
  const TickerFreeCircularProgressIndicator({
    super.key,
    this.value,
    this.backgroundColor,
    this.color,
    this.strokeWidth = 4.0,
    this.strokeAlign = 0.0,
    this.strokeCap,
    this.semanticsLabel,
    this.semanticsValue,
    this.delay,
    this.defaultWidgetAfterDelay,
  });

  /// If non-null, the value of this progress indicator (0.0 to 1.0).
  /// If null, the indicator is indeterminate.
  final double? value;

  /// The progress indicator's background color.
  final Color? backgroundColor;

  /// The progress indicator's color.
  final Color? color;

  /// The width of the line used to draw the circle.
  final double strokeWidth;

  /// The relative position of the stroke (-1.0 to 1.0).
  final double strokeAlign;

  /// The progress indicator's line ending shape.
  final StrokeCap? strokeCap;

  /// The semantic label for accessibility.
  final String? semanticsLabel;

  /// The semantic value for accessibility.
  final String? semanticsValue;

  /// Optional delay before showing the default widget.
  final Duration? delay;

  /// Widget to display after the delay period expires.
  final Widget? defaultWidgetAfterDelay;

  @override
  State<TickerFreeCircularProgressIndicator> createState() =>
      _TickerFreeCircularProgressIndicatorState();
}

class _TickerFreeCircularProgressIndicatorState
    extends State<TickerFreeCircularProgressIndicator> {
  Timer? _animationTimer;
  Timer? _delayTimer;
  double _animationValue = 0.0;
  DateTime? _startTime;
  bool _delayExpired = false;

  @override
  void initState() {
    super.initState();
    if (widget.value == null) {
      _startAnimation();
    }
    _startDelayTimer();
  }

  @override
  void didUpdateWidget(TickerFreeCircularProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Start/stop animation based on value changes
    if (widget.value == null && oldWidget.value != null) {
      _startAnimation();
    } else if (widget.value != null && oldWidget.value == null) {
      _stopAnimation();
    }

    // Handle delay changes
    if (widget.delay != oldWidget.delay ||
        widget.defaultWidgetAfterDelay != oldWidget.defaultWidgetAfterDelay) {
      _delayExpired = false;
      _startDelayTimer();
    }
  }

  @override
  void dispose() {
    _stopAnimation();
    _stopDelayTimer();
    super.dispose();
  }

  void _startDelayTimer() {
    _stopDelayTimer();
    if (widget.delay != null && widget.defaultWidgetAfterDelay != null) {
      _delayTimer = Timer(widget.delay!, () {
        if (mounted) {
          setState(() {
            _delayExpired = true;
          });
        }
      });
    }
  }

  void _stopDelayTimer() {
    _delayTimer?.cancel();
    _delayTimer = null;
  }

  void _startAnimation() {
    _startTime = DateTime.now();
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        final elapsed = DateTime.now().difference(_startTime!).inMilliseconds;
        _animationValue = (elapsed % 2963) / 2963.0;
      });
    });
  }

  void _stopAnimation() {
    _animationTimer?.cancel();
    _animationTimer = null;
  }

  Color _getValueColor(BuildContext context) {
    return widget.color ?? Theme.of(context).primaryColor;
  }

  Widget _buildSemanticsWrapper({required Widget child}) {
    String? expandedSemanticsValue = widget.semanticsValue;
    if (widget.value != null) {
      expandedSemanticsValue ??= '${(widget.value! * 100).round()}%';
    }
    return Semantics(
      label: widget.semanticsLabel,
      value: expandedSemanticsValue,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // If delay has expired and default widget is provided, show it
    if (_delayExpired && widget.defaultWidgetAfterDelay != null) {
      return widget.defaultWidgetAfterDelay!;
    }

    final Color valueColor = _getValueColor(context);

    if (widget.value != null) {
      // Determinate progress indicator
      return _buildSemanticsWrapper(
        child: SizedBox(
          width: 36.0,
          height: 36.0,
          child: CustomPaint(
            painter: _TickerFreeCircularProgressPainter(
              backgroundColor: widget.backgroundColor,
              valueColor: valueColor,
              value: widget.value,
              strokeWidth: widget.strokeWidth,
              strokeAlign: widget.strokeAlign,
              strokeCap: widget.strokeCap ?? StrokeCap.butt,
              headValue: 0.0,
              tailValue: 0.0,
              offsetValue: 0.0,
              rotationValue: 0.0,
            ),
          ),
        ),
      );
    }

    // Indeterminate progress indicator
    final double headValue = _calculateHeadValue(_animationValue);
    final double tailValue = _calculateTailValue(_animationValue);
    final double offsetValue = _calculateOffsetValue(_animationValue);
    final double rotationValue = _calculateRotationValue(_animationValue);

    return _buildSemanticsWrapper(
      child: SizedBox(
        width: 36.0,
        height: 36.0,
        child: CustomPaint(
          painter: _TickerFreeCircularProgressPainter(
            backgroundColor: widget.backgroundColor,
            valueColor: valueColor,
            value: null,
            strokeWidth: widget.strokeWidth,
            strokeAlign: widget.strokeAlign,
            strokeCap: widget.strokeCap ?? StrokeCap.square,
            headValue: headValue,
            tailValue: tailValue,
            offsetValue: offsetValue,
            rotationValue: rotationValue,
          ),
        ),
      ),
    );
  }

  // Animation value calculations matching Flutter's implementation
  static const int _pathCount = 2963 ~/ 1333;
  static const int _rotationCount = 2963 ~/ 2222;

  double _calculateHeadValue(double t) {
    // Fast out slow in curve applied twice
    final double pathProgress = (t * _pathCount) % 1.0;
    final double curveValue = _fastOutSlowIn(pathProgress);
    return _fastOutSlowIn(curveValue.clamp(0.0, 0.5) * 2.0);
  }

  double _calculateTailValue(double t) {
    final double pathProgress = (t * _pathCount) % 1.0;
    final double curveValue = _fastOutSlowIn(pathProgress);
    return _fastOutSlowIn(((curveValue - 0.5).clamp(0.0, 0.5)) * 2.0);
  }

  double _calculateOffsetValue(double t) {
    return (t * _pathCount) % 1.0;
  }

  double _calculateRotationValue(double t) {
    return (t * _rotationCount) % 1.0;
  }

  // Fast out slow in curve implementation
  double _fastOutSlowIn(double t) {
    const double t1 = 0.4;
    if (t < t1) {
      return 0.5 * t / t1;
    } else {
      return 0.5 + 0.5 * (t - t1) / (1.0 - t1);
    }
  }
}

class _TickerFreeCircularProgressPainter extends CustomPainter {
  _TickerFreeCircularProgressPainter({
    this.backgroundColor,
    required this.valueColor,
    required this.value,
    required this.strokeWidth,
    required this.strokeAlign,
    required this.strokeCap,
    required this.headValue,
    required this.tailValue,
    required this.offsetValue,
    required this.rotationValue,
  }) : super();

  final Color? backgroundColor;
  final Color valueColor;
  final double? value;
  final double strokeWidth;
  final double strokeAlign;
  final StrokeCap strokeCap;
  final double headValue;
  final double tailValue;
  final double offsetValue;
  final double rotationValue;

  static const double _twoPi = math.pi * 2.0;
  static const double _epsilon = .001;
  static const double _sweep = _twoPi - _epsilon;
  static const double _startAngle = -math.pi / 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = valueColor
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeCap
      ..style = PaintingStyle.stroke;

    final double strokeOffset = strokeWidth / 2 * -strokeAlign;
    final Offset arcBaseOffset = Offset(strokeOffset, strokeOffset);
    final Size arcActualSize = Size(
      size.width - strokeOffset * 2,
      size.height - strokeOffset * 2,
    );

    // Draw background track if specified
    if (backgroundColor != null) {
      final Paint backgroundPaint = Paint()
        ..color = backgroundColor!
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        arcBaseOffset & arcActualSize,
        0,
        _sweep,
        false,
        backgroundPaint,
      );
    }

    // Calculate arc parameters
    final double arcStart;
    final double arcSweep;

    if (value != null) {
      // Determinate
      arcStart = _startAngle;
      arcSweep = value!.clamp(0.0, 1.0) * _sweep;
    } else {
      // Indeterminate
      arcStart = _startAngle +
          tailValue * 3 / 2 * math.pi +
          rotationValue * math.pi * 2.0 +
          offsetValue * 0.5 * math.pi;
      arcSweep = math.max(
        headValue * 3 / 2 * math.pi - tailValue * 3 / 2 * math.pi,
        _epsilon,
      );
    }

    canvas.drawArc(
      arcBaseOffset & arcActualSize,
      arcStart,
      arcSweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_TickerFreeCircularProgressPainter oldPainter) {
    return oldPainter.backgroundColor != backgroundColor ||
        oldPainter.valueColor != valueColor ||
        oldPainter.value != value ||
        oldPainter.strokeWidth != strokeWidth ||
        oldPainter.strokeAlign != strokeAlign ||
        oldPainter.strokeCap != strokeCap ||
        oldPainter.headValue != headValue ||
        oldPainter.tailValue != tailValue ||
        oldPainter.offsetValue != offsetValue ||
        oldPainter.rotationValue != rotationValue;
  }
}
