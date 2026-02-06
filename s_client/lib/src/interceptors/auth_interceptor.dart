import 'client_interceptor.dart';
import '../models/client_response.dart';

/// Type of authentication to use.
enum AuthType {
  /// Bearer token authentication
  bearer,

  /// Basic authentication (username:password base64 encoded)
  basic,

  /// API key authentication
  apiKey,

  /// Custom authentication
  custom,
}

/// An interceptor that adds authentication headers to requests.
class AuthInterceptor extends ClientInterceptor {
  /// The type of authentication.
  final AuthType authType;

  /// The authentication token (for bearer/apiKey).
  final String? Function()? tokenProvider;

  /// The username (for basic auth).
  final String? username;

  /// The password (for basic auth).
  final String? password;

  /// The API key header name (for apiKey auth).
  final String apiKeyHeaderName;

  /// Custom header name and value provider.
  final Map<String, String> Function()? customHeadersProvider;

  /// Callback when a 401 response is received.
  /// Return true to retry the request after refreshing the token.
  final Future<bool> Function()? onUnauthorized;

  /// Endpoints to exclude from authentication.
  final List<String> excludedEndpoints;

  AuthInterceptor({
    this.authType = AuthType.bearer,
    this.tokenProvider,
    this.username,
    this.password,
    this.apiKeyHeaderName = 'X-API-Key',
    this.customHeadersProvider,
    this.onUnauthorized,
    this.excludedEndpoints = const [],
  });

  bool _isExcluded(String url) {
    for (final endpoint in excludedEndpoints) {
      if (url.contains(endpoint)) return true;
    }
    return false;
  }

  @override
  Future<ClientRequest?> onRequest(ClientRequest request) async {
    if (_isExcluded(request.url)) {
      return request;
    }

    final headers = Map<String, String>.from(request.headers);

    switch (authType) {
      case AuthType.bearer:
        final token = tokenProvider?.call();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
        break;

      case AuthType.basic:
        if (username != null && password != null) {
          final credentials = Uri.encodeComponent('$username:$password');
          final encoded = Uri.encodeFull(credentials);
          headers['Authorization'] = 'Basic $encoded';
        }
        break;

      case AuthType.apiKey:
        final token = tokenProvider?.call();
        if (token != null && token.isNotEmpty) {
          headers[apiKeyHeaderName] = token;
        }
        break;

      case AuthType.custom:
        final customHeaders = customHeadersProvider?.call();
        if (customHeaders != null) {
          headers.addAll(customHeaders);
        }
        break;
    }

    return request.copyWith(headers: headers);
  }

  @override
  Future<ClientResponse> onResponse(
    ClientRequest request,
    ClientResponse response,
  ) async {
    return response;
  }

  @override
  Future<bool> onError(
    ClientRequest request,
    Object error,
    int attemptCount,
  ) async {
    // Check if it's a 401 error and we have an unauthorized handler
    if (onUnauthorized != null && attemptCount == 1) {
      // Only try once
      return await onUnauthorized!();
    }
    return false;
  }
}
