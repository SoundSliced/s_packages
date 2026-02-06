import 'package:s_packages/s_packages.dart';

class IndexscrollListviewBuilderExampleScreen extends StatefulWidget {
  const IndexscrollListviewBuilderExampleScreen({super.key});

  @override
  State<IndexscrollListviewBuilderExampleScreen> createState() =>
      _IndexscrollListviewBuilderExampleScreenState();
}

class _IndexscrollListviewBuilderExampleScreenState
    extends State<IndexscrollListviewBuilderExampleScreen> {
  int _itemCount = 50;
  int? _scrollToIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IndexScrollListViewBuilder Example'),
      ),
      body: Column(
        children: [
          // Controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scroll to index programmatically',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => _scrollToIndex = 0),
                      child: const Text('Top'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => setState(() => _scrollToIndex = 25),
                      child: const Text('Middle'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () =>
                          setState(() => _scrollToIndex = _itemCount - 1),
                      child: const Text('Bottom'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Item count: $_itemCount'),
                Slider(
                  value: _itemCount.toDouble(),
                  min: 10,
                  max: 100,
                  divisions: 18,
                  label: _itemCount.toString(),
                  onChanged: (value) =>
                      setState(() => _itemCount = value.toInt()),
                ),
              ],
            ),
          ),

          // List with basic usage
          Expanded(
            child: IndexScrollListViewBuilder(
              itemCount: _itemCount,
              indexToScrollTo: _scrollToIndex,
              onScrolledTo: (index) {
                // Reset to null after scrolling to prevent re-scrolling on rebuild
                if (_scrollToIndex != null && mounted) {
                  setState(() => _scrollToIndex = null);
                }
              },
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                    title: Text('Item ${index + 1}'),
                    subtitle: Text('Index: $index'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
