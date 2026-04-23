import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/s_packages.dart';

void main() {
  Finder _timeInputEditableText() => find.descendant(
        of: find.byType(TimeInput),
        matching: find.byType(EditableText),
      );

  group('TimeInput focus-entry cursor behavior', () {
    testWidgets('tap from unfocused puts caret at start', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 220,
                child: TimeInput(
                  title: 'Time',
                  time: DateTime.utc(2026, 4, 5, 10, 30),
                  onSubmitted: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final editableBefore = tester.widget<EditableText>(_timeInputEditableText());
      expect(editableBefore.focusNode.hasFocus, isFalse);

      // Tap near the far right to stress cursor placement logic.
      final inputBox = find.byType(TextFormField);
      final topRight = tester.getTopRight(inputBox);
      await tester.tapAt(Offset(topRight.dx - 8, topRight.dy + 20));
      await tester.pumpAndSettle();

      final editableAfter = tester.widget<EditableText>(_timeInputEditableText());
      expect(editableAfter.focusNode.hasFocus, isTrue);
      expect(editableAfter.controller.text, '10:30 z');
      expect(editableAfter.controller.selection.baseOffset, 0);
      expect(editableAfter.controller.selection.extentOffset, 0);
    });

    testWidgets('tab traversal into TimeInput puts caret at start', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const TextField(),
                TimeInput(
                  title: 'Time',
                  time: DateTime.utc(2026, 4, 5, 10, 30),
                  onSubmitted: (_) {},
                ),
                const TextField(),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Focus the first field, then TAB into TimeInput.
      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      final editableAfterTab = tester.widget<EditableText>(_timeInputEditableText());
      expect(editableAfterTab.focusNode.hasFocus, isTrue);
      expect(editableAfterTab.controller.text, '10:30 z');
      expect(editableAfterTab.controller.selection.baseOffset, 0);
      expect(editableAfterTab.controller.selection.extentOffset, 0);
    });

    testWidgets('typing keeps formatted display while editing digits', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 220,
                child: TimeInput(
                  title: 'Time',
                  time: DateTime.utc(2026, 4, 5, 10, 30),
                  onSubmitted: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '1445');
      await tester.pumpAndSettle();

      final editableAfterTyping = tester.widget<EditableText>(_timeInputEditableText());
      expect(editableAfterTyping.focusNode.hasFocus, isTrue);
      expect(editableAfterTyping.controller.text, '14:45 z');
    });

    testWidgets('focused cursor skips colon and suffix slots', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 220,
                child: TimeInput(
                  title: 'Time',
                  time: DateTime.utc(2026, 4, 5, 14, 45),
                  onSubmitted: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      final editable = tester.widget<EditableText>(_timeInputEditableText());

      // Try to place caret before ':' (offset 2) -> should skip to 3.
      editable.controller.selection = const TextSelection.collapsed(offset: 2);
      await tester.pump();
      expect(editable.controller.selection.baseOffset, 3);

      // Try to place caret inside suffix (offset 6) -> should snap to after last digit (offset 5).
      editable.controller.selection = const TextSelection.collapsed(offset: 6);
      await tester.pump();
      expect(editable.controller.selection.baseOffset, 5);
    });

    testWidgets('backspace after minute tens clears that digit, not minute ones', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 220,
                child: TimeInput(
                  title: 'Time',
                  time: DateTime.utc(2026, 4, 5, 13, 45),
                  onSubmitted: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      final editable = tester.widget<EditableText>(_timeInputEditableText());

      // Place caret between '4' and '5' (offset 4 in "13:45 z").
      editable.controller.selection = const TextSelection.collapsed(offset: 4);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();

      final editableAfter = tester.widget<EditableText>(_timeInputEditableText());
      expect(editableAfter.controller.text, '13:05 z');
    });
  });
}
