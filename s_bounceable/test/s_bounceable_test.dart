import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:s_bounceable/s_bounceable.dart';

void main() {
  group('SBounceable Widget Tests', () {
    testWidgets('SBounceable renders child correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SBounceable(
            child: Text('Test Child'),
          ),
        ),
      );
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('SBounceable single tap triggers onTap',
        (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: SBounceable(
            onTap: () => tapped = true,
            child: const Text('Tap'),
          ),
        ),
      );
      await tester.tap(find.text('Tap'));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));
      expect(tapped, isTrue);
    });

    testWidgets('SBounceable double tap triggers onDoubleTap',
        (WidgetTester tester) async {
      bool doubleTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: SBounceable(
            onDoubleTap: () => doubleTapped = true,
            child: const Text('Double Tap'),
          ),
        ),
      );
      await tester.tap(find.text('Double Tap'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Double Tap'));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));
      expect(doubleTapped, isTrue);
    });

    testWidgets('SBounceable double tap does not trigger onTap',
        (WidgetTester tester) async {
      bool singleTapped = false;
      bool doubleTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: SBounceable(
            onTap: () => singleTapped = true,
            onDoubleTap: () => doubleTapped = true,
            child: const Text('Tap Test'),
          ),
        ),
      );
      await tester.tap(find.text('Tap Test'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Tap Test'));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));
      expect(doubleTapped, isTrue);
      expect(singleTapped, isFalse);
    });

    testWidgets('SBounceable works with custom scaleFactor',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SBounceable(
            scaleFactor: 0.90,
            onTap: () {},
            child: const Text('Custom Scale'),
          ),
        ),
      );
      expect(find.text('Custom Scale'), findsOneWidget);
    });

    testWidgets('SBounceable works with onTap only',
        (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: SBounceable(
            onTap: () => tapped = true,
            child: const Text('Single Only'),
          ),
        ),
      );
      await tester.tap(find.text('Single Only'));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));
      expect(tapped, isTrue);
    });

    testWidgets('SBounceable works with onDoubleTap only',
        (WidgetTester tester) async {
      bool doubleTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: SBounceable(
            onDoubleTap: () => doubleTapped = true,
            child: const Text('Double Only'),
          ),
        ),
      );
      await tester.tap(find.text('Double Only'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Double Only'));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));
      expect(doubleTapped, isTrue);
    });

    testWidgets('SBounceable handles rapid taps correctly',
        (WidgetTester tester) async {
      int tapCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: SBounceable(
            onTap: () => tapCount++,
            child: const Text('Rapid Tap'),
          ),
        ),
      );
      // First tap
      await tester.tap(find.text('Rapid Tap'));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));
      expect(tapCount, equals(1));

      // Second tap (after threshold)
      await tester.tap(find.text('Rapid Tap'));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));
      expect(tapCount, equals(2));
    });
  });
}
