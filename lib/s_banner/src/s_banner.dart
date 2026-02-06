import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A corner banner you can overlay on top of a required [child].
///
/// - [bannerContent] renders inside the angled ribbon (defaults to an empty Text).
/// - [child] is required: the base widget the banner overlays, similar to a Stack.
/// - [isActive] toggles whether the banner is shown; when false, this widget
///   simply returns [child] without additional layout cost.
/// - [clipBannerToChild] controls whether the banner is clipped to the child's
///   rectangular bounds (default: true). Set to false for stylistic overflow.
/// - [isChildCircular] indicates whether the child widget is circular/round shaped.
///   When true, the banner shape adapts to curve along the circular edges.
class SBanner extends StatefulWidget {
  const SBanner({
    super.key,
    this.bannerPosition = SBannerPosition.topLeft,
    this.bannerColor = const Color.fromARGB(255, 1, 143, 1),
    this.elevation = 5,
    this.shadowColor = const Color.fromARGB(167, 0, 0, 0),
    this.bannerContent = const Text('Banner'),
    required this.child,
    this.isActive = true,
    this.clipBannerToChild = true,
    this.isChildCircular = false,
    this.childBorderRadius,
  });

  /// The position where the banner is displayed.
  final SBannerPosition bannerPosition;

  /// The color of the banner, which appears behind the [bannerContent] content.
  final Color bannerColor;

  /// The elevation of the banner, which impacts the size of the shadow.
  final double elevation;

  /// The color of the shadow beneath the banner.
  final Color shadowColor;

  /// The content to draw inside the ribbon.
  final Widget bannerContent;

  /// The base widget to overlay the banner on.
  final Widget child;

  /// Whether the banner is visible. If false, returns [child] directly.
  final bool isActive;

  /// If true, clips the banner to the child's bounds. If false, allows
  /// the ribbon to paint outside the child (no clipping).
  final bool clipBannerToChild;

  /// If true, adapts the banner shape to wrap naturally around circular edges.
  /// When false (default), uses the standard rectangular corner banner.
  final bool isChildCircular;

  /// Optional override for the child's border radius when using circular banners.
  /// If null, the radius is inferred from the child's rendered size.
  final double? childBorderRadius;

  @override
  State<SBanner> createState() => _SBannerState();
}

class _SBannerState extends State<SBanner> {
  Size? _childSize;

  @override
  void didUpdateWidget(covariant SBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reset child size when parameters that actually affect the child's layout change
    // Don't reset for isActive, clipBannerToChild, or banner-only properties
    if (oldWidget.isChildCircular != widget.isChildCircular ||
        oldWidget.child != widget.child ||
        oldWidget.childBorderRadius != widget.childBorderRadius) {
      _childSize = null;
    }
    // If isActive changes from false to true and we don't have a size yet,
    // we need to ensure we get it on the next frame
    if (!oldWidget.isActive && widget.isActive && _childSize == null) {
      // Schedule a rebuild for the next frame to pick up the size
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _childSize == null) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final measuredChild = _SizeReportingWidget(
      onSizeChanged: (size) {
        if (!mounted) return;
        // Always update if size changed or if we don't have a size yet
        if (size != _childSize) {
          setState(() => _childSize = size);
        }
      },
      child: widget.child,
    );

    if (!widget.isActive) return measuredChild;

    // If we don't have the child size yet, wrap in LayoutBuilder to get it
    // This allows immediate display without waiting for a callback
    if (_childSize == null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return measuredChild;
        },
      );
    }

    final ribbon = _buildBannerForCurrentMode();

    return SizedBox(
      width: _childSize!.width,
      height: _childSize!.height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: widget.clipBannerToChild ? Clip.hardEdge : Clip.none,
        children: [
          measuredChild,
          Align(
            alignment: _alignmentFor(widget.bannerPosition),
            child: ribbon,
          ),
        ],
      ),
    );
  }

  Widget _buildBannerForCurrentMode() {
    if (!widget.isChildCircular || _childSize == null) {
      return _BannerBox(
        bannerPosition: widget.bannerPosition,
        bannerColor: widget.bannerColor,
        elevation: widget.elevation,
        shadowColor: widget.shadowColor,
        bannerContent: widget.bannerContent,
        paintBannerShape: true,
      );
    }

    final Size childSize = _childSize!;
    final double radius = widget.childBorderRadius ??
        (childSize.shortestSide.isFinite ? childSize.shortestSide / 2 : 0);

    final double thickness = min(childSize.shortestSide * 0.15, radius * 0.3);

    return SizedBox(
      width: childSize.width,
      height: childSize.height,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(childSize.width, childSize.height),
            painter: _CircularBannerPainter(
              bannerPosition: widget.bannerPosition,
              bannerColor: widget.bannerColor,
              shadowColor: widget.shadowColor,
              elevation: widget.elevation,
              radius: radius,
              thickness: thickness,
            ),
          ),
          _CircularBannerContent(
            bannerPosition: widget.bannerPosition,
            radius: radius,
            thickness: thickness,
            childSize: childSize,
            child: widget.bannerContent,
          ),
        ],
      ),
    );
  }

  AlignmentGeometry _alignmentFor(SBannerPosition pos) {
    switch (pos._corner) {
      case _Corner.topLeft:
        return Alignment.topLeft;
      case _Corner.topRight:
        return Alignment.topRight;
      case _Corner.bottomLeft:
        return Alignment.bottomLeft;
      case _Corner.bottomRight:
        return Alignment.bottomRight;
    }
  }
}

