import 'dart:convert';
import 'package:universal_io/io.dart';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

part 'tools.dart';

class SScreenshot {
  /// Captures a widget screenshot using the provided [key].
  ///
  /// Returns String (base64), Uint8List (bytes), or File based on [config].
  /// Throws [ScreenshotException] on failure.
  static Future<dynamic> capture(
    GlobalKey key, {
    ScreenshotConfig config = const ScreenshotConfig(),
  }) async {
    try {
      if (config.resultType == ScreenshotResultType.download &&
          (config.fileName == null || config.fileName!.isEmpty)) {
        throw ScreenshotException(
            'fileName is required when resultType is download');
      }

      // Get render object before any async operations to avoid BuildContext issues
      final context = key.currentContext;
      if (context == null) {
        throw ScreenshotException(
            'Widget is not yet rendered. Make sure the GlobalKey is attached to a widget in the tree.');
      }

      final renderObject = context.findRenderObject();
      if (renderObject == null) {
        throw ScreenshotException(
            'RenderObject not found. Make sure the widget is visible.');
      }

      if (renderObject is! RenderRepaintBoundary) {
        throw ScreenshotException(
            'The widget must be wrapped in a RepaintBoundary.');
      }

      if (config.captureDelay != null) {
        await Future.delayed(config.captureDelay!);
      }

      // Wait for the rendering pipeline to fully complete
      final boundary = renderObject;
      await WidgetsBinding.instance.endOfFrame;

      // Capture and immediately extract byte data, then dispose the native image
      final image = await boundary.toImage(pixelRatio: config.pixelRatio);
      final ByteData? byteData;
      try {
        byteData = await image.toByteData(
            format: config.format == ScreenshotFormat.png
                ? ui.ImageByteFormat.png
                : ui.ImageByteFormat.rawRgba);
      } finally {
        image.dispose();
      }

      if (byteData == null) {
        throw ScreenshotException('Failed to convert image to byte data');
      }

      // Use precise offset and length to avoid reading beyond actual data
      final buffer = byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

      if (kDebugMode && config.shouldShowDebugLogs) {
        debugPrint('Screenshot captured: ${buffer.length} bytes');
      }
      switch (config.resultType) {
        case ScreenshotResultType.base64:
          // Offload base64 encoding to a separate isolate on native platforms;
          // on web, isolates aren't supported so we encode on the main thread.
          final base64String = kIsWeb
              ? base64Encode(buffer)
              : await compute(base64Encode, buffer);
          if (kDebugMode && config.shouldShowDebugLogs) {
            debugPrint('Base64 length: ${base64String.length}');
          }
          return base64String;

        case ScreenshotResultType.bytes:
          return buffer;

        case ScreenshotResultType.download:
          // For download type, return bytes and let downloadScreenshot handle the file saving
          return buffer;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Screenshot capture failed: $e');
      }
      if (e is ScreenshotException) {
        rethrow;
      }
      throw ScreenshotException('Failed to capture screenshot', e);
    }
  }

