import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/s_screenshot/s_screenshot.dart';
import 'package:s_packages/s_spreadsheet/s_spreadsheet.dart';

void main() {
  testWidgets('captures far-right and final cells beyond both viewport axes',
      (tester) async {
    late BuildContext context;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (c) {
      context = c;
      return const SizedBox();
    })));
    final sheet = SSpreadsheet(
      rowCount: 30,
      columnCount: 6,
      headerHeight: 40,
      rowHeaderWidth: 60,
      rowHeightBuilder: (_) => 30,
      columnWidthBuilder: (_) => 180,
      rowHeaderBuilder: (_, row) => const ColoredBox(color: Colors.white),
      cornerBuilder: (_) => const ColoredBox(color: Colors.black),
      columnHeaderBuilder: (_, col) => const ColoredBox(color: Colors.yellow),
      cellBuilder: (_, row, col) => ColoredBox(
          color: row == 29 && col == 5
              ? const Color(0xFF00FF00)
              : const Color(0xFFFF0000)),
    );
    final size = sheet.exportSize(context);
    expect(size, const Size(1140, 940));
    final bytes = await tester.runAsync(() => SScreenshot.captureWidget(
          context: context,
          child: sheet.buildExport(context),
          logicalSize: size,
          pixelRatio: 1,
          settleDelay: Duration.zero,
        ));
    final image = await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(bytes!);
      try {
        return (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
    });
    expect(image!.width, 1140);
    expect(image.height, 940);
    final pixels = await tester
        .runAsync(() => image.toByteData(format: ui.ImageByteFormat.rawRgba));
    final offset = ((image.height - 10) * image.width + image.width - 10) * 4;
    expect(pixels!.buffer.asUint8List(offset, 4), [0, 255, 0, 255]);
    image.dispose();
    expect(tester.takeException(), isNull);
  });

  testWidgets('selected rows retain ordering, dimensions, headers and padding',
      (tester) async {
    late BuildContext context;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (c) {
      context = c;
      return const SizedBox();
    })));
    final seen = <int>[];
    final sheet = SSpreadsheet(
        rowCount: 10,
        columnCount: 2,
        padding: const EdgeInsets.all(5),
        rowPadding: const EdgeInsets.all(2),
        rowHeaderBuilder: (_, row) => const SizedBox(),
        rowHeightBuilder: (row) => 30 + row.toDouble(),
        cellBuilder: (_, row, col) {
          seen.add(row);
          return Text('$row/$col');
        });
    expect(sheet.exportSize(context, rowIndices: [9, 2]), const Size(474, 129));
    await tester.pumpWidget(MaterialApp(
        home: Center(child: sheet.buildExport(context, rowIndices: [9, 2]))));
    expect(seen, [9, 9, 2, 2]);
    expect(find.text('9/1'), findsOneWidget);
    expect(find.text('2/1'), findsOneWidget);
    expect(find.text('0/0'), findsNothing);
    expect(tester.takeException(), isNull);
    expect(
        () => sheet.buildExport(context, rowIndices: [-1]), throwsRangeError);
  });

  testWidgets('output shrinks proportionally and detached widgets are disposed',
      (tester) async {
    late BuildContext context;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (c) {
      context = c;
      return const SizedBox();
    })));
    var disposed = false;
    final bytes = await tester.runAsync(() => SScreenshot.captureWidget(
        context: context,
        child: _DisposeProbe(() => disposed = true),
        logicalSize: const Size(1000, 2000),
        pixelRatio: 2,
        maxPixelDimension: 1000,
        maxPixels: 500000,
        settleDelay: Duration.zero));
    final image = await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(bytes!);
      try {
        return (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
    });
    expect(Size(image!.width.toDouble(), image.height.toDouble()),
        const Size(500, 1000));
    image.dispose();
    expect(disposed, isTrue);
    expect(tester.takeException(), isNull);
    await expectLater(
        SScreenshot.captureWidget(
            context: context, child: const SizedBox(), logicalSize: Size.zero),
        throwsArgumentError);
  });

  testWidgets(
      'viewport includes partially visible rows after vertical and horizontal scrolling',
      (tester) async {
    final key = GlobalKey<SSpreadsheetState>();
    final vertical = IndexedScrollController();
    final horizontal = SSpreadsheetHorizontalSyncController();
    await tester.pumpWidget(MaterialApp(
        home: Center(
            child: SizedBox(
                width: 250,
                height: 145,
                child: SSpreadsheet(
                    key: key,
                    rowCount: 30,
                    columnCount: 6,
                    headerHeight: 40,
                    rowHeightBuilder: (_) => 30,
                    verticalIndexedController: vertical,
                    horizontalSyncController: horizontal,
                    enableRowAnimations: false,
                    cellBuilder: (_, row, col) => Text('$row/$col'))))));
    await tester.pumpAndSettle();
    vertical.controller.jumpTo(45);
    horizontal.value.controller!.jumpTo(200);
    await tester.pumpAndSettle();
    expect(key.currentState!.visibleRowIndices, [1, 2, 3, 4]);
    await tester.pumpWidget(const SizedBox());
    vertical.dispose();
    horizontal.dispose();
  });
}

class _DisposeProbe extends StatefulWidget {
  final VoidCallback onDispose;
  const _DisposeProbe(this.onDispose);
  @override
  State<_DisposeProbe> createState() => _DisposeProbeState();
}

class _DisposeProbeState extends State<_DisposeProbe> {
  @override
  Widget build(BuildContext context) => const ColoredBox(color: Colors.blue);
  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }
}