/// Private render-object widget that draws the ribbon and lays out `bannerContent`.
class _BannerBox extends SingleChildRenderObjectWidget {
  const _BannerBox({
    required this.bannerPosition,
    required this.bannerColor,
    required this.elevation,
    required this.shadowColor,
    required Widget bannerContent,
    required this.paintBannerShape,
  }) : super(child: bannerContent);

  final SBannerPosition bannerPosition;
  final Color bannerColor;
  final double elevation;
  final Color shadowColor;
  final bool paintBannerShape;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderBanner(
      bannerPosition: bannerPosition,
      bannerColor: bannerColor,
      elevation: elevation,
      shadowColor: shadowColor,
      paintBannerShape: paintBannerShape,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderBanner)
      ..bannerPosition = bannerPosition
      ..bannerColor = bannerColor
      ..elevation = elevation
      ..shadowColor = shadowColor
      ..paintBannerShape = paintBannerShape;
  }
}

class _RenderBanner extends RenderBox with RenderObjectWithChildMixin {
  _RenderBanner({
    required SBannerPosition bannerPosition,
    required Color bannerColor,
    required double elevation,
    required Color shadowColor,
    required bool paintBannerShape,
  })  : _bannerPosition = bannerPosition,
        _bannerColor = bannerColor,
        _elevation = elevation,
        _shadowColor = shadowColor,
        _paintBannerShape = paintBannerShape;

  SBannerPosition _bannerPosition;
  set bannerPosition(SBannerPosition newPosition) {
    if (newPosition != _bannerPosition) {
      _bannerPosition = newPosition;
      markNeedsPaint();
    }
  }

  Color _bannerColor;
  set bannerColor(Color newColor) {
    if (newColor != _bannerColor) {
      _bannerColor = newColor;
      markNeedsPaint();
    }
  }

  double _elevation;
  set elevation(double newElevation) {
    if (newElevation != _elevation) {
      _elevation = newElevation;
      markNeedsPaint();
    }
  }

  Color _shadowColor;
  set shadowColor(Color newColor) {
    if (newColor != _shadowColor) {
      _shadowColor = newColor;
      markNeedsPaint();
    }
  }

