import 'dart:async';

import 'webview_controller_web.dart';

export 'webview_controller_web.dart';
export 'webview_controller_extensions.dart';

/// Extension methods for [WebViewController] providing navigation control.
///
/// This extension adds synchronous and asynchronous navigation methods
/// for going back, forward, and loading new URLs.
extension WebViewControllerExtension on WebViewController {
  /// Navigates back in the WebView's history (synchronous version).
  ///
  /// This method will do nothing if the controller is not initialized.
  /// On mobile platforms, it delegates to the underlying mobile controller.
  /// On desktop platforms, it delegates to the desktop webview controller.
  void goBackSync() {
    if (is_init == false) {
      return;
    }
    if (is_mobile) {
      webview_mobile_controller.goBack();
    }
    if (is_desktop) {
      unawaited(webview_desktop_controller.back());
    }
  }

  /// Navigates forward in the WebView's history (synchronous version).
  ///
  /// This method will do nothing if the controller is not initialized.
  /// On mobile platforms, it delegates to the underlying mobile controller.
  /// On desktop platforms, it delegates to the desktop webview controller.
  void goForwardSync() {
    if (is_init == false) {
      return;
    }
    if (is_mobile) {
      webview_mobile_controller.goForward();
    }
    if (is_desktop) {
      unawaited(webview_desktop_controller.forward());
    }
  }

  /// Loads the specified [uri] in the WebView (synchronous version).
  ///
  /// This method will do nothing if the controller is not initialized.
  /// On mobile platforms, it delegates to the underlying mobile controller.
  /// On desktop platforms, it delegates to the desktop webview controller.
  void goSync({
    required Uri uri,
  }) {
    if (is_init == false) {
      return;
    }
    unawaited(loadUri(uri));
  }

  /// Navigates back in the WebView's history (asynchronous version).
  ///
  /// Returns a [Future] that completes when the navigation is finished.
  /// This method will do nothing if the controller is not initialized.
  /// On mobile platforms, it delegates to the underlying mobile controller.
  /// On desktop platforms, it delegates to the desktop webview controller.
  Future<void> goBack() async {
    if (is_init == false) {
      return;
    }
    if (is_mobile) {
      await webview_mobile_controller.goBack();
    }
    if (is_desktop) {
      await webview_desktop_controller.back();
    }
  }

  /// Navigates forward in the WebView's history (asynchronous version).
  ///
  /// Returns a [Future] that completes when the navigation is finished.
  /// This method will do nothing if the controller is not initialized.
  /// On mobile platforms, it delegates to the underlying mobile controller.
  /// On desktop platforms, it delegates to the desktop webview controller.
  Future<void> goForward() async {
    if (is_init == false) {
      return;
    }
    if (is_mobile) {
      await webview_mobile_controller.goForward();
    }
    if (is_desktop) {
      await webview_desktop_controller.forward();
    }
  }

  /// Loads the specified [uri] in the WebView (asynchronous version).
  ///
  /// Returns a [Future] that completes when the navigation is finished.
  /// This method will do nothing if the controller is not initialized.
  /// On mobile platforms, it delegates to the underlying mobile controller.
  /// On desktop platforms, it delegates to the desktop webview controller.
  Future<void> go({
    required Uri uri,
  }) async {
    if (is_init == false) {
      return;
    }
    await loadUri(uri);
  }
}
