import 'package:flutter_test/flutter_test.dart';
import 'package:s_client/s_client.dart';

/// Tests for Client HTTP method signatures and configurations.
/// Note: These tests verify method configurations and behaviors
/// without making actual HTTP requests.
void main() {
  group('Client HTTP Methods Configuration', () {
    late SClient client;

    setUp(() {
      SClient.configure(
        const ClientConfig(
          baseUrl: 'https://api.example.com',
          connectTimeout: Duration(seconds: 30),
          receiveTimeout: Duration(seconds: 30),
        ),
      );
      client = SClient.instance;
    });

    group('GET Methods', () {
      test('Client has get method', () {
        expect(client.get, isA<Function>());
      });

      test('Client has getJson method', () {
        expect(client.getJson, isA<Function>());
      });

      test('Client has getJsonList method', () {
        expect(client.getJsonList, isA<Function>());
      });
    });

    group('POST Methods', () {
      test('Client has post method', () {
        expect(client.post, isA<Function>());
      });

      test('Client has postJson method', () {
        expect(client.postJson, isA<Function>());
      });
    });

    group('PUT Methods', () {
      test('Client has put method', () {
        expect(client.put, isA<Function>());
      });
    });

    group('PATCH Methods', () {
      test('Client has patch method', () {
        expect(client.patch, isA<Function>());
      });
    });

    group('DELETE Methods', () {
      test('Client has delete method', () {
        expect(client.delete, isA<Function>());
      });
    });

    group('HEAD Methods', () {
      test('Client has head method', () {
        expect(client.head, isA<Function>());
      });
    });

    group('File Operations', () {
      test('Client has download method', () {
        expect(client.download, isA<Function>());
      });

      test('Client has uploadFile method', () {
        expect(client.uploadFile, isA<Function>());
      });
    });

    group('Utility Methods', () {
      test('Client has isReachable method', () {
        expect(client.isReachable, isA<Function>());
      });

      test('Client has cancel method', () {
        expect(client.cancel, isA<Function>());
      });

      test('Client has cancelAll method', () {
        expect(client.cancelAll, isA<Function>());
      });

      test('Client has close method', () {
        expect(client.close, isA<Function>());
      });
    });
  });

  group('ClientType Backend Switching', () {
    test('Client can be configured with http backend', () {
      SClient.configure(
        const ClientConfig(
          clientType: ClientType.http,
        ),
      );

      expect(SClient.instance, isNotNull);
    });

    test('Client can be configured with dio backend', () {
      SClient.configure(
        const ClientConfig(
          clientType: ClientType.dio,
        ),
      );

      expect(SClient.instance, isNotNull);
    });

    test('Default backend is http', () {
      const config = ClientConfig();
      expect(config.clientType, equals(ClientType.http));
    });
  });

  group('Client Retry Configuration', () {
    test('Client accepts maxRetries', () {
      SClient.configure(
        const ClientConfig(
          maxRetries: 5,
        ),
      );

      expect(SClient.instance, isNotNull);
    });

    test('Client accepts retryDelay', () {
      SClient.configure(
        const ClientConfig(
          retryDelay: Duration(seconds: 2),
        ),
      );

      expect(SClient.instance, isNotNull);
    });

    test('Client accepts exponentialBackoff', () {
      SClient.configure(
        const ClientConfig(
          exponentialBackoff: true,
        ),
      );

      expect(SClient.instance, isNotNull);
    });

    test('Client accepts retryStatusCodes', () {
      SClient.configure(
        const ClientConfig(
          retryStatusCodes: {500, 502, 503, 504},
        ),
      );

      expect(SClient.instance, isNotNull);
    });
  });

  group('Client with Interceptors', () {
    test('Client accepts LoggingInterceptor', () {
      SClient.configure(
        ClientConfig(
          interceptors: [
            LoggingInterceptor(),
          ],
        ),
      );

      expect(SClient.instance, isNotNull);
    });

    test('Client accepts AuthInterceptor', () {
      SClient.configure(
        ClientConfig(
          interceptors: [
            AuthInterceptor(
              authType: AuthType.bearer,
              tokenProvider: () => 'token',
            ),
          ],
        ),
      );

      expect(SClient.instance, isNotNull);
    });

    test('Client accepts CacheInterceptor', () {
      SClient.configure(
        ClientConfig(
          interceptors: [
            CacheInterceptor(),
          ],
        ),
      );

      expect(SClient.instance, isNotNull);
    });

    test('Client accepts multiple interceptors', () {
      SClient.configure(
        ClientConfig(
          interceptors: [
            LoggingInterceptor(),
            AuthInterceptor(
              authType: AuthType.bearer,
              tokenProvider: () => 'token',
            ),
            CacheInterceptor(),
          ],
        ),
      );

      expect(SClient.instance, isNotNull);
    });

    test('Client accepts custom ClientInterceptor', () {
      SClient.configure(
        ClientConfig(
          interceptors: [
            _TestInterceptor(),
          ],
        ),
      );

      expect(SClient.instance, isNotNull);
    });
  });

  group('Client Request Cancellation', () {
    late SClient client;

    setUp(() {
      SClient.configure(const ClientConfig());
      client = SClient.instance;
    });

    test('cancel with specific key does not throw', () {
      expect(() => client.cancel('test-key'), returnsNormally);
    });

    test('cancelAll does not throw', () {
      expect(() => client.cancelAll(), returnsNormally);
    });

    test('close does not throw', () {
      // Create a new instance for close test
      final testClient = SClient(config: const ClientConfig());
      expect(() => testClient.close(), returnsNormally);
    });
  });

  group('LoggingInterceptor Options', () {
    test('LoggingInterceptor with all options', () {
      final interceptor = LoggingInterceptor(
        logRequest: true,
        logResponse: true,
        logRequestHeaders: true,
        logResponseHeaders: true,
        logRequestBody: true,
        logResponseBody: true,
        maxBodyLength: 1000,
        prettyPrintJson: true,
      );

      expect(interceptor, isNotNull);
    });

    test('LoggingInterceptor with custom logger', () {
      final logs = <String>[];

      final interceptor = LoggingInterceptor(
        logger: (message) {
          logs.add(message);
        },
      );

      expect(interceptor, isNotNull);
    });
  });

  group('CacheInterceptor Options', () {
    test('CacheInterceptor with custom maxAge', () {
      final interceptor = CacheInterceptor(
        defaultMaxAge: const Duration(hours: 1),
      );

      expect(interceptor.cacheSize, equals(0));
    });

    test('CacheInterceptor with maxEntries', () {
      final interceptor = CacheInterceptor(
        maxEntries: 50,
      );

      expect(interceptor, isNotNull);
    });

    test('CacheInterceptor clearCache works', () async {
      final interceptor = CacheInterceptor();

      // Add an entry to cache
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

      // Clear cache
      interceptor.clearCache();
      expect(interceptor.cacheSize, equals(0));
    });

    test('CacheInterceptor invalidate works', () async {
      final interceptor = CacheInterceptor();

      final request1 = ClientRequest(
        url: 'https://api.example.com/users/1',
        method: 'GET',
      );

      final request2 = ClientRequest(
        url: 'https://api.example.com/posts/1',
        method: 'GET',
      );

      const response = ClientResponse(
        statusCode: 200,
        body: '{}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/users/1',
        method: 'GET',
      );

      await interceptor.onRequest(request1);
      await interceptor.onResponse(request1, response);

      await interceptor.onRequest(request2);
      await interceptor.onResponse(
        request2,
        response.copyWith(requestUrl: 'https://api.example.com/posts/1'),
      );

      expect(interceptor.cacheSize, equals(2));

      // Invalidate only users endpoint
      interceptor.invalidate('users');
      expect(interceptor.cacheSize, equals(1));
    });
  });
}

/// A simple test interceptor
class _TestInterceptor extends ClientInterceptor {
  @override
  Future<ClientRequest?> onRequest(ClientRequest request) async {
    return request;
  }
}
