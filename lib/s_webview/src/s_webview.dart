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

  const SWebViewConfig({
    this.autoDetectFrameRestrictions = true,
    this.corsProxyUrls = const [
      'https://api.codetabs.com/v1/proxy?quest=',
      'https://cors.bridged.cc/',
      'https://api.allorigins.win/raw?url=',
    ],
    this.knownRestrictedDomains = const {
      'google.com',
      'github.com',
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
    if (kDebugMode && showDebugLogs) {
      debugPrint('SWebView: User requested retry with proxy for $url');
      debugPrint(
          'SWebView: ⚠️ SUGGESTION: Add "${Uri.parse(url).host}" to restrictedDomains list');
    }

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
    if (kDebugMode && showDebugLogs) {
      debugPrint('SWebView: Opening in new tab: $url');
      if (addToProxyCacheForNextTime) {
        debugPrint('SWebView: URL marked to use proxy for next load: $url');
      } else {
        debugPrint(
            'SWebView: ⚠️ SUGGESTION: Add "${Uri.parse(url).host}" to restrictedDomains list');
      }
    }

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
    if (kDebugMode && showDebugLogs) {
      debugPrint('SWebView: Removing $url from proxy cache');
    }

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

  void _log(String message) {
    if (kDebugMode && widget.showDebugLogs) {
      debugPrint(message);
    }
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

        if (kDebugMode && showDebugLogs) {
          debugPrint(
              'SWebView: Loaded ${_restrictionCache.length} cached restrictions from storage');
        }
      } else {
        if (kDebugMode && showDebugLogs) {
          debugPrint('SWebView: No cached restrictions found in storage');
        }
      }
    } catch (e) {
      if (kDebugMode && showDebugLogs) {
        debugPrint('SWebView: Error loading cache: $e');
      }
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

      if (kDebugMode && showDebugLogs) {
        debugPrint(
            'SWebView: Saved ${_restrictionCache.length} restrictions to storage');
      }
    } catch (e) {
      if (kDebugMode && showDebugLogs) {
        debugPrint('SWebView: Error saving cache: $e');
      }
    }
  }

  /// Detects frame restrictions by testing with each CORS proxy
  /// Uses known domain rules and response headers/content hints.
  /// Returns true if we should use proxy, false for direct load
  Future<bool> _checkHeadersForRestrictions(String url) async {
    if (!kIsWeb) return false; // Native platforms don't need proxy

    final cacheKey = _cacheKeyFor(url);

    // Check configured known restricted domains first.
    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
    final isKnownRestricted =
        _knownRestrictedDomains.any((domain) => host.endsWith(domain));
    if (isKnownRestricted) {
      _log('SWebView: Known restricted domain detected for $host');
      await _cacheRestriction(cacheKey, true);
      return true;
    }

    // Check cache first
    final cachedEntry = _restrictionCache[cacheKey];
    if (cachedEntry != null && _isEntryFresh(cachedEntry)) {
      _log(
          'SWebView: Using cached restriction check - needs proxy: ${cachedEntry.needsProxy}');
      return cachedEntry.needsProxy;
    }
    if (cachedEntry != null && !_isEntryFresh(cachedEntry)) {
      _restrictionCache.remove(cacheKey);
    }

    try {
      _log('SWebView: Testing URL restrictions for $url...');

      // Test via proxy and inspect headers for frame restrictions.
      if (_corsProxyUrls.isNotEmpty) {
        try {
          final proxyUrl = '${_corsProxyUrls[0]}${Uri.encodeComponent(url)}';

          _log('SWebView: Testing proxy access...');

          final response = await http.get(Uri.parse(proxyUrl)).timeout(
                const Duration(seconds: 3),
              );

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

            final shouldUseProxy = hasRestrictedXFrame ||
                hasRestrictedCsp ||
                bodySignalsFrameRestriction;

            _log(
                'SWebView: Restriction check result -> proxy: $shouldUseProxy');
            await _cacheRestriction(cacheKey, shouldUseProxy);
            return shouldUseProxy;
          }
        } catch (e) {
          _log('SWebView: Proxy test failed: $e');
        }
      }

      // Default: assume no restrictions and try direct load
      _log('SWebView: No restrictions detected, will try direct load');
      await _cacheRestriction(cacheKey, false);
      return false;
    } catch (e) {
      _log('SWebView: Error checking restrictions: $e');
      // On any error, assume no restrictions (fail gracefully)
      await _cacheRestriction(cacheKey, false);
      return false;
    }
  }

  /// Detects if a page loaded successfully by checking URL and loading state
  /// Returns true if page appears to be blocked/failed, false if it loaded
  /// Fetches page source through CORS proxy with fallback (web platform only)
  Future<String?> _fetchPageSourceViaProxy(String url) async {
    if (!kIsWeb) {
      return null; // Not on web, don't fetch
    }

    if (kDebugMode && widget.showDebugLogs) {
      _log(
          'SWebView: ⚠️ Proxy mode enabled. Avoid sensitive/authenticated pages.');
    }

    for (int i = 0; i < _corsProxyUrls.length; i++) {
      try {
        final proxyBase = _corsProxyUrls[i];
        final encodedUrl = Uri.encodeComponent(url);
        final proxiedUrl = '$proxyBase$encodedUrl';

        _log('SWebView: Fetching via proxy ($i): $url -> $proxiedUrl');

        final response = await http
            .get(Uri.parse(proxiedUrl))
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          _log('SWebView: Successfully fetched via proxy');
          return SWebViewProxyHtmlUtils.normalizeProxyHtml(
            response.body,
            headers: response.headers,
          );
        } else {
          throw Exception('Proxy returned status ${response.statusCode}');
        }
      } catch (e) {
        _log('SWebView: Proxy $i failed: $e');

        if (i == _corsProxyUrls.length - 1) {
          // Last proxy failed
          _log('SWebView: All proxies exhausted');
          return null;
        }
        // Try next proxy
        continue;
      }
    }

    return null;
  }

  Uri _buildProxyDataUriOrThrow({
    required String pageSource,
    required String originalUrl,
  }) {
    var html = SWebViewProxyHtmlUtils.injectBaseTagIfMissing(
      pageSource,
      originalUrl,
    );

    if (SWebViewProxyHtmlUtils.isLikelyProxyIncompatibleDocument(html)) {
      throw _ProxyIncompatibleDocumentException(
        'Proxy-injected page requires first-party origin (likely anti-bot/challenge page). '
        'Use Open in New Tab for this URL.',
      );
    }

    final base64Html = base64.encode(utf8.encode(html));
    return Uri.parse('data:text/html;base64,$base64Html');
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
      onPageStarted: widget.onPageStarted,
      onUrlChanged: widget.onUrlChanged,
      onPageFinished: widget.onPageFinished,
      onNavigationRequest: widget.onNavigationRequest,
      onJavaScriptMessage: widget.onJavaScriptMessage,
    );
  }

  /// Detects if a URL requires CORS proxy by checking HTTP response headers
  /// Checks for: X-Frame-Options (DENY, SAMEORIGIN) and CSP frame-ancestors
  /// Returns true if CORS proxy should be used, false for direct load
  Future<void> initialisation() async {
    try {
      if (mounted) {
        setState(() {
          isLoaded = null;
        });
      }
      _ensureController();

      // In test mode, skip all network calls and just mark as loaded
      if (WebViewController.isTestMode) {
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
        // Check cache first
        bool needsProxy;
        final cacheKey = _cacheKeyFor(widget.url);
        final cached = _restrictionCache[cacheKey];
        if (cached != null && _isEntryFresh(cached)) {
          needsProxy = cached.needsProxy;
          _log('SWebView: Using cached result - needs proxy: $needsProxy');
        } else {
          // Check headers to detect restrictions
          _log(
              'SWebView: Checking headers for restrictions on ${widget.url}...');
          needsProxy = await _checkHeadersForRestrictions(widget.url);
        }

        if (needsProxy) {
          // Use proxy
          _log('SWebView: Loading via proxy...');
          _isUsingProxy = true;
          var pageSource = await _fetchPageSourceViaProxy(widget.url);

          if (pageSource != null) {
            final dataUri = _buildProxyDataUriOrThrow(
              pageSource: pageSource,
              originalUrl: widget.url,
            );
            await _initControllerWithUri(dataUri);
          } else {
            throw Exception('Failed to load via proxy');
          }
        } else {
          // Load directly
          _log('SWebView: Loading directly (no restrictions detected)...');
          _isUsingProxy = false;

          await _initControllerWithUri(Uri.parse(widget.url));
        }
      } else {
        // Auto-detection disabled or native platform, load directly
        _isUsingProxy = false;
        await _initControllerWithUri(Uri.parse(widget.url));
      }

      if (mounted) {
        setState(() {
          isLoaded = true;
        });
        widget.onLoaded?.call();
      }
    } catch (e) {
      _log('Error initializing webview: $e');
      final errorMessage =
          'Failed to load: ${e.toString().replaceAll('Exception: ', '')}';

      if (e is _ProxyIncompatibleDocumentException) {
        _log('SWebView: proxy-incompatible document detected');
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
    if (webViewController == null || webViewController!.is_init == false) {
      await initialisation();
      return;
    }

    // In test mode, just update the loaded state without actual navigation
    if (WebViewController.isTestMode) {
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
        // Check cache first
        bool needsProxy;
        final cacheKey = _cacheKeyFor(url);
        final cached = _restrictionCache[cacheKey];
        if (cached != null && _isEntryFresh(cached)) {
          needsProxy = cached.needsProxy;
          _log('SWebView: Using cached result - needs proxy: $needsProxy');
        } else {
          // Check headers to detect restrictions
          _log('SWebView: Checking headers for restrictions on $url...');
          needsProxy = await _checkHeadersForRestrictions(url);
        }

        if (needsProxy) {
          // Use proxy
          _log('SWebView: Loading via proxy...');
          _isUsingProxy = true;
          var pageSource = await _fetchPageSourceViaProxy(url);
          if (pageSource != null) {
            final dataUri = _buildProxyDataUriOrThrow(
              pageSource: pageSource,
              originalUrl: url,
            );
            await webViewController!.go(uri: dataUri);
          } else {
            throw Exception('Failed to load via proxy');
          }
        } else {
          // Load directly
          _log('SWebView: Loading directly (no restrictions detected)...');
          _isUsingProxy = false;
          await webViewController!.go(uri: Uri.parse(url));
        }
      } else {
        // Auto-detection disabled or native platform, load directly
        _isUsingProxy = false;
        await webViewController!.go(uri: Uri.parse(url));
      }

      if (mounted) {
        setState(() {
          isLoaded = true;
        });
        widget.onLoaded?.call();
      }
    } catch (e) {
      _log('Error loading new url: $e');
      final errorMessage =
          'Failed to load: ${e.toString().replaceAll('Exception: ', '')}';

      if (e is _ProxyIncompatibleDocumentException) {
        _log('SWebView: proxy-incompatible document detected');
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
                  ? const Center(child: Text("Failed to load URL"))
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
