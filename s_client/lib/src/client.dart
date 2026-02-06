import 'dart:async';
import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import 'enums/client_type.dart';
import 'client_config.dart';
import 'interceptors/client_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'models/client_exception.dart';
import 'models/client_response.dart';

/// A result type for HTTP requests containing either a response or an error.
typedef ClientResult = (ClientResponse?, ClientException?);

/// A result type for parsed JSON responses.
typedef JsonResult<T> = (T?, Object?);

/// Callback for successful responses.
typedef OnSuccess = void Function(ClientResponse response);

/// Callback for successful responses with typed data.
typedef OnSuccessTyped<T> = void Function(T data, ClientResponse response);

/// Callback for error responses.
typedef OnError = void Function(ClientException error);

/// Callback for HTTP error responses (non-2xx that aren't exceptions).
typedef OnHttpError = void Function(int statusCode, ClientResponse response);

/// Callback for custom status code handling.
typedef OnStatus = void Function(int statusCode, ClientResponse response);

/// Callback for download/upload progress.
typedef OnProgress = void Function(int current, int total);

/// A powerful HTTP client supporting both http and dio backends.
///
/// Use [SClient.instance] for a singleton with default configuration,
/// or create a new instance with custom [ClientConfig].
class SClient {
  /// The configuration for this instance.
  final ClientConfig config;

  /// The Dio client instance (created lazily if needed).
  dio.Dio? _dioClient;

  /// The HTTP client instance (created lazily if needed).
  http.Client? _httpClient;

  /// Active interceptors including any added from config.
  late final List<ClientInterceptor> _interceptors;

  /// Cancellation tokens for request cancellation.
  final Map<String, dio.CancelToken> _cancelTokens = {};

  /// Private singleton instance.
  static SClient? _instance;

  /// Gets the singleton instance with default configuration.
  static SClient get instance {
    _instance ??= SClient();
    return _instance!;
  }

  /// Reconfigures the singleton instance.
  static void configure(ClientConfig config) {
    _instance = SClient(config: config);
  }

  /// Creates a new SClient instance with optional configuration.
  SClient({this.config = const ClientConfig()}) {
    _interceptors = [...config.interceptors];
    if (config.enableLogging) {
      _interceptors.insert(0, LoggingInterceptor());
    }
  }

  /// Gets or creates the Dio client.
  dio.Dio get _dio {
    _dioClient ??= dio.Dio(dio.BaseOptions(
      baseUrl: config.baseUrl ?? '',
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      // sendTimeout cannot be used without a request body on Web platform
      sendTimeout: kIsWeb ? null : config.sendTimeout,
      headers: config.defaultHeaders,
      followRedirects: config.followRedirects,
      maxRedirects: config.maxRedirects,
      validateStatus: (status) => true, // Don't throw on any status
    ));
    return _dioClient!;
  }

  /// Gets or creates the HTTP client.
  http.Client get _http {
    _httpClient ??= http.Client();
    return _httpClient!;
  }

  /// Builds the full URL with base URL if configured.
  String _buildUrl(String url) {
    if (config.baseUrl != null &&
        !url.startsWith('http://') &&
        !url.startsWith('https://')) {
      return '${config.baseUrl}$url';
    }
    return url;
  }

  /// Runs interceptors' onRequest handlers.
  Future<ClientRequest?> _runRequestInterceptors(ClientRequest request) async {
    ClientRequest? currentRequest = request;
    for (final interceptor in _interceptors) {
      if (currentRequest == null) return null;
      currentRequest = await interceptor.onRequest(currentRequest);
    }
    return currentRequest;
  }

  /// Runs interceptors' onResponse handlers.
  Future<ClientResponse> _runResponseInterceptors(
    ClientRequest request,
    ClientResponse response,
  ) async {
    ClientResponse currentResponse = response;
    for (final interceptor in _interceptors.reversed) {
      currentResponse = await interceptor.onResponse(request, currentResponse);
    }
    return currentResponse;
  }

  /// Runs interceptors' onError handlers.
  Future<bool> _runErrorInterceptors(
    ClientRequest request,
    Object error,
    int attemptCount,
  ) async {
    for (final interceptor in _interceptors) {
      if (await interceptor.onError(request, error, attemptCount)) {
        return true; // Retry requested
      }
    }
    return false;
  }

  /// Converts http.Response to ClientResponse.
  ClientResponse _httpToResponse(
    http.Response response,
    String method,
    int? duration,
  ) {
    return ClientResponse(
      statusCode: response.statusCode,
      body: response.body,
      bodyBytes: response.bodyBytes,
      headers: response.headers,
      requestUrl: response.request?.url.toString() ?? '',
      method: method,
      requestDuration: duration,
    );
  }

  /// Converts dio.Response to ClientResponse.
  ClientResponse _dioToResponse(
    dio.Response response,
    String method,
    int? duration,
  ) {
    final body = response.data is String
        ? response.data as String
        : response.data != null
            ? jsonEncode(response.data)
            : '';

    return ClientResponse(
      statusCode: response.statusCode ?? 0,
      body: body,
      bodyBytes: utf8.encode(body),
      headers: response.headers.map.map((k, v) => MapEntry(k, v.join(', '))),
      requestUrl: response.requestOptions.uri.toString(),
      method: method,
      requestDuration: duration,
    );
  }

  /// Converts exceptions to ClientException.
  ClientException _toException(Object error, String url) {
    if (error is dio.DioException) {
      ClientErrorType type;
      switch (error.type) {
        case dio.DioExceptionType.connectionTimeout:
          type = ClientErrorType.connectionTimeout;
          break;
        case dio.DioExceptionType.sendTimeout:
          type = ClientErrorType.sendTimeout;
          break;
        case dio.DioExceptionType.receiveTimeout:
          type = ClientErrorType.receiveTimeout;
          break;
        case dio.DioExceptionType.cancel:
          type = ClientErrorType.cancelled;
          break;
        case dio.DioExceptionType.badResponse:
          type = ClientErrorType.badResponse;
          break;
        case dio.DioExceptionType.connectionError:
          type = ClientErrorType.connectionError;
          break;
        case dio.DioExceptionType.badCertificate:
          type = ClientErrorType.badCertificate;
          break;
        default:
          type = ClientErrorType.unknown;
      }

      return ClientException(
        message: error.message ?? 'Unknown Dio error',
        url: url,
        statusCode: error.response?.statusCode,
        type: type,
        originalError: error,
        responseBody: error.response?.data?.toString(),
      );
    }

    if (error is http.ClientException) {
      return ClientException(
        message: error.message,
        url: url,
        type: ClientErrorType.connectionError,
        originalError: error,
      );
    }

    if (error is TimeoutException) {
      return ClientException(
        message: 'Request timed out',
        url: url,
        type: ClientErrorType.connectionTimeout,
        originalError: error,
      );
    }

    return ClientException(
      message: error.toString(),
      url: url,
      type: ClientErrorType.unknown,
      originalError: error,
    );
  }

