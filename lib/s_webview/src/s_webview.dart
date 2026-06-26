// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:s_packages/s_packages.dart';
import 'package:s_packages/s_packages_extra1.dart';

import '_proxy_html_utils.dart';
import '_debug_log.dart';
import '_s_webview/webview_controller/webview_controller.dart';
import '_s_webview/widget/widget.dart';
import '_s_webview/web_utils/web_utils.dart' as web_utils;

// Internal _s_webview implementation provides optimal performance
// across all platforms (iOS, Android, Web, Windows, macOS, Linux)
// TOOLBAR FIXED: showToolbar parameter now correctly controls toolbar visibility
// When showToolbar=false, the toolbar is never shown (even if page fails to load)
// When showToolbar=true, the toolbar with retry and open-in-new-tab buttons is displayed

class SWebViewConfig {
  /// Automatically detect frame restrictions and apply proxy only when needed.
  final bool autoDetectFrameRestrictions;

  /// List of CORS proxies used as fallback on web platform.
  ///
  /// ⚠️ Avoid using public proxies for sensitive or authenticated content.
  final List<String> corsProxyUrls;

  /// Domains known to block iframe embedding.
  final Set<String> knownRestrictedDomains;

  /// Restriction cache entry TTL.
  final Duration proxyCacheTtl;

  /// When true, cache proxy decisions by host instead of full URL.
  final bool cacheProxyByHost;

  /// Optional custom HTTP headers to be sent with requests routed through a CORS proxy.
  final Map<String, String>? proxyHeaders;

  const SWebViewConfig({
    this.autoDetectFrameRestrictions = true,
    this.corsProxyUrls = const [
      'https://api.codetabs.com/v1/proxy?quest=',
      'https://corsproxy.io/?url=',
      'https://api.allorigins.win/raw?url=',
    ],
    this.knownRestrictedDomains = const {
      'google.com',
      'github.com',
      'windy.com',
      'facebook.com',
      'twitter.com',
      'instagram.com',
      'linkedin.com',
      'pinterest.com',
      'reddit.com',
      'amazon.com',
      'ebay.com',
    },
    this.proxyCacheTtl = const Duration(days: 7),
    this.cacheProxyByHost = true,
    this.proxyHeaders,
  });
}

class _RestrictionCacheEntry {
  final bool needsProxy;
  final int updatedAtMillis;

  const _RestrictionCacheEntry({
    required this.needsProxy,
    required this.updatedAtMillis,
  });

  Map<String, dynamic> toJson() => {
        'needsProxy': needsProxy,
        'updatedAtMillis': updatedAtMillis,
      };

  factory _RestrictionCacheEntry.fromJson(Map<String, dynamic> json) {
    return _RestrictionCacheEntry(
      needsProxy: json['needsProxy'] == true,
      updatedAtMillis: (json['updatedAtMillis'] as num?)?.toInt() ?? 0,
    );
  }
}

class _ProxyFetchResult {
  final String html;
  final String proxyBase;

  const _ProxyFetchResult({
    required this.html,
    required this.proxyBase,
  });
}

class _ProxyHealthSnapshot {
  final int errorCount;
  final int swallowedCount;
  final int unhandledRejectionCount;
  final int pluginFailureCount;
  final List<String> recentMessages;

  const _ProxyHealthSnapshot({
    required this.errorCount,
    required this.swallowedCount,
    required this.unhandledRejectionCount,
    required this.pluginFailureCount,
    required this.recentMessages,
  });

  bool get hasSevereRuntimeIssues {
    if (pluginFailureCount > 0) return true;
    if (errorCount >= 6) return true;
    if (swallowedCount >= 6) return true;
    if (unhandledRejectionCount >= 3) return true;

    return recentMessages.any(
      (m) =>
          m.contains('unlegal embed') ||
          m.contains('idbfactory') ||
          m.contains('plugin'),
    );
  }

  static const empty = _ProxyHealthSnapshot(
    errorCount: 0,
    swallowedCount: 0,
    unhandledRejectionCount: 0,
    pluginFailureCount: 0,
    recentMessages: <String>[],
  );

  factory _ProxyHealthSnapshot.fromJson(Map<String, dynamic> json) {
    final messagesRaw = json['messages'];
    final messages = messagesRaw is List
        ? messagesRaw.map((e) => e.toString().toLowerCase()).toList()
        : const <String>[];

    int readInt(String key) {
      final value = json[key];
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return _ProxyHealthSnapshot(
      errorCount: readInt('errors'),
      swallowedCount: readInt('swallowedErrors'),
      unhandledRejectionCount: readInt('unhandledRejections'),
      pluginFailureCount: readInt('pluginFailures'),
      recentMessages: messages,
    );
  }
}

class SWebView extends StatefulWidget {
  /// The URL to load in the WebView
  final String url;

  /// Optional externally managed controller.
  ///
  /// When provided, [SWebView] will not dispose it.
  final WebViewController? controller;

  /// Optional advanced typed config.
  final SWebViewConfig config;

  /// Callback for load errors.
  ///
  /// Called only when a load fails.
  final Function(String? error)? onError;

  /// Callback when page load succeeds.
  final VoidCallback? onLoaded;

  /// Callback when iframe is blocked (web platform only)
  final VoidCallback? onIframeBlocked;

  /// Callback fired when a proxy-fetched page is detected as incompatible
  /// with `data:` URL origin (e.g. Cloudflare anti-bot challenge pages).
  ///
  /// Use this to trigger a fallback action such as opening the URL in a
  /// new browser tab. When this callback is provided it is called instead
  /// of [onIframeBlocked] for this specific case.
  ///
  /// Example:
  /// ```dart
  /// SWebView(
  ///   url: 'https://flightradar24.com',
  ///   onProxyIncompatibleDocument: () {
  ///     SWebView.openInNewTab('https://flightradar24.com',
  ///         addToProxyCacheForNextTime: false);
  ///   },
  /// )
  /// ```
  final VoidCallback? onProxyIncompatibleDocument;

