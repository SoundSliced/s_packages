import 'package:flutter/material.dart';
import 'package:indexscroll_listview_builder/indexscroll_listview_builder.dart';

/// Imperative scroll example with external controller.
class ImperativeScrollCard extends StatefulWidget {
  final int globalCount;

  const ImperativeScrollCard({super.key, required this.globalCount});

  @override
  State<ImperativeScrollCard> createState() => _ImperativeScrollCardState();
}

class _ImperativeScrollCardState extends State<ImperativeScrollCard> {
  final IndexedScrollController _controller = IndexedScrollController();
  int _controlledTarget = 5;
  int? _currentIndex; // tracks last index confirmed by onScrolledTo

  @override
  void didUpdateWidget(ImperativeScrollCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep target within valid bounds when globalCount changes
    if (_controlledTarget >= widget.globalCount) {
      _controlledTarget = widget.globalCount - 1;
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
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.control_camera_rounded,
                      color: Colors.purple, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Imperative Scroll',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                      Text('indexToScrollTo: null - controller persists',
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
                onScrolledTo: (idx) {
                  // update current index for visual highlighting
                  if (_currentIndex != idx) {
                    setState(() => _currentIndex = idx);
                  }
                },
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  final isHere = _currentIndex == index;
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isHere
                          ? Colors.purple.withValues(alpha: 0.08)
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isHere
                            ? Colors.purple
                            : colorScheme.outline.withValues(alpha: 0.15),
                        width: isHere ? 1.5 : 1,
                      ),
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
                      title: Row(
                        children: [
                          Text(
                            'Item #$index',
                            style: TextStyle(
                              fontWeight:
                                  isHere ? FontWeight.bold : FontWeight.w600,
                              color: isHere ? Colors.purple : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isHere)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.purple,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'HERE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                        ],
                      ),
                      leading: CircleAvatar(
                        backgroundColor: isHere
                            ? Colors.purple
                            : Colors.purple.withValues(alpha: 0.1),
                        child: Text('$index',
                            style: TextStyle(
                              color: isHere ? Colors.white : Colors.purple,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            )),
                      ),
                      trailing: Icon(
                        isHere ? Icons.location_on : Icons.drag_indicator,
                        size: 16,
                        color: isHere ? Colors.purple : colorScheme.outline,
                      ),
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        setState(() => _controlledTarget =
                            (_controlledTarget + 10) % widget.globalCount);
                        await _controller.scrollToIndex(
                          _controlledTarget,
                          alignmentOverride: 0.3,
                          itemCount: widget.globalCount,
                        );
                      },
                      icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                      label: const Text('+10'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.purple.withValues(alpha: 0.1),
                        foregroundColor: Colors.purple,
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        setState(() => _controlledTarget =
                            (_controlledTarget - 10) < 0
                                ? 0
                                : _controlledTarget - 10);
                        await _controller.scrollToIndex(
                          _controlledTarget,
                          alignmentOverride: 0.7,
                          itemCount: widget.globalCount,
                        );
                      },
                      icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                      label: const Text('-10'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.purple.withValues(alpha: 0.1),
                        foregroundColor: Colors.purple,
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        setState(() => _controlledTarget = 0);
                        await _controller.scrollToIndex(
                          0,
                          alignmentOverride: 0.0,
                          itemCount: widget.globalCount,
                        );
                      },
                      icon: const Icon(Icons.first_page_rounded, size: 18),
                      label: const Text('First'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.purple.withValues(alpha: 0.1),
                        foregroundColor: Colors.purple,
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        setState(
                            () => _controlledTarget = widget.globalCount - 1);
                        await _controller.scrollToIndex(
                          widget.globalCount - 1,
                          alignmentOverride: 1.0,
                          itemCount: widget.globalCount,
                        );
                      },
                      icon: const Icon(Icons.last_page_rounded, size: 18),
                      label: const Text('Last'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.purple.withValues(alpha: 0.1),
                        foregroundColor: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 16, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                          'Current Position: ${_currentIndex ?? _controlledTarget}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          )),
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
}
