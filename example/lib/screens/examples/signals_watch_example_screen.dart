import 'package:s_packages/s_packages.dart';

class SignalsWatchExampleScreen extends StatefulWidget {
  const SignalsWatchExampleScreen({super.key});

  @override
  State<SignalsWatchExampleScreen> createState() =>
      _SignalsWatchExampleScreenState();
}

class _SignalsWatchExampleScreenState extends State<SignalsWatchExampleScreen> {
  // Create signals with debug labels
  final counter = SignalsWatch.signal(
    0, /* debugLabel: 'example.counter' */
  );
  late final userName = SignalsWatch.signal(
    '',
    /* debugLabel: 'example.userName' */
    onValueUpdated: _onUserNameUpdated,
  );

  void _onUserNameUpdated() {
    log("yoo: '${userName.value}'");
    if (userName.value.isEmpty) {
      _nameController.clear();
    }
  }

  // Computed signal derived from counter
  late final doubled = SignalsWatch.computed(
    () => counter.value * 2,
    onValueUpdated: (value, previous) {
      debugPrint('Doubled changed: $previous -> $value');
    },
  );

  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SignalsWatch.initializeSignalsObserver();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SignalsWatch Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Reactive Signals Demo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Basic counter example
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Basic Counter Signal',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      counter.observe(
                        (value) => Text(
                          'Count: $value',
                          style: const TextStyle(fontSize: 24),
                        ),
                        onValueUpdated: (value, previous) {
                          debugPrint('Counter: $previous -> $value');
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => counter.value++,
                            child: const Text('Increment'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => counter.value--,
                            child: const Text('Decrement'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Computed signal example
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Computed Signal (Doubled)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      doubled.observe(
                        (value) => Text(
                          'Doubled: $value',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Automatically updates when counter changes',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // String signal with TextField
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Text Signal',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Enter your name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (text) => userName.value = text,
                      ),
                      const SizedBox(height: 12),
                      SignalsWatch.fromSignal(
                        userName,
                        debounce: const Duration(milliseconds: 300),
                        builder: (name) => Text(
                          name.isEmpty ? 'Hello, Guest!' : 'Hello, $name!',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Reset button
              OutlinedButton.icon(
                onPressed: () {
                  counter.reset();
                  userName.reset();
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
