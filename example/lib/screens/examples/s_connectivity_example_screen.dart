import 'package:s_packages/s_packages.dart';

class SConnectivityExampleScreen extends StatefulWidget {
  const SConnectivityExampleScreen({super.key});

  @override
  State<SConnectivityExampleScreen> createState() =>
      _SConnectivityExampleScreenState();
}

class _SConnectivityExampleScreenState
    extends State<SConnectivityExampleScreen> {
  final _eventLog = <String>[];
  bool _showNoInternetSnackbar = false;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    await AppInternetConnectivity.initialiseInternetConnectivityListener(
      emitInitialStatus: true,
      showDebugLog: false,
      showNoInternetSnackbar: false,
      onConnected: () => _logEvent('🟢 Connected'),
      onDisconnected: () => _logEvent('🔴 Disconnected'),
    );
  }

  void _logEvent(String event) {
    if (!mounted) return;
    setState(() {
      _eventLog.insert(
        0,
        '${DateTime.now().toString().substring(11, 19)} - $event',
      );
      if (_eventLog.length > 10) _eventLog.removeLast();
    });
  }

  @override
  void dispose() {
    AppInternetConnectivity.disposeInternetConnectivityListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('s_connectivity Example'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              child: NoInternetWidget(
                size: 28,
                shouldAnimate: true,
                shouldShowWhenNoInternet: true,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Status Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connection Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<bool>(
                      valueListenable: AppInternetConnectivity.listenable,
                      builder: (context, isConnected, _) {
                        return Row(
                          children: [
                            Icon(
                              isConnected ? Icons.wifi : Icons.wifi_off,
                              color: isConnected ? Colors.green : Colors.red,
                              size: 48,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isConnected ? 'Online' : 'Offline',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isConnected ? Colors.green : Colors.red,
                                  ),
                                ),
                                Text(
                                  isConnected
                                      ? 'Internet is available'
                                      : 'No internet connection',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // NoInternetWidget Demo
            const Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NoInternetWidget',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        NoInternetWidget(
                          size: 40,
                          backgroundColor: Colors.red,
                          iconColor: Colors.white,
                          icon: Icons.wifi_off_rounded,
                          shouldShowWhenNoInternet: true,
                          shouldAnimate: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'A small widget that appears when offline',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Popup Demo
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NoInternetConnectionPopup',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Displays a full-screen overlay with a snackbar when offline',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title:
                          const Text('Enable package snackbar warning Overlay'),
                      value: _showNoInternetSnackbar,
                      onChanged: (value) {
                        setState(() {
                          _showNoInternetSnackbar = value;
                          AppInternetConnectivity.showNoInternetSnackbar =
                              value;
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Event Log
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Event Log',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() => _eventLog.clear()),
                          icon: const Icon(Icons.clear_all, size: 16),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: _eventLog.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'Events will appear here',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: _eventLog.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    _eventLog[index],
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 13,
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
      ),
    );
  }
}
