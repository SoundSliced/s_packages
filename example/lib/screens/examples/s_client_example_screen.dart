import 'package:s_packages/s_packages.dart';

class SClientExampleScreen extends StatefulWidget {
  const SClientExampleScreen({super.key});

  @override
  State<SClientExampleScreen> createState() => _SClientExampleScreenState();
}

class _SClientExampleScreenState extends State<SClientExampleScreen> {
  String _responseText = 'No request made yet';
  bool _isLoading = false;
  ClientType _selectedBackend = ClientType.http;

  @override
  void initState() {
    super.initState();
    // Configure s_client with default backend
    SClient.configure(
      ClientConfig(
        clientType: _selectedBackend,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  Future<void> _makeGetRequest() async {
    setState(() {
      _isLoading = true;
      _responseText = 'Loading...';
    });

    // Make a GET request - returns (response, error) tuple
    // Never throws! Safe by design.
    final (response, error) = await SClient.instance.get(
      url: 'https://jsonplaceholder.typicode.com/posts/1',
      clientType: _selectedBackend,
      onSuccess: (response) {
        debugPrint('Request succeeded');
      },
      onError: (error) {
        debugPrint('Request failed: ${error.message}');
      },
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (error != null) {
        _responseText = 'Error: ${error.message}\n\n'
            'Type: ${error.type}\n'
            'Is timeout: ${error.isTimeout}\n'
            'Is connection error: ${error.isConnectionError}';
      } else if (response != null) {
        _responseText = 'Success! (${response.statusCode})\n\n'
            'Backend: ${_selectedBackend.name}\n\n'
            'Response:\n${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...';
      }
    });
  }

  Future<void> _makePostRequest() async {
    setState(() {
      _isLoading = true;
      _responseText = 'Posting...';
    });

    final (response, error) = await SClient.instance.post(
      url: 'https://jsonplaceholder.typicode.com/posts',
      body: {
        'title': 'Test Post',
        'body': 'This is a test from s_client',
        'userId': 1,
      },
      clientType: _selectedBackend,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (error != null) {
        _responseText = 'Error: ${error.message}';
      } else if (response != null) {
        _responseText = 'POST Success! (${response.statusCode})\n\n'
            'Backend: ${_selectedBackend.name}\n\n'
            'Created:\n${response.body}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('s_client Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'HTTP Client Backend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'One API, two backends - switch between http and dio',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Backend selector
            SegmentedButton<ClientType>(
              segments: const [
                ButtonSegment(
                  value: ClientType.http,
                  label: Text('HTTP'),
                  icon: Icon(Icons.http),
                ),
                ButtonSegment(
                  value: ClientType.dio,
                  label: Text('Dio'),
                  icon: Icon(Icons.rocket_launch),
                ),
              ],
              selected: {_selectedBackend},
              onSelectionChanged: (Set<ClientType> selection) {
                setState(() {
                  _selectedBackend = selection.first;
                  SClient.configure(
                    ClientConfig(clientType: _selectedBackend),
                  );
                });
              },
            ),

            const SizedBox(height: 24),

            // GET Request button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _makeGetRequest,
              icon: const Icon(Icons.download),
              label: const Text('GET Request (JSONPlaceholder)'),
            ),

            const SizedBox(height: 12),

            // POST Request button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _makePostRequest,
              icon: const Icon(Icons.upload),
              label: const Text('POST Request (JSONPlaceholder)'),
            ),

            const SizedBox(height: 12),

            // PUT Request button (typed)
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() {
                        _isLoading = true;
                        _responseText = 'PUT request...';
                      });
                      await SClient.instance.putJson<Map<String, dynamic>>(
                        url: 'https://jsonplaceholder.typicode.com/posts/1',
                        body: {
                          'id': 1,
                          'title': 'Updated Title',
                          'body': 'Updated body via putJson',
                          'userId': 1,
                        },
                        fromJson: (json) => json,
                        onSuccess: (data, response) {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                              _responseText =
                                  'PUT Success (${response.statusCode})!\n\n${data.toString()}';
                            });
                          }
                        },
                        onError: (error) {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                              _responseText = 'PUT Error: ${error.message}';
                            });
                          }
                        },
                      );
                    },
              icon: const Icon(Icons.edit),
              label: const Text('PUT Request (typed)'),
            ),

            const SizedBox(height: 24),

            // Response display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              constraints: const BoxConstraints(minHeight: 200),
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading...'),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Text(
                        _responseText,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // Info section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🛡️ Safe by Default',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'All requests are wrapped in try-catch internally. '
                    'No runtime crashes, ever! Returns (response, error) tuple.',
                    style: TextStyle(fontSize: 14),
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
