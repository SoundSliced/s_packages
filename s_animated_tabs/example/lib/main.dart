import 'package:flutter/material.dart';
import 'package:s_animated_tabs/s_animated_tabs.dart';

void main() {
  runApp(const AnimatedTabsExampleApp());
}

class AnimatedTabsExampleApp extends StatelessWidget {
  const AnimatedTabsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S Animated Tabs Example',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4F46E5),
        useMaterial3: true,
      ),
      home: const AnimatedTabsDemoPage(),
    );
  }
}

class AnimatedTabsDemoPage extends StatefulWidget {
  const AnimatedTabsDemoPage({super.key});

  @override
  State<AnimatedTabsDemoPage> createState() => _AnimatedTabsDemoPageState();
}

class _AnimatedTabsDemoPageState extends State<AnimatedTabsDemoPage> {
  final List<String> _tabTitles = const ['Overview', 'Details', 'Reviews'];
  int _selectedIndex = 0;

  bool _advancedEnabled = false;

  final int _rebuildCounter = 0;

  bool _useCustomTextStyles = false;
  bool _useCustomSize = false;
  double _customHeight = 52.0;
  double _customWidth = 320.0;

  bool _useCustomPadding = false;
  double _paddingValue = 4.0;

  bool _useCustomRadius = false;
  double _borderRadius = 12.0;

  bool _enableHaptics = true;
  bool _enableElevation = false;
  double _elevation = 2.0;

  TabTextSize _textSize = TabTextSize.medium;
  TabColorScheme? _colorScheme;
  bool _useCustomColors = false;
  _ColorOption _backgroundColor = _backgroundOptions.first;
  _ColorOption _activeColor = _activeOptions.first;

