import 'package:flutter/material.dart';
import 'package:s_glow/s_glow.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glow1_2 Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GlowExamplePage(),
    );
  }
}

class GlowExamplePage extends StatefulWidget {
  const GlowExamplePage({super.key});

  @override
  State<GlowExamplePage> createState() => _GlowExamplePageState();
}

class _GlowExamplePageState extends State<GlowExamplePage> {
  bool _isGlow1Enabled = true;
  bool _isGlow2Enabled = true;
  double _glowRadiusFactor = 0.3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Glow1_2 Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Glow1 Examples
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Glow1 - Breathing Effect',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Example 1: Basic Glow1
                  const ExampleCard(
                    title: 'Basic Breathing Glow',
                    child: Center(
                      child: Glow1(
                        child: _BlueBox(),
                      ),
                    ),
                  ),

                  // Example 2: Glow1 with custom color
                  const ExampleCard(
                    title: 'Custom Color (Purple)',
                    child: Center(
                      child: Glow1(
                        color: Colors.purple,
                        opacity: 0.5,
                        child: _PurpleBox(),
                      ),
                    ),
                  ),

                  // Example 3: Glow1 with button
                  ExampleCard(
                    title: 'Button with Glow',
                    child: Center(
                      child: Glow1(
                        color: Colors.purple,
                        opacity: 0.6,
                        borderRadius: BorderRadius.circular(8),
                        animationDuration: const Duration(milliseconds: 2000),
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            disabledBackgroundColor: Colors.purpleAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                          ),
                          child: const Text(
                            'Click Me',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Example 4: Toggle Glow1
                  ExampleCard(
                    title: 'Toggle Glow Effect',
                    child: Column(
                      children: [
                        Center(
                          child: Glow1(
                            isEnabled: _isGlow1Enabled,
                            color: Colors.orange,
                            child: const _OrangeBox(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _isGlow1Enabled = !_isGlow1Enabled);
                          },
                          child: Text(
                              _isGlow1Enabled ? 'Disable Glow' : 'Enable Glow'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Right Column: Glow2 Examples
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Glow2 - Ripple Effect',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Example 5: Basic Glow2
                  const ExampleCard(
                    title: 'Basic Ripple Effect (Circle)',
                    child: Center(
                      child: Glow2(
                        glowColor: Colors.blue,
                        glowShape: BoxShape.circle,
                        child: _CircleWidget(color: Colors.blue),
                      ),
                    ),
                  ),

                  // Example 6: Glow2 with multiple waves
                  const ExampleCard(
                    title: 'Multiple Waves (3 waves)',
                    child: Center(
                      child: Glow2(
                        glowCount: 3,
                        glowColor: Colors.green,
                        glowShape: BoxShape.circle,
                        duration: Duration(milliseconds: 2500),
                        child: _CircleWidget(color: Colors.green),
                      ),
                    ),
                  ),

                  // Example 7: Glow2 with rectangle
                  ExampleCard(
                    title: 'Rectangle Shape with Adjustable Factor',
                    child: Column(
                      children: [
                        Center(
                          child: Glow2(
                            glowShape: BoxShape.rectangle,
                            glowBorderRadius: BorderRadius.circular(16),
                            glowColor: Colors.red.withValues(alpha: 0.5),
                            glowCount: 2,
                            glowRadiusFactor: _glowRadiusFactor,
                            child: Container(
                              width: 150,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  'Custom Glow',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Text('Factor: '),
                              Expanded(
                                child: Slider(
                                  value: _glowRadiusFactor,
                                  min: 0.0,
                                  max: 1.0,
                                  divisions: 20,
                                  label: _glowRadiusFactor.toStringAsFixed(2),
                                  onChanged: (value) {
                                    setState(() => _glowRadiusFactor = value);
                                  },
                                ),
                              ),
                              Text(_glowRadiusFactor.toStringAsFixed(2)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Example 8: Toggle Glow2
                  ExampleCard(
                    title: 'Toggle Ripple Effect',
                    child: Column(
                      children: [
                        Center(
                          child: Glow2(
                            animate: _isGlow2Enabled,
                            glowColor: Colors.purple,
                            glowShape: BoxShape.circle,
                            child: const _CircleWidget(color: Colors.purple),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _isGlow2Enabled = !_isGlow2Enabled);
                          },
                          child: Text(
                              _isGlow2Enabled ? 'Stop Ripple' : 'Start Ripple'),
                        ),
                      ],
                    ),
                  ),

                  // Example 9: Avatar with Glow2
                  ExampleCard(
                    title: 'Avatar with Ripple',
                    child: Center(
                      child: Glow2(
                        glowCount: 2,
                        glowColor: Colors.cyan.withValues(alpha: 0.4),
                        glowShape: BoxShape.circle,
                        duration: const Duration(seconds: 3),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.cyan.shade700,
                          child: const Icon(Icons.person,
                              size: 40, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widgets
class ExampleCard extends StatelessWidget {
  final String title;
  final Widget child;

  const ExampleCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _BlueBox extends StatelessWidget {
  const _BlueBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _PurpleBox extends StatelessWidget {
  const _PurpleBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _OrangeBox extends StatelessWidget {
  const _OrangeBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _CircleWidget extends StatelessWidget {
  final Color color;

  const _CircleWidget({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
