import 'package:s_packages/s_packages.dart';

class SBounceableExampleScreen extends StatefulWidget {
  const SBounceableExampleScreen({super.key});

  @override
  State<SBounceableExampleScreen> createState() =>
      _SBounceableExampleScreenState();
}

class _SBounceableExampleScreenState extends State<SBounceableExampleScreen> {
  double _scaleFactor = 0.9;
  int _tapCount = 0;
  int _doubleTapCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SBounceable Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Scale Factor: ${_scaleFactor.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _scaleFactor,
                min: 0.5,
                max: 1.0,
                divisions: 50,
                label: _scaleFactor.toStringAsFixed(2),
                onChanged: (value) => setState(() => _scaleFactor = value),
              ),
              const SizedBox(height: 40),

              // Basic bounceable
              SBounceable(
                scaleFactor: _scaleFactor,
                curve: Curves.easeOutBack,
                enableHapticFeedback: true,
                onTap: () {
                  setState(() => _tapCount++);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tap! Count: $_tapCount'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                onDoubleTap: () {
                  setState(() => _doubleTapCount++);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Double Tap! Count: $_doubleTapCount'),
                      backgroundColor: Colors.purple,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                onLongPress: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Long press detected!'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Tap, Double Tap, or Long Press!',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Stats
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Single Taps: $_tapCount',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Double Taps: $_doubleTapCount',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
