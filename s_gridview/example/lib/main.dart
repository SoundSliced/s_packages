import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:indexscroll_listview_builder/indexscroll_listview_builder.dart';
import 'package:s_gridview/s_gridview.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 's_gridview Example',
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
  final IndexedScrollController _controller = IndexedScrollController();
  Axis _direction = Axis.vertical;
  int _crossAxis = 3;
  bool _showScrollIndicators = true;
  Color? _indicatorColor = Colors.yellow.shade600;
  int? _autoIndex;
  double _scrollFraction = 1.0;
  final TextEditingController _textC = TextEditingController();

  @override
  void dispose() {
    _textC.dispose();
    _controller.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = List.generate(
      30,
      (i) => Container(
        width: 100,
        height: 80,
        color: Colors.primaries[i % Colors.primaries.length],
        child: Center(
          child: Text('Item ${i + 1}'),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('s_gridview Example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _direction =
                      _direction == Axis.vertical
                          ? Axis.horizontal
                          : Axis.vertical),
                  child: Text(
                      _direction == Axis.vertical ? 'Vertical' : 'Horizontal'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      setState(() => _crossAxis = (_crossAxis % 6) + 1),
                  child: Text('crossAxisItemCount: $_crossAxis'),
                ),
                SwitchListTile(
                  value: _showScrollIndicators,
                  onChanged: (v) => setState(() => _showScrollIndicators = v),
                  title: const Text('Show Scroll Indicators'),
                  dense: true,
                ),
                ElevatedButton(
                  onPressed: () =>
                      setState(() => _indicatorColor = Colors.red.shade400),
                  child: const Text('Indicator Red'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      setState(() => _indicatorColor = Colors.green.shade600),
                  child: const Text('Indicator Green'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      setState(() => _indicatorColor = Colors.blue.shade600),
                  child: const Text('Indicator Blue'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Programmatic scroll using the external controller
                    // Clear autoIndex to avoid conflicts
                    setState(() => _autoIndex = null);
                    await _controller.scrollToIndex(
                      20,
                      alignmentOverride: 0.35,
                      itemCount: items.length,
                    );
                    // Mounted check after async operation
                    if (!mounted) return;
                  },
                  child: const Text('Scroll to #21 (via controller)'),
                ),
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: _textC,
                    decoration: const InputDecoration(
                        hintText: 'Enter index to auto-scroll'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      final int? v = int.tryParse(_textC.text);
                      _autoIndex = v;
                    });
                  },
                  child: const Text('Set autoScrollToIndex (build)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Example of demonstration clamping: set to large value
                    setState(() => _autoIndex = 999);
                  },
                  child: const Text('Auto scroll (out-of-bounds)'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text('Indicator Scroll Distance:'),
                Expanded(
                  child: Slider(
                    value: _scrollFraction,
                    min: 0.1,
                    max: 2.0,
                    divisions: 19,
                    label: '${(_scrollFraction * 100).toStringAsFixed(0)}%',
                    onChanged: (value) {
                      setState(() => _scrollFraction = value);
                    },
                  ),
                ),
                Text(
                  '${(_scrollFraction * 100).toStringAsFixed(0)}% of viewport',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SGridView(
                controller: _controller,
                crossAxisItemCount: _crossAxis,
                mainAxisDirection: _direction,
                itemPadding: const EdgeInsets.all(6),
                autoScrollToIndex: _autoIndex,
                showScrollIndicators: _showScrollIndicators,
                indicatorColor: _indicatorColor,
                indicatorScrollFraction: _scrollFraction,
                children: items,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
