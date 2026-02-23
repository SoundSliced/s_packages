import 'package:s_packages/s_packages.dart';
import 'package:s_packages/s_webview/src/_s_webview/webview_controller/webview_controller.dart';

class SWebviewExampleScreen extends StatefulWidget {
  const SWebviewExampleScreen({super.key});

  @override
  State<SWebviewExampleScreen> createState() => _SWebviewExampleScreenState();
}

class _SWebviewExampleScreenState extends State<SWebviewExampleScreen> {
  late final WebViewController _controller;

  String currentUrl = 'https://pub.dev';
  String lastSeenUrl = 'https://pub.dev';
  String? lastError;
  String? lastJsMessage;

  int progress = 0;
  bool isLoading = false;

  bool ignorePointerEvents = false;
  bool blockCrossHostNavigation = false;

  SWebViewConfig get _config => const SWebViewConfig(
        autoDetectFrameRestrictions: true,
        proxyCacheTtl: Duration(days: 7),
        cacheProxyByHost: true,
      );

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setUrl(String url) {
    setState(() {
      currentUrl = url;
      lastError = null;
      progress = 0;
    });
  }

  SWebViewNavigationDecision _handleNavigationDecision(Uri uri) {
    if (!blockCrossHostNavigation) {
      return SWebViewNavigationDecision.navigate;
    }

    final currentHost = Uri.tryParse(currentUrl)?.host.toLowerCase();
    final nextHost = uri.host.toLowerCase();

    if (currentHost != null &&
        currentHost.isNotEmpty &&
        nextHost != currentHost) {
      if (mounted) {
        setState(() {
          lastError =
              'Navigation prevented by policy: $nextHost (current host: $currentHost)';
        });
      }
      return SWebViewNavigationDecision.prevent;
    }

    return SWebViewNavigationDecision.navigate;
  }

  @override
  Widget build(BuildContext context) {
    final progressValue = (progress.clamp(0, 100)) / 100;

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
                      onPressed: () => _setUrl('https://flutter.dev'),
                      child: const Text('Flutter.dev'),
                    ),
                    ElevatedButton(
                      onPressed: () => _setUrl('https://pub.dev'),
                      child: const Text('Pub.dev'),
                    ),
                    ElevatedButton(
                      onPressed: () => _setUrl('https://github.com'),
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
                const SizedBox(height: 4),
                Text(
                  'Last seen URL: $lastSeenUrl',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: isLoading ? progressValue : null,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isLoading ? '$progress%' : 'Idle',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tip: some websites (or proxy-loaded pages) can emit noisy console logs.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Block cross-host navigation'),
                  subtitle: const Text(
                    'Demonstrates onNavigationRequest callback decisions',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: blockCrossHostNavigation,
                  onChanged: (value) {
                    setState(() {
                      blockCrossHostNavigation = value;
                    });
                  },
                ),
                SwitchListTile.adaptive(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Disable pointer events in SWebView'),
                  subtitle: const Text(
                    'When enabled, taps/scrolls are ignored by the webview',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: ignorePointerEvents,
                  onChanged: (value) {
                    setState(() {
                      ignorePointerEvents = value;
                    });
                  },
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

          if (lastJsMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Icon(Icons.message_outlined, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'JS message: $lastJsMessage',
                      style:
                          TextStyle(fontSize: 12, color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),

          // WebView
          Expanded(
            child: SWebView(
              key: ValueKey('$currentUrl-$ignorePointerEvents'),
              controller: _controller,
              config: _config,
              url: currentUrl,
              showDebugLogs: false,
              ignorePointerEvents: ignorePointerEvents,
              onProgress: (value) {
                if (!mounted) return;
                setState(() {
                  progress = value;
                  isLoading = value < 100;
                });
              },
              onPageStarted: (uri) {
                if (!mounted) return;
                setState(() {
                  isLoading = true;
                  lastSeenUrl = uri.toString();
                });
              },
              onPageFinished: (uri) {
                if (!mounted) return;
                setState(() {
                  progress = 100;
                  isLoading = false;
                  lastSeenUrl = uri.toString();
                });
              },
              onUrlChanged: (uri) {
                if (!mounted) return;
                setState(() {
                  lastSeenUrl = uri.toString();
                });
              },
              onNavigationRequest: _handleNavigationDecision,
              onJavaScriptMessage: (message) {
                if (!mounted) return;
                setState(() {
                  lastJsMessage = message;
                });
              },
              onError: (error) {
                if (mounted) {
                  setState(() {
                    lastError = error;
                    isLoading = false;
                  });
                }
              },
              onLoaded: () {
                if (mounted) {
                  setState(() {
                    lastError = null;
                    isLoading = false;
                  });
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
