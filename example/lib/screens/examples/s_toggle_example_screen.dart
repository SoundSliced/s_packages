import 'package:s_packages/s_packages.dart';

class SToggleExampleScreen extends StatefulWidget {
  const SToggleExampleScreen({super.key});

  @override
  State<SToggleExampleScreen> createState() => _SToggleExampleScreenState();
}

class _SToggleExampleScreenState extends State<SToggleExampleScreen> {
  bool _toggle1 = false;
  bool _toggle2 = true;
  bool _toggle3 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SToggle Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Basic toggle
              SToggle(
                value: _toggle1,
                onChange: (value) => setState(() => _toggle1 = value),
                borderColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text('Toggle 1: ${_toggle1 ? 'ON' : 'OFF'}'),
              const SizedBox(height: 40),

              // Custom colors
              SToggle(
                value: _toggle2,
                onChange: (value) => setState(() => _toggle2 = value),
                onColor: Colors.green,
                offColor: Colors.red,
                size: 80,
              ),
              const SizedBox(height: 16),
              Text('Toggle 2: ${_toggle2 ? 'ON' : 'OFF'}'),
              const SizedBox(height: 40),

              // Larger toggle
              SToggle(
                value: _toggle3,
                onChange: (value) => setState(() => _toggle3 = value),
                size: 100,
                onColor: Colors.purple,
                offColor: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text('Toggle 3: ${_toggle3 ? 'ON' : 'OFF'}'),
            ],
          ),
        ),
      ),
    );
  }
}
