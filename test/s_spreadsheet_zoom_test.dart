import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/s_spreadsheet/s_spreadsheet.dart';

/// The zoom policy and the viewport primitive it drives.
///
/// These are the two halves every zoom entry point (wheel, keystroke, toolbar
/// control) is built from, so they are asserted on their own rather than
/// through [SSpreadsheet]: the policy is pure arithmetic on a
/// [ValueNotifier], and the viewport is pure geometry.
void main() {
  group('SSpreadsheetZoomController policy', () {
    test('ships a 50%-200% range with a 10% press and a 5% wheel notch', () {
      final controller = SSpreadsheetZoomController();

      expect(SSpreadsheetZoomController.defaultZoom, 1.0);
      expect(controller.zoom, 1.0);
      expect(controller.minZoom, 0.5);
      expect(controller.maxZoom, 2.0);
      expect(controller.step, 0.10);
      expect(controller.wheelStep, 0.05);

      controller.dispose();
    });

    test('clamps an out-of-range initial factor', () {
      final low = SSpreadsheetZoomController(zoom: 0.01);
      final high = SSpreadsheetZoomController(zoom: 9.0);

      expect(low.zoom, 0.5);
      expect(high.zoom, 2.0);

      low.dispose();
      high.dispose();
    });

    test('clamps setZoom to the configured range', () {
      final controller = SSpreadsheetZoomController();

      expect(controller.setZoom(5.0), isTrue);
      expect(controller.zoom, 2.0);
      expect(controller.setZoom(0.1), isTrue);
      expect(controller.zoom, 0.5);
      expect(controller.setZoom(1.3), isTrue);
      expect(controller.zoom, 1.3);

      controller.dispose();
    });

    test('a request that clamps onto the current factor is a silent no-op', () {
      final controller = SSpreadsheetZoomController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.setZoom(2.0);
      expect(notifications, 1);

      // Already at the ceiling: asking for more changes nothing and must not
      // notify, so a wheel stream at the end of the range stays quiet.
      expect(controller.setZoom(2.0), isFalse);
      expect(controller.setZoom(4.0), isFalse);
      expect(notifications, 1);

      // ... and the same at the floor.
      controller.setZoom(0.5);
      expect(notifications, 2);
      expect(controller.setZoom(0.5), isFalse);
      expect(controller.setZoom(-3.0), isFalse);
      expect(notifications, 2);

      controller.dispose();
    });

    test('zoomIn / zoomOut move by exactly one step', () {
      final controller = SSpreadsheetZoomController();

      expect(controller.zoomIn(), isTrue);
      expect(controller.zoom, closeTo(1.10, 1e-9));
      expect(controller.zoomOut(), isTrue);
      expect(controller.zoom, closeTo(1.00, 1e-9));

      controller.dispose();
    });

    test('repeated presses reach the ends of the range and then stop', () {
      final controller = SSpreadsheetZoomController();

      for (var i = 0; i < 30; i++) {
        controller.zoomIn();
      }
      expect(controller.zoom, 2.0);
      expect(controller.canZoomIn, isFalse);
      expect(controller.zoomIn(), isFalse);
      expect(controller.zoom, 2.0);

      for (var i = 0; i < 30; i++) {
        controller.zoomOut();
      }
      expect(controller.zoom, 0.5);
      expect(controller.canZoomOut, isFalse);
      expect(controller.zoomOut(), isFalse);
      expect(controller.zoom, 0.5);

      controller.dispose();
    });

    test('a wheel notch moves half of a button press', () {
      final controller = SSpreadsheetZoomController();

      expect(controller.zoomByWheelNotches(1), isTrue);
      expect(controller.zoom, closeTo(1.05, 1e-9));
      expect(controller.zoomByWheelNotches(-2), isTrue);
      expect(controller.zoom, closeTo(0.95, 1e-9));

      controller.dispose();
    });

    test('reset returns to 100% from either end', () {
      final controller = SSpreadsheetZoomController();

      controller.zoomIn();
      controller.zoomIn();
      expect(controller.reset(), isTrue);
      expect(controller.zoom, 1.0);

      controller.setZoom(2.0);
      expect(controller.reset(), isTrue);
      expect(controller.zoom, 1.0);

      // Already at 100%: nothing to do, nothing to announce.
      expect(controller.reset(), isFalse);

      controller.dispose();
    });

    test('the anchor of a change is handed over exactly once', () {
      final controller = SSpreadsheetZoomController();

      expect(controller.takeAnchor(), isNull, reason: 'nothing requested yet');

      controller.setZoom(1.5, anchor: const Offset(40, 300));
      expect(controller.takeAnchor(), const Offset(40, 300));
      expect(controller.takeAnchor(), isNull,
          reason: 'a consumed anchor must not be applied to a later change');

      // A rejected change (clamped onto the current factor) must not leave a
      // stale anchor behind for whatever changes the factor next.
      controller.setZoom(9.0, anchor: const Offset(7, 7));
      expect(controller.zoom, 2.0);
      expect(controller.takeAnchor(), const Offset(7, 7));
      controller.setZoom(9.0, anchor: const Offset(7, 7));
      expect(controller.takeAnchor(), isNull);

      controller.dispose();
    });

    test('rejects an unusable range or increment', () {
      expect(
          () => SSpreadsheetZoomController(minZoom: 0), throwsAssertionError);
      expect(() => SSpreadsheetZoomController(minZoom: 2, maxZoom: 1),
          throwsAssertionError);
      expect(() => SSpreadsheetZoomController(step: 0), throwsAssertionError);
      expect(
          () => SSpreadsheetZoomController(wheelStep: 0), throwsAssertionError);
      expect(() => SSpreadsheetZoomController(wheelStep: -0.1),
          throwsAssertionError);
    });
  });

  group('SSpreadsheetZoomViewport geometry', () {
    const viewportSize = Size(200, 200);
    const childKey = Key('probe');

    /// Pumps [zoom] into a viewport of exactly [viewportSize] and returns the
    /// box the viewport occupied, so assertions can talk about the viewport.
    Future<void> pumpViewport(WidgetTester tester, double zoom,
        {bool bounded = true}) async {
      final viewport = SSpreadsheetZoomViewport(
        zoom: zoom,
        child: const SizedBox(key: childKey, width: 50, height: 50),
      );

      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: bounded
              ? SizedBox(
                  width: viewportSize.width,
                  height: viewportSize.height,
                  child: viewport,
                )
              // Unbounded in the scroll direction: no viewport to divide, so
              // the pass-through branch must take over.
              : SingleChildScrollView(child: viewport),
        ),
      ));
    }

    Finder transformInsideViewport() => find.descendant(
          of: find.byType(SSpreadsheetZoomViewport),
          matching: find.byType(Transform),
        );

    testWidgets('at 100% the child is passed through untouched',
        (tester) async {
      await pumpViewport(tester, 1.0);

      expect(tester.getSize(find.byKey(childKey)), viewportSize,
          reason: 'the child gets exactly the incoming box');
      expect(transformInsideViewport(), findsNothing,
          reason: 'no scale is applied at 100% — nothing to regress');
    });

    testWidgets('zooming out lays the child out larger and paints it fitted',
        (tester) async {
      await pumpViewport(tester, 0.5);

      // Logically twice the room: this is what reveals more of the sheet.
      expect(tester.getSize(find.byKey(childKey)), const Size(400, 400));
      // ...and it is painted back down to exactly the viewport.
      final painted = tester.getRect(find.byKey(childKey));
      expect(painted.width, closeTo(viewportSize.width, 0.01));
      expect(painted.height, closeTo(viewportSize.height, 0.01));
      expect(
          find.descendant(
            of: find.byType(SSpreadsheetZoomViewport),
            matching: find.byType(ClipRect),
          ),
          findsOneWidget);
    });

    testWidgets('zooming in lays the child out smaller and paints it enlarged',
        (tester) async {
      await pumpViewport(tester, 2.0);

      // Half the room: fewer rows and columns fit, the point of zooming in.
      expect(tester.getSize(find.byKey(childKey)), const Size(100, 100));
      final painted = tester.getRect(find.byKey(childKey));
      expect(painted.width, closeTo(viewportSize.width, 0.01));
      expect(painted.height, closeTo(viewportSize.height, 0.01));
    });

    testWidgets('a W×H child paints at W·zoom × H·zoom', (tester) async {
      for (final zoom in const [0.5, 0.75, 1.5, 2.0]) {
        await pumpViewport(tester, zoom);

        final layout = tester.getSize(find.byKey(childKey));
        expect(layout.width, closeTo(viewportSize.width / zoom, 0.01));
        expect(layout.height, closeTo(viewportSize.height / zoom, 0.01));

        final painted = tester.getRect(find.byKey(childKey));
        expect(painted.width, closeTo(layout.width * zoom, 0.01));
        expect(painted.height, closeTo(layout.height * zoom, 0.01));
        expect(painted.width, closeTo(viewportSize.width, 0.01));
      }
    });

    testWidgets('unbounded constraints fall back to an unscaled layout',
        (tester) async {
      await pumpViewport(tester, 0.5, bounded: false);

      expect(tester.getSize(find.byKey(childKey)), const Size(50, 50),
          reason: 'no viewport to divide, so the child keeps its own size');
      expect(transformInsideViewport(), findsNothing);
    });

    testWidgets('rejects a non-positive factor', (tester) async {
      expect(
        () => SSpreadsheetZoomViewport(zoom: 0, child: const SizedBox()),
        throwsAssertionError,
      );
    });
  });

  group('SSpreadsheet zoom integration', () {
    const double rowH = 100;
    const double colW = 100;
    const double headerH = 50;
    const double rowHeaderW = 50;
    const Size box = Size(400, 400);

    /// Pumps a zoomable sheet inside a fixed [box] and returns its key plus the
    /// vertical controller it scrolls with (supplied, so the test can move it).
    Future<
        ({
          GlobalKey<SSpreadsheetState> key,
          IndexedScrollController vertical
        })> pumpSheet(
      WidgetTester tester, {
      required SSpreadsheetZoomController zoomController,
      bool enableZoomGestures = false,
      int rowCount = 20,
    }) async {
      final key = GlobalKey<SSpreadsheetState>();
      final vertical = IndexedScrollController();

      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: SizedBox(
            width: box.width,
            height: box.height,
            child: SSpreadsheet(
              key: key,
              rowCount: rowCount,
              columnCount: 6,
              headerHeight: headerH,
              rowHeaderWidth: rowHeaderW,
              rowHeightBuilder: (_) => rowH,
              columnWidthBuilder: (_) => colW,
              zoomController: zoomController,
              enableZoomGestures: enableZoomGestures,
              verticalIndexedController: vertical,
              rowHeaderBuilder: (_, row) =>
                  ColoredBox(color: Colors.blueGrey.shade50),
              cornerBuilder: (_) => const ColoredBox(color: Colors.black),
              columnHeaderBuilder: (_, col) =>
                  ColoredBox(color: Colors.blueGrey.shade100),
              cellBuilder: (_, row, col) => ColoredBox(
                  color: (row + col).isEven ? Colors.white : Colors.grey),
            ),
          ),
        ),
      ));

      return (key: key, vertical: vertical);
    }

    /// Sends one wheel notch at the centre of the sheet, with Ctrl held when
    /// [withModifier]. A raw wheel event replaces nothing that [WidgetTester]
    /// offers, so the pointer is built by hand.
    Future<void> wheel(WidgetTester tester, Offset delta,
        {required bool withModifier}) async {
      if (withModifier) {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      }
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      pointer.hover(tester.getCenter(find.byType(SSpreadsheet)));
      await tester.sendEventToBinding(pointer.scroll(delta));
      await tester.pump();
      if (withModifier) {
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      }
    }

    testWidgets('hit testing maps a painted point back through the zoom',
        (tester) async {
      final zoomController = SSpreadsheetZoomController();
      final sheet = await pumpSheet(tester, zoomController: zoomController);
      final state = sheet.key.currentState!;

      // 10 logical pixels into the first cell, at 100%.
      final atOneToOne =
          state.hitTest(rowHeaderW + 10, headerH + 10, box.width, box.height);
      expect(atOneToOne.rowIndex, 0);
      expect(atOneToOne.columnIndex, 0);

      // A row further down tracks the same way, at 100%.
      final secondRowAtOneToOne = state.hitTest(
          rowHeaderW + 10, headerH + rowH + 10, box.width, box.height);
      expect(secondRowAtOneToOne.rowIndex, 1);

      zoomController.setZoom(2.0);
      await tester.pump();

      // The same content point now paints at twice the distance from the
      // sheet's origin, and must still report the same cell.
      final zoomed = state.hitTest(
          (rowHeaderW + 10) * 2, (headerH + 10) * 2, box.width, box.height);
      expect(zoomed.rowIndex, 0);
      expect(zoomed.columnIndex, 0);
      expect(zoomed.rowProgress, closeTo(atOneToOne.rowProgress, 1e-9));
      expect(zoomed.columnProgress, closeTo(atOneToOne.columnProgress, 1e-9));

      final secondRowZoomed = state.hitTest((rowHeaderW + 10) * 2,
          (headerH + rowH + 10) * 2, box.width, box.height);
      expect(secondRowZoomed.rowIndex, 1);

      // The un-scaled coordinate is no longer that cell: at 200% it lands one
      // row higher. This is exactly the mistake the mapping exists to prevent.
      final unscaled = state.hitTest(
          rowHeaderW + 10, headerH + rowH + 10, box.width, box.height);
      expect(unscaled.rowIndex, isNot(1));
    });

    testWidgets('an anchored zoom keeps the content under the anchor in place',
        (tester) async {
      final zoomController = SSpreadsheetZoomController();
      final sheet = await pumpSheet(tester, zoomController: zoomController);
      final state = sheet.key.currentState!;

      // Scroll, so the correction has a non-zero offset to preserve.
      sheet.vertical.controller.jumpTo(300);
      await tester.pump();

      const anchor = Offset(120, 250);
      final before = state.hitTest(anchor.dx, anchor.dy, box.width, box.height);
      expect(before.rowIndex, isNotNull);

      zoomController.setZoom(1.5, anchor: anchor);
      await tester.pump(); // applies the factor and lays the sheet out again
      await tester.pump(); // runs the post-frame offset correction
      await tester.pump();

      final after = state.hitTest(anchor.dx, anchor.dy, box.width, box.height);
      expect(after.rowIndex, before.rowIndex,
          reason: 'the row under the cursor must not move');
      expect(after.rowProgress, closeTo(before.rowProgress, 0.001),
          reason: 'nor the point within that row');
    });

    testWidgets('ctrl+wheel zooms only when gestures are enabled',
        (tester) async {
      final zoomController = SSpreadsheetZoomController();

      await pumpSheet(tester, zoomController: zoomController);
      await wheel(tester, const Offset(0, -120), withModifier: true);
      expect(zoomController.zoom, 1.0,
          reason: 'enableZoomGestures is false, so the wheel is not ours');

      await pumpSheet(
        tester,
        zoomController: zoomController,
        enableZoomGestures: true,
      );
      await wheel(tester, const Offset(0, -120), withModifier: true);
      expect(zoomController.zoom, greaterThan(1.0));

      final afterZoomIn = zoomController.zoom;
      await wheel(tester, const Offset(0, -120), withModifier: false);
      expect(zoomController.zoom, afterZoomIn,
          reason: 'an unmodified wheel keeps scrolling, it does not zoom');

      zoomController.dispose();
    });

    testWidgets('zoom never reaches buildExport or exportSize', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (c) {
          context = c;
          return const SizedBox();
        }),
      ));

      SSpreadsheet sheetAt(double zoom) => SSpreadsheet(
            rowCount: 5,
            columnCount: 3,
            headerHeight: 40,
            rowHeaderWidth: 60,
            rowHeightBuilder: (_) => 30,
            columnWidthBuilder: (_) => 100,
            zoom: zoom,
            rowHeaderBuilder: (_, row) => const ColoredBox(color: Colors.white),
            cornerBuilder: (_) => const ColoredBox(color: Colors.black),
            columnHeaderBuilder: (_, col) =>
                const ColoredBox(color: Colors.yellow),
            cellBuilder: (_, row, col) => const ColoredBox(color: Colors.red),
          );

      // 60 row-header + 3 × 100 columns, and 40 header + 5 × 30 rows: the
      // natural size, whatever the live factor is.
      expect(sheetAt(1.0).exportSize(context), const Size(360, 190));
      expect(sheetAt(2.0).exportSize(context), const Size(360, 190));

      Future<Size> renderedExport(double zoom) async {
        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            // Loose height, so the export reports its natural dimensions
            // rather than being stretched to the test surface.
            child: Align(
              alignment: Alignment.topLeft,
              child: Builder(builder: (c) => sheetAt(zoom).buildExport(c)),
            ),
          ),
        ));
        return tester.getSize(find.byType(Column).first);
      }

      expect(await renderedExport(2.0), await renderedExport(1.0));
      expect(await renderedExport(1.0), const Size(360, 190));
    });
  });
}
