import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:s_packages/s_universal_html/html.dart' as uhtml;
import 'package:s_packages/s_universal_html/s_universal_html.dart';

class SUniversalHtmlExampleScreen extends StatefulWidget {
  const SUniversalHtmlExampleScreen({super.key});

  @override
  State<SUniversalHtmlExampleScreen> createState() =>
      _SUniversalHtmlExampleScreenState();
}

class _SUniversalHtmlExampleScreenState
    extends State<SUniversalHtmlExampleScreen> {
  String? _currentHref;
  String? _userAgent;
  String? _platform;
  List<String>? _languages;
  bool? _onLine;
  bool? _cookieEnabled;
  String _log = '';

  // Context-menu prevention
  bool _contextMenuPrevented = false;
  void Function()? _contextMenuCancel;

  @override
  void initState() {
    super.initState();
    _readNavigatorInfo();
  }

  @override
  void dispose() {
    _contextMenuCancel?.call();
    super.dispose();
  }

  void _toggleContextMenuPrevention() {
    if (_contextMenuPrevented) {
      _contextMenuCancel?.call();
      _contextMenuCancel = null;
      setState(() => _contextMenuPrevented = false);
      _appendLog('Context menu prevention disabled.');
    } else {
      _contextMenuCancel = SUniversalHtml.preventDefaultContextMenu();
      setState(() => _contextMenuPrevented = true);
      _appendLog(
        kIsWeb
            ? 'Context menu prevention enabled — right-click the box below.'
            : '⚠️  No-op on non-web platform (expected).',
      );
    }
  }

  void _readNavigatorInfo() {
    final nav = uhtml.window.navigator;
    setState(() {
      _currentHref = uhtml.window.location.href;
      _userAgent = nav.userAgent;
      _platform = nav.platform;
      _languages = nav.languages.toList();
      _onLine = nav.onLine;
      _cookieEnabled = nav.cookieEnabled;
    });
  }

  void _reloadWindow() {
    _appendLog('Calling window.location.reload()...');
    try {
      uhtml.window.location.reload();
      // On non-web platforms the call is a no-op; we log accordingly.
      if (!kIsWeb) {
        _appendLog('⚠️  No-op on non-web platform (expected).');
      }
    } catch (e) {
      _appendLog('Error: $e');
    }
  }

  void _navigateTo(String url) {
    _appendLog('Calling window.location.assign("$url")...');
    try {
      uhtml.window.location.assign(url);
      if (!kIsWeb) {
        _appendLog('⚠️  No-op on non-web platform (expected).');
      }
    } catch (e) {
      _appendLog('Error: $e');
    }
  }

  void _replaceLocation(String url) {
    _appendLog('Calling window.location.replace("$url")...');
    try {
      uhtml.window.location.replace(url);
      if (!kIsWeb) {
        _appendLog('⚠️  No-op on non-web platform (expected).');
      }
    } catch (e) {
      _appendLog('Error: $e');
    }
  }

  void _appendLog(String msg) {
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      _log = '[$timestamp] $msg\n$_log';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('s_universal_html Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Platform note
            Card(
              color: kIsWeb ? Colors.green.shade50 : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      kIsWeb ? Icons.check_circle : Icons.info_outline,
                      color: kIsWeb ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        kIsWeb
                            ? 'Running on Web — all helpers are live.'
                            : 'Running on non-web platform — location helpers are no-ops.',
                        style: TextStyle(
                          color: kIsWeb
                              ? Colors.green.shade800
                              : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Navigator info card
            _SectionCard(
              title: 'window.navigator',
              child: Column(
                children: [
                  _InfoRow('userAgent', _userAgent),
                  _InfoRow('platform', _platform),
                  _InfoRow('languages', _languages?.join(', ')),
                  _InfoRow('onLine', _onLine?.toString()),
                  _InfoRow('cookieEnabled', _cookieEnabled?.toString()),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _readNavigatorInfo,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Location info card
            _SectionCard(
              title: 'window.location',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _InfoRow('href', _currentHref),
                  const SizedBox(height: 12),

                  // Reload
                  ElevatedButton.icon(
                    onPressed: _reloadWindow,
                    icon: const Icon(Icons.replay),
                    label: const Text('window.location.reload()'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Assign
                  OutlinedButton.icon(
                    onPressed: () => _navigateTo('https://flutter.dev'),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('location.assign("https://flutter.dev")'),
                  ),
                  const SizedBox(height: 8),

                  // Replace
                  OutlinedButton.icon(
                    onPressed: () => _replaceLocation('https://dart.dev'),
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('location.replace("https://dart.dev")'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Context menu card
            _SectionCard(
              title: 'SUniversalHtml.preventDefaultContextMenu()',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Toggle browser context-menu suppression, then right-click '
                    'inside the box to verify.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _toggleContextMenuPrevention,
                    icon: Icon(
                      _contextMenuPrevented
                          ? Icons.block
                          : Icons.check_circle_outline,
                    ),
                    label: Text(
                      _contextMenuPrevented
                          ? 'Disable prevention'
                          : 'Enable prevention',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _contextMenuPrevented
                          ? Colors.red.shade600
                          : Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: _contextMenuPrevented
                          ? Colors.red.shade50
                          : Colors.grey.shade100,
                      border: Border.all(
                        color: _contextMenuPrevented
                            ? Colors.red.shade300
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _contextMenuPrevented
                            ? '🚫  Right-click is blocked'
                            : '✅  Right-click me — menu should appear',
                        style: TextStyle(
                          fontSize: 13,
                          color: _contextMenuPrevented
                              ? Colors.red.shade700
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Log card
            _SectionCard(
              title: 'Event log',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_log.isEmpty)
                    const Text(
                      'No events yet — tap a button above.',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    Text(
                      _log,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  if (_log.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() => _log = ''),
                      child: const Text('Clear log'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '—',
              style: TextStyle(
                fontSize: 13,
                color: value != null
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.grey,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
