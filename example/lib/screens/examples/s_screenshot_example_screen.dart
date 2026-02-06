import 'package:flutter/material.dart';
import 'package:s_screenshot/s_screenshot.dart';

class SScreenshotExampleScreen extends StatefulWidget {
  const SScreenshotExampleScreen({super.key});

  @override
  State<SScreenshotExampleScreen> createState() =>
      _SScreenshotExampleScreenState();
}

class _SScreenshotExampleScreenState extends State<SScreenshotExampleScreen> {
  final GlobalKey _screenshotKey = GlobalKey();
  String _status = 'Ready to capture';
  String? _base64Result;
  bool _isCapturing = false;

  Future<void> _captureAsBase64() async {
    setState(() {
      _isCapturing = true;
      _status = 'Capturing screenshot...';
      _base64Result = null;
    });

    try {
      final result = await SScreenshot.capture(
        _screenshotKey,
        config: const ScreenshotConfig(
          pixelRatio: 3.0,
          resultType: ScreenshotResultType.base64,
          shouldShowDebugLogs: true,
        ),
      );

      setState(() {
        _base64Result = result as String;
        _status = 'Screenshot captured! (${_base64Result!.length} chars)';
      });
    } on ScreenshotException catch (e) {
      setState(() {
        _status = 'Error: ${e.message}';
      });
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _captureAsBytes() async {
    setState(() {
      _isCapturing = true;
      _status = 'Capturing as bytes...';
      _base64Result = null;
    });

    try {
      final result = await SScreenshot.capture(
        _screenshotKey,
        config: const ScreenshotConfig(
          pixelRatio: 2.0,
          resultType: ScreenshotResultType.bytes,
          shouldShowDebugLogs: true,
        ),
      );

      final bytes = result as List<int>;
      setState(() {
        _status = 'Captured as bytes! (${bytes.length} bytes)';
      });
    } on ScreenshotException catch (e) {
      setState(() {
        _status = 'Error: ${e.message}';
      });
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _captureWithDelay() async {
    setState(() {
      _isCapturing = true;
      _status = 'Waiting 2 seconds...';
      _base64Result = null;
    });

    try {
      final result = await SScreenshot.capture(
        _screenshotKey,
        config: const ScreenshotConfig(
          pixelRatio: 3.0,
          resultType: ScreenshotResultType.base64,
          captureDelay: Duration(seconds: 2),
          shouldShowDebugLogs: true,
        ),
      );

      setState(() {
        _base64Result = result as String;
        _status = 'Screenshot captured with delay!';
      });
    } on ScreenshotException catch (e) {
      setState(() {
        _status = 'Error: ${e.message}';
      });
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('s_screenshot Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Screenshot Capture Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Widget to capture
            RepaintBoundary(
              key: _screenshotKey,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade400,
                      Colors.blue.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .shadow
                          .withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 64,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Capture This!',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateTime.now().toString().split('.')[0],
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),

            // Capture buttons
            ElevatedButton.icon(
              onPressed: _isCapturing ? null : _captureAsBase64,
              icon: const Icon(Icons.text_fields),
              label: const Text('Capture as Base64'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isCapturing ? null : _captureAsBytes,
              icon: const Icon(Icons.memory),
              label: const Text('Capture as Bytes'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isCapturing ? null : _captureWithDelay,
              icon: const Icon(Icons.timer),
              label: const Text('Capture with 2s Delay'),
            ),
            const SizedBox(height: 24),

            // Preview
            if (_base64Result != null) ...[
              const Text(
                'Screenshot Preview:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    Uri.parse('data:image/png;base64,$_base64Result')
                        .data!
                        .contentAsBytes(),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
