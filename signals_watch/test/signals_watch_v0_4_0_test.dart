import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_watch/signals_watch.dart';

void main() {
  group('v0.4.0 - .transform() extension', () {
    testWidgets('transforms signal value correctly', (tester) async {
      final counter = SignalsWatch.signal(5);

      await tester.pumpWidget(
        MaterialApp(
          home: counter.transform(
            (value) => value * 2,
            builder: (doubled) => Text('$doubled'),
          ),
        ),
      );

      expect(find.text('10'), findsOneWidget);

      counter.value = 3;
      await tester.pump();

      expect(find.text('6'), findsOneWidget);
    });

    testWidgets('handles errors in transformation', (tester) async {
      final counter = SignalsWatch.signal(5);
      Object? capturedError;

      await tester.pumpWidget(
        MaterialApp(
          home: counter.transform(
            (value) {
              if (value < 0) throw Exception('Negative!');
              return value * 2;
            },
            builder: (doubled) => Text('Result: $doubled'),
            onError: (error, stack) => capturedError = error,
            errorBuilder: (error) => Text('Error: ${error.toString()}'),
          ),
        ),
      );

      expect(find.text('Result: 10'), findsOneWidget);
      expect(capturedError, isNull);

      counter.value = -1;
      await tester.pump();

      expect(find.textContaining('Error:'), findsOneWidget);
      expect(find.textContaining('Negative'), findsOneWidget);
      expect(capturedError, isNotNull);
    });

    testWidgets('supports all lifecycle callbacks', (tester) async {
      final counter = SignalsWatch.signal(0);
      int? initValue;
      int? updatedValue;
      int? afterBuildValue;
      int? disposeValue;

      await tester.pumpWidget(
        MaterialApp(
          home: counter.transform(
            (value) => value * 2,
            builder: (doubled) => Text('$doubled'),
            onInit: (value) => initValue = value,
            onValueUpdated: (value) => updatedValue = value,
            onAfterBuild: (value) => afterBuildValue = value,
            onDispose: (value) => disposeValue = value,
          ),
        ),
      );

      await tester.pump();
      expect(initValue, 0);
      expect(afterBuildValue, 0);

      counter.value = 5;
      await tester.pump();
      expect(updatedValue, 10);
      expect(afterBuildValue, 10);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      expect(disposeValue, 10);
    });

    testWidgets('supports debouncing', (tester) async {
      final counter = SignalsWatch.signal(0);
      final values = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: counter.transform(
            (value) => value * 2,
            builder: (doubled) => Text('$doubled'),
            debounce: const Duration(milliseconds: 100),
            onValueUpdated: (value) => values.add(value),
          ),
        ),
      );

      counter.value = 1;
      counter.value = 2;
      counter.value = 3;
      await tester.pump(const Duration(milliseconds: 50));
      expect(values, isEmpty);

      await tester.pump(const Duration(milliseconds: 100));
      expect(values, [6]); // Only last value (3 * 2)
    });

    testWidgets('supports shouldRebuild', (tester) async {
      final counter = SignalsWatch.signal(0);
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: counter.transform(
            (value) => value * 2,
            builder: (doubled) {
              buildCount++;
              return Text('$doubled');
            },
            shouldRebuild: (newValue, oldValue) => newValue % 4 == 0,
          ),
        ),
      );

      expect(buildCount, 1); // Initial build

      counter.value = 1; // doubled = 2, not divisible by 4
      await tester.pump();
      expect(buildCount, 1); // No rebuild

      counter.value = 2; // doubled = 4, divisible by 4
      await tester.pump();
      expect(buildCount, 2); // Rebuild

      counter.value = 3; // doubled = 6, not divisible by 4
      await tester.pump();
      expect(buildCount, 2); // No rebuild

      counter.value = 4; // doubled = 8, divisible by 4
      await tester.pump();
      expect(buildCount, 3); // Rebuild
    });

    testWidgets('can chain with other transformations', (tester) async {
      final counter = SignalsWatch.signal(5);

      await tester.pumpWidget(
        MaterialApp(
          home: counter.transform(
            (value) => value * 2,
            builder: (doubled) => counter.transform(
              (value) => value + doubled,
              builder: (sum) => Text('$sum'),
            ),
          ),
        ),
      );

      // 5 * 2 = 10, 5 + 10 = 15
      expect(find.text('15'), findsOneWidget);

      counter.value = 3;
      await tester.pump();

      // 3 * 2 = 6, 3 + 6 = 9
      expect(find.text('9'), findsOneWidget);
    });

    testWidgets('supports type transformation', (tester) async {
      final intSignal = SignalsWatch.signal(42);

      await tester.pumpWidget(
        MaterialApp(
          home: intSignal.transform<String>(
            (value) => 'Number: $value',
            builder: (text) => Text(text),
          ),
        ),
      );

      expect(find.text('Number: 42'), findsOneWidget);

      intSignal.value = 100;
      await tester.pump();

      expect(find.text('Number: 100'), findsOneWidget);
    });

    testWidgets('supports errorBuilder for custom error UI', (tester) async {
      final counter = SignalsWatch.signal(5);

      await tester.pumpWidget(
        MaterialApp(
          home: counter.transform(
            (value) {
              if (value < 0) throw ArgumentError('Must be positive');
              return value * 2;
            },
            builder: (doubled) => Text('Success: $doubled'),
            errorBuilder: (error) => Container(
              color: Colors.red,
              child: Text('Custom Error: ${error.toString()}'),
            ),
          ),
        ),
      );

      expect(find.text('Success: 10'), findsOneWidget);

      counter.value = -5;
      await tester.pump();

      expect(find.textContaining('Custom Error'), findsOneWidget);
      expect(find.textContaining('Must be positive'), findsOneWidget);
    });

    testWidgets('reactively tracks source signal changes', (tester) async {
      final source = SignalsWatch.signal(1);
      final transformedValues = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: source.transform(
            (value) {
              final result = value * 3;
              return result;
            },
            builder: (result) => Text('$result'),
            onValueUpdated: (value) => transformedValues.add(value),
          ),
        ),
      );

      await tester.pump();

      source.value = 2;
      await tester.pump();
      source.value = 3;
      await tester.pump();
      source.value = 4;
      await tester.pump();

      expect(transformedValues, [6, 9, 12]);
    });
  });
}
