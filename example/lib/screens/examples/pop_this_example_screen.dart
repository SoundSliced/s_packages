import 'package:s_packages/s_packages.dart';

class PopThisExampleScreen extends StatelessWidget {
  const PopThisExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PopThis Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Explore different popup styles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Simple Popup
              ElevatedButton(
                onPressed: () {
                  PopThis.pop(
                    context: context,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: const Text(
                        'Simple Popup\n\nTap outside to dismiss',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
                child: const Text('Show Simple Popup'),
              ),
              const SizedBox(height: 24),

              // Auto-dismiss with Timer
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                onPressed: () {
                  PopThis.pop(
                    context: context,
                    duration: const Duration(seconds: 3),
                    showTimer: true,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: const Text(
                        'Auto Dismiss Popup\n\nWill close in 3 seconds',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
                child: const Text('Popup with Timer'),
              ),
              const SizedBox(height: 24),

              // Custom Styled Popup
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                onPressed: () {
                  PopThis.pop(
                    context: context,
                    popBackgroundColor: Colors.purple.shade50,
                    dismissBarrierColor: Colors.purple.withValues(alpha: 0.5),
                    shouldBlurBackgroundOverlayLayer: true,
                    hasShadow: true,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 50,
                            color: Colors.purple.shade600,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Custom Styled Popup',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'This popup has custom colors and blur effect!',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: const Text('Custom Styled Popup'),
              ),
              const SizedBox(height: 40),

              // Success and Error Overlays
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      PopThis.showSuccessOverlay(
                        successMessage: 'Operation Successful!',
                        duration: const Duration(seconds: 2),
                      );
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Success'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      PopThis.showErrorOverlay(
                        errorMessage: 'Something went wrong!',
                        duration: const Duration(seconds: 2),
                      );
                    },
                    icon: const Icon(Icons.error),
                    label: const Text('Error'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
