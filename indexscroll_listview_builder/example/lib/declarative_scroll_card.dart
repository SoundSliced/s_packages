import 'package:flutter/material.dart';
import 'package:indexscroll_listview_builder/indexscroll_listview_builder.dart';

/// Declarative scroll example - scrolls on build/rebuild.
class DeclarativeScrollCard extends StatefulWidget {
  final int globalCount;

  const DeclarativeScrollCard({super.key, required this.globalCount});

  @override
  State<DeclarativeScrollCard> createState() => _DeclarativeScrollCardState();
}

class _DeclarativeScrollCardState extends State<DeclarativeScrollCard> {
  int _autoTarget = 10;
  int _autoOffset = 1;
  double _autoAlignment = 0.2;

  @override
  void didUpdateWidget(DeclarativeScrollCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep target within valid bounds when globalCount changes
    if (_autoTarget >= widget.globalCount) {
      _autoTarget = widget.globalCount - 1;
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
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome_motion_rounded,
                      color: Colors.orange, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Declarative Scroll',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                      Text('indexToScrollTo acts as "home position"',
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
              height: 220,
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: IndexScrollListViewBuilder(
                itemCount: widget.globalCount,
                indexToScrollTo: _autoTarget,
                numberOfOffsetedItemsPriorToSelectedItem: _autoOffset,
                scrollAlignment: _autoAlignment,
                onScrolledTo: (_) {},
                showScrollbar: true,
                scrollbarThumbVisibility: true,
                shrinkWrap: true,
                itemBuilder: (context, index) => Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: index == _autoTarget
                        ? LinearGradient(
                            colors: [
                              Colors.orange.withValues(alpha: 0.3),
                              Colors.amber.withValues(alpha: 0.2),
                            ],
                          )
                        : null,
                    color: index == _autoTarget ? null : colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: index == _autoTarget
                        ? Border.all(color: Colors.orange, width: 2)
                        : null,
                    boxShadow: index == _autoTarget
                        ? [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: colorScheme.shadow.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: ListTile(
                    dense: true,
                    leading: index == _autoTarget
                        ? const Icon(Icons.stars_rounded, color: Colors.orange)
                        : Icon(Icons.circle,
                            size: 8, color: colorScheme.outline),
                    title: Text('Item #$index',
                        style: TextStyle(
                          fontWeight: index == _autoTarget
                              ? FontWeight.bold
                              : FontWeight.w500,
                        )),
                    trailing: index == _autoTarget
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('TARGET',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                )),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Controls
            Column(
              children: [
                _buildSliderControl(
                  context,
                  icon: Icons.location_searching_rounded,
                  label: 'Target Index',
                  value: _autoTarget.toDouble(),
                  displayValue: '$_autoTarget',
                  min: 0,
                  max: (widget.globalCount - 1).toDouble(),
                  divisions: (widget.globalCount - 1).clamp(1, 199).toInt(),
                  color: Colors.orange,
                  onChanged: (v) => setState(() => _autoTarget = v.toInt()),
                ),
                const SizedBox(height: 8),
                _buildSliderControl(
                  context,
                  icon: Icons.format_indent_increase,
                  label: 'Offset',
                  value: _autoOffset.toDouble(),
                  displayValue: '$_autoOffset',
                  min: 0,
                  max: 6,
                  divisions: 6,
                  color: Colors.orange,
                  onChanged: (v) => setState(() => _autoOffset = v.toInt()),
                ),
                const SizedBox(height: 8),
                _buildSliderControl(
                  context,
                  icon: Icons.vertical_align_center,
                  label: 'Alignment',
                  value: _autoAlignment,
                  displayValue: '${(_autoAlignment * 100).round()}%',
                  min: 0,
                  max: 1,
                  divisions: 10,
                  color: Colors.orange,
                  onChanged: (v) => setState(() => _autoAlignment = v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
