// ignore_for_file: unused_import, unused_element

/// Platform support detection for s_webview
/// This file imports all platform-specific implementations to ensure
/// pub.dev's static analyzer detects support for all platforms.
library;

// Import all platform implementations
// Web platform is conditionally exported to avoid loading dart:js_interop in tests
export '_platforms/ios.dart';
export '_platforms/android.dart';
export '_platforms/web_stub.dart'
    if (dart.library.js_interop) '_platforms/web.dart'
    if (dart.library.html) '_platforms/web.dart';
// Desktop implementations only where dart:io exists: desktop_webview_window
// imports dart:isolate, which web builds (dart2js, dart2wasm) cannot include.
export '_platforms/desktop.dart'
    if (dart.library.js_interop) '_platforms/desktop_stub.dart';

/// This module declares explicit platform support for:
/// - iOS (via webview_flutter and WKWebView)
/// - Android (via webview_flutter and native Android WebView)
/// - Web (via webview_flutter_web and iframes)
/// - Windows (via desktop_webview_window and WebView2)
/// - macOS (via desktop_webview_window and WKWebView)
/// - Linux (via desktop_webview_window and WebKitGTK)
void _declarePlatformSupport() {
  // This function is not called, but helps analysis tools
}