  /// Executes a request with retry logic.
  Future<ClientResult> _executeWithRetry({
    required ClientRequest request,
    required Future<ClientResult> Function() execute,
  }) async {
    int attempts = 0;
    Duration delay = config.retryDelay;

    while (true) {
      attempts++;
      final result = await execute();
      final (response, error) = result;

      // Check if we should retry
      bool shouldRetry = false;

      if (error != null && attempts <= config.maxRetries) {
        shouldRetry = await _runErrorInterceptors(request, error, attempts);
      } else if (response != null &&
          config.retryStatusCodes.contains(response.statusCode) &&
          attempts <= config.maxRetries) {
        shouldRetry = true;
      }

      if (!shouldRetry || attempts > config.maxRetries) {
        return result;
      }

      // Wait before retrying
      await Future.delayed(delay);
      if (config.exponentialBackoff) {
        delay *= 2;
      }
    }
  }

  /// Handles the response with callbacks.
  void _handleCallbacks({
    required ClientResponse? response,
    required ClientException? error,
    OnSuccess? onSuccess,
    OnError? onError,
    OnHttpError? onHttpError,
    Map<int, OnStatus>? onStatus,
    Set<int>? successCodes,
    Set<int>? errorCodes,
  }) {
    final effectiveSuccessCodes = successCodes ?? config.successCodes;
    final effectiveErrorCodes = errorCodes ?? config.errorCodes;

    if (error != null) {
      onError?.call(error);
      return;
    }

    if (response == null) {
      onError?.call(const ClientException(
        message: 'No response received',
        type: ClientErrorType.unknown,
      ));
      return;
    }

    // Check for custom status handler first
    if (onStatus != null && onStatus.containsKey(response.statusCode)) {
      onStatus[response.statusCode]!(response.statusCode, response);
      return;
    }

    // Check if it's a success status
    if (effectiveSuccessCodes.contains(response.statusCode)) {
      onSuccess?.call(response);
      return;
    }

    // Check if it's an error status
    if (effectiveErrorCodes.contains(response.statusCode)) {
      if (onHttpError != null) {
        onHttpError(response.statusCode, response);
      } else {
        onError?.call(ClientException(
          message: 'HTTP error ${response.statusCode}',
          url: response.requestUrl,
          statusCode: response.statusCode,
          type: ClientErrorType.badResponse,
          responseBody: response.body,
        ));
      }
      return;
    }

    // Default: treat as success if 2xx-3xx, otherwise error
    if (response.statusCode >= 200 && response.statusCode < 400) {
      onSuccess?.call(response);
    } else {
      if (onHttpError != null) {
        onHttpError(response.statusCode, response);
      } else {
        onError?.call(ClientException(
          message: 'HTTP error ${response.statusCode}',
          url: response.requestUrl,
          statusCode: response.statusCode,
          type: ClientErrorType.badResponse,
          responseBody: response.body,
        ));
      }
    }
  }

  // ============================================================================
  // GET Methods
  // ============================================================================

  /// Performs a GET request and returns the result as a tuple.
  ///
  /// Optionally accepts callbacks for convenient response handling.
  /// When callbacks are provided, they are invoked based on the response
  /// status code, but the result tuple is still returned.
  ///
  /// Example with tuple only:
  /// ```dart
  /// final (response, error) = await client.get(url: '/users');
  /// if (error != null) {
  ///   print('Error: ${error.message}');
  /// } else {
  ///   print('Success: ${response!.body}');
  /// }
  /// ```
  ///
  /// Example with callbacks:
  /// ```dart
  /// await client.get(
  ///   url: 'https://api.example.com/users',
  ///   onSuccess: (response) => print('Got ${response.body}'),
  ///   onError: (error) => print('Error: ${error.message}'),
  ///   onHttpError: (code, response) => print('HTTP $code'),
  ///   successCodes: {200, 201},
  ///   onStatus: {
  ///     401: (code, response) => refreshToken(),
  ///     429: (code, response) => handleRateLimit(),
  ///   },
  ///
  /// ```
  Future<ClientResult> get({
    required String url,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Duration? timeout,
    ClientType? clientType,
    String? cancelKey,
    // Optional callbacks
    OnSuccess? onSuccess,
    OnError? onError,
    OnHttpError? onHttpError,
    Map<int, OnStatus>? onStatus,
    Set<int>? successCodes,
    Set<int>? errorCodes,
  }) async {
    final fullUrl = _buildUrl(url);
    final request = ClientRequest(
      url: fullUrl,
      method: 'GET',
      headers: {...config.defaultHeaders, ...?headers},
      queryParameters: queryParameters,
    );

    final processedRequest = await _runRequestInterceptors(request);
    if (processedRequest == null) {
      final result = (
        null,
        ClientException(
            message: 'Request cancelled by interceptor', url: fullUrl)
      );
      _handleCallbacks(
        response: result.$1,
        error: result.$2,
        onSuccess: onSuccess,
        onError: onError,
        onHttpError: onHttpError,
        onStatus: onStatus,
        successCodes: successCodes,
        errorCodes: errorCodes,
      );
      return result;
    }

    // Check for cached response
    final cachedResponse =
        processedRequest.extra['cachedResponse'] as ClientResponse?;
    if (cachedResponse != null) {
      final response =
          await _runResponseInterceptors(processedRequest, cachedResponse);
      final result = (response, null);
      _handleCallbacks(
        response: result.$1,
        error: result.$2,
        onSuccess: onSuccess,
        onError: onError,
        onHttpError: onHttpError,
        onStatus: onStatus,
        successCodes: successCodes,
        errorCodes: errorCodes,
      );
      return result;
    }

    final result = await _executeWithRetry(
      request: processedRequest,
      execute: () =>
          _performGet(processedRequest, timeout, clientType, cancelKey),
    );

    _handleCallbacks(
      response: result.$1,
      error: result.$2,
      onSuccess: onSuccess,
      onError: onError,
      onHttpError: onHttpError,
      onStatus: onStatus,
      successCodes: successCodes,
      errorCodes: errorCodes,
    );

    return result;
  }

