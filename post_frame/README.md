# post_frame

`post_frame` is a Flutter package that provides utilities to execute actions after the first frame is rendered, making it easy to schedule work that depends on layout or widget tree completion. It supports waiting for `ScrollController` metrics and end-of-frame passes for precise timing of UI-dependent logic.

Version 1.1.0 introduces comprehensive post-frame scheduling features:

**Core Features:**
* Advanced `PostFrame.run<T>()` with cancellation, timeout & diagnostics
* Declarative widget builders (`PostFrame.builder`, `PostFrame.simpleBuilder`)
* Frame iteration (`PostFrame.repeat`) with streams and intervals
* Layout size detection (`PostFrame.onLayout`) with stability checks
* Task serialization (`PostFrame.queueRun`) and debouncing (`PostFrame.debounced`)

**Developer Ergonomics:**
* BuildContext extensions: `context.postFrame()`, `context.postFrameRun()`, `context.postFrameDebounced()`
* Conditional execution with predicates and `PostFramePredicates` helpers
* Global and per-call error handling (`PostFrame.errorHandler`, `onError` parameter)
* Rich diagnostics via `PostFrameResult<T>`

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  post_frame: ^1.1.0
```

## Features

- Execute actions after the first frame is rendered using `PostFrame.postFrame`.
- Optionally wait for end-of-frame passes for more accurate layout timing.
- Wait for `ScrollController` metrics to be available before executing actions.
 - Supply multiple scroll controllers to wait on complex composite layouts.
 - Configure maximum wait frames to avoid indefinite waiting in edge cases.

## Usage

```dart
import 'package:post_frame/post_frame.dart';

// Example: update state after first frame
PostFrame.postFrame(() {
  // Your code here, e.g. setState or navigation
});
```

### Full Example

```dart
import 'package:flutter/material.dart';
import 'package:post_frame/post_frame.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PostFrame Example',
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  String _message = 'Waiting for post frame...';

  @override
  void initState() {
    super.initState();
    PostFrame.postFrame(() {
      setState(() {
        _message = 'This ran after the first frame!';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PostFrame Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_message),
            ElevatedButton(
              onPressed: () {
                PostFrame.postFrame(() {
                  setState(() {
                    _message = 'Button pressed after frame!';
                  });
                });
              },
              child: const Text('Press Me'),
            ),
          ],
        ),
      ),
    );
  }
}
```

See `example/lib/main.dart` for the minimal quick start.

For comprehensive demonstrations (builders, repeat, queueRun, onLayout, predicates, debouncing, error handling, diagnostics) open `example/lib/advanced_examples.dart` and use `PostFrameExampleApp` as your app root.

### Advanced Usage

Use multiple scroll controllers and tune waiting behavior. This ensures your logic runs only after nested scrolling regions have stable metrics and several frame passes are complete.

```dart
import 'package:post_frame/post_frame.dart';

// Inside a State class
final ScrollController outerController = ScrollController();
final ScrollController innerController = ScrollController();

@override
void initState() {
  super.initState();
  PostFrame.postFrame(() {
    // Safe to access sizes, scroll extents, etc.
    debugPrint('Metrics stable: ' + outerController.position.maxScrollExtent.toString());
  },
    scrollControllers: [outerController, innerController],
    maxWaitFrames: 10,          // Give layout time to stabilize
    waitForEndOfFrame: true,     // Await endOfFrame signals
    endOfFramePasses: 3,         // Extra passes for animations/layout settling
  );
}
```

The advanced auto-scroll merged example lives in `example/lib/advanced_examples.dart` and demonstrates:
1. Waiting on multiple scroll controllers.
2. Tuned `maxWaitFrames` and `endOfFramePasses`.
3. Auto-scrolling after metrics stabilization.

### Cancellation & Timeout

Use the advanced API when you need finer control:

```dart
final task = PostFrame.run<String>(() => 'Ready',
  scrollControllers: [outerController, innerController],
  maxWaitFrames: 6,
  endOfFramePasses: 2,
  waitForEndOfFrame: true,
  timeout: const Duration(seconds: 2),
);

