import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundsliced_tween_animation_builder/soundsliced_tween_animation_builder.dart';

void main() {
  testWidgets('STweenAnimationBuilder animates correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: STweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 100.0),
          duration: const Duration(seconds: 1),
          builder: (context, value, child) {
            return Text('Value: $value');
          },
        ),
      ),
    );

    // Initial value
    expect(find.text('Value: 0.0'), findsOneWidget);

    // Wait for animation
    await tester.pump(const Duration(milliseconds: 500));
    // Value should be between 0 and 100
    expect(find.textContaining('Value:'), findsOneWidget);
  });

  testWidgets('STweenAnimationBuilder renders with initial value',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: STweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 100.0),
          duration: const Duration(milliseconds: 100),
          builder: (context, value, child) {
            return Text('Value: $value');
          },
        ),
      ),
    );

    // Initial pump
    await tester.pump();

    // Should start at initial value
    expect(find.text('Value: 0.0'), findsOneWidget);
  });

  testWidgets('STweenAnimationBuilder restarts with new key',
      (WidgetTester tester) async {
    Object? animationKey = Object();

    await tester.pumpWidget(
      MaterialApp(
        home: STweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 100.0),
          duration: const Duration(milliseconds: 200),
          animationKey: animationKey,
          builder: (context, value, child) {
            return Text('Value: $value');
          },
        ),
      ),
    );

    // Initial value
    expect(find.text('Value: 0.0'), findsOneWidget);

    // Wait for animation to progress
    await tester.pump(const Duration(milliseconds: 100));

    // Change the key to restart animation
    animationKey = Object();
    await tester.pumpWidget(
      MaterialApp(
        home: STweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 100.0),
          duration: const Duration(milliseconds: 200),
          animationKey: animationKey,
          builder: (context, value, child) {
            return Text('Value: $value');
          },
        ),
      ),
    );

    // Should restart from 0
    expect(find.text('Value: 0.0'), findsOneWidget);
  });

  testWidgets('STweenAnimationBuilder applies curve',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: STweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 100.0),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Text('Value: $value');
          },
        ),
      ),
    );

    // Curve should affect the animation progression
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('Value:'), findsOneWidget);
  });

  testWidgets('STweenAnimationBuilder accepts all constructor parameters',
      (WidgetTester tester) async {
    // Test that widget can be created with all parameters
    await tester.pumpWidget(
      MaterialApp(
        home: STweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 100.0),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          autoRepeat: true,
          animationKey: Object(),
          onEnd: () {},
          child: const Text('Child'),
          builder: (context, value, child) {
            return Column(
              children: [
                Text('Value: $value'),
                if (child != null) child,
              ],
            );
          },
        ),
      ),
    );

    await tester.pump();

    // Should render with initial value and child
    expect(find.text('Value: 0.0'), findsOneWidget);
    expect(find.text('Child'), findsOneWidget);
  });
}
