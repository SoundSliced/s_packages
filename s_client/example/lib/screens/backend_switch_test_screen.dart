import 'package:flutter/material.dart';
import 'package:s_client/s_client.dart';

class BackendSwitchTestScreen extends StatefulWidget {
  const BackendSwitchTestScreen({super.key});

  @override
  State<BackendSwitchTestScreen> createState() =>
      _BackendSwitchTestScreenState();
}

class _BackendSwitchTestScreenState extends State<BackendSwitchTestScreen> {
  String _httpResult = '';
  String _dioResult = '';
  bool _isLoadingHttp = false;
  bool _isLoadingDio = false;
  final List<_ComparisonResult> _comparisons = [];

  @override
  void initState() {
    super.initState();
    // Initialize with http as default backend
    SClient.configure(
      const ClientConfig(
        clientType: ClientType.http,
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
      ),
    );
  }

  Future<void> _testWithHttpBackend() async {
    setState(() {
      _isLoadingHttp = true;
      _httpResult = '';
    });

    final stopwatch = Stopwatch()..start();

    final (response, error) = await SClient.instance.get(
      url: 'https://jsonplaceholder.typicode.com/posts/1',
      clientType: ClientType.http, // Explicitly use http backend
    );

    stopwatch.stop();

    setState(() {
      _isLoadingHttp = false;
      if (error != null) {
        _httpResult = 'Error: ${error.message}';
      } else if (response != null) {
        _httpResult = '''
Backend: HTTP Package
Status: ${response.statusCode}
Duration: ${stopwatch.elapsedMilliseconds}ms
From Cache: ${response.isFromCache}
Body Preview: ${response.body.substring(0, response.body.length.clamp(0, 100))}...
''';
      }
    });
  }

  Future<void> _testWithDioBackend() async {
    setState(() {
      _isLoadingDio = true;
      _dioResult = '';
    });

    final stopwatch = Stopwatch()..start();

    final (response, error) = await SClient.instance.get(
      url: 'https://jsonplaceholder.typicode.com/posts/1',
      clientType: ClientType.dio, // Explicitly use dio backend
    );

    stopwatch.stop();

    setState(() {
      _isLoadingDio = false;
      if (error != null) {
        _dioResult = 'Error: ${error.message}';
      } else if (response != null) {
        _dioResult = '''
Backend: Dio Package
Status: ${response.statusCode}
Duration: ${stopwatch.elapsedMilliseconds}ms
From Cache: ${response.isFromCache}
Body Preview: ${response.body.substring(0, response.body.length.clamp(0, 100))}...
''';
      }
    });
  }

  Future<void> _runComparisonTest() async {
    final endpoints = [
      ('GET Posts', 'https://jsonplaceholder.typicode.com/posts'),
      ('GET Users', 'https://jsonplaceholder.typicode.com/users'),
      (
        'GET Comments',
        'https://jsonplaceholder.typicode.com/comments?postId=1'
      ),
    ];

    setState(() {
      _comparisons.clear();
    });

    for (final (name, url) in endpoints) {
      // Test with HTTP
      final httpStopwatch = Stopwatch()..start();
      final (httpResponse, httpError) = await SClient.instance.get(
        url: url,
        clientType: ClientType.http,
      );
      httpStopwatch.stop();

      // Test with Dio
      final dioStopwatch = Stopwatch()..start();
      final (dioResponse, dioError) = await SClient.instance.get(
        url: url,
        clientType: ClientType.dio,
      );
      dioStopwatch.stop();

      setState(() {
        _comparisons.add(_ComparisonResult(
          name: name,
          httpTime: httpStopwatch.elapsedMilliseconds,
          dioTime: dioStopwatch.elapsedMilliseconds,
          httpSuccess: httpError == null && httpResponse?.isSuccess == true,
          dioSuccess: dioError == null && dioResponse?.isSuccess == true,
          httpStatusCode: httpResponse?.statusCode,
          dioStatusCode: dioResponse?.statusCode,
        ));
      });
    }
  }