  bool _paintBannerShape;
  set paintBannerShape(bool value) {
    if (value != _paintBannerShape) {
      _paintBannerShape = value;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    if (child == null) {
      size = constraints.constrain(Size.zero);
      return;
    }

    child!.layout(constraints, parentUsesSize: true);

    final childSize = (child as RenderBox).size;
    final dimension =
        _bannerPosition.calculateDistanceToFarBannerEdge(childSize);
    // Respect incoming constraints from parent (e.g., when overlaid on a child)
    // by clamping the banner's square size to the available space.
    size = constraints.constrain(Size.square(dimension));
  }

  @override
  void paint(PaintingContext paintingContext, Offset offset) {
    if (child == null) {
      return;
    }

    final childSize = (child as RenderBox).size;

    if (_paintBannerShape) {
      final bannerPath = _bannerPosition.createBannerPath(
        bannerBoundingBoxTopLeft: offset,
        contentSize: childSize,
      );

      paintingContext.canvas
        ..drawShadow(
          bannerPath,
          _shadowColor,
          _elevation,
          false,
        )
        ..drawPath(
          bannerPath,
          Paint()
            ..color = _bannerColor
            ..style = PaintingStyle.fill,
        );
    }

    // Orient the canvas to paint the child.
    paintingContext.canvas.save();
    _bannerPosition.positionCanvasToDrawContent(
        paintingContext.canvas, offset, childSize);

    // Paint the child.
    child!.paint(paintingContext, Offset.zero);
    paintingContext.canvas.restore();
  }
}

class SBannerPosition {
  static const SBannerPosition topLeft = SBannerPosition._(_Corner.topLeft);
  static const SBannerPosition topRight = SBannerPosition._(_Corner.topRight);
  static const SBannerPosition bottomLeft =
      SBannerPosition._(_Corner.bottomLeft);
  static const SBannerPosition bottomRight =
      SBannerPosition._(_Corner.bottomRight);

  const SBannerPosition._(_Corner corner) : _corner = corner;

  final _Corner _corner;

  /// Creates the path for a banner that fits into the corner of
  /// this [SBannerPosition].
  ///
  /// [bannerBoundingBoxTopLeft] is the global screen-space offset for the top
  /// left corner of the banner's bounding box.
  Path createBannerPath({
    required Offset bannerBoundingBoxTopLeft,
    required Size contentSize,
  }) {
    final distanceToNearEdge = calculateDistanceToNearBannerEdge(contentSize);
    final distanceToFarEdge = calculateDistanceToFarBannerEdge(contentSize);

    late Path relativePath;

    switch (_corner) {
      case _Corner.topLeft:
        relativePath = Path()
          ..moveTo(0, distanceToNearEdge)
          ..lineTo(distanceToNearEdge, 0)
          ..lineTo(distanceToFarEdge, 0)
          ..lineTo(0, distanceToFarEdge)
          ..close();
        break;
      case _Corner.topRight:
        relativePath = Path()
          ..moveTo(0, 0)
          ..lineTo(distanceToFarEdge - distanceToNearEdge, 0)
          ..lineTo(distanceToFarEdge, distanceToNearEdge)
          ..lineTo(distanceToFarEdge, distanceToFarEdge)
          ..close();
        break;
      case _Corner.bottomLeft:
        relativePath = Path()
          ..moveTo(0, 0)
          ..lineTo(distanceToFarEdge, distanceToFarEdge)
          ..lineTo(distanceToNearEdge, distanceToFarEdge)
          ..lineTo(0, distanceToFarEdge - distanceToNearEdge)
          ..close();
        break;
      case _Corner.bottomRight:
        relativePath = Path()
          ..moveTo(0, distanceToFarEdge)
          ..lineTo(distanceToFarEdge, 0)
          ..lineTo(distanceToFarEdge, distanceToFarEdge - distanceToNearEdge)
          ..lineTo(distanceToFarEdge - distanceToNearEdge, distanceToFarEdge)
          ..close();
        break;
    }

    return relativePath.shift(bannerBoundingBoxTopLeft);
  }

  /// Translates and rotates the canvas such that the top-left corner of
  /// the content is drawn at the desired location on the screen, and
  /// that content is angled 45 degrees in the appropriate direction
  /// for this banner position.
  void positionCanvasToDrawContent(
      Canvas canvas, Offset paintingOffset, Size contentSize) {
    final contentOrigin = _calculateContentOrigin(paintingOffset, contentSize);
    switch (_corner) {
      case _Corner.topLeft:
        canvas
          ..translate(contentOrigin.dx, contentOrigin.dy)
          ..rotate(-pi / 4);
        break;
      case _Corner.topRight:
        canvas
          ..translate(contentOrigin.dx, contentOrigin.dy)
          ..rotate(pi / 4);
        break;
      case _Corner.bottomLeft:
        canvas
          ..translate(contentOrigin.dx, contentOrigin.dy)
          ..rotate(pi / 4);
        break;
      case _Corner.bottomRight:
        canvas
          ..translate(contentOrigin.dx, contentOrigin.dy)
          ..rotate(-pi / 4);
        break;
    }
  }

