import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:s_client/s_client.dart';

class JsonResponseTestScreen extends StatefulWidget {
  const JsonResponseTestScreen({super.key});

  @override
  State<JsonResponseTestScreen> createState() => _JsonResponseTestScreenState();
}

class _JsonResponseTestScreenState extends State<JsonResponseTestScreen> {
  bool _isLoadingHttp = false;
  bool _isLoadingDio = false;
  Map<String, dynamic>? _httpParsedData;
  Map<String, dynamic>? _dioParsedData;
  String? _httpError;
  String? _dioError;
  int? _httpDuration;
  int? _dioDuration;

  Future<void> _runJsonParseTest({required ClientType clientType}) async {
    final isHttp = clientType == ClientType.http;
    setState(() {
      if (isHttp) {
        _isLoadingHttp = true;
        _httpParsedData = null;
        _httpError = null;
        _httpDuration = null;
      } else {
        _isLoadingDio = true;
        _dioParsedData = null;
        _dioError = null;
        _dioDuration = null;
      }
    });

    final stopwatch = Stopwatch()..start();

    // Using httpbin.org which returns comprehensive JSON response
    final (response, error) = await SClient.instance.post(
      url: 'https://httpbin.org/post',
      body: {
        'name': 'John Doe',
        'email': 'john@example.com',
        'age': 30,
        'preferences': {
          'newsletter': true,
          'notifications': false,
        },
        'tags': ['developer', 'flutter', 'dart'],
      },
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
          try {
            _httpParsedData = jsonDecode(response.body) as Map<String, dynamic>;
          } catch (e) {
            _httpError = 'Failed to parse JSON: $e';
          }
        }
      } else {
        _isLoadingDio = false;
        _dioDuration = stopwatch.elapsedMilliseconds;
        if (error != null) {
          _dioError = error.message;
        } else if (response != null) {
          try {
            _dioParsedData = jsonDecode(response.body) as Map<String, dynamic>;
          } catch (e) {
            _dioError = 'Failed to parse JSON: $e';
          }
        }
      }
    });
  }

  Future<void> _runBothTests() async {
    await Future.wait([
      _runJsonParseTest(clientType: ClientType.http),
      _runJsonParseTest(clientType: ClientType.dio),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON Response Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test: JSON Response Parsing',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This test demonstrates parsing JSON responses into Dart objects. '
              'The response is parsed and displayed in a structured format.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingHttp
                        ? null
                        : () => _runJsonParseTest(clientType: ClientType.http),
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
                        : () => _runJsonParseTest(clientType: ClientType.dio),
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
                          child: _buildResultsPanel(
                            parsedData: _httpParsedData,
                            error: _httpError,
                            isLoading: _isLoadingHttp,
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
                          child: _buildResultsPanel(
                            parsedData: _dioParsedData,
                            error: _dioError,
                            isLoading: _isLoadingDio,
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

  Widget _buildResultsPanel({
    required Map<String, dynamic>? parsedData,
    required String? error,
    required bool isLoading,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Card(
        color: Colors.red[50],
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.error, color: Colors.red[700], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Error',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(error, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      );
    }

    if (parsedData == null) {
      return const Center(
        child: Text(
          'Run test',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSection(
            title: 'Request Data',
            icon: Icons.upload,
            child: _buildJsonTree(parsedData['json']),
          ),
          const SizedBox(height: 8),
          _buildSection(
            title: 'Origin',
            icon: Icons.language,
            child: Text(
              parsedData['origin'] ?? 'N/A',
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildJsonTree(dynamic data, {int indent = 0}) {
    if (data == null) {
      return const Text('null', style: TextStyle(color: Colors.grey));
    }

    if (data is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((e) {
          return Padding(
            padding: EdgeInsets.only(left: indent * 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${e.key}: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Expanded(
                  child: e.value is Map || e.value is List
                      ? _buildJsonTree(e.value, indent: indent + 1)
                      : Text(
                          '${e.value}',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: _getValueColor(e.value),
                          ),
                        ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    if (data is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.asMap().entries.map((e) {
          return Padding(
            padding: EdgeInsets.only(left: indent * 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[${e.key}] ',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: e.value is Map || e.value is List
                      ? _buildJsonTree(e.value, indent: indent + 1)
                      : Text(
                          '${e.value}',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: _getValueColor(e.value),
                          ),
                        ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Text('$data');
  }

  Color _getValueColor(dynamic value) {
    if (value is String) return Colors.green[700]!;
    if (value is num) return Colors.blue[700]!;
    if (value is bool) return Colors.orange[700]!;
    return Colors.black;
  }
}
