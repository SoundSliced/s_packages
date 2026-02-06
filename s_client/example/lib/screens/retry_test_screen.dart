import 'package:flutter/material.dart';
import 'package:s_client/s_client.dart';

class RetryTestScreen extends StatefulWidget {
  const RetryTestScreen({super.key});

  @override
  State<RetryTestScreen> createState() => _RetryTestScreenState();
}

class _RetryTestScreenState extends State<RetryTestScreen> {
  bool _isLoading = false;
  final List<_RetryAttempt> _attempts = [];
  int _maxRetries = 3;
  String _selectedScenario = 'success';
  String _result = '';
  ClientType _selectedClientType = ClientType.http;

  final Map<String, _RetryScenario> _scenarios = {
    'success': const _RetryScenario(
      name: 'Successful Request',
      description: 'Request succeeds on first try',
      url: 'https://httpbin.org/post',
    ),
    'server_error': const _RetryScenario(
      name: 'Server Error (500)',
      description: 'Simulates server error with retries',
      url: 'https://httpbin.org/status/500',
    ),
    'timeout': const _RetryScenario(
      name: 'Slow Response',
      description: 'Tests retry on slow responses',
      url: 'https://httpbin.org/delay/5',
    ),
  };

  Future<void> _runRetryTest() async {
    setState(() {
      _isLoading = true;
      _attempts.clear();
      _result = '';
    });

    int attemptCount = 0;

    // Configure Client with retry settings
    SClient.configure(
      ClientConfig(
        clientType: _selectedClientType,
        maxRetries: _maxRetries,
        retryDelay: const Duration(milliseconds: 500),
        exponentialBackoff: true,
        retryStatusCodes: {500, 502, 503, 504},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        interceptors: [
          LoggingInterceptor(
            logRequestHeaders: false,
            logResponseBody: false,
            logger: (message) {
              if (message.contains('→ POST') || message.contains('→ GET')) {
                attemptCount++;
                final now = DateTime.now();
                setState(() {
                  _attempts.add(_RetryAttempt(
                    number: attemptCount,
                    startTime: now,
                    status: 'Sending request...',
                    isSuccess: null,
                  ));
                });
              } else if (message.contains('← ') && _attempts.isNotEmpty) {
                final now = DateTime.now();
                final lastAttempt = _attempts.last;
                final isError = message.contains('500') ||
                    message.contains('502') ||
                    message.contains('503') ||
                    message.contains('504');
                setState(() {
                  _attempts[_attempts.length - 1] = _RetryAttempt(
                    number: lastAttempt.number,
                    startTime: lastAttempt.startTime,
                    duration: now.difference(lastAttempt.startTime),
                    status: isError ? 'Server error (will retry)' : 'Success!',
                    isSuccess: !isError,
                  );
                });
              }
            },
          ),
        ],
      ),
    );

    final stopwatch = Stopwatch()..start();

    final (response, error) = await SClient.instance.post(
      url: _scenarios[_selectedScenario]!.url,
      body: {
        'test': 'retry',
        'maxRetries': _maxRetries,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    stopwatch.stop();

    setState(() {
      _isLoading = false;
      if (error != null) {
        _result = '''
❌ Request Failed (${_selectedClientType.name.toUpperCase()} backend)

Error Type: ${error.type.name}
Message: ${error.message}

Total Attempts: ${_attempts.length}
Total Duration: ${stopwatch.elapsedMilliseconds}ms
''';
      } else if (response != null) {
        _result = '''
✅ Request Succeeded (${_selectedClientType.name.toUpperCase()} backend)

Status Code: ${response.statusCode}
Request Duration: ${response.requestDuration ?? 0}ms

Total Attempts: ${_attempts.length}
Total Duration: ${stopwatch.elapsedMilliseconds}ms
${response.isFromCache ? '\n📦 Response was from cache' : ''}
''';
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error != null
                ? 'All ${_attempts.length} attempts failed'
                : 'Request completed with status ${response?.statusCode}',
          ),
          backgroundColor: error != null || (response?.statusCode ?? 500) >= 400
              ? Colors.red
              : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retry with Backoff'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test: Automatic Retry with Exponential Backoff',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Demonstrates automatic retry functionality with configurable attempts '
              'and exponential backoff between retries.',
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Configuration:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Max Retries: '),
                        Expanded(
                          child: Slider(
                            value: _maxRetries.toDouble(),
                            min: 0,
                            max: 5,
                            divisions: 5,
                            label: _maxRetries.toString(),
                            onChanged: (value) {
                              setState(() => _maxRetries = value.round());
                            },
                          ),
                        ),
                        Text(_maxRetries.toString()),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Scenario:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    RadioGroup<String>(
                      groupValue: _selectedScenario,
                      onChanged: (value) {
                        setState(() => _selectedScenario = value!);
                      },
                      child: Column(
                        children: _scenarios.entries
                            .map((e) => RadioListTile<String>(
                                  title: Text(e.value.name),
                                  subtitle: Text(e.value.description),
                                  value: e.key,
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                ))
                            .toList(),
                      ),
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
                              setState(
                                  () => _selectedClientType = ClientType.http);
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
                              setState(
                                  () => _selectedClientType = ClientType.dio);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runRetryTest,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _selectedClientType == ClientType.http
                          ? Icons.http
                          : Icons.rocket_launch,
                    ),
              label: Text(_isLoading
                  ? 'Running...'
                  : 'Run Retry Test (${_selectedClientType.name.toUpperCase()})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedClientType == ClientType.http
                    ? Colors.blue.shade100
                    : Colors.green.shade100,
              ),
            ),
            const SizedBox(height: 16),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _result.contains('❌')
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _result.contains('❌')
                        ? Colors.red.shade200
                        : Colors.green.shade200,
                  ),
                ),
                child: Text(
                  _result,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Attempt Log:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _attempts.isEmpty
                  ? const Center(
                      child: Text(
                        'Run the test to see retry attempts',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _attempts.length,
                      itemBuilder: (context, index) {
                        final attempt = _attempts[index];
                        return _AttemptCard(attempt: attempt);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RetryScenario {
  const _RetryScenario({
    required this.name,
    required this.description,
    required this.url,
  });

  final String name;
  final String description;
  final String url;
}

class _RetryAttempt {
  const _RetryAttempt({
    required this.number,
    required this.startTime,
    this.duration,
    required this.status,
    required this.isSuccess,
  });

  final int number;
  final DateTime startTime;
  final Duration? duration;
  final String status;
  final bool? isSuccess;
}

class _AttemptCard extends StatelessWidget {
  const _AttemptCard({required this.attempt});

  final _RetryAttempt attempt;

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    IconData icon;

    if (attempt.isSuccess == null) {
      backgroundColor = Colors.blue[50];
      icon = Icons.hourglass_empty;
    } else if (attempt.isSuccess!) {
      backgroundColor = Colors.green[50];
      icon = Icons.check_circle;
    } else {
      backgroundColor = Colors.red[50];
      icon = Icons.error;
    }

    return Card(
      color: backgroundColor,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              icon,
              color: attempt.isSuccess == null
                  ? Colors.blue
                  : attempt.isSuccess!
                      ? Colors.green
                      : Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attempt #${attempt.number}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(attempt.status),
                  if (attempt.duration != null)
                    Text(
                      'Duration: ${attempt.duration!.inMilliseconds}ms',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
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
