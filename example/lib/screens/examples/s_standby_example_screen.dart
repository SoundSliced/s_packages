import 'package:flutter/material.dart';
import 'package:s_standby/s_standby.dart';

class SStandbyExampleScreen extends StatefulWidget {
  const SStandbyExampleScreen({super.key});

  @override
  State<SStandbyExampleScreen> createState() => _SStandbyExampleScreenState();
}

class _SStandbyExampleScreenState extends State<SStandbyExampleScreen> {
  bool _isBusy = false;
  String _lastResult = 'No operations yet';

  void _handleDismiss({
    bool? wasSuccessful,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!mounted) return;

    String message;
    if (wasSuccessful == true) {
      message = '✓ Success - Operation completed';
    } else if (wasSuccessful == false) {
      message = '✗ Error - ${error.toString()}';
    } else {
      message = '⊘ Cancelled before completion';
    }

    setState(() {
      _isBusy = false;
      _lastResult = message;
    });
  }

  Future<void> _runSuccessDemo() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    final future = Future<void>.delayed(const Duration(seconds: 2));
    SStandby.show(
      future: future,
      id: 'success_demo',
      title: 'Processing...',
      isDismissible: true,
      onDismissed: _handleDismiss,
    );
  }

  Future<void> _runErrorDemo() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    final future = Future<void>.delayed(
      const Duration(seconds: 2),
      () => throw Exception('Something went wrong!'),
    );

    SStandby.show<void>(
      future: future,
      id: 'error_demo',
      title: 'Processing...',
      isDismissible: true,
      onDismissed: _handleDismiss,
    );
  }

  Future<void> _runSuccessWithFeedback() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    final future = Future<void>.delayed(const Duration(seconds: 2));

    SStandby.show<void>(
      future: future,
      id: 'success_feedback',
      title: 'Saving...',
      isDismissible: true,
      onDismissed: _handleDismiss,
      successBuilder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.tertiary,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.tertiary,
                size: 32,
              ),
              const SizedBox(width: 12),
              const Text(
                'Saved successfully!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
      successAutoDismissAfter: const Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('s_standby Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Standby Overlay Demo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Shows a progress overlay while a Future runs.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),

              // Example 1: Success Demo
              ElevatedButton.icon(
                onPressed: _isBusy ? null : _runSuccessDemo,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Run Success Demo'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(250, 48),
                ),
              ),
              const SizedBox(height: 12),

              // Example 2: Error Demo
              ElevatedButton.icon(
                onPressed: _isBusy ? null : _runErrorDemo,
                icon: const Icon(Icons.error_outline),
                label: const Text('Run Error Demo'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(250, 48),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
              ),
              const SizedBox(height: 12),

              // Example 3: Success with Custom Feedback
              ElevatedButton.icon(
                onPressed: _isBusy ? null : _runSuccessWithFeedback,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Success + Auto Dismiss'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(250, 48),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  foregroundColor: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              const SizedBox(height: 32),

              // Status display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Text(
                      _isBusy ? 'Busy...' : 'Ready',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isBusy ? Colors.orange : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Last Result:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _lastResult,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Tip: Tap outside to dismiss the overlay',
                style: TextStyle(fontSize: 12, color: Colors.black45),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
