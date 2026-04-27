/// High-level helpers for web DOM operations.
///
/// Use [SUniversalHtml] instead of importing `html.dart` directly and calling
/// `html.window` / `html.document` everywhere. This avoids boilerplate,
/// centralises the platform guard, and provides a single API that works on
/// both JS-compiled and WASM-compiled Flutter web.
///
/// Implemented with `package:web` + `dart:js_interop` on web platforms and
/// safe no-op stubs on native platforms.
///
/// Example:
/// ```dart
/// // Before
/// html.document.onContextMenu.listen((e) => e.preventDefault());
/// final href = html.window.location.href;
///
/// // After
/// final cancel = SUniversalHtml.preventDefaultContextMenu();
/// final href = SUniversalHtml.windowLocationHref;
/// ```
library;

import 'dart:async';
import 'dart:convert' show utf8;

import 'src/s_universal_html_impl.dart' as impl;

/// A collection of safe, zero-boilerplate helpers for browser DOM operations.
///
/// All methods are no-ops (or return sensible empty defaults) when called on
/// non-web platforms. On web, they delegate to `package:web` / `dart:js_interop`
/// so they work on both JS-compiled and WASM-compiled targets.
///
/// Event-stream getters return `Stream<void>` — they fire when the event
/// occurs but carry no event object. If you need the raw event data on web,
/// use `package:web` directly.
abstract final class SUniversalHtml {
  // ─── Context Menu ────────────────────────────────────────────────────────

  /// Globally prevents the browser's native right-click context menu.
  ///
  /// Returns a cancel callback — call it to restore the default menu. Returns
  /// `null` on non-web.
  static void Function()? preventDefaultContextMenu() =>
      impl.preventDefaultContextMenu();

  /// Stream that fires (with `null`) whenever a `contextmenu` event occurs on
  /// the document. Returns an empty stream on non-web.
  static Stream<void> get onContextMenu => impl.onContextMenu();

  // ─── Window Location ─────────────────────────────────────────────────────

  /// The current page's full URL (`window.location.href`).
  ///
  /// Returns an empty string on non-web.
  static String get windowLocationHref => impl.windowLocationHref;

  /// Replaces the current browser history entry with [url]. No-op on non-web.
  static void windowLocationReplace(String url) =>
      impl.windowLocationReplace(url);

  /// Opens [url] in [target] (`window.open(url, target)`).
  ///
  /// [target] defaults to `'_blank'` (new tab). No-op on non-web.
  static void windowOpen(String url, [String target = '_blank']) =>
      impl.windowOpen(url, target);

  /// Opens [url] in a new tab. No-op on non-web.
  static void openInNewTab(String url) => windowOpen(url, '_blank');

  /// Navigates the current tab to [url]. No-op on non-web.
  static void navigateTo(String url) => windowOpen(url, '_self');

  // ─── URL Parameters ───────────────────────────────────────────────────────

  /// Returns the query parameters of the current URL as a map.
  ///
  /// Returns an empty map on non-web or when parsing fails.
  static Map<String, String> get urlParameters => impl.urlParameters;

  /// Returns a single query parameter value by [key], or `null` if absent.
  static String? urlParameter(String key) => urlParameters[key];

  // ─── Location Fragment / Hash ─────────────────────────────────────────────

  /// The current URL hash fragment, e.g. `'#section'` (with the leading `#`).
  ///
  /// Returns an empty string on non-web.
  static String get locationHash => impl.locationHash;

  /// Sets the URL hash fragment. No-op on non-web.
  static set locationHash(String value) => impl.setLocationHash(value);

  // ─── Browser History ─────────────────────────────────────────────────────

  /// Pushes a new entry onto the browser history stack. No-op on non-web.
  static void historyPushState(Object? state, String title, String url) =>
      impl.historyPushState(state, title, url);

  /// Replaces the current browser history entry. No-op on non-web.
  static void historyReplaceState(Object? state, String title, String url) =>
      impl.historyReplaceState(state, title, url);

  /// Stream that fires when the user navigates browser history (`popstate`).
  ///
  /// Returns an empty stream on non-web.
  static Stream<void> get onPopState => impl.onPopState();

  // ─── Document Title ───────────────────────────────────────────────────────

  /// The browser tab/window title. Returns an empty string on non-web.
  static String get documentTitle => impl.documentTitle;

  /// Sets the browser tab/window title. No-op on non-web.
  static set documentTitle(String value) => impl.setDocumentTitle(value);

  // ─── Window Size ─────────────────────────────────────────────────────────

  /// The viewport width in CSS pixels. Returns 0 on non-web.
  static int get windowWidth => impl.windowWidth;

  /// The viewport height in CSS pixels. Returns 0 on non-web.
  static int get windowHeight => impl.windowHeight;

  // ─── Window Events ────────────────────────────────────────────────────────

  /// Stream of window resize events. Returns an empty stream on non-web.
  static Stream<void> get onResize => impl.onResize();

  /// Stream of `beforeunload` events. Returns an empty stream on non-web.
  static Stream<void> get onBeforeUnload => impl.onBeforeUnload();

  /// Stream of window focus events. Returns an empty stream on non-web.
  static Stream<void> get onWindowFocus => impl.onWindowFocus();

  /// Stream of window blur events. Returns an empty stream on non-web.
  static Stream<void> get onWindowBlur => impl.onWindowBlur();

  /// Stream of `visibilitychange` events. Returns an empty stream on non-web.
  static Stream<void> get onVisibilityChange => impl.onVisibilityChange();

  /// Whether the page is currently visible. Returns `true` on non-web.
  static bool get isPageVisible => impl.isPageVisible;

