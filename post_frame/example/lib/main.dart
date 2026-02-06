import 'package:flutter/material.dart';
import 'package:post_frame/post_frame.dart';

// ---------------------------------------------------------------------------
// Minimal Quick Start Example (lib/main.dart)
// ---------------------------------------------------------------------------
// This entrypoint demonstrates the MOST BASIC usage patterns:
//  * Schedule code after first frame using PostFrame.postFrame
//  * Use BuildContext extension context.postFrame for ergonomic calls
//  * Show a debounced action example
//
// For full, feature-rich demonstrations (repeat, queue, layout sizing, builders,
// predicates, debouncing, etc.) open lib/advanced_examples.dart which contains
// PostFrameExampleApp with navigation to all advanced samples.
// ---------------------------------------------------------------------------

void main() {
  runApp(const QuickStartApp());
}

class QuickStartApp extends StatelessWidget {
  const QuickStartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'post_frame Quick Start',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const QuickStartDemo(),
    );
  }
}

class QuickStartDemo extends StatefulWidget {
  const QuickStartDemo({super.key});

  @override
  State<QuickStartDemo> createState() => _QuickStartDemoState();
}

class _QuickStartDemoState extends State<QuickStartDemo> {
  String message = 'Waiting for first frame...';
  int debouncedCount = 0;

  @override
  void initState() {
    super.initState();
    // Run code after first frame. Safe to access layout-dependent properties.
    PostFrame.postFrame(() {
      setState(() => message = 'First frame complete!');
    });
  }

  void _useContextExtension() {
    // Uses mounted check automatically.
    context.postFrame(() {
      if (!mounted) return;
      setState(() => message = 'context.postFrame() ran after next frame');
    });
  }

  void _spamDebounced() {
    // Only the last scheduled debounced invocation executes.
    for (var i = 0; i < 10; i++) {
      PostFrame.debounced(() {
        if (!mounted) return;
        setState(() {
          debouncedCount++;
          message = 'Debounced executed once (count=$debouncedCount)';
        });
      }, debounceKey: 'demo');
    }
  }

  void _openAdvancedExamples() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Advanced Examples Info')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'To explore ALL features (repeat, queueRun, onLayout, builders, predicates, debouncing, error handling) open lib/advanced_examples.dart and use PostFrameExampleApp as your app root.',
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Start')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _useContextExtension,
                child: const Text('Use context.postFrame()'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _spamDebounced,
                child: const Text('Debounced action spam (10x)'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _openAdvancedExamples,
                child: const Text('Where are advanced examples?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
