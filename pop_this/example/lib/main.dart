import 'package:flutter/material.dart';
import 'package:pop_this/pop_this.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PopThis Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text('PopThis Example'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Basic Examples',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
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
                child: const Text('Simple Popup'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  PopThis.pop(
                    context: context,
                    duration: const Duration(seconds: 5),
                    showTimer: true,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: const Text(
                        'Auto Dismiss with Timer\n\nThis popup will automatically close in 5 seconds',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
                child: const Text('Popup with Timer'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  PopThis.showSuccessOverlay(
                    successMessage: 'Operation Successful!',
                    duration: const Duration(seconds: 2),
                  );
                },
                child: const Text('Success Overlay'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  PopThis.showErrorOverlay(
                    errorMessage: 'Something went wrong!',
                    duration: const Duration(seconds: 2),
                  );
                },
                child: const Text('Error Overlay'),
              ),
              const SizedBox(height: 32),
              const Text(
                'Advanced Examples',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  PopThis.pop(
                    context: context,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'First Popup',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'You can stack multiple popups!\nClick the button below to open another popup.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              PopThis.pop(
                                context: context,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Second Popup (Stacked)',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'Notice the back button appeared!\nYou can go back to the previous popup.',
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () {
                                          PopThis.pop(
                                            context: context,
                                            child: Container(
                                              padding: const EdgeInsets.all(20),
                                              constraints: const BoxConstraints(
                                                maxWidth: 250,
                                              ),
                                              child: const Text(
                                                'Third Popup!\n\nUse the back button to navigate through the popup stack.',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('Open Third Popup'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: const Text('Open Another Popup'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: const Text('Stacked Popups'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  PopThis.pop(
                    context: context,
                    popBackgroundColor: Colors.purple.shade50,
                    dismissBarrierColor: Colors.purple.withValues(alpha: 0.5),
                    shouldBlurBackgroundOverlayLayer: true,
                    popUpAnimationDuration: 0.6,
                    hasShadow: true,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.palette,
                            size: 50,
                            color: Colors.purple,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Custom Styled Popup',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'This popup has custom colors, blur effect, and custom animation duration!',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: const Text('Custom Styled Popup'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  PopThis.pop(
                    context: context,
                    popPositionOffset: const Offset(20, 100),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(maxWidth: 250),
                      child: const Text(
                        'Positioned Popup\n\nThis popup appears at a custom position on the screen!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
                child: const Text('Positioned Popup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