  /// Performs a GET request with typed JSON response.
  ///
  /// Automatically parses the response body as JSON and deserializes it
  /// using the provided [fromJson] function.
  Future<ClientResult> getJson<T>({
    required String url,
    required T Function(Map<String, dynamic> json) fromJson,
    required OnSuccessTyped<T> onSuccess,
    required OnError onError,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Duration? timeout,
    ClientType? clientType,
    String? cancelKey,
    OnHttpError? onHttpError,
    Map<int, OnStatus>? onStatus,
    Set<int>? successCodes,
    Set<int>? errorCodes,
  }) async {
    return get(
      url: url,
      headers: headers,
      queryParameters: queryParameters,
      timeout: timeout,
      clientType: clientType,
      cancelKey: cancelKey,
      onSuccess: (response) {
        try {
          final json = response.jsonBody;
          if (json == null) {
            onError(ClientException(
              message: 'Invalid JSON response',
              url: url,
              type: ClientErrorType.badResponse,
              responseBody: response.body,
            ));
            return;
          }
          final data = fromJson(json);
          onSuccess(data, response);
        } catch (e) {
          onError(ClientException(
            message: 'Failed to parse JSON: $e',
            url: url,
            type: ClientErrorType.unknown,
            originalError: e,
          ));
        }
      },
      onError: onError,
      onHttpError: onHttpError,
      onStatus: onStatus,
      successCodes: successCodes,
      errorCodes: errorCodes,
    );
  }

  /// Performs a GET request with typed JSON list response.
  ///
  /// Automatically parses the response body as a JSON array and deserializes
  /// each item using the provided [fromJson] function.
  Future<ClientResult> getJsonList<T>({
    required String url,
    required T Function(Map<String, dynamic> json) fromJson,
    required OnSuccessTyped<List<T>> onSuccess,
    required OnError onError,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Duration? timeout,
    ClientType? clientType,
    String? cancelKey,
    OnHttpError? onHttpError,
    Map<int, OnStatus>? onStatus,
    Set<int>? successCodes,
    Set<int>? errorCodes,
  }) async {
    return get(
      url: url,
      headers: headers,
      queryParameters: queryParameters,
      timeout: timeout,
      clientType: clientType,
      cancelKey: cancelKey,
      onSuccess: (response) {
        try {
          final list = response.jsonListBody;
          if (list == null) {
            onError(ClientException(
              message: 'Invalid JSON array response',
              url: url,
              type: ClientErrorType.badResponse,
              responseBody: response.body,
            ));
            return;
          }
          final items =
              list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
          onSuccess(items, response);
        } catch (e) {
          onError(ClientException(
            message: 'Failed to parse JSON list: $e',
            url: url,
            type: ClientErrorType.unknown,
            originalError: e,
          ));
        }
      },
      onError: onError,
      onHttpError: onHttpError,
      onStatus: onStatus,
      successCodes: successCodes,
      errorCodes: errorCodes,
    );
  }

  Future<ClientResult> _performGet(
    ClientRequest request,
    Duration? timeout,
    ClientType? clientType,
    String? cancelKey,
  ) async {
    final useClient = clientType ?? config.clientType;
    final stopwatch = Stopwatch()..start();

    try {
      if (useClient == ClientType.dio) {
        dio.CancelToken? cancelToken;
        if (cancelKey != null) {
          cancelToken = dio.CancelToken();
          _cancelTokens[cancelKey] = cancelToken;
        }

        var uri = Uri.parse(request.url);
        if (request.queryParameters != null) {
          uri = uri.replace(queryParameters: {
            ...uri.queryParameters,
            ...request.queryParameters!,
          });
        }

        final response = await _dio.getUri(
          uri,
          options: dio.Options(
            headers: request.headers,
            receiveTimeout: timeout ?? config.receiveTimeout,
          ),
          cancelToken: cancelToken,
        );

        stopwatch.stop();
        if (cancelKey != null) _cancelTokens.remove(cancelKey);

        final httpResponse =
            _dioToResponse(response, 'GET', stopwatch.elapsedMilliseconds);
        final processedResponse =
            await _runResponseInterceptors(request, httpResponse);
        return (processedResponse, null);
      } else {
        var uri = Uri.parse(request.url);
        if (request.queryParameters != null) {
          uri = uri.replace(queryParameters: {
            ...uri.queryParameters,
            ...request.queryParameters!,
          });
        }

        final response = await _http
            .get(uri, headers: request.headers)
            .timeout(timeout ?? config.receiveTimeout);

        stopwatch.stop();

        final httpResponse =
            _httpToResponse(response, 'GET', stopwatch.elapsedMilliseconds);
        final processedResponse =
            await _runResponseInterceptors(request, httpResponse);
        return (processedResponse, null);
      }
    } catch (e) {
      stopwatch.stop();
      if (cancelKey != null) _cancelTokens.remove(cancelKey);
      return (null, _toException(e, request.url));
    }
  }

  // ============================================================================
  // POST Methods
  // ============================================================================

