import 'package:flutter/material.dart';
import 'package:signals_watch/signals_watch.dart';

void main() {
  // Enable selective signal tracking - only labeled signals will be logged
  SignalsWatch.initializeSignalsObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignalsWatch Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExamplesPage(),
    );
  }
}

// Global signals with debug labels for tracking
final counter = SignalsWatch.signal(0, debugLabel: 'counter');
final searchQuery = SignalsWatch.signal('', debugLabel: 'search.query');
final user =
    SignalsWatch.signal(User(name: 'John', age: 25), debugLabel: 'user');

class User {
  final String name;
  final int age;

  User({required this.name, required this.age});

  @override
  String toString() => 'User(name: $name, age: $age)';
}

class ExamplesPage extends StatelessWidget {
  const ExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WatchValue Signal Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Basic Counter',
            'Simple signal watching with callback',
            const BasicCounterExample(),
          ),
          _buildSection(
            'Debounced Search',
            'Search with 500ms debounce',
            const DebouncedSearchExample(),
          ),
          _buildSection(
            'Conditional Updates',
            'Only notifies when counter > 10',
            const ConditionalExample(),
          ),
          _buildSection(
            'Selector Pattern',
            'Only rebuilds when age changes',
            const SelectorExample(),
          ),
          _buildSection(
            'Multiple Signals',
            'Combines name and age',
            const MultipleSignalsExample(),
          ),
          _buildSection(
            'Widget Override Precedence',
            'Widget onValueUpdated overrides signal-level onValueUpdated',
            const WidgetOverrideExample(),
          ),
          _buildSection(
            'Custom Equals',
            'Ignore specific fields using equals (ignore name changes)',
            const CustomEqualsExample(),
          ),
          _buildSection(
            'Transform with .transform() (v0.4.0)',
            'Transform signal values with error handling',
            const TransformExample(),
          ),
          _buildSection(
            'Computed Signal',
            'Doubled value derived from counter with callbacks',
            const ComputedExample(),
          ),
          _buildSection(
            'Lifecycle Callbacks',
            'onInit, onAfterBuild, onDispose at signal level',
            const LifecycleCallbacksExample(),
          ),
          _buildSection(
            'Reset API',
            'Restore initial value and trigger callbacks',
            const ResetExample(),
          ),
          _buildSection(
            'ShouldRebuild vs ShouldNotify',
            'Rebuild only on even numbers; still notify on every change',
            const ShouldRebuildExample(),
          ),
          _buildSection(
            'Async: fromFuture',
            'Loading and error builders with lifecycle callbacks',
            const FromFutureExample(),
          ),
          _buildSection(
            'Async: fromStream',
            'Stream updates with lifecycle callbacks',
            const FromStreamExample(),
          ),
          _buildSection(
            'Debug Trace & Observer',
            'Debug labels + initializeSignalsObserver()',
            const DebugTraceExample(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String description, Widget example) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            example,
          ],
        ),
      ),
    );
  }
}

// Example 1: Basic Counter
class BasicCounterExample extends StatelessWidget {
  const BasicCounterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Using fluent .observe() syntax instead of SignalsWatch.fromSignal
        counter.observe(
          (value) =>
              Text('Count: $value', style: const TextStyle(fontSize: 24)),
          onValueUpdated: (value, previous) {
            debugPrint('Counter changed: $previous -> $value');
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => counter.value++,
              child: const Text('Increment'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => counter.value--,
              child: const Text('Decrement'),
            ),
          ],
        ),
      ],
    );
  }
}