  /// Show the toolbar with retry with proxy and open-in-new-tab buttons
  /// Default: true when on Web platform
  final bool showToolbar;

  /// Automatically detect X-Frame-Options and CSP restrictions (default: true on web)
  /// When true, SWebView will check headers and apply CORS proxy only if needed
  /// This eliminates the need to manually pass useCorsProxy parameter
  final bool autoDetectFrameRestrictions;

  /// List of CORS proxies to try in order (with fallback)
  /// Default is empty: falls back to [config.corsProxyUrls].
  final List<String> corsProxyUrls;

  /// When true, SWebView debug logs are shown in debug mode.
  /// Default: false
  final bool showDebugLogs;

  /// When true, the embedded WebView ignores all pointer events.
  /// Default: false
  final bool ignorePointerEvents;

  /// When true, renders the WebView in dark mode.
  /// On Web, this applies a CSS invert/hue-rotate filter to the iframe container.
  /// On Desktop platforms, this sets native webview brightness to dark.
  final bool darkMode;

  /// Optional custom builder for displaying a fallback UI when page loading fails
  /// (e.g. because of iframe embed restriction or proxy incompatibility).
  final Widget Function(
    BuildContext context,
    VoidCallback onRetryWithProxy,
    VoidCallback onOpenInNewTab,
  )? fallbackBuilder;

  /// Callback with page loading progress (0..100).
  final ValueChanged<int>? onProgress;

  /// Callback when a page starts loading.
  final ValueChanged<Uri>? onPageStarted;

  /// Callback when URL changes.
  final ValueChanged<Uri>? onUrlChanged;

  /// Callback when a page finishes loading.
  final ValueChanged<Uri>? onPageFinished;

  /// Callback to decide whether navigation is allowed.
  final SWebViewNavigationRequestCallback? onNavigationRequest;

  /// Callback for JavaScript channel messages.
  final ValueChanged<String>? onJavaScriptMessage;

  const SWebView({
    super.key,
    this.url = "https://flutter.dev",
    this.controller,
    this.config = const SWebViewConfig(),
    this.onError,
    this.onLoaded,
    this.onIframeBlocked,
    this.onProxyIncompatibleDocument,
    this.autoDetectFrameRestrictions = /* kIsWeb ? true : false */ true,
    this.corsProxyUrls = const [],
    this.showToolbar = kIsWeb,
    this.showDebugLogs = false,
    this.ignorePointerEvents = false,
    this.darkMode = false,
    this.fallbackBuilder,
    this.onProgress,
    this.onPageStarted,
    this.onUrlChanged,
    this.onPageFinished,
    this.onNavigationRequest,
    this.onJavaScriptMessage,
  });

  @override
  State<SWebView> createState() => _SWebViewState();

  /// A convenience widget that wraps any child with PointerInterceptor
  ///
  /// Use this to wrap buttons or other interactive widgets that are stacked
  /// on top of SWebView in a Stack. This ensures they receive pointer events
  /// on Flutter Web where WebView iframes capture all events.
  ///
  /// **Example:**
  /// ```dart
  /// Stack(
  ///   children: [
  ///     SWebView(url: 'https://flutter.dev'),
  ///     Positioned(
  ///       top: 100,
  ///       right: 100,
  ///       child: SWebView.tapTarget(
  ///         child: ElevatedButton(
  ///           onPressed: () => print('Tapped!'),
  ///           child: Text('Tap me'),
  ///         ),
  ///       ),
  ///     ),
  ///   ],
  /// )
  /// ```
  static Widget tapTarget({
    required Widget child,
    Key? key,
  }) {
    if (kIsWeb) {
      return PointerInterceptor(
        key: key,
        child: child,
      );
    }
    return child;
  }

