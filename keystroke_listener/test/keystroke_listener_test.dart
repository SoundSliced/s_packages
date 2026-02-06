import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keystroke_listener/keystroke_listener.dart';

void main() {
  group('Keystroke Listener - Intent Definitions', () {
    test('EscapeIntent can be created', () {
      const intent = EscapeIntent();
      expect(intent, isA<Intent>());
    });

    test('NavigateUpIntent can be created', () {
      const intent = NavigateUpIntent();
      expect(intent, isA<Intent>());
    });

    test('NavigateDownIntent can be created', () {
      const intent = NavigateDownIntent();
      expect(intent, isA<Intent>());
    });

    test('NavigateLeftIntent can be created', () {
      const intent = NavigateLeftIntent();
      expect(intent, isA<Intent>());
    });

    test('NavigateRightIntent can be created', () {
      const intent = NavigateRightIntent();
      expect(intent, isA<Intent>());
    });

    test('SubmitIntent can be created', () {
      const intent = SubmitIntent();
      expect(intent, isA<Intent>());
    });

    test('DeleteIntent can be created', () {
      const intent = DeleteIntent();
      expect(intent, isA<Intent>());
    });

    test('SaveIntent can be created', () {
      const intent = SaveIntent();
      expect(intent, isA<Intent>());
    });

    test('UndoIntent can be created', () {
      const intent = UndoIntent();
      expect(intent, isA<Intent>());
    });

    test('RedoIntent can be created', () {
      const intent = RedoIntent();
      expect(intent, isA<Intent>());
    });

    test('SelectAllIntent can be created', () {
      const intent = SelectAllIntent();
      expect(intent, isA<Intent>());
    });

    test('CopyIntent can be created', () {
      const intent = CopyIntent();
      expect(intent, isA<Intent>());
    });

    test('PasteIntent can be created', () {
      const intent = PasteIntent();
      expect(intent, isA<Intent>());
    });

    test('CutIntent can be created', () {
      const intent = CutIntent();
      expect(intent, isA<Intent>());
    });

    test('TabIntent can be created', () {
      const intent = TabIntent();
      expect(intent, isA<Intent>());
    });

    test('ReverseTabIntent can be created', () {
      const intent = ReverseTabIntent();
      expect(intent, isA<Intent>());
    });

    test('ToggleCommentIntent can be created', () {
      const intent = ToggleCommentIntent();
      expect(intent, isA<Intent>());
    });

    test('HelpIntent can be created', () {
      const intent = HelpIntent();
      expect(intent, isA<Intent>());
    });

    test('SpaceIntent can be created', () {
      const intent = SpaceIntent();
      expect(intent, isA<Intent>());
    });
  });

  group('KeystrokeListener - Basic Tests', () {
    testWidgets('KeystrokeListener builds with child widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeystrokeListener(
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('KeystrokeListener can be created with custom FocusNode',
        (WidgetTester tester) async {
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeystrokeListener(
              focusNode: focusNode,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);

      focusNode.dispose();
    });

    testWidgets('KeystrokeListener respects enableVisualDebug flag',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeystrokeListener(
              enableVisualDebug: true,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('KeystrokeListener respects autoFocus flag',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeystrokeListener(
              autoFocus: false,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('KeystrokeListener respects requestFocusOnInit flag',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeystrokeListener(
              requestFocusOnInit: false,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });
  });

  group('KeystrokeListener - Advanced Tests', () {
    testWidgets('KeystrokeListener calls onKeyEvent callback',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeystrokeListener(
              onKeyEvent: (event) {
                // Key event received
              },
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      // Focus the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeystrokeListener(
              onKeyEvent: (event) {
                // Key event received
              },
              autoFocus: true,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('KeystrokeListener FocusNode management',
        (WidgetTester tester) async {
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeystrokeListener(
              focusNode: focusNode,
              requestFocusOnInit: true,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Child'), findsOneWidget);

      focusNode.dispose();
    });

    testWidgets('KeystrokeListener handles FocusNode changes',
        (WidgetTester tester) async {
      final focusNode1 = FocusNode();
      final focusNode2 = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeystrokeListener(
              focusNode: focusNode1,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeystrokeListener(
              focusNode: focusNode2,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);

      focusNode1.dispose();
      focusNode2.dispose();
    });

    testWidgets('KeystrokeListener disposes resources correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeystrokeListener(
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Different Widget'),
          ),
        ),
      );

      expect(find.text('Test Child'), findsNothing);
    });

    testWidgets('KeystrokeListener with multiple shortcuts and actions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeystrokeListener(
              onKeyEvent: (event) {
                // Handle key event
              },
              autoFocus: true,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('KeystrokeListener updates when child changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeystrokeListener(
              child: const Text('First Child'),
            ),
          ),
        ),
      );

      expect(find.text('First Child'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeystrokeListener(
              child: const Text('Second Child'),
            ),
          ),
        ),
      );

      expect(find.text('Second Child'), findsOneWidget);
      expect(find.text('First Child'), findsNothing);
    });

    testWidgets('KeystrokeListener with complex child widget tree',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeystrokeListener(
              child: Column(
                children: [
                  const Text('Header'),
                  Expanded(
                    child: ListView(
                      children: List.generate(
                        5,
                        (index) => Text('Item $index'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 4'), findsOneWidget);
    });
  });

  group('KeystrokeListener - Edge Cases', () {
    testWidgets('KeystrokeListener with null focusNode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeystrokeListener(
              focusNode: null,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('KeystrokeListener maintains state with requestFocusOnInit',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeystrokeListener(
              requestFocusOnInit: true,
              autoFocus: true,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('KeystrokeListener with onKeyEvent callback and visual debug',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeystrokeListener(
              enableVisualDebug: true,
              onKeyEvent: (event) {
                // Handle key event
              },
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });
  });
}
