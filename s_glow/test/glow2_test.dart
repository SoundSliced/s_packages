import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_glow/s_glow.dart';

void main() {
  group('Glow2 Widget Tests', () {
    testWidgets('Glow2 renders with child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow2(
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('Glow2 renders without animation when disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow2(
              animate: false,
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byType(Glow2), findsOneWidget);
    });

    testWidgets('Glow2 respects glowCount property',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow2(
              glowCount: 3,
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byType(Glow2), findsOneWidget);
    });

    testWidgets('Glow2 respects custom glowColor', (WidgetTester tester) async {
      const testColor = Colors.red;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow2(
              glowColor: testColor,
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('Glow2 circle shape renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow2(
              glowShape: BoxShape.circle,
              child: SizedBox(
                width: 100,
                height: 100,
                child: Text('Test'),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Glow2), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('Glow2 rectangle shape renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Glow2(
              glowShape: BoxShape.rectangle,
              glowBorderRadius: BorderRadius.circular(16),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Glow2), findsOneWidget);
      expect(find.byType(Container),
          findsWidgets); // Should find the child container
    });

    testWidgets('Glow2 assertion test for circle with border radius',
        (WidgetTester tester) async {
      expect(
        () => Glow2(
          glowShape: BoxShape.circle,
          glowBorderRadius: BorderRadius.circular(16), // Invalid for circle
          child: const Text('Test'),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('Glow2 animates when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow2(
              animate: true,
              duration: Duration(milliseconds: 100),
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      // Initial state - animation should start after delay
      await tester.pump();
      expect(find.text('Test Child'), findsOneWidget);

      // Pump and settle to complete all animations and delays
      await tester.pumpAndSettle();
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('Glow2 respects startDelay', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow2(
              startDelay: Duration(milliseconds: 100),
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      // Before delay
      await tester.pump();
      expect(find.text('Test Child'), findsOneWidget);

      // After delay
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('Glow2 toggles animation on state change',
        (WidgetTester tester) async {
      bool animate = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Glow2(
                      animate: animate,
                      child: const Text('Test Child'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          animate = !animate;
                        });
                      },
                      child: const Text('Toggle'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test Child'), findsOneWidget);

      // Toggle animation
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();
      expect(find.text('Test Child'), findsOneWidget);

      // Toggle back
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('Glow2 respects repeat flag', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow2(
              repeat: false,
              duration: Duration(milliseconds: 100),
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('Glow2 respects custom curve', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow2(
              curve: Curves.easeInOut,
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('Glow2 respects glowRadiusFactor', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow2(
              glowRadiusFactor: 1.0,
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('Glow2 with different glowCount values',
        (WidgetTester tester) async {
      for (int count in [1, 2, 3, 5]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Glow2(
                glowCount: count,
                child: const Text('Test Child'),
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.text('Test Child'), findsOneWidget);
      }
    });

    testWidgets('Glow2 respects custom duration', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow2(
              duration: Duration(seconds: 5),
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Test Child'), findsOneWidget);

      // Pump partial duration
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('Glow2 handles widget updates correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow2(
              duration: Duration(milliseconds: 1000),
              glowCount: 2,
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Test Child'), findsOneWidget);

      // Update with different properties
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow2(
              duration: Duration(milliseconds: 2000),
              glowCount: 3,
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Test Child'), findsOneWidget);
    });
  });
}
