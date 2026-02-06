import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:post_frame/post_frame.dart';

void main() {
  testWidgets('PostFrame.run hits timeout before action completes',
      (tester) async {
    bool executed = false;
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));

    final task = PostFrame.run<void>(() async {
      // Simulate longer async work than timeout.
      await Future.delayed(const Duration(milliseconds: 100));
      executed = true;
    },
        waitForEndOfFrame: false,
        timeout: const Duration(milliseconds: 10),
        maxWaitFrames: 0);

    // Pump enough time for timeout.
    await tester.pump(const Duration(milliseconds: 50));

    final result = await task.future;
    expect(executed, isFalse,
        reason: 'Action should not have completed due to timeout');
    expect(result.canceled, isTrue, reason: 'Timeout marks task as canceled');
    expect(result.hasError, isTrue);
    expect(result.error, isA<TimeoutException>());
  });
}
