// This example app shows how to use the s_offstage package.
import 'package:flutter/material.dart';
import 'package:s_offstage/s_offstage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOffstage Example',
      home: const ExampleHome(),
    );
  }
}

//****************//

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key});

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  bool _loading = true;
  String _statusMessage = 'Content is loading...';
  SOffstageTransition _transition = SOffstageTransition.fadeAndScale;
  String _animationStatus = '';
  bool _showLoadingIndicator = true;
  bool _useCustomLoadingIndicator = false;
  bool _maintainState = false;
  bool _useHiddenContent = false;
  bool _showRevealButton = false;
  final GlobalKey _counterKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  void _handleOffstageStateChange(bool isOffstage) {
    // Avoid calling setState synchronously during the build phase; schedule it
    // to run after this frame to prevent "setState() called during build" errors.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _loading = isOffstage;
        _statusMessage =
            isOffstage ? 'Content is hidden (offstage)' : 'Content is visible!';
      });
    });
    debugPrint('Offstage state changed: $isOffstage');
  }

  void _handleAnimationComplete(bool isOffstage) {
    // Schedule UI updates after frame to avoid setState during build errors.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _animationStatus = isOffstage
            ? 'Animation complete: Fully hidden'
            : 'Animation complete: Fully visible';
      });
    });
    debugPrint('Animation completed: $isOffstage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOffstage Example'),
        elevation: 0,
        backgroundColor: Colors.grey[50],
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Main Demo Area
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Widget Above',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SOffstage(
                      isOffstage: _loading,
                      transition: _transition,
                      showLoadingIndicator: _showLoadingIndicator,
                      maintainState: _maintainState,
                      showHiddenContent: _useHiddenContent,
                      showRevealButton: _showRevealButton,
                      hiddenContent: _useCustomLoadingIndicator
                          ? const CustomHiddenContent()
                          : null,
                      loadingIndicator: _useCustomLoadingIndicator
                          ? const CustomLoadingIndicator()
                          : null,
                      onChanged: _handleOffstageStateChange,
                      onAnimationComplete: _handleAnimationComplete,
                      fadeInCurve: Curves.easeOut,
                      fadeOutCurve: Curves.easeIn,
                      delayBeforeShow: const Duration(milliseconds: 100),
                      showLoadingAfter: const Duration(milliseconds: 200),
                      slideDirection: AxisDirection.up,
                      slideOffset: 0.5,
                      child: StatefulCounterWidget(key: _counterKey),
                    ),
                    const SizedBox(height: 20),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Widget Below',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Controls Area
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Text
                SizedBox(
                  height: 50,
                  child: Column(
                    children: [
                      Text(
                        _statusMessage,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _loading ? Colors.orange : Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_animationStatus.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _animationStatus,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Transition Selector
                const Text(
                  'Transition Type',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: SOffstageTransition.values.map((type) {
                      final isSelected = _transition == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(_getTransitionName(type)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _transition = type;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Toggles Row
                Row(
                  children: [
                    Flexible(
                      child: Column(
                        children: [
                          CompactSwitch(
                            label: 'Show Indicator',
                            value: _showLoadingIndicator,
                            onChanged: (v) =>
                                setState(() => _showLoadingIndicator = v),
                          ),
                          CompactSwitch(
                            label: 'Custom Indicator',
                            value: _useCustomLoadingIndicator,
                            onChanged: (v) =>
                                setState(() => _useCustomLoadingIndicator = v),
                          ),
                          CompactSwitch(
                            label: 'Maintain State',
                            value: _maintainState,
                            onChanged: (v) =>
                                setState(() => _maintainState = v),
                          ),
                          CompactSwitch(
                            label: 'Use HiddenContent',
                            value: _useHiddenContent,
                            onChanged: (v) =>
                                setState(() => _useHiddenContent = v),
                          ),
                          if (_useHiddenContent)
                            CompactSwitch(
                              label: 'Show Reveal Button',
                              value: _showRevealButton,
                              onChanged: (v) =>
                                  setState(() => _showRevealButton = v),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Main Action Button
                    SizedBox(
                      width: 100,
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          setState(() {
                            _loading = !_loading;
                            _animationStatus = '';
                          });
                        },
                        backgroundColor:
                            _loading ? Colors.green : Colors.orange,
                        icon: Icon(
                            _loading ? Icons.visibility : Icons.visibility_off),
                        label: Text(_loading ? 'Show' : 'Hide'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTransitionName(SOffstageTransition type) {
    switch (type) {
      case SOffstageTransition.fade:
        return 'Fade';
      case SOffstageTransition.scale:
        return 'Scale';
      case SOffstageTransition.fadeAndScale:
        return 'Fade & Scale';
      case SOffstageTransition.slide:
        return 'Slide';
      case SOffstageTransition.rotation:
        return 'Rotation';
    }
  }
}

//****************//

/// A compact switch widget with a label, used for toggling settings in the example app.
class CompactSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const CompactSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}

//****************//

/// A custom widget to demonstrate the [hiddenContent] feature.
///
/// This widget is shown when the content is hidden and [showHiddenContent] is true.
class CustomHiddenContent extends StatelessWidget {
  const CustomHiddenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            'Secure Content Hidden',
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

//****************//

/// A custom animated loading indicator to demonstrate the [loadingIndicator] feature.
class CustomLoadingIndicator extends StatefulWidget {
  const CustomLoadingIndicator({super.key});

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * 3.14159,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.deepPurple,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Custom Loading...',
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

//****************//

/// A stateful widget with a counter to demonstrate state preservation.
///
/// Used to verify that [maintainState] works correctly by checking if the
/// counter value is preserved when the widget goes offstage and back.
class StatefulCounterWidget extends StatefulWidget {
  const StatefulCounterWidget({super.key});

  @override
  State<StatefulCounterWidget> createState() => _StatefulCounterWidgetState();
}

class _StatefulCounterWidgetState extends State<StatefulCounterWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app,
            size: 48,
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 16),
          const Text(
            'Stateful Content',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Counter: $_counter',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _counter++;
              });
            },
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}
