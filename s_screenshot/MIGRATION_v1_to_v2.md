# Migration Guide: s_screenshot v1.0.0 → v2.0.0

## Overview

v2.0.0 is a **breaking release** that unifies file saving across all platforms (web, mobile, desktop) using a callback-based approach. The direct file save functionality (`ScreenshotResultType.file`) has been removed.

## Breaking Changes

### 1. Removed: `ScreenshotResultType.file`

**v1.0.0 (Removed):**
```dart
final file = await SScreenshot.capture(
  key,
  config: ScreenshotConfig(
    resultType: ScreenshotResultType.file,
    filePath: '/path/to/screenshot.png',
  ),
) as File;
```

**v2.0.0 (Use this instead):**
```dart
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

### 2. Removed: `ScreenshotConfig.filePath` Parameter

This parameter is no longer needed. Use `fileName` instead, and provide platform-specific handling via callbacks.

**v1.0.0:**
```dart
ScreenshotConfig(
  filePath: '/path/to/file.png',  // ❌ REMOVED
)
```

**v2.0.0:**
```dart
ScreenshotConfig(
  fileName: 'screenshot.png',  // ✅ Use this with captureAndDownload()
)
```

## What Stays the Same

All capture functionality remains **identical**:

```dart
// Base64 - unchanged
final base64 = await SScreenshot.capture(key);

// Bytes - unchanged
final bytes = await SScreenshot.capture(
  key,
  config: const ScreenshotConfig(
    resultType: ScreenshotResultType.bytes,
  ),
);

// All config options for capture - unchanged
final screenshot = await SScreenshot.capture(
  key,
  config: ScreenshotConfig(
    pixelRatio: 3.0,
    format: ScreenshotFormat.png,
    captureDelay: Duration(milliseconds: 500),
    shouldShowDebugLogs: true,
  ),
);
```

## New APIs

### `captureAndDownload()` - Recommended

Combines capture and download in one step:

```dart
await SScreenshot.captureAndDownload(
  _screenshotKey,
  fileName: 'my_screenshot.png',
  pixelRatio: 3.0,
  fileSaverCallback: kIsWeb ? (bytes, name) async {
    // Web: Use file_saver for browser download
    await FileSaver.instance.saveFile(
      name: name,
      bytes: bytes,
      mimeType: MimeType.png,
    );
  } : null,
  pathProviderCallback: !kIsWeb ? (bytes, name) async {
    // Native: Save to application directory
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  } : null,
);
```

### `downloadScreenshot()` - For Advanced Use

For manual capture followed by download:

```dart
// Step 1: Capture
final bytes = await SScreenshot.capture(
  key,
  config: const ScreenshotConfig(
    resultType: ScreenshotResultType.bytes,
  ),
) as List<int>;

// Step 2: Download
await SScreenshot.downloadScreenshot(
  bytes,
  fileName: 'screenshot.png',
  fileSaverCallback: (bytes, name) async {
    // Handle web download
  },
  pathProviderCallback: (bytes, name) async {
    // Handle native save
  },
);
```

## Platform-Specific Examples

### Web

```dart
import 'package:file_saver/file_saver.dart';
import 'package:s_screenshot/s_screenshot.dart';

await SScreenshot.captureAndDownload(
  _screenshotKey,
  fileName: 'screenshot.png',
  fileSaverCallback: (bytes, name) async {
    await FileSaver.instance.saveFile(
      name: name,
      bytes: Uint8List.fromList(bytes),
      mimeType: MimeType.png,
    );
  },
);
```

### iOS/Android

```dart
import 'package:path_provider/path_provider.dart';
import 'package:s_screenshot/s_screenshot.dart';

await SScreenshot.captureAndDownload(
  _screenshotKey,
  fileName: 'screenshot.png',
  pathProviderCallback: (bytes, name) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  },
);
```

### Cross-Platform

```dart
import 'package:flutter/foundation.dart';
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:s_screenshot/s_screenshot.dart';

await SScreenshot.captureAndDownload(
  _screenshotKey,
  fileName: 'screenshot.png',
  fileSaverCallback: kIsWeb ? (bytes, name) async {
    await FileSaver.instance.saveFile(
      name: name,
      bytes: Uint8List.fromList(bytes),
      mimeType: MimeType.png,
    );
  } : null,
  pathProviderCallback: !kIsWeb ? (bytes, name) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  } : null,
);
```

## Why These Changes?

1. **Unified API**: Single approach for all platforms instead of platform-specific code
2. **Better Control**: You decide how to handle downloads on each platform
3. **Cleaner Code**: No conditional imports or complicated platform detection
4. **Flexibility**: Easy to customize file locations without waiting for package updates
5. **Better UX**: Web and native have identical file download experience

## Need Help?

- See the [example app](example/) for complete working examples
- Check [IOS_MACOS_SETUP.md](IOS_MACOS_SETUP.md) for platform configuration
- Review [README.md](README.md) for API documentation
- Open an [issue on GitHub](https://github.com/SoundSliced/s_screenshot/issues)
