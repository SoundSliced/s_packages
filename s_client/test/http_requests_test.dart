import 'package:flutter_test/flutter_test.dart';
import 'package:s_client/s_client.dart';

/// Tests for HTTP request/response behavior.
/// Note: These are placeholder tests that verify expected behavior patterns.
/// For full integration testing with mocked HTTP calls, run:
/// flutter pub run build_runner build
/// to generate the mock classes.
void main() {
  group('HTTP Request Configuration', () {
    test('GET request can be configured with headers', () {
      final client = SClient(
        config: const ClientConfig(
          defaultHeaders: {'X-Custom': 'value'},
        ),
      );

      expect(client.config.defaultHeaders['X-Custom'], equals('value'));
    });

    test('POST request can be configured with JSON headers', () {
      final client = SClient(
        config: ClientConfig(
          defaultHeaders: defaultJsonHeaders,
        ),
      );

      expect(client.config.defaultHeaders['Content-Type'],
          equals('application/json'));
    });

    test('Request timeout can be configured', () {
      final client = SClient(
        config: const ClientConfig(
          connectTimeout: Duration(seconds: 10),
          receiveTimeout: Duration(seconds: 20),
        ),
      );

      expect(client.config.connectTimeout, equals(const Duration(seconds: 10)));
      expect(client.config.receiveTimeout, equals(const Duration(seconds: 20)));
    });
  });

  group('Retry Logic Configuration', () {
    test('Retry is disabled by default', () {
      const config = ClientConfig();
      expect(config.maxRetries, equals(0));
    });

    test('Retry can be enabled with maxRetries', () {
      const config = ClientConfig(
        maxRetries: 3,
        retryDelay: Duration(seconds: 1),
      );

      expect(config.maxRetries, equals(3));
      expect(config.retryDelay, equals(const Duration(seconds: 1)));
    });

    test('Exponential backoff can be configured', () {
      const config = ClientConfig(
        maxRetries: 3,
        exponentialBackoff: true,
      );

      expect(config.exponentialBackoff, isTrue);
    });

    test('Retry status codes can be customized', () {
      const config = ClientConfig(
        maxRetries: 3,
        retryStatusCodes: {500, 502, 503, 504},
      );

      expect(config.retryStatusCodes, contains(500));
      expect(config.retryStatusCodes, contains(502));
    });
  });

  group('Callback-based API Configuration', () {
    test('Success codes can be customized', () {
      const config = ClientConfig(
        successCodes: {200, 201, 202, 204},
      );

      expect(config.successCodes, contains(200));
      expect(config.successCodes, contains(204));
    });

    test('Error codes can be customized', () {
      const config = ClientConfig(
        errorCodes: {400, 401, 403, 404, 500, 503},
      );

      expect(config.errorCodes, contains(400));
      expect(config.errorCodes, contains(500));
    });

    test('Default success codes include 2xx range', () {
      expect(defaultSuccessCodes, contains(200));
      expect(defaultSuccessCodes, contains(201));
      expect(defaultSuccessCodes, contains(204));
    });

    test('Default error codes include 4xx and 5xx', () {
      expect(defaultErrorCodes, contains(400));
      expect(defaultErrorCodes, contains(404));
      expect(defaultErrorCodes, contains(500));
      expect(defaultErrorCodes, contains(503));
    });
  });

  group('Response Handling', () {
    test('ClientResponse can parse JSON body', () {
      const response = ClientResponse(
        statusCode: 200,
        body: '{"name": "test", "value": 123}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com',
        method: 'GET',
      );

      final json = response.jsonBody;
      expect(json, isNotNull);
      expect(json!['name'], equals('test'));
      expect(json['value'], equals(123));
    });

    test('ClientResponse can parse JSON list', () {
      const response = ClientResponse(
        statusCode: 200,
        body: '[{"id": 1}, {"id": 2}]',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com',
        method: 'GET',
      );

      final list = response.jsonListBody;
      expect(list, isNotNull);
      expect(list!.length, equals(2));
    });

    test('ClientResponse handles invalid JSON gracefully', () {
      const response = ClientResponse(
        statusCode: 200,
        body: 'not json',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com',
        method: 'GET',
      );

      expect(response.jsonBody, isNull);
    });
  });

  group('Error Handling', () {
    test('ClientException includes error details', () {
      const exception = ClientException(
        type: ClientErrorType.badResponse,
        message: 'Server error',
        statusCode: 500,
        url: 'https://api.example.com',
        responseBody: '{"error": "Internal server error"}',
      );

      expect(exception.statusCode, equals(500));
      expect(exception.responseBody, contains('Internal server error'));
    });

    test('ClientException identifies timeout errors', () {
      const exception = ClientException(
        type: ClientErrorType.connectionTimeout,
        message: 'Connection timeout',
      );

      expect(exception.isTimeout, isTrue);
    });

    test('ClientException identifies connection errors', () {
      const exception = ClientException(
        type: ClientErrorType.connectionError,
        message: 'No internet',
      );

      expect(exception.isConnectionError, isTrue);
    });

    test('ClientException identifies cancelled requests', () {
      const exception = ClientException(
        type: ClientErrorType.cancelled,
        message: 'Request cancelled',
      );

      expect(exception.isCancelled, isTrue);
    });
  });

  group('Backend Selection', () {
    test('HTTP backend can be selected', () {
      final client = SClient(
        config: const ClientConfig(
          clientType: ClientType.http,
        ),
      );

      expect(client.config.clientType, equals(ClientType.http));
    });

    test('Dio backend can be selected', () {
      final client = SClient(
        config: const ClientConfig(
          clientType: ClientType.dio,
        ),
      );

      expect(client.config.clientType, equals(ClientType.dio));
    });
  });
}
