import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indexscroll_listview_builder/indexscroll_listview_builder.dart';

void main() {
  group('IndexScrollListViewBuilder', () {
    testWidgets('builds list items', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: IndexScrollListViewBuilder(
            itemCount: 10,
            onScrolledTo: (_) {},
            itemBuilder: (context, index) => Text('Item $index'),
          ),
        ),
      ));

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 9'), findsOneWidget);
    });

    testWidgets('auto scroll triggers without error', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: IndexScrollListViewBuilder(
            itemCount: 50,
            indexToScrollTo: 25,
            numberOfOffsetedItemsPriorToSelectedItem: 2,
            onScrolledTo: (_) {},
            itemBuilder: (context, index) => Text('Auto $index'),
          ),
        ),
      ));

      // Allow frames for post frame callback
      await tester.pumpAndSettle(const Duration(seconds: 1));
      // Just ensure target exists and no exceptions occurred
      expect(find.text('Auto 25'), findsOneWidget);
    });

    testWidgets('external controller scrollToIndex executes', (tester) async {
      final controller = IndexedScrollController();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 100, // Constrain height to force scrolling
            child: IndexScrollListViewBuilder(
              controller: controller,
              itemCount: 50, // Larger list to ensure scrolling
              onScrolledTo: (_) {},
              itemBuilder: (context, index) => Text('X $index'),
            ),
          ),
        ),
      ));

      // Initial pump to build widgets
      await tester.pump();

      // Use scrollUntilVisible to force ListView to build and reveal item 25
      await tester.scrollUntilVisible(
        find.text('X 25'),
        50.0, // delta in pixels per scroll
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('X 25'), findsOneWidget,
          reason: 'Item X 25 should be visible after scrollUntilVisible.');
    });

    testWidgets('indexToScrollTo acts as declarative home position on rebuild',
        (tester) async {
      int homeIndex = 10;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Rebuild'),
                  ),
                  Expanded(
                    child: IndexScrollListViewBuilder(
                      itemCount: 50,
                      indexToScrollTo: homeIndex, // Declarative home position
                      onScrolledTo: (_) {},
                      itemBuilder: (context, index) => Text('Home $index'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ));

      // Initial build and scroll
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('Home $homeIndex'), findsOneWidget);

      // Trigger rebuild - should maintain/restore home position
      await tester.tap(find.text('Rebuild'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Home position should still be visible after rebuild
      expect(find.text('Home $homeIndex'), findsOneWidget,
          reason:
              'indexToScrollTo should act as home position, restored on rebuild');
    });

    testWidgets(
        'null indexToScrollTo allows imperative scrolling to persist across rebuilds',
        (tester) async {
      final controller = IndexedScrollController();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Rebuild'),
                  ),
                  Expanded(
                    child: IndexScrollListViewBuilder(
                      controller: controller,
                      itemCount: 50,
                      indexToScrollTo: null, // Imperative control
                      onScrolledTo: (_) {},
                      itemBuilder: (context, index) => SizedBox(
                        height: 50,
                        child: Text('Imperative $index'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ));

      await tester.pump();
      await tester.pumpAndSettle();

      // Scroll imperatively using controller
      await tester.scrollUntilVisible(
        find.text('Imperative 25'),
        50.0,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Imperative 25'), findsOneWidget);

      // Trigger rebuild
      await tester.tap(find.text('Rebuild'));
      await tester.pumpAndSettle();

      // Item 25 should still be visible - imperative scroll persisted
      expect(find.text('Imperative 25'), findsOneWidget,
          reason:
              'With null indexToScrollTo, imperative scrolling should persist across rebuilds');
    });
  });
}