// Optional: cancel before completion
task.cancel();

task.future.then((result) {
  if (result.canceled) {
    debugPrint('Action canceled');
  } else if (result.hasError) {
    debugPrint('Failed: ${result.error}');
  } else {
    debugPrint('Value: ${result.value} waited: ${result.totalFramesWaited} frames');
  }
});
```

### Builder Helpers

Use `PostFrame.builder` for full control over the snapshot, or `PostFrame.simpleBuilder` for a ready‑made loading/data/error pattern.

```dart
// Full control builder
PostFrame.builder<int>(
  scrollControllers: [verticalController],
  maxWaitFrames: 4,
  endOfFramePasses: 2,
  action: () => verticalController.hasClients
      ? verticalController.position.maxScrollExtent.toInt()
      : 0,
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    final result = snapshot.data!;
    if (result.canceled) return const Text('Canceled');
    if (result.hasError) return Text('Error: ${result.error}');
    return Text('Extent: ${result.value}, waited ${result.totalFramesWaited} frames');
  },
);

// Simple builder convenience
PostFrame.simpleBuilder<int>(
  action: () => 42,
  dataBuilder: (result) => Text('Value: ${result.value}'),
);
```


### Repeat Tasks

Run an action every frame (optionally after endOfFrame) until canceled or a maximum iteration count is reached:

```dart
final repeater = PostFrame.repeat((i) {
  debugPrint('Iteration: $i');
  if (i == 9) repeater.cancel(); // Stop after 10 iterations.
}, maxIterations: 10);

// Listen to iteration stream (optional):
repeater.iterationStream.listen((i) => debugPrint('Stream iteration: $i'));

// Await completion:
await repeater.done;
```

Parameters:
| Parameter | Use |
|-----------|-----|
| `maxIterations` | Upper bound; if null repeats indefinitely until canceled. |
| `interval` | Inserts delay between iterations (throttling). |
| `waitForEndOfFrame` | If true, waits for pipeline drain each loop. |

### Waiting for Layout (`onLayout`)

Wait for a widget's size to become available and stable across successive frames:

```dart
final key = GlobalKey();
// In build: SizedBox(key: key, width: 200, height: 80)
final size = await PostFrame.onLayout(key, maxWaitFrames: 15);
if (size != null) {
  debugPrint('Stable size: $size');
}
```

Parameters:
| Parameter | Purpose |
|-----------|---------|
| `maxWaitFrames` | Upper bound on frame polls. |
| `stabilityFrames` | Required consecutive identical sizes. |
| `waitForEndOfFrame` | Use endOfFrame for stronger layout finality. |

### Queued Post-frame Runs

Ensure multiple advanced tasks execute sequentially:

```dart
final first = PostFrame.queueRun(() => 'A');
final second = PostFrame.queueRun(() => 'B');

final a = await first.future; // Completes before second starts
final b = await second.future;
debugPrint('${a.value}, ${b.value}'); // A, B
```

You can clear not-yet-started tasks:

```dart
PostFrame.clearQueue();
```

### BuildContext Extensions

Use convenient extensions for ergonomic widget-context access with automatic mounted checks:

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Simple post-frame with mounted check
    context.postFrame(() {
      // Safe: automatically checks if widget is mounted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Frame complete')),
      );
    });

    // Advanced with cancellation and diagnostics
    context.postFrameRun<int>(() {
      return 42;
    }, timeout: const Duration(seconds: 1));

    // Debounced (cancels previous tasks with same key)
    context.postFrameDebounced(() {
      // Only latest call executes
    }, debounceKey: 'myKey');

    return Container();
  }
}
```

### Conditional Execution with Predicates

Control when actions execute using predicates:

