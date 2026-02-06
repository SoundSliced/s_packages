import 'package:flutter/material.dart';
import 'package:s_client/s_client.dart';

class InterceptorsTestScreen extends StatefulWidget {
  const InterceptorsTestScreen({super.key});

  @override
  State<InterceptorsTestScreen> createState() => _InterceptorsTestScreenState();
}

class _InterceptorsTestScreenState extends State<InterceptorsTestScreen> {
  final List<String> _logs = [];
  String _result = '';
  bool _isLoading = false;
  bool _loggingEnabled = true;
  bool _cachingEnabled = true;
  bool _authEnabled = false;
  ClientType _selectedClientType = ClientType.http;

  late CacheInterceptor _cacheInterceptor;

  @override
  void initState() {
    super.initState();
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _cacheInterceptor = CacheInterceptor(
      defaultMaxAge: const Duration(seconds: 30),
      maxEntries: 50,
    );

    final interceptors = <ClientInterceptor>[];

    if (_loggingEnabled) {
      interceptors.add(LoggingInterceptor(
        logRequestHeaders: true,
        logResponseBody: true,
        maxBodyLength: 500,
        logger: (message) {
          if (!mounted) return;
          setState(() {
            _logs.add(
                '[${DateTime.now().toString().split('.').first}] $message');
            // Keep only last 100 logs
            if (_logs.length > 100) {
              _logs.removeAt(0);
            }
          });
        },
      ));
    }

    if (_authEnabled) {
      interceptors.add(AuthInterceptor(
        authType: AuthType.bearer,
        tokenProvider: () => 'demo-token-12345',
        onUnauthorized: () async {
          if (!mounted) return false;
          setState(() {
            _logs.add('⚠️ UNAUTHORIZED - Token refresh needed');
          });
          return false;
        },
      ));
    }

    if (_cachingEnabled) {
      interceptors.add(_cacheInterceptor);
    }

    SClient.configure(
      ClientConfig(
        clientType: _selectedClientType,
        interceptors: interceptors,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }

  Future<void> _testLogging() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    final (response, error) = await SClient.instance.get(
      url: 'https://jsonplaceholder.typicode.com/posts/1',
    );

    setState(() {
      _isLoading = false;
      if (error != null) {
        _result = 'Error: ${error.message}';
      } else if (response != null) {
        _result = '''
✅ Request completed successfully!
Status: ${response.statusCode}
From Cache: ${response.isFromCache}
Duration: ${response.requestDuration ?? 0}ms

Check the logs below to see interceptor activity.
''';
      }
    });
  }

  Future<void> _testCaching() async {
    setState(() {
      _logs.add('--- Starting Cache Test ---');
      _isLoading = true;
      _result = '';
    });

    // First request - should be fresh
    final stopwatch1 = Stopwatch()..start();
    final (response1, _) = await SClient.instance.get(
      url: 'https://jsonplaceholder.typicode.com/users/1',
    );
    stopwatch1.stop();

    setState(() {
      _logs.add(
          '1st request: ${stopwatch1.elapsedMilliseconds}ms (from cache: ${response1?.isFromCache})');
    });

    // Second request - should be from cache
    final stopwatch2 = Stopwatch()..start();
    final (response2, _) = await SClient.instance.get(
      url: 'https://jsonplaceholder.typicode.com/users/1',
    );
    stopwatch2.stop();

    setState(() {
      _logs.add(
          '2nd request: ${stopwatch2.elapsedMilliseconds}ms (from cache: ${response2?.isFromCache})');
    });

    // Third request - should be from cache
    final stopwatch3 = Stopwatch()..start();
    final (response3, _) = await SClient.instance.get(
      url: 'https://jsonplaceholder.typicode.com/users/1',
    );
    stopwatch3.stop();

    setState(() {
      _isLoading = false;
      _logs.add(
          '3rd request: ${stopwatch3.elapsedMilliseconds}ms (from cache: ${response3?.isFromCache})');
      _result = '''
🗄️ Cache Test Results:

1st Request: ${stopwatch1.elapsedMilliseconds}ms (${response1?.isFromCache == true ? 'CACHED' : 'FRESH'})
2nd Request: ${stopwatch2.elapsedMilliseconds}ms (${response2?.isFromCache == true ? 'CACHED' : 'FRESH'})
3rd Request: ${stopwatch3.elapsedMilliseconds}ms (${response3?.isFromCache == true ? 'CACHED' : 'FRESH'})

${_cachingEnabled ? 'Cache is ENABLED - 2nd and 3rd requests should be faster' : 'Cache is DISABLED - all requests go to server'}

Cache speedup: ${stopwatch1.elapsedMilliseconds > 0 ? ((1 - stopwatch2.elapsedMilliseconds / stopwatch1.elapsedMilliseconds) * 100).toStringAsFixed(1) : 0}% faster
''';
    });
  }

  Future<void> _testAuth() async {
    setState(() {
      _isLoading = true;
      _result = '';
      _logs.add('--- Starting Auth Test ---');
    });

    final (response, error) = await SClient.instance.get(
      url: 'https://jsonplaceholder.typicode.com/posts/1',
    );

    setState(() {
      _isLoading = false;
      if (error != null) {
        _result = 'Error: ${error.message}';
      } else if (response != null) {
        _result = '''
🔐 Auth Interceptor Test

${_authEnabled ? '✅ Auth is ENABLED' : '⚠️ Auth is DISABLED'}

${_authEnabled ? 'Authorization header was added to the request.\nCheck the logs to see the Bearer token being injected.' : 'Enable Auth toggle to test token injection.'}

Status: ${response.statusCode}
''';
      }
    });
  }

  Future<void> _testMultipleInterceptors() async {
    setState(() {
      _isLoading = true;
      _result = '';
      _logs.add('--- Testing Multiple Interceptors Chain ---');
    });

    // Make several requests to show the interceptor chain in action
    final endpoints = [
      'https://jsonplaceholder.typicode.com/posts/1',
      'https://jsonplaceholder.typicode.com/users/1',
      'https://jsonplaceholder.typicode.com/comments/1',
    ];

    final results = <String>[];

    for (final url in endpoints) {
      final stopwatch = Stopwatch()..start();
      final (response, error) = await SClient.instance.get(url: url);
      stopwatch.stop();

      results.add(
        '${url.split('/').last}: ${response?.statusCode ?? 'ERROR'} (${stopwatch.elapsedMilliseconds}ms)',
      );
    }

    setState(() {
      _isLoading = false;
      _result = '''
🔗 Interceptor Chain Test

Active Interceptors:
${_loggingEnabled ? '  ✅ LoggingInterceptor' : '  ❌ LoggingInterceptor'}
${_authEnabled ? '  ✅ AuthInterceptor' : '  ❌ AuthInterceptor'}
${_cachingEnabled ? '  ✅ CacheInterceptor' : '  ❌ CacheInterceptor'}

Results:
${results.map((r) => '  • $r').join('\n')}

Check the logs below to see each interceptor processing requests in order.
''';
    });
  }

  void _clearCache() {
    _cacheInterceptor.clearCache();
    setState(() {
      _logs.add('🗑️ Cache cleared!');
      _result = 'Cache has been cleared. Next request will fetch fresh data.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interceptors Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => setState(() => _logs.clear()),
            tooltip: 'Clear Logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Controls section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Interceptor Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Logging'),
                      selected: _loggingEnabled,
                      onSelected: (value) {
                        setState(() {
                          _loggingEnabled = value;
                          _setupInterceptors();
                        });
                      },
                      avatar: Icon(
                        _loggingEnabled
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: 18,
                      ),
                    ),
                    FilterChip(
                      label: const Text('Caching'),
                      selected: _cachingEnabled,
                      onSelected: (value) {
                        setState(() {
                          _cachingEnabled = value;
                          _setupInterceptors();
                        });
                      },
                      avatar: Icon(
                        _cachingEnabled ? Icons.cached : Icons.sync_disabled,
                        size: 18,
                      ),
                    ),
                    FilterChip(
                      label: const Text('Auth'),
                      selected: _authEnabled,
                      onSelected: (value) {
                        setState(() {
                          _authEnabled = value;
                          _setupInterceptors();
                        });
                      },
                      avatar: Icon(
                        _authEnabled ? Icons.lock : Icons.lock_open,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Backend:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.http,
                            size: 16,
                            color: _selectedClientType == ClientType.http
                                ? Colors.white
                                : Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          const Text('HTTP'),
                        ],
                      ),
                      selected: _selectedClientType == ClientType.http,
                      selectedColor: Colors.blue,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedClientType = ClientType.http;
                            _setupInterceptors();
                          });
                        }
                      },
                    ),
                    ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.rocket_launch,
                            size: 16,
                            color: _selectedClientType == ClientType.dio
                                ? Colors.white
                                : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          const Text('Dio'),
                        ],
                      ),
                      selected: _selectedClientType == ClientType.dio,
                      selectedColor: Colors.green,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedClientType = ClientType.dio;
                            _setupInterceptors();
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testLogging,
                      icon: const Icon(Icons.article, size: 18),
                      label: const Text('Test Logging'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testCaching,
                      icon: const Icon(Icons.cached, size: 18),
                      label: const Text('Test Cache'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testAuth,
                      icon: const Icon(Icons.key, size: 18),
                      label: const Text('Test Auth'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testMultipleInterceptors,
                      icon: const Icon(Icons.link, size: 18),
                      label: const Text('Test Chain'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _clearCache,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Clear Cache'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Result section
          if (_result.isNotEmpty || _isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Text(
                      _result,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
            ),

          // Logs section
          Expanded(
            child: Container(
              color: Colors.grey.shade900,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.grey.shade800,
                    child: Row(
                      children: [
                        const Icon(Icons.terminal,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Interceptor Logs',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_logs.length} entries',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _logs.isEmpty
                        ? Center(
                            child: Text(
                              'No logs yet. Run a test to see interceptor activity.',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              final log = _logs[_logs.length - 1 - index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  log,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: log.contains('ERROR') ||
                                            log.contains('⚠️')
                                        ? Colors.red.shade300
                                        : log.contains('✅') ||
                                                log.contains('200')
                                            ? Colors.green.shade300
                                            : log.contains('→') ||
                                                    log.contains('Request')
                                                ? Colors.blue.shade300
                                                : log.contains('←') ||
                                                        log.contains('Response')
                                                    ? Colors.yellow.shade300
                                                    : Colors.grey.shade300,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
