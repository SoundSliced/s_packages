import '../models/client_response.dart';

/// A request object that can be modified by interceptors.
class ClientRequest {
  /// The request URL.
  String url;

  /// The HTTP method.
  String method;

  /// The request headers.
  Map<String, String> headers;

  /// The request body (for POST, PUT, PATCH).
  dynamic body;

  /// Query parameters.
  Map<String, String>? queryParameters;

  /// Extra data that can be passed between interceptors.
  Map<String, dynamic> extra;

  ClientRequest({
    required this.url,
    required this.method,
    this.headers = const {},
    this.body,
    this.queryParameters,
    Map<String, dynamic>? extra,
  }) : extra = extra ?? {};

  /// Creates a copy of this request with optional modifications.
  ClientRequest copyWith({
    String? url,
    String? method,
    Map<String, String>? headers,
    dynamic body,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? extra,
  }) {
    return ClientRequest(
      url: url ?? this.url,
      method: method ?? this.method,
      headers: headers ?? Map.from(this.headers),
      body: body ?? this.body,
      queryParameters: queryParameters ?? this.queryParameters,
      extra: extra ?? Map.from(this.extra),
    );
  }

  @override
  String toString() {
    return 'ClientRequest(method: $method, url: $url)';
  }
}

/// Base class for interceptors that can modify requests and responses.
abstract class ClientInterceptor {
  /// Called before the request is sent.
  /// Return the modified request, or null to cancel the request.
  Future<ClientRequest?> onRequest(ClientRequest request) async => request;

  /// Called after the response is received.
  /// Return the modified response.
  Future<ClientResponse> onResponse(
    ClientRequest request,
    ClientResponse response,
  ) async =>
      response;

  /// Called when an error occurs.
  /// Return true to retry the request, false to propagate the error.
  Future<bool> onError(
    ClientRequest request,
    Object error,
    int attemptCount,
  ) async =>
      false;
}
