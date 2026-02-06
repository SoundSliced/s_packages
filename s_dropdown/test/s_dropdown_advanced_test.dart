import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_dropdown/s_dropdown.dart';

void main() {
  testWidgets('excludeSelected hides the selected item in overlay',
      (WidgetTester tester) async {
    final items = ['A', 'B', 'C'];
    String? selected = 'B';

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SDropdown(
            items: items,
            selectedItem: selected,
            excludeSelected: true,
            hintText: 'Pick',
            width: 200,
            height: 48,
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    ));

    // There should be only one 'B' visible - the header
    expect(find.text('B'), findsOneWidget);

    // Open overlay and confirm it contains the non-selected values
    await tester.tap(find.byType(SDropdown));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Overlay should show 'A' and 'C' (but not 'B' since it's selected and excluded)
    expect(find.text('A'), findsWidgets);
    expect(find.text('C'), findsWidgets);
    expect(find.text('B'), findsOneWidget);

    // Tap on 'A' to select it
    await tester.tap(find.text('A').first);
    await tester.pump();
    // allow overlay close timer and animation to complete
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // 'selected' variable should update to 'A'
    expect(selected, 'A');
    // The header should show 'A' once (the overlay is closed)
    expect(find.text('A').evaluate().length, equals(1));

    // Re-open overlay to make sure 'A' is excluded and 'B' and 'C' are visible
    await tester.tap(find.byType(SDropdown));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(find.text('A').evaluate().length, equals(1));
    expect(find.text('B'), findsWidgets);
    expect(find.text('C'), findsWidgets);
  });

  testWidgets('controller highlight navigation and selectHighlighted',
      (WidgetTester tester) async {
    final controller = SDropdownController();
    final items = ['A', 'B', 'C'];
    String? selected;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SDropdown(
            items: items,
            controller: controller,
            hintText: 'Pick',
            onChanged: (value) => selected = value,
            width: 200,
            height: 48,
          ),
        ),
      ),
    ));

    controller.open();
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Highlight the next item (should highlight 'B'), then select it
    controller.highlightNext();
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    controller.selectHighlighted();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(selected, 'B');
  });

  testWidgets(
      'controller highlightAtIndex/selectIndex and highlightItem/selectItem',
      (WidgetTester tester) async {
    final controller = SDropdownController();
    final items = ['A', 'B', 'C', 'D'];
    String? selected;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SDropdown(
            items: items,
            controller: controller,
            hintText: 'Pick',
            onChanged: (value) => selected = value,
            width: 200,
            height: 48,
          ),
        ),
      ),
    ));

    // Use selectIndex to pick 'D' (index 3)
    controller.selectIndex(3);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(selected, 'D');

    // Now use selectItem to pick 'B'
    controller.selectItem('B');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(selected, 'B');

    // Open overlay and test highlightAtIndex
    controller.open();
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    controller.highlightAtIndex(2); // 'C'
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    controller.selectHighlighted();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(selected, 'C');

    // Use highlightItem and selectHighlighted to validate string-based highlight
    controller.open();
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    controller.highlightItem('A');
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    controller.selectHighlighted();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(selected, 'A');
  });

  testWidgets(
      'highlightAtIndex on excluded selected item does not highlight but selectIndex still works',
      (WidgetTester tester) async {
    final controller = SDropdownController();
    final items = ['A', 'B', 'C'];
    String? selected = 'A';

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SDropdown(
            items: items,
            selectedItem: selected,
            excludeSelected: true,
            controller: controller,
            hintText: 'Pick',
            onChanged: (value) => selected = value,
            width: 200,
            height: 48,
          ),
        ),
      ),
    ));

    // Try to highlight selected item (index 0) while it's excluded
    controller.highlightAtIndex(0);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(controller.isExpanded, isTrue);
    // 'A' should not be present in the overlay as it's excluded
    expect(find.text('A').evaluate().length, equals(1));

    // Now select index 2 to change selection
    controller.selectIndex(2);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(selected, 'C');
  });

  testWidgets('customItemsNamesDisplayed uses custom display text',
      (WidgetTester tester) async {
    final items = ['apple', 'banana', 'cherry'];
    final customNames = ['🍎 Apple', '🍌 Banana', '🍒 Cherry'];
    String? selected;

    String current = items[0];
    String currentDisplay = customNames[0];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: StatefulBuilder(builder: (context, setState) {
            return SDropdown(
              items: items,
              selectedItem: current,
              selectedItemText: currentDisplay,
              customItemsNamesDisplayed: customNames,
              hintText: 'Pick',
              onChanged: (value) {
                setState(() {
                  selected = value;
                  if (value != null) {
                    final idx = items.indexOf(value);
                    current = value;
                    currentDisplay = customNames[idx];
                  }
                });
              },
              width: 200,
              height: 48,
            );
          }),
        ),
      ),
    ));

    expect(find.text('🍎 Apple'), findsOneWidget);

    await tester.tap(find.byType(SDropdown));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Custom display names should be visible in overlay
    expect(find.text('🍌 Banana'), findsWidgets);

    // Select '🍌 Banana' and verify selection maps to logical value 'banana'
    await tester.tap(find.text('🍌 Banana').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(selected, 'banana');
    // Header should now display the custom name
    expect(find.text('🍌 Banana'), findsOneWidget);

    // Re-open overlay to ensure custom display names are still shown in the list
    await tester.tap(find.byType(SDropdown));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    // After selection, the overlay should not include the selected item and should show the others
    expect(find.text('🍌 Banana').evaluate().length, equals(1));
  });

  testWidgets('validator is called on selection when validateOnChange = true',
      (WidgetTester tester) async {
    final items = ['A', 'B', 'C'];
    int validatorCalls = 0;
    String? selected;

    String? validator(String? value) {
      validatorCalls++;
      if (value == null || value.isEmpty) return 'Invalid';
      return null;
    }

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SDropdown(
            items: items,
            hintText: 'Pick',
            onChanged: (value) => selected = value,
            validator: validator,
            validateOnChange: true,
            width: 200,
            height: 48,
          ),
        ),
      ),
    ));

    await tester.tap(find.byType(SDropdown));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    await tester.tap(find.text('C').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(selected, 'C');
    expect(validatorCalls, greaterThanOrEqualTo(1));
  });
}
