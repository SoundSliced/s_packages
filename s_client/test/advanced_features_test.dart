import 'package:flutter_test/flutter_test.dart';
import 'package:s_client/s_client.dart';

void main() {
  group('ClientConfig Advanced Options', () {
    test('ClientConfig retry configuration', () {
      const config = ClientConfig(
        maxRetries: 5,
        retryDelay: Duration(seconds: 2),
        exponentialBackoff: true,
        retryStatusCodes: {500, 502, 503},
      );

      expect(config.maxRetries, equals(5));
      expect(config.retryDelay, equals(const Duration(seconds: 2)));
      expect(config.exponentialBackoff, isTrue);
      expect(config.retryStatusCodes, contains(500));
      expect(config.retryStatusCodes, contains(502));
      expect(config.retryStatusCodes, contains(503));
    });

    test('ClientConfig custom success/error codes', () {
      const config = ClientConfig(
        successCodes: {200, 201, 204},
        errorCodes: {400, 401, 403, 404, 500},
      );

      expect(config.successCodes, contains(200));
      expect(config.successCodes, contains(204));
      expect(config.errorCodes, contains(401));
      expect(config.errorCodes, contains(500));
    });

    test('ClientConfig default headers', () {
      const config = ClientConfig(
        defaultHeaders: {
          'Accept': 'application/json',
          'X-Custom-Header': 'value',
        },
      );

      expect(config.defaultHeaders['Accept'], equals('application/json'));
      expect(config.defaultHeaders['X-Custom-Header'], equals('value'));
    });

    test('ClientConfig redirect settings', () {
      const config = ClientConfig(
        followRedirects: true,
        maxRedirects: 10,
      );

      expect(config.followRedirects, isTrue);
      expect(config.maxRedirects, equals(10));
    });

    test('ClientConfig certificate validation', () {
      const config = ClientConfig(
        validateCertificates: false,
      );

      expect(config.validateCertificates, isFalse);
    });

    test('ClientConfig logging enabled', () {
      // Just verify the config accepts enableLogging
      const config = ClientConfig(
        enableLogging: true,
      );

      expect(config.enableLogging, isTrue);
    });

    test('ClientConfig all timeout types', () {
      const config = ClientConfig(
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 20),
        sendTimeout: Duration(seconds: 15),
      );

      expect(config.connectTimeout, equals(const Duration(seconds: 10)));
      expect(config.receiveTimeout, equals(const Duration(seconds: 20)));
      expect(config.sendTimeout, equals(const Duration(seconds: 15)));
    });

    test('defaultJsonHeaders constant', () {
      expect(defaultJsonHeaders['Accept'], equals('application/json'));
      expect(defaultJsonHeaders['Content-Type'], equals('application/json'));
    });

    test('defaultSuccessCodes includes all 2xx codes', () {
      expect(defaultSuccessCodes, contains(200));
      expect(defaultSuccessCodes, contains(201));
      expect(defaultSuccessCodes, contains(204));
    });

    test('defaultErrorCodes includes 4xx and 5xx codes', () {
      expect(defaultErrorCodes, contains(400));
      expect(defaultErrorCodes, contains(401));
      expect(defaultErrorCodes, contains(404));
      expect(defaultErrorCodes, contains(500));
      expect(defaultErrorCodes, contains(503));
    });
  });

  group('ClientResponse Advanced', () {
    test('isRedirect returns true for 3xx status codes', () {
      const response = ClientResponse(
        statusCode: 301,
        body: '',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/test',
        method: 'GET',
      );

      expect(response.isRedirect, isTrue);
      expect(response.isSuccess, isFalse);
    });

    test('requestDuration is tracked', () {
      const response = ClientResponse(
        statusCode: 200,
        body: '{}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/test',
        method: 'GET',
        requestDuration: 150,
      );

      expect(response.requestDuration, equals(150));
    });

    test('isFromCache flag', () {
      const cachedResponse = ClientResponse(
        statusCode: 200,
        body: '{}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/test',
        method: 'GET',
        isFromCache: true,
      );

      expect(cachedResponse.isFromCache, isTrue);
    });

    test('toString provides readable format', () {
      const response = ClientResponse(
        statusCode: 200,
        body: '{}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/test',
        method: 'GET',
        requestDuration: 100,
      );

      final str = response.toString();
      expect(str, contains('200'));
      expect(str, contains('GET'));
      expect(str, contains('api.example.com'));
    });
  });

  group('ClientException Advanced', () {
    test('ClientException with responseBody', () {
      const exception = ClientException(
        type: ClientErrorType.badResponse,
        message: 'Bad request',
        url: 'https://api.example.com/test',
        statusCode: 400,
        responseBody: '{"error": "validation failed"}',
      );

      expect(exception.responseBody, contains('validation failed'));
    });

    test('ClientException with originalError', () {
      final originalError = Exception('Socket error');
      final exception = ClientException(
        type: ClientErrorType.connectionError,
        message: 'Network error',
        originalError: originalError,
      );

      expect(exception.originalError, equals(originalError));
    });

    test('All ClientErrorType values', () {
      expect(ClientErrorType.values.length, greaterThanOrEqualTo(5));
      expect(ClientErrorType.values, contains(ClientErrorType.connectionError));
      expect(
          ClientErrorType.values, contains(ClientErrorType.connectionTimeout));
      expect(ClientErrorType.values, contains(ClientErrorType.cancelled));
      expect(ClientErrorType.values, contains(ClientErrorType.badResponse));
      expect(ClientErrorType.values, contains(ClientErrorType.unknown));
    });

    test('isTimeout returns true for timeout errors', () {
      const connectTimeoutException = ClientException(
        type: ClientErrorType.connectionTimeout,
        message: 'Connection timeout',
      );

      const sendTimeoutException = ClientException(
        type: ClientErrorType.sendTimeout,
        message: 'Send timeout',
      );

      const receiveTimeoutException = ClientException(
        type: ClientErrorType.receiveTimeout,
        message: 'Receive timeout',
      );

      expect(connectTimeoutException.isTimeout, isTrue);
      expect(sendTimeoutException.isTimeout, isTrue);
      expect(receiveTimeoutException.isTimeout, isTrue);
    });

    test('isConnectionError returns true for connection errors', () {
      const exception = ClientException(
        type: ClientErrorType.connectionError,
        message: 'No internet',
      );

      expect(exception.isConnectionError, isTrue);
    });

    test('isCancelled returns true for cancelled requests', () {
      const exception = ClientException(
        type: ClientErrorType.cancelled,
        message: 'Request cancelled',
      );

      expect(exception.isCancelled, isTrue);
    });

    test('toString provides readable format', () {
      const exception = ClientException(
        type: ClientErrorType.badResponse,
        message: 'Not found',
        url: 'https://api.example.com/test',
        statusCode: 404,
      );

      final str = exception.toString();
      expect(str, contains('Not found'));
      expect(str, contains('404'));
      expect(str, contains('badResponse'));
    });
  });

  group('AuthInterceptor Advanced', () {
    test('AuthInterceptor with Basic auth', () async {
      final interceptor = AuthInterceptor(
        authType: AuthType.basic,
        username: 'user',
        password: 'pass',
      );

      final request = ClientRequest(
        url: 'https://api.example.com/data',
        method: 'GET',
      );

      final result = await interceptor.onRequest(request);

      expect(result, isNotNull);
      expect(result!.headers['Authorization'], isNotNull);
      expect(result.headers['Authorization'], startsWith('Basic'));
    });

    test('AuthInterceptor with custom headers provider', () async {
      final interceptor = AuthInterceptor(
        authType: AuthType.custom,
        customHeadersProvider: () => {
          'X-Custom-Auth': 'custom-value',
          'X-Request-ID': 'req-123',
        },
      );

      final request = ClientRequest(
        url: 'https://api.example.com/data',
        method: 'GET',
      );

      final result = await interceptor.onRequest(request);

      expect(result, isNotNull);
      expect(result!.headers['X-Custom-Auth'], equals('custom-value'));
      expect(result.headers['X-Request-ID'], equals('req-123'));
    });

    test('AuthInterceptor onUnauthorized callback', () async {
      bool refreshCalled = false;

      final interceptor = AuthInterceptor(
        authType: AuthType.bearer,
        tokenProvider: () => 'token',
        onUnauthorized: () async {
          refreshCalled = true;
          return true;
        },
      );

      final request = ClientRequest(
        url: 'https://api.example.com/data',
        method: 'GET',
      );

      // Simulate error with attemptCount = 1 to trigger onUnauthorized
      final shouldRetry = await interceptor.onError(
        request,
        const ClientException(
          type: ClientErrorType.badResponse,
          message: 'Unauthorized',
          statusCode: 401,
        ),
        1,
      );

      expect(refreshCalled, isTrue);
      expect(shouldRetry, isTrue);
    });

    test('AuthInterceptor excludes specific endpoints', () async {
      final interceptor = AuthInterceptor(
        authType: AuthType.bearer,
        tokenProvider: () => 'my-token',
        excludedEndpoints: ['/public/', '/login'],
      );

      // Request to excluded endpoint
      final publicRequest = ClientRequest(
        url: 'https://api.example.com/public/data',
        method: 'GET',
      );

      final publicResult = await interceptor.onRequest(publicRequest);
      expect(publicResult!.headers['Authorization'], isNull);

      // Request to protected endpoint
      final protectedRequest = ClientRequest(
        url: 'https://api.example.com/protected/data',
        method: 'GET',
      );

      final protectedResult = await interceptor.onRequest(protectedRequest);
      expect(protectedResult!.headers['Authorization'], isNotNull);
      expect(
          protectedResult.headers['Authorization'], equals('Bearer my-token'));
    });

    test('AuthInterceptor with API key', () async {
      final interceptor = AuthInterceptor(
        authType: AuthType.apiKey,
        tokenProvider: () => 'api-key-123',
        apiKeyHeaderName: 'X-API-Key',
      );

      final request = ClientRequest(
        url: 'https://api.example.com/data',
        method: 'GET',
      );

      final result = await interceptor.onRequest(request);

      expect(result, isNotNull);
      expect(result!.headers['X-API-Key'], equals('api-key-123'));
    });

    test('AuthInterceptor with custom API key header name', () async {
      final interceptor = AuthInterceptor(
        authType: AuthType.apiKey,
        tokenProvider: () => 'secret-key',
        apiKeyHeaderName: 'X-Secret-Token',
      );

      final request = ClientRequest(
        url: 'https://api.example.com/data',
        method: 'GET',
      );

      final result = await interceptor.onRequest(request);

      expect(result, isNotNull);
      expect(result!.headers['X-Secret-Token'], equals('secret-key'));
    });
  });

  group('CacheInterceptor Advanced', () {
    test('CacheInterceptor excludes patterns', () async {
      final interceptor = CacheInterceptor(
        excludePatterns: [
          RegExp(r'/auth/'),
          RegExp(r'/realtime/'),
        ],
      );

      final authRequest = ClientRequest(
        url: 'https://api.example.com/auth/login',
        method: 'GET',
      );

      const response = ClientResponse(
        statusCode: 200,
        body: '{}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/auth/login',
        method: 'GET',
      );

      await interceptor.onRequest(authRequest);
      await interceptor.onResponse(authRequest, response);

      // Auth endpoint should not be cached
      expect(interceptor.cacheSize, equals(0));
    });

    test('CacheInterceptor does not cache POST requests', () async {
      final interceptor = CacheInterceptor();

      final request = ClientRequest(
        url: 'https://api.example.com/data',
        method: 'POST',
        body: {'key': 'value'},
      );

      const response = ClientResponse(
        statusCode: 200,
        body: '{}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/data',
        method: 'POST',
      );

      await interceptor.onRequest(request);
      await interceptor.onResponse(request, response);

      expect(interceptor.cacheSize, equals(0));
    });

    test('CacheInterceptor removes expired entries', () async {
      final interceptor = CacheInterceptor(
        defaultMaxAge: const Duration(milliseconds: 50),
      );

      final request = ClientRequest(
        url: 'https://api.example.com/data',
        method: 'GET',
      );

      const response = ClientResponse(
        statusCode: 200,
        body: '{}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/data',
        method: 'GET',
      );

      await interceptor.onRequest(request);
      await interceptor.onResponse(request, response);
      expect(interceptor.cacheSize, equals(1));

      // Wait for cache to expire
      await Future.delayed(const Duration(milliseconds: 100));

      interceptor.removeExpired();
      expect(interceptor.cacheSize, equals(0));
    });

    test('CacheInterceptor custom cacheMaxAge per request', () async {
      final interceptor = CacheInterceptor(
        defaultMaxAge: const Duration(minutes: 5),
      );

      final request = ClientRequest(
        url: 'https://api.example.com/data',
        method: 'GET',
        extra: {'cacheMaxAge': const Duration(hours: 1)},
      );

      const response = ClientResponse(
        statusCode: 200,
        body: '{}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/data',
        method: 'GET',
      );

      await interceptor.onRequest(request);
      await interceptor.onResponse(request, response);

      // Cache should have the entry
      expect(interceptor.cacheSize, equals(1));
    });

    test('CacheInterceptor cacheOnlySuccess true skips error responses',
        () async {
      final interceptor = CacheInterceptor(
        cacheOnlySuccess: true,
      );

      final request = ClientRequest(
        url: 'https://api.example.com/data',
        method: 'GET',
      );

      const errorResponse = ClientResponse(
        statusCode: 500,
        body: '{"error": "server error"}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/data',
        method: 'GET',
      );

      await interceptor.onRequest(request);
      await interceptor.onResponse(request, errorResponse);

      expect(interceptor.cacheSize, equals(0));
    });

    test('CacheInterceptor cacheOnlySuccess false caches errors', () async {
      final interceptor = CacheInterceptor(
        cacheOnlySuccess: false,
      );

      final request = ClientRequest(
        url: 'https://api.example.com/data',
        method: 'GET',
      );

      const errorResponse = ClientResponse(
        statusCode: 500,
        body: '{"error": "server error"}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/data',
        method: 'GET',
      );

      await interceptor.onRequest(request);
      await interceptor.onResponse(request, errorResponse);

      expect(interceptor.cacheSize, equals(1));
    });
  });

  group('ClientInterceptor Base', () {
    test('Custom interceptor can modify request', () async {
      final interceptor = _CustomHeaderInterceptor('X-Test', 'test-value');

      final request = ClientRequest(
        url: 'https://api.example.com/data',
        method: 'GET',
      );

      final result = await interceptor.onRequest(request);

      expect(result!.headers['X-Test'], equals('test-value'));
    });

    test('Custom interceptor can modify response', () async {
      final interceptor = _ResponseModifyingInterceptor();

      final request = ClientRequest(
        url: 'https://api.example.com/data',
        method: 'GET',
      );

      const response = ClientResponse(
        statusCode: 200,
        body: '{}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/data',
        method: 'GET',
      );

      final result = await interceptor.onResponse(request, response);

      expect(result.headers['X-Modified'], equals('true'));
    });
  });

  group('ClientRequest Advanced', () {
    test('ClientRequest toString provides readable format', () {
      final request = ClientRequest(
        url: 'https://api.example.com/test',
        method: 'POST',
      );

      final str = request.toString();
      expect(str, contains('POST'));
      expect(str, contains('api.example.com'));
    });

    test('ClientRequest with all fields', () {
      final request = ClientRequest(
        url: 'https://api.example.com/test',
        method: 'POST',
        headers: {'Authorization': 'Bearer token'},
        body: {'data': 'value'},
        queryParameters: {'page': '1', 'limit': '10'},
        extra: {'cancelKey': 'request-1'},
      );

      expect(request.url, isNotEmpty);
      expect(request.method, equals('POST'));
      expect(request.headers['Authorization'], isNotNull);
      expect(request.body['data'], equals('value'));
      expect(request.queryParameters!['page'], equals('1'));
      expect(request.extra['cancelKey'], equals('request-1'));
    });
  });
}

/// Custom interceptor that adds a header
class _CustomHeaderInterceptor extends ClientInterceptor {
  final String headerName;
  final String headerValue;

  _CustomHeaderInterceptor(this.headerName, this.headerValue);

  @override
  Future<ClientRequest?> onRequest(ClientRequest request) async {
    final headers = Map<String, String>.from(request.headers);
    headers[headerName] = headerValue;
    return request.copyWith(headers: headers);
  }
}

/// Custom interceptor that modifies response
class _ResponseModifyingInterceptor extends ClientInterceptor {
  @override
  Future<ClientResponse> onResponse(
    ClientRequest request,
    ClientResponse response,
  ) async {
    final headers = Map<String, String>.from(response.headers);
    headers['X-Modified'] = 'true';
    return response.copyWith(headers: headers);
  }
}