  /// Static method to load a URL via CORS proxy
  /// Can be called from custom buttons stacked over the widget
  /// This will mark the URL for proxy usage and trigger a reload
  ///
  /// **Example usage:**
  /// ```dart
  /// Stack(children: [
  ///   SWebView(url: 'https://example.com'),
  ///   Positioned(
  ///     top: 10,
  ///     right: 10,
  ///     child: PointerInterceptor(
  ///       child: ElevatedButton(
  ///         onPressed: () => SWebView.retryWithProxy('https://example.com'),
  ///         child: Text('Retry with Proxy'),
  ///       ),
  ///     ),
  ///   ),
  /// ])
  /// ```
  static Future<void> retryWithProxy(
    String url, {
    bool showDebugLogs = false,
  }) async {
    final key = _SWebViewState.cacheKeyFromUrl(url, cacheByHost: true);
    _SWebViewState._restrictionCache[key] = _RestrictionCacheEntry(
      needsProxy: true,
      updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    await _SWebViewState._saveCache(showDebugLogs: showDebugLogs);
  }

  /// Static method to open a URL in a new browser tab
  /// Can be called from custom buttons stacked over the widget
  /// Web platform only - no-op on native platforms
  ///
  /// **Parameters:**
  /// - `url`: The URL to open in a new tab
  /// - `addToProxyCacheForNextTime`: If true, the URL will be marked as requiring
  ///   a proxy for future loads. Default is true (maintains existing behavior).
  ///
  /// **Example usage:**
  /// ```dart
  /// Stack(children: [
  ///   SWebView(url: 'https://example.com'),
  ///   Positioned(
  ///     top: 10,
  ///     right: 10,
  ///     child: PointerInterceptor(
  ///       child: ElevatedButton(
  ///         // With proxy cache update (default)
  ///         onPressed: () => SWebView.openInNewTab('https://example.com'),
  ///         child: Text('Open in New Tab'),
  ///       ),
  ///     ),
  ///   ),
  /// ])
  /// ```
  ///
  /// **Example without proxy caching:**
  /// ```dart
  /// ElevatedButton(
  ///   onPressed: () => SWebView.openInNewTab(
  ///     'https://example.com',
  ///     addToProxyCacheForNextTime: false,
  ///   ),
  ///   child: Text('Open'),
  /// )
  /// ```
  static Future<void> openInNewTab(
    String url, {
    bool addToProxyCacheForNextTime = true,
    bool showDebugLogs = false,
  }) async {
    // Mark URL as needing proxy for future loads (default behavior)
    if (addToProxyCacheForNextTime) {
      final key = _SWebViewState.cacheKeyFromUrl(url, cacheByHost: true);
      _SWebViewState._restrictionCache[key] = _RestrictionCacheEntry(
        needsProxy: true,
        updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
      );
    }
    await _SWebViewState._saveCache(showDebugLogs: showDebugLogs);

    // Open in new tab (web platform)
    if (kIsWeb) {
      web_utils.openInNewTab(url);
    }
  }

  /// Static method to remove a URL from the proxy cache
  /// Use this to remove a URL that was previously marked as requiring a proxy
  /// The next load attempt will try a direct connection without the proxy
  ///
  /// **Example usage:**
  /// ```dart
  /// Stack(children: [
  ///   SWebView(url: 'https://example.com'),
  ///   Positioned(
  ///     top: 10,
  ///     right: 10,
  ///     child: PointerInterceptor(
  ///       child: ElevatedButton(
  ///         onPressed: () => SWebView.removeFromCache('https://example.com'),
  ///         child: Text('Clear Proxy Cache'),
  ///       ),
  ///     ),
  ///   ),
  /// ])
  /// ```
  static Future<void> removeFromCache(
    String url, {
    bool showDebugLogs = false,
  }) async {
    final key = _SWebViewState.cacheKeyFromUrl(url, cacheByHost: true);
    _SWebViewState._restrictionCache.remove(key);
    await _SWebViewState._saveCache(showDebugLogs: showDebugLogs);
  }

  /// Get a read-only copy of the current proxy cache
  /// Returns a map of URLs to whether they require a proxy
  /// Key: URL string, Value: bool (true = needs proxy)
  static Map<String, bool> getProxyCache() {
    return _SWebViewState._restrictionCache.map(
      (key, value) => MapEntry(key, value.needsProxy),
    );
  }

  /// Check if a specific URL is in the proxy cache and requires a proxy
  /// Returns true if the URL is cached and requires a proxy, false otherwise
  static bool isUrlInProxyCache(String url) {
    final key = _SWebViewState.cacheKeyFromUrl(url, cacheByHost: true);
    return _SWebViewState._restrictionCache[key]?.needsProxy ?? false;
  }
}

class _SWebViewState extends State<SWebView> {
  WebViewController? webViewController;
  bool _ownsController = false;
  bool? isLoaded;
  bool _isUsingProxy = false;
  int _proxyHealthProbeGeneration = 0;
  bool _proxyAdaptiveRetriedCurrentLoad = false;
  bool _proxyHealthTelemetryUnsupported = false;

  void _log(String message) {
    // Intentionally no-op: verbose internal debug logging has been removed.
  }

  @override
  void initState() {
    super.initState();
    SWebViewDebug.enabled = widget.showDebugLogs;
    _initializeWithCache();
  }

  /// Initialize with cached data loaded
  Future<void> _initializeWithCache() async {
    // Skip cache loading in test mode to avoid SharedPreferences dependency
    if (!WebViewController.isTestMode) {
      await _loadCache(showDebugLogs: widget.showDebugLogs);
    }
    await initialisation();
  }

  /// Cache for frame restriction detection
  /// Maps URL/host keys to whether they require a proxy.
  static final Map<String, _RestrictionCacheEntry> _restrictionCache = {};
  static const String _cacheKey = 'swebview_restriction_cache';

  static String cacheKeyFromUrl(String rawUrl, {required bool cacheByHost}) {
    if (!cacheByHost) {
      return rawUrl;
    }
    final uri = Uri.tryParse(rawUrl);
    final host = uri?.host.trim().toLowerCase();
    if (host == null || host.isEmpty) {
      return rawUrl;
    }
    return host;
  }

  bool get _autoDetectFrameRestrictions =>
      widget.config.autoDetectFrameRestrictions &&
      widget.autoDetectFrameRestrictions;

  List<String> get _corsProxyUrls => widget.corsProxyUrls.isNotEmpty
      ? widget.corsProxyUrls
      : widget.config.corsProxyUrls;

  bool get _cacheByHost => widget.config.cacheProxyByHost;

  Duration get _proxyCacheTtl => widget.config.proxyCacheTtl;

  Set<String> get _knownRestrictedDomains =>
      widget.config.knownRestrictedDomains;

  String _cacheKeyFor(String url) =>
      cacheKeyFromUrl(url, cacheByHost: _cacheByHost);

  bool _isEntryFresh(_RestrictionCacheEntry entry) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final age = now - entry.updatedAtMillis;
    return age <= _proxyCacheTtl.inMilliseconds;
  }

