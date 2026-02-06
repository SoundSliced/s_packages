import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:post_frame/post_frame.dart';

void main() {
  testWidgets('PostFrame.queueRun executes tasks sequentially', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final executionOrder = <int>[];

    final t1 = PostFrame.queueRun(() async {
      executionOrder.add(1);
      return 1;
    }, waitForEndOfFrame: false, maxWaitFrames: 0);

    PostFrame.queueRun(() async {
      executionOrder.add(2);
      return 2;
    }, waitForEndOfFrame: false, maxWaitFrames: 0);

    // Pump enough frames for both tasks.
    for (var i = 0; i < 5; i++) {
      await tester.pump();
    }

    final r1 = await t1.future;
    // Second task result implied by execution order; ensure order length==2
    expect(executionOrder.length, 2);
    final secondValue = executionOrder[1];

    expect(r1.value, 1);
    expect(secondValue, 2);
    expect(executionOrder, [1, 2]);
  });

  testWidgets('PostFrame.clearQueue cancels queued but not started tasks',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final executionOrder = <int>[];

    final t1 = PostFrame.queueRun(() async {
      executionOrder.add(1);
      return 1;
    }, waitForEndOfFrame: false, maxWaitFrames: 0);

    PostFrame.queueRun(() async {
      executionOrder.add(2);
      return 2;
    }, waitForEndOfFrame: false, maxWaitFrames: 0);

    PostFrame.clearQueue();

    for (var i = 0; i < 4; i++) {
      await tester.pump();
    }

    final r1 = await t1.future;
    expect(r1.value, 1);
    expect(executionOrder, [1]);
  });
}
