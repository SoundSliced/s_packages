import 'package:s_packages/s_packages.dart';

class SGlowExampleScreen extends StatefulWidget {
  const SGlowExampleScreen({super.key});

  @override
  State<SGlowExampleScreen> createState() => _SGlowExampleScreenState();
}

class _SGlowExampleScreenState extends State<SGlowExampleScreen> {
  bool _isGlow1Enabled = true;
  bool _isGlow2Enabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('s_glow Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Glow Effects Demo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Example 1: Glow1 - Breathing Effect
              const Text(
                'Glow1 - Breathing Effect',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Glow1(
                isEnabled: _isGlow1Enabled,
                color: Theme.of(context).colorScheme.primary,
                opacity: 0.5,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.star,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 48,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Toggle Breathing Effect'),
                value: _isGlow1Enabled,
                onChanged: (value) => setState(() => _isGlow1Enabled = value),
              ),
              const SizedBox(height: 32),

              // Example 2: Glow2 - Ripple Effect (Circle)
              const Text(
                'Glow2 - Ripple Effect',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Glow2(
                animate: _isGlow2Enabled,
                glowCount: 3,
                glowColor: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.4),
                glowShape: BoxShape.circle,
                duration: const Duration(milliseconds: 2500),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.favorite,
                      color: Theme.of(context).colorScheme.onSecondary,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Toggle Ripple Effect'),
                value: _isGlow2Enabled,
                onChanged: (value) => setState(() => _isGlow2Enabled = value),
              ),
              const SizedBox(height: 32),

              // Example 3: Glow2 with Rectangle
              const Text(
                'Glow2 - Rectangle Shape',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Glow2(
                glowShape: BoxShape.rectangle,
                glowBorderRadius: BorderRadius.circular(16),
                glowColor: Theme.of(context)
                    .colorScheme
                    .tertiary
                    .withValues(alpha: 0.3),
                glowCount: 2,
                child: Container(
                  width: 160,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Tap Me',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
