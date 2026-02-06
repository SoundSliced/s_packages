import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:post_frame/post_frame.dart';

void main() {
  testWidgets('PostFrame.postFrame executes after frame', (tester) async {
    String message = 'before';
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    PostFrame.postFrame(() {
      message = 'after';
    }, waitForEndOfFrame: false);
    // Pump a few frames to allow the post frame callback to run
    await tester.pump();
    expect(message, 'after');
  }, timeout: const Timeout(Duration(seconds: 10)));

  testWidgets('PostFrame.postFrame waits for ScrollController metrics',
      (tester) async {
    final scrollController = ScrollController();
    String message = 'before';

    await tester.pumpWidget(MaterialApp(
      home: ListView.builder(
        controller: scrollController,
        itemCount: 100,
        itemBuilder: (context, index) => Text('Item $index'),
      ),
    ));

    PostFrame.postFrame(() {
      message = 'after';
    }, scrollControllers: [scrollController]);

    // Simulate scrolling to ensure metrics are updated
    scrollController.jumpTo(50);
    await tester.pumpAndSettle();

    expect(message, 'after');
  });
}
