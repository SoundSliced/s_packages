import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:post_frame/post_frame.dart';

void main() {
  testWidgets('PostFrame.run cancellation prevents action execution',
      (tester) async {
    bool executed = false;
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));

    final task = PostFrame.run<void>(() {
      executed = true;
    }, waitForEndOfFrame: false, maxWaitFrames: 0);

    task.cancel();

    // Pump a couple frames.
    await tester.pump();
    await tester.pump();

    final result = await task.future;
    expect(executed, isFalse,
        reason: 'Action should not execute after cancellation');
    expect(result.canceled, isTrue);
    expect(result.hasError, isFalse);
  });
}
