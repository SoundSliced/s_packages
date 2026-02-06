import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_screenshot/s_screenshot.dart';

void main() {
  group('SScreenshot', () {
    testWidgets('captureScreenshot returns base64 string',
        (WidgetTester tester) async {
      final key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepaintBoundary(
              key: key,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        final result = await SScreenshot.capture(
          key,
          config: const ScreenshotConfig(
            resultType: ScreenshotResultType.base64,
          ),
        );

        expect(result, isA<String>());
        expect((result as String).isNotEmpty, true);
      });
    });

    testWidgets('captureScreenshot returns bytes', (WidgetTester tester) async {
      final key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepaintBoundary(
              key: key,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        final result = await SScreenshot.capture(
          key,
          config: const ScreenshotConfig(
            resultType: ScreenshotResultType.bytes,
          ),
        );

        expect(result, isA<Uint8List>());
        expect((result as Uint8List).isNotEmpty, true);
      });
    });

    testWidgets('captureScreenshot with custom pixel ratio',
        (WidgetTester tester) async {
      final key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepaintBoundary(
              key: key,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.green,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        final result1 = await SScreenshot.capture(
          key,
          config: const ScreenshotConfig(
            pixelRatio: 1.0,
            resultType: ScreenshotResultType.bytes,
          ),
        );

        final result2 = await SScreenshot.capture(
          key,
          config: const ScreenshotConfig(
            pixelRatio: 3.0,
            resultType: ScreenshotResultType.bytes,
          ),
        );

        expect((result1 as Uint8List).length,
            lessThan((result2 as Uint8List).length));
      });
    });

    testWidgets('throws ScreenshotException when widget not rendered',
        (WidgetTester tester) async {
      final key = GlobalKey();

      expect(
        () => SScreenshot.capture(key),
        throwsA(isA<ScreenshotException>()),
      );
    });

    testWidgets(
        'throws ScreenshotException when not wrapped in RepaintBoundary',
        (WidgetTester tester) async {
      final key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              key: key,
              width: 100,
              height: 100,
              color: Colors.yellow,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        () => SScreenshot.capture(key),
        throwsA(isA<ScreenshotException>()),
      );
    });

    testWidgets(
        'throws ScreenshotException when fileName missing for download result type',
        (WidgetTester tester) async {
      final key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepaintBoundary(
              key: key,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.purple,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        () => SScreenshot.capture(
          key,
          config: const ScreenshotConfig(
            resultType: ScreenshotResultType.download,
          ),
        ),
        throwsA(
          isA<ScreenshotException>().having(
            (e) => e.message,
            'message',
            contains('fileName is required'),
          ),
        ),
      );
    });

    testWidgets(
        'throws ScreenshotException when fileName missing for download result type',
        (WidgetTester tester) async {
      final key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepaintBoundary(
              key: key,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.teal,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        () => SScreenshot.capture(
          key,
          config: const ScreenshotConfig(
            resultType: ScreenshotResultType.download,
          ),
        ),
        throwsA(
          isA<ScreenshotException>().having(
            (e) => e.message,
            'message',
            contains('fileName is required'),
          ),
        ),
      );
    });

    testWidgets('captureScreenshot with delay', (WidgetTester tester) async {
      final key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepaintBoundary(
              key: key,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.orange,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        final result = await SScreenshot.capture(
          key,
          config: const ScreenshotConfig(
            captureDelay: Duration(milliseconds: 100),
            resultType: ScreenshotResultType.base64,
          ),
        );

        expect(result, isA<String>());
        expect((result as String).isNotEmpty, true);
      });
    });

    testWidgets('downloadScreenshot throws when no callback provided',
        (WidgetTester tester) async {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      const fileName = 'test.png';

      expect(
        () => SScreenshot.downloadScreenshot(
          bytes,
          fileName: fileName,
        ),
        throwsA(isA<ScreenshotException>()),
      );
    });
  });

  group('ScreenshotConfig', () {
    test('has correct default values', () {
      const config = ScreenshotConfig();

      expect(config.pixelRatio, 3.0);
      expect(config.format, ScreenshotFormat.png);
      expect(config.resultType, ScreenshotResultType.base64);
      expect(config.fileName, null);
      expect(config.shouldShowDebugLogs, false);
      expect(config.captureDelay, null);
    });

    test('can be created with custom values', () {
      const config = ScreenshotConfig(
        pixelRatio: 2.0,
        format: ScreenshotFormat.rawRgba,
        resultType: ScreenshotResultType.bytes,
        fileName: 'screenshot.png',
        shouldShowDebugLogs: true,
        captureDelay: Duration(seconds: 1),
      );

      expect(config.pixelRatio, 2.0);
      expect(config.format, ScreenshotFormat.rawRgba);
      expect(config.resultType, ScreenshotResultType.bytes);
      expect(config.fileName, 'screenshot.png');
      expect(config.shouldShowDebugLogs, true);
      expect(config.captureDelay, const Duration(seconds: 1));
    });

    test('supports download result type', () {
      const config = ScreenshotConfig(
        resultType: ScreenshotResultType.download,
        fileName: 'my_screenshot.png',
      );

      expect(config.resultType, ScreenshotResultType.download);
      expect(config.fileName, 'my_screenshot.png');
    });
  });

  group('ScreenshotException', () {
    test('creates exception with message', () {
      final exception = ScreenshotException('Test error');

      expect(exception.message, 'Test error');
      expect(exception.originalError, null);
      expect(exception.toString(), 'ScreenshotException: Test error');
    });

    test('creates exception with message and original error', () {
      final originalError = Exception('Original');
      final exception = ScreenshotException('Test error', originalError);

      expect(exception.message, 'Test error');
      expect(exception.originalError, originalError);
      expect(exception.toString(), contains('Test error'));
      expect(exception.toString(), contains('Original'));
    });
  });
}