  // ─── Keyboard Events ──────────────────────────────────────────────────────

  /// Stream of `keydown` events on the window. Returns an empty stream on non-web.
  static Stream<void> get onKeyDown => impl.onKeyDown();

  /// Stream of `keyup` events on the window. Returns an empty stream on non-web.
  static Stream<void> get onKeyUp => impl.onKeyUp();

  /// Stream of `keypress` events on the window. Returns an empty stream on non-web.
  static Stream<void> get onKeyPress => impl.onKeyPress();

  // ─── Mouse Events ─────────────────────────────────────────────────────────

  /// Stream of `mousemove` events on the window. Returns an empty stream on non-web.
  static Stream<void> get onMouseMove => impl.onMouseMove();

  /// Stream of `mouseup` events on the window. Returns an empty stream on non-web.
  static Stream<void> get onMouseUp => impl.onMouseUp();

  /// Stream of `mousedown` events on the window. Returns an empty stream on non-web.
  static Stream<void> get onMouseDown => impl.onMouseDown();

  /// Stream of `click` events on the window. Returns an empty stream on non-web.
  static Stream<void> get onWindowClick => impl.onWindowClick();

  // ─── Clipboard ────────────────────────────────────────────────────────────

  /// Copies [text] to the system clipboard. Falls back silently on non-web
  /// or when the permission is denied.
  static Future<void> copyToClipboard(String text) =>
      impl.copyToClipboard(text);

  /// Reads text from the system clipboard.
  ///
  /// Returns an empty string on non-web or when the permission is denied.
  static Future<String> readFromClipboard() => impl.readFromClipboard();

  // ─── Fullscreen ───────────────────────────────────────────────────────────

  /// Requests fullscreen for the document root element. No-op on non-web.
  static Future<void> requestFullscreen() => impl.requestFullscreen();

  /// Exits fullscreen mode. No-op on non-web.
  static Future<void> exitFullscreen() => impl.exitFullscreen();

  /// Whether the page is currently in fullscreen mode. Returns `false` on non-web.
  static bool get isFullscreen => impl.isFullscreen;

  /// Stream of fullscreen change events. Returns an empty stream on non-web.
  static Stream<void> get onFullscreenChange => impl.onFullscreenChange();

  // ─── Text Selection ───────────────────────────────────────────────────────

  /// Disables text selection across the page via CSS `user-select: none`.
  ///
  /// No-op on non-web.
  static void disableTextSelection() => impl.disableTextSelection();

  /// Re-enables text selection across the page. No-op on non-web.
  static void enableTextSelection() => impl.enableTextSelection();

  // ─── CSS Custom Properties ────────────────────────────────────────────────

  /// Sets a CSS custom property on the document root (`--name: value`).
  ///
  /// Example: `SUniversalHtml.setCssVariable('--primary-color', '#ff0000');`
  ///
  /// No-op on non-web.
  static void setCssVariable(String name, String value) =>
      impl.setCssVariable(name, value);

  /// Gets a CSS custom property value from the document root.
  ///
  /// Returns `null` on non-web or if the property is not set.
  static String? getCssVariable(String name) => impl.getCssVariable(name);

  // ─── Scroll ───────────────────────────────────────────────────────────────

  /// Scrolls the window to the given position. No-op on non-web.
  static void scrollTo(int x, int y) => impl.scrollTo(x, y);

  /// Scrolls the window by the given amounts. No-op on non-web.
  static void scrollBy(int x, int y) => impl.scrollBy(x, y);

  // ─── File Download ────────────────────────────────────────────────────────

  /// Triggers a browser file download with [filename] and text [content].
  ///
  /// No-op on non-web.
  static void downloadTextFile(
    String filename,
    String content, [
    String mimeType = 'text/plain',
  ]) {
    impl.downloadBytesFile(filename, utf8.encode(content), mimeType);
  }

  /// Triggers a browser file download with [filename] and raw [bytes].
  ///
  /// No-op on non-web.
  static void downloadBytesFile(
    String filename,
    List<int> bytes, [
    String mimeType = 'application/octet-stream',
  ]) =>
      impl.downloadBytesFile(filename, bytes, mimeType);

  // ─── Window Focus / Print ─────────────────────────────────────────────────

  /// Brings the browser window to the foreground. No-op on non-web.
  static void windowFocus() => impl.windowFocus();

  /// Removes focus from the browser window. No-op on non-web.
  static void windowBlur() => impl.windowBlur();

  /// Opens the browser's print dialog. No-op on non-web.
  static void printPage() => impl.printPage();

  // ─── Cookies ─────────────────────────────────────────────────────────────

  /// Returns the raw cookie string (`document.cookie`).
  ///
  /// Returns an empty string on non-web.
  static String get cookies => impl.cookies;

  /// Sets a cookie. No-op on non-web.
  static void setCookie(
    String name,
    String value, {
    DateTime? expires,
    String path = '/',
  }) {
    var cookie = '$name=${Uri.encodeComponent(value)}; path=$path';
    if (expires != null) {
      cookie += '; expires=${expires.toUtc().toIso8601String()}';
    }
    impl.setCookieStr(cookie);
  }

  /// Returns the value of the cookie with [name], or `null` if not found.
  static String? getCookie(String name) {
    final allCookies = impl.cookies;
    if (allCookies.isEmpty) return null;
    for (final part in allCookies.split(';')) {
      final trimmed = part.trim();
      if (trimmed.startsWith('$name=')) {
        return Uri.decodeComponent(trimmed.substring('$name='.length));
      }
    }
    return null;
  }
}