  /// Calculates the global translation that should be applied before
  /// drawing the content such that (0,0) in the content space corresponds
  /// to the top-left corner of the content in the global screen space.
  Offset _calculateContentOrigin(Offset paintingOffset, Size contentSize) {
    late Offset relativeOrigin;
    switch (_corner) {
      case _Corner.topLeft:
        relativeOrigin =
            Offset(0, calculateDistanceToNearBannerEdge(contentSize));
        break;
      case _Corner.topRight:
        relativeOrigin = Offset(
          (calculateDistanceToFarBannerEdge(contentSize) -
              calculateDistanceToNearBannerEdge(contentSize)),
          0,
        );
        break;
      case _Corner.bottomLeft:
        final leftBottomBannerCorner = Offset(
            0,
            calculateDistanceToFarBannerEdge(contentSize) -
                calculateDistanceToNearBannerEdge(contentSize));
        relativeOrigin = leftBottomBannerCorner +
            Offset(contentSize.height * sin(pi / 4),
                -contentSize.height * sin(pi / 4));
        break;
      case _Corner.bottomRight:
        final distanceToNearEdge =
            calculateDistanceToNearBannerEdge(contentSize);
        final distanceToFarEdge = calculateDistanceToFarBannerEdge(contentSize);
        final bottomRightBannerCorner =
            Offset(distanceToFarEdge - distanceToNearEdge, distanceToFarEdge);
        relativeOrigin = bottomRightBannerCorner +
            Offset(-contentSize.height * sin(pi / 4),
                -contentSize.height * sin(pi / 4));
        break;
    }

    return relativeOrigin + paintingOffset;
  }

  /// Distance from the corner to the nearest edge of the banner along
  /// the vertical or horizontal axis (the two distances are equal because
  /// the angle is 45 degrees).
  double calculateDistanceToNearBannerEdge(Size contentSize) {
    return (contentSize.width * sin(-pi / 4)).abs();
  }

  /// Distance from the corner to the furthest edge of the banner along
  /// the vertical or horizontal axis (the two distances are equal because
  /// the angle is 45 degrees).
  double calculateDistanceToFarBannerEdge(Size contentSize) {
    return calculateDistanceToNearBannerEdge(contentSize) +
        (contentSize.height / sin(-pi / 4)).abs();
  }
}

class _SizeReportingWidget extends SingleChildRenderObjectWidget {
  const _SizeReportingWidget({
    required this.onSizeChanged,
    required Widget child,
  }) : super(child: child);

  final ValueChanged<Size> onSizeChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSizeReporter(onSizeChanged);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderSizeReporter renderObject) {
    renderObject.onSizeChanged = onSizeChanged;
  }
}

class _RenderSizeReporter extends RenderProxyBox {
  _RenderSizeReporter(this._onSizeChanged);

  ValueChanged<Size> _onSizeChanged;
  Size? _lastSize;
  bool _callbackScheduled = false;

  set onSizeChanged(ValueChanged<Size> callback) {
    _onSizeChanged = callback;
    // When callback changes, reset last size to force a report
    _lastSize = null;
  }

  @override
  void performLayout() {
    super.performLayout();
    final currentSize = size;
    if (_lastSize == currentSize) return;
    _lastSize = currentSize;

    // Schedule callback if not already scheduled
    if (!_callbackScheduled) {
      _callbackScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _callbackScheduled = false;
        _onSizeChanged(currentSize);
      });
    }
  }
}

/// Widget that positions banner content within the circular banner area
class _CircularBannerContent extends SingleChildRenderObjectWidget {
  const _CircularBannerContent({
    required this.bannerPosition,
    required this.radius,
    required this.thickness,
    required this.childSize,
    required Widget child,
  }) : super(child: child);

  final SBannerPosition bannerPosition;
  final double radius;
  final double thickness;
  final Size childSize;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderCircularBannerContent(
      bannerPosition: bannerPosition,
      radius: radius,
      thickness: thickness,
      childSize: childSize,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderCircularBannerContent renderObject) {
    renderObject
      ..bannerPosition = bannerPosition
      ..radius = radius
      ..thickness = thickness
      ..childSize = childSize;
  }
}

