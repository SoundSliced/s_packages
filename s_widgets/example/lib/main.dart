import 'package:flutter/material.dart';
import 'package:s_widgets/s_widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 's_widgets Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ExampleHomeScreen(),
    );
  }
}

class ExampleHomeScreen extends StatefulWidget {
  const ExampleHomeScreen({super.key});

  @override
  State<ExampleHomeScreen> createState() => _ExampleHomeScreenState();
}

class _ExampleHomeScreenState extends State<ExampleHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('s_widgets Examples')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Basic Examples'),
              const SizedBox(height: 12),
              _buildExampleCard(
                'Keyboard Management',
                'Tap to dismiss keyboard',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KeyboardManagementExample(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildExampleCard(
                'Loading Indicator',
                'Custom animated loading indicator',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoadingIndicatorExample(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildExampleCard(
                'Custom Buttons',
                'Text and Icon buttons',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomButtonsExample(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildExampleCard(
                'Widget Extensions',
                'Apply styling extensions',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WidgetExtensionsExample(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Advanced Examples'),
              const SizedBox(height: 12),
              _buildExampleCard(
                'Blur Effects',
                'Static and animated blur',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BlurEffectsExample(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildExampleCard(
                'Auto-Scrolling Fields',
                'Text field with keyboard scroll',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AutoScrollingExample(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildExampleCard(
                'Widget Measurement',
                'Get widget size dynamically',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WidgetMeasurementExample(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildExampleCard(
                'Safe State Management',
                'Prevent setState errors',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SafeStateExample(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
    );
  }

  Widget _buildExampleCard(
      String title, String description, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent, width: 1),
          borderRadius: BorderRadius.circular(8),
          color: Colors.blue.withValues(alpha: 0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// BASIC EXAMPLES
// ============================================================================

class KeyboardManagementExample extends StatelessWidget {
  const KeyboardManagementExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keyboard Management')),
      body: DismissKeyboard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Tap anywhere to dismiss keyboard',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              TextField(
                onTap: () {
                  KeyboardOverlay.showDoneButtonOverlay(
                    context: context,
                    onTap: () {
                      context.showSnackBar(message: 'Done tapped!');
                    },
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Tap here to see done button',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Regular text field',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tap outside the text fields to dismiss the keyboard.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingIndicatorExample extends StatelessWidget {
  const LoadingIndicatorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading Indicators')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              spacing: 100,
              children: [
                // Default indicator
                Column(
                  children: [
                    Text(
                      'Default Indicator',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: const SLoadingIndicator(
                        indicatorType: Indicator.circleStrokeSpin,
                        scale: 1.5,
                      ),
                    ),
                  ],
                ),

                // Colored indicator
                Column(
                  children: [
                    Text(
                      'Colored Indicator',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: const SLoadingIndicator(
                        indicatorType: Indicator.circleStrokeSpin,
                        colors: [Colors.blue, Colors.cyan],
                        scale: 1.2,
                      ),
                    ),
                  ],
                ),

                // Scaled indicator
                Column(
                  children: [
                    Text(
                      'Scaled Indicator',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: const SLoadingIndicator(
                        indicatorType: Indicator.ballClipRotate,
                        colors: [Colors.orange, Colors.red],
                        scale: 1.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomButtonsExample extends StatelessWidget {
  const CustomButtonsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Buttons')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('Text Buttons',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                STextButton(
                  buttonTitle: 'Submit',
                  backgroundColor: Colors.blue,
                  onTap: (offset) {
                    context.showSnackBar(message: 'Submit tapped!');
                  },
                  height: 48,
                  width: 150,
                ),
              ],
            ),
            Column(
              children: [
                Text('Icon Buttons',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SIconButton(
                      iconData: Icons.home,
                      label: 'Home',
                      color: Colors.blue,
                      onTap: (offset) {
                        context.showSnackBar(message: 'Home tapped!');
                      },
                    ),
                    SIconButton(
                      iconData: Icons.settings,
                      label: 'Settings',
                      color: Colors.green,
                      onTap: (offset) {
                        context.showSnackBar(message: 'Settings tapped!');
                      },
                    ),
                    SIconButton(
                      iconData: Icons.info,
                      label: 'Info',
                      color: Colors.orange,
                      onTap: (offset) {
                        context.showSnackBar(message: 'Info tapped!');
                      },
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                Text('Custom Styled Button',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                STextButton(
                  buttonTitle: 'Delete',
                  backgroundColor: Colors.red,
                  backgroundColorOpacity: 0.6,
                  onTap: (offset) {
                    context.showErrorSnackBar(message: 'Delete action!');
                  },
                  height: 48,
                  width: 150,
                  buttonBorderRadius: BorderRadius.circular(20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WidgetExtensionsExample extends StatelessWidget {
  const WidgetExtensionsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Extensions')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('With Tooltip',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Icon(Icons.info_outline, size: 48)
                    .addTooltipWidget('This is a helpful icon'),
              ],
            ),
            Column(
              children: [
                Text('With Color Filter',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                  child: const Center(child: Text('Colored')),
                ).colorFilter(
                  ColorFilter.mode(
                      Colors.yellow.withValues(alpha: 0.3), BlendMode.multiply),
                ),
              ],
            ),
            Column(
              children: [
                Text('With Border Radius',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.green,
                  child: const Center(child: Text('Rounded')),
                ).borderRadius(BorderRadius.circular(20)),
              ],
            ),
            Column(
              children: [
                Text('Snackbar Extension',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.showSnackBar(
                      message: 'Success message!',
                      backgroundColor: Colors.green,
                    );
                  },
                  child: const Text('Show Snackbar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ADVANCED EXAMPLES
// ============================================================================

class BlurEffectsExample extends StatefulWidget {
  const BlurEffectsExample({super.key});

  @override
  State<BlurEffectsExample> createState() => _BlurEffectsExampleState();
}

class _BlurEffectsExampleState extends State<BlurEffectsExample> {
  bool _isBlurred = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blur Effects')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('Static Blur',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                SBlur(
                  isEnabled: _isBlurred,
                  blurAmountOnX: 5,
                  blurAmountOnY: 5,
                  child: Container(
                    width: 150,
                    height: 150,
                    color: Colors.blue,
                    child: const Center(
                      child: Text('Blurred Content'),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text('Animated Blur',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                SAnimatedBlur(
                  duration: const Duration(milliseconds: 300),
                  isBlurred: _isBlurred,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 150,
                    height: 150,
                    color: Colors.purple,
                    child: const Center(
                      child: Text('Auto-animated blur'),
                    ),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _isBlurred = !_isBlurred);
              },
              child: Text(_isBlurred ? 'Remove Blur' : 'Add Blur'),
            ),
          ],
        ),
      ),
    );
  }
}

class AutoScrollingExample extends StatelessWidget {
  const AutoScrollingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto-Scrolling Text Field')),
      body: ScrollTextFormFieldWhenKeyboardIsShown(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'When you focus on the text field at the bottom, the view will auto-scroll to show it',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 300),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Tap here - will auto-scroll!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Another field',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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

class WidgetMeasurementExample extends StatefulWidget {
  const WidgetMeasurementExample({super.key});

  @override
  State<WidgetMeasurementExample> createState() =>
      _WidgetMeasurementExampleState();
}

class _WidgetMeasurementExampleState extends State<WidgetMeasurementExample> {
  Size? _measuredSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Measurement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Measured Size: ${_measuredSize != null ? '${_measuredSize!.width.toStringAsFixed(1)} x ${_measuredSize!.height.toStringAsFixed(1)}' : 'Measuring...'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            MeasureChildSizeWidget(
              onChange: (size) {
                if (mounted) {
                  setState(() => _measuredSize = size);
                }
              },
              child: Container(
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Measured Widget',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SafeStateExample extends StatefulWidget {
  const SafeStateExample({super.key});

  @override
  State<SafeStateExample> createState() => _SafeStateExampleState();
}

class _SafeStateExampleState extends MountedState<SafeStateExample> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    // Simulate delayed state update after widget might be disposed
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _counter++);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safe State Management')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Counter: $_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'This widget extends MountedState, so setState() is safe even if the widget is disposed.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() => _counter++),
              child: const Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}
