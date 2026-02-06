import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_banner/s_banner.dart';

void main() {
  group('SBanner with circular child', () {
    testWidgets('uses CustomPaint painter for semi-circle banner',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SBanner(
              bannerPosition: SBannerPosition.topLeft,
              isChildCircular: true,
              bannerContent: Text('PAINT'),
              child: SizedBox.square(dimension: 120),
            ),
          ),
        ),
      );

      // Wait for the deferred size reporting rebuild that introduces the painter.
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint &&
              widget.painter?.runtimeType.toString() ==
                  '_CircularBannerPainter',
        ),
        findsOneWidget,
      );
    });

    testWidgets('semi-circle painter matches child bounds',
        (WidgetTester tester) async {
      const childKey = Key('circle-child');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SBanner(
                bannerPosition: SBannerPosition.topRight,
                isChildCircular: true,
                bannerContent: Text('SIZE'),
                child: SizedBox(
                  key: childKey,
                  width: 180,
                  height: 180,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Allow the size reporter to propagate the child's dimensions.
      await tester.pumpAndSettle();

      final Size childSize = tester.getSize(find.byKey(childKey));
      final Finder painterFinder = find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint &&
            widget.painter?.runtimeType.toString() == '_CircularBannerPainter',
      );

      expect(painterFinder, findsOneWidget);
      final Size painterSize = tester.getSize(painterFinder);
      expect(painterSize, childSize);
    });

    testWidgets('renders with circular child in topLeft position',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SBanner(
              bannerPosition: SBannerPosition.topLeft,
              isChildCircular: true,
              bannerContent: const Text('NEW'),
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('NEW'), findsOneWidget);
      expect(find.byType(SBanner), findsOneWidget);
    });

    testWidgets('renders with circular child in topRight position',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SBanner(
              bannerPosition: SBannerPosition.topRight,
              isChildCircular: true,
              bannerContent: const Text('SALE'),
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('SALE'), findsOneWidget);
      expect(find.byType(SBanner), findsOneWidget);
    });

    testWidgets('renders with circular child in bottomLeft position',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SBanner(
              bannerPosition: SBannerPosition.bottomLeft,
              isChildCircular: true,
              bannerContent: const Text('HOT'),
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('HOT'), findsOneWidget);
      expect(find.byType(SBanner), findsOneWidget);
    });

    testWidgets('renders with circular child in bottomRight position',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SBanner(
              bannerPosition: SBannerPosition.bottomRight,
              isChildCircular: true,
              bannerContent: const Text('BEST'),
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('BEST'), findsOneWidget);
      expect(find.byType(SBanner), findsOneWidget);
    });

    testWidgets('isChildCircular defaults to false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SBanner(
              bannerContent: const Text('TEST'),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('TEST'), findsOneWidget);
      expect(find.byType(SBanner), findsOneWidget);
    });

    testWidgets('can toggle isChildCircular dynamically',
        (WidgetTester tester) async {
      bool isCircular = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    SBanner(
                      isChildCircular: isCircular,
                      bannerContent: const Text('DYNAMIC'),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape:
                              isCircular ? BoxShape.circle : BoxShape.rectangle,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isCircular = !isCircular;
                        });
                      },
                      child: const Text('Toggle'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('DYNAMIC'), findsOneWidget);

      // Toggle to circular
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      expect(find.text('DYNAMIC'), findsOneWidget);

      // Toggle back to rectangular
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      expect(find.text('DYNAMIC'), findsOneWidget);
    });

    testWidgets('circular banner works with isActive toggle',
        (WidgetTester tester) async {
      bool active = true;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    SBanner(
                      isActive: active,
                      isChildCircular: true,
                      bannerContent: const Text('TOGGLE'),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          active = !active;
                        });
                      },
                      child: const Text('Toggle Active'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('TOGGLE'), findsOneWidget);

      // Deactivate banner
      await tester.tap(find.text('Toggle Active'));
      await tester.pumpAndSettle();

      expect(find.text('TOGGLE'), findsNothing);
    });

    testWidgets('circular banner respects custom colors and elevation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SBanner(
              isChildCircular: true,
              bannerColor: Colors.deepPurple,
              shadowColor: Colors.black54,
              elevation: 10,
              bannerContent:
                  const Text('CUSTOM', style: TextStyle(color: Colors.white)),
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('CUSTOM'), findsOneWidget);
      expect(find.byType(SBanner), findsOneWidget);
    });

    testWidgets('circular banner with clipBannerToChild set to false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SBanner(
                isChildCircular: true,
                clipBannerToChild: false,
                bannerContent: const Text('OVERFLOW'),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.pink,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('OVERFLOW'), findsOneWidget);
      expect(find.byType(SBanner), findsOneWidget);
    });
  });
}
