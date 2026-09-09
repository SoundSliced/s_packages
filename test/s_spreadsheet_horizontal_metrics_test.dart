import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/s_spreadsheet/s_spreadsheet.dart';

/// Regression coverage for the horizontal metric publication fixed in 5.5.3.
///
/// Every test resizes the *same mounted* spreadsheet rather than pumping a
/// fresh widget at each size — a rebuilt widget would re-run `initState`'s
/// report and hide the very defect these tests exist to catch.
void main() {
  group('resize republishes metrics without a scroll', () {
    testWidgets('fit -> overflow -> fit, never scrolling', (tester) async {
      final controller = SSpreadsheetHorizontalSyncController();
      final width = ValueNotifier<double>(700);
      addTearDown(width.dispose);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_fixture(width, controller));
      await tester.pumpAndSettle();

      // 6 columns x 100 = 600 of content in a 700 viewport: nothing to scroll.
      expect(controller.value.maxScrollExtent, 0);
      expect(controller.value.controller, isNotNull);

      width.value = 500;
      await tester.pumpAndSettle();
      expect(controller.value.maxScrollExtent, closeTo(100, 0.01),
          reason: 'shrinking the viewport must republish the new extent');

      width.value = 700;
      await tester.pumpAndSettle();
      expect(controller.value.maxScrollExtent, 0,
          reason: 'growing it back must republish again');
      expect(tester.takeException(), isNull);
    });

    testWidgets('overflow of 1, 50, 99, 100 and 101 pixels is exact',
        (tester) async {
      final controller = SSpreadsheetHorizontalSyncController();
      final width = ValueNotifier<double>(700);
      addTearDown(width.dispose);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_fixture(width, controller));
      await tester.pumpAndSettle();
      final owner = controller.value.controller;

      for (final overflow in [1, 50, 99, 100, 101]) {
        width.value = 600 - overflow.toDouble();
        await tester.pumpAndSettle();

        expect(controller.value.maxScrollExtent,
            closeTo(overflow.toDouble(), 0.01),
            reason: 'extent for $overflow px of hidden content');
        // The package default of 100 is deliberately coarse; a host that wants
        // every hidden pixel to count passes its own threshold.
        expect(controller.value.canScrollRight(threshold: 1), isTrue,
            reason: '$overflow px is scrollable at a 1px tolerance');
        expect(controller.value.controller, same(owner),
            reason: 'the header keeps ownership across resizes');

        // The right arrow must land on the *current* end after a resize.
        await controller.animateToEnd(
            duration: const Duration(milliseconds: 20));
        await tester.pumpAndSettle();
        expect(controller.value.offset, closeTo(overflow.toDouble(), 0.01));
        expect(controller.value.canScrollLeft(threshold: 1), overflow > 1);

        width.value = 700;
        await tester.pumpAndSettle();
        expect(controller.value.maxScrollExtent, 0);
        expect(controller.value.offset, 0);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('resizing at start, middle and end keeps the offset valid',
        (tester) async {
      final controller = SSpreadsheetHorizontalSyncController();
      final width = ValueNotifier<double>(400); // 200px of overflow
      addTearDown(width.dispose);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_fixture(width, controller));
      await tester.pumpAndSettle();
      expect(controller.value.maxScrollExtent, closeTo(200, 0.01));

      for (final target in [0.0, 100.0, 200.0]) {
        controller.value.controller!.jumpTo(target);
        await tester.pumpAndSettle();
        expect(controller.value.offset, closeTo(target, 0.01));

        width.value = 450; // 150px of overflow
        await tester.pumpAndSettle();
        expect(controller.value.maxScrollExtent, closeTo(150, 0.01));
        expect(controller.value.offset,
            lessThanOrEqualTo(controller.value.maxScrollExtent + 0.01),
            reason: 'offset must never outrun the republished extent');

        width.value = 400;
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('changing column widths republishes without a resize',
        (tester) async {
      final controller = SSpreadsheetHorizontalSyncController();
      final width = ValueNotifier<double>(700);
      final columnWidth = ValueNotifier<double>(100);
      addTearDown(width.dispose);
      addTearDown(columnWidth.dispose);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_fixture(width, controller, columnWidth: columnWidth));
      await tester.pumpAndSettle();
      expect(controller.value.maxScrollExtent, 0);

      columnWidth.value = 150; // 6 x 150 = 900 of content in a 700 viewport
      await tester.pumpAndSettle();
      expect(controller.value.maxScrollExtent, closeTo(200, 0.01));
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty content publishes a zero extent, not an exception',
        (tester) async {
      final controller = SSpreadsheetHorizontalSyncController();
      final width = ValueNotifier<double>(700);
      addTearDown(width.dispose);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_fixture(width, controller, columnCount: 0));
      await tester.pumpAndSettle();

      expect(controller.value.maxScrollExtent, 0);
      expect(controller.value.offset, 0);
      expect(tester.takeException(), isNull);
    });
  });

  group('publication hygiene', () {
    testWidgets('a settled layout stops notifying', (tester) async {
      final controller = SSpreadsheetHorizontalSyncController();
      final width = ValueNotifier<double>(700);
      addTearDown(width.dispose);
      addTearDown(controller.dispose);

      var notifications = 0;
      controller.addListener(() => notifications++);

      await tester.pumpWidget(_fixture(width, controller));
      await tester.pumpAndSettle();

      // Flip the width faster than layout can settle, then let it rest — the
      // interrupted/reversed panel-animation case.
      for (final w in [650, 500, 640, 420, 700, 380, 610, 700]) {
        width.value = w.toDouble();
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(controller.value.maxScrollExtent, 0);

      final settled = notifications;
      await tester.pump(const Duration(seconds: 2));
      expect(notifications, settled,
          reason: 'no continuous notification loop once layout has settled');
    });

    testWidgets('an unchanged report does not notify', (tester) async {
      final controller = SSpreadsheetHorizontalSyncController();
      final width = ValueNotifier<double>(500);
      addTearDown(width.dispose);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_fixture(width, controller));
      await tester.pumpAndSettle();

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.refresh();
      controller.refresh();
      await tester.pump();
      expect(notifications, 0,
          reason: 'republishing an identical tuple must be a no-op');
    });

    testWidgets('vertical scrolling does not overwrite horizontal metrics',
        (tester) async {
      final controller = SSpreadsheetHorizontalSyncController();
      final width = ValueNotifier<double>(500); // 100px of horizontal overflow
      addTearDown(width.dispose);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_fixture(width, controller));
      await tester.pumpAndSettle();
      final before = controller.value;
      expect(before.maxScrollExtent, closeTo(100, 0.01));

      await tester.drag(find.text('0:0'), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(controller.value.maxScrollExtent, closeTo(100, 0.01),
          reason: 'a vertical drag must not clobber the horizontal extent');
      expect(controller.value.controller, same(before.controller));
      expect(tester.takeException(), isNull);
    });
  });

  group('controller ownership', () {
    testWidgets('the header owns metrics while it is mounted', (tester) async {
      final controller = SSpreadsheetHorizontalSyncController();
      final width = ValueNotifier<double>(400);
      addTearDown(width.dispose);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_fixture(width, controller));
      await tester.pumpAndSettle();
      final owner = controller.value.controller;
      expect(owner, isNotNull);

      // Scroll the body vertically so rows are recycled underneath. The owner
      // must not follow whichever row happened to report last.
      await tester.drag(find.text('0:0'), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(controller.value.controller, same(owner));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a header-less spreadsheet falls back to a live body strip',
        (tester) async {
      final controller = SSpreadsheetHorizontalSyncController();
      final width = ValueNotifier<double>(400);
      addTearDown(width.dispose);
      addTearDown(controller.dispose);

      await tester
          .pumpWidget(_fixture(width, controller, showColumnHeader: false));
      await tester.pumpAndSettle();

      expect(controller.value.controller, isNotNull,
          reason: 'a body strip must take ownership when there is no header');
      expect(controller.value.maxScrollExtent, closeTo(200, 0.01));
      expect(tester.takeException(), isNull);
    });

    testWidgets('unmounting leaves no dangling controller and scrolls safely',
        (tester) async {
      final controller = SSpreadsheetHorizontalSyncController();
      final width = ValueNotifier<double>(400);
      addTearDown(width.dispose);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_fixture(width, controller));
      await tester.pumpAndSettle();
      expect(controller.value.maxScrollExtent, greaterThan(0));

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      expect(controller.value.controller, isNull,
          reason: 'the disposed strip must not stay published');
      await controller.animateToEnd(duration: const Duration(milliseconds: 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('remounting elects a new owner', (tester) async {
      final controller = SSpreadsheetHorizontalSyncController();
      final width = ValueNotifier<double>(400);
      addTearDown(width.dispose);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_fixture(width, controller));
      await tester.pumpAndSettle();
      final first = controller.value.controller;

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      await tester.pumpWidget(_fixture(width, controller));
      await tester.pumpAndSettle();

      expect(controller.value.controller, isNotNull);
      expect(controller.value.controller, isNot(same(first)));
      expect(controller.value.maxScrollExtent, closeTo(200, 0.01));
      expect(tester.takeException(), isNull);
    });
  });
}

Widget _fixture(
  ValueNotifier<double> width,
  SSpreadsheetHorizontalSyncController controller, {
  int columnCount = 6,
  bool showColumnHeader = true,
  ValueNotifier<double>? columnWidth,
}) {
  final widths = columnWidth ?? ValueNotifier<double>(100);
  return MaterialApp(
    home: Scaffold(
      body: ValueListenableBuilder<double>(
        valueListenable: width,
        builder: (_, currentWidth, __) => ValueListenableBuilder<double>(
          valueListenable: widths,
          builder: (_, currentColumnWidth, __) => SizedBox(
            width: currentWidth,
            height: 300,
            child: SSpreadsheet(
              rowCount: 30,
              columnCount: columnCount,
              showColumnHeader: showColumnHeader,
              columnWidthBuilder: (_) => currentColumnWidth,
              rowHeightBuilder: (_) => 40,
              headerHeight: 40,
              columnHeaderBuilder: (_, column) => Text('Header $column'),
              cellBuilder: (_, row, column) => Text('$row:$column'),
              horizontalSyncController: controller,
            ),
          ),
        ),
      ),
    ),
  );
}
