import 'enums/client_type.dart';
import 'interceptors/client_interceptor.dart';

/// Default headers for JSON requests.
const Map<String, String> defaultJsonHeaders = {
  'Accept': 'application/json',
  'Content-Type': 'application/json',
};

/// Default success status codes (2xx).
const Set<int> defaultSuccessCodes = {
  200,
  201,
  202,
  203,
  204,
  205,
  206,
  207,
  208,
  226
};

/// Default error status codes (4xx and 5xx).
const Set<int> defaultErrorCodes = {
  400,
  401,
  402,
  403,
  404,
  405,
  406,
  407,
  408,
  409,
  410,
  411,
  412,
  413,
  414,
  415,
  416,
  417,
  418,
  421,
  422,
  423,
  424,
  425,
  426,
  428,
  429,
  431,
  451,
  500,
  501,
  502,
  503,
  504,
  505,
  506,
  507,
  508,
  510,
  511,
};

/// Configuration class for Client.
class ClientConfig {
  /// The HTTP client type to use.
  final ClientType clientType;

  /// Base URL to prepend to all requests.
  final String? baseUrl;

  /// Default timeout for connection.
  final Duration connectTimeout;

  /// Default timeout for receiving data.
  final Duration receiveTimeout;

  /// Default timeout for sending data.
  final Duration sendTimeout;

  /// Default headers to include in all requests.
  final Map<String, String> defaultHeaders;

  /// List of interceptors to apply to requests/responses.
  final List<ClientInterceptor> interceptors;

  /// Whether to follow redirects.
  final bool followRedirects;

  /// Maximum number of redirects to follow.
  final int maxRedirects;

  /// Whether to validate SSL certificates.
  final bool validateCertificates;

  /// Whether to enable logging (adds LoggingInterceptor if true).
  final bool enableLogging;

  /// Maximum number of retries for failed requests.
  final int maxRetries;

  /// Initial delay for retry backoff.
  final Duration retryDelay;

  /// Whether to use exponential backoff for retries.
  final bool exponentialBackoff;

  /// HTTP status codes that should trigger a retry.
  final Set<int> retryStatusCodes;

  /// Default success status codes.
  final Set<int> successCodes;

  /// Default error status codes.
  final Set<int> errorCodes;

  const ClientConfig({
    this.clientType = ClientType.http,
    this.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.defaultHeaders = defaultJsonHeaders,
    this.interceptors = const [],
    this.followRedirects = true,
    this.maxRedirects = 5,
    this.validateCertificates = true,
    this.enableLogging = false,
    this.maxRetries = 0,
    this.retryDelay = const Duration(seconds: 1),
    this.exponentialBackoff = true,
    this.retryStatusCodes = const {408, 429, 500, 502, 503, 504},
    this.successCodes = defaultSuccessCodes,
    this.errorCodes = defaultErrorCodes,
  });

  /// Creates a copy of this config with the specified changes.
  ClientConfig copyWith({
    ClientType? clientType,
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Map<String, String>? defaultHeaders,
    List<ClientInterceptor>? interceptors,
    bool? followRedirects,
    int? maxRedirects,
    bool? validateCertificates,
    bool? enableLogging,
    int? maxRetries,
    Duration? retryDelay,
    bool? exponentialBackoff,
    Set<int>? retryStatusCodes,
    Set<int>? successCodes,
    Set<int>? errorCodes,
  }) {
    return ClientConfig(
      clientType: clientType ?? this.clientType,
      baseUrl: baseUrl ?? this.baseUrl,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      defaultHeaders: defaultHeaders ?? this.defaultHeaders,
      interceptors: interceptors ?? this.interceptors,
      followRedirects: followRedirects ?? this.followRedirects,
      maxRedirects: maxRedirects ?? this.maxRedirects,
      validateCertificates: validateCertificates ?? this.validateCertificates,
      enableLogging: enableLogging ?? this.enableLogging,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
      exponentialBackoff: exponentialBackoff ?? this.exponentialBackoff,
      retryStatusCodes: retryStatusCodes ?? this.retryStatusCodes,
      successCodes: successCodes ?? this.successCodes,
      errorCodes: errorCodes ?? this.errorCodes,
    );
  }
}