class _RenderCircularBannerContent extends RenderBox
    with RenderObjectWithChildMixin {
  _RenderCircularBannerContent({
    required SBannerPosition bannerPosition,
    required double radius,
    required double thickness,
    required Size childSize,
  })  : _bannerPosition = bannerPosition,
        _radius = radius,
        _thickness = thickness,
        _childSize = childSize;

  SBannerPosition _bannerPosition;
  set bannerPosition(SBannerPosition value) {
    if (_bannerPosition != value) {
      _bannerPosition = value;
      markNeedsLayout();
    }
  }

  double _radius;
  set radius(double value) {
    if (_radius != value) {
      _radius = value;
      markNeedsLayout();
    }
  }

  double _thickness;
  set thickness(double value) {
    if (_thickness != value) {
      _thickness = value;
      markNeedsLayout();
    }
  }

  Size _childSize;
  set childSize(Size value) {
    if (_childSize != value) {
      _childSize = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    if (child == null) {
      size = constraints.constrain(Size.zero);
      return;
    }

    // Let child determine its natural size
    child!.layout(constraints.loosen(), parentUsesSize: true);

    // Use the constraints' max size which matches the Stack's size
    size = Size(
      constraints.hasBoundedWidth ? constraints.maxWidth : _childSize.width,
      constraints.hasBoundedHeight ? constraints.maxHeight : _childSize.height,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    final double maxRadius = _childSize.shortestSide / 2;
    final double clampedRadius = _radius.clamp(0, maxRadius).toDouble();
    final double innerRadius = max(0, clampedRadius - _thickness).toDouble();
    final double contentRadius = (clampedRadius + innerRadius) / 2;

    final (Offset center, double arcStartAngle, bool isBottomPosition) =
        _calculateCenterAndAngle(offset, clampedRadius);

    // Paint child along the arc
    _paintChildAlongArc(
      context,
      center: center,
      radius: contentRadius,
      startAngle: arcStartAngle,
      sweepAngle: pi / 2, // 90 degrees
      flipText: isBottomPosition,
    );
  }

  (Offset, double, bool) _calculateCenterAndAngle(
      Offset offset, double clampedRadius) {
    switch (_bannerPosition._corner) {
      case _Corner.topLeft:
        return (
          offset + Offset(clampedRadius, clampedRadius),
          pi, // Start from left edge (180 degrees)
          false,
        );
      case _Corner.topRight:
        return (
          offset + Offset(_childSize.width - clampedRadius, clampedRadius),
          -pi / 2, // Start from top edge (270 degrees)
          false,
        );
      case _Corner.bottomLeft:
        return (
          offset + Offset(clampedRadius, _childSize.height - clampedRadius),
          pi / 2, // Start from bottom edge (90 degrees)
          true,
        );
      case _Corner.bottomRight:
        return (
          offset +
              Offset(_childSize.width - clampedRadius,
                  _childSize.height - clampedRadius),
          0, // Start from right edge (0 degrees)
          true,
        );
    }
  }

  void _paintChildAlongArc(
    PaintingContext context, {
    required Offset center,
    required double radius,
    required double startAngle,
    required double sweepAngle,
    required bool flipText,
  }) {
    if (child == null) return;

    final RenderBox renderBox = child as RenderBox;
    final Size childSize = renderBox.size;
    final double contentWidth = childSize.width;

    // Calculate the arc length available and scale
    final double arcLength = radius * sweepAngle;
    final double scale =
        contentWidth > arcLength ? arcLength / contentWidth : 1.0;

    // Save canvas state and translate to center
    context.canvas.save();
    context.canvas.translate(center.dx, center.dy);

    // Calculate starting position - offset to center content in arc
    final double contentArcLength = contentWidth * scale;
    final double contentSweepAngle = contentArcLength / radius;
    final double sweepOffset = (sweepAngle - contentSweepAngle) / 2;

    // For bottom positions, reverse the direction
    final double startOffsetAngle = flipText
        ? startAngle + sweepAngle - sweepOffset
        : startAngle + sweepOffset;

    // For each horizontal slice of the child, paint it at the appropriate angle
    final int slices = max(1, (contentWidth * scale).ceil());
    final double sliceWidth = contentWidth / slices;
    final double halfSliceWidth = sliceWidth / 2;
    final double halfChildHeight = childSize.height / 2;

    for (int i = 0; i < slices; i++) {
      final double progress = i / slices;
      // Reverse direction for flipped text
      final double angle = flipText
          ? startOffsetAngle - (contentSweepAngle * progress)
          : startOffsetAngle + (contentSweepAngle * progress);

      context.canvas.save();

      // Position on arc
      final double x = radius * cos(angle);
      final double y = radius * sin(angle);
      context.canvas.translate(x, y);

      // Rotate to be tangent to arc
      double rotation = angle + pi / 2;
      if (flipText) {
        rotation += pi;
      }
      context.canvas.rotate(rotation);

      // Apply scale
      context.canvas.scale(scale, 1.0);

      // Translate to paint the specific slice
      context.canvas
          .translate(-sliceWidth * i - halfSliceWidth, -halfChildHeight);

      // Clip to only show this slice
      context.canvas.clipRect(
          Rect.fromLTWH(sliceWidth * i, 0, sliceWidth, childSize.height));

      // Paint the child
      renderBox.paint(context, Offset.zero);

      context.canvas.restore();
    }

    context.canvas.restore();
  }
}

class _CircularBannerPainter extends CustomPainter {
  const _CircularBannerPainter({
    required this.bannerPosition,
    required this.bannerColor,
    required this.shadowColor,
    required this.elevation,
    required this.radius,
    required this.thickness,
  });

  final SBannerPosition bannerPosition;
  final Color bannerColor;
  final Color shadowColor;
  final double elevation;
  final double radius;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    if (radius <= 0 || thickness <= 0) {
      return;
    }

    final Path semiCircle = _buildSemiCirclePath(size);

    final bool isBottomPosition =
        bannerPosition._corner == _Corner.bottomLeft ||
            bannerPosition._corner == _Corner.bottomRight;

    // For bottom positions, shift the path up to cast shadow upward
    if (isBottomPosition) {
      final Path shiftedPath = semiCircle.shift(Offset(0, -elevation * 2));
      canvas.drawShadow(shiftedPath, shadowColor, elevation, false);
    } else {
      canvas.drawShadow(semiCircle, shadowColor, elevation, false);
    }

    canvas.drawPath(
      semiCircle,
      Paint()
        ..color = bannerColor
        ..style = PaintingStyle.fill,
    );
  }

  Path _buildSemiCirclePath(Size size) {
    final double maxRadius = size.shortestSide / 2;
    final double clampedRadius = radius.clamp(0, maxRadius);
    final Offset center = _childCenter(size, clampedRadius);

    // Create a ring that starts from near the edge (not from center)
    // The outer radius matches the child's border
    final double outerRadius = clampedRadius;
    final double innerRadius = max(0, clampedRadius - thickness);

    // Calculate the angles for the 90-degree arc in each corner
    const double sweepAngle = pi / 2; // 90 degrees
    final double startAngle = switch (bannerPosition._corner) {
      _Corner.topLeft => pi,
      _Corner.topRight => -pi / 2,
      _Corner.bottomLeft => pi / 2,
      _Corner.bottomRight => 0,
    };

    final Path bannerPath = Path();

    // Create the arc path manually for better control
    final Rect outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    final Rect innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    // Start at outer arc
    bannerPath.arcTo(outerRect, startAngle, sweepAngle, false);

    // Draw line to inner arc
    final double endAngle = startAngle + sweepAngle;
    final Offset innerEnd = Offset(
      center.dx + innerRadius * cos(endAngle),
      center.dy + innerRadius * sin(endAngle),
    );
    bannerPath.lineTo(innerEnd.dx, innerEnd.dy);

    // Draw inner arc backwards
    bannerPath.arcTo(innerRect, endAngle, -sweepAngle, false);

    // Close the path
    bannerPath.close();

    return bannerPath;
  }

  Offset _childCenter(Size size, double clampedRadius) {
    switch (bannerPosition._corner) {
      case _Corner.topLeft:
        return Offset(clampedRadius, clampedRadius);
      case _Corner.topRight:
        return Offset(size.width - clampedRadius, clampedRadius);
      case _Corner.bottomLeft:
        return Offset(clampedRadius, size.height - clampedRadius);
      case _Corner.bottomRight:
        return Offset(size.width - clampedRadius, size.height - clampedRadius);
    }
  }

  @override
  bool shouldRepaint(covariant _CircularBannerPainter oldDelegate) {
    return oldDelegate.bannerPosition != bannerPosition ||
        oldDelegate.bannerColor != bannerColor ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.elevation != elevation ||
        oldDelegate.radius != radius ||
        oldDelegate.thickness != thickness;
  }
}

enum _Corner {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}
