import 'package:flutter/material.dart';
import 'package:post_frame/post_frame.dart';

// ---------------------------------------------------------------------------
// Advanced Examples - PostFrame Package v1.1.0
// ---------------------------------------------------------------------------
// This file contains comprehensive demonstrations of ALL major features:
// 1. Basic postFrame() with scroll controller metrics stabilization
// 2. Advanced run() with cancellation, timeout, and diagnostics
// 3. Builder widgets (PostFrame.builder, PostFrame.simpleBuilder)
// 4. Repeat tasks with iteration streams
// 5. onLayout() waiting for widget size stabilization
// 6. Queue serialization (queueRun)
// 7. BuildContext extensions (postFrame, postFrameRun, postFrameDebounced)
// 8. Conditional execution with predicates
// 9. Debounced actions
// 10. Error handling (global and local)
//
// NOTE: This is NOT the entrypoint for the example app. The minimal quick
// start lives in lib/main.dart. To explore everything, use PostFrameExampleApp.
// ---------------------------------------------------------------------------

/// Optional helper to install a global error handler before running the
/// advanced example app. Call this in your own main() if desired.
void initPostFrameErrorHandler() {
  PostFrame.errorHandler = (error, stack, operation) {
    debugPrint('⚠️ PostFrame error in $operation: $error');
  };
}

class PostFrameExampleApp extends StatelessWidget {
  const PostFrameExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PostFrame Advanced Examples',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const ExampleHomePage(),
    );
  }
}

/// Main navigation page with links to all feature examples.
class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PostFrame Examples')),
      body: ListView(
        children: [
          _buildTile(
            context,
            'Basic Usage',
            'postFrame() with scroll metrics',
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BasicExample())),
          ),
          _buildTile(
            context,
            'Advanced API',
            'run() with cancellation & timeout',
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdvancedExample())),
          ),
          _buildTile(
            context,
            'Builder Widgets',
            'builder() and simpleBuilder()',
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BuilderExample())),
          ),
          _buildTile(
            context,
            'Repeat Tasks',
            'repeat() with iterations',
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RepeatExample())),
          ),
          _buildTile(
            context,
            'Layout Waiting',
            'onLayout() for size stabilization',
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LayoutExample())),
          ),
          _buildTile(
            context,
            'Queue Serialization',
            'queueRun() for sequential tasks',
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const QueueExample())),
          ),
          _buildTile(
            context,
            'Context Extensions',
            'context.postFrame() helpers',
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ExtensionsExample())),
          ),
          _buildTile(
            context,
            'Conditional Execution',
            'Predicates & debouncing',
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ConditionalExample())),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
      BuildContext context, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

// ---------------------------------------------------------------------------
// 1. Basic Example
// ---------------------------------------------------------------------------
class BasicExample extends StatefulWidget {
  const BasicExample({super.key});

  @override
  State<BasicExample> createState() => _BasicExampleState();
}

class _BasicExampleState extends State<BasicExample> {
  final ScrollController verticalController = ScrollController();
  final ScrollController horizontalController = ScrollController();

  String status = 'Waiting for metrics & frame passes...';
  bool autoScrollDone = false;

  @override
  void initState() {
    super.initState();

    PostFrame.postFrame(() async {
      setState(() => status = 'Metrics stable, starting auto-scroll...');
      if (horizontalController.hasClients) {
        final maxH = horizontalController.position.maxScrollExtent;
        if (maxH > 0) {
          await horizontalController.animateTo(
            maxH,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
          );
        }
      }
      if (verticalController.hasClients) {
        final maxV = verticalController.position.maxScrollExtent;
        final target = maxV * 0.5;
        await verticalController.animateTo(
          target,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutQuad,
        );
      }
      setState(() {
        autoScrollDone = true;
        status = 'Auto-scroll complete.';
      });
    },
        scrollControllers: [verticalController, horizontalController],
        maxWaitFrames: 8,
        waitForEndOfFrame: true,
        endOfFramePasses: 3);
  }