  bool _enhancedAnimations = true;
  TabAnimationStyle _animationStyle = TabAnimationStyle.smooth;
  double _durationMs = 320;
  _CurveOption _curveOption = _curveOptions.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('S Animated Tabs'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: Text(
                _advancedEnabled ? 'Advanced' : 'Basic',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPreviewCard(context),
            const SizedBox(height: 16),
            _buildSelectionCard(context),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildModeToggle(),
                  if (_advancedEnabled) ...[
                    const SizedBox(height: 12),
                    _buildAdvancedControls(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Preview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Center(child: _buildAnimatedTabs()),
            const SizedBox(height: 12),
            Text(
              'Toggle between tabs to see animations and styles update in real time.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Tab',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _tabTitles[_selectedIndex],
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Index: $_selectedIndex',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return SwitchListTile.adaptive(
      value: _advancedEnabled,
      title: const Text('Enable advanced features'),
      subtitle: const Text(
        'Turn this on to tweak every available setting in the package.',
      ),
      onChanged: (value) {
        setState(() {
          _advancedEnabled = value;
        });
      },
    );
  }

  Widget _buildAdvancedControls(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'Layout'),
        SwitchListTile.adaptive(
          value: _useCustomSize,
          title: const Text('Custom size'),
          subtitle: const Text('Control the height and width.'),
          onChanged: (value) {
            setState(() {
              _useCustomSize = value;
            });
          },
        ),
        if (_useCustomSize) ...[
          _buildSlider(
            context,
            label: 'Height',
            value: _customHeight,
            min: 40,
            max: 68,
            onChanged: (value) => setState(() => _customHeight = value),
          ),
          _buildSlider(
            context,
            label: 'Width',
            value: _customWidth,
            min: 240,
            max: 360,
            onChanged: (value) => setState(() => _customWidth = value),
          ),
        ],
        SwitchListTile.adaptive(
          value: _useCustomPadding,
          title: const Text('Custom padding'),
          subtitle: const Text('Adjust internal spacing.'),
          onChanged: (value) {
            setState(() {
              _useCustomPadding = value;
            });
          },
        ),
        if (_useCustomPadding)
          _buildSlider(
            context,
            label: 'Padding',
            value: _paddingValue,
            min: 2,
            max: 12,
            onChanged: (value) => setState(() => _paddingValue = value),
          ),
        SwitchListTile.adaptive(
          value: _useCustomRadius,
          title: const Text('Custom border radius'),
          subtitle: const Text('Round the container and indicator.'),
          onChanged: (value) {
            setState(() {
              _useCustomRadius = value;
            });
          },
        ),
        if (_useCustomRadius)
          _buildSlider(
            context,
            label: 'Border radius',
            value: _borderRadius,
            min: 6,
            max: 20,
            onChanged: (value) => setState(() => _borderRadius = value),
          ),
        const Divider(height: 24),
        _sectionTitle(context, 'Typography'),
        SwitchListTile.adaptive(
          value: _useCustomTextStyles,
          title: const Text('Custom text styles'),
          subtitle: const Text('Override active and inactive styles.'),
          onChanged: (value) {
            setState(() {
              _useCustomTextStyles = value;
            });
          },
        ),
        _buildDropdown<TabTextSize>(
          context,
          label: 'Inactive Tab\'s Text size',
          value: _textSize,
          items: TabTextSize.values
              .map(
                (size) => DropdownMenuItem(
                  value: size,
                  child: Text(size.name),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _textSize = value);
          },
        ),
        const Divider(height: 24),
        _sectionTitle(context, 'Colors'),
        _buildDropdown<TabColorScheme?>(
          context,
          label: 'Color scheme',
          value: _colorScheme,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Default (use custom colors)'),
            ),
            ...TabColorScheme.values.map(
              (scheme) => DropdownMenuItem(
                value: scheme,
                child: Text(scheme.name),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _colorScheme = value;
              if (_colorScheme != null) {
                _useCustomColors = false;
              }
            });
          },
        ),
        SwitchListTile.adaptive(
          value: _useCustomColors,
          title: const Text('Custom colors'),
          subtitle: Text(
            _colorScheme == null
                ? 'Override background and active colors.'
                : 'Disabled because a color scheme is active.',
          ),
          onChanged: _colorScheme == null
              ? (value) => setState(() => _useCustomColors = value)
              : null,
        ),
        if (_useCustomColors) ...[
          _buildDropdown<_ColorOption>(
            context,
            label: 'Background color',
            value: _backgroundColor,
            items: _backgroundOptions
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(option.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _backgroundColor = value);
            },
          ),
          _buildDropdown<_ColorOption>(
            context,
            label: 'Active color',
            value: _activeColor,
            items: _activeOptions
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(option.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _activeColor = value);
            },
          ),
        ],
        const Divider(height: 24),
        _sectionTitle(context, 'Animation'),
        _buildDropdown<TabAnimationStyle>(
          context,
          label: 'Animation style',
          value: _animationStyle,
          items: TabAnimationStyle.values
              .map(
                (style) => DropdownMenuItem(
                  value: style,
                  child: Text(style.name),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _animationStyle = value);
          },
        ),
        _buildDropdown<_CurveOption>(
          context,
          label: 'Animation curve',
          value: _curveOption,
          items: _curveOptions
              .map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(option.label),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _curveOption = value);
          },
        ),
        _buildSlider(
          context,
          label: 'Duration (ms)',
          value: _durationMs,
          min: 180,
          max: 800,
          divisions: 31,
          onChanged: (value) => setState(() => _durationMs = value),
        ),
        SwitchListTile.adaptive(
          value: _enhancedAnimations,
          title: const Text('Enhanced animations'),
          subtitle: const Text('Enable bounce + scale effects.'),
          onChanged: (value) => setState(() => _enhancedAnimations = value),
        ),
        const Divider(height: 24),
        _sectionTitle(context, 'Interaction'),
        SwitchListTile.adaptive(
          value: _enableHaptics,
          title: const Text('Haptic feedback'),
          subtitle: const Text('Light impact when switching tabs.'),
          onChanged: (value) => setState(() => _enableHaptics = value),
        ),
        SwitchListTile.adaptive(
          value: _enableElevation,
          title: const Text('Elevation shadow'),
          subtitle: const Text('Demonstrates the elevation option.'),
          onChanged: (value) => setState(() => _enableElevation = value),
        ),
        if (_enableElevation)
          _buildSlider(
            context,
            label: 'Elevation',
            value: _elevation,
            min: 0,
            max: 6,
            divisions: 12,
            onChanged: (value) => setState(() => _elevation = value),
          ),
        const Divider(height: 24),
        _sectionTitle(context, 'Programmatic tab'),
        _buildDropdown<int>(
          context,
          label: 'Programmatic index',
          value: _selectedIndex,
          items: List.generate(
            _tabTitles.length,
            (index) => DropdownMenuItem(
              value: index,
              child: Text('$index — ${_tabTitles[index]}'),
            ),
          ),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedIndex = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedTabs() {
    if (!_advancedEnabled) {
      return SAnimatedTabs(
        tabTitles: _tabTitles,
        onTabSelected: (index) => setState(() => _selectedIndex = index),
      );
    }

    return SAnimatedTabs(
      key: ValueKey('tabs_$_rebuildCounter$_selectedIndex'),
      tabTitles: _tabTitles,
      onTabSelected: (index) => setState(() => _selectedIndex = index),
      activeTextStyle: _useCustomTextStyles
          ? TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: _textSize.fontSize,
              letterSpacing: _textSize.letterSpacing,
            )
          : null,
      inactiveTextStyle: _useCustomTextStyles
          ? TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: _textSize.fontSize,
              letterSpacing: _textSize.letterSpacing,
            )
          : null,
      height: _useCustomSize ? _customHeight : null,
      width: _useCustomSize ? _customWidth : null,
      backgroundColor: _useCustomColors ? _backgroundColor.color : null,
      activeColor: _useCustomColors ? _activeColor.color : null,
      borderRadius: _useCustomRadius ? _borderRadius : 8.0,
      animationDuration: Duration(milliseconds: _durationMs.round()),
      animationCurve: _curveOption.curve,
      initialIndex: _selectedIndex,
      padding: _useCustomPadding
          ? EdgeInsets.all(_paddingValue)
          : const EdgeInsets.all(3.0),
      enableHapticFeedback: _enableHaptics,
      enableElevation: _enableElevation,
      elevation: _elevation,
      textSize: _textSize,
      colorScheme: _colorScheme,
      enableEnhancedAnimations: _enhancedAnimations,
      animationStyle: _animationStyle,
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }

  Widget _buildDropdown<T>(
    BuildContext context, {
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(0)}'),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ColorOption {
  final String label;
  final Color color;

  const _ColorOption(this.label, this.color);
}

