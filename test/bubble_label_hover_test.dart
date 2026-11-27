import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:s_packages/s_packages.dart';

void main() {
  Future<TestPointer> pumpButton(
    WidgetTester tester, {
    required Duration? hoverAfter,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SButton(
              bubbleLabelContent: BubbleLabelContent(
                child: const Text('bubble-text'),
                showOnHoverAfter: hoverAfter,
              ),
              child: const SizedBox(width: 80, height: 40, child: Text('btn')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return TestPointer(1, PointerDeviceKind.mouse);
  }

  testWidgets('mouse hover shows the bubble after the delay and hides it on exit',
      (tester) async {
    final pointer = await pumpButton(
      tester,
      hoverAfter: const Duration(seconds: 1),
    );
    final center = tester.getCenter(find.text('btn'));

    await tester.sendEventToBinding(pointer.hover(center));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('bubble-text'), findsNothing);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('bubble-text'), findsOneWidget);

    await tester.sendEventToBinding(pointer.hover(const Offset(1, 1)));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('bubble-text'), findsNothing);
  });

  testWidgets('leaving before the delay shows no bubble', (tester) async {
    final pointer = await pumpButton(
      tester,
      hoverAfter: const Duration(seconds: 1),
    );
    final center = tester.getCenter(find.text('btn'));

    await tester.sendEventToBinding(pointer.hover(center));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.sendEventToBinding(pointer.hover(const Offset(1, 1)));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('bubble-text'), findsNothing);
  });

  testWidgets('a null delay disables hover', (tester) async {
    final pointer = await pumpButton(tester, hoverAfter: null);
    final center = tester.getCenter(find.text('btn'));

    await tester.sendEventToBinding(pointer.hover(center));
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('bubble-text'), findsNothing);
  });
}
