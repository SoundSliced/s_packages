import 'package:s_packages/s_packages.dart';

class SoundslicedTweenAnimationBuilderExampleScreen extends StatefulWidget {
  const SoundslicedTweenAnimationBuilderExampleScreen({super.key});

  @override
  State<SoundslicedTweenAnimationBuilderExampleScreen> createState() =>
      _SoundslicedTweenAnimationBuilderExampleScreenState();
}

class _SoundslicedTweenAnimationBuilderExampleScreenState
    extends State<SoundslicedTweenAnimationBuilderExampleScreen> {
  Object? _animationKey;

  void _restartAnimation() {
    setState(() {
      _animationKey = Object(); // New key restarts animation
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STweenAnimationBuilder'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Timer-based animations (hot-restart safe)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Basic opacity animation
                const Text(
                  'Basic Opacity Animation:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                STweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 2),
                  animationKey: _animationKey,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Fading Text',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Size animation
                const Text(
                  'Size Animation with Curve:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                STweenAnimationBuilder<double>(
                  tween: Tween(begin: 50.0, end: 150.0),
                  duration: const Duration(seconds: 2),
                  curve: Curves.bounceOut,
                  animationKey: _animationKey,
                  builder: (context, value, child) {
                    return Container(
                      width: value,
                      height: value,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.onTertiary,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Auto-repeat rotation
                const Text(
                  'Auto-Repeat Rotation (3 times with delay):',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                STweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 360.0),
                  duration: const Duration(seconds: 3),
                  autoRepeat: true,
                  repeatCount: 3,
                  delay: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * 3.14159 / 180, // Convert to radians
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.refresh,
                            color: Theme.of(context).colorScheme.onSecondary,
                            size: 40,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: _restartAnimation,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Restart Animations',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 40),

                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Features:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('• Timer-based (not ticker-based)'),
                        Text('• Hot-restart safe'),
                        Text('• Auto-repeat support'),
                        Text('• Custom curves'),
                        Text('• Animation restart via key'),
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
