import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pop_this/pop_this.dart';
import 'package:sizer/sizer.dart';

void main() {
  testWidgets('PopThis.pop shows a widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          // No OverlaySupport.global needed - PopThis handles it automatically
          return MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      PopThis.pop(
                        context: context,
                        child: const Text('Hello PopThis'),
                      );
                    },
                    child: const Text('Show Pop'),
                  );
                },
              ),
            ),
          );
        },
      ),
    );

    // Verify initial state
    expect(find.text('Hello PopThis'), findsNothing);

    // Tap the button to show the popup
    await tester.tap(find.text('Show Pop'));
    await tester.pumpAndSettle();

    // Verify popup is shown
    expect(find.text('Hello PopThis'), findsOneWidget);
  });

  test('PopThis package exports necessary classes', () {
    // This test verifies the package structure is correct
    expect(PopThis, isNotNull);
  });
}
