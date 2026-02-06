import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticker_free_circular_progress_indicator/ticker_free_circular_progress_indicator.dart';

void main() {
  group('TickerFreeCircularProgressIndicator', () {
    testWidgets('should render indeterminate progress indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TickerFreeCircularProgressIndicator(),
          ),
        ),
      );

      expect(find.byType(TickerFreeCircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render determinate progress indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TickerFreeCircularProgressIndicator(value: 0.5),
          ),
        ),
      );

      expect(find.byType(TickerFreeCircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should accept custom color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TickerFreeCircularProgressIndicator(
              color: Colors.red,
            ),
          ),
        ),
      );

      expect(find.byType(TickerFreeCircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should accept custom stroke width',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TickerFreeCircularProgressIndicator(
              strokeWidth: 8.0,
            ),
          ),
        ),
      );

      expect(find.byType(TickerFreeCircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should accept background color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TickerFreeCircularProgressIndicator(
              backgroundColor: Colors.grey,
            ),
          ),
        ),
      );

      expect(find.byType(TickerFreeCircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should accept stroke cap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TickerFreeCircularProgressIndicator(
              strokeCap: StrokeCap.round,
            ),
          ),
        ),
      );

      expect(find.byType(TickerFreeCircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should accept stroke align', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TickerFreeCircularProgressIndicator(
              strokeAlign: -1.0,
            ),
          ),
        ),
      );

      expect(find.byType(TickerFreeCircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle delay and default widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TickerFreeCircularProgressIndicator(
              delay: Duration(seconds: 1),
              defaultWidgetAfterDelay: Text('Delayed widget'),
            ),
          ),
        ),
      );

      expect(find.byType(TickerFreeCircularProgressIndicator), findsOneWidget);
      expect(find.text('Delayed widget'), findsNothing);

      // Wait for the delay to expire
      await tester.pump(const Duration(seconds: 1));

      // The default widget should now be visible
      expect(find.text('Delayed widget'), findsOneWidget);
    });

    testWidgets('should accept semantics labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TickerFreeCircularProgressIndicator(
              semanticsLabel: 'Loading progress',
              semanticsValue: '50%',
            ),
          ),
        ),
      );

      expect(find.byType(TickerFreeCircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should animate indeterminate progress indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TickerFreeCircularProgressIndicator(),
          ),
        ),
      );

      expect(find.byType(TickerFreeCircularProgressIndicator), findsOneWidget);

      // Pump some frames to ensure animation is working
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(TickerFreeCircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(TickerFreeCircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should switch between determinate and indeterminate',
        (WidgetTester tester) async {
      double? progressValue = 0.5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return TickerFreeCircularProgressIndicator(
                  value: progressValue,
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(TickerFreeCircularProgressIndicator), findsOneWidget);

      // Change to indeterminate
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TickerFreeCircularProgressIndicator(
              value: null,
            ),
          ),
        ),
      );

      expect(find.byType(TickerFreeCircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should update progress value', (WidgetTester tester) async {
      double progressValue = 0.3;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    TickerFreeCircularProgressIndicator(
                      value: progressValue,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          progressValue = 0.8;
                        });
                      },
                      child: const Text('Update'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(TickerFreeCircularProgressIndicator), findsOneWidget);

      // Tap button to update progress
      await tester.tap(find.text('Update'));
      await tester.pump();

      expect(find.byType(TickerFreeCircularProgressIndicator), findsOneWidget);
    });
  });
}
