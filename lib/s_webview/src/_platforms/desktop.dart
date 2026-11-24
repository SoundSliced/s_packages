/// Desktop platform declarations (Windows, macOS, Linux).
///
/// Exported only where `dart:io` exists (see `_platforms.dart`), because
/// `desktop_webview_window` imports `dart:isolate`, which web builds
/// (dart2js and dart2wasm) cannot include.
library;

export 'windows.dart';
export 'macos.dart';
export 'linux.dart';
