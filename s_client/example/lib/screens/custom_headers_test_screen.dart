import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:s_client/s_client.dart';
import 'package:s_client_example/widgets/response_viewer.dart';

class CustomHeadersTestScreen extends StatefulWidget {
  const CustomHeadersTestScreen({super.key});

  @override
  State<CustomHeadersTestScreen> createState() =>
      _CustomHeadersTestScreenState();
}

class _CustomHeadersTestScreenState extends State<CustomHeadersTestScreen> {
  bool _isLoadingHttp = false;
  bool _isLoadingDio = false;
  String? _httpResponseBody;
  String? _dioResponseBody;
  int? _httpStatusCode;
  int? _dioStatusCode;
  String? _httpError;
  String? _dioError;
  int? _httpDuration;
  int? _dioDuration;

  final Map<String, String> _customHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'X-Custom-Header': 'http_handler_test',
    'X-Request-ID': 'test-123',
  };

  Future<void> _runCustomHeadersTest({required ClientType clientType}) async {
    final isHttp = clientType == ClientType.http;
    setState(() {
      if (isHttp) {
        _isLoadingHttp = true;
        _httpResponseBody = null;
        _httpStatusCode = null;
        _httpError = null;
        _httpDuration = null;
      } else {
        _isLoadingDio = true;
        _dioResponseBody = null;
        _dioStatusCode = null;
        _dioError = null;
        _dioDuration = null;
      }
    });

    final stopwatch = Stopwatch()..start();

    // Using httpbin.org which echoes back the request data including headers
    final (response, error) = await SClient.instance.post(
      url: 'https://httpbin.org/post',
      body: {
        'message': 'Testing custom headers',
        'timestamp': DateTime.now().toIso8601String(),
      },
      headers: _customHeaders,
      clientType: clientType,
    );

    stopwatch.stop();

    setState(() {
      if (isHttp) {
        _isLoadingHttp = false;
        _httpDuration = stopwatch.elapsedMilliseconds;
        if (error != null) {
          _httpError = error.message;
        } else if (response != null) {
          _httpStatusCode = response.statusCode;
          _httpResponseBody = _formatJson(response.body);
        }
      } else {
        _isLoadingDio = false;
        _dioDuration = stopwatch.elapsedMilliseconds;
        if (error != null) {
          _dioError = error.message;
        } else if (response != null) {
          _dioStatusCode = response.statusCode;
          _dioResponseBody = _formatJson(response.body);
        }
      }
    });
  }

  Future<void> _runBothTests() async {
    await Future.wait([
      _runCustomHeadersTest(clientType: ClientType.http),
      _runCustomHeadersTest(clientType: ClientType.dio),
    ]);
  }

  String _formatJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (e) {
      return jsonString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Headers Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test: Custom Headers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This test sends a POST request with custom headers. '
              'httpbin.org echoes back the request so you can verify the headers were sent.',
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Custom Headers:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._customHeaders.entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.label,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${e.key}: ${e.value}',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingHttp
                        ? null
                        : () =>
                            _runCustomHeadersTest(clientType: ClientType.http),
                    icon: _isLoadingHttp
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.http, size: 18),
                    label: const Text('HTTP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade100,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingDio
                        ? null
                        : () =>
                            _runCustomHeadersTest(clientType: ClientType.dio),
                    icon: _isLoadingDio
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.rocket_launch, size: 18),
                    label: const Text('Dio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_isLoadingHttp || _isLoadingDio)
                        ? null
                        : _runBothTests,
                    icon: (_isLoadingHttp || _isLoadingDio)
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.compare_arrows, size: 18),
                    label: const Text('Both'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.http, size: 16),
                              const SizedBox(width: 4),
                              const Text(
                                'HTTP',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              if (_httpDuration != null)
                                Text(
                                  '${_httpDuration}ms',
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ResponseViewer(
                            statusCode: _httpStatusCode,
                            responseBody: _httpResponseBody,
                            error: _httpError,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.rocket_launch, size: 16),
                              const SizedBox(width: 4),
                              const Text(
                                'Dio',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              if (_dioDuration != null)
                                Text(
                                  '${_dioDuration}ms',
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ResponseViewer(
                            statusCode: _dioStatusCode,
                            responseBody: _dioResponseBody,
                            error: _dioError,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
