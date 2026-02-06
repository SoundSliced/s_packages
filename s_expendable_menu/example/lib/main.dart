import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:s_expendable_menu/s_expendable_menu.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 's_expendable_menu example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4B5042)),
        useMaterial3: true,
      ),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: false,
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.invertedStylus,
        },
        physics: const BouncingScrollPhysics(),
        overscroll: false,
      ),
      home: const ExampleHome(),
    );
  }
}

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key});

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  bool _useCustomColors = false;
  bool _useManyItems = false;
  bool _largeSize = false;
  bool _rtl = false;
  bool _triggerHandleTap = false;
  bool _handleExpanded = false;
  int _handleTapCount = 0;
  String _lastTapped = 'None';
  ExpandDirection _expandDirection = ExpandDirection.auto;

  final List<IconData> _icons = const [
    Icons.home,
    Icons.search,
    Icons.favorite,
    Icons.settings,
    Icons.notifications,
    Icons.person,
    Icons.camera_alt,
    Icons.map,
    Icons.shopping_cart,
    Icons.music_note,
  ];

  List<SExpandableItem> _buildItems(int count) {
    return List.generate(count, (index) {
      final icon = _icons[index % _icons.length];
      return SExpandableItem(
        icon: icon,
        onTap: (pos) {
          if (!mounted) return;
          setState(() => _lastTapped = 'Item ${index + 1}');
        },
      );
    });
  }

  void _fireHandleTrigger() {
    if (!mounted) {
      return;
    }
    setState(() {
      _triggerHandleTap = !_triggerHandleTap;
      _handleExpanded = !_handleExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = _useManyItems ? 10 : 4;
    final width = _largeSize ? 90.0 : 70.0;
    final height = _largeSize ? 90.0 : 70.0;

    final backgroundColor =
        _useCustomColors ? const Color(0xFF283149) : const Color(0xFF4B5042);
    final iconColor = _useCustomColors ? const Color(0xFFFFD369) : Colors.white;
    final itemContainerColor =
        _useCustomColors ? const Color(0xFF00A8CC) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('s_expendable_menu example'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            key: const ValueKey('toggle-custom-colors'),
            title: const Text('Custom colors'),
            subtitle: const Text('Background, icons, and item container'),
            value: _useCustomColors,
            onChanged: (value) => setState(() => _useCustomColors = value),
          ),
          SwitchListTile.adaptive(
            key: const ValueKey('toggle-many-items'),
            title: const Text('Many items'),
            subtitle: const Text('Show more menu icons'),
            value: _useManyItems,
            onChanged: (value) => setState(() => _useManyItems = value),
          ),
          SwitchListTile.adaptive(
            key: const ValueKey('toggle-large-size'),
            title: const Text('Large size'),
            subtitle: const Text('Increase menu width and height'),
            value: _largeSize,
            onChanged: (value) => setState(() => _largeSize = value),
          ),
          SwitchListTile.adaptive(
            key: const ValueKey('toggle-rtl'),
            title: const Text('Reverse item order'),
            subtitle: const Text('Reverses the order of menu items'),
            value: _rtl,
            onChanged: (value) => setState(() => _rtl = value),
          ),
          const SizedBox(height: 12),
          const Text(
            'Expand direction',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          SegmentedButton<ExpandDirection>(
            segments: const [
              ButtonSegment(
                value: ExpandDirection.auto,
                label: Text('Auto'),
                icon: Icon(Icons.auto_fix_high),
              ),
              ButtonSegment(
                value: ExpandDirection.left,
                label: Text('Left'),
                icon: Icon(Icons.keyboard_arrow_left),
              ),
              ButtonSegment(
                value: ExpandDirection.right,
                label: Text('Right'),
                icon: Icon(Icons.keyboard_arrow_right),
              ),
            ],
            selected: {_expandDirection},
            onSelectionChanged: (Set<ExpandDirection> selection) {
              setState(() => _expandDirection = selection.first);
            },
          ),
          const SizedBox(height: 8),
          SegmentedButton<ExpandDirection>(
            segments: const [
              ButtonSegment(
                value: ExpandDirection.up,
                label: Text('Up'),
                icon: Icon(Icons.keyboard_arrow_up),
              ),
              ButtonSegment(
                value: ExpandDirection.down,
                label: Text('Down'),
                icon: Icon(Icons.keyboard_arrow_down),
              ),
            ],
            selected: {_expandDirection},
            onSelectionChanged: (Set<ExpandDirection> selection) {
              setState(() => _expandDirection = selection.first);
            },
            emptySelectionAllowed: true,
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 12),
          SizedBox(
            height: _expandDirection == ExpandDirection.up ||
                    _expandDirection == ExpandDirection.down
                ? 400.0 // Fixed height container for vertical expansion
                : null,
            child: Align(
              alignment: _expandDirection == ExpandDirection.right
                  ? Alignment.centerLeft
                  : _expandDirection == ExpandDirection.left ||
                          _expandDirection == ExpandDirection.auto
                      ? Alignment.centerRight
                      : _expandDirection == ExpandDirection.down
                          ? Alignment.topCenter
                          : Alignment.bottomCenter,
              child: Directionality(
                textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
                child: SExpandableMenu(
                  key: const ValueKey('advanced-menu'),
                  items: _buildItems(itemCount),
                  width: width,
                  height: height,
                  backgroundColor: backgroundColor,
                  iconColor: iconColor,
                  itemContainerColor: itemContainerColor,
                  expandDirection: _expandDirection,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Last tapped: $_lastTapped'),
          const SizedBox(height: 80),
          const Text(
            'Handles demo (advanced) wrapped in a DecoratedBox',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'External state control with trigger',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: backgroundColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SExpandableHandles(
                    key: const ValueKey('handles-demo'),
                    width: width,
                    height: height,
                    iconColor: iconColor,
                    // isExpanded: _handleExpanded,
                    // expandsRight: true,
                    triggerOnTap: _triggerHandleTap,
                    onTap: () {
                      if (!mounted) return;
                      setState(() => _handleTapCount++);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Handle taps: $_handleTapCount'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _fireHandleTrigger,
                      child: const Text('Trigger animation'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