  /// Downloads a screenshot file cross-platform.
  ///
  /// **Platform-specific behavior:**
  /// - **Web**: Uses `file_saver` to trigger browser download
  /// - **Native**: Saves to application documents directory using `path_provider`
  ///
  /// **Parameters:**
  /// - [bytes]: The image bytes to save
  /// - [fileName]: The name of the file (e.g., 'screenshot.png')
  /// - [fileSaverCallback]: Callback for web downloads using `file_saver` package
  /// - [pathProviderCallback]: Callback for native saves using `path_provider` package
  ///
  /// **Returns:**
  /// - On web: Returns the [fileName] as a String
  /// - On native: Returns a File instance pointing to the saved file
  ///
  /// **Throws:** [ScreenshotException] on failure
  ///
  /// **Example:**
  /// ```dart
  /// // On web
  /// if (kIsWeb) {
  ///   await SScreenshot.downloadScreenshot(
  ///     bytes,
  ///     fileName: 'screenshot.png',
  ///     fileSaverCallback: (bytes, fileName) async {
  ///       await FileSaver.instance.saveFile(
  ///         name: fileName,
  ///         bytes: bytes,
  ///         ext: fileName.split('.').last,
  ///         mimeType: MimeType.png,
  ///       );
  ///     },
  ///   );
  /// } else {
  /// // On native
  ///   await SScreenshot.downloadScreenshot(
  ///     bytes,
  ///     fileName: 'screenshot.png',
  ///     pathProviderCallback: (bytes, fileName) async {
  ///       final directory = await getApplicationDocumentsDirectory();
  ///       final file = File('${directory.path}/$fileName');
  ///       await file.writeAsBytes(bytes);
  ///       return file;
  ///     },
  ///   );
  /// }
  /// ```
  static Future<dynamic> downloadScreenshot(
    List<int> bytes, {
    required String fileName,
    Future<void> Function(List<int>, String)? fileSaverCallback,
    Future<File> Function(List<int>, String)? pathProviderCallback,
  }) async {
    try {
      if (fileName.isEmpty) {
        throw ScreenshotException('fileName cannot be empty');
      }

      if (kIsWeb) {
        // Web platform: use file_saver callback
        if (fileSaverCallback == null) {
          throw ScreenshotException(
            'fileSaverCallback is required on web platform. '
            'Make sure to import file_saver package and provide the callback.',
          );
        }
        await fileSaverCallback(bytes, fileName);
        return fileName;
      } else {
        // Native platforms: use path_provider callback
        if (pathProviderCallback == null) {
          throw ScreenshotException(
            'pathProviderCallback is required on native platforms. '
            'Make sure to import path_provider package and provide the callback.',
          );
        }
        return await pathProviderCallback(bytes, fileName);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Screenshot download failed: $e');
      }
      if (e is ScreenshotException) {
        rethrow;
      }
      throw ScreenshotException('Failed to download screenshot', e);
    }
  }

  /// Captures and downloads a screenshot in one step.
  ///
  /// This is a convenience method that combines [capture] and [downloadScreenshot].
  ///
  /// **Parameters:**
  /// - [key]: The GlobalKey of the widget to capture
  /// - [fileName]: Optional custom file name. Defaults to 'screenshot_[timestamp].png'
  /// - [pixelRatio]: The pixel ratio for capture quality. Defaults to 3.0
  /// - [captureDelay]: Optional delay before capturing to allow animations to complete
  /// - [shouldShowDebugLogs]: Enable debug logging. Defaults to false
  /// - [fileSaverCallback]: Required on web. Callback for file saving using `file_saver`
  /// - [pathProviderCallback]: Required on native. Callback for file saving using `path_provider`
  ///
  /// **Returns:** The result of [downloadScreenshot]
  ///
  /// **Example:**
  /// ```dart
  /// await SScreenshot.captureAndDownload(
  ///   _screenshotKey,
  ///   fileName: 'my_screenshot.png',
  ///   fileSaverCallback: kIsWeb ? (bytes, name) async {
  ///     await FileSaver.instance.saveFile(
  ///       name: name,
  ///       bytes: bytes,
  ///       ext: name.split('.').last,
  ///       mimeType: MimeType.png,
  ///     );
  ///   } : null,
  ///   pathProviderCallback: !kIsWeb ? (bytes, name) async {
  ///     final dir = await getApplicationDocumentsDirectory();
  ///     final file = File('${dir.path}/$name');
  ///     await file.writeAsBytes(bytes);
  ///     return file;
  ///   } : null,
  /// );
  /// ```
  static Future<dynamic> captureAndDownload(
    GlobalKey key, {
    String? fileName,
    double pixelRatio = 3.0,
    Duration? captureDelay,
    bool shouldShowDebugLogs = false,
    Future<void> Function(List<int>, String)? fileSaverCallback,
    Future<File> Function(List<int>, String)? pathProviderCallback,
  }) async {
    try {
      final fileName_ =
          fileName ?? 'screenshot_${DateTime.now().millisecondsSinceEpoch}.png';

      // First capture as bytes
      final bytes = await capture(
        key,
        config: ScreenshotConfig(
          pixelRatio: pixelRatio,
          resultType: ScreenshotResultType.bytes,
          captureDelay: captureDelay,
          shouldShowDebugLogs: shouldShowDebugLogs,
        ),
      ) as List<int>;

      // Then download
      return await downloadScreenshot(
        bytes,
        fileName: fileName_,
        fileSaverCallback: fileSaverCallback,
        pathProviderCallback: pathProviderCallback,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Capture and download failed: $e');
      }
      if (e is ScreenshotException) {
        rethrow;
      }
      throw ScreenshotException('Failed to capture and download screenshot', e);
    }
  }
}

// Platform-specific implementations
// These functions are kept as helpers for potential future use
// Users should provide callbacks directly to downloadScreenshot and captureAndDownload
