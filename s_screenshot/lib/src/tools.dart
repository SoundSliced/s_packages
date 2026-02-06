part of 's_screenshot.dart';

/// Exception for screenshot capture failures.
class ScreenshotException implements Exception {
  final String message;
  final dynamic originalError;

  ScreenshotException(this.message, [this.originalError]);

  @override
  String toString() =>
      'ScreenshotException: $message${originalError != null ? ' ($originalError)' : ''}';
}

/// Image format for the screenshot.
enum ScreenshotFormat {
  png,
  rawRgba,
}

/// Output type for captured screenshot.
enum ScreenshotResultType {
  /// Returns base64 encoded string
  base64,

  /// Returns Uint8List bytes
  bytes,

  /// Downloads file cross-platform (web: browser download, native: documents directory)
  /// BREAKING CHANGE v2.0.0: Removed 'file' type. Use captureAndDownload() instead.
  download,
}

/// Configuration options for screenshot capture.
class ScreenshotConfig {
  /// Pixel ratio (higher = better quality, larger size).
  final double pixelRatio;

  /// Image format.
  final ScreenshotFormat format;

  /// Output type.
  final ScreenshotResultType resultType;

  /// File name (required for download output). Defaults to 'screenshot_[timestamp].png'
  final String? fileName;

  /// Enable debug logging.
  final bool shouldShowDebugLogs;

  /// Delay before capture (allows animations to complete).
  final Duration? captureDelay;

  const ScreenshotConfig({
    this.pixelRatio = 3.0,
    this.format = ScreenshotFormat.png,
    this.resultType = ScreenshotResultType.base64,
    this.fileName,
    this.shouldShowDebugLogs = false,
    this.captureDelay,
  });
}
