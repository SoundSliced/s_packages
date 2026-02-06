import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_banner/s_banner.dart';

void main() {
  testWidgets('SBanner places content in expected corner positions',
      (WidgetTester tester) async {
    const bannerText = 'NEW';
    const childSize = Size(200, 200);

    // Helper that pumps a layout and returns the center of child and the
    // center of the banner content text.
    Future<Map<String, Offset>> pumpWithPosition(SBannerPosition pos,
        {bool isActive = true}) async {
      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: Center(
            child: SBanner(
              bannerPosition: pos,
              isActive: isActive,
              bannerContent: const SizedBox(
                width: 20,
                height: 10,
                child: Center(child: Text(bannerText)),
              ),
              child: SizedBox(width: childSize.width, height: childSize.height),
            ),
          ),
        ),
      ));

      await tester.pumpAndSettle();

      // Read positions
      final childFinder = find.byType(SBanner);
      final childTopLeft = tester.getTopLeft(childFinder);
      final childBottomRight = tester.getBottomRight(childFinder);
      final childCenter = Offset((childTopLeft.dx + childBottomRight.dx) / 2,
          (childTopLeft.dy + childBottomRight.dy) / 2);

      final bannerTextFinder = find.text(bannerText);
      final bannerCenter = tester.getCenter(bannerTextFinder);
      return {
        'childCenter': childCenter,
        'bannerCenter': bannerCenter,
      };
    }

    for (final item in [
      SBannerPosition.topLeft,
      SBannerPosition.topRight,
      SBannerPosition.bottomLeft,
      SBannerPosition.bottomRight
    ]) {
      final positions = await pumpWithPosition(item);
      final childCenter = positions['childCenter']!;
      final bannerCenter = positions['bannerCenter']!;

      final isLeft = identical(item, SBannerPosition.topLeft) ||
          identical(item, SBannerPosition.bottomLeft);
      final isTop = identical(item, SBannerPosition.topLeft) ||
          identical(item, SBannerPosition.topRight);

      if (isLeft) {
        expect(bannerCenter.dx < childCenter.dx, true,
            reason: 'banner should be left of child center for $item');
      } else {
        expect(bannerCenter.dx > childCenter.dx, true,
            reason: 'banner should be right of child center for $item');
      }

      if (isTop) {
        expect(bannerCenter.dy < childCenter.dy, true,
            reason: 'banner should be above child center for $item');
      } else {
        expect(bannerCenter.dy > childCenter.dy, true,
            reason: 'banner should be below child center for $item');
      }
    }
  });

  testWidgets('SBanner respects clipBannerToChild for Stack clipBehavior',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: Center(
          child: SBanner(
            clipBannerToChild: true,
            bannerContent: const Text('X'),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      ),
    ));

    await tester.pumpAndSettle();

    // There's a Stack within SBanner; ensure its clipBehavior is Clip.hardEdge
    final sbannerStack =
        find.descendant(of: find.byType(SBanner), matching: find.byType(Stack));
    expect(sbannerStack, findsOneWidget);
    final stackWidget = tester.widget<Stack>(sbannerStack);
    expect(stackWidget.clipBehavior, equals(Clip.hardEdge));

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: Center(
          child: SBanner(
            clipBannerToChild: false,
            bannerContent: const Text('X'),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      ),
    ));

    await tester.pumpAndSettle();

    final sbannerStack2 =
        find.descendant(of: find.byType(SBanner), matching: find.byType(Stack));
    final stackWidget2 = tester.widget<Stack>(sbannerStack2);
    expect(stackWidget2.clipBehavior, equals(Clip.none));
  });

  testWidgets('Banner render box dimension matches expected value',
      (WidgetTester tester) async {
    // Use a small content size where math is easy to compute.
    const contentWidth = 10.0;
    const contentHeight = 20.0;
    final expectedDistanceToNear = (contentWidth * sin(-pi / 4)).abs();
    final expectedDistanceToFar =
        expectedDistanceToNear + (contentHeight / sin(-pi / 4)).abs();

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: Center(
          child: SBanner(
            bannerPosition: SBannerPosition.topLeft,
            isActive: true,
            bannerContent: const SizedBox(
              width: contentWidth,
              height: contentHeight,
              child: Text('X'),
            ),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      ),
    ));

    await tester.pumpAndSettle();

    // Find the private `_BannerBox` widget by runtime type name.
    final bannerBoxFinder = find.byWidgetPredicate((w) =>
        w.runtimeType.toString() == '_BannerBox' ||
        w.runtimeType.toString() == 'BannerBox');

    expect(bannerBoxFinder, findsOneWidget);
    final bannerSize = tester.getSize(bannerBoxFinder);
    expect((bannerSize.width - expectedDistanceToFar).abs() < 0.5, true,
        reason: 'banner width should equal expected distance to far edge');
    expect((bannerSize.height - expectedDistanceToFar).abs() < 0.5, true);
  });
}
