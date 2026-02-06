import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indexscroll_listview_builder/indexscroll_listview_builder.dart';
import 'package:s_gridview/s_gridview.dart';

void main() {
  testWidgets('SGridView builds and shows items', (WidgetTester tester) async {
    final items = List.generate(
      6,
      (i) => Container(
        width: 100,
        height: 80,
        color: Colors.blue,
        child: Center(child: Text('Item ${i + 1}')),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 400,
            child: SGridView(
              crossAxisItemCount: 2,
              itemPadding: const EdgeInsets.all(4),
              children: items,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that at least one of the generated text widgets is present in the widget tree
    expect(find.text('Item 1'), findsOneWidget);
  });

  testWidgets('Long list shows bottom indicator and toggles on scroll',
      (WidgetTester tester) async {
    final controller = IndexedScrollController(alignment: 1.0);
    final items = List.generate(
      30,
      (i) => Container(
        width: 100,
        height: 80,
        color: Colors.primaries[i % Colors.primaries.length],
        child: Center(child: Text('Item ${i + 1}')),
      ),
    );

    const crossAxis = 3;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 400,
            child: SGridView(
              controller: controller,
              crossAxisItemCount: crossAxis,
              itemPadding: const EdgeInsets.all(4),
              children: items,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Initial check: bottom indicator should be visible for long lists
    // Initial check: bottom indicator should be visible for long lists
    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);

    // Scroll to bottom (use jumpTo because `scrollToIndex` can hang in widget tests).
    await tester.runAsync(() async {
      controller.controller
          .jumpTo(controller.controller.position.maxScrollExtent);
    });
    await tester.pumpAndSettle();
    // Debug: report scroll position
    debugPrint(
        'offset: ${controller.controller.offset}, max: ${controller.controller.position.maxScrollExtent}');
    // Debug: report scroll position
    debugPrint(
        'offset: ${controller.controller.offset}, max: ${controller.controller.position.maxScrollExtent}');

    // After scrolling to bottom, top indicator should show and bottom should be gone
    expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
  });

  testWidgets('Horizontal layout uses left/right indicators',
      (WidgetTester tester) async {
    final controller = IndexedScrollController(alignment: 1.0);
    final items = List.generate(
      30,
      (i) => Container(
        width: 100,
        height: 80,
        color: Colors.primaries[i % Colors.primaries.length],
        child: Center(child: Text('Item ${i + 1}')),
      ),
    );

    const crossAxis = 3;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 400,
            child: SGridView(
              controller: controller,
              mainAxisDirection: Axis.horizontal,
              crossAxisItemCount: crossAxis,
              itemPadding: const EdgeInsets.all(4),
              children: items,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Initial check: right arrow indicator should show
    expect(find.byIcon(Icons.keyboard_arrow_right), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_left), findsNothing);

    // Scroll to the end (last "row")
    await tester.runAsync(() async {
      controller.controller
          .jumpTo(controller.controller.position.maxScrollExtent);
    });
    await tester.pumpAndSettle();
    debugPrint(
        'offset: ${controller.controller.offset}, max: ${controller.controller.position.maxScrollExtent}');
    debugPrint(
        'offset: ${controller.controller.offset}, max: ${controller.controller.position.maxScrollExtent}');

    // After scrolling to the end, left arrow should show and right arrow should be gone
    expect(find.byIcon(Icons.keyboard_arrow_left), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_right), findsNothing);
  });
}