  /// Performs a POST request and returns the result as a tuple.
  ///
  /// Optionally accepts callbacks for convenient response handling.
  /// When callbacks are provided, they are invoked based on the response
  /// status code, but the result tuple is still returned.
  Future<ClientResult> post({
    required String url,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    Duration? timeout,
    ClientType? clientType,
    String? cancelKey,
    // Optional callbacks
    OnSuccess? onSuccess,
    OnError? onError,
    OnHttpError? onHttpError,
    Map<int, OnStatus>? onStatus,
    Set<int>? successCodes,
    Set<int>? errorCodes,
  }) async {
    final fullUrl = _buildUrl(url);
    final request = ClientRequest(
      url: fullUrl,
      method: 'POST',
      headers: {...config.defaultHeaders, ...?headers},
      body: body,
    );

    final processedRequest = await _runRequestInterceptors(request);
    if (processedRequest == null) {
      final result = (
        null,
        ClientException(
            message: 'Request cancelled by interceptor', url: fullUrl)
      );
      _handleCallbacks(
        response: result.$1,
        error: result.$2,
        onSuccess: onSuccess,
        onError: onError,
        onHttpError: onHttpError,
        onStatus: onStatus,
        successCodes: successCodes,
        errorCodes: errorCodes,
      );
      return result;
    }

    final result = await _executeWithRetry(
      request: processedRequest,
      execute: () =>
          _performPost(processedRequest, timeout, clientType, cancelKey),
    );

    _handleCallbacks(
      response: result.$1,
      error: result.$2,
      onSuccess: onSuccess,
      onError: onError,
      onHttpError: onHttpError,
      onStatus: onStatus,
      successCodes: successCodes,
      errorCodes: errorCodes,
    );

    return result;
  }