  Future<void> _cacheRestriction(String key, bool needsProxy) async {
    _restrictionCache[key] = _RestrictionCacheEntry(
      needsProxy: needsProxy,
      updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    await _saveCache(showDebugLogs: widget.showDebugLogs);
  }

  /// Load restriction cache from persistent storage
  static Future<void> _loadCache({
    bool showDebugLogs = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString(_cacheKey);

      if (cacheJson != null) {
        final Map<String, dynamic> decoded = json.decode(cacheJson);
        _restrictionCache.clear();
        decoded.forEach((key, value) {
          if (value is bool) {
            _restrictionCache[key] = _RestrictionCacheEntry(
              needsProxy: value,
              updatedAtMillis: 0,
            );
          } else if (value is Map<String, dynamic>) {
            _restrictionCache[key] = _RestrictionCacheEntry.fromJson(value);
          } else if (value is Map) {
            _restrictionCache[key] = _RestrictionCacheEntry.fromJson(
              Map<String, dynamic>.from(value),
            );
          }
        });
      }
    } catch (e) {
      // no-op
    }
  }

  /// Save restriction cache to persistent storage
  static Future<void> _saveCache({
    bool showDebugLogs = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = json.encode(
        _restrictionCache.map((key, value) => MapEntry(key, value.toJson())),
      );
      await prefs.setString(_cacheKey, cacheJson);
    } catch (e) {
      // no-op
    }
  }

  /// Detects frame restrictions by testing with each CORS proxy
  /// Uses known domain rules and response headers/content hints.
  /// Returns true if we should use proxy, false for direct load
  Future<bool> _checkHeadersForRestrictions(String url) async {
    if (!kIsWeb) return false; // Native platforms don't need proxy

    final cacheKey = _cacheKeyFor(url);

    _log('━━━ [SWebView] _checkHeadersForRestrictions ━━━');
    _log('  url      : $url');
    _log('  cacheKey : $cacheKey');

    // Check configured known restricted domains first.
    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
    final isKnownRestricted =
        _knownRestrictedDomains.any((domain) => host.endsWith(domain));
    if (isKnownRestricted) {
      _log('  → Known restricted domain: $host  [needs proxy=true]');
      await _cacheRestriction(cacheKey, true);
      return true;
    }

    // Check cache first
    final cachedEntry = _restrictionCache[cacheKey];
    if (cachedEntry != null && _isEntryFresh(cachedEntry)) {
      _log(
          '  → Cache hit: needsProxy=${cachedEntry.needsProxy}  (age ${DateTime.now().millisecondsSinceEpoch - cachedEntry.updatedAtMillis}ms)');
      return cachedEntry.needsProxy;
    }
    if (cachedEntry != null && !_isEntryFresh(cachedEntry)) {
      _log('  → Cache entry stale – removing');
      _restrictionCache.remove(cacheKey);
    }

    try {
      _log(
          '  → No cache hit – probing via proxy (${_corsProxyUrls.isNotEmpty ? _corsProxyUrls[0] : 'none'})');

      // Test via proxy and inspect headers for frame restrictions.
      if (_corsProxyUrls.isNotEmpty) {
        try {
          final proxyUrl = SWebViewProxyHtmlUtils.buildProxiedUrl(
            _corsProxyUrls[0],
            url,
          );

          _log('  → Probe request: $proxyUrl');
          final sw = Stopwatch()..start();
          final response = await http
              .get(
                Uri.parse(proxyUrl),
                headers: widget.config.proxyHeaders,
              )
              .timeout(const Duration(seconds: 3));
          sw.stop();
          _log(
              '  → Probe response: HTTP ${response.statusCode}  (${sw.elapsedMilliseconds}ms, ${response.bodyBytes.length} bytes)');

          if (response.statusCode == 200) {
            final xFrameOptions =
                response.headers['x-frame-options']?.toLowerCase() ?? '';
            final csp =
                response.headers['content-security-policy']?.toLowerCase() ??
                    '';
            final body = response.body.toLowerCase();

            final hasRestrictedXFrame = xFrameOptions.contains('deny') ||
                xFrameOptions.contains('sameorigin');
            final hasRestrictedCsp = csp.contains('frame-ancestors') &&
                (csp.contains("'none'") ||
                    csp.contains("'self'") ||
                    csp.contains('none'));
            final bodySignalsFrameRestriction =
                body.contains('x-frame-options') ||
                    body.contains('refused to connect') ||
                    body.contains('frame-ancestors');

            _log(
                '  → X-Frame-Options : "$xFrameOptions"  restricted=$hasRestrictedXFrame');
            _log(
                '  → CSP             : "${csp.length > 120 ? '${csp.substring(0, 120)}…' : csp}"  restricted=$hasRestrictedCsp');
            _log('  → Body signals    : $bodySignalsFrameRestriction');

            final shouldUseProxy = hasRestrictedXFrame ||
                hasRestrictedCsp ||
                bodySignalsFrameRestriction;

            _log('  → Result: needsProxy=$shouldUseProxy');
            await _cacheRestriction(cacheKey, shouldUseProxy);
            return shouldUseProxy;
          }
        } catch (e) {
          _log('  → Probe failed: $e');
        }
      }

      // Default: assume no restrictions and try direct load
      _log('  → Defaulting to direct load (no restriction signal)');
      await _cacheRestriction(cacheKey, false);
      return false;
    } catch (e) {
      _log('  → Restriction check threw: $e – defaulting to direct load');
      await _cacheRestriction(cacheKey, false);
      return false;
    }
  }

  /// Detects if a page loaded successfully by checking URL and loading state
  /// Returns true if page appears to be blocked/failed, false if it loaded
  /// Fetches page source through CORS proxy with fallback (web platform only)
  Future<_ProxyFetchResult?> _fetchPageSourceViaProxy(String url) async {
    if (!kIsWeb) {
      return null; // Not on web, don't fetch
    }

    _log('━━━ [SWebView] _fetchPageSourceViaProxy ━━━');
    _log('  url          : $url');
    _log('  proxy count  : ${_corsProxyUrls.length}');
    for (int k = 0; k < _corsProxyUrls.length; k++) {
      _log('  proxy[$k]     : ${_corsProxyUrls[k]}');
    }

    for (int i = 0; i < _corsProxyUrls.length; i++) {
      try {
        final proxyBase = _corsProxyUrls[i];
        final proxiedUrl =
            SWebViewProxyHtmlUtils.buildProxiedUrl(proxyBase, url);

        _log('  ─── Attempt proxy[$i]: $proxyBase');
        _log('    fetch URL : $proxiedUrl');

        final sw = Stopwatch()..start();
        final response = await http
            .get(
              Uri.parse(proxiedUrl),
              headers: widget.config.proxyHeaders,
            )
            .timeout(const Duration(seconds: 15));
        sw.stop();

        _log(
            '    HTTP ${response.statusCode}  (${sw.elapsedMilliseconds}ms, ${response.bodyBytes.length} bytes)');
        _log('    content-type : ${response.headers['content-type'] ?? '–'}');

        if (response.statusCode == 200) {
          final normalized = SWebViewProxyHtmlUtils.normalizeProxyHtml(
            response.body,
            headers: response.headers,
          );

          final looksHtml = SWebViewProxyHtmlUtils.looksLikeHtml(normalized);
          final needsPathFriendlyProxy =
              SWebViewProxyHtmlUtils.requiresPathFriendlyProxy(normalized);
          final isQueryStyleProxy =
              SWebViewProxyHtmlUtils.isQueryStyleProxyBase(proxyBase);

          _log('    looksLikeHtml           : $looksHtml');
          _log('    requiresPathFriendly    : $needsPathFriendlyProxy');
          _log('    isQueryStyleProxy       : $isQueryStyleProxy');
          _log('    normalized length       : ${normalized.length} chars');
          if (normalized.length > 200) {
            _log(
                '    normalized preview      : ${normalized.substring(0, 200).replaceAll('\n', ' ')}…');
          }

          if (needsPathFriendlyProxy && isQueryStyleProxy) {
            // Only skip if there is a path-style proxy still available in the list.
            // If all remaining proxies are also query-style, use this one and
            // rely on the absolute <base> tag to resolve module imports correctly.
            final hasNextPathStyleProxy = _corsProxyUrls
                .skip(i + 1)
                .any((p) => !SWebViewProxyHtmlUtils.isQueryStyleProxyBase(p));
            if (hasNextPathStyleProxy) {
              _log(
                '    → Skipping: query-style proxy; a path-style proxy is available next.',
              );
              continue;
            }
            _log(
              '    → No path-style proxy available; using query-style proxy '
              'with absolute <base> fallback for module resolution.',
            );
          }

          _log('    → Selected proxy[$i] for final load');
          return _ProxyFetchResult(
            html: normalized,
            proxyBase: proxyBase,
          );
        } else {
          throw Exception('Proxy returned status ${response.statusCode}');
        }
      } catch (e) {
        _log('    → proxy[$i] failed: $e');

        if (i == _corsProxyUrls.length - 1) {
          _log(
              '  → All ${_corsProxyUrls.length} proxies exhausted – returning null');
          return null;
        }
        continue;
      }
    }

    return null;
  }

  Uri _buildProxyDataUriOrThrow({
    required String pageSource,
    required String originalUrl,
    required String proxyBase,
    bool forceRewriteResources = false,
  }) {
    _log('━━━ [SWebView] _buildProxyDataUriOrThrow ━━━');
    _log('  originalUrl    : $originalUrl');
    _log('  proxyBase      : $proxyBase');
    _log('  pageSource len : ${pageSource.length} chars');

    var html = SWebViewProxyHtmlUtils.injectBaseTagIfMissing(
      pageSource,
      originalUrl,
    );
    _log('  after injectBase len   : ${html.length} chars');

    final isModulePage = SWebViewProxyHtmlUtils.requiresPathFriendlyProxy(html);
    final isQueryProxy =
        SWebViewProxyHtmlUtils.isQueryStyleProxyBase(proxyBase);
    _log('  isModulePage           : $isModulePage');
    _log('  isQueryProxy           : $isQueryProxy');

    if (!forceRewriteResources && isModulePage && isQueryProxy) {
      // Module/importmap pages rely on the browser's own module resolution.
      // Routing sub-resources through a query-style proxy breaks relative imports
      // inside JS modules (e.g. `import "./utils.js"` resolves wrongly against
      // `proxy.com/?url=...index.js`). Instead, the absolute <base href> injected
      // above lets the browser resolve all relative URLs directly against the
      // original origin – which typically serves static assets with CORS headers.
      _log(
          '  → Skipping resource rewrite: relying on <base> for module resolution');
    } else {
      if (forceRewriteResources && isModulePage && isQueryProxy) {
        _log(
            '  → Adaptive mode: forcing resource rewrite even on module/query proxy');
      }
      html = SWebViewProxyHtmlUtils.rewriteHtmlResourceUrlsForProxy(
        html,
        originalUrl: originalUrl,
        proxyBase: proxyBase,
      );
      _log('  after rewriteResources : ${html.length} chars');
    }

    html = SWebViewProxyHtmlUtils.injectProxyCompatibilityScript(html);
    _log('  after injectCompat     : ${html.length} chars');

    if (widget.darkMode) {
      html = _injectDarkModeStyleBlock(html);
      _log('  after dark mode style inject : ${html.length} chars');
    }

    final isIncompat =
        SWebViewProxyHtmlUtils.isLikelyProxyIncompatibleDocument(html);
    _log('  isProxyIncompatible    : $isIncompat');

    if (isIncompat) {
      throw _ProxyIncompatibleDocumentException(
        'Proxy-injected page requires first-party origin (likely anti-bot/challenge page). '
        'Use Open in New Tab for this URL.',
      );
    }

    final encoded = base64.encode(utf8.encode(html));
    _log('  data URI base64 len    : ${encoded.length} chars');
    _log(
        '  data URI preview       : data:text/html;base64,${encoded.substring(0, encoded.length.clamp(0, 80))}…');
    return Uri.parse('data:text/html;base64,$encoded');
  }

  Future<void> _loadThroughProxy(
    String url, {
    required bool useInitController,
    required bool forceRewriteResources,
    bool enableAdaptiveMonitoring = true,
  }) async {
    _isUsingProxy = true;
    final fetched = await _fetchPageSourceViaProxy(url);

    if (fetched == null) {
      throw Exception('Failed to load via proxy');
    }

    _log('  → Building data URI (proxyBase=${fetched.proxyBase})');
    final dataUri = _buildProxyDataUriOrThrow(
      pageSource: fetched.html,
      originalUrl: url,
      proxyBase: fetched.proxyBase,
      forceRewriteResources: forceRewriteResources,
    );

    _log('  → Loading data URI into controller');
    if (useInitController) {
      await _initControllerWithUri(dataUri);
    } else {
      await webViewController!.go(uri: dataUri);
    }

    if (kIsWeb && enableAdaptiveMonitoring) {
      final generation = ++_proxyHealthProbeGeneration;
      unawaited(_monitorProxyRuntimeAndAdapt(
        url: url,
        generation: generation,
        forceRewriteResources: forceRewriteResources,
        useInitController: useInitController,
      ));
    }
  }

  Future<void> _monitorProxyRuntimeAndAdapt({
    required String url,
    required int generation,
    required bool forceRewriteResources,
    required bool useInitController,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted ||
        !_isUsingProxy ||
        generation != _proxyHealthProbeGeneration) {
      return;
    }

    final snapshot = await _readProxyHealthSnapshot();
    if (snapshot == null) {
      return;
    }
    _log(
      '  → proxy health: errors=${snapshot.errorCount}, '
      'swallowed=${snapshot.swallowedCount}, '
      'rejections=${snapshot.unhandledRejectionCount}, '
      'pluginFailures=${snapshot.pluginFailureCount}',
    );

    if (!snapshot.hasSevereRuntimeIssues) {
      return;
    }

    if (_proxyAdaptiveRetriedCurrentLoad || forceRewriteResources) {
      _log('  → proxy health degraded; adaptive retry already consumed');
      return;
    }

    _proxyAdaptiveRetriedCurrentLoad = true;
    _log(
      '  → proxy health degraded; running one-shot adaptive retry '
      '(forcing resource rewrite strategy)',
    );

    try {
      await _loadThroughProxy(
        url,
        useInitController: useInitController,
        forceRewriteResources: true,
        enableAdaptiveMonitoring: false,
      );
    } catch (e) {
      _log('  → adaptive proxy retry failed: $e');
    }
  }

  Future<_ProxyHealthSnapshot?> _readProxyHealthSnapshot() async {
    if (webViewController == null || webViewController!.is_init == false) {
      return _ProxyHealthSnapshot.empty;
    }

    if (!webViewController!.is_mobile) {
      return _ProxyHealthSnapshot.empty;
    }

    if (_proxyHealthTelemetryUnsupported) {
      return null;
    }

    try {
      final dynamic raw = await webViewController!.webview_mobile_controller
          .runJavaScriptReturningResult('''
            (function(){
              try {
                var stats = window.__swebviewCompatStats || {};
                return JSON.stringify(stats);
              } catch (_) {
                return '{}';
              }
            })();
          ''');

      String payload;
      if (raw == null) {
        payload = '{}';
      } else if (raw is String) {
        final trimmed = raw.trim();
        if (trimmed.length >= 2 &&
            ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
                (trimmed.startsWith("'") && trimmed.endsWith("'")))) {
          payload = trimmed.substring(1, trimmed.length - 1);
        } else {
          payload = trimmed;
        }
      } else {
        payload = raw.toString();
      }

      final decoded = json.decode(payload);
      if (decoded is Map<String, dynamic>) {
        return _ProxyHealthSnapshot.fromJson(decoded);
      }
      if (decoded is Map) {
        return _ProxyHealthSnapshot.fromJson(
            Map<String, dynamic>.from(decoded));
      }
    } on UnimplementedError {
      _proxyHealthTelemetryUnsupported = true;
      _log(
          '  → proxy health probe disabled: JS result API not implemented on this platform');
      return null;
    } catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('runjavascriptreturningresult') &&
          message.contains('not implemented')) {
        _proxyHealthTelemetryUnsupported = true;
        _log(
            '  → proxy health probe disabled: JS result API not implemented on this platform');
        return null;
      }
      _log('  → failed to read proxy health snapshot: $e');
    }

