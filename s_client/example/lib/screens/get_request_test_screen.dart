import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:s_client/s_client.dart';
import 'package:s_client_example/widgets/response_viewer.dart';

class GetRequestTestScreen extends StatefulWidget {
  const GetRequestTestScreen({super.key});

  @override
  State<GetRequestTestScreen> createState() => _GetRequestTestScreenState();
}

class _GetRequestTestScreenState extends State<GetRequestTestScreen> {
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

  int _userId = 1;
  int _limit = 5;

  Future<void> _runGetTest({required ClientType clientType}) async {
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

    // Using the unified API with optional callbacks
    await SClient.instance.get(
      url: 'https://jsonplaceholder.typicode.com/posts',
      queryParameters: {
        'userId': _userId.toString(),
        '_limit': _limit.toString(),
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
      // Custom status code handling - e.g., handle 429 rate limiting
      onStatus: {
        429: (code, response) {
          stopwatch.stop();
          setState(() {
            if (isHttp) {
              _isLoadingHttp = false;
              _httpError = 'Rate limited! Please wait and try again.';
              _httpDuration = stopwatch.elapsedMilliseconds;
            } else {
              _isLoadingDio = false;
              _dioError = 'Rate limited! Please wait and try again.';
              _dioDuration = stopwatch.elapsedMilliseconds;
            }
          });
        },
      },
    );
  }

  Future<void> _runBothTests() async {
    await Future.wait([
      _runGetTest(clientType: ClientType.http),
      _runGetTest(clientType: ClientType.dio),
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
        title: const Text('GET Request Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test: GET Request with Query Parameters',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fetch posts from JSONPlaceholder API with customizable query parameters.',
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Query Parameters:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('User ID: '),
                        Expanded(
                          child: Slider(
                            value: _userId.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: _userId.toString(),
                            onChanged: (value) {
                              setState(() => _userId = value.round());
                            },
                          ),
                        ),
                        Text(_userId.toString()),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Limit: '),
                        Expanded(
                          child: Slider(
                            value: _limit.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: _limit.toString(),
                            onChanged: (value) {
                              setState(() => _limit = value.round());
                            },
                          ),
                        ),
                        Text(_limit.toString()),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'URL: https://jsonplaceholder.typicode.com/posts?userId=$_userId&_limit=$_limit',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
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
                        : () => _runGetTest(clientType: ClientType.http),
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
                        : () => _runGetTest(clientType: ClientType.dio),
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