```dart
// Only execute if mounted
PostFrame.run(() {
  // action
}, predicate: PostFramePredicates.mounted(context));

// Only if route is still active
PostFrame.run(() {
  // action
}, predicate: PostFramePredicates.routeActive(context));

// Only if scroll extent meets threshold
PostFrame.run(() {
  // action
}, predicate: PostFramePredicates.scrollExtentAtLeast(controller, 100.0));

// Combine predicates with AND/OR/NOT
PostFrame.run(() {
  // action
}, predicate: PostFramePredicates.all([
  PostFramePredicates.mounted(context),
  PostFramePredicates.routeActive(context),
]));
```

Available predicates:
* `PostFramePredicates.mounted(context)` - Widget is still mounted
* `PostFramePredicates.stateMounted(state)` - State is still mounted
* `PostFramePredicates.routeActive(context)` - Current route is active
* `PostFramePredicates.scrollControllerHasClients(controller)` - Controller has clients
* `PostFramePredicates.scrollExtentAtLeast(controller, minExtent)` - Scroll extent threshold
* `PostFramePredicates.all([...])` - Combine with AND logic
* `PostFramePredicates.any([...])` - Combine with OR logic
* `PostFramePredicates.not(predicate)` - Negate predicate

### Debounced Actions

Prevent redundant work by canceling previous pending tasks:

```dart
// Rapid successive calls - only last executes
for (var i = 0; i < 100; i++) {
  PostFrame.debounced(() {
    debugPrint('Only once!');
  }, debounceKey: 'my-operation');
}

// Different keys don't interfere
PostFrame.debounced(() => updateUI(), debounceKey: 'ui');
PostFrame.debounced(() => saveData(), debounceKey: 'save');
```

### Error Handling

Set up global error handling for debugging:

```dart
void main() {
  // Global handler for all PostFrame errors
  PostFrame.errorHandler = (error, stack, operation) {
    debugPrint('PostFrame error in $operation: $error');
    // Log to analytics, crash reporting, etc.
  };

  runApp(MyApp());
}

// Per-call error handler
PostFrame.run(() {
  throw Exception('Oops');
}, onError: (error, stack) {
  // Handle specific error
  debugPrint('Task failed: $error');
});
```

### Diagnostics (PostFrameResult)

Fields available:
* `value` - The returned value from the callback (if successful).
* `canceled` - Whether the task was canceled before completion.
* `error` / `stackTrace` - Error information if callback threw or timeout occurred.
* `endOfFramePassesWaited` - Number of end-of-frame passes actually waited.
* `scrollMetricWaitFrames` - Number of frame polls spent waiting on scroll metrics.
* `totalFramesWaited` - Sum of all frame waits (passes + metric polls).
* `controllers` - The controllers targeted for stabilization.

### Parameter Reference

| Parameter | Purpose | Recommended Use |
|-----------|---------|-----------------|
| `scrollControllers` | Ensures each controller has clients and stable metrics before running action. | Pass all controllers you depend on (e.g., nested `ListView`, `PageView`). |
| `maxWaitFrames` | Upper bound on how many frames to wait for metrics stabilization. | Increase for complex layouts; default `5` covers most simple screens. |
| `waitForEndOfFrame` | If true, waits for `binding.endOfFrame` before running action. | Keep true when syncing with final layout/paint. |
| `endOfFramePasses` | Additional end-of-frame passes to allow animations/rebuilds to settle. | Use `2-4` when lists populate asynchronously. |

### Best Practices

1. Keep `maxWaitFrames` modest to avoid excessive delays.
2. Consider wrapping `PostFrame.postFrame` inside your own utility for repeated patterns.
3. Avoid heavy synchronous work in the callback; schedule microtasks or isolates if needed.
4. If you need cancellation, consider a wrapper Future that you can ignore (feature planned).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Repository

https://github.com/SoundSliced/post_frame
