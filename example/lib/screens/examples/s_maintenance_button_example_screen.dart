import 'package:s_packages/s_packages.dart';

class SMaintenanceButtonExampleScreen extends StatefulWidget {
  const SMaintenanceButtonExampleScreen({super.key});

  @override
  State<SMaintenanceButtonExampleScreen> createState() =>
      _SMaintenanceButtonExampleScreenState();
}

class _SMaintenanceButtonExampleScreenState
    extends State<SMaintenanceButtonExampleScreen> {
  bool _isOnMaintenance = false;
  int _tapCount = 0;

  void _handleTap() {
    setState(() {
      _isOnMaintenance = !_isOnMaintenance;
      _tapCount++;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isOnMaintenance
              ? 'Maintenance mode activated!'
              : 'Maintenance mode deactivated',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('s_maintenance_button Example'),
        actions: [
          // Example 1: In AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SMaintenanceButton(
              isOnMaintenance: _isOnMaintenance,
              onTap: _handleTap,
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Maintenance Mode Button',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'This widget is only visible in debug/profile mode.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),

              // Example 2: Scaled up for demo
              const Text(
                'Interactive Button (with confirmation):',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Transform.scale(
                scale: 3.0,
                child: SMaintenanceButton(
                  isOnMaintenance: _isOnMaintenance,
                  activeColor: Theme.of(context).colorScheme.error,
                  nonActiveColor: Theme.of(context).colorScheme.primary,
                  icon: const Icon(Icons.engineering),
                  showConfirmation: true,
                  confirmationMessage:
                      'Are you sure you want to toggle maintenance mode?',
                  onTap: _handleTap,
                ),
              ),
              const SizedBox(height: 40),

              // Status display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isOnMaintenance
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isOnMaintenance ? Colors.red : Colors.green,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isOnMaintenance
                              ? Icons.warning_amber
                              : Icons.check_circle,
                          color: _isOnMaintenance ? Colors.red : Colors.green,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isOnMaintenance ? 'MAINTENANCE MODE' : 'NORMAL MODE',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isOnMaintenance ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap count: $_tapCount',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Example 3: Different colors
              const Text(
                'Custom Colors:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 2.0,
                    child: SMaintenanceButton(
                      isOnMaintenance: _isOnMaintenance,
                      activeColor: Colors.orange,
                      nonActiveColor: Colors.grey,
                      onTap: null, // Read-only
                    ),
                  ),
                  const SizedBox(width: 40),
                  Transform.scale(
                    scale: 2.0,
                    child: SMaintenanceButton(
                      isOnMaintenance: _isOnMaintenance,
                      activeColor: Colors.purple,
                      nonActiveColor: Colors.teal,
                      onTap: null, // Read-only
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