class _CurveOption {
  final String label;
  final Curve curve;

  const _CurveOption(this.label, this.curve);
}

const List<_ColorOption> _backgroundOptions = [
  _ColorOption('Slate 100', Color(0xFFF1F5F9)),
  _ColorOption('Indigo 50', Color(0xFFE0E7FF)),
  _ColorOption('Emerald 50', Color(0xFFECFDF3)),
  _ColorOption('Amber 50', Color(0xFFFFFBEB)),
  _ColorOption('Rose 50', Color(0xFFFFE4E6)),
];

const List<_ColorOption> _activeOptions = [
  _ColorOption('Indigo 600', Color(0xFF4F46E5)),
  _ColorOption('Blue 600', Color(0xFF2563EB)),
  _ColorOption('Emerald 500', Color(0xFF10B981)),
  _ColorOption('Amber 500', Color(0xFFF59E0B)),
  _ColorOption('Rose 500', Color(0xFFF43F5E)),
];

const List<_CurveOption> _curveOptions = [
  _CurveOption('easeOutQuart', Curves.easeOutQuart),
  _CurveOption('easeOutCubic', Curves.easeOutCubic),
  _CurveOption('easeOutBack', Curves.easeOutBack),
  _CurveOption('elasticOut', Curves.elasticOut),
];