// Example 2: Debounced Search
class DebouncedSearchExample extends StatelessWidget {
  const DebouncedSearchExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search',
            hintText: 'Type to search...',
            border: OutlineInputBorder(),
          ),
          onChanged: (text) => searchQuery.value = text,
        ),
        const SizedBox(height: 8),
        SignalsWatch.fromSignal(
          searchQuery,
          debounce: const Duration(milliseconds: 500),
          onValueUpdated: (query) {
            debugPrint('Searching for: $query');
          },
          builder: (query) => Text(
            query.isEmpty ? 'Start typing...' : 'Searching: "$query"',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

// Example 3: Conditional Updates
class ConditionalExample extends StatelessWidget {
  const ConditionalExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SignalsWatch.fromSignal(
          counter,
          shouldNotify: (value, _) => value > 10,
          onValueUpdated: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Threshold exceeded: $value')),
            );
          },
          builder: (value) => Column(
            children: [
              Text('Count: $value', style: const TextStyle(fontSize: 24)),
              Text(
                value > 10 ? '✓ Above threshold' : 'Below threshold (10)',
                style: TextStyle(
                  color: value > 10 ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Example 4: Selector Pattern
class SelectorExample extends StatelessWidget {
  const SelectorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Using fluent .selectObserve() syntax
        user.selectObserve(
          (u) => (u as User).age,
          (age) => Text('Age: $age', style: const TextStyle(fontSize: 20)),
          onValueUpdated: (age, previousAge) {
            debugPrint('Age changed: $previousAge -> $age');
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => user.value = User(
                name: user.value.name,
                age: user.value.age + 1,
              ),
              child: const Text('Birthday'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                // This won't trigger rebuild (name change ignored)
                user.value = User(
                  name: '${user.value.name}!',
                  age: user.value.age,
                );
              },
              child: const Text('Change Name'),
            ),
          ],
        ),
      ],
    );
  }
}

// Example 5: Multiple Signals
class MultipleSignalsExample extends StatelessWidget {
  const MultipleSignalsExample({super.key});

  @override
  Widget build(BuildContext context) {
    final firstName = SignalsWatch.signal('John');
    final lastName = SignalsWatch.signal('Doe');

    return Column(
      children: [
        // Using fluent list .observe() syntax
        [firstName, lastName].observe(
          combine: (values) => '${values[0]} ${values[1]}',
          builder: (fullName) =>
              Text(fullName, style: const TextStyle(fontSize: 20)),
          onValueUpdated: (fullName) {
            debugPrint('Full name: $fullName');
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => firstName.value = 'Jane',
              child: const Text('Change First'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => lastName.value = 'Smith',
              child: const Text('Change Last'),
            ),
          ],
        ),
      ],
    );
  }
}

// Example 6a: Widget Override Precedence
class WidgetOverrideExample extends StatefulWidget {
  const WidgetOverrideExample({super.key});

  @override
  State<WidgetOverrideExample> createState() => _WidgetOverrideExampleState();
}

class _WidgetOverrideExampleState extends State<WidgetOverrideExample> {
  final sig = SignalsWatch.signal(
    0,
    debugLabel: 'override.sig',
    onValueUpdated: (v, p) => debugPrint(
      '[signal-level] $p -> $v (suppressed if any widget overrides)',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Two widgets listening to the same signal:'),
        const SizedBox(height: 6),
        // Widget A: overrides onValueUpdated (suppresses signal-level callback globally)
        SignalsWatch.fromSignal(
          sig,
          onValueUpdated: (v, p) => debugPrint('[widget-level A] $p -> $v'),
          builder: (v) => Text('Widget A value: $v (overrides callback)'),
        ),
        const SizedBox(height: 4),
        // Widget B: no override; since widget A overrides, signal-level callback is suppressed
        SignalsWatch.fromSignal(
          sig,
          builder: (v) => Text('Widget B value: $v (no override)'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => sig.value++,
              child: const Text('Increment'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => sig.value = 0,
              child: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Check logs: only [widget-level A] should appear; signal-level suppressed.',
        ),
      ],
    );
  }
}

// Example 6b: Custom Equals (ignore name changes)
class CustomEqualsExample extends StatefulWidget {
  const CustomEqualsExample({super.key});

  @override
  State<CustomEqualsExample> createState() => _CustomEqualsExampleState();
}

class _CustomEqualsExampleState extends State<CustomEqualsExample> {
  final u = SignalsWatch.signal(User(name: 'Alice', age: 30));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SignalsWatch.fromSignal(
          u,
          equals: (User a, User b) => a.age == b.age, // ignore name changes
          onValueUpdated: (User v, User? p) => debugPrint('[equals] $p -> $v'),
          builder: (user) => Text(
            'User: ${user.name}, ${user.age} (rebuilds only when age changes)',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => setState(() {
                u.value = User(name: '${u.value.name}*', age: u.value.age);
              }),
              child: const Text('Change Name'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => setState(() {
                u.value = User(name: u.value.name, age: u.value.age + 1);
              }),
              child: const Text('Increase Age'),
            ),
          ],
        ),
      ],
    );
  }
}

