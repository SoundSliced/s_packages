import 'package:flutter/material.dart';
import 'package:s_maintenance_button/s_maintenance_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S Maintenance Button Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  bool _isOnMaintenance = false;
  bool _hasCallback = true;
  Color? _activeColor;
  Color? _inactiveColor;
  int _tapCount = 0;

  // Available colors for selection
  final Map<String, Color?> _colors = {
    'Default': null,
    'Orange': Colors.orange,
    'Purple': Colors.purple,
    'Cyan': Colors.cyan,
    'Red': Colors.red,
    'Green': Colors.green,
    'Blue': Colors.blue,
    'Pink': Colors.pink,
  };

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleButtonTap() {
    if (!mounted) {
      return;
    }
    setState(() {
      _tapCount++;
      _isOnMaintenance = !_isOnMaintenance;
    });
    _showMessage(
      'Button Tapped! Maintenance mode: ${_isOnMaintenance ? "ON" : "OFF"}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('S Maintenance Button Playground'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header and Description
              const Text(
                'Interactive Playground',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Adjust the settings below to see how the maintenance button behaves.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 8),

              // Main Demo Area (Center Stage)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      const Text('Button Preview'),
                      const SizedBox(height: 24),
                      Transform.scale(
                        scale: 2.0, // Make it bigger for better visibility
                        child: SMaintenanceButton(
                          isOnMaintenance: _isOnMaintenance,
                          activeColor: _activeColor,
                          nonActiveColor: _inactiveColor,
                          onTap: _hasCallback ? _handleButtonTap : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Status: ${_isOnMaintenance ? "MAINTENANCE ON" : "NORMAL"}',
                        style: TextStyle(
                          color: _isOnMaintenance ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Settings Controls
              const Text(
                'Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // 1. Maintenance Mode Toggle
              SwitchListTile(
                title: const Text('Maintenance Mode Active'),
                subtitle: const Text('Toggles the animated glow effect'),
                value: _isOnMaintenance,
                onChanged: (value) => setState(() => _isOnMaintenance = value),
              ),

              // 2. Callback Toggle
              SwitchListTile(
                title: const Text('Enable Tap Callback'),
                subtitle: const Text('If disabled, the button is read-only'),
                value: _hasCallback,
                onChanged: (value) => setState(() => _hasCallback = value),
              ),

              const Divider(height: 8),

              // 3. Active Color Selection
              const Text(
                'Active Color (When Maintenance is ON)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _colors.entries.map((entry) {
                  final isSelected = _activeColor == entry.value;
                  return ChoiceChip(
                    label: Text(entry.key),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() => _activeColor = entry.value);
                      }
                    },
                    avatar: entry.value != null
                        ? CircleAvatar(backgroundColor: entry.value, radius: 8)
                        : null,
                  );
                }).toList(),
              ),

              const Divider(height: 32),

              // 4. Inactive Color Selection
              const Text(
                'Inactive Color (When Maintenance is OFF)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _colors.entries.map((entry) {
                  final isSelected = _inactiveColor == entry.value;
                  return ChoiceChip(
                    label: Text(entry.key),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() => _inactiveColor = entry.value);
                      }
                    },
                    avatar: entry.value != null
                        ? CircleAvatar(backgroundColor: entry.value, radius: 8)
                        : null,
                  );
                }).toList(),
              ),

              const Divider(height: 32),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tap Count',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '$_tapCount',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _tapCount = 0),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Counter'),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Note about release mode
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade900),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Note: This button is only visible in debug and profile modes. '
                        'It will not appear in release builds.',
                        style: TextStyle(color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
