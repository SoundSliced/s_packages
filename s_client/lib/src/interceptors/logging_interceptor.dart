import 'dart:convert';
import 'dart:developer' as developer;

import 'client_interceptor.dart';
import '../models/client_response.dart';

/// An interceptor that logs HTTP requests and responses.
class LoggingInterceptor extends ClientInterceptor {
  /// Whether to log request details.
  final bool logRequest;

  /// Whether to log request headers.
  final bool logRequestHeaders;

  /// Whether to log request body.
  final bool logRequestBody;

  /// Whether to log response details.
  final bool logResponse;

  /// Whether to log response headers.
  final bool logResponseHeaders;

  /// Whether to log response body.
  final bool logResponseBody;

  /// Maximum length of body to log (to avoid huge logs).
  final int maxBodyLength;

  /// Whether to pretty print JSON bodies.
  final bool prettyPrintJson;

  /// Custom log function. If null, uses dart:developer log.
  final void Function(String message)? logger;

  LoggingInterceptor({
    this.logRequest = true,
    this.logRequestHeaders = false,
    this.logRequestBody = true,
    this.logResponse = true,
    this.logResponseHeaders = false,
    this.logResponseBody = true,
    this.maxBodyLength = 1000,
    this.prettyPrintJson = true,
    this.logger,
  });

  void _log(String message) {
    if (logger != null) {
      logger!(message);
    } else {
      developer.log(message, name: 'SClient');
    }
  }

  String _formatBody(dynamic body) {
    if (body == null) return 'null';

    String bodyStr;
    if (body is Map || body is List) {
      if (prettyPrintJson) {
        bodyStr = const JsonEncoder.withIndent('  ').convert(body);
      } else {
        bodyStr = jsonEncode(body);
      }
    } else {
      bodyStr = body.toString();
    }

    if (bodyStr.length > maxBodyLength) {
      return '${bodyStr.substring(0, maxBodyLength)}... (truncated)';
    }
    return bodyStr;
  }

  @override
  Future<ClientRequest?> onRequest(ClientRequest request) async {
    if (logRequest) {
      final buffer = StringBuffer();
      buffer.writeln('┌─────────────────────────────────────────────────────');
      buffer.writeln('│ ➡️ REQUEST: ${request.method} ${request.url}');

      if (logRequestHeaders && request.headers.isNotEmpty) {
        buffer.writeln('│ Headers:');
        request.headers.forEach((key, value) {
          // Mask authorization headers for security
          final displayValue = key.toLowerCase() == 'authorization'
              ? '${value.substring(0, 10)}...'
              : value;
          buffer.writeln('│   $key: $displayValue');
        });
      }

      if (logRequestBody && request.body != null) {
        buffer.writeln('│ Body:');
        buffer.writeln('│   ${_formatBody(request.body)}');
      }

      buffer.writeln('└─────────────────────────────────────────────────────');
      _log(buffer.toString());
    }

    return request;
  }

  @override
  Future<ClientResponse> onResponse(
    ClientRequest request,
    ClientResponse response,
  ) async {
    if (logResponse) {
      final buffer = StringBuffer();
      buffer.writeln('┌─────────────────────────────────────────────────────');

      final statusEmoji = response.isSuccess ? '✅' : '❌';
      buffer.writeln(
        '│ $statusEmoji RESPONSE: ${response.statusCode} ${request.method} ${request.url}',
      );

      if (response.requestDuration != null) {
        buffer.writeln('│ Duration: ${response.requestDuration}ms');
      }

      if (response.isFromCache) {
        buffer.writeln('│ 📦 From Cache');
      }

      if (logResponseHeaders && response.headers.isNotEmpty) {
        buffer.writeln('│ Headers:');
        response.headers.forEach((key, value) {
          buffer.writeln('│   $key: $value');
        });
      }

      if (logResponseBody && response.body.isNotEmpty) {
        buffer.writeln('│ Body:');
        try {
          final json = jsonDecode(response.body);
          buffer.writeln('│   ${_formatBody(json)}');
        } catch (_) {
          buffer.writeln(
            '│   ${response.body.length > maxBodyLength ? '${response.body.substring(0, maxBodyLength)}...' : response.body}',
          );
        }
      }

      buffer.writeln('└─────────────────────────────────────────────────────');
      _log(buffer.toString());
    }

    return response;
  }

  @override
  Future<bool> onError(
    ClientRequest request,
    Object error,
    int attemptCount,
  ) async {
    _log(
      '┌─────────────────────────────────────────────────────\n'
      '│ ❌ ERROR: ${request.method} ${request.url}\n'
      '│ Attempt: $attemptCount\n'
      '│ Error: $error\n'
      '└─────────────────────────────────────────────────────',
    );
    return false;
  }
}
