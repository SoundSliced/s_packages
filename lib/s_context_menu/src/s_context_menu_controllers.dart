import 'dart:math' as math;

import 'package:flutter/material.dart';

import 's_context_menu.dart';

class SContextMenuControllers {
  static const double kButtonHeight = 36.0;
  static const int _maxCacheSize = 50;
  static final Map<String, double> _labelWidthCache = {};

  static double labelWidth(String text, TextStyle style) {
    final key =
        '${style.fontSize ?? 14}_${style.fontWeight?.value ?? 400}_$text';
    final cached = _labelWidthCache[key];
    if (cached != null) return cached;
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);
    final w = painter.width;
    if (_labelWidthCache.length >= _maxCacheSize) {
      _labelWidthCache.clear();
    }
    _labelWidthCache[key] = w;
    return w;
  }

  static double computeTargetWidth(
      List<SContextMenuItem> buttons, TextStyle style, double screenWidth) {
    const double iconAndGap = 24 + 6; // icon + gap
    const double horizontalPadding = 16;
    final longest = buttons.isEmpty
        ? labelWidth(SContextMenu.defaultButtonLabel, style)
        : buttons
            .map((b) => labelWidth(b.label, style))
            .fold<double>(0, math.max);
    final adaptiveMax = math.min(screenWidth * 0.45, 280.0);
    final raw = longest + iconAndGap + horizontalPadding;
    return raw.clamp(80.0, adaptiveMax);
  }

  static void disposeFocusNodes(
      List<FocusNode> nodes, List<VoidCallback> activators) {
    for (final n in nodes) {
      n.dispose();
    }
    nodes.clear();
    activators.clear();
  }

  static Path createArrowPath(ArrowGeometry geometry, ArrowConfig config) {
    if (config.shape == ArrowShape.smallTriangle) {
      final r = config.tipRoundness.clamp(0, geometry.baseEdgeA.distance - 0.1);
      final Path p = Path();
      p.moveTo(geometry.baseEdgeA.dx, geometry.baseEdgeA.dy);
      p.lineTo(geometry.baseEdgeB.dx, geometry.baseEdgeB.dy);
      if (r > 0) {
        Offset shorten(Offset from, Offset to) {
          final v = to - from;
          final len = v.distance;
          if (len <= 0.0001) return to;
          final cut = math.min(r, len * 0.6);
          final scale = (cut / len).toDouble();
          return to - v * scale;
        }

        final p1 = shorten(geometry.baseEdgeB, geometry.tip);
        final p2 = shorten(geometry.baseEdgeA, geometry.tip);
        p.lineTo(p1.dx, p1.dy);
        p.quadraticBezierTo(geometry.tip.dx, geometry.tip.dy, p2.dx, p2.dy);
        p.lineTo(geometry.baseEdgeA.dx, geometry.baseEdgeA.dy);
        p.close();
        return p;
      } else {
        p.lineTo(geometry.tip.dx, geometry.tip.dy);
        p.close();
        return p;
      }
    }

    final Path path = Path();
    final Offset cornerStart = getCornerStartPoint(geometry, config);
    final Offset cornerEnd = getCornerEndPoint(geometry, config);
    path.moveTo(cornerStart.dx, cornerStart.dy);
    path.arcToPoint(cornerEnd,
        radius: Radius.circular(config.cornerRadius),
        clockwise: isClockwiseCorner(config));
    final Offset control1 = Offset.lerp(geometry.baseEdgeA, geometry.tip, 0.4)!;
    final Offset control2 = Offset.lerp(geometry.baseEdgeB, geometry.tip, 0.4)!;
    path.lineTo(geometry.baseEdgeA.dx, geometry.baseEdgeA.dy);
    path.cubicTo(
      control1.dx,
      control1.dy,
      geometry.tip.dx - (geometry.tip.dx - control1.dx) * 0.3,
      geometry.tip.dy - (geometry.tip.dy - control1.dy) * 0.3,
      geometry.tip.dx,
      geometry.tip.dy,
    );
    path.cubicTo(
      geometry.tip.dx - (geometry.tip.dx - control2.dx) * 0.3,
      geometry.tip.dy - (geometry.tip.dy - control2.dy) * 0.3,
      control2.dx,
      control2.dy,
      geometry.baseEdgeB.dx,
      geometry.baseEdgeB.dy,
    );
    path.close();
    return path;
  }

  static ArrowGeometry computeGeometry(
      Offset pointer, Rect panelRect, Size overlaySize, ArrowConfig config) {
    late final Offset baseCorner;
    late final Offset baseEdgeA;
    late final Offset baseEdgeB;
    switch (config.corner) {
      case ArrowCorner.topLeft:
        baseCorner = panelRect.topLeft;
        baseEdgeA = baseCorner + Offset(config.baseWidth, 0);
        baseEdgeB = baseCorner + Offset(0, config.baseWidth);
        break;
      case ArrowCorner.topRight:
        baseCorner = panelRect.topRight;
        baseEdgeA = baseCorner + Offset(-config.baseWidth, 0);
        baseEdgeB = baseCorner + Offset(0, config.baseWidth);
        break;
      case ArrowCorner.bottomLeft:
        baseCorner = panelRect.bottomLeft;
        baseEdgeA = baseCorner + Offset(config.baseWidth, 0);
        baseEdgeB = baseCorner + Offset(0, -config.baseWidth);
        break;
      case ArrowCorner.bottomRight:
        baseCorner = panelRect.bottomRight;
        baseEdgeA = baseCorner + Offset(-config.baseWidth, 0);
        baseEdgeB = baseCorner + Offset(0, -config.baseWidth);
        break;
    }
    final Offset tip = clampTip(pointer, baseCorner, config, overlaySize);
    return ArrowGeometry(
        baseCorner: baseCorner,
        baseEdgeA: baseEdgeA,
        baseEdgeB: baseEdgeB,
        tip: tip);
  }

  static Offset clampTip(
      Offset rawTip, Offset cornerPoint, ArrowConfig config, Size overlaySize) {
    double x = rawTip.dx;
    double y = rawTip.dy;
    switch (config.corner) {
      case ArrowCorner.topLeft:
        x = math.max(cornerPoint.dx - config.maxLength,
            math.min(cornerPoint.dx - config.tipGap, x));
        y = math.max(cornerPoint.dy - config.maxLength,
            math.min(cornerPoint.dy - config.tipGap, y));
        break;
      case ArrowCorner.topRight:
        x = math.max(cornerPoint.dx + config.tipGap,
            math.min(cornerPoint.dx + config.maxLength, x));
        y = math.max(cornerPoint.dy - config.maxLength,
            math.min(cornerPoint.dy - config.tipGap, y));
        break;
      case ArrowCorner.bottomLeft:
        x = math.max(cornerPoint.dx - config.maxLength,
            math.min(cornerPoint.dx - config.tipGap, x));
        y = math.max(cornerPoint.dy + config.tipGap,
            math.min(cornerPoint.dy + config.maxLength, y));
        break;
      case ArrowCorner.bottomRight:
        x = math.max(cornerPoint.dx + config.tipGap,
            math.min(cornerPoint.dx + config.maxLength, x));
        y = math.max(cornerPoint.dy + config.tipGap,
            math.min(cornerPoint.dy + config.maxLength, y));
        break;
    }
    x = math.max(0.0, math.min(overlaySize.width, x));
    y = math.max(0.0, math.min(overlaySize.height, y));
    return Offset(x, y);
  }

  static Offset getCornerStartPoint(
      ArrowGeometry geometry, ArrowConfig config) {
    switch (config.corner) {
      case ArrowCorner.topLeft:
        return geometry.baseCorner + Offset(config.cornerRadius, 0);
      case ArrowCorner.topRight:
        return geometry.baseCorner + Offset(-config.cornerRadius, 0);
      case ArrowCorner.bottomLeft:
        return geometry.baseCorner + Offset(config.cornerRadius, 0);
      case ArrowCorner.bottomRight:
        return geometry.baseCorner + Offset(-config.cornerRadius, 0);
    }
  }

  static Offset getCornerEndPoint(ArrowGeometry geometry, ArrowConfig config) {
    switch (config.corner) {
      case ArrowCorner.topLeft:
        return geometry.baseCorner + Offset(0, config.cornerRadius);
      case ArrowCorner.topRight:
        return geometry.baseCorner + Offset(0, config.cornerRadius);
      case ArrowCorner.bottomLeft:
        return geometry.baseCorner + Offset(0, -config.cornerRadius);
      case ArrowCorner.bottomRight:
        return geometry.baseCorner + Offset(0, -config.cornerRadius);
    }
  }

  static bool isClockwiseCorner(ArrowConfig config) =>
      config.corner == ArrowCorner.topLeft ||
      config.corner == ArrowCorner.bottomRight;

  static ({
    Rect panelRect,
    ArrowConfig arrowConfig,
    Offset pointerOffset,
    Offset followerOffset
  }) computeMenuLayout({
    required BuildContext context,
    required Offset globalPosition,
    required double targetWidth,
    required int buttonCount,
    required Size overlaySize,
    required bool followAnchor,
    GlobalKey? childKey,
  }) {
    const Offset pointerDisplacement = Offset(3, 4);
    const double panelHorizontalGap = 10;
    const double panelVerticalGap = 8;
    const double buttonHeight = kButtonHeight;

    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    double panelHeight = (buttonCount * buttonHeight) + 12.0; // padding
    panelHeight = panelHeight.clamp(48.0, overlaySize.height).toDouble();

    // When followAnchor is true, compute positions relative to child widget
    Offset followerOffset = Offset.zero;
    Rect panelRect;
    Offset pointerOffset;
    Offset anchorLocal;

    if (followAnchor && childKey != null) {
      final ctx = childKey.currentContext;
      if (ctx != null) {
        final childBox = ctx.findRenderObject() as RenderBox?;
        if (childBox != null && childBox.attached) {
          // Get child's position and size
          final childTopLeftGlobal = childBox.localToGlobal(Offset.zero);
          final childTopLeftLocal =
              overlayBox.globalToLocal(childTopLeftGlobal);

          // Get click position relative to child
          final clickInChild = childBox.globalToLocal(globalPosition);

          // Calculate where to place menu relative to click, with displacement
          final displacedClickInChild = clickInChild + pointerDisplacement;

          // Determine if menu can fit to the right of click position
          final menuRightEdge = childTopLeftLocal.dx +
              displacedClickInChild.dx +
              panelHorizontalGap +
              targetWidth;

          final bool canPlaceToRight = menuRightEdge <= overlaySize.width;

          // Calculate follower offset (relative to child's top-left)
          double offsetX;
          double offsetY;

          if (canPlaceToRight) {
            offsetX = displacedClickInChild.dx + panelHorizontalGap;
          } else {
            offsetX =
                displacedClickInChild.dx - targetWidth - panelHorizontalGap;
          }

          offsetY = displacedClickInChild.dy - panelVerticalGap;

          // Clamp to keep menu on screen
          offsetX = offsetX
              .clamp(-childTopLeftLocal.dx,
                  overlaySize.width - childTopLeftLocal.dx - targetWidth)
              .toDouble();
          offsetY = offsetY
              .clamp(-childTopLeftLocal.dy,
                  overlaySize.height - childTopLeftLocal.dy - panelHeight)
              .toDouble();

          followerOffset = Offset(offsetX, offsetY);

          // Panel rect for follower mode: positioned at origin since follower handles positioning
          // But we still need the dimensions and a reference point for arrow calculation
          panelRect = Rect.fromLTWH(
            0,
            0,
            targetWidth,
            panelHeight,
          );

          // Pointer offset in overlay coordinates (for arrow calculation relative to panel at origin)
          pointerOffset = overlayBox.globalToLocal(globalPosition);
          // Adjust pointer to be relative to where the panel actually is (child + followerOffset)
          pointerOffset = Offset(
            pointerOffset.dx - childTopLeftLocal.dx - offsetX,
            pointerOffset.dy - childTopLeftLocal.dy - offsetY,
          );
          anchorLocal = pointerOffset;
        } else {
          // Fallback if child not available
          final Offset originalLocal = overlayBox.globalToLocal(globalPosition);
          final Offset displacedLocal = originalLocal + pointerDisplacement;
          anchorLocal = Offset(
            displacedLocal.dx.clamp(0.0, overlaySize.width).toDouble(),
            displacedLocal.dy.clamp(0.0, overlaySize.height).toDouble(),
          );
          pointerOffset = Offset(
            originalLocal.dx.clamp(0.0, overlaySize.width).toDouble(),
            originalLocal.dy.clamp(0.0, overlaySize.height).toDouble(),
          );

          final bool canPlaceToRight =
              anchorLocal.dx + panelHorizontalGap + targetWidth <=
                  overlaySize.width;
          double panelLeft = canPlaceToRight
              ? anchorLocal.dx + panelHorizontalGap
              : anchorLocal.dx - panelHorizontalGap - targetWidth;
          panelLeft = panelLeft
              .clamp(0.0, math.max(0.0, overlaySize.width - targetWidth))
              .toDouble();
          double panelTop = anchorLocal.dy - panelVerticalGap;
          panelTop = panelTop
              .clamp(0.0, math.max(0.0, overlaySize.height - panelHeight))
              .toDouble();
          panelRect =
              Rect.fromLTWH(panelLeft, panelTop, targetWidth, panelHeight);
        }
      } else {
        // Fallback if context not available
        final Offset originalLocal = overlayBox.globalToLocal(globalPosition);
        final Offset displacedLocal = originalLocal + pointerDisplacement;
        anchorLocal = Offset(
          displacedLocal.dx.clamp(0.0, overlaySize.width).toDouble(),
          displacedLocal.dy.clamp(0.0, overlaySize.height).toDouble(),
        );
        pointerOffset = Offset(
          originalLocal.dx.clamp(0.0, overlaySize.width).toDouble(),
          originalLocal.dy.clamp(0.0, overlaySize.height).toDouble(),
        );

        final bool canPlaceToRight =
            anchorLocal.dx + panelHorizontalGap + targetWidth <=
                overlaySize.width;
        double panelLeft = canPlaceToRight
            ? anchorLocal.dx + panelHorizontalGap
            : anchorLocal.dx - panelHorizontalGap - targetWidth;
        panelLeft = panelLeft
            .clamp(0.0, math.max(0.0, overlaySize.width - targetWidth))
            .toDouble();
        double panelTop = anchorLocal.dy - panelVerticalGap;
        panelTop = panelTop
            .clamp(0.0, math.max(0.0, overlaySize.height - panelHeight))
            .toDouble();
        panelRect =
            Rect.fromLTWH(panelLeft, panelTop, targetWidth, panelHeight);
      }
    } else {
      // Original behavior when followAnchor is false
      final Offset originalLocal = overlayBox.globalToLocal(globalPosition);
      final Offset displacedLocal = originalLocal + pointerDisplacement;

      anchorLocal = Offset(
        displacedLocal.dx.clamp(0.0, overlaySize.width).toDouble(),
        displacedLocal.dy.clamp(0.0, overlaySize.height).toDouble(),
      );

      pointerOffset = Offset(
        originalLocal.dx.clamp(0.0, overlaySize.width).toDouble(),
        originalLocal.dy.clamp(0.0, overlaySize.height).toDouble(),
      );

      final bool canPlaceToRight =
          anchorLocal.dx + panelHorizontalGap + targetWidth <=
              overlaySize.width;
      double panelLeft = canPlaceToRight
          ? anchorLocal.dx + panelHorizontalGap
          : anchorLocal.dx - panelHorizontalGap - targetWidth;
      panelLeft = panelLeft
          .clamp(0.0, math.max(0.0, overlaySize.width - targetWidth))
          .toDouble();

      double panelTop = anchorLocal.dy - panelVerticalGap;
      panelTop = panelTop
          .clamp(0.0, math.max(0.0, overlaySize.height - panelHeight))
          .toDouble();

      panelRect = Rect.fromLTWH(panelLeft, panelTop, targetWidth, panelHeight);
    }

    final double panelBottom = panelRect.top + panelRect.height;
    final double panelCenterY = panelRect.top + (panelRect.height / 2);
    final bool pointerBelowPanel = pointerOffset.dy >= panelBottom;
    final bool pointerAbovePanel = pointerOffset.dy <= panelRect.top;
    final bool useBottomCorner = pointerBelowPanel
        ? true
        : (pointerAbovePanel ? false : pointerOffset.dy >= panelCenterY);

    final bool canPlaceToRight =
        (panelRect.left > anchorLocal.dx - targetWidth);
    final ArrowCorner arrowCorner;
    if (canPlaceToRight) {
      arrowCorner =
          useBottomCorner ? ArrowCorner.bottomLeft : ArrowCorner.topLeft;
    } else {
      arrowCorner =
          useBottomCorner ? ArrowCorner.bottomRight : ArrowCorner.topRight;
    }

    final arrowConfig = ArrowConfig(
      corner: arrowCorner,
      baseWidth: 10,
      cornerRadius: 4,
      tipGap: 2,
      maxLength: 2,
      shape: ArrowShape.smallTriangle,
      tipRoundness: 5,
    );

    return (
      panelRect: panelRect,
      arrowConfig: arrowConfig,
      pointerOffset: pointerOffset,
      followerOffset: followerOffset
    );
  }

  static double computeContentHeight(int buttonCount) =>
      (buttonCount * kButtonHeight) + 12.0;
}
