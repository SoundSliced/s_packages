import 'package:s_packages/s_packages.dart';

class SExpendableMenuExampleScreen extends StatefulWidget {
  const SExpendableMenuExampleScreen({super.key});

  @override
  State<SExpendableMenuExampleScreen> createState() =>
      _SExpendableMenuExampleScreenState();
}

class _SExpendableMenuExampleScreenState
    extends State<SExpendableMenuExampleScreen> {
  String _lastTapped = 'None';
  bool _useCustomColors = false;
  ExpandDirection _expandDirection = ExpandDirection.auto;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _useCustomColors
        ? Colors.teal.shade100
        : Theme.of(context).colorScheme.secondaryContainer;
    final iconColor = _useCustomColors
        ? Colors.teal.shade900
        : Theme.of(context).colorScheme.onSecondaryContainer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('s_expendable_menu Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Custom colors toggle
            SwitchListTile(
              title: const Text('Custom colors'),
              subtitle: const Text('Use custom background and icon colors'),
              value: _useCustomColors,
              onChanged: (value) => setState(() => _useCustomColors = value),
            ),

            const SizedBox(height: 16),

            // Expand direction selector
            const Text(
              'Expand Direction',
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

            const SizedBox(height: 24),

            // Menu demo
            const Text(
              'Expandable Menu Demo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Menu container
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Align(
                alignment: _expandDirection == ExpandDirection.right
                    ? Alignment.centerLeft
                    : _expandDirection == ExpandDirection.left ||
                            _expandDirection == ExpandDirection.auto
                        ? Alignment.centerRight
                        : Alignment.center,
                child: SExpandableMenu(
                  items: [
                    SExpandableItem(
                      icon: Icons.home,
                      tooltip: 'Home',
                      onTap: (pos) {
                        setState(() => _lastTapped = 'Home');
                      },
                    ),
                    SExpandableItem(
                      icon: Icons.search,
                      tooltip: 'Search',
                      onTap: (pos) {
                        setState(() => _lastTapped = 'Search');
                      },
                    ),
                    SExpandableItem(
                      icon: Icons.favorite,
                      tooltip: 'Favorite',
                      onTap: (pos) {
                        setState(() => _lastTapped = 'Favorite');
                      },
                    ),
                    SExpandableItem(
                      icon: Icons.settings,
                      tooltip: 'Settings',
                      disabled: true,
                      onTap: (pos) {
                        setState(() => _lastTapped = 'Settings');
                      },
                    ),
                  ],
                  width: 70,
                  height: 70,
                  backgroundColor: backgroundColor,
                  iconColor: iconColor,
                  expandDirection: _expandDirection,
                  onExpansionChanged: (isExpanded) {
                    debugPrint('Menu expanded: $isExpanded');
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Last tapped display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app, color: Colors.deepPurple),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last Tapped',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _lastTapped,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Info section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About s_expendable_menu',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Expandable floating action menu\n'
                    '• Customizable colors and size\n'
                    '• Multiple expand directions\n'
                    '• Smooth animations\n'
                    '• Easy to use with SExpandableItem',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
