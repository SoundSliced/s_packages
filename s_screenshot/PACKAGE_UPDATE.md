# S_Screenshot Package Update - Cross-Platform Download Support

## Overview

The `s_screenshot` package now includes built-in cross-platform file downloading functionality. The package intelligently handles file saving based on the platform:

- **Web**: Uses `file_saver` for browser downloads
- **Native** (iOS, Android, macOS, Windows, Linux): Saves to application documents directory using `path_provider`

## New Features

### 1. `downloadScreenshot()` Method

Downloads screenshot bytes cross-platform with platform-specific callbacks:

```dart
static Future<dynamic> downloadScreenshot(
  List<int> bytes, {
  required String fileName,
  Future<void> Function(List<int>, String)? fileSaverCallback,
  Future<File> Function(List<int>, String)? pathProviderCallback,
}) async
```

**Parameters:**
- `bytes`: The image bytes to save
- `fileName`: The name of the file (e.g., 'screenshot.png')
- `fileSaverCallback`: Required on web. Handles file saving using `file_saver` package
- `pathProviderCallback`: Required on native. Handles file saving using `path_provider` package

**Returns:**
- On web: The `fileName` as a String
- On native: A File instance pointing to the saved file

**Example:**
```dart
await SScreenshot.downloadScreenshot(
  bytes,
  fileName: 'screenshot.png',
  fileSaverCallback: kIsWeb
      ? (bytes, name) async {
          await FileSaver.instance.saveFile(
            name: name,
            bytes: Uint8List.fromList(bytes),
            mimeType: MimeType.png,
          );
        }
      : null,
  pathProviderCallback: !kIsWeb
      ? (bytes, name) async {
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/$name');
          await file.writeAsBytes(bytes);
          return file;
        }
      : null,
);
```

### 2. `captureAndDownload()` Method

Convenience method that combines capture and download in one call:

```dart
static Future<dynamic> captureAndDownload(
  GlobalKey key, {
  String? fileName,
  double pixelRatio = 3.0,
  Duration? captureDelay,
  bool shouldShowDebugLogs = false,
  Future<void> Function(List<int>, String)? fileSaverCallback,
  Future<File> Function(List<int>, String)? pathProviderCallback,
}) async
```

**Example:**
```dart
await SScreenshot.captureAndDownload(
  _screenshotKey,
  fileName: 'my_screenshot.png',
  fileSaverCallback: kIsWeb
      ? (bytes, name) async {
          await FileSaver.instance.saveFile(
            name: name,
            bytes: Uint8List.fromList(bytes),
            mimeType: MimeType.png,
          );
        }
      : null,
  pathProviderCallback: !kIsWeb
      ? (bytes, name) async {
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/$name');
          await file.writeAsBytes(bytes);
          return file;
        }
      : null,
);
```

## Updated Enums

### ScreenshotResultType

Added `download` option:

```dart
enum ScreenshotResultType {
  base64,       // Returns base64 encoded string
  bytes,        // Returns Uint8List bytes
  file,         // Returns File (requires filePath)
  download,     // Downloads file cross-platform (reserved for future use)
}
```

## Updated Configuration

### ScreenshotConfig

Added `fileName` parameter:

```dart
class ScreenshotConfig {
  final double pixelRatio;
  final ScreenshotFormat format;
  final ScreenshotResultType resultType;
  final String? filePath;        // For file type
  final String? fileName;        // For download type
  final bool shouldShowDebugLogs;
  final Duration? captureDelay;
  
  const ScreenshotConfig({...});
}
```

## Dependencies

The package now includes:

```yaml
dependencies:
  file_saver: ^0.2.13      # For web downloads
  path_provider: ^2.1.0    # For native file saving
```

## Why Callback-Based Approach?

The package uses callbacks instead of direct imports to:

1. **Avoid Forced Dependencies**: Users only need to import `file_saver` or `path_provider` based on their target platforms
2. **Better Code Organization**: Platform-specific code stays in the application layer
3. **Flexibility**: Users have full control over which MIME types and save options to use
4. **Cleaner API**: No complex conditional imports needed in the package core

## Migration Guide

### Before:
```dart
// Only worked on native platforms
final directory = await getApplicationDocumentsDirectory();
final file = await SScreenshot.capture(
  key,
  config: ScreenshotConfig(
    resultType: ScreenshotResultType.file,
    filePath: '${directory.path}/screenshot.png',
  ),
);
```

### After:
```dart
// Works on all platforms!
if (kIsWeb) {
  await SScreenshot.downloadScreenshot(
    bytes,
    fileName: 'screenshot.png',
    fileSaverCallback: (bytes, name) async {
      await FileSaver.instance.saveFile(
        name: name,
        bytes: Uint8List.fromList(bytes),
        mimeType: MimeType.png,
      );
    },
  );
} else {
  await SScreenshot.downloadScreenshot(
    bytes,
    fileName: 'screenshot.png',
    pathProviderCallback: (bytes, name) async {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$name');
      await file.writeAsBytes(bytes);
      return file;
    },
  );
}
```

## Platform-Specific Code Example

Create a helper function for cleaner code:

```dart
Future<dynamic> downloadScreenshot(List<int> bytes, String fileName) {
  return SScreenshot.downloadScreenshot(
    bytes,
    fileName: fileName,
    fileSaverCallback: kIsWeb
        ? (bytes, name) async {
            await FileSaver.instance.saveFile(
              name: name,
              bytes: Uint8List.fromList(bytes),
              mimeType: MimeType.png,
            );
          }
        : null,
    pathProviderCallback: !kIsWeb
        ? (bytes, name) async {
            final directory = await getApplicationDocumentsDirectory();
            final file = File('${directory.path}/$name');
            await file.writeAsBytes(bytes);
            return file;
          }
        : null,
  );
}

// Usage
await downloadScreenshot(bytes, 'screenshot.png');
```

## Error Handling

The package will throw `ScreenshotException` if:
- Required callback is null on the target platform
- File writing fails
- MIME type is invalid

```dart
try {
  await SScreenshot.downloadScreenshot(
    bytes,
    fileName: 'screenshot.png',
    fileSaverCallback: ...,
    pathProviderCallback: ...,
  );
} on ScreenshotException catch (e) {
  print('Error: ${e.message}');
}
```

## Full Working Example

See the example app in `/example/lib/main.dart` for a complete, production-ready implementation showcasing:
- All capture methods (base64, bytes, file)
- Cross-platform downloading
- Error handling
- UI feedback during capture/download

Run with:
```bash
cd example
flutter pub get
flutter run
```

## Version History

- **v1.0.0** - Initial release with cross-platform screenshot capture
- **v1.1.0** - Added cross-platform download support with callbacks (this update)

## Support

- 📱 **Platforms**: Web, iOS, Android, macOS, Windows, Linux
- 📦 **Formats**: PNG (recommended), JPEG, and custom MIME types
- 🎯 **Use Cases**: Screenshot capture, export, sharing, analytics
