// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:webview_flutter/webview_flutter.dart' as webview_flutter;
import '../../_debug_log.dart';
import '../webview_desktop/webview_desktop.dart' as webview_desktop;

/// A navigation decision for URL requests.
enum SWebViewNavigationDecision {
  navigate,
  prevent,
}

/// Signature for intercepting URL requests before navigation.
typedef SWebViewNavigationRequestCallback = SWebViewNavigationDecision Function(
  Uri uri,
);

/// Capability matrix for current platform support.
class SWebViewPlatformCapabilities {
  final bool canUseNativeWebView;
  final bool supportsJavaScript;
  final bool supportsDesktopWebview;
  final bool supportsNavigationDelegate;
  final bool supportsCookieJavaScript;

  const SWebViewPlatformCapabilities({
    required this.canUseNativeWebView,
    required this.supportsJavaScript,
    required this.supportsDesktopWebview,
    required this.supportsNavigationDelegate,
    required this.supportsCookieJavaScript,
  });
}

/// Cookie management data class
class WebViewCookie {
  final String name;
  final String value;
  final String? domain;
  final String? path;
  final DateTime? expires;
  final bool? httpOnly;
  final bool? secure;

  WebViewCookie({
    required this.name,
    required this.value,
    this.domain,
    this.path,
    this.expires,
    this.httpOnly,
    this.secure,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'value': value,
        'domain': domain,
        'path': path,
        'expires': expires?.millisecondsSinceEpoch,
        'httpOnly': httpOnly,
        'secure': secure,
      };
}

/// SSL Certificate pinning configuration
class SSLPinningConfig {
  final String hostname;
  final List<String> certificatePins; // Base64 encoded SHA256 hashes
  final bool allowBackupPin;

  SSLPinningConfig({
    required this.hostname,
    required this.certificatePins,
    this.allowBackupPin = true,
  });
}

/// A controller for managing WebView instances across different platforms.
///
/// This controller provides a unified API for WebView operations on both
/// mobile (iOS, Android, Web) and desktop (Windows, macOS, Linux) platforms.
///
/// Example usage:
/// ```dart
/// final controller = WebViewController();
/// await controller.init(
///   context: context,
///   setState: setState,
///   uri: Uri.parse('https://flutter.dev'),
/// );
/// ```
class WebViewController {
  /// The desktop webview controller instance.
  late final webview_desktop.Webview webview_desktop_controller;

  /// The mobile webview controller instance.
  late final webview_flutter.WebViewController webview_mobile_controller;

  /// Whether the controller has been initialized.
  bool is_init = false;

  /// Whether the current platform is desktop (Windows, macOS, Linux).
  final bool is_desktop = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows);

  /// Whether the current platform is mobile (iOS, Android, Web).
  final bool is_mobile = kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  /// Static flag to enable test mode.
  ///
  /// When set to true, the controller will bypass platform initialization
  /// and simulate successful initialization. This is useful for widget testing.
  static bool isTestMode = false;

  /// Custom HTTP headers to be sent with requests
  Map<String, String> customHeaders = {};

  /// SSL pinning configuration
  List<SSLPinningConfig> sslPinningConfigs = [];

  /// Page metadata notifiers
  final ValueNotifier<Uri?> currentUrlNotifier = ValueNotifier<Uri?>(null);
  final ValueNotifier<String?> pageTitleNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  /// Request timeout duration (default 30 seconds)
  Duration requestTimeout = const Duration(seconds: 30);

  /// Custom User-Agent string
  String? customUserAgent;

  /// Whether to follow redirects (default true)
  bool followRedirects = true;

  /// Proxy URL (optional)
  String? proxyUrl;

  /// Optional callback for progress updates.
  ValueChanged<int>? onProgress;

  /// Optional callback for page started events.
  ValueChanged<Uri>? onPageStarted;

  /// Optional callback for URL changes.
  ValueChanged<Uri>? onUrlChanged;

  /// Optional callback for page finished events.
  ValueChanged<Uri>? onPageFinished;

  /// Optional callback for JavaScript channel messages.
  ValueChanged<String>? onJavaScriptMessage;

  /// Optional callback to decide whether a navigation should proceed.
  SWebViewNavigationRequestCallback? onNavigationRequest;

  /// Current platform capabilities.
  SWebViewPlatformCapabilities get capabilities => SWebViewPlatformCapabilities(
        canUseNativeWebView: true,
        supportsJavaScript: true,
        supportsDesktopWebview: is_desktop,
        supportsNavigationDelegate: is_mobile,
        supportsCookieJavaScript: is_mobile,
      );

  /// Cookie jar for storing and managing cookies
  final Map<String, Map<String, String>> _cookieJar = {};

  Uri? _initialUri;
  bool _isInitializing = false;
  Completer<void>? _initializationCompleter;

  /// Creates a new WebViewController instance.
  WebViewController();

