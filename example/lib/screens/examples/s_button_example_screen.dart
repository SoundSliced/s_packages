import 'package:flutter/material.dart';
import 'package:s_button/s_button.dart';

class SButtonExampleScreen extends StatefulWidget {
  const SButtonExampleScreen({super.key});

  @override
  State<SButtonExampleScreen> createState() => _SButtonExampleScreenState();
}

class _SButtonExampleScreenState extends State<SButtonExampleScreen> {
  int _tapCount = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SButton Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Basic SButton
              SButton(
                onTap: (offset) {
                  setState(() => _tapCount++);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tapped! Count: $_tapCount'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                shouldBounce: true,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Basic SButton',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // SButton with loading
              SButton(
                onTap: (_) async {
                  final messenger = ScaffoldMessenger.of(context);
                  setState(() => _isLoading = true);
                  await Future.delayed(const Duration(seconds: 2));
                  if (mounted) {
                    setState(() => _isLoading = false);
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Action completed!')),
                    );
                  }
                },
                isLoading: _isLoading,
                shouldBounce: true,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Button with Loading',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Circular SButton
              SButton(
                onTap: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Circular button!')),
                  );
                },
                isCircleButton: true,
                shouldBounce: true,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Disabled SButton
              SButton(
                onTap: (_) {},
                isActive: false,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Disabled Button',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Tap count: $_tapCount',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
