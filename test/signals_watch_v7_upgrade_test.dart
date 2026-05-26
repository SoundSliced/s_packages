import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/s_packages.dart';

void main() {
  group('SignalsWatch v7 upgrade compatibility', () {
    testWidgets('supports zero-arg onValueUpdated callback', (tester) async {
      final counter = SignalsWatch.signal(0);
      var callbackCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SignalsWatch<int>.fromSignal(
              counter,
              onValueUpdated: () => callbackCalls++,
              builder: (value) => Text('count: $value'),
            ),
          ),
        ),
      );

      expect(callbackCalls, 0);
      expect(find.text('count: 0'), findsOneWidget);

      counter.value = 1;
      await tester.pump();

      expect(callbackCalls, 1);
      expect(find.text('count: 1'), findsOneWidget);
    });

    testWidgets('switching source signal updates active listener',
        (tester) async {
      final signalA = SignalsWatch.signal(0);
      final signalB = SignalsWatch.signal(100);
      var useSignalA = true;
      var callbackCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          useSignalA = false;
                        });
                      },
                      child: const Text('switch'),
                    ),
                    SignalsWatch<int>.fromSignal(
                      useSignalA ? signalA : signalB,
                      onValueUpdated: (_) => callbackCalls++,
                      builder: (value) => Text('value: $value'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('value: 0'), findsOneWidget);

      signalA.value = 1;
      await tester.pump();
      expect(callbackCalls, 1);
      expect(find.text('value: 1'), findsOneWidget);

      await tester.tap(find.text('switch'));
      await tester.pump();

      expect(find.text('value: 100'), findsOneWidget);

      signalA.value = 2;
      await tester.pump();
      expect(callbackCalls, 1);

      signalB.value = 101;
      await tester.pump();
      expect(callbackCalls, 2);
      expect(find.text('value: 101'), findsOneWidget);
    });
  });
}
