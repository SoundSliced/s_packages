import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:post_frame/post_frame.dart';

void main() {
  testWidgets('PostFrame.repeat runs specified number of iterations',
      (tester) async {
    int observed = 0;
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));

    final repeater = PostFrame.repeat((i) {
      observed = i + 1; // iterations are 0-based
    }, maxIterations: 3);

    // Pump frames until iterations reach expected or safety cap.
    int safety = 0;
    while (repeater.iterations < 3 && safety++ < 20) {
      await tester.pump();
    }

    expect(observed, 3);
    expect(repeater.iterations, 3);
    expect(repeater.isCanceled, isFalse);
  });

  testWidgets('PostFrame.repeat can be canceled early', (tester) async {
    int calls = 0;
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));

    late PostFrameRepeater repeater;
    repeater = PostFrame.repeat((i) {
      calls++;
      if (i == 1) {
        repeater.cancel();
      }
    });

    int safety = 0;
    while (!repeater.isCanceled && safety++ < 20) {
      await tester.pump();
      if (calls > 5) break; // avoid infinite loops in failure case
    }

    expect(calls >= 2, isTrue); // At least two iterations before cancel
    expect(repeater.isCanceled, isTrue);
  });
}
