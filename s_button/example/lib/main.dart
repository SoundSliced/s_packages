import 'dart:async';

import 'package:flutter/material.dart';
import 'package:s_button/s_button.dart';
import 'package:s_toggle/s_toggle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SButton Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const SButtonShowcase(),
    );
  }
}

class SButtonShowcase extends StatefulWidget {
  const SButtonShowcase({super.key});

  @override
  State<SButtonShowcase> createState() => _SButtonShowcaseState();
}

class _SButtonShowcaseState extends State<SButtonShowcase> {
  // Feature toggles
  bool _enableBounce = true;
  bool _enableHaptic = true;
  bool _enableCircle = false;
  bool _enableBorderRadius = true;
  bool _enableSplashColor = true;
  bool _enableLoading = false;
  bool _enableSelected = false;
  bool _enableBubbleLabel = false;
  bool _enableTooltip = false;
  bool _isActive = true;
  bool _disableOpacityChange = false;

  // State
  int _tapCount = 0;
  Timer? _loadingTimer;

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleTap(Offset offset) {
    setState(() {
      _tapCount++;
      // Toggle selected state on tap to demonstrate selectedColor
      _enableSelected = !_enableSelected;
    });
    _showSnackBar(
        'Tapped at ${offset.dx.toStringAsFixed(1)}, ${offset.dy.toStringAsFixed(1)}! Count: $_tapCount');
  }

  void _simulateLoading() {
    _loadingTimer?.cancel();
    setState(() => _enableLoading = true);
    _loadingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _enableLoading = false);
        _showSnackBar('Loading complete!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SButton Showcase'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          // The Demo Button
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDemoButton(),
                  const SizedBox(height: 16),
                  Text(
                    'Tap Count: $_tapCount',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          // Settings Panel
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: _buildSettingsPanel(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoButton() {
    return SButton(
      onTap: _enableLoading ? null : _handleTap,
      onDoubleTap: (_) => _showSnackBar('Double Tapped!'),
      onLongPressStart: (details) => _showSnackBar('Long Press Started!'),
      onLongPressEnd: (details) => _showSnackBar('Long Press Ended!'),
      shouldBounce: _enableBounce,
      bounceScale: 0.95,
      enableHapticFeedback: _enableHaptic,
      hapticFeedbackType: HapticFeedbackType.mediumImpact,
      isCircleButton: _enableCircle,
      borderRadius: _enableBorderRadius && !_enableCircle
          ? BorderRadius.circular(16)
          : null,
      splashColor: _enableSplashColor ? Colors.yellow : null,
      splashOpacity: 0.3,
      isLoading: _enableLoading,
      loadingWidget: _buildButtonChild(
        content: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
      ),
      selectedColor: _enableSelected ? Colors.green : null,
      isActive: _isActive,
      disableOpacityChange: _disableOpacityChange,
      onTappedWhenDisabled: (offset) => _showSnackBar(
          'Disabled tap at ${offset.dx.toStringAsFixed(1)}, ${offset.dy.toStringAsFixed(1)}'),
      tooltipMessage: _enableTooltip ? 'This is a tooltip!' : null,
      bubbleLabelContent: _enableBubbleLabel
          ? BubbleLabelContent(
              child: const Text(
                'I am a Bubble Label!',
                style: TextStyle(color: Colors.white),
              ),
              bubbleColor: Colors.indigo,
            )
          : null,
      child: _buildButtonChild(),
    );
  }

  Widget _buildButtonChild({Widget? content}) {
    Widget childContent = content ??
        (_enableCircle
            ? const Icon(
                Icons.touch_app,
                color: Colors.white,
                size: 32,
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Tap Me',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ));

    if (_enableCircle) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.indigo,
              Colors.indigo.shade300,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(child: childContent),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo,
            Colors.indigo.shade300,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            _enableBorderRadius ? BorderRadius.circular(16) : BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: childContent,
    );
  }

  Widget _buildSettingsPanel() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Button Features',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildToggleRow(
          label: 'Bounce Animation',
          value: _enableBounce,
          onChanged: (v) => setState(() => _enableBounce = v),
          icon: Icons.animation,
        ),
        _buildToggleRow(
          label: 'Haptic Feedback',
          value: _enableHaptic,
          onChanged: (v) => setState(() => _enableHaptic = v),
          icon: Icons.vibration,
        ),
        _buildToggleRow(
          label: 'Circle Button',
          value: _enableCircle,
          onChanged: (v) => setState(() => _enableCircle = v),
          icon: Icons.circle_outlined,
        ),
        _buildToggleRow(
          label: 'Border Radius',
          value: _enableBorderRadius,
          onChanged: (v) => setState(() => _enableBorderRadius = v),
          icon: Icons.rounded_corner,
          enabled: !_enableCircle,
        ),
        _buildToggleRow(
          label: 'Splash Color',
          value: _enableSplashColor,
          onChanged: (v) => setState(() => _enableSplashColor = v),
          icon: Icons.water_drop,
        ),
        _buildToggleRow(
          label: 'Selected Overlay',
          value: _enableSelected,
          onChanged: (v) => setState(() => _enableSelected = v),
          icon: Icons.check_circle_outline,
        ),
        _buildToggleRow(
          label: 'Loading State',
          value: _enableLoading,
          onChanged: (v) {
            if (v) {
              _simulateLoading();
            } else {
              _loadingTimer?.cancel();
              setState(() => _enableLoading = false);
            }
          },
          icon: Icons.hourglass_empty,
        ),
        _buildToggleRow(
          label: 'Active/Enabled',
          value: _isActive,
          onChanged: (v) => setState(() => _isActive = v),
          icon: Icons.power_settings_new,
        ),
        _buildToggleRow(
          label: 'Disable Opacity Change',
          value: _disableOpacityChange,
          onChanged: (v) => setState(() => _disableOpacityChange = v),
          icon: Icons.opacity,
          enabled: !_isActive,
        ),
        const Divider(height: 32),
        Text(
          'Tooltips & Labels',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildToggleRow(
          label: 'Tooltip',
          value: _enableTooltip,
          onChanged: (v) => setState(() => _enableTooltip = v),
          icon: Icons.info_outline,
        ),
        _buildToggleRow(
          label: 'Bubble Label (hover/long-press)',
          value: _enableBubbleLabel,
          onChanged: (v) => setState(() => _enableBubbleLabel = v),
          icon: Icons.chat_bubble_outline,
        ),
        const SizedBox(height: 24),
        Center(
          child: TextButton.icon(
            onPressed: () => setState(() => _tapCount = 0),
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Counter'),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            IgnorePointer(
              ignoring: !enabled,
              child: SToggle(
                size: 50,
                value: value,
                onChange: onChanged,
                onColor: Theme.of(context).colorScheme.primary,
                offColor: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
