import 'client_interceptor.dart';
import '../models/client_response.dart';

/// Cache entry with metadata.
class _CacheEntry {
  final ClientResponse response;
  final DateTime timestamp;
  final Duration maxAge;

  _CacheEntry({
    required this.response,
    required this.timestamp,
    required this.maxAge,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > maxAge;
}

/// An interceptor that provides simple in-memory caching for GET requests.
class CacheInterceptor extends ClientInterceptor {
  /// The cache storage.
  final Map<String, _CacheEntry> _cache = {};

  /// Default cache duration.
  final Duration defaultMaxAge;

  /// Maximum number of entries in the cache.
  final int maxEntries;

  /// Whether to cache only successful responses.
  final bool cacheOnlySuccess;

  /// HTTP methods to cache (usually only GET).
  final Set<String> methodsToCache;

  /// URL patterns to exclude from caching.
  final List<RegExp> excludePatterns;

  CacheInterceptor({
    this.defaultMaxAge = const Duration(minutes: 5),
    this.maxEntries = 100,
    this.cacheOnlySuccess = true,
    this.methodsToCache = const {'GET'},
    this.excludePatterns = const [],
  });

  String _getCacheKey(ClientRequest request) {
    final queryString = request.queryParameters?.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&') ??
        '';
    return '${request.method}:${request.url}?$queryString';
  }

  bool _shouldCache(ClientRequest request) {
    if (!methodsToCache.contains(request.method.toUpperCase())) {
      return false;
    }

    for (final pattern in excludePatterns) {
      if (pattern.hasMatch(request.url)) {
        return false;
      }
    }

    // Check if request explicitly disables caching
    if (request.extra['noCache'] == true) {
      return false;
    }

    return true;
  }

  void _evictOldest() {
    if (_cache.length >= maxEntries) {
      final entries = _cache.entries.toList()
        ..sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));

      // Remove oldest 10% of entries
      final toRemove = (maxEntries * 0.1).ceil();
      for (int i = 0; i < toRemove && i < entries.length; i++) {
        _cache.remove(entries[i].key);
      }
    }
  }

  @override
  Future<ClientRequest?> onRequest(ClientRequest request) async {
    if (!_shouldCache(request)) {
      return request;
    }

    final cacheKey = _getCacheKey(request);
    final entry = _cache[cacheKey];

    if (entry != null && !entry.isExpired) {
      // Store the cached response in extra so we can return it
      request.extra['cachedResponse'] = entry.response;
    }

    return request;
  }

  @override
  Future<ClientResponse> onResponse(
    ClientRequest request,
    ClientResponse response,
  ) async {
    // Check if we have a cached response
    final cachedResponse = request.extra['cachedResponse'] as ClientResponse?;
    if (cachedResponse != null) {
      // Return cached response with isFromCache flag
      return ClientResponse(
        statusCode: cachedResponse.statusCode,
        body: cachedResponse.body,
        bodyBytes: cachedResponse.bodyBytes,
        headers: cachedResponse.headers,
        requestUrl: cachedResponse.requestUrl,
        method: cachedResponse.method,
        requestDuration: 0,
        isFromCache: true,
      );
    }

    // Cache the response if appropriate
    if (_shouldCache(request)) {
      if (!cacheOnlySuccess || response.isSuccess) {
        _evictOldest();

        final maxAge =
            request.extra['cacheMaxAge'] as Duration? ?? defaultMaxAge;

        _cache[_getCacheKey(request)] = _CacheEntry(
          response: response,
          timestamp: DateTime.now(),
          maxAge: maxAge,
        );
      }
    }

    return response;
  }

  /// Clears all cached entries.
  void clearCache() {
    _cache.clear();
  }

  /// Removes expired entries from the cache.
  void removeExpired() {
    _cache.removeWhere((_, entry) => entry.isExpired);
  }

  /// Invalidates cache entries matching the given URL pattern.
  void invalidate(String urlPattern) {
    final pattern = RegExp(urlPattern);
    _cache.removeWhere((key, _) => pattern.hasMatch(key));
  }

  /// Returns the number of cached entries.
  int get cacheSize => _cache.length;
}
