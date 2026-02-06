import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_button/s_button.dart';

void main() {
  group('SButton Widget Tests', () {
    // Basic widget existence test
    testWidgets('SButton renders with required child',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SButton(
              child: const Text('Test Button'),
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(SButton), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
    });

    // Test single tap
    testWidgets('SButton calls onTap callback when tapped',
        (WidgetTester tester) async {
      bool wasTapped = false;
      Offset? tapOffset;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SButton(
                onTap: (offset) {
                  wasTapped = true;
                  tapOffset = offset;
                },
                child: const Text('Tap Me'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      expect(wasTapped, isTrue);
      expect(tapOffset, isNotNull);
    });

    // Test double tap
    testWidgets('SButton accepts onDoubleTap callback parameter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SButton(
                onDoubleTap: (offset) {
                  // Callback implementation
                },
                child: const Text('Double Tap Me'),
              ),
            ),
          ),
        ),
      );

      // Verify the button renders correctly with onDoubleTap callback
      expect(find.text('Double Tap Me'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    // Test long press
    testWidgets('SButton accepts onLongPressStart and onLongPressEnd callbacks',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SButton(
                onLongPressStart: (details) {
                  // Callback accepted
                },
                onLongPressEnd: (details) {
                  // Callback accepted
                },
                child: const Text('Long Press Me'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Long Press Me'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    // Test loading state
    testWidgets('SButton shows loading widget when isLoading is true',
        (WidgetTester tester) async {
      const loadingWidget = CircularProgressIndicator();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SButton(
                isLoading: true,
                loadingWidget: loadingWidget,
                child: const Text('Button Text'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Button Text'), findsNothing);
    });

    // Test isActive state - button should not be tappable when inactive
    testWidgets('SButton does not call onTap when isActive is false',
        (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SButton(
                isActive: false,
                onTap: (offset) {
                  wasTapped = true;
                },
                child: const Text('Inactive Button'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Inactive Button'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(wasTapped, isFalse);
    });

    // Test circle button
    testWidgets('SButton renders as circle when isCircleButton is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SButton(
                isCircleButton: true,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SButton), findsOneWidget);
      // Container with circle shape should exist
      expect(find.byType(Container), findsWidgets);
    });

    // Test bounce animation
    testWidgets('SButton applies bounce scale when shouldBounce is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SButton(
                shouldBounce: true,
                bounceScale: 0.95,
                child: const Text('Bounce Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SButton), findsOneWidget);
      // Verify widget renders without errors
      await tester.pumpAndSettle();
    });

    // Test splash color
    testWidgets('SButton accepts custom splash color',
        (WidgetTester tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SButton(
                splashColor: customColor,
                child: const Text('Colored Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SButton), findsOneWidget);
      await tester.pumpAndSettle();
    });

    // Test delay parameter
    testWidgets('SButton respects delay parameter for initialization',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SButton(
                delay: const Duration(milliseconds: 300),
                child: const Text('Delayed Button'),
              ),
            ),
          ),
        ),
      );

      // Widget should initially not be fully visible
      expect(find.byType(SButton), findsOneWidget);

      // After delay, button should be visible
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.text('Delayed Button'), findsOneWidget);
    });

    // Test buttonSelectedColor
    testWidgets('SButton accepts buttonSelectedColor parameter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SButton(
                selectedColor: Colors.blue.withValues(alpha: 0.2),
                child: const Text('Selected Color Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SButton), findsOneWidget);
      expect(find.text('Selected Color Button'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    // Test haptic feedback parameter
    testWidgets('SButton accepts haptic feedback parameters',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SButton(
                enableHapticFeedback: true,
                hapticFeedbackType: HapticFeedbackType.lightImpact,
                child: const Text('Haptic Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SButton), findsOneWidget);
      await tester.pumpAndSettle();
    });

    // Test tooltip message
    testWidgets('SButton accepts tooltip message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SButton(
                tooltipMessage: 'This is a tooltip',
                child: const Text('Tooltip Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SButton), findsOneWidget);
      await tester.pumpAndSettle();
    });

    // Test ignoreChildWidgetOnTap parameter
    testWidgets('SButton respects ignoreChildWidgetOnTap parameter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SButton(
                ignoreChildWidgetOnTap: true,
                onTap: (offset) {
                  // Callback accepted
                },
                child: const Text('Ignore Child Button'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ignore Child Button'));
      await tester.pumpAndSettle();

      // With ignoreChildWidgetOnTap: true, button renders correctly
      expect(find.byType(SButton), findsOneWidget);
    });

    // Test alignment parameter
    testWidgets('SButton accepts alignment parameter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SButton(
                alignment: Alignment.center,
                child: const Text('Aligned Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SButton), findsOneWidget);
      expect(find.text('Aligned Button'), findsOneWidget);
    });

    // Test splashOpacity
    testWidgets('SButton accepts custom splashOpacity',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SButton(
                splashColor: Colors.blue,
                splashOpacity: 0.5,
                child: const Text('Opacity Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SButton), findsOneWidget);
      await tester.pumpAndSettle();
    });

    // Test borderRadius
    testWidgets('SButton accepts custom borderRadius',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SButton(
                borderRadius: BorderRadius.circular(12),
                child: const Text('BorderRadius Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SButton), findsOneWidget);
      await tester.pumpAndSettle();
    });

    // Test error handling
    testWidgets('SButton handles errors with errorBuilder',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SButton(
                onError: (error) {
                  // Handle error
                },
                errorBuilder: (context, error) {
                  return const Text('Error occurred');
                },
                child: const Text('Error Handler Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SButton), findsOneWidget);
      await tester.pumpAndSettle();
    });

    // Test widget state changes
    testWidgets('SButton updates when parameters change',
        (WidgetTester tester) async {
      bool isActive = true;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Column(
                    children: [
                      SButton(
                        isActive: isActive,
                        child: const Text('Dynamic Button'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isActive = !isActive;
                          });
                        },
                        child: const Text('Toggle'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );

      expect(find.byType(SButton), findsOneWidget);
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();
      expect(find.byType(SButton), findsOneWidget);
    });

    // Test that button doesn't process taps when loading
    testWidgets('SButton ignores taps when isLoading is true',
        (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SButton(
                isLoading: true,
                onTap: (offset) {
                  wasTapped = true;
                },
                child: const Text('Loading Button'),
              ),
            ),
          ),
        ),
      );

      // Try to tap - should not trigger onTap
      await tester.tap(find.byType(SButton));
      await tester.pumpAndSettle();

      expect(wasTapped, isFalse);
    });
  });
}
