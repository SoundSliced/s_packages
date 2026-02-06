// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_watch/signals_watch.dart';

void main() {
  testWidgets('debug silent update', (tester) async {
    var buildCount = 0;

    final counter = SignalsWatch.signal(0);

    await tester.pumpWidget(
      MaterialApp(
        home: SignalsWatch.fromSignal(
          counter,
          debugPrint: true,
          debugLabel: 'TestWidget',
          builder: (value) {
            buildCount++;
            print('Builder called, buildCount=$buildCount, value=$value');
            return Text('$value');
          },
        ),
      ),
    );

    print('=== Initial build complete, buildCount=$buildCount ===');

    // Normal update
    print('=== Setting counter.value = 1 ===');
    counter.value = 1;
    await tester.pump();
    print('=== After pump, buildCount=$buildCount ===');

    // Second normal update (silent updates removed in v0.3.0)
    print('=== Setting counter.value = 2 ===');
    counter.value = 2;
    await tester.pump();
    print('=== After pump, buildCount=$buildCount (should be 3) ===');

    // Verify value
    print('=== Final value: ${counter.value} ===');
  });
}
