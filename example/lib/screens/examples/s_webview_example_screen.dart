import 'package:s_webview/s_webview.dart';

class SWebviewExampleScreen extends StatefulWidget {
  const SWebviewExampleScreen({super.key});

  @override
  State<SWebviewExampleScreen> createState() => _SWebviewExampleScreenState();
}

class _SWebviewExampleScreenState extends State<SWebviewExampleScreen> {
  String currentUrl = 'https://flutter.dev';
  String? lastError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SWebView Example'),
      ),
      body: Column(
        children: [
          // URL selection buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Cross-platform WebView with loading states & error handling',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentUrl = 'https://flutter.dev';
                          lastError = null;
                        });
                      },
                      child: const Text('Flutter.dev'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentUrl = 'https://pub.dev';
                          lastError = null;
                        });
                      },
                      child: const Text('Pub.dev'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentUrl = 'https://github.com';
                          lastError = null;
                        });
                      },
                      child: const Text('GitHub'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Current: $currentUrl',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Error display
          if (lastError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lastError!,
                      style:
                          TextStyle(fontSize: 12, color: Colors.red.shade700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => lastError = null),
                  ),
                ],
              ),
            ),

          // WebView
          Expanded(
            child: SWebView(
              key: ValueKey(currentUrl),
              url: currentUrl,
              onError: (error) {
                if (mounted) {
                  setState(() => lastError = error);
                }
              },
              onIframeBlocked: () {
                if (mounted) {
                  setState(() {
                    lastError =
                        'Site blocks iframe embedding. Try "Open in Browser".';
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
