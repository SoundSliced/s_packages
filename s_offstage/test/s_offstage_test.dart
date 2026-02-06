import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:s_offstage/s_offstage.dart';

void main() {
  testWidgets('SOffstage shows child when not offstage',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: false,
          child: const Text('Visible'),
        ),
      ),
    );
    expect(find.text('Visible'), findsOneWidget);
  });

  testWidgets('SOffstage hides child when offstage',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: true,
          child: const Text('Hidden'),
        ),
      ),
    );
    expect(find.text('Hidden'), findsNothing);
  });

  testWidgets('SOffstage triggers callback when state changes',
      (WidgetTester tester) async {
    bool? callbackValue;
    int callbackCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return SOffstage(
              isOffstage: false,
              onChanged: (isOffstage) {
                callbackValue = isOffstage;
                callbackCount++;
              },
              child: const Text('Test'),
            );
          },
        ),
      ),
    );

    // Initial state - no callback should be triggered yet
    expect(callbackCount, 0);
    expect(callbackValue, isNull);

    // Change to offstage
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return SOffstage(
              isOffstage: true,
              onChanged: (isOffstage) {
                callbackValue = isOffstage;
                callbackCount++;
              },
              child: const Text('Test'),
            );
          },
        ),
      ),
    );

    // Callback should be triggered with true
    expect(callbackCount, 1);
    expect(callbackValue, true);

    // Change back to visible
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return SOffstage(
              isOffstage: false,
              onChanged: (isOffstage) {
                callbackValue = isOffstage;
                callbackCount++;
              },
              child: const Text('Test'),
            );
          },
        ),
      ),
    );

    // Callback should be triggered again with false
    expect(callbackCount, 2);
    expect(callbackValue, false);
  });

  testWidgets('SOffstage does not trigger callback when state stays the same',
      (WidgetTester tester) async {
    int callbackCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: false,
          onChanged: (isOffstage) {
            callbackCount++;
          },
          child: const Text('Test'),
        ),
      ),
    );

    expect(callbackCount, 0);

    // Rebuild with same state
    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: false,
          onChanged: (isOffstage) {
            callbackCount++;
          },
          child: const Text('Test'),
        ),
      ),
    );

    // Callback should not be triggered
    expect(callbackCount, 0);
  });

  testWidgets('SOffstage triggers animation complete callback',
      (WidgetTester tester) async {
    bool? animationCompleteValue;
    int completeCallbackCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: false,
          fadeDuration: const Duration(milliseconds: 100),
          onAnimationComplete: (isOffstage) {
            animationCompleteValue = isOffstage;
            completeCallbackCount++;
          },
          child: const Text('Test'),
        ),
      ),
    );

    // Wait for initial animation to complete
    await tester.pumpAndSettle();

    // Reset counter after initial build
    final initialCount = completeCallbackCount;

    // Change to offstage
    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: true,
          fadeDuration: const Duration(milliseconds: 100),
          onAnimationComplete: (isOffstage) {
            animationCompleteValue = isOffstage;
            completeCallbackCount++;
          },
          child: const Text('Test'),
        ),
      ),
    );

    // Wait for animation to complete
    await tester.pumpAndSettle();

    // Should have triggered completion callback
    expect(completeCallbackCount, greaterThan(initialCount));
    expect(animationCompleteValue, true);

    // Change back to visible
    final beforeVisible = completeCallbackCount;
    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: false,
          fadeDuration: const Duration(milliseconds: 100),
          onAnimationComplete: (isOffstage) {
            animationCompleteValue = isOffstage;
            completeCallbackCount++;
          },
          child: const Text('Test'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Should have triggered completion callback again
    expect(completeCallbackCount, greaterThan(beforeVisible));
    expect(animationCompleteValue, false);
  });

  testWidgets('SOffstage respects different transition types',
      (WidgetTester tester) async {
    // Test fade transition
    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: false,
          transition: SOffstageTransition.fade,
          child: const Text('Fade Test'),
        ),
      ),
    );

    expect(find.text('Fade Test'), findsOneWidget);

    // Test scale transition
    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: false,
          transition: SOffstageTransition.scale,
          child: const Text('Scale Test'),
        ),
      ),
    );

    expect(find.text('Scale Test'), findsOneWidget);

    // Test slide transition
    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: false,
          transition: SOffstageTransition.slide,
          child: const Text('Slide Test'),
        ),
      ),
    );

    expect(find.text('Slide Test'), findsOneWidget);

    // Test rotation transition
    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: false,
          transition: SOffstageTransition.rotation,
          child: const Text('Rotation Test'),
        ),
      ),
    );

    expect(find.text('Rotation Test'), findsOneWidget);
  });

  testWidgets('SOffstage respects delay parameters',
      (WidgetTester tester) async {
    bool stateChanged = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: true,
          delayBeforeShow: const Duration(milliseconds: 100),
          child: const Text('Delayed Test'),
        ),
      ),
    );

    // Change to visible with delay
    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: false,
          delayBeforeShow: const Duration(milliseconds: 100),
          onChanged: (isOffstage) {
            stateChanged = true;
          },
          child: const Text('Delayed Test'),
        ),
      ),
    );

    // State should change immediately
    expect(stateChanged, true);

    // But animation should be delayed
    await tester.pump(const Duration(milliseconds: 50));
    // Still in transition
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();

    // Should now be visible
    expect(find.text('Delayed Test'), findsOneWidget);
  });

  testWidgets('SOffstage respects custom animation curves',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: false,
          fadeInCurve: Curves.bounceIn,
          fadeOutCurve: Curves.easeOut,
          child: const Text('Curve Test'),
        ),
      ),
    );

    expect(find.text('Curve Test'), findsOneWidget);

    // Change state
    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: true,
          fadeInCurve: Curves.bounceIn,
          fadeOutCurve: Curves.easeOut,
          child: const Text('Curve Test'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Curve Test'), findsNothing);
  });

  testWidgets('SOffstage shows custom loading indicator',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: true,
          showLoadingIndicator: true,
          loadingIndicator: const Text('Custom Loading'),
          child: const Text('Content'),
        ),
      ),
    );

    expect(find.text('Custom Loading'), findsOneWidget);
    expect(find.text('Content'), findsNothing);
  });

  testWidgets('SOffstage respects showLoadingIndicator toggle',
      (WidgetTester tester) async {
    // Test with indicator hidden
    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: true,
          showLoadingIndicator: false,
          child: const Text('Content'),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Content'), findsNothing);

    // Test with indicator shown
    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: true,
          showLoadingIndicator: true,
          child: const Text('Content'),
        ),
      ),
    );

    // Note: SOffstage uses TickerFreeCircularProgressIndicator by default if no custom indicator is provided
    // We need to check for that or just check that *something* is there if we can't easily import the type
    // But since we can't easily import TickerFreeCircularProgressIndicator in the test without adding it to dev_dependencies or exporting it,
    // let's just check that we find a widget that isn't the content.
    // Actually, let's use a custom indicator to be sure.

    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: true,
          showLoadingIndicator: true,
          loadingIndicator: const Text('Loading...'),
          child: const Text('Content'),
        ),
      ),
    );

    expect(find.text('Loading...'), findsOneWidget);
  });

  testWidgets('SOffstage shows reveal button when configured',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SOffstage(
          isOffstage: true,
          showRevealButton: true,
          child: const Text('Content'),
        ),
      ),
    );

    // Should find the visibility icon
    expect(find.byIcon(Icons.visibility), findsOneWidget);

    // Tap it
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pumpAndSettle();

    // Should now show content (and maybe the hide button)
    expect(find.text('Content'), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });
}