  /// Initializes the WebView controller with the provided configuration.
  ///
  /// [context] is the BuildContext for the widget.
  /// [setState] is a callback to update the parent widget's state.
  /// [uri] is the initial URL to load in the WebView.
  /// [customHeaders] optional custom HTTP headers to send with requests.
  /// [sslPinningConfigs] optional SSL certificate pinning configurations.
  /// [customUserAgent] optional custom User-Agent string for requests.
  /// [requestTimeout] timeout duration for requests (default 30 seconds).
  /// [followRedirects] whether to follow HTTP redirects (default true).
  /// [proxyUrl] optional proxy URL for network requests.
  Future<void> init({
    required BuildContext context,
    required void Function(void Function() fn) setState,
    required Uri uri,
    Map<String, String>? customHeaders,
    List<SSLPinningConfig>? sslPinningConfigs,
    String? customUserAgent,
    Duration? requestTimeout,
    bool? followRedirects,
    String? proxyUrl,
    ValueChanged<int>? onProgress,
    ValueChanged<Uri>? onPageStarted,
    ValueChanged<Uri>? onUrlChanged,
    ValueChanged<Uri>? onPageFinished,
    ValueChanged<String>? onJavaScriptMessage,
    SWebViewNavigationRequestCallback? onNavigationRequest,
  }) async {
    // Only apply custom headers if explicitly provided
    this.customHeaders = customHeaders ?? {};
    this.sslPinningConfigs = sslPinningConfigs ?? [];
    this.customUserAgent = customUserAgent;
    this.requestTimeout = requestTimeout ?? const Duration(seconds: 30);
    this.followRedirects = followRedirects ?? true;
    this.proxyUrl = proxyUrl;
    this.onProgress = onProgress;
    this.onPageStarted = onPageStarted;
    this.onUrlChanged = onUrlChanged;
    this.onPageFinished = onPageFinished;
    this.onJavaScriptMessage = onJavaScriptMessage;
    this.onNavigationRequest = onNavigationRequest;
    _initialUri = uri;

    if (_isInitializing) {
      await _initializationCompleter?.future;
      if (is_init) {
        await loadUri(uri);
      }
      return;
    }

    if (is_init) {
      await loadUri(uri);
      return;
    }

    _isInitializing = true;
    _initializationCompleter = Completer<void>();

    try {
      if (isTestMode) {
        is_init = true;
        currentUrlNotifier.value = uri;
        // In test mode, immediately set loaded state without timer
        isLoadingNotifier.value = false;
        setState(() {});
        return;
      }

      if (is_mobile) {
        final webview_flutter.PlatformWebViewControllerCreationParams params =
            const webview_flutter.PlatformWebViewControllerCreationParams();

        webview_mobile_controller =
            webview_flutter.WebViewController.fromPlatformCreationParams(
                params);
        setState(() {});
        if (!kIsWeb) {
          webview_mobile_controller
              .setJavaScriptMode(webview_flutter.JavaScriptMode.unrestricted);

          // Set custom User-Agent if provided
          if (customUserAgent != null) {
            webview_mobile_controller.setUserAgent(customUserAgent);
          }

          webview_mobile_controller.setNavigationDelegate(
            webview_flutter.NavigationDelegate(
              onProgress: (int progress) {
                isLoadingNotifier.value = progress < 100;
                this.onProgress?.call(progress);
                SWebViewDebug.log('WebView is loading (progress : $progress%)');
              },
              onPageStarted: (String url) {
                isLoadingNotifier.value = true;
                final uri = Uri.tryParse(url);
                if (uri != null) {
                  currentUrlNotifier.value = uri;
                  onPageStarted?.call(uri);
                  this.onUrlChanged?.call(uri);
                }
                SWebViewDebug.log('Page started loading: $url');
              },
              onPageFinished: (String url) {
                isLoadingNotifier.value = false;
                final uri = Uri.tryParse(url);
                if (uri != null) {
                  currentUrlNotifier.value = uri;
                  onPageFinished?.call(uri);
                  this.onUrlChanged?.call(uri);
                }
                _updatePageTitle();
                SWebViewDebug.log('Page finished loading: $url');
              },
              onWebResourceError: (webview_flutter.WebResourceError error) {
                isLoadingNotifier.value = false;
                SWebViewDebug.log('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
              },
              onNavigationRequest: (webview_flutter.NavigationRequest request) {
                final requestUri = Uri.tryParse(request.url);
                if (requestUri == null) {
                  return webview_flutter.NavigationDecision.navigate;
                }

                if (!this.followRedirects && _initialUri != null) {
                  final originalHost = _initialUri!.host;
                  if (originalHost.isNotEmpty &&
                      requestUri.host != originalHost) {
                    SWebViewDebug.log(
                        'Navigation prevented by followRedirects=false: ${request.url}');
                    return webview_flutter.NavigationDecision.prevent;
                  }
                }

                final decision = onNavigationRequest?.call(requestUri);
                if (decision == SWebViewNavigationDecision.prevent) {
                  SWebViewDebug.log(
                      'Navigation prevented by callback: ${request.url}');
                  return webview_flutter.NavigationDecision.prevent;
                }

                SWebViewDebug.log('allowing navigation to ${request.url}');
                return webview_flutter.NavigationDecision.navigate;
              },
            ),
          );
          webview_mobile_controller.addJavaScriptChannel(
            'Toaster',
            onMessageReceived: (webview_flutter.JavaScriptMessage message) {
              onJavaScriptMessage?.call(message.message);
              final messenger = ScaffoldMessenger.maybeOf(context);
              if (messenger == null) return;
              messenger.hideCurrentSnackBar();
              messenger.showSnackBar(SnackBar(content: Text(message.message)));
            },
          );
        }
        await _loadRequest(uri);

        // #docregion platform_features
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          try {
            (webview_mobile_controller.platform as dynamic)
                .setMediaPlaybackRequiresUserGesture(false);
          } catch (e) {
            SWebViewDebug.log(
                'Error setting media playback requires user gesture: $e');
          }
        }
        setState(() {});
        is_init = true;
      } else if (is_desktop) {
        final bool isWebviewAvailable =
            await webview_desktop.WebviewWindow.isWebviewAvailable();
        if (isWebviewAvailable) {
          final webview_desktop.Webview localWebviewController =
              await webview_desktop.WebviewWindow.create(
            configuration: webview_desktop.CreateConfiguration(
              titleBarTopPadding:
                  defaultTargetPlatform == TargetPlatform.macOS ? 20 : 0,
            ),
          );
          webview_desktop_controller = localWebviewController;
          webview_desktop_controller.setBrightness(Brightness.dark);
          webview_desktop_controller.launch(resolveUriForLoad(uri).toString());
          currentUrlNotifier.value = uri;
          setState(() {});
          is_init = true;
        } else {
          throw StateError(
            'Desktop WebView runtime is not available on this machine.',
          );
        }
      } else {
        throw StateError('Unsupported platform for WebViewController.');
      }
    } finally {
      _isInitializing = false;
      if (!(_initializationCompleter?.isCompleted ?? true)) {
        _initializationCompleter?.complete();
      }
      _initializationCompleter = null;
    }
  }

