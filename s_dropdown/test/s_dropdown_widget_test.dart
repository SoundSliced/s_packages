import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_dropdown/s_dropdown.dart';

void main() {
  testWidgets('SDropdown renders and displays overlay on tap',
      (WidgetTester tester) async {
    String? selected;
    final List<String> items = ['One', 'Two', 'Three'];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SDropdown(
            items: items,
            width: 200,
            height: 48,
            hintText: 'Choose',
            onChanged: (value) {
              selected = value;
            },
          ),
        ),
      ),
    ));

    expect(find.byType(SDropdown), findsOneWidget);
    expect(find.text('Choose'), findsOneWidget);

    // Tap to open
    await tester.tap(find.byType(SDropdown));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // The overlay should show the items
    expect(find.text('One'), findsWidgets);
    expect(find.text('Two'), findsWidgets);

    // Tap on an item to select
    await tester.tap(find.text('Two').first);
    await tester.pump();
    // Allow delayed overlay close timer (200ms in widget) to run
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(selected, 'Two');
  });

  testWidgets('SDropdownController open/close toggles overlay',
      (WidgetTester tester) async {
    final controller = SDropdownController();
    final items = ['A', 'B', 'C'];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SDropdown(
            items: items,
            controller: controller,
            hintText: 'Pick',
          ),
        ),
      ),
    ));

    expect(find.text('Pick'), findsOneWidget);

    controller.open();
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(controller.isExpanded, isTrue);

    controller.close();
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(controller.isExpanded, isFalse);
  });
}
