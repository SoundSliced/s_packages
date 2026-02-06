/// A unified exception class that works with both http and dio backends.
class ClientException implements Exception {
  /// The error message.
  final String message;

  /// The request URL that caused the error.
  final String? url;

  /// The HTTP status code if available.
  final int? statusCode;

  /// The error type.
  final ClientErrorType type;

  /// The original error object from the underlying client.
  final Object? originalError;

  /// The response body if available (for error responses).
  final String? responseBody;

  const ClientException({
    required this.message,
    this.url,
    this.statusCode,
    this.type = ClientErrorType.unknown,
    this.originalError,
    this.responseBody,
  });

  /// Returns true if this is a timeout error.
  bool get isTimeout =>
      type == ClientErrorType.connectionTimeout ||
      type == ClientErrorType.sendTimeout ||
      type == ClientErrorType.receiveTimeout;

  /// Returns true if this is a connection error.
  bool get isConnectionError => type == ClientErrorType.connectionError;

  /// Returns true if the request was cancelled.
  bool get isCancelled => type == ClientErrorType.cancelled;

  @override
  String toString() {
    return 'ClientException: $message (type: ${type.name}, url: $url, status: $statusCode)';
  }
}

/// Types of errors that can occur during HTTP requests.
enum ClientErrorType {
  /// Connection timeout
  connectionTimeout,

  /// Send timeout
  sendTimeout,

  /// Receive timeout
  receiveTimeout,

  /// Request was cancelled
  cancelled,

  /// Bad response from server (4xx, 5xx)
  badResponse,

  /// Connection error (no internet, DNS resolution failed, etc.)
  connectionError,

  /// Bad certificate (SSL/TLS error)
  badCertificate,

  /// Unknown error
  unknown,
}
