import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:post_frame/post_frame.dart';

void main() {
  testWidgets('PostFrame.builder produces result with value and diagnostics',
      (tester) async {
    final controller = ScrollController();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PostFrame.builder<int>(
          scrollControllers: [controller],
          maxWaitFrames: 1,
          endOfFramePasses: 1,
          action: () => 42,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final result = snapshot.data!;
            return Column(
              children: [
                Text('Value:${result.value}'),
                Text('Frames:${result.totalFramesWaited}'),
                Text('Canceled:${result.canceled}'),
              ],
            );
          },
        ),
      ),
    ));

    // Initial waiting state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Pump several frames to allow stabilization & builder completion.
    for (var i = 0; i < 6; i++) {
      await tester.pump();
    }

    expect(find.text('Value:42'), findsOneWidget);
  });
}
