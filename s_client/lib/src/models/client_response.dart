import 'dart:convert';

/// A unified response class that works with both http and dio backends.
class ClientResponse {
  /// The HTTP status code.
  final int statusCode;

  /// The response body as a string.
  final String body;

  /// The response body as bytes.
  final List<int> bodyBytes;

  /// The response headers.
  final Map<String, String> headers;

  /// The request URL.
  final String requestUrl;

  /// The request method.
  final String method;

  /// The time taken for the request in milliseconds.
  final int? requestDuration;

  /// Whether the request was from cache (if caching is enabled).
  final bool isFromCache;

  const ClientResponse({
    required this.statusCode,
    required this.body,
    required this.bodyBytes,
    required this.headers,
    required this.requestUrl,
    required this.method,
    this.requestDuration,
    this.isFromCache = false,
  });

  /// Returns true if the status code indicates success (2xx).
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// Returns true if the status code indicates a redirect (3xx).
  bool get isRedirect => statusCode >= 300 && statusCode < 400;

  /// Returns true if the status code indicates a client error (4xx).
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// Returns true if the status code indicates a server error (5xx).
  bool get isServerError => statusCode >= 500;

  /// Parses the response body as JSON and returns a Map.
  Map<String, dynamic>? get jsonBody {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Parses the response body as a JSON list.
  List<dynamic>? get jsonListBody {
    try {
      return jsonDecode(body) as List<dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Parses the response body as JSON and converts it using the provided function.
  T? parseJson<T>(T Function(Map<String, dynamic> json) fromJson) {
    final json = jsonBody;
    if (json == null) return null;
    try {
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Parses the response body as a JSON list and converts each item.
  List<T>? parseJsonList<T>(T Function(Map<String, dynamic> json) fromJson) {
    final list = jsonListBody;
    if (list == null) return null;
    try {
      return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  /// Creates a copy of this response with optional modifications.
  ClientResponse copyWith({
    int? statusCode,
    String? body,
    List<int>? bodyBytes,
    Map<String, String>? headers,
    String? requestUrl,
    String? method,
    int? requestDuration,
    bool? isFromCache,
  }) {
    return ClientResponse(
      statusCode: statusCode ?? this.statusCode,
      body: body ?? this.body,
      bodyBytes: bodyBytes ?? this.bodyBytes,
      headers: headers ?? this.headers,
      requestUrl: requestUrl ?? this.requestUrl,
      method: method ?? this.method,
      requestDuration: requestDuration ?? this.requestDuration,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  String toString() {
    return 'ClientResponse(statusCode: $statusCode, method: $method, url: $requestUrl, '
        'duration: ${requestDuration}ms, fromCache: $isFromCache)';
  }
}
