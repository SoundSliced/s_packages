import 'package:flutter/material.dart';
import 'package:s_ink_button/s_ink_button.dart';

class SInkButtonExampleScreen extends StatefulWidget {
  const SInkButtonExampleScreen({super.key});

  @override
  State<SInkButtonExampleScreen> createState() =>
      _SInkButtonExampleScreenState();
}

class _SInkButtonExampleScreenState extends State<SInkButtonExampleScreen> {
  int _tapCount = 0;
  String _lastAction = 'None';

  void _showMessage(String message) {
    setState(() {
      _lastAction = message;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SInkButton Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'SInkButton Examples',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Basic ink button
              const Text(
                'Basic Ink Button:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SInkButton(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Tap me',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                onTap: (pos) {
                  setState(() {
                    _tapCount++;
                  });
                  _showMessage('Tapped! Count: $_tapCount');
                },
              ),
              const SizedBox(height: 32),

              // Circular button with haptic feedback
              const Text(
                'Circular Button (Haptic + Double Tap):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SInkButton(
                color: Colors.red.withValues(alpha: 0.5),
                scaleFactor: 0.95,
                isCircleButton: true,
                enableHapticFeedback: true,
                hapticFeedbackType: HapticFeedbackType.mediumImpact,
                onTap: (pos) => _showMessage('Single Tap'),
                onDoubleTap: (pos) => _showMessage('Double Tap'),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: Theme.of(context).colorScheme.onSecondary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Long press example
              const Text(
                'Long Press Detection:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SInkButton(
                color: Colors.green.withValues(alpha: 0.3),
                onTap: (pos) => _showMessage('Tap'),
                onLongPressStart: (details) {
                  _showMessage('Long press started');
                },
                onLongPressEnd: (details) {
                  _showMessage('Long press ended');
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Press and hold',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Status display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Column(
                  children: [
                    Text(
                      'Tap Count: $_tapCount',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last Action: $_lastAction',
                      style: const TextStyle(fontSize: 14),
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
