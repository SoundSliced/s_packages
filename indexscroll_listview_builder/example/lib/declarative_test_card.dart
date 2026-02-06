import 'package:flutter/material.dart';
import 'package:indexscroll_listview_builder/indexscroll_listview_builder.dart';

/// Declarative behavior test - demonstrates indexToScrollTo as "home position".
class DeclarativeTestCard extends StatefulWidget {
  final int globalCount;

  const DeclarativeTestCard({super.key, required this.globalCount});

  @override
  State<DeclarativeTestCard> createState() => _DeclarativeTestCardState();
}

class _DeclarativeTestCardState extends State<DeclarativeTestCard> {
  final IndexedScrollController _controller = IndexedScrollController();
  int? _declarativeIndex = 15;
  int? _currentScrollPosition; // Track where controller actually scrolled to
  String _status = 'Ready to test';
  bool _updateIndexInCallback = true; // Toggle for coordinated behavior

  @override
  void didUpdateWidget(DeclarativeTestCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep home position within valid bounds when globalCount changes
    if (_declarativeIndex != null && _declarativeIndex! >= widget.globalCount) {
      _declarativeIndex = widget.globalCount - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.home_rounded,
                      color: Colors.teal, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Declarative Test',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                      Text(
                          'indexToScrollTo: ${_declarativeIndex ?? 'null'} - ${_declarativeIndex != null ? 'restores on rebuild' : 'imperative mode'}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // List content
            Container(
              height: 280,
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: IndexScrollListViewBuilder(
                controller: _controller,
                itemCount: widget.globalCount,
                indexToScrollTo:
                    _declarativeIndex, // Declarative index position
                onScrolledTo: (idx) {
                  // Always track the current scroll position for visual feedback
                  _currentScrollPosition = idx;

                  // Conditional behavior based on toggle:
                  // When _updateIndexInCallback is true, we update _declarativeIndex
                  // to coordinate with imperative scrolls (v2.2.0 intelligent tracking).
                  // When false, we DON'T update it, so declarative home position
                  // will restore on rebuild.
                  if (!_updateIndexInCallback) {
                    setState(() {
                      _status =
                          'Scrolled to $idx — NOT updating home (will restore on rebuild)';
                    });
                    return;
                  }

                  if (_declarativeIndex == null || _declarativeIndex == idx) {
                    // No change or in imperative mode; skip redundant setState.
                    // But still update to show current position visually
                    setState(() {
                      _status = 'At position $idx';
                    });
                    return;
                  }
                  setState(() {
                    _declarativeIndex = idx;
                    _status = 'Scrolled to $idx — home updated (coordinated)';
                  });
                },
                itemBuilder: (context, index) {
                  final isHome = index == _declarativeIndex;
                  final isCurrentPosition = index == _currentScrollPosition;
                  final isBoth = isHome && isCurrentPosition;

                  // Determine colors based on state
                  Color backgroundColor;
                  Color? borderColor;
                  double borderWidth = 0;

                  if (isBoth) {
                    // Both home and current position - teal
                    backgroundColor = Colors.teal.withValues(alpha: 0.2);
                    borderColor = Colors.teal;
                    borderWidth = 2;
                  } else if (isHome) {
                    // Home position only - teal with dashed style
                    backgroundColor = Colors.teal.withValues(alpha: 0.1);
                    borderColor = Colors.teal;
                    borderWidth = 2;
                  } else if (isCurrentPosition) {
                    // Current scroll position only - purple
                    backgroundColor = Colors.purple.withValues(alpha: 0.15);
                    borderColor = Colors.purple;
                    borderWidth = 2;
                  } else {
                    backgroundColor = colorScheme.surface;
                  }

                  return Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: borderColor != null
                          ? Border.all(color: borderColor, width: borderWidth)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      dense: true,
                      leading: isBoth
                          ? const Icon(Icons.home, color: Colors.teal)
                          : isHome
                              ? const Icon(Icons.home_outlined,
                                  color: Colors.teal)
                              : isCurrentPosition
                                  ? const Icon(Icons.location_on,
                                      color: Colors.purple)
                                  : Text('$index',
                                      style: const TextStyle(fontSize: 12)),
                      title: Text('Item #$index',
                          style: TextStyle(
                            fontWeight: (isHome || isCurrentPosition)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          )),
                      trailing:
                          _buildTrailing(isHome, isCurrentPosition, isBoth),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Controls
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Toggle for update behavior
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _updateIndexInCallback
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _updateIndexInCallback
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _updateIndexInCallback
                            ? Icons.sync
                            : Icons.restore_rounded,
                        size: 20,
                        color: _updateIndexInCallback
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _updateIndexInCallback
                                  ? 'Coordinated Mode (v2.2.0)'
                                  : 'Declarative Restore Mode',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _updateIndexInCallback
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _updateIndexInCallback
                                  ? 'Updates indexToScrollTo in onScrolledTo → imperative scrolls persist on rebuild'
                                  : 'Does NOT update indexToScrollTo → declarative home restores on rebuild',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _updateIndexInCallback,
                        onChanged: (value) => setState(() {
                          _updateIndexInCallback = value;
                          _status = value
                              ? 'Mode: Coordinated (updates home)'
                              : 'Mode: Restore (keeps home fixed)';
                        }),
                        activeThumbColor: Colors.green,
                        inactiveThumbColor: Colors.orange,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildSliderControl(
                  context,
                  icon: Icons.home,
                  label: 'Home Position',
                  value: (_declarativeIndex ?? 15).toDouble(),
                  displayValue:
                      _declarativeIndex != null ? '$_declarativeIndex' : 'null',
                  min: 0,
                  max: (widget.globalCount - 1).toDouble(),
                  divisions: (widget.globalCount - 1).clamp(1, 199).toInt(),
                  color: Colors.teal,
                  onChanged: (v) =>
                      setState(() => _declarativeIndex = v.toInt()),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Imperative scroll to random index
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        // Generate random index in valid range
                        final randomIndex = 20 +
                            (DateTime.now().millisecondsSinceEpoch %
                                    (widget.globalCount - 20))
                                .toInt();
                        setState(() {
                          _status = 'Scrolling to $randomIndex (imperative)...';
                        });
                        await _controller.scrollToIndex(
                          randomIndex,
                          itemCount: widget.globalCount,
                        );
                        // Status is updated in onScrolledTo callback
                      },
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Scroll Random'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.teal.withValues(alpha: 0.1),
                        foregroundColor: Colors.teal,
                      ),
                    ),
                    // Trigger rebuild button
                    FilledButton.tonalIcon(
                      onPressed: () {
                        setState(() {
                          _status = _updateIndexInCallback
                              ? 'Rebuild triggered — stays at current position'
                              : 'Rebuild triggered — IndexScrollListViewBuilder auto-restores to home ${_declarativeIndex ?? 15}';
                        });
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Trigger Rebuild'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.purple.withValues(alpha: 0.1),
                        foregroundColor: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: Colors.teal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_status,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.teal,
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildTrailing(bool isHome, bool isCurrentPosition, bool isBoth) {
    if (isHome) {
      // Home position (shown whether current position matches or not)
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('HOME',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            )),
      );
    } else if (isCurrentPosition) {
      // Current scroll position only (when different from home)
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('CONTROLLER INDEX',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            )),
      );
    }
    return null;
  }

  Widget _buildSliderControl(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double value,
    required String displayValue,
    required double min,
    required double max,
    required int divisions,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(displayValue,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: color,
                  )),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            min: min,
            max: max,
            divisions: divisions,
            value: value.clamp(min, max),
            activeColor: color,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
