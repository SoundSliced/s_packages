import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_watch/signals_watch.dart';

void main() {
  group('SignalsWatch v0.3.0 Features', () {
    group('Signal-level lifecycle callbacks', () {
      testWidgets('onInit callback is called when signal is created',
          (tester) async {
        var initCalled = false;
        int? initValue;

        final counter = SignalsWatch.signal(
          0,
          onInit: (value, _) {
            initCalled = true;
            initValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SignalsWatch.fromSignal(
              counter,
              builder: (value) => Text('$value'),
            ),
          ),
        );

        expect(initCalled, true);
        expect(initValue, 0);
      });

      testWidgets('onValueUpdated callback is called when signal changes',
          (tester) async {
        var updateCount = 0;
        int? oldValue;
        int? newValue;

        final counter = SignalsWatch.signal(
          0,
          onValueUpdated: (value, previous) {
            updateCount++;
            oldValue = previous;
            newValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SignalsWatch.fromSignal(
              counter,
              builder: (value) => Text('$value'),
            ),
          ),
        );

        expect(updateCount, 0);

        counter.value = 1;
        await tester.pump();

        expect(updateCount, 1);
        expect(oldValue, 0);
        expect(newValue, 1);
      });

      testWidgets('onAfterBuild callback is called after widget build',
          (tester) async {
        var afterBuildCalled = false;

        final counter = SignalsWatch.signal(
          0,
          onAfterBuild: (value, _) {
            afterBuildCalled = true;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SignalsWatch.fromSignal(
              counter,
              builder: (value) => Text('$value'),
            ),
          ),
        );

        expect(afterBuildCalled, true);
      });

      testWidgets('onDispose callback is called when widget is disposed',
          (tester) async {
        var disposeCalled = false;

        final counter = SignalsWatch.signal(
          0,
          onDispose: (value, _) {
            disposeCalled = true;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SignalsWatch.fromSignal(
              counter,
              builder: (value) => Text('$value'),
            ),
          ),
        );

        expect(disposeCalled, false);

        // Dispose the widget
        await tester.pumpWidget(const MaterialApp(home: SizedBox()));

        expect(disposeCalled, true);
      });
    });

    group('Widget callback override', () {
      testWidgets('widget onValueUpdated overrides signal callback',
          (tester) async {
        var signalUpdateCount = 0;
        var widgetUpdateCount = 0;

        final counter = SignalsWatch.signal(
          0,
          onValueUpdated: (value, _) {
            signalUpdateCount++;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SignalsWatch.fromSignal(
              counter,
              onValueUpdated: (value, _) {
                widgetUpdateCount++;
              },
              builder: (value) => Text('$value'),
            ),
          ),
        );

        counter.value = 1;
        await tester.pump();

        expect(signalUpdateCount, 0); // Signal callback shouldn't fire
        expect(widgetUpdateCount, 1); // Widget callback should fire
      });

      testWidgets('multiple widgets can have different callbacks',
          (tester) async {
        var widget1UpdateCount = 0;
        var widget2UpdateCount = 0;

        final counter = SignalsWatch.signal(0);

        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                SignalsWatch.fromSignal(
                  counter,
                  onValueUpdated: (value, _) {
                    widget1UpdateCount++;
                  },
                  builder: (value) => Text('Widget1: $value'),
                ),
                SignalsWatch.fromSignal(
                  counter,
                  onValueUpdated: (value, _) {
                    widget2UpdateCount++;
                  },
                  builder: (value) => Text('Widget2: $value'),
                ),
              ],
            ),
          ),
        );

        counter.value = 1;
        await tester.pump();

        expect(widget1UpdateCount, 1);
        expect(widget2UpdateCount, 1);
      });

      testWidgets('signal callback fires when no widget overrides',
          (tester) async {
        var signalUpdateCount = 0;

        final counter = SignalsWatch.signal(
          0,
          onValueUpdated: (value, _) {
            signalUpdateCount++;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SignalsWatch.fromSignal(
              counter,
              builder: (value) => Text('$value'),
            ),
          ),
        );

        counter.value = 1;
        await tester.pump();

        expect(signalUpdateCount, 1);
      });
    });

    group('.reset() method', () {
      testWidgets('reset() restores initial value', (tester) async {
        final counter = SignalsWatch.signal(
          5,
          onValueUpdated: (value, _) {},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SignalsWatch.fromSignal(
              counter,
              builder: (value) => Text('$value'),
            ),
          ),
        );

        expect(counter.value, 5);

        counter.value = 10;
        await tester.pump();
        expect(counter.value, 10);

        counter.reset();
        await tester.pump();
        expect(counter.value, 5);
      });

      testWidgets('reset() triggers callbacks', (tester) async {
        var updateCount = 0;

        final counter = SignalsWatch.signal(
          5,
          onValueUpdated: (value, _) {
            updateCount++;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SignalsWatch.fromSignal(
              counter,
              builder: (value) => Text('$value'),
            ),
          ),
        );

        counter.value = 10;
        await tester.pump();
        expect(updateCount, 1);

        counter.reset();
        await tester.pump();
        expect(updateCount, 2);
      });
    });

    group('.reset() method', () {
      testWidgets('reset() restores initial value', (tester) async {
        final counter = SignalsWatch.signal(
          5,
          onValueUpdated: (value, _) {},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SignalsWatch.fromSignal(
              counter,
              builder: (value) => Text('$value'),
            ),
          ),
        );

        expect(counter.value, 5);

        counter.value = 10;
        await tester.pump();
        expect(counter.value, 10);

        counter.reset();
        await tester.pump();
        expect(counter.value, 5);
      });

      testWidgets('reset() triggers callbacks', (tester) async {
        var updateCount = 0;

        final counter = SignalsWatch.signal(
          5,
          onValueUpdated: (value, _) {
            updateCount++;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SignalsWatch.fromSignal(
              counter,
              builder: (value) => Text('$value'),
            ),
          ),
        );

        counter.value = 10;
        await tester.pump();
        expect(updateCount, 1);

        counter.reset();
        await tester.pump();
        expect(updateCount, 2);
      });
    });

    group('Computed signals with callbacks', () {
      testWidgets('computed signals support lifecycle callbacks',
          (tester) async {
        var updateCount = 0;

        final counter = SignalsWatch.signal(0);
        final doubled = SignalsWatch.computed(
          () => counter.value * 2,
          onValueUpdated: (value, _) {
            updateCount++;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SignalsWatch.fromSignal(
              doubled,
              builder: (value) => Text('$value'),
            ),
          ),
        );

        expect(doubled.value, 0);

        counter.value = 5;
        await tester.pump();

        expect(doubled.value, 10);
        expect(updateCount, 1);
      });
    });

    group('Async signals with callbacks', () {
      testWidgets('fromFuture supports lifecycle callbacks', (tester) async {
        var initCalled = false;
        var updateCalled = false;

        final futureSignal = SignalsWatch.fromFuture(
          Future.value(42),
          initialValue: 0,
          onInit: (value, _) {
            initCalled = true;
          },
          onValueUpdated: (value, _) {
            updateCalled = true;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SignalsWatch.fromSignal(
              futureSignal,
              builder: (value) => Text('$value'),
            ),
          ),
        );

        expect(initCalled, true);

        // Wait for future to complete
        await tester.pumpAndSettle();

        expect(futureSignal.value, 42);
        expect(updateCalled, true);
      });

      testWidgets('fromStream supports lifecycle callbacks', (tester) async {
        var updateCount = 0;

        final stream = Stream.fromIterable([1, 2, 3]);
        final streamSignal = SignalsWatch.fromStream(
          stream,
          initialValue: 0,
          onValueUpdated: (value, _) {
            updateCount++;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SignalsWatch.fromSignal(
              streamSignal,
              builder: (value) => Text('$value'),
            ),
          ),
        );

        // Wait for stream events
        await tester.pumpAndSettle();

        expect(streamSignal.value, 3);
        expect(updateCount, 3); // One for each stream event
      });
    });

    group('Metadata storage', () {
      testWidgets('signals store custom metadata', (tester) async {
        final counter = SignalsWatch.signal(
          0,
          metadata: {'description': 'A counter', 'category': 'test'},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SignalsWatch.fromSignal(
              counter,
              builder: (value) => Text('$value'),
            ),
          ),
        );

        // Metadata is stored internally and can be retrieved via the signal
        expect(counter.value, 0);
      });
    });

    group('debugTrace option', () {
      testWidgets('debugTrace enables debug printing', (tester) async {
        final counter = SignalsWatch.signal(
          0,
          debugTrace: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SignalsWatch.fromSignal(
              counter,
              builder: (value) => Text('$value'),
            ),
          ),
        );

        counter.value = 1;
        await tester.pump();

        // debugTrace doesn't throw errors
        expect(counter.value, 1);
      });
    });

    group('Edge cases', () {
      testWidgets('multiple widgets observing same signal with callbacks',
          (tester) async {
        var signalUpdateCount = 0;

        final counter = SignalsWatch.signal(
          0,
          onValueUpdated: (value, _) {
            signalUpdateCount++;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                SignalsWatch.fromSignal(
                  counter,
                  builder: (value) => Text('Widget1: $value'),
                ),
                SignalsWatch.fromSignal(
                  counter,
                  builder: (value) => Text('Widget2: $value'),
                ),
              ],
            ),
          ),
        );

        counter.value = 1;
        await tester.pump();

        // Signal callback should fire only once, not per widget
        expect(signalUpdateCount, 1);
      });
    });
  });
}
