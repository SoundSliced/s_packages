import 'package:flutter_test/flutter_test.dart';
import 'package:s_client/s_client.dart';

void main() {
  group('LoggingInterceptor', () {
    test('LoggingInterceptor has configurable options', () {
      final interceptor = LoggingInterceptor(
        logRequest: true,
        logRequestHeaders: true,
        logRequestBody: true,
        logResponse: true,
        logResponseHeaders: false,
        logResponseBody: true,
        maxBodyLength: 500,
        prettyPrintJson: true,
      );

      expect(interceptor.logRequest, isTrue);
      expect(interceptor.logRequestHeaders, isTrue);
      expect(interceptor.logResponseHeaders, isFalse);
      expect(interceptor.maxBodyLength, equals(500));
    });

    test('LoggingInterceptor with custom logger captures logs', () async {
      final logs = <String>[];
      final interceptor = LoggingInterceptor(
        logger: (message) => logs.add(message),
      );

      final request = ClientRequest(
        url: 'https://api.example.com/test',
        method: 'GET',
      );

      await interceptor.onRequest(request);

      expect(logs, isNotEmpty);
      expect(logs.first, contains('GET'));
      expect(logs.first, contains('api.example.com'));
    });

    test('LoggingInterceptor passes request through unchanged', () async {
      final interceptor = LoggingInterceptor(
        logger: (_) {}, // Suppress output
      );

      final request = ClientRequest(
        url: 'https://api.example.com/test',
        method: 'POST',
        body: {'key': 'value'},
      );

      final result = await interceptor.onRequest(request);

      expect(result, isNotNull);
      expect(result!.url, equals(request.url));
      expect(result.method, equals(request.method));
      expect(result.body, equals(request.body));
    });

    test('LoggingInterceptor logs response details', () async {
      final logs = <String>[];
      final interceptor = LoggingInterceptor(
        logger: (message) => logs.add(message),
      );

      final request = ClientRequest(
        url: 'https://api.example.com/test',
        method: 'GET',
      );

      const response = ClientResponse(
        statusCode: 200,
        body: '{"result": "success"}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/test',
        method: 'GET',
        requestDuration: 150,
      );

      await interceptor.onResponse(request, response);

      expect(logs, isNotEmpty);
      expect(logs.first, contains('200'));
    });
  });

  group('AuthInterceptor', () {
    test('AuthInterceptor adds Bearer token', () async {
      final interceptor = AuthInterceptor(
        authType: AuthType.bearer,
        tokenProvider: () => 'test-token-12345',
      );

      final request = ClientRequest(
        url: 'https://api.example.com/protected',
        method: 'GET',
      );

      final result = await interceptor.onRequest(request);

      expect(result, isNotNull);
      expect(
          result!.headers['Authorization'], equals('Bearer test-token-12345'));
    });

    test('AuthInterceptor adds API key header', () async {
      final interceptor = AuthInterceptor(
        authType: AuthType.apiKey,
        tokenProvider: () => 'my-api-key',
        apiKeyHeaderName: 'X-API-Key',
      );

      final request = ClientRequest(
        url: 'https://api.example.com/data',
        method: 'GET',
      );

      final result = await interceptor.onRequest(request);

      expect(result, isNotNull);
      expect(result!.headers['X-API-Key'], equals('my-api-key'));
    });

    test('AuthInterceptor excludes specified endpoints', () async {
      final interceptor = AuthInterceptor(
        authType: AuthType.bearer,
        tokenProvider: () => 'secret-token',
        excludedEndpoints: ['/login', '/register'],
      );

      final request = ClientRequest(
        url: 'https://api.example.com/login',
        method: 'POST',
      );

      final result = await interceptor.onRequest(request);

      expect(result, isNotNull);
      expect(result!.headers['Authorization'], isNull);
    });

    test('AuthInterceptor handles null token gracefully', () async {
      final interceptor = AuthInterceptor(
        authType: AuthType.bearer,
        tokenProvider: () => null,
      );

      final request = ClientRequest(
        url: 'https://api.example.com/data',
        method: 'GET',
      );

      final result = await interceptor.onRequest(request);

      expect(result, isNotNull);
      expect(result!.headers['Authorization'], isNull);
    });

    test('AuthType enum has all auth types', () {
      expect(AuthType.values, contains(AuthType.bearer));
      expect(AuthType.values, contains(AuthType.basic));
      expect(AuthType.values, contains(AuthType.apiKey));
      expect(AuthType.values, contains(AuthType.custom));
    });
  });

  group('CacheInterceptor', () {
    test('CacheInterceptor has configurable options', () {
      final interceptor = CacheInterceptor(
        defaultMaxAge: const Duration(minutes: 10),
        maxEntries: 50,
        cacheOnlySuccess: true,
        methodsToCache: {'GET', 'HEAD'},
      );

      expect(interceptor.defaultMaxAge, equals(const Duration(minutes: 10)));
      expect(interceptor.maxEntries, equals(50));
      expect(interceptor.cacheOnlySuccess, isTrue);
    });

    test('CacheInterceptor caches GET responses', () async {
      final interceptor = CacheInterceptor(
        defaultMaxAge: const Duration(minutes: 5),
      );

      final request = ClientRequest(
        url: 'https://api.example.com/data',
        method: 'GET',
      );

      const response = ClientResponse(
        statusCode: 200,
        body: '{"cached": true}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/data',
        method: 'GET',
      );

      // First request - should cache
      await interceptor.onRequest(request);
      await interceptor.onResponse(request, response);

      expect(interceptor.cacheSize, equals(1));
    });

    test('CacheInterceptor returns cached response', () async {
      final interceptor = CacheInterceptor(
        defaultMaxAge: const Duration(minutes: 5),
      );

      final request = ClientRequest(
        url: 'https://api.example.com/data',
        method: 'GET',
      );

      const response = ClientResponse(
        statusCode: 200,
        body: '{"cached": true}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/data',
        method: 'GET',
      );

      // Cache the response
      await interceptor.onRequest(request);
      await interceptor.onResponse(request, response);

      // Second request - should get cached
      final secondRequest = ClientRequest(
        url: 'https://api.example.com/data',
        method: 'GET',
      );
      final processedRequest = await interceptor.onRequest(secondRequest);

      expect(processedRequest!.extra['cachedResponse'], isNotNull);
    });

    test('CacheInterceptor clearCache removes all entries', () async {
      final interceptor = CacheInterceptor();

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

      interceptor.clearCache();
      expect(interceptor.cacheSize, equals(0));
    });

    test('CacheInterceptor respects noCache flag', () async {
      final interceptor = CacheInterceptor();

      final request = ClientRequest(
        url: 'https://api.example.com/data',
        method: 'GET',
        extra: {'noCache': true},
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

      expect(interceptor.cacheSize, equals(0));
    });

    test('CacheInterceptor invalidate removes matching entries', () async {
      final interceptor = CacheInterceptor();

      // Add multiple entries
      for (int i = 1; i <= 3; i++) {
        final request = ClientRequest(
          url: 'https://api.example.com/users/$i',
          method: 'GET',
        );

        final response = ClientResponse(
          statusCode: 200,
          body: '{"id": $i}',
          bodyBytes: const [],
          headers: const {},
          requestUrl: 'https://api.example.com/users/$i',
          method: 'GET',
        );

        await interceptor.onRequest(request);
        await interceptor.onResponse(request, response);
      }

      expect(interceptor.cacheSize, equals(3));

      // Invalidate user 2
      interceptor.invalidate('users/2');
      expect(interceptor.cacheSize, equals(2));
    });
  });

  group('Interceptor Chain', () {
    test('Multiple interceptors can be chained', () {
      final loggingInterceptor = LoggingInterceptor(logger: (_) {});
      final authInterceptor = AuthInterceptor(
        tokenProvider: () => 'token',
      );
      final cacheInterceptor = CacheInterceptor();

      SClient.configure(
        ClientConfig(
          interceptors: [
            loggingInterceptor,
            authInterceptor,
            cacheInterceptor,
          ],
        ),
      );

      expect(SClient.instance, isNotNull);
    });
  });
}
