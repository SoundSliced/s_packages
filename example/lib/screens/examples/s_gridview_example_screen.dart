import 'package:s_packages/s_packages.dart';

class SGridviewExampleScreen extends StatefulWidget {
  const SGridviewExampleScreen({super.key});

  @override
  State<SGridviewExampleScreen> createState() => _SGridviewExampleScreenState();
}

class _SGridviewExampleScreenState extends State<SGridviewExampleScreen> {
  final IndexedScrollController _controller = IndexedScrollController();
  int _crossAxisCount = 3;
  Axis _direction = Axis.vertical;
  bool _showIndicators = true;
  bool _showEmpty = false;

  @override
  void dispose() {
    _controller.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      30,
      (i) => Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.primaries[i % Colors.primaries.length],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Text(
            '${i + 1}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('s_gridview Example'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Grid with Index Scrolling',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _crossAxisCount = (_crossAxisCount % 5) + 1;
                      }),
                      child: Text(
                          '${_direction == Axis.vertical ? 'Columns' : 'Rows'}: $_crossAxisCount'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _direction = _direction == Axis.vertical
                            ? Axis.horizontal
                            : Axis.vertical;
                      }),
                      child: Text(
                        _direction == Axis.vertical ? 'Horizontal' : 'Vertical',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _showIndicators = !_showIndicators;
                      }),
                      child: Text(
                        _showIndicators ? 'Hide Indicators' : 'Show Indicators',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _showEmpty = !_showEmpty;
                      }),
                      child: Text(
                        _showEmpty ? 'Show Items' : 'Show Empty State',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _controller.scrollToIndex(
                      15,
                      alignmentOverride: 0.35,
                      itemCount: items.length,
                    );
                  },
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text('Scroll to #16'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SGridView(
                controller: _controller,
                crossAxisItemCount: _crossAxisCount,
                mainAxisDirection: _direction,
                itemPadding: const EdgeInsets.all(4),
                showScrollIndicators: _showIndicators,
                indicatorColor: Colors.amber,
                emptyStateWidget: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No items to display',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                ),
                children: _showEmpty ? [] : items,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
