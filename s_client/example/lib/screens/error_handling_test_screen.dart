import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:s_client/s_client.dart';
import 'package:s_client_example/widgets/response_viewer.dart';

class ErrorHandlingTestScreen extends StatefulWidget {
  const ErrorHandlingTestScreen({super.key});

  @override
  State<ErrorHandlingTestScreen> createState() =>
      _ErrorHandlingTestScreenState();
}

class _ErrorHandlingTestScreenState extends State<ErrorHandlingTestScreen> {
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
  String _selectedTest = 'invalid_url';

  final Map<String, _TestScenario> _testScenarios = {
    'invalid_url': const _TestScenario(
      name: 'Invalid URL',
      description: 'Test with a malformed/invalid URL',
      url: 'https://this-domain-does-not-exist-12345.com/api',
      body: {'test': 'data'},
    ),
    'status_404': const _TestScenario(
      name: 'HTTP 404 Error',
      description: 'Request to a non-existent endpoint',
      url: 'https://httpbin.org/status/404',
      body: {'test': 'data'},
    ),
    'status_500': const _TestScenario(
      name: 'HTTP 500 Error',
      description: 'Server error simulation',
      url: 'https://httpbin.org/status/500',
      body: {'test': 'data'},
    ),
    'status_401': const _TestScenario(
      name: 'HTTP 401 Unauthorized',
      description: 'Authentication error simulation',
      url: 'https://httpbin.org/status/401',
      body: {'test': 'data'},
    ),
    'timeout': const _TestScenario(
      name: 'Slow Response',
      description: 'Test with delayed response (3 seconds)',
      url: 'https://httpbin.org/delay/3',
      body: {'test': 'delayed request'},
    ),
  };

  Future<void> _runErrorTest({required ClientType clientType}) async {
    final scenario = _testScenarios[_selectedTest]!;
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
    final (response, error) = await SClient.instance.post(
      url: scenario.url,
      body: scenario.body,
      clientType: clientType,
    );
    stopwatch.stop();

    setState(() {
      if (isHttp) {
        _isLoadingHttp = false;
        _httpDuration = stopwatch.elapsedMilliseconds;
        if (error != null) {
          _httpError = 'ClientException: ${error.message}';
        } else if (response != null) {
          _httpStatusCode = response.statusCode;
          _httpResponseBody = _formatJson(response.body);
        }
      } else {
        _isLoadingDio = false;
        _dioDuration = stopwatch.elapsedMilliseconds;
        if (error != null) {
          _dioError = 'ClientException: ${error.message}';
        } else if (response != null) {
          _dioStatusCode = response.statusCode;
          _dioResponseBody = _formatJson(response.body);
        }
      }
    });
  }

  Future<void> _runBothTests() async {
    await Future.wait([
      _runErrorTest(clientType: ClientType.http),
      _runErrorTest(clientType: ClientType.dio),
    ]);
  }

  String _formatJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (e) {
      return jsonString.isEmpty ? '(empty response)' : jsonString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Handling Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test: Error Handling',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test different error scenarios to see how http_handler handles them. '
              'The package returns errors as part of the tuple result.',
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Test Scenario:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    RadioGroup<String>(
                      groupValue: _selectedTest,
                      onChanged: (value) {
                        setState(() => _selectedTest = value!);
                      },
                      child: Column(
                        children: _testScenarios.entries
                            .map(
                              (e) => RadioListTile<String>(
                                title: Text(e.value.name),
                                subtitle: Text(e.value.description),
                                value: e.key,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                            )
                            .toList(),
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
                        : () => _runErrorTest(clientType: ClientType.http),
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
                        : () => _runErrorTest(clientType: ClientType.dio),
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

class _TestScenario {
  const _TestScenario({
    required this.name,
    required this.description,
    required this.url,
    required this.body,
  });

  final String name;
  final String description;
  final String url;
  final Map<String, dynamic> body;
}
