import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/s_bounceable/s_bounceable.dart';

void main() {
  testWidgets('single tap is deferred when double tap is available', (tester) async {
    var taps = 0;
    var doubleTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SBounceable(
            onTap: () => taps++,
            onDoubleTap: () => doubleTaps++,
            child: const SizedBox(width: 80, height: 80),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(SBounceable));

    expect(taps, 0);
    expect(doubleTaps, 0);

    await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 1));

    expect(taps, 1);
    expect(doubleTaps, 0);
  });

  testWidgets('double tap cancels pending single tap', (tester) async {
    var taps = 0;
    var doubleTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SBounceable(
            onTap: () => taps++,
            onDoubleTap: () => doubleTaps++,
            child: const SizedBox(width: 80, height: 80),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(SBounceable));
    await tester.tap(find.byType(SBounceable));
    await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 1));

    expect(taps, 0);
    expect(doubleTaps, 1);
  });
}
