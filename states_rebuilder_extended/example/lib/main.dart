import 'package:flutter/material.dart';
import 'package:states_rebuilder_extended/states_rebuilder_extended.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'states_rebuilder_extended Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
      appBar: AppBar(
        title: const Text('states_rebuilder_extended Example'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CounterWidget(),
            SizedBox(height: 20),
            ToggleWidget(),
            SizedBox(height: 20),
            MultiCounterWidget(),
          ],
        ),
      ),
    );
  }
}

// Example of safer update and builder
class CounterWidget extends StatelessWidget {
  const CounterWidget({super.key});

  static final counter = 0.inject();

  @override
  Widget build(BuildContext context) {
    return counter.builderData<int>(
      (count) => Column(
        children: [
          Text('Counter: $count'),
          ElevatedButton(
            onPressed: () => counter.update<int>((s) => s + 1),
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}

// Example of toggle
class ToggleWidget extends StatelessWidget {
  const ToggleWidget({super.key});

  static final isEnabled = false.inject();

  @override
  Widget build(BuildContext context) {
    return isEnabled.builderData<bool>(
      (enabled) => Column(
        children: [
          Text('Enabled: $enabled'),
          ElevatedButton(
            onPressed: () => isEnabled.toggle(),
            child: const Text('Toggle'),
          ),
        ],
      ),
    );
  }
}

// Example of multi-builder
class MultiCounterWidget extends StatelessWidget {
  const MultiCounterWidget({super.key});

  static final counters = [0.inject(), 0.inject(), 0.inject()];

  @override
  Widget build(BuildContext context) {
    return counters.builderDataIndexed(
      (index, count) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Counter $index: $count'),
          ElevatedButton(
            onPressed: () => counters.update<int>((s) => s + 1, index: index),
            child: const Text('+'),
          ),
        ],
      ),
    );
  }
}
