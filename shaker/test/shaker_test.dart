import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shaker/shaker.dart';

void main() {
  group('Shaker Widget Tests', () {
    testWidgets('Shaker widget renders child correctly',
        (WidgetTester tester) async {
      // Build the Shaker widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Shaker(
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      // Verify that the child is rendered
      expect(find.text('Test Child'), findsOneWidget);

      // Wait for any animations to complete
      await tester.pumpAndSettle();
    });

    testWidgets('Shaker widget accepts custom parameters',
        (WidgetTester tester) async {
      // Build the Shaker widget with custom parameters
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Shaker(
              isShaking: true,
              duration: const Duration(milliseconds: 1000),
              hz: 5,
              rotation: -0.04,
              offset: const Offset(0.3, 0.4),
              curve: Curves.easeInOut,
              child: const Icon(Icons.star),
            ),
          ),
        ),
      );

      // Verify that the child icon is rendered
      expect(find.byIcon(Icons.star), findsOneWidget);

      // Wait for animations to complete
      await tester.pumpAndSettle();
    });

    testWidgets('Shaker widget with isShaking false does not animate',
        (WidgetTester tester) async {
      // Build the Shaker widget with isShaking set to false
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Shaker(
              isShaking: false,
              child: Text('No Shake'),
            ),
          ),
        ),
      );

      // Verify that the child is rendered
      expect(find.text('No Shake'), findsOneWidget);

      // Pump frames to ensure no animation occurs
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('No Shake'), findsOneWidget);
    });

    testWidgets('Shaker widget with isShaking true triggers animation',
        (WidgetTester tester) async {
      bool onCompleteCalled = false;

      // Build the Shaker widget with isShaking set to true
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Shaker(
              isShaking: true,
              duration: const Duration(milliseconds: 500),
              onComplete: () {
                onCompleteCalled = true;
              },
              child: const Text('Shaking'),
            ),
          ),
        ),
      );

      // Verify that the child is rendered
      expect(find.text('Shaking'), findsOneWidget);

      // Pump frames to simulate animation
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Shaking'), findsOneWidget);

      // Pump and settle to complete the animation
      await tester.pumpAndSettle();

      // Verify onComplete callback was called
      expect(onCompleteCalled, true);
    });

    testWidgets('Shaker widget with different children renders correctly',
        (WidgetTester tester) async {
      // Test with Icon child
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Shaker(
              child: Icon(Icons.home),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.home), findsOneWidget);
      await tester.pumpAndSettle();

      // Test with Container child
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Shaker(
              child: Container(
                width: 50,
                height: 50,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );
      expect(find.byType(Container), findsWidgets);
      await tester.pumpAndSettle();
    });
  });
}
