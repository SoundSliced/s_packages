import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_context_menu/s_context_menu.dart';

void main() {
  group('SContextMenu Types Tests', () {
    test('ArrowCorner enum has all expected values', () {
      expect(ArrowCorner.topLeft, ArrowCorner.topLeft);
      expect(ArrowCorner.topRight, ArrowCorner.topRight);
      expect(ArrowCorner.bottomLeft, ArrowCorner.bottomLeft);
      expect(ArrowCorner.bottomRight, ArrowCorner.bottomRight);
    });

    test('ArrowShape enum has all expected values', () {
      expect(ArrowShape.curved, ArrowShape.curved);
      expect(ArrowShape.smallTriangle, ArrowShape.smallTriangle);
    });

    test('ArrowConfig creates with defaults', () {
      const config = ArrowConfig(corner: ArrowCorner.topLeft);

      expect(config.corner, ArrowCorner.topLeft);
      expect(config.baseWidth, 10);
      expect(config.cornerRadius, 6);
      expect(config.tipGap, 4);
      expect(config.shape, ArrowShape.curved);
    });

    test('ArrowConfig copyWith works correctly', () {
      const originalConfig = ArrowConfig(
        corner: ArrowCorner.topLeft,
        baseWidth: 10,
        cornerRadius: 6,
      );

      final newConfig = originalConfig.copyWith(
        corner: ArrowCorner.bottomRight,
        baseWidth: 14,
      );

      expect(newConfig.corner, ArrowCorner.bottomRight);
      expect(newConfig.baseWidth, 14);
      expect(newConfig.cornerRadius, 6); // unchanged
    });

    test('SContextMenuItem equality works with id', () {
      final item1 = SContextMenuItem(
        label: 'Item',
        onPressed: () {},
        id: 'unique_id',
      );

      final item2 = SContextMenuItem(
        label: 'Item',
        onPressed: () {},
        id: 'unique_id',
      );

      expect(item1, item2);
      expect(item1.hashCode, item2.hashCode);
    });

    test('SContextMenuItem equality works without id', () {
      final item1 = SContextMenuItem(
        label: 'Item',
        icon: Icons.edit,
        onPressed: () {},
      );

      final item2 = SContextMenuItem(
        label: 'Item',
        icon: Icons.edit,
        onPressed: () {},
      );

      expect(item1, item2);
    });

    test('SContextMenuItem with different labels are not equal', () {
      final item1 = SContextMenuItem(
        label: 'Item 1',
        icon: Icons.edit,
        onPressed: () {},
      );

      final item2 = SContextMenuItem(
        label: 'Item 2',
        icon: Icons.edit,
        onPressed: () {},
      );

      expect(item1, isNot(item2));
    });

    test('SContextMenuTheme.resolveBackground returns correct colors', () {
      const theme = SContextMenuTheme();

      final darkColor = theme.resolveBackground(Brightness.dark);
      final lightColor = theme.resolveBackground(Brightness.light);

      expect(darkColor, isNotNull);
      expect(lightColor, isNotNull);
      expect(darkColor, isNot(lightColor));
    });

    test('SContextMenuTheme.resolveBorder returns correct colors', () {
      const theme = SContextMenuTheme();

      final darkColor = theme.resolveBorder(Brightness.dark);
      final lightColor = theme.resolveBorder(Brightness.light);

      expect(darkColor, isNotNull);
      expect(lightColor, isNotNull);
    });

    test('SContextMenuTheme.resolveShadows returns non-empty list', () {
      const theme = SContextMenuTheme();

      final darkShadows = theme.resolveShadows(Brightness.dark);
      final lightShadows = theme.resolveShadows(Brightness.light);

      expect(darkShadows, isNotEmpty);
      expect(lightShadows, isNotEmpty);
    });

    test('SContextMenuTheme custom panelShadows are used', () {
      final customShadows = [
        const BoxShadow(
          color: Colors.red,
          blurRadius: 5,
        ),
      ];

      final theme = SContextMenuTheme(panelShadows: customShadows);
      final resolved = theme.resolveShadows(Brightness.light);

      expect(resolved, customShadows);
    });

    test('ArrowGeometry constructs correctly', () {
      const baseCorner = Offset(10, 10);
      const baseEdgeA = Offset(5, 5);
      const baseEdgeB = Offset(15, 15);
      const tip = Offset(20, 20);

      const geometry = ArrowGeometry(
        baseCorner: baseCorner,
        baseEdgeA: baseEdgeA,
        baseEdgeB: baseEdgeB,
        tip: tip,
      );

      expect(geometry.baseCorner, baseCorner);
      expect(geometry.baseEdgeA, baseEdgeA);
      expect(geometry.baseEdgeB, baseEdgeB);
      expect(geometry.tip, tip);
    });
  });
}