  Future<void> _testPostWithBothBackends() async {
    final testData = {
      'title': 'Test Post',
      'body': 'This is a test post body',
      'userId': 1,
    };

    // HTTP Backend POST
    final httpStopwatch = Stopwatch()..start();
    final (httpResponse, httpError) = await SClient.instance.post(
      url: 'https://jsonplaceholder.typicode.com/posts',
      body: testData,
      clientType: ClientType.http,
    );
    httpStopwatch.stop();

    // Dio Backend POST
    final dioStopwatch = Stopwatch()..start();
    final (dioResponse, dioError) = await SClient.instance.post(
      url: 'https://jsonplaceholder.typicode.com/posts',
      body: testData,
      clientType: ClientType.dio,
    );
    dioStopwatch.stop();

    setState(() {
      _comparisons.add(_ComparisonResult(
        name: 'POST Create',
        httpTime: httpStopwatch.elapsedMilliseconds,
        dioTime: dioStopwatch.elapsedMilliseconds,
        httpSuccess: httpError == null && httpResponse?.statusCode == 201,
        dioSuccess: dioError == null && dioResponse?.statusCode == 201,
        httpStatusCode: httpResponse?.statusCode,
        dioStatusCode: dioResponse?.statusCode,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Switch Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Backend Comparison',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Compare HTTP and Dio backends side by side. '
              'Each method can override the default backend by passing clientType.',
            ),
            const SizedBox(height: 24),

            // Side by side test buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingHttp ? null : _testWithHttpBackend,
                    icon: _isLoadingHttp
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.http),
                    label: const Text('Test HTTP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade100,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingDio ? null : _testWithDioBackend,
                    icon: _isLoadingDio
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.rocket_launch),
                    label: const Text('Test Dio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Results side by side
            if (_httpResult.isNotEmpty || _dioResult.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_httpResult.isNotEmpty)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          _httpResult,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                  if (_httpResult.isNotEmpty && _dioResult.isNotEmpty)
                    const SizedBox(width: 8),
                  if (_dioResult.isNotEmpty)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          _dioResult,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                ],
              ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            const Text(
              'Batch Comparison',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Run multiple requests with both backends and compare performance.',
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _runComparisonTest,
                    icon: const Icon(Icons.compare_arrows),
                    label: const Text('Run GET Comparison'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testPostWithBothBackends,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add POST Test'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_comparisons.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Endpoint',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'HTTP',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Dio',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: 60, child: Text('Winner')),
                        ],
                      ),
                    ),
                    ..._comparisons.map((result) => Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(result.name),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Icon(
                                      result.httpSuccess
                                          ? Icons.check_circle
                                          : Icons.error,
                                      color: result.httpSuccess
                                          ? Colors.green
                                          : Colors.red,
                                      size: 16,
                                    ),
                                    Text(
                                      '${result.httpTime}ms',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: result.httpTime < result.dioTime
                                            ? Colors.green
                                            : null,
                                        fontWeight:
                                            result.httpTime < result.dioTime
                                                ? FontWeight.bold
                                                : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Icon(
                                      result.dioSuccess
                                          ? Icons.check_circle
                                          : Icons.error,
                                      color: result.dioSuccess
                                          ? Colors.green
                                          : Colors.red,
                                      size: 16,
                                    ),
                                    Text(
                                      '${result.dioTime}ms',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: result.dioTime < result.httpTime
                                            ? Colors.green
                                            : null,
                                        fontWeight:
                                            result.dioTime < result.httpTime
                                                ? FontWeight.bold
                                                : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  result.httpTime < result.dioTime
                                      ? 'HTTP'
                                      : result.dioTime < result.httpTime
                                          ? 'Dio'
                                          : 'Tie',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: result.httpTime < result.dioTime
                                        ? Colors.blue
                                        : result.dioTime < result.httpTime
                                            ? Colors.green
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => setState(() => _comparisons.clear()),
                icon: const Icon(Icons.clear),
                label: const Text('Clear Results'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ComparisonResult {
  final String name;
  final int httpTime;
  final int dioTime;
  final bool httpSuccess;
  final bool dioSuccess;
  final int? httpStatusCode;
  final int? dioStatusCode;

  _ComparisonResult({
    required this.name,
    required this.httpTime,
    required this.dioTime,
    required this.httpSuccess,
    required this.dioSuccess,
    this.httpStatusCode,
    this.dioStatusCode,
  });
}