// Example 5.5: Transform with .transform() (v0.4.0)
class TransformExample extends StatefulWidget {
  const TransformExample({super.key});

  @override
  State<TransformExample> createState() => _TransformExampleState();
}

class _TransformExampleState extends State<TransformExample> {
  final temperatureC = SignalsWatch.signal<double>(25.0);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Temperature Converter with Validation'),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Celsius:'),
            const SizedBox(width: 8),
            temperatureC.observe(
              (temp) => Text(
                '${temp.toStringAsFixed(1)}°C',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Using .transform() to transform Celsius to Fahrenheit with validation
        temperatureC.transform<String>(
          (celsius) {
            // Validate temperature range
            if (celsius < -273.15) {
              throw ArgumentError('Temperature below absolute zero!');
            }
            if (celsius > 1000) {
              throw ArgumentError('Temperature too high!');
            }
            // Convert to Fahrenheit
            final fahrenheit = (celsius * 9 / 5) + 32;
            return '${fahrenheit.toStringAsFixed(1)}°F';
          },
          builder: (fahrenheitStr) => Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.green),
            ),
            child: Text(
              'Fahrenheit: $fahrenheitStr',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
          ),
          onError: (error, stack) {
            debugPrint('Temperature error: $error');
          },
          errorBuilder: (error) => Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.red),
            ),
            child: Text(
              'Error: ${error.toString().replaceAll('Invalid argument(s): ', '')}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => temperatureC.value += 10,
              child: const Text('+10°C'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => temperatureC.value -= 10,
              child: const Text('-10°C'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => temperatureC.value = -300, // Triggers error
              child: const Text('Test Error'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Try the error button to see errorBuilder in action!',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

// Example 6: Computed Signal
class ComputedExample extends StatelessWidget {
  const ComputedExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Computed derived from the global counter
    final doubled = SignalsWatch.computed(
      () => counter.value * 2,
      onValueUpdated: (value, previous) {
        debugPrint('Doubled changed: $previous -> $value');
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Counter:'),
            const SizedBox(width: 8),
            counter.observe((v) => Text('$v')),
            const SizedBox(width: 24),
            const Text('Doubled:'),
            const SizedBox(width: 8),
            doubled.observe((v) => Text('$v')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => counter.value++,
              child: const Text('Increment Counter'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => counter.value = 0,
              child: const Text('Reset Counter'),
            ),
          ],
        ),
      ],
    );
  }
}

// Example 7: Lifecycle Callbacks (signal-level)
class LifecycleCallbacksExample extends StatefulWidget {
  const LifecycleCallbacksExample({super.key});

  @override
  State<LifecycleCallbacksExample> createState() =>
      _LifecycleCallbacksExampleState();
}

class _LifecycleCallbacksExampleState extends State<LifecycleCallbacksExample> {
  bool _mounted = true;

  // Create a signal with lifecycle callbacks at signal level
  final lifecycleSignal = SignalsWatch.signal(
    0,
    debugLabel: 'lifecycle',
    onInit: (value) => debugPrint('[lifecycle] onInit: $value'),
    onAfterBuild: (value) => debugPrint('[lifecycle] onAfterBuild: $value'),
    onDispose: (value) => debugPrint('[lifecycle] onDispose: $value'),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () => setState(() => _mounted = !_mounted),
              child: Text(_mounted ? 'Unmount widget' : 'Mount widget'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => lifecycleSignal.value++,
              child: const Text('Increment'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_mounted)
          SignalsWatch.fromSignal(
            lifecycleSignal,
            builder: (value) => Text('Lifecycle value: $value'),
          ),
      ],
    );
  }
}

// Example 8: Reset API
class ResetExample extends StatefulWidget {
  const ResetExample({super.key});

  @override
  State<ResetExample> createState() => _ResetExampleState();
}

class _ResetExampleState extends State<ResetExample> {
  final local = SignalsWatch.signal(
    5,
    onValueUpdated: (value, previous) =>
        debugPrint('local: $previous -> $value'),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SignalsWatch.fromSignal(
          local,
          builder: (v) => Text('Value: $v'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => local.value++,
              child: const Text('Increment'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => local.reset(),
              child: const Text('Reset to initial (5)'),
            ),
          ],
        ),
      ],
    );
  }
}

