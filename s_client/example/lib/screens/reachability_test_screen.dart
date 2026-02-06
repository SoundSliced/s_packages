import 'package:flutter/material.dart';
import 'package:s_client/s_client.dart';

class ReachabilityTestScreen extends StatefulWidget {
  const ReachabilityTestScreen({super.key});

  @override
  State<ReachabilityTestScreen> createState() => _ReachabilityTestScreenState();
}

class _ReachabilityTestScreenState extends State<ReachabilityTestScreen> {
  bool _isLoading = false;
  final List<_UrlCheckResult> _results = [];
  final _urlController = TextEditingController();

  final List<String> _predefinedUrls = [
    'https://www.google.com',
    'https://jsonplaceholder.typicode.com',
    'https://httpbin.org',
    'https://api.github.com',
    'https://this-does-not-exist-12345.com',
    'https://httpbin.org/status/404',
    'https://httpbin.org/status/500',
  ];

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _checkUrl(String url, {required ClientType clientType}) async {
    setState(() {
      _results.add(_UrlCheckResult(
        url: url,
        status: CheckStatus.checking,
        clientType: clientType,
      ));
    });

    final stopwatch = Stopwatch()..start();
    final isReachable = await SClient.instance.isReachable(
      url,
      clientType: clientType,
    );
    stopwatch.stop();

    setState(() {
      final index = _results.indexWhere(
        (r) =>
            r.url == url &&
            r.status == CheckStatus.checking &&
            r.clientType == clientType,
      );
      if (index != -1) {
        _results[index] = _UrlCheckResult(
          url: url,
          isReachable: isReachable,
          status: CheckStatus.done,
          clientType: clientType,
          durationMs: stopwatch.elapsedMilliseconds,
        );
      }
    });
  }

  Future<void> _checkUrlBoth(String url) async {
    await Future.wait([
      _checkUrl(url, clientType: ClientType.http),
      _checkUrl(url, clientType: ClientType.dio),
    ]);
  }

  Future<void> _checkAllPredefined() async {
    setState(() {
      _isLoading = true;
      _results.clear();
    });

    for (final url in _predefinedUrls) {
      await _checkUrlBoth(url);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkCustomUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL must start with http:// or https://'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await _checkUrlBoth(url);
    _urlController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reachability Check'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => setState(() => _results.clear()),
            tooltip: 'Clear results',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test: URL Reachability',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check if URLs are reachable using HEAD requests. '
              'This is useful for validating endpoints before making full requests.',
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Check Custom URL:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _urlController,
                            decoration: const InputDecoration(
                              hintText: 'https://example.com',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onSubmitted: (_) => _checkCustomUrl(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _checkCustomUrl,
                          child: const Icon(Icons.search),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkAllPredefined,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi_find),
              label: Text(
                  _isLoading ? 'Checking...' : 'Check All Predefined URLs'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: _predefinedUrls.take(4).map((url) {
                final shortUrl =
                    url.replaceAll('https://', '').split('/').first;
                return Chip(
                  label: Text(shortUrl, style: const TextStyle(fontSize: 11)),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Results:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _results.isEmpty
                  ? const Center(
                      child: Text(
                        'Check URLs to see results',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final result = _results[index];
                        return _ResultCard(result: result);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

enum CheckStatus { checking, done }

class _UrlCheckResult {
  final String url;
  final bool? isReachable;
  final CheckStatus status;
  final ClientType clientType;
  final int? durationMs;

  _UrlCheckResult({
    required this.url,
    this.isReachable,
    required this.status,
    required this.clientType,
    this.durationMs,
  });
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final _UrlCheckResult result;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String statusText;

    if (result.status == CheckStatus.checking) {
      icon = Icons.hourglass_empty;
      color = Colors.blue;
      statusText = 'Checking...';
    } else if (result.isReachable == true) {
      icon = Icons.check_circle;
      color = Colors.green;
      statusText = 'Reachable';
    } else {
      icon = Icons.cancel;
      color = Colors.red;
      statusText = 'Not Reachable';
    }

    final isHttp = result.clientType == ClientType.http;
    final clientColor = isHttp ? Colors.blue : Colors.green;
    final clientLabel = isHttp ? 'HTTP' : 'Dio';
    final clientIcon = isHttp ? Icons.http : Icons.rocket_launch;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: result.status == CheckStatus.checking
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            : Icon(icon, color: color),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: clientColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(clientIcon, size: 12, color: clientColor),
                  const SizedBox(width: 4),
                  Text(
                    clientLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: clientColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                result.url,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            if (result.durationMs != null)
              Text(
                '${result.durationMs}ms',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
