import 'package:flutter/material.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';

class SoundslicedDartExtensionsExampleScreen extends StatefulWidget {
  const SoundslicedDartExtensionsExampleScreen({super.key});

  @override
  State<SoundslicedDartExtensionsExampleScreen> createState() =>
      _SoundslicedDartExtensionsExampleScreenState();
}

class _SoundslicedDartExtensionsExampleScreenState
    extends State<SoundslicedDartExtensionsExampleScreen> {
  final List<int> numbers = [1, 2, 3, 4, 5];
  String inputText = 'hello world. how are you?';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('soundsliced_dart_extensions Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Dart & Flutter Extensions Demo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Duration shortcuts
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Duration Shortcuts',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '5.seconds = ${5.seconds}',
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                      Text(
                        '2.minutes = ${2.minutes}',
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                      Text(
                        '1.hours = ${1.hours}',
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Combined: ${(5.seconds + 2.minutes + 1.hours).convertToEasyReadString()}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // String extensions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'String Extensions',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Original: "$inputText"',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Capitalized:\n"${inputText.capitalizeFirstLetterOfEverySentence()}"',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        '"true".parseBool() = ${"true".parseBool()}',
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                      Text(
                        '"false".parseBool() = ${"false".parseBool()}',
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // DateTime utilities
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DateTime Utilities',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Builder(
                        builder: (context) {
                          final now = DateTime.now();
                          final rounded =
                              now.toNearestMinute(nearestMinute: 15);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Now: ${now.convertToStringTime(showSeconds: true)}',
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                              Text(
                                'Rounded (15 min): ${rounded.convertToStringTime(showSeconds: true)}',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Month: ${now.convertToMonthString()}',
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // List extensions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Safe List Access',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'List: $numbers',
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'list.safe[2] = ${numbers.safe[2]} ✓',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'list.safe[10] = ${numbers.safe[10]} (safe!)',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chunks of 2: ${numbers.splitInChunks(2)}',
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // EdgeInsets helpers
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EdgeInsets Extensions',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: 12.leftPad,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: const Text('12.leftPad'),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: (8, 16).leftPad.rightPad,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Text('(8, 16).leftPad.rightPad'),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          border: Border.all(color: Colors.purple),
                          borderRadius: 8.topRad,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Text('8.topRad (BorderRadius)'),
                      ),
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
