import 'package:flutter_test/flutter_test.dart';
import 'package:s_client/s_client.dart';

void main() {
  group('Client Configuration', () {
    setUp(() {
      // Reset client before each test
      SClient.configure(const ClientConfig());
    });

    test('Client.configure sets default configuration', () {
      SClient.configure(
        const ClientConfig(
          clientType: ClientType.http,
          baseUrl: 'https://api.example.com',
          connectTimeout: Duration(seconds: 30),
          receiveTimeout: Duration(seconds: 30),
        ),
      );

      expect(SClient.instance, isNotNull);
    });

    test('Client.instance returns singleton', () {
      final instance1 = SClient.instance;
      final instance2 = SClient.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('ClientConfig has sensible defaults', () {
      const config = ClientConfig();
      expect(config.clientType, equals(ClientType.http));
      expect(config.connectTimeout, equals(const Duration(seconds: 30)));
      expect(config.receiveTimeout, equals(const Duration(seconds: 30)));
      expect(config.maxRetries, equals(0)); // Default is 0 (no retry)
    });

    test('ClientConfig copyWith works correctly', () {
      const config = ClientConfig(
        clientType: ClientType.http,
        baseUrl: 'https://api.example.com',
      );

      final newConfig = config.copyWith(
        clientType: ClientType.dio,
        connectTimeout: const Duration(seconds: 60),
      );

      expect(newConfig.clientType, equals(ClientType.dio));
      expect(newConfig.baseUrl, equals('https://api.example.com'));
      expect(newConfig.connectTimeout, equals(const Duration(seconds: 60)));
    });
  });

  group('ClientResponse', () {
    test('isSuccess returns true for 2xx status codes', () {
      const response = ClientResponse(
        statusCode: 200,
        body: '{"data": "test"}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/test',
        method: 'GET',
      );

      expect(response.isSuccess, isTrue);
      expect(response.isClientError, isFalse);
      expect(response.isServerError, isFalse);
    });

    test('isClientError returns true for 4xx status codes', () {
      const response = ClientResponse(
        statusCode: 404,
        body: '{"error": "Not found"}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/test',
        method: 'GET',
      );

      expect(response.isSuccess, isFalse);
      expect(response.isClientError, isTrue);
      expect(response.isServerError, isFalse);
    });

    test('isServerError returns true for 5xx status codes', () {
      const response = ClientResponse(
        statusCode: 500,
        body: '{"error": "Internal server error"}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/test',
        method: 'GET',
      );

      expect(response.isSuccess, isFalse);
      expect(response.isClientError, isFalse);
      expect(response.isServerError, isTrue);
    });

    test('jsonBody parses valid JSON', () {
      const response = ClientResponse(
        statusCode: 200,
        body: '{"name": "John", "age": 30}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/test',
        method: 'GET',
      );

      final json = response.jsonBody;
      expect(json, isNotNull);
      expect(json!['name'], equals('John'));
      expect(json['age'], equals(30));
    });

    test('jsonBody returns null for invalid JSON', () {
      const response = ClientResponse(
        statusCode: 200,
        body: 'not valid json',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/test',
        method: 'GET',
      );

      expect(response.jsonBody, isNull);
    });

    test('jsonListBody parses valid JSON array', () {
      const response = ClientResponse(
        statusCode: 200,
        body: '[{"id": 1}, {"id": 2}, {"id": 3}]',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/test',
        method: 'GET',
      );

      final list = response.jsonListBody;
      expect(list, isNotNull);
      expect(list!.length, equals(3));
    });

    test('parseJson converts JSON to typed object', () {
      const response = ClientResponse(
        statusCode: 200,
        body: '{"id": 1, "title": "Test Post"}',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/test',
        method: 'GET',
      );

      final post = response.parseJson((json) => _TestPost.fromJson(json));
      expect(post, isNotNull);
      expect(post!.id, equals(1));
      expect(post.title, equals('Test Post'));
    });

    test('parseJsonList converts JSON array to typed list', () {
      const response = ClientResponse(
        statusCode: 200,
        body: '[{"id": 1, "title": "Post 1"}, {"id": 2, "title": "Post 2"}]',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/test',
        method: 'GET',
      );

      final posts = response.parseJsonList((json) => _TestPost.fromJson(json));
      expect(posts, isNotNull);
      expect(posts!.length, equals(2));
      expect(posts[0].title, equals('Post 1'));
      expect(posts[1].title, equals('Post 2'));
    });

    test('copyWith creates modified copy', () {
      const response = ClientResponse(
        statusCode: 200,
        body: 'original',
        bodyBytes: [],
        headers: {},
        requestUrl: 'https://api.example.com/test',
        method: 'GET',
        isFromCache: false,
      );

      final cached = response.copyWith(isFromCache: true);

      expect(cached.statusCode, equals(200));
      expect(cached.body, equals('original'));
      expect(cached.isFromCache, isTrue);
    });
  });

  group('ClientException', () {
    test('ClientException stores error details', () {
      const exception = ClientException(
        type: ClientErrorType.connectionError,
        message: 'Connection failed',
        url: 'https://api.example.com/test',
        statusCode: null,
      );

      expect(exception.type, equals(ClientErrorType.connectionError));
      expect(exception.message, equals('Connection failed'));
      expect(exception.url, equals('https://api.example.com/test'));
      expect(exception.statusCode, isNull);
    });

    test('ClientException toString returns formatted message', () {
      const exception = ClientException(
        type: ClientErrorType.connectionTimeout,
        message: 'Request timed out',
        url: 'https://api.example.com/test',
      );

      final str = exception.toString();
      expect(str, contains('ClientException'));
      expect(str, contains('connectionTimeout'));
    });

    test('ClientErrorType covers common error scenarios', () {
      expect(ClientErrorType.values, contains(ClientErrorType.connectionError));
      expect(
          ClientErrorType.values, contains(ClientErrorType.connectionTimeout));
      expect(ClientErrorType.values, contains(ClientErrorType.cancelled));
      expect(ClientErrorType.values, contains(ClientErrorType.badResponse));
      expect(ClientErrorType.values, contains(ClientErrorType.unknown));
    });
  });

  group('ClientRequest', () {
    test('ClientRequest stores request details', () {
      final request = ClientRequest(
        url: 'https://api.example.com/test',
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: {'key': 'value'},
        queryParameters: {'page': '1'},
      );

      expect(request.url, equals('https://api.example.com/test'));
      expect(request.method, equals('POST'));
      expect(request.headers['Content-Type'], equals('application/json'));
      expect(request.body, equals({'key': 'value'}));
      expect(request.queryParameters!['page'], equals('1'));
    });

    test('ClientRequest copyWith creates modified copy', () {
      final request = ClientRequest(
        url: 'https://api.example.com/test',
        method: 'GET',
      );

      final modified = request.copyWith(
        method: 'POST',
        headers: {'Authorization': 'Bearer token'},
      );

      expect(modified.url, equals('https://api.example.com/test'));
      expect(modified.method, equals('POST'));
      expect(modified.headers['Authorization'], equals('Bearer token'));
    });

    test('ClientRequest extra field stores custom data', () {
      final request = ClientRequest(
        url: 'https://api.example.com/test',
        method: 'GET',
        extra: {'customKey': 'customValue'},
      );

      expect(request.extra['customKey'], equals('customValue'));
    });
  });

  group('ClientType', () {
    test('ClientType has http and dio options', () {
      expect(ClientType.values, contains(ClientType.http));
      expect(ClientType.values, contains(ClientType.dio));
    });
  });
}

/// Test model for parseJson tests
class _TestPost {
  final int id;
  final String title;

  _TestPost({required this.id, required this.title});

  factory _TestPost.fromJson(Map<String, dynamic> json) {
    return _TestPost(
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }
}
