import 'package:s_packages/s_packages.dart';

class ShakerExampleScreen extends StatefulWidget {
  const ShakerExampleScreen({super.key});

  @override
  State<ShakerExampleScreen> createState() => _ShakerExampleScreenState();
}

class _ShakerExampleScreenState extends State<ShakerExampleScreen> {
  bool _isShaking = false;
  final ShakeController _shakeController = ShakeController();

  void _triggerShake() {
    setState(() => _isShaking = true);

    // Reset after animation completes
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isShaking = false);
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shaker Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Add shake animations to any widget',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Basic shake
                const Text(
                  'Basic Shake:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Shaker(
                  isShaking: _isShaking,
                  child: const Icon(
                    Icons.favorite,
                    size: 80,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),

                // Custom shake with different parameters
                const Text(
                  'Custom Shake (different parameters):',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Shaker(
                  isShaking: _isShaking,
                  duration: const Duration(milliseconds: 800),
                  hz: 6,
                  rotation: -0.05,
                  offset: const Offset(0.3, 0.3),
                  curve: Curves.bounceInOut,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'BOX',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Trigger button
                ElevatedButton(
                  onPressed: _triggerShake,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Shake It!',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // Controller-driven shake
                const Text(
                  'Controller-Driven Shake:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Shaker(
                  controller: _shakeController,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.gamepad, color: Colors.white, size: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _shakeController.shake(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                  child: const Text(
                    'Shake via Controller',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),

                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customization Options:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('• Duration - animation length'),
                        Text('• Hz - shake frequency'),
                        Text('• Rotation - rotation angle'),
                        Text('• Offset - direction & intensity'),
                        Text('• Curve - easing function'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
