import 'package:flutter/material.dart';
import 'package:states_rebuilder_extended/states_rebuilder_extended.dart';

class StatesRebuilderExtendedExampleScreen extends StatelessWidget {
  const StatesRebuilderExtendedExampleScreen({super.key});

  // Create injected states
  static final counter = 0.inject<int>();
  static final isEnabled = false.inject<bool>();
  static final userName = 'Guest'.inject<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('states_rebuilder_extended Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Type-Safe State Management',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Counter example
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Counter with builderData',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      counter.builderData<int>(
                        (count) => Text(
                          'Count: $count',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => counter.update<int>((s) => s + 1),
                            child: const Text('Increment'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => counter.update<int>((s) => s - 1),
                            child: const Text('Decrement'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Boolean toggle example
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Boolean Toggle',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      isEnabled.builderData<bool>(
                        (enabled) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              enabled ? 'Enabled ✓' : 'Disabled ✗',
                              style: TextStyle(
                                fontSize: 18,
                                color: enabled ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Switch(
                              value: enabled,
                              onChanged: (_) => isEnabled.toggle(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => isEnabled.toggle(),
                        child: const Text('Toggle'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // String state example
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'String State',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      userName.builderData<String>(
                        (name) => Text(
                          'Hello, $name!',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          ElevatedButton(
                            onPressed: () =>
                                userName.update<String>((s) => 'Alice'),
                            child: const Text('Alice'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                userName.update<String>((s) => 'Bob'),
                            child: const Text('Bob'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                userName.update<String>((s) => 'Charlie'),
                            child: const Text('Charlie'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Reset button
              OutlinedButton.icon(
                onPressed: () {
                  counter.update<int>((s) => 0);
                  isEnabled.update<bool>((s) => false);
                  userName.update<String>((s) => 'Guest');
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reset All'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
