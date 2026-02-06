# s_screenshot

A powerful and flexible Flutter package for capturing high-quality screenshots of widgets with multiple output formats, cross-platform file saving, and comprehensive configuration options.

## Features

✨ **Multiple Output Formats**
- Base64 encoded string
- Raw bytes (Uint8List)
- **[BREAKING] Download to device** with `file_saver` (unified approach for all platforms)
  - Removed direct file save (use downloads instead)

🌐 **Cross-Platform File Saving**
- **Web**: Browser downloads via `file_saver`
- **Mobile (iOS/Android)**: Application documents directory
- **Desktop (Windows/macOS/Linux)**: Downloads folder
- Unified API with callback-based platform handling

🎨 **Configurable Options**
- Custom pixel ratio for quality control
- PNG or raw RGBA format support
- Optional capture delay for animations
- Debug logging
- **[NEW] Customizable file names for downloads**

🛡️ **Robust Error Handling**
- Type-safe exceptions with detailed error messages
- Widget validation before capture
- Clear error reporting
- Platform-specific error guidance

🔧 **Easy to Use**
- Simple API with sensible defaults
- **Breaking changes from v1.0.0** - see migration guide
- Comprehensive example app
- Well-documented with platform setup guides

## Demo
![Demo](https://raw.githubusercontent.com/SoundSliced/s_screenshot/main/example/assets/example.gif)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  s_screenshot: ^2.0.0
```

Then run:
```bash
flutter pub get
```

## Platform-Specific Setup

### iOS & macOS

To enable file saving on iOS and macOS, please follow the configuration guide:

📖 [iOS & macOS Setup Guide](IOS_MACOS_SETUP.md)

Quick summary:
- **iOS**: Add file sharing support to `Info.plist`
- **macOS**: Add downloads folder access to entitlements

## Usage

### 1. Basic Usage - Capture as Base64

```dart
import 'package:flutter/material.dart';
import 'package:s_screenshot/s_screenshot.dart';

class MyWidget extends StatelessWidget {
  final GlobalKey _screenshotKey = GlobalKey();

  Future<void> captureScreenshot() async {
    try {
      final base64String = await SScreenshot.capture(
        _screenshotKey,
        config: const ScreenshotConfig(
          resultType: ScreenshotResultType.base64,
        ),
      );
      
      print('Screenshot captured: ${base64String.length} characters');
    } on ScreenshotException catch (e) {
      print('Error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _screenshotKey,
      child: Container(
        // Your widget content here
      ),
    );
  }
}
```

### 2. Capture as Bytes

```dart
final bytes = await SScreenshot.capture(
  _screenshotKey,
  config: const ScreenshotConfig(
    resultType: ScreenshotResultType.bytes,
    pixelRatio: 2.0,
  ),
) as Uint8List;

// Use the bytes directly
await someApi.uploadImage(bytes);
```

### 3. **Download Screenshot (Cross-Platform - Recommended)**

The easiest way to save files across all platforms (web, mobile, desktop):

```dart
import 'package:s_screenshot/s_screenshot.dart';
import 'package:file_saver/file_saver.dart';

Future<void> downloadScreenshot() async {
  try {
    // Captures and downloads in one step
    await SScreenshot.captureAndDownload(
      _screenshotKey,
      fileName: 'my_screenshot.png',
      pixelRatio: 3.0,
      fileSaverCallback: (bytes, name) async {
        await FileSaver.instance.saveFile(
          name: name,
          bytes: Uint8List.fromList(bytes),
          mimeType: MimeType.png,
        );
      },
    );
  } on ScreenshotException catch (e) {
    print('Error: ${e.message}');
  }
}
```

### 5. Capture with Delay

Useful for waiting for animations to complete:

```dart
final screenshot = await SScreenshot.capture(
  _screenshotKey,
  config: const ScreenshotConfig(
    captureDelay: Duration(milliseconds: 500),
    resultType: ScreenshotResultType.base64,
  ),
);
```

### 6. Custom Configuration

```dart
final screenshot = await SScreenshot.capture(
  _screenshotKey,
  config: const ScreenshotConfig(
    pixelRatio: 4.0,              // Higher quality
    format: ScreenshotFormat.png,  // PNG or rawRgba
    resultType: ScreenshotResultType.bytes,
    shouldShowDebugLogs: true,     // Enable logging
    captureDelay: Duration(seconds: 1),
  ),
);
```

## Configuration Options

### ScreenshotConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `pixelRatio` | `double` | `3.0` | Pixel ratio for screenshot quality (higher = better quality but larger size) |
| `format` | `ScreenshotFormat` | `png` | Image format: `png` or `rawRgba` |
| `resultType` | `ScreenshotResultType` | `base64` | Output format: `base64`, `bytes`, or `download` |
| `fileName` | `String?` | `null` | File name (required when `resultType` is `download`) |
| `shouldShowDebugLogs` | `bool` | `false` | Enable debug logging |
| `captureDelay` | `Duration?` | `null` | Delay before capturing (useful for animations) |

### Result Types

- **`ScreenshotResultType.base64`**: Returns a `String` with base64-encoded image
- **`ScreenshotResultType.bytes`**: Returns `Uint8List` with raw image bytes
- **`ScreenshotResultType.download`**: Triggers cross-platform download (use with `captureAndDownload()` method)

## API Methods

### `SScreenshot.capture()`

Captures a widget screenshot with the specified configuration.

```dart
static Future<dynamic> capture(
  GlobalKey key, {
  ScreenshotConfig config = const ScreenshotConfig(),
}) async
```

### `SScreenshot.downloadScreenshot()`

Downloads screenshot bytes cross-platform using `file_saver` (web) or file system (native).

```dart
static Future<dynamic> downloadScreenshot(
  List<int> bytes, {
  required String fileName,
  Future<void> Function(List<int>, String)? fileSaverCallback,
  Future<File> Function(List<int>, String)? pathProviderCallback,
}) async
```

### `SScreenshot.captureAndDownload()`

Convenience method that combines capture and download in one step.

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

## Error Handling

The package throws `ScreenshotException` with detailed error messages:

```dart
try {
  final screenshot = await SScreenshot.capture(_key);
} on ScreenshotException catch (e) {
  print('Screenshot failed: ${e.message}');
  if (e.originalError != null) {
    print('Original error: ${e.originalError}');
  }
}
```

Common errors:
- Widget not yet rendered
- Widget not wrapped in `RepaintBoundary`
- Missing file path when using `file` result type
- Missing file name when using `download` result type
- Failed to convert image to byte data

## Important Notes

1. **RepaintBoundary Required**: Always wrap the widget you want to capture in a `RepaintBoundary`:

```dart
RepaintBoundary(
  key: _screenshotKey,
  child: YourWidget(),
)
```

2. **Widget Must Be Rendered**: Ensure the widget is visible and rendered before capturing:

```dart
await tester.pumpAndSettle(); // In tests
await Future.delayed(Duration(milliseconds: 100)); // In production if needed
```

3. **Pixel Ratio Impact**: Higher pixel ratios produce better quality but larger file sizes:
   - `1.0`: Low quality, small size
   - `2.0`: Medium quality
   - `3.0`: High quality (default)
   - `4.0+`: Very high quality, large size

4. **Cross-Platform Downloads**: When using `captureAndDownload()` with `fileSaverCallback`:
   - Make sure to import `file_saver` package
   - Check [iOS & macOS Setup Guide](IOS_MACOS_SETUP.md) for platform requirements

## Dependencies

- `flutter`: ^3.0.0
- `universal_io`: ^2.2.2 (for cross-platform File handling)
- `file_saver`: ^0.3.1 (for cross-platform downloads)
- `path_provider`: ^2.1.0 (optional, for native file paths)

These dependencies are automatically available through the package exports.

## Example

Check out the [example](example/) directory for a complete working app demonstrating all features.

To run the example:

```bash
cd example
flutter pub get
flutter run
```

## Testing

The package includes comprehensive tests covering:
- Base64 output
- Bytes output
- File output
- Custom pixel ratios
- Error handling and validation
- Configuration defaults

Run tests with:

```bash
flutter test
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and detailed changes.

## What's New in v2.0.0

🚀 **Major Breaking Release - Unified Cross-Platform Approach**

### Breaking Changes ⚠️
- **REMOVED**: `ScreenshotResultType.file` - use `captureAndDownload()` instead
- **REMOVED**: `ScreenshotConfig.filePath` parameter
- **Rationale**: Unified file handling across all platforms (web, mobile, desktop) via downloads

### New Features ✨
- ✨ New `downloadScreenshot()` method for cross-platform file saving
- ✨ New `captureAndDownload()` convenience method
- ✨ Support for `file_saver` package (works on all platforms)
- ✨ Callback-based architecture for flexible platform handling
- ✨ Added `universal_io` for unified File API
- 🔄 Updated `ScreenshotResultType` enum with unified `download` option
- 🔄 Enhanced `ScreenshotConfig` with `fileName` parameter only (no more filePath)
- 📖 Comprehensive iOS & macOS setup guide

### Migration from v1.0.0 → v2.0.0

**Old approach (v1.0.0):**
```dart
// Save directly to file
final file = await SScreenshot.capture(
  key,
  config: ScreenshotConfig(
    resultType: ScreenshotResultType.file,
    filePath: '/path/to/file.png',
  ),
) as File;
```

**New approach (v2.0.0):**
```dart
// Use captureAndDownload with callback
await SScreenshot.captureAndDownload(
  key,
  fileName: 'screenshot.png',
  fileSaverCallback: (bytes, name) async {
    await FileSaver.instance.saveFile(
      name: name,
      bytes: bytes,
      mimeType: MimeType.png,
    );
  },
);
```

### Why This Change?
The old `file` approach required platform-specific code and different methods for web vs. native platforms. The new unified download approach with callbacks provides:
- Single API for all platforms
- Consistent behavior across web, mobile, and desktop
- More flexibility with platform-specific implementations
- Better separation of concerns (package focuses on capture, callbacks handle platform details)

## License

MIT License - feel free to use this package in your projects.

See [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Repository

https://github.com/SoundSliced/s_screenshot

## Support

For issues, questions, or feature requests, please open an issue on [GitHub](https://github.com/SoundSliced/s_screenshot/issues).
