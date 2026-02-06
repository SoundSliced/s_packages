import 'package:flutter/material.dart';
import 'package:s_connectivity/s_connectivity.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'S_Connectivity Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const ConnectivityDemo(),
        );
      },
    );
  }
}

class ConnectivityDemo extends StatefulWidget {
  const ConnectivityDemo({super.key});

  @override
  State<ConnectivityDemo> createState() => _ConnectivityDemoState();
}

class _ConnectivityDemoState extends State<ConnectivityDemo> {
  // Debug toggles to isolate hot-restart-only Flutter Web view disposal asserts.
  // Flip these to narrow whether the issue is caused by UI rebuilds/setState
  // or by connectivity stream updates themselves.
  static const bool kEnablePopupOverlay = true;
  static const bool kEnableNoInternetWidget = true;

  final _eventLog = <String>[];
  bool _showPopup = false;
  bool _showWidget = true;
  bool _animateWidget = true;
  double _widgetSize = 40.0;
  Color _widgetBgColor = Colors.red;
  Color _widgetIconColor = Colors.white;
  IconData _widgetIcon = Icons.wifi_off_rounded;

  @override
  void initState() {
    super.initState();
    // Defer initialization to ensure widget is fully mounted
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeConnectivity();
    // });
  }

  Future<void> _initializeConnectivity() async {
    // Flutter Web hot-restart can leave stale listeners/streams alive briefly.
    // This guarantees a clean slate before re-subscribing.
    await AppInternetConnectivity.hardReset();
    await AppInternetConnectivity.initialiseInternetConnectivityListener(
      emitInitialStatus: true,
      showDebugLog: true,
      onConnected: () => _logEvent('🟢 Connected'),
      onDisconnected: () => _logEvent('🔴 Disconnected'),
    );
  }

  void _logEvent(String event) {
    if (mounted) {
      setState(() {
        //  debugPrint(event);

        _eventLog.insert(
            0, '${DateTime.now().toString().substring(11, 19)} - $event');
        if (_eventLog.length > 20) _eventLog.removeLast();
      });
    }
  }

  @override
  void dispose() {
    // We don't await in dispose, but we still call it for cleanup.
    AppInternetConnectivity.disposeInternetConnectivityListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('S_Connectivity Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Status Card
                _buildStatusCard(),
                const SizedBox(height: 20),

                // Widget Demo Section
                _buildWidgetDemoSection(),
                const SizedBox(height: 20),

                // Popup Demo Section
                _buildPopupDemoSection(),
                const SizedBox(height: 20),

                // Event Log
                _buildEventLog(),
              ],
            ),
          ),

          // Show popup overlay when enabled
          if (kEnablePopupOverlay && _showPopup)
            ValueListenableBuilder<bool>(
              valueListenable: AppInternetConnectivity.listenable,
              builder: (context, isConnected, _) {
                if (!isConnected) {
                  return const NoInternetConnectionPopup();
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connection Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isConnected ? 'Online' : 'Offline',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: isConnected ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetDemoSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'NoInternetWidget',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                NoInternetWidget(
                  size: _widgetSize,
                  backgroundColor: _widgetBgColor,
                  iconColor: _widgetIconColor,
                  icon: _widgetIcon,
                  shouldShowWhenNoInternet:
                      kEnableNoInternetWidget ? _showWidget : false,
                  shouldAnimate: _animateWidget,
                ),
              ],
            ),
            const Divider(height: 24),

            // Toggle Settings
            SwitchListTile(
              title: const Text('Show Widget'),
              value: _showWidget,
              onChanged: (value) => setState(() => _showWidget = value),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Animate'),
              value: _animateWidget,
              onChanged: (value) => setState(() => _animateWidget = value),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 12),

            // Size Slider
            Text('Size: ${_widgetSize.toInt()}'),
            Slider(
              value: _widgetSize,
              min: 20,
              max: 80,
              divisions: 12,
              label: _widgetSize.toInt().toString(),
              onChanged: (value) => setState(() => _widgetSize = value),
            ),

            const SizedBox(height: 8),

            // Color Pickers
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Background'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _colorButton(Colors.red, 'bg'),
                          _colorButton(Colors.orange, 'bg'),
                          _colorButton(Colors.purple, 'bg'),
                          _colorButton(Colors.blue, 'bg'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Icon Color'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _colorButton(Colors.white, 'icon'),
                          _colorButton(Colors.yellow, 'icon'),
                          _colorButton(Colors.black, 'icon'),
                          _colorButton(Colors.lightBlue, 'icon'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Icon Selector
            const Text('Icon'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _iconButton(Icons.wifi_off_rounded),
                _iconButton(Icons.cloud_off),
                _iconButton(Icons.signal_wifi_off),
                _iconButton(Icons.portable_wifi_off),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupDemoSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NoInternetConnectionPopup',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Displays an animated overlay when offline',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Enable Popup'),
              value: _showPopup,
              onChanged: (value) => setState(() => _showPopup = value),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventLog() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Event Log',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
              constraints: const BoxConstraints(maxHeight: 200),
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
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
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
    );
  }

  Widget _colorButton(Color color, String type) {
    final isSelected =
        type == 'bg' ? _widgetBgColor == color : _widgetIconColor == color;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (type == 'bg') {
            _widgetBgColor = color;
          } else {
            _widgetIconColor = color;
          }
        });
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    final isSelected = _widgetIcon == icon;

    return GestureDetector(
      onTap: () => setState(() => _widgetIcon = icon),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.deepPurple : Colors.grey.shade700,
        ),
      ),
    );
  }
}