    return _ProxyHealthSnapshot.empty;
  }

  void _updateIframeTheme() {
    if (!kIsWeb) return;
    final filter = widget.darkMode ? 'invert(1) hue-rotate(180deg)' : 'none';
    final currentUri = webViewController?.currentUrlNotifier.value;
    if (currentUri != null) {
      web_utils.applyIframeFilter(currentUri.toString(), filter);
    }
  }

  String _injectDarkModeStyleBlock(String html) {
    const styleBlock = '''
<style id="swebview-dark-mode-override">
  img, video, canvas, picture, [style*="background-image"] {
    filter: invert(1) hue-rotate(-180deg) !important;
  }
</style>
''';
    final headTag = RegExp(r'<head\b[^>]*>', caseSensitive: false);
    if (headTag.hasMatch(html)) {
      return html.replaceFirstMapped(headTag, (match) {
        return '${match.group(0)}$styleBlock';
      });
    }
    return '$styleBlock$html';
  }

  Widget _buildFallbackUI() {
    Future<void> onRetryWithProxy() async {
      await SWebView.retryWithProxy(
        widget.url,
        showDebugLogs: widget.showDebugLogs,
      );
      if (mounted) {
        setState(() {
          isLoaded = null;
          _isUsingProxy = true;
        });
      }
      await _loadUrl(widget.url);
    }

    void onOpenInNewTab() {
      SWebView.openInNewTab(
        widget.url,
        showDebugLogs: widget.showDebugLogs,
      );
    }

    if (widget.fallbackBuilder != null) {
      return widget.fallbackBuilder!(context, onRetryWithProxy, onOpenInNewTab);
    }

    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                "Embedding Restricted",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "This website prevents other applications from embedding it directly. You can try loading it through our secure CORS proxy or open it in a new browser tab.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_isUsingProxy) ...[
                    FilledButton.icon(
                      onPressed: onRetryWithProxy,
                      icon: const Icon(Icons.vpn_lock, size: 18),
                      label: const Text("Retry with Proxy"),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  OutlinedButton.icon(
                    onPressed: onOpenInNewTab,
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text("Open in New Tab"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _ensureController() {
    final injected = widget.controller;
    if (injected != null) {
      if (!identical(webViewController, injected)) {
        webViewController = injected;
        _ownsController = false;
      }
      return;
    }

    if (webViewController == null) {
      webViewController = WebViewController();
      _ownsController = true;
    }
  }

  Future<void> _initControllerWithUri(Uri uri) async {
    _ensureController();
    await webViewController!.init(
      context: context,
      uri: uri,
      setState: (fn) {
        if (mounted) {
          setState(fn);
        }
      },
      onProgress: widget.onProgress,
      onPageStarted: (Uri pageUri) {
        _updateIframeTheme();
        widget.onPageStarted?.call(pageUri);
      },
      onUrlChanged: widget.onUrlChanged,
      onPageFinished: (Uri pageUri) {
        _updateIframeTheme();
        widget.onPageFinished?.call(pageUri);
      },
      onNavigationRequest: widget.onNavigationRequest,
      onJavaScriptMessage: widget.onJavaScriptMessage,
    );
  }

  /// Detects if a URL requires CORS proxy by checking HTTP response headers
  /// Checks for: X-Frame-Options (DENY, SAMEORIGIN) and CSP frame-ancestors
  /// Returns true if CORS proxy should be used, false for direct load
  Future<void> initialisation() async {
    _log('━━━ [SWebView] initialisation ━━━');
    _log('  url                      : ${widget.url}');
    _log('  kIsWeb                   : $kIsWeb');
    _log('  autoDetectRestrictions   : $_autoDetectFrameRestrictions');
    _log('  platform                 : ${defaultTargetPlatform.name}');
    try {
      if (mounted) {
        setState(() {
          isLoaded = null;
        });
      }
      _ensureController();

      // In test mode, skip all network calls and just mark as loaded
      if (WebViewController.isTestMode) {
        _log('  → Test mode active – skipping network');
        await _initControllerWithUri(Uri.parse(widget.url));
        if (mounted) {
          setState(() {
            isLoaded = true;
          });
          widget.onLoaded?.call();
        }
        return;
      }

      if (kIsWeb && _autoDetectFrameRestrictions) {
        _proxyAdaptiveRetriedCurrentLoad = false;
        // Check cache first
        bool needsProxy;
        final cacheKey = _cacheKeyFor(widget.url);
        final cached = _restrictionCache[cacheKey];
        if (cached != null && _isEntryFresh(cached)) {
          needsProxy = cached.needsProxy;
          _log('  → Cache hit: needsProxy=$needsProxy');
        } else {
          _log('  → No cache hit – running restriction check…');
          needsProxy = await _checkHeadersForRestrictions(widget.url);
          _log('  → Restriction check done: needsProxy=$needsProxy');
        }

        if (needsProxy) {
          _log('  → MODE: proxy');
          await _loadThroughProxy(
            widget.url,
            useInitController: true,
            forceRewriteResources: false,
          );
        } else {
          _log('  → MODE: direct (${widget.url})');
          _isUsingProxy = false;
          await _initControllerWithUri(Uri.parse(widget.url));
        }
      } else {
        _log('  → MODE: direct – auto-detect disabled or native platform');
        _isUsingProxy = false;
        await _initControllerWithUri(Uri.parse(widget.url));
      }

      _log('  → initialisation complete: isLoaded=true');
      if (mounted) {
        setState(() {
          isLoaded = true;
        });
        widget.onLoaded?.call();
      }
    } catch (e) {
      _log('━━━ [SWebView] initialisation FAILED ━━━');
      _log('  error: $e');
      final errorMessage =
          'Failed to load: ${e.toString().replaceAll('Exception: ', '')}';

      if (e is _ProxyIncompatibleDocumentException) {
        _log(
            '  → proxy-incompatible document – firing onProxyIncompatibleDocument');
        if (mounted) {
          setState(() {
            isLoaded = false;
          });
          if (widget.onProxyIncompatibleDocument != null) {
            widget.onProxyIncompatibleDocument!.call();
          } else {
            // Fall back to the generic blocked/error callbacks.
            if (kIsWeb) widget.onIframeBlocked?.call();
            widget.onError?.call(errorMessage);
          }
        }
        return;
      }

      // On web, likely an iframe restriction
      if (kIsWeb && mounted) {
        _log('  → firing onIframeBlocked');
        widget.onIframeBlocked?.call();
      }

      if (mounted) {
        setState(() {
          isLoaded = false;
        });
        widget.onError?.call(errorMessage);
      }
    }
  }

  Future<void> _loadUrl(String url) async {
    _log('━━━ [SWebView] _loadUrl ━━━');
    _log('  url : $url');

    if (webViewController == null || webViewController!.is_init == false) {
      _log('  → Controller not init – delegating to initialisation()');
      await initialisation();
      return;
    }

    // In test mode, just update the loaded state without actual navigation
    if (WebViewController.isTestMode) {
      _log('  → Test mode – skipping network');
      if (mounted) {
        setState(() {
          isLoaded = true;
        });
        widget.onLoaded?.call();
      }
      return;
    }

    try {
      if (mounted) {
        setState(() {
          isLoaded = null;
        });
      }

      if (kIsWeb && _autoDetectFrameRestrictions) {
        _proxyAdaptiveRetriedCurrentLoad = false;
        // Check cache first
        bool needsProxy;
        final cacheKey = _cacheKeyFor(url);
        final cached = _restrictionCache[cacheKey];
        if (cached != null && _isEntryFresh(cached)) {
          needsProxy = cached.needsProxy;
          _log('  → Cache hit: needsProxy=$needsProxy');
        } else {
          _log('  → No cache hit – running restriction check…');
          needsProxy = await _checkHeadersForRestrictions(url);
          _log('  → Restriction check done: needsProxy=$needsProxy');
        }

        if (needsProxy) {
          _log('  → MODE: proxy');
          await _loadThroughProxy(
            url,
            useInitController: false,
            forceRewriteResources: false,
          );
        } else {
          _log('  → MODE: direct ($url)');
          _isUsingProxy = false;
          await webViewController!.go(uri: Uri.parse(url));
        }
      } else {
        _log('  → MODE: direct – auto-detect disabled or native platform');
        _isUsingProxy = false;
        await webViewController!.go(uri: Uri.parse(url));
      }

      _log('  → _loadUrl complete: isLoaded=true');
      if (mounted) {
        setState(() {
          isLoaded = true;
        });
        widget.onLoaded?.call();
      }
    } catch (e) {
      _log('━━━ [SWebView] _loadUrl FAILED ━━━');
      _log('  error: $e');
      final errorMessage =
          'Failed to load: ${e.toString().replaceAll('Exception: ', '')}';

      if (e is _ProxyIncompatibleDocumentException) {
        _log(
            '  → proxy-incompatible document – firing onProxyIncompatibleDocument');
        if (mounted) {
          setState(() {
            isLoaded = false;
          });
          if (widget.onProxyIncompatibleDocument != null) {
            widget.onProxyIncompatibleDocument!.call();
          } else {
            // Fall back to the generic blocked/error callbacks.
            if (kIsWeb) widget.onIframeBlocked?.call();
            widget.onError?.call(errorMessage);
          }
        }
        return;
      }

      // On web, likely an iframe restriction
      if (kIsWeb && mounted) {
        _log('  → firing onIframeBlocked');
        widget.onIframeBlocked?.call();
      }

      if (mounted) {
        setState(() {
          isLoaded = false;
        });
        widget.onError?.call(errorMessage);
      }
    }
  }

  @override
  void didUpdateWidget(SWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showDebugLogs != widget.showDebugLogs) {
      SWebViewDebug.enabled = widget.showDebugLogs;
    }
    if (oldWidget.darkMode != widget.darkMode) {
      _updateIframeTheme();
    }
    if (!identical(oldWidget.controller, widget.controller)) {
      if (_ownsController) {
        webViewController?.dispose();
      }
      webViewController = widget.controller;
      _ownsController = widget.controller == null;
      unawaited(initialisation());
      return;
    }
    if (oldWidget.url != widget.url) {
      _loadUrl(widget.url);
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      webViewController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build the loading indicator widget
    Widget loadingWidget = Center(child: TickerFreeCircularProgressIndicator());

    // Build the webview widget only if controller is initialized
    Widget webviewWidget =
        webViewController != null && webViewController!.is_init
            ? WebView(
                controller: webViewController!,
                ignorePointerEvents: widget.ignorePointerEvents,
              )
            : const SizedBox.shrink();

    // Apply animations only when not in test mode
    if (!WebViewController.isTestMode) {
      loadingWidget = loadingWidget.animate(
        key: const ValueKey("loading"),
        effects: [
          FadeEffect(
            duration: Duration(seconds: 0, milliseconds: 500),
            curve: Curves.easeInOut,
          )
        ],
      );
      webviewWidget = webviewWidget.animate(
        key: ValueKey("sWebview - ${widget.url}"),
        effects: [
          FadeEffect(
            duration: Duration(seconds: 2, milliseconds: 500),
            curve: Curves.fastEaseInToSlowEaseOut,
          )
        ],
      );
    }

    return Column(
      children: [
        // Toolbar with action buttons (web only)
        if (kIsWeb && widget.showToolbar) _buildToolbar(),

        // Main content
        Expanded(
          child: isLoaded == null
              ? loadingWidget
              : !isLoaded!
                  ? _buildFallbackUI()
                  : webviewWidget,
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return SWebView.tapTarget(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if (_isUsingProxy)
              Tooltip(
                message:
                    'Remove this URL from the proxy cache and reload directly',
                child: FilledButton.icon(
                  onPressed: () async {
                    await SWebView.removeFromCache(
                      widget.url,
                      showDebugLogs: widget.showDebugLogs,
                    );
                    // Reload without proxy
                    if (mounted) {
                      setState(() {
                        isLoaded = null;
                        _isUsingProxy = false;
                      });
                    }
                    await _loadUrl(widget.url);
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Clear URL from Proxy'),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onErrorContainer,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            if (_isUsingProxy) const SizedBox(width: 12),
            if (!_isUsingProxy) const Spacer(),
            if (!_isUsingProxy)
              Tooltip(
                message: 'Try loading this page through a CORS proxy',
                child: FilledButton.icon(
                  onPressed: () async {
                    await SWebView.retryWithProxy(
                      widget.url,
                      showDebugLogs: widget.showDebugLogs,
                    );
                    // Reload with proxy
                    if (mounted) {
                      setState(() {
                        isLoaded = null;
                        _isUsingProxy = true;
                      });
                    }
                    await _loadUrl(widget.url);
                  },
                  icon: const Icon(Icons.vpn_lock, size: 18),
                  label: const Text('Retry with Proxy'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            if (!_isUsingProxy) const SizedBox(width: 12),
            Tooltip(
              message: 'Open this page in a new browser tab',
              child: OutlinedButton.icon(
                onPressed: () => SWebView.openInNewTab(
                  widget.url,
                  showDebugLogs: widget.showDebugLogs,
                ),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Open in New Tab'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ********************************** */

/// Exception thrown when a CORS-proxy-fetched HTML document is detected to be
/// incompatible with `data:` URL loading (e.g. Cloudflare challenge pages).
class _ProxyIncompatibleDocumentException implements Exception {
  final String message;

  const _ProxyIncompatibleDocumentException(this.message);

  @override
  String toString() => message;
}