  /// Updates page title from JavaScript evaluation
  Future<void> _updatePageTitle() async {
    if (is_mobile && is_init) {
      try {
        final dynamic raw = await webview_mobile_controller
            .runJavaScriptReturningResult('document.title');
        final String? title = _normalizeJsString(raw);
        if (title != null && title.isNotEmpty) {
          pageTitleNotifier.value = title;
        }
      } catch (e) {
        SWebViewDebug.log('Error getting page title: $e');
      }
    }
  }

  /// Disposes platform resources associated with this controller.
  void dispose() {
    if (is_init == false) {
      return;
    }
    if (is_desktop) {
      try {
        webview_desktop_controller.close();
      } catch (e) {
        SWebViewDebug.log('Error closing desktop webview: $e');
      }
    }
    currentUrlNotifier.dispose();
    pageTitleNotifier.dispose();
    isLoadingNotifier.dispose();
    _cookieJar.clear();
    is_init = false;
  }

  /// Stores a cookie in memory for caller-managed usage.
  void setMemoryCookie(String name, String value, {String? domain}) {
    final host = domain ?? currentUrlNotifier.value?.host ?? 'default';
    if (!_cookieJar.containsKey(host)) {
      _cookieJar[host] = {};
    }
    _cookieJar[host]![name] = value;
    SWebViewDebug.log('Cookie set: $name=$value for domain $host');
  }

  /// Gets stored in-memory cookies for a domain.
  Map<String, String> getMemoryCookies({String? domain}) {
    final host = domain ?? currentUrlNotifier.value?.host ?? 'default';
    return _cookieJar[host] ?? {};
  }

  /// Clears all stored in-memory cookies.
  void clearMemoryCookies() {
    _cookieJar.clear();
    SWebViewDebug.log('All cookies cleared');
  }

  /// Resolves a URL to load, applying proxy URL if configured.
  Uri resolveUriForLoad(Uri uri) {
    if (proxyUrl == null || proxyUrl!.trim().isEmpty) {
      return uri;
    }
    if (!(uri.scheme == 'http' || uri.scheme == 'https')) {
      return uri;
    }
    return Uri.parse('${proxyUrl!}${Uri.encodeComponent(uri.toString())}');
  }

  /// Loads a URL in the active webview honoring timeout, headers and proxy settings.
  Future<void> loadUri(Uri uri) async {
    if (!is_init) {
      return;
    }
    final target = resolveUriForLoad(uri);
    if (is_mobile) {
      await _loadRequest(target);
      return;
    }
    if (is_desktop) {
      webview_desktop_controller.launch(target.toString());
      currentUrlNotifier.value = target;
    }
  }

  Future<void> _loadRequest(Uri uri) async {
    if (customHeaders.isNotEmpty) {
      await webview_mobile_controller
          .loadRequest(uri, headers: customHeaders)
          .timeout(requestTimeout);
    } else {
      await webview_mobile_controller.loadRequest(uri).timeout(requestTimeout);
    }
  }

  String? _normalizeJsString(dynamic raw) {
    if (raw == null) {
      return null;
    }
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.length >= 2 &&
          ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
              (trimmed.startsWith("'") && trimmed.endsWith("'")))) {
        return trimmed.substring(1, trimmed.length - 1);
      }
      return trimmed;
    }
    return raw.toString();
  }
}