  @override
  void dispose() {
    verticalController.dispose();
    horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    status,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (!autoScrollDone)
                  const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
          ),
          SizedBox(
            height: 110,
            child: ListView.builder(
              controller: horizontalController,
              scrollDirection: Axis.horizontal,
              itemCount: 40,
              itemBuilder: (context, i) => Container(
                width: 90,
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.indigo[(i % 9 + 1) * 100],
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child:
                    Text('H $i', style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              controller: verticalController,
              itemCount: 60,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, idx) => ListTile(
                title: Text('Vertical Item $idx'),
                subtitle: const Text('Demonstrating metrics stabilization'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            status = 'Re-scheduling post-frame actions...';
            autoScrollDone = false;
          });
          PostFrame.postFrame(() async {
            setState(() => status = 'Metrics stable (manual), scrolling...');
            if (horizontalController.hasClients) {
              await horizontalController.animateTo(
                horizontalController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
              );
            }
            if (verticalController.hasClients) {
              await verticalController.animateTo(
                verticalController.position.maxScrollExtent * 0.25,
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutQuad,
              );
            }
            setState(() {
              status = 'Manual auto-scroll complete.';
              autoScrollDone = true;
            });
          },
              scrollControllers: [verticalController, horizontalController],
              maxWaitFrames: 5,
              waitForEndOfFrame: true,
              endOfFramePasses: 2);
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Re-run'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Advanced Example - run() with cancellation & timeout
// ---------------------------------------------------------------------------
class AdvancedExample extends StatefulWidget {
  const AdvancedExample({super.key});

  @override
  State<AdvancedExample> createState() => _AdvancedExampleState();
}

class _AdvancedExampleState extends State<AdvancedExample> {
  PostFrameTask<String>? currentTask;
  String result = 'No task started';
  int framesWaited = 0;

  void _startTask() {
    setState(() {
      result = 'Task running...';
      framesWaited = 0;
    });

    currentTask = PostFrame.run<String>(
      () => 'Task completed successfully',
      maxWaitFrames: 3,
      waitForEndOfFrame: true,
      endOfFramePasses: 2,
      timeout: const Duration(seconds: 5),
      onError: (error, stack) {
        debugPrint('Task error: $error');
      },
    );

    currentTask!.future.then((r) {
      if (mounted) {
        setState(() {
          if (r.canceled) {
            result = 'Task was canceled';
          } else if (r.hasError) {
            result = 'Task error: ${r.error}';
          } else {
            result = 'Result: ${r.value}';
            framesWaited = r.totalFramesWaited;
          }
        });
      }
    });
  }

  void _cancelTask() {
    currentTask?.cancel();
    setState(() => result = 'Task canceled by user');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced API')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(result, style: Theme.of(context).textTheme.titleLarge),
            if (framesWaited > 0) ...[
              const SizedBox(height: 8),
              Text('Waited $framesWaited frames'),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startTask,
              child: const Text('Start Task'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _cancelTask,
              child: const Text('Cancel Task'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Builder Example
// ---------------------------------------------------------------------------
class BuilderExample extends StatelessWidget {
  const BuilderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Builder Widgets')),
      body: Column(
        children: [
          Expanded(
            child: PostFrame.builder<int>(
              action: () => DateTime.now().millisecond,
              maxWaitFrames: 2,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final result = snapshot.data!;
                if (result.canceled) return const Text('Canceled');
                if (result.hasError) return Text('Error: ${result.error}');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Value: ${result.value}',
                          style: Theme.of(context).textTheme.headlineMedium),
                      Text('Frames waited: ${result.totalFramesWaited}'),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: PostFrame.simpleBuilder<String>(
              action: () => 'Simple builder result',
              dataBuilder: (result) => Center(
                child: Text(
                  result.value ?? '',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Repeat Example
// ---------------------------------------------------------------------------
class RepeatExample extends StatefulWidget {
  const RepeatExample({super.key});

  @override
  State<RepeatExample> createState() => _RepeatExampleState();
}

class _RepeatExampleState extends State<RepeatExample> {
  PostFrameRepeater? repeater;
  List<int> iterations = [];

  void _startRepeater() {
    setState(() => iterations.clear());

    repeater = PostFrame.repeat(
      (i) {
        setState(() => iterations.add(i));
      },
      maxIterations: 10,
      waitForEndOfFrame: true,
    );

    repeater!.iterationStream.listen((i) {
      debugPrint('Stream: iteration $i');
    });

    repeater!.done.then((_) {
      debugPrint('Repeater completed');
    });
  }

  void _stopRepeater() {
    repeater?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Repeat Tasks')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Iterations: ${iterations.length}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: iterations.map((i) => Chip(label: Text('$i'))).toList(),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _startRepeater,
                  child: const Text('Start'),
                ),
                ElevatedButton(
                  onPressed: _stopRepeater,
                  child: const Text('Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Layout Example - onLayout()
// ---------------------------------------------------------------------------
class LayoutExample extends StatefulWidget {
  const LayoutExample({super.key});

  @override
  State<LayoutExample> createState() => _LayoutExampleState();
}

class _LayoutExampleState extends State<LayoutExample> {
  final GlobalKey _boxKey = GlobalKey();
  Size? detectedSize;
  bool waiting = false;

  Future<void> _detectSize() async {
    setState(() {
      waiting = true;
      detectedSize = null;
    });

    final size = await PostFrame.onLayout(_boxKey, maxWaitFrames: 20);

    if (mounted) {
      setState(() {
        detectedSize = size;
        waiting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Layout Waiting')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              key: _boxKey,
              width: 200,
              height: 150,
              color: Colors.blue.shade100,
              alignment: Alignment.center,
              child: const Text('Target Widget'),
            ),
            const SizedBox(height: 24),
            if (waiting)
              const CircularProgressIndicator()
            else if (detectedSize != null)
              Text('Detected size: $detectedSize',
                  style: Theme.of(context).textTheme.titleMedium)
            else
              const Text('Press button to detect size'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: waiting ? null : _detectSize,
              child: const Text('Detect Size'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. Queue Example - queueRun()
// ---------------------------------------------------------------------------
class QueueExample extends StatefulWidget {
  const QueueExample({super.key});

  @override
  State<QueueExample> createState() => _QueueExampleState();
}

class _QueueExampleState extends State<QueueExample> {
  List<String> executionLog = [];

  void _enqueueTask(String name) {
    PostFrame.queueRun<String>(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      return name;
    }).future.then((result) {
      if (mounted && !result.canceled) {
        setState(() => executionLog.add('✓ ${result.value}'));
      }
    });
  }

  void _clearQueue() {
    PostFrame.clearQueue();
    setState(() => executionLog.add('🗑️ Queue cleared'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Queue Serialization')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: executionLog.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text(executionLog[i]),
                ),
              ),
            ),
            const Divider(),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _enqueueTask('Task A'),
                  child: const Text('Enqueue A'),
                ),
                ElevatedButton(
                  onPressed: () => _enqueueTask('Task B'),
                  child: const Text('Enqueue B'),
                ),
                ElevatedButton(
                  onPressed: () => _enqueueTask('Task C'),
                  child: const Text('Enqueue C'),
                ),
                ElevatedButton(
                  onPressed: _clearQueue,
                  child: const Text('Clear Queue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7. Context Extensions Example
// ---------------------------------------------------------------------------
class ExtensionsExample extends StatefulWidget {
  const ExtensionsExample({super.key});

  @override
  State<ExtensionsExample> createState() => _ExtensionsExampleState();
}

class _ExtensionsExampleState extends State<ExtensionsExample> {
  String message = 'No action yet';

  void _usePostFrame(BuildContext context) {
    context.postFrame(() {
      if (mounted) {
        setState(() => message = 'context.postFrame() executed');
      }
    });
  }

  void _usePostFrameRun(BuildContext context) {
    context.postFrameRun<String>(() => 'Advanced result').future.then((result) {
      if (mounted && !result.canceled) {
        setState(() => message = 'context.postFrameRun(): ${result.value}');
      }
    });
  }

  void _useDebounced(BuildContext context) {
    for (var i = 0; i < 5; i++) {
      context.postFrameDebounced(
        () {
          if (mounted) {
            setState(() => message = 'Debounced: executed once');
          }
        },
        debounceKey: 'example',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Context Extensions')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _usePostFrame(context),
              child: const Text('context.postFrame()'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _usePostFrameRun(context),
              child: const Text('context.postFrameRun()'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _useDebounced(context),
              child: const Text('context.postFrameDebounced()'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 8. Conditional Execution Example
// ---------------------------------------------------------------------------
class ConditionalExample extends StatefulWidget {
  const ConditionalExample({super.key});

  @override
  State<ConditionalExample> createState() => _ConditionalExampleState();
}

class _ConditionalExampleState extends State<ConditionalExample> {
  String result = 'No action yet';
  bool allowExecution = true;

  void _executeWithPredicate() {
    PostFrame.run<String>(
      () => 'Predicate allowed execution',
      predicate: () => allowExecution,
    ).future.then((r) {
      if (mounted) {
        setState(() {
          if (r.canceled) {
            result = 'Predicate blocked execution';
          } else {
            result = r.value ?? '';
          }
        });
      }
    });
  }

  void _executeMountedCheck() {
    final predicate = PostFramePredicates.mounted(context);
    PostFrame.run<String>(
      () => 'Mounted check passed',
      predicate: predicate,
    ).future.then((r) {
      if (mounted) {
        setState(() {
          result = r.canceled ? 'Not mounted' : r.value ?? '';
        });
      }
    });
  }

  void _executeDebounced() {
    for (var i = 0; i < 10; i++) {
      PostFrame.debounced<int>(
        () => i,
        debounceKey: 'counter',
      ).future.then((r) {
        if (mounted && !r.canceled) {
          setState(() => result = 'Debounced result: ${r.value}');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conditional Execution')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(result,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Allow Execution'),
              value: allowExecution,
              onChanged: (v) => setState(() => allowExecution = v),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _executeWithPredicate,
              child: const Text('Execute with Predicate'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _executeMountedCheck,
              child: const Text('Execute with Mounted Check'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _executeDebounced,
              child: const Text('Execute Debounced (10x)'),
            ),
          ],
        ),
      ),
    );
  }
}
