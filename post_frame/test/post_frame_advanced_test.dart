import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:post_frame/post_frame.dart';

void main() {
  testWidgets(
      'Advanced PostFrame usage waits for multiple controllers & passes',
      (tester) async {
    final outer = ScrollController();
    final inner = ScrollController();
    var ran = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: outer,
                itemCount: 50,
                itemBuilder: (context, index) =>
                    ListTile(title: Text('Item $index')),
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                controller: inner,
                scrollDirection: Axis.horizontal,
                itemCount: 30,
                itemBuilder: (context, idx) => Container(
                  width: 80,
                  margin: const EdgeInsets.all(4),
                  color: Colors.indigo[(idx % 9 + 1) * 100],
                  alignment: Alignment.center,
                  child: Text('H $idx',
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    ));

    PostFrame.postFrame(() {
      ran = true;
    },
        scrollControllers: [outer, inner],
        maxWaitFrames: 0,
        waitForEndOfFrame: false,
        endOfFramePasses: 1);

    // Pump a handful of frames to allow callback & waits to complete.
    // Pump a few frames; with waitForEndOfFrame disabled action should run quickly.
    for (var i = 0; i < 5 && !ran; i++) {
      await tester.pump();
    }

    expect(ran, isTrue,
        reason: 'Callback should have executed after stabilization');
    expect(outer.hasClients, isTrue);
    expect(inner.hasClients, isTrue);
    expect(outer.position.maxScrollExtent, greaterThan(0),
        reason: 'Outer list should have scroll extent');
    expect(inner.position.maxScrollExtent, greaterThan(0),
        reason: 'Inner list should have scroll extent');
  });
}
