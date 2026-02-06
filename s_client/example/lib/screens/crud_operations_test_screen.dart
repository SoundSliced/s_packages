import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:s_client/s_client.dart';
import 'package:s_client_example/widgets/response_viewer.dart';

class CrudOperationsTestScreen extends StatefulWidget {
  const CrudOperationsTestScreen({super.key});

  @override
  State<CrudOperationsTestScreen> createState() =>
      _CrudOperationsTestScreenState();
}

class _CrudOperationsTestScreenState extends State<CrudOperationsTestScreen> {
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
  String _selectedMethod = 'PUT';

  final Map<String, _CrudOperation> _operations = {
    'PUT': const _CrudOperation(
      name: 'PUT (Full Update)',
      description: 'Replace entire resource',
      url: 'https://jsonplaceholder.typicode.com/posts/1',
      body: {
        'id': 1,
        'title': 'Updated Title (PUT)',
        'body': 'This is the completely updated body via PUT request',
        'userId': 1,
      },
    ),
    'PATCH': const _CrudOperation(
      name: 'PATCH (Partial Update)',
      description: 'Update specific fields only',
      url: 'https://jsonplaceholder.typicode.com/posts/1',
      body: {
        'title': 'Patched Title Only',
      },
    ),
    'DELETE': const _CrudOperation(
      name: 'DELETE',
      description: 'Remove a resource',
      url: 'https://jsonplaceholder.typicode.com/posts/1',
      body: null,
    ),
    'HEAD': const _CrudOperation(
      name: 'HEAD',
      description: 'Get headers without body',
      url: 'https://jsonplaceholder.typicode.com/posts/1',
      body: null,
    ),
  };

  Future<void> _runOperation({required ClientType clientType}) async {
    final operation = _operations[_selectedMethod]!;
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
    ClientResult result;

    switch (_selectedMethod) {
      case 'PUT':
        result = await SClient.instance.put(
          url: operation.url,
          body: operation.body!,
          clientType: clientType,
        );
        break;
      case 'PATCH':
        result = await SClient.instance.patch(
          url: operation.url,
          body: operation.body!,
          clientType: clientType,
        );
        break;
      case 'DELETE':
        result = await SClient.instance.delete(
          url: operation.url,
          clientType: clientType,
        );
        break;
      case 'HEAD':
        result = await SClient.instance.head(
          url: operation.url,
          clientType: clientType,
        );
        break;
      default:
        result = (null, null);
    }

    stopwatch.stop();
    final (response, error) = result;

    setState(() {
      if (isHttp) {
        _isLoadingHttp = false;
        _httpDuration = stopwatch.elapsedMilliseconds;
        if (error != null) {
          _httpError = error.message;
        } else if (response != null) {
          _httpStatusCode = response.statusCode;
          if (_selectedMethod == 'HEAD') {
            final headers = response.headers.entries
                .map((e) => '${e.key}: ${e.value}')
                .join('\n');
            _httpResponseBody = 'Response Headers:\n\n$headers';
          } else {
            _httpResponseBody = _formatJson(response.body);
          }
        }
      } else {
        _isLoadingDio = false;
        _dioDuration = stopwatch.elapsedMilliseconds;
        if (error != null) {
          _dioError = error.message;
        } else if (response != null) {
          _dioStatusCode = response.statusCode;
          if (_selectedMethod == 'HEAD') {
            final headers = response.headers.entries
                .map((e) => '${e.key}: ${e.value}')
                .join('\n');
            _dioResponseBody = 'Response Headers:\n\n$headers';
          } else {
            _dioResponseBody = _formatJson(response.body);
          }
        }
      }
    });
  }

  Future<void> _runBothOperations() async {
    await Future.wait([
      _runOperation(clientType: ClientType.http),
      _runOperation(clientType: ClientType.dio),
    ]);
  }

  String _formatJson(String jsonString) {
    if (jsonString.isEmpty) {
      return '(empty response - resource deleted)';
    }
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
        title: const Text('CRUD Operations Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test: PUT, PATCH, DELETE, HEAD',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test different HTTP methods for CRUD operations using JSONPlaceholder API.',
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select HTTP Method:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _operations.keys.map((method) {
                        return ChoiceChip(
                          label: Text(method),
                          selected: _selectedMethod == method,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedMethod = method);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _operations[_selectedMethod]!.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_operations[_selectedMethod]!.description),
                    const SizedBox(height: 8),
                    Text(
                      'URL: ${_operations[_selectedMethod]!.url}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                    if (_operations[_selectedMethod]!.body != null) ...[
                      const SizedBox(height: 8),
                      const Text('Body:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        const JsonEncoder.withIndent('  ')
                            .convert(_operations[_selectedMethod]!.body),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ],
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
                        : () => _runOperation(clientType: ClientType.http),
                    icon: _isLoadingHttp
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.http, size: 18),
                    label: Text('HTTP $_selectedMethod'),
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
                        : () => _runOperation(clientType: ClientType.dio),
                    icon: _isLoadingDio
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.rocket_launch, size: 18),
                    label: Text('Dio $_selectedMethod'),
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
                        : _runBothOperations,
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

class _CrudOperation {
  const _CrudOperation({
    required this.name,
    required this.description,
    required this.url,
    required this.body,
  });

  final String name;
  final String description;
  final String url;
  final Map<String, dynamic>? body;
}
