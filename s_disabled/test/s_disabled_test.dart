import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_disabled/s_disabled.dart';

void main() {
  group('SDisabled Widget Tests', () {
    testWidgets('SDisabled renders child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SDisabled(
              isDisabled: false,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('SDisabled displays child at full opacity when enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SDisabled(
              isDisabled: false,
              child: Container(
                key: const ValueKey('container'),
                color: Colors.blue,
                child: const Text('Test Child'),
              ),
            ),
          ),
        ),
      );

      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );

      expect(opacity.opacity, 1.0);
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('SDisabled reduces opacity when disabled with default value',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SDisabled(
              isDisabled: true,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );

      expect(opacity.opacity, 0.3);
    });

    testWidgets('SDisabled respects custom opacity value',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SDisabled(
              isDisabled: true,
              opacityWhenDisabled: 0.7,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );

      expect(opacity.opacity, 0.7);
    });

    testWidgets('SDisabled can disable opacity change',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SDisabled(
              isDisabled: true,
              disableOpacityChange: true,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );

      expect(opacity.opacity, 1.0);
    });

    testWidgets('SDisabled prevents interaction when disabled',
        (WidgetTester tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SDisabled(
              isDisabled: true,
              child: ElevatedButton(
                onPressed: () {
                  buttonPressed = true;
                },
                child: const Text('Click Me'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(buttonPressed, false);
    });

    testWidgets('SDisabled allows interaction when enabled',
        (WidgetTester tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SDisabled(
              isDisabled: false,
              child: ElevatedButton(
                onPressed: () {
                  buttonPressed = true;
                },
                child: const Text('Click Me'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(buttonPressed, true);
    });

    testWidgets('SDisabled calls onTappedWhenDisabled callback',
        (WidgetTester tester) async {
      Offset? tappedOffset;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SDisabled(
              isDisabled: true,
              onTappedWhenDisabled: (offset) {
                tappedOffset = offset;
              },
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
                child: const Text('Tap Me'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Container), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(tappedOffset, isNotNull);
      expect(tappedOffset!.dx, greaterThanOrEqualTo(0));
      expect(tappedOffset!.dy, greaterThanOrEqualTo(0));
    });

    testWidgets('SDisabled animates opacity transition',
        (WidgetTester tester) async {
      bool isDisabled = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    SDisabled(
                      isDisabled: isDisabled,
                      child: const Text('Test Child'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isDisabled = !isDisabled;
                        });
                      },
                      child: const Text('Toggle'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
        1.0,
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 200));
      final midAnimationOpacity =
          tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;
      expect(midAnimationOpacity, lessThan(1.0));
      expect(midAnimationOpacity, greaterThanOrEqualTo(0.3));

      await tester.pumpAndSettle();

      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
        0.3,
      );
    });

    testWidgets('SDisabled works with different child widgets',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SDisabled(
                  isDisabled: true,
                  child: const TextField(),
                ),
                SDisabled(
                  isDisabled: true,
                  child: Checkbox(
                    value: true,
                    onChanged: (_) {},
                  ),
                ),
                SDisabled(
                  isDisabled: true,
                  child: const Icon(Icons.favorite),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('SDisabled with AbsorbPointer blocks pointer events',
        (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SDisabled(
              isDisabled: true,
              child: GestureDetector(
                onTap: () => tapCount++,
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Container), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(tapCount, 0);
    });

    testWidgets(
      'SDisabled opacity animation duration is correct',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SDisabled(
                isDisabled: true,
                child: const Text('Test'),
              ),
            ),
          ),
        );

        final animatedOpacity =
            tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));

        expect(animatedOpacity.duration, const Duration(milliseconds: 300));
      },
    );

    testWidgets('SDisabled can handle rapid state changes',
        (WidgetTester tester) async {
      bool isDisabled = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    SDisabled(
                      isDisabled: isDisabled,
                      child: const Text('Test Child'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isDisabled = !isDisabled;
                        });
                      },
                      child: const Text('Toggle'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
      }

      await tester.pumpAndSettle();

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('SDisabled preserves child widget state',
        (WidgetTester tester) async {
      bool isDisabled = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    SDisabled(
                      isDisabled: isDisabled,
                      child: TextField(
                        key: const ValueKey('textfield'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isDisabled = !isDisabled;
                        });
                      },
                      child: const Text('Toggle'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      final textFieldFinder = find.byKey(const ValueKey('textfield'));
      expect(textFieldFinder, findsOneWidget);

      await tester.enterText(textFieldFinder, 'Test input');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('SDisabled handles null callback gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SDisabled(
              isDisabled: true,
              onTappedWhenDisabled: null,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Container), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsOneWidget);
    });
  });
}
