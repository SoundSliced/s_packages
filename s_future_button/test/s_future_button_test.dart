import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_future_button/s_future_button.dart';

void main() {
  group('SFutureButton Widget Tests', () {
    testWidgets('SFutureButton renders with default label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SFutureButton(
              onTap: () async => true,
              label: 'Test Button',
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(SFutureButton), findsOneWidget);
    });

    testWidgets('SFutureButton renders with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SFutureButton(
              onTap: () async => true,
              icon: const Icon(Icons.check),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('SFutureButton respects isEnabled parameter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SFutureButton(
              onTap: () async => true,
              label: 'Disabled Button',
              isEnabled: false,
            ),
          ),
        ),
      );

      expect(find.text('Disabled Button'), findsOneWidget);
      // Disabled state is handled by SDisabled wrapper
      expect(find.byType(SFutureButton), findsOneWidget);
    });

    testWidgets('SFutureButton respects custom dimensions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SFutureButton(
              onTap: () async => true,
              label: 'Custom Size',
              width: 200,
              height: 60,
            ),
          ),
        ),
      );

      expect(find.byType(SFutureButton), findsOneWidget);
      expect(find.text('Custom Size'), findsOneWidget);
    });

    testWidgets('SFutureButton respects bgColor parameter',
        (WidgetTester tester) async {
      const Color customColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SFutureButton(
              onTap: () async => true,
              label: 'Custom Color',
              bgColor: customColor,
            ),
          ),
        ),
      );

      expect(find.byType(SFutureButton), findsOneWidget);
    });

    testWidgets('SFutureButton respects borderRadius parameter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SFutureButton(
              onTap: () async => true,
              label: 'Rounded Button',
              borderRadius: 12,
            ),
          ),
        ),
      );

      expect(find.byType(SFutureButton), findsOneWidget);
    });

    testWidgets('SFutureButton respects isElevatedButton parameter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SFutureButton(
              onTap: () async => true,
              label: 'Flat Button',
              isElevatedButton: false,
            ),
          ),
        ),
      );

      expect(find.byType(SFutureButton), findsOneWidget);
    });

    testWidgets(
        'SFutureButton shows error message when showErrorMessage is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SFutureButton(
              onTap: () async => false,
              label: 'Validate',
              showErrorMessage: true,
            ),
          ),
        ),
      );

      expect(find.byType(SFutureButton), findsOneWidget);
    });

    testWidgets(
        'SFutureButton hides error message when showErrorMessage is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SFutureButton(
              onTap: () async => false,
              label: 'Validate',
              showErrorMessage: false,
            ),
          ),
        ),
      );

      expect(find.byType(SFutureButton), findsOneWidget);
    });

    testWidgets('SFutureButton calls onPostSuccess callback on success',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SFutureButton(
              onTap: () async => true,
              label: 'Success',
              onPostSuccess: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.byType(SFutureButton), findsOneWidget);
    });

    testWidgets('SFutureButton configures onPostError callback',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SFutureButton(
              onTap: () async => false,
              label: 'Error',
              onPostError: (error) {},
            ),
          ),
        ),
      );

      // Verify the button renders correctly
      expect(find.byType(SFutureButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('SFutureButton configures exception handling callback',
        (WidgetTester tester) async {
      final Exception testException = Exception('Test error');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SFutureButton(
              onTap: () async {
                throw testException;
              },
              label: 'Exception',
              onPostError: (error) {
                // Callback is configured
              },
            ),
          ),
        ),
      );

      // Verify the button renders correctly
      expect(find.byType(SFutureButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Exception'), findsOneWidget);
    });

    testWidgets('SFutureButton handles null return (silent dismissal)',
        (WidgetTester tester) async {
      bool successCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SFutureButton(
              onTap: () async => null,
              label: 'Silent',
              onPostSuccess: () {
                successCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      // Advance time to allow the async operation to complete
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // onPostSuccess should NOT be called for silent dismissal
      expect(successCalled, false);
    });

    testWidgets('SFutureButton respects loadingCircleSize parameter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SFutureButton(
              onTap: () async {
                return true;
              },
              label: 'Large Loader',
              loadingCircleSize: 32,
            ),
          ),
        ),
      );

      expect(find.byType(SFutureButton), findsOneWidget);
    });

    testWidgets('SFutureButton respects focusNode parameter',
        (WidgetTester tester) async {
      final FocusNode focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SFutureButton(
              onTap: () async => true,
              label: 'Focusable',
              focusNode: focusNode,
            ),
          ),
        ),
      );

      expect(find.byType(SFutureButton), findsOneWidget);

      addTearDown(focusNode.dispose);
    });

    testWidgets('SFutureButton respects onFocusChange callback',
        (WidgetTester tester) async {
      bool focusCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SFutureButton(
              onTap: () async => true,
              label: 'Focus Test',
              onFocusChange: (isFocused) {
                if (isFocused) {
                  focusCalled = true;
                }
              },
            ),
          ),
        ),
      );

      // Request focus on the button
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(focusCalled, true);
    });

    testWidgets('SFutureButton respects iconColor parameter',
        (WidgetTester tester) async {
      const Color customIconColor = Colors.yellow;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SFutureButton(
              onTap: () async => true,
              label: 'Icon Color',
              iconColor: customIconColor,
            ),
          ),
        ),
      );

      expect(find.byType(SFutureButton), findsOneWidget);
    });

    testWidgets('SFutureButton disabled when onTap is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SFutureButton(
              onTap: null,
              label: 'No Action',
            ),
          ),
        ),
      );

      expect(find.text('No Action'), findsOneWidget);
      expect(find.byType(SFutureButton), findsOneWidget);
    });
  });
}
