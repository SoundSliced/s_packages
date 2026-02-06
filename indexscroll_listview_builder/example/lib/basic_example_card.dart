import 'package:flutter/material.dart';
import 'package:indexscroll_listview_builder/indexscroll_listview_builder.dart';

/// Basic usage example without auto-scrolling or external control.
class BasicExampleCard extends StatefulWidget {
  const BasicExampleCard({super.key});

  @override
  State<BasicExampleCard> createState() => _BasicExampleCardState();
}

class _BasicExampleCardState extends State<BasicExampleCard> {
  int _basicCount = 20;

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
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.list_alt_rounded,
                      color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Basic Usage',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                      Text('Simple list builder without auto-scroll',
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
              height: 180,
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: IndexScrollListViewBuilder(
                itemCount: _basicCount,
                onScrolledTo: (_) {},
                shrinkWrap: true,
                itemBuilder: (context, index) => Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
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
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                      child: Text('$index',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          )),
                    ),
                    title: Text('Item #$index',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Basic list entry',
                        style: TextStyle(fontSize: 11)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Controls
            Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.format_list_numbered_rounded,
                        size: 16, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text('Item Count'),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('$_basicCount',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          )),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    min: 5,
                    max: 50,
                    divisions: 45,
                    value: _basicCount.toDouble(),
                    activeColor: Colors.blue,
                    onChanged: (v) => setState(() => _basicCount = v.toInt()),
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
