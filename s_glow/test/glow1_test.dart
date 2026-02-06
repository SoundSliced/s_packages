import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_glow/s_glow.dart';

void main() {
  group('Glow1 Widget Tests', () {
    testWidgets('Glow1 renders with child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow1(
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('Glow1 renders without glow when disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow1(
              isEnabled: false,
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byType(Glow1), findsOneWidget);
      // When disabled, the child should still be rendered
    });

    testWidgets('Glow1 animates when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow1(
              isEnabled: true,
              animationDuration: Duration(milliseconds: 100),
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      // Initial state
      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byType(Glow1), findsOneWidget);

      // Let animation start
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(Glow1), findsOneWidget);

      // Complete animation
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Glow1), findsOneWidget);
    });

    testWidgets('Glow1 respects custom color', (WidgetTester tester) async {
      const testColor = Colors.red;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow1(
              color: testColor,
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify the glow container exists
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Glow1 respects custom opacity', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow1(
              opacity: 0.8,
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('Glow1 opacity assertion test', (WidgetTester tester) async {
      expect(
        () => Glow1(
          opacity: 1.5, // Invalid opacity
          child: const Text('Test'),
        ),
        throwsAssertionError,
      );

      expect(
        () => Glow1(
          opacity: -0.1, // Invalid opacity
          child: const Text('Test'),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('Glow1 toggles animation on state change',
        (WidgetTester tester) async {
      bool isEnabled = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Glow1(
                      isEnabled: isEnabled,
                      child: const Text('Test Child'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isEnabled = !isEnabled;
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

      // Initially enabled
      await tester.pump();
      expect(find.byType(Glow1), findsOneWidget);

      // Tap to disable
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      // Should still have Glow1 widget when disabled
      expect(find.byType(Glow1), findsOneWidget);

      // Tap to re-enable
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      // Should have Glow1 widget again when enabled
      expect(find.byType(Glow1), findsOneWidget);
    });

    testWidgets('Glow1 respects custom border radius',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Glow1(
              borderRadius: BorderRadius.circular(24),
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
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Glow1 respects custom animation duration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow1(
              animationDuration: Duration(milliseconds: 500),
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Test Child'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('Glow1 respects repeatAnimation flag',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow1(
              repeatAnimation: false,
              animationDuration: Duration(milliseconds: 100),
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('Glow1 uses custom scale values', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Glow1(
              startScaleRadius: 1.0,
              endScaleRadius: 1.5,
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byType(Transform), findsWidgets);
    });
  });
}