// Example 9: ShouldRebuild vs ShouldNotify
class ShouldRebuildExample extends StatefulWidget {
  const ShouldRebuildExample({super.key});

  @override
  State<ShouldRebuildExample> createState() => _ShouldRebuildExampleState();
}

class _ShouldRebuildExampleState extends State<ShouldRebuildExample> {
  final sig = SignalsWatch.signal(0);
  int buildCount = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SignalsWatch.fromSignal(
          sig,
          shouldRebuild: (n, o) => n % 2 == 0, // rebuild only on even values
          onValueUpdated: (n, o) => debugPrint('onValueUpdated: $o -> $n'),
          builder: (v) {
            buildCount++;
            return Text(
              'Value: $v | buildCount: $buildCount (rebuild on even)',
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => sig.value++,
              child: const Text('+1'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => sig.value += 2,
              child: const Text('+2'),
            ),
          ],
        ),
      ],
    );
  }
}

// Example 10: Async fromFuture
class FromFutureExample extends StatefulWidget {
  const FromFutureExample({super.key});

  @override
  State<FromFutureExample> createState() => _FromFutureExampleState();
}

class _FromFutureExampleState extends State<FromFutureExample> {
  bool _error = false;

  Future<int> _load() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (_error) {
      throw Exception('Failed to load');
    }
    return 42;
  }

  @override
  Widget build(BuildContext context) {
    final futureSignal = SignalsWatch.fromFuture(
      _load(),
      initialValue: 0,
      onInit: (v) => debugPrint('[future] onInit: $v'),
      onValueUpdated: (v, p) => debugPrint('[future] $p -> $v'),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () => setState(() => _error = !_error),
              child: Text(_error ? 'Set: success' : 'Set: throw error'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SignalsWatch.fromSignal(
          futureSignal,
          loadingBuilder: () => const Text('Loading...'),
          errorBuilder: (err) =>
              Text('Error: $err', style: const TextStyle(color: Colors.red)),
          builder: (v) => Text('Loaded value: $v'),
        ),
      ],
    );
  }
}

// Example 11: Async fromStream
class FromStreamExample extends StatelessWidget {
  const FromStreamExample({super.key});

  @override
  Widget build(BuildContext context) {
    final stream =
        Stream<int>.periodic(const Duration(milliseconds: 300), (i) => i + 1)
            .take(5);
    final streamSignal = SignalsWatch.fromStream(
      stream,
      initialValue: 0,
      onValueUpdated: (v, p) => debugPrint('[stream] $p -> $v'),
    );

    return SignalsWatch.fromSignal(
      streamSignal,
      builder: (v) => Text('Stream value: $v'),
    );
  }
}

// Example 12: Debug Trace & Observer
class DebugTraceExample extends StatelessWidget {
  const DebugTraceExample({super.key});

  @override
  Widget build(BuildContext context) {
    final debugSig = SignalsWatch.signal(0, debugLabel: 'debug.counter');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SignalsWatch.fromSignal(
          debugSig,
          debugLabel: 'widget.debug',
          debugPrint: true,
          onValueUpdated: (v, p) => debugPrint('[widget] $p -> $v'),
          builder: (v) => Text('Debug counter: $v'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => debugSig.value++,
              child: const Text('Increment (logs)'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => debugSig.value = 0,
              child: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Check console for SelectiveSignalsObserver logs for labeled signals.',
        ),
      ],
    );
  }
}
