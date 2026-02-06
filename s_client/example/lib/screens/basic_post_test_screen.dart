import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:s_client/s_client.dart';
import 'package:s_client_example/widgets/response_viewer.dart';

class BasicPostTestScreen extends StatefulWidget {
  const BasicPostTestScreen({super.key});

  @override
  State<BasicPostTestScreen> createState() => _BasicPostTestScreenState();
}

class _BasicPostTestScreenState extends State<BasicPostTestScreen> {
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

  Future<void> _runBasicPostTest({required ClientType clientType}) async {
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

    // Using the new callback-based API - no more tuple handling!
    await SClient.instance.post(
      url: 'https://jsonplaceholder.typicode.com/posts',
      body: {
        'title': 'Test Post',
        'body': 'This is a test post created by s_client package',
        'userId': 1,
      },
      clientType: clientType,
      onSuccess: (response) {
        stopwatch.stop();
        setState(() {
          if (isHttp) {
            _isLoadingHttp = false;
            _httpStatusCode = response.statusCode;
            _httpResponseBody = _formatJson(response.body);
            _httpDuration = stopwatch.elapsedMilliseconds;
          } else {
            _isLoadingDio = false;
            _dioStatusCode = response.statusCode;
            _dioResponseBody = _formatJson(response.body);
            _dioDuration = stopwatch.elapsedMilliseconds;
          }
        });
      },
      onError: (error) {
        stopwatch.stop();
        setState(() {
          if (isHttp) {
            _isLoadingHttp = false;
            _httpError = error.message;
            _httpDuration = stopwatch.elapsedMilliseconds;
          } else {
            _isLoadingDio = false;
            _dioError = error.message;
            _dioDuration = stopwatch.elapsedMilliseconds;
          }
        });
      },
      // Optional: handle specific HTTP error codes differently
      onHttpError: (code, response) {
        stopwatch.stop();
        setState(() {
          if (isHttp) {
            _isLoadingHttp = false;
            _httpStatusCode = code;
            _httpError = 'HTTP Error $code: ${response.body}';
            _httpDuration = stopwatch.elapsedMilliseconds;
          } else {
            _isLoadingDio = false;
            _dioStatusCode = code;
            _dioError = 'HTTP Error $code: ${response.body}';
            _dioDuration = stopwatch.elapsedMilliseconds;
          }
        });
      },
    );
  }

  Future<void> _runBothTests() async {
    await Future.wait([
      _runBasicPostTest(clientType: ClientType.http),
      _runBasicPostTest(clientType: ClientType.dio),
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
        title: const Text('Basic POST Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test: Basic POST Request',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This test sends a simple POST request to JSONPlaceholder API '
              'with a JSON body containing title, body, and userId.',
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.grey[100],
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('URL:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('https://jsonplaceholder.typicode.com/posts'),
                    SizedBox(height: 8),
                    Text('Body:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                        '{\n  "title": "Test Post",\n  "body": "...",\n  "userId": 1\n}'),
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
                        : () => _runBasicPostTest(clientType: ClientType.http),
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
                        : () => _runBasicPostTest(clientType: ClientType.dio),
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