  /// Performs a POST request with typed JSON response.
  ///
  /// Automatically parses the response body as JSON and deserializes it
  /// using the provided [fromJson] function.
  Future<ClientResult> postJson<T>({
    required String url,
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic> json) fromJson,
    required OnSuccessTyped<T> onSuccess,
    required OnError onError,
    Map<String, String>? headers,
    Duration? timeout,
    ClientType? clientType,
    String? cancelKey,
    OnHttpError? onHttpError,
    Map<int, OnStatus>? onStatus,
    Set<int>? successCodes,
    Set<int>? errorCodes,
  }) async {
    return post(
      url: url,
      body: body,
      headers: headers,
      timeout: timeout,
      clientType: clientType,
      cancelKey: cancelKey,
      onSuccess: (response) {
        try {
          final json = response.jsonBody;
          if (json == null) {
            onError(ClientException(
              message: 'Invalid JSON response',
              url: url,
              type: ClientErrorType.badResponse,
              responseBody: response.body,
            ));
            return;
          }
          final data = fromJson(json);
          onSuccess(data, response);
        } catch (e) {
          onError(ClientException(
            message: 'Failed to parse JSON: $e',
            url: url,
            type: ClientErrorType.unknown,
            originalError: e,
          ));
        }
      },
      onError: onError,
      onHttpError: onHttpError,
      onStatus: onStatus,
      successCodes: successCodes,
      errorCodes: errorCodes,
    );
  }

  Future<ClientResult> _performPost(
    ClientRequest request,
    Duration? timeout,
    ClientType? clientType,
    String? cancelKey,
  ) async {
    final useClient = clientType ?? config.clientType;
    final stopwatch = Stopwatch()..start();

    try {
      if (useClient == ClientType.dio) {
        dio.CancelToken? cancelToken;
        if (cancelKey != null) {
          cancelToken = dio.CancelToken();
          _cancelTokens[cancelKey] = cancelToken;
        }

        final response = await _dio.post(
          request.url,
          data: request.body,
          options: dio.Options(
            headers: request.headers,
            receiveTimeout: timeout ?? config.receiveTimeout,
          ),
          cancelToken: cancelToken,
        );

        stopwatch.stop();
        if (cancelKey != null) _cancelTokens.remove(cancelKey);

        final httpResponse =
            _dioToResponse(response, 'POST', stopwatch.elapsedMilliseconds);
        final processedResponse =
            await _runResponseInterceptors(request, httpResponse);
        return (processedResponse, null);
      } else {
        final response = await _http
            .post(
              Uri.parse(request.url),
              headers: request.headers,
              body: jsonEncode(request.body),
            )
            .timeout(timeout ?? config.receiveTimeout);

        stopwatch.stop();

        final httpResponse =
            _httpToResponse(response, 'POST', stopwatch.elapsedMilliseconds);
        final processedResponse =
            await _runResponseInterceptors(request, httpResponse);
        return (processedResponse, null);
      }
    } catch (e) {
      stopwatch.stop();
      if (cancelKey != null) _cancelTokens.remove(cancelKey);
      return (null, _toException(e, request.url));
    }
  }

  // ============================================================================
  // PUT Methods
  // ============================================================================

  /// Performs a PUT request and returns the result as a tuple.
  ///
  /// Optionally accepts callbacks for convenient response handling.
  /// When callbacks are provided, they are invoked based on the response
  /// status code, but the result tuple is still returned.
  Future<ClientResult> put({
    required String url,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    Duration? timeout,
    ClientType? clientType,
    String? cancelKey,
    // Optional callbacks
    OnSuccess? onSuccess,
    OnError? onError,
    OnHttpError? onHttpError,
    Map<int, OnStatus>? onStatus,
    Set<int>? successCodes,
    Set<int>? errorCodes,
  }) async {
    final fullUrl = _buildUrl(url);
    final request = ClientRequest(
      url: fullUrl,
      method: 'PUT',
      headers: {...config.defaultHeaders, ...?headers},
      body: body,
    );

    final processedRequest = await _runRequestInterceptors(request);
    if (processedRequest == null) {
      final result = (
        null,
        ClientException(
            message: 'Request cancelled by interceptor', url: fullUrl)
      );
      _handleCallbacks(
        response: result.$1,
        error: result.$2,
        onSuccess: onSuccess,
        onError: onError,
        onHttpError: onHttpError,
        onStatus: onStatus,
        successCodes: successCodes,
        errorCodes: errorCodes,
      );
      return result;
    }

    final result = await _executeWithRetry(
      request: processedRequest,
      execute: () =>
          _performPut(processedRequest, timeout, clientType, cancelKey),
    );

    _handleCallbacks(
      response: result.$1,
      error: result.$2,
      onSuccess: onSuccess,
      onError: onError,
      onHttpError: onHttpError,
      onStatus: onStatus,
      successCodes: successCodes,
      errorCodes: errorCodes,
    );

    return result;
  }

  Future<ClientResult> _performPut(
    ClientRequest request,
    Duration? timeout,
    ClientType? clientType,
    String? cancelKey,
  ) async {
    final useClient = clientType ?? config.clientType;
    final stopwatch = Stopwatch()..start();

    try {
      if (useClient == ClientType.dio) {
        dio.CancelToken? cancelToken;
        if (cancelKey != null) {
          cancelToken = dio.CancelToken();
          _cancelTokens[cancelKey] = cancelToken;
        }

        final response = await _dio.put(
          request.url,
          data: request.body,
          options: dio.Options(
            headers: request.headers,
            receiveTimeout: timeout ?? config.receiveTimeout,
          ),
          cancelToken: cancelToken,
        );

        stopwatch.stop();
        if (cancelKey != null) _cancelTokens.remove(cancelKey);

        final httpResponse =
            _dioToResponse(response, 'PUT', stopwatch.elapsedMilliseconds);
        final processedResponse =
            await _runResponseInterceptors(request, httpResponse);
        return (processedResponse, null);
      } else {
        final response = await _http
            .put(
              Uri.parse(request.url),
              headers: request.headers,
              body: jsonEncode(request.body),
            )
            .timeout(timeout ?? config.receiveTimeout);

        stopwatch.stop();

        final httpResponse =
            _httpToResponse(response, 'PUT', stopwatch.elapsedMilliseconds);
        final processedResponse =
            await _runResponseInterceptors(request, httpResponse);
        return (processedResponse, null);
      }
    } catch (e) {
      stopwatch.stop();
      if (cancelKey != null) _cancelTokens.remove(cancelKey);
      return (null, _toException(e, request.url));
    }
  }

  // ============================================================================
  // PATCH Methods
  // ============================================================================

  /// Performs a PATCH request and returns the result as a tuple.
  ///
  /// Optionally accepts callbacks for convenient response handling.
  /// When callbacks are provided, they are invoked based on the response
  /// status code, but the result tuple is still returned.
  Future<ClientResult> patch({
    required String url,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    Duration? timeout,
    ClientType? clientType,
    String? cancelKey,
    // Optional callbacks
    OnSuccess? onSuccess,
    OnError? onError,
    OnHttpError? onHttpError,
    Map<int, OnStatus>? onStatus,
    Set<int>? successCodes,
    Set<int>? errorCodes,
  }) async {
    final fullUrl = _buildUrl(url);
    final request = ClientRequest(
      url: fullUrl,
      method: 'PATCH',
      headers: {...config.defaultHeaders, ...?headers},
      body: body,
    );

    final processedRequest = await _runRequestInterceptors(request);
    if (processedRequest == null) {
      final result = (
        null,
        ClientException(
            message: 'Request cancelled by interceptor', url: fullUrl)
      );
      _handleCallbacks(
        response: result.$1,
        error: result.$2,
        onSuccess: onSuccess,
        onError: onError,
        onHttpError: onHttpError,
        onStatus: onStatus,
        successCodes: successCodes,
        errorCodes: errorCodes,
      );
      return result;
    }

    final result = await _executeWithRetry(
      request: processedRequest,
      execute: () =>
          _performPatch(processedRequest, timeout, clientType, cancelKey),
    );

    _handleCallbacks(
      response: result.$1,
      error: result.$2,
      onSuccess: onSuccess,
      onError: onError,
      onHttpError: onHttpError,
      onStatus: onStatus,
      successCodes: successCodes,
      errorCodes: errorCodes,
    );

    return result;
  }

  Future<ClientResult> _performPatch(
    ClientRequest request,
    Duration? timeout,
    ClientType? clientType,
    String? cancelKey,
  ) async {
    final useClient = clientType ?? config.clientType;
    final stopwatch = Stopwatch()..start();

    try {
      if (useClient == ClientType.dio) {
        dio.CancelToken? cancelToken;
        if (cancelKey != null) {
          cancelToken = dio.CancelToken();
          _cancelTokens[cancelKey] = cancelToken;
        }

        final response = await _dio.patch(
          request.url,
          data: request.body,
          options: dio.Options(
            headers: request.headers,
            receiveTimeout: timeout ?? config.receiveTimeout,
          ),
          cancelToken: cancelToken,
        );

        stopwatch.stop();
        if (cancelKey != null) _cancelTokens.remove(cancelKey);

        final httpResponse =
            _dioToResponse(response, 'PATCH', stopwatch.elapsedMilliseconds);
        final processedResponse =
            await _runResponseInterceptors(request, httpResponse);
        return (processedResponse, null);
      } else {
        final response = await _http
            .patch(
              Uri.parse(request.url),
              headers: request.headers,
              body: jsonEncode(request.body),
            )
            .timeout(timeout ?? config.receiveTimeout);

        stopwatch.stop();

        final httpResponse =
            _httpToResponse(response, 'PATCH', stopwatch.elapsedMilliseconds);
        final processedResponse =
            await _runResponseInterceptors(request, httpResponse);
        return (processedResponse, null);
      }
    } catch (e) {
      stopwatch.stop();
      if (cancelKey != null) _cancelTokens.remove(cancelKey);
      return (null, _toException(e, request.url));
    }
  }

  // ============================================================================
  // DELETE Methods
  // ============================================================================

  /// Performs a DELETE request and returns the result as a tuple.
  ///
  /// Optionally accepts callbacks for convenient response handling.
  /// When callbacks are provided, they are invoked based on the response
  /// status code, but the result tuple is still returned.
  Future<ClientResult> delete({
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration? timeout,
    ClientType? clientType,
    String? cancelKey,
    // Optional callbacks
    OnSuccess? onSuccess,
    OnError? onError,
    OnHttpError? onHttpError,
    Map<int, OnStatus>? onStatus,
    Set<int>? successCodes,
    Set<int>? errorCodes,
  }) async {
    final fullUrl = _buildUrl(url);
    final request = ClientRequest(
      url: fullUrl,
      method: 'DELETE',
      headers: {...config.defaultHeaders, ...?headers},
      body: body,
    );

    final processedRequest = await _runRequestInterceptors(request);
    if (processedRequest == null) {
      final result = (
        null,
        ClientException(
            message: 'Request cancelled by interceptor', url: fullUrl)
      );
      _handleCallbacks(
        response: result.$1,
        error: result.$2,
        onSuccess: onSuccess,
        onError: onError,
        onHttpError: onHttpError,
        onStatus: onStatus,
        successCodes: successCodes,
        errorCodes: errorCodes,
      );
      return result;
    }

    final result = await _executeWithRetry(
      request: processedRequest,
      execute: () =>
          _performDelete(processedRequest, timeout, clientType, cancelKey),
    );

    _handleCallbacks(
      response: result.$1,
      error: result.$2,
      onSuccess: onSuccess,
      onError: onError,
      onHttpError: onHttpError,
      onStatus: onStatus,
      successCodes: successCodes,
      errorCodes: errorCodes,
    );

    return result;
  }

  Future<ClientResult> _performDelete(
    ClientRequest request,
    Duration? timeout,
    ClientType? clientType,
    String? cancelKey,
  ) async {
    final useClient = clientType ?? config.clientType;
    final stopwatch = Stopwatch()..start();

    try {
      if (useClient == ClientType.dio) {
        dio.CancelToken? cancelToken;
        if (cancelKey != null) {
          cancelToken = dio.CancelToken();
          _cancelTokens[cancelKey] = cancelToken;
        }

        final response = await _dio.delete(
          request.url,
          data: request.body,
          options: dio.Options(
            headers: request.headers,
            receiveTimeout: timeout ?? config.receiveTimeout,
          ),
          cancelToken: cancelToken,
        );

        stopwatch.stop();
        if (cancelKey != null) _cancelTokens.remove(cancelKey);

        final httpResponse =
            _dioToResponse(response, 'DELETE', stopwatch.elapsedMilliseconds);
        final processedResponse =
            await _runResponseInterceptors(request, httpResponse);
        return (processedResponse, null);
      } else {
        final httpRequest = http.Request('DELETE', Uri.parse(request.url));
        httpRequest.headers.addAll(request.headers);
        if (request.body != null) {
          httpRequest.body = jsonEncode(request.body);
        }

        final streamedResponse = await _http
            .send(httpRequest)
            .timeout(timeout ?? config.receiveTimeout);
        final response = await http.Response.fromStream(streamedResponse);

        stopwatch.stop();

        final httpResponse =
            _httpToResponse(response, 'DELETE', stopwatch.elapsedMilliseconds);
        final processedResponse =
            await _runResponseInterceptors(request, httpResponse);
        return (processedResponse, null);
      }
    } catch (e) {
      stopwatch.stop();
      if (cancelKey != null) _cancelTokens.remove(cancelKey);
      return (null, _toException(e, request.url));
    }
  }

  // ============================================================================
  // HEAD Methods
  // ============================================================================

  /// Performs a HEAD request and returns the result as a tuple.
  ///
  /// Optionally accepts callbacks for convenient response handling.
  /// When callbacks are provided, they are invoked based on the response
  /// status code, but the result tuple is still returned.
  Future<ClientResult> head({
    required String url,
    Map<String, String>? headers,
    Duration? timeout,
    ClientType? clientType,
    String? cancelKey,
    // Optional callbacks
    OnSuccess? onSuccess,
    OnError? onError,
    OnHttpError? onHttpError,
    Map<int, OnStatus>? onStatus,
    Set<int>? successCodes,
    Set<int>? errorCodes,
  }) async {
    final fullUrl = _buildUrl(url);
    final request = ClientRequest(
      url: fullUrl,
      method: 'HEAD',
      headers: {...config.defaultHeaders, ...?headers},
    );

    final processedRequest = await _runRequestInterceptors(request);
    if (processedRequest == null) {
      final result = (
        null,
        ClientException(
            message: 'Request cancelled by interceptor', url: fullUrl)
      );
      _handleCallbacks(
        response: result.$1,
        error: result.$2,
        onSuccess: onSuccess,
        onError: onError,
        onHttpError: onHttpError,
        onStatus: onStatus,
        successCodes: successCodes,
        errorCodes: errorCodes,
      );
      return result;
    }

    final result = await _executeWithRetry(
      request: processedRequest,
      execute: () => _performHead(processedRequest, timeout, clientType),
    );

    _handleCallbacks(
      response: result.$1,
      error: result.$2,
      onSuccess: onSuccess,
      onError: onError,
      onHttpError: onHttpError,
      onStatus: onStatus,
      successCodes: successCodes,
      errorCodes: errorCodes,
    );

    return result;
  }

  Future<ClientResult> _performHead(
    ClientRequest request,
    Duration? timeout,
    ClientType? clientType,
  ) async {
    final useClient = clientType ?? config.clientType;
    final stopwatch = Stopwatch()..start();

    try {
      if (useClient == ClientType.dio) {
        final response = await _dio.head(
          request.url,
          options: dio.Options(
            headers: request.headers,
            receiveTimeout: timeout ?? config.receiveTimeout,
          ),
        );

        stopwatch.stop();

        final httpResponse =
            _dioToResponse(response, 'HEAD', stopwatch.elapsedMilliseconds);
        final processedResponse =
            await _runResponseInterceptors(request, httpResponse);
        return (processedResponse, null);
      } else {
        final response = await _http
            .head(Uri.parse(request.url), headers: request.headers)
            .timeout(timeout ?? config.receiveTimeout);

        stopwatch.stop();

        final httpResponse =
            _httpToResponse(response, 'HEAD', stopwatch.elapsedMilliseconds);
        final processedResponse =
            await _runResponseInterceptors(request, httpResponse);
        return (processedResponse, null);
      }
    } catch (e) {
      stopwatch.stop();
      return (null, _toException(e, request.url));
    }
  }

  // ============================================================================
  // Download & Upload
  // ============================================================================

  /// Downloads a file from the specified URL.
  ///
  /// Returns a tuple of (bytes, error). Optionally accepts callbacks for
  /// convenient response handling.
  Future<(List<int>?, ClientException?)> download({
    required String url,
    Map<String, String>? headers,
    Duration? timeout,
    ClientType? clientType,
    OnProgress? onProgress,
    String? cancelKey,
    // Optional callbacks
    void Function(List<int> bytes)? onSuccess,
    OnError? onError,
  }) async {
    final fullUrl = _buildUrl(url);
    final useClient = clientType ?? config.clientType;

    try {
      if (useClient == ClientType.dio) {
        dio.CancelToken? cancelToken;
        if (cancelKey != null) {
          cancelToken = dio.CancelToken();
          _cancelTokens[cancelKey] = cancelToken;
        }

        final response = await _dio.get<List<int>>(
          fullUrl,
          options: dio.Options(
            headers: headers,
            responseType: dio.ResponseType.bytes,
            receiveTimeout: timeout ?? config.receiveTimeout,
          ),
          onReceiveProgress: onProgress,
          cancelToken: cancelToken,
        );

        if (cancelKey != null) _cancelTokens.remove(cancelKey);

        if (response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300) {
          final result = (response.data, null);
          if (result.$1 != null) {
            onSuccess?.call(result.$1!);
          }
          return result;
        } else {
          final result = (
            null,
            ClientException(
              message: 'Download failed with status ${response.statusCode}',
              url: fullUrl,
              statusCode: response.statusCode,
              type: ClientErrorType.badResponse,
            )
          );
          onError?.call(result.$2);
          return result;
        }
      } else {
        final response = await _http
            .get(Uri.parse(fullUrl), headers: headers)
            .timeout(timeout ?? config.receiveTimeout);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final result = (response.bodyBytes, null);
          onSuccess?.call(result.$1);
          return result;
        } else {
          final result = (
            null,
            ClientException(
              message: 'Download failed with status ${response.statusCode}',
              url: fullUrl,
              statusCode: response.statusCode,
              type: ClientErrorType.badResponse,
            )
          );
          onError?.call(result.$2);
          return result;
        }
      }
    } catch (e) {
      if (cancelKey != null) _cancelTokens.remove(cancelKey);
      final result = (null, _toException(e, fullUrl));
      onError?.call(result.$2);
      return result;
    }
  }

  /// Downloads a file from the specified URL and saves it to a file path.
  ///
  /// This method saves the file directly to disk, which is more memory-efficient
  /// for large files compared to [download] which loads the entire file into memory.
  ///
  /// The [fileAccessMode] parameter (Dio 5.8+) controls how the file is opened:
  /// - [FileAccessMode.write] (default): Creates a new file or truncates existing
  /// - [FileAccessMode.append]: Appends to an existing file (useful for resumable downloads)
  /// - [FileAccessMode.writeOnly]: Write-only access
  /// - [FileAccessMode.writeOnlyAppend]: Write-only, appending to existing file
  ///
  /// Note: [fileAccessMode] is only supported with [ClientType.dio]. When using
  /// [ClientType.http], files are always written in write mode.
  ///
  /// Returns a tuple of (savePath, error). The savePath is returned on success
  /// to confirm where the file was saved.
  Future<(String?, ClientException?)> downloadToFile({
    required String url,
    required String savePath,
    Map<String, String>? headers,
    Duration? timeout,
    ClientType? clientType,
    OnProgress? onProgress,
    String? cancelKey,
    dio.FileAccessMode? fileAccessMode,
    // Optional callbacks
    void Function(String savedPath)? onSuccess,
    OnError? onError,
  }) async {
    final fullUrl = _buildUrl(url);
    final useClient = clientType ?? config.clientType;

    try {
      if (useClient == ClientType.dio) {
        dio.CancelToken? cancelToken;
        if (cancelKey != null) {
          cancelToken = dio.CancelToken();
          _cancelTokens[cancelKey] = cancelToken;
        }

        final response = await _dio.download(
          fullUrl,
          savePath,
          options: dio.Options(
            headers: headers,
            receiveTimeout: timeout ?? config.receiveTimeout,
          ),
          onReceiveProgress: onProgress,
          cancelToken: cancelToken,
          fileAccessMode: fileAccessMode ?? dio.FileAccessMode.write,
        );

        if (cancelKey != null) _cancelTokens.remove(cancelKey);

        if (response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300) {
          final result = (savePath, null);
          onSuccess?.call(savePath);
          return result;
        } else {
          final result = (
            null,
            ClientException(
              message: 'Download failed with status ${response.statusCode}',
              url: fullUrl,
              statusCode: response.statusCode,
              type: ClientErrorType.badResponse,
            )
          );
          onError?.call(result.$2);
          return result;
        }
      } else {
        // For http package, we need to download and write manually
        final response = await _http
            .get(Uri.parse(fullUrl), headers: headers)
            .timeout(timeout ?? config.receiveTimeout);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Write to file (note: fileAccessMode not supported with http package)
          final file = await _writeToFile(savePath, response.bodyBytes);
          final result = (file.path, null);
          onSuccess?.call(file.path);
          return result;
        } else {
          final result = (
            null,
            ClientException(
              message: 'Download failed with status ${response.statusCode}',
              url: fullUrl,
              statusCode: response.statusCode,
              type: ClientErrorType.badResponse,
            )
          );
          onError?.call(result.$2);
          return result;
        }
      }
    } catch (e) {
      if (cancelKey != null) _cancelTokens.remove(cancelKey);
      final result = (null, _toException(e, fullUrl));
      onError?.call(result.$2);
      return result;
    }
  }

  /// Helper method to write bytes to a file.
  Future<File> _writeToFile(String path, List<int> bytes) async {
    // Using dart:io File - only available on non-web platforms
    if (kIsWeb) {
      throw UnsupportedError(
          'downloadToFile with http backend is not supported on web. Use ClientType.dio instead.');
    }
    final file = File(path);
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Uploads a file using multipart/form-data.
  ///
  /// Returns a [ClientResult] tuple. Optionally accepts callbacks for
  /// convenient response handling.
  Future<ClientResult> uploadFile({
    required String url,
    required String filePath,
    required String fileField,
    Map<String, String>? fields,
    Map<String, String>? headers,
    Duration? timeout,
    ClientType? clientType,
    OnProgress? onProgress,
    String? cancelKey,
    // Optional callbacks
    OnSuccess? onSuccess,
    OnError? onError,
    OnHttpError? onHttpError,
    Map<int, OnStatus>? onStatus,
    Set<int>? successCodes,
    Set<int>? errorCodes,
  }) async {
    final fullUrl = _buildUrl(url);
    final useClient = clientType ?? config.clientType;
    final stopwatch = Stopwatch()..start();

    try {
      if (useClient == ClientType.dio) {
        dio.CancelToken? cancelToken;
        if (cancelKey != null) {
          cancelToken = dio.CancelToken();
          _cancelTokens[cancelKey] = cancelToken;
        }

        final formData = dio.FormData.fromMap({
          ...?fields,
          fileField: await dio.MultipartFile.fromFile(filePath),
        });

        final response = await _dio.post(
          fullUrl,
          data: formData,
          options: dio.Options(
            headers: headers,
            sendTimeout: timeout ?? config.sendTimeout,
          ),
          onSendProgress: onProgress,
          cancelToken: cancelToken,
        );

        stopwatch.stop();
        if (cancelKey != null) _cancelTokens.remove(cancelKey);

        final result = (
          _dioToResponse(response, 'POST', stopwatch.elapsedMilliseconds),
          null
        );

        _handleCallbacks(
          response: result.$1,
          error: result.$2,
          onSuccess: onSuccess,
          onError: onError,
          onHttpError: onHttpError,
          onStatus: onStatus,
          successCodes: successCodes,
          errorCodes: errorCodes,
        );

        return result;
      } else {
        final request = http.MultipartRequest('POST', Uri.parse(fullUrl));

        if (headers != null) request.headers.addAll(headers);
        if (fields != null) request.fields.addAll(fields);

        request.files
            .add(await http.MultipartFile.fromPath(fileField, filePath));

        final streamedResponse =
            await _http.send(request).timeout(timeout ?? config.sendTimeout);
        final response = await http.Response.fromStream(streamedResponse);

        stopwatch.stop();

        final result = (
          _httpToResponse(response, 'POST', stopwatch.elapsedMilliseconds),
          null
        );

        _handleCallbacks(
          response: result.$1,
          error: result.$2,
          onSuccess: onSuccess,
          onError: onError,
          onHttpError: onHttpError,
          onStatus: onStatus,
          successCodes: successCodes,
          errorCodes: errorCodes,
        );

        return result;
      }
    } catch (e) {
      stopwatch.stop();
      if (cancelKey != null) _cancelTokens.remove(cancelKey);
      final result = (null, _toException(e, fullUrl));

      _handleCallbacks(
        response: result.$1,
        error: result.$2,
        onSuccess: onSuccess,
        onError: onError,
        onHttpError: onHttpError,
        onStatus: onStatus,
        successCodes: successCodes,
        errorCodes: errorCodes,
      );

      return result;
    }
  }

  // ============================================================================
  // Utility Methods
  // ============================================================================

  /// Checks if a URL is reachable.
  ///
  /// First attempts a HEAD request, but if it fails with 403/405/501
  /// (common for servers that block HEAD), falls back to a GET request.
  ///
  /// A URL is considered reachable if we get ANY response from the server,
  /// even error responses like 404 or 500 - because that means the server
  /// is online and responding. Only connection failures return false.
  Future<bool> isReachable(String url,
      {Duration? timeout, ClientType? clientType}) async {
    final effectiveTimeout = timeout ?? const Duration(seconds: 10);

    // First try HEAD request (lighter weight)
    final (headResponse, headError) = await head(
      url: url,
      timeout: effectiveTimeout,
      clientType: clientType,
    );

    // If HEAD succeeded with any response, the server is reachable
    if (headError == null && headResponse != null) {
      return true;
    }

    // If HEAD returned 403, 405, or 501, the server blocked HEAD but is reachable
    // Try a GET request to confirm
    if (headResponse != null &&
        (headResponse.statusCode == 403 ||
            headResponse.statusCode == 405 ||
            headResponse.statusCode == 501)) {
      final (getResponse, getError) = await get(
        url: url,
        timeout: effectiveTimeout,
        clientType: clientType,
      );
      // Any response (even 404, 500) means the server is reachable
      return getError == null || getResponse != null;
    }

    // If HEAD had a connection error, try GET as fallback
    // Some servers don't handle HEAD properly
    if (headError != null &&
        (headError.type == ClientErrorType.unknown ||
            headError.type == ClientErrorType.badResponse)) {
      final (getResponse, getError) = await get(
        url: url,
        timeout: effectiveTimeout,
        clientType: clientType,
      );
      // Any response means server is reachable
      return getError == null || getResponse != null;
    }

    // Check if the error indicates a network/connection issue vs server response
    if (headError != null) {
      // These errors mean we couldn't connect at all
      if (headError.type == ClientErrorType.connectionError ||
          headError.type == ClientErrorType.connectionTimeout ||
          headError.type == ClientErrorType.sendTimeout) {
        return false;
      }
      // Other errors might mean the server responded but with an error
      // If we have a response object, the server IS reachable
      if (headResponse != null) {
        return true;
      }
    }

    return false;
  }

  /// Checks reachability with callback-based response handling.
  Future<void> checkReachability({
    required String url,
    required void Function(bool isReachable) onResult,
    Duration? timeout,
    ClientType? clientType,
  }) async {
    final result =
        await isReachable(url, timeout: timeout, clientType: clientType);
    onResult(result);
  }

  /// Cancels a request by its cancel key.
  void cancel(String cancelKey, {String? reason}) {
    final token = _cancelTokens[cancelKey];
    if (token != null) {
      token.cancel(reason);
      _cancelTokens.remove(cancelKey);
    }
  }

  /// Cancels all pending requests.
  void cancelAll({String? reason}) {
    for (final token in _cancelTokens.values) {
      token.cancel(reason);
    }
    _cancelTokens.clear();
  }

  /// Closes the HTTP clients and cleans up resources.
  void close() {
    _httpClient?.close();
    _httpClient = null;
    _dioClient?.close();
    _dioClient = null;
    _cancelTokens.clear();
  }
}
