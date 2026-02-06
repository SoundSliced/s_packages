import 'package:flutter/material.dart';
import 'package:ticker_free_circular_progress_indicator/ticker_free_circular_progress_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TickerFree Circular Progress Indicator Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  double _progress = 0.0;
  bool _isLoading = false;

  void _startLoading() {
    setState(() {
      _isLoading = true;
      _progress = 0.0;
    });

    // Simulate progress
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _progress = 0.2);
      }
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _progress = 0.5);
      }
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _progress = 0.8);
      }
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _progress = 1.0;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TickerFree Circular Progress Indicator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Hot-Restart Safe Circular Progress Indicator',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Determinate progress indicator
            const Text('Determinate Progress:'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TickerFreeCircularProgressIndicator(
                  value: _progress,
                  color: Colors.blue,
                  strokeWidth: 6.0,
                ),
                const SizedBox(width: 20),
                Text('${(_progress * 100).round()}%'),
              ],
            ),

            const SizedBox(height: 40),

            // Indeterminate progress indicator
            const Text('Indeterminate Progress:'),
            const SizedBox(height: 10),
            const TickerFreeCircularProgressIndicator(
              color: Colors.green,
              strokeWidth: 4.0,
            ),

            const SizedBox(height: 40),

            // Custom styled indicator
            const Text('Custom Styled:'),
            const SizedBox(height: 10),
            TickerFreeCircularProgressIndicator(
              value: 0.75,
              color: Colors.purple,
              backgroundColor: Colors.purple.withValues(alpha: 0.2),
              strokeWidth: 8.0,
              strokeAlign: -1.0, // Inside stroke
              strokeCap: StrokeCap.round,
            ),

            const SizedBox(height: 40),

            // Button to start loading simulation
            ElevatedButton(
              onPressed: _isLoading ? null : _startLoading,
              child: Text(_isLoading ? 'Loading...' : 'Start Loading'),
            ),

            const SizedBox(height: 20),

            // Usage information
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Key Features:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('• Hot-restart safe (no TickerProviderStateMixin)'),
                    Text('• Manual frame callbacks for smooth animations'),
                    Text('• Supports determinate and indeterminate modes'),
                    Text('• Customizable colors and styling'),
                    Text('• Optional delay with default widget'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
