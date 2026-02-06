import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:post_frame/post_frame.dart';

void main() {
  testWidgets('PostFrame.onLayout resolves size for keyed widget',
      (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: SizedBox(key: key, width: 120, height: 55),
      ),
    ));

    final sizeFuture = PostFrame.onLayout(key, maxWaitFrames: 10);

    // Advance a few frames for stabilization.
    for (var i = 0; i < 5; i++) {
      await tester.pump();
    }

    final size = await sizeFuture;
    expect(size, isNotNull);
    expect(size!.width, 120);
    expect(size.height, 55);
  });

  testWidgets('PostFrame.onLayout returns null when timeout exceeded',
      (tester) async {
    final key = GlobalKey();
    // Not attaching key to widget tree at all.
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));

    final sizeFuture = PostFrame.onLayout(key, maxWaitFrames: 2);
    // Pump a few frames allowing onLayout loop to progress.
    for (var i = 0; i < 3; i++) {
      await tester.pump();
    }
    final size = await sizeFuture;
    expect(size, isNull);
  });
}
