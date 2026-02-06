import 'package:flutter/material.dart';
import 'package:bubble_label/bubble_label.dart';

class BubbleLabelExampleScreen extends StatelessWidget {
  const BubbleLabelExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BubbleLabel Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Tap buttons to show bubbles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Basic bubble
              Builder(
                builder: (btnContext) {
                  return ElevatedButton(
                    onPressed: () {
                      BubbleLabel.show(
                        context: btnContext,
                        bubbleContent: BubbleLabelContent(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'This is a bubble label! 🎈',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            ),
                          ),
                          bubbleColor: Colors.blue,
                          backgroundOverlayLayerOpacity: 0.3,
                        ),
                        animate: true,
                      );
                    },
                    child: const Text('Show Blue Bubble'),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Green bubble without overlay
              Builder(
                builder: (btnContext) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      BubbleLabel.show(
                        context: btnContext,
                        bubbleContent: BubbleLabelContent(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'No background overlay',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            ),
                          ),
                          bubbleColor: Colors.green,
                          backgroundOverlayLayerOpacity: 0.0,
                          verticalPadding: 20,
                        ),
                        animate: true,
                      );
                    },
                    child: const Text(
                      'Green Bubble (No Overlay)',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Custom styled bubble with tap callback
              Builder(
                builder: (btnContext) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                    onPressed: () {
                      BubbleLabel.show(
                        context: btnContext,
                        bubbleContent: BubbleLabelContent(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Builder(
                              builder: (context) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Tap outside to dismiss',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Icon(
                                    Icons.info_outline,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    size: 32,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          bubbleColor: Colors.purple,
                          backgroundOverlayLayerOpacity: 0.5,
                          onTapOutside: (_) {
                            BubbleLabel.dismiss(animate: true);
                          },
                        ),
                        animate: true,
                      );
                    },
                    child: const Text(
                      'Purple Info Bubble',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              // Dismiss button
              OutlinedButton(
                onPressed: () {
                  if (BubbleLabel.isActive) {
                    BubbleLabel.dismiss(animate: true);
                  }
                },
                child: const Text('Dismiss Active Bubble'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
