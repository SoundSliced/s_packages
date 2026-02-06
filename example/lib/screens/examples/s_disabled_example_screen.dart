import 'package:s_packages/s_packages.dart';

class SDisabledExampleScreen extends StatefulWidget {
  const SDisabledExampleScreen({super.key});

  @override
  State<SDisabledExampleScreen> createState() => _SDisabledExampleScreenState();
}

class _SDisabledExampleScreenState extends State<SDisabledExampleScreen> {
  bool _isButtonDisabled = false;
  bool _isWidgetDisabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SDisabled Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'SDisabled Examples',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Basic disabled button example
              const Text(
                'Basic Disabled Button:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SDisabled(
                isDisabled: _isButtonDisabled,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Button clicked!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Click Me'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isButtonDisabled = !_isButtonDisabled;
                  });
                },
                child: Text(_isButtonDisabled ? 'Enable' : 'Disable'),
              ),
              const SizedBox(height: 32),

              // Custom opacity example
              const Text(
                'Custom Opacity (0.3):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SDisabled(
                isDisabled: _isWidgetDisabled,
                opacityWhenDisabled: 0.3,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Information Widget',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Tap detection when disabled
              const Text(
                'Tap Detection When Disabled:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SDisabled(
                isDisabled: _isWidgetDisabled,
                opacityWhenDisabled: 0.5,
                onTappedWhenDisabled: (offset) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Tapped disabled widget at: (${offset.dx.toStringAsFixed(0)}, ${offset.dy.toStringAsFixed(0)})',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app,
                          color: Theme.of(context).colorScheme.onSecondary,
                          size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Try tapping me!',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isWidgetDisabled = !_isWidgetDisabled;
                  });
                },
                child: Text(
                    _isWidgetDisabled ? 'Enable Widget' : 'Disable Widget'),
              ),
              const SizedBox(height: 32),

              // Status display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Column(
                  children: [
                    Text(
                      'Button Status: ${_isButtonDisabled ? "DISABLED" : "ENABLED"}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _isButtonDisabled ? Colors.red : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Widget Status: ${_isWidgetDisabled ? "DISABLED" : "ENABLED"}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _isWidgetDisabled ? Colors.red : Colors.green,
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
