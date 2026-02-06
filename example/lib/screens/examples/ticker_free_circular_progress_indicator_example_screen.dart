import 'package:s_packages/s_packages.dart';

class TickerFreeCircularProgressIndicatorExampleScreen extends StatefulWidget {
  const TickerFreeCircularProgressIndicatorExampleScreen({super.key});

  @override
  State<TickerFreeCircularProgressIndicatorExampleScreen> createState() =>
      _TickerFreeCircularProgressIndicatorExampleScreenState();
}

class _TickerFreeCircularProgressIndicatorExampleScreenState
    extends State<TickerFreeCircularProgressIndicatorExampleScreen> {
  double _progress = 0.0;
  bool _isLoading = false;

  void _startLoading() {
    setState(() {
      _isLoading = true;
      _progress = 0.0;
    });

    // Simulate progress
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _progress = 0.25);
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _progress = 0.5);
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _progress = 0.75);
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
        title: const Text('TickerFree Progress Indicator'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Hot-restart safe circular progress indicators',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Indeterminate progress
              const Text(
                'Indeterminate Progress:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              const TickerFreeCircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 4.0,
              ),
              const SizedBox(height: 40),

              // Determinate progress
              const Text(
                'Determinate Progress:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TickerFreeCircularProgressIndicator(
                    value: _progress,
                    color: Colors.green,
                    strokeWidth: 6.0,
                  ),
                  const SizedBox(width: 20),
                  Text(
                    '${(_progress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Custom styled progress
              const Text(
                'Custom Styled:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TickerFreeCircularProgressIndicator(
                value: 0.75,
                color: Colors.purple,
                backgroundColor: Colors.purple.withValues(alpha: 0.2),
                strokeWidth: 8.0,
                strokeCap: StrokeCap.round,
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isLoading ? null : _startLoading,
                child: Text(_isLoading ? 'Loading...' : 'Start Loading'),
              ),
              const SizedBox(height: 24),

              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Key Features:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('• No TickerProviderStateMixin required'),
                      Text('• Hot-restart safe'),
                      Text('• Manual frame callbacks'),
                      Text('• Customizable styling'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
