import 'package:s_packages/s_packages.dart';

class PostFrameExampleScreen extends StatefulWidget {
  const PostFrameExampleScreen({super.key});

  @override
  State<PostFrameExampleScreen> createState() => _PostFrameExampleScreenState();
}

class _PostFrameExampleScreenState extends State<PostFrameExampleScreen> {
  String _message = 'Waiting for first frame...';
  int _debouncedCount = 0;
  int _regularPostFrameCount = 0;

  @override
  void initState() {
    super.initState();
    // Run code after first frame - safe to access layout-dependent properties
    PostFrame.postFrame(() {
      if (!mounted) return;
      setState(() => _message = 'First frame complete!');
    });
  }

  void _useContextExtension() {
    // Uses mounted check automatically
    context.postFrame(() {
      if (!mounted) return;
      setState(() {
        _regularPostFrameCount++;
        _message =
            'context.postFrame() ran after next frame (count: $_regularPostFrameCount)';
      });
    });
  }

  void _spamDebounced() {
    // Only the last scheduled debounced invocation executes
    for (var i = 0; i < 10; i++) {
      PostFrame.debounced(() {
        if (!mounted) return;
        setState(() {
          _debouncedCount++;
          _message = 'Debounced executed once (count: $_debouncedCount)';
        });
      }, debounceKey: 'demo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PostFrame Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.access_time,
                size: 64,
                color: Colors.indigo,
              ),
              const SizedBox(height: 24),
              const Text(
                'PostFrame Examples',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 32),

              // Context extension example
              ElevatedButton.icon(
                onPressed: _useContextExtension,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Use context.postFrame()'),
              ),
              const SizedBox(height: 12),

              // Debounced example
              ElevatedButton.icon(
                onPressed: _spamDebounced,
                icon: const Icon(Icons.radio_button_checked),
                label: const Text('Debounced action spam (10x)'),
              ),
              const SizedBox(height: 32),

              const Divider(),
              const SizedBox(height: 16),

              // Info section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What is PostFrame?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Schedule code after frame rendering\n'
                      '• Safe for layout-dependent operations\n'
                      '• Debouncing support for performance\n'
                      '• Automatic mounted checks',
                      style: TextStyle(fontSize: 14),
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
