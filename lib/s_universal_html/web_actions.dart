import 'src/web_actions_impl_browser.dart'
    if (dart.library.io) 'src/web_actions_impl_others.dart' as impl;

/// Cross-platform helpers for common web window/location actions.
///
/// On web: delegates to `package:web` (`web.window.location.*`).
/// On non-web platforms: all methods are no-ops and [currentHref] returns `''`.
///
/// Usage:
/// ```dart
/// import 'package:s_packages/s_universal_html/web_actions.dart';
///
/// SUniversalHtml.reloadWindow();
/// SUniversalHtml.navigateTo('https://example.com');
/// SUniversalHtml.replaceLocation('https://example.com');
/// print(SUniversalHtml.currentHref);
/// ```
class SUniversalHtml {
  SUniversalHtml._();

  /// Reloads the current browser window. No-op on non-web platforms.
  static void reloadWindow() => impl.reloadWindow();

  /// Navigates to [url] via `location.assign()`. No-op on non-web platforms.
  static void navigateTo(String url) => impl.navigateTo(url);

  /// Replaces the current history entry with [url] via `location.replace()`.
  /// No-op on non-web platforms.
  static void replaceLocation(String url) => impl.replaceLocation(url);

  /// Returns the current `location.href`. Returns `''` on non-web platforms.
  static String get currentHref => impl.currentHref;
}
