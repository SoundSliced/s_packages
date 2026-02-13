import 'package:flutter/material.dart';

class SContextMenuItem {
  final String label;
  final IconData? icon;

  final VoidCallback onPressed;
  final String? id; // stable identity (optional)
  final String? semanticsLabel;
  final bool destructive; // style hint for dangerous actions
  final bool keepMenuOpen; // when true, menu stays open after button press

  /// Whether this item is disabled (grayed out, non-interactive).
  final bool disabled;

  /// Optional keyboard shortcut hint displayed on the right side (e.g., "⌘C").
  final String? shortcutHint;

  SContextMenuItem({
    required this.label,
    this.icon,
    required this.onPressed,
    this.id,
    this.semanticsLabel,
    this.destructive = false,
    this.keepMenuOpen = false,
    this.disabled = false,
    this.shortcutHint,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SContextMenuItem &&
        (id != null
            ? other.id == id
            : (other.label == label && other.icon == icon));
  }

  @override
  int get hashCode => id != null ? id.hashCode : Object.hash(label, icon);
}

enum ArrowCorner { topLeft, topRight, bottomLeft, bottomRight }

enum ArrowShape { curved, smallTriangle }

class ArrowConfig {
  final ArrowCorner corner;
  final double baseWidth;
  final double tipLength;
  final double cornerRadius;
  final double tipGap;
  final double maxLength;
  final ArrowShape shape;
  final double tipRoundness;

  const ArrowConfig({
    required this.corner,
    this.baseWidth = 10,
    this.tipLength = 2,
    this.cornerRadius = 6,
    this.tipGap = 4,
    this.maxLength = 4,
    this.shape = ArrowShape.curved,
    this.tipRoundness = 0,
  });

  ArrowConfig copyWith({
    ArrowCorner? corner,
    double? baseWidth,
    double? tipLength,
    double? cornerRadius,
    double? tipGap,
    double? maxLength,
    ArrowShape? shape,
    double? tipRoundness,
  }) =>
      ArrowConfig(
        corner: corner ?? this.corner,
        baseWidth: baseWidth ?? this.baseWidth,
        tipLength: tipLength ?? this.tipLength,
        cornerRadius: cornerRadius ?? this.cornerRadius,
        tipGap: tipGap ?? this.tipGap,
        maxLength: maxLength ?? this.maxLength,
        shape: shape ?? this.shape,
        tipRoundness: tipRoundness ?? this.tipRoundness,
      );
}

class ArrowGeometry {
  final Offset baseCorner;
  final Offset baseEdgeA;
  final Offset baseEdgeB;
  final Offset tip;

  const ArrowGeometry({
    required this.baseCorner,
    required this.baseEdgeA,
    required this.baseEdgeB,
    required this.tip,
  });
}
