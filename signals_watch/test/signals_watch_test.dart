import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_watch/signals_watch.dart';

void main() {
  group('SignalsWatch.fromSignal', () {
    testWidgets('renders initial value', (tester) async {
      final counter = SignalsWatch.signal(0);

      await tester.pumpWidget(
        MaterialApp(
          home: SignalsWatch.fromSignal(
            counter,
            builder: (value) => Text('$value'),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('rebuilds on value change', (tester) async {
      final counter = SignalsWatch.signal(0);

      await tester.pumpWidget(
        MaterialApp(
          home: SignalsWatch.fromSignal(
            counter,
            builder: (value) => Text('$value'),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      counter.value = 5;
      await tester.pump();

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('calls onInit once', (tester) async {
      final counter = SignalsWatch.signal(0);
      int initCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: SignalsWatch.fromSignal(
            counter,
            onInit: (value) => initCount++,
            builder: (value) => Text('$value'),
          ),
        ),
      );

      expect(initCount, 1);

      counter.value = 5;
      await tester.pump();

      expect(initCount, 1); // Still 1, not called again
    });

    testWidgets('calls onValueUpdated on changes', (tester) async {
      final counter = SignalsWatch.signal(0);
      final updates = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: SignalsWatch.fromSignal(
            counter,
            onValueUpdated: (value) => updates.add(value),
            builder: (value) => Text('$value'),
          ),
        ),
      );

      expect(updates, isEmpty); // Not called on init

      counter.value = 1;
      await tester.pump();
      expect(updates, [1]);

      counter.value = 2;
      await tester.pump();
      expect(updates, [1, 2]);
    });

    testWidgets('passes previous value to callbacks', (tester) async {
      final counter = SignalsWatch.signal(0);
      final changes = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: SignalsWatch.fromSignal(
            counter,
            onValueUpdated: (value, previous) {
              changes.add('$previous -> $value');
            },
            builder: (value) => Text('$value'),
          ),
        ),
      );

      counter.value = 1;
      await tester.pump();
      expect(changes, ['0 -> 1']);

      counter.value = 5;
      await tester.pump();
      expect(changes, ['0 -> 1', '1 -> 5']);
    });

    testWidgets('calls onDispose when removed', (tester) async {
      final counter = SignalsWatch.signal(0);
      bool disposed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SignalsWatch.fromSignal(
            counter,
            onDispose: (value) => disposed = true,
            builder: (value) => Text('$value'),
          ),
        ),
      );

      expect(disposed, false);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      expect(disposed, true);
    });
  });

  group('SignalsWatch conditional updates', () {
    testWidgets('shouldRebuild controls rebuilds', (tester) async {
      final counter = SignalsWatch.signal(0);
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: SignalsWatch.fromSignal(
            counter,
            shouldRebuild: (newValue, oldValue) => newValue % 2 == 0,
            builder: (value) {
              buildCount++;
              return Text('$value');
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(find.text('0'), findsOneWidget);

      counter.value = 1; // Odd, should not rebuild
      await tester.pump();
      expect(buildCount, 1); // No rebuild
      expect(find.text('0'), findsOneWidget); // Still shows 0

      counter.value = 2; // Even, should rebuild
      await tester.pump();
      expect(buildCount, 2);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('shouldNotify controls callbacks', (tester) async {
      final counter = SignalsWatch.signal(0);
      final notified = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: SignalsWatch.fromSignal(
            counter,
            shouldNotify: (value, _) => value > 5,
            onValueUpdated: (value) => notified.add(value),
            builder: (value) => Text('$value'),
          ),
        ),
      );

      counter.value = 3; // Below threshold
      await tester.pump();
      expect(notified, isEmpty);

      counter.value = 6; // Above threshold
      await tester.pump();
      expect(notified, [6]);
    });

    testWidgets('custom equals prevents unnecessary updates', (tester) async {
      final signal1 = SignalsWatch.signal(User('John', 25));
      final updates = <User>[];

      await tester.pumpWidget(
        MaterialApp(
          home: SignalsWatch.fromSignal(
            signal1,
            equals: (a, b) => a.name == b.name, // Only compare names
            onValueUpdated: (value) => updates.add(value),
            builder: (value) => Text(value.name),
          ),
        ),
      );

      // Change age only (same name)
      signal1.value = User('John', 26);
      await tester.pump();
      expect(updates, isEmpty); // Not notified due to custom equals

      // Change name
      signal1.value = User('Jane', 26);
      await tester.pump();
      expect(updates.length, 1);
      expect(updates[0].name, 'Jane');
    });
  });

  group('SignalsWatch timing control', () {
    testWidgets('debounce delays callbacks', (tester) async {
      final counter = SignalsWatch.signal(0);
      final updates = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: SignalsWatch.fromSignal(
            counter,
            debounce: const Duration(milliseconds: 100),
            onValueUpdated: (value) => updates.add(value),
            builder: (value) => Text('$value'),
          ),
        ),
      );

      counter.value = 1;
      await tester.pump();
      expect(updates, isEmpty); // Not yet called

      counter.value = 2;
      await tester.pump();
      expect(updates, isEmpty); // Still waiting

      await tester.pump(const Duration(milliseconds: 100));
      expect(updates, [2]); // Called with latest value
    });

    testWidgets('throttle limits update frequency', (tester) async {
      final counter = SignalsWatch.signal(0);
      final updates = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: SignalsWatch.fromSignal(
            counter,
            throttle: const Duration(milliseconds: 100),
            onValueUpdated: (value) => updates.add(value),
            builder: (value) => Text('$value'),
          ),
        ),
      );

      counter.value = 1;
      await tester.pump();
      expect(updates, [1]); // First call immediate

      counter.value = 2;
      await tester.pump();
      expect(updates, [1]); // Throttled, not called

      await tester.pump(const Duration(milliseconds: 100));
      counter.value = 3;
      await tester.pump();
      expect(updates, [1, 3]); // Now allowed
    });
  });

  group('SignalsWatch.select', () {
    testWidgets('only rebuilds when selected value changes', (tester) async {
      final userSignal = SignalsWatch.signal(User('John', 25));
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: SignalsWatch.select(
            userSignal,
            selector: (user) => user.age,
            builder: (age) {
              buildCount++;
              return Text('$age');
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(find.text('25'), findsOneWidget);

      // Change name only (age unchanged)
      userSignal.value = User('Jane', 25);
      await tester.pump();
      expect(buildCount, 1); // No rebuild
      expect(find.text('25'), findsOneWidget);

      // Change age
      userSignal.value = User('Jane', 26);
      await tester.pump();
      expect(buildCount, 2); // Rebuild
      expect(find.text('26'), findsOneWidget);
    });
  });

  group('SignalsWatch.fromSignals', () {
    testWidgets('combines multiple signals', (tester) async {
      final firstName = SignalsWatch.signal('John');
      final lastName = SignalsWatch.signal('Doe');

      await tester.pumpWidget(
        MaterialApp(
          home: SignalsWatch.fromSignals(
            [firstName, lastName],
            combine: (values) => '${values[0]} ${values[1]}',
            builder: (fullName) => Text(fullName),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);

      firstName.value = 'Jane';
      await tester.pump();
      expect(find.text('Jane Doe'), findsOneWidget);

      lastName.value = 'Smith';
      await tester.pump();
      expect(find.text('Jane Smith'), findsOneWidget);
    });
  });

  group('SignalsWatch error handling', () {
    testWidgets('catches errors in read function', (tester) async {
      final shouldError = SignalsWatch.signal(false);

      await tester.pumpWidget(
        MaterialApp(
          home: SignalsWatch(
            read: () {
              if (shouldError.value) throw Exception('Test error');
              return 'OK';
            },
            builder: (value) => Text(value),
          ),
        ),
      );

      expect(find.text('OK'), findsOneWidget);

      shouldError.value = true;
      await tester.pump();

      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('calls onError callback', (tester) async {
      final shouldError = SignalsWatch.signal(false);
      Object? caughtError;

      await tester.pumpWidget(
        MaterialApp(
          home: SignalsWatch(
            read: () {
              if (shouldError.value) throw Exception('Test error');
              return 'OK';
            },
            onError: (error, stack) => caughtError = error,
            builder: (value) => Text(value),
          ),
        ),
      );

      shouldError.value = true;
      await tester.pump();

      expect(caughtError, isNotNull);
      expect(caughtError.toString(), contains('Test error'));
    });

    testWidgets('uses custom errorBuilder', (tester) async {
      final shouldError = SignalsWatch.signal(false);

      await tester.pumpWidget(
        MaterialApp(
          home: SignalsWatch(
            read: () {
              if (shouldError.value) throw Exception('Test error');
              return 'OK';
            },
            errorBuilder: (error) => const Text('Custom Error'),
            builder: (value) => Text(value),
          ),
        ),
      );

      shouldError.value = true;
      await tester.pump();

      expect(find.text('Custom Error'), findsOneWidget);
    });
  });

  group('SignalsWatch cleanup', () {
    testWidgets('cancels debounce timer on dispose', (tester) async {
      final counter = SignalsWatch.signal(0);
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SignalsWatch.fromSignal(
            counter,
            debounce: const Duration(milliseconds: 100),
            onValueUpdated: (value) => callbackCalled = true,
            builder: (value) => Text('$value'),
          ),
        ),
      );

      counter.value = 1;
      await tester.pump();

      // Dispose before debounce completes
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      // Wait for debounce duration
      await tester.pump(const Duration(milliseconds: 100));

      // Callback should not be called
      expect(callbackCalled, false);
    });
  });

  group('SignalObserveExtension', () {
    testWidgets('renders using fluent .observe() syntax', (tester) async {
      final counter = SignalsWatch.signal(0);

      await tester.pumpWidget(
        MaterialApp(
          home: counter.observe((value) => Text('$value')),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('rebuilds on value change with .observe()', (tester) async {
      final counter = SignalsWatch.signal(0);

      await tester.pumpWidget(
        MaterialApp(
          home: counter.observe((value) => Text('$value')),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      counter.value = 5;
      await tester.pump();

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('supports all parameters with .observe()', (tester) async {
      final counter = SignalsWatch.signal(0);
      int initCount = 0;
      final updates = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: counter.observe(
            (value) => Text('$value'),
            onInit: (value) => initCount++,
            onValueUpdated: (value) => updates.add(value),
            debounce: const Duration(milliseconds: 50),
          ),
        ),
      );

      expect(initCount, 1);
      expect(find.text('0'), findsOneWidget);

      counter.value = 1;
      await tester.pump();
      expect(updates, isEmpty); // Debounced

      await tester.pump(const Duration(milliseconds: 50));
      expect(updates, [1]);
    });

    testWidgets('works with computed signals', (tester) async {
      final counter = SignalsWatch.signal(0);
      final doubled = SignalsWatch.computed(() => counter.value * 2);

      await tester.pumpWidget(
        MaterialApp(
          home: doubled.observe((value) => Text('$value')),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      counter.value = 5;
      await tester.pump();

      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('works with fromFuture signals', (tester) async {
      final futureSignal = SignalsWatch.fromFuture(
        Future.delayed(const Duration(milliseconds: 10), () => 42),
        initialValue: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: futureSignal.observe((value) => Text('$value')),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('works with fromStream signals', (tester) async {
      final streamController = StreamController<int>();
      final streamSignal = SignalsWatch.fromStream(
        streamController.stream,
        initialValue: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: streamSignal.observe((value) => Text('$value')),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      streamController.add(99);
      await tester.pump();
      expect(find.text('99'), findsOneWidget);

      streamController.close();
    });

    testWidgets('.selectObserve() only rebuilds when selected value changes',
        (tester) async {
      final userSignal = SignalsWatch.signal(User('John', 25));
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: userSignal.selectObserve(
            (user) => (user as User).age,
            (age) {
              buildCount++;
              return Text('$age');
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(find.text('25'), findsOneWidget);

      // Change name only (age unchanged)
      userSignal.value = User('Jane', 25);
      await tester.pump();
      expect(buildCount, 1); // No rebuild
      expect(find.text('25'), findsOneWidget);

      // Change age
      userSignal.value = User('Jane', 26);
      await tester.pump();
      expect(buildCount, 2); // Rebuild
      expect(find.text('26'), findsOneWidget);
    });

    testWidgets('.selectObserve() supports all parameters', (tester) async {
      final userSignal = SignalsWatch.signal(User('John', 25));
      final updates = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: userSignal.selectObserve(
            (user) => (user as User).age,
            (age) => Text('$age'),
            onValueUpdated: (age) => updates.add(age),
          ),
        ),
      );

      userSignal.value = User('John', 26);
      await tester.pump();
      expect(updates, [26]);
    });
  });

  group('SignalListObserveExtension', () {
    testWidgets('combines multiple signals with .observe()', (tester) async {
      final firstName = SignalsWatch.signal('John');
      final lastName = SignalsWatch.signal('Doe');

      await tester.pumpWidget(
        MaterialApp(
          home: [firstName, lastName].observe(
            combine: (values) => '${values[0]} ${values[1]}',
            builder: (fullName) => Text(fullName),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);

      firstName.value = 'Jane';
      await tester.pump();
      expect(find.text('Jane Doe'), findsOneWidget);

      lastName.value = 'Smith';
      await tester.pump();
      expect(find.text('Jane Smith'), findsOneWidget);
    });

    testWidgets('list .observe() supports all parameters', (tester) async {
      final firstName = SignalsWatch.signal('John');
      final lastName = SignalsWatch.signal('Doe');
      final updates = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: [firstName, lastName].observe(
            combine: (values) => '${values[0]} ${values[1]}',
            builder: (fullName) => Text(fullName),
            onValueUpdated: (fullName) => updates.add(fullName),
          ),
        ),
      );

      firstName.value = 'Jane';
      await tester.pump();
      expect(updates, ['Jane Doe']);

      lastName.value = 'Smith';
      await tester.pump();
      expect(updates, ['Jane Doe', 'Jane Smith']);
    });

    testWidgets('list .observe() works with different signal types',
        (tester) async {
      final counter = SignalsWatch.signal(5);
      final doubled = SignalsWatch.computed(() => counter.value * 2);

      await tester.pumpWidget(
        MaterialApp(
          home: [counter, doubled].observe(
            combine: (values) => (values[0] as int) + (values[1] as int),
            builder: (sum) => Text('$sum'),
          ),
        ),
      );

      expect(find.text('15'), findsOneWidget); // 5 + 10

      counter.value = 10;
      await tester.pump();
      expect(find.text('30'), findsOneWidget); // 10 + 20
    });
  });
}

class User {
  final String name;
  final int age;

  User(this.name, this.age);

  @override
  String toString() => 'User(name: $name, age: $age)';
}
